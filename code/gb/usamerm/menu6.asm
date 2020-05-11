; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu6.asm                                                             **
; **                                                                       **
; ** Created : 20000518 by David Ashley                                    **
; **   Options menu                                                        **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

		INTERFACE ProcessDirties
		INTERFACE Menu7
		INTERFACE BBRAMZap
		INTERFACE Language


menu6_row	EQUS	"wTemp1024+00"
menu6_cx	EQUS	"wTemp1024+01"
menu6_cy	EQUS	"wTemp1024+02"
menu6_cp	EQUS	"wTemp1024+03"
menu6_first	EQUS	"wTemp1024+04"

menu6_list	EQUS	"bMenus+OPT_OPTIONS"

GROUP_CURSOR	EQU	1
GROUP_CURSOR2	EQU	2

menu6maplist:
		db	21
		dw	IDX_OPTIONSRGB
		dw	IDX_OPTIONSMAP
		db	21
		dw	IDX_OPTIONSRGB
		dw	IDX_GOPTIONSMAP
		db	21
		dw	IDX_OPTIONSRGB
		dw	IDX_FOPTIONSMAP
		db	21
		dw	IDX_OPTIONSRGB
		dw	IDX_IOPTIONSMAP
		db	21
		dw	IDX_OPTIONSRGB
		dw	IDX_SOPTIONSMAP

Menu6::
		xor	a
menu6redo:	push	af

		call	menu6maxes

		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_BALL
		call	AddPalette
		ld	hl,PAL_ARROW
		call	AddPalette

		ld	a,BANK(Char40)
		ld	[wPinCharBank],a
		ld	a,[bLanguage]
		ld	e,a
		ld	d,0
		add	a
		add	a
		add	e
		ld	e,a
		ld	hl,menu6maplist
		add	hl,de
		call	NewLoadMap
		ld	hl,IDX_OPTIONBITSMAP
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		call	showrows

		pop	af
		ld	[menu6_row],a

		ld	a,1
		ld	[menu6_first],a

menu6outer:	call	movecursor
menu6loop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu6_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu6_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menu6forward
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		bit	JOY_B,a
		jp	nz,menu6back
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		bit	JOY_A,a
		jr	nz,.doit
		jr	menu6loop

.updown:	ld	a,[menu6_row]
		add	c
		cp	5
		jr	c,.menuok
		ld	a,0
		jr	z,.menuok
		ld	a,5-1
.menuok:	ld	[menu6_row],a
		call	fxmove
		jr	menu6outer
.leftright:
		ld	a,[menu6_row]
		cp	2
		jr	nc,menu6loop
		ld	e,a
		ld	d,0
		ld	hl,rowlengths
		add	hl,de
		ld	b,[hl]
		ld	hl,menu6_list
		add	hl,de
		ld	a,[hl]
		cp	b
		jr	c,.fine
		xor	a
		ld	[hl],a
.fine:		push	af
		add	c
		cp	b
		jr	c,.fine2
		ld	a,0
		jr	z,.fine2
		ld	a,b
		dec	a
.fine2:		ld	[hl],a
		ld	b,a
		ld	hl,rowstarts
		add	hl,de
		add	[hl]
		pop	bc
		push	af
		ld	a,b
		add	[hl]
		call	menu6off
		pop	af
		call	menu6on
		call	menutune
		call	fxmove
		jp	menu6outer
.doit:		ld	a,[menu6_row]
		cp	4
		jr	z,.credits
		cp	3
		jr	z,.language
		cp	2
		jp	nz,menu6loop
		call	fxsel
		call	menu6shutdown
		call	Menu7_b
		or	a
		call	nz,BBRAMZap_b
		call	menutune
		ld	a,2
		jp	menu6redo
.credits:	call	fxsel
		call	FadeOutBlack
		call	WaveOff
		call	credits
		ld	a,4
		jp	menu6redo
.language:	call	fxsel
		call	FadeOutBlack
		call	WaveOff
		call	Language_b
		ld	a,3
		jp	menu6redo

showrows:
		ld	hl,menu6_list
		ld	de,rowstarts
		call	showrow
		jp	showrow
showrow:	ld	a,[de]
		inc	de
		add	[hl]
		inc	hl
		push	de
		push	hl
		call	menu6on
		pop	hl
		pop	de
		ret

menu6forward:	call	fxsel
		call	menu6shutdown
		xor	a
		ret
menu6back:	call	fxback
		call	menu6shutdown
		ld	a,1
		ret

menu6shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank

menu6on:	ld	hl,menu6onlist
		jr	menu6onoff
menu6off:	ld	hl,menu6offlist
menu6onoff:
		push	af
		ld	a,[menu6_row]
		ld	c,a
		ld	b,0
		ld	d,b
		ld	a,[bLanguage]
		add	a
		ld	e,a
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	hl,.positions
		add	hl,bc
.wait:		ldio	a,[rLY]
		cp	[hl]
		jr	nz,.wait
		pop	hl
		pop	af
		add	a
		ld	c,a
		add	a
		add	c
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
		call	BGRect
		jp	ProcessDirties_b
.positions:	db	110
		db	110
		db	110

menu6onlist:	dw	menu6ons
		dw	menu6gons
		dw	menu6fons
		dw	menu6ions
		dw	menu6sons

menu6offlist:	dw	menu6offs
		dw	menu6goffs
		dw	menu6foffs
		dw	menu6ioffs
		dw	menu6soffs


menu6ons:	db	3,3,0,0,14,2
		db	3,3,6,0,17,2
		db	3,2,0,3,14,5
		db	3,2,6,3,17,5
