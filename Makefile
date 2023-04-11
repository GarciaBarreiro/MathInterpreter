CC = gcc -Wall

HEADER_FILES_DIR = ./src/

INCLUDES = -I $(HEADER_FILES_DIR)

OUTPUT = mathA

LIB_HEADERS = lex.yy.h syn.tab.h defs.h errors.h tree.h

SRCS = src/lex.yy.c src/syn.tab.c src/main.c src/errors.c src/tree.c

OBJS = $(SRCS:.c=.o)

LEX = flex

src/lex.yy.%: src/lex.l
	$(LEX) -o src/lex.yy.c --header-file=src/lex.yy.h $^
	$(CC)    -c -o src/lex.yy.o src/lex.yy.c

src/syn.tab.%: src/syn.y
	bison --output=src/syn.tab.c --header=src/syn.tab.h $^ 
	$(CC)   -c -o src/syn.tab.o src/syn.tab.c

$(OUTPUT): $(OBJS)
	$(CC) -o $(OUTPUT) $(OBJS) -lm
	rm src/*.o
	# rm -f src/lex.yy.*
	# rm -f src/syn.tab.*

%.o: %.c $(LIB_HEADERS)
	$(CC) -c -o $@ $< $(INCLUDES)

cleanall: clean
	rm -f $(OUTPUT)

clean:
	rm -f src/*.o *~
	rm -f src/lex.yy.*
	rm -f src/syn.tab.*
