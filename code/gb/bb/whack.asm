; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** WHACK.ASM                                                             **
; **                                                                       **
; ** Last modified : 990326 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"whack",CODE,BANK[1]
		section 1

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

whack_top::


SFX_WHACKDUCK	EQU	64
SFX_WHACKJUMP	EQU	4
SFX_WHACKPUNCH	EQU	23
SFX_WHACKHIT	EQU	15
SFX_WHACKWOLF	EQU	59
SONG_WHACK	EQU	13


WHACK_BONUSTIME	EQU	16
WHACK_DUSTTIME	EQU	20
WHACK_DUSTHOLD	EQU	5
WHACK_FLASHTIME	EQU	14

MAPSIZE		EQU	32*18

ENDHOLD		EQU	70

MAPORIG		EQU	$e000-4*MAPSIZE
ATTRORIG	EQU	$e000-3*MAPSIZE
MAPCOPY		EQU	$e000-2*MAPSIZE
ATTRCOPY	EQU	$e000-1*MAPSIZE

MAXBEASTCHR	EQU	$61

WHACKFLG_FIRST	EQU	0
WHACKFLG_HIT	EQU	1
WHACKFLG_OVER	EQU	2
WHACKFLG_STINC	EQU	3
WHACKFLG_DUST	EQU	4

BASE		EQU	0
JUMPING		EQU	1
PUNCHINGLEFT	EQU	2
PUNCHINGRIGHT	EQU	3
RISING		EQU	4
DUCKING		EQU	5
VICTORY		EQU	6

CRITICAL	EQU	3	;which anim frame # to hit/miss

REGAIN		EQU	255


whack_phase	EQUS	"hTemp48+00"
whack_counter	EQUS	"hTemp48+01"
whack_flags	EQUS	"hTemp48+02"
whack_bstvect	EQUS	"hTemp48+03" ;3 bytes
whack_bstcntr	EQUS	"hTemp48+06"
whack_bstpick	EQUS	"hTemp48+07"
whack_frame	EQUS	"hTemp48+08"
whack_take	EQUS	"hTemp48+09" ;2 bytes
whack_tono	EQUS	"hTemp48+11" ;2 bytes
whack_want	EQUS	"hTemp48+13"
whack_decide	EQUS	"hTemp48+14"
whack_wolfpick	EQUS	"hTemp48+15"
whack_wolftime	EQUS	"hTemp48+16"
whack_wolfstep	EQUS	"hTemp48+17"
whack_state	EQUS	"hTemp48+18"
whack_statewant	EQUS	"hTemp48+19"
whack_arrowpos	EQUS	"hTemp48+20"
whack_arrowfrm	EQUS	"hTemp48+21"
whack_arrowtime	EQUS	"hTemp48+22"
whack_health	EQUS	"hTemp48+23"
whack_losttime	EQUS	"hTemp48+24"
whack_takelo	EQUS	"hTemp48+25"
whack_takehi	EQUS	"hTemp48+26"
whack_wolfcnt	EQUS	"hTemp48+27"
whack_between	EQUS	"hTemp48+28"
whack_stagepos	EQUS	"hTemp48+29"
whack_bonuscnt	EQUS	"hTemp48+30"
whack_bonusloc	EQUS	"hTemp48+31"
whack_bonuspick	EQUS	"hTemp48+32"
whack_pause	EQUS	"hTemp48+33"

CHMODE:		MACRO
		ld	a,LOW(\1)
		ldh	[whack_bstvect+1],a
		ld	a,HIGH(\1)
		ldh	[whack_bstvect+2],a
		ENDM


;up,right,down,left
whackbonuslocs:	db	80,48,128,96,80,132,32,96


;blocks:
;1st byte is # of wolf attacks
;2nd byte is time between wolves
;3rd byte is time to hold warning arrow
whackblock1:	db	6,4,9
whackblock2:	db	8,2,5
whackblock3:	db	10,1,4
whackblock4:	db	255,2,4
whackblock5:	db	255,1,3

whacklevel1:	dw	whackblock1,whackblock1,whackblock1,0
whacklevel2:	dw	whackblock2,whackblock2,whackblock2,0
whacklevel3:	dw	whackblock2,whackblock3,whackblock3,0
whacklevel4:	dw	whackblock4,whackblock4,whackblock4,0
whacklevel5:	dw	whackblock5,whackblock5,whackblock5,0

whacklevels	dw	whacklevel1
		dw	whacklevel2
		dw	whacklevel3
		dw	whacklevel4
		dw	whacklevel5

