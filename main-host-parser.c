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

    uint8_t cmd_table[1536];

    parser_init( cmd_table );
    parser_setverbosity( verbose );

    while ( (length = getline( &line, &bytes, fp ) )  > 0 ) {
	
	line_counter++;

	if (length>=140) {
	    fprintf(stderr, "Input line too long: %d (is %ld bytes, max. 140)\n", line_counter, bytes ); 
	}

	// feed line to the parser
	char pline[255];
	strncpy( pline, line, sizeof(pline));

	//printf("-> in: %s",pline);

	int res = parse_line( pline );
	//printf("p ret: %d\n",res);
	parser_echo_result( res ) ;    

    }


}
