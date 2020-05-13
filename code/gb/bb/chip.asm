; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** CHIP.ASM                                                              **
; **                                                                       **
; ** Last modified : 990302 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"chip",CODE,BANK[19]
		section 19

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

chip_top::


SFX_CHIPRIGHT	EQU	27
SFX_CHIPWRONG	EQU	26


CHMODE:		MACRO
		ld	a,LOW(\1)
		ldh	[chip_vector+1],a
		ld	a,HIGH(\1)
		ldh	[chip_vector+2],a
		ENDM

CHCHAIN:	MACRO
		ld	a,LOW(\1)
		ldh	[chip_chain],a
		ld	a,HIGH(\1)
		ldh	[chip_chain+1],a
		ENDM

CHCHAINDE:	MACRO
		ld	a,e
		ldh	[chip_chain],a
		ld	a,d
		ldh	[chip_chain+1],a
		ENDM

NUM_CUPS	EQU	5
NUM_STEPS	EQU	32

FLG_NEGX	EQU	7
FLG_NEGY	EQU	6

MSK_NEGX	EQU	$80
MSK_NEGY	EQU	$40
MSK_TRANS	EQU	$0f

SONG_CHIP	EQU	6

;chip_flags
CHIPFLG_STAR	EQU	0
CHIPFLG_FIRST	EQU	1
CHIPFLG_NEW	EQU	2
CHIPFLG_DONE	EQU	3

CHIP_SHOW_RATE	EQU	$20
POINTER_ABOVE	EQU	$30

chip_count	EQUS	"hTemp48+0"
chip_frame	EQUS	"hTemp48+1"
chip_at		EQUS	"hTemp48+2"
chip_xypos	EQUS	"hTemp48+3"	;NUM_CUPS*2 bytes
chip_trans	EQUS	"hTemp48+13"	;NUM_CUPS bytes
chip_bonussave	EQUS	"hTemp48+18"
chip_rate	EQUS	"hTemp48+19"
chip_arrowx	EQUS	"hTemp48+20"
chip_arrowy	EQUS	"hTemp48+21"
chip_transcnt	EQUS	"hTemp48+22"
chip_pos	EQUS	"hTemp48+23"
chip_yfix	EQUS	"hTemp48+24"
chip_loc	EQUS	"hTemp48+25"
chip_choice	EQUS	"hTemp48+26"
chip_shuffles	EQUS	"hTemp48+27"	;NUM_CUPS bytes
chip_step	EQUS	"hTemp48+32"
chip_bonus	EQUS	"hTemp48+33"
chip_animcnt	EQUS	"hTemp48+34"
chip_hold	EQUS	"hTemp48+35"
chip_flags	EQUS	"hTemp48+36"
chip_vector	EQUS	"hTemp48+37"	;3 bytes
chip_chain	EQUS	"hTemp48+40"	;2 bytes
chip_time	EQUS	"hTemp48+42"
chip_stagelo	EQUS	"hTemp48+43"
chip_stagehi	EQUS	"hTemp48+44"
chip_stagepos	EQUS	"hTemp48+45"


delay:		db	16
rate:		db	12


;step for anim(1,2,4),#of transitions,frame rate in 8x 60ths of a second
chipblock1:	db	1,6,20
chipblock2:	db	1,8,16
chipblock3:	db	2,10,24
chipblock4:	db	2,12,16
chipblock5:	db	4,12,28
chipblock6:	db	4,12,26
chipblock7:	db	4,18,24
chipblock8:	db	4,20,22

chipstage1:	dw	chipblock1,chipblock2,chipblock1,0
chipstage2:	dw	chipblock3,chipblock3,chipblock2,0
chipstage3:	dw	chipblock4,chipblock5,chipblock3,0
chipstage4:	dw	chipblock4 ;Special mode easy
chipstage5:	dw	chipblock5 ;Special mode hard

chipstage8:	dw	chipblock8,chipblock8,chipblock8,0

chipmastertbl:	dw	chipstage1
		dw	chipstage2
		dw	chipstage3
		dw	chipstage4
		dw	chipstage5

chip::

		ld	a,[wSubLevel]
		add	a
		ld	hl,chipmastertbl
		call	addahl
		ld	a,[hli]
		ldh	[chip_stagelo],a
		ld	a,[hl]
		ldh	[chip_stagehi],a

