/** 
 * The interpreter's opcodes
 *
 * This is the list of official the 'machine instructions' understood by the interpreter.
 *
 * */

#ifndef _INC_OPCODES_HEADERS
#define _INC_OPCODES_HEADERS

#include "avrprogmem.h"
#include <stdint.h>

typedef struct  {
	uint8_t byte;
	uint8_t size;
	uint8_t cycl;
	uint8_t dprt;
	int8_t nest;
	char mnemonic[5];
	char name[8];
	char desc[40];
}  opcode_struct ;

const opcode_struct opcode_list[100];


#endif

