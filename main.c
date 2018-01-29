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
    { AVR_MCU_VCD_SYMBOL("PORTB1"), .mask = (2 ), .what= (void*)&PORTB, },
};


static int uart_putchar(char c, FILE *stream) {
  if (c == '\n')
    uart_putchar('\r', stream);
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}


static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL,
                                         _FDEV_SETUP_WRITE);


extern void timing_interpreter(); 
extern void asmtest();

uint8_t spacing[80] ={0,1,2,3,4,5,6};


volatile uint8_t timing_table[90] = {

    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x11,   // set low on port b
    0xFF,   // all pins
    0x21,   // set high on port b
    0xFF,   // all pins  
    0x70    // end program 
}; 


int main() {

    DDRB=0xff;
   
    stdout= &mystdout;
    /*
    stdout = &mystdout;


    printf("timing_table %d (%d,%d) \n",
	(int)&timing_table, (int)((&timing_table))&0xFF, (int)(&timing_table)>>8);

    */
    
    cli();
    timing_interpreter();
    
    //asmtest();
    cli();


    sleep_cpu();
}
