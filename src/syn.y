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
%right '^'

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
    | exp '+' exp       { $$ = $1 + $3;     }
    | exp '-' exp       { $$ = $1 - $3;     }
    | exp '*' exp       { $$ = $1 * $3;     }
    | exp '/' exp       { $$ = $1 / $3;     }
    | '-' exp           { $$ = -$2;         }   /*???*/
    | exp '^' exp       { $$ = pow($1, $3); }
    | exp '*' '*' exp   { $$ = pow($1, $4); }
    | '(' exp ')'       { $$ = $2;          }
    ;

keyw:
    ID                  { $$ = $1; printf("keyw %s\n", $$);/*TODO: BUSCAR TABOA*/ }
    | keyw '(' param ')'{ $$ = $1;          }
    | keyw '(' ')'      /* TODO: exit() and such */
    ;

param:
     exp
     | keyw
     | param ',' param
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
