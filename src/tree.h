#ifndef TABLE_H
#define TABLE_H

union ptr { // TODO: change
    void (*func)();
    double value;
};

typedef struct {
    int id;     // ID vs different keywords
    int type;   // is it a function, a variable or a constant?
    char *name;
    // union ptr a;// points to var value / function (TODO)
    union ptr p;
} comp;

// inits tree with keywords
void initTree();

// frees keywords
void freeTree();

// searches node for name
// if it doesn't exist, name is inserted
// returns either a keyword id or D_ID
comp searchNode(char *name);

#endif // TABLE_H
