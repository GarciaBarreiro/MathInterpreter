#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#include "defs.h"
#include "funcs.h"
#include "lex.yy.h"
#include "tree.h"
#include "errors.h"

double ma_clear() {
    system("clear");
    return 0;
}

double ma_clean() {
    cleanWorkspace();
    return 0;
}

double ma_exit() {
    freeTree();
    yylex_destroy();
    exit(0);
}

double ma_help() {
    printf("SYSTEM FUNCTIONS\n"
            "   clear()             clears screen\n"
            "   clean()             cleans workspace\n"
            "   exit()              exits program\n"
            "   help()              prints this message\n"
            "   import(header)      imports functions from header\n"
            "   load(file)          loads and executes file\n"
            "   workspace()         prints workspace (currently initialized variables)\n"
            "MATH FUNCTIONS\n"
            "   none :)\n"
            "   import `libm` for them\n"
            "   example:            import(\"libm.so.6\")\n"
            "   and then call them using `libm.[function]([param])`\n"
            "   example:            libm.sqrt(4)\n"
            );
    return 0;
}

double ma_import(char *header) {      // either full path or relative
    char *name;
    comp c;
    void *handle = dlopen(header, RTLD_LAZY);

    if (!handle) {
        if (yyin == stdin) printError(ERR_NO_LIB);
        else printErrorLine(ERR_NO_LIB, yylineno-1);
        free(header);
        return 1;
    }

    if ((name = strrchr(header, '/')) != NULL) {
        name = name + 1;    // name pointed to last '/' 
    } else name = header;

    name = strdup(strtok(name, "."));   // first string before '.'

    printf("Imported library as %s\n", name);

    free(header);

    c.type = MA_LIB; c.name = name; c.p.handle = handle;

    searchNode(&c, 1);

    return 0;
}

double ma_load(char *file) {
    FILE *fp;
    char *ext = strrchr(file, '.');

    if (!ext || strcmp(ext, ".mi")) {
        if (yyin == stdin) printError(ERR_BAD_EXTENSION);
        else printErrorLine(ERR_BAD_EXTENSION, yylineno-1);
        return 1;
    }

    fp = fopen(file, "r");

    if (!fp) {
        printError(ERR_BAD_FILE);
        return 1;
    }

    free(file);
    yylineno = 0;   // resets line counter

    // changing buffer this way is incorrect
    // functions described at chapter 11 (Multiple Input Buffers) on the flex manual should be used
    // however, bison returns syntax errors
    // and parses incorrectly
    yyin = fp;
    return 0;
}

double ma_workspace() {
    printWorkspace();
    return 0;
}
