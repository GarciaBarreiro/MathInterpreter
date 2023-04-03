#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tree.h"
#include "defs.h"

// this is not an optimal implementation of a table

struct node {
    comp el;
    struct node *greater, *lesser;
};

struct node *T;

// even though all keywords are defined, not all of them exist in regression.d
comp kws[] = { { M_STR, "import" }, { M_STR, "double" }, { M_STR, "int" },
        { M_STR, "while" }, { M_STR, "foreach" }, { M_STR, "return" }, { M_STR, "void" }};

/*void _printTree(struct node *t) {
    printf("%d, %s\n", t->el.id, t->el.name);
    if (t->lesser) _printTree(t->lesser);
    if (t->greater) _printTree(t->greater);
    
}*/

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
    if (tr->el.id == M_ID) free(tr->el.name);
    free(tr);
    tr = NULL;
}

comp _insertNode(struct node **tr, comp c) {
    if (!c.id) c.id = M_ID;
    *tr = (struct node*) malloc(sizeof(struct node));
    (*tr)->el = c;
    (*tr)->lesser = NULL;
    (*tr)->greater = NULL;
    return c;
}

// if not found, inserted
comp _searchNode(struct node *tr, comp c) {
    int cmp = strcmp(c.name, tr->el.name);

    if (!cmp) {
        free(c.name);
        c = tr->el;
    } else if (cmp < 0) {
        if (tr->lesser) c = _searchNode(tr->lesser, c);
        else c = _insertNode(&tr->lesser, c);
    } else {
        if (tr->greater) c = _searchNode(tr->greater, c);
        else c = _insertNode(&tr->greater, c);
    }

    return c;
}

// tree root is first keyword
void initTree() {
    T = (struct node*) malloc(sizeof(struct node));
    T->el = kws[0];
    T->lesser = NULL;
    T->greater = NULL;

    size_t total_kws = sizeof(kws) / sizeof(kws[0]);

    for (int i = 1; i < total_kws; i++)
        _searchNode(T, kws[i]);
}

void freeTree() {
    if (T != NULL)
        _freeTree(T);
}

comp searchNode(char *name) {
    comp c;
    c.id = M_ID;
    c.name = name;

    int cmp = strcmp(c.name, T->el.name);

    if (!cmp) {
        free(c.name);
        c = T->el;
    } else if (cmp < 0) {
        if (T->lesser) c = _searchNode(T->lesser, c);
        else c = _insertNode(&T->lesser, c);
    } else {
        if (T->greater) c = _searchNode(T->greater, c);
        else c = _insertNode(&T->greater, c);
    }

    return c;
}
