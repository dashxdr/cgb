; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** falcon.asm                                                            **
; **                                                                       **
; ** Created : 20000721 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

FALCONSCORE1	EQU	200	;locked a matching ball
FALCONSCORE2	EQU	100	;locked a wildcard ball
FALCONSCORE3	EQU	25	;hit the base

falc_temp	EQUS	"wTemp1024+00"
falc_slow	EQUS	"wTemp1024+01"
falc_slowclock	EQUS	"wTemp1024+02"
falc_second	EQUS	"wTemp1024+03"
falc_frame	EQUS	"wTemp1024+04"
falc_front	EQUS	"wTemp1024+05"
falc_locked	EQUS	"wTemp1024+06" ;3
falc_eject	EQUS	"wTemp1024+09"
falc_shown	EQUS	"wTemp1024+10" ;3
falc_wrongs	EQUS	"wTemp1024+13"

FALCONSLOWTIME	EQU	10

FALCEJECT	EQU	20

falconinfo:	db	BANK(falconhit)		;wPinJmpHit
		dw	falconhit
		db	BANK(falconprocess)	;wPinJmpProcess
		dw	falconprocess
		db	BANK(falconsprites)	;wPinJmpSprites
		dw	falconsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(FalconBumper)	;wPinJmpHitBumper
		dw	FalconBumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(falclostball)	;wPinJmpLost
		dw	falclostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(falcondone)	;wPinJmpDone
		dw	falcondone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

falconmaplist:	db	21
		dw	IDX_FALCONBACKRGB
		dw	IDX_FALCONBACKMAP

falcondone:	ld	a,[falc_locked]
		or	a
		call	nz,Credit1
		ld	a,[falc_locked+1]
		or	a
		call	nz,Credit1
		ld	a,[falc_locked+2]
		or	a
		call	nz,Credit1
		ret

FalconInit::
		ld	hl,falconinfo
		call	SetPinInfo

		ld	a,TIME_FALCON
		call	SetTime

		ld	hl,PAL_FLIPPERS
		call	AddPalette

		ld	hl,PAL_REDMARKER
		call	AddPalette
		ld	hl,PAL_GREENMARKER
		call	AddPalette
		ld	hl,PAL_BLUEMARKER
		call	AddPalette
		ld	hl,PAL_REDBALL
		call	AddPalette
		ld	hl,PAL_GREENBALL
		call	AddPalette
		ld	hl,PAL_BLUEBALL
		call	AddPalette

		ld	hl,IDX_FALC0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,falconmaplist
		call	NewLoadMap
		ld	hl,IDX_FALCONLIGHTSMAP
		call	SecondHalf

		ld	hl,IDX_FALCONREDRGB
		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopyInFileSys

		call	falconon
		call	falcsaver.on

; call	SubAddBall3

		ld	de,50<<5	;x
		ld	bc,50<<5	;y
		ld	hl,0
		call	AddBall
		ld	a,1
		or	[hl]
		ld	[hl],a

		ld	de,60<<5	;x
		ld	bc,60<<5	;y
		ld	hl,0
		call	AddBall
		ld	a,2
		or	[hl]
		ld	[hl],a

		ld	de,70<<5	;x
		ld	bc,70<<5	;y
		ld	hl,0
		call	AddBall
		ld	a,3
		or	[hl]
		ld	[hl],a

		call	subsaver

		ld	hl,falconcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

falclostball:	ld	a,[any_ballsaver]
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

falconprocess:
		ld	hl,falc_shown
		ld	c,18
		ld	a,[falc_locked]
		cp	[hl]
		call	nz,falcshow
		ld	hl,falc_shown+1
		ld	c,20
		ld	a,[falc_locked+1]
		cp	[hl]
		call	nz,falcshow
		ld	hl,falc_shown+2
		ld	c,22
		ld	a,[falc_locked+2]
		cp	[hl]
		call	nz,falcshow

		ld	a,[falc_frame]
		ld	c,a
		ld	hl,falc_temp
		inc	[hl]
		ld	a,[falc_slowclock]
		or	a
		ld	a,[hl]
		jr	z,.fast
		srl	a
.fast:		srl	a
		srl	a
		srl	a
		srl	a
		and	3
		ld	[falc_frame],a
		cp	c
		jr	z,.nochange
		push	af
		call	falcwhirly
		pop	af
		or	a
		call	z,falcnewcolor
