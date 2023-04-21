#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#include "funcs.h"
#include "lex.yy.h"
#include "tree.h"
#include "errors.h"

void ma_clear() {
    system("clear");
}

void ma_clean() {
    cleanWorkspace();
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

void ma_import(char *header) {      // either full path or relative
    printf("holaaaaaaaa %s\n", header);
    char *name;
    void *handle = dlopen(header, RTLD_LAZY);

    if (!handle) {
        printf("TODO: HEADER NOT FOUND\n");
        return;
    }

    if ((name = strrchr(header, '/')) != NULL) {
        name = name + 1;
        printf("NAME == %s\n", name);
    }   // TODO

}

void ma_load(char *file) {  // TODO
    char *ext = strrchr(file, '.');
    if (!ext || strcmp(ext, ".ma")) {
        printError(ERR_BAD_EXTENSION);
        return;
    }
    FILE *fp = fopen(file, "r");

    if (!fp) {
        printf("ERROR (TODO)\n");
        printError(ERR_BAD_FILE);   // TODO: don't exit
    }

    free(file);
    yyin = fp;
}

void ma_workspace() {
    printWorkspace();
}
