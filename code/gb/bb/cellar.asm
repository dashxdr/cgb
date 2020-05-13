; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** CELLAR.ASM                                                              **
; **                                                                       **
; ** Last modified : 990507 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"cellar",CODE,BANK[6]
		section 6

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

cellar_top::



SONG_CELLAR	EQU	12
SFX_WATERVAPOR	EQU	63
SFX_WATERDRIP	EQU	64
SFX_WATERSPLASH	EQU	65

SPECIALFLAMEINC1 EQU	25
SPECIALFLAMEDEC1 EQU	2
SPECIALGRAVITY1 EQU	4
SPECIALCYCLE1	EQU	15

SPECIALFLAMEINC2 EQU	25
SPECIALFLAMEDEC2 EQU	2
SPECIALGRAVITY2	EQU	5
SPECIALCYCLE2	EQU	15


DUSTTIME	EQU	50
DUSTFLICKER	EQU	35


FLAMESIZE	EQU	20 	;more = bigger flame collision area
R		EQU	16	;random
P		EQU	17	;Pause

AUTOREPEAT	EQU	4


MAPSIZE		EQU	18*$20
CELLARMAP	EQU	$e000-MAPSIZE*4
CELLARATTR	EQU	$e000-MAPSIZE*3
MAPCOPY		EQU	$e000-MAPSIZE*2
ATTRCOPY	EQU	$e000-MAPSIZE*1


CELLARXSCROLL	EQU	$CF00
DRIPLEVELS	EQU	$d100
DRIPTYPES	EQU	$d100+32

LUMY1		EQU	144-80
LUMY2		EQU	144-88


CANDLEY1	EQU	LUMY1+30
CANDLEY2	EQU	LUMY2+30
CANDLEX		EQU	8

DRIPBASE	EQU	118

GLUBY		EQU	CANDLEY2+16
GLUBX		EQU	CANDLEX+14-2


MAXDRIPS	EQU	6
MAXDEPTH	EQU	6

;drip structure
;byte 0:
;  bits 3-7 = xpos
;  bits 0-2 = mode
;byte 1:
;  counter based on mode
;byte 2:
;  y pos



cellar_flags	EQUS	"hTemp48+00"
cellar_phase	EQUS	"hTemp48+01"
cellar_lumpos	EQUS	"hTemp48+02"
cellar_drip	EQUS	"hTemp48+03"
cellar_drips	EQUS	"hTemp48+04"	;6*3 bytes/drip
cellar_gravity	EQUS	"hTemp48+22"
cellar_depth	EQUS	"hTemp48+23"
cellar_candle1	EQUS	"hTemp48+24"
cellar_candle2	EQUS	"hTemp48+25"
cellar_candle3	EQUS	"hTemp48+26"
cellar_glub1	EQUS	"hTemp48+27"
cellar_glub2	EQUS	"hTemp48+28"
cellar_glub3	EQUS	"hTemp48+29"
cellar_endcnt	EQUS	"hTemp48+30"
cellar_seqtake	EQUS	"hTemp48+31"
cellar_seqtake2	EQUS	"hTemp48+33"
cellar_steptime	EQUS	"hTemp48+35"
cellar_timecnt	EQUS	"hTemp48+36"
cellar_stagepos	EQUS	"hTemp48+37"
cellar_inccnt	EQUS	"hTemp48+38"
cellar_incmax	EQUS	"hTemp48+39"
cellar_repeat	EQUS	"hTemp48+40"
cellar_damage	EQUS	"hTemp48+41"
cellar_busy	EQUS	"hTemp48+42"
cellar_bonuspos	EQUS	"hTemp48+43"
cellar_bonuscnt	EQUS	"hTemp48+44"
cellar_bonusgo	EQUS	"hTemp48+45"

CELLARFLG_FIRST	EQU	0
CELLARFLG_DONE	EQU	1
CELLARFLG_WON	EQU	2
CELLARFLG_DUST	EQU	3
CELLARFLG_STAR	EQU	4

ENDHOLDDIED	EQU	100	;200
ENDHOLDLIVED	EQU	100
BUBBLESTOP	EQU	80

Cellar::
		ld	a,3
		ldh	[cellar_gravity],a
		ld	a,10
		ldh	[cellar_candle1],a
		ldh	[cellar_candle2],a
		ldh	[cellar_candle3],a

		call	newcellarstage

		call	random
		and	15
		add	4
		ldh	[cellar_bonusgo],a

		ld	a,[wSubGaston]
		or	a
		jr	z,.nogaston
		ld	a,MAXDEPTH-3
		ldh	[cellar_depth],a
.nogaston:
		call	cellar_setup


cellarloop:	call	cellarsong
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,cellarpause
		ldh	a,[cellar_flags]
		bit	CELLARFLG_DONE,a
		jr	z,.notdone
		ld	b,ENDHOLDDIED
		bit	CELLARFLG_WON,a
		jr	z,.bok
		ld	b,ENDHOLDLIVED
.bok:		ld	hl,cellar_endcnt
		inc	[hl]
		ld	a,[hl]
		cp	b	;ENDHOLD
		jp	z,cellardone
