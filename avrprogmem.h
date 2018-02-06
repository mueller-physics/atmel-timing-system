#ifndef _INC_AVR_PROGMEM
#define _INC_AVR_PROGMEM

// redefine AVRs 'progmem' functions to their
// defaults when compiling for standard CPU
#ifndef NOAVR
#include <avr/pgmspace.h>

#else
#define PSTR(s) s
#define strcmp_P(x,y) strcmp(x,y)
#define strncmp_P(x,y,z) strncmp(x,y,z)
#define strncpy_P(x,y,z) strncpy(x,y,z)
#define strtok_P(x,y) strtok(x,y)
#define pgm_read_byte(x) (* x)
#define PROGMEM 
#include <stdio.h>
#endif

#endif
