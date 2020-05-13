; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SULTAN.ASM                                                            **
; **                                                                       **
; ** Last modified : 990301 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"sultan",CODE,BANK[19]
		section 19

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

sultan_top::


SONG_SULTAN	EQU	0 ;10

SUL_STAGE_CYCLE	EQU	80
SUL_STAGEY	EQU	20

SFX_SULTANJUMPS	EQU	2	;3 different sfx
SFX_SULTANEXIT	EQU	64
SFX_ERRORS	EQU	15	;2 different sfx

SULMODE_SULTAN	EQU	0
SULMODE_FIFI	EQU	1
SULMODE_DONE	EQU	2
SULMODE_FIFIANI	EQU	3
SULMODE_WAIT	EQU	4
SULMODE_GOOD	EQU	5
SULMODE_BAD	EQU	6
SULMODE_BONUS	EQU	7
SULMODE_FIFI2	EQU	8
SULMODE_STAGE	EQU	9

SULFLG_END	EQU	0
SULFLG_FIRST	EQU	1
SULFLG_ROTATING	EQU	2
SULFLG_BEGUN	EQU	3
SULFLG_BONUS	EQU	4
SULFLG_STINC	EQU	5

SUL_BONUSTIME	EQU	40	;time bonus is available
SUL_BONUSHOLD	EQU	30	;if you get the bonus
SUL_BONUSFLIC	EQU	20	;time after which dust begins flickering

sul_nextat	EQUS	"(hTemp48+00)"
sul_flags	EQUS	"(hTemp48+01)"
sul_counter	EQUS	"(hTemp48+02)"
sul_spot1	EQUS	"(hTemp48+03)"
sul_spot2	EQUS	"(hTemp48+04)"
sul_spot3	EQUS	"(hTemp48+05)"
sul_spot4	EQUS	"(hTemp48+06)"
sul_victory	EQUS	"(hTemp48+07)"
sul_sulrate	EQUS	"(hTemp48+08)"
sul_fifirate	EQUS	"(hTemp48+09)"
sul_dirat	EQUS	"(hTemp48+10)"
sul_counter2	EQUS	"(hTemp48+11)"
sul_posat	EQUS	"(hTemp48+12)"
sul_chain	EQUS	"(hTemp48+13)"
sul_seqlen	EQUS	"(hTemp48+14)"
sul_lenstart	EQUS	"(hTemp48+15)"
sul_seqrate	EQUS	"(hTemp48+16)"
sul_seqid	EQUS	"(hTemp48+17)"
sul_seqsize	EQUS	"(hTemp48+18)"
sul_seqlo	EQUS	"(hTemp48+19)"
sul_seqhi	EQUS	"(hTemp48+20)"
sul_mode	EQUS	"(hTemp48+21)"
sul_rotseq	EQUS	"(hTemp48+22)" ;8 bytes
sul_bonus	EQUS	"hTemp48+30"
sul_bonustime	EQUS	"hTemp48+31"
sul_bonusat	EQUS	"hTemp48+32"
sul_stepchg	EQUS	"hTemp48+33"
sul_stagepos	EQUS	"hTemp48+34"

sul_sequence	EQUS	"(hTemp48+36)" ;4/byte or 48 steps in sequence


;sultan rate, fifi rate, starting # of steps, ending # of steps, step change
sulstages:
		db	40,20,3,5,1
		db	38,20,4,6,1
		db	36,20,4,8,2
		db	34,20,1,46,1	;20 was 28
		db	34,20,2,46,2	;20 was 28
;		db	32,24,7,9,1
;		db	32,24,8,10,1
;		db	32,24,8,10,1
;		db	32,24,8,10,1

fifisfxtab:	db	31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46
		db	31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46


sultan::	ld	a,[wSubLevel]
		ld	l,a
		ld	h,0
		ld	e,l
		ld	d,h
		add	hl,hl
		add	hl,hl
		add	hl,de
		ld	de,sulstages
		add	hl,de
		ld	a,[hli]
		ldh	[sul_sulrate],a
		ld	a,[hli]
		ldh	[sul_fifirate],a
		ld	a,[hli]
		ldh	[sul_lenstart],a
		ld	b,a
		ld	a,[hli]
		ldh	[sul_victory],a
		inc	a
		ld	c,a
		ld	a,[wSubGaston]
		or	a
		jr	z,.nogaston
		ldh	a,[sul_lenstart]
		add	[hl]
		add	[hl]
		ldh	[sul_lenstart],a
		ld	a,255
		jr	.nobonus
.nogaston:	ld	a,[wSubLevel]
		cp	3
		ld	a,255
		jr	nc,.nobonus
		ld	a,c
		sub	b
		ld	b,a
		call	random
		or	$80
.back:		sub	b
		cp	c
		jr	nc,.back
.nobonus:	ldh	[sul_bonus],a
		ld	a,[hl]
		ldh	[sul_stepchg],a


		ldh	a,[sul_lenstart]
		ldh	[sul_seqlen],a

		call	newstage

		call	fillcycle

		ld	hl,sul_flags
		set	SULFLG_END,[hl]

		call	sul_setup

sultanloop::	call	sultansong
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jr	nz,sultanpause
		call	InitFigures
		call	sultanmode
		call	sulbonus
		call	seqstep
		call	OutFigures
		ld	hl,sul_flags
		bit	SULFLG_FIRST,[hl]
		jr	nz,.nofade
		set	SULFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ld	[hVbl8],a
.nofade:	ld	a,[sul_seqrate]
		call	AccurateWait
		ld	a,[sul_mode]
		cp	SULMODE_DONE
		jr	nz,sultanloop
		jp	sul_shutdown

sultanpause:	call	sul_shutdown
		call	PauseMenu_B
		call	sul_setup
		jp	sultanloop

sulmodestage:	call	sulstage
		ldh	a,[sul_stagepos]
		or	a
		ret	nz
		ld	a,SULMODE_SULTAN
		ldh	[sul_mode],a
		ret

sulstage:	ld	hl,sul_stagepos
		ld	a,[wGroup4]
		jp	StdStage

newstage:	ld	a,16
		ldh	[sul_seqrate],a
		ld	a,SULMODE_STAGE
		ldh	[sul_mode],a
		ld	a,[wSubLevel]	; For special mode
		cp	3		;
		jr	nc,.nostage	;
		ld	a,1
		ldh	[sul_stagepos],a
.nostage:	ld	hl,sul_flags
		ld	a,[hl]
		set	SULFLG_STINC,[hl]
		cp	[hl]
		ret	nz
		ld	hl,wSubStage
		inc	[hl]
		ret

newsultanmode:	ld	[sul_mode],a
sultanmode:	ld	a,[sul_mode]
		add	a
		ld	hl,sultanmodes
		ld	e,a
		ld	d,0
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	hl,sul_flags
		ret


