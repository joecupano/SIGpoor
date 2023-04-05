#!/bin/bash

###
### SIGpoor_installer
###

###
###  REVISION: 202300404-2300
###

###
###  Usage:    SIGpoor_installer  [CALLSIGN] 
###
###  where:
###            CALLSIGN if using ax.25
###

###
### INIT VARIABLES AND DIRECTORIES
###

# SIGpi Directory tree
SIGPI_ROOT=$HOME/SIG
SIGPI_SOURCE=$SIGPI_ROOT/source
SIGPI_HOME=$SIGPI_ROOT/SIGpoor
SIGPI_ETC=$SIGPI_ROOT/etc
SIGPI_SCRIPTS=$SIGPI_HOME/scripts
SIGPI_PACKAGES=$SIGPI_HOME/packages
SIGPI_DEBS=$SIGPI_HOME/debs
SIGPI_AX25FILES=$SIGPI_HOME/templates/ax25

# SIGpi Install Support files
SIGPI_INSTALLER=$SIGPI_ETC/INSTALL_CONFIG
SIGPI_CONFIG=$SIGPI_ETC/INSTALLED
SIGPI_PKGLIST=$SIGPI_PACKAGES/PACKAGES
SIGPI_INSTALL_TXT=$SIGPI_SCRIPTS/scr_install_welcome.txt
SIGPI_BANNER_COLOR="\e[0;104m\e[K"   # blue
SIGPI_BANNER_RESET="\e[0m"

# Detect architecture (x86, x86_64, aarch64, ARMv8, ARMv7)
SIGPI_HWARCH=`lscpu|grep Architecture|awk '{print $2}'`
# Detect Operating system (Debian GNU/Linux 11 (bullseye) or Ubuntu 20.04.3 LTS)
SIGPI_OSNAME=`cat /etc/os-release|grep "PRETTY_NAME"|awk -F'"' '{print $2}'`
# Is Platform good for install- true or false - we start with false
SIGPI_CERTIFIED="false"

# Are we where we should be
if [ -f /home/$USER/SIG/SIGpoor/SIGpoor_installer.sh ]; then
    echo
else
    echo "ERROR:  300 - Software install setup issue"
    echo "ERROR:"
    echo "ERROR:  Repo must be cloned from within /home/$USER/SIG directory"
    echo "ERROR:  and SIGpoor_installer.sh run from there."
    echo "ERROR:"
    echo "ERROR:  Aborting"
    exit 1;
fi


###
### FUNCTIONS
###

calc_wt_size() {

  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error 
  # output from tput. However in this case, tput detects neither stdout or 
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=26
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=60
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=80
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}

select_startscreen(){
    TERM=ansi whiptail --title "SIGpoor Installer" --clear --textbox $SIGPI_INSTALL_TXT 34 100 16
}

