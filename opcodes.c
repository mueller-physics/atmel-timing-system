#include "opcodes.h"

const opcode_struct opcode_list [] PROGMEM = {
    { .byte=0x00, .mnemonic="ter",  .size=1, .cycl=0xff, .name="term", .desc="terminates the interpreted programm" },
    { .byte=0x01, .mnemonic="nop",  .size=1, .cycl=0x10, .name="noop", .desc="no operation (1 tic)" },
    // delay command
    { .byte=0x20, .mnemonic="dla1", .size=2, .cycl=0x20, .name="delay", .dprt=1, .desc="for 2+n tics, with 1-byte for n" },
    { .byte=0x21, .mnemonic="dla2", .size=3, .cycl=0x20, .name="delay", .dprt=1, .desc="for 2+n tics, with 2-byte for n" },
    { .byte=0x22, .mnemonic="dla3", .size=4, .cycl=0x20, .name="delay", .dprt=1, .desc="for 2+n tics, with 3-byte for n" },
    // loop commands
    { .byte=0x30, .mnemonic="lia1", .size=2, .cycl=0x20, .name="loopA", .nest=1, .dprt=1, .desc="set A1 (1byte), store cur. pos. in A2" },
    { .byte=0x31, .mnemonic="lia2", .size=3, .cycl=0x20, .name="loopA", .nest=1, .dprt=1, .desc="set A1 (2byte), store cur. pos. in A2" },
    { .byte=0x32, .mnemonic="lib1", .size=2, .cycl=0x20, .name="loopB", .nest=1, .dprt=1, .desc="set B1 (1byte), store cur. pos. in B2" },
    { .byte=0x33, .mnemonic="lib2", .size=3, .cycl=0x20, .name="loopB", .nest=1, .dprt=1, .desc="set B1 (2byte), store cur. pos. in B2" },
    { .byte=0x34, .mnemonic="lic1", .size=2, .cycl=0x20, .name="loopC", .nest=1, .dprt=1, .desc="set C1 (1byte), store cur. pos. in C2" },
    { .byte=0x35, .mnemonic="lic2", .size=3, .cycl=0x20, .name="loopC", .nest=1, .dprt=1, .desc="set C1 (2byte), store cur. pos. in C2" },
    { .byte=0x36, .mnemonic="lid1", .size=2, .cycl=0x20, .name="loopD", .nest=1, .dprt=1, .desc="set D1 (1byte), store cur. pos. in D2" },
    { .byte=0x37, .mnemonic="lid2", .size=3, .cycl=0x20, .name="loopD", .nest=1, .dprt=1, .desc="set D1 (2byte), store cur. pos. in D2" },
    { .byte=0x38, .mnemonic="dja" , .size=1, .cycl=0x20, .name="lEndA", .nest=-1, .desc="A1--, then jump back to A2 if A1>=0" },
    { .byte=0x39, .mnemonic="djb" , .size=1, .cycl=0x20, .name="lEndB", .nest=-1, .desc="B1--, then jump back to B2 if B1>=0" },
    { .byte=0x3A, .mnemonic="djc" , .size=1, .cycl=0x20, .name="lEndC", .nest=-1, .desc="C1--, then jump back to C2 if C1>=0" },
    { .byte=0x3B, .mnemonic="djd" , .size=1, .cycl=0x20, .name="lEndD", .nest=-1, .desc="D1--, then jump back to D2 if D1>=0" },
    { .byte=0x3C, .mnemonic="lif1", .size=2, .cycl=0x10, .name="loopA", .nest=1, .dprt=1, .desc="(fast): same as 'lia1', but one tick" },
    { .byte=0x3D, .mnemonic="lif2", .size=3, .cycl=0x10, .name="loopA", .nest=1, .dprt=1, .desc="(fast): same as 'lia2', but one tick" },
    { .byte=0x3E, .mnemonic="djf" , .size=1, .cycl=0x10, .name="lEndA", .nest=-1, .desc="(fast): same as 'dja', but one tick" },
    // pin set commands
    { .byte=0x40, .mnemonic="sp2l", .size=1, .cycl=0x10, .name="pin2_off", .desc="set pin 2 low (off)" },
    { .byte=0x41, .mnemonic="sp2h", .size=1, .cycl=0x10, .name="pin2_ON",  .desc="set pin 2 high (on)" },
    { .byte=0x42, .mnemonic="sp3l", .size=1, .cycl=0x10, .name="pin3_off", .desc="set pin 3 low (off)" },
    { .byte=0x43, .mnemonic="sp3h", .size=1, .cycl=0x10, .name="pin3_ON",  .desc="set pin 3 high (on)" },
    { .byte=0x44, .mnemonic="sp4l", .size=1, .cycl=0x10, .name="pin4_off", .desc="set pin 4 low (off)" },
    { .byte=0x45, .mnemonic="sp4h", .size=1, .cycl=0x10, .name="pin4_ON",  .desc="set pin 4 high (on)" },
    { .byte=0x46, .mnemonic="sp5l", .size=1, .cycl=0x10, .name="pin5_off", .desc="set pin 5 low (off)" },
    { .byte=0x47, .mnemonic="sp5h", .size=1, .cycl=0x10, .name="pin5_ON",  .desc="set pin 5 high (on)" },
    { .byte=0x48, .mnemonic="sp6l", .size=1, .cycl=0x10, .name="pin6_off", .desc="set pin 6 low (off)" },
    { .byte=0x49, .mnemonic="sp6h", .size=1, .cycl=0x10, .name="pin6_ON",  .desc="set pin 6 high (on)" },
    { .byte=0x4A, .mnemonic="sp7l", .size=1, .cycl=0x10, .name="pin7_off", .desc="set pin 7 low (off)" },
    { .byte=0x4B, .mnemonic="sp7h", .size=1, .cycl=0x10, .name="pin7_ON",  .desc="set pin 7 high (on)" },
    { .byte=0x4C, .mnemonic="sp8l", .size=1, .cycl=0x10, .name="pin8_off", .desc="set pin 8 low (off)" },
    { .byte=0x4D, .mnemonic="sp8h", .size=1, .cycl=0x10, .name="pin8_ON",  .desc="set pin 8 high (on)" },
    { .byte=0x4E, .mnemonic="sp9l", .size=1, .cycl=0x10, .name="pin9_off", .desc="set pin 9 low (off)" },
    { .byte=0x4F, .mnemonic="sp9h", .size=1, .cycl=0x10, .name="pin9_ON",  .desc="set pin 9 high (on)" },
    // EOL meta command
    { .byte=0xFF, .mnemonic="non" , .size=-1, .cycl=0xff, .desc="--- end of command list ---" },

};




