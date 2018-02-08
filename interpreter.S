#include <avr/io.h>
#include "fast-ports.h"	// fast ports for op codes 0x10--0x1F

// register definitions:
// r2,r3, r16 - 19, r24-r31 are used to keep data

// used for precise, 31bit NOP counting
#define rL0	r16
#define rL1	r17
#define rL2	r18
#define rL3	r19

#define rTMP0	r20
#define rTMP1	r21
#define rTMP2	r22
#define rTMP3	r23

#define rCntL	r24
#define rCntH	r25

#define lStartL	r2
#define lStartH	r3

// global variable with the timing table, initialized in c
.extern timing_table

// export our function call
.global timing_interpreter

// variables to store some state
.data

_varB:
    .word 0x0000
_addrB:
    .word 0x0000
_varC:
    .word 0x0000
_addrC:
    .word 0x0000
_varD:
    .word 0x0000
_addrD:
    .word 0x0000


.text

// main program:
timing_interpreter:

    // save registers we are going to use
    _save_registers:
    push rL0
    push rL1
    push rL2
    push rL3

    push rTMP0
    push rTMP1    
    push rTMP2    
    push rTMP3    

    push rCntL
    push rCntH
    push lStartL
    push lStartH
    
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
    
    pop lStartH
    pop lStartL
    pop rCntH
    pop rCntL
    
    pop rTMP3
    pop rTMP2
    pop rTMP1
    pop rTMP0

    pop rL3
    pop rL2
    pop rL1
    pop rL0

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
    rjmp _intptr_loop_0nop	; no need to run through the NOP chain	

    // the main loop interpreting our timing table
    _intptr_loop_21nop:
	nop			; 21c extra
    _intptr_loop_20nop:
	nop			; 20c extra
    _intptr_loop_19nop:
	nop			; 19c extra
    _intptr_loop_18nop:
	nop			; 18c extra
    _intptr_loop_17nop:
	nop			; 17c extra
    _intptr_loop_16nop:
	nop			; 16c extra
    _intptr_loop_15nop:
	nop			; 15c extra
    _intptr_loop_14nop:
	nop			; 14c extra
    _intptr_loop_13nop:
	nop			; 13c extra
    _intptr_loop_12nop:
	nop			; 12c extra
    _intptr_loop_11nop:
	nop			; 11c extra
    _intptr_loop_10nop:
	nop			; 10c extra
    _intptr_loop_9nop:
	nop			; 9c extra
    _intptr_loop_8nop:
	nop			; 8c extra
    _intptr_loop_7nop:
	nop			; 7c extra
    _intptr_loop_6nop:
	nop			; 6c extra
    _intptr_loop_5nop:
	nop			; 5c extra
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
    rjmp _cmd_nop_delay_08		; c 0x20 nop loop, 1 byte counter
    rjmp _cmd_nop_delay_16		; c 0x21 nop loop, 2 byte counter
    rjmp _cmd_nop_delay_24		; c 0x22 nop loop, 3 byte counter
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

    // 0x30 -- 0x3F: loop commands 
    rjmp _cmd_init_loop_a08		; - 0x30 lia1 : initialize loop, counter/addr a, 8 bit
    rjmp _cmd_init_loop_a16		; - 0x31 lia2 : initialize loop, connter/addr a, 16 bit
    rjmp _cmd_init_loop_b08		; - 0x32 lib1 : initialize loop, counter/addr b, 8 bit
    rjmp _cmd_init_loop_b16		; - 0x33 lib2 : initialize loop, connter/addr b, 16 bit
    rjmp _cmd_init_loop_c08		; - 0x34 lic1 : initialize loop, counter/addr c, 8 bit
    rjmp _cmd_init_loop_c16		; - 0x35 lic2 : initialize loop, connter/addr c, 16 bit
    rjmp _cmd_init_loop_d08		; - 0x36 lid1 : initialize loop, counter/addr d, 8 bit
    rjmp _cmd_init_loop_d16		; - 0x37 lid2 : initialize loop, connter/addr d, 16 bit
    rjmp _cmd_dec_jgez_a		; - 0x38 dja  : decrement varA, jump (back) to addrA if varA>=0
    rjmp _cmd_dec_jgez_b		; - 0x39 djb  : decrement varB, jump (back) to addrB if varB>=0
    rjmp _cmd_dec_jgez_c		; - 0x3A djc  : decrement varC, jump (back) to addrC if varC>=0
    rjmp _cmd_dec_jgez_d		; - 0x3B djd  : decrement varD, jump (back) to addrD if varD>=0
    rjmp _cmd_init_loop_a08_fast	; - 0x3C lif1 : initialize loop, counter/addr a, 8 bit, in 1 tic
    rjmp _cmd_init_loop_a16_fast	; - 0x3D lif2 : initialize loop, connter/addr a, 16 bit, in 1 tic
    rjmp _cmd_dec_jgez_a_fast		; - 0x3E djf  : decrement varA, jump (back) to addrA if varA>=0, in 1 tic 
    rjmp _cmd_invalid_op		; - 0x3F invalid op code
   

    // 0x40 -- 0x4F: pin set commands
    rjmp _cmd_pin2_low			; - 0x40 set pin 2 low
    rjmp _cmd_pin2_high			; - 0x41 set pin 2 low
    rjmp _cmd_pin3_low			; - 0x42 set pin 2 low
    rjmp _cmd_pin3_high			; - 0x43 set pin 2 low
    rjmp _cmd_pin4_low			; - 0x44 set pin 2 low
    rjmp _cmd_pin4_high			; - 0x45 set pin 2 low
    rjmp _cmd_pin5_low			; - 0x46 set pin 2 low
    rjmp _cmd_pin5_high			; - 0x47 set pin 2 low
    rjmp _cmd_pin6_low			; - 0x48 set pin 2 low
    rjmp _cmd_pin6_high			; - 0x49 set pin 2 low
    rjmp _cmd_pin7_low			; - 0x4A set pin 2 low
    rjmp _cmd_pin7_high			; - 0x4B set pin 2 low
    rjmp _cmd_pin8_low			; - 0x4C set pin 2 low
    rjmp _cmd_pin8_high			; - 0x4D set pin 2 low
    rjmp _cmd_pin9_low			; - 0x4E set pin 2 low
    rjmp _cmd_pin9_high			; - 0x4F set pin 2 low

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
    cbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; C 0xB0 set fast pin 6 low
    rjmp _intptr_loop_0nop;		; - 0xB1 jump back 
    sbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; C 0xB2 set fast pin 6 high
    rjmp _intptr_loop_0nop;		; - 0xB3 jump back 
    cbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; C 0xB4 set fast pin 7 low
    rjmp _intptr_loop_0nop;		; - 0xB5 jump back 
    sbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; C 0xB6 set fast pin 7 high
    rjmp _intptr_loop_0nop;		; - 0xB7 jump back 
    cbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; C 0xB8 set fast pin 8 low
    rjmp _intptr_loop_0nop;		; - 0xB9 jump back 
    sbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; C 0xBA set fast pin 8 high
    rjmp _intptr_loop_0nop;		; - 0xBB jump back 
    cbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; C 0xBC set fast pin 9 low
    rjmp _intptr_loop_0nop;		; - 0xBD jump back 
    sbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; C 0xBE set fast pin 9 high
    rjmp _intptr_loop_0nop;		; - 0xBF jump back

  

    // ============ END OF JUMP TABLE =================


