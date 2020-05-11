; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SCUTTLE.ASM                                                           **
; **                                                                       **
; ** Created : 20000222 by David Ashley                                    **
; **  File included in pin.asm                                             **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	11


MAXTREASURES	EQU	3
TREASURESIZE	EQU	6
SCUTTLEJERKTIME	EQU	10
MAXFURY		EQU	4
FURYRED		EQU	128
SCUTTLEFURYDEC	EQU	180


GROUP_BROWN	EQU	2
GROUP_PINK	EQU	3
GROUP_RED	EQU	4
GROUP_SINK	EQU	5

scuttle_x	EQUS	"wTemp1024+00"
scuttle_cycle	EQUS	"wTemp1024+01"
scuttle_cycle2	EQUS	"wTemp1024+02"
scuttle_flap	EQUS	"wTemp1024+03"
scuttle_move	EQUS	"wTemp1024+04"
scuttle_must	EQUS	"wTemp1024+05"
scuttle_jerk	EQUS	"wTemp1024+06"
scuttle_fury	EQUS	"wTemp1024+07"
scuttle_goal	EQUS	"wTemp1024+08"

scuttle_treas	EQUS	"wTemp1024+16"	;TREASURESIZE*MAXTREASURES


scuttlerates:	db	12
		db	5

scuttleflaprates:
		db	6
		db	3

scuttleinfo:	db	BANK(scuttlehit)	;wPinJmpHit
		dw	scuttlehit
		db	BANK(scuttleprocess)	;wPinJmpProcess
		dw	scuttleprocess
		db	BANK(scuttlesprites)	;wPinJmpSprites
		dw	scuttlesprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(culltreasures)	;wPinJmpPerBall
		dw	culltreasures
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

scuttlemaplist:	db	21
		dw	IDX_SEABACKRGB
		dw	IDX_SEABACKMAP

ScuttleInit::
		ld	a,3
		ld	[scuttle_goal],a
		xor	a
		ld	[scuttle_fury],a
		ld	hl,scuttleinfo
		call	SetPinInfo

		ld	a,TIME_SCUTTLE
		call	SetTime

		ld	a,NEED_SCUTTLE
		call	SetCount2

		ld	hl,PAL_DARKFLIP
		call	AddPalette
		ld	hl,PAL_BRWNTRES
		call	AddPalette
		ld	hl,PAL_PINKTRES
		call	AddPalette
		ld	hl,PAL_REDTRES
		call	AddPalette
		ld	hl,PAL_OBSINK
		call	AddPalette

		ld	a,6
		ldh	[pin_textpal],a

		ld	a,3
		ld	[scuttle_x],a
		xor	a
		ld	[scuttle_cycle2],a

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap

		ld	hl,scuttlemaplist
		call	NewLoadMap
		ld	hl,IDX_SCUTTLEMAP
		call	SecondHalf

 call	SubAddBall

		ld	hl,scuttlecollisions
		jp	MakeCollisions


scuttleprocess:
		call	SubEnd
		call	AnyDecTime

		xor	a
		ld	[scuttle_must],a

		ld	a,[scuttle_jerk]
		or	a
		jr	z,.nojerk
		dec	a
		ld	[scuttle_jerk],a
		jr	z,.showjerk
		cp	SCUTTLEJERKTIME-1
		jr	nz,.nojerk
.showjerk:	ld	a,1
		ld	[scuttle_must],a
.nojerk:

		ld	d,0
		ld	a,[scuttle_fury]
		cp	FURYRED
		ld	e,0
		jr	c,.eok
		inc	e
.eok:		ld	a,[scuttle_flap]
		inc	a
		ld	hl,scuttleflaprates
		add	hl,de
		cp	[hl]
		jr	c,.aok1
		ld	a,1
		ld	[scuttle_must],a
		ld	a,[scuttle_cycle]
		inc	a
		cp	6
		jr	c,.aok2
		xor	a
.aok2:		ld	[scuttle_cycle],a
		xor	a
.aok1:		ld	[scuttle_flap],a

		ld	hl,scuttlerates
		add	hl,de
		ld	a,[scuttle_move]
		inc	a
		cp	[hl]
		jr	c,.aok3
		ld	a,1
		ld	[scuttle_must],a

		ld	a,[scuttle_x]
	sub	3
		add	255&IDX_SCDET000CHG
		ld	l,a
		ld	a,0
		adc	IDX_SCDET000CHG>>8
		ld	h,a
		call	UndoChanges

		ld	a,[scuttle_cycle2]
		inc	a
		cp	22
		jr	c,.aok4
		xor	a
