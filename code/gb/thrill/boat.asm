; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** boat.asm                                                              **
; **                                                                       **
; ** Created : 20000802 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"

		section	27


GROUP_BOAT	EQU	2

boat_second	EQUS	"wTemp1024+00"
boat_drop	EQUS	"wTemp1024+01"
boat_x		EQUS	"wTemp1024+02"
boat_in		EQUS	"wTemp1024+03"
boat_hist	EQUS	"wTemp1024+04" ;2

MAXHEIGHT	EQU	7

boatinfo:	db	BANK(boathit)		;wPinJmpHit
		dw	boathit
		db	BANK(boatprocess)	;wPinJmpProcess
		dw	boatprocess
		db	BANK(boatsprites)	;wPinJmpSprites
		dw	boatsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(boatbumper)	;wPinJmpHitBumper
		dw	boatbumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(boatlostball)	;wPinJmpLost
		dw	boatlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(boatdone)		;wPinJmpDone
		dw	boatdone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

boatmaplist:	db	21
		dw	IDX_BOATBACKRGB
		dw	IDX_BOATBACKMAP

boatdone:	ret

BoatInit::
		ld	hl,boatinfo
		call	SetPinInfo

		ld	a,TIME_BOAT
		call	SetTime

		ld	a,NEED_BOAT
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_BOAT
		call	AddPalette

		ld	hl,IDX_BOAT0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,boatmaplist
		call	NewLoadMap
		ld	hl,IDX_BOATLIGHTSMAP
		call	SecondHalf

		call	boatsaver.on

 call	SubAddBall

		ld	a,BANK(BoatInit)
		ld	[wPinHitBank],a

		call	subsaver

		call	boaton

		ld	hl,boatcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

boatlostball:	ld	a,[any_ballsaver]
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

boatprocess:
		ld	a,[boat_x]
		or	a
		jr	z,.noincm
		dec	a
		call	z,launchboat
		ld	hl,boat_x
		inc	[hl]
		call	z,boaton
		ld	a,[boat_x]
		cp	128
		call	z,boatcredit
.noincm:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,boatsaver

		ld	a,[wTime]
		and	15
		cp	15
		jr	nz,.noarrows
		ld	a,[wTime]
		swap	a
		call	boatarrows
.noarrows:
		ret

boatsaver:	ld	hl,any_ballsaver
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
		jp	boatrect
.off:		ld	a,0
		jp	boatrect


;a=#
boatrect:	ld	hl,boatrects
		jp	RectList


boatrects:	db	2,2,17,3,10,12	; 0 saver 0
		db	2,2,17,0,10,12	; 1 saver 1
		db	2,2,0,3,3,8	; 2 drop a 0
		db	2,2,0,0,3,8	; 3 drop a 1
		db	3,2,3,3,7,7	; 4 drop b 0
		db	3,2,3,0,7,7	; 5 drop b 1
		db	2,2,7,3,10,7	; 6 drop c 0
		db	2,2,7,0,10,7	; 7 drop c 1
		db	3,2,10,3,12,7	; 8 drop d 0
		db	3,2,10,0,12,7	; 9 drop d 1
		db	2,2,14,3,17,8	;10 drop e 0
		db	2,2,14,0,17,8	;11 drop e 1
		db	2,2,0,9,4,10	;12 b 0
		db	2,2,0,6,4,10	;13 b 1
		db	2,2,3,9,7,9	;14 o 0
		db	2,2,3,6,7,9	;15 o 1
		db	2,2,6,9,10,9	;16 a 0
		db	2,2,6,6,10,9	;17 a 1
		db	2,2,9,9,13,9	;18 r 0
		db	2,2,9,6,13,9	;19 r 1
		db	2,2,12,9,16,10	;20 d 0
		db	2,2,12,6,16,10	;21 d 1
		db	3,3,0,16,6,11	;22 left arrow 0
		db	3,3,0,12,6,11	;23 left arrow 1
		db	3,3,4,16,13,11	;24 right arrow 0
		db	3,3,4,12,13,11	;25 right arrow 1

boatcredits:	db	0,5
		db	1,25
		db	2,50
		db	3,75
		db	4,100
		db	8,250

