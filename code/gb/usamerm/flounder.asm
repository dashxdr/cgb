; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** flounder.asm                                                          **
; **                                                                       **
; ** Created : 20000320 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

fl_flounder	EQUS	"wTemp1024+00"
fl_floundermode	EQUS	"wTemp1024+01"
fl_sharky	EQUS	"wTemp1024+02"
fl_sharkcount	EQUS	"wTemp1024+03"
fl_left		EQUS	"wTemp1024+04"	;2 bytes

SHARKYMAX	EQU	$68
SHARKYMIN	EQU	$20
SHARKRATE	EQU	100

GROUP_FLOUNDER	EQU	2
GROUP_SHARK	EQU	3
GROUP_EYE	EQU	4
GROUP_TENTACLE	EQU	5

floundermaplist:
		db	21
		dw	IDX_FLOUNDERBACKRGB
		dw	IDX_FLOUNDERBACKMAP


flounderinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(flounderprocess)	;wPinJmpProcess
		dw	flounderprocess
		db	BANK(floundersprites)	;wPinJmpSprites
		dw	floundersprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(flounderhit)	;wPinJmpHitBumper
		dw	flounderhit
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



flounderinit::
		ld	hl,flounderinfo
		call	SetPinInfo

		ld	a,TIME_FLOUNDER
		call	SetTime

		ld	a,NEED_FLOUNDER
		call	SetCount2

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_FLOUNDER
		call	AddPalette
		ld	hl,PAL_FLSHARK
		call	AddPalette
		ld	hl,PAL_FLEYE
		call	AddPalette
		ld	hl,PAL_FLTENTACLE
		call	AddPalette

		ld	a,1
		ld	[fl_left],a

		ld	a,1
		ld	[fl_floundermode],a

		ld	hl,IDX_DETFLD000PMP
		call	LoadPinMap

		ld	hl,IDX_DETFLD001CHG
		call	MakeChanges
		ld	hl,IDX_DETFLD002CHG
		call	MakeChanges
		ld	hl,IDX_DETFLD003CHG
		call	MakeChanges

		ld	hl,floundermaplist
		call	NewLoadMap

 call	SubAddBall

		ld	a,SHARKYMAX
		ld	[fl_sharky],a

		ld	hl,floundercollisions
		jp	MakeCollisions

flounderprocess:

		ld	a,[wTime]
		and	$7f
		jr	nz,.notryeye
		call	CountBalls
		cp	2
		jr	nc,.notryeye
		ld	hl,fl_left
		ld	a,[hl]
		or	a
		jr	nz,.notryeye
		ld	a,1
		ld	[hli],a
		ld	[hl],0
.notryeye:

		call	SubEnd
		call	AnyDecTime

		ld	b,SHARKRATE
		ldh	a,[pin_difficulty]
		or	a
		jr	nz,.bok
		sla	b
.bok:		ld	hl,fl_sharkcount
		inc	[hl]
		ld	a,[hl]
		cp	b
		jr	c,.nomoveshark
		ld	[hl],0
		ld	hl,fl_sharky
		dec	[hl]
		ld	a,[hl]
		cp	SHARKYMIN
		jr	nz,.alive
		call	AnyEnd
.alive:
.nomoveshark:

		ret

FLYMIN		EQU	21<<5
FLYMAX		EQU	50<<5

FLX0		EQU	20<<5
FLX1		EQU	64<<5
FLX2		EQU	112<<5
FLX3		EQU	155<<5


flounderhit:

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
		jr	nz,.notflounder
		ld	a,[fl_floundermode]
		dec	a
		ret	nz
		xor	a
		ld	[fl_flounder],a
		ld	a,2
		ld	[fl_floundermode],a
		call	AnyDec2
		call	Credit1
		ld	a,FX_FLOUNDERHIT
		call	InitSfx
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	nz
		ld	a,3
		ld	[fl_floundermode],a
		ret
