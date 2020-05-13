; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** rapids.asm                                                            **
; **                                                                       **
; ** Created : 20000801 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	03

		INTERFACE SubHitFlipper
RAPIDSCORE1	EQU	100	;saved a raft
RAPIDSCORE2	EQU	5	;submerged a rock

GROUP_RAFT	EQU	2
GROUP_RIPPLE	EQU	3

rapid_second	EQUS	"wTemp1024+00"
rapid_hits	EQUS	"wTemp1024+01" ;9 bytes
rapid_sink	EQUS	"wTemp1024+10"
rapid_raise	EQUS	"wTemp1024+11"
rapid_rafts	EQUS	"wTemp1024+12" ;4
rapid_onemore	EQUS	"wTemp1024+16"
rapid_frame	EQUS	"wTemp1024+17"
rapid_ripplepos	EQUS	"wTemp1024+18"
rapid_ripple	EQUS	"wTemp1024+19"

MAXHEIGHT	EQU	7

rapidinfo:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(rapidprocess)	;wPinJmpProcess
		dw	rapidprocess
		db	BANK(rapidsprites)	;wPinJmpSprites
		dw	rapidsprites
		db	BANK(rapidhit)		;wPinJmpHitFlipper
		dw	rapidhit
		db	BANK(Nothing)		;wPinJmpHitBumper
		dw	Nothing
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(rapidlostball)	;wPinJmpLost
		dw	rapidlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(rapiddone)		;wPinJmpDone
		dw	rapiddone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

rapidmaplist:	db	21
		dw	IDX_RAPIDBACKRGB
		dw	IDX_RAPIDBACKMAP

rapiddone:	ret

RapidsInit::

		ld	hl,rapidinfo
		call	SetPinInfo

		ld	a,NEED_RAPIDS
		ld	[rapid_onemore],a
		call	SetCount2

		ld	a,TIME_RAPID
		call	SetTime

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_RAFT
		call	AddPalette
		ld	hl,PAL_RIPPLE
		call	AddPalette

		ld	hl,IDX_RAPID0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		call	rocksup

		ld	hl,rapidmaplist
		call	NewLoadMap
		ld	hl,IDX_RAPIDLIGHTSMAP
		call	SecondHalf

		call	rapidon
		call	rapidsaver.on

 call	SubAddBall

		call	subsaver

		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,hitsrequired
		add	hl,bc
		ld	a,[hl]
		ld	[rapid_sink],a
		ld	hl,risetime
		add	hl,bc
		ld	a,[hl]
		add	$80
		ld	[rapid_raise],a

	call	random
	and	15
	inc	a
	ld	[rapid_rafts],a
	call	random
	and	15
	inc	a
	ld	[rapid_rafts+2],a
	ld	hl,rapid_onemore
	dec	[hl]
	dec	[hl]



		ld	hl,rapidcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

rapidlostball:	ld	a,[any_ballsaver]
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

rapidprocess:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,rapidsaver

		ld	a,[wTime]
		and	7
		jr	nz,.nospin
		ld	a,[rapid_frame]
		inc	a
		cp	5
		jr	c,.aok
		xor	a
.aok:		ld	[rapid_frame],a
.nospin:

		ld	a,[wTime]
		and	3
		call	z,moverafts

		ld	hl,rapid_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

		call	raiserocks

.nosecond:

		ret

rapidsaver:	ld	hl,any_ballsaver
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
.on:		ld	a,19
		jp	rapidrect
.off:		ld	a,18
		jp	rapidrect


rapidon:	ld	a,0
		call	rapidrect
		ld	a,2
		call	rapidrect
		ld	a,4
		call	rapidrect
		ld	a,6
		call	rapidrect
		ld	a,8
		call	rapidrect
		ld	a,10
		call	rapidrect
		ld	a,12
		call	rapidrect
		ld	a,14
		call	rapidrect
		ld	a,16
		jr	rapidrect

