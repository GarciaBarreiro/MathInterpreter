#ifndef TABLE_H
#define TABLE_H

union ptr { // TODO: change
    void (*func)();
    double value;
};

typedef struct {
    int type;   // is it a function, a variable or a constant?
    char *name;
    union ptr p;
} comp;

// inits tree with keywords
void initTree();

// frees keywords
void freeTree();

// searches node for name
void searchNode(comp *c, short insert);

// prints current initialized variables
void printWorkspace();

// similar to freeTree, probably gonna merge them later
void cleanWorkspace();

#endif // TABLE_H
