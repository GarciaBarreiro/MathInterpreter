%{
    #include <stdio.h>
    #include <math.h>
    // include lex.yy.h??????????//////
    #include "lex.yy.h"
    #include "errors.h"
    void yyerror (char const *);
%}

%token NUM
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'

%%

input:
     %empty
     | input line
     ;

line:
    '\n'
    | exp '\n'
    ;

exp:
   NUM
   | exp '+' exp        { $$ = $1 + $3;     }
   | exp '-' exp        { $$ = $1 - $3;     }
   | exp '*' exp        { $$ = $1 * $3;     }
   | exp '/' exp        { $$ = $1 / $3;     }
   | '-' exp %prec NEG  { $$ = -$2;         }
   | exp '^' exp        { $$ = pow($1, $3); }
   | '(' exp ')'        { $$ = $2;          }
   ;

%%

void yyerror (char const *s) {
    printf("s: %s\n", s);
    printErrorLine(ERR_SYNTAX, 0);
}