sultanmodes:	dw	sulmodesultan
		dw	sulmodefifi
		dw	sulmodedone
		dw	sulmodefifiani
		dw	sulmodewait
		dw	sulmodegood
		dw	sulmodebad
		dw	sulmodebonus
		dw	sulmodefifi2
		dw	sulmodestage

sulmodedone:	ret


sultansong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_SULTAN
		jp	InitTunePref



tofifi:		xor	a
		ld	[sul_counter],a
		ld	[sul_posat],a
		ld	a,SULMODE_FIFI
		jp	newsultanmode

sulmodesultan:	bit	SULFLG_END,[hl]
		ret	z
		res	SULFLG_END,[hl]
		ld	a,[hl]
		res	SULFLG_ROTATING,[hl]
		cp	[hl]
		jr	nz,.nospot
		ld	a,[sul_posat]
		or	a
		jr	z,.nospot
		call	incdir
.nospot:
		ld	a,[sul_counter]
		ld	b,a
		ld	a,[sul_seqlen]
		inc	a
		cp	b
		jr	z,tofifi
		ld	a,[sul_posat]
		ld	e,a
		add	a
		add	a
		add	e
		ld	e,a
		ld	a,[sul_counter]
		call	getudlr
		ld	[sul_nextat],a
		add	e
		ld	e,a
		ld	d,0
		ld	hl,suldirsfirst
		add	hl,de
		ld	c,[hl]
		ld	a,[sul_dirat]
		cp	c
		jr	z,norotate
		ld	b,a
		ld	a,c
		ld	[sul_dirat],a
;b=current dir
;c=desired dir
		call	spinsultan
		ld	hl,sul_flags
		set	SULFLG_ROTATING,[hl]
		ld	hl,sul_rotseq
		jp	playsultan
norotate:	ld	hl,suldirslast
		add	hl,de
		ld	a,[hl]
		ld	[sul_dirat],a
		ld	a,[sul_nextat]
		ld	[sul_posat],a
		ld	hl,sul_counter
		inc	[hl]
		ld	hl,sultrans
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	playsultan
		ldh	a,[sul_posat]
		or	a
		ld	a,SFX_SULTANEXIT
		jr	z,.gotsfx
		call	random
		and	3
		jr	nz,.aok
		inc	a
.aok:		dec	a
		add	SFX_SULTANJUMPS
.gotsfx:	jp	InitSfx


bonuslocs:	db	80+0,72-36
		db	80+47,72-11
		db	80+0,72+13
		db	80-47,72-11


sulbonus:	ldh	a,[sul_bonusat]
		or	a
		ret	z
		dec	a
		add	a
		ld	hl,bonuslocs
		call	addahl
		ld	d,[hl]
		inc	hl
		ld	e,[hl]
		ld	bc,IDX_STAR
		ldh	a,[sul_flags]
		bit	SULFLG_BONUS,a
		jr	z,.bonus1
		ldh	a,[sul_bonustime]
		cp	SUL_BONUSFLIC
		jr	c,.noflicker
		bit	0,a
		ret	z
.noflicker:	cpl
		add	e
		ld	e,a
		ld	bc,IDX_DUST
.bonus1:	ldh	a,[sul_bonustime]
		and	7
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,[wGroup3]
		jp	AddFigure


incbonustime:	ldh	a,[sul_bonusat]
		or	a
		ret	z
		ld	hl,sul_bonustime
		inc	[hl]
		ldh	a,[sul_flags]
		bit	SULFLG_BONUS,a
		ld	b,SUL_BONUSTIME
		jr	z,.bonus1
		ld	b,SUL_BONUSHOLD
.bonus1:	ld	a,[hl]
		cp	b
		ret	c
		xor	a
		ldh	[sul_bonusat],a
		ret

sulmodebonus:	call	incbonustime
		or	a
		jp	z,.bonusdone
		ldh	a,[sul_flags]
		bit	SULFLG_BONUS,a
		ret	nz
		call	GetJoyDir
		ret	z
		ld	hl,sul_flags
		res	SULFLG_END,[hl]
		ld	b,SULMODE_FIFI2
		jp	fifinewdir
.bonusdone:	ld	a,SULMODE_FIFI
		jp	newsultanmode

trybonus:	ldh	a,[sul_bonustime]
		or	a
		ret	nz
		ldh	a,[sul_seqlen]
		ld	c,a
		ldh	a,[sul_counter]
		cp	c
		ret	c	;nz
		ldh	a,[sul_bonus]
		cp	c
		jr	c,.atbonus
		ret	nz
.atbonus:	pop	hl
		ldh	a,[sul_posat]
		ld	c,a
.pickbonus:	call	random
		and	3
		inc	a
		cp	c
		jr	z,.pickbonus
		ldh	[sul_bonusat],a
		xor	a
		ldh	[sul_bonustime],a
		ld	a,SULMODE_BONUS
		jp	newsultanmode

sulmodefifi:	call	trybonus
		ldh	a,[sul_seqlen]
		ld	c,a
		ldh	a,[sul_counter]
		cp	c
		jr	nz,.stillgoing
		ld	[wScoreLo],a	;For special mode
		ldh	a,[sul_victory]
		cp	c
		jp	z,fifigood
;		ld	hl,wSubStage
;		inc	[hl]
		xor	a
		jr	.gotdir
.stillgoing:	call	GetJoyDir
		ret	z
.gotdir:	ld	b,SULMODE_FIFIANI
fifinewdir:	ld	c,a
		ldh	a,[sul_posat]
		cp	c
		ret	z
		push	bc
		res	SULFLG_END,[hl]
		ld	e,a
		add	a
		add	a
		add	e
		add	c
		ld	e,a
		ld	a,c
		ld	[sul_posat],a
		ld	d,0
		ld	hl,fifitrans
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	playfifi
		pop	bc
		ld	a,c
		or	a
		jr	z,.noexitsnd
		ldh	a,[sul_counter]
		and	$1f
		ld	hl,fifisfxtab
		call	addahl
		ld	a,[hl]
		push	bc
		call	InitSfx
		pop	bc
.noexitsnd:
		ld	a,b
		jp	newsultanmode

tosultan::	ld	hl,sul_seqlen
		ldh	a,[sul_stepchg]
		add	[hl]
		ld	[hl],a
		xor	a
		ld	[sul_counter],a
		ld	[sul_posat],a
		jp	newstage

sulmodefifi2:	call	incbonustime
		ld	hl,sul_flags
		bit	SULFLG_END,[hl]
		ret	z
		res	SULFLG_END,[hl]
		ldh	a,[sul_bonusat]
		or	a
		jr	z,.nobonus
		ld	c,a
		ldh	a,[sul_posat]
		cp	c
		jr	nz,.nobonus
		ld	hl,sul_flags
		set	SULFLG_BONUS,[hl]
		ld	a,1
		ldh	[sul_bonustime],a
		ld	a,SONG_GOTSTAR
		call	InitTune
		ld	hl,wSubStars
		inc	[hl]
		ld	a,SULMODE_BONUS
		jp	newsultanmode