newwhackstage:
		ldh	a,[whack_takelo]
		ld	l,a
		ldh	a,[whack_takehi]
		ld	h,a
		ld	a,[wSubStage]
		add	a
		call	addahl
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		ret	z
		ld	h,d
		ld	l,e
		ld	a,[hli]
		inc	a
		ldh	[whack_wolfcnt],a
		ld	a,[hli]
		ldh	[whack_between],a
		ld	a,[hli]
		ld	[whack_arrowtime],a
		xor	a
		ldh	[whack_frame],a
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	nc,.nostage	;
		ld	a,1
		ldh	[whack_stagepos],a
.nostage:	ret

Whack::
		ld	a,$c3
		ldh	[whack_bstvect],a
		CHMODE	beastbase

		ld	a,16
		ldh	[whack_wolfstep],a

		ld	a,[wSubLevel]
		add	a
		ld	hl,whacklevels
		call	addahl
		ld	a,[hli]
		ldh	[whack_takelo],a
		ld	h,[hl]
		ld	l,a
		ld	a,h
		ldh	[whack_takehi],a
		ld	b,0
.countwolves:	ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		jr	z,.counted
		ld	a,[de]
		add	b
		ld	b,a
		jr	.countwolves
.counted:	call	random
		and	63
		cp	b
		jr	nc,.counted
		inc	a
		ldh	[whack_bonuspick],a

		call	newwhackstage

		ld	a,[wSubGaston]
		or	a
		jr	nz,.nolives
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		ld	a,2		;
		jr	c,.aok		;
.nolives:	ld	a,20
		ldh	[whack_pause],a	;safety pause for challenge/gaston
		xor	a
.aok:
		ldh	[whack_health],a

		call	whack_setup

whackloop::
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,whackpause

		ldh	a,[whack_flags]
		bit	WHACKFLG_OVER,a
		call	z,whackstartsong
		ldh	a,[whack_decide]
		or	a
		jr	nz,.noattack
		ldh	a,[whack_pause]
		or	a
		jr	z,.nopause
		dec	a
		ldh	[whack_pause],a
		jr	.noattack
.nopause:	ldh	a,[whack_stagepos]
		or	a
		jr	nz,.noattack
		ldh	a,[whack_flags]
		bit	WHACKFLG_OVER,a
		jr	nz,.noattack
		ldh	a,[whack_bonuscnt]
		or	a
		jr	nz,.noattack
		ldh	a,[whack_frame]
		or	a
		jr	nz,.nobonus
;		call	random
;		and	3
;		jr	nz,.nobonus
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	nc,.nobonus	;
		ld	a,[wSubGaston]
		or	a
		jr	nz,.nobonus
		ld	hl,whack_bonuspick
		dec	[hl]
		jr	nz,.nobonus
		call	newwhackbonus
		jr	.noattack
.nobonus:


		ld	hl,whack_frame
		inc	[hl]
		ldh	a,[whack_between]
		cp	[hl]
		jr	nz,.noattack
		ld	[hl],0
;		call	IncScore
		ld	hl,whack_wolfcnt
		dec	[hl]
		jr	nz,.pick
		ld	hl,wSubStage
		inc	[hl]
		call	newwhackstage
		jr	nz,.noattack
;victory
		ld	hl,whack_flags
		set	WHACKFLG_OVER,[hl]
		ld	a,SONG_WON
		call	InitTune
		call	tobeastvictory
		jr	.noattack
.pick:		call	random
		and	7
		cp	6
		jr	nc,.pick
		call	whackattack
.noattack:
		call	InitFigures64
		call	whack_bstvect
		call	dowhackarrow
		call	dowhackbonus
		call	whackstage

		ldh	a,[whack_wolfstep]
		ld	b,a
		ldh	a,[whack_wolftime]
		add	b
		ldh	[whack_wolftime],a
		cp	32
		jr	c,.noprocess
		sub	32
		ldh	[whack_wolftime],a
		call	processattack
.noprocess:
		ldh	a,[whack_wolfpick]
		or	a
		jr	z,.nowolf
		call	wolfframe
		ld	b,a
		ldh	a,[whack_flags]
		bit	WHACKFLG_HIT,a
		jr	z,.nowolf
		ld	a,b
		ldh	[whack_bstpick],a
.nowolf:	call	OutFiguresPassive
		ldh	a,[whack_bstpick]
		dec	a
		call	testbeast

		ldh	a,[whack_phase]
		srl	a
		ld	a,%10000111
		jr	nc,.aok
		ld	a,%10001111
