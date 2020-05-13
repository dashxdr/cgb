; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** looper.asm                                                            **
; **                                                                       **
; ** Created : 20000801 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

GROUP_PLATFORM	EQU	2

loop_second	EQUS	"wTemp1024+00"
loop_arrow	EQUS	"wTemp1024+01"
loop_arrowtime	EQUS	"wTemp1024+02"
loop_last1	EQUS	"wTemp1024+03"
loop_last2	EQUS	"wTemp1024+04"
loop_last3	EQUS	"wTemp1024+05"
loop_event	EQUS	"wTemp1024+06"
loop_repeats	EQUS	"wTemp1024+07"
loop_time	EQUS	"wTemp1024+08"

ARROWTIME	EQU	15	;in 4/15ths of a second


loopinfo:	db	BANK(loophit)		;wPinJmpHit
		dw	loophit
		db	BANK(loopprocess)	;wPinJmpProcess
		dw	loopprocess
		db	BANK(loopsprites)	;wPinJmpSprites
		dw	loopsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(loopBumper)	;wPinJmpHitBumper
		dw	loopBumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(looplostball)	;wPinJmpLost
		dw	looplostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(loopdone)		;wPinJmpDone
		dw	loopdone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

loopmaplist:	db	21
		dw	IDX_LOOPBACKRGB
		dw	IDX_LOOPBACKMAP

loopdone:	ret

arrowtimes:	db	ARROWTIME*2,ARROWTIME*3/2,ARROWTIME

LooperInit::
		ldh	a,[pin_difficulty]
		ld	e,a
		ld	d,0
		ld	hl,arrowtimes
		add	hl,de
		ld	a,[hl]
		ld	[loop_time],a



		ld	hl,loopinfo
		call	SetPinInfo

		ld	a,TIME_LOOPER
		call	SetTime

		ld	a,NEED_LOOPER
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_PLATFORM
		call	AddPalette

		ld	hl,IDX_LOOP0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,loopmaplist
		call	NewLoadMap
		ld	hl,IDX_LOOPLIGHTSMAP
		call	SecondHalf

		ld	a,BANK(LooperInit)
		ld	[wPinHitBank],a

		xor	a
		ld	[loop_arrowtime],a
		ld	a,1
		ld	[loop_arrow],a

		call	loopsaver.on

 call	SubAddBall

		call	subsaver

		ld	hl,loopcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

looplostball:	ld	a,[any_ballsaver]
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

loopprocess:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,loopsaver

		ld	a,[wTime]
		and	15
		jr	nz,.noarrowchange
		ld	hl,loop_arrowtime
		ld	a,[hl]
		dec	[hl]
		or	a
		call	z,newlooparrow
.noarrowchange:

		ld	a,[loop_event]
		or	a
		call	nz,handleloopevent

		ld	hl,loop_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:

		ret

loopcredits:	dw	25,50,100,200,400

handleloopevent:
		ld	c,a
		xor	a
		ld	[loop_event],a
		xor	a
		ld	[loop_arrowtime],a
		ld	a,[loop_arrow]
		inc	a
		cp	c
		ld	a,0
		jr	nz,.aok
		ld	a,[loop_repeats]
		inc	a
		cp	5
		jr	c,.aok
		dec	a
.aok:		ld	[loop_repeats],a
		or	a
		call	nz,loopdec
		call	loopdec
		ld	a,[loop_repeats]
		add	a
		ld	c,a
		ld	b,0
		ld	hl,loopcredits
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	addthousandshlinform

		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	z,.done
		ld	a,FX_LOOPERRAMP
		jp	InitSfx
.done:		call	AnyEnd
		ld	a,FX_LOOPERWON
		jp	InitSfx
loopdec:	ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	AnyDec2
		jp	Credit1



newlooparrow:	ld	a,[loop_time]
		ld	[loop_arrowtime],a
		ld	a,[loop_arrow]
		ld	c,a
		ld	b,0
		ld	hl,nextloop
		add	hl,bc
		ld	a,[hl]
		jp	looparrowon
nextloop:	db	2,3,1,0


loopsaver:	ld	hl,any_ballsaver
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
		jp	looprect
.off:		ld	a,8
		jp	looprect


;a=#
looprect:	ld	hl,looprects
		jp	RectList


looprects:
		db	2,4,0,5,4,8	; 0 arrow a 0
		db	2,4,0,0,4,8	; 1 arrow a 1
		db	3,3,3,5,7,7	; 2 arrow b 0
		db	3,3,3,0,7,7	; 3 arrow b 1
		db	3,3,7,5,12,7	; 4 arrow c 0
		db	3,3,7,0,12,7	; 5 arrow c 1
		db	2,4,11,5,16,8	; 6 arrow d 0
		db	2,4,11,0,16,8	; 7 arrow d 1
		db	2,2,14,5,10,12	; 8 saver 0
		db	2,2,14,0,10,12	; 9 saver 1


looparrowon:	push	af
		ld	a,[loop_arrow]
		add	a
		call	looprect
		pop	af
		ld	[loop_arrow],a
		add	a
		inc	a
		jp	looprect



loopBumper:
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

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

loopset1:	ld	c,1
		jr	loopevent
loopset2:	ld	c,2
		jr	loopevent
loopset3:	ld	c,3
		jr	loopevent
loopset4:	ld	c,4
		jr	loopevent
loopset5:	ld	c,5
		jr	loopevent
loopset6:	ld	c,6
loopevent:	ld	a,[loop_last3]
		cp	c
		ret	z
		ld	a,[loop_last2]
		ld	[loop_last1],a
		ld	d,a		;#1
		ld	a,[loop_last3]
		ld	[loop_last2],a
		ld	e,a		;#2
		ld	a,c		;#3
		ld	[loop_last3],a

		ld	a,d
		cp	1
		jr	z,.maybe1
		cp	3
		jr	z,.maybe2
		cp	4
		jr	z,.maybe3
		cp	6
		jr	z,.maybe4
		ret
.maybe1:	ld	a,e
		cp	2
		ret	nz
		ld	a,c
		cp	3
		ret	nz
		ld	a,1
		ld	[loop_event],a
		ret
.maybe2:	ld	a,e
		cp	2
		ret	nz
		ld	a,c
		cp	1
		ret	nz
		ld	a,2
		ld	[loop_event],a
		ret
.maybe3:	ld	a,e
		cp	5
		ret	nz
		ld	a,c
		cp	6
		ret	nz
		ld	a,3
		ld	[loop_event],a
		ret
.maybe4:	ld	a,e
		cp	5
		ret	nz
		ld	a,c
		cp	4
		ret	nz
		ld	a,4
		ld	[loop_event],a
		ret

loopcollisions:
		dw	loopset1,30,55
		db	5,5
		dw	loopset2,28,11
		db	5,5
		dw	loopset3,62,46
		db	5,5
		dw	loopset4,113,44
		db	5,5
		dw	loopset5,147,11
		db	5,5
		dw	loopset6,145,56
		db	5,5
		dw	0

loophit:	ret

loopsprites:

		jp	SubFlippers