.nochange:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,falcsaver

		ld	hl,falc_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0
		ld	hl,falc_slowclock
		ld	a,[hl]
		or	a
		jr	z,.nofalcslow
		dec	[hl]
		call	z,falconon
.nofalcslow:
		ld	a,[falc_eject]
		or	a
		jr	z,.noeject
		dec	a
		ld	[falc_eject],a
		call	z,falceject
.noeject:

.nosecond:
		ld	hl,falc_locked
		ld	a,[hli]
		add	[hl]
		inc	hl
		add	[hl]
		ld	hl,any_count2+1
		cp	[hl]
		jr	z,.same
		ld	[hl],a
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
.same:
		ret


falcshow:	ld	[hl],a
		add	c
		jp	falconrect

falcsaver:	ld	hl,any_ballsaver
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
		jp	falconrect
.off:		ld	a,8
		jp	falconrect

setfalceject:
		ldh	a,[pin_difficulty]
		or	a
		ld	a,FALCEJECT
		jr	z,.aok
		dec	a
		ld	a,FALCEJECT*3/4
		jr	z,.aok
		ld	a,FALCEJECT/2
.aok:		ld	[falc_eject],a
		ret

falceject:
		call	setfalceject
		ld	hl,falc_locked
		ld	b,1
		ld	a,[hl]
		or	a
		jr	nz,falcdoeject
		inc	hl
		ld	b,2
		ld	a,[hl]
		or	a
		jr	nz,falcdoeject
		inc	hl
		ld	b,3
		ld	a,[hl]
		or	a
		jr	nz,falcdoeject
		ret

falcdoeject:	ld	[hl],0
		push	bc
		ld	de,60<<5	;x
		ld	bc,60<<5	;y
		ld	hl,0
		call	AddBall
		pop	af
		or	[hl]
		ld	[hl],a
		ld	a,FX_FALCONEJECT
		jp	InitSfx


falcnewcolor:	ld	a,[falc_front]
		inc	a
		and	3
		ld	[falc_front],a
		ld	e,a
		ld	d,0
		ld	hl,IDX_FALCONREDRGB
		add	hl,de
		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopyInFileSys
		ld	hl,wBcpArcade
		ld	de,wBcpShadow
		ld	bc,64
		call	MemCopy
		ld	a,1
		ldh	[hPalFlag],a
		ret

falcbasehit:
		ldh	a,[pin_ballflags]
		and	3
		dec	a
		ld	c,a
		ld	a,[falc_front]
		cp	c
		jr	z,.match
		cp	3
		jp	nz,.wrong
		push	bc
		ld	hl,FALCONSCORE2
		call	addthousandshlinform
		pop	bc
		jr	.wildcard
.match:		push	bc
		ld	hl,FALCONSCORE1
		call	addthousandshlinform
		pop	bc
.wildcard:	call	setfalceject
		ldh	a,[pin_ballflags]
		res	BALLFLG_USED,a
		ldh	[pin_ballflags],a
		ld	b,0
		ld	hl,falc_locked
		add	hl,bc
		ld	[hl],1
		call	CountBalls
		cp	2
		jr	nc,.notyet
		ld	a,120
		ld	[any_done],a
		ld	a,FX_FALCONWON
		jp	InitSfx
.notyet:	ld	a,FX_FALCONHIT
		jp	InitSfx
.wrong:		ld	hl,falc_wrongs
		inc	[hl]
		ld	a,[hl]
		cp	3
		jr	c,.fine
		ld	[hl],0
		call	falceject
.fine:		ld	hl,FALCONSCORE3
		jp	addthousandshlinform



falcwhirly:	and	3
		add	a
		ld	c,a
		ld	b,0
		ld	hl,falcwhirlys
		add	hl,bc
		ld	a,[hli]
		ld	d,a
		ld	e,[hl]
		ld	h,7
		ld	l,0
		ld	b,8
		ld	c,5
		call	BGRect
		jp	ProcessDirties
falcwhirlys:	db	0,0
		db	9,0
		db	0,6
		db	9,6


falcondropon:	or	a
		ret	z
		ld	hl,IDX_FALC0002CHG-1
		ld	c,a
		ld	b,0
		add	hl,bc
		jp	MakeChanges