rocksup:	ld	hl,IDX_RAPID0002CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0003CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0004CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0005CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0006CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0007CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0008CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0009CHG
		call	MakeChanges
		ld	hl,IDX_RAPID0010CHG
		call	MakeChanges

		ld	a,0
		call	rapidrect
		ld	a,2
		call	rapidrect
		ld	a,4
		call	rapidrect
		ld	a,6
		call	rapidrect
		ld	a,8
		call	rapidrect
		ld	a,10
		call	rapidrect
		ld	a,12
		call	rapidrect
		ld	a,14
		call	rapidrect
		ld	a,16
		call	rapidrect

		ret

;a=#
rapidrect:	ld	hl,rapidrects
		jp	RectList


rapidrects:	db	2,2,0,0,4,3	; 0 rock 0 1
		db	2,2,0,4,4,3	; 1 rock 0 0
		db	2,3,8,0,16,2	; 2 rock 1 1
		db	2,3,8,4,16,2	; 3 rock 1 0
		db	2,2,2,0,7,5	; 4 rock 2 1
		db	2,2,2,4,7,5	; 5 rock 2 0
		db	2,3,6,0,13,4	; 6 rock 3 1
		db	2,3,6,4,13,4	; 7 rock 3 0
		db	2,2,4,0,10,7	; 8 rock 4 1
		db	2,2,4,4,10,7	; 9 rock 4 0
		db	2,3,12,0,7,9	;10 rock 5 1
		db	2,3,12,4,7,9	;11 rock 5 0
		db	2,3,14,0,13,9	;12 rock 6 1
		db	2,3,14,4,13,9	;13 rock 6 0
		db	2,2,10,0,4,11	;14 rock 7 1
		db	2,2,10,4,4,11	;15 rock 7 0
		db	2,2,16,0,16,11	;16 rock 8 1
		db	2,2,16,4,16,11	;17 rock 8 0
		db	2,2,0,11,10,12	;18 saver 0
		db	2,2,0,8,10,12	;19 saver 1

rapidhit:
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
		cp	110
		jp	nc,.notarock

		ld	a,d
		cp	125
		jr	nc,.column4
		cp	100
		jr	nc,.column3
		cp	75
		jr	nc,.column2
		cp	50
		jr	nc,.column1
.column0:	ld	a,e
		cp	64
		ld	a,0
		jr	c,.rock
		ld	a,7
		jr	.rock
.column1:	ld	a,e
		cp	64
		ld	a,2
		jr	c,.rock
		ld	a,5
		jr	.rock
.column2:	ld	a,4
		jr	.rock
.column3:	ld	a,e
		cp	64
		ld	a,3
		jr	c,.rock
		ld	a,6
		jr	.rock
.column4:	ld	a,e
		cp	64
		ld	a,1
		jr	c,.rock
		ld	a,8
.rock:		call	hitrock

.notarock:
		jp	SubHitFlipper_b
;		ld	hl,pin_flags2
;		res	PINFLG2_HARD,[hl]
;		ret

hitrock:	ld	e,a
		ld	d,0
		ld	hl,rapid_hits
		add	hl,de
		inc	[hl]
		ld	a,[rapid_sink]
		cp	[hl]
		ret	nz
		ld	[hl],$80
		ld	hl,IDX_RAPID0002CHG
		add	hl,de
		push	de
		call	UndoChanges
		pop	de
		ld	a,e
		push	af
		add	a
		inc	a
		call	rapidrect
		pop	af
		inc	a
		ld	[rapid_ripplepos],a
		xor	a
		ld	[rapid_ripple],a
		ld	a,FX_RAPIDROCK
		call	InitSfx
		ld	hl,RAPIDSCORE2
		jp	addthousandshlinform

raiserocks:	ld	hl,rapid_hits
		ld	bc,0
.raise:		bit	7,[hl]
		jr	z,.next
		inc	[hl]
		ld	a,[rapid_raise]
		cp	[hl]
		jr	nz,.next
		ld	[hl],0
		push	hl
		push	bc
		ld	hl,IDX_RAPID0002CHG
		add	hl,bc
		call	MakeChanges
		pop	bc
		push	bc
		ld	a,c
		add	a
		call	rapidrect
		pop	bc
		pop	hl
.next:		inc	hl
		inc	c
		ld	a,c
		cp	9
		jr	c,.raise
		ret


hitsrequired:	db	1,1,1
risetime:	db	12,10,8

rapidcollisions:
		dw	0

