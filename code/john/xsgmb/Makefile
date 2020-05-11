CC = gcc
CFLAGS = -O2 -DPC
OBJS = bitio.o data.o elmer.o iff.o pcx.o spr.o xs.o \
	xvert.o xvert3do.o xvertfnt.o xvertgen.o xvertgmb.o \
	xvertibm.o xvertn64.o xvertpsx.o xvertsat.o xvertsfx.o xvertagb.o

all: xsgmb

xsgmb: $(OBJS)
	gcc -o xsgmb $(OBJS)

clean:
	rm -f *.o xsgmb
