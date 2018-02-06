// include stdlib and int sizes
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "avrprogmem.h"
#include "parser.h"
#include "opcodes.h"


#define CMP(s) ( strcmp_P( cmd, PSTR( s )) == 0 )

#define _LMASK_A 0b00001000 
#define _LMASK_B 0b00000100 
#define _LMASK_C 0b00000010 
#define _LMASK_D 0b00000001 


const char _cmd_delim[] PROGMEM = " \t\n"; 

struct {
    int8_t  loop_mask;	// 0b0000ABCD (bit 1 -> loop is open)
    int16_t cmd_count;	// how many cmds have been issued
    int16_t cmd_bytes;
} parser_state;


#define _INTERR_NOTFOUND  -8
#define _INTERR_EXTRACHAR  1
int8_t _int_parse_err;


int16_t find_opcode_bycode( uint8_t opcode ) {
    int16_t ret=0;
    const opcode_struct * opc = opcode_list;
    while ( pgm_read_byte( &(opc->byte) ) !=0xFF ) {
	if ( pgm_read_byte( &(opc->byte) ) == opcode ) {
	    return ret;
	}
	opc++; ret++;
    }
    return -1;
}


int16_t find_opcode_bynm(const char * mn) {
    int16_t ret = 0; 
    const opcode_struct * opc = opcode_list;
    while ( pgm_read_byte( &(opc->byte) ) !=0xFF ) {
	//printf(" -> %ld -> %s \n",opc,opc->mnemonic);
	if ( strncmp_P( mn,  opc->mnemonic , 4 ) == 0 ) {
	    //printf(" found %d -> %ld -> %s \n",ret,opc,opc->mnemonic);
	    return ret;
	} 
	opc++; ret++;
    }
    return -1;
}

int16_t find_opcode_bynm_P(const char * mn_P ) {
    char opcode[5];
    strncpy_P( opcode, mn_P, 4);
    return find_opcode_bynm( opcode);
}


// set an error number 
long parse_int( const char * tokens ) {

    _int_parse_err = 0;
    char * end;

    long ret = strtol( tokens, &end, 0);
    if ( end == tokens ) {
	_int_parse_err = _INTERR_NOTFOUND;
	return 0;
    }
    if ( *end != '\0' ) {
	_int_parse_err = _INTERR_EXTRACHAR;
    }
    return ret;
}


// parse a line of clear-text into a command
parsed_cmd parse_line(char * line) {

    // default return is 'invalid command"
    parsed_cmd ret = { CSIZE_INVALID, {0, 0, 0, 0}};

    // tokenize the first part of the command
    char * cmd = strtok_P( line, _cmd_delim );

    // check for comments
    if ( cmd!=NULL && cmd[0]=='#' ) {
	ret.size = CSIZE_COMMENT;
	return ret;
    } 

    // check for empty lines, white-space only
    if (cmd==NULL) {
	ret.size=CSIZE_WSPACE;
	return ret;
    }
    
    // ----- high level commands ------

    // loop: expands to one of the loop commands
    if ( strcmp_P( cmd, PSTR("loop"))==0 ) {
	
	uint8_t lm = 0;
	
	// figure out which loop to open
	if ( ! (parser_state.loop_mask & _LMASK_A ) ) lm = _LMASK_A ; 
	if ( ! (parser_state.loop_mask & _LMASK_B ) ) lm = _LMASK_B ; 
	if ( ! (parser_state.loop_mask & _LMASK_C ) ) lm = _LMASK_C ; 
	if ( ! (parser_state.loop_mask & _LMASK_D ) ) lm = _LMASK_D ; 
	
	if ( !lm  ) {
	    ret.size = CSIZE_LFULL;
	    return ret;
	}	

	
	// figure out the number of iterations
	char * carg = strtok_P( NULL, _cmd_delim );
	long iarg   = parse_int( carg );
	
	if ( _int_parse_err || iarg <=0 || iarg >= 32768 ) {
	    ret.size = CSIZE_ARGERR;
	    return ret; 
	}	 

	// figure out bit depth
	if ( iarg < 128 ) {
	    ret.size = 2;
	    ret.cmd[1] = (int8_t)iarg;
	} else {
	    ret.size = 3;
	    ret.cmd[1] = (uint8_t) iarg&0xFF;
	    ret.cmd[2] = (uint8_t) (iarg>>8);
	}

	//printf("DBG: lm: %d\n",lm);

	// figure out the command
	if ( lm == _LMASK_A && ret.size == 2 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lia1")) ;
	if ( lm == _LMASK_A && ret.size == 3 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lia2")) ;
	if ( lm == _LMASK_B && ret.size == 2 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lib1")) ;
	if ( lm == _LMASK_B && ret.size == 3 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lib2")) ;
	if ( lm == _LMASK_C && ret.size == 2 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lic1")) ;
	if ( lm == _LMASK_C && ret.size == 3 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lic2")) ;
	if ( lm == _LMASK_D && ret.size == 2 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lid1")) ;
	if ( lm == _LMASK_D && ret.size == 3 ) ret.cmd[0] = find_opcode_bynm_P(PSTR("lid2")) ;
	
	// check for opcode not found, which should really not happen
	if (ret.cmd[0]<0) {
	    ret.size = CSIZE_PARSERERR;
	} else {
	    ret.cmd[0] = pgm_read_byte( &opcode_list[ret.cmd[0]].byte );
	}

	// update parser state
	parser_state.loop_mask |= lm;
	parser_state.cmd_count++;
	parser_state.cmd_bytes+=ret.size;
		
	return ret; 	    
    } 


    return ret;
}



