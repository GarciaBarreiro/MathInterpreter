%{
    #include <stdlib.h>
    #include "errors.h"
    #include "defs.h"
    #include "syn.tab.h"

    int num_lines = 0;

    // TODO: USE YYLINENO
%}

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

%%

{DEC}  {
    yylval.s.value = strtod(yytext, NULL);
    return(MA_DEC_NUM);
}

{BIN}  {
    return(MA_BIN_NUM);
}

{HEX}  {
    return(MA_HEX_NUM);
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
    return(MA_EQUALS);
}

"!="    {
    return(MA_NOT_EQUALS);
}

"+="    {
    return(MA_PLUS_EQUALS);
}

"++"    {
    return(MA_PLUS_PLUS);
}

"-="    {
    return(MA_MINUS_EQUALS);
}

"--"    {
    return(MA_MINUS_MINUS);
}

">>"    {
    yylval.s.lex = strdup(yytext);
    return(MA_PRINT_R);
}

"<<"    {
    yylval.s.lex = strdup(yytext);
    return(MA_PRINT_L);
}

{ID}    {
    yylval.s.lex = strdup(yytext);
    return(MA_ID);
}

{STRING}    {
    return(MA_STR);
}

\n  {
    num_lines++;
    return(yytext[0]);
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

    //yy_delete_buffer(YY_CURRENT_BUFFER);
    fclose(yyin);

    yyrestart(stdin);

    /* TODO: CALL LATER FROM syn.y*/
    /*yylex_destroy();
    yy_init = 1;*/
    return MA_EOF;
}

%%
