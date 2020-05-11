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
		INTERFACE Fire

		SECTION	03

LINEX		EQU	5
LINEY		EQU	5
SPACEY		EQU	15

LETTERX		EQU	15
LETTERY		EQU	90
LETTERXSPACE	EQU	15
LETTERYSPACE	EQU	14


GROUP_CURSOR	EQU	0
GROUP_BUBBLE	EQU	1

CXFIX		EQU	-12
CYFIX		EQU	8

CXFIX2		EQU	-1
CYFIX2		EQU	-1

eh_name		EQUS	"wTemp1024+00" ;10 bytes
eh_cp		EQUS	"wTemp1024+10"
eh_cx		EQUS	"wTemp1024+11"
eh_cy		EQUS	"wTemp1024+12"
eh_cat		EQUS	"wTemp1024+13"
eh_lc		EQUS	"wTemp1024+14"
eh_done		EQUS	"wTemp1024+15"
eh_k6		EQUS	"wTemp1024+16"
eh_colorsave	EQUS	"wTemp1024+32"

AREA3X		EQU	5
AREA3Y		EQU	4
AREA3XSIZE	EQU	10
AREA3YSIZE	EQU	3
L3X		EQU	14

clear3:
 ld de,IDX_ENTERPKG
 jp XferBitmap

;		ld	a,AREA3Y*8
;		ldh	[hSprYLo],a
;		ld	a,AREA3X*8
;		ldh	[hSprXLo],a
;		ld	a,AREA3XSIZE*8
;		ld	[wStringW],a
;		ld	a,AREA3YSIZE*8
;		ld	[wStringH],a
;		jp	ClrRect18_b


;a=player #
EnterHigh::
		push	af
		call	Fire_b

;		ld	a,SONG_HIGHSCORE
;		call	InitTune

		ld	hl,wTemp1024
		ld	bc,1024
		call	MemClear
;		call	BuildMessageList

		call	InitGroups
		ld	hl,PAL_ARROW
		call	AddPalette
		ld	hl,PAL_BUBBLE
		call	AddPalette

		xor	a
		call	ehnewpos
		call	picklite

		call	SetBitmap20x18

		call	ehshow3

		ld	de,MSGPLAYER1
		pop	af
		add	e
		ld	e,a
		ld	a,0
		adc	d
		ld	d,a
		call	FetchMessage
		ld	hl,wMessage
		ld	a,70
		ld	[hli],a
		ld	a,78
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hl],a
		ld	hl,wMessage
		call	DrawStringLst

		ld	bc,0
.drawletters:	ld	hl,ehpositions
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	e,[hl]
		ld	hl,ehmap
		add	hl,bc
		ld	d,[hl]
		ld	hl,wMessage
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hli],a
		push	bc
		ld	a,c
		cp	27
		jr	nz,.notexit
.h:		ld	de,MSGEXIT
		call	GetString
		ld	hl,wString
		ld	de,wMessage+4
.zcpy:		ld	a,[hli]
		ld	[de],a
		inc	de
		or	a
		jr	nz,.zcpy
		ld	[de],a
.notexit:	ld	hl,wMessage
		call	DrawStringLst
		pop	bc
		inc	c
		ld	a,c
		cp	28
		jr	c,.drawletters

		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	elang

		call	FadeInBlack

.loop:		call	WaitForVBL
		call	ReadJoypad
		call	ProcAutoRepeat
		call	InitFigures
		call	ehcursor
		call	OutFigures

		call	ehprocess
		ld	a,[eh_done]
		or	a
		jr	z,.loop
		jp	ehdone

ehprocess:
		ld	a,[eh_cat]
		ld	c,a
		ld	b,0
		ld	a,[wJoy1Hit]
		ld	hl,.righttab
		bit	JOY_R,a
		jr	nz,.move
		ld	hl,.lefttab
		bit	JOY_L,a
		jr	nz,.move
		ld	hl,.downtab
		bit	JOY_D,a
		jr	nz,.move
		ld	hl,.uptab
		bit	JOY_U,a
		jr	nz,.move
		bit	JOY_A,a
		jp	nz,.pick
		bit	JOY_B,a
		jp	nz,.rub
		ret
.move:		add	hl,bc
		ld	a,[hl]
		call	ehnewpos
		jp	fxmove
.lefttab:	db	09,00,01,02,03,04,05,06,07,08
		db	19,10,11,12,13,14,15,16,17,18
		db	25,20,21,22,23,24,27,26
.righttab:	db	01,02,03,04,05,06,07,08,09,00
		db	11,12,13,14,15,16,17,18,19,10
		db	21,22,23,24,25,20,27,26
.uptab:		db	26,26,26,26,26,27,27,27,27,27
		db	00,01,02,03,04,05,06,07,08,09
		db	12,13,14,15,16,17,21,24
