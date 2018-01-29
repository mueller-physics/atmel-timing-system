#define __SFR_OFFSET 0
#include <avr/io.h>

.global asmtest

asmtest:
    /*
    push r5
    lds r5, testa
    sts testb, r5
    pop r5
    reti
    */
    push r16
    push r17

    ldi r16, 0x00
    ldi r17, 0xff
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop 
    out PORTB, r16
    nop
    out PORTB, r17
    nop

    pop r17
    pop r16
 
    reti
