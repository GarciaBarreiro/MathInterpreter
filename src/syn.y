%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include "lex.yy.h"
    #include "errors.h"
    #include "defs.h"
    void yyerror (char const *);
%}

%union {
    double value;
    char *lex;
}

%token <value> NUM 750  /* TODO: change this to MA_DEC_NUM */
// %token <value> NUM
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'

%type <value> exp

%%

input:
     { printf("> "); }
     | input line
     ;

line:
    '\n'
    | exp '\n' { printf("%lf\n> ", $1); }
    ;

exp:
   NUM                  /* when a rule has no action, bison does $$ = $1 */
   | exp '+' exp        { $$ = $1 + $3;     }
   | exp '-' exp        { $$ = $1 - $3;     }
   | exp '*' exp        { $$ = $1 * $3;     }
   | exp '/' exp        { $$ = $1 / $3;     }
   | '-' exp %prec NEG  { $$ = -$2;         }   /*???*/
   | exp '^' exp        { $$ = pow($1, $3); }
   | exp '*' '*' exp    { $$ = pow($1, $4); }
   | '(' exp ')'        { $$ = $2;          }
   ;

%%

void yyerror (char const *s) {
    printf("s: %s\n", s);
    printErrorLine(ERR_SYNTAX, 0);
    // TODO: continue
}
