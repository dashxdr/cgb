; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** RIDE.ASM                                                              **
; **                                                                       **
; ** Last modified : 990311 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"ride",CODE,BANK[6]
		section 6

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

ride_top::


PATTERNBLOCK	EQU	$d010
RNDSAVE		EQU	$d000
wRideSetLo	EQU	$d004
wRideSetHi	EQU	$d005
wRideSelectLo	EQU	$d006
wRideSelectHi	EQU	$d007
wRideSelMask	EQU	$d008
wRideSelNum	EQU	$d009

SFX_BELLEJUMP	EQU	17
SFX_BELLEWOLF	EQU	18
SFX_BELLEHIT	EQU	19
SFX_BELLEBAT	EQU	19
SONG_RIDE	EQU	4

BELLE_RUN	EQU	0
BELLE_JUMP	EQU	1
BELLE_FLOAT	EQU	2
BELLE_LAND	EQU	3
BELLE_WIN	EQU	4
BELLE_LOSE	EQU	5
BELLE_DUCK	EQU	6
BELLE_LANDDUCK	EQU	7

BELLE_Y		EQU	$6e
BELLE_X		EQU	$20
BELLE_XMIN	EQU	$20
BELLE_XMAX	EQU	$40

WOLF_Y		EQU	$79

BELLE_STARY	EQU	$48

;ride_flags
RIDEFLG_FIRST	EQU	0
RIDEFLG_OVER	EQU	1
RIDEFLG_FLICKER	EQU	2
RIDEFLG_CHANGED	EQU	3
RIDEFLG_DUST	EQU	4
RIDEFLG_DUCKHLD	EQU	5
RIDEFLG_STINC	EQU	6
RIDEFLG_SETUP	EQU	7

MIN_SPEED	EQU	5
MAX_SPEED	EQU	7
START_SPEED	EQU	5
LOSE_SPEED	EQU	0

STAGE_CYCLE	EQU	80
RIDE_STAGEY	EQU	40

BAT_CYCLE	EQU	100
WOLF_CYCLE	EQU	100
STAR_CYCLE	EQU	100
DUST_CYCLE	EQU	30
DUST_FLICKER	EQU	20
STAR_TOUCHLO	EQU	$2b
STAR_TOUCHHI	EQU	$45
WOLF_DANGERLO	EQU	$2b
WOLF_DANGERHI	EQU	$45
BAT_DANGERLO	EQU	$2b
BAT_DANGERHI	EQU	$3c

SAFEHEIGHT	EQU	24	;below this & you hit the wolf (8*lines)
DUCKHEIGHT	EQU	48	;above this & you hit the bat (8*lines)

ENDHOLD		EQU	35	;how many rows to hold before victory
FLOAT_MAX	EQU	2	;how many cycles of floating to allow
FLICKERTIME	EQU	30	;how long to hold flicker

JOY_JUMP	EQU	JOY_A
JOY_DUCK	EQU	JOY_D
JOY_DUCK2	EQU	JOY_B

ridergb:	incbin	"res/dave/ride/ride.rgb"
ridemap:	incbin	"res/dave/ride/ride.map"
ridegmbmap:	incbin	"res/dave/ride/ridegmb.map"

ride_topx	EQUS	"hTemp48+0"
ride_forestx	EQUS	"hTemp48+1"
ride_pathx	EQUS	"hTemp48+2"
ride_frac0	EQUS	"hTemp48+3"
ride_frac1	EQUS	"hTemp48+4"
ride_frac2	EQUS	"hTemp48+5"
ride_frame	EQUS	"hTemp48+6"

ride_hispace	EQUS	"hTemp48+7"
ride_hithing	EQUS	"hTemp48+8"
ride_hipntr	EQUS	"hTemp48+9" ;2 bytes
ride_himask	EQUS	"hTemp48+11" ;3 bytes

ride_mode	EQUS	"hTemp48+14"
ride_anim	EQUS	"hTemp48+15"
ride_bellefig	EQUS	"hTemp48+16"
ride_bellex	EQUS	"hTemp48+17"
ride_belley	EQUS	"hTemp48+18"
ride_stagepos	EQUS	"hTemp48+19"
ride_flags	EQUS	"hTemp48+20"
ride_jumpy	EQUS	"hTemp48+21"
ride_vely	EQUS	"hTemp48+22"
ride_speed	EQUS	"hTemp48+23"
ride_phase	EQUS	"hTemp48+24"
ride_pathlo	EQUS	"hTemp48+25"
ride_pathhi	EQUS	"hTemp48+26"
ride_endcnt	EQUS	"hTemp48+27"
ride_floating	EQUS	"hTemp48+28"
ride_errors	EQUS	"hTemp48+29"
ride_batframe	EQUS	"hTemp48+30"
ride_batspeed	EQUS	"hTemp48+31"
ride_batpos	EQUS	"hTemp48+32"
ride_wolfframe	EQUS	"hTemp48+33"
ride_wolfspeed	EQUS	"hTemp48+34"
ride_wolfpos	EQUS	"hTemp48+35"
ride_starpos	EQUS	"hTemp48+36"
ride_starframe	EQUS	"hTemp48+37"
ride_flickertime EQUS	"hTemp48+38"
ride_rnd	EQUS	"hTemp48+39"	;4 bytes
ride_scorelo	EQUS	"hTemp48+43"
ride_scorehi	EQUS	"hTemp48+44"



PAGE1		EQU	$e000-41*16*2
PAGE2		EQU	$e000-41*16*1

CUTOFF		EQU	244
STAGE		EQU	244
STAR		EQU	245
LOG		EQU	246
TRAP		EQU	247
ROCK		EQU	248
BAT1		EQU	249
BAT2		EQU	250
BAT3		EQU	251
WOLF1		EQU	252
WOLF2		EQU	253
WOLF3		EQU	254
FINISH		EQU	255

MODE_END	EQU	255

action_run:	db	0,1,2,3,4,5,6,7,MODE_END
action_jump:	db	16,MODE_END
action_float:	db	17,18,19,20,21,22,MODE_END
action_land:	db	18,19,20,21,22
		db	28,29,30,31,MODE_END
