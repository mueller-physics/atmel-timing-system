

all: simulator real

simulator:	main.c interpreter.S
	avr-gcc -Wall -gdwarf-2 -Os -std=gnu99 \
			-mmcu=atmega328 \
			-DF_CPU=1000000 \
			-fno-inline-small-functions \
			-ffunction-sections -fdata-sections \
			-Wl,--relax,--gc-sections \
			-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000,--section-start=.ijr=0x4000 \
			-I/home/marcel/tmp/simavr/simavr/sim/avr  \
			main.c interpreter.S asmtest.S  -o test.axf


real:	main.c interpreter.S
	avr-gcc -Wall -gdwarf-2 -Os -std=gnu99 \
			-mmcu=atmega328p \
			-DF_CPU=16000000 \
			-fno-inline-small-functions \
			-ffunction-sections -fdata-sections \
			-Wl,--relax,--gc-sections \
			-I/home/marcel/tmp/simavr/simavr/sim/avr  \
			main.c interpreter.S asmtest.S  -o test.elf
	 avr-objcopy -O ihex  test.elf test.hex
