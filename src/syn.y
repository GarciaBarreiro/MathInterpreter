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
    double value;
    char* lex;
}

%token <value> NUM 750  /* TODO: change this to MA_DEC_NUM */
%token <lex> ID 700
%token <value> FILE_EOF 800
// %token <value> NUM MA_DEC_NUM
%left '-' '+'
%left '*' '/'
%left '%' ','   // TODO: check if left or right
%right '^' '='

%type <value> exp
%type <lex> keyw

%%

input:
    { _printPrompt(); }
    | input line
    | input FILE_EOF    {printf("\r\rFinised parsing file, entering prompt mode\n> ");} /*TODO: AT EOF, CLEAR TREE FROM VARS*/
    ;

line:
    '\n'
    | exp '\n'          { printf("%lf\n", $1);
                          _printPrompt();   }
    | keyw '\n'         { _printPrompt();   }
    ;

exp:
    NUM                  /* when a rule has no action, bison does $$ = $1 */
    | ID                { comp c; c.name = $1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_ID || c.type == MA_CONST) {
                              $$ = c.p.value;
                          } else {
                              printf("undefined var\n");
                          }}
    | exp '+' exp       { $$ = $1 + $3; }
    | exp '-' exp       { $$ = $1 - $3; }
    | exp '*' exp       { $$ = $1 * $3; }
    | exp '/' exp       { $$ = $1 / $3; }
    | '-' exp           { $$ = -$2; }   /*???*/
    | exp '^' exp       { $$ = pow($1, $3); }
    | exp '%' exp       { $$ = (long) $1 % (long) $3; }
    | '(' exp ')'       { $$ = $2; }
    ;

keyw:
    ID                  { $$ = $1; printf("keyw %s\n", $$);/*TODO: BUSCAR TABOA*/ }
    | keyw '(' param ')'{ $$ = $1;          }
    | keyw '(' ')'      { comp c;
                          c.name = $1;
                          searchNode(&c, 0);  /*TODO: BORRAR SE NON EXISTE E MOSTRAR ERRO*/
                          if (c.type == MA_COMMAND || c.type == MA_FUNC) {
                            printf("aaaaaaaaaaaaa\n");
                            c.p.func();
                          } else {
                            printf("NO FUNCTIONS OF THIS NAME\n");
                          }}/* TODO: exit() and such */
    | keyw '=' exp      { comp c;
                          c.name = $1;
                          c.p.value = $3;
                          searchNode(&c, 1);}
    ;

param:
     exp
     | keyw
     | param ',' param  /* ???? */
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