action_landduck:
		db	18,57,58,59,60,61,62,63,64,65,MODE_END

action_win:	db	34,35,36,37,38,39,40,41,42,43,44,45,46,47
		db	47,47,47,47,47,47,47,47,47
		db	MODE_END
action_lose:	db	47,48,49,50,51,52,53,54,55,56
		db	56,56,56,56,56,56,56,56,56,56
		db	MODE_END
action_duck:	db	8,9,10,11,12,13,14,15,MODE_END


bellemodes:	dw	action_run,mode_run
		dw	action_jump,mode_jump
		dw	action_float,mode_float
		dw	action_land,mode_land
		dw	action_win,mode_win
		dw	action_lose,mode_lose
		dw	action_duck,mode_duck
		dw	action_landduck,mode_landduck

BelleRide::

		ld	hl,wParallax0
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a

		ld	hl,ride_rnd
		call	random
		ld	[hli],a
		call	random
		ld	[hli],a
		call	random
		ld	[hli],a
		call	random
		ld	[hl],a


		ld	a,21
		ld	[ride_pathlo],a

		ld	a,BELLE_X
		ld	[ride_bellex],a
		ld	a,BELLE_Y
		ld	[ride_belley],a
		ld	a,START_SPEED
		ld	[ride_speed],a
		ld	a,BELLE_RUN
		ld	[ride_mode],a

		ld	a,[wSubGaston]
		or	a
		jr	nz,.nolives
		ld	a,[wSubLevel]
		cp	3
		ld	a,3
		jr	c,.aok
.nolives:	ld	a,1
.aok:		ldh	[ride_errors],a

		call	ride_setup

rideloop::	call	startsong
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jr	nz,.pause
		ld	a,[ride_speed]
		call	scrolltop
		ld	a,[ride_speed]
		add	a
		add	a
		call	scrollforest
		ld	a,[ride_speed]
		add	a
		add	a
		add	a
		call	scrollpath

		call	InitFigures64
		call	dobelle
		call	domoon
		call	dobat
		call	dowolf
		call	dostage
		call	dostar
		call	OutFigures
		call	checkcollision
		ld	hl,ride_flags
		bit	RIDEFLG_FIRST,[hl]
		jr	nz,.nofade
		set	RIDEFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:	ld	hl,ride_frame
		inc	[hl]
		ld	hl,ride_flags
		bit	RIDEFLG_OVER,[hl]
		jr	nz,rideover
		ld	a,16
		call	AccurateWait
		jr	rideloop
.pause:		call	ride_shutdown
		call	PauseMenu_B
		call	ride_setup
		jr	rideloop

rideover:	jp	ride_shutdown

dobat:		ld	hl,ride_batpos
		ld	a,[hl]
		or	a
		ret	z
		ld	a,[ride_batspeed]
		add	[hl]
		cp	BAT_CYCLE
		jr	nc,.batdone
		ld	[hl],a
		ld	hl,ride_batframe
		inc	[hl]
		ld	a,5*2
		cp	[hl]
		jr	nz,.noover
		ld	[hl],0
.noover:	ld	a,[hl]
		srl	a
		add	255&IDX_BAT
		ld	c,a
		ld	a,0
		adc	IDX_BAT>>8
		ld	b,a
		ldh	a,[ride_batpos]
		add	a
		ld	d,a
		ld	a,$a0
		sub	d
		ld	d,a
		ld	e,$55

		ld	a,[wGroup4]
		jp	AddFigure
.batdone:	ld	[hl],0
		ret

dostar:		ldh	a,[ride_starpos]
		or	a
		ret	z
		ld	hl,ride_starframe
		inc	[hl]
		ld	a,[hl]
		cp	8*2
		jr	c,.noover
		ld	[hl],0
.noover:	ldh	a,[ride_flags]
		bit	RIDEFLG_DUST,a
		jr	z,.nodust
		ldh	a,[ride_starpos]
		inc	a
		ldh	[ride_starpos],a
		cp	DUST_CYCLE
		jr	nc,.stardone
		cp	DUST_FLICKER
		jr	c,.noflicker
		srl	a
		ret	c
.noflicker:	ld	a,[hl]
		srl	a
		add	255&IDX_DUST
		ld	c,a
		ld	a,0
		adc	IDX_DUST>>8
		ld	b,a
		ldh	a,[ride_starpos]
		ld	e,a
		ld	a,BELLE_STARY
		sub	e
		ld	e,a
		ldh	a,[ride_bellex]
		ld	d,a
		ld	a,[wGroup6]
		jp	AddFigure
.nodust:	ldh	a,[ride_starpos]
		inc	a
		inc	a
		ldh	[ride_starpos],a
		cp	STAR_CYCLE
		jr	nc,.stardone
		ld	a,[hl]
		srl	a
		add	255&IDX_STAR
		ld	c,a
		ld	a,0
		adc	IDX_STAR>>8
		ld	b,a
		ldh	a,[ride_starpos]
		add	a
		ld	d,a
		ld	a,$a0
		sub	d
		ld	d,a
		ld	e,BELLE_STARY
		ld	a,[wGroup6]
		jp	AddFigure
.stardone:	xor	a
		ldh	[ride_starpos],a
		ld	hl,ride_flags
		res	RIDEFLG_DUST,[hl]
		ret

dowolf:		ld	hl,ride_wolfpos
		ld	a,[hl]
		or	a
		ret	z
		ld	a,[ride_wolfspeed]
		add	[hl]
		cp	WOLF_CYCLE
		jr	nc,.wolfdone
		ld	[hl],a
		ld	hl,ride_wolfframe
		inc	[hl]
		ld	a,8*2
		cp	[hl]
		jr	nz,.noover
		ld	[hl],0
.noover:	ld	a,[hl]
		srl	a
		add	255&IDX_WOLFX
		ld	c,a
		ld	a,0
		adc	IDX_WOLFX>>8
		ld	b,a
		ldh	a,[ride_wolfpos]
		add	a
		ld	d,a
		ld	a,$a0
		sub	d
		ld	d,a
		ld	e,WOLF_Y
		ld	a,[wGroup5]
		jp	AddFigure
.wolfdone:	ld	[hl],0
		ret

