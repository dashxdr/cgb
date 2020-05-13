; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** race.asm                                                              **
; **                                                                       **
; ** Created : 20000802 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	30

GROUP_RED	EQU	2
GROUP_BLUE	EQU	3

race_second	EQUS	"wTemp1024+00"
race_color	EQUS	"wTemp1024+01"
race_car1	EQUS	"wTemp1024+02" ;2 bytes
race_car2	EQUS	"wTemp1024+04" ;2 bytes
race_add1	EQUS	"wTemp1024+06"
race_add2	EQUS	"wTemp1024+07"
race_ons	EQUS	"wTemp1024+08"
race_white	EQUS	"wTemp1024+09"
race_whitemove	EQUS	"wTemp1024+10"
race_whitespeed	EQUS	"wTemp1024+11"
race_tempcolor	EQUS	"wTemp1024+12"

RACESCORE	EQU	25		;per hit, in 1000's

raceinfo:	db	BANK(racehit)		;wPinJmpHit
		dw	racehit
		db	BANK(raceprocess)	;wPinJmpProcess
		dw	raceprocess
		db	BANK(racesprites)	;wPinJmpSprites
		dw	racesprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(racebumper)	;wPinJmpHitBumper
		dw	racebumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(racelostball)	;wPinJmpLost
		dw	racelostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(racedone)		;wPinJmpDone
		dw	racedone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

racemaplist:	db	21
		dw	IDX_RACEBACKRGB
		dw	IDX_RACEBACKMAP

racedone:	ret

RaceInit::
		ld	hl,raceinfo
		call	SetPinInfo

		ld	a,TIME_RACE
		call	SetTime

		ld	a,NEED_RACE
		call	SetCount2

		call	setwhitespeed

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_FRONT
		call	AddPalette
		ld	hl,PAL_BLUECAR
		call	AddPalette

		ld	hl,IDX_RACE0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,racemaplist
		call	NewLoadMap
		ld	hl,IDX_RACELIGHTSMAP
		call	SecondHalf

		call	racesaver.on

		call	racefirstball

		call	subsaver

		ld	hl,racecollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

racelostball:	ld	a,[any_ballsaver]
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
racefirstball:
		ld	hl,0
		ld	de,FX
		ld	bc,FY
		jp	AddBall

raceprocess:




		call	racewhite
		call	racelights


 ld a,[wJoy1Cur]
 bit JOY_R,a
 jr nz,.force1
 ld a,[wJoy1Hit]
 bit JOY_SELECT,a
 jr nz,.force1
		ld	a,[race_add1]
		or	a
		jr	z,.no1
		dec	a
		ld	[race_add1],a
.force1:	ld	hl,race_car1
		inc	[hl]
		jr	nz,.no1
		inc	hl
		inc	[hl]
.no1:

 ld a,[wJoy1Cur]
 bit JOY_R,a
 jr nz,.force2
 ld a,[wJoy1Hit]
 bit JOY_SELECT,a
 jr nz,.force2
		ld	a,[race_add2]
		or	a
		jr	z,.no2
		dec	a
		ld	[race_add2],a
.force2:	ld	hl,race_car2
		inc	[hl]
		jr	nz,.no2
		inc	hl
		inc	[hl]
.no2:

		ld	a,[race_car1]
		sub	LEN1&255
		ld	a,[race_car1+1]
		sbc	LEN1>>8
		call	nc,racelost
		ld	a,[race_car2]
		sub	LEN2&255
		ld	a,[race_car2+1]
		sbc	LEN2>>8
		call	nc,racewon



		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,racesaver

		ld	hl,race_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:

		ret

racelost:
racewon:
		jp	AnyEnd


racesaver:	ld	hl,any_ballsaver
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
		jp	racerect
.off:		ld	a,0
		jp	racerect


;a=#
racerect:	ld	hl,racerects
		jp	RectList


