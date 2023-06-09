#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tree.h"
#include "defs.h"
#include "funcs.h"

// this is not an optimal implementation of a table

struct node {
    comp el;
    struct node *greater, *lesser;
};

struct node *T;

comp kws[] = { {MA_COMMAND, "import", {&ma_import}},
               {MA_COMMAND, "exit", {&ma_exit}},
               {MA_COMMAND, "load", {&ma_load}},
               {MA_COMMAND, "clear", {&ma_clear}}, 
               {MA_COMMAND, "help", {&ma_help}}, 
               {MA_COMMAND, "workspace", {&ma_workspace}},
               {MA_COMMAND, "clean", {&ma_clean}},
               {MA_CONST, "PI", {.value = MA_PI}},
               {MA_CONST, "E", {.value = MA_E}}
             };

void _printTree(struct node *t) {
    if (t->lesser) _printTree(t->lesser);
    printf("%d, %s\n", t->el.type, t->el.name);
    if (t->greater) _printTree(t->greater);
    
}

/*
 * CORE FUNCTIONS
 */

struct node _createNode(comp kw) {
    struct node n;
    n.el = kw;
    n.greater = NULL;
    n.lesser = NULL;
    return n;
}

// recursively frees tree
void _freeTree(struct node *tr) {
    if (tr->lesser)
        _freeTree(tr->lesser);
    if (tr->greater)
        _freeTree(tr->greater);
    if (tr->el.type == MA_ID || tr->el.type == MA_LIB) free(tr->el.name);    /* TODO: or imported func */
    if (tr->el.type == MA_LIB) dlclose(tr->el.p.handle);
    free(tr);
    tr = NULL;
}

void _insertNode(struct node **tr, comp *c) {
    if (!c->type) c->type = MA_ID;
    *tr = (struct node*) malloc(sizeof(struct node));
    (*tr)->el = *c;
    (*tr)->lesser = NULL;
    (*tr)->greater = NULL;
}

// if not found, insert
void _searchNode(struct node *tr, comp *c, short insert) {
    int cmp = strcmp(c->name, tr->el.name);

    if (!cmp) {
        free(c->name);
        if (tr->el.type == MA_ID && insert) tr->el.p = c->p;
        *c = tr->el;
    } else if (cmp < 0) {
        if (tr->lesser) _searchNode(tr->lesser, c, insert);
        else if (insert) _insertNode(&tr->lesser, c);
    } else {
        if (tr->greater) _searchNode(tr->greater, c, insert);
        else if (insert) _insertNode(&tr->greater, c);
    }
}

// tree root is first keyword
void initTree() {
    T = (struct node*) malloc(sizeof(struct node));
    T->el = kws[0];
    T->lesser = NULL;
    T->greater = NULL;

    size_t total_kws = sizeof(kws) / sizeof(kws[0]);

    for (int i = 1; i < total_kws; i++) {
        _searchNode(T, &kws[i], 1);
    }
}

void freeTree() {
    if (T != NULL)
        _freeTree(T);
}

void searchNode(comp *c, short insert) {
    int cmp = strcmp(c->name, T->el.name);
    if (c->type < MA_LIB || c->type > MA_LIB)
        c->type = 0;

    if (!cmp) {
        free(c->name);
        if (T->el.type == MA_ID && insert) T->el.p = c->p;
        *c = T->el;
    } else if (cmp < 0) {
        if (T->lesser) _searchNode(T->lesser, c, insert);
    } else {
        if (T->greater) _searchNode(T->greater, c, insert);
    }
}

/*
 * MATH INTERPRETER-SPECIFIC FUNCTIONS
 */

void _printWorkspace(struct node *t, int type, short *found) {
    if (t->lesser) _printWorkspace(t->lesser, type, found);

    if (t->el.type == type && (type != MA_LIB && type != MA_COMMAND)) {
        if (!(*found)) {
            *found = 1;
            if (type == MA_CONST) printf("CONSTANTS:\n");
            else printf("DECLARED VARIABLES:\n");
        }
        printf("    %-12s == %.6lf\n", t->el.name, t->el.p.value);
    }

    if (t->el.type == type && type == MA_LIB) {
        if (!(*found)) {
            *found = 1;
            printf("IMPORTED LIBS:\n");
        }
        printf("    %s\n", t->el.name);
    }
    
    if (t->greater) _printWorkspace(t->greater, type, found);
}

void printWorkspace() {
    short found = 0;
    _printWorkspace(T, MA_LIB, &found);
    found = 0;
    _printWorkspace(T, MA_ID, &found);
    found = 0;
    _printWorkspace(T, MA_CONST, &found);
}

short _cleanWorkspace(struct node *tr) {
    if (tr->lesser)
        if (_cleanWorkspace(tr->lesser)) tr->lesser = NULL;
    if (tr->greater)
        if (_cleanWorkspace(tr->greater)) tr->greater = NULL;
    if (tr->el.type == MA_ID || tr->el.type == MA_LIB) {
        free(tr->el.name);
        if (tr->el.type == MA_LIB) dlclose(tr->el.p.handle);
        free(tr);
        tr = NULL;
        return 1;
    }
    return 0;
}

void cleanWorkspace() {
    _cleanWorkspace(T);
}
