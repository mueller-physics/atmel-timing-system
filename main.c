#include <avr/io.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "avrprogmem.h"
#include "parser.h"


#define F_CPU 16000000
#define BAUD 9600
#include <util/setbaud.h>


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
volatile uint8_t timing_table[TIMING_TABLE_SIZE] = {0};

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
	if ( c==0x08 || c==0x7F ) {
	    if ( ccount>0 ) {
		ccount--;
		if (_term_echo ) {
		    uart_putchar(0x08,NULL);
		    uart_putchar(' ',NULL);
		    uart_putchar(0x08,NULL);
		}
	    } else {	 
		if (_term_echo ) uart_putchar('\a',NULL);
	    }
	} else {
	    uart_line_buffer[ccount++]=c;
	    if (_term_echo ) uart_putchar(c,NULL);
	}
    }
    uart_line_buffer[ccount]='\0';
    if (_term_echo ) {
	uart_putchar('\r',NULL);
	uart_putchar('\n',NULL);
    }
    return ccount;
}

void init_uart( void ) {
  
  UBRR0L = UBRRL_VALUE;
  UBRR0H = UBRRH_VALUE;
#ifdef USE_2X
  UCSR0A |= (1<<U2X0);
#endif

  UCSR0B |= (1<<TXEN0);
  UCSR0B |= (1<<RXEN0);
  //UCSR0C = (1<<URSEL)|(1 << UCSZ1)|(1 << UCSZ0);


}



// ------ main loop ------

int main() {

    init_uart();

    _term_echo = 1;

    // redirect 
    stdout=&uartstdout;
    
    DDRD=0xff;
    DDRB=0xff;

    parser_init( timing_table );

    printf_P(PSTR("\n\n----- micro-tics: Welcome -----\n\n"));

    while (1) {

	int res=1;

	while (res) {

	    printf_P(PSTR("> "));

	    // read a line from serial	
	    uart_readline();

	    // run it through the parser
	    res = parse_line( uart_line_buffer );

	    // echo back our state
	    parser_echo_result(res);	
	    
	}


	cli();
	timing_interpreter();
	sei();
    }

    sleep_cpu();
}