.notdone:	call	dolumiere
		call	makedepth
		ldh	a,[cellar_stagepos]
		or	a
		jr	nz,.notake
		ldh	a,[cellar_flags]
		bit	CELLARFLG_DONE,a
		jr	nz,.notake
		call	cellartake
.notake:
		call	cellarinit

		call	putlumiere
		call	tryglubs

		call	incflames
		call	decflames
		call	trycellarstar

		call	InitFigures64
		call	cellarstage
		call	doglubs
		call	dodrips
		call	docandles
		call	cellarstar
		call	OutFigures

		call	cellarcopy
		call	cellarflip
		ld	hl,cellar_flags
		bit	CELLARFLG_FIRST,[hl]
		jr	z,.nofade
		res	CELLARFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:
		call	makexscroll
		ld	a,16
		call	AccurateWait
		xor	a
		ldh	[hVbl8],a
		jp	cellarloop

cellarsong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ldh	a,[cellar_flags]
		bit	CELLARFLG_DONE,a
		ret	nz
		ld	a,SONG_CELLAR
		jp	InitTunePref


cellarpause:	call	cellar_shutdown
		call	PauseMenu_B
		call	cellar_setup
		jp	cellarloop

cellardone:	call	cellar_shutdown
		ret


cellarinit:	ld	hl,CELLARMAP
		ld	de,MAPCOPY
		ld	bc,MAPSIZE*2
		jp	MemCopy


cellarstage:	ld	hl,cellar_stagepos
		ld	a,[wGroup7]
		jp	StdStage

specialdata:	db	SPECIALFLAMEINC1
		db	SPECIALFLAMEDEC1
		db	SPECIALGRAVITY1
		db	SPECIALCYCLE1
		db	SPECIALFLAMEINC2
		db	SPECIALFLAMEDEC2
		db	SPECIALGRAVITY2
		db	SPECIALCYCLE2


newcellarstage:
		ld	a,[wSubLevel]
		cp	3		;Special mode
		jr	c,.notspecial	;
		ld	hl,specialdata
		jr	z,.hlok
		ld	hl,specialdata+4
.hlok:		ld	a,[hli]
		ldh	[cellar_incmax],a
		ld	a,[hli]
		ldh	[cellar_damage],a
		ld	a,[hli]
		ldh	[cellar_gravity],a
		ld	a,[hl]
		ldh	[cellar_steptime],a
		ret
.notspecial:	ld	b,a
		add	a
		add	b
		ld	b,a
		ld	a,[wSubStage]
		add	b
		ld	b,a
		add	a
		add	a
		add	b
		ld	hl,cellarsequences
		call	addahl
		ld	a,[hli]
		ldh	[cellar_seqtake2],a
		ld	a,[hli]
		ldh	[cellar_seqtake2+1],a
		ld	a,[hli]
		ldh	[cellar_incmax],a
		ld	a,[hli]
		ldh	[cellar_gravity],a
		ld	a,[hli]
		ldh	[cellar_damage],a
		xor	a
		ldh	[cellar_inccnt],a
		ld	a,1
		ldh	[cellar_stagepos],a
		call	lowerwater
newcellartake:	ldh	a,[cellar_seqtake2]
		ld	l,a
		ldh	a,[cellar_seqtake2+1]
		ld	h,a
		ld	a,[hli]
		ldh	[cellar_steptime],a
		or	a
		ret	z
		ld	a,[hli]
		ldh	[cellar_seqtake],a
		ld	a,[hli]
		ldh	[cellar_seqtake+1],a
		ld	a,l
		ldh	[cellar_seqtake2],a
		ld	a,h
		ldh	[cellar_seqtake2+1],a
		ret

cellartake:	ldh	a,[cellar_steptime]
		or	a
		ret	z
		ld	hl,cellar_timecnt
		inc	[hl]
		dec	a
		cp	[hl]
		ret	nc
		ld	[hl],0
		ld	hl,cellar_drips
		ld	c,MAXDRIPS
		ld	d,0
.find:		ld	a,[hl]
		and	7
		jr	nz,.noinc
		inc	d
.noinc:		inc	l
		inc	l
		inc	l
		dec	c
		jr	nz,.find
		ld	a,d
		or	a
		ret	z
.restart:
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	c,.notspecial
		call	IncScore
;		ld	hl,wScoreLo
;		inc	[hl]
;		jr	nz,.forcerand
;		inc	hl
;		inc	[hl]
		jr	.forcerand	;
.notspecial:
		ldh	a,[cellar_seqtake]
		ld	l,a
		ldh	a,[cellar_seqtake+1]
		ld	h,a
.waited:	ld	a,[hli]
		cp	255
		jr	nz,.nonew
		call	newcellartake
		ldh	a,[cellar_steptime]
		or	a
		jr	nz,.restart
		ld	hl,wSubStage
		inc	[hl]
		ld	a,[hl]
		cp	3
		jp	z,cellarwon
		jp	newcellarstage
