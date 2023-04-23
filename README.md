# MATH INTERPRETER

Compiled and executed under Linux Mint 21.1, *flex* version 2.6.4, *bison* version 3.8.2 and *gcc* version 11.3.0 for Ubuntu 22.04.

To compile, execute `make`. Once done, execute `./mathI` (or `./mathI -h` to see help).

## OPERATIONS

This interpreter supports these operations:

- Sum (1 + 1)
- Subtraction (1 - 1)
- Multplication (1 * 1)
- Division (1 / 1)
- Mod (1 % 1)
- Power (1 ^ 1)
- Negation (-1)
- Apart from accepting complex operations using parentheses

It also accepts assignations:

- a = 1
- a += 1
- a -= 1

The last two only with a previously declared variable.

## FUNCTIONS

For a list of functions and what each one does, call `help()` inside the program.

## ACCEPTED TYPES 

The interpreter accepts two types of values, numbers and strings. The latter only used when passing as an argument for `load()` and `import()`, and also printing to a file.

Numbers can be expressed in binary (using `0b` or `0B`), hexadecimal (`0x` or `0X`_ ) and decimal.

All numbers except decimals support being divided for better readability using `_`. For example. `0b1000_1000` is accepted, while `8_000` isn't.

Decimal numbers also support scientific notation (`1.0e+1`).

## PRINT

By default, expression values aren't printed. To view the, use `<<` or `>>`, at the start and end of it, respectively. Moreover, it's possible to indicate an output file, using `FILE <<` and `>> FILE`, as it defaults to `stdin`.

## EXAMPLES

There are a series of files on the `test` folder, with various different examples. The file extension used for them is `.mi`.