falcondropoff:	or	a
		ret	z
		ld	hl,IDX_FALC0002CHG-1
		ld	c,a
		ld	b,0
		add	hl,bc
		jp	UndoChanges


falconon:	ld	a,[falc_slow]
		call	falcondropoff
		ld	a,15
		ld	[falc_slow],a
		call	falcondropon
		ld	a,1
		call	falconrect
		ld	a,3
		call	falconrect
		ld	a,5
		call	falconrect
		ld	a,7
		call	falconrect
		ld	a,10
		call	falconrect
		ld	a,12
		call	falconrect
		ld	a,14
		call	falconrect
		ld	a,16
		jr	falconrect



;a=#
falconrect:	ld	hl,falconrects
		jp	RectList


falconrects:	db	2,2,0,15,2,2	; 0 drop a 0
		db	2,2,0,12,2,2	; 1 drop a 1
		db	2,2,3,15,4,1	; 2 drop b 0
		db	2,2,3,12,4,1	; 3 drop b 1
		db	2,2,6,15,16,1	; 4 drop c 0
		db	2,2,6,12,16,1	; 5 drop c 1
		db	2,2,9,15,18,2	; 6 drop d 0
		db	2,2,9,12,18,2	; 7 drop d 1
		db	2,2,21,0,10,12	; 8 saver 0
		db	2,2,18,0,10,12	; 9 saver 1
		db	2,2,12,15,3,4	;10 s 0
		db	2,2,12,12,3,4	;11 s 1
		db	2,2,15,15,5,3	;12 l 0
		db	2,2,15,12,5,3	;13 l 1
		db	2,2,18,15,15,3	;14 o 0
		db	2,2,18,12,15,3	;15 o 1
		db	2,2,21,15,17,4	;16 w 0
		db	2,2,21,12,17,4	;17 w 1
		db	2,2,0,21,7,6	;18 red off
		db	2,2,0,18,7,6	;19 red on
		db	2,2,3,21,10,7	;20 green off
		db	2,2,3,18,10,7	;21 green on
		db	2,2,6,21,13,6	;22 blue off
		db	2,2,6,18,13,6	;23 blue on



FalconBumper:
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

		ld	hl,falc_slow
		ld	b,[hl]
		ld	a,d
		cp	60
		jr	c,.left2
		cp	117
		jr	nc,.right2
;hit the base
		call	falcbasehit


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
		call	falcondropoff
		ld	a,[falc_slow]
		call	falcondropon
		pop	af
		add	a
		push	af
		call	falconrect
		pop	af
		add	11
		call	falconrect
		ld	a,FX_FALCONDROP
		call	InitSfx
		ld	a,[falc_slow]
		or	a
		call	z,falconslow
.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

falconslow:	ld	a,FALCONSLOWTIME
		ld	[falc_slowclock],a
		ret



falconcollisions:
		dw	0

falconhit:	ret
falconsprites:
		ld	bc,IDX_REDMARKER
		ld	e,4
		ld	h,2
		ld	a,[falc_locked]
		call	falcmarker
		ld	bc,IDX_GREENMARKER
		ld	e,0
		ld	h,3
		ld	a,[falc_locked+1]
		call	falcmarker
		ld	bc,IDX_BLUEMARKER
		ld	e,12
		ld	h,4
		ld	a,[falc_locked+2]
		call	falcmarker

		jp	SubFlippers

falcmarker:	ld	l,a
		ld	a,[falc_frame]
		add	e
		ld	e,a
		ld	a,[falc_front]
		add	a
		add	a
		add	e
		and	15
		add	a
		ld	e,a
		ld	d,0
		push	hl
		ld	hl,falccircle
		add	hl,de
		ld	a,[hli]
		ld	d,a
		ld	e,[hl]
		pop	hl
		ld	a,l
		or	a
		ld	a,h
		jr	z,.abcok
		ld	bc,IDX_BALL
		add	3
.abcok:		jp	AddFigure	

falccircle:	db	69-8,2
		db	68-8,10
		db	70-8,17
		db	74-8,21
		db	79-8,26
		db	87-8,28
		db	96-8,26
		db	101-8,22
		db	106-8,17
		db	107-8,10
		db	106-8,2
		db	101-8,-3
		db	-20,-20
		db	-20,-20
		db	-20,-20
		db	-20,-20

