; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** build.asm                                                             **
; **                                                                       **
; ** Created : 20000802 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

GROUP_GREEN	EQU	2

build_car	EQUS	"wTemp1024+00" ;2
build_rail	EQUS	"wTemp1024+02"
build_ons	EQUS	"wTemp1024+03"
build_white	EQUS	"wTemp1024+04"
build_whitemove	EQUS	"wTemp1024+05"
build_whitespeed EQUS	"wTemp1024+06"
build_pause	EQUS	"wTemp1024+07"


BUILDSCORE	EQU	25	;in 1000's. For each track built

buildinfo:	db	BANK(buildhit)		;wPinJmpHit
		dw	buildhit
		db	BANK(buildprocess)	;wPinJmpProcess
		dw	buildprocess
		db	BANK(buildsprites)	;wPinJmpSprites
		dw	buildsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(buildbumper)	;wPinJmpHitBumper
		dw	buildbumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(buildlostball)	;wPinJmpLost
		dw	buildlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(builddone)		;wPinJmpDone
		dw	builddone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

buildmaplist:	db	21
		dw	IDX_BUILDBACKRGB
		dw	IDX_BUILDBACKMAP

builddone:	ret

BuildInit::
		ld	a,300/16
		ld	[build_pause],a

		ld	hl,buildinfo
		call	SetPinInfo

		ld	a,TIME_BUILD
		call	SetTime

		ld	a,NEED_BUILD
		call	SetCount2

		call	buildwhitespeed

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_GREENCAR
		call	AddPalette

		ld	hl,IDX_BUILD0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,buildmaplist
		call	NewLoadMap
		ld	hl,IDX_BUILDLIGHTSMAP
		call	SecondHalf

		call	buildsaver.on

		call	buildfirstball

		call	subsaver

		ld	hl,buildcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

buildlostball:	ld	a,[any_ballsaver]
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

buildfirstball:
		ld	hl,0
		ld	de,FX
		ld	bc,FY
		jp	AddBall

buildprocess:
		ld	a,[build_pause]
		or	a
		jr	nz,.nocheck
		ld	hl,build_car
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		inc	l
		inc	l
		ld	a,[build_rail]
		cp	l
		call	c,AnyEnd
.nocheck:

		ld	a,[wTime]
		and	15
		cp	1
		call	z,buildmovecar
		call	buildwhite
		call	buildlights
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,buildsaver
		ret

buildmovecar:	ld	a,[build_pause]
		or	a
		jr	z,.nopause
		dec	a
		ld	[build_pause],a
		ret
.nopause:	ld	hl,build_car
		inc	[hl]
		jr	nz,.noinc2
		inc	hl
		inc	[hl]
.noinc2:	ret


buildtrack:
		ld	a,[build_rail]
		cp	58-26
		ret	nc
		inc	a
		ld	[build_rail],a
		add	26-1
		jp	buildrect


buildsaver:	ld	hl,any_ballsaver
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
.on:		ld	a,1
		jp	buildrect
.off:		ld	a,0
		jp	buildrect


;a=#
buildrect:	ld	hl,buildrects
		jp	RectList