.nobonus:	xor	a
		ldh	[sul_bonusat],a
		ld	a,SULMODE_FIFI
		jp	newsultanmode

sulmodefifiani:	bit	SULFLG_END,[hl]
		ret	z
		res	SULFLG_END,[hl]
		ldh	a,[sul_posat]
		call	decdir
		ldh	a,[sul_seqlen]
		ld	c,a
		ldh	a,[sul_counter]
		cp	c
		jr	z,tosultan
		call	getudlr
		ld	c,a
		ldh	a,[sul_posat]
		cp	c
		jr	nz,fifibad

		ld	hl,sul_counter
		inc	[hl]
		ld	a,SULMODE_FIFI
		jp	newsultanmode
fifibad:	ld	a,SONG_LOST
		call	InitTune
		ld	b,SULMODE_BAD
		ld	a,15
		jp	towait
fifigood:	ld	hl,wSubStage
		inc	[hl]
		ld	a,SONG_WON
		call	InitTune
		ld	a,3+1
		ld	[sul_counter2],a
		ld	a,SULMODE_GOOD
		jp	newsultanmode

;b=mode to chain to after wait
;a=# of cycles to wait
towait:		ld	[sul_counter],a
		ld	a,16
		ld	[sul_seqrate],a
		ld	a,b
		ld	[sul_chain],a
		ld	a,SULMODE_WAIT
		jp	newsultanmode

sulmodewait:	ld	hl,sul_counter
		dec	[hl]
		ret	nz
		ld	a,[sul_chain]
		jp	newsultanmode


sulmodebad:	bit	SULFLG_BEGUN,[hl]
		jr	z,.triggerbad
		bit	SULFLG_END,[hl]
		ret	z
		ld	b,SULMODE_DONE
		ld	a,30
		jp	towait
.triggerbad:	res	SULFLG_END,[hl]
		set	SULFLG_BEGUN,[hl]
		ld	a,[sul_posat]
		ld	hl,fifiloses-2
		add	a
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	playfifi
		call	random
		and	1
		add	SFX_ERRORS
		jp	InitSfx


sulmodegood:	bit	SULFLG_END,[hl]
		ret	z
		res	SULFLG_END,[hl]
		ld	hl,sul_counter2
		dec	[hl]
		ld	a,30
		ld	b,SULMODE_DONE
		jp	z,towait
		ld	a,[sul_posat]
		ld	hl,fifiwins-2
		add	a
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	playfifi






clearspots:	ld	hl,sul_spot1
		ld	d,1
.cslp:		ld	a,[hl]
		or	a
		jr	z,.next
		ld	a,d
		push	de
		push	hl
		call	decdir
		pop	hl
		pop	de
		jr	.cslp
.next:		inc	hl
		inc	d
		ld	a,d
		cp	5
		jr	nz,.cslp
		ret

restorespots:	ld	hl,sul_spot1
		ld	d,1
.rslp1:		ld	e,0
.rslp2:		ld	a,[hl]
		cp	e
		jr	z,.next
		push	de
		push	hl
		ld	b,d
		dec	b
		ld	a,e
		call	swapspot
		pop	hl
		pop	de
		inc	e
		jr	.rslp2
.next:		inc	hl
		inc	d
		ld	a,d
		cp	5
		jr	nz,.rslp1
		ret



;a=dir to inc, 1-4
incdir:
		or	a
		ret	z
		dec	a
		ld	b,a
		ld	hl,sul_spot1
		call	addahl
		ld	a,[hl]
		inc	[hl]
		jr	swapspot
;a=dir to dec, 1-4
decdir:
		or	a
		ret	z
		dec	a
		ld	b,a
		ld	hl,sul_spot1
		call	addahl
		ld	a,[hl]
		or	a
		ret	z
		dec	[hl]
		dec	a
swapspot:	cp	3
		ret	nc
		ld	c,a
		ld	a,b
		add	a
		add	b
		add	c
		add	a
		add	a
		ld	hl,spottable
		call	addahl
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	swap2
		ld	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		call	swap2
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret
swap2:		DI
Sync0::		LDIO	A,[rSTAT]
		AND	%11
		JR	Z,Sync0
Sync1::		LDIO	A,[rSTAT]
		AND	%11
		JR	NZ,Sync1
		ld	b,[hl]
		ld	a,[de]
		ld	[hl],a
		ld	a,b
		ld	[de],a
		ei
		ret


spottable:	dw	$9800+6*32+9,$9800+18*32+0
		dw	$9800+7*32+8,$9800+18*32+1
		dw	$9800+7*32+11,$9800+18*32+2
		dw	$9800+9*32+15,$9800+18*32+6
		dw	$9800+9*32+17,$9800+18*32+7
		dw	$9800+10*32+16,$9800+18*32+8
		dw	$9800+12*32+8,$9800+18*32+9
		dw	$9800+12*32+11,$9800+18*32+10
		dw	$9800+13*32+10,$9800+18*32+11
		dw	$9800+9*32+2,$9800+18*32+3
		dw	$9800+9*32+4,$9800+18*32+4
		dw	$9800+10*32+3,$9800+18*32+5


;using sul_posat = where sultan is now (up,down,left or right)
;b=current dir
;c=desired dir
;build up a fake anim sequence at sul_rotseq
spinsultan:	ld	hl,sul_rotseq
		ld	a,1
		ld	[hli],a
.spinlp:	ld	a,c
		sub	b
		jr	z,.spun
		jr	nc,.noadd6
		add	6
.noadd6:	cp	4
		jr	c,.inc
		dec	b
		jr	.dec
.inc:		inc	b
.dec:		ld	a,b
		cp	6
		jr	c,.ok
		ld	b,0
		jr	z,.ok
		ld	b,5
.ok:		ld	a,[sul_posat]
		dec	a
		add	a
		ld	e,a
		add	a
		add	e
		add	b
		add	LOW(sulrottable)
		ld	e,a
		ld	a,0
		adc	HIGH(sulrottable)
		ld	d,a
		ld	a,[de]
		ld	[hli],a
		jr	.spinlp
.spun:		xor	a
		ld	[hl],a
		ret

getudlr:	ld	l,a
		ld	a,[sul_seqlen]
		cp	l
		ld	a,0
		ret	z
		ld	a,l
		push	af
		srl	a
		srl	a
		ld	hl,sul_sequence
		call	addahl
		ld	l,[hl]
		pop	af
		and	3
		inc	a
.rotlp:		rlc	l
		rlc	l
		dec	a
		jr	nz,.rotlp
		ld	a,l
		and	3
		inc	a
		ret