// return from the interpreter call
_cmd_terminate_program:
    ldi r25, 0
    mov r0, r25
    rjmp _restore_registers_and_return 

// return with 'invalid op' error
_cmd_invalid_op:
    ldi r25, 1
    mov r0, r25
    rjmp _restore_registers_and_return 

// execute a 1-tick nop
_cmd_nop:	; 6c
    nop		; 7c
    nop		; 8c
    nop		; 9c
    nop		; 10c
    nop		; 11c
    nop		; 12c
    rjmp _intptr_loop_3nop	; 13c


// ----------- LOOP instructions  ---------------------

// this initializes the 'fast loop' with an 7bit counter
_cmd_init_loop_a08:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    clr	 rCntH			; 9c - set the high counter bits zero
    movw r2, Y			; 10c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_20nop	; 12c + 20c -> 32c

// this initializes the 'fast loop' with an 15bit counter
_cmd_init_loop_a16:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    ld   rCntH, Y+		; 10c - load the counter high byte
    movw r2, Y			; 11c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_19nop	; 13c + 19c -> 32c


// this initializes the 'fast loop' with an 7bit counter
_cmd_init_loop_a08_fast:	; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    clr	 rCntH			; 9c - set the high counter bits zero
    movw r2, Y			; 10c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_4nop	; 12c -> 16c

