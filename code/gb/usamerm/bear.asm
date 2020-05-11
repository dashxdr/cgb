; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** bear.asm                                                              **
; **                                                                       **
; ** Created : 20000425 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;credit1 = # of penguins saved, 4 = won
;credit2 = # of times bear hit

		include "equates.equ"
		include "pin.equ"
		section	11


PENGY		EQU	24


GROUP_BEAR	EQU	2
GROUP_PENG	EQU	3
GROUP_ICEBITS	EQU	4
GROUP_ANGRY	EQU	5

MAXICEFALLS	EQU	3

ANGERLIMIT	EQU	128

bear_penguins	EQUS	"wTemp1024+00" ;8 bytes
bear_hits	EQUS	"wTemp1024+08" ;4 bytes
bear_sharkx	EQUS	"wTemp1024+12"
bear_sharkdx	EQUS	"wTemp1024+13"
bear_sharkframe	EQUS	"wTemp1024+14"
bear_sharkflip	EQUS	"wTemp1024+15"
bear_sharkdet	EQUS	"wTemp1024+16"
bear_sharkend	EQUS	"wTemp1024+17"
bear_anger	EQUS	"wTemp1024+18"
;bear_angernext	EQUS	"wTemp1024+19"

bear_falls	EQUS	"wTemp1024+32" ;5*MAXICEFALLS bytes


bearinfo:	db	BANK(bearhit)		;wPinJmpHit
		dw	bearhit
		db	BANK(bearprocess)	;wPinJmpProcess
		dw	bearprocess
		db	BANK(bearsprites)	;wPinJmpSprites
		dw	bearsprites
		db	BANK(bearhitflipper)	;wPinJmpHitFlipper
		dw	bearhitflipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(bearhitbear)	;wPinJmpHitBumper
		dw	bearhitbear
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

bearmaplist:	db	21
		dw	IDX_BEARBACKRGB
		dw	IDX_BEARBACKMAP

bearhitbear:
		call	Credit2
		ld	hl,bear_anger
		inc	[hl]
;		ld	a,[hl]
;		cp	ANGERLIMIT
;		jr	nz,.nolimit
;		ld	[hl],0
;		jr	.calm
;.nolimit:	inc	[hl]
;		ld	a,[hl]
;		ld	hl,bear_angernext
;		cp	[hl]
;		jr	c,.calm
;		ld	a,ANGERLIMIT
;		ld	[bear_anger],a
;		inc	[hl]
;.calm:
		ld	a,[bear_sharkframe]
		cp	12
		jr	nc,.nohit
		ld	a,18
		ld	[bear_sharkframe],a
.nohit:		ret

BearInit::
;		ld	a,3
;		ld	[bear_angernext],a
		ld	a,$10
		ld	[bear_penguins],a
		ld	[bear_penguins+2],a
		ld	[bear_penguins+4],a
		ld	[bear_penguins+6],a
		ld	a,PENGY
		ld	[bear_penguins+1],a
		ld	[bear_penguins+3],a
		ld	[bear_penguins+5],a
		ld	[bear_penguins+7],a

		ld	hl,bearinfo
		call	SetPinInfo

		ld	a,(SHARKMINX+SHARKMAXX)/2
		ld	[bear_sharkx],a
		ld	a,-1
		ld	[bear_sharkdx],a

		ld	a,$ff
		ld	[bear_sharkdet],a

		ld	a,TIME_BEAR
		call	SetTime

		ld	a,NEED_BEAR
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_POLARBR
		call	AddPalette
		ld	hl,PAL_PENG
		call	AddPalette
		ld	hl,PAL_ICEBITS
		call	AddPalette
		ld	hl,PAL_PBRED
		call	AddPalette

		ld	a,0
		ldh	[pin_textpal],a

		ld	hl,IDX_BEAR000PMP
		call	LoadPinMap

		ld	hl,bearmaplist
		call	NewLoadMap
		ld	hl,IDX_BEARBITSMAP
		call	SecondHalf

 call	SubAddBall

		ld	hl,bearcollisions
		jp	MakeCollisions


bearprocess:
		ld	a,[bear_sharkend]
		or	a
		call	z,SubEnd
		call	AnyDecTime
		call	sharkcoll

		ld	hl,bear_sharkend
		ld	a,[hl]
		or	a
		jr	z,.tryend
		dec	[hl]
		jr	nz,.noend
		call	AnyEnd
		ld	[hl],50
		jr	.noend
