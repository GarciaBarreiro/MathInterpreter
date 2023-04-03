%{
#include "errors.h"
#include "defs.h"

int num_lines = 0;
%}

/* no need to indicate here creation of .h file */
%option yylineno
%option stack
%option noinput nounput noyywrap noyy_top_state

%x BLOCK_COMMENT
%x NESTED_COMMENT

DEC             [0-9][0-9_]*(\.[0-9_]*)?([eE][\+\-]?[0-9_]*)?
BIN             0[bB][01][01_]*
HEX             0[xX][0-9a-fA-F][0-9a-fA-F_]*
LINE_COMMENT    \/\/.*
ID              [a-zA-Z_][a-zA-Z_0-9]*
STRING          \"([^(\\\")]|(\\\"))*\"
SPACE           [ \t]+
NEWLINE         \n

%%

{DEC}  {
    return(M_DEC_NUM);
}

{BIN}  {
    return(M_BIN_NUM);
}

{HEX}  {
    return(M_HEX_NUM);
}

{LINE_COMMENT}  ;

\/\*    {
    BEGIN(BLOCK_COMMENT);
}

<BLOCK_COMMENT>\*\/ {
    BEGIN(INITIAL);
}

<BLOCK_COMMENT>.    ;

<BLOCK_COMMENT>\n   {
    num_lines++;
}

\/\+    {
    yy_push_state(NESTED_COMMENT);
}

<NESTED_COMMENT>\/\+    {
    yy_push_state(NESTED_COMMENT);
}

<NESTED_COMMENT>\+\/    {
    yy_pop_state();
}

<NESTED_COMMENT>.   ;

<NESTED_COMMENT>\n  {
    num_lines++;
}

"=="    {
    return(M_EQUALS);
}

"!="    {
    return(M_NOT_EQUALS);
}

"+="    {
    return(M_PLUS_EQUALS);
}

"++"    {
    return(M_PLUS_PLUS);
}

"-="    {
    return(M_MINUS_EQUALS);
}

"--"    {
    return(M_MINUS_MINUS);
}

{ID}    {
    return(M_ID);
}

{STRING}    {
    return(M_STR);
}

{NEWLINE}   {
    num_lines++;
}

{SPACE}   ;

.   {
    return(yytext[0]);
}

<<EOF>> {
    if (YYSTATE == BLOCK_COMMENT)
        printErrorLine(ERR_BLOCK_COMMENT, num_lines);
    else if (YYSTATE == NESTED_COMMENT)
        printErrorLine(ERR_NESTED_COMMENT, num_lines);

    yy_delete_buffer(YY_CURRENT_BUFFER);
    fclose(yyin);
    yylex_destroy();
    yy_init = 1;
    return EOF;
}

%%
