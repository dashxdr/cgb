; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** RESULT.ASM                                                            **
; **                                                                       **
; ** Created : 20000421 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		SECTION	11

SCORE1		EQUS	"wMessage+64"
SCORE2		EQUS	"wMessage+80"


LINEX		EQU	4
LINEY		EQU	108
SPACEY		EQU	10

ResultTest::
;	call	BuildMessageList
 ld a,1
.t1:
	ld	[pin_board],a
	xor	a
	ld	[any_credit1],a
	ld	[any_credit2],a
	call	tst
	ld	a,40
	ld	[any_credit1],a
	ld	[any_credit2],a
	call	tst
	ld	a,[pin_board]
	inc	a
	cp	18
	jr	c,.t1
	ret
tst:
ResultScreen_b::

		ld	a,[pin_board]
		ld	hl,part1
		call	funclist

		ld	a,d
		or	e
		ret	z

		push	hl
		call	loadpic
		call	picklite

		ldh	a,[pin_board]
		ld	hl,part2
		call	funclist

		pop	hl
		xor	a
		ld	[wStartHappy],a
		ld	a,h
		or	l
		jr	nz,.nocomplete
		ldh	a,[pin_board]
		cp	SUBGAME_URSULA
		jr	z,.happyon
		cp	SUBGAME_MORGANA
		jr	nz,.nohappy
.happyon:	ld	a,1
		ld	[wStartHappy],a
		ld	[any_gothappy],a
		ld	hl,completestring1b1
		call	DrawStringLstN
		ld	hl,completestring1b2
		call	DrawStringLst
		ld	de,score1000m
		call	addscore
		jr	.1000m
.nohappy:
.100m:		ld	hl,completestring1
		call	DrawStringLstN
		ld	hl,completestring2
		call	DrawStringLst
		ld	de,score100m
		call	addscore
.1000m:
.nocomplete:

; ld a,1
; ld [wStartHappy],a ;DEBUG

		call	InitGroups
		ld	hl,PAL_PRNTICON
		call	Palette7
		xor	a
		ld	[wPrinterState],a
		ld	a,32
		ld	[wWave],a

		call	copyshow

		ld	a,1
		ld	[wPrinterPossible],a

.wait:		call	WaitForVBL
		call	ReadJoypad
		call	InitFigures
		call	PrinterProcess
		call	OutFigures
		ld	a,[wJoy1Hit]
		bit	JOY_SELECT,a
		jr	nz,.print
		or	a
		jr	z,.wait
		call	FadeOutBlack
		ret
.print:
	IF	PRINTER
		call	fxsel
		ld	a,-1
		call	PrintSomething
	ENDC
		jr	.wait

funclist:	ld	e,a
		ld	d,0
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]

res2_nothing:
res1_nothing:	ld	de,0
		ret
res1_cave:	ld	de,IDX_SOULLOSEPKG
		ld	hl,IDX_SOULWINPKG
		ld	b,NEED_CAVE
		jp	res1_all
res1_scuttle:
		ld	de,IDX_SCTLLOSEPKG
		ld	hl,IDX_SCTLWINPKG
		ld	b,NEED_SCUTTLE
		jp	res1_all
res1_ship:
		ld	de,IDX_STORMLOSEPKG
		ld	hl,IDX_STORMWINPKG
		ld	b,NEED_SHIP
		jp	res1_all
res1_flounder:
		ld	de,IDX_FLNDLOSEPKG
		ld	hl,IDX_FLNDWINPKG
		ld	b,NEED_FLOUNDER
		jr	res1_all
res1_flotsam:
		ld	de,IDX_FLTSLOSEPKG
		ld	hl,IDX_FLTSWINPKG
		ld	b,NEED_FLOTSAM
		jr	res1_all
res1_kiss:
		ld	de,IDX_KISSLOSEPKG
		ld	hl,IDX_KISSWINPKG
		ld	b,NEED_KISS
		jr	res1_all
res1_ursula:
		ld	de,IDX_URSULOSEPKG
		ld	hl,IDX_URSULWINPKG
		ld	b,NEED_URSULA
		jr	res1_all
res1_treasure:
		ld	de,IDX_TRSURLOSEPKG
		ld	hl,IDX_TRSURWINPKG
		ld	b,NEED_TREASURE
		jr	res1_all
res1_prison:
		ld	de,IDX_MELLOSEPKG
		ld	hl,IDX_MELWINPKG
		ld	b,NEED_PRISON
		jr	res1_all
res1_dash:
		ld	de,IDX_DASHSADPKG
		ld	hl,IDX_DASHWINPKG
		ld	b,NEED_DASH
		jr	res1_all