fillcycle:	ld	d,12
		ld	hl,sul_sequence
		ld	b,255
.byte:		ld	e,4
		ld	c,0
.cbfill:	call	random
		and	3
		cp	b
		jr	z,.cbfill
		ld	b,a
		sla	c
		sla	c
		or	c
		ld	c,a
		dec	e
		jr	nz,.cbfill
		ld	a,c
		ld	[hli],a
		dec	d
		jr	nz,.byte
		ret

playfifi:	ld	a,[wGroup2]
		ld	b,a
		ld	a,[sul_fifirate]
		ld	c,a
		jr	playseq
playsultan:	ld	a,[wGroup1]
		ld	b,a
		ld	a,[sul_sulrate]
		ld	c,a
		jr	playseq
;hl=anim list
;b=Group ID #
;c=frame rate
playseq::
		ld	a,c
		ld	[sul_seqrate],a
		ld	a,b
		ld	[sul_seqid],a
		ld	a,[hli]
		ld	[sul_seqsize],a
		ld	a,l
		ld	[sul_seqlo],a
		ld	a,h
		ld	[sul_seqhi],a
		ret

seqstep:	ld	hl,sul_seqlo
		ld	a,[hli]
		ld	b,[hl]
		ld	c,a
		or	b
		ret	z
		ld	a,[sul_seqsize]
		dec	a
		ld	a,[bc]
		inc	bc
		ld	e,a
		ld	d,0
		jr	z,.byte
		ld	a,[bc]
		inc	bc
		ld	d,a
.byte:		or	e
		jr	z,.endmark
		ld	[hl],b
		dec	l
		ld	[hl],c
		ld	a,[sul_seqsize]
		dec	a
		ld	a,[bc]
		ld	l,a
		jr	z,.byte2
		inc	bc
		ld	a,[bc]
		dec	bc
		dec	bc
.byte2:		dec	bc
		or	l
		jr	nz,.more
		ld	hl,sul_flags
		set	SULFLG_END,[hl]
		ld	hl,sul_seqlo
		ld	[hl],c
		inc	l
		ld	[hl],b
.more:
		ld	a,[sul_seqid]
		ld	b,a
		call	AddFrame
.endmark:	ret


GetJoyDir:	ld	a,[wJoy1Hit]
		bit	JOY_U,a
		jr	nz,.ret1
		bit	JOY_R,a
		jr	nz,.ret2
		bit	JOY_D,a
		jr	nz,.ret3
		bit	JOY_L,a
		jr	nz,.ret4
		xor	a
		ret
.ret1:		ld	a,1
		ret
.ret2:		ld	a,2
		ret
.ret3:		ld	a,3
		ret
.ret4:		ld	a,4
		ret


sul_setup:	ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,IDX_SULBCKBG	;sulbckbg
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok
		ld	hl,IDX_SULBCKBWBG	;sulbckbwbg
.hlok:
		call	BgInFileSys

		call	InitGroups
		ld	de,sultanframes
		ld	a,BANK(sultanframes)
		call	RegisterGroup
		ld	[wGroup1],a
		ld	de,fififrames
		ld	a,BANK(fififrames)
		call	RegisterGroup
		ld	[wGroup2],a
		ld	hl,PAL_STAR
		call	AddPalette
		ld	[wGroup3],a
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup4],a
		call	restorespots
		ld	hl,sul_flags
		res	SULFLG_FIRST,[hl]
		ret
sul_shutdown:	call	FadeOut
		jp	SprOff




sulentert:	db	1,1,2,3,4,5,6,7,0
sulenterr:	db	1,8,9,10,11,12,13,0
sulenterb:	db	1,14,15,16,17,18,19,20,0
sulenterl:	db	1,21,22,23,24,25,26,0
sulmovetl:	db	1,27,28,29,30,31,32,33,0
sulmovetb:	db	1,34,35,36,37,38,39,40,0
sulmovetr:	db	1,41,42,43,44,45,46,47,0
sulmovert:	db	1,48,49,50,51,52,53,0
sulmoverl:	db	1,54,55,56,57,58,59,60,61,62,0
sulmoverb:	db	1,63,64,65,66,67,68,69,0
sulmovebr:	db	1,70,71,72,73,74,0
sulmovebt:	db	1,75,76,77,78,79,80,81,82,0
sulmovebl:	db	1,83,84,85,86,87,88,0
sulmovelb:	db	1,89,90,91,92,93,94,95,0
sulmovelr:	db	1,96,97,98,99,100,101,102,103,104,0
sulmovelt:	db	1,105,106,107,108,109,110,0
sulexitt:	db	1,111,112,113,114,115,116,0
sulexitr:	db	1,117,118,119,120,121,0
sulexitb:	db	1,122,123,124,125,126,127,0
sulexitl:	db	1,128,129,130,131,132,0

sulrottable:	db	133,134,135,136,137,138
		db	139,140,141,142,143,144
		db	145,146,147,148,149,150
		db	151,152,153,154,155,156

;index into sultan anims
;5*from+to
;from,to: 0=offscreen,1=up,2=right,3=down,4=left
sultrans:
			;Coming from offscreen
		dw	0,sulentert,sulenterr,sulenterb,sulenterl
			;Coming from top
		dw	sulexitt,0,sulmovetr,sulmovetb,sulmovetl
			;Coming from right
		dw	sulexitr,sulmovert,0,sulmoverb,sulmoverl
			;Coming from bottom
		dw	sulexitb,sulmovebt,sulmovebr,0,sulmovebl
			;Coming from left
		dw	sulexitl,sulmovelt,sulmovelr,sulmovelb,0

;5*from+to
;from,to: 0=offscreen,1=up,2=right,3=down,4=left
suldirsfirst:	db	0,0,0,0,0
		db	0,0,1,2,3
		db	1,4,0,3,4
		db	2,5,0,0,4
		db	3,0,0,1,0
;5*from+to
;from,to: 0=offscreen,1=up,2=right,3=down,4=left
suldirslast:	db	0,3,4,5,0
		db	0,0,1,2,3
		db	0,4,0,3,4
		db	0,5,0,0,4
		db	0,0,0,1,0



fifientert:	db	2
		dw	303,304,305,306,307,308,309,310,311,312,313,314,0
fifienterr:	db	2
		dw	280,281,282,283,284,285,286,287,288,289,290,291
		dw	292,293,294,0
fifienterb:	db	2
		dw	252,253,254,255,256,257,258,259,260,261,262,263
		dw	264,265,266,267,0
fifienterl:	db	2
		dw	322,323,324,325,326,327,328,329,330,331,332,333,0