.aok:		ldh	[hVblLCDC],a
		LD	A,HIGH(wOamShadow)	;Signal VBL to update OAM RAM and
		ldh	[hOamFlag],a	;signal to dl OAM
		ld	hl,whack_flags
		bit	WHACKFLG_FIRST,[hl]
		jr	nz,.nofade
		set	WHACKFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:	ldh	a,[whack_phase]
		inc	a
		ldh	[whack_phase],a
;		ldh	a,[hMachine]
;		cp	MACHINE_CGB
		ld	a,24
;		jr	z,.aok2
;		ld	a,32
;.aok2:
		call	AccurateWait

		ld	hl,whack_flags
		bit	WHACKFLG_OVER,[hl]
		jp	z,whackloop
		ld	hl,whack_losttime
		inc	[hl]
		ld	a,[hl]
		cp	ENDHOLD
		jp	c,whackloop

whackdone:	call	whack_shutdown
		ret

whackpause:	call	whack_shutdown
		call	PauseMenu_B
		call	whack_setup
		jp	whackloop


arrowpostab:	db	7,119
		db	152,119
		db	7,100
		db	152,100
		db	7,70
		db	152,70


whackstage:	ld	hl,whack_stagepos
		ld	a,[wGroup3]
		jp	StdStage

newwhackbonus:	ld	a,1
		ldh	[whack_bonuscnt],a
		call	random
		and	3
		ldh	[whack_bonusloc],a
		ld	hl,whack_flags
		res	WHACKFLG_DUST,[hl]
		ret

dowhackbonus:	ld	hl,whack_bonuscnt
		ld	a,[hl]
		or	a
		ret	z
		inc	[hl]
		ld	c,[hl]
		ldh	a,[whack_bonusloc]
		add	a
		ld	hl,whackbonuslocs
		call	addahl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		ld	l,c
		ldh	a,[whack_flags]
		bit	WHACKFLG_DUST,a
		jr	nz,whackdust
		ld	a,c
		cp	WHACK_BONUSTIME+1
		jr	nc,bonusover
		and	7
		add	255&IDX_STAR
		ld	c,a
		ld	a,0
		adc	IDX_STAR>>8
		ld	b,a
		ld	a,[wGroup4]
		jp	AddFigure
whackdust:	ld	a,c
		cp	WHACK_DUSTTIME+1
		jr	nc,bonusover
		and	7
		add	255&IDX_DUST
		ld	c,a
		ld	a,0
		adc	IDX_DUST>>8
		ld	b,a
		ld	a,l
		cp	WHACK_FLASHTIME
		jr	c,.noflash
		bit	0,a
		ret	nz
.noflash:
		sub	WHACK_DUSTHOLD
		jr	nc,.aok
		xor	a
.aok:		add	a
		ld	h,a
		ld	a,e
		sub	h
		ld	e,a
		ld	a,[wGroup4]
		jp	AddFigure

bonusover:	xor	a
		ldh	[whack_bonuscnt],a
		ret


dowhackarrow:	ldh	a,[whack_arrowpos]
		or	a
		ret	z
		dec	a
		add	a
		ld	hl,arrowpostab
		call	addahl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		ldh	a,[whack_arrowfrm]
		xor	1
		ldh	[whack_arrowfrm],a
		add	255&IDX_WHARROW
		ld	c,a
		ld	a,0
		adc	IDX_WHARROW>>8
		ld	b,a
		ldh	a,[whack_arrowpos]
		dec	a
		and	1
		rrc	a
		ld	h,a
		ld	a,[wGroup2]
		or	h
		jp	AddFigure





beastret:	ret

tobeastbase:
		CHMODE	beastbase

beastbase:
		ld	a,BASE
		ldh	[whack_state],a
		xor	a
		ldh	[whack_bstcntr],a
		inc	a
		ldh	[whack_bstpick],a
		ld	a,[wJoy1Hit]
		bit	JOY_U,a
		jr	nz,.jump
		bit	JOY_D,a
		jr	nz,.duck
		bit	JOY_L,a
		jr	nz,.punchleft
		bit	JOY_R,a
		jr	nz,.punchright
		ret
.jump:
		CHMODE	beastjump
		xor	a
		call	checkbonus
		ld	a,SFX_WHACKJUMP
		call	InitSfx
		jr	stoparrow
.punchleft:
		CHMODE	beastpunchleft
		ld	a,3
		call	checkbonus
		ld	a,SFX_WHACKPUNCH
		call	InitSfx
		jr	stoparrow
.punchright:
		CHMODE	beastpunchright
		ld	a,1
		call	checkbonus
		ld	a,SFX_WHACKPUNCH
		call	InitSfx
		jr	stoparrow
