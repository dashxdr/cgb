EXE=agbspr agbswd ase bintree bmap coag code1 comp coordbak coord crom
EXE+=crypt csvtoc deagb demime elf fixsound gather gbfconv gbswd gmbspr2
EXE+=makebga makebg mapdelta midifilter nsum pinmap2 remap remcr ridecnv2
EXE+=rideconv sniff space sprtoppm tumerd uconv2 uconv
CC = gcc
CFLAGS=-O2 -Wall
PLATFORM := $(shell uname -s)
ifneq ($(PLATFORM),Darwin)
	EXTRAFLAGS = -lcrypt
endif

all: $(EXE) subdir_all

crypt: crypt.c
	$(CC) -o $@ $^ $(CFLAGS) $(EXTRAFLAGS)

clean: subdir_clean
	rm -f $(EXE)

subdir_all:
	make -C animrgb all
subdir_clean:
	make -C animrgb clean

