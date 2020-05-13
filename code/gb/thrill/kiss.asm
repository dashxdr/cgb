; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** kiss.asm                                                              **
; **                                                                       **
; ** Created : 20000728 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

KISSSCORE1	EQU	50	;for each level

GROUP_PLATFORM	EQU	2

kiss_down	EQUS	"wTemp1024+00"
kiss_second	EQUS	"wTemp1024+01"
kiss_spin	EQUS	"wTemp1024+02"
kiss_y		EQUS	"wTemp1024+03"
kiss_lit	EQUS	"wTemp1024+04"
kiss_turnon	EQUS	"wTemp1024+05"

MAXHEIGHT	EQU	NEED_KISS

kissinfo:	db	BANK(kisshit)		;wPinJmpHit
		dw	kisshit
		db	BANK(kissprocess)	;wPinJmpProcess
		dw	kissprocess
		db	BANK(kisssprites)	;wPinJmpSprites
		dw	kisssprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(kissBumper)	;wPinJmpHitBumper
		dw	kissBumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(kisslostball)	;wPinJmpLost
		dw	kisslostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(kissdone)		;wPinJmpDone
		dw	kissdone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

kissmaplist:	db	21
		dw	IDX_KISSBACKRGB
		dw	IDX_KISSBACKMAP

kissdone:	ld	a,[kiss_y]
		or	a
		jr	z,.nothing
		ld	c,a
.credits:	push	bc
		call	Credit1
		ld	hl,KISSSCORE1
		call	addthousandshlinform
		pop	bc
		dec	c
		jr	nz,.credits
.nothing:	ret

KissInit::
		ld	hl,kissinfo
		call	SetPinInfo

		ld	a,TIME_KISS
		call	SetTime

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_PLATFORM
		call	AddPalette

		ld	hl,IDX_KISS0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,kissmaplist
		call	NewLoadMap
		ld	hl,IDX_KISSLIGHTSMAP
		call	SecondHalf

		call	kisson
		call	kisssaver.on

 call	SubAddBall

		call	subsaver

		ld	hl,kisscollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

kisslostball:	ld	a,[any_ballsaver]
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

kissprocess:
		call	kisshandlelit
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,kisssaver

		ld	hl,kiss_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:
		ld	a,[kiss_y]
		ld	hl,any_count2+1
		cp	[hl]
		jr	z,.same
		ld	[hl],a
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
.same:

		ret

kisssaver:	ld	hl,any_ballsaver
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
.on:		ld	a,9
		jp	kissrect
.off:		ld	a,8
		jp	kissrect

kissbasehit:
		ld	a,[kiss_turnon]
		or	a
		call	nz,kisson
		ld	a,[any_done]
		or	a
		ret	nz
		ld	a,[kiss_y]
		cp	MAXHEIGHT
		ret	z
		inc	a
		ld	[kiss_y],a
		cp	MAXHEIGHT
		ld	a,FX_KISSBASE
		jp	c,InitSfx
		ld	a,120
		ld	[any_done],a
		ld	a,FX_KISSWON
		jp	InitSfx

lowerplatform:
		ld	a,[any_done]
		or	a
		ret	nz
		ld	a,[kiss_y]
		or	a
		jr	z,.aok
		ld	a,FX_KISSDROP
		call	InitSfx
		ld	a,[kiss_y]
		dec	a
.aok:		ld	[kiss_y],a
		ret

bottomplatform:
		ld	a,[any_done]
		or	a
		ret	nz
		ld	a,FX_KISSDROP
		call	InitSfx
		xor	a
		ld	[kiss_y],a
		ld	a,1
		ld	[kiss_turnon],a
		ret


kissdropon:	or	a
		ret	z
		ld	hl,IDX_KISS0002CHG-1
		ld	c,a
		ld	b,0
		add	hl,bc
		jp	MakeChanges
kissdropoff:	or	a
		ret	z
		ld	hl,IDX_KISS0002CHG-1
		ld	c,a
		ld	b,0
		add	hl,bc
		jp	UndoChanges

kisson:		xor	a
		ld	[kiss_turnon],a
		ld	a,[kiss_down]
		call	kissdropoff
		ld	a,15
		ld	[kiss_down],a
		call	kissdropon
		ld	a,1
		call	kissrect
		ld	a,3
		call	kissrect
		ld	a,5
		call	kissrect
		ld	a,7
		call	kissrect
		ld	a,10
		call	kissrect
		ld	a,12
		call	kissrect
		ld	a,14
		call	kissrect
		ld	a,16
		jr	kissrect



;a=#
kissrect:	ld	hl,kissrects
		jp	RectList


