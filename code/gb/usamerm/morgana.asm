; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** morgana.asm                                                           **
; **                                                                       **
; ** Created : 20000425 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 11

GROUP_CLOAK	EQU	2
GROUP_BOLT	EQU	3

morg_eel1	EQUS	"wTemp1024+00" ;2 bytes
morg_eel2	EQUS	"wTemp1024+02" ;2 bytes
morg_bolt1	EQUS	"wTemp1024+04" ;5 bytes
morg_bolt2	EQUS	"wTemp1024+09" ;5 bytes
morg_bolt3	EQUS	"wTemp1024+14" ;5 bytes
morg_damage	EQUS	"wTemp1024+19"
morg_tcount	EQUS	"wTemp1024+20"
morg_rollup	EQUS	"wTemp1024+21" ;2 bytes
morg_react	EQUS	"wTemp1024+23" ;2 bytes
morg_fire	EQUS	"wTemp1024+25"
morg_exit	EQUS	"wTemp1024+26"

morganamaplist:
		db	21
		dw	IDX_MORGBACKRGB
		dw	IDX_MORGBACKMAP


morganainfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(morganaprocess)	;wPinJmpProcess
		dw	morganaprocess
		db	BANK(morganasprites)	;wPinJmpSprites
		dw	morganasprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(morghitbolt)	;wPinJmpPerBall
		dw	morghitbolt
		db	BANK(morganahit)	;wPinJmpHitBumper
		dw	morganahit
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



MorganaInit::
		ld	hl,morganainfo
		call	SetPinInfo

		ld	a,TIME_MORGANA
		call	SetTime

		ld	a,24
		ld	[morg_damage],a

		ld	a,NEED_MORGANA
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_CLOAK
		call	AddPalette
		ld	hl,PAL_BOLT
		call	AddPalette

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap
		ld	hl,IDX_UDET000CHG
		call	MakeChanges

		ld	hl,morganamaplist
		call	NewLoadMap
		ld	hl,IDX_MORGANABSMAP
		call	SecondHalf

		call	SubAddBall

		ld	hl,wStates
		ld	bc,64
		ld	a,$ff
		call	MemFill

 ld de,$0000
 call morgnewstate
 ld de,$0001
 call morgnewstate
 ld de,$0102
 call morgnewstate
 ld de,$0203
 call morgnewstate
 ld de,$0304
 call morgnewstate
 ld de,$0405
 call morgnewstate
 ld de,$0506
 call morgnewstate


		ld	hl,morganacollisions
		jp	MakeCollisions

morganaprocess:

		call	morganafire
		call	morganareact
		call	morganarollup
		call	morganatentacles

		call	SubEnd
		call	AnyDecTime

		ld	hl,morg_eel1
		call	eelstart
		ld	hl,morg_eel2
		call	eelstart

		ret

eelstart:	ld	a,[hl]
		or	a
		ret	nz
		ld	[hl],1
		inc	hl
		ld	[hl],0
		ret


morghitbolt:	ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		dec	a
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
		ld	hl,morg_bolt1
		call	checkbolt
		ret	c
		ld	hl,morg_bolt2
		call	checkbolt
		ret	c
		ld	hl,morg_bolt3
		call	checkbolt
		ret

BOLTMAX		EQU	10
checkbolt:	ld	a,[hl]
		or	a
		ret	z
		inc	hl
		ld	a,[hli]
		sub	d
		jr	nc,.nonegx
		cpl
		inc	a
.nonegx:	cp	BOLTMAX
		ret	nc
		ld	b,a
		ld	a,[hld]
		sub	e
		jr	nc,.nonegy
		cpl
		inc	a
.nonegy:	cp	BOLTMAX
		ret	nc
		dec	hl
		ld	[hl],0
		call	RandomVel
		scf
		ret

morganahit:
		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	90
		jp	nc,.flippers
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	44
		jr	c,.lefteel
		cp	132
		jr	nc,.righteel
