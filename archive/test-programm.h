// for testing, ready-made timing table
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