dostage:	ld	hl,ride_stagepos
		ld	a,[wGroup7]
		jp	StdStage

domoon:		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		ld	de,$2509
		ld	bc,IDX_MOON
		ld	a,[wGroup3]
		jp	AddFigure

checkcollision:
		ldh	a,[ride_errors]
		or	a
		ret	z
		ldh	a,[ride_bellex]
		sub	$30
		sra	a
		ld	c,a
		ldh	a,[ride_flags]
		bit	RIDEFLG_DUST,a
		jr	nz,.nostar
		ldh	a,[ride_starpos]
		or	a
		jr	z,.nostar
		add	c
		cp	STAR_TOUCHLO
		jr	c,.nostar
		cp	STAR_TOUCHHI
		jr	nc,.nostar
		ldh	a,[ride_jumpy]
		cp	SAFEHEIGHT
		jr	c,.nostar
		ld	a,SONG_GOTSTAR
		push	bc
		call	InitTune
		pop	bc
		ld	hl,wSubStars
		inc	[hl]
		ld	hl,ride_flags
		set	RIDEFLG_DUST,[hl]
		ld	a,1
		ldh	[ride_starpos],a
.nostar:
		ldh	a,[ride_flags]
		bit	RIDEFLG_FLICKER,a
		jp	nz,.flickering
		ld	hl,ride_himask
		ldh	a,[ride_wolfpos]
		or	a
		jr	z,.nowolf
		add	c
		cp	WOLF_DANGERLO
		jr	c,.nowolf
		cp	WOLF_DANGERHI
		jr	nc,.nowolf
		ldh	a,[ride_jumpy]
		cp	SAFEHEIGHT
		jr	nc,.nowolf
		ld	a,SFX_BELLEWOLF
		call	InitSfx
		ld	bc,$0101
		jr	.known
.nowolf:	ldh	a,[ride_batpos]
		add	c
		cp	BAT_DANGERLO
		jr	c,.nobat
		cp	BAT_DANGERHI
		jr	nc,.nobat
		ldh	a,[ride_mode]
		cp	BELLE_DUCK
		jr	z,.nobat
		cp	BELLE_LANDDUCK
		jr	nz,.bat
		ldh	a,[ride_jumpy]
		cp	DUCKHEIGHT
		jr	c,.nobat
.bat:		ld	a,SFX_BELLEBAT
		call	InitSfx
		ld	bc,$0101
		jr	.known
.nobat:
		inc	l
		ld	b,[hl]
		inc	l
		ld	c,[hl]
		dec	l
		ldh	a,[ride_bellex]
		srl	a
		srl	a
		srl	a
		inc	a
.rotlp:		rr	b
		rr	c
		dec	a
		jr	nz,.rotlp
		ld	a,c
		and	31
		ld	c,a
		and	30
		ld	b,a
		ld	hl,ride_flags
		jr	z,.known
		bit	RIDEFLG_FLICKER,[hl]
		jr	nz,.known
		ldh	a,[ride_jumpy]
		cp	SAFEHEIGHT
		jr	nc,.nohit
		ld	a,SFX_BELLEHIT
		push	bc
		call	InitSfx
		pop	bc
		jr	.known
.nohit:		ld	b,0
		ld	c,0
.known:		ld	a,b
		or	a
		ret	z
		call	declife
		ldh	a,[ride_errors]
		or	a
		ret	z
		ld	hl,ride_flags
		set	RIDEFLG_FLICKER,[hl]
		ld	a,FLICKERTIME
		ldh	[ride_flickertime],a
		ret
.flickering:	ldh	a,[ride_flickertime]
		or	a
		ret	nz
		ld	hl,ride_flags
		res	RIDEFLG_FLICKER,[hl]
		ret

dobelle:	ld	hl,ride_flickertime
		ld	a,[hl]
		or	a
		jr	z,.noft
		dec	[hl]
.noft:		ld	a,[ride_mode]
		add	a
		add	a
		ld	c,a
		ld	b,0
		ld	hl,bellemodes
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	a,[ride_anim]
		ld	c,a
		ld	h,d
		ld	l,e
		add	hl,bc
		ld	a,[hl]
		ret
mode_run:	cp	MODE_END
		jr	nz,.noend
		ld	c,0
.noend:		ldh	a,[ride_endcnt]
		cp	ENDHOLD
		jp	nc,victory
		ldh	a,[ride_errors]
		or	a
		jp	z,failure
		call	speedchange
		ld	a,[wJoy1Cur]
		bit	JOY_JUMP,a
		jr	z,.nojump
		ld	a,[ride_jumpy]
		or	a
		jr	nz,.nojump
		ld	a,SFX_BELLEJUMP
		call	InitSfx
		ld	c,0
		ld	a,BELLE_JUMP
		ld	[ride_mode],a
		ld	a,13
		ld	[ride_vely],a
		jr	.done_run
.nojump:	ld	a,[wJoy1Cur]
		bit	JOY_DUCK2,a
		jr	nz,.doduck
		bit	JOY_DUCK,a
		jr	z,.noduck
.doduck:	ld	c,0
		ld	a,BELLE_DUCK
		ld	[ride_mode],a
		ld	hl,ride_flags
		set	RIDEFLG_DUCKHLD,[hl]
		jr	.done_run
.noduck:
.done_run:	ld	a,[ride_speed]
		swap	a
		jp	modes_finish

failure:	ld	a,SONG_LOST
		call	InitTune
		ld	a,BELLE_LOSE
		ldh	[ride_mode],a
		ld	c,0
		ld	a,LOSE_SPEED
		ldh	[ride_speed],a
		jp	modes_finish

victory:	ld	a,SONG_WON
		call	InitTune
		ld	hl,wSubStage
		inc	[hl]
		ld	a,BELLE_WIN
		ldh	[ride_mode],a
		xor	a
		ldh	[ride_speed],a
		ld	c,a
		jp	modes_finish
mode_lose:
mode_win:	cp	MODE_END
		jr	nz,.done_win
		ld	hl,ride_flags
		dec	c
		set	RIDEFLG_OVER,[hl]
.done_win:	ld	a,$60
		jp	modes_finish

