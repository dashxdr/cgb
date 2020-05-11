; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** TREASURE.ASM                                                          **
; **                                                                       **
; ** Created : 20000329 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	11


MAXTREASURES	EQU	6
TREASURESIZE	EQU	6
TRESJERKTIME	EQU	10
MAXFURY		EQU	4
FURYRED		EQU	3
TRESFURYDEC	EQU	180


GROUP_BROWN	EQU	2
GROUP_PINK	EQU	3
GROUP_RED	EQU	4
GROUP_SHARK	EQU	5

tres_hits	EQUS	"wTemp1024+00" ;3 bytes
tres_closes	EQUS	"wTemp1024+03" ;3 bytes
tres_sharkx	EQUS	"wTemp1024+06"
tres_sharkdx	EQUS	"wTemp1024+07"
tres_sharkframe	EQUS	"wTemp1024+08"
tres_sharkflip	EQUS	"wTemp1024+09"
tres_sharkdet	EQUS	"wTemp1024+10"
tres_sharkend	EQUS	"wTemp1024+11"

tres_treas	EQUS	"wTemp1024+16"	;TREASURESIZE*MAXTREASURES

tresinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(tresprocess)	;wPinJmpProcess
		dw	tresprocess
		db	BANK(tressprites)	;wPinJmpSprites
		dw	tressprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(treshit)		;wPinJmpHitBumper
		dw	treshit
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(Nothing)		;wPinJmpLost
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUBDET001CHG	;lsubflippers
		dw	IDX_SUBDET009CHG	;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

tresmaplist:	db	21
		dw	IDX_CHSTBACKRGB
		dw	IDX_CHSTBACKMAP

TresInit::
		ld	hl,tresinfo
		call	SetPinInfo

		ld	a,(SHARKMINX+SHARKMAXX)/2
		ld	[tres_sharkx],a
		ld	a,-1
		ld	[tres_sharkdx],a

		ld	a,$ff
		ld	[tres_sharkdet],a

		ld	a,TIME_TREASURE
		call	SetTime

		ld	a,NEED_TREASURE
		call	SetCount2

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_BRWNTRES
		call	AddPalette
		ld	hl,PAL_PINKTRES
		call	AddPalette
		ld	hl,PAL_REDTRES
		call	AddPalette
		ld	hl,PAL_TRSHARK
		call	AddPalette

		ld	a,6
		ldh	[pin_textpal],a

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap
		ld	hl,IDX_DETCHSTCHG
		call	MakeChanges

		ld	hl,tresmaplist
		call	NewLoadMap
		ld	hl,IDX_CHESTSMAP
		call	SecondHalf

 call	SubAddBall

		ld	hl,trescollisions
		jp	MakeCollisions


tresprocess:
		ld	a,[tres_sharkend]
		or	a
		call	z,SubEnd
		call	AnyDecTime
		call	trescloses
		call	sharkcoll




		ld	hl,tres_sharkend
		ld	a,[hl]
		or	a
		jr	z,.tryend
		dec	[hl]
		jr	nz,.noend
		call	AnyEnd
		ld	[hl],50
		jr	.noend
.tryend:	ld	hl,tres_hits
		ld	a,MAXHITS
		cp	[hl]
		jr	nz,.noend
		inc	hl
		cp	[hl]
		jr	nz,.noend
		inc	hl
		cp	[hl]
		jr	nz,.noend
		ld	a,90
		ld	[tres_sharkend],a
.noend:


		ret


MAXHITS		EQU	5
treshit:

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	50
		ld	a,FX_TREASSHARK
		jp	nc,InitSfx

		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ld	c,0
		cp	67
		jr	c,.cok
		inc	c
		cp	111
		jr	c,.cok
		inc	c
.cok:		
		ld	b,0
		ld	hl,tres_hits
		add	hl,bc
		ld	a,[hl]
		cp	MAXHITS
		jr	z,.donehitnoise
		call	Credit2
		inc	[hl]
		cp	MAXHITS-1
		jr	nz,.shortopen
		call	AnyDec2
		call	Credit1
		ld	hl,tres_closes
		add	hl,bc
		ld	[hl],0

		push	bc
		ld	a,c
		call	tresopen
		ld	a,FX_TREASOPEN
		call	InitSfx
		pop	bc
		ld	hl,tresx
		add	hl,bc
		ld	a,[hl]
		push	af
		call	newtreasure
		pop	af
		add	16
		push	af
		call	newtreasure
		pop	af
		add	16
		call	newtreasure
		jr	.donehit