.morgana:	ld	a,[morg_damage]
		or	a
		jr	z,.moredamage
		dec	a
		ld	[morg_damage],a
		call	Credit2
		ld	a,[morg_damage]
		ld	c,a
		and	3
		jr	nz,.nodamage
		call	Credit1
		call	AnyDec2
		ld	a,[morg_rollup]
		or	a
		jr	z,.norollup
		push	bc
		ld	e,a
		ld	d,8
		call	morgnewstate
		pop	bc
.norollup:	ld	a,c
		srl	a
		srl	a
		inc	a
		ld	[morg_rollup],a
		xor	a
		ld	[morg_rollup+1],a
		ld	a,FX_BEASTCRUSH
		jr	.crushed
.nodamage:	ld	A,FX_BEASTHIT
.crushed:	call	InitSfx
		ld	a,2
		call	morgact
		xor	a
		ld	[morg_fire],a
		jr	.flippers
.moredamage:	ld	a,[morg_exit]
		inc	a
		ld	[morg_exit],a
		cp	3
		jr	c,.flippers
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	z,.nocredit
		call	Credit1
		call	AnyDec2
		ld	a,HOLDTIME
		ld	[any_done],a
.nocredit:	jr	.flippers


.lefteel:	ld	de,morg_eel1
		ld	hl,IDX_FLTDT001CHG
		jr	.eels
.righteel:	ld	de,morg_eel2
		ld	hl,IDX_FLTDT002CHG
.eels:		ld	a,4
		ld	[de],a
		inc	de
		xor	a
		ld	[de],a
;		call	UndoChanges
.flippers:	ret


morganasprites:
		call	SubFlippers
		ld	hl,morg_bolt1
		call	morgbolts
		ld	hl,morg_bolt2
		call	morgbolts
		ld	hl,morg_bolt3
		call	morgbolts
		ld	hl,morg_eel1
		call	morgeels
		ld	hl,morg_eel2
		call	morgeels
		ret



morgeellists:	dw	morgeelenter	;1
		dw	morgeelswim	;2
		dw	morgeelfire	;3
		dw	morgeelhit	;4

morgeelenter:	db	18,-2
morgeelswim:
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	-3
morgeelfire:	db	23,23,23,23,23,23,22
		db	-2
morgeelhit:	db	22,24,24,24,24,-2


morgeels:	ld	a,[hl]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(morgeellists)
		ld	c,a
		ld	a,0
		adc	HIGH(morgeellists)
		ld	b,a
		ld	a,[bc]
		push	af
		inc	bc
		ld	a,[bc]
		ld	b,a
		pop	af
		ld	c,a
		inc	hl
		ld	a,[hl]
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,[wTime]
		and	1
		ld	a,0
		jr	nz,.aok
		inc	a
.aok:		add	[hl]
		ld	[hl],a
		ld	a,[bc]
		add	a
		jr	c,.new
		jr	nz,.nonew
.new:		ld	a,[bc]
		cpl
		inc	a
		ld	[hl],0
		dec	hl
		ld	b,[hl]
		ld	[hl],a
		or	a
		ret	z
		cp	2
		jr	z,.collision
		cp	3
		jr	nz,morgeels
		ld	de,morg_eel2
		ld	a,l
		cp	e
		ld	de,$1012
		ld	bc,$0102
		jr	c,.bcdeok
		ld	d,$90
		ld	b,-1
.bcdeok:
		call	random
		and	7
		call	z,morgaddbolt
.collision:	push	hl
		ld	b,a
		ld	de,morg_eel2
		ld	a,l
		cp	e
		ld	hl,IDX_FLTDT001CHG
		jr	c,.hlok
		ld	hl,IDX_FLTDT002CHG
.hlok:		ld	a,b
		cp	2
		jr	z,.on
;		call	UndoChanges
		jr	.off
.on:
;		call	MakeChanges
.off:		pop	hl
		jr	morgeels

.nonew:		ld	a,[bc]
		sub	2
		add	IDX_CLOAK&255
		ld	c,a
		ld	a,0
		adc	IDX_CLOAK>>8
		ld	b,a
		ld	a,GROUP_CLOAK
		ld	de,morg_eel2
		ld	a,l
		cp	e
		ld	e,$0e
		ld	d,$18
		ld	a,GROUP_CLOAK
		jr	c,.deaok
		ld	d,$88
		ld	a,GROUP_CLOAK|$80