.downtab:	db	10,11,12,13,14,15,16,17,18,19
		db	20,20,20,21,22,23,24,25,25,25
		db	26,26,26,27,27,27,03,06
.pick:		ld	a,c
		cp	26
		jr	c,.letter
		jr	z,.rub
		ld	a,1
		ld	[eh_done],a
		ret
.k6:		ld	a,[eh_k6]
		ld	c,a
		ld	b,0
		ld	hl,k6match
		add	hl,bc
		ld	a,[eh_cat]
		add	"A"
		xor	$DA
		cp	[hl]
		jr	z,.good
		call	fxillegal
		xor	a
		ld	[eh_k6],a
		ret
.good:		call	fxsel
		ld	hl,eh_k6
		inc	[hl]
		ld	a,[hl]
		cp	10
		ret	c
		ld	[hl],0
		ld	a,1
		ld	[eh_done],a
		jp	showfam
.letter:	ld	a,[eh_lc]
		cp	3
		jp	nc,.k6
		ld	e,a
		inc	a
		ld	[eh_lc],a
		ld	d,b
		ld	hl,ehmap
		add	hl,bc
		ld	a,[hl]e
		ld	hl,eh_name
		add	hl,de
		ld	[hl],a
		call	fxsel
		call	ehshow3
		call	ehcopy3
		ld	a,[eh_lc]
		cp	3
		ld	a,27
		jp	z,ehnewpos
		ret
.rub:		ld	a,[eh_lc]
		or	a
		jp	z,fxillegal
		dec	a
		ld	[eh_lc],a
		ld	c,a
		ld	b,0
		ld	hl,eh_name
		add	hl,bc
		ld	[hl],0
		call	fxback
		call	ehshow3
		jp	ehcopy3

ehdone:		call	fxsel
		call	FadeOutBlack
		jp	sprblank

ehnewpos:	ld	[eh_cat],a
		ld	c,a
		ld	hl,ehpositions
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	[eh_cx],a
		ld	a,[hl]
		ld	[eh_cy],a
		ret

ehpositions:
		db	LETTERX+LETTERXSPACE*0
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*1
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*2
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*3
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*4
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*5
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*6
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*7
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*8
		db	LETTERY+LETTERYSPACE*0
		db	LETTERX+LETTERXSPACE*9
		db	LETTERY+LETTERYSPACE*0

		db	LETTERX+LETTERXSPACE*0
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*1
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*2
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*3
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*4
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*5
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*6
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*7
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*8
		db	LETTERY+LETTERYSPACE*1
		db	LETTERX+LETTERXSPACE*9
		db	LETTERY+LETTERYSPACE*1

		db	LETTERX+LETTERXSPACE*2
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*3
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*4
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*5
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*6
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*7
		db	LETTERY+LETTERYSPACE*2
		db	LETTERX+LETTERXSPACE*3
		db	LETTERY+LETTERYSPACE*3
		db	LETTERX+LETTERXSPACE*6
		db	LETTERY+LETTERYSPACE*3


ehmap:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		db	$5e,"x"

L3CENTER	EQU	70

ehshow3:
		call	clear3
		ld	hl,underlines
		call	DrawStringLst
		ld	a,[eh_lc]
		or	a
		ret	z
		ld	hl,wMessage
		ld	a,L3CENTER-L3X
		ld	[hli],a
		ld	a,8*AREA3Y+15
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		ld	a,[eh_name]
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	hl,wMessage
		call	DrawStringLst

		ld	a,[eh_lc]
		cp	2
		ret	c
		ld	hl,wMessage+4
		ld	a,[eh_name+1]
		ld	[hl],a
		ld	hl,wMessage
		ld	[hl],L3CENTER
		call	DrawStringLst
		ld	a,[eh_lc]
		cp	3
		ret	c
		ld	hl,wMessage+4
		ld	a,[eh_name+2]
		ld	[hl],a
		ld	hl,wMessage
		ld	[hl],L3CENTER+L3X
		jp	DrawStringLst



k6match:
		db	'A'^$da
		db	'N'^$da
		db	'D'^$da
		db	'Y'^$da
		db	'A'^$da
		db	'S'^$da
		db	'H'^$da
		db	'L'^$da
		db	'E'^$da
		db	'Y'^$da


ehcopy3:	ld	bc,(AREA3X<<8)+AREA3Y
		ld	de,(AREA3XSIZE<<8)+AREA3YSIZE
		jp	DmaBitbox20x18_b

underlines:
		db	L3CENTER-L3X
		db	8*AREA3Y+18
		db	0
		db	1
		db	"_",0

		db	L3CENTER
		db	8*AREA3Y+18
		db	0
		db	1
		db	"_",0

		db	L3CENTER+L3X
		db	8*AREA3Y+18
		db	0
		db	1
		db	"_",0

		db	0

