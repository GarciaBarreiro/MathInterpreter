%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <dlfcn.h>

    #include "lex.yy.h"
    #include "errors.h"
    #include "defs.h"
    #include "tree.h"

    void yyerror (char const *);
    void _printPrompt();
    void _printError(int err);
%}

%union {
    struct {
        double value;
        char *lex;
    } s;
}

/*
 * AFAIK bison doesn't let you use constants here
 * so i can't do %token <s> PLUS_EQUALS MA_PLUS_EQUALS
 */

%token <s> PLUS_EQUALS 650
%token <s> MINUS_EQUALS 651

%token <s> ID 700

%token <s> NUM 750
%token <s> STRING 751

%token <s> FILE_EOF 800

%token <s> PRINT_R 850
%token <s> PRINT_L 851

%precedence '='
%left '-' '+'
%left '*' '/'
%left '%' PRINT_L
%precedence NEG
%right '^' PRINT_R

%type <s> exp
%type <s> type
%type <s> func

%%

input:
    %empty              { _printPrompt(); }
    | input line        { _printPrompt(); }
    | input FILE_EOF    { printf("\r\rFinished parsing file, entering prompt mode\n> "); }
    ;

line:
    '\n'
    | assign '\n'       { }
    | exp '\n'          { }
    | exp PRINT_R '\n'  { fprintf(stdout, "%lf\n", $<s.value>1); }
    | exp PRINT_R STRING '\n'   { FILE *fp = fopen($<s.lex>3, "a");
                                  fprintf(fp, "%lf\n", $<s.value>1);
                                  fclose(fp);   /*COSTLY*/ }
    | PRINT_L exp '\n'  { fprintf(stdout, "%lf\n", $<s.value>2); }
    | STRING PRINT_L exp '\n'   { FILE *fp = fopen($<s.lex>1, "a");
                                  fprintf(fp, "%lf\n", $<s.value>3);
                                  fclose(fp); }
    ;

exp:
    type
    | exp '+' exp       { $<s.value>$ = $<s.value>1 + $<s.value>3; }
    | exp '-' exp       { $<s.value>$ = $<s.value>1 - $<s.value>3; }
    | exp '*' exp       { $<s.value>$ = $<s.value>1 * $<s.value>3; }
    | exp '/' exp       { if ($<s.value>3) $<s.value>$ = $<s.value>1 / $<s.value>3;
                          else _printError(ERR_DIV_0); }
    | '-' exp %prec NEG { $<s.value>$ = - $<s.value>2; }
    | '+' exp %prec NEG { $<s.value>$ = $<s.value>2; }
    | exp '^' exp       { $<s.value>$ = pow($<s.value>1, $<s.value>3); }
    | exp '%' exp       { $<s.value>$ = (long) $<s.value>1 % (long) $<s.value>3; }
    | '(' exp ')'       { $<s.value>$ = $<s.value>2; }
    | func              { $<s.value>$ = $<s.value>1; }
    ;

func:
    ID '(' ')'          { comp c; c.name = $<s.lex>1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND) {
                              c.p.func();
                          } else {
                              _printError(ERR_NO_FUNC);
                              free(c.name);
                          } }
    | ID '(' STRING ')' { comp c; c.name = $<s.lex>1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND) {
                              c.p.func($<s.lex>3);
                          } else {
                              _printError(ERR_NO_FUNC);
                              free(c.name);
                          } }
    | ID '.' ID '(' ')' { comp c; c.name = $<s.lex>1; c.type = 0;   // a lot of repeated code everywhere
                          searchNode(&c, 0);
                          if (c.type == MA_LIB) {
                              double (*func)() = dlsym(c.p.handle, $<s.lex>3);
                              if (func) {
                                  $<s.value>$ = func();
                                  free($<s.lex>3);
                              } else {
                                  _printError(ERR_NO_FUNC);
                              }
                          } else {
                              _printError(ERR_NO_LIB);
                          } }
    | ID '.' ID '(' exp ')' { comp c; c.name = $<s.lex>1; c.type = 0;
                              searchNode(&c, 0);
                              if (c.type == MA_LIB) {
                                  double (*func)() = dlsym(c.p.handle, $<s.lex>3);
                                  if (func) {
                                      $<s.value>$ = func($<s.value>5);
                                      free($<s.lex>3);
                                  } else {
                                      _printError(ERR_NO_FUNC);
                                  }
                              } else {
                                  _printError(ERR_NO_LIB);
                              } }
    | ID '.' ID '(' exp ',' exp ')' { comp c; c.name = $<s.lex>1; c.type = 0;
                                      searchNode(&c, 0);
                                      if (c.type == MA_LIB) {
                                          double (*func)() = dlsym(c.p.handle, $<s.lex>3);
                                          if (func) {
                                              $<s.value>$ = func($<s.value>5, $<s.value>7);
                                              free($<s.lex>3);
                                          } else {
                                              _printError(ERR_NO_FUNC);
                                          }
                                      } else {
                                          _printError(ERR_NO_LIB);
                                      } }
    ;

type:
    ID                  { comp c; c.name = $<s.lex>1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_ID || c.type == MA_CONST) {
                              $<s.value>$ = c.p.value;
                          } else {
                              _printError(ERR_NO_VAR);
                              if (c.type != MA_LIB && c.type != MA_COMMAND) free(c.name);
                          } }
    | NUM
    ;

assign:
    ID '=' exp              { comp c; c.name = $<s.lex>1; c.p.value = $<s.value>3; c.type = 0;
                              searchNode(&c, 1);
                              if (c.type == MA_CONST) {
                                  _printError(ERR_ASSIGN_CONST);
                              } }
    | ID PLUS_EQUALS exp    { comp c; c.name = $<s.lex>1; c.type = 0;
                              searchNode(&c, 0);
                              if (c.type == MA_CONST) {
                                  _printError(ERR_ASSIGN_CONST);
                              } else {
                                  c.p.value += $<s.value>3;
                                  c.name = strdup(c.name);  // else it frees needed arrays
                                  searchNode(&c, 1);
                              } }
    | ID MINUS_EQUALS exp   { comp c; c.name = $<s.lex>1; c.type = 0;
                              searchNode(&c, 0);
                              if (c.type == MA_CONST) {
                                  _printError(ERR_ASSIGN_CONST);
                              } else {
                                  c.p.value -= $<s.value>3;
                                  c.name = strdup(c.name);
                                  searchNode(&c, 1);
                              } }
    ;

%%

void yyerror (char const *s) {
    if (yyin == stdin) printError(ERR_SYNTAX);
    else printErrorLine(ERR_SYNTAX, yylineno-1);
}

void _printPrompt() {
    if (yyin == stdin) {
        printf("> ");
    }
}

void _printError(int err) {
    if (yyin == stdin) printError(err);
    else printErrorLine(err, yylineno-1);
}
