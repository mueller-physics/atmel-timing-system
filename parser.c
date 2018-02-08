// include stdlib and int sizes
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

#include "avrprogmem.h"
#include "parser.h"
#include "opcodes.h"


#define CMP(s) ( strcmp_P( cmd, PSTR( s )) == 0 )

#define _LMASK_A 0b00001000 
#define _LMASK_B 0b00000100 
#define _LMASK_C 0b00000010 
#define _LMASK_D 0b00000001 


const char _cmd_delim[] PROGMEM = " \t\n"; 

volatile uint8_t * cmd_table;    // the table to store commands in
int8_t  loop_mask;	    // 0b0000ABCD (bit 1 -> loop is open)
int16_t cmd_count;	    // how many cmds have been issued
int16_t cmd_bytes;	    // how many bytes have been written
int8_t  last_cmd_size;  // how long was the last command

int8_t parser_verbosity = 1;

#define _INTERR_NOTFOUND  -8
#define _INTERR_EXTRACHAR  1
int8_t _int_parse_err;

parsed_cmd ret_last_cmd() {
    parsed_cmd ret = {0x00};
    if ( cmd_count == 0 )
	return ret;

    ret.size = last_cmd_size;

    for (uint8_t i=0; i<ret.size; i++) {
	ret.cmd[i] = cmd_table[ cmd_bytes - last_cmd_size + i   ];
    }

    return ret;
}

