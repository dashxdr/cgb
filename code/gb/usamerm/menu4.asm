; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu4.asm                                                             **
; **                                                                       **
; ** Created : 20000503 by David Ashley                                    **
; **  Table selection                                                      **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 03

		INTERFACE ProcessDirties

menu4_row	EQUS	"wTemp1024+00"
menu4_cx	EQUS	"wTemp1024+01"
menu4_cy	EQUS	"wTemp1024+02"
menu4_cp	EQUS	"wTemp1024+03"
menu4_first	EQUS	"wTemp1024+04"


menu4_list	EQUS	"bMenus+OPT_TABLE"

GROUP_CURSOR	EQU	1
GROUP_CURSOR2	EQU	2

menu4maplist:
		db	21
		dw	IDX_TABLESRGB
		dw	IDX_TABLESMAP

Menu4::
		call	menu4maxes

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
		ld	hl,menu4maplist
		call	NewLoadMap
		ld	hl,IDX_TABLEBITSMAP
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		call	menu4showrows

		ld	a,[bLanguage]
		or	a
		jr	z,.fine
		dec	a
		ld	e,a
		add	a
		add	e
		add	30
		ld	e,a
		ld	d,0
		ld	bc,$1403
		ld	hl,0
		call	BGRect
		call	ProcessDirties_b
.fine:

		ld	a,1
		ld	[menu4_first],a


menu4outer:	call	menu4movecursor
menu4loop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	menu4cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu4_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu4_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menu4forward
		bit	JOY_A,a
		jp	nz,menu4forward
		bit	JOY_B,a
		jr	nz,menu4back
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		jr	menu4loop

.updown:	jr	menu4outer
.leftright:
		ld	a,[menu4_list]
		call	menu4off
		ld	a,[menu4_list]
		xor	1
		ld	[menu4_list],a
		call	menu4on
		call	fxmove
		jp	menu4outer

menu4showrows:
		ld	a,[menu4_list]
		jp	menu4on

menu4forward:	call	fxsel
		call	menu4shutdown
		xor	a
		ret
menu4back:	call	fxback
		call	menu4shutdown
		ld	a,1
		ret

menu4shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank


menu4on:	ld	hl,menu4ons
		jr	menu4onoff
menu4off:	ld	hl,menu4offs
menu4onoff:	add	a
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
.wipe:		push	bc
		push	de
		push	hl
		ld	a,c
		cp	WIPE
		jr	c,.aok
		ld	a,WIPE
.aok:		ld	c,a
		push	bc
		ld	a,h
		inc	a
		add	a
		add	a
		add	a
		ld	b,a
.wait:		ldio	a,[rLY]
		cp	b
		jr	c,.wait
		pop	bc
		push	bc
		call	BGRect
		call	ProcessDirties_b
		pop	bc
		pop	hl
		pop	de
		ld	a,e
		add	c
		ld	e,a
		ld	a,l
		add	c
		ld	l,a
		ld	a,c
		cpl
		inc	a
		pop	bc
		add	c
		ld	c,a
		jr	nz,.wipe
		ret
.positions:	db	100
WIPE		EQU	4

menu4ons:	db	8,15,0,0,2,3
		db	7,15,0,15,10,3

menu4offs:	db	8,15,8,0,2,3
		db	7,15,8,15,10,3


menu4movecursor:
		ld	a,[menu4_list]
		add	a
		ld	c,a
		ld	b,0
		ld	hl,menu4curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu4_cx],a
		ld	a,[hl]
		ld	[menu4_cy],a
		ret


menu4curslist:	db	38,140
		db	100,140
menu4cursor:	ld	a,[menu4_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu4_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu4_cx]
		ld	d,a
		ld	a,[menu4_cy]
		ld	e,a
		ld	a,GROUP_CURSOR2
		jp	AddFigure


menu4maxes:	ld	hl,menu4_list
		ld	a,[hl]
		and	1
		ld	[hl],a
		ret
		


;***********************************************************************
;***********************************************************************

