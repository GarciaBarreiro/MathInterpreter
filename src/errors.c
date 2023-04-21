#include <stdio.h>
#include <stdlib.h>
#include "errors.h"
#include "tree.h"

void printError(int error) {
    switch (error) {
        case ERR_BAD_ARGS:
            fprintf(stderr, "ERROR: Bad arguments passed\n");
            fprintf(stderr, "       Use `-h` for help\n");
            exit(1);
            break;
        case ERR_NO_INPUT:
            fprintf(stderr, "ERROR: No input file\n");      // don't need it
            exit(1);
            break;
        case ERR_BAD_FILE:
            fprintf(stderr, "ERROR: Unable to read file, going back to prompt mode\n");
            break;
        case ERR_BAD_EXTENSION:
            fprintf(stderr, "ERROR: File needs to have a MA extension, going back to prompt mode\n");
            break;
        case ERR_BAD_MALLOC:
            fprintf(stderr, "INTERNAL ERROR: `malloc` has failed, aborting...\n");
            freeTree();
            exit(2);
            break;
        case ERR_BAD_REALLOC:
            fprintf(stderr, "INTERNAL ERROR: `realloc` has failed, aborting...\n");
            freeTree();
            exit(2);
            break;
    }
}

void printErrorLine(int error, int line_number) {
    switch (error) {
        case ERR_BLOCK_COMMENT:
            fprintf(stderr, "LEXICAL ERROR: Block comment not closed at line %d\n", line_number);
            break;
        case ERR_NESTED_COMMENT:
            fprintf(stderr, "LEXICAL ERROR: Nested comment not closed at line %d\n", line_number);
            break;
        case ERR_SYNTAX:
            fprintf(stderr, "SYNTAX ERROR: TODO\n");
    }
}
