#include <avr/io.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>

// TODO: enclose in ifdef for simulator compule?
#include <avr_mcu_section.h>
AVR_MCU(F_CPU,"atmega328");
AVR_MCU_VCD_FILE("gtkwavetrace.vcd", 1);

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
    { AVR_MCU_VCD_SYMBOL("PORTB"), .what = (void*)&PORTB, },
    { AVR_MCU_VCD_SYMBOL("PORTB1"), .mask = (1 ), .what= (void*)&PORTB, },
};


/*
static int uart_putchar(char c, FILE *stream) {
  if (c == '\n')
    uart_putchar('\r', stream);
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}

static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL,
                                         _FDEV_SETUP_WRITE);
*/

extern void timing_interpreter(); 
extern void asmtest();

volatile uint8_t  timing_status;
volatile uint16_t timing_position;

volatile uint8_t timing_table[90] = {
    
    0x10,   // toggle pin low
    0x12,   // toogle pin high
    0x10,   // toggle pin low
    0x0C,   // init loop w. 7-bit counter
    0x0A,   // -- for 10 loops
    0x12,   //   - toogle pin high
    0x04,   //   - loop counter --
    0x10,   //   - toggle pin low
    0x08,   //   - jump back
    
    0x02,
    0x02,

    0x0D,   // init loop w. 15-bit counter
    0x04,   // -- for    12 loops
    0x00,   // -- for 0*256 loops
    0x12,   //   - toogle pin high
    0x02,   //	 - nop
    0x02,   //   - nop
    0x10,   //   - toggle pin low
    0x04,   //   - loop counter --
    0x08,   //   - jump back

    0x0C,   // init loop w. 7-bit counter
    30  ,   // -- for    30 loops
    0x12,   //   - toogle pin high
    0x10,   //   - toggle pin low
    0x20,   //	 - delay via internal nop loop
    33,     //	    loop 33 times 
    0x04,   //   - loop counter --
    0x08,   //   - jump back




    0x00    // end programm
}; 


int main() {

    DDRB=0xff;

    /*   
    stdout= &mystdout;

    printf("jump_table %d (l %d, h %d) \n",
	(int)&jump_table, (int)((&jump_table))&0xFF, (int)(&jump_table)>>8);

    */

    timing_interpreter();

    cli();
    sleep_cpu();
}
