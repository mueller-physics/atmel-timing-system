#!/bin/bash

startAddr=$( avr-nm atmega328.axf -n -t d | grep "D __data_start" | grep -oE '[1-9][0-9]*' )
endAddr=$( avr-nm atmega328.axf -n -t d | grep "D __data_end" | grep -oE '[1-9][0-9]*' )

echo "$startAddr, $endAddr --> $(( $endAddr - $startAddr)) bytes used."
echo "$(( 2048 + $startAddr - $endAddr )) bytes left for stack at 2k ram"