.aok4:		ld	[scuttle_cycle2],a
		add	a
		ld	c,a
		ld	b,0
		ld	hl,scuttlemove
		add	hl,bc
		ld	a,[hli]
		ld	[scuttle_x],a
		ld	h,[hl]
		ld	l,1
		ld	de,$0500
		ld	bc,$0105
		call	BGRect

		ld	a,[scuttle_x]
	sub	3
		add	255&IDX_SCDET000CHG
		ld	l,a
		ld	a,0
		adc	IDX_SCDET000CHG>>8
		ld	h,a
		call	MakeChanges

		xor	a
.aok3:		ld	[scuttle_move],a

		ld	a,[scuttle_must]
		or	a
		ret	z

		ld	a,[scuttle_jerk]
		or	a
		ld	a,6
		jr	nz,.jerk
		ld	a,[scuttle_cycle]
.jerk:		ld	l,a
		ld	a,[scuttle_fury]
		cp	FURYRED
		ld	a,l
		jr	c,.nored
		add	7
.nored:		add	a
		ld	c,a
		ld	b,0
		ld	hl,scuttlepositions
		add	hl,bc
		ld	d,[hl]
		inc	hl
		ld	e,[hl]

		ld	a,[scuttle_x]
		ld	h,a
		ld	l,1

		ld	bc,$0505
		jp	BGRect

scuttlemove:	db	3,8
		db	4,3
		db	5,4
		db	6,5
		db	7,6
		db	8,7
		db	9,8
		db	10,9
		db	11,10
		db	12,11
		db	13,12
		db	14,13
		db	13,18
		db	12,17
		db	11,16
		db	10,15
		db	9,14
		db	8,13
		db	7,12
		db	6,11
		db	5,10
		db	4,9



scuttlepositions:
		db	0,0
		db	6,0
		db	12,0
		db	18,0
		db	0,5
		db	6,5
		db	12,5

		db	0,10
		db	6,10
		db	12,10
		db	18,10
		db	0,15
		db	6,15
		db	12,15


SHYMIN		EQU	8<<5
SHYMAX		EQU	44<<5
SHXMIN		EQU	29<<5
SHXSIZE		EQU	29<<5

scuttlehit:
		ldh	a,[pin_y]
		ld	c,a
		sub	255&SHYMIN
		ldh	a,[pin_y+1]
		ld	b,a
		sbc	SHYMIN>>8
		ret	c
		ld	a,c
		sub	255&SHYMAX
		ld	a,b
		sbc	SHYMAX>>8
		ret	nc
		ld	hl,SHXMIN
		ld	a,[scuttle_x]
	sub	3
		add	h
		ld	h,a

		ldh	a,[pin_x]
		sub	l
		ld	e,a
		ldh	a,[pin_x+1]
		sbc	h
		ld	d,a
		ret	c
		ld	a,e
		sub	255&SHXSIZE
		ld	a,d
		sbc	SHXSIZE>>8
		ret	nc

		call	Credit2
		ld	a,FX_SCUTTLEHIT
		call	InitSfx
		ld	a,SCUTTLEJERKTIME
		ld	[scuttle_jerk],a
		ld	hl,scuttle_fury
		ld	a,[hl]
		cp	FURYRED
		jr	c,.more
		ld	[hl],0
		ld	hl,scuttle_goal
		inc	[hl]
		jp	scuttleball
.more:		inc	[hl]
		ld	a,[scuttle_goal]
		cp	[hl]
		jr	nz,.nomax
		ld	[hl],FURYRED
.nomax		call	newtreasure
		ret

scuttlesprites:
		call	SubFlippers
		call	scuttletreasures
		ret


scuttleball:	ld	hl,wBalls+BALL_FLAGS
		ld	de,BALLSIZE
		ld	bc,MAXBALLS
.countballs:	bit	BALLFLG_USED,[hl]
		jr	z,.noincb
		inc	b
.noincb:	add	hl,de
		dec	c
		jr	nz,.countballs
		ld	a,b
		cp	2
		ret	nc
		ld	a,FX_SECONDBALL
		call	InitSfx
		ld	a,[scuttle_x]
		inc	a
		ld	d,a
		ld	e,0
		ld	bc,40<<5
		xor	a
		ld	[scuttle_fury],a
		ld	hl,0
		jp	AddBall



SCUTTLEY	EQU	64


scuttletreasures:
		ld	hl,scuttle_treas
		ld	e,MAXTREASURES
		ld	a,[wTime]
		srl	a
		srl	a
		srl	a
		and	3
		ld	d,a
.stlp:		ld	a,[hli]
		ld	c,a
		or	[hl]
		jr	z,.next2
		ld	a,[hli]
		ld	b,a
		ld	a,c
		add	d
		ld	c,a
		jr	nc,.noincb
		inc	b