ehcursor:	ld	a,[eh_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[eh_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[eh_cx]
		add	CXFIX
		ld	d,a
		ld	a,[eh_cy]
		add	CYFIX
		ld	e,a
		ld	a,GROUP_CURSOR
		call	AddFigure
		ld	a,[eh_cat]
		cp	27
		ret	nc
		ld	a,[eh_cx]
		add	CXFIX2
		ld	d,a
		ld	a,[eh_cy]
		add	CYFIX2
		ld	e,a
		ld	bc,IDX_BUBBLE+5
		ld	a,GROUP_BUBBLE
		jp	AddFigure

HIGHSIZE	EQU	20
NUMHIGHS	EQU	5

CheckHighs::
		ldh	a,[pin_flags2]
		bit	PINFLG2_QUIT,a
		ret	nz
		ld	de,wStore1
		ld	c,0
		call	checkhigh
		ld	de,wStore2
		ld	c,1
		call	checkhigh
		ld	de,wStore3
		ld	c,2
		call	checkhigh
		ld	de,wStore4
		ld	c,3
checkhigh:	ld	a,[wNumPlayers]
		dec	a
		cp	c
		ret	c
		ld	a,c
		ldh	[hTmpLo],a
		ld	b,0
		ld	hl,bMenus+OPT_SPEEDS
		add	hl,bc
		ld	a,[hl]
		and	1
		ld	c,a
		ld	a,[bMenus+OPT_NUMBALLS]
		and	1
		add	a
		or	c
		ld	c,a
		ld	a,[bMenus+OPT_TABLE]
		and	1
		add	a
		add	a
		or	c
		ld	c,a
		ld	[bHighPage],a
		ld	hl,highstores
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	c,NUMHIGHS
.complp:	push	de
		push	hl
		ld	b,12
.ci:		ld	a,[de]
		cp	[hl]
		jr	c,.next
		jr	nz,.bigger
		inc	de
		inc	hl
		dec	b
		jr	nz,.ci
;		jr	.bigger
.next:		pop	hl
		ld	de,HIGHSIZE
		add	hl,de
		pop	de
		dec	c
		jr	nz,.complp
		pop	hl
		ret
.bigger:	pop	bc
		ld	hl,HIGHSIZE-1
		add	hl,bc
		ld	b,h
		ld	c,l
		pop	de
		pop	hl
		push	de
;hl=high score list
;bc=high score to replace
;tos=high score value to put
		ld	de,(NUMHIGHS-1)*HIGHSIZE-1
		add	hl,de
		push	hl
		ld	de,HIGHSIZE
		add	hl,de
		pop	de
.movelp:	ld	a,c
		cp	l
		jr	nz,.doit
		ld	a,b
		cp	h
		jr	z,.done
.doit:		push	bc
		ld	c,HIGHSIZE
.m2:		ld	a,[de]
		dec	de
		ld	[hld],a
		dec	c
		jr	nz,.m2
		pop	bc
		jr	.movelp
.done:		ld	hl,-(HIGHSIZE-1)
		add	hl,bc
		ld	d,h
		ld	e,l
		pop	hl
		ld	bc,12
		call	MemCopy
		push	de
		ldh	a,[hTmpLo]
		call	EnterHigh
		pop	de
		ld	hl,wTemp1024
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hl]
		ld	[de],a
		ret

showfam:
		call	FadeOutBlack
		ld	a,8
		call	InitTune
		call	SetBitmap20x18
		ld	de,IDX_K6PKG
		call	XferBitmap
		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	FadeInBlack
.wait:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_SELECT,a
		jr	nz,.print
		or	a
		jr	z,.wait
		jp	FadeOutBlack
.print:
		call	fxsel
		ld	a,$ff
		call	PrintSomething
		jr	.wait

highstores:	dw	bHighScores+HIGHSIZE*NUMHIGHS*0
		dw	bHighScores+HIGHSIZE*NUMHIGHS*1
		dw	bHighScores+HIGHSIZE*NUMHIGHS*2
		dw	bHighScores+HIGHSIZE*NUMHIGHS*3
		dw	bHighScores+HIGHSIZE*NUMHIGHS*4
		dw	bHighScores+HIGHSIZE*NUMHIGHS*5
		dw	bHighScores+HIGHSIZE*NUMHIGHS*6
		dw	bHighScores+HIGHSIZE*NUMHIGHS*7

elang:		ld	a,[bLanguage]
		or	a
		ret	z
		ld	hl,wBcpArcade
		ld	de,eh_colorsave
		ld	bc,64
		call	MemCopy
		ld	a,[bLanguage]
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,IDX_GENTERPKG
		add	hl,bc
		ld	d,h
		ld	e,l
		call	XferBitmap
		ld	bc,$0000
		ld	de,$1403
		call	DmaBitbox20x18_b
		ld	de,wBcpArcade
		ld	hl,eh_colorsave
		ld	bc,64
		jp	MemCopy


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
