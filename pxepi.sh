#!/bin/bash
# by Greg Lawler greg@outsideopen.com
#

##### Defaults when there are no defaults
: ${pieepromdir:=/lib/firmware/raspberrypi/bootloader/critical/}
: ${name:=pieeprom-}

function pieeprom-version() {
    newest-pieeprom=$(find "$pieepromdir/" -name "$name*" | sort | tail -1)
    echo $newest-pieeprom
}

pieeprom-version()

