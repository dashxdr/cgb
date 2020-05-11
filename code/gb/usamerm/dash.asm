; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** dash.asm                                                              **
; **                                                                       **
; ** Created : 20000424 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	11


MAXOBJECTS	EQU	3
OBJECTSIZE	EQU	6


dash_x		EQUS	"wTemp1024+00"
dash_pos	EQUS	"wTemp1024+01"
dash_mode	EQUS	"wTemp1024+02"
dash_last	EQUS	"wTemp1024+03"
dash_holding	EQUS	"wTemp1024+04"
dash_ball	EQUS	"wTemp1024+05"

dash_objs	EQUS	"wTemp1024+16"	;OBJECTSIZE*MAXOBJECT

GROUP_DFISH	EQU	2
GROUP_DHEAD	EQU	3
GROUP_DBALL	EQU	4

DASHX1		EQU	44-8
DASHX2		EQU	88-8
DASHX3		EQU	132-8
DASHY		EQU	36

dashinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(dashprocess)	;wPinJmpProcess
		dw	dashprocess
		db	BANK(dashsprites)	;wPinJmpSprites
		dw	dashsprites
		db	BANK(dashhit)		;wPinJmpHitFlipper
		dw	dashhit
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

dashmaplist:	db	21
		dw	IDX_DASHBACKRGB
		dw	IDX_DASHBACKMAP

DashInit::
		ld	hl,dashinfo
		call	SetPinInfo

		ld	a,TIME_DASH
		call	SetTime

		ld	a,NEED_DASH
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_DFISH
		call	AddPalette
		ld	hl,PAL_DHEAD
		call	AddPalette
		ld	hl,PAL_DBALL
		call	AddPalette


		ld	a,0
		ldh	[pin_textpal],a

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap

		ld	hl,dashmaplist
		call	NewLoadMap
		ld	hl,IDX_CHESTSMAP
		call	SecondHalf

 call	SubAddBall

		ld	hl,dashcollisions
		jp	MakeCollisions


dashprocess:
		call	SubEnd

		call	AnyDecTime
		ld	a,[dash_mode]
		or	a
		call	z,newdash
		call	dashcoll
		call	dashball

		ret

dashcoll:	ld	a,[dash_x]
		ld	c,a
		ld	b,0
		ld	hl,IDX_DSHDET001CHG
		add	hl,bc
		ld	a,[dash_last]
		cp	7
		jp	nz,UndoChanges
		jp	MakeChanges


MAXHITS		EQU	5
dashhit:

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		cp	80
		jp	nc,SubHitFlipper

		call	Credit2
		ld	a,[dash_holding]
		or	a
		ret	z
		ld	c,a
		xor	a
		ld	[dash_holding],a
		dec	c
		jr	z,.dropfish
;add ball
		call	getdashx
		ld	[dash_ball],a
		ret
.dropfish:
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	z,.nocredit
		call	Credit1
		call	AnyDec2
		ld	a,FX_DASHGET
		call	InitSfx
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.nocredit
		ld	a,HOLDTIME
		ld	[any_done],a

.nocredit:	call	getdashx
		jp	newobject


dashball:	ld	a,[dash_ball]
		or	a
		ret	z
		ld	l,a
		xor	a
		ld	[dash_ball],a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		inc	h
		ld	d,h
		ld	e,l
		ld	bc,DASHY<<5
		call	random
		and	15
		sub	8
		ld	l,a
		call	random
		and	15
		sub	8
		ld	h,a
		call	AddBall
		ld	a,FX_SECONDBALL
		jp	InitSfx


getdashx:
		ld	a,[dash_x]
		ld	d,DASHX1
		or	a
		jr	z,.dok
		dec	a
		ld	d,DASHX2
		jr	z,.dok
		ld	d,DASHX3
.dok:		ld	a,d
		ret



dashsprites:
		call	SubFlippers
		call	dashobjects
		call	dashhead
		ret

;a=#
dashopen:	or	a
		jr	z,.open0
		dec	a
		jr	z,.open1
.open2:		ld	bc,$0305
		ld	de,$1100
		ld	hl,$0f01
		jp	BGRect
.open0:		ld	bc,$0305
		ld	de,$0300
		ld	hl,$0401
		jp	BGRect
.open1:		ld	bc,$0405
		ld	de,$0a00
		ld	hl,$0901
		jp	BGRect

dashY	EQU	64
dashobjects:
		ld	hl,dash_objs
		ld	e,MAXOBJECTS
