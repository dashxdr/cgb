; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu2.asm                                                             **
; **                                                                       **
; ** Created : 20000503 by David Ashley                                    **
; **   Player difficulty                                                   **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 03

		INTERFACE ProcessDirties


menu2_row	EQUS	"wTemp1024+00"
menu2_cx	EQUS	"wTemp1024+01"
menu2_cy	EQUS	"wTemp1024+02"
menu2_cp	EQUS	"wTemp1024+03"
menu2_first	EQUS	"wTemp1024+04"


menu2_list	EQUS	"bMenus+OPT_SPEEDS"

GROUP_CURSOR	EQU	1
GROUP_CURSOR2	EQU	2

menu2maplist:
		db	21
		dw	IDX_SPEEDRGB
		dw	IDX_SPEEDMAP

Menu2::
		call	menu2maxes

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
		ld	hl,menu2maplist
		call	NewLoadMap
		ld	hl,IDX_SPEEDBITSMAP
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,[bLanguage]
		or	a
		jr	z,.fine
		dec	a
		add	a
		add	33
		ld	e,a
		ld	d,0
		ld	bc,$1402
		ld	hl,0
		call	BGRect
		call	ProcessDirties_b
.fine:



		call	menu2showrows

		ld	a,1
		ld	[menu2_first],a


menu2outer:	call	menu2movecursor
menu2loop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	menu2cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu2_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu2_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menu2forward
		bit	JOY_A,a
		jp	nz,menu2forward
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		bit	JOY_B,a
		jp	nz,menu2back
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		jr	menu2loop

.updown:	ld	a,[bMenus+OPT_NUMPLAYERS]
		or	a
		jr	z,menu2loop
		inc	a
		ld	b,a
		ld	a,[menu2_row]
		add	c
		cp	b
		jr	c,.menuok
		ld	a,0
		jr	z,.menuok
		ld	a,b
		dec	a
.menuok:	ld	[menu2_row],a
		call	fxmove
		jr	menu2outer
.leftright:
		ld	a,[menu2_row]
		ld	e,a
		ld	d,0
		ld	hl,menu2rowlengths
		add	hl,de
		ld	b,[hl]
		ld	hl,menu2_list
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
		ld	hl,menu2rowstarts
		add	hl,de
		add	[hl]
		pop	bc
		push	af
		ld	a,b
		add	[hl]
		call	menu2off
		pop	af
		call	menu2on
		call	fxmove
		jp	menu2outer

menu2showrows:
		ld	hl,menu2_list
		ld	de,menu2rowstarts
		ld	a,[bMenus+OPT_NUMPLAYERS]
		inc	a
		ld	c,a
		ld	b,8
.srlp:		push	bc
		call	showrow
		pop	bc
		push	bc
		push	de
		push	hl
		ld	a,b
		call	menu2on
		pop	hl
		pop	de
		pop	bc
		inc	b
		dec	c
		jr	nz,.srlp
		ret
showrow:	ld	a,[de]
		inc	de
		add	[hl]
		inc	hl
		push	de
		push	hl
		call	menu2on
		pop	hl
		pop	de
		ret

menu2forward:	call	fxsel
		call	menu2shutdown
		xor	a
		ret
menu2back:	call	fxback
		call	menu2shutdown
		ld	a,1
		ret

menu2shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank


menu2on:	ld	hl,menu2ons
		jr	menu2onoff
menu2off:	ld	hl,menu2offs
menu2onoff:	push	af
		push	hl
		ld	a,[menu2_row]
		ld	c,a
		ld	b,0
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
.positions:	db	64,110,5,5

menu2ons:	db	5,3,8,1,6,3
		db	7,4,0,16,12,2
		db	5,4,8,4,6,6
		db	7,4,0,20,12,6
		db	5,4,8,8,6,10
		db	7,4,0,24,12,10
		db	5,4,8,12,6,14
		db	7,4,0,28,12,14

		db	3,4,0,0,1,2
		db	3,4,0,4,1,6
		db	3,4,0,8,1,10
		db	4,4,0,12,1,14

menu2offs:
		db	5,3,13,1,6,3
		db	7,4,7,16,12,2
		db	5,4,13,4,6,6
		db	7,4,7,20,12,6
		db	5,4,13,8,6,10
		db	7,4,7,24,12,10
		db	5,4,13,12,6,14
		db	7,4,7,28,12,14


menu2rowlengths: db	2
		db	2
		db	2
		db	2

menu2rowstarts:	db	0
		db	2
		db	4
		db	6

menu2movecursor: ld	a,[menu2_row]
		ld	c,a
		ld	b,0
		ld	hl,menu2rowstarts
		add	hl,bc
		ld	a,[hl]
		ld	hl,menu2_list
		add	hl,bc
		add	[hl]
		add	a
		ld	c,a
		ld	hl,menu2curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu2_cx],a
		ld	a,[hl]
		ld	[menu2_cy],a
		ret

	IF	0
menu2curslist:	db	72,27
		db	128,27
		db	72,27+36
		db	128,27+36
		db	72,27+36*2
		db	128,27+36*2
		db	72,27+36*3
		db	128,27+36*3
menu2cursor:	ld	a,[menu2_cp]
		cpl
;		add	a
;		add	a
		and	31
		ld	c,a
		ld	b,0
		ld	hl,TblSin
		add	hl,bc
		ld	e,[hl]
		sra	e
		sra	e
		sra	e
		sra	e
 ld e,0
		ld	hl,TblCos
		add	hl,bc
		ld	d,[hl]
		sra	d
		sra	d
;		sra	d
;		sra	d

		ld	a,[menu2_cy]
		add	e
		ld	e,a
		push	de
		ld	a,[menu2_cx]
		add	d
		ld	d,a
		ld	bc,IDX_BALL
		ld	a,[menu2_cp]
		inc	a
		ld	[menu2_cp],a
		srl	a
		and	15
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,GROUP_CURSOR
		push	bc
		call	AddFigure
		pop	bc
		pop	de
		ld	a,[menu2_cx]
		sub	d
		ld	d,a
		ld	a,GROUP_CURSOR
		jp	AddFigure
	ELSE

menu2curslist:	db	64,42
		db	120,42
		db	64,76
		db	120,76
		db	64,110
		db	120,110
		db	64,140
		db	120,140
menu2cursor:	ld	a,[menu2_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu2_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu2_cx]
		ld	d,a
		ld	a,[menu2_cy]
		ld	e,a
		ld	a,GROUP_CURSOR2
		jp	AddFigure
	ENDC

menu2maxes:	ld	hl,bMenus+OPT_SPEEDS
		ld	de,menu2rowlengths
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


;***********************************************************************
;***********************************************************************

