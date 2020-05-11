; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** enterhigh.asm                                                         **
; **                                                                       **
; ** Created : 20000515 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE	"msg.equ"

		INTERFACE ClrRect18
		INTERFACE DmaBitbox20x18

		SECTION	03

CHOICEX		EQU	35
CHOICEY		EQU	130
CHOICEXSPACE	EQU	45
CHOICEYSPACE	EQU	20

HIGHX		EQU	4
HIGHX2		EQU	32
HIGHY		EQU	30

GROUP_CURSOR	EQU	1

CXFIX		EQU	-9
CYFIX		EQU	8

sh_cp		EQUS	"wTemp1024+00"
sh_cx		EQUS	"wTemp1024+01"
sh_cy		EQUS	"wTemp1024+02"
sh_cat		EQUS	"wTemp1024+03"
sh_done		EQUS	"wTemp1024+04"
sh_sel		EQUS	"wTemp1024+05"
sh_first	EQUS	"wTemp1024+06"
sh_colorsave	EQUS	"wTemp1024+32"

ShowHigh::
		ld	hl,wTemp1024
		ld	bc,1024
		call	MemClear

		ld	a,[bHighPage]
		and	7
		ld	[sh_sel],a

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_ARROW
		call	AddPalette
		ld	hl,PAL_PRNTICON
		call	Palette7
		xor	a
		ld	[wPrinterState],a
		ld	a,$88
		ld	[wWave],a

		ld	a,1
		ld	[sh_first],a

		xor	a
		call	ehnewpos
		call	picklite

		call	SetBitmap20x18
		call	shdraw

		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	hlang
		ld	a,1
		ld	[wPrinterPossible],a

.loop:		call	WaitForVBL
		call	WaveFX
		call	ReadJoypad
		call	ProcAutoRepeat

		call	InitFigures64
		call	PrinterProcess
		call	shcursor
		call	Bubbles
		call	OutFigures

		call	shprocess

		ld	a,[sh_first]
		or	a
		jr	z,.notfirst
		xor	a
		ld	[sh_first],a
		call	WaveOn
		call	FadeInBlack
.notfirst:
		ld	a,[sh_done]
		or	a
		jr	z,.loop
		jp	ehdone


shdraw:		ld	a,[sh_sel]
		add	IDX_HIGHS0PKG&255
		ld	e,a
		ld	a,0
		adc	IDX_HIGHS0PKG>>8
		ld	d,a
		call	XferBitmap
		ld	de,bHighScores
		ld	a,[sh_sel]
		ld	l,a
		ld	h,0
		add	hl,hl
		ld	de,shhighlist
		add	hl,de
		ld	a,[hli]
		ld	e,a
		ld	d,[hl]
		jp	shpage

shhighlist:	dw	bHighScores+100*0
		dw	bHighScores+100*1
		dw	bHighScores+100*2
		dw	bHighScores+100*3
		dw	bHighScores+100*4
		dw	bHighScores+100*5
		dw	bHighScores+100*6
		dw	bHighScores+100*7


;12 bytes of score
;3 bytes of name
;5 bytes padding
;de=high score structure
shpage:		ld	c,0
.lp:		ld	hl,wMessage
		ld	a,HIGHX
		ld	[hli],a
		ld	a,c
		swap	a
		add	HIGHY
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	a,c
		add	"1"
		ld	[hli],a
		ld	a,"."
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hli],a

		push	bc
		push	de
		ld	hl,wMessage
		call	DrawStringLst
		pop	de
		push	de
		call	shscore
		ld	hl,wMessage+3
		ld	a,2
		ld	[hld],a
		dec	hl
		dec	hl
		ld	[hl],160-HIGHX
		call	DrawStringLst
		pop	de
		push	de
		ld	hl,12
		add	hl,de
		ld	d,h
		ld	e,l
		call	sh3letters
		ld	hl,wMessage+3
		ld	a,1
		ld	[hld],a
		dec	hl
		dec	hl
		ld	[hl],HIGHX2
		call	DrawStringLst

		pop	de
		pop	bc
		ld	hl,20
		add	hl,de
		ld	d,h
		ld	e,l
		inc	c
		ld	a,c
		cp	5
		jr	c,.lp
		ret

sh3letters:	ld	hl,wMessage+4
		call	sh1letter
		jr	z,.done
		call	sh1letter
		jr	z,.done
		call	sh1letter