kissrects:	db	2,2,0,15,2,2	; 0 drop a 0
		db	2,2,0,12,2,2	; 1 drop a 1
		db	2,2,3,15,4,1	; 2 drop b 0
		db	2,2,3,12,4,1	; 3 drop b 1
		db	2,2,6,15,16,1	; 4 drop c 0
		db	2,2,6,12,16,1	; 5 drop c 1
		db	2,2,9,15,18,2	; 6 drop d 0
		db	2,2,9,12,18,2	; 7 drop d 1
		db	2,2,21,0,10,13	; 8 saver 0
		db	2,2,18,0,10,13	; 9 saver 1
		db	2,2,12,15,3,4	;10 d 0
		db	2,2,12,12,3,4	;11 d 1
		db	2,2,15,15,5,3	;12 o 0
		db	2,2,15,12,5,3	;13 o 1
		db	2,2,18,15,15,3	;14 w 0
		db	2,2,18,12,15,3	;15 w 1
		db	2,2,21,15,17,4	;16 n 0
		db	2,2,21,12,17,4	;17 n 1
		db	2,2,0,22,4,10	;18 k 0
		db	2,2,0,18,4,10	;19 k 1
		db	2,3,3,22,6,10	;20 i 0
		db	2,3,3,18,6,10	;21 i 1
		db	2,2,6,22,8,11	;22 s 0
		db	2,2,6,18,8,11	;23 s 1
		db	2,2,9,22,10,11	;24 s 0
		db	2,2,9,18,10,11	;25 s 1
		db	2,2,12,22,12,11	;26 i 0
		db	2,2,12,18,12,11	;27 i 1
		db	2,3,15,22,14,10	;28 n 0
		db	2,3,15,18,14,10	;29 n 1
		db	2,2,18,22,16,10	;30 g 0
		db	2,2,18,18,16,10	;31 g 1




kissBumper:
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

		ld	hl,kiss_down
		ld	b,[hl]
		ld	a,d
		cp	60
		jr	c,.left2
		cp	117
		jr	nc,.right2
;hit the base
		call	kissbasehit

		jr	.soft
.left2:		ld	a,d
		sub	13
		ld	d,a
		cp	e
		jr	nc,.hit2
.hit1:		bit	0,b
		jr	z,.hit2
		res	0,[hl]
		ld	a,0
		jr	.ahit
.hit2:		bit	1,b
		jr	z,.hit1
		res	1,[hl]
		ld	a,1
		jr	.ahit
.right2:	ld	a,d
		sub	145
		ld	d,a
		ld	a,e
		sub	15
		ld	e,a
		add	d
		add	a
		jr	nc,.hit4
.hit3:		bit	2,b
		jr	z,.hit4
		res	2,[hl]
		ld	a,2
		jr	.ahit
.hit4:		bit	3,b
		jr	z,.hit3
		res	3,[hl]
		ld	a,3
.ahit:		push	af
		ld	a,b
		call	kissdropoff
		ld	a,[kiss_down]
		call	kissdropon
		pop	af
		add	a
		push	af
		call	kissrect
		pop	af
		add	11
		call	kissrect
		ld	a,[kiss_down]
		or	a
		jr	z,.bottom
		call	lowerplatform
		jr	.down
.bottom:	call	bottomplatform
.down:
.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret


kisscollisions:
		dw	0

kisshit:	ret
kisssprites:
		ld	hl,kiss_spin
		inc	[hl]
		ld	a,[hl]
		ld	bc,IDX_PLATFORM
		and	1<<4
		jr	z,.noincbc
		inc	bc
.noincbc:	ld	d,80
		ld	a,[kiss_y]
		ld	e,a
		add	a
		add	a
		ld	e,a
		ld	a,50
		sub	e
		ld	e,a

		ldh	a,[pin_xpush]
		sra	a
		sra	a
		sra	a
		sra	a
		sra	a
		cpl
		inc	a
		add	d
		ld	d,a
		ldh	a,[pin_ypush]
		sra	a
		sra	a
		sra	a
		sra	a
		sra	a
		cpl
		inc	a
		add	e
		ld	e,a

		ld	a,GROUP_PLATFORM
		call	AddFigure

		jp	SubFlippers

kisshandlelit:
		ld	a,[kiss_y]
		ld	c,a
		ld	a,[kiss_lit]
		cp	c
		ret	z
		jr	c,.more
.less:		dec	a
		ld	[kiss_lit],a
		add	a
		add	18
		jp	kissrect
.more:		inc	a
		ld	[kiss_lit],a
		add	a
		add	17
		jp	kissrect

