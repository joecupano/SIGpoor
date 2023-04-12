#!/usr/bin/python3
#
#   radioDASH Command Library
#
#       USAGE: radioDASH_cmdlib.py 
#
#       Ⓒ2021 Joe Cupano, NE2Z
#
#       RELEASE: 20210320-2300
#       LICENSE: GPLv2
#
#


class CAPcom:
    def __init__(self):
        self.verb = ""
        self.noun = ""
        self.value = ""
        self.result = ""
    
    def parse(self, message):
        messageParse = message.split (':')
        self.verb = messageParse[0]
        self.noun = messageParse[1]
        self.value = messageParse[2]

    def execute(self, verb, noun, value):     
        if noun == "RX":
            self.result = self.rx(verb, value)
        if noun == "TX":
            self.result = self.tx(verb, value)
        if noun == "BEACON":
            self.result = self.beacon(verb, value)
        if noun == "RADIO":
            self.result = self.radio(verb, value)
        if noun == "TXPWR":
            self.result = self.txpwr(verb, value)
        if noun == "FREQUENCY":
            self.result = self.frequency(verb, value)
        if noun == "CHANNEL":
            self.result = self.channel(verb, value)
        if noun == "MODE":
            self.result = self.mode(verb, value)
        return (self.result)
    
    def rx(self, verb, value):
        if verb == "BROADCAST":
            ## Send RX message back to Websocks
            result = "BROADCAST:RX:" + value
        return (result)
    
    def tx(self, verb, value):
        if verb == "SET":
            ## Send TX message to radio
            ## HASit.transmit(value)
            result = "ACK:SET:TX:" + value
        return (result)

    def beacon(self, verb, value):
        if verb == "SET":
            if value == "ON":
                ## Turn Beacon on routine
                result = "ACK:BEACON:ON"
            if value == "OFF":
                ## Turn Beacon on routine
                result = "ACK:BEACON:OFF"
        return (result)

    def radio(self, verb, value):
        result = "ACK:"
        return (result)
    
    def txpwr(self, verb, value):
        if verb == "SET":
            if value == "LOW":
                ## Set TX power LOW routine
                result = "ACK:TXPWR:LOW"
            if value == "MEDIUM":
                ## Set TX power MEDIUM routine
                result = "ACK:TXPW:MEDIUM"
            if value == "HIGH":
                ## Set TX power HIGH routine
                result = "ACK:TXPW:HIGH"
        return (result)
    
    def frequency(self, verb, value):
        if verb == "SET":
            ## Set frequency on radio
            result = "ACK:SET:FREQUENCY:" + value
        return (result)
    
    def channel(self, verb, value):
        result = "ACK:"
        return (result)
    
    def mode(self, verb, value):
        result = "ACK:"
        return (result)
    

