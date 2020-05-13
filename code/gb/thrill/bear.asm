; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** bear.asm                                                              **
; **                                                                       **
; ** Created : 20000802 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

GROUP_CAR	EQU	2

bear_second	EQUS	"wTemp1024+00"
bear_car	EQUS	"wTemp1024+01"
bear_pos	EQUS	"wTemp1024+02"
bear_ons	EQUS	"wTemp1024+03" ;6
bear_delay	EQUS	"wTemp1024+09"
bear_step	EQUS	"wTemp1024+10"
bear_state	EQUS	"wTemp1024+11"
bear_sidecount	EQUS	"wTemp1024+12"

MAXHEIGHT	EQU	7

bearinfo:	db	BANK(bearhit)		;wPinJmpHit
		dw	bearhit
		db	BANK(bearprocess)	;wPinJmpProcess
		dw	bearprocess
		db	BANK(bearsprites)	;wPinJmpSprites
		dw	bearsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(bearbumper)	;wPinJmpHitBumper
		dw	bearbumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(bearlostball)	;wPinJmpLost
		dw	bearlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(beardone)		;wPinJmpDone
		dw	beardone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

bearmaplist:	db	21
		dw	IDX_BEARBACKRGB
		dw	IDX_BEARBACKMAP

beardone:
		ret

BearInit::
		ld	hl,bearinfo
		call	SetPinInfo

		ld	a,TIME_BEAR
		call	SetTime

		ld	a,NEED_BEAR
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_CAR
		call	AddPalette

		ld	hl,IDX_BEAR0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

;		ld	hl,IDX_BEAR0004CHG
;		call	MakeChanges
;		ld	hl,IDX_BEAR0009CHG
;		call	MakeChanges

		ld	hl,bearmaplist
		call	NewLoadMap
		ld	hl,IDX_BEARLIGHTSMAP
		call	SecondHalf

		call	bearsaver.on

 call	SubAddBall

		ld	a,$ff
		ld	[bear_pos],a

		ld	a,$7e
		ld	[bear_car],a

		call	subsaver

		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,bearsteps
		add	hl,bc
		ld	a,[hl]
		ld	[bear_step],a

		ld	hl,bearcollisions
		jp	MakeCollisions


FX		EQU	50<<5
FY		EQU	50<<5

bearlostball:	ld	a,[any_ballsaver]
		or	a
		ret	z
		ld	hl,pin_ballflags
		set	BALLFLG_USED,[hl]
		ld	a,FX&255
		ldh	[pin_x],a
		ld	a,FX>>8
		ld	[pin_x+1],a
		ld	a,FY&255
		ldh	[pin_y],a
		ld	a,FY>>8
		ld	[pin_y+1],a
		xor	a
		ldh	[pin_vx],a
		ldh	[pin_vx+1],a
		ldh	[pin_vy],a
		ldh	[pin_vy+1],a
		ret

bearprocess:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,bearsaver

		ld	a,[bear_step]
		ld	c,a
		ld	a,[bear_delay]
		add	c
		ld	[bear_delay],a
		call	c,bearmovecar

		ld	hl,bear_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:

		ret

BASE		EQU	20
SP		EQU	12

LEVEL0		EQU	BASE
LEVEL1		EQU	BASE+SP*1
LEVEL2		EQU	BASE+SP*2
LEVEL3		EQU	BASE+SP*6
LEVEL4		EQU	BASE+SP*7
LEVEL5		EQU	BASE+SP*8

bearmovecar:
		ld	hl,bear_car
		inc	[hl]
		ld	a,[hl]
		and	$7f
		cp	LEVEL0
		jr	c,.forceoff
		cp	LEVEL5
		jr	c,.noreset
		xor	[hl]
		xor	$80
		ld	[hl],a
		push	af
		ld	a,FX_BEARPASS
		call	InitSfx
		pop	af
		jr	z,.rightoff
.leftoff:
		ld	a,[bear_ons]
		or	a
		jr	z,.off0
		xor	a
		ld	[bear_ons],a
		ld	a,14
		call	bearrect
.off0:
		ld	a,[bear_ons+1]
		or	a
		jr	z,.off1
		xor	a
		ld	[bear_ons+1],a
		ld	a,14+2
		call	bearrect
