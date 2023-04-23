#include <stdio.h>
#include <stdlib.h>
#include "errors.h"
#include "tree.h"

#define RED   "\x1B[31m"
#define RESET "\x1B[0m"

void printError(int error) {
    switch (error) {
        case ERR_BAD_ARGS:
            fprintf(stderr, "%sERROR%s Bad arguments passed\n", RED, RESET);
            fprintf(stderr, "       Use `-h` for help\n");
            exit(1);
            break;
        case ERR_NO_INPUT:
            fprintf(stderr, "%sERROR%s No input file\n", RED, RESET);      // don't need it
            exit(1);
            break;
        case ERR_BAD_FILE:
            fprintf(stderr, "%sERROR%s Unable to read file, going back to prompt mode\n", RED, RESET);
            break;
        case ERR_BAD_EXTENSION:
            fprintf(stderr, "%sERROR%s File needs to have a MA extension, going back to prompt mode\n", RED, RESET);
            break;
        case ERR_BAD_MALLOC:
            fprintf(stderr, "%sINTERNAL ERROR%s `malloc` has failed, aborting...\n", RED, RESET);
            freeTree();
            exit(2);
            break;
        case ERR_BAD_REALLOC:
            fprintf(stderr, "%sINTERNAL ERROR%s `realloc` has failed, aborting...\n", RED, RESET);
            freeTree();
            exit(2);
            break;
        case ERR_SYNTAX:
            fprintf(stderr, "%sSYNTAX ERROR%s\n", RED, RESET);
            break;
        case ERR_NO_VAR:
            fprintf(stderr, "%sSYNTAX ERROR%s Undefined variable\n", RED, RESET);
            break;
        case ERR_NO_FUNC:
            fprintf(stderr, "%sSYNTAX ERROR%s Undefined function\n", RED, RESET);
            break;
        case ERR_ASSIGN_CONST:
            fprintf(stderr, "%sSYNTAX ERROR%s Can't assign a new value to a constant\n", RED, RESET);
            break;
    }
}

void printErrorLine(int error, int line_number) {
    switch (error) {
        case ERR_BLOCK_COMMENT:
            fprintf(stderr, "%sLEXICAL ERROR%s Block comment not closed at line %d\n", RED, RESET, line_number);
            break;
        case ERR_NESTED_COMMENT:
            fprintf(stderr, "%sLEXICAL ERROR%s Nested comment not closed at line %d\n", RED, RESET, line_number);
            break;
        case ERR_SYNTAX:
            fprintf(stderr, "%sSYNTAX ERROR%s at line %d\n", RED, RESET, line_number);
            break;
        case ERR_NO_VAR:
            fprintf(stderr, "%sSYNTAX ERROR%s Undefined variable at line %d\n", RED, RESET, line_number);
            break;
        case ERR_NO_FUNC:
            fprintf(stderr, "%sSYNTAX ERROR%s Undefined function at line %d\n", RED, RESET, line_number);
            break;
        case ERR_ASSIGN_CONST:
            fprintf(stderr, "%sSYNTAX ERROR%s Can't assign a new value to a constant, at line %d\n", RED, RESET, line_number);
            break;
    }
}