.duck:
		CHMODE	beastduck
		ld	a,2
		call	checkbonus
		ld	a,SFX_WHACKDUCK
		call	InitSfx
stoparrow:	ldh	a,[whack_decide]
		or	a
		ret	z
		ld	b,a
		ldh	a,[whack_arrowtime]
		cp	b
		ret	c
		ldh	[whack_decide],a
		ret

checkbonus:	ld	b,a
		ldh	a,[whack_bonuscnt]
		or	a
		ret	z
		ldh	a,[whack_flags]
		bit	WHACKFLG_DUST,a
		ret	nz
		ldh	a,[whack_bonusloc]
		cp	b
		ret	nz
		ld	a,1
		ldh	[whack_bonuscnt],a
		ld	hl,whack_flags
		set	WHACKFLG_DUST,[hl]
		ld	hl,wSubStars
		inc	[hl]
		ld	a,SONG_GOTSTAR
		call	InitTune
		ret


beastjumpframes:
		db	4,4,5,5,5,5,5,5,5,5,5,5,4,4,1,0
beastpunchleftframes:
		db	9,9,8,8,8,8,8,8,8,9,9,1,0
beastpunchrightframes:
		db	7,7,6,6,6,6,6,6,6,7,7,1,0

beastduckframes:
		db	2,0
beastriseframes:
		db	3,0

beastvictoryframes:
		db	15,15,15,15
		db	16,16,16,16
		db	15,15,15,15
		db	16,16,16,16
		db	13,13,13,13
		db	12,12,12,12
		db	0

beastpunchleft:
		ld	a,PUNCHINGLEFT
		ld	hl,beastpunchleftframes
		jr	beastbaseseq
beastpunchright:
		ld	a,PUNCHINGRIGHT
		ld	hl,beastpunchrightframes
		jr	beastbaseseq

beastduck:
		ld	a,DUCKING
		ld	hl,beastduckframes
		ld	de,tobeastcontduck
		jr	beastanyseq
tobeastvictory:	xor	a
		ldh	[whack_bstcntr],a
		CHMODE	beastvictory
		ret
beastvictory:	ld	hl,beastvictoryframes
		jr	beastbaseseq

tobeastcontduck:
		CHMODE	beastcontduck
beastcontduck:
		ld	a,2
		call	checkbonus
		xor	a
		ldh	[whack_bstcntr],a
		ld	a,[wJoy1Cur]
		bit	JOY_D,a
		ret	nz
		xor	a
		ldh	[whack_bstcntr],a
		CHMODE	beastrise
beastrise:	ld	hl,beastriseframes
		ld	a,RISING
		jr	beastbaseseq
beastjump:	ld	hl,beastjumpframes
		ld	a,JUMPING
beastbaseseq:	ld	de,tobeastbase
beastanyseq:	ldh	[whack_state],a
		ldh	a,[whack_bstcntr]
		inc	a
		ldh	[whack_bstcntr],a
		dec	a
		call	addahl
		ld	a,[hl]
		or	a
		jr	z,.tode
		ldh	[whack_bstpick],a
		ret
.tode:		ld	h,d
		ld	l,e
		jp	[hl]


HEARTS		EQU	17*32+19


whackfixh:	ldh	a,[whack_health]
		ld	b,a
		ld	a,3
		cp	b
		ret	z
		ldh	[whack_health],a
.wflp:		push	bc
		call	whackdamageq
		pop	bc
		ldh	a,[whack_health]
		cp	b
		jr	nz,.wflp
		ret
whackdamage:	ldh	a,[whack_health]
		or	a
		jr	z,whacklost
		ld	a,SFX_WHACKHIT
		call	InitSfx
whackdamageq:	ldh	a,[whack_health]
		dec	a
		ldh	[whack_health],a
		cpl
		add	255&(HEARTS+1)
		ld	c,a
		ld	b,HEARTS>>8
		ld	hl,MAPORIG
		add	hl,bc
		dec	hl
		ld	a,[hli]
		ld	[hl],a
		ld	hl,ATTRORIG
		add	hl,bc
		dec	hl
		ld	a,[hli]
		ld	[hl],a
		ret
whacklost:	ld	hl,whack_flags
		set	WHACKFLG_OVER,[hl]
		ld	a,SONG_LOST
		call	InitTune
		ret

NUM1		EQU	256-MAXBEASTCHR*2
FIX		EQU	128-NUM1