.shortopen:	ld	hl,tres_closes
		add	hl,bc
		ld	a,[hl]
		ld	[hl],20
		or	a
		ld	a,c
		call	z,tresjar
.donehitnoise:	ld	a,FX_TREASHIT
		jp	InitSfx
.donehit:	ret


tresx:		db	22,64,112


tressprites:
		call	SubFlippers
		call	trestreasures
		call	tresshark
		ret


tresball:	ld	hl,wBalls+BALL_FLAGS
		ld	de,BALLSIZE
		ld	bc,MAXBALLS
.countballs:	bit	BALLFLG_USED,[hl]
		jr	z,.noincb
		inc	b
.noincb:	add	hl,de
		dec	c
		jr	nz,.countballs
		ld	a,b
		cp	2
		ret	nc
;		ld	a,[tres_x]
		inc	a
		ld	d,a
		ld	e,0
		ld	bc,40<<5
		ld	hl,0
		jp	AddBall

;a=#
tresopen:	or	a
		jr	z,.open0
		dec	a
		jr	z,.open1
.open2:		ld	bc,$0305
		ld	de,$1100
		ld	hl,$0f01
		jp	BGRect
.open0:		ld	bc,$0305
		ld	de,$0300
		ld	hl,$0401
		jp	BGRect
.open1:		ld	bc,$0405
		ld	de,$0a00
		ld	hl,$0901
		jp	BGRect

trescloses:	ld	a,[tres_closes]
		or	a
		jr	z,.noclose0
		dec	a
		ld	[tres_closes],a
		jr	nz,.noclose0
		ld	bc,$0305
		ld	de,$0000
		ld	hl,$0401
		call	BGRect
.noclose0:	ld	a,[tres_closes+1]
		or	a
		jr	z,.noclose1
		dec	a
		ld	[tres_closes+1],a
		jr	nz,.noclose1
		ld	bc,$0405
		ld	de,$0600
		ld	hl,$0901
		call	BGRect
.noclose1:	ld	a,[tres_closes+2]
		or	a
		jr	z,.noclose2
		dec	a
		ld	[tres_closes+2],a
		jr	nz,.noclose2
		ld	bc,$0305
		ld	de,$0e00
		ld	hl,$0f01
		call	BGRect
.noclose2:	ret

tresjar:	or	a
		jr	z,.jar0
		dec	a
		jr	z,.jar1
.jar2:		ld	bc,$0305
		ld	de,$0705
		ld	hl,$0f01
		jp	BGRect
.jar0:		ld	bc,$0305
		ld	de,$0005
		ld	hl,$0401
		jp	BGRect
.jar1:		ld	bc,$0405
		ld	de,$0305
		ld	hl,$0901
		jp	BGRect



sharkdet:
		db	0,0,0,0,1,1,1,1,2,2
		db	2,2,3,3,3,3,4,4,4,5
		db	5,5,5,6,6,6,6,7,7,7
		db	7,8,8,8,9,9,9,9,10,10
		db	10,10,11,11,11,11,12,12,12,12
		db	13,13,13,14,14,14,14,15,15,15
		db	15,16,16,16,16,17,17,17,18,18
		db	18,18,19,19,19,19,20,20,20,20
		db	21,21,21,21,22,22,22,23,23,23
		db	23,24,24,24,24,25,25,25,25,26
		db	26

sharkcoll:	ld	a,[tres_sharkx]
		sub	SHARKMINX
		ld	c,a
		ld	b,0
		ld	hl,sharkdet
		add	hl,bc
		ld	a,[tres_sharkdet]
		cp	[hl]
		ret	z
		ld	c,a
		ld	a,[hl]
		ld	[tres_sharkdet],a
		ld	hl,IDX_SHRK001CHG
		add	hl,bc
		inc	c
		ld	c,a
		push	bc
		call	nz,UndoChanges
		pop	bc
		ld	hl,IDX_SHRK001CHG
		add	hl,bc
		jp	MakeChanges

sharkmap:	db	1,2,3,0,5,6,0

SHARKMINX	EQU	30
SHARKMAXX	EQU	160-SHARKMINX
SHARKY		EQU	62


