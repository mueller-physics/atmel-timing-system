#!/bin/bash

function ctrlc() {
    kill $PIDSIMAVR
}
trap ctrlc SIGINT

echo "Starting SIMAVR with SIMDUINO... "

cd ./simavr/examples/board_simduino/
export SIMAVR_UART_XTERM=1 
obj-x86_64-linux-gnu/simduino.elf &
PIDSIMAVR=$!
cd ../../../
echo " -> simavr: $PIDSIMAVR"

echo "Flashing firmware..."
avrdude -c arduino -P /tmp/simavr-uart0 -U flash:w:atmega328.hex  -p atmega328p


echo -e "========\ndone.\n Press CTRL-c to stop the simulator"

wait