.done:		xor	a
		ld	[hli],a
		ld	[hl],a
		ret
sh1letter:	ld	a,[de]
		inc	de
		or	a
		ret	z
		cp	"A"
		jr	c,.bad
		cp	"Z"+1
		jr	nc,.bad
		ld	[hli],a
		ret
.bad:		xor	a
		ret



;de=12 bytes of score
shscore:	ld	hl,wMessage+4
		ld	b,","
		ld	c,"0"
		call	sh3
		call	shcomma
		call	shcomma
		call	shcomma
		xor	a
		ld	[hl],a
		ld	hl,wMessage+4
		ld	d,14
.fnz:		ld	a,[hl]
		cp	b
		jr	z,.skip
		cp	c
		jr	nz,.done
.skip:		inc	hl
		dec	d
		jr	nz,.fnz
.done:		ld	de,wMessage+4
.cz:		ld	a,[hli]
		ld	[de],a
		inc	de
		or	a
		jr	nz,.cz
		ld	[de],a
		ret
shcomma:	ld	a,b
		ld	[hli],a
sh3:		call	sh1
		call	sh1
sh1:		ld	a,[de]
		cp	10
		jr	c,.aok
		xor	a
		ld	[de],a
.aok:		inc	de
		add	c
		ld	[hli],a
		ret

shprocess:	ld	a,[sh_cat]
		ld	c,a
		ld	b,0
		ld	a,[wJoy1Hit]
		ld	e,1
		bit	JOY_R,a
		jr	nz,.move
		ld	e,-1
		bit	JOY_L,a
		jr	nz,.move
		bit	JOY_A,a
		jr	nz,.change
		bit	JOY_START,a
		jr	nz,.change
		bit	JOY_B,a
		jr	nz,.done	
		bit	JOY_SELECT,a
		jr	nz,.print
		ret
.print:
	IF	PRINTER
 xor	a
 ld	[wPrinterState],a
		call	fxsel
		xor	a
		call	PrintSomething
	ENDC
		ret
.move:		ld	a,c
		add	e
		cp	3
		jr	c,.fine
		ld	a,0
		jr	z,.fine
		ld	a,2
.fine:		ld	[sh_cat],a
		call	ehnewpos
		jp	fxmove
.change:
 xor	a
 ld	[wPrinterState],a
		ld	a,c
		or	a
		ld	b,4
		jr	z,.bok
		dec	a
		ld	b,2
		jr	z,.bok
		ld	b,1
.bok:		ld	a,[sh_sel]
		xor	b
		and	7
		ld	[sh_sel],a
		call	fxsel
		call	FadeOutBlack
		call	shdraw
		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	hlang
		jp	FadeInBlack
.done:		ld	a,1
		ld	[sh_done],a
		ret

ehdone:
		call	fxback
		ld	a,[sh_sel]
		ld	[bHighPage],a
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank

ehnewpos:	ld	[sh_cat],a
		ld	c,a
		ld	hl,ehpositions
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	[sh_cx],a
		ld	a,[hl]
		ld	[sh_cy],a
		ret

ehpositions:
		db	CHOICEX+CHOICEXSPACE*0
		db	CHOICEY+CHOICEYSPACE*0
		db	CHOICEX+CHOICEXSPACE*1
		db	CHOICEY+CHOICEYSPACE*0
		db	CHOICEX+CHOICEXSPACE*2
		db	CHOICEY+CHOICEYSPACE*0


shcursor:	ld	a,[sh_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[sh_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[sh_cx]
		add	CXFIX
		ld	d,a
		ld	a,[sh_cy]
		add	CYFIX
		ld	e,a
		ld	a,GROUP_CURSOR
		jp	AddFigure

hlang:		ld	a,[bLanguage]
		or	a
		ret	z
		ld	hl,wBcpArcade
		ld	de,sh_colorsave
		ld	bc,64
		call	MemCopy
		ld	a,[bLanguage]
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,IDX_GRECORDSPKG
		add	hl,bc
		ld	d,h
		ld	e,l
		call	XferBitmap
		ld	bc,$0000
		ld	de,$1403
		call	DmaBitbox20x18_b
		ld	de,wBcpArcade
		ld	hl,sh_colorsave
		ld	bc,64
		jp	MemCopy


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
