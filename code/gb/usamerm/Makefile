GBTOOLS:=$(shell pwd)/../../gbasm
GBASM:=$(GBTOOLS)/gbasm
GBLINK:=$(GBTOOLS)/gblink

OUT=merm.gb

OBJS	     = \
		space09.obj \
		files00.obj \
		files01.obj \
		files02.obj \
		files03.obj \
		files04.obj \
		files05.obj \
		files06.obj \
		files07.obj \
		files08.obj \
		files09.obj \
		files10.obj \
		files11.obj \
		files12.obj \
		files13.obj \
		files14.obj \
		files15.obj \
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
		char0a0.obj \
		char0a1.obj \
		char0a2.obj \
		char0b0.obj \
		char0b1.obj \
		char0b2.obj \
		char10.obj \
		char11.obj \
		char12.obj \
		char13.obj \
		char20.obj \
		char21.obj \
		char22.obj \
		char23.obj \
		char30.obj \
		char31.obj \
		char32.obj \
		char33.obj \
		char40.obj \
		char41.obj \
		char42.obj \
		char43.obj \
		ram.obj      \
		bank00.obj   \
		bank01.obj   \
		bank02.obj   \
		bank03.obj   \
		bank0a.obj   \
		sprite00.obj   \
		sprite01.obj   \
		sprite02.obj   \
		sprite03.obj   \
		sprite04.obj   \
		sprites.obj  \
		spritesb.obj \
		fade.obj     \
		swd.obj      \
		sound1.obj    \
		sound2.obj    \
		bitmaplo.obj \
		bitmaphi.obj \
		fontlo.obj   \
		fonthi.obj \
		gmbchoke.obj \
		scroll.obj \
		scrollhi.obj \
		groups.obj \
		board1.obj \
		board2.obj \
		pin.obj \
		result.obj \
		ship.obj \
		volcano.obj \
		flounder.obj \
		prison.obj \
		souls.obj \
		ice.obj \
		flotsam.obj \
		cloak.obj \
		ursula.obj \
		morgana.obj \
		kiss.obj \
		trident.obj \
		scuttle.obj \
		treasure.obj \
		bear.obj \
		dash.obj \
		menu.obj \
		menu2.obj \
		menu3.obj \
		menu4.obj \
		menu5.obj \
		menu6.obj \
		menu7.obj \
		language.obj \
		rollup.obj \
		pinlo.obj \
		strings1.obj \
		strings2.obj \
		enterhigh.obj \
		pr.obj \
		fire.obj \
		showhigh.obj

vpath %.obj objs

all: res rom
rom:
	mkdir -p objs
	rm -f objs/* $(OUT)
	make $(OUT)

%.obj: %.asm *.equ res/filesys.asm
	$(GBASM) -oobjs/$@ $<

$(OUT): $(OBJS)
	cd objs ; $(GBLINK) $(OBJS) -o ../$(OUT)

clean: res
	rm -f $(OUT) objs/*.obj merm.map

res:
	make -C res $(MAKECMDGOALS)
.PHONY: res


play:
	mgb merm.gb

.PHONY: res rom

bank0a.obj:	res/jfont/*.gbf
sprite00.obj:	res/sprites.asm res/sprites.pal
sprite01.obj:	res/sprites.asm res/sprites.pal
sprite02.obj:	res/sprites.asm res/sprites.pal
sound1.obj:	gensound.asm
sound2.obj:	gensound.asm
strings1.obj:	res/text/some.b3f