whack_setup:	ld	hl,whack_flags
		res	WHACKFLG_FIRST,[hl]

		call	InitGroups
		ld	hl,PAL_WOLF
		call	AddPalette
		ld	[wGroup1],a
		ld	hl,PAL_WHARROW
		call	AddPalette
		ld	[wGroup2],a
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup3],a
		ld	hl,PAL_STAR
		call	AddPalette
		ld	[wGroup4],a

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jp	nz,.gmb


		ld	hl,beastpal
		call	LoadPalHL

		ld	hl,IDX_BST000CHR	;bst000chr
		ld	de,$c800
		call	SwdInFileSys


		ld	hl,65536-$c800
		add	hl,de
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		ld	de,-NUM1
		add	hl,de
		push	hl

		ld	hl,$c800
		ld	de,$9800-NUM1*16
		ld	c,NUM1
		call	DumpChrs

		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	de,$8800
		pop	bc
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A

		ld	hl,beastmap+8
		ld	de,MAPORIG
		ld	c,18
.y1:		ld	b,20
.x1:		ld	a,[hli]
		inc	hl
		add	FIX
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.x1
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.y1

		ld	hl,beastmap+8
		ld	de,ATTRORIG
		ld	c,18
.y2:		ld	b,20
.x2:		ld	a,[hli]
		cp	NUM1
		ld	a,[hli]
		jr	c,.noset
		set	3,a
.noset:
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.x2
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.y2
		jp	.cgb
.gmb:
		ld	hl,IDX_BW000CHR	;bw000chr
		ld	de,$c800
		call	SwdInFileSys

		ld	hl,65536-$c800
		add	hl,de
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		ld	de,-NUM1
		add	hl,de
		push	hl

		ld	hl,$c800
		ld	de,$9800-NUM1*16
		ld	c,NUM1
		call	DumpChrs

		ld	hl,beastbwmap+8
		ld	de,MAPORIG
		ld	c,18
.bwy1:		ld	b,20
.bwx1:		ld	a,[hli]
		inc	hl
		add	FIX
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.bwx1
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.bwy1

.cgb:

		call	whackfixh

		xor	a
		call	testbeast

		ld	a,%10000111
		ldh	[hVblLCDC],a

		ret

testbeast:	call	renderbeast

beastcopy:	ld	hl,MAPCOPY
		ldh	a,[whack_phase]
		srl	a
		ld	de,$9800
		jr	nc,.deok
		ld	de,$9c00
.deok:		ld	c,2*18
		push	de
		call	DumpChrs
		pop	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,ATTRCOPY
		ld	c,2*18
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret

whack_shutdown:
		call	FadeOut
		jp	SprOff


;a=# of Roger's anim to pick
;returns a=which beast frame to use for this wolf frame
wolfframe:	or	a
		ret	z
		dec	a
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		ld	de,beastani
		add	hl,de
		inc	hl
		ld	a,[hld]
		inc	a
		push	af
		ld	a,[hli]
		cp	255
		jr	z,.done
		ld	c,a
		inc	hl
		ld	a,[hli]
		add	80
		ld	d,a
		ld	a,[hl]
		add	72
		ld	e,a

		ld	l,c
		res	6,c
		ld	a,c
		add	255&IDX_WOLF
		ld	c,a
		ld	a,0
		adc	IDX_WOLF>>8
		ld	b,a
		ld	a,[wGroup1]
		bit	6,l
		jr	z,.aok
		or	$80
.aok:		call	AddFigure
.done:		pop	af
		ret

;a=beast # 0-15
renderbeast:	ld	e,a
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,e
		jr	z,.aok
		add	16
.aok:		push	af
		push	af
		ld	hl,MAPORIG
		ld	de,MAPCOPY
		ld	bc,MAPSIZE*2
		call	MemCopy
		pop	af
		add	a
		ld	hl,beastframes
		call	addahl
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		add	hl,de
		ld	de,MAPCOPY
		ldh	a,[whack_phase]
		srl	a
		ld	b,$80
		jr	nc,.bok
		ld	b,$80+MAXBEASTCHR
.bok:		call	apply
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.gmb
		ld	de,ATTRCOPY
		ld	b,0
		call	apply
.gmb:		pop	af
;a=beast # 0-15
bstchars:	ld	e,a
		add	a
		add	e
		ld	e,a
		ld	d,0
		ld	hl,bsttbl
		add	hl,de
		ld	c,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[whack_phase]
		srl	a
		ld	de,$8800
		jr	nc,.deok
		ld	de,$8800+MAXBEASTCHR*16
.deok:		jp	DumpChrsInFileSys


apply:		ld	a,[hli]
		or	a
		ret	z
		ld	c,a
		ld	a,[hli]
		add	e
		ld	e,a
		ld	a,[hli]
		adc	d
		ld	d,a