.tryend:	ld	hl,bear_hits
		ld	a,MAXHITS
		cp	[hl]
		jr	nz,.noend
		inc	hl
		cp	[hl]
		jr	nz,.noend
		inc	hl
		cp	[hl]
		jr	nz,.noend
		inc	hl
		cp	[hl]
		jr	nz,.noend
		ld	a,90
		ld	[bear_sharkend],a
.noend:

		ret


bearhit:
		ret

MAXHITS		EQU	6
bearhitflipper:

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	50
		jp	nc,SubHitFlipper

		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ld	c,0
		cp	51
		jr	c,.cok
		inc	c
		cp	88
		jr	c,.cok
		inc	c
		cp	125
		jr	c,.cok
		inc	c
.cok:		ld	hl,bear_hits
		ld	b,0
		add	hl,bc
		ld	a,[hl]
		cp	MAXHITS
		jr	z,.donehitflipper
		push	bc
		inc	a
		ld	[hl],a
		ld	e,a
		cp	MAXHITS
		ld	a,FX_BEAR_BREAK
		jr	nz,.nocomplete
		ld	hl,bear_penguins
		add	hl,bc
		add	hl,bc
		ld	[hl],$20
		call	Credit1
		call	AnyDec2
		ld	a,FX_BEAR_RELEASE
.nocomplete:	push	af
		ld	a,e
		srl	a
		ld	e,a
		jr	nc,.fine
		pop	af
		pop	de
		jp	InitSfx
.fine:		add	a
		add	a
		add	e
		ld	d,a
		ld	a,c
		add	a
		ld	e,a
		ld	hl,bearxlist
		add	hl,bc
		ld	h,[hl]
		ld	l,3
		ld	bc,$0502
		call	BGRect
		pop	af
		call	InitSfx
		pop	de
		call	bearaddbits
		call	bearaddbits
		call	bearaddbits
.donehitflipper:
		ret
bearxlist:	db	1,6,11,16


bearsprites:
		call	SubFlippers
		call	bearshark
		ld	hl,bear_penguins
		ld	d,30-8
		call	bearpenguin
		ld	hl,bear_penguins+2
		ld	d,68-8
		call	bearpenguin
		ld	hl,bear_penguins+4
		ld	d,105-8
		call	bearpenguin
		ld	hl,bear_penguins+6
		ld	d,144-8
		call	bearpenguin
		call	beardofalls

		ret


bearball:	ld	hl,wBalls+BALL_FLAGS
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
;		ld	a,[bear_x]
		inc	a
		ld	d,a
		ld	e,0
		ld	bc,40<<5
		ld	hl,0
		jp	AddBall

;a=#
bearopen:	or	a
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

sharkcoll:	ld	a,[bear_sharkx]
		sub	SHARKMINX
		ld	c,a
		ld	b,0
		ld	hl,sharkdet
		add	hl,bc
		ld	a,[bear_sharkdet]
		cp	[hl]
		ret	z
		ld	c,a
		ld	a,[hl]
		ld	[bear_sharkdet],a
		ld	hl,IDX_BEAR001CHG
		add	hl,bc
		inc	c
		ld	c,a
		push	bc
		call	nz,UndoChanges
		pop	bc
		ld	hl,IDX_BEAR001CHG
		add	hl,bc
		jp	MakeChanges

sharkmap:	db	1,2,3,4,5,6,7,8,9,10,11,0,13,14,15,16,17,0
		db	19,0

SHARKMINX	EQU	30
SHARKMAXX	EQU	160-SHARKMINX
SHARKY		EQU	70


bearshark:
		ld	a,[bear_sharkflip]
		push	af
		ld	a,[bear_sharkframe]
		ld	c,a
		ld	b,0
		ld	a,[bear_anger]
		bit	1,a
;		cp	ANGERLIMIT
		ld	e,7
		jr	z,.eok
		ld	e,3
.eok:		ld	a,[wTime]
		and	e
		jr	nz,.noinvert
		ld	hl,sharkmap
		add	hl,bc
		ld	a,[hl]
		ld	[bear_sharkframe],a
		ld	a,c
		cp	17
		jr	nz,.noinvert
		ld	a,[bear_sharkflip]
		xor	$80
		ld	[bear_sharkflip],a
.noinvert:
		ld	a,c
		cp	18
		jr	c,.cok
		ld	c,18
.cok:		ld	hl,IDX_POLARBR
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[bear_anger]
		bit	1,a
;		cp	ANGERLIMIT
		ld	e,1
		jr	z,.eok2
		ld	e,0
.eok2:		ld	a,[wTime]
		and	e
		jr	z,.move
		ld	a,[bear_sharkx]
		ld	d,a
		jr	.noinvertdx