.nonew:		or	a
		jr	nz,.nowait
		ld	a,d
		cp	MAXDRIPS
		ret	nz
		jr	.waited
.nowait:	cp	R
		jr	nz,.notrandom
.forcerand:	push	hl
		ld	b,0
.rpick:		call	random
		and	7
		cp	6
		jr	nc,.rpick
		ld	c,a
		ld	hl,cellarbits
		add	hl,bc
		ldh	a,[cellar_busy]
		and	[hl]
		jr	nz,.rpick
		pop	hl
		ld	a,c
		inc	a
		jr	.gotdrip
.notrandom:
.gotdrip:	ld	b,a
		ld	a,[wSubStage]
		cp	1
		jr	nz,.nodecbg
		ldh	a,[cellar_bonusgo]
		dec	a
		ldh	[cellar_bonusgo],a
.nodecbg:	ld	a,l
		ldh	[cellar_seqtake],a
		ld	a,h
		ldh	[cellar_seqtake+1],a
		ld	a,b
		cp	P
		jp	nz,startdrip
		ret
cellarwon:	ld	hl,cellar_flags
		set	CELLARFLG_WON,[hl]
		set	CELLARFLG_DONE,[hl]
		ld	a,SONG_WON
		jp	InitTune

tryglubs:	ldh	a,[cellar_depth]
		cp	MAXDEPTH
		ret	c
		ldh	a,[cellar_endcnt]
		cp	BUBBLESTOP
		ret	nc
		call	random
		ld	b,a
		and	3
		ret	nz
		ld	a,b
		swap	a
		and	3
		ret	z
		ld	hl,cellar_glub1-1
		call	addahl
		ld	a,[hl]
		or	a
		ret	nz
		ld	[hl],1
		ret

cellarstar:	ldh	a,[cellar_bonuscnt]
		or	a
		ret	z
		inc	a
		ldh	[cellar_bonuscnt],a
		ld	e,a
		ldh	a,[cellar_bonuspos]
		swap	a
		add	$17
		ld	d,a
		ldh	a,[cellar_flags]
		bit	CELLARFLG_DUST,a
		jr	nz,.cellardust
		ld	a,e
		and	7
		add	255&IDX_STAR
		ld	c,a
		ld	a,0
		adc	IDX_STAR>>8
		ld	b,a
		ld	a,e
		add	a
		add	e
		ld	e,a
		cp	144
		jr	nc,.offstar
		ld	a,[wGroup8]
		push	de
		call	AddFigure
		pop	de
		ld	a,e
		cp	90
		ret	c
		ldh	a,[cellar_lumpos]
		ld	b,a
		ldh	a,[cellar_bonuspos]
		cp	b
		jr	z,.gotit
		dec	b
		cp	b
		jr	z,.gotit
		inc	b
		inc	b
		cp	b
		ret	nz
.gotit:		ld	a,1
		ldh	[cellar_bonuscnt],a
		ld	hl,cellar_flags
		set	CELLARFLG_DUST,[hl]
		ld	hl,wSubStars
		inc	[hl]
		ld	a,SONG_GOTSTAR
		call	InitTune
		ret
.cellardust:	ld	a,e
		cp	DUSTTIME
		jr	z,.offstar
		cp	DUSTFLICKER
		jr	c,.noflicker
		srl	a
		ret	c
.noflicker:	ld	a,e
		and	7
		add	255&IDX_DUST
		ld	c,a
		ld	a,0
		adc	IDX_DUST>>8
		ld	b,a
		ld	a,90
		sub	e
		ld	e,a
		ld	a,[wGroup8]
		jp	AddFigure
.offstar:	xor	a
		ldh	[cellar_bonuscnt],a
		ret

trycellarstar:	ld	a,[wSubLevel]	;Special mode
		cp	3		;
		ret	nc		;
		ld	a,[wSubGaston]
		or	a
		ret	nz
		ld	hl,cellar_flags
		bit	CELLARFLG_STAR,[hl]
		ret	nz
		ldh	a,[cellar_stagepos]
		or	a
		ret	nz
		ldh	a,[cellar_bonusgo]
		or	a
		ret	nz
		set	CELLARFLG_STAR,[hl]
		ld	a,[cellar_lumpos]
		xor	4
		ldh	[cellar_bonuspos],a
		ld	a,1
		ldh	[cellar_bonuscnt],a
		ret



doglubs:	ld	hl,cellar_glub1
		call	doglub
		ld	hl,cellar_glub2
		call	doglub
		ld	hl,cellar_glub3
doglub:		ld	a,[hl]
		or	a
		ret	z
		cp	1+10*2
		jr	c,.glubbing
		ld	[hl],0
		ret
.glubbing:	inc	[hl]
		dec	a
		srl	a
		add	255&IDX_GLUB
		ld	c,a
		ld	a,0
		adc	IDX_GLUB>>8
		ld	b,a
		ld	e,GLUBY
		ld	a,l
		ld	l,cellar_glub1
		sub	l
