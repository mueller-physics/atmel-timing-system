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

    // ----- high level commands ------

    // check for loop
    if ( CMP("loop") ) {

	

	
    }
     



    return ret;
}



