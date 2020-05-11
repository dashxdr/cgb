; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu7.asm                                                             **
; **                                                                       **
; ** Created : 20000518 by David Ashley                                    **
; **   "Are you sure?" menu                                                **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 03

		INTERFACE ProcessDirties

menu7_row	EQUS	"wTemp1024+00"
menu7_cx	EQUS	"wTemp1024+01"
menu7_cy	EQUS	"wTemp1024+02"
menu7_cp	EQUS	"wTemp1024+03"
menu7_first	EQUS	"wTemp1024+04"
menu7_list	EQUS	"wTemp1024+05"

GROUP_CURSOR	EQU	1
GROUP_CURSOR2	EQU	2

menu7maplist:
		db	21
		dw	IDX_CONFIRMRGB
		dw	IDX_CONFIRMMAP
		db	21
		dw	IDX_CONFIRMRGB
		dw	IDX_GCONFIRMMAP
		db	21
		dw	IDX_CONFIRMRGB
		dw	IDX_FCONFIRMMAP
		db	21
		dw	IDX_CONFIRMRGB
		dw	IDX_ICONFIRMMAP
		db	21
		dw	IDX_CONFIRMRGB
		dw	IDX_SCONFIRMMAP

Menu7::

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
		push	de
		add	a
		add	a
		add	e
		ld	e,a
		ld	hl,menu7maplist
		add	hl,de
		call	NewLoadMap
		ld	hl,IDX_CONFIRMBITSMAP
		pop	de
		add	hl,de
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,1
		ld	[menu7_list],a

		call	menu7showrows

		ld	a,1
		ld	[menu7_first],a


menu7outer:	call	menu7movecursor
menu7loop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	menu7cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu7_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu7_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,.doit
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.leftright
		bit	JOY_B,a
		jr	nz,menu7back
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.leftright
		bit	JOY_A,a
		jr	nz,.doit
		jr	menu7loop

.updown:	jr	menu7outer

.leftright:
		ld	a,[menu7_row]
		ld	e,a
		ld	d,0
		ld	hl,menu7rowlengths
		add	hl,de
		ld	b,[hl]
		ld	hl,menu7_list
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
		ld	hl,menu7rowstarts
		add	hl,de
		add	[hl]
		pop	bc
		push	af
		ld	a,b
		add	[hl]
		call	menu7off
		pop	af
		call	menu7on
		call	fxmove
		jp	menu7outer
.doit:		ld	a,[menu7_list]
		or	a
		jr	z,menu7forward
		jr	menu7back

menu7showrows:
		ld	a,[menu7_list]
		jp	menu7on

menu7forward:	call	fxsel
		call	menu7shutdown
		ld	a,1
		ret
menu7back:	call	fxback
		call	menu7shutdown
		ld	a,0
		ret

menu7shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank


menu7on:	ld	hl,menu7onlist
		jr	menu7onoff
menu7off:	ld	hl,menu7offlist
menu7onoff:	push	af
		ld	a,[menu7_row]
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
.positions:	db	64,90,5,5


menu7onlist:	dw	menu7ons
		dw	menu7gons
		dw	menu7fons
		dw	menu7ions
		dw	menu7sons

menu7offlist:	dw	menu7offs
		dw	menu7goffs
		dw	menu7foffs
		dw	menu7ioffs
		dw	menu7soffs


menu7ons:	db	5,3,0,0,13,3
		db	4,2,0,3,13,7
menu7offs:	db	5,3,5,0,13,3
		db	4,2,4,3,13,7

menu7gons:	db	4,3,0,0,14,3
		db	6,3,0,3,13,7
menu7goffs:	db	4,3,4,0,14,3
		db	6,3,6,3,13,7

menu7fons:	db	5,3,0,0,13,3
		db	5,3,0,3,13,7
menu7foffs:	db	5,3,5,0,13,3
		db	5,3,5,3,13,7

menu7ions:	db	4,3,0,0,14,3
		db	4,3,0,3,14,7
menu7ioffs:	db	4,3,4,0,14,3
		db	4,3,4,3,14,7

menu7sons:	db	4,3,0,0,14,3
		db	4,3,0,3,14,7
menu7soffs:	db	4,3,4,0,14,3
		db	4,3,4,3,14,7

menu7rowlengths: db	2

menu7rowstarts:	db	0

menu7movecursor: ld	a,[menu7_row]
		ld	c,a
		ld	b,0
		ld	hl,menu7rowstarts
		add	hl,bc
		ld	a,[hl]
		ld	hl,menu7_list
		add	hl,bc
		add	[hl]
		add	a
		ld	c,a
		ld	hl,menu7curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu7_cx],a
		ld	a,[hl]
		ld	[menu7_cy],a
		ret


menu7curslist:	db	150,40
		db	150,70
menu7cursor:	ld	a,[menu7_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu7_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu7_cx]
		ld	d,a
		ld	a,[menu7_cy]
		ld	e,a
		ld	a,GROUP_CURSOR2+$80
		jp	AddFigure
		


;***********************************************************************
;***********************************************************************

