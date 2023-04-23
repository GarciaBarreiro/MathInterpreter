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
%}

%union {
    struct {
        double value;
        char *lex;
    } s;
}

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
    | input line
    | input FILE_EOF    { printf("\r\rFinished parsing file, entering prompt mode\n> ");} /*TODO: AT EOF, CLEAR TREE FROM VARS*/
    ;

line:
    '\n'
    | assign '\n'       { _printPrompt(); }
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
    | '-' exp %prec NEG { $<s.value>$ = - $<s.value>2; }   /*???*/
    | '+' exp %prec NEG { $<s.value>$ = $<s.value>2; }
    | exp '^' exp       { $<s.value>$ = pow($<s.value>1, $<s.value>3); }
    | exp '%' exp       { $<s.value>$ = (long) $<s.value>1 % (long) $<s.value>3; }
    | '(' exp ')'       { $<s.value>$ = $<s.value>2; }
    | func              { $<s.value>$ = $<s.value>1; }
    ;

func:
    ID '(' ')'          { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND) {
                              c.p.func();
                          } else {
                              if (yyin == stdin) printError(ERR_NO_FUNC);
                              else printErrorLine(ERR_NO_FUNC, yylineno-1);
                              free(c.name);
                          } }
    | ID '(' STRING ')' { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND) {
                              c.p.func($<s.lex>3);
                          } else {
                              if (yyin == stdin) printError(ERR_NO_FUNC);
                              else printErrorLine(ERR_NO_FUNC, yylineno-1);
                              free(c.name);
                          } }
    | ID '(' exp ')'    { comp c; c.name = $<s.lex>1;
                          searchNode(&c, 0);
                          if (c.type == MA_COMMAND) {
                              printf("b\n");
                              $<s.value>$ = c.p.func($<s.value>3);
                          } else {
                              if (yyin == stdin) printError(ERR_NO_FUNC);
                              else printErrorLine(ERR_NO_FUNC, yylineno-1);
                              free(c.name);
                          } }
    | ID '.' ID '(' exp ')' { comp c; c.name = $<s.lex>1;
                              searchNode(&c, 0);
                              if (c.type == MA_LIB) {
                                  printf("lib!!\n");
                                  double (*func)() = dlsym(c.p.handle, $<s.lex>3);
                                  if (func) {
                                      printf("func!!\n");
                                      $<s.value>$ = func($<s.value>5);
                                      free($<s.lex>3);
                                  } else {
                                      printf("not func :(\n");
                                  }
                              } else {
                                  printf("error\n");
                              } }
    | ID '.' ID '(' exp ',' exp ')' { comp c; c.name = $<s.lex>1;
                                      searchNode(&c, 0);
                                      if (c.type == MA_LIB) {
                                          printf("lib!!\n");
                                          double (*func)() = dlsym(c.p.handle, $<s.lex>3);
                                          if (func) {
                                              printf("func!!\n");
                                              $<s.value>$ = func($<s.value>5, $<s.value>7);
                                              free($<s.lex>3);
                                          } else {
                                              printf("not func :(\n");
                                          }
                                      } else {
                                          printf("error\n");
                                      } }
    ;

type:
    ID                  { comp c; c.name = $<s.lex>1; c.type = 0;
                          searchNode(&c, 0);
                          if (c.type == MA_ID || c.type == MA_CONST) {
                              $<s.value>$ = c.p.value;
                          } else {
                              if (yyin == stdin) printError(ERR_NO_VAR);
                              else printErrorLine(ERR_NO_VAR, yylineno-1);
                              if (c.type != MA_LIB && c.type != MA_COMMAND) free(c.name);
                          } }
    | NUM
    ;

assign:
    ID '=' exp              { comp c; c.name = $<s.lex>1; c.p.value = $<s.value>3;
                              searchNode(&c, 1);
                              if (c.type == MA_CONST) {
                                  if (yyin == stdin) printError(ERR_ASSIGN_CONST);
                                  else printErrorLine(ERR_ASSIGN_CONST, yylineno-1);
                              } }
    | ID PLUS_EQUALS exp    { comp c; c.name = $<s.lex>1;
                              searchNode(&c, 0);
                              if (c.type == MA_CONST) {
                                  if (yyin == stdin) printError(ERR_ASSIGN_CONST);
                                  else printErrorLine(ERR_ASSIGN_CONST, yylineno-1);
                              } else {
                                  c.p.value += $<s.value>3;
                                  c.name = strdup(c.name);  // else it frees needed arrays
                                  searchNode(&c, 1);
                              } }
    | ID MINUS_EQUALS exp   { comp c; c.name = $<s.lex>1;
                              searchNode(&c, 0);
                              if (c.type == MA_CONST) {
                                  if (yyin == stdin) printError(ERR_ASSIGN_CONST);
                                  else printErrorLine(ERR_ASSIGN_CONST, yylineno-1);
                              } else {
                                  c.p.value -= $<s.value>3;
                                  c.name = strdup(c.name);
                                  searchNode(&c, 1);
                              } }
    ;

%%

void yyerror (char const *s) {
    printf("s: %s\n", s);
    if (yyin == stdin) printError(ERR_SYNTAX);
    else printErrorLine(ERR_SYNTAX, yylineno-1);
    // TODO: continue
}

void _printPrompt() {
    if (yyin == stdin) {
        printf("> ");
    }
}