speedchange:	ld	a,[ride_frame]
		and	1
		ret	nz
		ld	hl,ride_bellex
		ld	a,[wJoy1Cur]
		bit	JOY_R,a
		jr	z,.nort
		ld	a,[hl]
		cp	BELLE_XMAX
		jr	z,.noincx
		inc	[hl]
		inc	[hl]
.noincx:	ld	a,[ride_speed]
		cp	MAX_SPEED
		jr	z,.noinc
		inc	a
.noinc:		ld	[ride_speed],a
.nort:		ld	a,[wJoy1Cur]
		bit	JOY_L,a
		jr	z,.nolf
		ld	a,[hl]
		cp	BELLE_XMIN
		jr	z,.nodecx
		dec	[hl]
		dec	[hl]
.nodecx:	ld	a,[ride_speed]
		cp	MIN_SPEED
		jr	z,.nodec
		dec	a
.nodec:		ld	[ride_speed],a
.nolf:		ret

mode_jump:	cp	MODE_END
		jr	nz,.done_jump
		ld	c,0
		ld	a,[wJoy1Cur]
		bit	JOY_JUMP,a
		ld	a,BELLE_FLOAT
;		jr	nz,.aok
;		ld	a,BELLE_LAND
.aok:		ld	[ride_mode],a
.done_jump:	call	speedchange
		ld	a,$40*2
		jp	modes_finish

mode_float:	ld	hl,ride_floating
		cp	MODE_END
		jr	nz,.noreset
		ld	c,0
		inc	[hl]
		ld	a,[hl]
		cp	FLOAT_MAX
		jr	z,.endfloat
.noreset:	ld	hl,ride_floating
		ld	a,[wJoy1Cur]
		bit	JOY_JUMP,a
		jr	nz,.continuefloat
.endfloat:	ld	a,BELLE_LAND
		ld	[ride_mode],a
		ld	c,0
		ld	[hl],c
		jr	.done_float
.continuefloat:	jr	.done_float
.done_float:	call	speedchange
		ld	a,[ride_vely]
		cp	$80
		jr	c,.goingup
		xor	a
.goingup:	ld	[ride_vely],a
		ld	a,$40*2
		jp	modes_finish
mode_land:	cp	MODE_END
		jr	nz,.done_land
		ld	hl,ride_flags
		res	RIDEFLG_CHANGED,[hl]
		ld	c,0
		ld	a,BELLE_RUN
		ldh	[ride_mode],a
		jr	.ended
.done_land:	call	speedchange
		ld	a,[wJoy1Cur]
		bit	JOY_DUCK2,a
		jr	nz,.landduck
		bit	JOY_DUCK,a
		jr	z,.ended
.landduck:	ld	a,BELLE_LANDDUCK
		ld	[ride_mode],a
.ended:		ld	a,$40*2
		jp	modes_finish
		

mode_landduck:	cp	MODE_END
		jr	nz,.done_landduck
		ld	hl,ride_flags
		res	RIDEFLG_CHANGED,[hl]
		ld	c,0
		ld	a,BELLE_DUCK
		ldh	[ride_mode],a
		jr	.ended
.done_landduck:	call	speedchange
.ended:		ld	a,$40*2
		jp	modes_finish

mode_duck:	ld	hl,ride_flags
		cp	MODE_END
		jr	nz,.ducknoend
		ld	c,0
		res	RIDEFLG_DUCKHLD,[hl]
.ducknoend:
		ldh	a,[ride_endcnt]
		cp	ENDHOLD
		jp	nc,victory

		bit	RIDEFLG_DUCKHLD,[hl]
		jr	nz,.done_duck
		ld	a,[wJoy1Cur]
		bit	JOY_DUCK2,a
		jr	nz,.done_duck
		bit	JOY_DUCK,a
		jr	nz,.done_duck
		ld	a,BELLE_RUN
		ld	[ride_mode],a
.done_duck:	ldh	a,[ride_errors]
		or	a
		jp	z,failure
		call	speedchange
		ld	a,$40*2
		jp	modes_finish


;a=phase change
modes_finish:	push	af
		ld	hl,ride_vely
		ld	a,[hl]
		dec	[hl]
		ld	hl,ride_jumpy
		bit	7,a
		jr	z,.pos
		cpl
		inc	a
		ld	e,a
		ld	a,[hl]
		sub	e
		jr	nc,.neg
		xor	a
		ld	[ride_vely],a
		jr	.neg
.pos:		add	[hl]
.neg:		ld	[hl],a

		ld	a,[ride_mode]
		add	a
		add	a
		ld	e,a
		ld	d,b
		ld	hl,bellemodes
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
;		ld	a,c
;		ld	[ride_anim],a
		add	hl,bc
		ld	a,[hl]
		ld	[ride_bellefig],a
		pop	de
		ld	a,[ride_phase]
		add	d
		ld	[ride_phase],a
		jr	nc,.noinc
		inc	c
.noinc:		ld	a,c
		ld	[ride_anim],a
		ld	a,[ride_jumpy]
		srl	a
		srl	a
		srl	a
		ld	c,a
		ld	a,[ride_bellex]
		ld	d,a
		ldh	a,[ride_belley]
		sub	c
		ld	e,a
		ldh	a,[ride_flags]
		bit	RIDEFLG_FLICKER,a
		jr	z,.noflicker
		ldh	a,[ride_frame]
		rr	a
		jr	c,.flicker
.noflicker:	ld	a,[ride_bellefig]
		add	255&IDX_BELLHRS2
		ld	c,a
		ld	a,0
		adc	IDX_BELLHRS2>>8
		ld	b,a
		ld	a,[wGroup1]
		push	de
		call	AddFigure
		ld	a,[ride_bellefig]
		add	255&IDX_PHILIP
		ld	c,a
		ld	a,0
		adc	IDX_PHILIP>>8
		ld	b,a
		pop	de
		ld	a,[wGroup2]
		call	AddFigure
.flicker:	ret


scrolltop:	ld	hl,ride_frac0
		add	[hl]
		ld	b,a
		and	$0f
		ld	[hl],a
		xor	b
		swap	a
		ld	hl,wParallax0
		ld	b,[hl]
		add	[hl]
		ld	[hl],a
		xor	b
		and	$f8
		ret	z
