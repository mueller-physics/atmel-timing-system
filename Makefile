


.PHONY: clean flash

SOURCES=main.c interpreter.S parser.c opcodes.c 
HEADERS=parser.h opcodes.h 
MMCU=atmega328

CC=avr-gcc
HOSTCC=gcc
RM=rm -f

# standard: compile and copy into hex for flashing
all:	$(MMCU).hex

# compiles into axf
$(MMCU).axf:  $(SOURCES) $(HEADERS)
	$(CC) -Wall -gdwarf-2 -Os -std=gnu99 \
			-mmcu=$(MMCU) \
			-DF_CPU=16000000 \
			-fno-inline-small-functions \
			-ffunction-sections -fdata-sections \
			-Wl,--relax,--gc-sections \
			-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000 \
			-I./simavr/simavr/sim/avr  \
			$^  -o $@
	avr-size -C --mcu=$(MMCU) $@

# object-copy into hex file
$(MMCU).hex:	$(MMCU).axf
	avr-objcopy -O ihex  $< $@


# compile parser also to run on host
hostparser:	main-host-parser.c parser.c opcodes.c $(HEADERS)
	    $(HOSTCC) $^ -o $@ -Wall -DNOAVR


clean:
	$(RM) hostparser
	$(RM) *.o
	$(RM) *.hex
	$(RM) *.axf


