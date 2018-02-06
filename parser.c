#include "parser.h"
#include "string.h"
// parse a line of clear-text into a command

const char * const  PROGMEM _cmd_delim = " \t\n"; 

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

    // check for loop
    //if ( CMP("loop") ) {
    if ( strcmp_P( cmd, PSTR("loop"))==0 ) {
	ret.size=1;
	ret.cmd[0] = 0x80;	
	
    } 



    return ret;
}



