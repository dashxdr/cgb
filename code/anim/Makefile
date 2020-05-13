CC = gcc
CFLAGS = -O2 $(shell sdl-config --cflags)
OBJS=data.o anim.o iff.o pcx.o elmer.o spr.o


anim: anim.o data.o iff.o pcx.o elmer.o spr.o 
	gcc -o anim anim.o data.o iff.o pcx.o elmer.o spr.o -lm $(shell sdl-config --libs)

data.o: data.c data.h elmer.h lfptypes.h
anim.o:	anim.c data.h elmer.h lfptypes.h
iff.o: iff.c iff.h
pcx.o: pcx.c pcx.h
spr.o: spr.c spr.h
elmer.o: elmer.h

lfptypes.h:
elmer.h:
data.h:
iff.h:
pcx.h:
elmer.h:

clean:
	rm -f *.o anim
