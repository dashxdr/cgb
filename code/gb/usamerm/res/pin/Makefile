CC	= gcc
CFLAGS:= -O2 $(shell sdl-config --cflags)

EXE=conv pinmap
all: $(EXE)
	./resall

conv: conv.o gfx.o font.o
	gcc -o $@ $^ $(shell sdl-config --libs) -lm

pinmap: pinmap.c
	gcc -o $@ $^ -lm
conv.o: conv.c gfx.h font.h
gfx.o:	gfx.c gfx.h
font.o:	font.c font.h

clean:
	rm -f *.o $(EXE)
	rm -f *.map *.chr *.rgb *.equ *.trg
	rm -f *.dm? *.ch? *.pn?
	rm -f *.pmp *.chg
	rm -rf swd
