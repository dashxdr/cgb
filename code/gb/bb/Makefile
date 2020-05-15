GBTOOLS:=$(shell pwd)/../../gbasm
GBASM:=$(GBTOOLS)/gbasm
GBLINK:=$(GBTOOLS)/gblink

OUT=bb.gb

objs=	ram.obj \
	bank00.obj \
	bank01.obj \
	bank02.obj \
	bank03.obj \
	bank04.obj \
	bank05.obj \
	bank06.obj \
	bank07.obj \
	bank08.obj \
	bank09.obj \
	bank0a.obj \
	bank0b.obj \
	bank0c.obj \
	bank0d.obj \
	bank0e.obj \
	bank0f.obj \
	bank10.obj \
	bank11.obj \
	bank12.obj \
	bank13.obj \
	bank14.obj \
	bank15.obj \
	bank16.obj \
	bank17.obj \
	bank18.obj \
	bank19.obj \
	bank1a.obj \
	bank1b.obj \
	bank1c.obj \
	bank1d.obj \
	bank1e.obj \
	bank1f.obj \
	bank20.obj \
	bank21.obj \
	bank22.obj \
	bank23.obj \
	bank24.obj \
	bank25.obj \
	bank26.obj \
	bank27.obj \
	bank28.obj \
	bank29.obj \
	bank2a.obj \
	bank2b.obj \
	bank2c.obj \
	bank2d.obj \
	bank2e.obj \
	bank2f.obj \
	bank30.obj \
	bank31.obj \
	bank32.obj \
	bank33.obj \
	bank34.obj \
	bank35.obj \
	bank36.obj \
	bank37.obj \
	bank38.obj \
	bank39.obj \
	bank3a.obj \
	bank3b.obj \
	bank3c.obj \
	bank3d.obj \
	bank3e.obj \
	bank3f.obj \
	sprites.obj \
	spritesb.obj \
	scroll.obj \
	fade.obj \
	swd.obj \
	sgb.obj \
	shell.obj \
	sound.obj \
	sultan.obj \
	chip.obj \
	ride.obj \
	boardlo.obj \
	boardhi.obj \
	introlo.obj \
	introhi.obj \
	levelslo.obj \
	levelshi.obj \
	targetlo.obj \
	targethi.obj \
	trivialo.obj \
	triviahi.obj \
	matchlo.obj \
	matchhi.obj \
	mirrorlo.obj \
	mirrorhi.obj \
	endinglo.obj \
	endinghi.obj \
	bitmaplo.obj \
	bitmaphi.obj \
	fontlo.obj \
	fonthi.obj \
	whack.obj \
	chopper.obj \
	stove.obj \
	spit.obj \
	cellar.obj \
	dance.obj \
	kiss.obj \
	fire.obj

vpath %.obj objs

all: res rom