rapidsprites:
		call	rapidrafts
		call	rapidripple
		jp	SubFlippers

rapidrafts:	ld	a,[rapid_rafts]
		or	a
		call	nz,leftraft
		ld	a,[rapid_rafts+1]
		or	a
		call	nz,leftraft
		ld	a,[rapid_rafts+2]
		or	a
		call	nz,rightraft
		ld	a,[rapid_rafts+3]
		or	a
		call	nz,rightraft
		ret
leftraft:	ld	hl,rapidlist1
		jr	bothrafts
rightraft:	ld	hl,rapidlist2
bothrafts:	dec	a
		cp	LASTRAFT
		ret	nc
		add	a
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[hli]
		sub	8
		ld	d,a
		ld	a,[hl]
		sub	4
		ld	e,a
		ld	bc,IDX_RAFT
		ld	a,[rapid_frame]
		add	c
		ld	c,a
		jr	nz,.noincb
		inc	b
.noincb:
		ld	a,GROUP_RAFT
		jp	AddFigure

rapidripple:	ld	a,[rapid_ripplepos]
		or	a
		ret	z
		dec	a
		add	a
		ld	c,a
		ld	b,0
		ld	hl,ripplepositions
		add	hl,bc
		ld	a,[hli]
		add	8
		ld	d,a
		ld	a,[hl]
		add	16
		ld	e,a
		ld	a,[rapid_ripple]
		inc	a
		cp	8*4
		jr	nc,.done
		ld	[rapid_ripple],a
		srl	a
		srl	a
		add	IDX_RIPPLE&255
		ld	c,a
		ld	a,0
		adc	IDX_RIPPLE>>8
		ld	b,a
		ld	a,GROUP_RIPPLE
		jp	AddFigure
.done:		xor	a
		ld	[rapid_ripplepos],a
		ret


moverafts:	ld	hl,rapid_rafts
		call	processleftraft
		ld	hl,rapid_rafts+1
		call	processleftraft
		ld	hl,rapid_rafts+2
		call	processrightraft
		ld	hl,rapid_rafts+3
		jp	processrightraft

processleftraft:
		ld	de,leftstops
		jr	processbothrafts
processrightraft:
		ld	de,rightstops
processbothrafts:
		ld	a,[hl]
		or	a
		ret	z
		dec	a
		ld	c,a
.find:		ld	a,[de]
		inc	de
		inc	de
		or	a
		jr	z,.continue
		cp	c
		jr	nz,.find
		dec	de
		ld	a,[de]
		ld	bc,rapid_hits
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,[bc]
		add	a
		ret	nc
.continue:	inc	[hl]
		ld	a,[hl]
		cp	LASTRAFT+20
		ret	c
		ld	[hl],0
		ld	a,[rapid_onemore]
		or	a
		jr	z,.nomore
		dec	a
		ld	[rapid_onemore],a
		inc	[hl]
.nomore:	call	Credit1
		call	AnyDec2
		ld	a,FX_RAPIDBOAT
		call	InitSfx
		ld	hl,RAPIDSCORE1
		call	addthousandshlinform
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	nz
		ld	a,FX_RAPIDWON
		call	InitSfx
		jp	AnyEnd

leftstops:	db	12*2,0
		db	20*2,2
		db	28*2,4
		db	36*2,6
		db	44*2,8
		db	0
rightstops:	db	12*2,1
		db	20*2,3
		db	28*2,4
		db	36*2,5
		db	44*2,7
		db	0

LASTRAFT	EQU	128