.loc:		call	random
		and	7
		cp	5
		jr	nc,.loc
		ld	[chip_loc],a
		ld	b,a
.loc2:		call	random
		and	7
		cp	5
		jr	nc,.loc2
		cp	b
		jr	z,.loc2

		ld	a,$c3
		ldh	[chip_vector],a

		call	newchipstage

		CHMODE	chipshow

		call	chip_setup

chiploop::	call	startsong
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jr	nz,chippause
		ld	hl,chip_flags
		call	chip_vector
		ld	hl,chip_flags
		bit	CHIPFLG_DONE,[hl]
		jr	nz,chipdone
		bit	CHIPFLG_FIRST,[hl]
		jr	nz,.nofade
		set	CHIPFLG_FIRST,[hl]
		call 	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:	ld	a,[chip_time]
		call	AccurateWait
		jr	chiploop

chipdone:	jp	chip_shutdown

chippause:	call	chip_shutdown
		call	PauseMenu_B
		call	chip_setup
		jr	chiploop


newchipstage:	xor	a
		ld	[chip_yfix],a
		ld	a,-$20
		ldh	[chip_arrowx],a
		ldh	[chip_arrowy],a
		ld	a,255
		ldh	[chip_pos],a
		xor	a
		ld	hl,chip_shuffles
.fillsh:	ld	[hli],a
		inc	a
		cp	NUM_CUPS
		jr	nz,.fillsh
		ldh	a,[chip_stagelo]
		ld	l,a
		ldh	a,[chip_stagehi]
		ld	h,a
		ld	a,[wSubGaston]
		or	a
		ld	a,[wSubStage]
		jr	z,.nogaston
		cp	2
		jr	nz,.nogaston
		dec	a
.nogaston:	add	a
		call	addahl

		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		ret	z
;		ld	a,[wSubLevel]	;Special mode
;		cp	3		;
;		jr	nc,.noincpntr	;
;		ld	a,l
;		ldh	[chip_stagelo],a
;		ld	a,h
;		ldh	[chip_stagehi],a
;.noincpntr:
		ld	a,[wSubGaston]
		or	a
		ld	a,255
		jr	nz,.nobonus

		ld	a,[hli]
		or	[hl]
		ld	a,255
		jr	nz,.nobonus
		ldh	a,[chip_loc]
		ld	b,a
.pickbonus:	call	random
		and	7
		cp	5
		jr	nc,.pickbonus
		cp	b
		jr	z,.pickbonus
.nobonus:	ldh	[chip_bonus],a
		ld	h,d
		ld	l,e
		ld	a,[hli]
		ldh	[chip_step],a
		ld	a,[hli]
		ldh	[chip_transcnt],a
		ld	a,[hl]
		ldh	[chip_rate],a
		ld	a,1
		ret

chipstg1:	ld	de,chipshow
anychipstg:
		CHCHAINDE
		call	placecups
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	nc,.nostage	;
		ld	a,1
		ldh	[chip_stagepos],a
.nostage:
		CHMODE	chipstg
		ld	a,16
		ldh	[chip_time],a
chipstg:	call	InitFigures
		call	drawcups
		ld	hl,chip_stagepos
		ld	a,[wGroup7]
		call	StdStage
		call	OutFigures
		ldh	a,[chip_stagepos]
		or	a
		ret	nz
		jp	chipchain

chipshow:	ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		call	placecups
		ld	a,5
		ldh	[chip_hold],a
		CHMODE	chipshow2
chipshow2:	call	neutral
		ld	hl,chip_hold
		dec	[hl]
		ret	nz
chipshow2b:
		ld	de,chipshow3
		jp	anychipstg
;		CHMODE	chipshow3
;		ret
chipshow3:	ld	a,[chip_loc]
		ld	[chip_pos],a
		ld	de,chipshow4
		ld	a,15
		jp	tochipup
chipshow4:	ld	de,dotrans
		jp	tochipdown

keepgoing:	call	newchipstage
		or	a
		jr	nz,chipshow2b
		ldh	a,[chip_loc]
		ldh	[chip_pos],a

correct:	call	placecups
		xor	a
		ld	de,correct2
		jp	tochipup
correct2:	ld	a,15
		ld	de,correct3
		jp	chipyes
correct3:	xor	a
		ld	de,holdend
		jp	tochipdown
