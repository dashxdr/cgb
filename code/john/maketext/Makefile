CFLAGS=-O2

all: maketext doit subdir_all

maketext: maketext.o

maketext.o: maketext.c maketext.h

doit:
	./maketext -BANK 0x2b -SKIP 0 -LANGUAGES 1 -JAPANESE -REMAPFROM 1 -REMAPFILE japanese.u16 fullengl2.txt
	./maketext -BANK 0x2b -SKIP 0 -LANGUAGES 5 all.txt

clean: subdir_clean
	rm -f *.o maketext *.b2b

subdir_all:
	make -C util all
subdir_clean:
	make -C util clean

# md5sums of generated files:
# e362a17e68a8da32b842799607d5d77d  all.b2b
# 9ac4a4a35c1a65f29a38340e976ea241  fullengl2.b2b