.copylp:	ld	a,[hli]
		add	b
		ld	[de],a
		inc	e	;won't cross 32 byte line
		dec	c
		jr	nz,.copylp
		jr	apply

whackstartsong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_WHACK
		call	InitTunePref
		ret


;a=attack #
whackattack:
		inc	a
		ldh	[whack_arrowpos],a
		dec	a
		add	a
		ld	hl,wolfattacks
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hli]
		ldh	[whack_want],a
		ld	a,[hli]
		ldh	[whack_statewant],a
		ld	a,[hli]
		ld	e,a
		ldh	[whack_take],a
		ld	a,[hli]
		ld	d,a
		ldh	[whack_take+1],a
		ld	a,[hli]
		sub	e
		ldh	[whack_tono],a
		ld	a,[hl]
		sbc	d
		ldh	[whack_tono+1],a
		ld	a,1
		ldh	[whack_decide],a
		ret

processattack:	ldh	a,[whack_decide]
		or	a
		ret	z
		inc	a
		ldh	[whack_decide],a
		dec	a
		ld	b,a
		ldh	a,[whack_take]
		ld	l,a
		ldh	a,[whack_take+1]
		ld	h,a
		ldh	a,[whack_arrowtime]
		cp	b
		jr	nz,.nosfx
		push	af
		push	hl
		push	bc
		ld	a,SFX_WHACKWOLF
;		call	InitSfx
		pop	bc
		pop	hl
		pop	af
.nosfx:
		add	CRITICAL
		cp	b
		jr	nz,.notcritical

		ld	a,[wJoy1Cur]
		ld	c,a
		ldh	a,[whack_want]
		and	c
;		jr	z,.gothit
		ldh	a,[whack_state]
		ld	c,a
		ldh	a,[whack_statewant]
		cp	c
		jr	nz,.gothit
		ldh	a,[whack_tono]
		add	l
		ld	l,a
		ldh	a,[whack_tono+1]
		adc	h
		ld	h,a
		push	hl
		call	IncScore
		pop	hl
		jr	.notcritical
.gothit:	ldh	a,[whack_flags]
		set	WHACKFLG_HIT,a
		ldh	[whack_flags],a
		CHMODE	beastret
		push	hl
		call	whackdamage
		pop	hl
.notcritical:	ld	a,[hl]
		or	a
		jr	z,.attackover
		cp	REGAIN
		jr	nz,.noregain
		ldh	a,[whack_flags]
		res	WHACKFLG_HIT,a
		ldh	[whack_flags],a
		CHMODE	beastbase
		inc	hl
		jr	.notcritical
.noregain:
		ld	b,a
		ldh	a,[whack_arrowtime]
		inc	a
		ld	c,a
		ldh	a,[whack_decide]
		cp	c
		jr	nc,.noarrow
		ld	b,0
		jr	.nostep
.noarrow:	inc	hl
		ld	a,l
		ldh	[whack_take],a
		ld	a,h
		ldh	[whack_take+1],a
		xor	a
		ldh	[whack_arrowpos],a
.nostep:	ld	a,b
		ldh	[whack_wolfpick],a
		ret
.attackover:	xor	a
		ldh	[whack_decide],a
		ldh	[whack_wolfpick],a
;		ld	hl,whack_flags
;		res	WHACKFLG_HIT,[hl]
;		CHMODE	beastbase
		ret





wolfattacks:	dw	wolflflo
		dw	wolfrtlo
		dw	wolflfmed
		dw	wolfrtmed
		dw	wolflfhi
		dw	wolfrthi

wolflflo:	db	1<<JOY_U,JUMPING
		dw	wolflfloyes,wolflflono

wolfrtlo:	db	1<<JOY_U,JUMPING
		dw	wolfrtloyes,wolfrtlono

wolflfhi:	db	1<<JOY_D,DUCKING
		dw	wolflfhiyes,wolflfhino

wolfrthi:	db	1<<JOY_D,DUCKING
		dw	wolfrthiyes,wolfrthino

wolflfmed:	db	1<<JOY_L,PUNCHINGLEFT
		dw	wolflfmedyes,wolflfmedno

wolfrtmed:	db	1<<JOY_R,PUNCHINGRIGHT
		dw	wolfrtmedyes,wolfrtmedno