holdend:	ld	a,255
		ld	[chip_pos],a
		ld	a,5
		ldh	[chip_hold],a
		CHMODE	holdendlp
holdendlp:	call	neutral
		ld	hl,chip_hold
		dec	[hl]
		ret	nz
		ld	hl,chip_flags
		bit	CHIPFLG_STAR,[hl]
		jr	nz,.done
		ldh	a,[chip_bonussave]
		cp	255
		jr	z,.done
		set	CHIPFLG_STAR,[hl]
		CHMODE	choosing
		ret
.done:		set	CHIPFLG_DONE,[hl]
		ret

neutral:	call	InitFigures
		call	drawcups
		jp	OutFigures

wrong:		call	placecups
		xor	a
		ld	de,wrong2
		jp	tochipup
wrong2:		ld	a,15
		ld	de,wrong3
		jp	chipno
wrong3:		xor	a
		ld	de,holdend
		jp	tochipdown


dotrans:	call	random
		ld	b,a
		and	$7f
		cp	119
		jr	nc,dotrans
		inc	b
		ld	a,b
		call	selecttrans
		call	draweverything
		ld	a,[chip_step]
		dec	a
		ld	[chip_frame],a
		ld	a,[chip_rate]
		ld	[chip_time],a
		CHMODE	transition
		ret

transition:	call	placecups
		call	movecups
		call	draweverything
		ld	hl,chip_frame
		ld	a,[chip_step]
		add	[hl]
		ld	[hl],a
		cp	NUM_STEPS
		ret	c
		ld	hl,chip_transcnt
		dec	[hl]
		jr	nz,dotrans
		ld	a,2
		ldh	[chip_choice],a
		CHMODE	choosing
		call	placecups
		ret

choosing:	ld	hl,chip_choice
		ld	a,[wJoy1Hit]
		ld	b,a
		bit	JOY_L,b
		jr	z,.nolf
		ld	a,[hl]
		or	a
		jr	nz,.ok1
		ld	a,NUM_CUPS
.ok1:		dec	a
		ld	[hl],a
.nolf:		bit	JOY_R,b
		jr	z,.nort
		ld	a,[hl]
		cp	NUM_CUPS-1
		jr	nz,.ok2
		ld	a,-1
.ok2:		inc	a
		ld	[hl],a
.nort:		bit	JOY_A,b
		jp	nz,picked
		ld	a,[hl]
		call	fetchany
		ld	a,e
		sub	POINTER_ABOVE
		ld	[chip_arrowy],a
		ld	a,d
		ld	[chip_arrowx],a
		jp	draweverything

picked:		ld	c,[hl]
		ld	hl,chip_flags
		bit	CHIPFLG_STAR,[hl]
		jr	nz,pickstar
		ld	a,[chip_bonus]
		call	find
		ldh	[chip_bonussave],a
		ld	a,255
		ldh	[chip_bonus],a
		ld	a,[chip_loc]
		call	find
		ldh	[chip_loc],a
		cp	c
		jr	z,.good
		ldh	[chip_pos],a
		ld	a,255
		ld	[chip_bonussave],a
		ld	a,SFX_CHIPWRONG
		call	InitSfx
		jp	wrong
.good:		ld	a,SFX_CHIPRIGHT
		call	InitSfx
		call	IncScore
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	nc,.noincstage	;
		ld	hl,wSubStage
		inc	[hl]
.noincstage:	jp	keepgoing

pickstar:	ldh	a,[chip_bonussave]
		ldh	[chip_bonus],a
		cp	c
		jp	z,bonusright
		jp	bonuswrong

find:		cp	NUM_CUPS
		ret	nc
		ld	b,0
		ld	hl,chip_shuffles
.findlp:	cp	[hl]
		jr	z,.found
		inc	b
		inc	hl
		jr	.findlp
.found:		ld	a,b
		ret

bonusright:	xor	a
		ld	[chip_frame],a
		ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		CHMODE	bonusrightlp
		ld	a,SONG_GOTSTAR
		call	InitTune
		ld	hl,wSubStars
		inc	[hl]
bonusrightlp:	call	InitFigures
		call	drawcups
		ld	a,[chip_bonus]
		call	fetchany
		ld	a,[chip_frame]