.noincb:	push	de
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		cp	152
		ld	a,0
		jr	c,.aok
		ld	a,GROUP_SINK
.aok:		push	af
		ld	a,[hl]
		cp	e
		jr	nc,.noinc
		inc	a
		ld	[hl],a
.noinc:		ld	e,a
		cp	150
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
		pop	af
		or	a
		jr	nz,.sinking
		ld	a,[hli]
		jr	.notsinking
.sinking:	inc	hl
.notsinking:	push	hl
		call	AddFigure
		pop	hl
		pop	de
		jr	.next
.next2:		ld	bc,TREASURESIZE-1
		add	hl,bc
.next:		dec	e
		jr	nz,.stlp
		ret

;treasure structure:
;2 bytes ID (or 0000 if not used)
;1 byte x
;1 byte y desired value
;1 byte y
;1 byte group

TREASUREHIT	EQU	8

culltreasures:
		ld	a,[wMapXPos]
		and	$e0
		ld	l,a
		ld	a,[wMapXPos+1]
		ld	h,a
		ldh	a,[pin_x]
		sub	l
		ld	l,a
		ldh	a,[pin_x+1]
		sbc	h
		inc	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	TREASUREHIT
		ld	d,a
		ld	a,[wMapYPos]
		and	$e0
		ld	l,a
		ld	a,[wMapYPos+1]
		ld	h,a
		ldh	a,[pin_y]
		sub	l
		ld	l,a
		ldh	a,[pin_y+1]
		sbc	h
		inc	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	TREASUREHIT
		ld	e,a

		ld	hl,scuttle_treas
		ld	bc,TREASURESIZE
		ld	a,MAXTREASURES
.ctlp:		ldh	[hTmpLo],a
		ld	a,[hli]
		or	[hl]
		dec	hl
		jr	z,.next2
		inc	hl
		inc	hl
		ld	a,[hli]
		inc	hl
		sub	d
		jr	c,.nope
		cp	TREASUREHIT*2
		jr	nc,.nope
		ld	a,[hl]
		sub	e
		jr	c,.nope
		cp	TREASUREHIT*2
		jr	nc,.nope
		ld	a,[hl]
		dec	hl
		cp	[hl]
		inc	hl
		jr	nz,.nope
		dec	hl
		ld	a,152
		ld	[hli],a
		push	hl
		call	gotscuttletreasure
		pop	hl
.nope:		inc	hl
		inc	hl
		jr	.next

.next2:		add	hl,bc
.next:		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.ctlp
		ret


newtreasure:
		ld	hl,scuttle_treas
		ld	de,TREASURESIZE-1
		ld	c,MAXTREASURES
.ntfind:	ld	a,[hli]
		or	[hl]
		jr	z,.got
		add	hl,de
		dec	c
		jr	nz,.ntfind
		ret
.got:		call	random
		and	15
		cp	10
		jr	nc,.got
		ld	e,a
		add	a
		add	e
		add	LOW(treasures)
		ld	e,a
		ld	a,0
		adc	HIGH(treasures)
		ld	d,a
		dec	hl
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
.bad:		call	random
		and	$30
		jr	z,.bad
		sub	$10
		ld	b,a
		ld	a,[scuttle_x]
		and	$fe
		add	a
		add	a
		add	a
		add	b
		ld	[hli],a
.y:		call	random
		and	$30
		jr	z,.y
		add	SCUTTLEY-16
		ld	[hli],a
		ld	a,32
		ld	[hli],a

		ld	a,[de]
		ld	[hl],a
		ret


gotscuttletreasure:
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	z
		call	Credit1
		ld	a,FX_SCUTTLEGET
		call	InitSfx
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		ret	nz
		ld	a,HOLDTIME
		ld	[any_done],a
		ret


treasures:	dw	IDX_BRWNTRES
		db	GROUP_BROWN
		dw	IDX_BRWNTRES+4
		db	GROUP_BROWN
		dw	IDX_BRWNTRES+8
		db	GROUP_BROWN
		dw	IDX_PINKTRES
		db	GROUP_PINK
		dw	IDX_PINKTRES+4
		db	GROUP_PINK
		dw	IDX_PINKTRES+8
		db	GROUP_PINK
		dw	IDX_REDTRES
		db	GROUP_RED
		dw	IDX_REDTRES+4
		db	GROUP_RED
		dw	IDX_REDTRES+8
		db	GROUP_RED
		dw	IDX_REDTRES+12
		db	GROUP_RED


scuttlecollisions:
		dw	0

;***********************************************************************
;***********************************************************************

