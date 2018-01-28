#include <stdint.h>
#include <avr/io.h>
#include <avr/sleep.h>

// TODO: enclose in ifdef for simulator compule?
#include <avr_mcu_section.h>
AVR_MCU(F_CPU,"atmega88");

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
    { AVR_MCU_VCD_SYMBOL("PORTB"), .what = (void*)&PORTB, },
    //{ AVR_MCU_VCD_SYMBOL("UDRE0"), .mask = (1 << UDRE0), .what= (void*)&UCSR0A, },
};


uint8_t timing_table[8192] = {0x11 };

int main() {

    DDRB=0xff;

    for (;;) {

    PORTB = 0x01;
    for (uint16_t i=0; i<1024; i++) {
	__asm__("nop");
    }
    PORTB = 0x00;
    
    for (uint16_t i=0; i<1024; i++) {
	__asm__("nop");
    }
    }
    sleep_cpu();
}
