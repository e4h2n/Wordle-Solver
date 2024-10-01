CC = clang
CFLAGS = -Wall -Wpedantic -Werror -Wextra


all: solver

solver: search_util.o solver.o
	$(CC) search_util.o solver.o -o solver

demo_functions: search_util.o demo_functions.o
	$(CC) search_util.o demo_functions.o -o demo_functions

search_util.o: search_util.c search_util.h
	$(CC) $(CFLAGS) -c search_util.c

solver.o: solver.c search_util.h
	$(CC) $(CFLAGS) -c solver.c

clean:
	rm -f search_util.o solver.o solver 

format:
	clang-format -i -style=file *.[ch]
