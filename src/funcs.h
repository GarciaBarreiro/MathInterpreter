#ifndef FUNCS_H
#define FUNCS_H

double ma_clear();  // clears screen

double ma_clean();  // cleans workspace

double ma_exit();   // exists program

double ma_help();   // prints help

double ma_import(char *header); // opens and saves lib

double ma_load(char *file);     // loads file to input buffer

double ma_workspace();  // prints current defined variables, constants and imported libs

#endif // !FUNCS_H