wolflfloyes:	db	2,3,4,5,6,7,8,7,8,7,8,9,REGAIN,10,11,12,13,14,15,16,0
wolflflono:	db	2,3,4,18,19,20,21,21,22,23,24,0
wolfrtloyes:	db	69,70,71,72,73,74,75,74,75,74,75,76,REGAIN,77,78,79,80,81,82,83,0
wolfrtlono:	db	69,70,71,85,86,87,88,89,90,91,0
wolflfhiyes:	db	49,50,51,52,53,54,53,54,53,54,REGAIN,55,56,57,58,59,60,61,0
wolflfhino:	db	49,50,51,62,63,64,65,66,67,0
wolfrthiyes:	db	118,119,120,121,122,123,122,123,122,123,REGAIN,124,125,126,127,128,129,0
wolfrthino:	db	118,119,120,131,132,133,134,135,0
wolflfmedyes:	db	26,27,28,29,30,31,30,31,30,31,32,REGAIN,33,34,35,36,37,38,39,0
wolflfmedno:	db	26,27,28,45,46,47,0
wolfrtmedyes:	db	93,94,95,96,97,98,97,98,97,98,99,REGAIN,100,101,102,103,104,105,106,107,0
wolfrtmedno:	db	93,94,95,114,115,116,0


bsttbl:
		db	FSSIZE_BST001CHR>>4
		dw	IDX_BST001CHR
		db	FSSIZE_BST002CHR>>4
		dw	IDX_BST002CHR
		db	FSSIZE_BST003CHR>>4
		dw	IDX_BST003CHR
		db	FSSIZE_BST004CHR>>4
		dw	IDX_BST004CHR
		db	FSSIZE_BST005CHR>>4
		dw	IDX_BST005CHR
		db	FSSIZE_BST006CHR>>4
		dw	IDX_BST006CHR
		db	FSSIZE_BST007CHR>>4
		dw	IDX_BST007CHR
		db	FSSIZE_BST008CHR>>4
		dw	IDX_BST008CHR
		db	FSSIZE_BST009CHR>>4
		dw	IDX_BST009CHR
		db	FSSIZE_BST010CHR>>4
		dw	IDX_BST010CHR
		db	FSSIZE_BST011CHR>>4
		dw	IDX_BST011CHR
		db	FSSIZE_BST012CHR>>4
		dw	IDX_BST012CHR
		db	FSSIZE_BST013CHR>>4
		dw	IDX_BST013CHR
		db	FSSIZE_BST014CHR>>4
		dw	IDX_BST014CHR
		db	FSSIZE_BST015CHR>>4
		dw	IDX_BST015CHR
		db	FSSIZE_BST016CHR>>4
		dw	IDX_BST016CHR

		db	FSSIZE_BW001CHR>>4
		dw	IDX_BW001CHR
		db	FSSIZE_BW002CHR>>4
		dw	IDX_BW002CHR
		db	FSSIZE_BW003CHR>>4
		dw	IDX_BW003CHR
		db	FSSIZE_BW004CHR>>4
		dw	IDX_BW004CHR
		db	FSSIZE_BW005CHR>>4
		dw	IDX_BW005CHR
		db	FSSIZE_BW006CHR>>4
		dw	IDX_BW006CHR
		db	FSSIZE_BW007CHR>>4
		dw	IDX_BW007CHR
		db	FSSIZE_BW008CHR>>4
		dw	IDX_BW008CHR
		db	FSSIZE_BW009CHR>>4
		dw	IDX_BW009CHR
		db	FSSIZE_BW010CHR>>4
		dw	IDX_BW010CHR
		db	FSSIZE_BW011CHR>>4
		dw	IDX_BW011CHR
		db	FSSIZE_BW012CHR>>4
		dw	IDX_BW012CHR
		db	FSSIZE_BW013CHR>>4
		dw	IDX_BW013CHR
		db	FSSIZE_BW014CHR>>4
		dw	IDX_BW014CHR
		db	FSSIZE_BW015CHR>>4
		dw	IDX_BW015CHR
		db	FSSIZE_BW016CHR>>4
		dw	IDX_BW016CHR

;This data is made with the following perl script on the linux box
;BEAST.AS2 is the output of anim after taking Roger's BEAST.POS as
;input

;#!/usr/bin/perl
;open INFILE,"BEAST.AS2" or die "Can't open file\n";
;
;<INFILE>;
;<INFILE>;
;<INFILE>;
;<INFILE>;
;<INFILE>;
;while($line1=<INFILE>)
;{
;	$line2=<INFILE>;
;	$line1 =~ tr/0-9,\-//cd;
;	$line2 =~ tr/0-9,\-//cd;
;	@gr1= split(",",$line1);
;	@gr2= split(",",$line2);
;	if($gr2[0]<0)
;	{
;		$out=join(",", "-1" , $gr1[0], "0", "0");
;	} else
;	{
;		$xflip=$gr1[1]>=128 ? 64 : 0;
;		$out=join(",",$gr1[0]+$xflip,$gr2[0],$gr1[2],$gr1[3]);
;	}
;	print "\t\tdb\t",$out,"\n";
;
;}