;		add	a
		ld	b,a
		ld	a,e
		sub	b
		sub	POINTER_ABOVE
		ld	e,a
		ld	bc,IDX_DUST
		ld	hl,chip_animcnt
		inc	[hl]
		ld	a,[hl]
		and	7
		add	c
		ld	c,a
		ld	a,b
		adc	0
		ld	b,a
		ldh	a,[chip_frame]
		cp	15
		jr	c,.noflicker
		rr	a
		jr	c,.flicker
.noflicker:	ld	a,[wGroup5]
		call	AddFigure
.flicker:	call	OutFigures
		ld	hl,chip_frame
		inc	[hl]
		ld	a,[hl]
		cp	40
		ret	nz
		jp	holdend


bonuswrong:	xor	a
		ld	[chip_frame],a
		ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		CHMODE	bonuswronglp
bonuswronglp:	call	InitFigures
		call	drawcups
		call	trybonus
		call	OutFigures
		ld	hl,chip_frame
		inc	[hl]
		ld	a,[hl]
		cp	32
		ret	nz
		jp	holdend


placecups:	ld	hl,chip_xypos
		ld	de,$104c
		ld	c,NUM_CUPS
.pclp:		ld	a,d
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		ld	a,d
		add	32
		ld	d,a
		dec	c
		jr	nz,.pclp
		ret

TEMPMEM		EQU	$d000-NUM_CUPS


;a=trans 0-119
;$80 bit means invert y's
selecttrans:	ld	c,a
		res	7,c
		ld	b,0
		ld	hl,transitions
		add	hl,bc
		add	hl,bc
		add	hl,bc
		add	hl,bc
		add	hl,bc
		ld	de,TEMPMEM
		ld	c,0
.findlp:	push	hl
		ld	b,-1
.f2:		ld	a,[hli]
		inc	b
		cp	c
		jr	nz,.f2
		ld	a,b
		ld	[de],a
		inc	de
		pop	hl
		inc	c
		ld	a,c
		cp	5
		jr	nz,.findlp
		ld	hl,TEMPMEM
		ld	bc,0
.shuffle:	ld	a,[hli]
		push	hl
		ld	hl,chip_shuffles
		add	hl,bc
		ld	d,[hl]
		ld	hl,chip_trans
		call	addahl
		ld	[hl],d
		pop	hl
		inc	c
		ld	a,c
		cp	NUM_CUPS
		jr	nz,.shuffle
		ld	hl,chip_trans
		ld	de,chip_shuffles
		ld	bc,NUM_CUPS
		call	MemCopy
		ld	hl,TEMPMEM
		ld	de,chip_trans
		ld	bc,0
		bit	7,a
		jr	z,.noinvy
		ld	b,MSK_NEGY
.noinvy:
.stlp:		ld	a,[hli]
		sub	c
		jr	nc,.aok
		cpl
		inc	a
		or	MSK_NEGX|MSK_NEGY
.aok:		xor	b
		ld	[de],a
		inc	de
		inc	c
		ld	a,c
		cp	NUM_CUPS
		jr	nz,.stlp
		ret

;use chip_frame to move cups based on what transition they're doing
movecups::	xor	a
.mclp:		ldh	[hTmpLo],a
		ld	c,a
		ld	b,0
		ld	hl,chip_xypos
		add	hl,bc
		add	hl,bc
		push	hl
		ld	hl,chip_trans
		add	hl,bc
		ld	a,[hl]
		ldh	[hTmpHi],a
		and	MSK_TRANS
		add	a
		ld	hl,steps
		ld	c,a
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[chip_frame]
		ld	c,a
		add	hl,bc
		add	hl,bc
		ld	d,h
		ld	e,l
		pop	hl
		ldh	a,[hTmpHi]
		ld	c,a
		ld	a,[de]
		inc	de
		bit	FLG_NEGX,c
		jr	z,.nonegx
		cpl
		inc	a
.nonegx:	add	[hl]
		ld	[hli],a
		ld	a,[de]
		bit	FLG_NEGY,c
		jr	z,.nonegy
		cpl
		inc	a
.nonegy:	add	[hl]
		ld	[hl],a
		ldh	a,[hTmpLo]
		inc	a
		cp	NUM_CUPS
		jr	nz,.mclp
		ret

fetchpos:	ld	a,[chip_pos]
fetchany:	ld	hl,chip_xypos
		add	a
		call	addahl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		ret