.notflounder:
		ld	de,fllhitmap
		or	a
		jr	z,.deok
		ld	de,flrhitmap
.deok:		ld	hl,fl_left
		ld	a,[hl]
		add	e
		ld	e,a
		ld	a,0
		adc	d
		ld	d,a
		ld	a,[de]
		cp	[hl]
		ret	z
		ld	[hl],a
		inc	hl
		ld	[hl],0
		ld	a,FX_FLOUNDEREYE
		jp	InitSfx

floundersprites:
		call	SubFlippers
		call	floundersprite
		ld	de,$2010
		ld	hl,fl_left
		call	fleye
;		ld	de,$8010
;		ld	hl,fl_right
;		call	fleye

		ld	bc,IDX_FLSHARK
		ld	d,$4f
		ld	a,[fl_sharky]
		ld	e,a
		ld	a,GROUP_SHARK
		call	AddFigure

		ret

flounderlists:	dw	flwiggling
		dw	flstruck
		dw	flescape

flwiggling:	db	3,4,5,4,3,4,5,4,3,4,5,4,4,4,4,4,4,4,4,4,-1
flstruck:	db	7,7,7,-1
flescape:	db	6,7,8,9,10,10,10,10,10,10,0


floundersprite:
		ld	a,[fl_floundermode]
		or	a
		jp	z,AnyEnd
		dec	a
		add	a
		add	LOW(flounderlists)
		ld	l,a
		ld	a,0
		adc	HIGH(flounderlists)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[wTime]
		and	7
		ld	c,0
		jr	nz,.cok
		inc	c
.cok:		ld	a,[fl_flounder]
		add	c
		ld	[fl_flounder],a
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
		ld	[fl_floundermode],a
		xor	a
		ld	[fl_flounder],a
		jr	floundersprite
.nonew:		ld	a,[hl]
		sub	2
		add	IDX_FLOUNDER&255
		ld	c,a
		ld	a,0
		adc	IDX_FLOUNDER>>8
		ld	b,a
		ld	de,$5010
		ld	a,GROUP_FLOUNDER
		jp	AddFigure

fllhitmap:	db	0,2,3,3,4,5
flrhitmap:	db	0,1,2,4,5,0

fleyelists:	dw	fleyemove		;1
		dw	fleyehit		;2
		dw	fltentaclein		;3
		dw	fltentacleloop		;4
		dw	fltentaclehit		;5

fleyemove:	db	2,3,4,4,5,5,6,6,3,3,3,3,2
		db	2,3,4,4,5,5,6,6,3,3,3,3,2
		db	0
fleyehit:	db	7,7,7,7,3,2,-3
fltentaclein:	db	22,23,24,25,26,-4
fltentacleloop:	db	26,27,28,29,30,31,32
		db	26,27,28,29,30,31,32
		db	26,27,28,29,30,31,32
		db	25,24,23,22
		db	0
fltentaclehit:	db	25,24,23,22,0





fleye:		ld	a,[hl]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(fleyelists)
		ld	c,a
		ld	a,0
		adc	HIGH(fleyelists)
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
		and	7
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
		jr	nz,fleye
		jp	flsecondball
.nonew:		ld	a,[bc]
		sub	2
		cp	20
		jr	c,.eye
.tentacle:	sub	20
		add	IDX_FLTENTACLE&255
		ld	c,a
		ld	a,0
		adc	IDX_FLTENTACLE>>8
		ld	b,a
		ld	a,GROUP_TENTACLE
		ld	de,$8014
		jp	AddFigure
.eye:		add	IDX_FLEYE&255
		ld	c,a
		ld	a,0
		adc	IDX_FLEYE>>8
		ld	b,a
		ld	a,GROUP_EYE
		ld	de,$2010
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
		call	AddBall
		ld	a,FX_SECONDBALL
		jp	InitSfx


floundercollisions:
		dw	0

;***********************************************************************
;***********************************************************************
