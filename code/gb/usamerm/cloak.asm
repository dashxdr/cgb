; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** cloak.asm                                                             **
; **                                                                       **
; ** Created : 20000426 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

GROUP_EEL	EQU	2
GROUP_BOLT	EQU	3


cloak_eel1	EQUS	"wTemp1024+00" ;2 bytes
cloak_eel2	EQUS	"wTemp1024+02" ;2 bytes
cloak_bolt1	EQUS	"wTemp1024+04" ;5 bytes
cloak_bolt2	EQUS	"wTemp1024+09" ;5 bytes

cloakmaplist:
		db	21
		dw	IDX_RAYBACKRGB
		dw	IDX_RAYBACKMAP


cloakinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(cloakprocess)	;wPinJmpProcess
		dw	cloakprocess
		db	BANK(cloaksprites)	;wPinJmpSprites
		dw	cloaksprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(cloakhitbolt)	;wPinJmpPerBall
		dw	cloakhitbolt
		db	BANK(cloakhit)		;wPinJmpHitBumper
		dw	cloakhit
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



CloakInit::
		ld	hl,cloakinfo
		call	SetPinInfo

		ld	a,TIME_CLOAK
		call	SetTime

		ld	a,NEED_CLOAK
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_CLOAK
		call	AddPalette
		ld	hl,PAL_BOLT
		call	AddPalette

		ld	hl,IDX_FLTDT000PMP
		call	LoadPinMap

		ld	hl,cloakmaplist
		call	NewLoadMap

		call	SubAddBall

		ld	hl,cloakcollisions
		jp	MakeCollisions

cloakprocess:
		call	SubEnd
		call	AnyDecTime

		ld	hl,cloak_eel1
		call	eelstart
		ld	hl,cloak_eel2
		call	eelstart

		ret

eelstart:	ld	a,[hl]
		or	a
		ret	nz
		ld	[hl],1
		inc	hl
		ld	[hl],0
		ret


cloakhitbolt:	ldh	a,[pin_x]
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
		ld	hl,cloak_bolt1
		call	checkbolt
		ret	c
		ld	hl,cloak_bolt2
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


cloakhit:
		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	90
		jr	nc,.noeel
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	z,.nocredit
		call	Credit1
		ld	a,FX_CLOAKHIT
		call	InitSfx
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.nocredit
		ld	a,HOLDTIME
		ld	[any_done],a
.nocredit:	ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	80
		ld	de,cloak_eel1
		ld	hl,IDX_FLTDT001CHG
		jr	c,.hlok
		ld	de,cloak_eel2
		ld	hl,IDX_FLTDT002CHG
.hlok:		ld	a,4
		ld	[de],a
		inc	de
		xor	a
		ld	[de],a
		call	UndoChanges
.noeel:		ret


cloaksprites:
		call	SubFlippers
		ld	hl,cloak_eel1
		call	eels
		ld	hl,cloak_eel2
		call	eels
		ld	hl,cloak_bolt1
		call	bolts
		ld	hl,cloak_bolt2
		call	bolts
		ret



cloaklists:	dw	cloakenter		;1
		dw	cloakswim		;2
		dw	cloakfire		;3
		dw	cloakgothit		;4

cloakenter:
		db	2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9
		db	10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17
		db	-2
cloakswim:
		db	18,18,18,19,19,19,20,20,20,21,21,21,22,22,22

		db	-3

cloakfire:
		db	23,23,23,22
		db	-2

cloakgothit:
		db	22,22,24,24,24,24,24,23,23,23,25,25,25,26,26,26
		db	1,1,1,1,1,1,1,1,1,1,1,1,1
		db	1,1,1,1,1,1,1,1,1,1,1,1,1
		db	1,1,1,1,1,1,1,1,1,1,1,1,1
		db	-1

eels:		ld	a,[hl]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(cloaklists)
		ld	c,a
		ld	a,0
		adc	HIGH(cloaklists)
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
		jr	nz,eels
		push	af
		call	addbolt
		pop	af
.collision:	push	hl
		ld	b,a
		ld	de,cloak_eel2
		ld	a,l
		cp	e
		ld	hl,IDX_FLTDT001CHG
		jr	c,.hlok
		ld	hl,IDX_FLTDT002CHG
.hlok:
;		ld	a,b
;		cp	2
;		jr	z,.on
;		call	UndoChanges
;		jr	.off
.on:		call	MakeChanges
.off:		pop	hl
		jr	eels

.nonew:		ld	a,[bc]
		sub	2
		ret	c
		add	IDX_CLOAK&255
		ld	c,a
		ld	a,0
		adc	IDX_CLOAK>>8
		ld	b,a
		ld	a,GROUP_EEL
		ld	de,cloak_eel2
		ld	a,l
		cp	e
		ld	de,$3124
		ld	a,GROUP_EEL
		jr	c,.deaok
		ld	de,$6f24
		ld	a,GROUP_EEL|$80
.deaok:		jp	AddFigure

addbolt:
		ld	de,cloak_eel2
		ld	a,l
		cp	e
		ld	de,$3100
		jr	c,.deok
		ld	de,$6fff
.deok:		push	hl
		ld	hl,cloak_bolt1
		ld	a,[hl]
		or	a
		jr	z,.freebolt
		ld	hl,cloak_bolt2
		ld	a,[hl]
		or	a
		jr	z,.freebolt
		jr	.nope
.freebolt:	ld	[hl],1
		inc	hl
		ld	[hl],d
		inc	hl
		ld	[hl],70
		inc	hl
		call	random
		and	1
		add	e
		ld	[hli],a
		ld	[hl],1

.nope:		pop	hl
		ret

bolts:		ld	a,[hl]
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

cloakcollisions:
		dw	0

;***********************************************************************
;***********************************************************************
