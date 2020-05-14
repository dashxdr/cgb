GBTOOLS:=$(shell pwd)/../../gbasm
GBASM:=$(GBTOOLS)/gbasm
GBLINK:=$(GBTOOLS)/gblink
SUBDIRS:= util res

OUT	     =	thrill.gb

OBJS	     = \
		files00.obj \
		files01.obj \
		files02.obj \
		files03.obj \
		files04.obj \
		files05.obj \
		files06.obj \
		files07.obj \
		pin00.obj \
		pin01.obj \
		pin02.obj \
		pin03.obj \
		pin04.obj \
		pin05.obj \
		pin06.obj \
		pin07.obj \
		pin08.obj \
		pin09.obj \
		strings1.obj \
		strings2.obj \
		sprite00.obj   \
		sprite01.obj   \
		fonthi.obj \
		char00.obj \
		char01.obj \
		char02.obj \
		char10.obj \
		char11.obj \
		char12.obj \
		char13.obj \
		char20.obj \
		char21.obj \
		char22.obj \
		char23.obj \
		sound.obj    \
		ram.obj      \
		bank00.obj   \
		shell.obj   \
		sprites.obj  \
		spritesb.obj \
		fade.obj     \
		swd.obj      \
		bitmaplo.obj \
		bitmaphi.obj \
		fontlo.obj   \
		gmbchoke.obj \
		scroll.obj \
		scrollhi.obj \
		board.obj \
		pin.obj \
		result.obj \
		menu.obj \
		menu2.obj \
		menu3.obj \
		menu6.obj \
		menu7.obj \
		pinlo.obj \
		enterhigh.obj \
		fire.obj \
		falcon.obj \
		kiss.obj \
		rapids.obj \
		looper.obj \
		build.obj \
		bear.obj \
		boat.obj \
		race.obj \
		side.obj \
		ir.obj \
		out.obj \
		showhigh.obj

vpath %.obj objs

all: $(SUBDIRS) rom

rom:
	mkdir -p objs
	rm -f objs/* $(OUT)
	make $(OUT)

%.obj:	%.asm *.equ res/filesys.asm
	$(GBASM) -oobjs/$@ $<

$(OUT):	$(OBJS)
	cd objs ; $(GBLINK) $(OBJS) -o ../$(OUT)
$(SUBDIRS):
	make -C $@ $(MAKECMDGOALS)
clean: $(SUBDIRS)
	rm -f $(OUT) objs/*.obj
play:
	../../mgb/mgb $(OUT)

.PHONY: $(SUBDIRS) rom

#fonthi.obj:	res/jfont/*.gbf
#sprite00.obj:	res/sprites.asm res/sprites.pal
#sprite01.obj:	res/sprites.asm res/sprites.pal
#sprite02.obj:	res/sprites.asm res/sprites.pal
#sound.obj:	musicd.bin
#strings1.obj:	res/text/some.b00