newtop:		ld	a,[ride_topx]
		ld	l,a
		inc	a
		cp	20
		jr	c,.aok
		xor	a
.aok:		ld	[ride_topx],a
		ld	h,0
		ld	b,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	de,PAGE1+12+20*16
		add	hl,de
		ld	d,h
		ld	e,l
		ld	a,[wParallax0]
		add	160
		srl	a
		srl	a
		srl	a
		ld	c,a
		ld	hl,$9800
		add	hl,bc
		jp	copycol2

scrollforest:	ld	hl,ride_frac1
		add	[hl]
		ld	b,a
		and	$0f
		ld	[hl],a
		xor	b
		swap	a
		ld	hl,wParallax1
		ld	b,[hl]
		add	[hl]
		ld	[hl],a
		xor	b
		and	$f8
		ret	z
newforest:	ld	a,[ride_forestx]
		ld	l,a
		inc	a
		cp	40
		jr	c,.aok
		xor	a
.aok:		ld	[ride_forestx],a
		ld	h,0
		ld	b,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	de,PAGE1
		add	hl,de
		ld	d,h
		ld	e,l
		ld	a,[wParallax1]
		add	160
		srl	a
		srl	a
		srl	a
		ld	c,a
		ld	hl,$9800+$20*2
		add	hl,bc
		push	de
		push	hl
		call	copycol4
		pop	hl
		pop	de
		inc	de
		inc	de
		inc	de
		inc	de
		ld	bc,$20*4
		add	hl,bc
		push	de
		push	hl
		call	copycol4
		pop	hl
		pop	de
		inc	de
		inc	de
		inc	de
		inc	de
		ld	bc,$20*4
		add	hl,bc
		jp	copycol4
scrollpath:	ld	hl,ride_frac2
		add	[hl]
		ld	b,a
		and	$0f
		ld	[hl],a
		xor	b
		swap	a
		ld	hl,wParallax2
		ld	b,[hl]
		add	[hl]
		ld	[hl],a
		xor	b
		and	$f8
		ret	z
newpath:	ld	a,[ride_pathx]
		ld	l,a
		inc	a
		cp	20
		jr	c,.aok
		xor	a
.aok:		ld	[ride_pathx],a
		ld	h,0
		ld	b,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	de,PAGE1+12
		add	hl,de
		ld	d,h
		ld	e,l
		ld	a,[wParallax2]
		add	160
		srl	a
		srl	a
		srl	a
		ld	c,a
		ld	hl,$9800+$20*14
		add	hl,bc
		push	hl
		call	copycol4
		ld	hl,ride_hispace
		call	step
		or	a
		jr	z,.noupper
		cp	CUTOFF
		jr	c,.nowolfbat1
		ld	e,a
		ldh	a,[ride_flags]
		bit	RIDEFLG_SETUP,a
		jr	nz,.noupper
		ld	a,e
		ld	e,BELLE_Y
		call	triggerspecial
		jr	.noupper
.nowolfbat1:	ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	bc,PAGE1+14+19*$10
		add	hl,bc
		ld	d,h
		ld	e,l
		pop	hl
		ld	bc,$20
		add	hl,bc
		push	hl
		call	copycol2
.noupper:	pop	hl
		call	checkdone
		ld	hl,ride_pathlo
		inc	[hl]
		jr	nz,.nocarry
		inc	l
		inc	[hl]
		dec	l
.nocarry:	call	IncScore
;		ld	a,[hli]
;		sub	20
;		ld	[wScoreLo],a
;		ld	a,[hl]
;		sbc	0
;		ld	[wScoreHi],a

		ret
obremap:	db	0,2,3,4,5,6,7,0,9,10,11,0,13,14,15,16,17,18,19,20,21,0

convmap:	ld	b,41
.convmapx:	ld	c,16
		push	hl
.convmapy:	ld	a,[hl]
		ld	[de],a
		inc	de
		ld	a,41*2
		call	addahl
		dec	c
		jr	nz,.convmapy
		pop	hl
		inc	hl
		inc	hl
		dec	b
		jr	nz,.convmapx
		ret


;e=y of this row
;a=# to trigger (BAT1-3 or WOLF1-3)
triggerspecial:	cp	BAT1
		jr	c,.nobat
		cp	BAT1+3
		jr	nc,.nobat
		sub	BAT1-1
		ldh	[ride_batspeed],a
		ld	a,1
		ldh	[ride_batpos],a
		ret
.nobat:		cp	WOLF1
		jr	c,.nowolf
		cp	WOLF1+3
		jr	nc,.nowolf
		sub	WOLF1-1
		ldh	[ride_wolfspeed],a
		ld	a,1
		ldh	[ride_wolfpos],a
		ret
.nowolf:	cp	STAR
		jr	nz,.nostar
		ld	a,1
		ldh	[ride_starpos],a
		ld	hl,ride_flags
		res	RIDEFLG_DUST,[hl]
		ret
.nostar:	cp	STAGE
		jr	nz,.nostage
		ld	a,[wSubLevel]
		cp	3
		jr	nc,.nostage
		ld	a,1
		ldh	[ride_stagepos],a
		ld	hl,ride_flags
		ld	a,[hl]
		set	RIDEFLG_STINC,[hl]
		cp	[hl]
		ret	nz
		ld	hl,wSubStage
		inc	[hl]
		ret
.nostage:	ret



;de=src in PAGE1
;hl=dest
copycol2:	push	hl
		push	de
		call	col2sync
		pop	de
		ld	hl,PAGE2-PAGE1
		add	hl,de
		ld	d,h
		ld	e,l
		pop	hl
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		call	col2sync
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret
col2sync:
		ldh	a,[hCutoff]
		ld	b,a
		ldio	a,[rLY]
		dec	a
		cp	139 ;142
		jr	nc,col2sync
		cp	b
		jr	nc,col2sync

		di
.sync0:		LDIO	A,[rSTAT]
		AND	%11
		JR	Z,.sync0
.sync1:		LDIO	A,[rSTAT]
		AND	%11
		JR	NZ,.sync1
		ld	a,[de]
		ld	[hl],a
		ld	bc,32
		add	hl,bc
		inc	e
		ld	a,[de]
		ld	[hl],a
		add	hl,bc
		ei
		ret