fifimovetl:	db	1,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,0
fifimovetb:	db	1,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,0
fifimovetr:	db	1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,0
fifimovert:	db	1,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,0
fifimoverl:	db	1,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,0
fifimoverb:	db	1,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,0
fifimovebr:	db	1,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,0
fifimovebt:	db	1,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,0
fifimovebl:	db	1,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,0
fifimovelb:	db	1,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,0
fifimovelr:	db	1,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,0
fifimovelt:	db	1,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,0
fifiexitt:	db	2
		dw	314,315,316,317,318,319,320,321,0
fifiexitr:	db	2
		dw	295,296,297,298,299,300,301,302,0
fifiexitb:	db	2
		dw	267,268,269,270,271,272,273,274,275,276,277,278
		dw	279,302,0
fifiexitl:	db	2
		dw	334,335,336,337,338,339,0
fifiwint:	db	1,192,193,194,195,196,197,198,199,200,0
fifiwinr:	db	1,201,202,203,204,205,206,207,208,209,0
fifiwinb:	db	1,210,211,212,213,214,215,216,217,218,0
fifiwinl:	db	1,219,220,221,222,223,224,225,226,227,0
fifiloset:	db	1,228,229,230,231,232,233,0
fifiloser:	db	1,234,235,236,237,238,239,0
fifiloseb:	db	1,240,241,242,243,244,245,0
fifilosel:	db	1,246,247,248,249,250,251,0
;index into FIFI anims
;5*from+to
;from,to: 0=offscreen,1=up,2=right,3=down,4=left
fifitrans:
			;Coming from offscreen
		dw	0,fifientert,fifienterr,fifienterb,fifienterl
			;Coming from top
		dw	fifiexitt,0,fifimovetr,fifimovetb,fifimovetl
			;Coming from right
		dw	fifiexitr,fifimovert,0,fifimoverb,fifimoverl
			;Coming from bottom
		dw	fifiexitb,fifimovebt,fifimovebr,0,fifimovebl
			;Coming from left
		dw	fifiexitl,fifimovelt,fifimovelr,fifimovelb,0
fifiloses:	dw	fifiloset,fifiloser,fifiloseb,fifilosel
fifiwins:	dw	fifiwint,fifiwinr,fifiwinb,fifiwinl



sultanframes::
	db	1
	dw	PAL_SLTNCHP2
	dw	IDX_SLTNCHP2
	db	-1,0,0,0
	db	22,128,78,-53
	db	22,128,45,-43
	db	23,128,25,-34
	db	24,128,12,-21
	db	7,0,-4,-30
	db	0,0,-4,-29
	db	-1,0,0,0
	db	9,0,84,17
	db	9,0,65,8
	db	10,0,48,5
	db	11,0,45,1
	db	7,0,48,-7
	db	-1,0,0,0
	db	15,0,-3,84
	db	27,0,-2,67
	db	15,0,-4,32
	db	14,0,-6,18
	db	26,0,-1,24
	db	25,0,-1,17
	db	-1,0,0,0
	db	9,128,-82,7
	db	9,128,-71,3
	db	10,128,-52,2
	db	11,128,-46,2
	db	7,128,-47,-6
	db	0,0,-4,-29
	db	1,0,-20,-31
	db	2,0,-34,-21
	db	3,0,-43,-9
	db	4,0,-49,-5
	db	5,0,-55,-4
	db	0,0,-55,-6
	db	28,0,-2,-30
	db	15,0,-4,-24
	db	15,0,-4,-13
	db	16,0,-5,-11
	db	17,0,-3,26
	db	14,0,-4,17
	db	13,0,-3,17
	db	0,128,4,-30
	db	1,128,18,-33
	db	2,128,31,-22
	db	3,128,41,-10
	db	4,128,48,-5
	db	5,128,56,-3
	db	0,128,51,-7
	db	7,0,47,-8
	db	8,0,48,0
	db	9,0,29,-19
	db	10,0,2,-20
	db	11,0,-5,-22
	db	7,0,-2,-30
	db	7,0,48,-8
	db	19,128,51,0
	db	20,128,37,-10
	db	21,128,20,-17
	db	22,128,0,-17
	db	23,128,-26,-8
	db	24,0,-56,0
	db	18,128,-51,-6
	db	7,0,-55,-9
	db	0,0,47,-7
	db	1,0,36,-6
	db	2,0,23,1
	db	3,0,14,8
	db	4,0,7,18
	db	5,0,-1,22
	db	0,0,0,18
	db	7,128,5,18
	db	8,128,5,25
	db	9,128,25,8
	db	10,128,51,4
	db	7,128,57,-6
	db	25,0,-1,17
	db	26,0,0,25
	db	27,0,-1,-1
	db	15,0,-4,-25
	db	28,0,-2,-31
	db	29,0,-1,-20
	db	26,0,0,-25
	db	25,0,-1,-32
	db	7,0,-4,18
	db	8,0,-4,26
	db	9,0,-24,9
	db	10,0,-49,4
	db	11,0,-55,0
	db	7,0,-53,-7
	db	0,128,-47,-6
	db	1,128,-30,-4
	db	2,128,-20,3
	db	3,128,-8,15
	db	4,128,0,19
	db	5,128,5,21
	db	7,128,6,18
	db	7,128,-47,-7
	db	19,0,-50,1
	db	20,0,-44,-3
	db	21,0,-19,-19
	db	22,0,7,-19
	db	23,0,26,-10
	db	24,0,43,1
	db	18,0,53,-4
	db	7,128,55,-7
	db	7,128,-47,-7
	db	8,128,-47,1
	db	9,128,-28,-16
	db	10,128,-3,-20
	db	11,128,9,-24
	db	7,128,4,-31
	db	20,0,8,-30
	db	21,0,27,-42
	db	22,0,57,-45
	db	23,0,80,-38
	db	24,0,92,-34
	db	-1,0,0,0
	db	0,128,55,-7
	db	1,128,71,-8
	db	2,128,90,-4
	db	3,128,96,12
	db	-1,0,0,0
	db	13,0,-4,18
	db	14,0,-5,16
	db	15,0,-5,36
	db	16,0,-6,66
	db	14,0,-4,89
	db	-1,0,0,0
	db	0,0,-53,-7
	db	1,0,-68,-9
	db	2,0,-91,-1
	db	3,0,-97,14
	db	-1,0,0,0
	db	7,128,5,-30
	db	0,128,4,-29
	db	28,0,-2,-25
	db	0,0,-3,-29
	db	7,0,-3,-30
	db	31,0,-1,-28
	db	7,128,55,-7
	db	0,128,54,-7
	db	28,128,54,-3
	db	0,0,50,-7
	db	7,0,48,-7
	db	25,0,51,-8
	db	7,128,4,18
	db	0,128,4,18
	db	28,0,-1,22
	db	0,0,-2,18
	db	7,0,-2,18
	db	25,0,-2,18
	db	7,128,-48,-7
	db	0,128,-48,-7
	db	28,0,-54,-3
	db	0,0,-53,-7
	db	7,0,-54,-7
	db	25,0,-52,-8
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0


