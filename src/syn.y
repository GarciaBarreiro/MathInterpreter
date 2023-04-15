%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>

    #include "lex.yy.h"
    #include "errors.h"
    #include "defs.h"
    #include "tree.h"

    void yyerror (char const *);
    void _printPrompt();
%}

%union {
    struct {
        double value;
        char *lex;
    } s;
}

%token <s> NUM 750
%token <s> ID 700
%token <s> FILE_EOF 800
%token <s> PRINT_R 850
%token <s> PRINT_L 851
%token <s> STRING 900

%left '-' '+' '*' '/' '%' ',' '=' PRINT_L
%left NEG
%right '^' '(' PRINT_R

%type <s> exp
%type <s> type
%type <s> func

%%

input:
    %empty              { _printPrompt(); }
    | input line
    | input FILE_EOF    { printf("\r\rFinised parsing file, entering prompt mode\n> ");} /*TODO: AT EOF, CLEAR TREE FROM VARS*/
    ;

line:
    '\n'
    | ID '=' exp '\n'   { comp c; c.name = $<s.lex>1; c.p.value = $<s.value>3;
                          searchNode(&c, 1);
                          _printPrompt(); } /*TODO: MOVE*/
    | exp '\n'          { _printPrompt(); }
    | exp PRINT_R '\n'  { fprintf(stdout, "%lf\n", $<s.value>1);
                          _printPrompt(); }
    | exp PRINT_R STRING '\n'   { FILE *fp = fopen($<s.lex>3, "a");
                                  fprintf(fp, "%lf\n", $<s.value>1);
                                  fclose(fp);   /*COSTLY*/
                                  _printPrompt(); }
    | PRINT_L exp '\n'  { fprintf(stdout, "%lf\n", $<s.value>2);
                          _printPrompt(); }
    | STRING PRINT_L exp '\n'   { FILE *fp = fopen($<s.lex>1, "a");
                                  fprintf(fp, "%lf\n", $<s.value>3);
                                  fclose(fp);
                                  _printPrompt(); }
    ;

exp:
    type
    | exp '+' exp       { $<s.value>$ = $<s.value>1 + $<s.value>3; }
    | exp '-' exp       { $<s.value>$ = $<s.value>1 - $<s.value>3; }
    | exp '*' exp       { $<s.value>$ = $<s.value>1 * $<s.value>3; }
    | exp '/' exp       { $<s.value>$ = $<s.value>1 / $<s.value>3; }
    | exp '^' exp       { $<s.value>$ = pow($<s.value>1, $<s.value>3); }
    | exp '%' exp       { $<s.value>$ = (long) $<s.value>1 % (long) $<s.value>3; }
    | '(' exp ')'       { $<s.value>$ = $<s.value>2; }
    | '-' exp %prec NEG { $<s.value>$ = - $<s.value>2; }   /*???*/
    | func
    ;

func:
    ID '(' ')'          { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND || c.type == MA_FUNC) {
                            printf("aaaaaaaaaaaaa\n");
                            c.p.func();
                          } else {
                            printf("NO FUNCTIONS OF THIS NAME\n");
                            free(c.name);
                          } }
    | ID '(' STRING ')' { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND || c.type == MA_FUNC) {
                              printf("a\n");
                              c.p.func($<s.lex>3);
                          } else {
                              printf("TODO: call errors\n");
                              free(c.name);
                          } }
    | ID '(' exp ')'    { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND || c.type == MA_FUNC) {
                              printf("b\n");
                              c.p.func($<s.value>3);
                          } else {
                              printf("TODO: call errors\n");
                              free(c.name);
                          } }
    | ID '(' exp ',' exp ')'
    ;

type:
    ID                  { comp c; c.name = $<s.lex>1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_ID || c.type == MA_CONST) {
                              $<s.value>$ = c.p.value;
                          } else {
                              printf("TODO: UNDEF VAR\n");
                              free(c.name);
                          } }
    | NUM
    ;

%%

void yyerror (char const *s) {
    printf("s: %s\n", s);
    printErrorLine(ERR_SYNTAX, 0);
    // TODO: continue
}

void _printPrompt() {
    if (yyin == stdin) {
        printf("> ");
    }
}
