#include <avr/io.h>
#include "fast-ports.h"	// fast ports for op codes 0x10--0x1F

// register definitions:
#define rCntL	r24
#define rCntH	r25
#define lStartL	r2
#define lStartH	r3

#define rL0	16
#define rL1	17
#define rL2	18
#define rL3	19


// global variable with the timing table, initialized in c
.extern timing_table

// export our function call
.global timing_interpreter

// main program:
timing_interpreter:

    // save registers we are going to use
    _save_registers:
    push rCntL
    push rCntH
    push lStartL
    push lStartH
    push rL0
    push rL1
    push rL2
    push rL3
    push ZH
    push ZL
    push YH
    push YL
    push XH
    push XL

    rjmp _start_interpreter

    // restore all the registers
    _restore_registers_and_return:
    pop XL
    pop XH
    pop YL
    pop YH
    pop ZL
    pop ZH
    pop rL3
    pop rL2
    pop rL1
    pop rL0
    pop lStartH
    pop lStartL
    pop rCntH
    pop rCntL
    mov r24, r0	    ; copy the return code into r24
    ret


    _start_interpreter:
    // load the start addr of the timing table into X
    ldi YL, lo8( timing_table )
    ldi YH, hi8( timing_table )

    /** This decodes commands, using some trickery to get this into as few a cycles as possible:
	- We use the 'command' as an offset into a jump table
	- The jump table address has to be in the Z-register for an indirect jump
	- However, we have the assembler align it to a multiple of 256 bytes
	- So, the low byte of its address is zero, i.e. no need to load it
    */

    // load high byte of the jump table into ZH 
    // (its align to 256 bytes, so ZL only has the offset)
    ldi ZH, pm_hi8( jump_table )	

    // the main loop interpreting our timing table
    _intptr_loop_4nop:
	nop			; 4c extra
    _intptr_loop_3nop:
	nop			; 3c extra
    _intptr_loop_2nop:
	nop			; 2c extra
    _intptr_loop_1nop:
	nop			; 1c extra
    _intptr_loop_0nop:		; 0c - start, '0c' is the cycle count
	ld  ZL, Y+		; 2c - low byte of jump table:  the command to execute (offset)
	ijmp ;			; 4c - jump into the table    

    .align 9			; this (TODO: seems to!) align the table to a multiple of 2^9 bytes
    jump_table:			; command interpreter jump table

    // 0x00 -- 0x0F: nop, end and fast loops
    rjmp _cmd_terminate_program	; C 0x00 ter
    rjmp _cmd_nop;		; C 0x01 nop
    rjmp _cmd_invalid_op	; - 0x02 invalid op code
    rjmp _cmd_invalid_op	; - 0x03 invalid op code
    rjmp _cmd_invalid_op	; - 0x04 invalid op code
    rjmp _cmd_invalid_op	; - 0x05 invalid op code
    rjmp _cmd_invalid_op	; - 0x06 invalid op code
    rjmp _cmd_invalid_op	; - 0x07 invalid op code
    rjmp _cmd_invalid_op	; - 0x08 invalid op code
    rjmp _cmd_invalid_op	; - 0x09 invalid op code
    rjmp _cmd_invalid_op	; - 0x0A invalid op code
    rjmp _cmd_invalid_op	; - 0x0B invalid op code
    rjmp _cmd_invalid_op	; - 0x0C invalid op code
    rjmp _cmd_invalid_op	; - 0x0D invalid op code
    rjmp _cmd_invalid_op	; - 0x0E invalid op code
    rjmp _cmd_invalid_op	; - 0x0F invalid op code
   

    // 0x10 -- 0x1F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x10 invalid op code
    rjmp _cmd_invalid_op		; - 0x11 invalid op code
    rjmp _cmd_invalid_op		; - 0x12 invalid op code
    rjmp _cmd_invalid_op		; - 0x13 invalid op code
    rjmp _cmd_invalid_op		; - 0x14 invalid op code
    rjmp _cmd_invalid_op		; - 0x15 invalid op code
    rjmp _cmd_invalid_op		; - 0x16 invalid op code
    rjmp _cmd_invalid_op		; - 0x17 invalid op code
    rjmp _cmd_invalid_op		; - 0x18 invalid op code
    rjmp _cmd_invalid_op		; - 0x19 invalid op code
    rjmp _cmd_invalid_op		; - 0x1A invalid op code
    rjmp _cmd_invalid_op		; - 0x1B invalid op code
    rjmp _cmd_invalid_op		; - 0x1C invalid op code
    rjmp _cmd_invalid_op		; - 0x1D invalid op code
    rjmp _cmd_invalid_op		; - 0x1E invalid op code
    rjmp _cmd_invalid_op		; - 0x1F invalid op code
    

    // 0x20 -- 0x2F: delays
    rjmp _cmd_nop_loop_8		; c 0x20 nop loop, 1 byte counter
    rjmp _cmd_nop_loop_16		; c 0x21 nop loop, 2 byte counter
    rjmp _cmd_nop_loop_24		; c 0x22 nop loop, 3 byte counter
    rjmp _cmd_invalid_op		; - 0x23 invalid op code
    rjmp _cmd_invalid_op		; - 0x24 invalid op code
    rjmp _cmd_invalid_op		; - 0x25 invalid op code
    rjmp _cmd_invalid_op		; - 0x26 invalid op code
    rjmp _cmd_invalid_op		; - 0x27 invalid op code
    rjmp _cmd_invalid_op		; - 0x28 invalid op code
    rjmp _cmd_invalid_op		; - 0x29 invalid op code
    rjmp _cmd_invalid_op		; - 0x2A invalid op code
    rjmp _cmd_invalid_op		; - 0x2B invalid op code
    rjmp _cmd_invalid_op		; - 0x2C invalid op code
    rjmp _cmd_invalid_op		; - 0x2D invalid op code
    rjmp _cmd_invalid_op		; - 0x2E invalid op code
    rjmp _cmd_invalid_op		; - 0x2F invalid op code

    // 0x30 -- 0x3F: currently unassinged 
    rjmp _cmd_init_loop_8		; - 0x30 ls1 : initialize loop
    rjmp _cmd_init_loop_16		; - 0x31 ls2 : initialize loop
    rjmp _cmd_invalid_op		; - 0x32 invalid op code
    rjmp _cmd_invalid_op		; - 0x33 invalid op code
    rjmp _cmd_invalid_op		; - 0x34 invalid op code
    rjmp _cmd_invalid_op		; - 0x35 invalid op code
    rjmp _cmd_invalid_op		; - 0x36 invalid op code
    rjmp _cmd_invalid_op		; - 0x37 invalid op code
    rjmp _cmd_invalid_op		; - 0x38 invalid op code
    rjmp _cmd_invalid_op		; - 0x39 invalid op code
    rjmp _cmd_invalid_op		; - 0x3A invalid op code
    rjmp _cmd_invalid_op		; - 0x3B invalid op code
    rjmp _cmd_invalid_op		; - 0x3C invalid op code
    rjmp _cmd_invalid_op		; - 0x3D invalid op code
    rjmp _cmd_invalid_op		; - 0x3E invalid op code
    rjmp _cmd_invalid_op		; - 0x3F invalid op code
   

    // 0x40 -- 0x5F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x40 invalid op code
    rjmp _cmd_invalid_op		; - 0x41 invalid op code
    rjmp _cmd_invalid_op		; - 0x42 invalid op code
    rjmp _cmd_invalid_op		; - 0x43 invalid op code
    rjmp _cmd_invalid_op		; - 0x44 invalid op code
    rjmp _cmd_invalid_op		; - 0x45 invalid op code
    rjmp _cmd_invalid_op		; - 0x46 invalid op code
    rjmp _cmd_invalid_op		; - 0x47 invalid op code
    rjmp _cmd_invalid_op		; - 0x48 invalid op code
    rjmp _cmd_invalid_op		; - 0x49 invalid op code
    rjmp _cmd_invalid_op		; - 0x4A invalid op code
    rjmp _cmd_invalid_op		; - 0x4B invalid op code
    rjmp _cmd_invalid_op		; - 0x4C invalid op code
    rjmp _cmd_invalid_op		; - 0x4D invalid op code
    rjmp _cmd_invalid_op		; - 0x4E invalid op code
    rjmp _cmd_invalid_op		; - 0x4F invalid op code

    // 0x50 -- 0x6F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x50 invalid op code
    rjmp _cmd_invalid_op		; - 0x51 invalid op code
    rjmp _cmd_invalid_op		; - 0x52 invalid op code
    rjmp _cmd_invalid_op		; - 0x53 invalid op code
    rjmp _cmd_invalid_op		; - 0x54 invalid op code
    rjmp _cmd_invalid_op		; - 0x55 invalid op code
    rjmp _cmd_invalid_op		; - 0x56 invalid op code
    rjmp _cmd_invalid_op		; - 0x57 invalid op code
    rjmp _cmd_invalid_op		; - 0x58 invalid op code
    rjmp _cmd_invalid_op		; - 0x59 invalid op code
    rjmp _cmd_invalid_op		; - 0x5A invalid op code
    rjmp _cmd_invalid_op		; - 0x5B invalid op code
    rjmp _cmd_invalid_op		; - 0x5C invalid op code
    rjmp _cmd_invalid_op		; - 0x5D invalid op code
    rjmp _cmd_invalid_op		; - 0x5E invalid op code
    rjmp _cmd_invalid_op		; - 0x5F invalid op code
   
    // 0x60 -- 0x6F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x60 invalid op code
    rjmp _cmd_invalid_op		; - 0x61 invalid op code
    rjmp _cmd_invalid_op		; - 0x62 invalid op code
    rjmp _cmd_invalid_op		; - 0x63 invalid op code
    rjmp _cmd_invalid_op		; - 0x64 invalid op code
    rjmp _cmd_invalid_op		; - 0x65 invalid op code
    rjmp _cmd_invalid_op		; - 0x66 invalid op code
    rjmp _cmd_invalid_op		; - 0x67 invalid op code
    rjmp _cmd_invalid_op		; - 0x68 invalid op code
    rjmp _cmd_invalid_op		; - 0x69 invalid op code
    rjmp _cmd_invalid_op		; - 0x6A invalid op code
    rjmp _cmd_invalid_op		; - 0x6B invalid op code
    rjmp _cmd_invalid_op		; - 0x6C invalid op code
    rjmp _cmd_invalid_op		; - 0x6D invalid op code
    rjmp _cmd_invalid_op		; - 0x6E invalid op code
    rjmp _cmd_invalid_op		; - 0x6F invalid op code
   
   
    // 0x70 -- 0x7F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x70 invalid op code
    rjmp _cmd_invalid_op		; - 0x71 invalid op code
    rjmp _cmd_invalid_op		; - 0x72 invalid op code
    rjmp _cmd_invalid_op		; - 0x73 invalid op code
    rjmp _cmd_invalid_op		; - 0x74 invalid op code
    rjmp _cmd_invalid_op		; - 0x75 invalid op code
    rjmp _cmd_invalid_op		; - 0x76 invalid op code
    rjmp _cmd_invalid_op		; - 0x77 invalid op code
    rjmp _cmd_invalid_op		; - 0x78 invalid op code
    rjmp _cmd_invalid_op		; - 0x79 invalid op code
    rjmp _cmd_invalid_op		; - 0x7A invalid op code
    rjmp _cmd_invalid_op		; - 0x7B invalid op code
    rjmp _cmd_invalid_op		; - 0x7C invalid op code
    rjmp _cmd_invalid_op		; - 0x7D invalid op code
    rjmp _cmd_invalid_op		; - 0x7E invalid op code
    rjmp _cmd_invalid_op		; - 0x7F invalid op code
   
  
    /** Second half of command table: 'fast' commands that execute
      * in half-ticks (8 cycles). This also means 'no jumps'.
      * Only even addresses (last bit 0) in this table are valid op-codes! */
 
    // 0x80 -- 0x8F: currently unassinged 
    rjmp _intptr_loop_2nop;		; C 0x80 fnp: half-tick nop, jump back and add two cycles
    rjmp _cmd_invalid_op		; - 0x81    invalid op code
    rjmp _cmd_invalid_op		; - 0x82    invalid op code
    rjmp _cmd_invalid_op		; - 0x83    invalid op code
    sbiw rCntL, 1			; C 0x84 fdc: decrement the loop counter (6c)
    rjmp _intptr_loop_0nop;		; i 0x85      jump back (8c)
    rjmp _cmd_invalid_op		; - 0x86    invalid op code
    rjmp _cmd_invalid_op		; - 0x87    invalid op code
    sbrs rCntH,7			; C 0x88 fle: skips the 'movw' if the loop counter is negative    
    movw Y, lStartL			; i 0x89      set the timing table pointer to the loop start
    rjmp _intptr_loop_0nop;		; i 0x8A      jump back (8c)
    rjmp _cmd_invalid_op		; - 0x8B    invalid op code
    rjmp _cmd_invalid_op		; - 0x8C    invalid op code
    rjmp _cmd_invalid_op		; - 0x8D    invalid op code
    rjmp _cmd_invalid_op		; - 0x8E    invalid op code
    rjmp _cmd_invalid_op		; - 0x8F    invalid op code
   
    // 0x90 -- 0x9F: currently unassinged 
    rjmp _cmd_invalid_op		; - 0x90 invalid op code
    rjmp _cmd_invalid_op		; - 0x91 invalid op code
    rjmp _cmd_invalid_op		; - 0x92 invalid op code
    rjmp _cmd_invalid_op		; - 0x93 invalid op code
    rjmp _cmd_invalid_op		; - 0x94 invalid op code
    rjmp _cmd_invalid_op		; - 0x95 invalid op code
    rjmp _cmd_invalid_op		; - 0x96 invalid op code
    rjmp _cmd_invalid_op		; - 0x97 invalid op code
    rjmp _cmd_invalid_op		; - 0x98 invalid op code
    rjmp _cmd_invalid_op		; - 0x99 invalid op code
    rjmp _cmd_invalid_op		; - 0x9A invalid op code
    rjmp _cmd_invalid_op		; - 0x9B invalid op code
    rjmp _cmd_invalid_op		; - 0x9C invalid op code
    rjmp _cmd_invalid_op		; - 0x9D invalid op code
    rjmp _cmd_invalid_op		; - 0x9E invalid op code
    rjmp _cmd_invalid_op		; - 0x9F invalid op code
   
    // 0xA0 -- 0xAF: fast pin writes, pins 2 .. 5
    cbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; C 0xA0 set fast pin 2 low
    rjmp _intptr_loop_0nop;		; - 0xA1 jump back 
    sbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; C 0xA2 set fast pin 2 high
    rjmp _intptr_loop_0nop;		; - 0xA3 jump back 
    cbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; C 0xA4 set fast pin 3 low
    rjmp _intptr_loop_0nop;		; - 0xA5 jump back 
    sbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; C 0xA6 set fast pin 3 high
    rjmp _intptr_loop_0nop;		; - 0xA7 jump back 
    cbi _SFR_IO_ADDR( _FPOR4), _FPIN4	; C 0xA8 set fast pin 4 low
    rjmp _intptr_loop_0nop;		; - 0xA9 jump back 
    sbi _SFR_IO_ADDR( _FPOR4), _FPIN4	; C 0xAA set fast pin 4 high
    rjmp _intptr_loop_0nop;		; - 0xAB jump back 
    cbi _SFR_IO_ADDR( _FPOR5), _FPIN5	; C 0xAC set fast pin 5 low
    rjmp _intptr_loop_0nop;		; - 0xAD jump back 
    sbi _SFR_IO_ADDR( _FPOR5), _FPIN5	; C 0xAE set fast pin 5 high
    rjmp _intptr_loop_0nop;		; - 0xAF jump back
    
    // 0xB0 -- 0xBF: fast pin writes, pins 6 .. 9
    cbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; C 0xB0 set fast pin 2 low
    rjmp _intptr_loop_0nop;		; - 0xB1 jump back 
    sbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; C 0xB2 set fast pin 2 high
    rjmp _intptr_loop_0nop;		; - 0xB3 jump back 
    cbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; C 0xB4 set fast pin 3 low
    rjmp _intptr_loop_0nop;		; - 0xB5 jump back 
    sbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; C 0xB6 set fast pin 3 high
    rjmp _intptr_loop_0nop;		; - 0xB7 jump back 
    cbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; C 0xB8 set fast pin 4 low
    rjmp _intptr_loop_0nop;		; - 0xB9 jump back 
    sbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; C 0xBA set fast pin 4 high
    rjmp _intptr_loop_0nop;		; - 0xBB jump back 
    cbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; C 0xBC set fast pin 5 low
    rjmp _intptr_loop_0nop;		; - 0xBD jump back 
    sbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; C 0xBE set fast pin 5 high
    rjmp _intptr_loop_0nop;		; - 0xBF jump back

  

    // ============ END OF JUMP TABLE =================



