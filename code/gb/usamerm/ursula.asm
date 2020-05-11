; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** ursula.asm                                                            **
; **                                                                       **
; ** Created : 20000328 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 11

GROUP_EEL	EQU	2
GROUP_BOLT	EQU	3

urs_eel1	EQUS	"wTemp1024+00" ;2 bytes
urs_eel2	EQUS	"wTemp1024+02" ;2 bytes
urs_bolt1	EQUS	"wTemp1024+04" ;5 bytes
urs_bolt2	EQUS	"wTemp1024+09" ;5 bytes
urs_bolt3	EQUS	"wTemp1024+14" ;5 bytes
urs_damage	EQUS	"wTemp1024+19"
urs_tcount	EQUS	"wTemp1024+20"
urs_rollup	EQUS	"wTemp1024+21" ;2 bytes
urs_react	EQUS	"wTemp1024+23" ;2 bytes
urs_fire	EQUS	"wTemp1024+25"
urs_exit	EQUS	"wTemp1024+26"

ursulamaplist:
		db	21
		dw	IDX_UBACKRGB
		dw	IDX_UBACKMAP


ursulainfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(ursulaprocess)	;wPinJmpProcess
		dw	ursulaprocess
		db	BANK(ursulasprites)	;wPinJmpSprites
		dw	ursulasprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(urshitbolt)	;wPinJmpPerBall
		dw	urshitbolt
		db	BANK(ursulahit)		;wPinJmpHitBumper
		dw	ursulahit
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



ursulainit::
		ld	hl,ursulainfo
		call	SetPinInfo

		ld	a,TIME_URSULA
		call	SetTime

		ld	a,24
		ld	[urs_damage],a

		ld	a,NEED_URSULA
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_EEL
		call	AddPalette
		ld	hl,PAL_BOLT
		call	AddPalette

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap
		ld	hl,IDX_UDET000CHG
		call	MakeChanges

		ld	hl,ursulamaplist
		call	NewLoadMap
		ld	hl,IDX_URSULABSMAP
		call	SecondHalf

		call	SubAddBall

		ld	hl,wStates
		ld	bc,64
		ld	a,$ff
		call	MemFill

 ld de,$0000
 call ursnewstate
 ld de,$0001
 call ursnewstate
 ld de,$0102
 call ursnewstate
 ld de,$0203
 call ursnewstate
 ld de,$0304
 call ursnewstate
 ld de,$0405
 call ursnewstate
 ld de,$0506
 call ursnewstate


		ld	hl,ursulacollisions
		jp	MakeCollisions

ursulaprocess:

		call	ursulafire
		call	ursulareact
		call	ursularollup
		call	ursulatentacles

		call	SubEnd
		call	AnyDecTime

		ld	hl,urs_eel1
		call	eelstart
		ld	hl,urs_eel2
		call	eelstart

		ret

eelstart:	ld	a,[hl]
		or	a
		ret	nz
		ld	[hl],1
		inc	hl
		ld	[hl],0
		ret


urshitbolt:	ldh	a,[pin_x]
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
		ld	hl,urs_bolt1
		call	checkbolt
		ret	c
		ld	hl,urs_bolt2
		call	checkbolt
		ret	c
		ld	hl,urs_bolt3
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


ursulahit:
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
.ursula:	ld	a,[urs_damage]
		or	a
		jr	z,.moredamage
		dec	a
		ld	[urs_damage],a
		call	Credit2
		ld	a,[urs_damage]
		ld	c,a
		and	3
		jr	nz,.nodamage
		call	Credit1
		call	AnyDec2
		ld	a,[urs_rollup]
		or	a
		jr	z,.norollup
		push	bc
		ld	e,a
		ld	d,8
		call	ursnewstate
		pop	bc
.norollup:	ld	a,c
		srl	a
		srl	a
		inc	a
		ld	[urs_rollup],a
		xor	a
		ld	[urs_rollup+1],a
		ld	a,FX_BEASTCRUSH
		jr	.crushed
.nodamage:	ld	A,FX_BEASTHIT
.crushed:	call	InitSfx
		ld	a,2
		call	ursact
		xor	a
		ld	[urs_fire],a
		jr	.flippers
.moredamage:	ld	a,[urs_exit]
		inc	a
		ld	[urs_exit],a
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
.lefteel:	ld	de,urs_eel1
		ld	hl,IDX_FLTDT001CHG
		jr	.eels
.righteel:	ld	de,urs_eel2
		ld	hl,IDX_FLTDT002CHG
.eels:		ld	a,4
		ld	[de],a
		inc	de
		xor	a
		ld	[de],a
;		call	UndoChanges
.flippers:	ret