;		sub	255&(cellar_glub1)
		add	a
		add	a
		ld	d,a
		ldh	a,[cellar_lumpos]
		swap	a
		add	GLUBX
		add	d
		ld	d,a
		ld	a,[wGroup6]
		jp	AddFigure

dolumiere:
		ldh	a,[cellar_depth]
		cp	MAXDEPTH
		ret	z

		ld	hl,cellar_lumpos
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_B,c
		jr	nz,.goleft
		bit	JOY_L,c
		jr	z,.noleft
.goleft:	ld	a,[hl]
		or	a
		jr	z,.noleft
		dec	[hl]
		xor	a
		ldh	[cellar_repeat],a
.noleft:	bit	JOY_A,c
		jr	nz,.goright
		bit	JOY_R,c
		jr	z,.noright
.goright:	ld	a,[hl]
		cp	7
		jr	z,.noright
		inc	[hl]
		xor	a
		ldh	[cellar_repeat],a
.noright:	ld	a,[wJoy1Cur]
		ld	c,a
		bit	JOY_B,c
		jr	nz,.goleft2
		bit	JOY_L,c
		jr	z,.noleft2
.goleft2:	ld	a,[hl]
		or	a
		jr	z,.noleft2
		ldh	a,[cellar_repeat]
		cp	AUTOREPEAT
		jr	z,.doleft2
		inc	a
		ldh	[cellar_repeat],a
		jr	.noleft2
.doleft2:	ldh	a,[cellar_phase]
		srl	a
		jr	c,.noleft2
		dec	[hl]
.noleft2:	bit	JOY_A,c
		jr	nz,.goright2
		bit	JOY_R,c
		jr	z,.noright2
.goright2:	ld	a,[hl]
		cp	7
		jr	z,.noright2
		ldh	a,[cellar_repeat]
		cp	AUTOREPEAT
		jr	z,.doright2
		inc	a
		ldh	[cellar_repeat],a
		jr	.noright2
.doright2:	ldh	a,[cellar_phase]
		srl	a
		jr	c,.noright2
		inc	[hl]
.noright2:	ret



incflames:	ldh	a,[cellar_incmax]
		ld	b,a
		ldh	a,[cellar_inccnt]
		inc	a
		ldh	[cellar_inccnt],a
		cp	b
		ret	c
		xor	a
		ldh	[cellar_inccnt],a
		ld	hl,cellar_candle2
		call	incflame
		ldh	a,[cellar_depth]
		cp	MAXDEPTH
		ret	z
		ld	hl,cellar_candle1
		call	incflame
		ld	hl,cellar_candle3
incflame:	ld	a,[hl]
		or	a
		jr	z,.dead
		cp	10
		jr	nc,.dead
		inc	[hl]
.dead:		ret

decflames:	ldh	a,[cellar_depth]
		cp	MAXDEPTH
		ret	nz
		ldh	a,[cellar_phase]
		and	3
		ret	nz
		ld	hl,cellar_candle1
		call	decflame
		ld	hl,cellar_candle2
		call	decflame
		ld	hl,cellar_candle3
decflame:	ld	a,[hl]
		or	a
		jr	z,.dead
		dec	[hl]
.dead:		ret



lowerwater:	ldh	a,[cellar_depth]
		or	a
		ret	z
		dec	a
		ldh	[cellar_depth],a
		inc	a
		jr	renderwater
raisewater:	ldh	a,[cellar_depth]
		cp	MAXDEPTH
		ret	z
		inc	a
		ldh	[cellar_depth],a
		cp	MAXDEPTH
		jr	c,renderwater
		ld	hl,cellar_flags
		set	CELLARFLG_DONE,[hl]
		call	renderwater
		ld	a,SONG_LOST
		jp	InitTune
renderwater:	add	a
		ld	hl,watercopies-2
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
.wclp:		ld	a,[hli]
		or	a
		ret	z
		ld	c,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		push	hl
		ld	h,a
		ld	l,b

.swaplp:	ld	b,[hl]
		ld	a,[de]
		ld	[hli],a
		ld	a,b
		ld	[de],a
		inc	de
		dec	c
		jr	nz,.swaplp

		pop	hl
		jr	.wclp


watercopies:	dw	wc0
		dw	wc1
		dw	wc2
		dw	wc3
		dw	wc4
		dw	wc5

wc0:		db	10
		dw	00+17*$20+CELLARMAP,20+17*$20+CELLARMAP
		db	10
		dw	00+17*$20+CELLARATTR,20+17*$20+CELLARATTR
		db	10
		dw	10+17*$20+CELLARMAP,20+11*$20+CELLARMAP
		db	10
		dw	10+17*$20+CELLARATTR,20+11*$20+CELLARATTR
		db	0
wc1:		db	10
		dw	00+16*$20+CELLARMAP,20+16*$20+CELLARMAP
		db	10
		dw	00+16*$20+CELLARATTR,20+16*$20+CELLARATTR
		db	10
		dw	10+16*$20+CELLARMAP,20+10*$20+CELLARMAP
		db	10
		dw	10+16*$20+CELLARATTR,20+10*$20+CELLARATTR
		db	6
		dw	20+5*$20+CELLARMAP,26+5*$20+CELLARMAP
		db	6
		dw	20+5*$20+CELLARATTR,26+5*$20+CELLARATTR
		db	0