.deaok:		jp	AddFigure

morgaddbolt:
		push	hl
		xor	a
		ld	hl,morg_bolt1
		cp	[hl]
		jr	z,.freebolt
		ld	hl,morg_bolt2
		cp	[hl]
		jr	z,.freebolt
		ld	hl,morg_bolt3
		cp	[hl]
		jr	z,.freebolt
		jr	.nope
.freebolt:	ld	a,1
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		ld	a,b
		ld	[hli],a
		ld	a,c
		ld	[hli],a
.nope:		pop	hl
		ret

morgbolts:	ld	a,[hl]
		or	a
		ret	z
		inc	a
		cp	1+3*4
		jr	c,.aok
		ld	a,1
.aok:		ld	[hli],a
		dec	a
		srl	a
		srl	a
		add	IDX_BOLT&255
		ld	c,a
		ld	a,0
		adc	IDX_BOLT>>8
		ld	b,a
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		inc	hl
		ld	a,[hli]
		add	d
		ld	d,a
		ld	a,[hld]
		add	e
		ld	e,a
		dec	hl
		ld	[hl],e
		dec	hl
		ld	[hl],d
		dec	hl
		ld	a,d
		cp	180
		jr	nc,.kill
		ld	a,e
		cp	150
		jr	nc,.kill
		ld	a,GROUP_BOLT
		jp	AddFigure
.kill:		ld	[hl],0
		ret

morganacollisions:
		dw	0

morgrolluplist:	db	5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,-1
morganarollup:
		ld	a,[morg_rollup]
		or	a
		ret	z
		ld	e,a
		ld	a,[morg_rollup+1]
		ld	c,a
		inc	a
		ld	[morg_rollup+1],a
		ld	b,0
		ld	hl,morgrolluplist
		add	hl,bc
		ld	a,[hl]
		add	a
		jr	c,.end
		ld	d,[hl]
		jp	morgnewstate
.end:		xor	a
		ld	[morg_rollup],a
		ret

morgact:		ld	d,a
		ld	e,0
		call	morgnewstate
		ld	a,30
		ld	[morg_react],a
		ret

morganareact:	ld	a,[morg_react]
		or	a
		ret	z
		dec	a
		ld	[morg_react],a
		ret	nz
		ld	de,0
		jp	morgnewstate

morganafire:	ld	a,[morg_fire]
		inc	a
		ld	[morg_fire],a
		cp	90
		ret	c
		xor	a
		ld	[morg_fire],a
		ld	a,1
		call	morgact
		ld	de,$4430
		ld	bc,$0001
		call	morgaddbolt
		ld	de,$4430
		ld	bc,$0101
		call	morgaddbolt
		ld	de,$4430
		ld	bc,$ff01
		call	morgaddbolt
		ret


morganatentacles:

		ld	a,[wTime]
		and	7
		cp	6
		jr	nc,.skip
		ld	b,a
		inc	a
		ld	e,a
		sla	b
		sla	b
		ld	a,[morg_damage]
		cp	b
		jr	z,.skip
		jr	c,.skip
		ld	a,[morg_tcount]
		ld	d,a
		call	morgnewstate
.skip:
.nextt:		ld	a,[morg_tcount]
		inc	a
		cp	5
		jr	c,.aok
		xor	a
.aok:		ld	[morg_tcount],a
		ret




;e=state #
;d=new value
morgnewstate:	ld	a,d
		ld	d,0
		ld	hl,wStates
		add	hl,de
		cp	[hl]
		ret	z
		ld	[hl],a
		ld	hl,morgstatestarts
		add	hl,de
		ld	c,a
		ld	a,[hl]
		add	c
		ld	l,a
		ld	e,a
		ld	h,d
		add	hl,hl
		add	hl,hl
		add	hl,de
		add	hl,de
		ld	de,morgstatelist
		add	hl,de
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
		jp	BGRect

