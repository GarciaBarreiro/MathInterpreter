#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#include "defs.h"
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
        printf("CALL ERRORS.H\n");
        printf("%s\n", dlerror());
        free(header);
        return;
    }

    if ((name = strrchr(header, '/')) != NULL) {
        name = name + 1;
        printf("NAME == %s\n", name);
    }   // TODO

    name = strtok(name, ".");
    printf("NAME == %s\n", name);

    free(header);

    comp c = {MA_LIB, name};

    searchNode(&c, 1);

    // basicamente:
    // abrir libraría e gardala na árbore
    // logo, indicar nome da libraría e nome da función
    // e buscar a función na libraría
    // ou non indicar libraría e ir simplemente iterando entre as abertas
    // ata que cheguemos a que contén a función que buscamos
}

void ma_load(char *file) {  // TODO
    FILE *fp;
    char *ext = strrchr(file, '.');

    if (!ext || strcmp(ext, ".ma")) {
        printError(ERR_BAD_EXTENSION);
        return;
    }

    fp = fopen(file, "r");

    if (!fp) {
        printError(ERR_BAD_FILE);
        return;
    }

    free(file);
    yylineno = 0;   // resets line counter
    yyin = fp;
}

void ma_workspace() {
    printWorkspace();
}