buildrects:
		db	2,2,7,3,10,12	; 0 saver 0
		db	2,2,7,0,10,12	; 1 saver 1
		db	2,2,0,6,5,10	; 2 light a 0
		db	2,2,0,0,5,10	; 3 light a 1
		db	2,2,0,3,5,10	; 4 light a 2
		db	2,2,0,6,5,7	; 5 light b 0
		db	2,2,0,0,5,7	; 6 light b 1
		db	2,2,0,3,5,7	; 7 light b 2
		db	3,2,3,6,5,4	; 8 light c 0
		db	3,2,3,0,5,4	; 9 light c 1
		db	3,2,3,3,5,4	;10 light c 2
		db	3,2,3,6,8,4	;11 light d 0
		db	3,2,3,0,8,4	;12 light d 1
		db	3,2,3,3,8,4	;13 light d 2
		db	3,2,3,6,11,4	;14 light e 0
		db	3,2,3,0,11,4	;15 light e 1
		db	3,2,3,3,11,4	;16 light e 2
		db	3,2,3,6,14,4	;17 light f 0
		db	3,2,3,0,14,4	;18 light f 1
		db	3,2,3,3,14,4	;19 light f 2
		db	2,2,0,6,15,7	;20 light g 0
		db	2,2,0,0,15,7	;21 light g 1
		db	2,2,0,3,15,7	;22 light g 2
		db	2,2,0,6,15,10	;23 light h 0
		db	2,2,0,0,15,10	;24 light h 1
		db	2,2,0,3,15,10	;25 light h 2
		db	1,1,10,0,3,9	;26 rail 1
		db	1,1,10,0,3,8	;27 rail 2
		db	1,1,10,0,3,7	;28 rail 3
		db	1,1,10,0,3,6	;29 rail 4
		db	1,1,10,0,3,5	;30 rail 5
		db	1,1,10,0,3,4	;31 rail 6
		db	1,1,10,0,3,3	;32 rail 7
		db	1,1,10,3,3,2	;33 rail 8 (ul corner)
		db	1,1,10,6,4,2	;34 rail 9
		db	1,1,10,6,5,2	;35 rail 10
		db	1,1,10,6,6,2	;36 rail 11
		db	1,1,10,6,7,2	;37 rail 12
		db	1,1,10,6,8,2	;38 rail 13
		db	1,1,10,6,9,2	;39 rail 14
		db	1,1,10,6,10,2	;40 rail 15
		db	1,1,10,6,11,2	;41 rail 16
		db	1,1,10,6,12,2	;42 rail 17
		db	1,1,10,6,13,2	;43 rail 18
		db	1,1,10,6,14,2	;44 rail 19
		db	1,1,10,6,15,2	;45 rail 20
		db	1,1,10,6,16,2	;46 rail 21
		db	1,1,10,6,17,2	;47 rail 22
		db	1,1,10,9,18,2	;48 rail 23 (ur corner)
		db	1,1,10,12,18,3	;49 rail 24
		db	1,1,10,12,18,4	;50 rail 25
		db	1,1,10,12,18,5	;51 rail 26
		db	1,1,10,12,18,6	;52 rail 27
		db	1,1,10,12,18,7	;53 rail 28
		db	1,1,10,12,18,8	;54 rail 29
		db	1,1,10,12,18,9	;55 rail 30
		db	1,1,10,12,18,10	;56 rail 31
		db	1,1,10,12,18,11	;57 rail 32


buildbumper:
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

		ld	a,e
		cp	76
		jr	nc,.t07
		cp	50
		jr	nc,.t16
		ld	a,d
		cp	64
		jr	c,.t2
		cp	88
		jr	c,.t3
		cp	112
		jr	c,.t4
.t5:		ld	c,5
		jr	.target
.t4:		ld	c,4
		jr	.target
.t3:		ld	c,3
		jr	.target
.t2:		ld	c,2
		jr	.target
.t07:		ld	a,d
		cp	80
		jr	c,.t0
.t7:		ld	c,7
		jr	.target
.t0:		ld	c,0
		jr	.target
.t16:		ld	a,d
		cp	80
		jr	c,.t1
.t6:		ld	c,6
		jr	.target
.t1:		ld	c,1
.target:	call	buildtarget

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret


buildtarget:
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		ld	b,0
		ld	hl,buildbits
		add	hl,bc
		ld	d,[hl]
		ld	hl,build_ons
		ld	a,[build_white]
		cp	c
		jr	z,.force
		ld	a,d
		and	[hl]
		ret	nz
.force:		ld	a,d
		or	[hl]
		ld	[hl],a
		inc	a
		jr	nz,.noreset
		ld	[hl],0
.noreset:
		ld	a,[build_white]
		cp	c
		push	af
		call	z,.good
		call	.good
		pop	af
		ld	c,FX_BUILDHIT
		jr	nz,.cok
		ld	c,FX_BUILDWHITE
.cok:		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ld	a,c
		jr	nz,.aok
		ld	a,FX_BUILDWON
.aok:		jp	InitSfx

