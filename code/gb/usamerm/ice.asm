; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** ICE.ASM                                                               **
; **                                                                       **
; ** Created : 20000217 by David Ashley                                    **
; **  File included in pin.asm                                             **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	03

MAXICEFALLS	EQU	6

ice_hitcounts	EQUS	"wTemp1024+00"	;17 bytes
ice_savecount	EQUS	"wTemp1024+17"
ice_falls	EQUS	"wTemp1024+18"	;5*MAXICEFALLS bytes

GROUP_ICEBITS	EQU	2

iceinfo:	db	BANK(icehit)		;wPinJmpHit
		dw	icehit
		db	BANK(iceprocess)	;wPinJmpProcess
		dw	iceprocess
		db	BANK(icesprites)	;wPinJmpSprites
		dw	icesprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
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

icemaplist:	db	21
		dw	IDX_ICEBACKRGB
		dw	IDX_ICEBACKMAP

IceInit::
		ld	hl,iceinfo
		call	SetPinInfo

		ld	a,TIME_ICECAVE
		call	SetTime

		ld	a,NEED_ICECAVE
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_ICEBITS
		call	AddPalette

		ld	hl,ice_falls
		ld	bc,MAXICEFALLS*5
		call	MemClear

		ld	hl,ice_hitcounts
		ld	bc,17
		ld	a,1
		call	MemFill
		ld	a,17
		ld	[ice_savecount],a

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap

		ld	hl,icemaplist
		call	NewLoadMap
		ld	hl,IDX_ICEBLOCKSMAP
		call	SecondHalf

		ld	hl,IDX_ICEDET000CHG
		ld	e,0
.icebglp:	push	hl
		push	de
		ld	a,e
		cp	2
		call	nz,MakeChanges
		pop	de
		pop	hl
		inc	hl
		inc	e
		ld	a,e
		cp	17
		jr	c,.icebglp
 call	SubAddBall

		ld	hl,icecollisions
		jp	MakeCollisions

iceprocess:
		call	SubEnd
		call	AnyDecTime

		ld	a,[ice_savecount]
		cp	2
		jr	nc,.notriton
		ld	a,[wTime]
		and	7
		jr	nz,.notriton
		ld	a,[ice_hitcounts+2]
		ld	d,a
		and	$80
		ld	e,a
		xor	d
		ld	c,1
.max:		inc	c
		inc	c
		inc	c
		cp	c
		jr	nc,.max
		inc	a
		cp	c
		jr	nz,.fine
		sub	3
.fine:		or	e
		ld	[ice_hitcounts+2],a
		xor	e
		dec	a
		ld	de,2
		call	icereact

.notriton:


		ld	a,[wTime]
		ld	b,17
.mod17:		sub	b
		jr	nc,.mod17
		add	b
		push	af
		call	.doice
		pop	af
		add	9
		cp	17
		jr	c,.aok
		sub	17
.aok:
.doice:		ld	e,a
		ld	d,0
		ld	hl,ice_hitcounts
		add	hl,de
		bit	7,[hl]
		ret	z
		call	Credit2
		res	7,[hl]
		ld	a,e
		cp	2
		jr	z,.triton
		inc	[hl]
		ld	a,[hl]
		push	af
		call	addbits
		call	addbits
		pop	af
		dec	a
		cp	2
		jr	c,.notgone
		push	de
		call	icereact
		pop	de
		jr	.gone
.triton:	ld	a,[hl]
		ld	c,1
.bigger3:	inc	c
		inc	c
		inc	c
		cp	c
		jr	nc,.bigger3
		ld	[hl],c
		ld	a,c		
		push	af
		call	addbits
		call	addbits
		call	addbits
		call	addbits
		push	de
		ld	a,FX_ICEHIT
		call	InitSfx
		pop	de
		pop	af
		cp	13
		ret	c
.h:		ld	a,HOLDTIME
		ld	[any_done],a