racerects:	db	2,2,14,3,10,12	; 0 saver 0
		db	2,2,14,0,10,12	; 1 saver 1
		db	2,2,3,6,5,10	; 2 red a 0
		db	2,2,3,0,5,10	; 3 red a 1
		db	2,2,3,3,5,10	; 4 red a 2
		db	2,2,3,6,5,7	; 5 red b 0
		db	2,2,3,0,5,7	; 6 red b 1
		db	2,2,3,3,5,7	; 7 red b 2
		db	3,2,10,6,5,4	; 8 red c 0
		db	3,2,10,0,5,4	; 9 red c 1
		db	3,2,10,3,5,4	;10 red c 2
		db	3,2,10,6,8,4	;11 red d 0
		db	3,2,10,0,8,4	;12 red d 1
		db	3,2,10,3,8,4	;13 red d 2
		db	3,2,6,6,11,4	;14 blue a 0
		db	3,2,6,0,11,4	;15 blue a 1
		db	3,2,6,3,11,4	;16 blue a 2
		db	3,2,6,6,14,4	;17 blue b 0
		db	3,2,6,0,14,4	;18 blue b 1
		db	3,2,6,3,14,4	;19 blue b 2
		db	2,2,0,6,15,7	;20 blue c 0
		db	2,2,0,0,15,7	;21 blue c 1
		db	2,2,0,3,15,7	;22 blue c 2
		db	2,2,0,6,15,10	;23 blue d 0
		db	2,2,0,0,15,10	;24 blue d 1
		db	2,2,0,3,15,10	;25 blue d 2


racebumper:
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
.target:	call	racetarget

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

RACESTEP	EQU	12

racetarget:
		ld	a,c
		cp	4
		ld	b,1
		jr	c,.bok
		ld	b,2
.bok:

		ld	a,[race_color]
		or	a
		jr	nz,.notfirst
		ld	a,b
		ld	[race_color],a
		add	2
		ld	[race_white],a
.notfirst:
		ld	a,[race_color]
		xor	b
		jr	z,.good
		ld	a,[race_add1]
		add	RACESTEP
		ld	[race_add1],a
		ret
.good:		ld	b,0
		ld	hl,racebits
		add	hl,bc
		ld	a,[hl]
		ld	d,a
		ld	hl,race_ons
		ld	a,[race_white]
		cp	c
		jr	z,.force
		ld	a,d
		and	[hl]
		ret	nz
.force:		ld	a,[hl]
		or	d
		ld	[hl],a
		cp	$f0
		jr	z,.full
		cp	$0f
		jr	nz,.notfull
.full:		ld	[hl],0
.notfull:
		ld	a,[race_white]
		cp	c
		push	af
		call	z,.double
		call	.double
		pop	af
		ld	c,FX_RACEHIT
		jr	nz,.cok
		ld	c,FX_RACEWHITE
.cok:		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ld	a,c
		jr	nz,.aok
		ld	a,FX_RACEWON
.aok:		jp	InitSfx
.double:	ld	a,[race_add2]
		add	RACESTEP
		ld	[race_add2],a
		ld	hl,RACESCORE
		call	addthousandshl
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	Credit1
		jp	AnyDec2

racecollisions:
		dw	0

racehit:	ret

racewhitespeeds:
		db	120,90,60

setwhitespeed:
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,racewhitespeeds
		add	hl,bc
		ld	a,[hl]
		ld	[race_whitespeed],a
		ret

whiteleft:	db	3,0,1,2,0,0,0,0
whiteright:	db	0,0,0,0,5,6,7,4


racewhite:	ld	a,[race_color]
		or	a
		ret	z
		ld	b,a
		ld	hl,race_whitemove
		inc	[hl]
		ld	a,[race_whitespeed]
		cp	[hl]
		ret	nz
		ld	[hl],0
		ld	hl,whiteleft
		dec	b
		jr	z,.hlok
		ld	hl,whiteright
.hlok:		ld	a,[race_white]
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[hl]
		ld	[race_white],a
		ret
		

racebits:	db	$01,$02,$04,$08,$10,$20,$40,$80
racelights:	ld	a,[wTime]
		and	7
		ld	c,a
		add	a
		add	c
		add	2
		ld	e,a
		ld	a,[race_color]
		or	a
		jr	z,.off
		dec	a
		add	a
		add	a
		xor	c
		and	4
		jr	nz,.off
		ld	a,[race_white]
		cp	c
		jr	z,.white
		ld	hl,racebits
		ld	b,0
		add	hl,bc
		ld	a,[race_ons]
		and	[hl]
		jr	z,.on
.off:		ld	a,e
		jp	racerect
.on:		ld	a,e
		inc	a
		jp	racerect
