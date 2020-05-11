; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu3.asm                                                             **
; **                                                                       **
; ** Created : 20000516 by David Ashley                                    **
; **   Main menu: start/practice/records/options                           **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

		INTERFACE ProcessDirties

menu3_first	EQUS	"wTemp1024+00"
menu3_row	EQUS	"wMainSelected"
menu3_cx	EQUS	"wTemp1024+01"
menu3_cy	EQUS	"wTemp1024+02"
menu3_cp	EQUS	"wTemp1024+03"
menu3_inact	EQUS	"wTemp1024+04" ;2 bytes

GROUP_BUBBLE	EQU	0
GROUP_CURSOR	EQU	1

menu3maplist:
		db	21
		dw	IDX_MAINXRGB
		dw	IDX_MAINXMAP
		db	21
		dw	IDX_MAINXRGB
		dw	IDX_GMAINXMAP
		db	21
		dw	IDX_MAINXRGB
		dw	IDX_FMAINXMAP
		db	21
		dw	IDX_MAINXRGB
		dw	IDX_IMAINXMAP
		db	21
		dw	IDX_MAINXRGB
		dw	IDX_SMAINXMAP

Menu3::
;		xor	a
;		ld	[menu3_row],a

menu3re:	ld	a,[menu3_row]
		and	3
		push	af
		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		pop	af
		ld	[menu3_row],a

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_ARROW
		call	AddPalette

		ld	a,BANK(Char40)
		ld	[wPinCharBank],a
		ld	hl,menu3maplist
		ld	a,[bLanguage]
		ld	d,0
		ld	e,a
		push	de
		add	a
		add	a
		add	e
		ld	e,a
		ld	d,0
		add	hl,de
		call	NewLoadMap
		pop	de
;		ld	hl,IDX_MAINBITSMAP
;		add	hl,de
;		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

;		call	menu3on


;		xor	a
;		call	menu3on
;		ld	a,1
;		call	menu3on
;		ld	a,2
;		call	menu3on
;		ld	a,3
;		call	menu3on


		ld	a,1
		ld	[menu3_first],a


menu3outer:	call	menu3movecursor

menu3loop:
		ld	hl,menu3_inact
		inc	[hl]
		jr	nz,.no2
		inc	hl
		inc	[hl]
		ld	a,[hl]
		cp	4
		jr	c,.no2
		jp	menu3demo
.no2:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	menu3cursor
		call	Bubbles
		call	OutFigures

		ld	a,[menu3_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu3_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad
		ld	a,[wJoy1Cur]
		or	a
		jr	z,.noclr
		xor	a
		ld	[menu3_inact],a
		ld	[menu3_inact+1],a
.noclr:
		ld	a,[wJoy1Hit]
		ld	c,-1
		bit	JOY_U,a
		jr	nz,.updown
		ld	c,1
		bit	JOY_D,a
		jr	nz,.updown
		bit	JOY_START,a
		jr	nz,.done
		bit	JOY_A,a
		jr	nz,.done
		jr	menu3loop

.updown:	ld	a,[menu3_row]
		push	af
		add	c
		and	3
		ld	[menu3_row],a
;		call	menu3on
		pop	af
;		call	menu3off
		call	fxmove
		jp	menu3outer
.done:
		call	fxsel
		call	menu3shutdown
		ld	a,[menu3_row]
		ret

menu3demo:	call	menu3shutdown
		ld	a,[menu3_row]
		push	af
		call	DemoMode
		call	menutune
		pop	af
		jp	menu3re

menu3shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank


menu3on:	ld	hl,menu3onlist
		jr	menu3onoff
menu3off:	ld	hl,menu3offlist
menu3onoff:	push	af
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
.positions:	db	64,64,5,5

menu3ons:	db	14,3,0,0,3,2
		db	20,3,0,6,0,6
		db	19,3,0,12,1,10
		db	18,3,0,18,1,14
menu3offs:	db	14,3,0,3,3,2
		db	20,3,0,9,0,6
		db	19,3,0,15,1,10
		db	18,3,0,21,1,14

menu3gons:	db	14,3,0,0,3,2
		db	19,3,0,6,1,6
		db	19,3,0,12,1,10
		db	20,3,0,18,0,14
menu3goffs:	db	14,3,0,3,3,2
		db	19,3,0,9,1,6
		db	19,3,0,15,1,10
		db	20,3,0,21,0,14

menu3fons:	db	9,4,0,0,6,1
		db	17,3,0,8,2,6
		db	20,3,0,14,0,10
		db	10,3,0,20,5,14
menu3foffs:	db	9,4,0,4,6,1
		db	17,3,0,11,2,6
		db	20,3,0,17,0,10
		db	10,3,0,23,5,14

menu3ions:	db	8,2,0,0,6,2
		db	20,3,0,4,0,6
		db	12,2,0,10,4,10
		db	11,3,0,14,5,14
menu3ioffs:	db	8,2,0,2,6,2
		db	20,3,0,7,0,6
		db	12,2,0,12,4,10
		db	11,3,0,17,5,14

menu3sons:	db	20,3,0,0,0,2
		db	20,4,0,6,0,5
		db	19,4,0,14,1,9
		db	20,3,0,22,0,14
menu3soffs:	db	20,3,0,3,0,2
		db	20,4,0,10,0,5
		db	19,4,0,18,1,9
		db	20,3,0,25,0,14


menu3onlist:	dw	menu3ons
		dw	menu3gons
		dw	menu3fons
		dw	menu3ions
		dw	menu3sons

menu3offlist:	dw	menu3offs
		dw	menu3goffs
		dw	menu3foffs
		dw	menu3ioffs
		dw	menu3soffs






CY		EQU	86
SPY		EQU	16
menu3curslist:
		db	92,CY
		db	54,CY+SPY*1
		db	50,CY+SPY*2
		db	80,CY+SPY*3

;CY		EQU	3
;		db	20,35+CY
;		db 	20,66+CY
;		db	20,100+CY
;		db	20,130+CY



menu3movecursor:
		ld	a,[menu3_row]
		and	3
		add	a
		ld	c,a
		ld	b,0
		ld	hl,menu3curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu3_cx],a
		ld	a,[hl]
		ld	[menu3_cy],a
		ret

menu3cursor:	ld	a,[menu3_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu3_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu3_cx]
		ld	d,a
		ld	a,[menu3_cy]
		ld	e,a
		ld	a,GROUP_CURSOR
;		jp	AddFigure
		push	bc
		push	de
;		call	AddFigure
		pop	de
		pop	bc
;		ld	a,160
;		sub	d
;		ld	d,a
	ld	d,152
		ld	a,$80+GROUP_CURSOR
		jp	AddFigure



;***********************************************************************
;***********************************************************************

