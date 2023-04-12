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
        "    ./mathA [-i file] [-o file]\n\n"
        "Options:\n"
        "    -h        Shows this screen\n"
        "    -i FILE   Reads input from FILE\n"
        "    -o FILE   Saves output to FILE\n\n"
        "Inside the prompt, call `help()` for help with functions\n");
}

int main(int argc, char *argv[]) {
    char c;
    short oflag = 0, iflag = 0;
    char *input = NULL;     // input file name
    char *output = NULL;    // output file name (NEEDED???)
    // option parser
    while ((c = getopt(argc, argv, "ho:i:")) != -1) {
        switch (c) {
            case 'o':
                if (!oflag) output = optarg;
                oflag = 1;
                break;
            case 'i':
                if (!iflag) input = optarg;
                iflag = 1;
                break;
            case 'h':
                _printHelp();
                exit(1);
            default:
                printf("ERROR: Use `-h` for help\n");
                exit(1);
        }
    }

    if (optind != argc) printError(ERR_BAD_ARGS);

    if (input) {
        printf("%s\n", input);
        yyin = fopen(input, "r");
    } else yyin = stdin;
    if (output) printf("%s\n", output);
    printf("optind == %d\n", optind);
    printf("argc == %d\n", argc);

    initTree();
    short ret = 1;
    while (ret) {
        ret = yyparse();
    }
    freeTree();

    return 0;
}