tresshark:
		ld	a,[tres_sharkflip]
		push	af
		ld	a,[tres_sharkframe]
		ld	c,a
		ld	b,0
		ld	a,[wTime]
		and	3
		jr	nz,.noinvert
		ld	hl,sharkmap
		add	hl,bc
		ld	a,[hl]
		ld	[tres_sharkframe],a
		ld	a,c
		cp	6
		jr	nz,.noinvert
		ld	a,[tres_sharkflip]
		xor	$80
		ld	[tres_sharkflip],a
.noinvert:
		ld	hl,IDX_TRSHARK
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[tres_sharkdx]
		ld	l,a
		ld	a,[tres_sharkx]
		add	l
		ld	[tres_sharkx],a
		ld	d,a
		cp	SHARKMINX
		jr	z,.invertdx
		cp	SHARKMAXX
		jr	nz,.noinvertdx
.invertdx:	ld	a,[tres_sharkdx]
		cpl
		inc	a
		ld	[tres_sharkdx],a
		ld	a,4
		ld	[tres_sharkframe],a
.noinvertdx:	ld	e,SHARKY
		pop	af
		add	GROUP_SHARK
		jp	AddFigure


TRESY	EQU	64
trestreasures:
		ld	hl,tres_treas
		ld	e,MAXTREASURES
		ld	a,[wTime]
		srl	a
		srl	a
		srl	a
		and	3
		ld	d,a
.stlp:		ld	a,[hli]
		ld	c,a
		or	[hl]
		jr	z,.next2
		ld	a,[hli]
		ld	b,a
		ld	a,c
		add	d
		ld	c,a
		jr	nc,.noincb
		inc	b
.noincb:	push	de
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hl]
		cp	e
		jr	nc,.noinc
		inc	a
		ld	[hl],a
.noinc:		ld	e,a
		cp	150
		jr	c,.nodestroy
		dec	hl
		dec	hl
		dec	hl
		dec	hl
		xor	a
		ld	[hli],a
		ld	[hli],a
		inc	hl
		inc	hl
.nodestroy:	inc	hl
		ld	a,[hli]
		push	hl
		call	AddFigure
		pop	hl
		pop	de
		jr	.next
.next2:		ld	bc,TREASURESIZE-1
		add	hl,bc
.next:		dec	e
		jr	nz,.stlp
		ret

;treasure structure:
;2 bytes ID (or 0000 if not used)
;1 byte x
;1 byte y desired value
;1 byte y
;1 byte group


;a=x
newtreasure:
		ldh	[hTmpLo],a
		ld	hl,tres_treas
		ld	de,TREASURESIZE-1
		ld	c,MAXTREASURES
.ntfind:	ld	a,[hli]
		or	[hl]
		jr	z,.got
		add	hl,de
		dec	c
		jr	nz,.ntfind
		ret
.got:		call	random
		and	15
		cp	10
		jr	nc,.got
		ld	e,a
		add	a
		add	e
		add	LOW(treslist)
		ld	e,a
		ld	a,0
		adc	HIGH(treslist)
		ld	d,a
		dec	hl
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
.bad:		call	random
		and	$30
		jr	z,.bad
		sub	$10
		ld	b,a
		ldh	a,[hTmpLo]
		ld	[hli],a
		ld	a,150
		ld	[hli],a
.y:		call	random
		and	$30
		jr	z,.y
		ld	[hli],a

		ld	a,[de]
		ld	[hl],a
		ret


gottrestreasure:
		jp	AnyDec2


treslist:	dw	IDX_BRWNTRES
		db	GROUP_BROWN
		dw	IDX_BRWNTRES+4
		db	GROUP_BROWN
		dw	IDX_BRWNTRES+8
		db	GROUP_BROWN
		dw	IDX_PINKTRES
		db	GROUP_PINK
		dw	IDX_PINKTRES+4
		db	GROUP_PINK
		dw	IDX_PINKTRES+8
		db	GROUP_PINK
		dw	IDX_REDTRES
		db	GROUP_RED
		dw	IDX_REDTRES+4
		db	GROUP_RED
		dw	IDX_REDTRES+8
		db	GROUP_RED
		dw	IDX_REDTRES+12
		db	GROUP_RED


trescollisions:
		dw	0

;***********************************************************************
;***********************************************************************