trybonus:	ld	a,[chip_bonus]
		cp	NUM_CUPS
		ret	nc
		call	fetchany
		ld	a,[chip_yfix]
		add	e
		sub	POINTER_ABOVE
		ld	e,a
		ld	bc,IDX_STAR
		ld	hl,chip_animcnt
		inc	[hl]
		ld	a,[hl]
		and	7
		add	c
		ld	c,a
		ld	a,b
		adc	0
		ld	b,a
		ld	a,[wGroup5]
		jp	AddFigure

;a=# of frames to pause at end
;de=chain routine
tochipup:	ldh	[chip_hold],a
		xor	a
		ldh	[chip_frame],a
		ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		ld	a,b
		CHMODE	chipup
		CHCHAINDE
chipup:		call	InitFigures
		call	fetchpos
		ld	a,[chip_frame]
		inc	a
		ld	b,a
		add	a
		add	a
		ld	[chip_yfix],a
		cpl
		inc	a
		add	e
		ld	e,a
		ld	a,b
		call	chipanim
		call	drawcups
		call	trybonus
		call	OutFigures
		ld	hl,chip_frame
		inc	[hl]
		ld	a,[hl]
		cp	6
		ret	nz
		dec	[hl]
		ld	hl,chip_hold
		ld	a,[hl]
		dec	[hl]
		or	a
		ret	nz
chipchain:	ldh	a,[chip_chain]
		ldh	[chip_vector+1],a
		ldh	a,[chip_chain+1]
		ldh	[chip_vector+2],a
		ret

;de=chain routine
tochipdown:	xor	a
		ldh	[chip_frame],a
		ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		ld	a,b
		CHMODE	chipdown
		CHCHAINDE
chipdown:	call	InitFigures
		call	fetchpos
		ld	a,[chip_frame]
		ld	b,a
		ld	a,6
		sub	b
		ld	b,a
		add	a
		add	a
		ld	[chip_yfix],a
		cpl
		inc	a
		add	e
		ld	e,a
		ld	a,b
		call	chipanim
		call	drawcups
		call	trybonus
		call	OutFigures
		ld	hl,chip_frame
		inc	[hl]
		ld	a,[hl]
		cp	6
		ret	nz
		xor	a
		ld	[chip_yfix],a
		jp	chipchain

chipyes:	ld	bc,$0610
		jr	chipanimseq
chipno:		ld	bc,$0f1b
chipanimseq:	ld	[chip_hold],a
		ld	a,b
		ld	[chip_at],a
		ld	a,c
		ld	[chip_frame],a
		ld	a,CHIP_SHOW_RATE
		ldh	[chip_time],a
		CHCHAINDE
		CHMODE	chipyesno
chipyesno:	call	InitFigures
		call	drawcups
		call	fetchpos
		ld	a,e
		sub	4*6
		ld	e,a
		ld	a,[chip_at]
		call	chipanim
		call	trybonus
		call	OutFigures
		ld	hl,chip_at
		inc	[hl]
		ld	a,[chip_frame]
		cp	[hl]
		ret	nz
		dec	[hl]
		ld	hl,chip_hold
		ld	a,[hl]
		dec	[hl]
		or	a
		ret	nz
		jp	chipchain



;a=frame # of chip's special anims
;de=xy
chipanim:	ld	l,a
		ld	h,0
		ld	bc,IDX_BRWNCHIP
		push	hl
		push	de
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[wGroup4]
		call	AddFigure
		pop	de
		pop	hl
		ld	bc,IDX_YELLCHIP
		push	hl
		push	de
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[wGroup1]
		call	AddFigure
		pop	de
		pop	hl
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		ld	bc,IDX_RFLTCHIP
		push	de
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[wGroup2]
		call	AddFigure
		pop	de
		ret




draweverything:
		ld	a,[chip_pos]
		ld	b,a
		ld	a,[chip_bonus]
		ld	c,a
		push	bc
		ld	a,255
		ld	[chip_pos],a
		call	InitFigures
		call	drawcups
		call	drawarrow
		call	OutFigures
		pop	bc
		ld	a,b
		ld	[chip_pos],a
		ld	a,c
		ld	[chip_bonus],a
		ret
drawarrow:
		ld	a,[chip_arrowx]
		ld	d,a
		ld	a,[chip_arrowy]
		ld	e,a
		ld	bc,IDX_ARROW
		ld	a,[chip_flags]
		bit	CHIPFLG_STAR,a
		ld	a,[wGroup3]
		jr	z,.bcok
		ld	bc,IDX_STARCURS
		ld	a,[wGroup6]
