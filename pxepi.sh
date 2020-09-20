#!/bin/bash
# by Greg Lawler greg@outsideopen.com
#

##### Defaults when there are no defaults
: ${pieepromdir:=/lib/firmware/raspberrypi/bootloader/critical/}
: ${pname:=pieeprom-}

if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root' >&2
    exit 1
fi

function pieeprom_config() {
    get_pieeprom=$(find "$pieepromdir" -type f -name "$pname*" | sort | tail -1)
    latest_pieeprom=$(basename $get_pieeprom)
    CP_MSG=$(cp $get_pieeprom $latest_pieeprom.tmp)
    echo "Copying, $latest_pieeprom to current directory"
    echo $CP_MSG
    rpi-eeprom-config $latest_pieeprom.tmp > bootconf.txt
 }

function isPxeBoot {
    bootOrder=$(vcgencmd bootloader_config | grep BOOT_ORDER | awk -F "= " "{print $1}")
    IFS="="
    read -ra ADDR <<<"$bootOrder"
    currentBootorder=${ADDR[1]}
    if [ $currentBootorder == "0x1" ] ; then
      echo $currentBootorder
      echo "PXE boot is enabled, BOOT_ORDER=0x21"
    else
      echo $currentBootorder
      echo "PXE boot is NOT enabled"
      enablePXE
    fi
}

function enablePXE() {
    echo "Verify eeprom is up to date..."
    UPG_MSG=$(rpi-eeprom-update -a)
    echo $UPG_MSG
    pieeprom_config
}
# pieeprom_version
isPxeBoot
