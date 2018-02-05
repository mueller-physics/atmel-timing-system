#include <string.h>
#include <stdio.h>

// mini test programm just to see if I understood strtok correctly
int main() {

    char *input = strdup(" This is\ta  test \t  string\n");
    char *token = strtok( input, " \t");

    while (token != NULL) {
	printf("'%s'\n", token);
	token = strtok(NULL, " \t\n");
    }   

    return 0;
}

