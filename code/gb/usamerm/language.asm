; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** language.asm                                                          **
; **                                                                       **
; ** Created : 20000530 by David Ashley                                    **
; **   Language selection: english/german/french/italian/spanish           **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 03

		INTERFACE ProcessDirties

lan_first	EQUS	"wTemp1024+00"
lan_row		EQUS	"wTemp1024+01"
lan_cx		EQUS	"wTemp1024+02"
lan_cy		EQUS	"wTemp1024+03"
lan_cp		EQUS	"wTemp1024+04"

GROUP_CURSOR	EQU	1

lanmaplist:
		db	21
		dw	IDX_LANGXRGB
		dw	IDX_LANGXMAP

Language::

		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_ARROW
		call	AddPalette

		ld	a,BANK(Char40)
		ld	[wPinCharBank],a
		ld	hl,lanmaplist
		call	NewLoadMap
		ld	hl,IDX_LANGXBITSMAP
		call	SecondHalf

		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,[bLanguage]
		or	a
		jr	z,.nolang
		dec	a
		ld	e,a
		add	a
		add	e
		ld	e,a
		ld	hl,0
		ld	d,h
		ld	bc,$1403
		call	BGRect
		call	ProcessDirties_b
.nolang:


		ld	a,[bLanguage]
		cp	5
		jr	c,.aok
		xor	a
.aok:		ld	[lan_row],a


		ld	a,1
		ld	[lan_first],a


lanouter:	call	lanmovecursor

lanloop:
		call	WaitForVBL
		call	WaveFX

		call	InitFigures
		call	lancursor
		call	Bubbles
		call	OutFigures

		ld	a,[lan_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[lan_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:

		call	ReadJoypad

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
		bit	JOY_B,a
		jr	nz,.back
		jr	lanloop

.updown:	ld	a,[lan_row]
		add	c
		cp	5
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,4
.aok:		ld	[lan_row],a
		call	fxmove
		jp	lanouter
.done:
		call	fxsel
		call	lanshutdown
		ld	a,[lan_row]
		ld	[bLanguage],a
		xor	$DA
		ld	[bLanguageHash],a
		ret
.back:		ld	a,[bLanguage]
		ld	c,a
		ld	a,[bLanguageHash]
		xor	$da
		cp	c
		jp	nz,lanloop

		call	fxback
		jp	lanshutdown



lanshutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank

CX		EQU	145
CY		EQU	68
CYS		EQU	16

lancurslist:	db	CX,CY+CYS*0
		db 	CX,CY+CYS*1
		db	CX,CY+CYS*2
		db	CX,CY+CYS*3
		db	CX,CY+CYS*4

lanmovecursor:
		ld	a,[lan_row]
		add	a
		ld	c,a
		ld	b,0
		ld	hl,lancurslist
		add	hl,bc
		ld	a,[hli]
		ld	[lan_cx],a
		ld	a,[hl]
		ld	[lan_cy],a
		ret

lancursor:	ld	a,[lan_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[lan_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[lan_cx]
		ld	d,a
		ld	a,[lan_cy]
		ld	e,a
		ld	a,$80+GROUP_CURSOR
		jp	AddFigure


;***********************************************************************
;***********************************************************************

