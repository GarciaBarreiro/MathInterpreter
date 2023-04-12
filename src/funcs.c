#include <stdio.h>
#include <stdlib.h>

#include "funcs.h"

void ma_clear() {
    system("clear");
}

void ma_exit() {
    // TODO: free everything
}

void ma_help() {
    printf("SYSTEM FUNCTIONS\n"
            "   clear()             clears screen\n"
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

void ma_load(char *file) {
    FILE *fp = fopen(file, "r");

    if (!fp) {
        printf("ERROR (TODO)\n");
    }

}

void ma_workspace() {

}