wc2:		db	10
		dw	00+15*$20+CELLARMAP,20+15*$20+CELLARMAP
		db	10
		dw	00+15*$20+CELLARATTR,20+15*$20+CELLARATTR
		db	10
		dw	10+15*$20+CELLARMAP,20+9*$20+CELLARMAP
		db	10
		dw	10+15*$20+CELLARATTR,20+9*$20+CELLARATTR
		db	6
		dw	20+4*$20+CELLARMAP,26+4*$20+CELLARMAP
		db	6
		dw	20+4*$20+CELLARATTR,26+4*$20+CELLARATTR
		db	0
wc3:		db	10
		dw	00+14*$20+CELLARMAP,20+14*$20+CELLARMAP
		db	10
		dw	00+14*$20+CELLARATTR,20+14*$20+CELLARATTR
		db	10
		dw	10+14*$20+CELLARMAP,20+8*$20+CELLARMAP
		db	10
		dw	10+14*$20+CELLARATTR,20+8*$20+CELLARATTR
		db	6
		dw	20+3*$20+CELLARMAP,26+3*$20+CELLARMAP
		db	6
		dw	20+3*$20+CELLARATTR,26+3*$20+CELLARATTR
		db	0
wc4:		db	10
		dw	00+13*$20+CELLARMAP,20+13*$20+CELLARMAP
		db	10
		dw	00+13*$20+CELLARATTR,20+13*$20+CELLARATTR
		db	10
		dw	10+13*$20+CELLARMAP,20+7*$20+CELLARMAP
		db	10
		dw	10+13*$20+CELLARATTR,20+7*$20+CELLARATTR
		db	6
		dw	20+2*$20+CELLARMAP,26+2*$20+CELLARMAP
		db	6
		dw	20+2*$20+CELLARATTR,26+2*$20+CELLARATTR
		db	0
wc5:		db	10
		dw	00+12*$20+CELLARMAP,20+12*$20+CELLARMAP
		db	10
		dw	00+12*$20+CELLARATTR,20+12*$20+CELLARATTR
		db	10
		dw	10+12*$20+CELLARMAP,20+6*$20+CELLARMAP
		db	10
		dw	10+12*$20+CELLARATTR,20+6*$20+CELLARATTR
		db	6
		dw	20+1*$20+CELLARMAP,26+1*$20+CELLARMAP
		db	6
		dw	20+1*$20+CELLARATTR,26+1*$20+CELLARATTR
		db	0




DRIPDOWN	EQU	56
DRIPY		EQU	8
makedepth:	ld	hl,DRIPLEVELS
		ldh	a,[cellar_depth]
		add	a
		add	a
		add	a
		cpl
		add	DRIPBASE+1
		ld	bc,21
		call	MemFill
		ld	hl,DRIPTYPES
		ld	bc,20
		call	MemClear
		ld	hl,DRIPLEVELS
		ldh	a,[cellar_lumpos]
		call	addahl
		ld	a,l
		add	255&(DRIPTYPES-DRIPLEVELS)
		ld	e,a
		ld	a,h
		adc	(DRIPTYPES-DRIPLEVELS)>>8
		ld	d,a
		ldh	a,[cellar_candle1]
		or	a
		jr	z,.no1
		ld	[hl],LUMY1
		ld	a,1
		ld	[de],a
.no1:		inc	hl
		inc	de
		ldh	a,[cellar_candle2]
		or	a
		jr	z,.no2
		ld	[hl],LUMY2
		ld	a,2
		ld	[de],a
.no2:		inc	hl
		inc	de
		ldh	a,[cellar_candle3]
		or	a
		jr	z,.no3
		ld	[hl],LUMY1
		ld	a,3
		ld	[de],a
.no3:		ret


startdrip:	or	a
		ret	z
		dec	a
		ld	b,a
		ld	hl,cellar_drips
		ld	c,MAXDRIPS
.find:		ld	a,[hl]
		and	7
		jr	z,.found
		inc	l
		inc	l
		inc	l
		dec	c
		jr	nz,.find
		ret
.found:
;		call	random
;		and	$70
;		cp	$60
;		jr	nc,.found
		ld	a,b
		swap	a
		add	$20
		inc	a
		ld	[hli],a
		xor	a
		ld	[hli],a
		ret



docandles:	ld	d,-1
		ld	e,CANDLEY1
		ldh	a,[cellar_candle1]
		call	docandle
		ld	d,16
		ld	e,CANDLEY2
		ldh	a,[cellar_candle2]
		call	docandle
		ld	d,32
		ld	e,CANDLEY1
		ldh	a,[cellar_candle3]

docandle:	or	a
		ret	z
		ld	c,a
		ldh	a,[cellar_phase]
		srl	a
		srl	a
		jr	c,.nodec
		dec	c
		ret	z