boatcredit:
		ld	a,[boat_in]
		add	a
		ld	c,a
		ld	b,0
		ld	hl,boatcredits
		add	hl,bc
		ld	a,[hli]
		push	af
		ld	l,[hl]
		ld	h,b
		call	addthousandshlinform
		pop	af
		or	a
		jr	z,.none
		ld	b,a
.dec:		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	z,.none
		push	bc
		call	Credit1
		call	AnyDec2
		pop	bc
		dec	b
		jr	nz,.dec
.none:
.done:		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.noend
		call	AnyEnd
		ld	a,FX_BOATWON
		call	InitSfx
.noend:
		xor	a
		ld	[boat_in],a
		ret

;		ld	a,[boat_in]
;		or	a
;		jr	z,.empty
;		cp	8
;		ld	hl,BOATSCORE1		;Full boat score
;		call	z,addthousandshlinform
;		ld	a,[boat_in]
;		ld	c,a
;.dec:		ld	hl,any_count2
;		ld	a,[hli]
;		or	[hl]
;		jr	z,.done
;		push	bc
;		ld	hl,BOATSCORE2		;For each rider
;		call	addthousandshlinform
;
;		call	Credit1
;		call	AnyDec2
;		pop	bc
;		dec	c
;		jr	nz,.dec
;.done:		ld	hl,any_count2
;		ld	a,[hli]
;		or	[hl]
;		call	z,AnyEnd
;		xor	a
;		ld	[boat_in],a
;
;		ret
;.empty:		ld	hl,BOATSCORE3		;For empty boat
;		jp	addthousandshlinform
;BOATSCORE1	EQU	100	;Bonus for a full boat
;BOATSCORE2	EQU	25	;for each rider
;BOATSCORE3	EQU	5	;for empty boat





setboatdrop:	push	af
		ld	a,[boat_drop]
		bit	4,a
		ld	hl,IDX_BOAT0003CHG
		call	nz,UndoChanges
		ld	a,[boat_drop]
		bit	0,a
		ld	hl,IDX_BOAT0002CHG
		call	nz,UndoChanges
		ld	a,[boat_drop]
		srl	a
		and	7
		jr	z,.no1
		ld	c,a
		ld	b,0
		ld	hl,IDX_BOAT0004CHG-1
		add	hl,bc
		call	UndoChanges
.no1:		pop	af
		ld	[boat_drop],a
		bit	4,a
		ld	hl,IDX_BOAT0003CHG
		call	nz,MakeChanges
		ld	a,[boat_drop]
		bit	0,a
		ld	hl,IDX_BOAT0002CHG
		call	nz,MakeChanges
		ld	a,[boat_drop]
		srl	a
		and	7
		jr	z,.no2
		ld	c,a
		ld	b,0
		ld	hl,IDX_BOAT0004CHG-1
		add	hl,bc
		call	MakeChanges
.no2:		ret


boaton:
		ld	a,$1f
		call	setboatdrop
		xor	a
		ld	[boat_in],a
		ld	a,12
		call	boatrect
		ld	a,14
		call	boatrect
		ld	a,16
		call	boatrect
		ld	a,18
		call	boatrect
		ld	a,20
		call	boatrect
		ld	a,3
		call	boatrect
		ld	a,5
		call	boatrect
		ld	a,7
		call	boatrect
		ld	a,9
		call	boatrect
		ld	a,11
		jp	boatrect
boatoff:
		xor	a
		call	setboatdrop
		ld	a,13
		call	boatrect
		ld	a,15
		call	boatrect
		ld	a,17
		call	boatrect
		ld	a,19
		call	boatrect
		ld	a,21
		call	boatrect
		ld	a,2
		call	boatrect
		ld	a,4
		call	boatrect
		ld	a,6
		call	boatrect
		ld	a,8
		call	boatrect
		ld	a,10
		jp	boatrect


boatbumper:
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
		ld	l,2
		ld	c,255-$10
		cp	50
		jr	c,.cok
		ld	l,4
		ld	c,255-$08
		cp	78
		jr	c,.cok
		ld	l,6
		ld	c,255-$04
		cp	97
		jr	c,.cok
		ld	l,8
		ld	c,255-$02
		cp	125
		jr	c,.cok
		ld	l,10
		ld	c,255-$01
