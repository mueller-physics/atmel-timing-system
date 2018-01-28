

all:	main.c interpreter.S
	avr-gcc -Wall -gdwarf-2 -Os -std=gnu99 \
			-mmcu=atmega48 \
			-DF_CPU=16000000 \
			-fno-inline-small-functions \
			-ffunction-sections -fdata-sections \
			-Wl,--relax,--gc-sections \
			-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000 \
			-I/home/marcel/tmp/simavr/simavr/sim/avr  \
			main.c interpreter.S -o test.axf