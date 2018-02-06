#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "opcodes.h"
#include "parser.h"

int main( int argc, char ** argv ) {

    if (argc<=1) {
    }

    int opt, verbose = 0 ;
    char fname[256];

    while ( ( opt = getopt(argc,argv, "vf:"))!=-1) {
	switch (opt) {
	    case 'v':
		verbose++;
		break;
	    case 'f':
		strncpy( fname,  optarg, sizeof(fname));
		break;
	    default:
		fprintf(stderr, "Usage: %s -i input_file [-v]\n",argv[0]);
		fprintf(stderr, "input will be fed through parser line by line\n");
		exit(EXIT_FAILURE);
	}
    }   



    char * line = malloc( 1024 );
    size_t bytes = 1024;
    int length=0;

    printf("# opening micro-tics file: '%s'\n",fname);


    FILE * fp = fopen(fname, "r");

    if (fp==NULL) {
	fprintf(stderr,"Error opening file '%s'\n",fname);
	exit(EXIT_FAILURE);
    }    

    int line_counter=0;

    while ( (length = getline( &line, &bytes, fp ) )  > 0 ) {
	
	line_counter++;

	if (length>=255) {
	    fprintf(stderr, "Input line too long: %d (is %ld bytes, max. 255)\n", line_counter, bytes ); 
	}

	

	// feed line to the parser
	char pline[255];
	strncpy( pline, line, sizeof(pline));

	parsed_cmd res = parse_line( pline );
    
	if (verbose) {
	    switch (res.size) {
		case CSIZE_WSPACE:
		    if (verbose>1) printf("l%4d . . . . \n", line_counter);
		    break;
		case CSIZE_COMMENT:
		    if (verbose>1) printf("l%4d #...... \n", line_counter);
		    break;
		case CSIZE_ARGERR:
		    fprintf(stderr,"l%4d  ERR ->  argument invalid\n", line_counter);
		    break;
		case 0x01:
		    printf("l%4d  c %#2x (1B)              ; %s \n", line_counter, res.cmd[0], 
			opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		    break;
		case 0x02:
		    printf("l%4d  c %#2x  (2B) par: %5d  ; %s \n", line_counter, res.cmd[0], res.cmd[1],
			opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		    break;
		case 0x03:
		    printf("l%4d  c %#2x  (3B) par: %5d  ; %s \n", line_counter, res.cmd[0], 
			(res.cmd[2]<<8)+res.cmd[1],
			opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		    break;
		case 0x04:
		    printf("l%4d  c %#2x  (4B) par: %5d  ; %s \n", line_counter, res.cmd[0], 
			(res.cmd[3]<<16)+(res.cmd[2]<<8)+res.cmd[1],
			opcode_list[ find_opcode_bycode(res.cmd[0]) ].desc ); 
		    break;
		}
	}
	
	


    }


}