// this initializes the 'fast loop' with an 15bit counter
_cmd_init_loop_a16_fast:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    ld   rCntH, Y+		; 10c - load the counter high byte
    movw r2, Y			; 11c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_3nop	; 13c -> 16c


// this initializes loop B
_cmd_init_loop_b16:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    ld   rTMP1, Y+		; 10c - load the counter high byte
    sts	 ( _varB     ), rTMP0	; 12c - store 
    sts  ( _varB +1  ), rTMP1	; 14c - store
    sts  ( _addrB    ), YL	; 16c - store low byte jmp addr.   
    sts  ( _addrB+1  ), YH	; 18c - store low byte jmp addr.   
    rjmp _intptr_loop_12nop	; 20c -> 32c

// this initializes loop B
_cmd_init_loop_b08:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    clr	 rTMP1			; 9c  - no counter high value
    sts	 ( _varB     ), rTMP0	; 11c - store 
    sts  ( _varB +1  ), rTMP1	; 13c - store
    sts  ( _addrB    ), YL	; 15c - store low byte jmp addr.   
    sts  ( _addrB+1  ), YH	; 17c - store low byte jmp addr.   
    rjmp _intptr_loop_13nop	; 19c -> 32c


// this initializes loop C
_cmd_init_loop_c16:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    ld   rTMP1, Y+		; 10c - load the counter high byte
    sts	 ( _varC     ), rTMP0	; 12c - store 
    sts  ( _varC +1  ), rTMP1	; 14c - store
    sts  ( _addrC    ), YL	; 16c - store low byte jmp addr.   
    sts  ( _addrC+1  ), YH	; 18c - store low byte jmp addr.   
    rjmp _intptr_loop_12nop	; 20c -> 32c

// this initializes loop C
_cmd_init_loop_c08:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    clr	 rTMP1			; 9c  - no counter high value
    sts	 ( _varC     ), rTMP0	; 11c - store 
    sts  ( _varC +1  ), rTMP1	; 13c - store
    sts  ( _addrC    ), YL	; 15c - store low byte jmp addr.   
    sts  ( _addrC+1  ), YH	; 17c - store low byte jmp addr.   
    rjmp _intptr_loop_13nop	; 19c -> 32c


// this initializes loop D
_cmd_init_loop_d16:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    ld   rTMP1, Y+		; 10c - load the counter high byte
    sts	 ( _varD     ), rTMP0	; 12c - store 
    sts  ( _varD +1  ), rTMP1	; 14c - store
    sts  ( _addrD    ), YL	; 16c - store low byte jmp addr.   
    sts  ( _addrD+1  ), YH	; 18c - store low byte jmp addr.   
    rjmp _intptr_loop_12nop	; 20c -> 32c

// this initializes loop D
_cmd_init_loop_d08:
    ld   rTMP0, Y+		; 8c  - load the counter low byte
    clr	 rTMP1			; 9c  - no counter high value
    sts	 ( _varD     ), rTMP0	; 11c - store 
    sts  ( _varD +1  ), rTMP1	; 13c - store
    sts  ( _addrD    ), YL	; 15c - store low byte jmp addr.   
    sts  ( _addrD+1  ), YH	; 17c - store low byte jmp addr.   
    rjmp _intptr_loop_13nop	; 19c -> 32c


// do varA--, jump to addrA if A>=0, in 1 tic
_cmd_dec_jgez_a_fast:
    sbiw rCntL, 1		; 8c dec loop counter
    sbrs rCntH, 7		; skip the 'movw' if the counter is not negative (>=0)
    movw Y, lStartL		; 10c overwrite the interpreter's programm counter 
    rjmp _intptr_loop_4nop	; 12c + 4c -> 16c   
 

// do varA--, jump to addrA if A>=0, in 2 tics
_cmd_dec_jgez_a:
    sbiw rCntL, 1		; 8c dec loop counter
    sbrs rCntH, 7		; skip the 'movw' if the counter is not negative (>=0)
    movw Y, lStartL		; 10c overwrite the interpreter's programm counter 
    rjmp _intptr_loop_20nop	; 12c + 20c -> 32c   
 