morgstatestarts:
		db	0	;0,morgana
		db	3	;upper right tentacle
		db	12	;upper left tentacle
		db	21	;middle right tentacle
		db	30	;middle left tentacle
		db	39	;bottom right tentacle
		db	48	;bottom left tentacle

;xsize,ysize,xsrc,ysrc,xdest,ydest
morgstatelist:	db	10,8,0,0,6,0	;0,morgana normal
		db	10,8,10,0,6,0	;1,morgana attacking
		db	10,8,0,8,6,0	;2,morgana laughing
		db	4,2,0,16,14,4	;3,upper right tentacle
		db	4,2,4,16,14,4	;4,upper right tentacle
		db	4,2,8,16,14,4	;5,upper right tentacle
		db	4,2,12,16,14,4	;6,upper right tentacle
		db	4,2,16,16,14,4	;7,upper right tentacle
		db	4,2,20,16,14,4	;8,upper right tentacle
		db	4,2,0,18,14,4	;9,upper right tentacle
		db	4,2,4,18,14,4	;10,upper right tentacle
		db	4,2,8,18,14,4	;11,upper right tentacle

		db	4,2,12,18,4,4	;12,upper left tentacle
		db	4,2,16,18,4,4	;13,upper left tentacle
		db	4,2,20,18,4,4	;14,upper left tentacle
		db	4,2,0,20,4,4	;15,upper left tentacle
		db	4,2,4,20,4,4	;16,upper left tentacle
		db	4,2,8,20,4,4	;17,upper left tentacle
		db	4,2,12,20,4,4	;18,upper left tentacle
		db	4,2,16,20,4,4	;19,upper left tentacle
		db	4,2,20,20,4,4	;20,upper left tentacle

		db	4,3,0,22,14,6	;21,middle right tentacle
		db	4,3,4,22,14,6	;22,middle right tentacle
		db	4,3,8,22,14,6	;23,middle right tentacle
		db	4,3,12,22,14,6	;24,middle right tentacle
		db	4,3,16,22,14,6	;25,middle right tentacle
		db	4,3,20,22,14,6	;26,middle right tentacle
		db	4,3,0,25,14,6	;27,middle right tentacle
		db	4,3,4,25,14,6	;28,middle right tentacle
		db	4,3,8,25,14,6	;29,middle right tentacle

		db	4,3,12,25,4,6	;30,middle left tentacle
		db	4,3,16,25,4,6	;31,middle left tentacle
		db	4,3,20,25,4,6	;32,middle left tentacle
		db	4,3,0,28,4,6	;33,middle left tentacle
		db	4,3,4,28,4,6	;34,middle left tentacle
		db	4,3,8,28,4,6	;35,middle left tentacle
		db	4,3,12,28,4,6	;36,middle left tentacle
		db	4,3,16,28,4,6	;37,middle left tentacle
		db	4,3,20,28,4,6	;38,middle left tentacle

		db	3,4,0,31,11,8	;39,bottom right tentacle
		db	3,4,3,31,11,8	;40,bottom right tentacle
		db	3,4,6,31,11,8	;41,bottom right tentacle
		db	3,4,9,31,11,8	;42,bottom right tentacle
		db	3,4,12,31,11,8	;43,bottom right tentacle
		db	3,4,15,31,11,8	;44,bottom right tentacle
		db	3,4,18,31,11,8	;45,bottom right tentacle
		db	3,4,21,31,11,8	;46,bottom right tentacle
		db	3,4,0,35,11,8	;47,bottom right tentacle

		db	3,4,3,35,8,8	;48,bottom left tentacle
		db	3,4,6,35,8,8	;49,bottom left tentacle
		db	3,4,9,35,8,8	;50,bottom left tentacle
		db	3,4,12,35,8,8	;51,bottom left tentacle
		db	3,4,15,35,8,8	;52,bottom left tentacle
		db	3,4,18,35,8,8	;53,bottom left tentacle
		db	3,4,21,35,8,8	;54,bottom left tentacle
		db	3,4,10,8,8,8	;55,bottom left tentacle
		db	3,4,13,8,8,8	;56,bottom left tentacle


;***********************************************************************
;***********************************************************************