;de=src in PAGE1
;hl=dest
copycol4:	ld	bc,32
		push	hl
		push	de
		call	col4sync
		pop	de
		ld	hl,PAGE2-PAGE1
		add	hl,de
		ld	d,h
		ld	e,l
		pop	hl
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		call	col4sync
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret
col4sync:
		ldh	a,[hCutoff]
		ld	b,a
		ldio	a,[rLY]
		dec	a
		cp	139 ;142
		jr	nc,col4sync
		cp	b
		jr	nc,col4sync

		di
.sync0:		LDIO	A,[rSTAT]
		AND	%11
		JR	Z,.sync0
.sync1:		LDIO	A,[rSTAT]
		AND	%11
		JR	NZ,.sync1
		ld	a,[de]
		ld	[hl],a
		ld	bc,32
		add	hl,bc
		inc	e
		ld	a,[de]
		ld	[hl],a
		add	hl,bc
		inc	e
		ld	a,[de]
		ld	[hl],a
		add	hl,bc
		inc	e
		ld	a,[de]
		ld	[hl],a
		add	hl,bc
		ei
		ret

;de=list
;hl=ride_hispace or ride_lospace
initsequence:
;		ld	a,20
		xor	a
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],e
		inc	hl
		ld	[hl],d
		ret

stephandlers:	dw	ridespecial	;STAGE
		dw	ridespecial	;STAR
		dw	ridelog		;LOG
		dw	ridetrap	;TRAP
		dw	riderock	;ROCK
		dw	ridespecial	;BAT1
		dw	ridespecial	;BAT2
		dw	ridespecial	;BAT3
		dw	ridespecial	;WOLF1
		dw	ridespecial	;WOLF2
		dw	ridespecial	;WOLF3

;hl=ride_hispace or ride_lospace
step:		push	hl
		ld	a,[hl]
		or	a
		jr	nz,rideinspace
		inc	hl
		ld	a,[hl]
		or	a
		jr	nz,rideinthing
		inc	hl
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		ld	a,[de]
		cp	FINISH
		jr	z,rideret0
		inc	de
		ld	[hl],d
		dec	hl
		ld	[hl],e
		dec	hl
		cp	CUTOFF
		jr	c,setspace
		ld	d,a
		sub	CUTOFF
		add	a
		ld	bc,stephandlers
		add	c
		ld	c,a
		ld	a,b
		adc	0
		ld	b,a
		ld	a,[bc]
		ld	e,a
		inc	bc
		ld	a,[bc]
		ld	b,a
		ld	c,e
		push	bc
		ret
setspace:	dec	hl
		dec	a
		ld	[hl],a
		jr	rideret0
riderock:	ld	a,1
		jr	ridepick
ridetrap:	ld	a,8
		jr	ridepick
ridelog:	ld	a,12
		jr	ridepick
ridespecial:	ld	a,d
		jr	ridedone
rideinthing:	add	LOW(obremap)
		ld	e,a
		ld	a,0
		adc	HIGH(obremap)
		ld	d,a
		ld	a,[de]
		or	a
		jr	nz,ridepick
		ld	[hl],a
		pop	hl
		jr	step
ridepick:	ld	[hl],a
		jr	ridedone
rideinspace:	dec	[hl]
rideret0:	xor	a
ridedone:	pop	hl
		inc	l
		inc	l
		inc	l
		inc	l
		or	a
		ld	d,0
		jr	z,.dok
		cp	CUTOFF
		jr	nc,.dok
		inc	d
.dok:		rr	d
		rr	[hl]
		inc	l
		rr	[hl]
		inc	l
		rr	[hl]
		ret

checkdone:	ld	hl,ride_hispace
		ld	a,[hli]
		or	[hl]
		jr	nz,.notdone
		inc	l
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hl]
		cp	FINISH
		jr	nz,.notdone
		ld	hl,ride_endcnt
		inc	[hl]
.notdone:	ldh	a,[ride_endcnt]
		ret

ride_shutdown:	call	FadeOut
		xor	a
		call	InitTune
		di
		SETVBL	VblNormal	;restore vectors so John's 8 bit
		SETLYC	LycNormal	;vector writing doesn't get wrecked.
		ld	a,255
		ldio	[rLYC],a
		ei
		ld	a,140+5
		call	wJmpSprDumpMod
		xor	a
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a
		dec	a
		ldh	[hPosFlag],a
		call	SprOff
		ld	a,[ride_topx]
		sub	1
		jr	nc,.aok1
		add	20
.aok1:		ld	[ride_topx],a
		ld	a,[ride_forestx]
		sub	21
		jr	nc,.aok2
		add	40
.aok2:		ld	[ride_forestx],a
		ld	a,[ride_pathx]
		sub	1
		jr	nc,.aok3
		add	20
.aok3:		ld	[ride_pathx],a
		ld	a,192
		call	wJmpSprDumpMod

		ret

startsong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_RIDE
		jp	InitTunePref

ride_setup:
		ld	a,[wScoreLo]
		ldh	[ride_scorelo],a
		ld	a,[wScoreHi]
		ldh	[ride_scorehi],a

		ld	hl,ride_flags
		set	RIDEFLG_SETUP,[hl]
		call	startsong

		ld	a,255
		ldh	[hCutoff],a

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jp	nz,.setupgmb
		ld	hl,IDX_RIDE0PKG	;ride0pkg
		ld	de,$d000
		call	SwdInFileSys
		ld	hl,$d000
		ld	de,$9000
		ld	c,128
		call	DumpChrs
		ld	de,$8800
		ld	c,128
		call	DumpChrs
		ld	hl,IDX_RIDE1PKG	;ride1pkg
		ld	de,$d000
		call	SwdInFileSys
		ld	hl,$d000
		ld	de,$8000
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	de,$9000
		ld	c,128
		call	DumpChrs
		ld	de,$8800
		ld	c,128
		call	DumpChrs
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		ld	de,wBcpArcade
		ld	hl,ridergb
		ld	bc,64
		call	MemCopy
		LD	A,WRKBANK_NRM
		LDH	[hWrkBank],A
		LDIO	[rSVBK],A
		ld	hl,ridemap+8
		ld	de,PAGE1
		call	convmap
		ld	hl,ridemap+9
		call	convmap
		ld	hl,PAGE2+20*16+12
		ld	de,16-1
		ld	c,20