.good:		call	.double
.double:
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	Credit1
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		call	z,AnyEnd
		ld	hl,BUILDSCORE
		call	addthousandshl
		jp	buildtrack


buildcollisions:
		dw	0

buildhit:	ret

buildsprites:
		call	buildcar

		jp	SubFlippers

buildbits:	db	$01,$02,$04,$08,$10,$20,$40,$80
buildlights:	ld	a,[wTime]
		and	7
		ld	c,a
		add	a
		add	c
		add	2
		ld	e,a
		ld	a,[build_white]
		cp	c
		jr	z,.white
		ld	hl,buildbits
		ld	b,0
		add	hl,bc
		ld	a,[build_ons]
		and	[hl]
		jr	z,.on
.off:		ld	a,e
		jp	buildrect
.on:		ld	a,e
		inc	a
		jp	buildrect
.white:		ld	a,e
		add	2
		jp	buildrect

buildwhite:	ld	hl,build_whitemove
		inc	[hl]
		ld	a,[build_whitespeed]
		cp	[hl]
		ret	nz
		ld	[hl],0
		ld	a,[build_white]
		inc	a
		and	7
		ld	[build_white],a
		ret
buildwhitespeeds:
		db	120,90,60

buildwhitespeed:
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,buildwhitespeeds
		add	hl,bc
		ld	a,[hl]
		ld	[build_whitespeed],a
		ret
SPACE1		EQU	8
SPACE2		EQU	9

buildcar:
		ld	de,build_car
		ld	hl,buildtracklist
buildcoaster:	ld	a,[de]
		ld	c,a
		inc	de
		ld	a,[de]
		ld	b,a
		add	hl,bc
		add	hl,bc
		add	hl,bc
		ld	bc,6+3*(SPACE1+SPACE2)
		add	hl,bc

		ld	a,[hli]
		add	IDX_FRONT&255
		ld	c,a
		ld	a,0
		adc	IDX_FRONT>>8
		ld	b,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,GROUP_GREEN
		push	hl
		call	AddFigure
		pop	hl
		ld	de,-3-3*SPACE2
		add	hl,de
		ld	a,[hli]
		add	IDX_BACK&255
		ld	c,a
		ld	a,0
		adc	IDX_BACK>>8
		ld	b,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,GROUP_GREEN
		push	hl
		call	AddFigure
		pop	hl
		ld	de,-3-3*SPACE1
		add	hl,de
		ld	a,[hli]
		add	IDX_BACK&255
		ld	c,a
		ld	a,0
		adc	IDX_BACK>>8
		ld	b,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,GROUP_GREEN
		jp	AddFigure
