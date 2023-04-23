%{
    #include <stdlib.h>
    #include "errors.h"
    #include "defs.h"
    #include "syn.tab.h"

    double _bintod(char *str);
    double _hextod(char *str);
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
    return(MA_NUM);
}

{BIN}  {
    yylval.s.value = _bintod(yytext + 2);
    return(MA_NUM);
}

{HEX}  {
    yylval.s.value = _hextod(yytext + 2);
    return(MA_NUM);
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
}

"+="    {
    return(MA_PLUS_EQUALS);
}

"-="    {
    return(MA_MINUS_EQUALS);
}

">>"    {
    return(MA_PRINT_R);
}

"<<"    {
    return(MA_PRINT_L);
}

{ID}    {
    yylval.s.lex = strdup(yytext);
    return(MA_ID);
}

{STRING}    {
    /* removes quotes */
    yylval.s.lex = strndup(&yytext[1], strlen(yytext) - 2);
    return(MA_STR);
}

\n  {
    return(yytext[0]);
}

{SPACE}   ;

.   {
    return(yytext[0]);
}

<<EOF>> {
    if (YYSTATE == BLOCK_COMMENT)
        printErrorLine(ERR_BLOCK_COMMENT, yylineno);
    else if (YYSTATE == NESTED_COMMENT)
        printErrorLine(ERR_NESTED_COMMENT, yylineno);

    //yy_delete_buffer(YY_CURRENT_BUFFER);
    fclose(yyin);

    yyrestart(stdin);

    /*yylex_destroy();
    yy_init = 1;*/
    yylineno = 0;
    return MA_EOF;
}

%%

double _bintod(char *str) {
    double val = 0;
    unsigned int pow = 1;
    
    for (short i = strlen(str); i > 0; i--) {
        if (str[i-1] != '_') {
            val += pow * (str[i-1] - 48);   // '0' == 48
            pow *= 2;
        }
    }

    return val;
}

double _hextod(char *str) {
    double val = 0;
    unsigned int pow = 1;
    char c;

    for (short i = strlen(str); i > 0; i--) {
        c = str[i-1];
        if (c >= '0' && c <= '9')
            val += pow * (c - 48);
        else if (c >= 'A' && c <= 'F')
            val += pow * (c - 55);      // 'A' == 65
        else if (c >= 'a' && c <= 'f')
            val += pow * (c - 87);      // 'A' == 97
        if (c != '_') pow *= 16;
    }

    return val;
}
