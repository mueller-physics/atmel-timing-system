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


## High level commands

There a several "high level" commands that are intended to quickly write human-readable
timing programs. Each command has a known execution time, as its translation into one of
the "low level" commands is fixed.

### delay

Example: 'delay 50000' inserts a 50ms delay (16x 50000 tics) into the programm. The execution
of the delay itself takes up another 2 ticks!

The command gets translated into 'dla1', 'dla2' or 'dla3', depending on the length of the delay (if it fits into 1, 2 or 3 bytes respectively). The longest achievable delay is 2^23 microseconds, or approx. 8.3 seconds.

### loop & endloop

Examples: 'loop 100', [commands], 'endloop' creates a standard loop, i.e. the commands between loop and endloop will be executed 100 times. Initializing the loop takes 2 ticks once, jumping back takes two ticks on every loop cycle.






## Commands for the timing interpreter:

These commands can be used to set pins, wait for pins to become low/high,
execute loops, etc.

Each command needs a certain number of tics to execute, where 1 tick corresponds to 16 cycles on the microcontroller.
On a 16 MHz system (Arduino), this means a tick takes exactly 1 microsecond.


| opcode | mnemonic | bytes | ticks | group	| description  |	
| ------ | -------- | ----- | ----- | --------- | ------------ |
| 0x00	 | ter	    |	  1 |	  X | general	| terminates the interpreter programm 
| 0x01	 | nop	    |	  1 |	  1 |		| does nothing (but takes a tick to do so)
| ------ | -------- | ----- | ----- | --------- | ------------ |
| 0x20   | dla1	    |     2 | 2 + n | delayy	| delay for 2 + n ticks (n 0..2^7)
| 0x21   | dla2	    |     3 | 2 + n |		| delay for 2 + n ticks (n 0..2^15)
| 0x22   | dla3	    |     4 | 2 + n |		| delay for 2 + n ticks (n 0..2^31)
| ------ | -------- | ----- | ----- | ----------|
| 0x30   | lia1	    |     2 |     2 | loop	| set A1 (n 0..2^8),  store prog. counter in A2
| 0x31   | lia2	    |     3 |     2 | (setup)	| set A1 (n 0..2^16), store prog. counter in A2
| 0x32   | lia1	    |     2 |     2 |		| set B1 (n 0..2^8),  store prog. counter in B2
| 0x33   | lia2	    |     3 |     2 |	    	| set B1 (n 0..2^16), store prog. counter in B2
| 0x34   | lic1	    |     2 |     2 |		| set C1 (n 0..2^8),  store prog. counter in C2
| 0x35   | lic2	    |     3 |     2 |		| set C1 (n 0..2^16), store prog. counter in C2
| 0x36   | lid1	    |     2 |     2 |		| set D1 (n 0..2^8),  store prog. counter in D2
| 0x37   | lid2	    |     3 |     2 |		| set D1 (n 0..2^16), store prog. counter in D2
| 0x36   | lid1	    |     2 |     2 |   	| set D1 (n 0..2^8),  store prog. counter in D2
| 0x37   | lid2	    |     3 |     2 |		| set D1 (n 0..2^16), store prog. counter in D2
| 0x38   | dja	    |     1 |     2 | loop  	| decrement A1 (A1--), then jump to A2 if A1 >= 0
| 0x39   | djb	    |     1 |     2 | (execute)	| decrement B2 (B1--), then jump to B2 if B1 >= 0
| 0x3A   | djc	    |     1 |     2 |		| decrement C2 (B1--), then jump to C2 if C1 >= 0
| 0x3B   | djd	    |     1 |     2 |		| decrement D2 (B1--), then jump to D2 if D1 >= 0
| 0x3C   | lif1	    |	  2 |     1 | loop      | same as 'lia1', but executes in 1 tic
| 0x3D   | lif2	    |	  3 |     1 | (fast)    | same as 'lia2', but executes in 1 tic
| 0x3E   | djf	    |	  1 |     1 |	        | same as 'dja', but executes in 1 tic
| ------ | -------- | ----- | ----- | --------------|


## 'fast' commands
 
The fast commands offer a limited set of operations that can be executed in half a tick 
(8 cycles, so 500 nanoseconds on a 16 MHz ATMEL). The pins available are limited to those
set during compile time. 



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