rom:
	mkdir -p objs
	rm -f objs/* $(OUT)
	make $(OUT)

%.obj:		%.asm
		$(GBASM) -oobjs/$@ $<



$(OUT):	$(objs)
	cd objs ; $(GBLINK) $(objs) -o ../$(OUT)

clean: res
	rm -f $(OUT) bb.map objs/*
	rm -fd objs
data:
	make -C res

res:
	make -C res $(MAKECMDGOALS)

.PHONY: res

equates.equ:	gameboy.equ ram.equ sprites.equ spritesb.equ \
		scroll.equ swd.equ sgb.equ sound.equ board.equ \
		intro.equ levels.equ mirror.equ trivia.equ target.equ \
		match.equ bitmap.equ font.equ \
		res/sprites.asm res/sprites.equ res/filesys.asm
		touch equates.equ


#ram.obj:	ram.asm    equates.equ
#bank00.obj:	bank00.asm equates.equ
#bank01.obj:	bank01.asm equates.equ res/filesys.asm
#bank02.obj:	bank02.asm
#bank03.obj:	bank03.asm equates.equ res/dave/font/pal.rgb res/filesys.asm
#bank04.obj:	bank04.asm
#bank05.obj:	bank05.asm res/filesys.asm
#bank06.obj:	bank06.asm res/filesys.asm
#bank07.obj:	bank07.asm res/filesys.asm
#bank08.obj:	bank08.asm res/john/font/*.gbf res/filesys.asm
#bank09.obj:	bank09.asm res/john/font/*.gbf res/filesys.asm
#bank0a.obj:	bank0a.asm res/sprites.b0a res/sprites.pal
#bank0b.obj:	bank0b.asm res/sprites.b0b
#bank0c.obj:	bank0c.asm res/sprites.b0c
#bank0d.obj:	bank0d.asm res/sprites.b0d
#bank0e.obj:	bank0e.asm res/sprites.b0e
#bank0f.obj:	bank0f.asm res/sprites.b0f
#bank10.obj:	bank10.asm res/sprites.b10
#bank11.obj:	bank11.asm res/sprites.b11
#bank12.obj:	bank12.asm res/sprites.b12
#bank13.obj:	bank13.asm res/sprites.b13
#bank14.obj:	bank14.asm res/filesys.b14
#bank15.obj:	bank15.asm res/filesys.b15
#bank16.obj:	bank16.asm res/filesys.b16
#bank17.obj:	bank17.asm res/filesys.b17
#bank18.obj:	bank18.asm res/filesys.b18
#bank19.obj:	bank19.asm res/filesys.b19
#bank1a.obj:	bank1a.asm res/filesys.b1a
#bank1b.obj:	bank1b.asm res/filesys.b1b
#bank1c.obj:	bank1c.asm res/filesys.b1c
#bank1d.obj:	bank1d.asm res/filesys.b1d
#bank1e.obj:	bank1e.asm res/filesys.b1e
#bank1f.obj:	bank1f.asm res/filesys.b1f
#bank20.obj:	bank20.asm res/filesys.b20
#bank21.obj:	bank21.asm res/filesys.b21
#bank22.obj:	bank22.asm res/filesys.b22
#bank23.obj:	bank23.asm res/filesys.b23
#bank24.obj:	bank24.asm res/filesys.b24
#bank25.obj:	bank25.asm res/filesys.b25
#bank26.obj:	bank26.asm res/filesys.b26
#bank27.obj:	bank27.asm res/filesys.b27
#bank28.obj:	bank28.asm res/filesys.b28
#bank29.obj:	bank29.asm res/filesys.b29
#bank2a.obj:	bank2a.asm res/filesys.b2a
#bank2b.obj:	bank2b.asm res/filesys.b2b
#bank2c.obj:	bank2c.asm res/filesys.b2c
#bank2d.obj:	bank2d.asm res/filesys.b2d
#bank2e.obj:	bank2e.asm res/filesys.b2e
#bank2f.obj:	bank2f.asm res/filesys.b2f
#bank30.obj:	bank30.asm res/filesys.b30
#bank31.obj:	bank31.asm res/filesys.b31
#bank32.obj:	bank32.asm res/filesys.b32
#bank33.obj:	bank33.asm res/filesys.asm
#bank34.obj:	bank34.asm res/filesys.asm
#bank35.obj:	bank35.asm res/john/maps/bboard.pk0
#bank36.obj:	bank36.asm res/john/maps/bboard.pk0
#bank37.obj:	bank37.asm res/john/maps/bboard.pk0
#bank38.obj:	bank38.asm res/john/maps/bboard.pk0
#bank39.obj:	bank39.asm res/john/maps/cboard.pk0
#bank3a.obj:	bank3a.asm res/john/maps/cboard.pk0
#bank3b.obj:	bank3b.asm res/john/maps/cboard.pk0
#bank3c.obj:	bank3c.asm res/john/maps/cboard.pk0
#bank3d.obj:	bank3d.asm res/john/strings/*.b3d
#bank3e.obj:	bank3e.asm res/john/strings/*.b3d res/john/font/*.gbf
#bank3f.obj:	bank3f.asm res/john/strings/*.b3d
#shell.obj:	shell.asm    equates.equ
#swd.obj:	swd.asm      equates.equ ram.equ swd.equ
#sgb.obj:	sgb.asm      equates.equ ram.equ sgb.equ res/dave/sgb/superpal.rgb
#sprites.obj:	sprites.asm  equates.equ ram.equ sprites.equ
#spritesb.obj:	spritesb.asm equates.equ ram.equ spritesb.equ
#scroll.obj:	scroll.asm   equates.equ ram.equ scroll.equ
#fade.obj:	fade.asm     equates.equ ram.equ fade.equ
#sound.obj:	sound.asm    equates.equ ram.equ sound.equ
#introlo.obj:	introlo.asm  equates.equ ram.equ sound.equ intro.equ  res/filesys.asm
#introhi.obj:	introhi.asm  equates.equ ram.equ sound.equ intro.equ  res/filesys.asm
#boardlo.obj:	boardlo.asm  equates.equ ram.equ sound.equ board.equ  intro.equ  res/filesys.asm
#boardhi.obj:	boardhi.asm  equates.equ ram.equ sound.equ board.equ  intro.equ  res/filesys.asm
#levelslo.obj:	levelslo.asm equates.equ ram.equ sound.equ levels.equ intro.equ  res/filesys.asm
#levelshi.obj:	levelshi.asm equates.equ ram.equ sound.equ levels.equ intro.equ  res/filesys.asm
#targetlo.obj:	targetlo.asm equates.equ ram.equ sound.equ target.equ intro.equ  res/filesys.asm
#targethi.obj:	targethi.asm equates.equ ram.equ sound.equ target.equ intro.equ  res/filesys.asm
#trivialo.obj:	trivialo.asm equates.equ ram.equ sound.equ trivia.equ intro.equ  res/filesys.asm
#triviahi.obj:	triviahi.asm equates.equ ram.equ sound.equ trivia.equ intro.equ  res/filesys.asm
#matchlo.obj:	matchlo.asm  equates.equ ram.equ sound.equ match.equ  intro.equ  res/filesys.asm
#matchhi.obj:	matchhi.asm  equates.equ ram.equ sound.equ match.equ  intro.equ  res/filesys.asm
#mirrorlo.obj:	mirrorlo.asm equates.equ ram.equ sound.equ mirror.equ intro.equ  res/filesys.asm
#mirrorhi.obj:	mirrorhi.asm equates.equ ram.equ sound.equ mirror.equ intro.equ  res/filesys.asm
#endinglo.obj:	endinglo.asm equates.equ ram.equ sound.equ ending.equ intro.equ  res/filesys.asm
#endinghi.obj:	endinghi.asm equates.equ ram.equ sound.equ ending.equ intro.equ  res/filesys.asm
#bitmaplo.obj:	bitmaplo.asm equates.equ ram.equ sound.equ bitmap.equ res/filesys.asm
#bitmaphi.obj:	bitmaphi.asm equates.equ ram.equ sound.equ bitmap.equ res/filesys.asm
#fontlo.obj:	fontlo.asm   equates.equ ram.equ sound.equ font.equ   res/filesys.asm
#fonthi.obj:	fonthi.asm   equates.equ ram.equ sound.equ font.equ   res/filesys.asm
#sultan.obj:	sultan.asm   equates.equ
#chip.obj:	chip.asm     equates.equ
#ride.obj:	ride.asm     equates.equ res/dave/ride/ride.chr res/dave/ride/ridetrg2.asm
#whack.obj:	whack.asm    equates.equ res/dave/whackoff/bstmap.bin
#chopper.obj:	chopper.asm  equates.equ res/dave/chopper/chopdat.bin
#stove.obj:	stove.asm    equates.equ res/dave/stove/potts.as2
#spit.obj:	spit.asm     equates.equ
#cellar.obj:	cellar.asm   equates.equ
#dance.obj:	dance.asm    equates.equ
#fire.obj:	fire.asm     equates.equ
#kiss.obj:	kiss.asm     equates.equ
