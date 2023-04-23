#ifndef ERRORS_H
#define ERRORS_H

#define ERR_BAD_ARGS 0          // bad args passed
#define ERR_BAD_FILE 1          // can't open file
#define ERR_BAD_EXTENSION 2     // bad file extension
#define ERR_BLOCK_COMMENT 3     // EOF and block comment isn't closed
#define ERR_NESTED_COMMENT 4    // EOF and nested comment isn't closed
#define ERR_SYNTAX 5            // byson calls yyerror()
#define ERR_NO_VAR 6            // undef var
#define ERR_NO_FUNC 7           // undef func
#define ERR_ASSIGN_CONST 8      // assigning to constant
#define ERR_NO_LIB 9            // undef / unfound lib
#define ERR_DIV_0 10            // div by 0

void printError(int error);

void printErrorLine(int error, int line_number);

#endif // ERRORS_H
