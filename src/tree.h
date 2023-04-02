#ifndef TABLE_H
#define TABLE_H

union ptr {
    double d_value;
    long l_value;
};

typedef struct {
    int id;
    char *name;
    union ptr a;
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