;		db	3,3,0,5,14,7
;		db	3,3,6,5,17,7
menu6offs:	db	3,3,3,0,14,2
		db	3,3,9,0,17,2
		db	3,2,3,3,14,5
		db	3,2,9,3,17,5
;		db	3,3,3,5,14,7
;		db	3,3,9,5,17,7

menu6gons:	db	3,3,0,0,14,2
		db	3,3,6,0,17,2
		db	3,2,0,3,14,5
		db	3,2,6,3,17,5
;		db	3,3,0,5,14,7
;		db	3,3,6,5,17,7
menu6goffs:	db	3,3,3,0,14,2
		db	3,3,9,0,17,2
		db	3,2,3,3,14,5
		db	3,2,9,3,17,5
;		db	3,3,3,5,14,7
;		db	3,3,9,5,17,7
menu6fons:	db	3,3,0,0,14,2
		db	3,3,6,0,17,2
		db	3,2,0,3,14,5
		db	3,2,6,3,17,5
;		db	3,3,0,5,14,7
;		db	3,3,6,5,17,7
menu6foffs:	db	3,3,3,0,14,2
		db	3,3,9,0,17,2
		db	3,2,3,3,14,5
		db	3,2,9,3,17,5
;		db	3,3,3,5,14,7
;		db	3,3,9,5,17,7
menu6ions:	db	3,3,0,0,14,2
		db	3,3,6,0,17,2
		db	3,2,0,3,14,5
		db	3,2,6,3,17,5
;		db	3,3,0,5,14,7
;		db	3,3,6,5,17,7
menu6ioffs:	db	3,3,3,0,14,2
		db	3,3,9,0,17,2
		db	3,2,3,3,14,5
		db	3,2,9,3,17,5
;		db	3,3,3,5,14,7
;		db	3,3,9,5,17,7
menu6sons:	db	3,3,0,0,14,2
		db	3,3,6,0,17,2
		db	3,2,0,3,14,5
		db	3,2,6,3,17,5
;		db	3,3,0,5,14,7
;		db	3,3,6,5,17,7
menu6soffs:	db	3,3,3,0,14,2
		db	3,3,9,0,17,2
		db	3,2,3,3,14,5
		db	3,2,9,3,17,5
;		db	3,3,3,5,14,7
;		db	3,3,9,5,17,7


rowlengths:	db	2
		db	2
;		db	2
		db	1
		db	1
		db	1

rowstarts:	db	0
		db	2
		db	4
		db	5
		db	6

movecursor:	ld	a,[menu6_row]
		ld	c,a
		ld	b,0
		ld	hl,rowstarts
		add	hl,bc
		ld	a,[hl]
		ld	hl,menu6_list
		add	hl,bc
		add	[hl]
		add	a
		ld	c,a
		ld	hl,curslists
		ld	a,[bLanguage]
		add	a
		ld	e,a
		ld	d,b
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		add	hl,bc
		ld	a,[hli]
		ld	[menu6_cx],a
		ld	a,[hl]
		ld	[menu6_cy],a
		ret

curslists:	dw	curslist
		dw	gcurslist
		dw	fcurslist
		dw	icurslist
		dw	scurslist
curslist:	db	110,30
		db	130,30
		db	110,50
		db	130,50
;		db	110,70
;		db	130,70
		db	10,90
		db	10,110
		db	10,130

gcurslist:
		db	110,30
		db	130,30
		db	110,50
		db	130,50
;		db	110,70
;		db	130,70
		db	10,90
		db	10,110
		db	10,130

fcurslist:	db	110,30
		db	130,30
		db	110,50
		db	130,50
;		db	110,70
;		db	130,70
		db	10,90
		db	10,110
		db	10,130

icurslist:	db	110,30
		db	130,30
		db	110,50
		db	130,50
;		db	110,70
;		db	130,70
		db	10,90
		db	10,110
		db	10,130

scurslist:	db	110,30
		db	130,30
		db	110,50
		db	130,50
;		db	110,70
;		db	130,70
		db	10,90
		db	10,110
		db	10,130




cursor:		ld	a,[menu6_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu6_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu6_cx]
		ld	d,a
		ld	a,[menu6_cy]
		ld	e,a
		ld	a,GROUP_CURSOR2
		jp	AddFigure

menu6maxes:	ld	hl,menu6_list
		ld	de,rowlengths
		call	.max1
		call	.max1
		call	.max1
		call	.max1
		call	.max1
.max1:		ld	a,[de]
		dec	a
		cp	[hl]
		jr	nc,.good
.bad:		ld	[hl],a
.good:		inc	de
		inc	hl
		ret


credits:
		ld	a,[bMenus+OPT_OPTIONS]
		or	a
		jr	nz,.notune
		ld	a,SONG_CREDITS
		call	InitTune
.notune:	ld	de,IDX_CREDITS1PKG
		call	.sh1
		ld	de,IDX_CREDITS2PKG
		call	.sh1
		ld	de,IDX_CREDITS3PKG
		call	.sh1
		ld	de,IDX_CREDITS4PKG
		call	.sh1
		ld	de,IDX_CREDITS5PKG
		call	.sh1
		ld	de,IDX_CREDITS6PKG
		call	.sh1
		ld	de,IDX_CREDITS7PKG
		call	.sh1
		jp	menutune
.sh1:		push	de
		call	SetBitmap20x18
		pop	de
		call	XferBitmap
		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	FadeInBlack
.wait:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	z,.wait
		call	fxsel
		jp	FadeOutBlack



;***********************************************************************
;***********************************************************************

