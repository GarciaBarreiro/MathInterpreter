#ifndef DEFS_H
#define DEFS_H

// keywords
#define MA_CLEAN 600        // clean workspace
#define MA_EXIT 601         // exit program
#define MA_HELP 602         // print help
#define MA_IMPORT 603       // import header
#define MA_LET 604          // define variable
#define MA_LOAD 605         // load file
#define MA_WORKSPACE 606    // print workspace

// operators    (maybe needed??)
#define MA_EQUALS 650       // ==
#define MA_NOT_EQUALS 651   // !=
#define MA_PLUS_EQUALS 652  // +=
#define MA_PLUS_PLUS 653    // ++
#define MA_MINUS_EQUALS 654 // -=
#define MA_MINUS_MINUS 655  // --

// ids (vars, function names...)
#define MA_ID 700           // variables
#define MA_FUNC 701         // functions
#define MA_CONST 702        // constants (PI, E)

// num types
#define MA_DEC_NUM 750
#define MA_BIN_NUM 751
#define MA_HEX_NUM 752

#define MA_EOF 800

// strings
#define MA_STR 850

#define MA_PI 3.14159
#define MA_E  2.71828

#endif // DEFS_H