.gone:		call	Credit1
		call	AnyDec2
		ld	hl,ice_savecount
		dec	[hl]
		ld	hl,IDX_ICEDET000CHG
		add	hl,de
		call	UndoChanges
		ld	a,FX_ICEGONE
		call	InitSfx
		ld	a,[ice_savecount]
		dec	a
		ret	nz
		ld	hl,IDX_ICEDET002CHG
		jp	MakeChanges
.notgone:	call	icereact
		ld	a,FX_ICEHIT
		jp	InitSfx
;de=# of block
;a=what to put there
icereact:	ld	hl,icetable
		add	hl,de
		add	hl,de
		add	hl,de
		add	hl,de
		ld	e,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		push	bc	;where to put
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a	;bc = size
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	e,[hl]
		ld	d,a	;de = where from
		pop	hl
		jp	BGRect


icetable:	db	3,2
		dw	icetype1
		db	6,1
		dw	icetype1
		db	9,2
		dw	icetype2
		db	14,1
		dw	icetype1
		db	17,2
		dw	icetype1
		db	3,5
		dw	icetype1
		db	6,4
		dw	icetype1
		db	14,4
		dw	icetype1
		db	17,5
		dw	icetype1
		db	4,8
		dw	icetype1
		db	7,7
		dw	icetype1
		db	10,7
		dw	icetype1
		db	13,7
		dw	icetype1
		db	16,8
		dw	icetype1
		db	7,10
		dw	icetype1
		db	10,10
		dw	icetype1
		db	13,10
		dw	icetype1


icetype1:	db	2,2	;size
		db	0,6
		db	4,6
		db	8,6

icetype2:	db	4,4
		db	0,0
		db	0,0
		db	0,0
		db	4,0
		db	8,0
		db	12,0
		db	0,8
		db	4,8
		db	8,8
		db	0,12
		db	4,12
		db	8,12
		db	0,16
		db	4,16
		db	8,16


icepositions:	db	22,14
		db	46,9
		db	78,22
		db	110,9
		db	134,14
		db	22,38
		db	46,30
		db	110,30
		db	134,38
		db	30,62
		db	54,54
		db	78,54
		db	102,54
		db	126,62
		db	54,78
		db	78,78
		db	102,78

icehit:		ldh	a,[pin_x+1]
		ld	d,a
		ldh	a,[pin_x]
		add	a
		rl	d
		add	a
		rl	d
		add	a
		rl	d
		ldh	a,[pin_y+1]
		ld	e,a
		ldh	a,[pin_y]
		add	a
		rl	e
		add	a
		rl	e
		add	a
		rl	e
		ld	a,d
		sub	71
		jr	c,.notbig
		cp	35
		jr	nc,.notbig
		ld	a,e
		sub	15
		jr	c,.notbig
		cp	35
		jr	nc,.notbig
		ld	a,2
		jr	.b2hit
.notbig:	ld	hl,icepositions
		ld	c,17
.look:		ld	a,[hli]
		ld	b,a
		ld	a,e
		sub	[hl]
		jr	c,.next
		cp	21
		jr	nc,.next
		ld	a,d
		sub	b
		jr	c,.next
		cp	21
		jr	nc,.next
		ld	a,17
		sub	c
		jr	.b2hit
.next:		inc	hl
		dec	c
		jr	nz,.look
		ret
.b2hit:		ld	e,a
		ld	d,0
		cp	2
		jr	nz,.nottriton
		ld	a,[ice_savecount]
		dec	a
		ret	nz
.nottriton:	ld	hl,ice_hitcounts
		add	hl,de
		set	7,[hl]
		ret

icesprites:
		call	SubFlippers

		ld	hl,ice_falls
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
addbits:	ld	hl,ice_falls
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
		add	LOW(icepositions)
		ld	c,a
		ld	a,0
		adc	HIGH(icepositions)
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



icecollisions:
		dw	0

;***********************************************************************
;***********************************************************************

