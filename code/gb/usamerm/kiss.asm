; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** kiss.asm                                                              **
; **                                                                       **
; ** Created : 20000321 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 11

GROUP_FISH1	EQU	2
GROUP_FISH2	EQU	3
GROUP_FISH3	EQU	4

kiss_t1		EQUS	"wTemp1024+00"
kiss_t2		EQUS	"wTemp1024+01"
kiss_extra	EQUS	"wTemp1024+02"
kiss_on		EQUS	"wTemp1024+03"
kiss_rate	EQUS	"wTemp1024+04"
kiss_pos	EQUS	"wTemp1024+05"
kiss_fish	EQUS	"wTemp1024+06" ;8 bytes
kiss_toadd	EQUS	"wTemp1024+14"

kissmaplist:
		db	21
		dw	IDX_KISSBACKRGB
		dw	IDX_KISSBACKMAP


kissinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(kissprocess)	;wPinJmpProcess
		dw	kissprocess
		db	BANK(kisssprites)	;wPinJmpSprites
		dw	kisssprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(kisshit)		;wPinJmpHitBumper
		dw	kisshit
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(Nothing)		;wPinJmpLost
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUBDET001CHG	;lsubflippers
		dw	IDX_SUBDET009CHG	;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank



kissinit::
		ld	hl,kissinfo
		call	SetPinInfo

		ld	a,TIME_KISS
		call	SetTime

		ld	a,NEED_KISS
		call	SetCount2

		ld	a,20
		ld	[kiss_rate],a

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_PINKFSH
		call	AddPalette
		ld	hl,PAL_ORANGEFSH
		call	AddPalette
		ld	hl,PAL_KSFISH
		call	AddPalette

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap

		ld	a,$ff
		ld	[kiss_on],a

		ld	hl,kiss_fish
		ld	c,8
		xor	a
.fi:		ld	[hli],a
		inc	a
		dec	c
		jr	nz,.fi

		ld	hl,kissmaplist
		call	NewLoadMap

 call	SubAddBall

		ld	hl,kisscollisions
		jp	MakeCollisions

kissprocess:

		call	kisstryadd
		call	SubEnd
		call	AnyDecTime

		ld	a,[wTime]
		and	7
		ld	c,a
		ld	b,0
		ld	hl,kiss_fish
		add	hl,bc
		ld	b,[hl]
		ld	a,[hl]
		and	7
		ld	c,a
		xor	b
		ld	b,a
		inc	c
		ld	a,c
		and	7
		or	b
		ld	[hl],a

;		ld	hl,kiss_fish
;		ld	bc,$1806
;.checkdone:	ld	a,[hli]
;		cp	b
;		jr	c,.notdone
;		dec	c
;		jr	nz,.checkdone
;		call	AnyEnd
;.notdone:
		ret


MAXRAD		EQU	50

kisshit:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ldh	[hTmpLo],a
		sub	87
		jr	nc,.nonegx
		cpl
		inc	a
.nonegx:	ld	c,a
		ld	b,0
		call	bcmula
		ld	d,h
		ld	e,l

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ldh	[hTmpHi],a
		sub	58
		jr	nc,.nonegy
		cpl
		inc	a
.nonegy:	ld	c,a
		ld	b,0
		call	bcmula
		add	hl,de
		ld	a,l
		sub	(MAXRAD*MAXRAD)&255
		ld	a,h
		sbc	(MAXRAD*MAXRAD)>>8
;		ret	nc

		ld	b,$ff
		ld	a,[kiss_pos]
		and	3
		add	a
		ld	e,a
		ld	d,0
		ld	hl,fishpostab
		add	hl,de
		ld	e,0
.findclosest:	ldh	a,[hTmpLo]
		sub	[hl]
		jr	nc,.nonegx2
		cpl
		inc	a
.nonegx2:	ld	d,a
		inc	hl
		ldh	a,[hTmpHi]
		sub	[hl]
		jr	nc,.nonegy2
		cpl
		inc	a
.nonegy2:	add	d
		inc	hl
		cp	b
		jr	nc,.same
		ld	b,a
		ld	c,e
.same:		inc	hl
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		inc	e
		ld	a,e
		cp	6
		jr	nz,.findclosest
		ld	a,[kiss_pos]
		srl	a
		srl	a
		cpl
		add	6+1
		add	c
