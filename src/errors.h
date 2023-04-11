#ifndef ERRORS_H
#define ERRORS_H

#define ERR_BAD_ARGS 0      // bad args passed
#define ERR_NO_INPUT 1      // no input passed // NOT NEEDED
#define ERR_BAD_FILE 2      // can't open file
#define ERR_BAD_EXTENSION 3 // bad file extension
#define ERR_BAD_MALLOC 4    // failed `malloc` (exits)
#define ERR_BAD_REALLOC 5   // failed `realloc` (exits)

void printError(int error);

#define ERR_BLOCK_COMMENT 6     // EOF and block comment isn't closed
#define ERR_NESTED_COMMENT 7    // EOF and nested comment isn't closed
#define ERR_SYNTAX 8          // byson calls yyerror()

void printErrorLine(int error, int line_number);

#endif // ERRORS_H