.nodec:		dec	c
		ldh	a,[cellar_lumpos]
		swap	a
		add	d
		add	CANDLEX
		ld	d,a
		ld	a,c
		cpl
		add	9+1
		ld	l,a
		add	255&IDX_FLAMEA
		ld	c,a
		ld	a,0
		adc	IDX_FLAMEA>>8
		ld	b,a
		ld	a,l
		srl	a
		ld	hl,wGroup1
		call	addahl
		ld	a,[hl]
		jp	AddFigure


;modes:
;0 = nothing, slot empty
;1 = dripping off pipe
;2 = falling down
;3 = splashing on ground
;4 = steam frames

dodrips:	xor	a
		ldh	[cellar_busy],a
	 	ld	hl,cellar_drips+00
		call	dodrip
		ld	hl,cellar_drips+03
		call	dodrip
		ld	hl,cellar_drips+06
		call	dodrip
		ld	hl,cellar_drips+09
		call	dodrip
		ld	hl,cellar_drips+12
		call	dodrip
		ld	hl,cellar_drips+15
dodrip:		ld	a,[hl]
		and	7
		ret	z
		ld	c,a
		xor	[hl]
		inc	l
		add	7
		ld	d,a
		dec	c
		jp	z,dripmode1
		dec	c
		jp	z,dripmode2
		dec	c
		jp	z,dripmode3
		dec	c
		jp	z,dripmode4
		ret

;dripping
dripmode1:	ld	b,[hl]
		ldh	a,[cellar_phase]
		and	3
		jr	nz,.noinc
		inc	[hl]
.noinc:		ld	a,b
		cp	13
		jr	c,.dripping
		ld	[hl],0
		dec	l
		inc	[hl]
		push	hl
		ld	a,SFX_WATERDRIP
		call	InitSfx
		pop	hl
		jp	dodrip
.dripping:	dec	l
		push	hl
		ld	e,DRIPY
		add	255&IDX_DRIP
		ld	c,a
		ld	a,0
		adc	IDX_DRIP>>8
		ld	b,a
		ld	a,[wGroup6]
		call	AddFigure
		pop	hl
		ld	a,[hl]
		and	$f8
		sub	$20
		swap	a
		ld	hl,cellarbits
		call	addahl
		ldh	a,[cellar_busy]
		or	[hl]
		ldh	[cellar_busy],a
		ret


;falling
dripmode2:	ldh	a,[cellar_gravity]
		ld	e,[hl]
		add	e
		ld	[hl],a
		ld	a,[DRIPLEVELS+20]
		cp	e
		jr	nc,.nopool
		xor	a
		ld	[hli],a
		ld	a,e
		add	DRIPY+2
		ld	[hld],a
		dec	l
		inc	[hl]
		push	hl
		ld	a,SFX_WATERSPLASH
		call	InitSfx
		pop	hl
		jp	dodrip
.nopool:	ld	a,d
		swap	a
		and	15
		add	255&DRIPLEVELS
		ld	c,a
		ld	a,0
		adc	DRIPLEVELS>>8
		ld	b,a
		ld	a,[bc]
		sub	e
		jr	nc,.dripping
		cp	256-FLAMESIZE
		jr	c,.dripping
		ld	[hl],0
		inc	l
		ld	a,e
		add	DRIPY+2
		ld	[hld],a
		dec	l
		ld	a,c
		add	255&(DRIPTYPES-DRIPLEVELS)
		ld	c,a
		ld	a,b
		adc	(DRIPTYPES-DRIPLEVELS)>>8
		ld	b,a
		ld	a,[bc]
		inc	[hl]
		inc	[hl]
		ld	e,cellar_candle1-1
		add	e
;		add	255&(cellar_candle1-1)
		ld	e,a
		ld	d,$ff
		ldh	a,[cellar_damage]
		ld	b,a
		ld	a,[de]
		sub	b
		jr	nc,.aok
		xor	a
.aok:		ld	[de],a
.noinc2:	push	hl
		ld	a,SFX_WATERVAPOR
		call	InitSfx
		pop	hl
		jp	dodrip
.dripping:	ld	a,e
		add	DRIPY+2
		ld	e,a
		ld	bc,IDX_DRIP+13
		ld	a,[wGroup6]
		jp	AddFigure

;splashing
dripmode3:	ld	a,[hl]
		inc	[hl]
		cp	8
		jr	c,.splashing
		dec	l
		ld	[hl],0
		jp	raisewater

.splashing:	inc	l
		ld	e,[hl]
		dec	l
		add	13
		add	255&IDX_DRIP
		ld	c,a
		ld	a,0
		adc	IDX_DRIP>>8
		ld	b,a
		ld	a,[wGroup6]
		jp	AddFigure

;vaporizing
dripmode4:	ld	a,[hl]
		inc	[hl]
		cp	14
		jr	c,.smoking
		dec	l
		ld	[hl],0
		ret
.smoking:	inc	l
		ld	e,[hl]
		dec	l
		add	255&IDX_STEAM
		ld	c,a
		ld	a,0
		adc	IDX_STEAM>>8
		ld	b,a
		ld	a,[wGroup7]
		jp	AddFigure


