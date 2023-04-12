#include <stdio.h>
#include <stdlib.h>

#include "funcs.h"
#include "tree.h"

void ma_clear() {
    system("clear");
}

void ma_clean() {   // TODO: clean workspace (delete vars, imported libs)

}

void ma_exit() {
    // TODO: free everything
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

}

void ma_load(char *file) {  // TODO
    FILE *fp = fopen(file, "r");

    if (!fp) {
        printf("ERROR (TODO)\n");
    }

}

void ma_workspace() {
    printf("INITIALIZED VARIABLES AND CONSTANTS\n");
    printWorkspace();
}
