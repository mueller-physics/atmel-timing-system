

#define __SFR_OFFSET 0
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
#define loY r28
#define hiY r29

// global variable with the timing table, initialized in c
.extern timing_table
.global timing_interpreter

// main program:

timing_interpreter:
// save the registers we are going to use
// TODO: I assume C has set up the stack pointer
// TOOD: Also, gcc does assume some registers will be cluttered, but we'll save them all

push rDATA

//in rDATA, _SFR_IO_ADDR(SREG) ; saves the state register
//push rDATA

push rCMD   ; saves our registers
push rATTR
push rTMP
push loY
push hiY

inittable:

ldi loY, lo8( timing_table )
ldi hiY, hi8( timing_table )


// the main loop interpreting our timing table
interpreter_loop:	; 0c - start, '0c' is the cycle count
    ld  rCMD, Y+		; 2c - load the command 
    ld  rDATA, Y+		; 4c - load the data
    mov rATTR, rCMD	; 5c - copy cmd to attr
    andi rATTR, 0x0F	; 6c - set upper nibble to 0
    andi rCMD, 0xF0		; 7c - set lower nibble to 0


    // TODO: replace this stuff with a jump table!
    // check for 'low set' command
    cpi rCMD, cmdLOWSET	; 8c	  - check for 'low set'
    breq lsPortX	; 9(10)c  - branch into the command
    
    // check for 'high set' command
    cpi rCMD, cmdHIGHSET ; 10c	  - check for 'high set'
    breq hsPortX	 ; 11(12)c - branch into the command	

    cpi rCMD, cmdEND	 ; 12c
    breq endInterpreterLoop   ; 13(14)c - branch into 'end the interpreter'


// this will use 4 + 4x rTMP cycles and then restart the command read loop
// note: rTMP has to be at least 1!
nop_and_next_command:		; 0c
    dec rTMP			; 1c
    cpi rTMP, 0			; 2c
    brne nop_and_next_command	; 3(4)c
    rjmp interpreter_loop;	; 6c


// leave the interpreter loop
endInterpreterLoop:
    pop hiY
    pop loY
    pop rTMP
    pop rATTR
    pop rCMD
    
    //pop rDATA
    //out _SFR_IO_ADDR(SREG), rDATA

    pop rDATA

    reti 


// command 'set pins to low', entry is after 10 cycles
lsPortX:  ; 10c
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
	rjmp interpreter_loop; 24c

    lsPortC:		; 15c
	nop		; 16c
	nop		; 17c
	in rTMP, PORTC	; 18c	- read the current state
	com rDATA	; 19c   - invert the data
	and rTMP, rDATA ; 20c   - compute the new port state
	out PORTC, rTMP ; 21c   - write data back to port
	nop		; 22c
	rjmp interpreter_loop; 24c


    lsPortD:		; 17c
	in rTMP, PORTD	; 18c	- read the current state
	com rDATA	; 19c   - invert the data
	and rTMP, rDATA ; 20c   - compute the new port state
	out PORTD, rTMP ; 21c   - write data back to port
	nop		; 22c
	rjmp interpreter_loop; 24c

// command 'set pins to high', entry is after 12 cycles
hsPortX: ; 12c
    cpi rATTR, 0x01	; 13c	    - set portB?
    breq hsPortB	; 14(15)c   
    cpi rATTR, 0x02	; 15c	    - set portC?
    breq hsPortC	; 16(17)c
    cpi rATTR, 0x03	; 17c	    - set portD?
    breq hsPortD	; 18(19)c
    // TODO: jump into an error handler

    hsPortB:		; 15c
	nop		; 16c
	nop		; 17c
	nop		; 18c
	in rTMP, PORTB	; 19c	- read the current state
	or rTMP, rDATA  ; 20c   - compute the new port state
	out PORTB, rTMP ; 21c   - write data back to port
	nop		; 22c
	rjmp interpreter_loop; 24c

    hsPortC:		; 17c
	nop		; 18c
	in rTMP, PORTC	; 19c	- read the current state
	or rTMP, rDATA  ; 20c   - compute the new port state
	out PORTC, rTMP ; 21c   - write data back to port
	nop		; 22c
	rjmp interpreter_loop; 24c


    hsPortD:		; 19c
	in rTMP, PORTD	; 20c	- read the current state
	or rTMP, rDATA  ; 21c   - compute the new port state
	out PORTD, rTMP ; 22c   - write data back to port
	rjmp interpreter_loop; 24c