.off1:
		ld	a,[bear_ons+2]
		or	a
		jr	z,.off2
		xor	a
		ld	[bear_ons+2],a
		ld	a,14+4
		call	bearrect
.off2:
		jr	.bothoff
.rightoff:
		ld	a,[bear_ons+3]
		or	a
		jr	z,.off3
		xor	a
		ld	[bear_ons+3],a
		ld	a,14+6
		call	bearrect
.off3:

		ld	a,[bear_ons+4]
		or	a
		jr	z,.off4
		xor	a
		ld	[bear_ons+4],a
		ld	a,14+8
		call	bearrect
.off4:
		ld	a,[bear_ons+5]
		or	a
		jr	z,.off5
		xor	a
		ld	[bear_ons+5],a
		ld	a,14+10
		call	bearrect
.off5:
.bothoff:
		xor	a
		ld	[bear_sidecount],a
.forceoff:	ld	hl,bearoff
		jp	.alloff
.noreset:
		ld	a,[hl]
		ld	c,0
		cp	LEVEL1
		jr	c,.cok
		inc	c
		cp	LEVEL2
		jr	c,.cok
		inc	c
		cp	LEVEL3
		jr	c,.cok
		inc	c
		cp	LEVEL4
		jr	c,.cok
		inc	c
		cp	LEVEL5
		jr	c,.cok
		inc	c
		cp	$80+LEVEL1
		jr	c,.cok
		inc	c
		cp	$80+LEVEL2
		jr	c,.cok
		inc	c
		cp	$80+LEVEL3
		jr	c,.cok
		inc	c
		cp	$80+LEVEL4
		jr	c,.cok
		inc	c
.cok:		ld	a,[bear_pos]
		cp	c
		ret	z
		ld	b,0
		cp	$ff
		jr	z,.skipoff
		push	bc
		ld	c,a
		ld	hl,IDX_BEAR0002CHG
		add	hl,bc
		call	UndoChanges
		pop	bc
.skipoff	push	bc
		ld	hl,IDX_BEAR0002CHG
		add	hl,bc
		call	MakeChanges
		pop	bc
		ld	a,c
		ld	[bear_pos],a
		ld	b,0
		ld	hl,bearbits
		add	hl,bc
.alloff:	ld	a,[bear_state]
		ld	c,a
		ld	a,[hl]
		ld	[bear_state],a
		ld	b,a
		xor	c
		ld	c,a
		ld	d,2
		call	.bearbit
		call	.bearbit
		call	.bearbit
		call	.bearbit
		call	.bearbit
.bearbit:	srl	c
		jr	nc,.same
		push	bc
		push	de
		srl	b
		ld	a,d
		jr	nc,.aok
		inc	a
		call	bearrect
		ld	a,FX_BEARRAISE
		call	InitSfx
		jr	.down
.aok:		call	bearrect
.down:		pop	de
		pop	bc
.same:		inc	d
		inc	d
		srl	b
		ret


bearoff:	db	%000000
bearbits:	db	%000001
		db	%000011
		db	%000111
		db	%000110
		db	%000100
		db	%001000
		db	%011000
		db	%111000
		db	%110000
		db	%100000



bearsaver:	ld	hl,any_ballsaver
		ld	a,[hl]
		or	a
		ret	z
		dec	[hl]
		jr	z,.off
		cp	8
		jr	nc,.on
		cp	3
		jr	c,.off
		srl	a
		jr	c,.off
.on:		ld	a,1
		jp	bearrect
.off:		ld	a,0
		jp	bearrect



;a=#
bearrect:	ld	hl,bearrects
		jp	RectList


bearrects:	db	2,2,18,3,10,12	; 0 saver 0
		db	2,2,18,0,10,12	; 1 saver 1
		db	2,2,6,3,5,1	; 2 drop a 0
		db	2,2,6,0,5,1	; 3 drop a 1
		db	2,2,3,3,4,3	; 4 drop b 0
		db	2,2,3,0,4,3	; 5 drop b 1
		db	2,2,0,3,2,4	; 6 drop c 0
		db	2,2,0,0,2,4	; 7 drop c 1
		db	2,2,9,3,15,1	; 8 drop d 0
		db	2,2,9,0,15,1	; 9 drop d 1
		db	2,2,12,3,16,3	;10 drop e 0
		db	2,2,12,0,16,3	;11 drop e 1
		db	2,2,15,3,18,4	;12 drop f 0
		db	2,2,15,0,18,4	;13 drop f 1
		db	2,2,6,9,7,2	;14 s 0
		db	2,2,6,6,7,2	;15 s 1
		db	2,2,3,9,5,4	;16 r 0
		db	2,2,3,6,5,4	;17 r 1
		db	2,2,0,9,3,6	;18 u 0
		db	2,2,0,6,3,6	;19 u 1
		db	2,2,9,9,13,2	;20 i 0
		db	2,2,9,6,13,2	;21 i 1
		db	2,2,12,9,15,4	;22 n 0
		db	2,2,12,6,15,4	;23 n 1
		db	2,2,15,9,17,6	;24 e 0
		db	2,2,15,6,17,6	;25 e 1