.fixmountains:	set	7,[hl]
		inc	hl
		set	7,[hl]
		add	hl,de
		dec	c
		jr	nz,.fixmountains
		jr	.setupcgb
.setupgmb:
		ld	hl,IDX_RIDEGMBCHR	;ridegmbchr
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$9000
		ld	c,128
		call	DumpChrs
		ld	de,$8800
		ld	c,128
		call	DumpChrs
		ld	hl,ridegmbmap+8
		ld	de,PAGE1
		call	convmap
.setupcgb:

		call	InitGroups
		ld	hl,PAL_BELLHRS2
		call	AddPalette
		ld	[wGroup1],a	;Belle on horse
		ld	hl,PAL_PHILIP
		call	AddPalette
		ld	[wGroup2],a	;Philip the horse
		ld	hl,PAL_MOON
		call	AddPalette
		ld	[wGroup3],a	;Moon
		ld	hl,PAL_BAT
		call	AddPalette
		ld	[wGroup4],a	;Bat
		ld	hl,PAL_WOLFX
		call	AddPalette
		ld	[wGroup5],a
		ld	hl,PAL_STAR
		call	AddPalette
		ld	[wGroup6],a
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup7],a

		ld	hl,wParallax0
		ld	b,168
		ld	a,[hl]
		sub	b
		ld	[hli],a
		ld	a,[hl]
		sub	b
		ld	[hli],a
		ld	a,[hl]
		sub	b
		ld	[hli],a

		call	buildpattern

		ld	de,PATTERNBLOCK
		ld	hl,ride_hispace
		call	initsequence

		ld	hl,ride_pathlo
		ld	a,[hl]
		sub	21
		ld	[hli],a
		ld	c,a
		ld	a,[hl]
		sbc	0
		ld	[hl],a
		ld	b,a

.stepout:	ld	a,b
		or	c
		jr	z,.stepped
		push	bc
		ld	hl,ride_hispace
		call	step
		pop	bc
		dec	bc
		jr	.stepout
.stepped:	ld	c,21
.fillup:	push	bc
		ld	a,128
		call	scrolltop
		ld	a,128
		call	scrollforest
		ld	a,128
		call	scrollpath
		pop	bc
		dec	c
		jr	nz,.fillup
		di
		SETVBL	RideVector0
		ei
		ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,ride_flags
		res	RIDEFLG_FIRST,[hl]
		res	RIDEFLG_SETUP,[hl]
		call	drawpanel

		ldh	a,[ride_scorelo]
		ld	[wScoreLo],a
		ldh	a,[ride_scorehi]
		ld	[wScoreHi],a

		ret

whichstar:	ld	b,0
.cnt:		ld	a,[hli]
		cp	STAR
		jr	nz,.noinc
		inc	b
.noinc:		cp	FINISH
		jr	nz,.cnt
		ld	a,b
		or	a
		ret	z
.pick:		call	random
		and	15
		cp	b
		jr	nc,.pick
		inc	a
		ret


drawpanel:
		ld	de,$9800+19+18*$20
		ldh	a,[ride_errors]
		ld	c,a
		ld	b,0
.life:		inc	b
		ld	a,b
		cp	c
		ld	a,3
		jr	nc,.aok
		xor	a
.aok:		call	botpanel
		dec	e
		ld	a,b
		cp	5
		jr	c,.life
		ld	c,15
.left:		ld	a,3
		call	botpanel
		dec	e
		dec	c
		jr	nz,.left
		ret

declife:	ldh	a,[ride_errors]
		or	a
		ret	z
		dec	a
		ld	[ride_errors],a
		or	a
		ret	z
		dec	a
		ld	de,$9800+19+18*$20
		sub	e
		cpl
		inc	a
		ld	e,a
		ld	a,3
		jp	botpanel



		ld	de,$9800+$20*18
.btlp:		ld	a,e
		and	3
		call	botpanel
		inc	e
		ld	a,e
		and	$1f
		jr	nz,.btlp
		ret

;de=where to put char
;a=which column to put
;preserves bc
botpanel:	push	bc
		ld	hl,PAGE1+40*16
		call	addahl
		call	map1
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.notcgb
		ld	bc,PAGE2-PAGE1
		add	hl,bc
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		call	map1
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A
.notcgb:	pop	bc
		ret
map1:
map1sync:
		ldh	a,[hCutoff]
		ld	b,a
		ldio	a,[rLY]
		dec	a
		cp	139 ;142
		jr	nc,map1sync
		cp	b
		jr	nc,map1sync
		di
.sync0:		LDIO	A,[rSTAT]
		AND	%11
		JR	Z,.sync0
.sync1:		LDIO	A,[rSTAT]
		AND	%11
		JR	NZ,.sync1
		ld	a,[hl]
		ld	[de],a
		ei
		ret


buildpattern:	ld	hl,ride_rnd
		ld	de,RNDSAVE
		ld	bc,4
		call	MemCopy


		ld	a,[wSubLevel]
		ld	b,a
		swap	a
		add	b
		add	b
		ld	hl,ridedata
		call	addahl
		ld	a,[wSubGaston]
		or	a
		ld	a,0
		jr	nz,.nostar
		ld	a,[wSubLevel]
		cp	3
		ld	a,0
		jr	nc,.nostar
		push	hl
		ld	bc,4
		add	hl,bc
		ld	c,6
		ld	a,[hl]
		add	hl,bc
		add	[hl]
		add	hl,bc
		add	[hl]
		srl	a
		ld	c,a
.pickstar:	call	ridernd
		cp	c
		jr	nc,.pickstar
		srl	c
		add	c
		pop	hl
.nostar:	ldh	[hTmpHi],a

		ld	de,PATTERNBLOCK
		ld	a,21
		ld	[de],a
		inc	de

		ld	a,[wSubGaston]
		or	a
		jr	nz,.yesgaston
		call	buildpattern1
		call	buildpattern1
