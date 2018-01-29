#include <avr/io.h>
#include "fast-ports.h"	// fast ports for op codes 0x10--0x1F

// register definitions:
#define rCntL	r24
#define rCntH	r25
#define lStartL	r2
#define lStartH	r3



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

    // 0x00 -- 0x0F
    rjmp _cmd_end_program	; C 0x00 jumps to 'end this program'
    rjmp _cmd_invalid_op	; - 0x01 invalid op code
    rjmp _intptr_loop_2nop;	; C 0x02 nop, jump back and add two cycles
    rjmp _cmd_invalid_op	; - 0x03 invalid op code
    sbiw rCntL, 1		; C 0x04 decrement the loop counter (6c)
    rjmp _intptr_loop_0nop;	; - 0x05 jump back (8c)
    rjmp _cmd_invalid_op	; - 0x06 invalid op code
    rjmp _cmd_invalid_op	; - 0x07 invalid op code
    sbrs rCntH,7		; C 0x08 skips the 'movw' if the loop counter is negative    
    movw Y, lStartL		; - 0x09 set the timing table pointer to the loop start
    rjmp _intptr_loop_0nop;	; - 0x0A jump back (8c)
    rjmp _cmd_invalid_op	; - 0x0B invalid op code
    rjmp _cmd_init_fast_loop_16	; C 0x0C initialize a fast loop (16 bit counter)
    rjmp _cmd_init_fast_loop_8	; C 0x0D initialize a fast loop ( 8 bit counter)
    rjmp _cmd_invalid_op	; - 0x0E invalid op code
    rjmp _cmd_invalid_op	; - 0x0F invalid op code
    
    // 0x10 -- 0x1F
    cbi _SFR_IO_ADDR( _FPOR0), _FPIN0	; C 0x10 set fast pin 0 low
    rjmp _intptr_loop_0nop;		; - 0x11 jump back (+1 cycles)
    sbi _SFR_IO_ADDR( _FPOR0), _FPIN0	; C 0x12 set fast pin 0 high
    rjmp _intptr_loop_0nop;		; - 0x13 jump back (+1 cycles)
    cbi _SFR_IO_ADDR( _FPOR1), _FPIN1	; C 0x14 set fast pin 0 low
    rjmp _intptr_loop_0nop;		; - 0x15 jump back (+1 cycles)
    sbi _SFR_IO_ADDR( _FPOR1), _FPIN1	; C 0x16 set fast pin 0 high
    rjmp _intptr_loop_0nop;		; - 0x17 jump back (+1 cycles)
    cbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; C 0x18 set fast pin 0 low
    rjmp _intptr_loop_0nop;		; - 0x19 jump back (+1 cycles)
    sbi _SFR_IO_ADDR( _FPOR2), _FPIN2	; C 0 set fast pin 0 high
    rjmp _intptr_loop_0nop;		; - 0x21 jump back (+1 cycles)
    cbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; C 0x22 set fast pin 0 low
    rjmp _intptr_loop_0nop;		; - 0x23 jump back (+1 cycles)
    sbi _SFR_IO_ADDR( _FPOR3), _FPIN3	; C 0x24 set fast pin 0 high
    rjmp _intptr_loop_0nop;		; - 0x25 jump back (+1 cycles)


  

    // ============ END OF JUMP TABLE =================



_cmd_end_program:
    ldi r25, 0
    mov r0, r25
    rjmp _restore_registers_and_return 

_cmd_invalid_op:
    ldi r25, 1
    mov r0, r25
    rjmp _restore_registers_and_return 


// this initializes the 'fast loop' with an 7bit counter
_cmd_init_fast_loop_8:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    clr	 rCntH			; 9c - set the high counter bits zero
    movw r2, Y			; 10c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_4nop	; 12c

// this initializes the 'fast loop' with an 15bit counter
_cmd_init_fast_loop_16:		; 6c
    ld   rCntL, Y+		; 8c - load the counter low byte
    ld   rCntH, Y+		; 10c - load the counter low byte
    movw r2, Y			; 11c - store the current table position as loop 'jump to' point
    rjmp _intptr_loop_3nop	; 13c




