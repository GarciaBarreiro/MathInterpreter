#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_LENGTH 1024

int main(int argc, char *argv[]) {
    char input_buf[MAX_LENGTH];
    /*
    char c;
    short oflag = 0;
    char *input = NULL;     // input file name
    char *output = NULL;    // output file name
    // option parser
    while ((c = getopt(argc, argv, "ho:")) != -1) {
        switch (c) {
            case 'o':
                if (!oflag) output = optarg;
                oflag = 1;
                break;
            case 'h':
                _printHelp();
                exit(1);
            default:
                printf("Use `-h` for help\n");
                exit(1);
        }
    }

    if (argc == 1) printError(ERR_NO_ARGS);

    for (int i = optind; i < argc; i++)
        if (!input) input = argv[i];

    if (!input) printError(ERR_NO_INPUT);
    */

    yyparse();
    while (1) {
        printf("> ");
        fgets(input_buf, MAX_LENGTH, stdin);    // SAVES \n
        printf("  %s", input_buf);
        memset(input_buf, '\0', MAX_LENGTH);
    }

    return 0;
}
