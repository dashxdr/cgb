; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SHIP.ASM                                                              **
; **                                                                       **
; ** Created : 20000229 by David Ashley                                    **
; **  File included in pin.asm                                             **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	09


MAXMEN		EQU	7

MAN_STATE	EQU	0
MAN_COUNT	EQU	1
MAN_X		EQU	2
MAN_Y		EQU	3
MAN_YWANT	EQU	4
MAN_SIZE	EQU	5


ship_men 	EQUS	"wTemp1024+00" ;MAXMEN*MAN_SIZE
ship_counts	EQUS	"wTemp1024+64" ;3
ship_tosave	EQUS	"wTemp1024+67"
ship_newball	EQUS	"wTemp1024+68"

GROUP_ERIC	EQU	2
GROUP_CREW	EQU	3
GROUP_BARREL	EQU	4
GROUP_BOOM	EQU	5
GROUP_SCORE	EQU	6

BARRELSPERBALL	EQU	4


shipinfo:	db	BANK(shiphit)		;wPinJmpHit
		dw	shiphit
		db	BANK(shipprocess)	;wPinJmpProcess
		dw	shipprocess
		db	BANK(shipsprites)	;wPinJmpSprites
		dw	shipsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(shipcull)		;wPinJmpPerBall
		dw	shipcull
		db	BANK(Nothing)		;wPinJmpHitBumper
		dw	Nothing
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

shipmaplist:	db	21
		dw	IDX_SHIPBACKRGB
		dw	IDX_SHIPBACKMAP

ShipInit::
		ld	hl,shipinfo
		call	SetPinInfo

		ld	a,TIME_SHIP
		call	SetTime

		ld	a,NEED_SHIP
		ld	[ship_tosave],a
		call	SetCount2

		ld	a,5
		ldh	[pin_textpal],a

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_ERIC
		call	AddPalette
		ld	hl,PAL_CREW
		call	AddPalette
		ld	hl,PAL_BARREL
		call	AddPalette
		ld	hl,PAL_BOOM
		call	AddPalette
		ld	hl,PAL_SCORE
		call	AddPalette

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap
		ld	hl,IDX_SHPDET000CHG
		call	MakeChanges

		ld	hl,shipmaplist
		call	NewLoadMap

	call	SubAddBall

		ld	hl,shipcollisions
		jp	MakeCollisions


shipprocess:
		call	SubEnd
		call	AnyDecTime
		call	shipcount
		ret

shiphit:
		ldh	a,[pin_y+1]
		ld	e,a
		ldh	a,[pin_y]
		add	a
		rl	e
		add	a
		rl	e
		add	a
		rl	e
		ld	a,e
		cp	12
		ret	c
		cp	70
		ret	nc
		ldh	a,[pin_x+1]
		ld	d,a
		ldh	a,[pin_x]
		add	a
		rl	d
		add	a
		rl	d
		add	a
		rl	d
		ld	a,d
		cp	24
		ret	c
		cp	152
		ret	nc
		ld	c,0
		cp	70
		jr	c,.cok
		inc	c
		cp	110
		jr	c,.cok
		inc	c
.cok:		ld	b,0
		call	manoverboard
		ld	a,FX_SHIPHIT
		jp	InitSfx

SHIPPOS1	EQU	49-8
SHIPPOS2	EQU	89-8
SHIPPOS3	EQU	129-8
SHIPY		EQU	11

SHIPDOWN1	EQU	50
SHIPDOWN2	EQU	70
SHIPDOWN3	EQU	90

shippositions:	db	SHIPPOS1,SHIPPOS2,SHIPPOS3
shipdowns:	db	SHIPDOWN1,SHIPDOWN2,SHIPDOWN3


shipsprites:
		call	overboardsprites
		call	SubFlippers
		ret