res1_cloak:
		ld	de,IDX_CLCKLOSEPKG
		ld	hl,IDX_CLCKWINPKG
		ld	b,NEED_CLOAK
		jr	res1_all
res1_icecave:
		ld	de,IDX_TIPLOSEPKG
		ld	hl,IDX_TIPWINPKG
		ld	b,NEED_ICECAVE
		jr	res1_all
res1_volcano:
		ld	de,IDX_VOLCANLOSEPKG
		ld	hl,IDX_VOLCANWINPKG
		ld	b,NEED_VOLCANO
		jr	res1_all
res1_trident:
		ld	de,IDX_TRIDLOSEPKG
		ld	hl,IDX_TRIDWINPKG
		ld	b,NEED_TRIDENT
		jr	res1_all
res1_morgana:
		ld	de,IDX_MORGLOSEPKG
		ld	hl,IDX_MORGWINPKG
		ld	b,NEED_MORGANA
		jr	res1_all
res1_bear:
		ld	de,IDX_POLARLOSEPKG
		ld	hl,IDX_POLARWINPKG
		ld	b,NEED_BEAR
		jr	res1_all

res1_all:	ld	a,[any_credit1]
		sub	b
		ret	c
		ld	d,h
		ld	e,l
		ld	hl,0
		ret

part1:		dw	res1_nothing		;table1
		dw	res1_cave
		dw	res1_scuttle
		dw	res1_ship
		dw	res1_flounder
		dw	res1_flotsam
		dw	res1_kiss
		dw	res1_ursula
		dw	res1_treasure
		dw	res1_nothing		;table2
		dw	res1_icecave
		dw	res1_volcano
		dw	res1_trident
		dw	res1_prison
		dw	res1_dash
		dw	res1_morgana
		dw	res1_bear
		dw	res1_cloak

res2_cave:
		ld	de,MSGRESCUED
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_scuttle:
		ld	de,MSGCOLLECTED
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_ship:
		ld	de,MSGRESCUED
		call	line15m
		ret
res2_flounder:
		ld	de,MSGHIT
		call	line15m
		ret
res2_flotsam:
		ld	de,MSGHIT
		call	line11m
		ret
res2_kiss:
		ld	de,MSGACTIVE
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_ursula:
		ld	de,MSGCRUSHED
		call	line1100m
		ld	de,MSGHIT
		call	line25m
		ret
res2_treasure:
		ld	de,MSGOPENED
		call	line110m
		ld	de,MSGHIT
		call	line21m
		ret
res2_prison:
		ld	de,MSGBROKEN
		call	line15m
		ret
res2_dash:
		ld	de,MSGCAUGHT
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_cloak:
		ld	de,MSGHIT
		call	line11m
		ret
res2_icecave:
		ld	de,MSGSMASHED
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_volcano:
		ld	de,MSGRESCUED
		call	line15m
		ret
res2_trident:
		ld	de,MSGSTUNNED
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret
res2_morgana:
		ld	de,MSGCRUSHED
		call	line1100m
		ld	de,MSGHIT
		call	line25m
		ret
res2_bear:
		ld	de,MSGRESCUED
		call	line15m
		ld	de,MSGHIT
		call	line21m
		ret

part2:		dw	res2_nothing		;table1
		dw	res2_cave
		dw	res2_scuttle
		dw	res2_ship
		dw	res2_flounder
		dw	res2_flotsam
		dw	res2_kiss
		dw	res2_ursula
		dw	res2_treasure
		dw	res2_nothing		;table2
		dw	res2_icecave
		dw	res2_volcano
		dw	res2_trident
		dw	res2_prison
		dw	res2_dash
		dw	res2_morgana
		dw	res2_bear
		dw	res2_cloak




;de=message #
line3100m:	ld	a,[any_credit3]
		ld	c,LINEY+SPACEY*2
		ld	b,100
		jr	anyline
line2100m:	ld	a,[any_credit2]
		ld	c,LINEY+SPACEY
		ld	b,100
		jr	anyline
line1100m:	ld	a,[any_credit1]
		ld	b,100
		ld	c,LINEY
		jr	anyline
line310m:	ld	a,[any_credit3]
		ld	c,LINEY+SPACEY*2
		ld	b,10
		jr	anyline
line210m:	ld	a,[any_credit2]
		ld	c,LINEY+SPACEY
		ld	b,10
		jr	anyline
line110m:	ld	a,[any_credit1]
		ld	b,10
		ld	c,LINEY
		jr	anyline
line35m:	ld	a,[any_credit3]
		ld	c,LINEY+SPACEY*2
		ld	b,5
		jr	anyline
