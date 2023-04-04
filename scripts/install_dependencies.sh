#!/bin/bash

###
### SIGpoor
###
### installer_server_dependencies
###


echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR} ##   Install Dependencies"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_RESET}"

# Baseline
sudo apt-get install -y build-essential pkg-config git cmake g++ gcc autoconf automake libtool 
sudo apt-get install -y libssl-dev libavahi-client-dev libavahi-common-dev libaio-dev
sudo apt-get install -y libtool libudev1 libusb-1.0-0 libusb-1.0-0-dev libusb-dev
sudo apt-get install -y libsamplerate-dev

# Python Baseline
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-numpy
sudo apt-get install -y python3-scapy
sudo apt-get install -y python3-scipy
sudo apt-get install -y python3-setuptools
sudo apt-get install -y python-docutils
sudo apt-get install -y python3-dbg
sudo pip3 install pyinstaller
sudo pip3 install pygccxml

# SDRdevice Baseline

## RTLSDR
sudo apt-get install -y libudev1 
sudo apt-get install -y libusb-1.0-0 
sudo apt-get install -y libusb-1.0-0-dev
sudo apt-get install -y libusb-dev
sudo pip3 install pyrtlsdr
## HackRF
sudo apt-get install -y libusb-1.0-0-dev 
sudo apt-get install -y libfftw3-dev
## SoapySDR 
sudo apt-get install -y swig
sudo apt-get install -y avahi-daemon
sudo apt-get install -y libavahi-client-dev
sudo apt-get install -y libusb-1.0-0-dev
sudo apt-get install -y python-dev
sudo apt-get install -y python3-dev

echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##   Dependencies Installed"
echo -e "${SIGPI_BANNER_RESET}"
