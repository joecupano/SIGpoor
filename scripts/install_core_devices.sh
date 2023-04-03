#!/bin/bash

###
### SIGpoor
###
### install_core_sdrdevices
###

echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR} ##   Install Core Devices"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_RESET}"

# RTL-SDR
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - RTLSDR "
echo -e "${SIGPI_BANNER_RESET}"

## DEPENDENCIES
sudo apt-get install -y libusb-1.0-0-dev
sudo pip3 install pyrtlsdr

# INSTALL
cd $SIGPI_SOURCE
git clone https://github.com/osmocom/rtl-sdr.git
cd rtl-sdr
mkdir build	&& cd build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
sudo make install
sudo cp ../rtl-sdr.rules /etc/udev/rules.d/
sudo ldconfig


# HackRF
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - HackRF "
echo -e "${SIGPI_BANNER_RESET}"

## DEPENDENCIES
sudo apt-get install -y libusb-1.0-0-dev libfftw3-dev

## INSTALL
cd $SIGPI_SOURCE
git clone https://github.com/mossmann/hackrf.git
cd hackrf/host
mkdir build && cd build
cmake .. -Wno-dev
make -j4
sudo make install
sudo ldconfig

# SoapySDR
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - SoapySDR "
echo -e "${SIGPI_BANNER_RESET}"

## DEPENDENCIES
sudo apt-get install -y swig
sudo apt-get install -y avahi-daemon
sudo apt-get install -y libavahi-client-dev
sudo apt-get install -y libusb-1.0-0-dev
sudo apt-get install -y python-dev python3-dev

## INSTALL
cd $SIGPI_SOURCE
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
mkdir build && cd build
cmake ../ -Wno-dev -DCMAKE_BUILD_TYPE=Release
make -j4
sudo make install
sudo ldconfig
SoapySDRUtil --info

# SoapyRTLSDR
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - SoapyRTLSDR "
echo -e "${SIGPI_BANNER_RESET}"

cd $SIGPI_SOURCE
git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
mkdir build && cd build
cmake .. -Wno-dev -DCMAKE_BUILD_TYPE=Release
make
sudo make install
sudo ldconfig

# SoapyHackRF
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - SoapyHackRF "
echo -e "${SIGPI_BANNER_RESET}"

cd $SIGPI_SOURCE
git clone https://github.com/pothosware/SoapyHackRF.git
cd SoapyHackRF
mkdir build && cd build
cmake .. -Wno-dev -DCMAKE_BUILD_TYPE=Release
make
sudo make install
sudo ldconfig

# SoapyRemote
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - SoapyRemote "
echo -e "${SIGPI_BANNER_RESET}"

cd $SIGPI_SOURCE
git clone https://github.com/pothosware/SoapyRemote.git
cd SoapyRemote
mkdir build && cd build
cmake .. -Wno-dev
make
sudo make install
sudo ldconfig

# GPS
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ###   - GPS (Chrony) "
echo -e "${SIGPI_BANNER_RESET}"

sudo apt-get install -y gpsd chrony

echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##   Core Devices Installed"
echo -e "${SIGPI_BANNER_RESET}"