.white:		ld	a,e
		add	2
		jp	racerect



racesprites:
		ld	a,[race_color]
		or	a
		call	nz,racecars

		jp	SubFlippers


SPACE1		EQU	8
SPACE2		EQU	9

racecars:
		ld	de,race_car1
		ld	hl,racetrack1
		ld	a,[race_color]
		cp	1
		ld	a,GROUP_RED
		jr	nz,.ok1
		ld	a,GROUP_BLUE
.ok1:
		call	coaster

		ld	de,race_car2
		ld	hl,racetrack2
		ld	a,[race_color]
		cp	1
		ld	a,GROUP_BLUE
		jr	nz,.ok2
		ld	a,GROUP_RED
.ok2:

coaster:	ld	[race_tempcolor],a
		ld	a,[de]
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
		ld	a,[race_tempcolor]
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
		ld	a,[race_tempcolor]
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
		ld	a,[race_tempcolor]
		jp	AddFigure

racetrack2:
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
LEN2	EQU	(@-racetrack2)/3-SPACE1-SPACE2-3

racetrack1:
	db	0,-77+80,18+72
	db	0,-77+80,17+72
	db	0,-77+80,16+72
	db	0,-77+80,15+72
	db	0,-77+80,14+72
	db	0,-77+80,13+72
	db	0,-77+80,12+72
	db	0,-77+80,11+72
	db	0,-77+80,10+72
	db	0,-77+80,9+72
	db	0,-77+80,8+72
	db	0,-77+80,7+72
	db	0,-77+80,6+72
	db	0,-77+80,5+72
	db	0,-77+80,4+72
	db	0,-77+80,3+72
	db	0,-77+80,2+72
	db	0,-77+80,1+72
	db	0,-77+80,0+72
	db	0,-77+80,-1+72
	db	0,-77+80,-2+72
	db	0,-77+80,-3+72
	db	0,-77+80,-4+72
	db	0,-77+80,-5+72
	db	0,-77+80,-6+72
	db	0,-77+80,-7+72
	db	0,-77+80,-8+72
	db	0,-77+80,-9+72
	db	0,-77+80,-10+72
	db	0,-77+80,-11+72
	db	0,-77+80,-12+72
	db	0,-77+80,-13+72
	db	0,-77+80,-14+72
	db	0,-77+80,-15+72
	db	0,-77+80,-16+72
	db	0,-77+80,-17+72
	db	0,-77+80,-18+72
	db	0,-77+80,-19+72
	db	0,-77+80,-20+72
	db	0,-77+80,-21+72
	db	0,-77+80,-22+72
	db	0,-77+80,-23+72
	db	0,-77+80,-24+72
	db	0,-77+80,-25+72
	db	0,-77+80,-26+72
	db	0,-77+80,-27+72
	db	0,-77+80,-28+72
	db	0,-77+80,-29+72
	db	0,-77+80,-30+72
	db	0,-77+80,-31+72
	db	0,-77+80,-32+72
	db	0,-77+80,-33+72
	db	0,-77+80,-34+72
	db	0,-77+80,-35+72
	db	0,-77+80,-36+72
	db	0,-77+80,-37+72
	db	0,-77+80,-38+72
	db	0,-77+80,-39+72
	db	0,-77+80,-40+72
	db	0,-77+80,-41+72
	db	0,-77+80,-42+72
	db	0,-77+80,-43+72
	db	0,-77+80,-44+72
	db	0,-77+80,-45+72
	db	0,-77+80,-46+72
	db	0,-77+80,-47+72
	db	0,-77+80,-48+72
	db	0,-77+80,-49+72
	db	0,-77+80,-50+72
	db	0,-77+80,-51+72
	db	0,-77+80,-52+72
	db	0,-77+80,-53+72
	db	0,-77+80,-54+72
	db	0,-77+80,-55+72
	db	0,-77+80,-56+72
	db	0,-77+80,-57+72
	db	0,-77+80,-58+72
	db	0,-77+80,-59+72
	db	0,-77+80,-60+72
	db	0,-77+80,-61+72
	db	0,-77+80,-62+72
	db	0,-77+80,-63+72
	db	0,-77+80,-64+72
	db	1,-77+80,-65+72
	db	1,-77+80,-66+72
	db	2,-77+80,-67+72
	db	2,-76+80,-69+72
	db	3,-75+80,-69+72
	db	3,-74+80,-69+72
	db	4,-73+80,-69+72
	db	4,-72+80,-69+72
	db	4,-71+80,-69+72
	db	4,-70+80,-69+72
	db	4,-69+80,-69+72
	db	4,-68+80,-69+72
	db	4,-67+80,-69+72
	db	4,-66+80,-69+72
	db	4,-65+80,-69+72
	db	4,-64+80,-69+72
	db	4,-63+80,-69+72
	db	4,-62+80,-69+72
	db	4,-61+80,-69+72
	db	4,-60+80,-69+72
	db	4,-59+80,-69+72
	db	4,-58+80,-69+72
	db	4,-57+80,-69+72
	db	4,-56+80,-69+72
	db	4,-55+80,-69+72
	db	4,-54+80,-69+72
	db	4,-53+80,-69+72
	db	4,-52+80,-69+72
	db	4,-51+80,-69+72
	db	4,-50+80,-69+72
	db	4,-49+80,-69+72
	db	4,-48+80,-69+72
	db	4,-47+80,-69+72
	db	4,-46+80,-69+72
	db	4,-45+80,-69+72
	db	4,-44+80,-69+72
	db	4,-43+80,-69+72
	db	4,-42+80,-69+72
	db	4,-41+80,-69+72
	db	4,-40+80,-69+72
	db	4,-39+80,-69+72
	db	4,-38+80,-69+72
	db	4,-37+80,-69+72
	db	4,-36+80,-69+72
	db	4,-35+80,-69+72
	db	4,-34+80,-69+72
	db	4,-33+80,-69+72
	db	4,-32+80,-69+72
	db	4,-31+80,-69+72
	db	4,-30+80,-69+72
	db	4,-29+80,-69+72
	db	4,-28+80,-69+72
	db	4,-27+80,-69+72
	db	4,-26+80,-69+72
	db	4,-25+80,-69+72
	db	4,-24+80,-69+72
	db	4,-23+80,-69+72
	db	4,-22+80,-69+72
	db	4,-21+80,-69+72
	db	4,-20+80,-69+72
	db	4,-19+80,-69+72
	db	4,-18+80,-69+72
	db	4,-17+80,-69+72
	db	4,-16+80,-69+72
	db	4,-15+80,-69+72
	db	4,-14+80,-69+72
	db	4,-13+80,-69+72
	db	4,-12+80,-69+72
	db	4,-11+80,-69+72
	db	4,-10+80,-69+72
	db	4,-9+80,-69+72
	db	4,-8+80,-69+72
	db	4,-7+80,-69+72
	db	4,-6+80,-69+72
	db	4,-5+80,-69+72
	db	4,-4+80,-69+72
	db	4,-3+80,-69+72
	db	4,-2+80,-69+72
	db	4,-1+80,-69+72
	db	4,0+80,-69+72
	db	4,1+80,-69+72
	db	4,2+80,-69+72
	db	4,3+80,-69+72
	db	4,4+80,-69+72
	db	4,5+80,-69+72
	db	4,6+80,-69+72
	db	4,7+80,-69+72
	db	4,8+80,-69+72
	db	4,9+80,-69+72
	db	4,10+80,-69+72
	db	4,11+80,-69+72
	db	4,12+80,-69+72
	db	4,13+80,-69+72
	db	4,14+80,-69+72
	db	4,15+80,-69+72
	db	4,16+80,-69+72
	db	4,17+80,-69+72
	db	4,18+80,-69+72
	db	4,19+80,-69+72
	db	4,20+80,-69+72
	db	4,21+80,-69+72
	db	4,22+80,-69+72
	db	4,23+80,-69+72
	db	4,24+80,-69+72
	db	4,25+80,-69+72
	db	4,26+80,-69+72
	db	4,27+80,-69+72
	db	4,28+80,-69+72
	db	4,29+80,-69+72
	db	4,30+80,-69+72
	db	4,31+80,-69+72
	db	4,32+80,-69+72
	db	4,33+80,-69+72
	db	4,34+80,-69+72
	db	4,35+80,-69+72
	db	4,36+80,-69+72
	db	4,37+80,-69+72
	db	4,38+80,-69+72
	db	4,39+80,-69+72
	db	4,40+80,-69+72
	db	4,41+80,-69+72
	db	4,42+80,-69+72
	db	4,43+80,-69+72
	db	4,44+80,-69+72
	db	4,45+80,-69+72
	db	4,46+80,-69+72
	db	4,47+80,-69+72
	db	4,48+80,-69+72
	db	4,49+80,-69+72
	db	4,50+80,-69+72
	db	4,51+80,-69+72
	db	4,52+80,-69+72
	db	4,53+80,-69+72
	db	4,54+80,-69+72
	db	4,55+80,-69+72
	db	4,56+80,-69+72
	db	4,57+80,-69+72
	db	4,58+80,-69+72
	db	4,59+80,-69+72
	db	4,60+80,-69+72
	db	4,61+80,-69+72
	db	4,62+80,-69+72
	db	4,63+80,-69+72
	db	4,64+80,-69+72
	db	4,65+80,-69+72
	db	4,66+80,-69+72
	db	4,67+80,-69+72
	db	4,68+80,-69+72
	db	4,69+80,-69+72
	db	4,70+80,-69+72
	db	4,71+80,-69+72
	db	5,72+80,-69+72
	db	5,73+80,-69+72
	db	6,74+80,-69+72
	db	6,75+80,-68+72
	db	7,75+80,-67+72
	db	7,75+80,-66+72
	db	8,75+80,-65+72
	db	8,75+80,-64+72
	db	8,75+80,-63+72
	db	8,75+80,-62+72
	db	8,75+80,-61+72
	db	8,75+80,-60+72
	db	8,75+80,-59+72
	db	8,75+80,-58+72
	db	8,75+80,-57+72
	db	8,75+80,-56+72
	db	8,75+80,-55+72
	db	8,75+80,-54+72
	db	8,75+80,-53+72
	db	8,75+80,-52+72
	db	8,75+80,-51+72
	db	8,75+80,-50+72
	db	8,75+80,-49+72
	db	8,75+80,-48+72
	db	8,75+80,-47+72
	db	8,75+80,-46+72
	db	8,75+80,-45+72
	db	8,75+80,-44+72
	db	8,75+80,-43+72
	db	8,75+80,-42+72
	db	8,75+80,-41+72
	db	8,75+80,-40+72
	db	8,75+80,-39+72
	db	8,75+80,-38+72
	db	8,75+80,-37+72
	db	8,75+80,-36+72
	db	8,75+80,-35+72
	db	8,75+80,-34+72
	db	8,75+80,-33+72
	db	8,75+80,-32+72
	db	8,75+80,-31+72
	db	8,75+80,-30+72
	db	8,75+80,-29+72
	db	8,75+80,-28+72
	db	8,75+80,-27+72
	db	8,75+80,-26+72
	db	8,75+80,-25+72
	db	8,75+80,-24+72
	db	8,75+80,-23+72
	db	8,75+80,-22+72
	db	8,75+80,-21+72
	db	8,75+80,-20+72
	db	8,75+80,-19+72
	db	8,75+80,-18+72
	db	8,75+80,-17+72
	db	8,75+80,-16+72
	db	8,75+80,-15+72
	db	8,75+80,-14+72
	db	8,75+80,-13+72
	db	8,75+80,-12+72
	db	8,75+80,-11+72
	db	8,75+80,-10+72
	db	8,75+80,-9+72
	db	8,75+80,-8+72
	db	8,75+80,-7+72
	db	8,75+80,-6+72
	db	8,75+80,-5+72
	db	8,75+80,-4+72
	db	8,75+80,-3+72
	db	8,75+80,-2+72
	db	8,75+80,-1+72
	db	8,75+80,0+72
	db	8,75+80,1+72
	db	8,75+80,2+72
	db	8,75+80,3+72
	db	8,75+80,4+72
	db	8,75+80,5+72
	db	8,75+80,6+72
	db	8,75+80,7+72
	db	8,75+80,8+72
	db	8,75+80,9+72
	db	8,75+80,10+72
	db	8,75+80,11+72
	db	8,75+80,12+72
	db	8,75+80,13+72
	db	8,75+80,14+72
	db	8,75+80,15+72
	db	8,75+80,16+72
	db	8,75+80,17+72
	db	8,75+80,18+72
LEN1	EQU	(@-racetrack1)/3-SPACE1-SPACE2-3