LUMDOWN		EQU	11*$20-20

putlumiere:	ldh	a,[cellar_depth]
		cp	MAXDEPTH
		jp	nz,.normal
		ld	hl,cellar_candle1
		ld	a,[hli]
		or	[hl]
		inc	l
		or	[hl]
;;;;		jr	z,putlumiere2	;Lumiere keeled over (dead)
.normal:	ld	hl,CELLARMAP
		ld	de,MAPCOPY
		call	putlumiere1
		ld	hl,CELLARATTR
		ld	de,ATTRCOPY
putlumiere1:	ldh	a,[cellar_lumpos]
		add	a
		add	e
		ld	e,a
		ld	a,0
		adc	d
		ld	d,a
		ld	a,e
		add	255&LUMDOWN
		ld	e,a
		ld	a,d
		adc	LUMDOWN>>8
		ld	d,a

		ld	bc,lumlist
.pl:		ld	a,[bc]
		or	a
		ret	z
		push	de
		push	hl
		add	l
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ld	a,[bc]
		inc	bc
		add	e
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,[hl]
		ld	[de],a
		pop	hl
		pop	de
		jr	.pl

lumlist:
		db	22+0*$20
		db	23+0*$20
		db	20+1*$20
		db	21+1*$20
		db	22+1*$20
		db	23+1*$20
		db	24+1*$20
		db	25+1*$20
		db	20+2*$20
		db	21+2*$20
		db	22+2*$20
		db	23+2*$20
		db	24+2*$20
		db	25+2*$20
		db	20+3*$20
		db	21+3*$20
		db	22+3*$20
		db	23+3*$20
		db	24+3*$20
		db	25+3*$20
		db	22+4*$20
		db	23+4*$20
		db	21+5*$20
		db	22+5*$20
		db	23+5*$20
		db	24+5*$20
		db	0

putlumiere2:	ld	de,CELLARMAP
		ld	bc,MAPCOPY
		call	putlumiere12
		ld	de,CELLARATTR
		ld	bc,ATTRCOPY
putlumiere12:	ldh	a,[cellar_lumpos]
		add	a
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,c
		add	255&(LUMDOWN+2*$20+20)
		ld	c,a
		ld	a,b
		adc	(LUMDOWN+2*$20+20)>>8
		ld	b,a
		ld	hl,lumlist2
.pl:		ld	a,[hli]
		or	[hl]
		ret	z
		dec	hl
		push	bc
		push	de
		ld	a,[hli]
		add	e
		ld	e,a
		ld	a,[hli]
		adc	d
		ld	d,a
		ld	a,[hli]
		add	c
		ld	c,a
		ld	a,[hli]
		adc	b
		ld	b,a
		ld	a,[de]
		ld	[bc],a
		inc	de
		inc	bc
		ld	a,[de]
		ld	[bc],a
		pop	de
		pop	bc
		jr	.pl

lumlist2:	dw	30+06*$20,2+0*$20
		dw	30+07*$20,1+1*$20
		dw	30+08*$20,3+1*$20
		dw	30+09*$20,0+2*$20
		dw	30+10*$20,2+2*$20
		dw	30+11*$20,4+2*$20
		dw	20+00*$20,0+3*$20
		dw	24+00*$20,2+3*$20
		dw	26+00*$20,4+3*$20
		dw	0

cellar_setup::
		ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,cellar_flags
		set	CELLARFLG_FIRST,[hl]

		call	InitGroups
		ld	hl,PAL_FLAMEA
		call	AddPalette
		or	$10
		ld	[wGroup1],a
		ld	hl,PAL_FLAMEB
		call	AddPalette
		or	$10
		ld	[wGroup2],a
		ld	hl,PAL_FLAMEC
		call	AddPalette
		or	$10
		ld	[wGroup3],a
		ld	hl,PAL_FLAMED
		call	AddPalette
		or	$10
		ld	[wGroup4],a
		ld	hl,PAL_FLAMEE
		call	AddPalette
		or	$10
		ld	[wGroup5],a
		ld	hl,PAL_DRIP
		call	AddPalette
		or	$10
		ld	[wGroup6],a
		ld	hl,PAL_STEAM
		call	AddPalette
		or	$10
		ld	[wGroup7],a
		ld	hl,PAL_STAR
		call	AddPalette
		or	$10
		ld	[wGroup8],a

		ld	hl,cellarpal
		call	LoadPalHL

		ld	hl,IDX_CELLARCHR	;cellarchr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok1
		ld	hl,IDX_CELLARBWCHR	;cellarbwchr
.hlok1:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$a0
		call	DumpChrs
		ld	hl,IDX_CELLARMAP	;cellarmap
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok2
		ld	hl,IDX_CELLARBWMAP	;cellarbwmap
.hlok2:		ld	de,CELLARMAP
		ld	c,$80
		call	cellarmapfix
		ld	a,%10010011
		ld	[wGmbPal2],a

		ldh	a,[cellar_depth]
		or	a
		jr	z,.nodepth
		ld	c,a
		xor	a
		ldh	[cellar_depth],a
