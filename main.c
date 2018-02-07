#include <avr/io.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "avrprogmem.h"
#include "parser.h"

// ------ SIMAVR hooks -------------

#include <avr_mcu_section.h>
AVR_MCU(F_CPU,"atmega328");
AVR_MCU_VCD_FILE("gtkwavetrace.vcd", 1);

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
    { AVR_MCU_VCD_SYMBOL("PORTD"), .what = (void*)&PORTD, },
    { AVR_MCU_VCD_SYMBOL("PORTD2"), .mask = (1<<2 ), .what= (void*)&PORTD, },
};

// ------ timing interpreter ------

void timing_interpreter(); 
volatile uint8_t timing_table[1536] = {0};

// ------ serial port ------

char uart_line_buffer[140];

static int uart_putchar(char c, FILE *stream) {
  if (c == '\n')
    uart_putchar('\r', stream);
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}

static FILE uartstdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

static int uart_readline() {

    uint8_t ccount=0;

    while (1) {
	loop_until_bit_is_set(UCSR0A, RXC0);
	char c = UDR0;
	if ( c=='\r' || c=='\n') break;
	uart_line_buffer[ccount++]=c;
    }
    uart_line_buffer[ccount]='\0';
    return ccount;
}


// ------ main loop ------

int main() {

    // redirect 
    stdout=&uartstdout;
    
    DDRD=0x04;

    parser_init( timing_table );

    printf_P(PSTR("\n\n----- micro-tics: Welcome -----\n\n"));


    while (1) {

	printf_P(PSTR("> "));

	// read a line from serial	
	uart_readline();

	// run it through the parser
	int res = parse_line( uart_line_buffer );

	// echo back our state
	parser_echo_result(res);	
	
    }


    cli();
    timing_interpreter();
    cli();
    sleep_cpu();
}
