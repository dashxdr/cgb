
CC=gcc
CFLAGS=-DPC -Wall
OBJS=data.o animrgb.o iff.o pcx.o elmer.o spr.o

all: animrgb

animrgb: animrgb.o data.o iff.o pcx.o elmer.o spr.o
	gcc -o $@ $^

data.o: data.c data.h elmer.h lfptypes.h
animrgb.o:	animrgb.c data.h elmer.h lfptypes.h
iff.o: iff.c iff.h
pcx.o: pcx.c pcx.h
elmer.o: elmer.c elmer.h
spr.o: spr.c spr.h

lfptypes.h:
elmer.h:
data.h:
iff.h:
pcx.h:
elmer.h:

clean:
	rm -f *.o animrgb