.move:
		ld	a,[bear_sharkdx]
		ld	l,a
		ld	a,[bear_sharkx]
		add	l
		ld	[bear_sharkx],a
		ld	d,a
		cp	SHARKMINX
		jr	z,.invertdx
		cp	SHARKMAXX
		jr	nz,.noinvertdx
.invertdx:	ld	a,[bear_sharkdx]
		cpl
		inc	a
		ld	[bear_sharkdx],a
		ld	a,12
		ld	[bear_sharkframe],a
.noinvertdx:	ld	e,SHARKY
		ld	a,[bear_anger]
		bit	1,a
;		cp	ANGERLIMIT
		ld	l,GROUP_BEAR
		jr	z,.lok
		ld	l,GROUP_ANGRY
.lok:		pop	af
		add	l
		jp	AddFigure

penguinlist:	dw	penguin0
		dw	penguin1

penguin0:	db	2,2,3,4,4,4,4,3,2,2,-1
penguin1:	db	6,7,8,7,-2


;d=x position
;hl = struct (mode,y pos)
bearpenguin:
		ld	a,[hl]
		and	$f0
		ret	z
		swap	a
		dec	a
		push	af
		add	a
		add	LOW(penguinlist)
		ld	c,a
		ld	a,0
		adc	HIGH(penguinlist)
		ld	b,a
		ld	a,[bc]
		ld	e,a
		inc	bc
		ld	a,[bc]
		ld	b,a
		ld	c,e
		ld	a,[hl]
		and	15
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,[bc]
		ld	e,a
		ld	a,[wTime]
		and	3
		jr	nz,.fine
		inc	[hl]
		inc	bc
		ld	a,[bc]
		add	a
		jr	nc,.fine
		ld	a,[bc]
		cpl
		inc	a
		swap	a
		ld	[hl],a
.fine:		ld	a,e
		sub	2
		add	IDX_PENG&255
		ld	c,a
		ld	a,0
		adc	IDX_PENG>>8
		ld	b,a
		inc	hl
		ld	e,[hl]
		ld	a,GROUP_PENG
		push	hl
		call	AddFigure
		pop	hl
		pop	af
		cp	1
		jr	nz,.nomovedown
		inc	[hl]
		ld	a,l
		ld	b,110
		cp	1
		jr	z,.bok
		cp	7
		jr	z,.bok
		ld	b,150
.bok:		ld	a,[hl]
		cp	b
		jr	c,.nomovedown
		dec	hl
		ld	[hl],0
.nomovedown:	ret




beardofalls:

		ld	hl,bear_falls
		ld	e,MAXICEFALLS
.dofalls:	ld	a,[hli]
		or	a
		jr	z,.next2
		dec	hl
		inc	a
		ld	[hli],a
		cp	4*8+1
		jr	c,.cont
		dec	hl
		xor	a
		ld	[hli],a
		jr	.next2
.cont:		dec	a
		dec	a
		srl	a
		srl	a
		and	7
		add	255&IDX_ICEBITS
		ld	c,a
		ld	a,0
		adc	IDX_ICEBITS>>8
		ld	b,a
		push	de
		ld	a,[hli]
		add	[hl]
		ld	[hli],a
		ld	d,a
		ld	a,[wTime]
		and	3
		ld	e,0
		jr	nz,.eok
		inc	e
.eok:		ld	a,[hl]
		add	e
		ld	[hli],a
		add	[hl]
		ld	[hli],a
		ld	e,a
		ld	a,GROUP_ICEBITS
		push	hl
		call	AddFigure
		pop	hl
		pop	de
		jr	.next
.next2:		inc	hl
		inc	hl
		inc	hl
		inc	hl
.next:		dec	e
		jr	nz,.dofalls
		ret

;e=#
;preserves de
bearaddbits:	ld	hl,bear_falls
		ld	c,MAXICEFALLS
.look:		ld	a,[hli]
		or	a
		jr	z,.found
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		dec	c
		jr	nz,.look
		ret
.found:		dec	hl
		ld	a,1
		ld	[hli],a
		ld	a,e
		add	a
		add	LOW(bearpositions)
		ld	c,a
		ld	a,0
		adc	HIGH(bearpositions)
		ld	b,a
		call	.rnd3
		ld	[hli],a
		ld	a,[bc]
		ld	[hli],a
		inc	bc

		call	random
		and	1
		sub	2
		ld	[hli],a
		ld	a,[bc]
		ld	[hl],a
		ret

.rnd3:		call	random
		and	7
		jr	z,.rnd3
		sub	4
		ret

bearpositions:
		db	32,24
		db	72,24
		db	104,24
		db	144,24




bearcollisions:
		dw	0

;***********************************************************************
;***********************************************************************