fififrames::
	db	2
	dw	PAL_FIFIBODY
	dw	IDX_FIFIBODY
	dw	PAL_FIFIFTH
	dw	IDX_FIFIFTH
	db	15,1,2,-31
	db	15,0,0,-36
	db	0,1,1,-41
	db	0,0,0,-47
	db	1,1,7,-47
	db	1,0,4,-52
	db	2,1,12,-48
	db	2,0,10,-53
	db	3,1,22,-48
	db	3,0,20,-53
	db	4,1,26,-48
	db	4,0,24,-53
	db	5,1,29,-48
	db	5,0,27,-53
	db	6,1,34,-49
	db	6,0,32,-54
	db	7,1,38,-47
	db	7,0,36,-52
	db	8,1,43,-45
	db	8,0,41,-50
	db	9,1,47,-39
	db	9,0,45,-44
	db	10,1,50,-34
	db	10,0,48,-39
	db	11,1,49,-25
	db	11,0,47,-30
	db	12,1,51,-16
	db	12,0,49,-21
	db	13,1,54,-2
	db	13,0,52,-7
	db	14,1,56,-2
	db	14,0,54,-7
	db	15,129,47,-6
	db	15,128,49,-11
	db	0,129,46,-16
	db	0,128,47,-22
	db	1,129,40,-22
	db	1,128,43,-27
	db	2,129,35,-27
	db	2,128,37,-32
	db	3,129,25,-28
	db	3,128,27,-33
	db	4,129,20,-30
	db	4,128,22,-35
	db	5,129,14,-31
	db	5,128,16,-36
	db	6,129,9,-32
	db	6,128,11,-37
	db	7,129,5,-24
	db	7,128,7,-29
	db	8,129,-1,-20
	db	8,128,1,-25
	db	9,129,-4,-13
	db	9,128,-2,-18
	db	10,129,-6,-3
	db	10,128,-4,-8
	db	11,129,-7,12
	db	11,128,-5,7
	db	12,129,-7,19
	db	12,128,-5,14
	db	13,129,-5,21
	db	13,128,-3,16
	db	14,129,-4,22
	db	14,128,-2,17
	db	15,129,-4,18
	db	15,128,-2,13
	db	0,129,0,7
	db	0,128,1,1
	db	1,129,-5,-2
	db	1,128,-3,-7
	db	2,129,-7,-9
	db	2,128,-6,-14
	db	3,1,-12,-15
	db	3,0,-14,-20
	db	4,129,-17,-25
	db	4,128,-15,-30
	db	5,129,-22,-29
	db	5,128,-20,-34
	db	6,129,-31,-34
	db	6,128,-29,-39
	db	7,129,-36,-33
	db	7,128,-34,-38
	db	8,129,-44,-37
	db	8,128,-42,-42
	db	9,129,-52,-34
	db	9,128,-50,-39
	db	10,129,-57,-27
	db	10,128,-55,-32
	db	11,1,-48,-17
	db	11,0,-50,-22
	db	12,1,-48,-4
	db	12,0,-50,-9
	db	13,1,-49,-1
	db	13,0,-51,-6
	db	14,1,-47,-3
	db	14,0,-49,-8
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	0,1,-53,-18
	db	0,0,-54,-24
	db	1,1,-50,-25
	db	1,0,-53,-30
	db	2,1,-49,-29
	db	2,0,-51,-34
	db	3,1,-47,-31
	db	3,0,-49,-36
	db	4,1,-44,-34
	db	4,0,-46,-39
	db	5,1,-40,-39
	db	5,0,-42,-44
	db	6,1,-35,-43
	db	6,0,-37,-48
	db	7,1,-29,-43
	db	7,0,-31,-48
	db	8,1,-23,-49
	db	8,0,-25,-54
	db	9,1,-19,-48
	db	9,0,-21,-53
	db	10,1,-10,-49
	db	10,0,-12,-54
	db	11,1,-4,-49
	db	11,0,-6,-54
	db	12,1,-1,-39
	db	12,0,-3,-44
	db	13,1,1,-29
	db	13,0,-1,-34
	db	14,1,3,-29
	db	14,0,1,-34
	db	15,1,2,-31
	db	15,0,0,-36
	db	0,129,-4,-41
	db	0,128,-3,-47
	db	1,129,-9,-43
	db	1,128,-7,-48
	db	2,129,-17,-44
	db	2,128,-15,-49
	db	3,129,-23,-47
	db	3,128,-21,-52
	db	4,129,-28,-49
	db	4,128,-26,-54
	db	5,129,-34,-48
	db	5,128,-32,-53
	db	6,129,-41,-48
	db	6,128,-39,-53
	db	7,129,-44,-46
	db	7,128,-42,-51
	db	8,129,-52,-47
	db	8,128,-50,-52
	db	9,129,-55,-41
	db	9,128,-53,-46
	db	10,129,-57,-31
	db	10,128,-55,-36
	db	11,1,-50,-14
	db	11,0,-52,-19
	db	12,1,-49,-8
	db	12,0,-51,-13
	db	14,1,-46,-4
	db	14,0,-48,-9
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	0,1,-45,-19
	db	0,0,-46,-25
	db	1,1,-41,-24
	db	1,0,-44,-29
	db	2,1,-38,-26
	db	2,0,-40,-31
	db	3,1,-37,-26
	db	3,0,-39,-31
	db	4,1,-32,-29
	db	4,0,-34,-34
	db	5,1,-22,-32
	db	5,0,-24,-37
	db	6,1,-18,-33
	db	6,0,-20,-38
	db	7,1,-14,-33
	db	7,0,-15,-38
	db	8,1,-4,-32
	db	8,0,-6,-37
	db	9,1,0,-24
	db	9,0,-2,-29
	db	10,1,2,-15
	db	10,0,0,-20
	db	11,1,3,1
	db	11,0,1,-4
	db	12,1,3,12
	db	12,0,1,7
	db	13,1,3,21
	db	13,0,1,16
	db	14,1,6,21
	db	14,0,4,16
	db	15,1,3,19
	db	15,0,1,14
	db	0,1,0,8
	db	0,0,-1,2
	db	1,1,3,2
	db	1,0,1,-3
	db	2,1,7,-4
	db	2,0,5,-9
	db	3,1,15,-9
	db	3,0,13,-14
	db	4,1,20,-14
	db	4,0,18,-19
	db	5,1,25,-20
	db	5,0,23,-25
	db	6,1,30,-26
	db	6,0,28,-31
	db	7,1,34,-30
	db	7,0,32,-35
	db	8,1,42,-33
	db	8,0,40,-38
	db	9,1,50,-35
	db	9,0,48,-40
	db	10,1,52,-31
	db	10,0,50,-36
	db	11,129,47,-24
	db	11,128,49,-29
	db	12,1,55,-17
	db	12,128,48,-22
	db	13,129,50,-6
	db	13,128,52,-11
	db	14,129,46,0
	db	14,128,48,-5
	db	15,129,47,-6
	db	15,128,49,-11
	db	0,129,51,-16
	db	0,128,52,-22
	db	1,129,46,-22
	db	1,128,51,-28
	db	2,129,44,-26
	db	2,128,46,-31
	db	3,129,40,-31
	db	3,128,42,-36
	db	4,129,31,-37
	db	4,128,33,-42
	db	5,129,25,-42
	db	5,128,27,-47
	db	6,129,19,-50
	db	6,128,21,-55
	db	7,129,14,-52
	db	7,128,16,-57
	db	8,129,7,-55
	db	8,128,9,-60
	db	9,129,2,-51
	db	9,128,4,-56
	db	10,129,-1,-45
	db	10,128,1,-50
	db	11,129,-3,-36
	db	11,128,-1,-41
	db	12,129,-3,-31
	db	12,128,-1,-36
	db	13,129,-2,-28
	db	13,128,0,-33
	db	14,129,-5,-28
	db	14,128,-3,-33
	db	15,129,-3,-31
	db	15,128,-1,-36
	db	16,1,6,-37
	db	16,0,4,-42
	db	17,1,7,-44
	db	17,0,5,-49
	db	3,1,-3,-51
	db	3,0,-5,-56
	db	4,1,0,-48
	db	4,0,-2,-54
	db	5,1,2,-37
	db	5,0,0,-42
	db	6,1,1,-30
	db	6,0,-1,-35
	db	7,1,0,-15
	db	7,0,-2,-19
	db	8,1,3,-10
	db	8,0,1,-15
	db	9,1,3,-5
	db	9,0,1,-10
	db	10,1,4,2
	db	10,0,2,-3
	db	11,1,2,10
	db	11,0,0,5
	db	12,129,-5,15
	db	12,128,-3,10
	db	13,129,-4,19
	db	13,128,-2,14
	db	14,129,-6,20
	db	14,128,-4,15
	db	15,129,-4,18
	db	15,128,-2,13
	db	16,129,-6,7
	db	16,128,-4,2
	db	17,129,-5,1
	db	17,128,-3,-4
	db	3,1,-2,-11
	db	3,0,-4,-16
	db	4,1,-1,-18
	db	4,0,-3,-23
	db	5,1,1,-23
	db	5,0,-1,-28
	db	6,1,0,-29
	db	6,0,-2,-34
	db	7,1,-1,-36
	db	7,0,-3,-41
	db	8,1,4,-44
	db	8,0,1,-49
	db	9,1,4,-48
	db	9,0,2,-53
	db	10,1,5,-41
	db	10,0,3,-46
	db	11,1,4,-33
	db	11,0,2,-38
	db	12,1,4,-28
	db	12,0,2,-33
	db	13,1,2,-26
	db	13,0,0,-31
	db	14,1,5,-28
	db	14,0,3,-33
	db	15,1,2,-31
	db	15,0,0,-36
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	0,1,-46,-18
	db	0,0,-47,-24
	db	1,1,-43,-24
	db	1,0,-45,-29
	db	2,1,-39,-29
	db	2,0,-41,-34
	db	3,1,-30,-33
	db	3,0,-32,-38
	db	4,1,-21,-38
	db	4,0,-23,-43
	db	5,1,-8,-41
	db	5,0,-10,-46
	db	6,1,-1,-42
	db	6,0,-3,-47
	db	7,1,7,-39
	db	7,0,5,-44
	db	8,1,16,-39
	db	8,0,14,-44
	db	9,1,28,-38
	db	9,0,26,-43
	db	10,1,35,-35
	db	10,0,33,-40
	db	11,1,43,-24
	db	11,0,41,-29
	db	12,129,45,-11
	db	12,128,47,-16
	db	13,129,47,-4
	db	13,128,49,-9
	db	14,129,45,-4
	db	14,128,47,-9
	db	15,129,47,-6
	db	15,128,49,-11
	db	0,129,46,-18
	db	0,128,47,-24
	db	1,129,41,-26
	db	1,128,44,-31
	db	2,129,35,-30
	db	2,128,37,-35
	db	3,129,28,-34
	db	3,128,30,-39
	db	4,129,20,-35
	db	4,128,22,-40
	db	5,129,8,-38
	db	5,128,10,-43
	db	6,129,-1,-38
	db	6,128,1,-43
	db	7,129,-11,-37
	db	7,128,-9,-42
	db	8,129,-26,-37
	db	8,128,-24,-42
	db	9,129,-34,-33
	db	9,128,-32,-38
	db	10,129,-41,-29
	db	10,0,-35,-34
	db	11,129,-48,-23
	db	11,128,-46,-28
	db	12,1,-48,-7
	db	12,0,-50,-12
	db	13,1,-49,-4
	db	13,0,-51,-9
	db	14,1,-46,-4
	db	14,0,-48,-9
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	15,1,2,-31
	db	15,0,0,-36
	db	16,1,5,-37
	db	16,0,3,-42
	db	17,1,7,-40
	db	17,0,5,-45
	db	18,1,3,-44
	db	18,0,1,-49
	db	19,1,2,-47
	db	19,0,0,-52
	db	20,1,2,-42
	db	20,0,0,-47
	db	21,1,3,-33
	db	21,0,1,-38
	db	22,1,2,-25
	db	22,0,0,-30
	db	15,1,2,-31
	db	15,0,0,-36
	db	15,129,47,-6
	db	15,128,49,-11
	db	16,129,46,-11
	db	16,128,48,-16
	db	17,129,45,-17
	db	17,128,47,-22
	db	18,129,44,-27
	db	18,128,46,-32
	db	19,129,45,-28
	db	19,128,47,-33
	db	20,129,47,-28
	db	20,128,49,-33
	db	21,129,47,-10
	db	21,128,49,-15
	db	22,129,48,0
	db	22,128,50,-5
	db	15,129,47,-6
	db	15,128,49,-11
	db	15,1,4,18
	db	15,0,2,13
	db	16,1,3,10
	db	16,0,1,5
	db	17,1,3,4
	db	17,0,1,-1
	db	18,1,5,-5
	db	18,0,3,-10
	db	19,1,4,-7
	db	19,0,2,-12
	db	20,1,4,-7
	db	20,0,2,-12
	db	21,1,6,12
	db	21,0,4,7
	db	22,1,4,23
	db	22,0,2,18
	db	15,1,4,18
	db	15,0,2,13
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	16,1,-45,-14
	db	16,0,-47,-19
	db	17,1,-45,-20
	db	17,0,-47,-25
	db	18,1,-46,-28
	db	18,0,-48,-33
	db	19,1,-45,-34
	db	19,0,-47,-39
	db	20,1,-48,-29
	db	20,0,-50,-34
	db	21,1,-47,-14
	db	21,0,-49,-19
	db	22,1,-47,-2
	db	22,0,-49,-7
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	15,1,2,-31
	db	15,0,0,-36
	db	24,1,4,-29
	db	24,0,2,-34
	db	25,1,4,-29
	db	25,0,2,-34
	db	26,1,5,-29
	db	26,0,3,-34
	db	27,1,5,-30
	db	27,0,3,-35
	db	28,1,6,-30
	db	28,0,4,-35
	db	15,129,47,-6
	db	15,128,49,-11
	db	24,129,47,-4
	db	24,128,49,-9
	db	25,129,47,-5
	db	25,128,49,-10
	db	26,129,47,-5
	db	26,128,49,-10
	db	27,129,45,-5
	db	27,128,47,-10
	db	28,129,44,-5
	db	28,128,46,-10
	db	15,1,4,18
	db	15,0,2,13
	db	24,1,4,19
	db	24,0,2,14
	db	25,1,4,19
	db	25,0,2,14
	db	26,1,5,19
	db	26,0,3,14
	db	27,1,5,18
	db	27,0,3,13
	db	28,1,6,18
	db	28,0,4,13
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	24,1,-47,-6
	db	24,0,-49,-11
	db	25,1,-47,-6
	db	25,0,-49,-11
	db	26,1,-48,-6
	db	26,0,-50,-11
	db	27,1,-48,-7
	db	27,0,-50,-12
	db	28,1,-47,-7
	db	28,0,-49,-12
	db	0,1,-78,80
	db	0,0,-79,74
	db	1,1,-69,67
	db	1,0,-71,63
	db	2,1,-65,53
	db	2,0,-67,48
	db	3,1,-60,40
	db	3,0,-62,35
	db	4,1,-53,25
	db	4,0,-55,20
	db	5,1,-41,15
	db	5,0,-43,10
	db	6,1,-35,7
	db	6,0,-37,2
	db	7,1,-28,3
	db	7,0,-30,-2
	db	8,1,-19,0
	db	8,0,-21,-5
	db	9,1,-11,4
	db	9,0,-13,-1
	db	10,1,-4,9
	db	10,0,-6,4
	db	11,1,-4,16
	db	11,0,-6,11
	db	12,1,-2,22
	db	12,0,-4,17
	db	13,1,2,23
	db	13,0,0,18
	db	14,1,4,21
	db	14,0,2,16
	db	15,1,4,18
	db	15,0,2,13
	db	0,1,7,6
	db	0,0,6,0
	db	1,1,11,2
	db	1,0,9,-3
	db	2,1,18,-3
	db	2,0,16,-8
	db	3,1,29,-3
	db	3,0,27,-8
	db	4,1,47,-3
	db	4,0,45,-8
	db	5,1,59,5
	db	5,0,56,0
	db	6,1,63,16
	db	6,0,61,11
	db	7,1,66,27
	db	7,0,64,22
	db	8,1,70,31
	db	8,0,68,26
	db	9,1,74,43
	db	9,0,72,38
	db	10,1,90,57
	db	-1,0,0,0
	db	11,1,99,67
	db	-1,0,0,0
	db	0,129,92,58
	db	0,128,93,52
	db	1,129,77,39
	db	1,128,79,34
	db	2,129,72,26
	db	2,128,74,21
	db	3,129,67,2
	db	3,128,69,-3
	db	4,129,62,-6
	db	4,128,64,-11
	db	5,129,56,-20
	db	5,128,58,-25
	db	6,129,53,-26
	db	6,128,55,-31
	db	7,129,52,-28
	db	7,128,54,-33
	db	8,129,51,-23
	db	8,128,53,-28
	db	9,129,48,-15
	db	9,128,50,-20
	db	10,129,46,-8
	db	10,128,48,-13
	db	11,129,47,-4
	db	11,128,49,-9
	db	13,129,48,0
	db	13,128,50,-5
	db	14,129,45,-2
	db	14,128,47,-7
	db	15,129,47,-6
	db	15,128,49,-11
	db	15,1,53,-6
	db	15,0,51,-11
	db	16,1,56,-16
	db	16,0,54,-21
	db	17,1,63,-25
	db	17,0,60,-30
	db	18,1,69,-33
	db	18,0,67,-38
	db	8,1,78,-29
	db	8,0,76,-34
	db	7,1,84,-22
	db	7,0,82,-27
	db	10,1,103,-12
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0
	db	3,1,0,-88
	db	-1,0,0,0
	db	4,1,1,-79
	db	-1,0,0,0
	db	5,1,2,-73
	db	-1,0,0,0
	db	6,1,1,-63
	db	6,128,2,-68
	db	7,1,1,-53
	db	7,0,-1,-58
	db	8,1,4,-47
	db	8,128,1,-52
	db	9,129,-3,-40
	db	9,128,-1,-45
	db	10,129,-4,-33
	db	10,128,-2,-38
	db	11,1,3,-29
	db	11,0,1,-34
	db	13,1,3,-26
	db	13,0,1,-31
	db	14,1,4,-26
	db	14,0,2,-31
	db	15,1,2,-31
	db	15,0,0,-36
	db	0,1,4,-44
	db	0,0,3,-50
	db	1,1,15,-59
	db	1,0,14,-64
	db	2,1,25,-73
	db	-1,0,0,0
	db	3,1,35,-86
	db	-1,0,0,0
	db	4,1,52,-90
	db	-1,0,0,0
	db	5,1,68,-90
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0
	db	0,129,7,83
	db	0,128,9,77
	db	0,129,2,66
	db	1,128,1,63
	db	2,129,-10,45
	db	2,128,-8,40
	db	3,129,-14,32
	db	3,128,-12,27
	db	4,129,-22,18
	db	4,128,-20,13
	db	5,129,-31,10
	db	5,128,-29,5
	db	6,129,-35,-1
	db	6,128,-33,-6
	db	7,129,-42,-13
	db	7,128,-40,-18
	db	8,129,-52,-17
	db	8,128,-50,-22
	db	11,1,-48,-8
	db	11,0,-50,-13
	db	14,1,-46,-4
	db	14,0,-48,-9
	db	15,1,-48,-7
	db	15,0,-50,-12
	db	15,129,-54,-7
	db	15,128,-52,-12
	db	16,129,-61,-16
	db	16,128,-59,-21
	db	17,129,-71,-32
	db	17,128,-69,-37
	db	18,129,-81,-39
	db	18,128,-79,-44
	db	9,1,-94,-37
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0
	db	-1,0,0,0

sultan_end::


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SULTAN.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



