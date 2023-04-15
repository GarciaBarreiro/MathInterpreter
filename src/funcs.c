#include <stdio.h>
#include <stdlib.h>

#include "funcs.h"
#include "lex.yy.h"
#include "tree.h"
#include "errors.h"

void ma_clear() {
    system("clear");
}

void ma_clean() {   // TODO: clean workspace (delete vars, imported libs)
    // maybe don't
}

void ma_exit() {
    // TODO: free everything
    freeTree();
    yylex_destroy();
    exit(0);
}

void ma_help() {
    printf("SYSTEM FUNCTIONS\n"
            "   clear()             clears screen\n"
            "   clean()             cleans workspace\n"
            "   exit()              exits program\n"
            "   help()              prints this message\n"
            "   import(header)      imports functions from header\n"
            "   load(file)          loads and executes file\n"
            "   workspace()         prints workspace (currently initialized variables)\n"
            "MATH FUNCTIONS\n"
            "   TODO\n"
            );
}

void ma_import(char *header) {
    printf("holaaaaaaaa %s\n", header);
}

void ma_load(char *file) {  // TODO
    printf("file == %s\n", file);

    FILE *fp = fopen(file, "r");

    if (!fp) {
        printf("ERROR (TODO)\n");
        printError(ERR_BAD_FILE);   // TODO: don't exit
    }

    free(file);

    yyrestart(fp);
}

void ma_workspace() {
    printf("INITIALIZED VARIABLES AND CONSTANTS\n");
    printWorkspace();
}