.cok:		ld	a,[boat_drop]
		ld	b,a
		and	c
		cp	b
		jr	z,.ignore
		push	af
		ld	a,l
		push	af
		call	boatrect
		pop	af
		add	11
		call	boatrect
		pop	af
		call	setboatdrop
		ld	hl,boat_in
		inc	[hl]
		ld	a,FX_BOATDROP
		call	InitSfx
;		ld	a,[boat_drop]
;		or	a
;		jr	nz,.mok
;		ld	a,8
;		ld	[boat_in],a
.mok:

.ignore:


.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret


boatleft:	xor	a
		jr	boatloop
boatmiddle:	ld	a,1
		jr	boatloop
boatright:	ld	a,2
boatloop:	ld	hl,boat_hist
		cp	[hl]
		ret	z
		ld	d,[hl]
		ld	[hli],a
		ld	e,[hl]
		ld	[hl],d
		dec	d
		ret	nz
		xor	e
		cp	2
		ret	nz
		ld	hl,boat_x
		ld	a,[hl]
		or	a
		ret	nz
		inc	[hl]
		ld	a,[boat_in]
		cp	5
		ld	a,FX_BOATLAUNCH
		jr	c,.aok
		ld	a,FX_BOATFULL
.aok:		jp	InitSfx

launchboat:	xor	a
		call	setboatdrop
		jp	boatoff

boatcollisions:
		dw	boatleft,53,40
		db	4,4
		dw	boatmiddle,88,14
		db	4,4
		dw	boatright,121,40
		db	4,4
		dw	0

boatarrows:	ld	c,a
		ld	a,[boat_in]
		or	a
		jr	z,boatarrowsoff
		ld	a,[boat_x]
		or	a
		jr	nz,boatarrowsoff
		srl	c
		jr	c,boatarrowson
boatarrowsoff:	ld	a,22
		call	boatrect
		ld	a,24
		jp	boatrect
boatarrowson:	ld	a,23
		call	boatrect
		ld	a,25
		jp	boatrect



boathit:	ret

boatsprites:
		call	boatsprite

		jp	SubFlippers

BOATX		EQU	80
BOATY		EQU	39

MIN		EQU	28
MAX		EQU	49
RAD		EQU	6

boatsprite:	ld	a,[boat_in]
		cp	5
		jr	c,.aok
		add	3
.aok:		add	IDX_BOAT&255
		ld	c,a
		ld	a,0
		adc	IDX_BOAT>>8
		ld	b,a
		ld	e,BOATY
		ld	a,[boat_x]
		add	BOATX
		ld	d,a
		ld	a,GROUP_BOAT
		call	AddFigure

		call	CountBalls
		or	a
		ret	z

		ld	a,[wTemp512+SIZE_SPR+SPR_SCR_Y]
		ld	b,a

		ld	a,[wFigPhase]
		and	$7f
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	de,$8000
		add	hl,de

		ld	a,b
		cp	MAX+RAD
		ret	nc
		cp	MIN-RAD
		ret	c

		cp	MAX-RAD
		jr	nc,.top
		cp	MIN+RAD
		jr	c,.bottom
		jr	.all
.bottom:	ld	a,MIN+RAD
		sub	b
		ld	c,a
		add	a
		add	l
		ld	l,a
		ld	a,RAD*2+1
		sub	c
		jr	.both


		ret
.top: 
		sub	MAX-RAD+RAD*2+1
		cpl
		inc	a
.both:		cp	16
		jr	c,.ok
.all:		ld	a,16
.ok:		ld	c,a
		or	a
		ret	z
		ld	d,h
		ld	e,l
		call	.some
		ld	hl,$20
		add	hl,de
.some:		ld	b,c
.sync:
.sync1a:	ldio	a,[rSTAT]
		and	3
		jr	z,.sync1a
.sync1b:	ldio	a,[rSTAT]
		and	3
		jr	nz,.sync1b
.fill:		ld	[hli],a
		ld	[hli],a
		dec	b
		jr	nz,.fill
		ret