line25m:	ld	a,[any_credit2]
		ld	c,LINEY+SPACEY
		ld	b,5
		jr	anyline
line15m:	ld	a,[any_credit1]
		ld	c,LINEY
		ld	b,5
		jr	anyline
line31m:	ld	a,[any_credit3]
		ld	c,LINEY+SPACEY*2
		ld	b,1
		jr	anyline
line21m:	ld	a,[any_credit2]
		ld	c,LINEY+SPACEY
		ld	b,1
		jr	anyline
line11m:	ld	a,[any_credit1]
		ld	b,1
		ld	c,LINEY
anyline:	push	af
		push	bc
		call	FetchMessage
		pop	bc
		ld	a,LINEX
		ld	[wMessage],a
		ld	a,c
		ld	[wMessage+1],a
		pop	af
		ld	c,a
		push	bc
		call	prependdec
		xor	a
		ld	[wMessage+3],a
		ld	hl,wMessage
		call	DrawStringLst
		ld	hl,SCORE1
		ld	bc,12
		call	MemClear
		ld	hl,SCORE2
		ld	bc,12
		call	MemClear
		pop	bc
		ld	a,c
		ld	hl,SCORE2+3
		call	dec02hl
.mult:		push	bc
		call	add21
		pop	bc
		dec	b
		jr	nz,.mult
		ld	de,SCORE1
		call	addscore
		ld	de,SCORE1
		ld	hl,wMessage+4
		call	print6
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	a,160-LINEX
		ld	[wMessage],a
		ld	a,2
		ld	[wMessage+3],a
		ld	hl,wMessage
		jp	DrawStringLst

print6:
		push	hl
		ld	b,"0"
		ld	c,","
		call	print3
		call	printc3
		ld	a,"M"
		ld	[hli],a
		ld	[hl],0
		pop	hl
		ld	d,h
		ld	e,l
		ld	c,6
.rem0:		ld	a,[de]
		cp	"0"
		jr	z,.cont
		cp	","
		jr	nz,.done
.cont:		inc	de
		dec	c
		jr	nz,.rem0
.done:
.c0:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,.c0
		dec	hl
		ret



printc3:	ld	a,c
		ld	[hli],a
print3:
		REPT	3
		ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ENDR
		ret

add21:		ld	de,SCORE2+11
		ld	hl,SCORE1+11
		ld	bc,12
.addlp:		ld	a,[de]
		dec	de
		add	[hl]
		add	b
		ld	b,0
		cp	10
		jr	c,.noover10
		sub	10
		inc	b
.noover10:	ld	[hld],a
		dec	c
		jr	nz,.addlp
		ret



;a=value to prepend
prependdec:	ld	c,a
		ld	de,wMessage+64
		ld	hl,wMessage+4
.c1:		ld	a,[hli]
		ld	[de],a
		inc	de
		or	a
		jr	nz,.c1
		ld	a,c
		ld	hl,wMessage+4
		call	dec2hl
		ld	a," "
		ld	[hli],a
		ld	de,wMessage+64
.c2:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,.c2
		ld	[hl],a
		ret
dec2hl:		cp	100
		jr	c,.dig2
.dig3:		cp	200
		jr	nc,.dig2xx
		ld	[hl],"1"
		inc	hl
		sub	100
		jr	.dig2
.dig2xx:	ld	[hl],"2"
		inc	hl
		sub	200
.dig2:		cp	10
		jr	c,.dig1
		ld	[hl],"0"-1
.div10:		inc	[hl]
		sub	10
		jr	nc,.div10
		add	10
		inc	hl
.dig1:		add	"0"
		ld	[hli],a
		ret

dec02hl:	ld	[hl],-1
.d100:		inc	[hl]
		sub	100
		jr	nc,.d100
		add	100
		inc	hl
		ld	[hl],-1
.d10:		inc	[hl]
		sub	10
		jr	nc,.d10
		inc	hl
		add	10
		ld	[hli],a
		ret



completestring1:
		db	LINEX
		db	LINEY+2*SPACEY
		db	0
		db	0
		dw	MSGCOMPLETE
		db	0
completestring2:
		db	160-LINEX
		db	LINEY+2*SPACEY
		db	0
		db	2
		db	"100M",0
		db	0

completestring1b1:
		db	LINEX
		db	LINEY+2*SPACEY
		db	0
		db	0
		dw	MSGCOMPLETE
		db	0
completestring1b2:
		db	160-LINEX
		db	LINEY+2*SPACEY
		db	0
		db	2
		db	"1,000M",0
		db	0

; ***************************************************************************




; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

