#include <avr/io.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// TODO: enclose in ifdef for simulator compule?
#include <avr_mcu_section.h>
AVR_MCU(F_CPU,"atmega328");
AVR_MCU_VCD_FILE("gtkwavetrace.vcd", 1);

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
    { AVR_MCU_VCD_SYMBOL("PORTD"), .what = (void*)&PORTD, },
    { AVR_MCU_VCD_SYMBOL("PORTD2"), .mask = (1<<2 ), .what= (void*)&PORTD, },
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
   
    // example for the 'fast' (8 cycle) functions
    0x30,   // ls1: init loop w. 7-bit counter
    0x0A,   // (a)  -- for 10 loops (sets counter A to 10)
    0xA2,   // f2h:  - toogle pin 2 high
    0x84,   // fdc:  - decrease counter A
    0xA0,   // f2l:  - toggle pin 2 low
    0x80,   // fnp:  - do one fast nop
    0xA2,   // f2h:  - toogle pin 2 high
    0x80,   // fnp:  - do one fast nop
    0x80,   // fnp:  - do one fast nop
    0x80,   // fnp:  - do one fast nop
    0xA0,   // f2l:  - toggle pin 2 low
    0x88,   // flr:  - fast loop return: jump back if A>=0
    
    // some nop's
    0x01,   // nop
    0x01,   // nop
   
    // long LED blinking loop 
    0x31,   // ls2: init loop w. 15-bit counter
    0xC4,   // (l)  -- for   196 loops
    0x09,   // (h)  -- for 9*256 loops -> 2500 times
    0xA2,   // f2h:  - toogle pin 2 high
    0x80,   // fnp:  - do one fast nop
    0x22,   // dl3:  - delay w. 24 counter
    0x20,   // (l)
    0xA1,   // (m)
    0x07,   // (h) -> in total 500.000 ticks -> 0.5 sec
    0xA0,   //   - toggle pin low
    0x22,   // dl3:  - delay w. 24 counter
    0x40,   // (l)
    0x42,   // (m)
    0x0F,   // (h) -> in total 1.000.000 ticks -> 1.0 sec
    0x84,   //   - loop counter --
    0x88,   //   - jump back

    0x00    // end programm
}; 


int main() {

    DDRD=0x04;

    /*   
    stdout= &mystdout;

    printf("jump_table %d (l %d, h %d) \n",
	(int)&jump_table, (int)((&jump_table))&0xFF, (int)(&jump_table)>>8);

    */

    timing_interpreter();

    cli();
    sleep_cpu();
}