.bcok:		jp	AddFigure


drawcups:
		ld	hl,chip_xypos
		xor	a
.drawcups:	ld	[chip_count],a
		ld	b,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[chip_pos]
		cp	b
		jr	z,.skip1
		ld	a,[chip_yfix]
		add	e
		ld	e,a
		ld	bc,IDX_CHIP
		ld	a,[wGroup1]
		push	hl
		call	AddFigure
		pop	hl
.skip1:		ld	a,[chip_count]
		inc	a
		cp	NUM_CUPS
		jr	nz,.drawcups
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		ld	hl,chip_xypos
		xor	a
.drawreflects:	ld	[chip_count],a
		ld	b,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[chip_pos]
		cp	b
		jr	z,.skip2
		ld	a,[chip_yfix]
		add	e
		ld	e,a
		ld	bc,IDX_REFLECT
		ld	a,[wGroup2]
		push	hl
		call	AddFigure
		pop	hl
.skip2:		ld	a,[chip_count]
		inc	a
		cp	NUM_CUPS
		jr	nz,.drawreflects
		ret
startsong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_CHIP
		jp	InitTunePref


chip_setup:

		ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,IDX_CHIPBGBG	;chipbgbg
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok
		ld	hl,IDX_CHIPBWBG	;chipbwbg
.hlok:		call	BgInFileSys
		call	InitGroups
		ld	hl,PAL_CHIP
		call	AddPalette
		or	$10
		ld	[wGroup1],a	;chip's palette
		ld	hl,PAL_REFLECT
		call	AddPalette
		ld	[wGroup2],a	;reflect's palette
		ld	hl,PAL_ARROW
		call	AddPalette
		ld	[wGroup3],a	;Arrow's palette
		ld	hl,PAL_BRWNCHIP
		call	AddPalette
		or	$10
		ld	[wGroup4],a	;part 1 of chip
		ld	hl,PAL_STAR
		call	AddPalette
		or	$10
		ld	[wGroup5],a	;star and dust palette (8 frames each)
		ld	hl,PAL_STARCURS
		call	AddPalette
		ld	[wGroup6],a	;star cursor (1 frame)
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup7],a
		ld	hl,chip_flags
		res	CHIPFLG_FIRST,[hl]
		ret
chip_shutdown:	call	FadeOut
		xor	a
		call	InitTune
		jp	SprOff



steps:	dw	step0,step1,step2,step3,step4