.fillup:	push	bc
		call	raisewater
		pop	bc
		dec	c
		jr	nz,.fillup
.nodepth:

		call	makexscroll

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.nohints
		di
		SETVBL	CellarVector0
		SETLYC	CellarVector1
		ei
.nohints:
		ret


cellarxtab:
		db	1,1,0,-1,-1,-1,0,1


;		db	-2,-1,0,1
;		db	1,0,-1,-2

makexscroll:
		ldh	a,[cellar_depth]
		or	a
		jr	nz,.some
		ld	a,192
		jr	.skip
.some:		add	a
		add	a
		add	a
		cpl
		add	144+1
.skip:		ld	[CELLARXSCROLL],a
		ldh	a,[cellar_phase]
		srl	a
		srl	a
		and	6
		ld	e,a
		add	LOW(cellarxtab)
		ld	c,a
		ld	a,0
		adc	HIGH(cellarxtab)
		ld	b,a
		ld	a,8
		sub	e
		ld	e,a
		ld	d,50
		ld	hl,CELLARXSCROLL+90
.lp:		ld	a,[bc]
		inc	bc
		ld	[hli],a
		dec	e
		jr	nz,.noreset
		ld	bc,cellarxtab
		ld	e,8
.noreset:	dec	d
		jr	nz,.lp
		ret

cellarbits:	db	1,2,4,8,16,32,64,128

cellar_shutdown:
		call	FadeOut
		di
		SETVBL	VblNormal	;restore vectors so John's 8 bit
		SETLYC	LycNormal	;vector writing doesn't get wrecked.
		ei
		xor	a
		ldio	[rSCX],a
		dec	a
		ldio	[rLYC],a
		ld	a,140+5
		call	wJmpSprDumpMod
		LD	A,%11010010
		ld	[wGmbPal2],a
		ret

cellarflip:	ldh	a,[cellar_phase]
		inc	a
		ldh	[cellar_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret

cellarcopy:	ld	hl,MAPCOPY
		ldh	a,[cellar_phase]
		srl	a
		ld	de,$9800
		jr	nc,.deok
		ld	de,$9c00
.deok:
		ld	c,2*18
		push	de
		call	SafeDumpChrs
		pop	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,ATTRCOPY
		ld	c,2*18
		call	SafeDumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret



cellarmapfix:	push	de
		ld	a,c
		ldh	[hTmpLo],a
		ld	de,$c800
		call	SwdInFileSys
		pop	de
		ld	hl,$c800+8
		ld	c,18
.y1:		ld	b,32
.x1:		ldh	a,[hTmpLo]
		add	[hl]
		inc	hl
		inc	hl
		ld	[de],a
		inc	de
		dec	b
		jr	nz,.x1
		dec	c
		jr	nz,.y1

		ld	hl,$c800+8
		ld	c,18
.y2:		ld	b,32
.x2:		inc	hl
		ld	a,[hli]
		ld	[de],a
		inc	de
		dec	b
		jr	nz,.x2
		dec	c
		jr	nz,.y2
		ret

;0 = wait for all the drips to finish
;1-6 = initiate a drip in that position
;R   = random drop
;P   = Pause one drip's time
;255 = end of sequence marker


cellarseq0:
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	255




cellarseq1:
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	255


cellarseq2:
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	R,R,R,R,R,R
		db	0
		db	255



cellarseq3:
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	255




cellarseq4:
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	255


cellarseq5:
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	R,P,R,P,R,P
		db	0
		db	255






;first number (db) is time between drip launching, higher = slower
;0 = endmark
;second value (dw) is the sequence list

cellarimposs0:
cellarimposs1:
cellarimposs2:

cellareasy0:	db	15
		dw	cellarseq3
		db	0

cellareasy1:	db	15
		dw	cellarseq4
		db	0

cellareasy2:	db	15
		dw	cellarseq5
		db	0


cellarmedium0:	db	15
		dw	cellarseq0
		db	0

cellarmedium1:	db	15
		dw	cellarseq1
		db	0

cellarmedium2:	db	15
		dw	cellarseq2
		db	0


cellarhard0:	db	15
		dw	cellarseq0
		db	0

cellarhard1:	db	15
		dw	cellarseq1
		db	0

cellarhard2:	db	15
		dw	cellarseq2
		db	0

;dw is sequence list
;db is the # of frames to increment a flame once
cellarsequences:
		dw	cellareasy0	;seq list
		db	25,3,3	;inc flame time, gravity,water damage
		dw	cellareasy1
		db	25,3,3
		dw	cellareasy2
		db	25,3,3
		dw	cellarmedium0
		db	13,3,3
		dw	cellarmedium1
		db	13,3,3
		dw	cellarmedium2
		db	13,3,3
		dw	cellarhard0
		db	15,4,3
		dw	cellarhard1
		db	15,4,3
		dw	cellarhard2
		db	15,4,3



cellarpal:	incbin	"res/dave/cellar/cellar.rgb"

cellar_end::
