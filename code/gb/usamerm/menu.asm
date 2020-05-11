; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu.asm                                                              **
; **                                                                       **
; ** Created : 20000502 by David Ashley                                    **
; **  # of players and # of balls                                          **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

		INTERFACE ProcessDirties

menu_row	EQUS	"wTemp1024+00"
menu_cx		EQUS	"wTemp1024+01"
menu_cy		EQUS	"wTemp1024+02"
menu_cp		EQUS	"wTemp1024+03"
menu_first	EQUS	"wTemp1024+04"

menu_list	EQUS	"bMenus+OPT_NUMPLAYERS"

GROUP_CURSOR	EQU	1
GROUP_CURSOR2	EQU	2

menumaplist:
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_PLAYERSMAP
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_GPLAYERSMAP
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_FPLAYERSMAP
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_IPLAYERSMAP
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_SPLAYERSMAP

Menu::
		call	menu1maxes

		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_BALL
		call	AddPalette
		ld	hl,PAL_ARROW
		call	AddPalette

		ld	a,BANK(Char30)
		ld	[wPinCharBank],a
		ld	hl,menumaplist
		ld	a,[bLanguage]
		ld	e,a
		add	a
		add	a
		add	e
		ld	e,a
		ld	d,0
		add	hl,de
		call	NewLoadMap
		ld	hl,IDX_PLAYERBITSMAP
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		call	showrows

		ld	a,1
		ld	[menu_first],a

menuouter:	call	movecursor
menuloop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menuforward
		bit	JOY_A,a
		jp	nz,menuforward
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		bit	JOY_B,a
		jp	nz,menuback
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		jr	menuloop

.updown:	ld	a,[menu_row]
		add	c
		cp	2
		jr	c,.menuok
		ld	a,0
		jr	z,.menuok
		ld	a,1
.menuok:	ld	[menu_row],a
		call	fxmove
		jr	menuouter

.leftright:
		ld	a,[menu_row]
		ld	e,a
		ld	d,0
		ld	hl,rowlengths
		add	hl,de
		ld	b,[hl]
		ld	hl,menu_list
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
		call	menuoff
		pop	af
		call	menuon
		call	fxmove
		jp	menuouter

showrows:
		ld	hl,menu_list
		ld	de,rowstarts
		call	showrow
showrow:	ld	a,[de]
		inc	de
		add	[hl]
		inc	hl
		push	de
		push	hl
		call	menuon
		pop	hl
		pop	de
		ret

menuforward:	call	fxsel
		call	menushutdown
		xor	a
		ret
menuback:	call	fxback
		call	menushutdown
		ld	a,1
		ret

menushutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank

menuon:		ld	hl,menuons
		jr	menuonoff
menuoff:	ld	hl,menuoffs
menuonoff:
		push	af
		push	hl
		ld	a,[menu_row]
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
.positions:	db	64
		db	5
		db	110

menuons:	db	3,4,0,0,2,3
		db	3,4,0,4,6,3
		db	3,4,0,8,11,3
		db	3,4,0,12,15,3
		db	6,5,0,16,2,13
		db	9,5,0,21,9,13


menuoffs:	db	3,4,3,0,2,3
		db	3,4,3,4,6,3
		db	3,4,3,8,11,3
		db	3,4,3,12,15,3
		db	6,5,6,16,2,13
		db	9,5,9,21,9,13


rowlengths:	db	4
		db	2

rowstarts:	db	0
		db	4

movecursor:	ld	a,[menu_row]
		ld	c,a
		ld	b,0
		ld	hl,rowstarts
		add	hl,bc
		ld	a,[hl]
		ld	hl,menu_list
		add	hl,bc
		add	[hl]
		add	a
		ld	c,a
		ld	hl,curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu_cx],a
		ld	a,[hl]
		ld	[menu_cy],a
		ret

	IF	0
curslist:	db	8+13,27
		db	46+13,27
		db	85+13,27
		db	124+13,27
		db	19+22,63+6
		db	87+30,63+6
		db	8+34,135
		db	84+34,135
cursor:		ld	a,[menu_cp]
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

		ld	a,[menu_cy]
		add	e
		ld	e,a
		push	de
		ld	a,[menu_cx]
		add	d
		ld	d,a
		ld	bc,IDX_BALL
		ld	a,[menu_cp]
		inc	a
		ld	[menu_cp],a
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
		ld	a,[menu_cx]
		sub	d
		ld	d,a
		ld	a,GROUP_CURSOR
		jp	AddFigure
	ELSE

curslist:	db	12,50
		db	46,50
		db	82,50
		db	115,50
		db	19,130
		db	87,130
cursor:		ld	a,[menu_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu_cx]
		ld	d,a
		ld	a,[menu_cy]
		ld	e,a
		ld	a,GROUP_CURSOR2
		jp	AddFigure
	ENDC

menu1maxes:	ld	hl,menu_list
		ld	de,rowlengths
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

