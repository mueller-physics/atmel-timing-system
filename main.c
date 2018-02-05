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
volatile uint8_t timing_table[1536] = {0};

int main() {

    DDRD=0x04;

    cli();
    timing_interpreter();
    cli();
    sleep_cpu();
}
