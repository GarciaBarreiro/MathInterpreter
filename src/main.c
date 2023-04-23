#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "lex.yy.h"
#include "syn.tab.h"

#include "errors.h"
#include "tree.h"

#define MAX_LENGTH 1024

void _printHelp() {
    printf("Usage:\n"
           "    ./mathI [-i file]\n\n"
           "Options:\n"
           "    -h        Shows this screen\n"
           "    -i FILE   Reads input from FILE\n\n"
           "Inside the prompt, call `help()` for help with functions\n");
}

int main(int argc, char *argv[]) {
    char c;
    short iflag = 0;
    char *input = NULL;     // input file name
    char *ext = NULL;       // pointer to file extension

    // option parser
    while ((c = getopt(argc, argv, "hi:")) != -1) {
        switch (c) {
            case 'i':
                if (!iflag) input = optarg;
                iflag = 1;
                break;
            case 'h':
                _printHelp();
                exit(1);
            default:
                printError(ERR_BAD_ARGS);
        }
    }

    if (optind != argc) printError(ERR_BAD_ARGS);

    if (input) {
        ext = strrchr(input, '.');
        if (!ext || strcmp(ext, ".mi")) {
            printError(ERR_BAD_EXTENSION);
        } else {
            yyin = fopen(input, "r");
        }
    } else yyin = stdin;

    initTree();

    short ret = 1;
    while (ret) {  // if ret == 0, YYACCEPT
        ret = yyparse();
    }
    freeTree(); // in case it ends differently than with `exit()`

    return 0;
}
