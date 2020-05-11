CC	= gcc
CFLAGS	= -O2 $(shell sdl-config --cflags) -Wall
#-I/usr/local/include/SDL -D_REENTRANT -fomit-frame-pointer \
#		-funroll-all-loops -fexpensive-optimizations
OBJS	= mgb.o cpu.o cpudaa.o gfx.o sound.o dis.o font.o debug.o expr.o

mgb:	$(OBJS)
	gcc -o mgb $(OBJS) $(shell sdl-config --libs)

gfx.o:	gfx.c mgb.h

cpu.o:	cpu.c mgb.h debug.h

cpudaa.o:  cpudaa.c

mgb.o:	mgb.c mgb.h

sound.o: sound.c mgb.h

dis.o:	dis.c mgb.h debug.h

font.o:	font.c mgb.h

debug.o: debug.c mgb.h expr.h debug.h

expr.o: expr.c expr.h

mgb.h:

clean:
	rm -f *.o mgb

test: mgb
	./mgb ../leftfield/gbroms/merm.gb