void parser_init( volatile uint8_t * cmdtable ) {
    cmd_table = cmdtable;
    loop_mask = 0;
    cmd_count = 0;
    cmd_bytes = 0;
    last_cmd_size = 0;
}


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
int16_t parse_line(char * line) {

    // tokenize the first part of the command
    char * cmd = strtok_P( line, _cmd_delim );

    // check for comments
    if ( cmd!=NULL && cmd[0]=='#' ) {
	return PARSE_COMMENT;
    } 

    // check for empty lines, white-space only
    if (cmd==NULL) {
	return PARSE_WSPACE;
    }
    
    // ----- parser meta-commands -----
    
    if ( strcmp_P(cmd, PSTR(".run"))==0) {
	if (parser_verbosity)
	    printf_P(PSTR("starting program as loaded\n"));
	return PARSE_META_RUN;
    }

    if ( strcmp_P(cmd, PSTR(".verb")) == 0 ) {
	
	char * carg = strtok_P( NULL, _cmd_delim );
	long iarg   = parse_int( carg );
	
	if (!_int_parse_err && iarg >=0 && iarg <=10 ) {
	    parser_verbosity = iarg;
	    printf_P(PSTR("# meta cmd, parser now at verbosity %d\n"), parser_verbosity);
	} else {
	    printf_P(PSTR("# usage '.verb 0..10' to set verbosity\n"));
	    printf_P(PSTR("# current verbosity: %d\n"),parser_verbosity);
	}
	return PARSE_META;
    }

    if ( strcmp_P(cmd, PSTR(".list"))==0) {
	print_listing();
	return PARSE_META;
    }
    
    if ( strcmp_P(cmd, PSTR(".mem"))==0) {
	printf_P(PSTR("# memory: %d commands, %d bytes\n"),cmd_count, cmd_bytes);
	return PARSE_META;
    }
    
    // ----- high level commands ------

    // loop: expands to one of the loop commands
    if ( strcmp_P( cmd, PSTR("loop"))==0 ) {
	
	uint8_t lm = 0;
	
	// figure out which loop to open
	if ( ! (loop_mask & _LMASK_A ) ) lm = _LMASK_A ; 
	if ( ! (loop_mask & _LMASK_B ) ) lm = _LMASK_B ; 
	if ( ! (loop_mask & _LMASK_C ) ) lm = _LMASK_C ; 
	if ( ! (loop_mask & _LMASK_D ) ) lm = _LMASK_D ; 
	
	if ( !lm  ) {
	    return PARSE_LFULL;
	}	
	
	// figure out the number of iterations
	char * carg = strtok_P( NULL, _cmd_delim );
	long iarg   = parse_int( carg );
	
	if ( _int_parse_err || iarg <=0 || iarg >= 32768 ) {
	    return PARSE_ARGRANGE; 
	}	 

	uint8_t size,arg[2],cmd=-1;

	
	// figure out bit depth
	if ( iarg < 128 ) {
	    size = 2;
	    arg[0] = (int8_t)iarg;
	} else {
	    size = 3;
	    arg[0] = (uint8_t) iarg&0xFF;
	    arg[1] = (uint8_t) (iarg>>8);
	}

	//printf("DBG: lm: %d\n",lm);

	// figure out the command
	if ( lm == _LMASK_A && size == 2 ) cmd = find_opcode_bynm_P(PSTR("lia1")) ;
	if ( lm == _LMASK_A && size == 3 ) cmd = find_opcode_bynm_P(PSTR("lia2")) ;
	if ( lm == _LMASK_B && size == 2 ) cmd = find_opcode_bynm_P(PSTR("lib1")) ;
	if ( lm == _LMASK_B && size == 3 ) cmd = find_opcode_bynm_P(PSTR("lib2")) ;
	if ( lm == _LMASK_C && size == 2 ) cmd = find_opcode_bynm_P(PSTR("lic1")) ;
	if ( lm == _LMASK_C && size == 3 ) cmd = find_opcode_bynm_P(PSTR("lic2")) ;
	if ( lm == _LMASK_D && size == 2 ) cmd = find_opcode_bynm_P(PSTR("lid1")) ;
	if ( lm == _LMASK_D && size == 3 ) cmd = find_opcode_bynm_P(PSTR("lid2")) ;
	
	
	// check for opcode not found, which should really not happen
	if (cmd<0) {
	    return PARSE_NOOPCODE;
	} else {
	    cmd = pgm_read_byte( &opcode_list[cmd].byte );
	}
	

	// update parser state
	cmd_table[ cmd_bytes   ] = cmd;	
	cmd_table[ cmd_bytes+1 ] = arg[0];	
	if (size==3)
	    cmd_table[ cmd_bytes+2 ] = arg[1];	
	loop_mask |= lm;
	cmd_count++;
	cmd_bytes+=size;
	last_cmd_size=size;    
	
	return PARSE_COMMAND; 	    
    } 

    if ( strcmp_P( cmd, PSTR("endloop")) == 0 ) {
	
	int8_t lm=0x00;
	if (  loop_mask & _LMASK_D  ) lm = _LMASK_D ; 
	if (  loop_mask & _LMASK_C  ) lm = _LMASK_C ; 
	if (  loop_mask & _LMASK_B  ) lm = _LMASK_B ; 
	if (  loop_mask & _LMASK_A  ) lm = _LMASK_A ; 
	
	// check if at least 1 loop is open
	if ( !lm ) {
	    if (parser_verbosity)
		printf("hint: currently no loop is open\n");
	    return PARSE_LEVELERR;
	}

	int8_t cmd =0xff;
	if ( lm == _LMASK_A ) cmd = find_opcode_bynm_P(PSTR("dja")) ;
	if ( lm == _LMASK_B ) cmd = find_opcode_bynm_P(PSTR("djb")) ;
	if ( lm == _LMASK_C ) cmd = find_opcode_bynm_P(PSTR("djc")) ;
	if ( lm == _LMASK_D ) cmd = find_opcode_bynm_P(PSTR("djd")) ;
	
	// check for opcode not found, which should really not happen
	if (cmd<0) {
	    return PARSE_NOOPCODE;
	} else {
	    cmd = pgm_read_byte( &opcode_list[cmd].byte );
	}

	// update parser state
	cmd_table[ cmd_bytes   ] = cmd;	
	loop_mask &= ~lm;
	cmd_count++;
	cmd_bytes++;
	last_cmd_size=1;    
	return PARSE_COMMAND; 	    

    }   



    // turn on/off commands
    if ( strcmp_P( cmd, PSTR("turn"))==0 ) {

	// simple version first, get next argument, it should be 'p2' ... 'p9'
	char * carg = strtok_P( NULL, _cmd_delim );
    
	if ( carg[0] !='p' || carg[1]<'2' || carg[1]>'9' ) {
	    if (parser_verbosity)
		printf_P(PSTR("hint: pin not recognized, try p2, p3, .., p9\n"));//TODO: +'or a label'
	    return PARSE_ARGRANGE;
	}	

	int8_t pin_nr = carg[1]+2-'2';

	// match for on/off
	carg = strtok_P( NULL, _cmd_delim );
	if (carg[0] != 'o' || ( carg[1] !='f' && carg[1] !='n')) {
	    if (parser_verbosity)
		printf_P(PSTR("hint: try either 'on' or 'off'\n")); 
	    return PARSE_ARGRANGE;
	}

	int8_t pin_st = ( carg[1]=='n' );
	int8_t cmd = 0xFF;
	
	if ( pin_nr == 2 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp2l")) ;
	if ( pin_nr == 2 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp2h")) ;
	
	if ( pin_nr == 3 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp3l")) ;
	if ( pin_nr == 3 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp3h")) ;
	
	if ( pin_nr == 4 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp4l")) ;
	if ( pin_nr == 4 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp4h")) ;
	
	if ( pin_nr == 5 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp5l")) ;
	if ( pin_nr == 5 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp5h")) ;
	
	if ( pin_nr == 6 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp6l")) ;
	if ( pin_nr == 6 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp6h")) ;
	
	if ( pin_nr == 7 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp7l")) ;
	if ( pin_nr == 7 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp7h")) ;
	
	if ( pin_nr == 8 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp8l")) ;
	if ( pin_nr == 8 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp8h")) ;
	
	if ( pin_nr == 9 && !pin_st ) cmd = find_opcode_bynm_P(PSTR("sp9l")) ;
	if ( pin_nr == 9 &&  pin_st ) cmd = find_opcode_bynm_P(PSTR("sp9h")) ;
	
	if (cmd<0) {
	    return PARSE_NOOPCODE;
	} else {
	    cmd = pgm_read_byte( &opcode_list[cmd].byte );
	}
	
	// update parser state
	cmd_table[ cmd_bytes ] = cmd;	
	cmd_count++;
	cmd_bytes++;
	last_cmd_size=1;    
	
	return PARSE_COMMAND; 	    


    }

    return PARSE_UNKNOWN;
}



void parser_echo_result( int16_t rescode ) {

    if (rescode != PARSE_COMMAND ) {
	switch (rescode) {
	    case PARSE_WSPACE:
		if (parser_verbosity>3) printf_P(PSTR(" . . . . . whitespaces . . . . \n"));
		break;
	    case PARSE_COMMENT:
		if (parser_verbosity>3) printf_P(PSTR("# .-.-.-. comment line .-.-.-.\n"));
		break;
	    case PARSE_META:
		if (parser_verbosity>2) printf_P(PSTR("# -=-=-=- META COMMAND -=-=-=-\n"));
		break;
	    
	    case PARSE_UNKNOWN:
		printf_P(PSTR("ERR: unknown command\n"));
		break;
	    
	    case PARSE_ARGRANGE:
		printf_P(PSTR("ERR: argument out of range\n"));
		break;	    
	    
	    case PARSE_LEVELERR:
		printf_P(PSTR("ERR: nesting level wrong\n"));
		break;	    

	    case PARSE_LFULL:
		printf_P(PSTR("ERR: too many nested loops\n"));
		break;

	    case PARSE_NOOPCODE:
		printf_P(PSTR("ERR: internal opcode lookup failed\n"));
		break;
	}
    } else if (parser_verbosity>1) {

	parsed_cmd res = ret_last_cmd();
	//printf("res: %d\n",res.size);

	switch (res.size) {

	    case 0x01:
		printf_P(PSTR("l%4d  b%4d c %#2x (1B)              ; "), 
		    cmd_count, cmd_bytes, res.cmd[0] );
		puts_P( opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		break;
	    case 0x02:
		printf_P(PSTR("l%4d  b%4d c %#2x (2B) par: %5d  ; "), cmd_count, cmd_bytes,  
		    res.cmd[0], res.cmd[1] );
		puts_P( opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		break;
	    case 0x03:
		printf_P(PSTR("l%4d  b%4d c %#2x (3B) par: %5d  ; "), cmd_count, cmd_bytes,  
		    res.cmd[0], (res.cmd[2]<<8)+res.cmd[1]);
		puts_P( opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		break;
	    case 0x04:
		printf_P(PSTR("l%4d  b%4d c %#2x (4B) par: %5ld ; "), cmd_count, cmd_bytes,  
		    res.cmd[0], (((long)res.cmd[3])<<16)+(long)(res.cmd[2]<<8)+(long)res.cmd[1]);
		puts_P( opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		break;
	    }
    }

}

void print_listing() {

    int16_t curpos =0, curcount=0, nest_level=0;
    char cache[10];    

    while (curpos<cmd_bytes) {
	
	// fetch command
	uint8_t cmd = cmd_table[curpos];
	int16_t op  = find_opcode_bycode( cmd );
	uint8_t size = pgm_read_byte( &(opcode_list[op].size));
   
	// 'line' number
	printf_P(PSTR("%04d. "),curcount);
	
	// 3x whitespace per nesting level
	for (uint8_t n=0;n<nest_level;n++)
	    printf_P(PSTR("   "));

	// the name of the command
	strncpy_P( cache, opcode_list[op].name,9 );
	printf_P(PSTR("%-9s "), cache);

	// the parameter
	if ( pgm_read_byte(&opcode_list[op].dprt) == 1 ) {
	    if (size==2) {
		printf_P(PSTR("<- %5d "), cmd_table[curpos+1]); 
	    } 
	    if (size==3) {
		printf_P(PSTR("<- %5d "), (cmd_table[curpos+2]<<8)+cmd_table[curpos+1]); 
	    }
	    if (size==4) {
		printf_P(PSTR("<- %5ld "), 
		    ((long)cmd_table[curpos+3]<<16)+(cmd_table[curpos+2]<<8)+cmd_table[curpos+1]); 
	    }
	} else {
	    if (size==2) {
		printf_P(PSTR("0x%2x     "), cmd_table[curpos+1]); 
	    } 
	    if (size==3) {
		printf_P(PSTR("0x%2x 0x%2x"), cmd_table[curpos+1],cmd_table[curpos+2]); 
	    }
	}

	if (parser_verbosity>1) { 
	    for (uint8_t n=0;n<(3*(5-nest_level)+((size>1)?(0):(9)));n++) {
		printf_P(PSTR(" "));
	    }
	    puts_P( &(opcode_list[op].desc[0]) );
	} else {
	    printf_P(PSTR("\n"));
	}
    

	nest_level += (int8_t)pgm_read_byte(&opcode_list[op].nest);
	curpos += size;
	curcount++;
    }



}




void parser_setverbosity( int8_t verb ) {
    parser_verbosity = verb;
}

