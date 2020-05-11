CC = gcc

CFLAGS = -O2 -DPC

all: makepkg

makepkg: makepkg.c makepkg.h lfptypes.h
	$(CC) -o $@ makepkg.c $(CFLAGS)

clean:
	rm -f makepkg *.o
