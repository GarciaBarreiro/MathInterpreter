#ifndef TABLE_H
#define TABLE_H

typedef struct {
    int type;   // is it a function, a variable, a constant or a lib?
    char *name;
    union {
        double (*func)();   // functions
        void *handle;       // libs
        double value;       // constants and vars
    } p;
} comp;

/*
 * CORE FUNCTIONS
 */

// inits tree with keywords
void initTree();

// frees keywords
void freeTree();

// searches node for name
void searchNode(comp *c, short insert);

/*
 * MATH INTERPRETER-SPECIFIC FUNCTIONS
 */

// prints current initialized variables
void printWorkspace();

// similar to freeTree, probably gonna merge them later
void cleanWorkspace();

#endif // TABLE_H