// do varB--, jump to addrB if B>=0
_cmd_dec_jgez_b:
    lds rTMP0, (_varB  )	; 8c load low byte of coutner
    lds rTMP1, (_varB+1)	;10c load high byte of counter
    subi rTMP0, 1		;11c sub -1 from low byte
    sbci rTMP1, 0		;12c sub carry from high byte
    sts	 ( _varB     ), rTMP0	;14c - store low byte counter
    sts  ( _varB +1  ), rTMP1	;16c - store high byte counter
    lds rTMP2, (_addrB )	;18c load addr. low byte
    lds rTMP3, (_addrB+1)	;20c load addr. low byte
    sbrs rTMP1, 7		;skip the 'movw' if the counter is not negative (>=0)
    movw Y, rTMP2		;22c overwrite the interpreter's programm counter 
    rjmp _intptr_loop_8nop	;24c +8c -> 32c
       
// do varC--, jump to addrB if B>=0
_cmd_dec_jgez_c:
    lds rTMP0, (_varC  )	; 8c load low byte of coutner
    lds rTMP1, (_varC+1)	;10c load high byte of counter
    subi rTMP0, 1		;11c sub -1 from low byte
    sbci rTMP1, 0		;12c sub carry from high byte
    sts	 ( _varC     ), rTMP0	;14c - store low byte counter
    sts  ( _varC +1  ), rTMP1	;16c - store high byte counter
    lds rTMP2, (_addrC )	;18c load addr. low byte
    lds rTMP3, (_addrC+1)	;20c load addr. low byte
    sbrs rTMP1, 7		;skip the 'movw' if the counter is not negative (>=0)
    movw Y, rTMP2		;22c overwrite the interpreter's programm counter 
    rjmp _intptr_loop_8nop	;24c +8c -> 32c
       
 
// do varD--, jump to addrB if B>=0
_cmd_dec_jgez_d:
    lds rTMP0, (_varD  )	; 8c load low byte of coutner
    lds rTMP1, (_varD+1)	;10c load high byte of counter
    subi rTMP0, 1		;11c sub -1 from low byte
    sbci rTMP1, 0		;12c sub carry from high byte
    sts	 ( _varD     ), rTMP0	;14c - store low byte counter
    sts  ( _varD +1  ), rTMP1	;16c - store high byte counter
    lds rTMP2, (_addrD )	;18c load addr. low byte
    lds rTMP3, (_addrD+1)	;20c load addr. low byte
    sbrs rTMP1, 7		;skip the 'movw' if the counter is not negative (>=0)
    movw Y, rTMP2		;22c overwrite the interpreter's programm counter 
    rjmp _intptr_loop_8nop	;24c +8c -> 32c
       




// ----------- DELAY instructions  ---------------------

_cmd_nop_delay_08:
    ld rL0, Y+		    ; 8c - load  byte 0
    clr rL1		    ; 9c - clear byte 1
    nop			    ;10c
    clr rL2		    ;11c - clear byte 2
    nop			    ;12c
    clr rL3		    ;13c - clear byte 3
    nop			    ;14c
    rjmp _execute_nop_delay ;15c
    

_cmd_nop_delay_16:
    ld rL0, Y+			; 8c - load  byte 0
    ld rL1, Y+			;10c - load  byte 1
    clr rL2			;11c - clear byte 2
    nop				;12c
    clr rL3			;13c - clear byte 3
    rjmp _execute_nop_delay	;15c
    

_cmd_nop_delay_24:		; 6c
    ld rL0, Y+			; 8c - load  byte 0
    ld rL1, Y+			;10c - load  byte 1
    ld rL2, Y+			;12c - load  byte 2
    clr rL3			;13c - clear byte 3
    rjmp _execute_nop_delay	;15c
    

_execute_nop_delay:		;+0c
    
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
    brpl _execute_nop_delay	;+16c (+15c if no branch)
    rjmp _intptr_loop_0nop	;prev.call +17c (incl. ret jump) + rL*16 
    


// ----------- PIN  access instructions  ---------------------

_cmd_pin2_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin2_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin3_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin3_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 



_cmd_pin4_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR4), _FPIN4	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin4_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR4), _FPIN4	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin5_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR5), _FPIN5	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin5_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR5), _FPIN5	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin6_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin6_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR6), _FPIN6	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin7_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin7_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR7), _FPIN7	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin8_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin8_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR8), _FPIN8	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 


_cmd_pin9_high:				; 6c
    sbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

_cmd_pin9_low:				; 6c
    cbi _SFR_IO_ADDR( _FPOR9), _FPIN9	; 8c	     set pin
    rjmp _intptr_loop_6nop;		; 10+6 = 16c jump back 

// ----------- PORT access instructions  ---------------------













