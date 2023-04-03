# SIGpoor

RELEASE 1.0

## Introduction

SIGpoor is a low-end headless SDR and Packet Server
on **Raspberry Pi2 B** with 8GB microSD card running **Raspberry Pi OS Lite (32-bit)**

## Features

### Upgrade with modules, not fresh images
SIGpi includes it's own package manager to update applications to their latest releases using familiar syntax from package management systems

```
Usage: sigpi [ACTION] [TARGET]
          ACTION  
                 install   install TARGET from current release
                 remove    remove installed TARGET
                 purge     remove installed TARGET and purge configs
                 update    check to see if new TARGET available
                 upgrade   upgrade TARGET to latest release

          TARGET
                 A SIGpi package
```

You can update packages in your existing SIGpi install with the following commands using **SDRangel** and **SDR++** as examples:

```
SIGpi purge sdrangel
SIGpi install sdrangel
SIGpi purge sdrpp
SIGpi install sdrpp
```

### Add/Remove Packages anytime
Perhaps you forgot to add an application during your initial run of SIGpi_installer or there is a new software release available of SDRangel. **SIGpi** includes its own application management system akin to OS package management systems like APT. The difference is sigpi manages
applications whether they are from the distro releases or compiled from other repos such as Github. This enables you to just install the **base** system and go back and add inidividual applications. sigpi can periodically be run to check on availability of new applications and upgrade them.
```
 Usage:    SIGpi [ACTION] [TARGET]

        ACTION  
                 install   install TARGET application from current release
                 remove    remove installed TARGET application
                 purge     remove installed TARGET application and purge configs
                 update    check to see if new TARGET application available
                 upgrade   upgrade TARGET application to latest release
                 shell     wrap SIGpi environment variables around a TARGET script

        TARGET
                 A SIGpi package or script
```
Example
```
SIGpi install kismet
```

### Package Updates
Best efforts made to update releases when significant releases (X.Y) are made available for component packages with speciall attention to popular SDR packages like SDRangel and SDR++

### Multi-Architecture
Though our first priority of support platforms is the **Raspberry Pi4 4GB RAM** running **Raspberry Pi OS Full (64-bit)**, this build will install and run on **Ubuntu 22.04 LTS** (amd64 and aarch64)

### Amateur Radio
While tools are included for Amateur Radio, it is not this builds focus. We are focused on the ability to detect and decipher the range of RF signals around us from consumer IoT to critical infrastructure for educational purposes and provide tools to assist those with spectrum planning responsibiity to better visualize spectrum utilization around them.


## Installation

- Login as pi or sudo user on supported platform
- Update and install pre-requisite packages to install SIGpi
- From your home directory, create a directory called SIG and switch into it
- Clone the SIGpi repo 
- Change directory into SIGpi

```
sudo apt update && sudo apt upgrade
sudo apt-get install -y build-essential cmake git
cd ~
mkdir ~/SIG && cd ~/SIG
git clone https://github.com/joecupano/SIGpoor.git
cd SIGpoor
./SIGpoor_installer.sh node
```

During installation you will have the option to run either RTL-TCP, SDRangel Server, or SoapySDR server on startup or choose not to start 
any of them. 

## Release Notes
* [over here](RELEASE_NOTES.md)