.yesgaston:	call	buildpattern1

		ld	a,FINISH
		ld	[de],a

		ld	de,ride_rnd
		ld	hl,RNDSAVE
		ld	bc,4
		jp	MemCopy

buildpattern1:	ld	a,STAGE
		ld	[de],a
		inc	de
		ld	a,20
		ld	[de],a
		inc	de
buildpattern2:
		ld	a,[hli]
		ld	[wRideSetLo],a
		ld	a,[hli]
		ld	[wRideSetHi],a
		ld	a,[hli]
		ld	[wRideSelectLo],a
		ld	c,a
		ld	a,[hli]
		ld	[wRideSelectHi],a
		ld	b,a
		ld	a,[hli]
		ldh	[hTmpLo],a
		inc	hl
		push	hl
		ld	l,-1
.cnt1:		inc	l
		ld	a,[bc]
		inc	bc
		or	a
		jr	nz,.cnt1
		ld	a,1
.rleft:		add	a
		cp	l
		jr	c,.rleft
		dec	a
		ld	[wRideSelMask],a
		ld	a,l
		ld	[wRideSelNum],a

.bp1lp:		ldh	a,[hTmpHi]
		dec	a
		ldh	[hTmpHi],a
		jr	nz,.nostar
		ld	a,10
		ld	[de],a
		inc	de
		ld	a,STAR
		ld	[de],a
		inc	de
		ld	a,10
		ld	[de],a
		inc	de
.nostar:	ldh	a,[hTmpLo]
		or	a
		jr	z,.bp1done
		dec	a
		ldh	[hTmpLo],a
		ld	a,[wRideSelNum]
		ld	c,a
		ld	a,[wRideSelMask]
		ld	b,a
.select:	call	ridernd
		and	b
		cp	c
		jr	nc,.select
		ld	c,a
		ld	b,0
		ld	hl,wRideSelectLo
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		add	hl,bc
		ld	c,[hl]
		dec	c
		ld	hl,wRideSetLo
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
.cpy:		ld	a,[hli]
		cp	FINISH
		jr	z,.cpied
		ld	[de],a
		inc	de
		jr	.cpy
.cpied:		jr	.bp1lp
.bp1done:	pop	hl
		ret


ridernd:	push	bc
		ld	c,8
.rrlp:		ldh	a,[ride_rnd+3]
		ld	b,a
		add	a
		add	a
		add	a
		xor	b
		add	a
		ldh	a,[ride_rnd]
		rl	a
		ldh	[ride_rnd],a
		ldh	a,[ride_rnd+1]
		rl	a
		ldh	[ride_rnd+1],a
		ldh	a,[ride_rnd+2]
		rl	a
		ldh	[ride_rnd+2],a
		ldh	a,[ride_rnd+3]
		rl	a
		ldh	[ride_rnd+3],a
		dec	c
		jr	nz,.rrlp
		pop	bc
		ret

select4:
		db	01,02,03,04,05,06,07,08,09,10
		db	11,12,13,14,15,16,17,18,19,20
		db	21,22,23,24,25,26,27,28,29,30
		db	31,32,33,34,35,36,37,38,39,40
		db	41,42,43,44,45,46,47,48,49,50
		db	51,52,53,54,55,56,57,58,59,60
		db	61,62,63,64,65,66,67,68,69,70
		db	71,72,73,74,75,76,77,78,79,80
		db	81,82,83,84,85,86,87,88,89,90
		db	91,92,93,94,95,96,97,98,99,99
		db	0

select3:
		db	01,02,03,04,05,06,07,08,09,99
		db	99,12,13,14,15,16,17,18,19,20
		db	21,22,23,24,25,26,27,28,29,30
		db	31,32,33,34,35,36,37,38,39,40
		db	41,42,43,44,45,46,47,48,49,50
		db	51,52,53,54,55,56,57,58,59,60
		db	61,62,63,64,65,66,67,68,69,70
		db	71,72,73,74,75,76,77,78,79,80
		db	81,82,83,84,85,86,87,88,89,90
		db	91,92,93,94,95,96,97,98,99,99
		db	0

select2:
		db	01,02,99,04,05,99,07,08,99,99
		db	99,12,13,14,15,99,99,18,19,20
		db	21,99,99,24,25,26,27,28,29,99
		db	99,99,33,34,35,36,37,38,39,40
		db	41,42,43,44,99,99,99,99,99,99
		db	51,52,53,54,55,56,57,58,59,60
		db	61,62,99,99,99,99,99,99,69,70
		db	71,72,73,74,75,76,77,78,79,80
		db	81,82,83,84,85,86,87,88,89,90
		db	91,92,93,94,95,96,97,98,99,99
		db	0

select1:
		db	01,99,01,04,99,01,07,99,01,99
		db	01,12,13,99,01,99,01,18,19,99
		db	01,99,01,24,25,26,99,01,99,01
		db	99,01,33,34,35,36,37,38,99,01
		db	51,52,53,54,55,56,69,70,99,01
		db	71,72,73,74,75,76,77,78,79,80
		db	81,82,83,84,85,86,87,88,89,90
		db	91,92,93,94,95,96,97,98,99,99
		db	0


ridedata:
		dw	rideeasy,select1,4 	;easy stage 0
		dw	rideeasy,select2,5 	;easy stage 1
		dw	rideeasy,select3,6 	;easy stage 2
		dw	ridemed,select1,5 	;med  stage 0
		dw	ridemed,select2,6 	;med  stage 1
		dw	ridemed,select3,7 	;med  stage 2
		dw	ridehard,select1,6 	;hard stage 0
		dw	ridehard,select2,7 	;hard stage 1
		dw	ridehard,select3,8 	;hard stage 2
		dw	ridemed,select1,127	;spcl1 stage 0
		dw	ridemed,select2,127	;spcl1 stage 1
		dw	ridemed,select3,127	;spcl1 stage 2
		dw	ridespcl,select4,127	;spcl2 stage 0
		dw	ridespcl,select4,127	;spcl2 stage 1
		dw	ridespcl,select4,127	;spcl2 stage 2

		include	"res/dave/ride/ridetrg2.asm"

ride_end::


