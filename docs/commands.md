---
layout: default
title: ATMEL timing interpreter
---

## Pins

All pins on all ports can be accessed through the interpreter commands.
However, 2 input and 8 output pins are accessible with 1-byte instructions (saving space)
and with half-tick instructions (saving space and cycles).

Which pins are used by these instructions can be configured at compile time,
the default (for an Arduino Uno) is


| Nr | Pin | direction | Arduino |
| ---|---- | -------   | ------- |
|  0 | PC0 | input     |  A0     |  
|  1 | PC1 | input     |  A1     |  
| ---|---- | --------- | ------  |
|  2 | PD2 | output    |  d2     |
|  3 | PD3 | output    |  d3     |
|  4 | PD4 | output    |  d4     |
|  5 | PD5 | output    |  d5     |
|  6 | PD6 | output    |  d6     |
|  7 | PD7 | output    |  d7     |
|  8 | PB0 | output    |  d8     |
|  9 | PB1 | output    |  d9     |
| ---| --- | --------- | ------  |


## Commands for the timing interpreter:

These commands can be used to set pins, wait for pins to become low/high,
execute loops, etc.

Each command needs a certain number of tics to execute, where 1 tick corresponds to 16 cycles on the ATMEL.
On a 16 MHz system (Arduino), this means a tick takes exactly 1 microsecond.


| opcode | mnemonic | bytes | ticks | description  |	
| ------ | -------- | ----- | ----- | ------------ |
| 0x00	 | ter	    |	  1 |	  X | terminates the interpreter programm 
| 0x01	 | nop	    |	  1 |	  1 | does nothing (but takes a tick to do so)
| ------ | -------- | ----- | ----- | ------------ |
| 0x20   | dl1	    |     2 | 2 + n | delay for 2 + n ticks (n 0..2^7)
| 0x21   | dl2	    |     3 | 2 + n | delay for 2 + n ticks (n 0..2^15)
| 0x22   | dl3	    |     4 | 2 + n | delay for 2 + n ticks (n 0..2^31)
| ------ | -------- | ----- | ----- | --------------|
| 0x30   | ls1	    |     2 |     1 | loop starts here, for n counts (n 0..2^7)
| 0x31   | ls2	    |     3 |     1 | loop starts here, for n counts (n 0..2^15)
| ------ | -------- | ----- | ----- | --------------|


## 'fast' commands
 
The fast commands offer a limited set of operations that can be executed in half a tick 
(8 cycles, so 500 nanoseconds on a 16 MHz ATMEL). 

Which pins are 'fast pins' is detemined at compile time, i.e. it can be changed by
recompiling and reuploading the timing interpreter.


| opcode | mnemonic | description  |	
| ------ | -------- | ------------ |
| 0x80	 | fnp	    | 'fast' nop (0.5 ticks, 8 cycles)
| 0x84	 | fdc	    | decrement counter A
| 0x88   | flr	    | return to 'label A' if counter A >= 0
| ------ | -------- | ------------ |
| 0xA0   | f2l	    | set fast pin 2 to low
| 0xA2   | f2h	    | set fast pin 2 to high
| 0xA4   | f3l	    | set fast pin 3 to low
| 0xA6   | f3h	    | set fast pin 3 to high
| 0xA8   | f4l	    | set fast pin 4 to low
| 0xAA   | f4h	    | set fast pin 4 to high
| 0xAC   | f5l	    | set fast pin 5 to low
| 0xAE   | f5h	    | set fast pin 5 to high
| ------ | -------- | ------------ |
| 0xB0   | f6l	    | set fast pin 6 to low
| 0xB2   | f6h	    | set fast pin 6 to high
| 0xB4   | f7l	    | set fast pin 7 to low
| 0xB6   | f7h	    | set fast pin 7 to high
| 0xB8   | f8l	    | set fast pin 8 to low
| 0xBA   | f8h	    | set fast pin 8 to high
| 0xBC   | f9l	    | set fast pin 9 to low
| 0xBE   | f9h	    | set fast pin 9 to high
| ------ | -------- | ------------ |



