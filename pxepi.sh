#!/bin/bash
# by Greg Lawler
# greg@outsideopen.com
#
##### Defaults
: ${pieepromdir:=/lib/firmware/raspberrypi/bootloader/beta/}
: ${pname:=pieeprom-}

if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root' >&2
    exit 1
fi

function isPi4 () {
#    piModel=$(cat /proc/device-tree/model)
    piModel=$(tr -d '\0' < /proc/device-tree/model)
    IFS=" "
    read -ra ADDR <<<"$piModel"
    currentModel=${ADDR[2]}
    if [ $currentModel != "4" ] ; then
      echo $piModel
      echo "ERROR: Raspberry Pi 4 not detected"
      exit 1
    fi
}

function isPxeBoot {
    bootOrder=$(vcgencmd bootloader_config | grep BOOT_ORDER | awk -F "= " "{print $1}")
    IFS="="
    read -ra ADDR <<<"$bootOrder"
    currentBootorder=${ADDR[1]}
    if [ $currentBootorder == "0x21" ] ; then
      echo "PXE boot is enabled, BOOT_ORDER=$currentBootorder"
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

function pieeprom_config() {
    get_pieeprom=$(find "$pieepromdir" -type f -name "$pname*" | sort | tail -1)
    latest_pieeprom=$(basename $get_pieeprom)
    CP_MSG=$(cp $get_pieeprom $latest_pieeprom.tmp)
    echo "Copying, $latest_pieeprom to current directory"
    echo $CP_MSG
    rpi-eeprom-config $latest_pieeprom.tmp > eeprom-config.txt
    sed -i 's/BOOT_ORDER=0x1/BOOT_ORDER=0x21/gI' eeprom-config.txt
    rpi-eeprom-config --out pxepi-eeprom.bin --config eeprom-config.txt $latest_pieeprom.tmp
    rpi-eeprom-update -d -f pxepi-eeprom.bin
 }

isPi4
isPxeBoot