rapidlist1:
		db	14,3	;0
		db	15,3
		db	16,4
		db	17,5
		db	18,5
		db	19,6
		db	20,7
		db	21,7
		db	22,8
		db	23,9
		db	24,9
		db	25,10
		db	26,11
		db	27,11
		db	28,12
		db	29,13
		db	31,14	;16
		db	31,15
		db	31,16
		db	31,18
		db	31,19
		db	31,20
		db	31,22
		db	31,23
		db	31,25	;24
		db	32,26
		db	33,27
		db	35,28
		db	36,29
		db	37,30
		db	39,31
		db	40,32
		db	42,33
		db	43,34
		db	44,35
		db	46,36
		db	47,37
		db	48,38
		db	50,39
		db	51,40
		db	53,41	;40
		db	54,42
		db	56,43
		db	57,44
		db	59,45
		db	60,46
		db	62,47
		db	63,48
		db	65,49
		db	66,50
		db	68,51
		db	69,52
		db	71,53
		db	72,54
		db	74,55
		db	75,56
		db	77,58	;56
		db	78,59
		db	80,60
		db	81,61
		db	83,62
		db	84,63
		db	86,64
		db	87,65
		db	89,66
		db	91,67
		db	92,68
		db	94,69
		db	95,70
		db	97,71
		db	98,72
		db	100,73
		db	102,75	;72
		db	103,76
		db	104,77
		db	106,78
		db	107,79
		db	108,80
		db	110,81
		db	111,82
		db	113,83
		db	114,84
		db	115,85
		db	117,86
		db	118,87
		db	119,88
		db	121,89
		db	122,90
		db	124,92	;88
		db	125,92
		db	126,93
		db	127,94
		db	129,95
		db	130,96
		db	131,97
		db	133,98
		db	134,99
		db	135,100
		db	137,101
		db	138,102
		db	139,103
		db	141,104
		db	142,105
		db	143,106
		db	145,107	;104
		db	145,108
		db	145,109
		db	145,110
		db	145,112
		db	145,113
		db	145,114
		db	145,115
		db	146,117	;112
		db	147,118
		db	149,119
		db	150,120
		db	152,121
		db	153,122
		db	155,123
		db	156,124
		db	158,125
		db	159,126
		db	161,127
		db	162,128
		db	164,129
		db	165,130
		db	167,131
		db	168,132
rapidlist2:
		db	161,5	;0
		db	161,5
		db	160,6
		db	159,6
		db	158,7
		db	157,7
		db	156,8
		db	155,8
		db	154,9
		db	154,10
		db	153,10
		db	152,11
		db	151,11
		db	150,12
		db	149,12
		db	148,13
		db	147,14	;16
		db	147,15
		db	147,16
		db	147,17
		db	147,19
		db	147,20
		db	147,21
		db	147,22
		db	146,24	;24
		db	145,25
		db	143,26
		db	142,27
		db	140,28
		db	139,29
		db	137,30
		db	136,31
		db	134,32
		db	133,33
		db	131,34
		db	130,35
		db	128,36
		db	127,37
		db	125,38
		db	124,39
		db	122,41	;40
		db	121,42
		db	119,43
		db	118,44
		db	116,45
		db	115,46
		db	113,47
		db	112,48
		db	110,49
		db	109,50
		db	107,51
		db	106,52
		db	104,53
		db	103,54
		db	101,55
		db	100,56
		db	98,57	;56
		db	97,58
		db	95,59
		db	94,60
		db	92,61
		db	91,62
		db	89,64
		db	88,65
		db	86,66
		db	84,67
		db	83,68
		db	81,70
		db	80,71
		db	78,72
		db	77,73
		db	75,74
		db	73,76	;72
		db	72,77
		db	71,78
		db	69,79
		db	68,80
		db	66,81
		db	65,82
		db	63,83
		db	62,84
		db	61,85
		db	59,86
		db	58,87
		db	56,88
		db	55,89
		db	53,90
		db	52,91
		db	50,92	;88
		db	49,92
		db	48,93
		db	47,94
		db	45,95
		db	44,96
		db	43,97
		db	42,98
		db	40,99
		db	39,99
		db	38,100
		db	37,101
		db	35,102
		db	34,103
		db	33,104
		db	32,105
		db	30,106	;104
		db	30,107
		db	30,108
		db	30,110
		db	30,111
		db	30,112
		db	30,114
		db	30,115
		db	30,117	;112
		db	29,118
		db	27,119
		db	26,120
		db	24,121
		db	23,122
		db	21,123
		db	20,124
		db	18,125
		db	16,126
		db	15,127
		db	13,128
		db	12,129
		db	10,130
		db	9,131
		db	7,132


ripplepositions:
		db	26,15
		db	119,15
		db	48,31
		db	97,31
		db	73,48
		db	47,67
		db	97,66
		db	26,82
		db	119,82
