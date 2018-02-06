#include <stdint.h>

#define CSIZE_1BYTE 0x01
#define CSIZE_2BYTE 0x02
#define CSIZE_3BYTE 0x03
#define CSIZE_4BYTE 0x04
#define CSIZE_WSPACE  0xA0
#define CSIZE_COMMENT 0xA1
#define CSIZE_ARGERR  0xB0
#define CSIZE_LFULL   0xB1
#define CSIZE_PARSERERR 0xFE
#define CSIZE_INVALID 0xFF


typedef struct {
    uint8_t size;
    uint8_t cmd[4];
} parsed_cmd ; 

parsed_cmd parse_line(char * line);

int16_t find_opcode_bycode(uint8_t code);
int16_t find_opcode_bynm( const char *nmemonic);

