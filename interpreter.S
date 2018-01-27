#include <avr/io.h>

// define our commands
#define cmdNOP	   0x00
#define cmdLOWSET  0x10
#define cmdHIGHSET 0x20
#define cmdDELAY   0x30
#define cmdWAIT    0x40
#define cmdJUMP    0x50
#define cmdCOUNTER 0x60
#define cmdEND     0x70

// name our registers
#define rCMD  r16
#define rDATA r17
#define rATTR r18
#define rTMP  r19
#define loX r26
#define hiX r26

// global variable with the timing table, initialized in c
.global timing_table

// main program:

timing_interpreter:
// save the registers we are going to use
// TODO: I assume C has set up the stack pointer
// TOOD: Also, gcc does assume some registers will be cluttered, but we'll save them all

in rDATA, _SFR_IO_ADDR(SREG) ; saves the state register
push rDATA

push rCMD   ; saves our registers
push rDATA
push rATTR
push rTMP
push loX 
push hiX

// the main loop interpreting our timing table
interpreter_loop:	; 0c - start, '0c' is the cycle count
    ldd rCMD, Z+		; 2c - load the command 
    ldd rDATA, Z+		; 4c - load the data
    mov rATTR, rDATA	; 5c - copy cmd to attr
    andi rATTR, 0x0F	; 6c - set upper nibble to 0
    andi rCMD, 0xF0		; 7c - set lower nibble to 0

    // check for 'low set' command
    cpi rCMD, cmdLOWSET	; 8c	  - check for 'low set'
    breq low_set		; 9(10)c  - branch into the command
    
    // check for 'high set' command
    cpi rCMD, cmdHIGHSET	; 10c	  - check for 'high set'
    breq high_set		; 11(12)c - branch into the command	


// this will use 4 + 4x rTMP cycles and then restart the command read loop
// note: rTMP has to be at least 1!
nop_and_next_command:		; 0c
    nop;			; 1c
    dec rTMP			; 2c
    brne nop_and_next_command	; 3(4)c
    rjmp interpreter_loop;	; 6c


// command 'set pins to low', entry is after 10 cycles
low_set:  ; 10c
    cpi rATTR, 0x01	; 11c	    - set portB?
    breq lsPortB	; 12(13)c   
    cpi rATTR, 0x02	; 13c	    - set portC?
    breq lsPortC	; 14(15)c
    cpi rATTR, 0x03	; 15c	    - set portD?
    breq lsPortD	; 16(17)c
    // TODO: jump into an error handler

    lsPortB:		; 13c
	nop		; 14c
	nop		; 15c
	nop		; 16c
	nop		; 17c
	in rTMP, PORTB	; 18c	- read the current state
	com rDATA	; 19c   - invert the data
	and rTMP, rDATA ; 20c   - compute the new port state
	out PORTB, rTMP ; 21c   - write data back to port
	nop		; 22c	
	nop		; 23c	
	ldi rTMP, 4	; 24c	- set 	
	rjmp nop_and_next_command ; will waste 16 cycles, then restart the loop

    lsPortC:		; 15c
	nop		; 16c
	nop		; 17c
	in rTMP, PORTB	; 18c	- read the current state
	com rDATA	; 19c   - invert the data
	and rTMP, rDATA ; 20c   - compute the new port state
	out PORTB, rTMP ; 21c   - write data back to port
	nop		; 22c	
	nop		; 23c	
	ldi rTMP, 4	; 24c	- set 	
	rjmp nop_and_next_command ; will waste 16 cycles, then restart the loop


    lsPortD:		; 17c
	in rTMP, PORTD	; 18c	- read the current state
	com rDATA	; 19c   - invert the data
	and rTMP, rDATA ; 20c   - compute the new port state
	out PORTD, rTMP ; 21c   - write data back to port
	nop		; 22c	
	nop		; 23c	
	ldi rTMP, 4	; 24c	- set 	
	rjmp nop_and_next_command ; will waste 16 cycles, then restart the loop

// command 'set pins to high', entry is after 12 cycles
high_set: ; 12c