buildtracklist:
	db	0,-61+80,19+72
	db	0,-61+80,18+72
	db	0,-61+80,17+72
	db	0,-61+80,16+72
	db	0,-61+80,15+72
	db	0,-61+80,14+72
	db	0,-61+80,13+72
	db	0,-61+80,12+72
	db	0,-61+80,11+72
	db	0,-61+80,10+72
	db	0,-61+80,9+72
	db	0,-61+80,8+72
	db	0,-61+80,7+72
	db	0,-61+80,6+72
	db	0,-61+80,5+72
	db	0,-61+80,4+72
	db	0,-61+80,3+72
	db	0,-61+80,2+72
	db	0,-61+80,1+72
	db	0,-61+80,0+72
	db	0,-61+80,-1+72
	db	0,-61+80,-2+72
	db	0,-61+80,-3+72
	db	0,-61+80,-4+72
	db	0,-61+80,-5+72
	db	0,-61+80,-6+72
	db	0,-61+80,-7+72
	db	0,-61+80,-8+72
	db	0,-61+80,-9+72
	db	0,-61+80,-10+72
	db	0,-61+80,-11+72
	db	0,-61+80,-12+72
	db	0,-61+80,-13+72
	db	0,-61+80,-14+72
	db	0,-61+80,-15+72
	db	0,-61+80,-16+72
	db	0,-61+80,-17+72
	db	0,-61+80,-18+72
	db	0,-61+80,-19+72
	db	0,-61+80,-20+72
	db	0,-61+80,-21+72
	db	0,-61+80,-22+72
	db	0,-61+80,-23+72
	db	0,-61+80,-24+72
	db	0,-61+80,-25+72
	db	0,-61+80,-26+72
	db	0,-61+80,-27+72
	db	0,-61+80,-28+72
	db	0,-61+80,-29+72
	db	0,-61+80,-30+72
	db	0,-61+80,-31+72
	db	0,-61+80,-32+72
	db	0,-61+80,-33+72
	db	0,-61+80,-34+72
	db	0,-61+80,-35+72
	db	0,-61+80,-36+72
	db	0,-61+80,-37+72
	db	0,-61+80,-38+72
	db	0,-61+80,-39+72
	db	0,-61+80,-40+72
	db	0,-61+80,-41+72
	db	0,-61+80,-42+72
	db	0,-61+80,-43+72
	db	0,-61+80,-44+72
	db	0,-61+80,-45+72
	db	0,-61+80,-46+72
	db	0,-61+80,-47+72
	db	0,-61+80,-48+72
	db	0,-61+80,-49+72
	db	1,-61+80,-50+72
	db	1,-61+80,-51+72
	db	2,-61+80,-52+72
	db	2,-60+80,-53+72
	db	3,-59+80,-53+72
	db	3,-58+80,-53+72
	db	4,-57+80,-53+72
	db	4,-56+80,-53+72
	db	4,-55+80,-53+72
	db	4,-54+80,-53+72
	db	4,-53+80,-53+72
	db	4,-52+80,-53+72
	db	4,-51+80,-53+72
	db	4,-50+80,-53+72
	db	4,-49+80,-53+72
	db	4,-48+80,-53+72
	db	4,-47+80,-53+72
	db	4,-46+80,-53+72
	db	4,-45+80,-53+72
	db	4,-44+80,-53+72
	db	4,-43+80,-53+72
	db	4,-42+80,-53+72
	db	4,-41+80,-53+72
	db	4,-40+80,-53+72
	db	4,-39+80,-53+72
	db	4,-38+80,-53+72
	db	4,-37+80,-53+72
	db	4,-36+80,-53+72
	db	4,-35+80,-53+72
	db	4,-34+80,-53+72
	db	4,-33+80,-53+72
	db	4,-32+80,-53+72
	db	4,-31+80,-53+72
	db	4,-30+80,-53+72
	db	4,-29+80,-53+72
	db	4,-28+80,-53+72
	db	4,-27+80,-53+72
	db	4,-26+80,-53+72
	db	4,-25+80,-53+72
	db	4,-24+80,-53+72
	db	4,-23+80,-53+72
	db	4,-22+80,-53+72
	db	4,-21+80,-53+72
	db	4,-20+80,-53+72
	db	4,-19+80,-53+72
	db	4,-18+80,-53+72
	db	4,-17+80,-53+72
	db	4,-16+80,-53+72
	db	4,-15+80,-53+72
	db	4,-14+80,-53+72
	db	4,-13+80,-53+72
	db	4,-12+80,-53+72
	db	4,-11+80,-53+72
	db	4,-10+80,-53+72
	db	4,-9+80,-53+72
	db	4,-8+80,-53+72
	db	4,-7+80,-53+72
	db	4,-6+80,-53+72
	db	4,-5+80,-53+72
	db	4,-4+80,-53+72
	db	4,-3+80,-53+72
	db	4,-2+80,-53+72
	db	4,-1+80,-53+72
	db	4,0+80,-53+72
	db	4,1+80,-53+72
	db	4,2+80,-53+72
	db	4,3+80,-53+72
	db	4,4+80,-53+72
	db	4,5+80,-53+72
	db	4,6+80,-53+72
	db	4,7+80,-53+72
	db	4,8+80,-53+72
	db	4,9+80,-53+72
	db	4,10+80,-53+72
	db	4,11+80,-53+72
	db	4,12+80,-53+72
	db	4,13+80,-53+72
	db	4,14+80,-53+72
	db	4,15+80,-53+72
	db	4,16+80,-53+72
	db	4,17+80,-53+72
	db	4,18+80,-53+72
	db	4,19+80,-53+72
	db	4,20+80,-53+72
	db	4,21+80,-53+72
	db	4,22+80,-53+72
	db	4,23+80,-53+72
	db	4,24+80,-53+72
	db	4,25+80,-53+72
	db	4,26+80,-53+72
	db	4,27+80,-53+72
	db	4,28+80,-53+72
	db	4,29+80,-53+72
	db	4,30+80,-53+72
	db	4,31+80,-53+72
	db	4,32+80,-53+72
	db	4,33+80,-53+72
	db	4,34+80,-53+72
	db	4,35+80,-53+72
	db	4,36+80,-53+72
	db	4,37+80,-53+72
	db	4,38+80,-53+72
	db	4,39+80,-53+72
	db	4,40+80,-53+72
	db	4,41+80,-53+72
	db	4,42+80,-53+72
	db	4,43+80,-53+72
	db	4,44+80,-53+72
	db	4,45+80,-53+72
	db	4,46+80,-53+72
	db	4,47+80,-53+72
	db	4,48+80,-53+72
	db	4,49+80,-53+72
	db	4,50+80,-53+72
	db	4,51+80,-53+72
	db	4,52+80,-53+72
	db	4,53+80,-53+72
	db	4,54+80,-53+72
	db	4,55+80,-53+72
	db	5,56+80,-53+72
	db	5,57+80,-53+72
	db	6,58+80,-53+72
	db	6,59+80,-52+72
	db	7,59+80,-51+72
	db	7,59+80,-50+72
	db	8,59+80,-49+72
	db	8,59+80,-48+72
	db	8,59+80,-47+72
	db	8,59+80,-46+72
	db	8,59+80,-45+72
	db	8,59+80,-44+72
	db	8,59+80,-43+72
	db	8,59+80,-42+72
	db	8,59+80,-41+72
	db	8,59+80,-40+72
	db	8,59+80,-39+72
	db	8,59+80,-38+72
	db	8,59+80,-37+72
	db	8,59+80,-36+72
	db	8,59+80,-35+72
	db	8,59+80,-34+72
	db	8,59+80,-33+72
	db	8,59+80,-32+72
	db	8,59+80,-31+72
	db	8,59+80,-30+72
	db	8,59+80,-29+72
	db	8,59+80,-28+72
	db	8,59+80,-27+72
	db	8,59+80,-26+72
	db	8,59+80,-25+72
	db	8,59+80,-24+72
	db	8,59+80,-23+72
	db	8,59+80,-22+72
	db	8,59+80,-21+72
	db	8,59+80,-20+72
	db	8,59+80,-19+72
	db	8,59+80,-18+72
	db	8,59+80,-17+72
	db	8,59+80,-16+72
	db	8,59+80,-15+72
	db	8,59+80,-14+72
	db	8,59+80,-13+72
	db	8,59+80,-12+72
	db	8,59+80,-11+72
	db	8,59+80,-10+72
	db	8,59+80,-9+72
	db	8,59+80,-8+72
	db	8,59+80,-7+72
	db	8,59+80,-6+72
	db	8,59+80,-5+72
	db	8,59+80,-4+72
	db	8,59+80,-3+72
	db	8,59+80,-2+72
	db	8,59+80,-1+72
	db	8,59+80,0+72
	db	8,59+80,1+72
	db	8,59+80,2+72
	db	8,59+80,3+72
	db	8,59+80,4+72
	db	8,59+80,5+72
	db	8,59+80,6+72
	db	8,59+80,7+72
	db	8,59+80,8+72
	db	8,59+80,9+72
	db	8,59+80,10+72
	db	8,59+80,11+72
	db	8,59+80,12+72
	db	8,59+80,13+72
	db	8,59+80,14+72
	db	8,59+80,15+72
	db	8,59+80,16+72
	db	8,59+80,17+72
	db	8,59+80,18+72
LEN	EQU	(@-buildtracklist)/3-SPACE1-SPACE2-3
