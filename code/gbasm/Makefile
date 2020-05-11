CC=gcc
CFLAGS=-O2
EXE=gbasm gblink

all: $(EXE)

gbasm:	asm.o z80.o
	gcc -o gbasm asm.o z80.o

asm.o:	asm.c asm.h link.h

z80.o:	z80.c asm.h link.h

clean:
	rm -f *.o $(EXE)
