CC = gcc -Wall

HEADER_FILES_DIR = ./src/

INCLUDES = -I $(HEADER_FILES_DIR)

OUTPUT = dLexicalAnalyzer

LIB_HEADERS = lex.yy.h defs.h errors.h lexical.h syntactical.h tree.h

SRCS = src/lex.yy.c src/main.c src/errors.c src/lexical.c src/syntactical.c src/tree.c

OBJS = $(SRCS:.c=.o)

LEX = flex

src/lex.yy.%: src/lex.l
	$(LEX) -o src/lex.yy.c --header-file=src/lex.yy.h $^
	$(CC)    -c -o src/lex.yy.o src/lex.yy.c

$(OUTPUT): $(OBJS)
	$(CC) -o $(OUTPUT) $(OBJS)
	rm src/*.o
	rm -f src/lex.yy.*

%.o: %.c $(LIB_HEADERS)
	$(CC) -c -o $@ $< $(INCLUDES)

cleanall: clean
	rm -f $(OUTPUT)

clean:
	rm -f *.o *~