_cmd_terminate_program:
    ldi r25, 0
    mov r0, r25
    rjmp _restore_registers_and_return 

_cmd_invalid_op:
    ldi r25, 1
    mov r0, r25
    rjmp _restore_registers_and_return 

_cmd_nop:	; 6c
    nop		; 7c
    nop		; 8c
    nop		; 9c
    nop		; 10c
    nop		; 11c
    nop		; 12c
    rjmp _intptr_loop_3nop	; 13c




// this initializes the 'fast loop' with an 7bit counter
_cmd_init_loop_8:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    clr	 rCntH			; 9c - set the high counter bits zero
    movw r2, Y			; 10c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_4nop	; 12c

// this initializes the 'fast loop' with an 15bit counter
_cmd_init_loop_16:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    ld   rCntH, Y+		; 10c - load the counter low byte
    movw r2, Y			; 11c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_3nop	; 13c



_cmd_nop_loop_8:
    ld rL0, Y+		    ; 8c - load  byte 0
    clr rL1		    ; 9c - clear byte 1
    nop			    ;10c
    clr rL2		    ;11c - clear byte 2
    nop			    ;12c
    clr rL3		    ;13c - clear byte 3
    rjmp _execute_nop_loop  ;14c
    

_cmd_nop_loop_16:
    ld rL0, Y+			; 8c - load  byte 0
    ld rL1, Y+			;10c - load  byte 1
    clr rL2			;11c - clear byte 2
    nop				;12c
    clr rL3			;13c - clear byte 3
    rjmp _execute_nop_loop	;15c
    

_cmd_nop_loop_24:		; 6c
    ld rL0, Y+		; 8c - load  byte 0
    ld rL1, Y+		;10c - load  byte 1
    ld rL2, Y+		;12c - load  byte 2
    clr rL3		;13c - clear byte 3
    rjmp _execute_nop_loop	;15c
    

_execute_nop_loop:		;+0c
    
    subi rL0, 1			;+1c
    sbci rL1, 0			;+2c	
    sbci rL2, 0			;+3c
    sbci rL3, 0			;+4c
    
    nop				;+5c
    nop				;+6c
    nop				;+7c
    nop				;+8c
    
    nop				;+9c
    nop				;+10c
    nop				;+11c
    nop				;+12c
    
    nop				;+13c
    nop				;+14c
    brpl _execute_nop_loop	;+16c (+15c if no branch)

    rjmp _intptr_loop_0nop	;prev.call +17c (incl. ret jump) + rL*16 
    



