


.PHONY: clean flash

SOURCES=main.c interpreter.S parser.c
MMCU=atmega328

CC=avr-gcc
RM=rm -f

# standard: compile and copy into hex for flashing
all:	$(MMCU).hex

# compiles into axf
$(MMCU).axf:  $(SOURCES)
	$(CC) -Wall -gdwarf-2 -Os -std=gnu99 \
			-mmcu=$(MMCU) \
			-DF_CPU=16000000 \
			-fno-inline-small-functions \
			-ffunction-sections -fdata-sections \
			-Wl,--relax,--gc-sections \
			-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000,--section-start=.ijr=0x4000 \
			-I./simavr/simavr/sim/avr  \
			$^  -o $@

# object-copy into hex file
$(MMCU).hex:	$(MMCU).axf
	avr-objcopy -O ihex  $< $@

clean:
	$(RM) *.o
	$(RM) *.hex
	$(RM) *.axf


