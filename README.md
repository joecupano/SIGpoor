# SIGpoor

ALPHA

## Introduction

Simple Packet Radio (AX.25) and SDR server for RPi2/3 running **Raspberry Pi OS Lite (32-bit)**
RTLSDR and HackRF installed by default with the option to run RTL-TCP or SoapySDR server
software on startup. Install available for other well known SDRs.

## Installation

- Login as pi 

```
sudo apt update && sudo apt upgrade
sudo apt-get install -y build-essential cmake git
cd ~
mkdir ~/SIG && cd ~/SIG
git clone https://github.com/joecupano/SIGpoor.git
cd SIGpoor
./SIGpoor_installer.sh [CALLSIGN]
```

 whereas:
            CALLSIGN if using Packet

## Release Notes
* [over here](RELEASE_NOTES.md)