step0:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
step1:	db	0,0,0,0,0,0,0,1,0,1,0,1,1,2,1,2,2,3,3,4,4,4,6,5,8,6,10,6,13,6,16,6,19,6,22,6,24,6,26,5,28,4,29,4,30,3,31,2,31,2,32,1,32,1,32,1,32,0,32,0,32,0,32,0
step2:	db	0,0,0,0,0,1,0,1,0,2,1,3,1,4,2,5,4,6,6,7,8,9,12,10,16,11,20,12,26,13,32,13,38,13,44,12,48,11,52,10,56,9,58,7,60,6,62,5,63,4,63,3,64,2,64,1,64,1,64,0,64,0,64,0
step3:	db	0,0,0,0,0,1,0,2,1,3,1,4,2,6,4,7,6,9,9,11,13,13,18,15,24,17,31,18,39,19,48,19,57,19,65,18,72,17,78,15,83,13,87,11,90,9,92,7,94,6,95,4,95,3,96,2,96,1,96,0,96,0,96,0
step4:	db	0,0,0,1,0,1,0,3,1,4,2,6,3,8,5,10,8,12,12,15,17,17,23,20,31,22,41,24,52,25,64,26,76,25,87,24,97,22,105,20,111,17,116,15,120,12,123,10,125,8,126,6,127,4,128,3,128,1,128,1,128,0,128,0
transitions:
	db	0,1,2,3,4	;0
	db	0,1,2,4,3	;1
	db	0,1,3,2,4	;2
	db	0,1,3,4,2	;3
	db	0,1,4,2,3	;4
	db	0,1,4,3,2	;5
	db	0,2,1,3,4	;6
	db	0,2,1,4,3	;7
	db	0,2,3,1,4	;8
	db	0,2,3,4,1	;9
	db	0,2,4,1,3	;10
	db	0,2,4,3,1	;11
	db	0,3,1,2,4	;12
	db	0,3,1,4,2	;13
	db	0,3,2,1,4	;14
	db	0,3,2,4,1	;15
	db	0,3,4,1,2	;16
	db	0,3,4,2,1	;17
	db	0,4,1,2,3	;18
	db	0,4,1,3,2	;19
	db	0,4,2,1,3	;20
	db	0,4,2,3,1	;21
	db	0,4,3,1,2	;22
	db	0,4,3,2,1	;23
	db	1,0,2,3,4	;24
	db	1,0,2,4,3	;25
	db	1,0,3,2,4	;26
	db	1,0,3,4,2	;27
	db	1,0,4,2,3	;28
	db	1,0,4,3,2	;29
	db	1,2,0,3,4	;30
	db	1,2,0,4,3	;31
	db	1,2,3,0,4	;32
	db	1,2,3,4,0	;33
	db	1,2,4,0,3	;34
	db	1,2,4,3,0	;35
	db	1,3,0,2,4	;36
	db	1,3,0,4,2	;37
	db	1,3,2,0,4	;38
	db	1,3,2,4,0	;39
	db	1,3,4,0,2	;40
	db	1,3,4,2,0	;41
	db	1,4,0,2,3	;42
	db	1,4,0,3,2	;43
	db	1,4,2,0,3	;44
	db	1,4,2,3,0	;45
	db	1,4,3,0,2	;46
	db	1,4,3,2,0	;47
	db	2,0,1,3,4	;48
	db	2,0,1,4,3	;49
	db	2,0,3,1,4	;50
	db	2,0,3,4,1	;51
	db	2,0,4,1,3	;52
	db	2,0,4,3,1	;53
	db	2,1,0,3,4	;54
	db	2,1,0,4,3	;55
	db	2,1,3,0,4	;56
	db	2,1,3,4,0	;57
	db	2,1,4,0,3	;58
	db	2,1,4,3,0	;59
	db	2,3,0,1,4	;60
	db	2,3,0,4,1	;61
	db	2,3,1,0,4	;62
	db	2,3,1,4,0	;63
	db	2,3,4,0,1	;64
	db	2,3,4,1,0	;65
	db	2,4,0,1,3	;66
	db	2,4,0,3,1	;67
	db	2,4,1,0,3	;68
	db	2,4,1,3,0	;69
	db	2,4,3,0,1	;70
	db	2,4,3,1,0	;71
	db	3,0,1,2,4	;72
	db	3,0,1,4,2	;73
	db	3,0,2,1,4	;74
	db	3,0,2,4,1	;75
	db	3,0,4,1,2	;76
	db	3,0,4,2,1	;77
	db	3,1,0,2,4	;78
	db	3,1,0,4,2	;79
	db	3,1,2,0,4	;80
	db	3,1,2,4,0	;81
	db	3,1,4,0,2	;82
	db	3,1,4,2,0	;83
	db	3,2,0,1,4	;84
	db	3,2,0,4,1	;85
	db	3,2,1,0,4	;86
	db	3,2,1,4,0	;87
	db	3,2,4,0,1	;88
	db	3,2,4,1,0	;89
	db	3,4,0,1,2	;90
	db	3,4,0,2,1	;91
	db	3,4,1,0,2	;92
	db	3,4,1,2,0	;93
	db	3,4,2,0,1	;94
	db	3,4,2,1,0	;95
	db	4,0,1,2,3	;96
	db	4,0,1,3,2	;97
	db	4,0,2,1,3	;98
	db	4,0,2,3,1	;99
	db	4,0,3,1,2	;100
	db	4,0,3,2,1	;101
	db	4,1,0,2,3	;102
	db	4,1,0,3,2	;103
	db	4,1,2,0,3	;104
	db	4,1,2,3,0	;105
	db	4,1,3,0,2	;106
	db	4,1,3,2,0	;107
	db	4,2,0,1,3	;108
	db	4,2,0,3,1	;109
	db	4,2,1,0,3	;110
	db	4,2,1,3,0	;111
	db	4,2,3,0,1	;112
	db	4,2,3,1,0	;113
	db	4,3,0,1,2	;114
	db	4,3,0,2,1	;115
	db	4,3,1,0,2	;116
	db	4,3,1,2,0	;117
	db	4,3,2,0,1	;118
	db	4,3,2,1,0	;119

chip_end::
