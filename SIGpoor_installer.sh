#!/bin/bash

###
### SIGpoor_installer
###

###
###  REVISION: 20230330-2300
###

###
###  Usage:    SIGpoor_installer  [CALLSIGN] [PASSWORD] 
###
###  where:
###            CALLSIGN if using ax.25
###            PASSWORD to be used to login into ax25-node
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

select_devices() {
    FUN=$(whiptail --title "SIGpoor Installer" --clear --checklist --separate-output \
        "RTLSDR and HackRF supported included by default. Choose additional SDR devices if need be" 20 100 12 \
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
    FUN=$(whiptail --title "SIGpoor Installer" --clear --checklist --separate-output \
        "Choose which SDR server to run as a service" 20 80 12 \
        "rtltcpsrv" "RTL-TCP Server                     " OFF \
        "soapysdrsrv" "SoapySDR Server                     " OFF \
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
    FUN=$(whiptail --title "SIGpi Installer" --clear --checklist --separate-output \
        "Choose desired AX.25 settings (USB-Serial attached TNC in KISS Mode assumed)" 20 80 12 \
        "no-ax25" "No AX.25 support " \
        "simple-ax25" "ax0 interface only " \
        "network-ax25" "ax0 plus AXIP support " \
        "simplestart-ax25" "ax0 interface only at boot " \
        "netstart-ax25" "ax0 plus AXIP support on boot " \
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
##  Install 
##

calc_wt_size
select_startscreen
select_devices
select_sdrserver
select_packetmode
TERM=ansi whiptail --title "SIGpoor Install" --clear --msgbox "Ready to Install" 12 120

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
# Install Simple AX25 with CALLSIGN and PASSWORD from args
if grep simple-ax25 "$SIGPI_INSTALLER"; then
    source $SIGPI_SCRIPTS/pkg_simple-ax25 install $1 $2
fi
# Install Network AX25 with CALLSIGN and PASSWORD from args
if grep network-ax25 "$SIGPI_INSTALLER"; then
    source $SIGPI_SCRIPTS/pkg_network-ax25 install $1 $2
fi
# Install APTdec (NOAA APT)
source $SIGPI_PACKAGES/pkg_aptdec install
# Install cm256cc
source $SIGPI_PACKAGES/pkg_cm256cc install
# Install mbelib (P25 Phase)
source $SIGPI_PACKAGES/pkg_mbelib install
# Install SeriaDV (AMBE3000 chip serial control)
source $SIGPI_PACKAGES/pkg_serialdv install
# Install DSDcc (Digital Speech Decoder)
source $SIGPI_PACKAGES/pkg_dsdcc install
# Install Codec 2
source $SIGPI_PACKAGES/pkg_codec2 install
# Install Radiosonde (Atmospheric Telemetry)
source $SIGPI_PACKAGES/pkg_radiosonde install
# Install Ubertooth Tools
source $SIGPI_PACKAGES/pkg_ubertooth-tools install
# Install Direwolf (AFSK APRS)
source $SIGPI_PACKAGES/pkg_direwolf install
# Install RTL_433
source $SIGPI_PACKAGES/pkg_rtl_433 install
# Install Dump1090
source $SIGPI_PACKAGES/pkg_dump1090 install
  
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