bearbumper:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	d,h

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	e,h

		ld	a,d
		cp	80
		jr	c,.left
.right:		ld	a,d
		add	e
		cp	181
		jr	nc,.r2
		cp	152
		jr	nc,.r1
.r0:		ld	c,3
		jr	.all
.r1:		ld	c,4
		jr	.all
.r2:		ld	c,5
		jr	.all
.left:		ld	a,e
		add	23
		cp	d
		jr	c,.l0
		ld	a,d
		add	6
		cp	e
		jr	c,.l2
		jr	.l1
.l0:		ld	c,0
		jr	.all
.l1:		ld	c,1
		jr	.all
.l2:		ld	c,2
		jr	.all
.all:		ld	b,0
		ld	hl,Bits
		add	hl,bc
		ld	a,[bear_state]
		and	[hl]
		jr	z,.already
		ld	hl,bear_ons
		add	hl,bc
		ld	a,[hl]
		or	a
		jr	nz,.already
		ld	[hl],1
		ld	a,c
		add	a
		add	15
		call	bearrect
		ld	hl,bear_sidecount
		inc	[hl]
		ld	a,[hl]
		dec	a
		ld	hl,25
		jr	z,.hlok
		dec	a
		ld	hl,100
		jr	z,.hlok
		ld	hl,250
.hlok:		call	addthousandshlinform
		ld	a,[bear_sidecount]
		dec	a
		jr	z,.c1
		dec	a
		jr	.c2
		call	beardid1
.c2:		call	beardid1
.c1:		call	beardid1
		ld	a,[bear_sidecount]
		cp	3
		ld	a,FX_BEARDROP
		jr	nz,.aok
		ld	a,FX_BEARSET
.aok:		call	InitSfx

.already:

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

beardid1:	ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	AnyDec2
		call	Credit1
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	nz
		call	AnyEnd
		ld	a,FX_BEARWON
		jp	InitSfx


bearsteps:	db	100,100,100

bearcollisions:
		dw	0

bearhit:	ret

bearsprites:
		call	bearcar


		jp	SubFlippers

CARLEFTX	EQU	46
CARLEFTY	EQU	-10
CARRIGHTX	EQU	113
CARRIGHTY	EQU	-10

STEP		EQU	15
bearcar:	ld	bc,IDX_CAR
		ld	a,[bear_car]
		ld	h,a
		and	$7f
		cp	h
		ld	h,a
		jr	nz,.right
.left:		ld	a,CARLEFTX
		sub	h
		ld	d,a
		ld	a,CARLEFTY
		add	h
		ld	e,a
		ld	a,GROUP_CAR
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	STEP
		ld	d,a
		ld	a,e
		sub	STEP
		ld	e,a
		ld	bc,IDX_CAR
		ld	a,GROUP_CAR
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	STEP
		ld	d,a
		ld	a,e
		sub	STEP
		ld	e,a
		ld	bc,IDX_CAR
		ld	a,GROUP_CAR
		jp	AddFigure
.right:		ld	a,CARRIGHTX
		add	h
		ld	d,a
		ld	a,CARRIGHTY
		add	h
		ld	e,a
		ld	a,GROUP_CAR|$80
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		sub	STEP
		ld	d,a
		ld	a,e
		sub	STEP
		ld	e,a
		ld	bc,IDX_CAR
		ld	a,GROUP_CAR|$80
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		sub	STEP
		ld	d,a
		ld	a,e
		sub	STEP
		ld	e,a
		ld	bc,IDX_CAR
		ld	a,GROUP_CAR|$80
		jp	AddFigure

		