beastani:
		db	-1,0,0,0
		db	0,0,-93,58
		db	1,0,-77,58
		db	2,0,-60,57
		db	15,0,-44,59
		db	17,0,-27,53
		db	18,10,-27,52
		db	17,9,-27,52
		db	18,10,-27,52
		db	19,0,-10,49
		db	20,0,10,51
		db	21,0,28,54
		db	1,0,53,55
		db	2,0,72,57
		db	3,0,90,57
		db	4,0,104,57
		db	-1,0,0,0
		db	15,2,-44,59
		db	20,3,-9,51
		db	21,4,21,54
		db	1,3,48,55
		db	2,2,76,57
		db	3,0,93,57
		db	4,0,105,57
		db	-1,0,0,0
		db	13,0,-68,49
		db	14,0,-69,49
		db	15,0,-65,45
		db	17,0,-41,33
		db	18,10,-41,33
		db	34,9,-42,16
		db	10,10,-40,33
		db	0,0,-25,40
		db	1,0,-3,46
		db	2,0,19,57
		db	3,0,33,57
		db	4,0,50,57
		db	5,0,71,58
		db	6,0,87,58
		db	0,0,100,58
		db	12,10,-32,49
		db	37,9,-53,16
		db	37,11,-78,-5
		db	37,0,-93,-15
		db	27,7,-44,32
		db	27,8,-66,31
		db	27,0,-86,31
		db	-1,0,0,0
		db	13,0,-68,47
		db	14,0,-69,41
		db	15,0,-56,29
		db	16,0,-29,11
		db	17,10,-25,11
		db	18,9,-25,10
		db	19,0,-12,9
		db	21,0,13,11
		db	1,0,41,14
		db	21,0,62,26
		db	22,0,79,34
		db	23,0,82,37
		db	-1,0,0,0
		db	15,1,-28,20
		db	19,1,3,13
		db	20,1,25,18
		db	21,1,51,27
		db	22,2,76,37
		db	23,0,82,37
		db	-1,0,0,0
		db	64,0,85,58
		db	65,0,74,59
		db	66,0,63,57
		db	79,0,46,61
		db	81,0,26,54
		db	82,10,27,52
		db	81,9,27,52
		db	82,10,27,52
		db	83,0,7,49
		db	84,0,-24,51
		db	85,0,-43,54
		db	65,0,-60,54
		db	66,0,-73,55
		db	67,0,-91,58
		db	68,0,-106,55
		db	-1,0,0,0
		db	79,2,44,59
		db	84,3,9,51
		db	85,4,-21,54
		db	65,3,-48,55
		db	66,0,-76,57
		db	67,0,-93,57
		db	68,0,-105,57
		db	-1,0,0,0
		db	77,0,68,49
		db	78,0,69,49
		db	79,0,65,45
		db	81,0,41,33
		db	82,10,41,33
		db	98,9,42,16
		db	74,10,40,33
		db	64,0,25,40
		db	65,0,3,46
		db	66,0,-19,57
		db	67,0,-33,57
		db	68,0,-50,57
		db	69,0,-71,58
		db	70,0,-87,58
		db	64,0,-100,58
		db	-1,0,0,0
		db	76,10,32,49
		db	101,9,53,16
		db	101,11,78,-5
		db	101,0,93,-15
		db	-1,0,0,0
		db	91,5,44,32
		db	91,6,66,31
		db	91,0,86,31
		db	-1,0,0,0
		db	77,0,68,47
		db	78,0,69,41
		db	79,0,56,29
		db	80,0,29,11
		db	81,10,25,11
		db	82,9,25,10
		db	83,0,12,9
		db	85,0,-13,11
		db	65,0,-41,14
		db	85,0,-62,26
		db	86,0,-79,34
		db	87,0,-82,37
		db	-1,0,0,0
		db	79,1,28,20
		db	83,1,-3,13
		db	84,1,-25,18
		db	85,1,-51,27
		db	86,2,-76,37
		db	87,0,-82,37
		db	-1,10,0,0
		db	-1,12,0,0
		db	-1,11,0,0
		db	-1,13,0,0
		db	-1,14,0,0
		db	-1,15,0,0



beastframes:	incbin	"res/dave/whackoff/bstmap.bin"
beastpal:	incbin	"res/dave/whackoff/bst000.rgb"
beastmap:	incbin	"res/dave/whackoff/bst000.map"
beastbwmap:	incbin	"res/dave/whackoff/bw000.map"
whack_end::