.stlp:		ld	a,[hl]
		or	a
		jr	z,.next2
		ld	c,a
		ld	a,[wTime]
		and	3
		jr	nz,.noinc
		ld	a,c
		inc	a
		cp	14
		jr	c,.aok
		ld	a,6
.aok:		ld	[hl],a
.noinc:		ld	a,c
		dec	a
		add	IDX_DFISH&255
		ld	c,a
		ld	a,0
		adc	IDX_DFISH>>8
		ld	b,a
		push	de
		inc	hl
		inc	hl
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hl]
		cp	e
		jr	nc,.noinc2
		inc	a
		ld	[hl],a
.noinc2:
		ld	e,a
		cp	100
		jr	c,.nodestroy
		dec	hl
		dec	hl
		dec	hl
		dec	hl
		xor	a
		ld	[hli],a
		ld	[hli],a
		inc	hl
		inc	hl
.nodestroy:	inc	hl
		inc	hl
		ld	a,GROUP_DFISH
		push	hl
		call	AddFigure
		pop	hl
		pop	de
		jr	.next
.next2:		ld	bc,OBJECTSIZE
		add	hl,bc
.next:		dec	e
		jr	nz,.stlp
		ret

;object structure:
;1 byte fig counter (0 if not used)
;1 byte spare
;1 byte x
;1 byte y desired value
;1 byte y
;1 byte spare


;a=x
newobject:
		ldh	[hTmpLo],a
		ld	hl,dash_objs
		ld	de,OBJECTSIZE
		ld	c,MAXOBJECTS
.ntfind:	ld	a,[hl]
		or	a
		jr	z,.got
		add	hl,de
		dec	c
		jr	nz,.ntfind
		ret
.got:		ld	a,6
		ld	[hli],a
		xor	a
		ld	[hli],a
		ldh	a,[hTmpLo]
		ld	[hli],a
		ld	a,150
		ld	[hli],a
		ld	a,DASHY
		ld	[hli],a
		xor	a
		ld	[hl],a
		ret

newdash:	ld	a,1
		ld	[dash_mode],a
		xor	a
		ld	[dash_pos],a
		ld	a,[dash_x]
		ld	c,a
.r3:		call	random
		and	3
		jr	z,.r3
		dec	a
		cp	c
		jr	z,.r3
		ld	[dash_x],a
		call	CountBalls
		cp	2
		jr	nc,.hold1
		call	random
		and	3
		jr	nz,.hold1
		ld	a,2
		jr	.hold2
.hold1:		ld	a,1
.hold2:		ld	[dash_holding],a
		ret


dashmodelist:	dw	dashmode1
		dw	dashmode2

dashmode1:	db	2,3,4,5,6,7,7,7,7,7,7,7,7,7
		db	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
		db	11,12,3,2,1,1,1,1,1
		db	1,1,1,1,1,1,1,1,1,1,1,1,1
		db	0
dashmode2:	db	8,9,10,10,10,10,11,12,3,2,1,1,1,1,1
		db	1,1,1,1,1,1,1,1,1,1,1,1,1
		db	0


dashhead:
		ld	a,[dash_mode]
		or	a
		ret	z
		dec	a
		add	a
		ld	e,a
		ld	d,0
		ld	hl,dashmodelist
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[dash_pos]
		ld	e,a
		add	hl,de
		ld	a,[hli]
		ld	e,a
		ld	a,[wTime]
		and	3
		jr	nz,.nonewmode
		ld	a,[dash_pos]
		inc	a
		ld	[dash_pos],a
		ld	a,[hl]
		or	a
		jr	z,.newmode
		cp	$80
		jr	c,.nonewmode
.newmode:	cpl
		inc	a
		ld	[dash_mode],a
		xor	a
		ld	[dash_pos],a
.nonewmode:
		ld	a,e
		cp	2
		ret	c
		ld	[dash_last],a
		ld	hl,IDX_DHEAD-2
		add	hl,de
		ld	b,h
		ld	c,l

		call	getdashx
		ld	d,a
		ld	e,DASHY
		ld	a,GROUP_DHEAD
		push	bc
		push	de
		call	AddFigure
		pop	de
		pop	bc
		ld	a,[dash_holding]
		or	a
		ret	z
		ld	l,a
		ld	a,[dash_last]
		sub	5
		ret	c
		cp	3
		ret	nc
		ld	bc,IDX_DFISH
		ld	h,GROUP_DFISH
		dec	l
		jr	z,.bchok
		ld	bc,IDX_DBALL
		ld	h,GROUP_DBALL
.bchok:		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,h
		jp	AddFigure



dashlist:

dashcollisions:
		dw	0

;***********************************************************************
;***********************************************************************