;MODES:
;0 = unused slot
;1 = crew bob on wreck
;2 = crew jumping to position
;3 = crew bob in water (can be hit)
;4 = crew underwater (can't be hit)
;5 = barrel bob on wreck
;6 = barrel move to position
;7 = barrel bobbing in water (can be hit)
;8 = barrel explode
;9 = 5M
;+16 = Eric

shiptrans:	db	0		;0->0
		db	1		;1->1
		db	2		;2->2
		db	4		;3->4
		db	3		;4->3
		db	5		;5->5
		db	6		;6->6
		db	7		;7->7
		db	0		;8->0
		db	0		;9->0

shiplist1:	db	8,8,8,8,8,8,8,8,7,6,5,4,3,2,1,0,1,2,-5
shiplist2:	db	0,1,2,3,4,5,-2
shiplist3:	db	9,10,11,12,13,14,9,10,11,12,13,14,9,10,11,12,13,14,-6
shiplist4:	db	15,16,17,18,19,20,18,19,20,18,19,20,18,19,20,-3
shiplist5:	db	0,1,2,-1
shiplist6:	db	2,3,4,5,6,7,4,8,9,-3
shiplist7:	db	10,11,12,13,14,13,-3,15,-4
shiplist8:	db	0,1,2,3,4,-1
shiplist9:	db	0,1,2,3,4,5,6,7,-1

shiplists:	dw	shiplist1,shiplist2,shiplist3,shiplist4
		dw	shiplist5,shiplist6,shiplist7,shiplist8
		dw	shiplist9

overboardsprites:
		ld	hl,ship_men
		ld	c,MAXMEN
.lp:		ld	a,[hl]
		or	a
		jr	nz,.active
.cont:		ld	de,MAN_SIZE
		add	hl,de
		dec	c
		jr	nz,.lp
		ret
.active:	push	bc
		push	hl
		ld	a,[hli]
		ld	c,a
		and	15
		dec	a
		add	a
		add	LOW(shiplists)
		ld	e,a
		ld	a,0
		adc	HIGH(shiplists)
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	d,a
		ld	e,b
		ld	a,[wTime]
		and	7
		ld	a,[hl]
		jr	nz,.noinc
		inc	a
		ld	[hl],a
.noinc:		add	e
		ld	e,a
		ld	a,0
		adc	d
		ld	d,a
		ld	a,[de]
		bit	7,a
		jr	z,.noback
		add	[hl]
		ld	[hl],a
		ld	a,[de]
		add	e
		ld	e,a
		ld	a,$ff
		adc	d
		ld	d,a
		ld	a,[de]
		push	af
		ld	a,c
		and	15
		add	LOW(shiptrans)
		ld	e,a
		ld	a,0
		adc	HIGH(shiptrans)
		ld	d,a
		ld	b,0
		ld	a,[de]
		or	a
		jr	z,.bok
		ld	a,c
		and	16
		ld	b,a
.bok:		ld	a,[de]
		or	b
		dec	hl
		cp	[hl]
		ld	[hli],a
		jr	z,.noreset
		ld	[hl],0
.noreset:	pop	af
.noback:	ld	e,a
		ld	a,c
		ld	d,GROUP_CREW
		ld	bc,IDX_CREW
		cp	5
		jr	c,.bcok
		ld	d,GROUP_BARREL
		ld	bc,IDX_BARREL
		cp	8
		jr	c,.bcok
		ld	d,GROUP_BOOM
		ld	bc,IDX_BOOM
		jr	z,.bcok
		ld	d,GROUP_SCORE
		ld	bc,IDX_SCORE
		cp	9
		jr	z,.bcok
		ld	d,GROUP_ERIC
		ld	bc,IDX_ERIC
.bcok:		push	de
		ld	a,e
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		inc	hl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		inc	hl
		ld	a,[hld]
		cp	e
		jr	z,.nodown
		inc	e
		ld	[hl],e
		cp	e
		jr	nz,.nodown
		dec	hl
		dec	hl
		ld	[hl],0	;reset counter
		dec	hl
		inc	[hl]	;move to next state, we're in position
.nodown:
		pop	af
		call	AddFigure
		pop	hl
		pop	bc
		jp	.cont

;bc=0,1 or 2
manoverboard:
		ld	hl,shippositions
		add	hl,bc
		ld	b,[hl]


		ld	hl,ship_men
		ld	de,MAN_SIZE
		ld	c,MAXMEN
.find:		ld	a,[hl]
		and	15
		cp	1
		jr	z,.maybe
		cp	5
		jr	nz,.next
.maybe:		inc	hl
		inc	hl
		ld	a,[hld]
		dec	hl
		cp	b
		jr	z,.found
.next:		add	hl,de
		dec	c
		jr	nz,.find
		ret
.found:
		push	hl
		ld	hl,ship_men
		ld	c,MAXMEN
		xor	a
		ldh	[hTmpLo],a
.ruleout:	ld	a,[hl]
		and	15
		jr	z,.next2
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		ld	e,[hl]
		dec	hl
		dec	hl
		ld	a,[hld]
		dec	hl
		cp	b
		jr	nz,.next2
		ld	d,0
		ld	a,e
		cp	SHIPDOWN1
		jr	c,.dok
		ld	d,1
		jr	z,.dok
		ld	d,2
		cp	SHIPDOWN2
		jr	z,.dok
		ld	d,4
.dok:		ldh	a,[hTmpLo]
		or	d
		ldh	[hTmpLo],a
.next2:		ld	de,MAN_SIZE
		add	hl,de
		dec	c
		jr	nz,.ruleout
		pop	hl

		inc	[hl]
		inc	hl
		ld	[hl],0
		inc	hl
		inc	hl
		inc	hl
		ldh	a,[hTmpLo]
		ld	d,a
.rnd:		call	random
		and	3
		jr	z,.rnd
		ld	b,a
		ld	e,d
.shr:		srl	e
		dec	a
		jr	nz,.shr
		jr	c,.rnd
		ld	a,b
		dec	a
		add	LOW(shipdowns)
		ld	e,a
		ld	a,0
		adc	HIGH(shipdowns)
		ld	d,a
		ld	a,[de]
		ld	[hl],a
		ret

MANHIT		EQU	10
shipcull:
		ld	a,[wMapXPos]
		and	$e0
		ld	l,a
		ld	a,[wMapXPos+1]
		ld	h,a
		ldh	a,[pin_x]
		sub	l
		ld	l,a
		ldh	a,[pin_x+1]
		sbc	h
		inc	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	MANHIT
		ld	d,a
		ld	a,[wMapYPos]
		and	$e0
		ld	l,a
		ld	a,[wMapYPos+1]
		ld	h,a
		ldh	a,[pin_y]
		sub	l
		ld	l,a
		ldh	a,[pin_y+1]
		sbc	h
		inc	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	MANHIT
		ld	e,a

		ld	hl,ship_men
		ld	a,MAXMEN
.ctlp:		ldh	[hTmpLo],a
		push	de
		ld	a,[hl]
		and	15
		cp	3
		jr	z,.cull
		cp	7
		jr	nz,.next2
.cull:		inc	hl
		inc	hl
		inc	hl
		ld	a,[hli]
		cp	[hl]
		dec	hl
		dec	hl
		ld	a,[hli]
		jr	nz,.nope
		sub	d
		jr	c,.nope
		cp	MANHIT*2
		jr	nc,.nope
		ld	a,[hl]
		sub	e
		jr	c,.nope
		cp	MANHIT*2
		jr	nc,.nope
		dec	hl
		dec	hl
		ld	[hl],0
		dec	hl
		ld	a,[hl]
		and	15
		cp	3
		jr	z,.savedman
 push	hl
 call	RandomVel
 pop	hl
		ld	a,[ship_newball]
		inc	a
		ld	[ship_newball],a
		cp	BARRELSPERBALL
		jr	c,.nonewball
		xor	a
		ld	[ship_newball],a
		call	shipnewball
.nonewball:	ld	a,8
		jr	.aok
.savedman:	push	hl
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.notdone
		ld	a,HOLDTIME
		ld	[any_done],a
.notdone:
		ld	a,FX_SHIPSAVE
		call	InitSfx
		pop	hl
		call	Credit1
		ld	a,9
;		bit	4,[hl]
;		jr	z,.aok
;		ld	a,0
.aok:		ld	[hl],a
		jr	.next2
.nope:		inc	hl
		inc	hl
		jr	.next

.next2:		ld	bc,MAN_SIZE
		add	hl,bc
.next:
		pop	de
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.ctlp
		ret


shipcount:	ld	hl,ship_counts
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ld	hl,ship_men
		ld	c,MAXMEN
.countlp:	ld	a,[hl]
		and	15
		jr	z,.next
		ld	b,3
		cp	1
		jr	z,.bok
		cp	5
		jr	z,.bok
		ld	b,1
.bok:		inc	hl
		inc	hl
		ld	a,[hld]
		dec	hl
		ld	de,ship_counts
		cp	SHIPPOS1
		jr	z,.deok
		inc	de
		cp	SHIPPOS2
		jr	z,.deok
		inc	de
.deok:		ld	a,[de]
		add	b
		ld	[de],a
.next:		ld	de,MAN_SIZE
		add	hl,de
		dec	c
		jr	nz,.countlp

		ld	a,[ship_counts+1]
		cp	2
		ld	b,SHIPPOS2
		call	c,shipnewman

		ld	a,[ship_counts]
		cp	2
		ld	b,SHIPPOS1
		call	c,shipnewman

		ld	a,[ship_counts+2]
		cp	2
		ld	b,SHIPPOS3
		call	c,shipnewman
		ret
shipnewman:	ld	hl,ship_men
		ld	de,MAN_SIZE
		ld	c,MAXMEN
.find:		ld	a,[hl]
		or	a
		jr	z,.found
		add	hl,de
		dec	c
		jr	nz,.find
		ret
.found:
		ld	a,[ship_tosave]
		cp	2
		jr	nc,.crew
		or	a
		ret	z
		ld	a,[any_count2]
		or	a
		ret	nz
		ld	a,[any_count2+1]
		cp	1
		ret	nz
		ld	c,17
		jr	.dec
.crew:		call	random
		and	3
		jr	z,.barrel
		ld	c,1
.dec:		ld	a,[ship_tosave]
		dec	a
		ld	[ship_tosave],a
		jr	.gotc
.barrel:	ld	c,5
.gotc:		ld	[hl],c		;1,5,17
		inc	hl
		xor	a
		ld	[hli],a
		ld	[hl],b
		inc	hl
		ld	a,SHIPY
		ld	[hli],a
		ld	[hl],a
		ret

shipnewball:	push	hl
		call	CountBalls
		pop	hl
		cp	2
		ret	nc
		push	hl
		inc	hl
		inc	hl
		ld	d,[hl]
		inc	hl
		ld	b,[hl]

		ld	c,0
		ld	e,c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	d
		rr	e
		srl	d
		rr	e
		srl	d
		rr	e
		call	random
		and	63
		sub	32
		ld	h,a
		call	random
		and	63
		sub	32
		ld	l,a
		call	AddBall
		ld	a,FX_SECONDBALL
		call	InitSfx
		pop	hl
		ret


shipcollisions:
		dw	0

;***********************************************************************
;***********************************************************************
