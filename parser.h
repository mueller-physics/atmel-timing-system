
#include <stdint.h>

// redefine AVRs 'progmem' functions to their
// defaults when compiling for standard CPU
#ifndef NOAVR
#include <avr/pgmspace.h>
#else
#define PSTR(s) s
#define strcmp_P(x,y) strcmp(x,y)
#define strtok_P(x,y) strtok(x,y)
#define PROGMEM 
#endif


#define CSIZE_1BYTE 0x01
#define CSIZE_2BYTE 0x02
#define CSIZE_3BYTE 0x03
#define CSIZE_4BYTE 0x04
#define CSIZE_WSPACE  0xF0
#define CSIZE_COMMENT 0xF1
#define CSIZE_INVALID 0xFF




typedef struct {
    uint8_t size;
    uint8_t cmd[4];
} parsed_cmd ; 

parsed_cmd parse_line(char * line);


#define CMP(s) ( strcmp_P( cmd, PSTR( s )) == 0 )

