#!/usr/bin/python3
#
#   radioDASH Server
#
#       USAGE: radioDASH.py 
#
#       Ⓒ2021 Joe Cupano, NE2Z
#
#       RELEASE: 20210320-2300
#       LICENSE: GPLv2
#
#


#
# IMPORT LIBRARIES
#

import asyncio
import argparse 
import binascii
import gc
import hashlib
import json
import os
import ssl
import sys
import threading
import time
import tornado.httpserver
import tornado.ioloop
import tornado.web
import tornado.websocket
import tornado.gen
from tornado.options import define, options
import uuid
import radioDASHcmdlib
from radioDASHcmdlib import CAPcom


#
# VARIABLES
#

define("port", default=8000, help="run on the given port", type=int)
wsxCLIENTS = []                                                          # Client Connection Tracking for Tornado
radioDASHRXLOCK = False                                                  # True = RX is running
radioDASHTXLOCK = False                                                  # True = TX is running
radioDASHserverpath = "/home/pi/radiodash/server/"                       # Path to files. Change when Pi
radioDASHcfg = "/home/pi/radiodash/cfg/radioDASH.json"                   # Config file is in JSON format
radioDASHpwf = "/home/pi/radiodash/cfg/radioDASH.pwf"                    # Password file  user:hashedpasswd
radioDASHlogin = radioDASHserverpath + "static/radioDASH_LOGIN.html"
radioDASHlogincss = radioDASHserverpath + "static/radioDASH_LOGIN.css"
radioDASHindex = radioDASHserverpath + "static/radioDASH_INDEX.html"
radioDASHindexcss = radioDASHserverpath + "static/radioDASH.css"
radioDASHjs = radioDASHserverpath + "static/radioDASH.js"

dashVERB = ""
dashNOUN = ""
dashVALUE = ""
dashRESPONSE = ""


stored_password = ""                                                     # hashedpassword stored in Password file
currmsg_ts = ""
lastmsg_ts = ""

#
# CLASSES
#

class DASHini:
    def __init__(self):
        with open(radioDASHcfg) as configFileJson:
            jsonConfig = json.load(configFileJson)
        self.radio = jsonConfig["RADIO"]["rfmodule"]
        self.modemconfig = jsonConfig["RADIO"]["modemconfig"]
        self.modem = jsonConfig["RADIO"]["modem"]
        self.frequency = jsonConfig["RADIO"]["frequency"]
        self.spreadfactor = jsonConfig["RADIO"]["spreadfactor"]
        self.codingrate4 = jsonConfig["RADIO"]["codingrate4"]
        self.bandwidth = jsonConfig["RADIO"]["bandwidth"]
        self.txpwr = jsonConfig["RADIO"]["txpwr"]
        self.mycall = jsonConfig["CONTACT"]["mycall"]
        self.myssid = jsonConfig["CONTACT"]["myssid"]
        self.mybeacon = jsonConfig["CONTACT"]["mybeacon"]
        self.dstcall = jsonConfig["CONTACT"]["dstcall"]
        self.dstssid = jsonConfig["CONTACT"]["dstssid"]
        self.mystation = self.mycall + "-" + str(self.myssid)

class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        return self.get_secure_cookie("radioDASHuser")

class MainHandler(BaseHandler):
    @tornado.web.authenticated
    def get(self):
        self.render('static/radioDASH_INDEX.html')

class LoginHandler(BaseHandler):
    def get(self):
        self.render('static/radioDASH_LOGIN.html')

    def post(self):
        fusername = self.get_argument("fusername")
        fpassword = self.get_argument("fpassword")
        if find_user(fusername) == "":
            self.redirect("/login")
        stored_password = find_password(fusername)
        verdict = verify_password(stored_password, fpassword)
        if verdict == True:
            self.set_secure_cookie("radioDASHuser", str(uuid.uuid4()), secure=True, expires_days=1)
            self.redirect("/")

class WebSocketHandler(tornado.websocket.WebSocketHandler):

    @classmethod
    def on_rxradio(self, message):
        print ("WS:RXRADIO:" + message)
        for client in wsxCLIENTS:
            client.write_message(message)

    def cl_multicast(self, message):
        print ("WS:MULTICAST:" + message)
        for client in wsxCLIENTS:
            client.write_message("WS:CLIENTS:", wsxCLIENTS)

    def open(self):
        if self not in wsxCLIENTS:
            wsxCLIENTS.append(self)
        print ('WS:CLIENT:NEW')
        self.write_message("WS:CLIENT:CONNECTED")

    def on_message(self, message):
        print ('WS:CLIENT: %s' % message)
        DASHcmd.parse(message)
        dashRESPONSE = DASHcmd.execute(dashVERB, dashNOUN, dashVALUE)
        if dashVERB == "BROADCAST":
            ## Send received to all clients
            self.cl_multicast(dashRESPONSE)
        else:
            self.write_message(dashRESPONSE)
   
    def on_close(self):
        if self not in wsxCLIENTS:
            wsxCLIENTS.remove(self)
        print ('WS:CLIENT:CLOSED')
        self.write_message("WS:CLIENT:CLOSED")
        gc.collect()


#
# GLOBAL FUNCTIONS
#

def verify_password(stored_password, provided_password):
    """Verify a stored password against one provided by username"""
    salt = stored_password[:64]
    stored_password = stored_password[64:]
    pwdhash = hashlib.pbkdf2_hmac('sha512', provided_password.encode('utf-8'), salt.encode('ascii'), 100000)
    pwdhash = binascii.hexlify(pwdhash).decode('ascii')
    return pwdhash == stored_password

def find_user(user):
    userfound=""
    f = open(radioDASHpwf, "r")
    flines = f.readlines()
    for fl in flines:
        fluser = fl.split(":")
        if user == fluser[0]:
            userfound = fluser[0]
    f.close()
    return (userfound)

def find_password(user):
    userpassword = ""
    f = open(radioDASHpwf, "r")
    flines = f.readlines()
    for fl in flines:
        fluser = fl.split(":")
        if user == fluser[0]:
            userpassword = (fluser[1]).rstrip()
    f.close()
    return (userpassword)


#
# MAIN
#

def main():
    tornado.options.parse_command_line()

    settings = {
        "cookie_secret":"gWsdN18jkIWNmksfh2poINsJxZZ83Vo=",
        "login_url": "/login",
    }

    app = tornado.web.Application(
        handlers=[
            ('/wss', WebSocketHandler),
            ('/', MainHandler),
            ('/login', LoginHandler),
            ('/css/(.*)', tornado.web.StaticFileHandler, {'path': 'css/'}),
            ('/js/(.*)', tornado.web.StaticFileHandler, {'path': 'js/'}),
            ('/cfg/(.*)', tornado.web.StaticFileHandler, {'path': 'cfg/'}),
            ('/(.*)', tornado.web.StaticFileHandler, {'path': 'static/'})
        ], **settings
    )
    
    httpServer = tornado.httpserver.HTTPServer(app,
        ssl_options = {
            "certfile": os.path.join("cfg/radioDASH.crt"),
            "keyfile": os.path.join("cfg/radioDASH.key"),
        }
    )

    httpServer.listen(options.port)
    print (" ")
    print ("radioDASH Server started: listening on port:", options.port)
    print (" ")

    tornado.ioloop.IOLoop.instance().start()


#
# MAIN
#

DASHit = DASHini()
DASHcmd = CAPcom()
main()