select_sdrdevices() {
    FUN=$(whiptail --title "SDR Devices" --clear --checklist --separate-output \
        "RTLSDR and HackRF support are installed by default. Select additional supported SDR devices below if need be" 20 100 12 \
        "bladerf" "bladeRF        " OFF \
        "limesuite" "LimeSDR        " OFF \
        "pluto" "Pluto SDR        " OFF \
        "sdrplay" "SDRPlay        " OFF \
        "rfm95w" "Adafruit LoRa Radio Bonnet - RFM95W @ 915 MHz        " OFF \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

select_sdrserver() {
    FUN=$(whiptail --title "SDR Server Startup" --clear --checklist --separate-output \
        "Choose which SDR server to run as a service" 20 80 12 \
        "noserver" "No SDR Server on startup                     " OFF \
        "rtltcpsrv" "RTL-TCP on startup                          " OFF \
        "soapysdrsrv" "SoapySDR on startup                       " OFF \
		3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

select_optdecoders() {
    FUN=$(whiptail --title "Optional SDR Decoders" --clear --checklist --separate-output \
        "Select optional signal decoders" 20 80 12 \
        "aptdec" "APTdec (NOAA APT)                     " OFF \
        "codec2" "Codec 2. low-bitrate open source speech audio codec        " OFF \
        "dsdcc" "DSDcc (Digital Speech Decoder)             " OFF \
        "mbelib" "MBelib P25 Phase 1 and ProVoice vocoder      " OFF \
        "radiosonde" "Radiosonde (Atmospheric Telemetry)     " OFF \
        "serialdv" "AMBE3000 chip serial control              " OFF \
		3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

select_tncdevices() {
    FUN=$(whiptail --title "AX.25 Device" --clear --checklist --separate-output \
        "Which type of TNC will you be using" 20 100 12 \
        "serialtnc" "Serial-attached TNC         " OFF \
        "softtnc" "Software TNC (Direwolf)        " OFF \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

select_packetmode() {
    FUN=$(whiptail --title "AX.25 Configure" --clear --checklist --separate-output \
        "Choose desired AX.25 setting" 20 80 12 \
        "simple-ax25" "ax0 interface only " OFF \
        "network-ax25" "ax0 plus AXIP support " OFF \
		3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

select_usefultools() {
    FUN=$(whiptail --title "Optional Tools" --clear --checklist --separate-output \
        "Only select these tools if you know you will need them" 24 120 12 \
        "dump1090" "Mode S decoder" OFF \
        "hamlib" "Ham Radio Control Libraries 4.5.3 " OFF \
        "kismet" "A sniffer for Wi-Fi, Bluetooth, Zigbee, RF, and more " OFF \
        "linpac" "AX.25 kbd-kbd chat and PBBS program " OFF \
        "multimon-ng" "Decoder for POCSAG512 POCSAG1200 POCSAG2400 AFSK DTMF CW X10ers " OFF \
        "ubertooth" "Ubertooth Tools for Bluetooth " OFF \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        $FUN = "NONE"
    fi

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$FUN"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        echo $FUN >> $SIGPI_INSTALLER
    done
}

###
###  MAIN
###

# Setup directories
mkdir $SIGPI_ETC
touch $SIGPI_CONFIG
mkdir $SIGPI_SOURCE
cd $SIGPI_SOURCE

##
##  Install Menu
##

calc_wt_size
select_startscreen
select_sdrdevices
select_sdrserver
select_optdecoders
select_tncdevices
select_packetmode
select_usefultools

TERM=ansi whiptail --title "SIGpoor Install" --clear --msgbox "Ready to Install" 12 120

##
##  Update, Upgrade, Dependences, SIGpoor commands
##

echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR} ##   System Update & Upgrade"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_RESET}"

sudo apt-get -y update
sudo apt-get -y upgrade

touch $SIGPI_CONFIG
echo "sigpi_node" >> $SIGPI_CONFIG
cd $SIGPI_SOURCE

source $SIGPI_SCRIPTS/install_dependencies.sh
source $SIGPI_SCRIPTS/install_core_devices.sh

# Copy SIGpi commands into /usr/local/bin
sudo cp $SIGPI_HOME/scripts/SIGpi_exec-in-shell.sh /usr/local/bin/SIGpi_exec-in-shell 
sudo cp $SIGPI_HOME/scripts/SIGpi.sh /usr/local/bin/SIGpi

##
## SDR Additional Devices
##

# Install bladeRF
if grep bladerf "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_bladerf install
fi
# Install LimeSDR
if grep limesuite "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_limesuite install
fi
# Install PlutoSDR
if grep pluto "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_plutosdr install
fi
# Install SDRPlay
if grep sdrplay "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_sdrplay install
fi
# Install RFM95W (Adafruit RadioBonnet 900 MHz LoRa-FSK)
if grep rfm95w "$SIGPI_INSTALLER"; then
    source $SIGPI_SCRIPTS/install_devices_rfm95w.sh
fi

##
## Install Optional decoders
##

# Install APTdec (NOAA APT)
if grep aptdec "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_aptdec install
fi
# Install cm256cc
source $SIGPI_PACKAGES/pkg_cm256cc install

# Install mbelib (P25 Phase)
if grep mbelib "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_mbelib install
fi
# Install SeriaDV (AMBE3000 chip serial control)
if grep serialdv "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_serialdv install
fi
# Install Codec 2
if grep codec2 "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_codec2 install
fi
# Install Radiosonde (Atmospheric Telemetry)
if grep radiosonde "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_radiosonde install
fi

##
## Install AX.25 and device configurations
##

# Install AX.25
source $SIGPI_PACKAGES/pkg_ax25 install
# Install Direwolf (AX.25 AFSK APRS)
if grep softtnc "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_direwolf install $1
fi
# Config Simple AX25 with CALLSIGN from args
if grep simple-ax25 "$SIGPI_INSTALLER"; then
    source $SIGPI_SCRIPTS/cfg_simple-ax25 install $1
fi
# Config Network AX25 with CALLSIGN  from args
if grep network-ax25 "$SIGPI_INSTALLER"; then
    source $SIGPI_SCRIPTS/cfg_network-ax25 install $1
fi

##
## Install SDR cmdline apps
##

# Install RTL_433
source $SIGPI_PACKAGES/pkg_rtl_433 install

##
## Install Optional Tools
##

# Install Dump1090
if grep bladerf "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_dump1090 install
fi
# Install Hamlib
if grep hamlib "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_hamlib install
fi
# Install Kismet
if grep kismet "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_kismet install
fi
# Install Linpac
if grep linpac "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_linpac install
fi
# Install Multimon-NG
if grep multimon-ng "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_multimon-ng install
fi
# Install Ubertooth Tools
if grep ubertooth "$SIGPI_INSTALLER"; then
    source $SIGPI_PACKAGES/pkg_ubertooth-tools install
fi

##
## Setup SDR servers if requested
##

if grep rtltcpsrv "$SIGPI_INSTALLER"; then
    sudo cp $SIGPI_SOURCE/scripts/sigpi_node_rtltcp.service /etc/systemd/system/sigpoor.service
fi
if grep soapysdrsrv "$SIGPI_INSTALLER"; then
    sudo cp $SIGPI_SOURCE/scripts/sigpi_node_soapysdrsrv.service /etc/systemd/system/sigpoor.service
fi

echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR} ##   SIGpoor Installation Complete !!"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR}"
echo -e "${SIGPI_BANNER_COLOR} ##"
echo -e "${SIGPI_BANNER_COLOR} ##   System needs to reboot for all changes to occur"
echo -e "${SIGPI_BANNER_COLOR} ##   Reboot will begin in 15 seconsds unless CTRL-C hit"
echo -e "${SIGPI_BANNER_RESET}"
sleep 15
sudo sync
sudo reboot
exit 0
