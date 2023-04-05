# SIGpoor

ALPHA

## Introduction

Simple RPi 2/3 packet (ax/25) and SDR server (RTLSDR and HackRF only) running on **Raspberry Pi OS Lite (32-bit)**

## Installation

- Login as pi 

then 

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


During installation you will have the option to run either RTL-TCP or SoapySDR server on startup 

## Release Notes
* [over here](RELEASE_NOTES.md)
