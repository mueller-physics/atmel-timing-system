#include <avr/pgmspace.h>

#define CSIZE_1BYTE 0x01
#define CSIZE_2BYTE 0x02
#define CSIZE_3BYTE 0x03
#define CSIZE_4BYTE 0x04
#define CSIZE_COMMENT 0xF0
#define CSIZE_INVALID 0xFF


typedef struct {
    uint8_t size;
    uint8_t cmd[4];
} parsed_cmd ; 

parsed_cmd parse_line(char * line);


#define CMP(s) ( strcmp_P( cmd, PSTR( s )) == 0 )