ursulasprites:
		call	SubFlippers
		ld	hl,urs_bolt1
		call	ursbolts
		ld	hl,urs_bolt2
		call	ursbolts
		ld	hl,urs_bolt3
		call	ursbolts
		ld	hl,urs_eel1
		call	urseels
		ld	hl,urs_eel2
		call	urseels
		ret



urseellists:	dw	urseelenter	;1
		dw	urseelswim	;2
		dw	urseelfire	;3
		dw	urseelhit	;4

urseelenter:	db	18,-2
urseelswim:
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	18,18,19,19,20,20,21,21,22,22
		db	-3
urseelfire:	db	23,23,23,23,23,23,22
		db	-2
urseelhit:	db	22,24,24,24,24,-2

urseels:	ld	a,[hl]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(urseellists)
		ld	c,a
		ld	a,0
		adc	HIGH(urseellists)
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
		jr	nz,urseels
		ld	de,urs_eel2
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
		call	z,ursaddbolt
.collision:	push	hl
		ld	b,a
		ld	de,urs_eel2
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
.on:	;		call	MakeChanges
.off:		pop	hl
		jr	urseels

.nonew:		ld	a,[bc]
		sub	2
		add	IDX_EEL&255
		ld	c,a
		ld	a,0
		adc	IDX_EEL>>8
		ld	b,a
		ld	a,GROUP_EEL
		ld	de,urs_eel2
		ld	a,l
		cp	e
		ld	e,$07
		ld	d,$10
		ld	a,GROUP_EEL
		jr	c,.deaok
		ld	d,$90
		ld	a,GROUP_EEL|$80
.deaok:		jp	AddFigure

ursaddbolt:
		push	hl
		xor	a
		ld	hl,urs_bolt1
		cp	[hl]
		jr	z,.freebolt
		ld	hl,urs_bolt2
		cp	[hl]
		jr	z,.freebolt
		ld	hl,urs_bolt3
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

ursbolts:	ld	a,[hl]
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

ursulacollisions:
		dw	0

ursrolluplist:	db	5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,-1
ursularollup:
		ld	a,[urs_rollup]
		or	a
		ret	z
		ld	e,a
		ld	a,[urs_rollup+1]
		ld	c,a
		inc	a
		ld	[urs_rollup+1],a
		ld	b,0
		ld	hl,ursrolluplist
		add	hl,bc
		ld	a,[hl]
		add	a
		jr	c,.end
		ld	d,[hl]
		jp	ursnewstate
.end:		xor	a
		ld	[urs_rollup],a
		ret

ursact:		ld	d,a
		ld	e,0
		call	ursnewstate
		ld	a,30
		ld	[urs_react],a
		ret

ursulareact:	ld	a,[urs_react]
		or	a
		ret	z
		dec	a
		ld	[urs_react],a
		ret	nz
		ld	de,0
		jp	ursnewstate

ursulafire:	ld	a,[urs_fire]
		inc	a
		ld	[urs_fire],a
		cp	90
		ret	c
		xor	a
		ld	[urs_fire],a
		ld	a,1
		call	ursact
		ld	de,$4430
		ld	bc,$0001
		call	ursaddbolt
		ld	de,$4430
		ld	bc,$0101
		call	ursaddbolt
		ld	de,$4430
		ld	bc,$ff01
		call	ursaddbolt
		ret


ursulatentacles:

		ld	a,[wTime]
		and	7
		cp	6
		jr	nc,.skip
		ld	b,a
		inc	a
		ld	e,a
		sla	b
		sla	b
		ld	a,[urs_damage]
		cp	b
		jr	z,.skip
		jr	c,.skip
		ld	a,[urs_tcount]
		ld	d,a
		call	ursnewstate
.skip:
.nextt:		ld	a,[urs_tcount]
		inc	a
		cp	5
		jr	c,.aok
		xor	a
.aok:		ld	[urs_tcount],a
		ret




;e=state #
;d=new value
ursnewstate:	ld	a,d
		ld	d,0
		ld	hl,wStates
		add	hl,de
		cp	[hl]
		ret	z
		ld	[hl],a
		ld	hl,ursstatestarts
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
		ld	de,ursstatelist
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

ursstatestarts:
		db	0	;0,ursula
		db	3	;upper right tentacle
		db	12	;upper left tentacle
		db	21	;middle right tentacle
		db	30	;middle left tentacle
		db	39	;bottom right tentacle
		db	48	;bottom left tentacle

;xsize,ysize,xsrc,ysrc,xdest,ydest
ursstatelist:	db	10,8,0,0,6,0	;0,ursula normal
		db	10,8,10,0,6,0	;1,ursula attacking
		db	10,8,0,8,6,0	;2,ursula laughing
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