.mod6:		sub	6
		jr	nc,.mod6
		add	6
		ld	e,a
		ld	d,0
		ld	hl,kiss_fish
		add	hl,de
		bit	5,[hl]
		jr	nz,.giveextra
		ld	a,[hl]
		add	8
		cp	32
		jr	c,.done
		ld	a,[kiss_extra]
		or	a
		ret	nz
		call	CountBalls
		cp	2
		jr	nc,.credit2
		call	random
		and	7
		jr	nz,.credit2
		ld	a,e
		inc	a
		ld	[kiss_extra],a
		ld	a,[hl]
		add	8
		ld	[hl],a
.credit2:	ld	a,FX_KISSHIT
		call	InitSfx
		jp	Credit2
.done:		ld	[hl],a
		cp	24
		jp	c,.credit2
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.notdone
		ld	a,HOLDTIME
		ld	[any_done],a
.notdone:	call	Credit1
		ld	a,FX_KISSACTIVE
		jp	InitSfx


.giveextra:
		ld	a,[hl]
		and	7
		add	24
		ld	[hl],a
		ld	a,[kiss_extra]
		ld	[kiss_toadd],a
		xor	a
		ld	[kiss_extra],a
		ret

kisstryadd:	ld	a,[kiss_toadd]
		or	a
		ret	z
		call	kissanypos
		xor	a
		ld	[kiss_toadd],a
		ld	a,e
		ld	c,0
		ld	e,0
		srl	d
		rr	e
		srl	d
		rr	e
		srl	d
		rr	e
		add	12
		ld	b,a
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		ld	hl,0
		call	AddBall
		ld	a,FX_SECONDBALL
		jp	InitSfx


kisssprites:
		call	SubFlippers
		call	kissextra
		call	kissfish
		ret

kissextra:	ld	a,[kiss_extra]
		or	a
		ret	z
		call	kisspos
		ld	bc,IDX_BALL
		ld	a,GROUP_BALL
		jp	AddFigure

kisspos:	ld	a,[kiss_extra]
kissanypos:	dec	a
		add	a
		add	a
		ld	c,a
		ld	a,[kiss_pos]
		add	c
.mod24:		sub	24
		jr	nc,.mod24
		add	24
		add	a
		ld	c,a
		ld	b,0
		ld	hl,fishpostab
		add	hl,bc
		ld	a,[hli]
		sub	8
		ld	d,a
		ld	a,[hl]
		sub	24
		ld	e,a
		ret


kissfish:
		ld	a,[kiss_rate]
		ld	e,a
		ld	hl,kiss_t1
		inc	[hl]
		ld	a,[hl]
		cp	e
		jr	c,.noinc
		ld	[hl],0
		ld	hl,kiss_pos
		inc	[hl]
		ld	a,[hl]
		cp	24
		jr	c,.mok
		xor	a
		ld	[hl],a
.mok:
.noinc:
		ld	hl,kiss_fish
		ld	a,[kiss_pos]
		call	fish
		call	fish
		call	fish
		call	fish
		call	fish
		call	fish
		ld	a,[kiss_pos]
		and	3
		ld	c,a
		ld	a,[kiss_on]
		cp	c
		ret	z
		ld	b,0
		cp	4
		jr	nc,.skip
		push	bc
		ld	c,a
		ld	hl,IDX_KSDET000CHG
		add	hl,bc
		call	UndoChanges
		pop	bc
.skip:		ld	a,c
		ld	[kiss_on],a
		ld	hl,IDX_KSDET000CHG
		add	hl,bc
		jp	MakeChanges


fish:		push	af
		push	hl
		ld	e,a
		ld	a,[hl]
		push	af
		sub	16
		jr	nc,.aok
		and	7
.aok:		add	IDX_KSFISH&255
		ld	c,a
		ld	a,0
		adc	IDX_KSFISH>>8
		ld	b,a
		ld	d,0
		ld	hl,fishpostab
		add	hl,de
		add	hl,de
		ld	a,[hli]
		sub	8
		ld	d,a
		ld	a,[hl]
		sub	8
		ld	e,a
		pop	af
		ld	h,GROUP_FISH1
		cp	8
		jr	c,.hok
		inc	h
		cp	16
		jr	c,.hok
		inc	h
.hok:		ld	a,h
		call	AddFigure
		pop	hl
		inc	hl
		pop	af
		add	4
		cp	24
		ret	c
		sub	24
		ret



fishpostab:	db	93,10
		db	103,13
		db	112,18
		db	120,26
		db	125,35
		db	128,45
		db	128,56
		db	125,66
		db	120,75
		db	113,83
		db	104,88
		db	93,91
		db	83,91
		db	73,86
		db	63,83
		db	56,76
		db	50,67
		db	48,56
		db	47,46
		db	50,36
		db	55,26
		db	63,19
		db	72,13
		db	82,11


kisscollisions:
		dw	0

;***********************************************************************
;***********************************************************************
