; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** prison.asm                                                            **
; **                                                                       **
; ** Created : 20000424 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

MAXICEFALLS	EQU	6


pr_prison	EQUS	"wTemp1024+00"
pr_prisonmode	EQUS	"wTemp1024+01"
pr_damage	EQUS	"wTemp1024+02"
pr_falls	EQUS	"wTemp1024+10" ;5*MAXICEFALLS bytes

SHARKYMAX	EQU	$68
SHARKYMIN	EQU	$20
SHARKRATE	EQU	100

GROUP_ICEMEL	EQU	2
GROUP_ICEBITS	EQU	3

prisonmaplist:
		db	21
		dw	IDX_PRISONBACKRGB
		dw	IDX_PRISONBACKMAP


prisoninfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(prisonprocess)	;wPinJmpProcess
		dw	prisonprocess
		db	BANK(prisonsprites)	;wPinJmpSprites
		dw	prisonsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(prisonhit)		;wPinJmpHitBumper
		dw	prisonhit
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



PrisonInit::
		ld	hl,prisoninfo
		call	SetPinInfo

		ld	a,TIME_PRISON
		call	SetTime

		ld	a,13
		call	SetCount2

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_ICEMEL
		call	AddPalette
		ld	hl,PAL_ICEBITS
		call	AddPalette

;		ld	a,1
;		ld	[pr_left],a

		ld	a,1
		ld	[pr_prisonmode],a

		ld	hl,IDX_DETFLD000PMP
		call	LoadPinMap

;		ld	hl,IDX_DETFLD001CHG
;		call	MakeChanges
		ld	hl,IDX_DETFLD004CHG
		call	MakeChanges
;		ld	hl,IDX_DETFLD003CHG
;		call	MakeChanges

		ld	hl,prisonmaplist
		call	NewLoadMap
		ld	hl,IDX_BREAKICEMAP
		call	SecondHalf

 call	SubAddBall

		ld	hl,prisoncollisions
		jp	MakeCollisions

prisonprocess:
		call	SubEnd

;		ld	a,[wTime]
;		and	$7f
;		jr	nz,.notryeye
;		call	CountBalls
;		cp	2
;		jr	nc,.notryeye
;		ld	hl,pr_left
;		ld	a,[hl]
;		or	a
;		jr	nz,.notryeye
;		ld	a,1
;		ld	[hli],a
;		ld	[hl],0
;.notryeye:

		call	AnyDecTime
		ret

FLYMIN		EQU	21<<5
FLYMAX		EQU	50<<5

FLX0		EQU	20<<5
FLX1		EQU	64<<5
FLX2		EQU	112<<5
FLX3		EQU	155<<5


prisonhit:

		ldh	a,[pin_x]
		ld	e,a
		ldh	a,[pin_x+1]
		ld	d,a

		ld	c,0
		ld	a,e
		sub	FLX1&255
		ld	a,d
		sbc	FLX1>>8
		jr	c,.cok
		inc	c
		ld	a,e
		sub	FLX2&255
		ld	a,d
		sbc	FLX2>>8
		jr	c,.cok
		inc	c
.cok:		ld	a,c
		cp	1
		jr	nz,.notprison
		ld	a,[pr_prisonmode]
		dec	a
		ret	nz
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	breakice
		call	Credit1
		ld	a,FX_PRISONHIT
		call	InitSfx
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	nz
;finished game
		ld	a,HOLDTIME
		ld	[any_done],a
		ret
.notprison:
		ret

prisonsprites:
		call	SubFlippers
		call	prisonsprite

		call	prdofalls

		ret

prisonlists:	dw	flwiggling
		dw	flstruck
		dw	flescape

flwiggling:	db	2,2,3,3,4,4,5,5,-1
flstruck:	db	7,7,7,-1
flescape:	db	6,7,8,9,10,10,10,10,10,10,0


prisonsprite:
		ld	a,[pr_prisonmode]
		or	a
		jp	z,AnyEnd
		dec	a
		add	a
		add	LOW(prisonlists)
		ld	l,a
		ld	a,0
		adc	HIGH(prisonlists)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[wTime]
		and	7
		ld	c,0
		jr	nz,.cok
		inc	c
.cok:		ld	a,[pr_prison]
		add	c
		ld	[pr_prison],a
		sub	c
		add	l
		ld	l,a
		ld	a,0
		adc	h
		ld	h,a
		ld	a,[hl]
		add	a
		jr	c,.new
		jr	nz,.nonew
.new:		ld	a,[hl]
		cpl
		inc	a
		ld	[pr_prisonmode],a
		xor	a
		ld	[pr_prison],a
		jr	prisonsprite
.nonew:		ld	a,[hl]
		sub	2
		add	IDX_ICEMEL&255
		ld	c,a
		ld	a,0
		adc	IDX_ICEMEL>>8
		ld	b,a
		ld	de,$4e15
		ld	a,GROUP_ICEMEL
		jp	AddFigure


flsecondball:
		ld	a,b
		cp	5
		ret	nz
		push	de
		call	CountBalls
		pop	de
		cp	2
		ret	nc
		ld	a,d
		ld	bc,16<<5
		ld	de,$80<<5
		ld	hl,$0010
		jp	AddBall


breakice:
		ld	a,[pr_damage]
		cp	13
		ret	z
		inc	a
		ld	[pr_damage],a
		dec	a
		add	a
		ld	e,a
		ld	d,0
		ld	hl,breakpositions
		add	hl,de
		add	hl,de
		add	hl,de
		ld	b,[hl]
		inc	hl
		ld	c,[hl]
		inc	hl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		inc	hl
		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
		ld	a,d
		sub	h
		add	8
		ld	h,a
		ld	a,e
		sub	l
		ld	l,a
		call	BGRect
		ld	a,[pr_damage]
		dec	a
		ld	e,a
		call	praddbits
		call	praddbits
		call	praddbits
		jp	praddbits

breakpositions:
		db	2,2,8,3,6,0
		db	3,2,15,3,12,0
		db	2,2,19,3,18,0
		db	2,3,0,7,0,5
		db	2,3,6,6,6,5
		db	3,3,13,6,12,5
		db	2,3,21,6,18,5
		db	2,2,4,12,0,10
		db	3,3,9,11,6,10
		db	3,2,15,10,12,10
		db	2,2,18,10,18,10
		db	3,2,1,15,0,15
		db	3,2,9,15,6,15


prisoncollisions:
		dw	0


prdofalls:

		ld	hl,pr_falls
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
praddbits:	ld	hl,pr_falls
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
		add	LOW(prpositions)
		ld	c,a
		ld	a,0
		adc	HIGH(prpositions)
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

prpositions:
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22
		db	86,22



;***********************************************************************
;***********************************************************************
