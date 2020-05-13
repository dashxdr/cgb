; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BOARD.ASM                                                             **
; **                                                                       **
; ** Created : 20000716 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		section	10
board2_start::



b2_rollerjack	EQUS	"wTemp1024+00" ;2
b2_flumejack	EQUS	"wTemp1024+02" ;2
b2_poptimer	EQUS	"wTemp1024+04"
b2_seconds	EQUS	"wTemp1024+05"
b2_hidey	EQUS	"wTemp1024+06" ;2
b2_hide		EQUS	"wTemp1024+08"
b2_hideframe	EQUS	"wTemp1024+09"
b2_hidex	EQUS	"wTemp1024+10"
b2_hidedone	EQUS	"wTemp1024+11"
b2_wanthide	EQUS	"wTemp1024+12"
b2_hidecollect	EQUS	"wTemp1024+13"
b2_dropb	EQUS	"wTemp1024+14"
b2_dropbtimer	EQUS	"wTemp1024+15"
b2_kicklock	EQUS	"wTemp1024+16"
b2_fantasybits	EQUS	"wTemp1024+17"
b2_lefttrapped	EQUS	"wTemp1024+18"
b2_ridesdelay	EQUS	"wTemp1024+19"
b2_clock	EQUS	"wTemp1024+20"
b2_clocktimer	EQUS	"wTemp1024+21"
b2_thrillzone	EQUS	"wTemp1024+22"
b2_thrillgame	EQUS	"wTemp1024+23"
b2_12guage	EQUS	"wTemp1024+24"
b2_leftkick	EQUS	"wTemp1024+25"
b2_rightkick	EQUS	"wTemp1024+26"
b2_leftpops	EQUS	"wTemp1024+27"
b2_centerpops	EQUS	"wTemp1024+28"
b2_rightpops	EQUS	"wTemp1024+29"
b2_awardready	EQUS	"wTemp1024+30"
b2_lightbits	EQUS	"wTemp1024+31"
b2_holdpops	EQUS	"wTemp1024+32"
b2_rides	EQUS	"wTemp1024+33"
b2_ridestimer	EQUS	"wTemp1024+34"
b2_allrides	EQUS	"wTemp1024+35"
b2_rampcount	EQUS	"wTemp1024+36"
b2_kickspin	EQUS	"wTemp1024+37"
b2_kickdie	EQUS	"wTemp1024+38"
b2_funzone	EQUS	"wTemp1024+39"
b2_fungame	EQUS	"wTemp1024+40"
b2_holdmult	EQUS	"wTemp1024+41"
b2_leftlocked	EQUS	"wTemp1024+42"
b2_popupstate	EQUS	"wTemp1024+43"
b2_thrillride	EQUS	"wTemp1024+44"
b2_bonus	EQUS	"wTemp1024+45"
b2_happy	EQUS	"wTemp1024+46"
b2_happytimer	EQUS	"wTemp1024+47"
b2_happydelay	EQUS	"wTemp1024+48"
b2_launcher	EQUS	"wTemp1024+49"
b2_fantasydone	EQUS	"wTemp1024+50"
b2_thrilladd	EQUS	"wTemp1024+51"
b2_thrilltimer	EQUS	"wTemp1024+52"
b2_treat	EQUS	"wTemp1024+53"
b2_treatstaken	EQUS	"wTemp1024+54"
b2_ridephotos	EQUS	"wTemp1024+55"
b2_nextphoto	EQUS	"wTemp1024+56"
b2_brassrings	EQUS	"wTemp1024+57"
b2_nextring	EQUS	"wTemp1024+58"
b2_rightlocked	EQUS	"wTemp1024+59"
b2_righttrapped	EQUS	"wTemp1024+60"
b2_rightramps	EQUS	"wTemp1024+61"
b2_spit1	EQUS	"wTemp1024+62"
b2_spit2	EQUS	"wTemp1024+63"
b2_jackready	EQUS	"wTemp1024+64"
b2_normalskill	EQUS	"wTemp1024+65"
b2_superskill	EQUS	"wTemp1024+66"
b2_loop		EQUS	"wTemp1024+67"
b2_bumperhits	EQUS	"wTemp1024+68" ;8
b2_bumpergone	EQUS	"wTemp1024+76"
b2_flumes	EQUS	"wTemp1024+77"
b2_rollers	EQUS	"wTemp1024+78"
b2_done		EQUS	"wTemp1024+79"
b2_night	EQUS	"wTemp1024+80"
b2_nightwant	EQUS	"wTemp1024+81"
b2_finishedbits	EQUS	"wTemp1024+82"
b2_lastfun	EQUS	"wTemp1024+83"
b2_lastthrill	EQUS	"wTemp1024+84"
b2_warps	EQUS	"wTemp1024+85"
b2_pop		EQUS	"wTemp1024+86"
b2_hideyoohoo	EQUS	"wTemp1024+87"

SPITTIME	EQU	15

YOOHOOTIME	EQU	120

LAUNCHER	EQU	0

GROUP_SPINNER	EQU	2
GROUP_POP	EQU	3

KICKDIE		EQU	12	;in 32/60ths of of a second.

LAUNCHERX	EQU	173<<5
LAUNCHERY	EQU	305<<5

WANTHIDE	EQU	50	;how many treats for hide + seek mode
SKILLTIME	EQU	120 ;# of ticks/4 from ball launch to getting skill shot
SKILLSAFE	EQU	30

BUMPERHITS	EQU	5

BIT_THRILL	EQU	0
BIT_FUN		EQU	1
BIT_ROLLERS	EQU	2
BIT_FLUMES	EQU	3


CODE_LEFT	EQU	1
CODE_RIGHT	EQU	2
CODE_LEFTRAMP	EQU	3
CODE_RIGHTRAMP	EQU	4
CODE_SNACKBAR	EQU	5
CODE_LEFTSCOOP	EQU	6
CODE_RIGHTSCOOP	EQU	7

MASK_LEFT	EQU	1<<1
MASK_RIGHT	EQU	1<<2
MASK_LEFTRAMP	EQU	1<<3
MASK_RIGHTRAMP	EQU	1<<4
MASK_SNACKBAR	EQU	1<<5
MASK_LEFTSCOOP	EQU	1<<6
MASK_RIGHTSCOOP	EQU	1<<7

KICKSPINADD	EQU	9
MAXKICKSPIN	EQU	144
KICKSPINA	EQU	1*MAXKICKSPIN/7
KICKSPINB	EQU	2*MAXKICKSPIN/7
KICKSPINC	EQU	3*MAXKICKSPIN/7
KICKSPIND	EQU	4*MAXKICKSPIN/7
KICKSPINE	EQU	5*MAXKICKSPIN/7
KICKSPINF	EQU	6*MAXKICKSPIN/7
KICKSPING	EQU	7*MAXKICKSPIN/7

THRILLTIME	EQU	30

MAXBONUS	EQU	250	;max value of bonus multiplier

TABLEGAME_THRILL EQU	1
TABLEGAME_ROLLERMULTI EQU	2
TABLEGAME_HAPPY	EQU	3
TABLEGAME_FANTASY EQU	4
TABLEGAME_FLUMEMULTI EQU	5
TABLEGAME_HIDE	EQU	6
TABLEGAME_BUMPER EQU	7

TV_ROLLERMULTI	EQU	8
TV_FLUMEMULTI	EQU	4
TV_SAVER	EQU	1
TV_60SAVER	EQU	3
TV_30SAVER	EQU	2
TV_NORMALSKILL	EQU	0
TV_SUPERSKILL	EQU	33
TV_ADDBONUS	EQU	16
TV_RIDEPHOTO	EQU	14
TV_BRASSRING	EQU	13
TV_EXTRABALL	EQU	15
TV_JACKPOTS	EQU	24
TV_POPSHELD	EQU	31
TV_BONUSHELD	EQU	30
TV_POINTS	EQU	32
TV_POPSADVANCED	EQU	29
TV_JACKPOTADD	EQU	28
TV_BUMPER	EQU	12
TV_POPSMAX	EQU	34
TV_KICKBACK	EQU	35
TV_AWARDLIT	EQU	44
TV_LOCKLIT	EQU	43
TV_THRILLLIT	EQU	45
TV_FUNLIT	EQU	46
TV_KICKBACKLIT	EQU	47
TV_T		EQU	36
TV_H		EQU	37
TV_R		EQU	38
TV_I		EQU	39
TV_L		EQU	40
TV_D		EQU	41
TV_E		EQU	42
TV_TWIZZLER	EQU	17
TV_REESES	EQU	18
TV_PAYDAY	EQU	19
TV_SYRUP	EQU	20
TV_KISS		EQU	21
TV_CHOCO	EQU	22
TV_COW		EQU	23
TV_JACKREADY	EQU	48


POPBLUE		EQU	33
POPGREEN	EQU	66
POPORANGE	EQU	99


subcompletedsavers:
		db	30,20,10
subnotcompletedsavers:
		db	15,10,0
newballsavers:	db	20,15,10
lockedballsavers:
		db	10,5,0

multiballsavers:
		db	60,30,15
superskillsavers:
		db	60,40,20
normalskillsavers:
		db	30,20,10
tabletimes:	db	100,80,60

board2info:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(board2process)	;wPinJmpProcess
		dw	board2process
		db	BANK(board2sprites)	;wPinJmpSprites
		dw	board2sprites
		db	BANK(board2hitflipper)	;wPinJmpHitFlipper
		dw	board2hitflipper
		db	BANK(board2hitbumper)	;wPinJmpHitBumper
		dw	board2hitbumper
		db	BANK(PinScore)		;wPinJmpScore
		dw	PinScore
		db	BANK(b2lostball)	;wPinJmpLost
		dw	b2lostball
		db	BANK(board2eject)	;wPinJmpEject
		dw	board2eject
		db	BANK(b2unchain)		;wPinJmpChainRet
		dw	b2unchain
		db	BANK(Nothing)		;wPinJmpDone
		dw	Nothing
		dw	CUTOFFY			;wPinCutoff
		dw	IDX_MAIN0002CHG		;lflippers
		dw	IDX_MAIN0010CHG		;rflippers
		db	BANK(board2info)	;wPinHitBank
		db	BANK(Char00)		;wPinCharBank

board2maplist:	db	$2b	;height
		dw	IDX_BOARDRGB
		dw	IDX_BOARDMAP


b2phasetable:	dw	phaseindicator0
		dw	phaseleftramp
		dw	phasekicks
		dw	0
		dw	phaseindicator1
		dw	0
		dw	0
		dw	phaseleft
		dw	phaseindicator2
		dw	phasecharge
		dw	phaseright
		dw	phaseindicator3
		dw	phasesaver
		dw	phasejackpot
		dw	0
		dw	phaseleftscoop
		dw	phaseindicatorcenter
		dw	phasesnackbar
		dw	phaserightscoop
		dw	phasekicks
		dw	phaseindicator4
		dw	phase12guage
		dw	phaserightramp
		dw	0
		dw	phaseindicator5
		dw	0
		dw	0
		dw	phaseindicator6
		dw	phasesaver
		dw	phaseextra
		dw	phaseindicator7
		dw	0

phasekicks:	ld	a,[b2_kickdie]
		or	a
		ret	z
		dec	a
		ld	[b2_kickdie],a
		ret	nz
		xor	a
		ld	[b2_kickspin],a
		call	rightkickback
		xor	a
		jp	leftkickback

phasecharge:	jp	showkickspin
phase12guage:	jp	show12guage

phaseleftscoop:
		ld	e,B2_LEFTSCOOP
		call	leftscooplight
		jp	newstate

leftscooplight:
		ld	a,[b2_hide]
		cp	CODE_LEFTSCOOP
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.notflume
		ld	a,[any_mlock1]
		or	a
		ld	d,2
		jr	nz,.dok
		call	mlockpossible
		jr	c,.d0
		ld	d,3
		jr	.dok
.notflume:	ld	a,[any_table]
		or	a
		jr	z,.notable
		ld	d,0
		cp	TABLEGAME_HAPPY
		jr	nz,.nothappy
		ld	a,[b2_lightbits]
		jr	.bits
.nothappy:
		cp	TABLEGAME_FANTASY
		jr	nz,.dok
		ld	a,[b2_fantasybits]
.bits:		bit	CODE_LEFTSCOOP,a
		ld	d,1	;yellow
		jr	nz,.dok
.red:		ld	d,2	;red
		jr	.dok
.notable:
		ld	a,[b2_done]
		inc	a
		jr	z,.red

;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_rollers]
;		cp	[hl]
;		jr	c,.lockshigher
		ld	a,[b2_finishedbits]
		bit	BIT_ROLLERS,a
		jr	z,.lockshigher
		bit	BIT_THRILL,a
		jr	nz,.lockshigher
.lockslower:
		ld	d,1
		ld	a,[b2_thrillgame]
		or	a
		jr	nz,.dok
		ld	d,3
		ld	a,[b2_leftlocked]
		or	a
		jr	nz,.dok
		jr	.d0
.lockshigher:	ld	d,3
		ld	a,[b2_leftlocked]
		or	a
		jr	nz,.dok
		ld	d,1
		ld	a,[b2_thrillgame]
		or	a
		jr	nz,.dok
.d0:		ld	d,0
.dok:		ret


phaserightscoop:
		ld	e,B2_RIGHTSCOOP
		call	rightscooplight
		jp	newstate

rightscooplight:
		ld	a,[b2_hide]
		cp	CODE_RIGHTSCOOP
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.notflume
		ld	a,[any_mlock2]
		or	a
		ld	d,2
		jr	nz,.dok
		call	mlockpossible
		jr	c,.d0
		ld	d,3
		jr	.dok
.notflume:	ld	a,[any_table]
		or	a
		jr	z,.notable
		ld	d,0
		cp	TABLEGAME_HAPPY
		jr	nz,.nothappy
		ld	a,[b2_lightbits]
		jr	.bits
.nothappy:
		cp	TABLEGAME_FANTASY
		jr	nz,.dok
		ld	a,[b2_fantasybits]
.bits:		bit	CODE_RIGHTSCOOP,a
		ld	d,1	;yellow
		jr	nz,.dok
.red		ld	d,2	;red
		jr	.dok
.notable:
		ld	a,[b2_done]
		inc	a
		jr	z,.red


;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_flumes]
;		cp	[hl]
;		jr	c,.lockshigher
		ld	a,[b2_finishedbits]
		bit	BIT_FLUMES,a
		jr	z,.lockshigher
		bit	BIT_FUN,a
		jr	nz,.lockshigher
.lockslower:
		ld	d,1
		ld	a,[b2_fungame]
		or	a
		jr	nz,.dok
		ld	d,3
		ld	a,[b2_rightlocked]
		or	a
		jr	nz,.dok
		jr	.d0
.lockshigher:
		ld	d,3
		ld	a,[b2_rightlocked]
		or	a
		jr	nz,.dok
		ld	d,1
		ld	a,[b2_fungame]
		or	a
		jr	nz,.dok
.d0:		ld	d,0
.dok:		ret

mlockpossible:
		call	CountBalls
		cp	2
		ret

phaseleft:
		ld	e,B2_LEFT
		ld	a,[b2_hide]
		cp	CODE_LEFT
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_skill]
		cp	SKILLSAFE
		jr	nc,.red
		ld	d,3
		ld	a,[any_combo1]
		cp	2
		jr	z,.dok
		ld	d,0
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		jr	z,.red
		cp	TABLEGAME_FANTASY
		jr	z,.fantasy
		cp	TABLEGAME_HAPPY
		jr	z,.lightsout
		cp	TABLEGAME_ROLLERMULTI
		jr	nz,.nojackreset
		ldh	a,[pin_difficulty]
		cp	2
		jr	nz,.nojackreset
		ld	a,[b2_jackready]
		or	a
		jr	z,.red
.nojackreset:	jr	.dok
.red:		ld	d,2	;red
		jr	.dok
.lightsout:	ld	a,[b2_lightbits]
		jr	.bits
.fantasy:	ld	a,[b2_fantasybits]
.bits:		bit	CODE_LEFT,a
		ld	d,1	;yellow
		jr	nz,.dok
		inc	d	;red
.dok:		jp	newstate

phaseright:
		ld	e,B2_RIGHT
		ld	a,[b2_hide]
		cp	CODE_RIGHT
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_skill]
		cp	SKILLSAFE
		jr	nc,.red
		ld	d,3
		ld	a,[any_combo2]
		cp	2
		jr	z,.dok
		ld	d,0
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		jr	z,.red
		cp	TABLEGAME_FANTASY
		jr	z,.fantasy
		cp	TABLEGAME_HAPPY
		jr	z,.lightsout
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.nojackreset
		ldh	a,[pin_difficulty]
		cp	2
		jr	nz,.nojackreset
		ld	a,[b2_jackready]
		or	a
		jr	z,.red
.nojackreset:	jr	.dok
.red:		ld	d,2	;red
		jr	.dok
.lightsout:	ld	a,[b2_lightbits]
		jr	.bits
.fantasy:	ld	a,[b2_fantasybits]
.bits:		bit	CODE_RIGHT,a
		ld	d,1	;yellow
		jr	nz,.dok
		inc	d	;red
.dok:		jp	newstate


phaseleftramp:
		ld	e,B2_LEFTRAMP
		ld	a,[b2_hide]
		cp	CODE_LEFTRAMP
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_skill]
		cp	SKILLSAFE
		jr	nc,.yellow

		ld	d,0
		ld	a,[b2_jackready]
		or	a
		jr	z,.notmulti
		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	z,.superflume
		cp	TABLEGAME_ROLLERMULTI
		jr	nz,.notmulti
		ld	a,[any_1234]
		cp	3
		jr	c,.d3
		jr	.notmulti
.superflume:	ld	a,[any_1234]
		cp	3
		jr	z,.d4
.notmulti:	ld	a,[any_combo1]
		cp	3
		jr	z,.d5
		ld	a,[any_combo2]
		cp	1
		jr	z,.d5
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		jr	z,.yellow
		cp	TABLEGAME_HAPPY
		jr	nz,.notlightsout
		ld	a,[b2_lightbits]
		jr	.bits
.notlightsout:
		cp	TABLEGAME_FANTASY
		jr	nz,.dok
		ld	a,[b2_fantasybits]
.bits:		bit	CODE_LEFTRAMP,a
		jr	z,.red
.yellow:	ld	d,1
		jr	.dok
.red:		ld	d,2
		jr	.dok
.d4:		ld	d,4
		jr	.dok
.d3:		ld	d,3
		jr	.dok
.d5:		ld	d,5
		jr	.dok
.d1:		inc	d
.dok:		jp	newstate

phaserightramp:
		ld	e,B2_RIGHTRAMP
		ld	a,[b2_hide]
		cp	CODE_RIGHTRAMP
		jr	nz,.nohide
		ld	a,[b2_hidecollect]
		or	a
		jr	z,.red
.nohide:
		ld	a,[any_skill]
		cp	SKILLSAFE
		jr	nc,.yellow

		ld	d,0
		ld	a,[b2_jackready]
		or	a
		jr	z,.notmulti
		ld	a,[any_inmulti]
		cp	TABLEGAME_ROLLERMULTI
		jr	z,.superroller
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.notmulti
		ld	a,[any_1234]
		cp	3
		jr	c,.d3
		jr	.notmulti
.superroller:	ld	a,[any_1234]
		cp	3
		jr	z,.d4
.notmulti:	ld	a,[any_combo1]
		cp	1
		jr	z,.d5
		ld	a,[any_combo2]
		cp	3
		jr	z,.d5
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		jr	z,.yellow
		cp	TABLEGAME_HAPPY
		jr	nz,.notlightsout
		ld	a,[b2_lightbits]
		jr	.bits
.notlightsout:
		cp	TABLEGAME_FANTASY
		jr	nz,.dok
		ld	a,[b2_fantasybits]
.bits:		bit	CODE_RIGHTRAMP,a
		jr	z,.red
.yellow:	ld	d,1
		jr	.dok
.red:		ld	d,2
		jr	.dok
.d4:		ld	d,4
		jr	.dok
.d3:		ld	d,3
		jr	.dok
.d5:		ld	d,5
		jr	.dok
.d1:		inc	d
.dok:		jp	newstate


phasejackpot:
		ld	e,B2_JACKPOT
		ld	c,0
		ld	a,[any_inmulti]
		or	a
		jr	z,.cok
		ld	a,[any_1234]
		cp	3
		jr	nc,.cok
		inc	c
.cok:		ld	a,c
		jp	phaseflashing



phaseindicatorcenter:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		jp	showboardtimer

phaseindicator0:			;(DONE)5 Thrill zone games
		ld	a,[any_tvput]
		ld	e,a
		ld	a,[any_tvtake]
		ld	d,a
		ld	a,[any_tvhold]
		or	a
		jr	z,.nohold
		dec	a
		ld	[any_tvhold],a
		ret	nz
		ld	a,e
		cp	d
		jr	z,.restore
.nohold:	ld	a,e
		cp	d
		jr	z,.normal
		jp	b2tvpop
.restore:	ld	a,-1
		ld	[wStates+B2_TIMER10S],a
		ld	[wStates+B2_TIMER1S],a
.normal:
		ld	de,B2_MODES+0
;Thrill zone complete
		ld	a,[b2_finishedbits]
		bit	BIT_THRILL,a
		jr	z,.dok
		ld	hl,b2_done
		set	0,[hl]
		inc	d
.dok:
		jp	b2indicators
phaseindicator1:			;Snack bar food
		ld	de,B2_MODES+1
		call	enoughtreats
		jr	c,.dok
		ld	hl,b2_done
		set	1,[hl]
		inc	d
.dok:
		jp	b2indicators
phaseindicator2:			;Ride photos
		ld	de,B2_MODES+2
		ld	b,255
		ld	a,[b2_warps]
		add	a
		jr	c,.bok
		add	3
		jr	c,.bok
		ld	b,a
.bok:		ld	a,[b2_ridephotos]
		cp	b
		jr	c,.dok
		ld	hl,b2_done
		set	2,[hl]
		inc	d
.dok:		jr	b2indicators

phaseindicator3:			;Roller multiball complete
		ld	de,B2_MODES+3
;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_rollers]
;		cp	[hl]
;		jr	c,.dok
		ld	a,[b2_finishedbits]
		bit	BIT_ROLLERS,a
		jr	z,.dok
		ld	hl,b2_done
		set	3,[hl]
		inc	d
.dok:
		jr	b2indicators

jacksneeded:	db	7,9,11




phaseindicator4:			;Flume multiball complete
		ld	de,B2_MODES+4
;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_flumes]
;		cp	[hl]
;		jr	c,.dok
		ld	a,[b2_finishedbits]
		bit	BIT_FLUMES,a
		jr	z,.dok
		ld	hl,b2_done
		set	4,[hl]
		inc	d
.dok:
		jr	b2indicators

phaseindicator5:			;Funzone games complete
		ld	de,B2_MODES+5
;Fun zone complete
		ld	a,[b2_finishedbits]
		bit	BIT_FUN,a
		jr	z,.dok
		ld	hl,b2_done
		set	5,[hl]
		inc	d
.dok:		jr	b2indicators

phaseindicator6:			;Fantasy mode complete
		ld	de,B2_MODES+6
;FANTASY complete
		ld	a,[b2_fantasydone]
		or	a
		jr	z,.dok
		ld	hl,b2_done
		set	6,[hl]
		inc	d
.dok:		jr	b2indicators
phaseindicator7:			;Brass rings
		ld	de,B2_MODES+7
		ld	b,255
		ld	a,[b2_warps]
		add	a
		jr	c,.bok
		add	3
		jr	c,.bok
		ld	b,a
.bok:		ld	a,[b2_brassrings]
		cp	b
		jr	c,.dok
		ld	hl,b2_done
		set	7,[hl]
		inc	d
.dok:

;c=# of indicator to process
b2indicators:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		jp	newstate


phasesaver:
		ld	a,[any_ballsaver]
		cp	3
		jr	c,.nosaver
		ld	d,1
		cp	5
		jr	nc,.dok
		bit	4,b
		jr	z,.dok
		ld	d,0
		jr	.dok
.nosaver:	ld	d,0
.dok:		ld	e,B2_SAVER
		jp	newstate

phaseextra:	ld	a,[any_extraball]
		or	a
		ld	d,0
		jr	z,.dok
		inc	d
.dok:		ld	e,B2_EXTRA
		jp	newstate

phasesnackbar:
		ld	e,B2_SNACKBAR
		ld	d,1
		ld	a,[any_skill]
		cp	SKILLSAFE
		jr	nc,.dok
		ld	d,6
		ld	a,[any_combo2]
		cp	4
		jr	z,.dok
		ld	d,4
		ld	a,[any_extra]
		or	a
		jr	nz,.dok
		ld	a,[any_table]
		cp	TABLEGAME_FANTASY
		jr	nz,.notfantasy2
		ld	a,[b2_fantasybits]
		bit	CODE_SNACKBAR,a
		jr	z,.red
.notfantasy2:
		ld	a,[any_table]
		cp	TABLEGAME_HIDE]
		jr	nz,.nothide
		ld	a,[b2_hidecollect]
		or	a
		jr	nz,.red
		ld	a,[b2_hide]
		cp	CODE_SNACKBAR
		jr	z,.red
.nothide:	ld	d,5
		ld	a,[b2_awardready]
		or	a
		jr	nz,.dok
		ld	d,0
		ld	a,[any_table]
		cp	TABLEGAME_FANTASY
		jr	z,.fantasy
		cp	TABLEGAME_HAPPY
		jr	z,.lightsout
		cp	TABLEGAME_FLUMEMULTI
		jr	z,.jackreset
		cp	TABLEGAME_ROLLERMULTI
		jr	nz,.nojackreset
.jackreset:	ldh	a,[pin_difficulty]
		cp	1
		jr	nz,.nojackreset
		ld	a,[b2_jackready]
		or	a
		jr	z,.red
.nojackreset:	jr	.dok
.lightsout:	ld	a,[b2_lightbits]
		jr	.bits
.fantasy:	ld	a,[b2_fantasybits]
.bits:		bit	CODE_SNACKBAR,a
		ld	d,1	;yellow
		jr	nz,.dok
.red:		ld	d,2	;red
.dok:		jp	newstate

phaseflashing:
		ld	c,1
phaseflashing2:
		ld	d,0
		bit	5,b
		jr	z,.dok
		or	a
		jr	z,.dok
		ld	d,c
.dok:		jp	newstate
phasesolid:	ld	d,0
		or	a
		jr	z,.dok
		inc	d
.dok:		jp	newstate

b2leftpop:	ld	a,[b2_leftpops]
		ld	de,B2_LEFTPOP
		jr	b2newpopstate
b2centerpop:	ld	a,[b2_centerpops]
		ld	de,B2_CENTERPOP
		jr	b2newpopstate
b2rightpop:	ld	a,[b2_rightpops]
		ld	de,B2_RIGHTPOP
b2newpopstate:	cp	POPBLUE
		jr	c,.dok
		inc	d
		inc	d
		cp	POPGREEN
		jr	c,.dok
		inc	d
		inc	d
.dok:		jp	newstate

b2leftbumper:	ld	de,B2_LEFTBUMPER
		jp	newstate
b2rightbumper:	ld	de,B2_RIGHTBUMPER
		jp	newstate


;returns Z flag if all at max
advancetops:	ld	c,POPBLUE
		ld	d,2
		ld	e,B2_LEFTPOP
		ld	hl,b2_leftpops
		call	.try
		ld	e,B2_CENTERPOP
		ld	hl,b2_centerpops
		call	.try
		ld	e,B2_RIGHTPOP
		ld	hl,b2_rightpops
		call	.try
		ld	c,POPGREEN
		ld	d,4
		ld	e,B2_LEFTPOP
		ld	hl,b2_leftpops
		call	.try
		ld	e,B2_CENTERPOP
		ld	hl,b2_centerpops
		call	.try
		ld	e,B2_RIGHTPOP
		ld	hl,b2_rightpops
		call	.try
		xor	a
		ret
.try:		ld	a,[hl]
		cp	c
		ret	nc
		ld	[hl],c
		pop	hl
		call	explodepop
		call	newstate
		xor	a
		inc	a
		ret


LEFTRAMPX	EQU	126/2
LEFTRAMPY	EQU	367/2

RIGHTRAMPX	EQU	308/2
RIGHTRAMPY	EQU	384/2

board2collisions:
		dw	b2firedown,217/2,37/2
		db	4,3
		dw	b2enterleftramp,LEFTRAMPX,LEFTRAMPY
		db	9,8
		dw	b2exitleftramp,63/2,522/2
		db	5,3
		dw	b2enterrightramp,RIGHTRAMPX,RIGHTRAMPY
		db	9,11
		dw	b2exitrightramp,287/2,522/2
		db	5,3
		dw	happy1,18,528/2
		db	3,3
		dw	happy2,32,528/2
		db	3,3
		dw	happy3,46,528/2
		db	3,3
		dw	happy4,143,528/2
		db	3,3
		dw	happy5,158,528/2
		db	3,3
		dw	rides1,58,52-6
		db	5,4
		dw	rides2,73,46-6
		db	5,4
		dw	rides3,88,44-6
		db	5,4
		dw	rides4,103,46-6
		db	5,4
		dw	rides5,118,52-6
		db	5,4
		dw	hitrightkick,157,294
		db	4,9
		dw	hitleftkick,17,294
		db	4,9
		dw	enterleft,E2X>>5,E2Y>>5
		db	4,4
		dw	enterright,E3X>>5,E3Y>>5
		db	4,4
		dw	entersnackbar,E1X>>5,E1Y>>5
		db	5,5
		dw	b2loop1,30,159
		db	6,6
		dw	b2loop2,36,43
		db	6,6
		dw	b2loop3,140,43
		db	6,6
		dw	b2loop4,142,163
		db	6,6
		dw	hitspinner,SPINNERX,SPINNERY
		db	6,6
		dw	b2shoot,347/2,318/2
		db	6,6
		dw	0


b2loop1:	ld	a,[b2_loop]
		cp	-3
		jr	z,rightloop
		jr	loopset1
b2loop4:	ld	a,[b2_loop]
		cp	3
		jr	z,leftloop
		jr	loopsetm1
b2loop2:	ld	a,[b2_loop]
		cp	2
		ret	z
		cp	-3
		ret	z
		cp	1
		jr	z,loopset2
		cp	-2
		jr	z,loopsetm3
		jr	loopset0
b2loop3:	ld	a,[b2_loop]
		cp	3
		ret	z
		cp	-2
		ret	z
		cp	2
		jr	z,loopset3
		cp	-1
		jr	z,loopsetm2
		jr	loopset0

loopset0:	xor	a
		ld	[b2_loop],a
		ret
loopset2:	ld	a,2
		ld	[b2_loop],a
		ret
loopset3:	ld	a,3
		ld	[b2_loop],a
		ret
loopsetm2:	ld	a,-2
		ld	[b2_loop],a
		ret
loopsetm3:	ld	a,-3
		ld	[b2_loop],a
		ret
loopset1:	ld	a,1
		ld	[b2_loop],a
		ret
loopsetm1:	ld	a,-1
		ld	[b2_loop],a
		ret

rightloop:
		call	b2loopcredit
		ld	bc,(MASK_RIGHT<<8)+CODE_RIGHT
		call	allridesbit
		call	fantasybit
		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.nochargejack
		ldh	a,[pin_difficulty]
		cp	2
		jr	nz,.nochargejack
		ld	a,TV_JACKREADY
		call	showtv
		ld	a,1
		ld	[b2_jackready],a
.nochargejack:
		ld	c,CODE_RIGHT
		call	didloop
		jr	loopset1
leftloop:
		call	b2loopcredit
		ld	bc,(MASK_LEFT<<8)+CODE_LEFT
		call	allridesbit
		call	fantasybit
		ld	a,[any_inmulti]
		cp	TABLEGAME_ROLLERMULTI
		jr	nz,.nochargejack
		ldh	a,[pin_difficulty]
		cp	2
		jr	nz,.nochargejack
		ld	a,TV_JACKREADY
		call	showtv
		ld	a,1
		ld	[b2_jackready],a
.nochargejack:
		ld	c,CODE_LEFT
		call	didloop
		jr	loopsetm1

b2loopcredit:	ld	de,loopscore
		jp	addscore

;c=code
didloop:
		push	bc
		call	trybrassring
		ld	a,[any_skill]
		or	a
		call	nz,superskill
		pop	bc

		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		call	z,thrillloop
		ld	a,FX_ORBIT
		call	InitSfx

didramp:
		ld	a,c
		call	combocheck
		ld	bc,(0<<8)|2
		call	IncBonusVal	;2000 points for ramps + loops
		ld	a,[any_skill]
		or	a
		call	nz,normalskill

		ret

;a=new event
combocheck:
		ld	c,a
		ld	a,COMBOCLEARTIME
		ld	[any_comboclear],a

		ld	d,0

		ld	a,[any_combo1]
.retry1:	ld	e,a
		ld	hl,b2combo1
		add	hl,de
		ld	a,[hl]
		cp	c
		jr	z,.cont1
		ld	a,e
		or	a
		jr	z,.fail1
		xor	a
		jr	.retry1
.cont1:		ld	a,[any_combo1]
		inc	a
		cp	2
		jr	c,.good1
		push	af
		sub	2
		push	af
		ld	hl,b2combomsgs1
		call	flashlist
		ld	a,[any_combo1]
		call	ComboSound
		pop	af
		call	b2comboscore
		pop	af
		cp	5
		jr	c,.good1
.fail1:		xor	a
.good1:		ld	[any_combo1],a

		ld	a,[any_combo2]
.retry2:	ld	e,a
		ld	hl,b2combo2
		add	hl,de
		ld	a,[hl]
		cp	c
		jr	z,.cont2
		ld	a,e
		or	a
		jr	z,.fail2
		xor	a
		jr	.retry2
.cont2:		ld	a,[any_combo2]
		inc	a
		cp	2
		jr	c,.good2
		push	af
		sub	2
		push	af
		ld	hl,b2combomsgs2
		call	flashlist
		ld	a,[any_combo2]
		call	ComboSound
		pop	af
		call	b2comboscore
		pop	af
		cp	5
		jr	c,.good2
.fail2:		xor	a
.good2:		ld	[any_combo2],a

		ret

b2combo1:	db	CODE_RIGHT
		db	CODE_RIGHTRAMP
		db	CODE_LEFT
		db	CODE_LEFTRAMP
		db	CODE_SNACKBAR

b2combomsgs1:	dw	MSGCOMBO
		dw	MSGDOUBLECOMBO
		dw	MSGTRIPLECOMBO
		dw	MSGSUPERCOMBO

b2combo2:	db	CODE_LEFT
		db	CODE_LEFTRAMP
		db	CODE_RIGHT
		db	CODE_RIGHTRAMP
		db	CODE_SNACKBAR

b2combomsgs2:	dw	MSGREVERSECOMBO
		dw	MSGREVERSEDOUBLECOMBO
		dw	MSGREVERSETRIPLECOMBO
		dw	MSGREVERSESUPERCOMBO

b2comboscore:	or	a
		jr	z,.v1
		dec	a
		jr	z,.v2
		dec	a
		jr	z,.v3
		jr	.v4
.v1:		ld	hl,50
		jr	.any
.v2:		ld	hl,100
		jr	.any
.v3:		ld	hl,250
		jr	.any
.v4:		ld	hl,500
.any:		jp	addthousandshlinform

normalskill:	ld	hl,MSGNORMALSKILL
		call	statusflash
		ld	hl,normalskillsavers
		call	saverdifficulty

		ld	a,[b2_normalskill]
		ld	hl,50
		ld	de,10
		or	a
		jr	z,.nomore
.add:		add	hl,de
		dec	a
		jr	nz,.add
.nomore:	call	addthousandshlinform
		ld	a,TV_NORMALSKILL
		call	showtv
		ld	a,[b2_normalskill]
		cp	50
		jr	nc,.max
		inc	a
		ld	[b2_normalskill],a
.max:		jr	gotskill

superskill:	ld	hl,MSGSUPERSKILL
		call	statusflash
		ld	hl,superskillsavers
		call	saverdifficulty
		ldh	a,[pin_difficulty]
		or	a
		call	z,bothon
		ld	a,[b2_leftkick]
		or	a
		jr	nz,.either
		ld	a,[b2_rightkick]
		or	a
		jr	nz,.either
		call	rightonleftoff
.either:
		ld	a,[b2_superskill]
		ld	hl,150
		ld	de,50
		or	a
		jr	z,.nomore
.add:		add	hl,de
		dec	a
		jr	nz,.add
.nomore:	call	addthousandshlinform
		ld	a,TV_SUPERSKILL
		call	showtv
		ld	a,[b2_superskill]
		cp	50
		jr	nc,.max
		inc	a
		ld	[b2_superskill],a
.max:
gotskill:	xor	a
		ld	[any_skill],a
		ld	a,[b2_bonus]
		add	4
		cp	MAXBONUS
		jr	c,.aok
		ld	a,MAXBONUS
.aok:		ld	[b2_bonus],a
		ret


E1X		EQU	161<<4	;snack bar
E1Y		EQU	362<<4
E2X		EQU	79<<4	;left
E2Y		EQU	174<<4
E3X		EQU	267<<4	;right
E3Y		EQU	189<<4

E1VX		EQU	23
E1VY		EQU	23
E2VX		EQU	22
E2VY		EQU	22
E3VX		EQU	-25
E3VY		EQU	19

entersnackbar:	ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX
		ld	l,E1VY
		jr	b2traps
enterleft:	ld	de,E2X
		ld	bc,E2Y
		ld	h,E2VX
		ld	l,E2VY
		jr	b2traps
enterright:	ld	de,E3X
		ld	bc,E3Y
		ld	h,E3VX
		ld	l,E3VY
b2traps:	push	de
		push	bc
		call	passedby
		pop	bc
		pop	de
		or	a
		ret	nz
		jp	Eject



board2eject:	ldh	a,[pin_x]
		ld	c,a
		sub	255&E1X
		ld	e,a
		ldh	a,[pin_x+1]
		ld	b,a
		sbc	E1X>>8
		or	e
		jp	z,.take1
		ld	a,c
		sub	255&E2X
		ld	e,a
		ld	a,b
		sbc	E2X>>8
		or	e
		jp	z,.take2
		jp	.take3

.take1:						;snack bar
		ld	a,CODE_SNACKBAR
		call	combocheck
		ld	a,[b2_hidecollect]
		ldh	[hTmpLo],a
		ld	bc,(MASK_SNACKBAR<<8)+CODE_SNACKBAR
		call	allridesbit
		ld	a,[any_table]
		cp	TABLEGAME_HIDE
		jr	nz,.noadd1
		ld	hl,hidesnackbar
		call	addtabletime
.noadd1:

		ld	a,[any_skill]
		or	a
		jr	z,.noskill
		call	normalskill
		jp	.done1
.noskill:

		ld	a,[any_extra]
		or	a
		jr	z,.noextra
		dec	a
		ld	[any_extra],a
		call	b2doextraball
		jp	.done1
.noextra:
		ld	a,[any_table]
		cp	TABLEGAME_FANTASY
		jr	nz,.nofantasy1b
		ld	a,[b2_fantasybits]
		bit	CODE_SNACKBAR,a
		jr	z,.happy1
.nofantasy1b:

		ld	a,[any_table]
		cp	TABLEGAME_HIDE
		jr	nz,.nohide
		ldh	a,[hTmpLo]
		or	a
		jr	z,.nohide
		call	hidecollect
		jp	.done1
.nohide:
		ld	a,[b2_awardready]
		or	a
		jr	z,.noaward
		xor	a
		ld	[b2_awardready],a
		call	board2giveaward
		jp	.done1
.noaward:

		ld	a,[any_table]
		cp	TABLEGAME_FLUMEMULTI
		jr	z,.tryjackready
		cp	TABLEGAME_ROLLERMULTI
		jr	nz,.nojackready
.tryjackready:	ldh	a,[pin_difficulty]
		cp	1
		jr	nz,.nojackready
		ld	a,TV_JACKREADY
		call	showtv
		ld	a,1
		ld	[b2_jackready],a
.nojackready:

		call	treat
		ld	a,[any_table]
		or	a
		jr	z,.tryteleport
		cp	TABLEGAME_FLUMEMULTI
		jr	z,.tryteleport
		cp	TABLEGAME_HIDE
		jr	z,.tryteleportnotreat
		cp	TABLEGAME_HAPPY
		jr	z,.happy1
		cp	TABLEGAME_FANTASY
		jr	nz,.nofantasy1
.happy1:	ld	b,MASK_SNACKBAR
		ld	a,[b2_fantasybits]
		push	af
		call	fantasybit
		pop	bc
		ld	a,[b2_fantasybits]
		cp	b
		ld	a,[any_table]
		jr	nz,.nofantasyteleport
		cp	TABLEGAME_FANTASY
		jr	nz,.nofantasyteleport
		bit	CODE_LEFTSCOOP,b
		jr	z,.done1
		bit	CODE_RIGHTSCOOP,b
		jp	z,.done2
.nofantasyteleport:
		cp	TABLEGAME_HAPPY
		jr	nz,.done1
		ld	a,[b2_lightbits]
		bit	CODE_LEFTSCOOP,a
		jp	z,.done2
		bit	CODE_RIGHTSCOOP,a
		jp	z,.done3
		jr	.done1
.nofantasy1:
		jr	.noteleport
.tryteleport:
		ld	a,[b2_wanthide]
		cp	WANTHIDE
		jr	nc,.noteleport
.tryteleportnotreat:
		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.nolock1
		call	CountBalls
		cp	2
		jr	c,.noteleport
		ld	a,[any_mlock1]
		or	a
		jr	z,.lock11
		ld	a,[any_mlock2]
		or	a
		jr	nz,.noteleport
.lock12:	ld	a,1
		ld	[any_mlock2],a
		ld	a,SPITTIME
		ld	[b2_spit2],a
		jp	lockedmulti
.lock11:	ld	a,1
		ld	[any_mlock1],a
		ld	a,SPITTIME
		ld	[b2_spit1],a
		jp	lockedmulti
.nolock1:


		call	leftscooplight
		ld	a,d
		or	a
		jp	nz,.done2
		call	rightscooplight
		ld	a,d
		or	a
		jp	nz,.done3
.noteleport:


.done1:
		jp	b2set1

.take2:						;left scoop
		ld	bc,(MASK_LEFTSCOOP<<8)+CODE_LEFTSCOOP
		call	allridesbit

		ld	a,[any_table]
		or	a
		jr	z,.subs2

		cp	TABLEGAME_HAPPY
		jr	z,.happy2
		cp	TABLEGAME_FANTASY
		jr	nz,.nofantasy2
.happy2:	ld	b,MASK_LEFTSCOOP
		call	fantasybit
		jp	.done2
.nofantasy2:

		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.nolock2
		ld	a,[any_mlock1]
		or	a
		jr	nz,.nolock2
		call	CountBalls
		cp	2
		jr	c,.nolock2
		ld	a,1
		ld	[any_mlock1],a
		ld	a,SPITTIME
		ld	[b2_spit1],a
		jp	lockedmulti
.nolock2:

		jp	.nosubs2

.subs2:
		ld	a,[b2_done]
		inc	a
		jr	nz,.nolightsout2
		ld	a,SUBGAME_OUT
		jp	ChainSub
.nolightsout2:


;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_rollers]
;		cp	[hl]
;		jr	c,.lockshigher2
		ld	a,[b2_finishedbits]
		bit	BIT_ROLLERS,a
		jr	z,.lockshigher2
		bit	BIT_THRILL,a
		jr	nz,.lockshigher2
		ld	a,[b2_thrillgame]
		or	a
		jp	nz,.thrill
.lockshigher2:


		ld	a,[b2_leftlocked]
		or	a
		jr	z,.nolockball2

		xor	a
		ld	[b2_leftlocked],a
		ld	hl,b2_lefttrapped
		ld	a,[hl]
		cp	2
		jr	c,.leftnot2
		call	RumbleHigh
		ld	a,TABLEGAME_ROLLERMULTI
		call	startmulti
		ld	a,TV_ROLLERMULTI+3
		call	showtv
		ld	a,TABLEGAME_ROLLERMULTI
		ld	[any_table],a
		call	tablesong
		ld	hl,MSGROLLERMULTI
		call	statusflash
		ld	a,HOLDTIME/2+60
		ld	de,lefteject
		call	addtimed
		jp	.done1
.leftnot2:	inc	[hl]
		ld	a,[hl]
		add	TV_ROLLERMULTI
		call	showtv
		ld	a,FX_BALLLOCKED
		call	InitSfx
		ld	a,7
		call	board2popups
		xor	a
		ldh	[pin_ballflags],a
		ld	a,1
		ld	[any_wantfire],a
		ld	[any_weakball],a
		ret
.nolockball2:

		ld	a,[b2_thrillgame]
		or	a
.thrill:	jp	nz,thrillchain

.nosubs2:

.done2:
		jp	b2set2

.take3:						;right scoop
		ld	bc,(MASK_RIGHTSCOOP<<8)+CODE_RIGHTSCOOP
		call	allridesbit


		ld	a,[any_table]
		or	a
		jr	z,.subs3

		cp	TABLEGAME_HAPPY
		jr	z,.happy3
		cp	TABLEGAME_FANTASY
		jr	nz,.nofantasy3
.happy3:	ld	b,MASK_RIGHTSCOOP
		call	fantasybit
		jp	.done3
.nofantasy3:

		ld	a,[any_inmulti]
		cp	TABLEGAME_FLUMEMULTI
		jr	nz,.nolock3
		ld	a,[any_mlock2]
		or	a
		jr	nz,.nolock3
		call	CountBalls
		cp	2
		jr	c,.nolock3
		ld	a,1
		ld	[any_mlock2],a
		ld	a,SPITTIME
		ld	[b2_spit2],a
		jp	lockedmulti
.nolock3:
		jp	.nosubs3

.subs3:
		ld	a,[b2_done]
		inc	a
		jr	nz,.nolightsout3
		ld	a,SUBGAME_OUT
		jp	ChainSub
.nolightsout3:

;		ldh	a,[pin_difficulty]
;		ld	c,a
;		ld	b,0
;		ld	hl,jacksneeded
;		add	hl,bc
;		ld	a,[b2_flumes]
;		cp	[hl]
;		jr	c,.lockshigher3
		ld	a,[b2_finishedbits]
		bit	BIT_FLUMES,a
		jr	z,.lockshigher3
		bit	BIT_FUN,a
		jr	nz,.lockshigher3
		ld	a,[b2_fungame]
		or	a
		jp	nz,.fun
.lockshigher3:


		ld	a,[b2_rightlocked]
		or	a
		jr	z,.nolockball3

		xor	a
		ld	[b2_rightlocked],a
		ld	hl,b2_righttrapped
		ld	a,[hl]
		cp	2
		jr	c,.rightnot2
		call	RumbleHigh
		ld	a,TABLEGAME_FLUMEMULTI
		call	startmulti
		ld	a,TV_FLUMEMULTI+3
		call	showtv
		ld	a,TABLEGAME_FLUMEMULTI
		ld	[any_table],a
		call	tablesong
		ld	hl,MSGFLUMEMULTI
		call	statusflash
		ld	a,HOLDTIME/2+60
		ld	de,righteject
		call	addtimed
		jp	.done1
.rightnot2:	inc	[hl]
		ld	a,[hl]
		add	TV_FLUMEMULTI
		call	showtv
		ld	a,FX_BALLLOCKED
		call	InitSfx
		xor	a
		ldh	[pin_ballflags],a
		ld	a,1
		ld	[any_wantfire],a
		ld	[any_weakball],a
		ret
.nolockball3:
		ld	a,[b2_fungame]
		or	a
		jr	z,.nofunchain
.fun:		cp	1
		jp	nz,funchain
		call	startbumper
		jp	.done1
.nofunchain:
.nosubs3:


.done3:
		jp	b2set3

b2set1:		ld	de,E1X ;snack bar
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		jr	b2set

b2out2:		call	b2outs
b2set2:		ld	de,E2X ;left scoop
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		jr	b2set

b2outs:		ld	a,1<<BALLFLG_USED
		ldh	[pin_ballflags],a
		ld	a,HOLDTIME/2
		ldh	[pin_ballpause],a
		ret

b2out3:		call	b2outs
b2set3:		ld	de,E3X ;right scoop
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8

b2set:		ld	a,e
		ldh	[pin_x],a
		ld	a,d
		ldh	[pin_x+1],a
		ld	a,c
		ldh	[pin_y],a
		ld	a,b
		ldh	[pin_y+1],a
		ld	a,h
		ldh	[pin_vx],a
		add	a
		ld	a,0
		sbc	a
		ldh	[pin_vx+1],a
		ld	a,l
		ldh	[pin_vy],a
		add	a
		ld	a,0
		sbc	a
		ldh	[pin_vy+1],a
		jp	RumbleHigh

b2spit1:	ld	de,E1X		;snack bar
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		jr	b2spits
b2spit2:	ld	de,E2X		;left scoop
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		jr	b2spits
b2spit3:	ld	de,E3X		;right scoop
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8
b2spits:	call	AddBall
		ld	de,BALL_BALLPAUSE
		add	hl,de
		ld	[hl],HOLDTIME/2
		ret

lockedmulti:
		xor	a
		ldh	[pin_ballflags],a
		ldh	[pin_ballpause],a
		ret


jackvalue:
		ld	a,[any_mlock1]
		ld	b,a
		ld	a,[any_mlock2]
		add	b
		ld	b,a
		ld	a,[any_1234]
		cp	b
		jr	nc,.aok2
		ld	a,b
		ld	[any_1234],a
.aok2:		ld	a,[any_1234]
		ret

flumejackpot:
		ld	hl,b2_flumejack
		ld	bc,b2_flumes
		jr	jackpot

rollerjackpot:
		ld	hl,b2_rollerjack
		ld	bc,b2_rollers

;hl=value to add (in thousands)
jackpot:
		push	bc
		ld	e,[hl]
		ld	[hl],100
		inc	hl
		ld	d,[hl]
		ld	[hl],0
		ldh	a,[pin_difficulty]
		or	a
		jr	z,.noclear
		xor	a
		ld	[b2_jackready],a
.noclear:	call	jackvalue
		ld	a,[any_1234]
		add	TV_JACKPOTS
		push	de
		call	showtv
		pop	de
		ld	a,1
		ld	[any_spitout],a
		ld	a,[any_1234]
		ld	b,a
		inc	b
		ld	c,FX_JACKPOT
		or	a
		jr	z,.hlok
		dec	a
		jr	z,.hlok
		dec	a
		jr	z,.hlok
		inc	b
		ld	c,FX_SUPERJACK
.hlok:		pop	hl
		ld	a,[hl]
		add	b
		jr	nc,.aok
		ld	a,-1
.aok:		ld	[hl],a
		push	de
		ld	a,c
		push	bc
		call	InitSfx
		pop	bc
		pop	de
		ld	hl,0
.addlp:		add	hl,de
		dec	b
		jr	nz,.addlp
		call	addthousandshlinform
		ld	hl,any_1234
		inc	[hl]
		ld	a,[hl]
		cp	4
		jr	c,.mok
		xor	a
		ld	[hl],a
.mok:
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,jacksneeded
		add	hl,bc
		ld	a,[b2_warps]
		ld	b,255
		add	a
		jr	c,.bok
		add	[hl]
		jr	c,.bok
		ld	b,a
.bok:		
		ld	a,[b2_finishedbits]	
		ld	c,a
		ld	a,[b2_flumes]
		cp	b
		jr	c,.moreflumes
		set	BIT_FLUMES,c
.moreflumes:
		ld	a,[b2_rollers]
		cp	b
		jr	c,.morerollers
		set	BIT_ROLLERS,c
.morerollers:	ld	a,c
		ld	[b2_finishedbits],a
		ret

lefteject:	ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b2_lefttrapped
		dec	[hl]
		ret	z
		ld	a,60
		ld	de,lefteject
		jp	addtimed

righteject:	ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b2_righttrapped
		dec	[hl]
		ret	z
		ld	a,60
		ld	de,righteject
		jp	addtimed

fungames:
		db	SUBGAME_FALCON	;bumper cars
		db	SUBGAME_FALCON
		db	SUBGAME_BUILD
		db	SUBGAME_RAPIDS
		db	SUBGAME_KISS

thrillgames:
		db	SUBGAME_BEAR
		db	SUBGAME_LOOPER
		db	SUBGAME_RACE
		db	SUBGAME_BOAT
		db	SUBGAME_SIDE


rand5:		call	random
		and	7
		cp	5
		jr	nc,rand5
		ld	c,a
		inc	c
		ld	de,Bits
		add	e
		ld	e,a
		jr	nc,.noincd
		inc	d
.noincd:	ld	a,[de]
		and	h
		jr	nz,rand5
		ld	a,[de]
		or	l
		ld	l,a
		ld	a,c
		ret

tryfunzone:	ld	a,[b2_fungame]
		or	a
		jr	nz,nozone
		ld	a,[b2_funzone]
		ld	h,a
		ld	a,[b2_lastfun]
		ld	l,a
		or	h
		cp	$1f
		jr	nz,.ok
		ld	l,0
		ld	a,h
.ok:		ld	h,a
		call	rand5
		ld	[b2_fungame],a
		ld	a,l
		ld	[b2_lastfun],a
		ld	a,TV_FUNLIT
		jp	showtv

trythrillzone:
		ld	a,[b2_thrillgame]
		or	a
		jr	nz,nozone
		ld	a,[b2_thrillzone]
		ld	h,a
		ld	a,[b2_lastthrill]
		ld	l,a
		or	h
		cp	$1f
		jr	nz,.ok
		ld	l,0
		ld	a,h
.ok:		ld	h,a
		call	rand5
		ld	[b2_thrillgame],a
		ld	a,l
		ld	[b2_lastthrill],a
		
		ld	a,TV_THRILLLIT
		jp	showtv

nozone:		jp	dorelit

funchain:	ld	hl,b2_fungame
		ld	[hl],-1
		ld	hl,fungames-1
		jr	anychain
thrillchain:	ld	hl,b2_thrillgame
		ld	[hl],-1
		ld	hl,thrillgames-1
anychain:	call	addahl
		ld	a,[b2_funzone]
		ld	[wFunZone],a
		ld	a,[b2_thrillzone]
		ld	[wThrillZone],a
		ld	a,[hl]
		jp	ChainSub
b2unchain:
		ld	a,[wSubCompleted]
		or	a
		ld	hl,subcompletedsavers
		jr	nz,.hlok
		ld	hl,subnotcompletedsavers
.hlok:		call	saverdifficulty

		ld	hl,wTiltTimes
		ld	bc,32
		call	MemClear
		ld	a,[b2_done]
		inc	a
		jr	z,.waslightsout
		ld	a,[wFunZone]
		cp	$1f
		jr	nz,.nofunall
		ld	hl,b2_finishedbits
		set	BIT_FUN,[hl]
		xor	a
.nofunall:	ld	[b2_funzone],a

		ld	a,[wThrillZone]
		cp	$1f
		jr	nz,.nothrillall
		ld	hl,b2_finishedbits
		set	BIT_THRILL,[hl]
		xor	a
.nothrillall:	ld	[b2_thrillzone],a

		ld	hl,b2_fungame
		ld	a,[hl]
		inc	a
		jr	nz,.no3
		ld	[hl],a
		jp	b2spit3
.no3:
		ld	hl,b2_thrillgame
		ld	a,[hl]
		inc	a
		jr	nz,.no2
		ld	[hl],a
		jp	b2spit2
.no2:
		ret

.waslightsout:
		xor	a
		ld	[b2_funzone],a
		ld	[b2_thrillzone],a
		ld	[b2_brassrings],a
		ld	[b2_ridephotos],a
		ld	[b2_flumes],a
		ld	[b2_rollers],a
		ld	[b2_allrides],a
		ld	[b2_fantasydone],a
		ld	[b2_treatstaken],a
		ld	[b2_done],a
		ld	[b2_fantasybits],a
		ld	[b2_finishedbits],a
		call	incwarp
		jp	b2spit1

b2enterleftramp:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	LEFTRAMPX-20*2
		ld	d,a

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	LEFTRAMPY+20
		add	a
		add	d
		add	a
		ld	c,0
		jr	nc,.cok
		ld	c,1<<BALLFLG_LAYER
.cok:
		ldh	a,[pin_ballflags]
		and	255-(1<<BALLFLG_LAYER)
		or	c
		ldh	[pin_ballflags],a
		jp	setleftramp


b2exitleftramp:	ld	h,0
		ld	l,32
		call	passedby
		or	a
		ret	z
		ldh	a,[pin_ballflags]
		ld	b,a
		and	255-(1<<BALLFLG_LAYER)
		ldh	[pin_ballflags],a
		cp	b
		ret	z
		ld	a,FX_RAMP
		call	InitSfx
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		call	z,thrillramp
		xor	a
		call	setleftramp
		ld	bc,(MASK_LEFTRAMP<<8)+CODE_LEFTRAMP
		call	allridesbit
		call	fantasybit
		ld	c,CODE_LEFTRAMP
		call	didramp
		call	tryridephoto
		ld	a,[b2_jackready]
		or	a
		jr	z,.normalramp
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalramp
		cp	TABLEGAME_HAPPY
		jr	z,.normalramp
		cp	TABLEGAME_FLUMEMULTI
		ld	a,[any_1234]
		jr	z,.flume
		cp	3
		jp	c,rollerjackpot
		jr	.normalramp
.flume:		cp	3
		jp	z,flumejackpot
.normalramp:	ld	a,[any_table]
		or	a
		call	z,showrollerlocked
		ret

b2enterrightramp:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	RIGHTRAMPX-20*2
		ld	d,a

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	RIGHTRAMPY-20*2
		sub	d
		add	a
		ld	c,0
		jr	nc,.cok
		ld	c,1<<BALLFLG_LAYER
.cok:
		ldh	a,[pin_ballflags]
		and	255-(1<<BALLFLG_LAYER)
		or	c
		ldh	[pin_ballflags],a
		jp	setrightramp


b2exitrightramp:
		ld	h,0
		ld	l,32
		call	passedby
		or	a
		ret	z
		ldh	a,[pin_ballflags]
		ld	b,a
		and	255-(1<<BALLFLG_LAYER)
		ldh	[pin_ballflags],a
		cp	b
		ret	z
		ld	a,FX_RAMP
		call	InitSfx
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		call	z,thrillramp
		call	b2ramp
		ld	de,rampscore
		call	addscore
		xor	a
		call	setrightramp
		ld	a,[b2_rightlocked]
		or	a
		jr	nz,.notolock
		ld	a,[b2_rightramps]
		inc	a
		cp	3
		jr	c,.notenough
		ld	a,1
		ld	[b2_rightlocked],a
		call	b2showlockopen
		xor	a
.notenough:	ld	[b2_rightramps],a
.notolock:
		ld	bc,(MASK_RIGHTRAMP<<8)+CODE_RIGHTRAMP
		call	allridesbit
		call	fantasybit
		ld	c,CODE_RIGHTRAMP
		call	didramp
		ld	a,[b2_jackready]
		or	a
		jr	z,.normalramp
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalramp
		cp	TABLEGAME_HAPPY
		jr	z,.normalramp
		cp	TABLEGAME_ROLLERMULTI
		ld	a,[any_1234]
		jr	z,.roller
		cp	3
		jp	c,flumejackpot
		jr	.normalramp
.roller:	cp	3
		jp	z,rollerjackpot
.normalramp:
		ld	a,[any_table]
		or	a
		call	z,showflumelocked
		ret

allridesbit:	ld	a,[b2_allrides]
		or	b
		ld	[b2_allrides],a
		jp	tryhidecollect
fantasybit:	ld	a,[any_table]
		cp	TABLEGAME_HAPPY
		jr	z,lightsoutbit
		cp	TABLEGAME_FANTASY
		ret	nz
		ld	a,b
		ld	hl,b2_fantasybits
		or	[hl]
		cp	[hl]
		jr	z,.same
		ld	[hl],a
		ld	a,FX_FANTASYBIT
		call	InitSfx
		ld	hl,fantasyred
;lit another fantasy bit
		jr	.double
.same:		ld	a,FX_FANTASYYELLOW
		call	InitSfx
		ld	hl,fantasyyellow
.double:
;hl=list for easy,mesium,hard
addtabletime:	ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	e,[hl]
		ld	hl,tabletimes
		add	hl,bc
		ld	c,[hl]
		ld	a,[any_tabletime]
		add	e
		cp	c
		jr	c,.aok
		ld	a,c
.aok:		ld	[any_tabletime],a
		ret
;easy,medium, hard for red arrow
;easy,medium, hard for yellow arrow
fantasyred:	db	6*2,4*2,2*2
fantasyyellow:
		db	3*2,2*2,1*2
hidefound:	db	12*2,8*2,4*2
hidecollected:	db	16*2,12*2,8*2
hidesnackbar:	db	4*2,2*2,1*2

lightsoutbit:	ld	hl,b2_lightbits
		ld	a,b
		or	[hl]
		cp	[hl]
		jr	z,.same
		ld	[hl],a
		cp	$fe
		jr	nz,.aok
		xor	a
		ld	[b2_lightbits],a
		ld	hl,5000
		jr	.full
.aok:		ld	hl,250
.full:		call	addthousandshlinform
		ld	a,FX_LIGHTSBIT
		jp	InitSfx
.same:		ld	hl,10
		jp	addthousandshlinform


showflumelocked:
		ld	a,[b2_righttrapped]
		add	TV_FLUMEMULTI
		jp	showtv
showrollerlocked:
		ld	a,[b2_lefttrapped]
		add	TV_ROLLERMULTI
		jp	showtv


thrillpopcreditsblue:
		db	6,3,2
thrillpopcreditsgreen:
		db	12,6,3
thrillpopcreditsorange:
		db	18,12,6
thrillrampcredits:
		db	36,24,12
thrillloopcredits:
		db	48,36,24
thrillpop:	push	hl		;d=1,3,5
		push	af
		ld	a,d
		dec	a
		ld	hl,thrillpopcreditsblue
		jr	z,thrillcredit
		dec	a
		dec	a
		ld	hl,thrillpopcreditsgreen
		jr	z,thrillcredit
		ld	hl,thrillpopcreditsorange
		jr	thrillcredit
thrillloop:	push	hl
		push	af
		ld	hl,thrillloopcredits
		jr	thrillcredit
thrillramp:	push	hl
		push	af
		ld	hl,thrillrampcredits
thrillcredit:	ldh	a,[pin_difficulty]
		add	l
		ld	l,a
		jr	nc,.noinch
		inc	h
.noinch:	ld	a,[b2_12guage]
		add	[hl]
		ld	[b2_12guage],a
		pop	af
		pop	hl
		ret




b2ramp:
		ld	hl,b2_rampcount
		inc	[hl]
		ld	e,[hl]
		ld	d,HIGH(RampAwards)
		ld	a,[de]
		or	a
		ret	z
		dec	a
		jp	z,advancebonus
		dec	a
		jp	z,b2showmultheld
		jp	doextraopen

RAMPSET:	MACRO
		ld	hl,$d000+2*((\1/8)+24*(\2/8))
		set	3,[hl]
		ENDM
RAMPRESET:	MACRO
		ld	hl,$d000+2*((\1/8)+24*(\2/8))
		res	3,[hl]
		ENDM
RAMPMARK:	MACRO
		ld	a,\1/8
		call	MarkDirty
		ENDM

setleftramp:	and	1<<BALLFLG_LAYER
		jp	nz,leftrampdown
leftrampup:	ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	z
		res	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPSET	16,144
		RAMPSET	24,144
		RAMPSET	32,144
		RAMPSET	16,152
		RAMPSET	24,152
		RAMPSET	32,152
		RAMPSET	16,184
		RAMPSET	8,192
		RAMPSET	16,192
		RAMPSET	8,200
		RAMPSET	16,200
		RAMPSET	8,208
		RAMPSET	16,208
		RAMPSET	8,216
		RAMPSET	16,216
		RAMPSET	8,224
		RAMPSET	16,224
		RAMPSET	24,224
		RAMPSET	8,232
		RAMPSET	16,232
		RAMPSET	24,232
		RAMPSET	32,232
		RAMPSET	24,240
		RAMPSET	32,240
		jp	b2rampmarks
leftrampdown:	ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	nz
		set	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPRESET	16,144
		RAMPRESET	24,144
		RAMPRESET	32,144
		RAMPRESET	16,152
		RAMPRESET	24,152
		RAMPRESET	32,152
		RAMPRESET	16,184
		RAMPRESET	8,192
		RAMPRESET	16,192
		RAMPRESET	8,200
		RAMPRESET	16,200
		RAMPRESET	8,208
		RAMPRESET	16,208
		RAMPRESET	8,216
		RAMPRESET	16,216
		RAMPRESET	8,224
		RAMPRESET	16,224
		RAMPRESET	24,224
		RAMPRESET	8,232
		RAMPRESET	16,232
		RAMPRESET	24,232
		RAMPRESET	32,232
		RAMPRESET	24,240
		RAMPRESET	32,240
b2rampmarks:	ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPMARK	144
		RAMPMARK	152
		RAMPMARK	160
		RAMPMARK	168
		RAMPMARK	176
		RAMPMARK	184
		RAMPMARK	192
		RAMPMARK	200
		RAMPMARK	208
		RAMPMARK	216
		RAMPMARK	224
		RAMPMARK	232
		RAMPMARK	240
		ret

setrightramp:	and	(1<<BALLFLG_LAYER)
		jp	nz,rightrampdown
rightrampup:	ld	hl,pin_flags2
		bit	PINFLG2_RAMPDOWN,[hl]
		ret	z
		res	PINFLG2_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPSET	168,168
		RAMPSET	176,168
		RAMPSET	168,176
		RAMPSET	176,176
		RAMPSET	168,184
		RAMPSET	176,184
		RAMPSET	168,192
		RAMPSET	176,192
		RAMPSET	152,200
		RAMPSET	160,200
		RAMPSET	168,200
		RAMPSET	176,200
		RAMPSET	152,208
		RAMPSET	160,208
		RAMPSET	168,208
		RAMPSET	144,216
		RAMPSET	152,216
		RAMPSET	160,216
		RAMPSET	136,224
		RAMPSET	144,224
		RAMPSET	152,224
		RAMPSET	136,232
		RAMPSET	144,232
		RAMPSET	136,240
		RAMPSET	144,240
		jp	b2rampmarks2
rightrampdown:	ld	hl,pin_flags2
		bit	PINFLG2_RAMPDOWN,[hl]
		ret	nz
		set	PINFLG2_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPRESET	168,168
		RAMPRESET	176,168
		RAMPRESET	168,176
		RAMPRESET	176,176
		RAMPRESET	168,184
		RAMPRESET	176,184
		RAMPRESET	168,192
		RAMPRESET	176,192
		RAMPRESET	152,200
		RAMPRESET	160,200
		RAMPRESET	168,200
		RAMPRESET	176,200
		RAMPRESET	152,208
		RAMPRESET	160,208
		RAMPRESET	168,208
		RAMPRESET	144,216
		RAMPRESET	152,216
		RAMPRESET	160,216
		RAMPRESET	136,224
		RAMPRESET	144,224
		RAMPRESET	152,224
		RAMPRESET	136,232
		RAMPRESET	144,232
		RAMPRESET	136,240
		RAMPRESET	144,240
b2rampmarks2:	ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		RAMPMARK	168
		RAMPMARK	176
		RAMPMARK	184
		RAMPMARK	192
		RAMPMARK	200
		RAMPMARK	208
		RAMPMARK	216
		RAMPMARK	224
		RAMPMARK	232
		RAMPMARK	240
		ret

b2lostball:
		ld	a,[any_ballsaver]
		or	a
		jr	z,.nosaver
		ld	a,FX_BALLSAVED
		call	InitSfx
		call	b2autofire
		ld	a,TV_SAVER
		jp	showtv
.nosaver:

		ld	a,1
		ld	[any_spitout],a

		ld	a,[any_inmulti]
		or	a
		jp	nz,b2multiend

		ld	a,[any_mlock1]
		or	a
		jr	z,.nolock1
		xor	a
		ld	[any_mlock1],a
		jp	b2out2
.nolock1:

		ld	a,[any_mlock2]
		or	a
		jr	z,.nolock2
		xor	a
		ld	[any_mlock2],a
		jp	b2out3
.nolock2:

 ld	a,[wDemoMode]
 or	a
 jp	nz,AnyQuit

		ld	a,FX_LOSTBALL
		call	InitSfx

		call	endtable

		ld	a,1
		ld	[any_bonusinfo1],a

		ld	a,[any_tilt]
		or	a
		ld	a,[b2_bonus]
		jr	z,.aok
		xor	a
.aok:		ld	[any_bonusmul],a
		ret

b2finishloseball:

		xor	a
		ld	[any_combo1],a
		ld	[any_combo2],a
		ld	[any_comboclear],a

		ld	a,[b2_holdmult]
		or	a
		jr	nz,.noresetmult
		ld	a,1
		ld	[b2_bonus],a
		call	board2bonus
.noresetmult:	xor	a
		ld	[b2_holdmult],a

		call	ClearBonusVal

		ld	a,[b2_holdpops]
		or	a
		jr	nz,.noresetpops
		xor	a
		ld	[b2_leftpops],a
		ld	[b2_centerpops],a
		ld	[b2_rightpops],a
.noresetpops:	xor	a
		ld	[b2_holdpops],a

		ld	a,[any_ballsleft]
		or	a
		jr	nz,.doit
		ld	a,[any_extraball]
		or	a
		jr	nz,.doit
.gameover:
		ld	a,1
		ld	[any_lockedout],a
		ld	hl,MSGGAMEOVER1
		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		add	hl,bc
		call	statusflash
.doit:
		ld	a,[b2_kicklock]
		or	a
		jr	z,.nokicklock
		xor	a
		ld	[b2_kicklock],a
		ld	hl,MSGLOSTKICK
		call	statusflash
.nokicklock:
		ld	hl,any_extraball
		ld	a,[hl]
		or	a
		jr	z,.noextras
		dec	[hl]
		call	b2restoreq
		ld	a,1
		ld	[any_wantfire],a
		jp	PlayerReport
.noextras:

		ld	a,1
		ld	[any_wantswitch],a

		ret

b2multiend:	call	CountBalls
		dec	a
		ld	c,a
		ld	a,[any_inmulti]
		cp	TABLEGAME_ROLLERMULTI
		jr	z,.thrillmultiend
.happyend:	ld	a,[any_happyfire]
		jr	.all
.thrillmultiend:
		ld	a,[b2_lefttrapped]
.all:		or	a
		ret	nz
		ld	a,[any_mlock1]
		add	c
		ld	c,a
		ld	a,[any_mlock2]
		add	c
		cp	2
		ret	nc
		jp	endtable


b2autofire:	ld	a,1
		ld	[any_tofire],a
		ret

showtv:
		ld	c,a
		ld	a,[any_tvput]
		ld	e,a
		inc	a
		and	7
		ld	b,a
		ld	a,[any_tvtake]
		cp	b
		ret	z
		ld	a,e
		inc	a
		and	7
		ld	[any_tvput],a
		ld	d,0
		ld	hl,any_tvshow
		add	hl,de
		ld	[hl],c
		ret
b2tvpop:	ld	a,[any_tvtake]
		ld	e,a
		inc	a
		and	7
		ld	[any_tvtake],a
		ld	d,0
		ld	hl,any_tvshow
		add	hl,de
		ld	a,[hl]
		call	TVSet
		ld	a,4
		ld	[any_tvhold],a
		ld	hl,wStates+B2_MODES
		ld	a,5
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ret


b2firedown:	ld	hl,pin_ballflags
		res	BALLFLG_LAYER,[hl]
		ret

b2tempaddball:

		xor	a
		ld	[any_wantfire],a


		ld	a,[any_weakball]
		or	a
		jr	nz,.wasweakball

		ldh	a,[pin_difficulty]
		cp	2
		jr	c,.kickon
		ld	a,[b2_leftkick]
		or	a
		jr	nz,.kickon
		ld	a,[b2_rightkick]
		or	a
		jr	nz,.kickon
		xor	a
		ld	[b2_kickspin],a
		jr	.wasoff
.kickon:	call	rightonleftoff
.wasoff:	xor	a
		ld	[b2_kickdie],a
.wasweakball:


 ld a,[wDemoMode]
 or a
 jp nz,b2fire

		ld	a,1
		ld	[any_firing],a
		ld	[b2_launcher],a

		ld	de,170<<5
		ld	bc,280<<5
		ld	hl,0
		call	AddBall
		ret

rightonleftoff:
		ld	a,MAXKICKSPIN
		ld	[b2_kickspin],a
		ld	a,1
		call	rightkickback
		xor	a
		ld	[b2_kickdie],a
		jp	leftkickback

bothon:		xor	a
		ld	[b2_kickdie],a
		inc	a
		ld	[b2_kicklock],a
		ld	a,MAXKICKSPIN
		ld	[b2_kickspin],a
		ld	a,1
		call	leftkickback
		ld	a,1
		jp	rightkickback

b2shoot:
		ld	hl,pin_ballflags
		set	BALLFLG_LAYER,[hl]
		ld	a,[any_firing]
		or	a
		ret	nz
		ldh	a,[pin_vy+1]
		add	a
		ret	c
		ld	a,AUTOFIRERATE&255
		ldh	[pin_vy],a
		ld	a,$ff
		ldh	[pin_vy+1],a
		ret

b2firing:	ld	hl,any_firing
		ld	a,[hl]
		or	a
		ret	z

		xor	a
		ld	[any_tilt],a
		ld	hl,wTiltTimes
		ld	bc,32
		call	MemClear

		ld	hl,any_firing
		ld	a,[hl]

	IF	LAUNCHER

		cp	1
		jr	nz,.pulling
		xor	a
		ld	[wBalls+BALL_THETA],a
		ld	a,[wJoy1Hit]
		bit	JOY_SELECT,a
		ret	z
		inc	[hl]
		ld	a,2
		ld	[b2_launcher],a
		ret
.pulling:	cp	60
		jr	z,.atmax
		inc	a
.atmax:		ld	[hl],a
		ld	a,[wJoy1Cur]
		bit	JOY_SELECT,a
		ret	nz
		ld	a,[hl]
 srl	a
 add 50
	ELSE
		ld	a,[wJoy1Hit]
		bit	JOY_SELECT,a
		ret	z
		ld	a,60
	ENDC

		ld	[hl],0
		cpl
		inc	a
		ld	[wBalls+BALL_VY],a
		ld	a,$ff
		ld	[wBalls+BALL_VY+1],a
		xor	a
		ld	[b2_loop],a
		ld	a,[any_weakball]
		or	a
		ld	hl,newballsavers
		jr	z,.hlok
		ld	hl,lockedballsavers
.hlok:		call	saverdifficulty
		xor	a
		ld	[any_weakball],a
		ld	a,9
		ld	[b2_launcher],a
		call	RumbleHigh
		ld	a,SKILLTIME
		ld	[any_skill],a
		ld	a,FX_BALLFIRE
		jp	InitSfx

savernewball:
		ld	hl,newballsavers
;hl=list
saverdifficulty:
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[any_ballsaver]
		cp	[hl]
		ret	nc
		ld	a,[hl]
		ld	[any_ballsaver],a
		ret

b2fire:		call	RumbleHigh
		ld	a,FX_BALLFIRE
		call	InitSfx
		ld	de,170<<5
		ld	bc,280<<5
		ld	hl,AUTOFIRERATE
		jp	AddBall


board2process:
		ld	a,[b2_nightwant]
		ld	c,a
		ld	a,[b2_night]
		cp	c
		call	nz,fixnight

		ld	a,[any_wantswitch]
		or	a
		call	nz,tryswitch

		ld	a,[b2_wanthide]
		cp	WANTHIDE
		call	nc,starthide

		ld	a,[any_skill]
		or	a
		jr	z,.noskill
		ld	a,[wTime]
		and	3
		cp	3
		jr	nz,.noskill
		ld	hl,any_skill
		dec	[hl]
.noskill:

		ld	a,[wStartHappy]
		or	a
		call	nz,b2starthappy

		ld	a,[b2_thrilltimer]
		or	a
		call	z,startthrillride

		ld	a,[b2_thrillride]
		cp	10
		call	z,startfantasy

		ld	a,[any_spitout]
		or	a
		jr	z,.nospitout
		xor	a
		ld	[any_spitout],a
		call	tryspit1
		call	tryspit2
.nospitout:

		ld	hl,any_comboclear
		ld	a,[hl]
		or	a
		jr	z,.nodechist
		dec	[hl]
		jr	nz,.nodechist
		xor	a
		ld	[any_combo1],a
		ld	[any_combo2],a
.nodechist:

		call	BonusProcess
		call	nz,b2finishloseball

		ld	a,[wJoy1Hit]
		bit	JOY_L,a
		call	nz,shiftleft
		ld	a,[wJoy1Hit]
		bit	JOY_A,a
		call	nz,shiftright


		ld	a,[b2_ridesdelay]
		or	a
		jr	z,.nodecridesdelay
		dec	a
		ld	[b2_ridesdelay],a
.nodecridesdelay:

		ld	a,[b2_happydelay]
		or	a
		jr	z,.nodecawarddelay
		dec	a
		ld	[b2_happydelay],a
.nodecawarddelay:

		ld	a,[wTime]
		ld	b,a
		and	$1f
		add	a
		add	LOW(b2phasetable)
		ld	l,a
		ld	a,0
		adc	HIGH(b2phasetable)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		jr	z,.phaseret
		ld	de,.phaseret
		push	de
		jp	[hl]
.phaseret:


		ld	a,[any_wantfire]
		or	a
		call	nz,b2tempaddball

		call	b2firing


		ld	a,[any_tofire]
		or	a
		jr	z,.nofire
		xor	a
		ld	[any_tofire],a
		call	b2fire
.nofire:

		call	processtimed

		ld	hl,b2_seconds
		ld	a,[hl]
		dec	[hl]
		or	a
		jr	nz,.notyet
		ld	[hl],59
		ld	hl,any_ballsaver
		ld	a,[hl]
		or	a
		jr	z,.nodecsaver
		dec	[hl]
.nodecsaver:
		ld	hl,any_tabletime
		ld	a,[hl]
		or	a
		jr	z,.nodectabletime
		dec	[hl]
		call	z,endtable
		ldh	a,[pin_flags]
		set	PINFLG_SCORE,a
		ldh	[pin_flags],a

.nodectabletime:

		ldh	a,[pin_difficulty]
		cp	2
		jr	c,.nodeckickspin
		ld	a,[b2_kickspin]
		cp	MAXKICKSPIN
		jr	z,.nodeckickspin
		or	a
		jr	z,.nodeckickspin
		dec	a
		ld	[b2_kickspin],a
.nodeckickspin:

		ld	a,[b2_spit1]
		or	a
		jr	z,.nospit1
		dec	a
		ld	[b2_spit1],a
		call	z,tryspit1
.nospit1:	ld	a,[b2_spit2]
		or	a
		jr	z,.nospit2
		dec	a
		ld	[b2_spit2],a
		call	z,tryspit2
.nospit2:


.notyet:

		call	tableprocess

		ret


tryspit1:	ld	a,[any_mlock1]
		or	a
		jr	z,.nospit1
		xor	a
		ld	[any_mlock1],a
		ld	[b2_spit1],a
		jp	b2spit2
.nospit1:	ret
tryspit2:	ld	a,[any_mlock2]
		or	a
		jr	z,.nospit2
		xor	a
		ld	[any_mlock2],a
		ld	[b2_spit2],a
		jp	b2spit3
.nospit2:	ret


board2hitbumper:
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
		jp	c,.bottoms
		ld	a,[any_table]
		cp	TABLEGAME_BUMPER
		jr	nz,.notbumper
		ld	a,d
		cp	45
		jr	c,.notbumper
		ld	a,e
		cp	175
		jr	c,.notbumper
		cp	241
		jr	nc,.notbumper
		ld	a,d
		cp	92
		ld	a,e
		jr	nc,.car23
		cp	216
		jr	c,.car1
.car0:		ld	c,0
		jr	.cars
.car1:		ld	c,1
		jr	.cars
.car23:	cp	205
		jr	nc,.car3
.car2:		ld	c,2
		jr	.cars
.car3:		ld	c,3
		jr	.cars
.cars:		jp	bumpercar
.notbumper:	ld	a,e
		cp	242
		jr	nc,.bottoms
		cp	81
		jr	c,.top2
		cp	177
		jp	nc,.left3
		cp	166
		jp	nc,.dropmc3
		ld	a,d
		cp	68
		jp	c,.dropmb1orc1
		cp	108
		jp	nc,.dropmb4orc2
		ld	a,e
		cp	102
		jr	c,.centerpop
		ld	a,d
		cp	88
		jp	c,.dropmb2
		jp	.dropmb3
.top2:		ld	a,d
		cp	88
		jr	c,.leftpop
.rightpop:	ld	e,B2_RIGHTPOP
		ld	bc,b2rightpop
		ld	hl,b2_rightpops
		jr	.toppops
.leftpop:	ld	e,B2_LEFTPOP
		ld	bc,b2leftpop
		ld	hl,b2_leftpops
		jr	.toppops
.centerpop:	ld	e,B2_CENTERPOP
		ld	bc,b2centerpop
		ld	hl,b2_centerpops
		jr	.toppops
.bottoms:	ldh	a,[pin_x]
		sub	(96<<5)&255
		ldh	a,[pin_x+1]
		sbc	(96<<5)>>8
		jr	c,.bottomleft
.bottomright:	ld	e,B2_RIGHTBUMPER
		ld	bc,b2rightbumper
		jr	.bumps
.bottomleft:	ld	e,B2_LEFTBUMPER
		ld	bc,b2leftbumper
		jr	.bumps
.toppops:	ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
		ld	a,[hl]
		cp	99
		jr	z,.maxpops
		inc	a
		ld	[hl],a
.maxpops:	ld	d,1
		ld	hl,(2<<8)|1		;1,000 points for low level
		cp	POPBLUE
		jr	c,.tops
		ld	d,3
		ld	hl,(5<<8)|10		;10,000 points for medium level
		cp	POPGREEN
		jr	c,.tops
		ld	d,5
		ld	hl,(10<<8)|100		;100,000 points for high level
		jr	.tops
.tops:
		cp	POPBLUE
		jr	z,.explode
		cp	POPGREEN
.explode:	call	z,explodepop
		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		call	z,thrillpop
		jr	.anypop
.bumps:		ld	d,1
;HIT A POP BUMPER
		ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
		ld	hl,(2<<8)|2		;2,000 points for bottom bumpers
.anypop:
		push	hl
		push	bc
		call	newstate
		pop	de
		ld	a,15
		call	addtimed
		call	RumbleMedium

		pop	hl
		push	hl
		ld	h,0
		call	addthousandshl

		ld	hl,b2_rollerjack
		pop	af
		push	af
		call	increasejacka

		pop	af
		cp	10
		ld	a,FX_BUMPER
		jr	c,.popfxok
		ld	a,FX_BUMPERMAX
.popfxok:	jp	InitSfx

.dropmb1orc1:	ld	a,e
		cp	100
		jr	c,.dropmb1
		jr	.dropmc1
.dropmb1:	ld	b,1
		jr	.dropb
.dropmb2:	ld	b,2
		jr	.dropb
.dropmb4orc2:	ld	a,e
		cp	103
		jr	nc,.dropmc2
		jr	.dropmb4
.dropmb3:	ld	b,4
		jr	.dropb
.dropmb4:	ld	b,8
.dropb:		ld	a,[b2_dropb]
		ld	c,a
		or	b
		cp	c
		jr	z,.bsame
		cp	15
		jr	nz,.bnotall
		ld	a,FX_POPSALL
		call	InitSfx
		call	advancetops
		ld	hl,100
		call	z,addthousandshlinform

		xor	a
		ld	[b2_dropbtimer],a
		ld	a,1
		ld	de,dropbflash
		call	addtimed
		xor	a
		ld	[b2_dropb],a
		jr	.bsame
.bnotall:	call	dropb
		ld	a,FX_POPSBIT
		call	InitSfx
.bsame:		jr	.soft

.dropmc1:	ld	b,4
		jr	.clock
.dropmc2:	ld	b,2
		jr	.clock
.dropmc3:	ld	b,1
		jr	.clock
.clock:		ld	a,[b2_clock]
		ld	c,a
		or	b
		cp	c
		jr	z,.csame
		cp	7
		jr	nz,.cnotall
;all clocks lit
		xor	a
		ld	[b2_clocktimer],a
		ld	a,1
		ld	de,clockflash
		call	addtimed
		xor	a
		ld	[b2_clock],a
		call	lightaward
		ld	a,FX_CLOCKALL
		call	InitSfx
		jr	.csame
.cnotall:	call	clock
		ld	a,FX_CLOCKBIT
		call	InitSfx
.csame:	
		ldh	a,[pin_difficulty]
		or	a
		ld	b,4
		jr	z,.bok
		dec	a
		ld	b,2
		jr	z,.bok
		ld	b,1
.bok:		ld	a,[any_table]
		cp	TABLEGAME_THRILL
		jr	z,.inthrill
		ld	a,[b2_thrilltimer]
		sub	b
		jr	nc,.aok
		xor	a
.aok:		ld	[b2_thrilltimer],a
.inthrill:	jr	.soft


.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret
.left3:		cp	195
		jr	c,.left3a
		cp	211
		jr	c,.left3b
.left3c:	ld	b,255-1
		jr	.leftdrops
.left3b:	ld	b,255-2
		jr	.leftdrops
.left3a:	ld	b,255-4
.leftdrops:
		ld	a,[b2_popupstate]
		ld	c,a
		and	b
		cp	c
		jr	nz,.changed
		rlc	b
		ld	a,c
		and	b
		cp	c
		jr	nz,.changed
		rrc	b
		rrc	b
		ld	a,c
		and	b
		cp	c
		ret	z
.changed:	or	a
		jr	nz,.notall
		xor	a
		ld	[b2_poptimer],a
		ld	a,1
		ld	de,b2popupflash
		call	addtimed
		ld	a,FX_CATALL
		call	InitSfx
		call	b2showlockopen
		xor	a
		call	board2popups
		jr	.all
.notall:	call	board2popups
		ld	a,FX_CATBIT
		call	InitSfx
.all:		call	RumbleLow
		ld	de,dropscore
		call	addscore
		jp	.soft


board2sprites:
		call	board2flippers
	IF	LAUNCHER
		call	board2launcher
	ENDC
		ld	a,[b2_hide]
		or	a
		call	nz,hider
		ld	a,[any_table]
		cp	TABLEGAME_BUMPER
		call	z,bumpersprites
		ld	a,[b2_pop]
		or	a
		call	nz,popping
		jp	board2spinner


explodepop:	push	de
		ld	a,e
		cp	B2_LEFTPOP
		ld	b,$10
		jr	z,.bok
		cp	B2_CENTERPOP
		ld	b,$20
		jr	z,.bok
		ld	b,$30
.bok:		ld	a,b
		ld	[b2_pop],a
		ld	a,d
		cp	4
		ld	hl,PAL_BLUEPOP
		jr	c,.hlok
		ld	hl,PAL_GREENPOP
.hlok:		call	Palette3now
		ld	a,1
		ldh	[hPalFlag],a
		pop	de
		ret

POP1LOC		EQU	(70<<8)|67
POP2LOC		EQU	(87<<8)|96
POP3LOC		EQU	(106<<8)|67

popping:
		ld	de,POP1LOC
		cp	$20
		jr	c,.deok
		ld	de,POP2LOC
		cp	$30
		jr	c,.deok
		ld	de,POP3LOC
.deok:		and	15
		cp	12
		jr	c,.ok
		xor	a
		ld	[b2_pop],a
		ret
.ok:		srl	a
		srl	a
		add	IDX_BLUEPOP&255
		ld	c,a
		ld	a,0
		adc	IDX_BLUEPOP>>8
		ld	b,a
		ld	hl,b2_pop
		inc	[hl]
		ld	a,[wMapYPos]
		ld	l,a
		ld	a,[wMapYPos+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,e
		sub	h
		ld	e,a
		cp	152
		jr	c,.finey
		cp	256-8
		ret	c
.finey:		ld	a,e
		add	8
		ld	e,a
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,d
		add	8
		sub	h
		ld	d,a
		ld	a,GROUP_POP
		jp	AddFigure

bumpersprites:
		ld	a,[b2_bumperhits]
		cp	BUMPERHITS
		ld	a,[b2_bumperhits+4]
		ld	c,a
		ld	de,(55<<8)+228
		ld	a,4
		call	c,.bumper

		ld	a,[b2_bumperhits+1]
		cp	BUMPERHITS
		ld	a,[b2_bumperhits+5]
		ld	c,a
		ld	de,(73<<8)+203
		ld	a,5
		call	c,.bumper

		ld	a,[b2_bumperhits+2]
		cp	BUMPERHITS
		ld	a,[b2_bumperhits+6]
		ld	c,a
		ld	de,(107<<8)+187
		ld	a,$86
		call	c,.bumper

		ld	a,[b2_bumperhits+3]
		cp	BUMPERHITS
		ld	a,[b2_bumperhits+7]
		ld	c,a
		ld	de,(129<<8)+223
		ld	a,$87
		ret	nc
.bumper:	push	af
		ld	a,[wMapYPos]
		ld	l,a
		ld	a,[wMapYPos+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,e
		sub	h
		ld	e,a
		cp	152
		jr	c,.finey
		cp	256-8
		jr	nc,.finey
		pop	af
		ret
.finey:		ld	a,e
		add	8
		ld	e,a
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,d
		add	8
		sub	h
		ld	d,a
		ld	a,c
		or	a
		ld	bc,IDX_REDBUMP
		jr	z,.bcok
		inc	bc
.bcok:		pop	af
		jp	AddFigure



hidecollect:
		ld	a,FX_HIDETAKEN
		call	InitSfx
		ld	de,100
		ld	h,d
		ld	l,d
		ld	a,[b2_hidedone]
.add:		srl	a
		jr	nc,.noadd
		add	hl,de
.noadd:		or	a
		jr	nz,.add
		call	addthousandshlinform
		ld	a,[b2_hide]
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,tvhides
		add	hl,bc
		ld	a,[hl]
		call	showtv
		ld	a,[b2_hidedone]
		cp	$7f
		jr	nz,.noreset
		xor	a
		ld	[b2_hidedone],a
		jp	endtable
.noreset:	ld	hl,hidecollected
		call	addtabletime
		jr	newhider

hidebits:	db	$01,$02,$04,$08,$10,$20,$40,$80
newhider:
		ld	a,[b2_hidedone]
		ld	e,a
		cp	$7f-16	;cow
		ld	c,5
		ld	d,16
		jr	z,.forcecow
		ld	b,0
.findbit:	call	random
		and	7
		jr	z,.findbit
		cp	5
		jr	z,.findbit
		ld	c,a
		ld	hl,hidebits-1
		add	hl,bc
		ld	d,[hl]
		ld	a,e
		and	d
		jr	nz,.findbit
.forcecow:	ld	a,e
		or	d
		ld	[b2_hidedone],a
		ld	a,c
		ld	[b2_hide],a
		cp	1
		jr	nz,.notreeces
		ld	hl,PAL_REESES2
		call	Palette6now
.notreeces:
		ld	a,[b2_hide]
		add	a
		ld	c,a
		ld	b,0
		ld	hl,.palettes-2
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		xor	a
		ld	[b2_hideframe],a
		ld	[b2_hidecollect],a
		call	Palette7now
		ld	a,1
		ldh	[hPalFlag],a
		ret
.palettes:	dw	PAL_REESES1
		dw	PAL_KISS
		dw	PAL_PAYDAY
		dw	PAL_SYRUP
		dw	PAL_COW
		dw	PAL_TWIZZLER
		dw	PAL_CHOCO

tvhides:	db	TV_REESES
		db	TV_KISS
		db	TV_PAYDAY
		db	TV_SYRUP
		db	TV_COW
		db	TV_TWIZZLER
		db	TV_CHOCO


hider:		add	a
		ld	c,a
		ld	b,0
		ld	hl,hiders-2
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
hiders:		dw	.reeses
		dw	.kiss
		dw	.payday
		dw	.syrup
		dw	.cow
		dw	.twizzler
		dw	.choco
.reeses:	ld	d,18
		ld	bc,118
		call	.visible
		ld	bc,IDX_REESES2
		ld	a,[b2_hideframe]
		swap	a
		and	15
		add	c
		ld	c,a
		jr	nc,.bok2
		inc	b
.bok2:		ld	a,6
		push	de
		call	AddFigure
		pop	de
		ld	bc,IDX_REESES1
		ld	l,6
		jr	.all
.payday:	ld	d,26
		ld	bc,181
		call	.visible
		ld	bc,IDX_PAYDAY
		ld	l,5
		jr	.all
.cow:		ld	d,101
		ld	bc,172
		call	.visible
		ld	bc,IDX_COW
		ld	l,3
		jr	.all
.syrup:		ld	d,163
		ld	bc,150
		call	.visible
		ld	bc,IDX_SYRUP
		ld	l,4
		jr	.all
.kiss:		ld	d,158
		ld	bc,120
		call	.visible
		ld	bc,IDX_KISS
		ld	l,5
		jr	.all
.choco:		ld	d,127
		ld	bc,63
		call	.visible
		ld	bc,IDX_CHOCO
		ld	l,6
		jr	.all
.twizzler:	ld	d,48
		ld	bc,58
		call	.visible
		ld	bc,IDX_TWIZZLER
		ld	l,5
.all:		ld	a,[b2_hidecollect]
		or	a
		ld	a,[b2_hideframe]
		jr	z,.nodec
		or	a
		jr	z,.aok
		dec	a
		jr	.aok
.nodec:		swap	a
		and	15
		add	c
		ld	c,a
		jr	nc,.bok
		inc	b
.bok:		ld	a,[b2_hideframe]
		inc	a
		inc	l
		inc	l
		swap	l
		cp	l
		jr	c,.aok
		sub	32
.aok:		ld	[b2_hideframe],a

		ld	a,7
		jp	AddFigure

.visible:
		ld	a,d
		ld	[b2_hidex],a
		ld	a,c
		ld	[b2_hidey],a
		ld	a,b
		ld	[b2_hidey+1],a

		ld	a,[wMapYPos+1]
		dec	a
		ld	l,a
		ld	a,[wMapYPos]
		and	$e0
		ld	h,0
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		ld	a,c
		sub	l
		ld	e,a
		ld	a,b
		sbc	h
		ld	a,e
		jr	z,.below
		cp	160
		jr	c,.nope
		jr	.above
.below:		cp	160
		jr	nc,.nope
.above:		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,d
		sub	h
		ld	d,a
		ret
.nope:		pop	hl
		ret





board2flippers:
		ld	a,[wMapYPos+1]
		dec	a
		ld	l,a
		ld	a,[wMapYPos]
		and	$e0
		ld	h,0
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		push	hl
		ld	de,FLIPPERYB2>>5
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		jr	nz,.nobottoms
		ld	a,e
		cp	160
		jr	nc,.nobottoms
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,FLIPPERX1B2>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(FLIPPERX2B2-FLIPPERX1B2)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,$80+GROUP_FLIPPERS
		call	AddFigure
.nobottoms:	pop	hl
		ld	de,(FLIPPERY3B2>>5)+16
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		jr	nz,.notops
		ld	a,e
		cp	176
		jr	nc,.notops
		sub	16
		ld	e,a
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,FLIPPERX3B2>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS ;GROUP_FLIPPERS+$80
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(FLIPPERX4B2-FLIPPERX3B2)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,$80+GROUP_FLIPPERS
		call	AddFigure
.notops:
		ret



board2first::
		xor	a
		ld	[wGotHigh],a
		ld	hl,wWarps
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a

		xor	a
		ld	[wStartHappy],a
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]

		call	setthrilltime

		ld	hl,wScore
		ld	bc,16
		call	MemClear

		call	InitBalls

		ld	a,0
		ld	[any_wantfire],a
		ld	a,1
		ld	[b2_bonus],a

		ld	a,7
		ld	[b2_popupstate],a

		ld	a,-1
		ld	[b2_treat],a

		ld	a,100
		ld	[b2_rollerjack],a
		ld	[b2_flumejack],a

; ld a,POPGREEN
; ld [b2_leftpops],a
; ld [b2_centerpops],a
; ld [b2_rightpops],a

; ld a,1
; ld [b2_awardready],a

; ld a,2
; ld [b2_lefttrapped],a ;DEBUG
; ld [b2_leftlocked],a

; ld a,2
; ld [b2_righttrapped],a
; ld [b2_rightlocked],a

; ld a,1
; ld [any_extra],a ;DEBUG

; ld a,10 ;DEBUG
; ld [b2_thrillride],a

; ld a,1
; ld [b2_fungame],a

; ld a,15	;DEBUG
; ld [b2_finishedbits],a
; ld a,20
; ld [b2_brassrings],a
; ld [b2_ridephotos],a
; ld [b2_flumes],a
; ld [b2_rollers],a
; ld a,$fe
; ld [b2_allrides],a
; ld a,1
; ld [b2_fantasydone],a
; ld a,12
; ld [b2_treatstaken],a

		ld	a,0
		ld	[b2_dropb],a
		ld	[b2_clock],a

		call	PlayerReport

		ret

board2init::
		ld	hl,board2info
		call	SetPinInfo

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_SPINNER
		call	AddPalette

		ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_MAIN0001PMP
		ld	de,$d000
		call	SwdInFileSys
		ld	a,WRKBANK_PINMAP2
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_RAMP2PMP
		ld	de,$d000
		call	SwdInFileSys
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	hl,IDX_MAIN0020CHG	;close off entrance
		call	MakeChanges

		ld	hl,board2maplist
		call	NewLoadMap
		ld	a,[wStartHappy]
		or	a
		call	nz,nightonlightsout
		ld	hl,IDX_LIGHTSMAP
		call	SecondHalf
		ld	hl,IDX_TV1MAP
;		ld	a,[bLanguage]
;		ld	e,a
;		ld	d,0
;		add	hl,de
		call	OtherPage1
		ld	hl,IDX_TV2MAP
		call	OtherPage2
		ld	hl,IDX_TV3MAP
		call	OtherPage3
		ld	hl,IDX_TV4MAP
		call	OtherPage4

		call	b2restore

		ld	hl,board2chances

		ld	de,wChances
		call	b2chanceinit

		ld	hl,board2collisions
		jp	MakeCollisions

fixnight:	jr	c,.inc
		dec	a
		jr	.dec
.inc:		inc	a
.dec:		ld	c,a
		ld	a,[wTime]
		and	1
		ret	nz
		ld	a,c
		ld	[b2_night],a
		ld	b,0
		ld	hl,IDX_BOARDRGB
		add	hl,bc
		push	hl
		ld	de,wBcpShadow
		ld	bc,64
		call	MemCopyInFileSys
		pop	hl
		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopyInFileSys
		ld	a,1
		ldh	[hPalFlag],a
		ret



nightoff:	xor	a
		ld	[b2_nightwant],a
		ret
nightonlightsout:
nighton:
		ld	a,16
		ld	[b2_nightwant],a
		ret
nightswitch:	ld	a,[b2_nightwant]
		or	a
		jr	z,nighton
		jr	nightoff


showtreat:	add	56
		jp	showtv


b2restore:

		ld	hl,wStates
		ld	bc,128
		call	MemClear

b2restoreq:
		call	leftrampdown
		call	leftrampup
		call	rightrampdown
		call	rightrampup

		ld	a,[b2_bonus]
		call	board2bonus
		ld	a,[b2_popupstate]
		call	board2popups
		ld	a,[b2_rightkick]
		call	rightkickback
		xor	a
		ld	[b2_kickdie],a

		ld	a,[b2_leftkick]
		call	leftkickback

		ld	a,[b2_happy]
		call	happyshow
		ld	a,[b2_rides]
		call	ridesshow
		call	b2leftpop
		call	b2centerpop
		call	b2rightpop
		ld	a,[b2_dropb]
		call	dropbshow
		ld	a,[b2_clock]
		call	clockshow
		call	showkickspin
		call	show12guage
		call	showboardtimer
		call	showthrillride
		ret


	IF	LAUNCHER
board2launcher:
		ld	a,[b2_launcher]
		or	a
		ret	z
		ld	a,[wMapYPos+1]
		dec	a
		ld	l,a
		ld	a,[wMapYPos]
		and	$e0
		ld	h,0
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		ld	de,LAUNCHERY>>5
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		jr	nz,.novisible
		ld	a,e
		cp	160
		jr	nc,.novisible
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,LAUNCHERX>>5
		sub	h
		ld	d,a
		ld	a,[b2_launcher]
		dec	a
		cp	15
		jr	c,.aok
		xor	a
.aok:		add	IDX_LAUNCHER&255
		ld	c,a
		ld	a,0
		adc	IDX_LAUNCHER>>8
		ld	b,a
		ld	a,GROUP_LAUNCHER
		call	AddFigure
.novisible:	ld	hl,b2_launcher
		ld	a,[hl]
		cp	1
		ret	z
		cp	9
		jr	nc,.fast
		ld	a,[wTime]
		and	3
		ret	nz
.fast:		ld	a,[hl]
		inc	a
		cp	9
		jr	z,.sub2
		cp	20
		jr	nz,.ok
		xor	a
		jr	.ok
.sub2:		sub	2
.ok:		ld	[hl],a
		ret
	ENDC


showbonus:	ld	a,[b2_bonus]
		jp	bonusmul

advancebonus:	ld	hl,b2_bonus
		ld	a,[hl]
		cp	MAXBONUS
		ret	nc
		inc	[hl]
		ld	a,TV_ADDBONUS
		call	showtv
		call	showbonus
		ld	a,FX_MULTP1
		jp	InitSfx

board2bonus:
		ld	[b2_bonus],a
		ret

showboardtimer:
		ld	a,[any_table]
		or	a
		jr	z,.real
		ld	a,[any_tabletime]
		srl	a
		jr	.aok
.real:		ld	a,[b2_thrilltimer]
.aok:		ld	d,-1
.mod10:		inc	d
		sub	10
		jr	nc,.mod10
		add	10
		push	af
		ld	e,B2_TIMER10S
		call	newstate
		pop	de
		ld	e,B2_TIMER1S
		jp	newstate

showkickspin:
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEA
		cp	KICKSPINA
		ld	d,0
		jr	c,.dok1
		inc	d
.dok1:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEB
		cp	KICKSPINB
		ld	d,0
		jr	c,.dok2
		inc	d
.dok2:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEC
		cp	KICKSPINC
		ld	d,0
		jr	c,.dok3
		inc	d
.dok3:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGED
		cp	KICKSPIND
		ld	d,0
		jr	c,.dok4
		inc	d
.dok4:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEE
		cp	KICKSPINE
		ld	d,0
		jr	c,.dok5
		inc	d
.dok5:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEF
		cp	KICKSPINF
		ld	d,0
		jr	c,.dok6
		inc	d
.dok6:		call	newstate
		ld	a,[b2_kickspin]
		ld	e,B2_CHARGEG
		cp	KICKSPING
		ld	d,0
		jr	c,.dok7
		inc	d
.dok7:		jp	newstate

MAXTHRILL	EQU	72

show12guage:
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEA
		cp	1*MAXTHRILL/12
		ld	d,0
		jr	c,.dok1
		inc	d
.dok1:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEB
		cp	2*MAXTHRILL/12
		ld	d,0
		jr	c,.dok2
		inc	d
.dok2:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEC
		cp	3*MAXTHRILL/12
		ld	d,0
		jr	c,.dok3
		inc	d
.dok3:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGED
		cp	4*MAXTHRILL/12
		ld	d,0
		jr	c,.dok4
		inc	d
.dok4:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEE
		cp	5*MAXTHRILL/12
		ld	d,0
		jr	c,.dok5
		inc	d
.dok5:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEF
		cp	6*MAXTHRILL/12
		ld	d,0
		jr	c,.dok6
		inc	d
.dok6:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEG
		cp	7*MAXTHRILL/12
		ld	d,0
		jr	c,.dok7
		inc	d
.dok7:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEH
		cp	8*MAXTHRILL/12
		ld	d,0
		jr	c,.dok8
		inc	d
.dok8:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEI
		cp	9*MAXTHRILL/12
		ld	d,0
		jr	c,.dok9
		inc	d
.dok9:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEJ
		cp	10*MAXTHRILL/12
		ld	d,0
		jr	c,.dok10
		inc	d
.dok10:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEK
		cp	11*MAXTHRILL/12
		ld	d,0
		jr	c,.dok11
		inc	d
.dok11:		call	newstate
		ld	a,[b2_12guage]
		ld	e,B2_12GUAGEL
		cp	12*MAXTHRILL/12
		ld	d,0
		jr	c,.dok12
		inc	d
.dok12:		jp	newstate

showthrillride:	ld	a,[b2_thrillride]
		ld	e,B2_THRILLA
		cp	1
		ld	d,0
		jr	c,.dok1
		inc	d
.dok1:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLB
		cp	2
		ld	d,0
		jr	c,.dok2
		inc	d
.dok2:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLC
		cp	3
		ld	d,0
		jr	c,.dok3
		inc	d
.dok3:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLD
		cp	4
		ld	d,0
		jr	c,.dok4
		inc	d
.dok4:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLE
		cp	5
		ld	d,0
		jr	c,.dok5
		inc	d
.dok5:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLF
		cp	6
		ld	d,0
		jr	c,.dok6
		inc	d
.dok6:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLG
		cp	7
		ld	d,0
		jr	c,.dok7
		inc	d
.dok7:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLH
		cp	8
		ld	d,0
		jr	c,.dok8
		inc	d
.dok8:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLI
		cp	9
		ld	d,0
		jr	c,.dok9
		inc	d
.dok9:		call	newstate
		ld	a,[b2_thrillride]
		ld	e,B2_THRILLJ
		cp	10
		ld	d,0
		jr	c,.dok10
		inc	d
.dok10:		jp	newstate


;e=state #
;d=new value
newstate:	ld	a,e
		or	a
		ret	z
		ld	a,d
		ld	d,0
		ld	hl,wStates
		add	hl,de
		cp	[hl]
		ret	z
		ld	[hl],a
		ld	hl,b2statestarts
		add	hl,de
		ld	c,a
		ld	a,[hl]
		add	c
		ld	l,a
		ld	e,a
		ld	h,d
		add	hl,hl
		add	hl,hl
		add	hl,de
		add	hl,de
		ld	de,b2statelist
		add	hl,de
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
		jp	BGRect

B2_LEFTPOP	EQU	1
B2_CENTERPOP	EQU	2
B2_RIGHTPOP	EQU	3
B2_CHARGEA	EQU	4
B2_CHARGEB	EQU	5
B2_CHARGEC	EQU	6
B2_CHARGED	EQU	7
B2_CHARGEE	EQU	8
B2_CHARGEF	EQU	9
B2_CHARGEG	EQU	10
B2_MODES	EQU	11
B2_CLIGHT	EQU	19
B2_BLIGHT	EQU	20
B2_ALIGHT	EQU	21
B2_PC		EQU	22
B2_PB		EQU	23
B2_PA		EQU	24
B2_LEFTBUMPER	EQU	25
B2_RIGHTBUMPER	EQU	26
B2_SAVER	EQU	27
B2_EXTRA	EQU	28
B2_LANE1	EQU	29
B2_LANE2	EQU	30
B2_LANE3	EQU	31
B2_LANE4	EQU	32
B2_LANE5	EQU	33
B2_HAPPY1	EQU	34
B2_HAPPY2	EQU	35
B2_HAPPY3	EQU	36
B2_HAPPY4	EQU	37
B2_HAPPY5	EQU	38
B2_CLOCKA	EQU	39
B2_CLOCKB	EQU	40
B2_CLOCKC	EQU	41
B2_B4		EQU	42
B2_B3		EQU	43
B2_B2		EQU	44
B2_B1		EQU	45
B2_THRILLA	EQU	46
B2_THRILLB	EQU	47
B2_THRILLC	EQU	48
B2_THRILLD	EQU	49
B2_THRILLE	EQU	50
B2_THRILLF	EQU	51
B2_THRILLG	EQU	52
B2_THRILLH	EQU	53
B2_THRILLI	EQU	54
B2_THRILLJ	EQU	55
B2_12GUAGEA	EQU	56
B2_12GUAGEB	EQU	57
B2_12GUAGEC	EQU	58
B2_12GUAGED	EQU	59
B2_12GUAGEE	EQU	60
B2_12GUAGEF	EQU	61
B2_12GUAGEG	EQU	62
B2_12GUAGEH	EQU	63
B2_12GUAGEI	EQU	64
B2_12GUAGEJ	EQU	65
B2_12GUAGEK	EQU	66
B2_12GUAGEL	EQU	67
B2_LEFT		EQU	68
B2_RIGHT	EQU	69
B2_LEFTSCOOP	EQU	70
B2_RIGHTSCOOP	EQU	71
B2_LEFTRAMP	EQU	72
B2_RIGHTRAMP	EQU	73
B2_SNACKBAR	EQU	74
B2_TIMER10S	EQU	75
B2_TIMER1S	EQU	76
B2_RIGHTKICK	EQU	77
B2_LEFTKICK	EQU	78


B2_JACKPOT	EQU	0

B2_T		EQU	0
B2_I		EQU	0
B2_P		EQU	0
B2_EXTRALOCK	EQU	0

b2statestarts:	db	0	; 0, Gate 0
		db	2	; 1, Left balloon
		db	8	; 2, Center balloon
		db	14	; 3, Right balloon
		db	20	; 4, Charge A
		db	22	; 5, Charge B
		db	24	; 6, Charge C
		db	26	; 7, Charge D
		db	28	; 8, Charge E
		db	30	; 9, Charge F
		db	32	;10, Charge G
		db	34	;11, TV A
		db	36	;12, TV B
		db	38	;13, TV C
		db	40	;14, TV D
		db	42	;15, TV E
		db	44	;16, TV F
		db	46	;17, TV G
		db	48	;18, TV H
		db	50	;19, C
		db	52	;20, A
		db	54	;21, T
		db	56	;22, Drop A
		db	58	;23, Drop B
		db	60	;24, Drop C
		db	62	;25, Left bumper
		db	64	;26, Right bumper
		db	66	;27, Saver
		db	68	;28, Extra
		db	70	;29, R
		db	72	;30, I
		db	74	;31, D
		db	76	;32, E
		db	78	;33, S
		db	80	;34, H
		db	82	;35, A
		db	84	;36, P
		db	86	;37, P
		db	88	;38, Y
		db	90	;39, Clock A
		db	92	;40, Clock B
		db	94	;41, Clock C
		db	96	;42, P
		db	98	;43, O
		db	100	;44, P
		db	102	;45, S
		db	104	;46, T
		db	106	;47, H
		db	108	;48, R
		db	110	;49, I
		db	112	;50, L
		db	114	;51, L
		db	116	;52, R
		db	118	;53, I
		db	120	;54, D
		db	122	;55, E
		db	124	;56, Thrill A
		db	126	;57, Thrill B
		db	128	;58, Thrill C
		db	130	;59, Thrill D
		db	132	;60, Thrill E
		db	134	;61, Thrill F
		db	136	;62, Thrill G
		db	138	;63, Thrill H
		db	140	;64, Thrill I
		db	142	;65, Thrill J
		db	144	;66, Thrill K
		db	146	;67, Thrill L
		db	148	;68, Left loop
		db	152	;69, Right Loop
		db	156	;70, Left scoop
		db	160	;71, Right scoop
		db	164	;72, Left ramp
		db	170	;73, Right ramp
		db	176	;74, Center scoop
		db	183	;75, Left Counter 0-9
		db	193	;76, Right counter 0-9
		db	203	;77, Right Kickback 0-2
		db	206	;78, Left Kickback 0-2

;xsize,ysize,xsrc,ysrc,xdest,ydest
b2statelist:
		db	1,1,0,0,12,1		;  0 Gate 0
		db	1,1,9,0,12,1		;  1 Gate 1
		db	3,3,18,0,7,7		;  2 Left Balloon Blue 0
		db	3,3,21,0,7,7		;  3 Left Balloon Blue 1
		db	3,3,18,3,7,7		;  4 Left Balloon Green 0
		db	3,3,21,3,7,7		;  5 Left Balloon Green 1
		db	3,3,18,6,7,7		;  6 Left Balloon Orange 0
		db	3,3,21,6,7,7		;  7 Left Balloon Orange 1
		db	2,4,20,18,10,10		;  8 Center Balloon Blue 0
		db	2,4,22,18,10,10		;  9 Center Balloon Blue 1
		db	2,4,20,22,10,10		; 10 Center Balloon Green 0
		db	2,4,22,22,10,10		; 11 Center Balloon Green 1
		db	2,4,20,26,10,10		; 12 Center Balloon Orange 0
		db	2,4,22,26,10,10		; 13 Center Balloon Orange 1
		db	3,3,18,9,12,7		; 14 Right Balloon Blue 0
		db	3,3,21,9,12,7		; 15 Right Balloon Blue 1
		db	3,3,18,12,12,7		; 16 Right Balloon Green 0
		db	3,3,21,12,12,7		; 17 Right Balloon Green 1
		db	3,3,18,15,12,7		; 18 Right Balloon Orange 0
		db	3,3,21,15,12,7		; 19 Right Balloon Orange 1
		db	2,1,22,34,17,19		; 20 Charge A 0
		db	2,1,20,34,17,19		; 21 Charge A 1
		db	2,1,22,33,17,18		; 22 Charge B 0
		db	2,1,20,33,17,18		; 23 Charge B 1
		db	2,1,22,32,18,17		; 24 Charge C 0
		db	2,1,20,32,18,17		; 25 Charge C 1
		db	2,1,22,31,18,16		; 26 Charge D 0
		db	2,1,20,31,18,16		; 27 Charge D 1
		db	2,1,22,30,18,15		; 28 Charge E 0
		db	2,1,20,30,18,15		; 29 Charge E 1
		db	3,1,13,38,18,14		; 30 Charge F 0
		db	3,1,10,38,18,14		; 31 Charge F 1
		db	3,2,13,36,18,12		; 32 Charge G 0
		db	3,2,10,36,18,12		; 33 Charge G 1
		db	2,2,14,13,9,27		; 34 TV A 0
		db	2,2,12,13,9,27		; 35 TV A 1
		db	2,2,12,15,11,27		; 36 TV B 0
		db	2,2,16,13,11,27		; 37 TV B 1
		db	2,2,16,15,13,27		; 38 TV C 0
		db	2,2,14,15,13,27		; 39 TV C 1
		db	2,2,14,17,9,29		; 40 TV D 0
		db	2,2,12,17,9,29		; 41 TV D 1
		db	2,2,10,19,13,29		; 42 TV E 0
		db	2,2,16,17,13,29		; 43 TV E 1
		db	2,2,14,19,9,31		; 44 TV F 0
		db	2,2,12,19,9,31		; 45 TV F 1
		db	2,2,9,21,11,31		; 46 TV G 0
		db	2,2,16,19,11,31		; 47 TV G 1
		db	2,2,13,21,13,31		; 48 TV H 0
		db	2,2,11,21,13,31		; 49 TV H 1
		db	2,1,18,20,3,27		; 50 C 0
		db	2,1,18,19,3,27		; 51 C 1
		db	1,1,19,22,4,25		; 52 A 0
		db	1,1,19,21,4,25		; 53 A 1
		db	2,1,17,22,4,23		; 54 T 0
		db	2,1,17,21,4,23		; 55 T 1
		db	1,1,19,18,1,27		; 56 Drop A 0
		db	1,1,18,18,1,27		; 57 Drop A 1
		db	2,2,4,29,2,24		; 58 Drop B 0
		db	2,2,6,29,2,24		; 59 Drop B 1
		db	2,2,2,29,2,22		; 60 Drop C 0
		db	2,2,0,29,2,22		; 61 Drop C 1
		db	2,3,0,0,7,32		; 62 Left Bumper 0
		db	2,3,2,0,7,32		; 63 Left Bumper 1
		db	2,3,4,0,15,32		; 64 Right Bumper 0
		db	2,3,6,0,15,32		; 65 Right Bumper 1
		db	2,2,2,27,10,35		; 66 Saver 0
		db	2,2,0,27,10,35		; 67 Saver 1
		db	2,2,6,27,12,35		; 68 Extra 0
		db	2,2,4,27,12,35		; 69 Extra 1
		db	2,2,2,23,6,5		; 70 R 0
		db	2,2,0,23,6,5		; 71 R 1
		db	2,2,6,23,8,4		; 72 I 0
		db	2,2,4,23,8,4		; 73 I 1
		db	2,2,10,23,10,4		; 74 D 0
		db	2,2,8,23,10,4		; 75 D 1
		db	2,2,14,23,12,4		; 76 E 0
		db	2,2,12,23,12,4		; 77 E 1
		db	2,2,18,23,14,5		; 78 S 0
		db	2,2,16,23,14,5		; 79 S 1
		db	2,2,2,25,1,31		; 80 H 0
		db	2,2,0,25,1,31		; 81 H 1
		db	2,2,6,25,3,31		; 82 A 0
		db	2,2,4,25,3,31		; 83 A 1
		db	2,2,10,25,5,31		; 84 P 0
		db	2,2,8,25,5,31		; 85 P 1
		db	2,2,14,25,17,31		; 86 P 0
		db	2,2,12,25,17,31		; 87 P 1
		db	2,2,18,25,19,31		; 88 Y 0
		db	2,2,16,25,19,31		; 89 Y 1
		db	2,2,10,27,6,14		; 90 Clock A 0
		db	2,2,8,27,6,14		; 91 Clock A 1
		db	2,2,14,27,14,14		; 92 Clock B 0
		db	2,2,12,27,14,14		; 93 Clock B 1
		db	2,2,18,27,14,21		; 94 Clock C 0
		db	2,2,16,27,14,21		; 95 Clock C 1
		db	2,2,10,29,7,10		; 96 P 0
		db	2,2,8,29,7,10		; 97 P 1
		db	1,2,13,29,9,10		; 98 O 0
		db	1,2,12,29,9,10		; 99 O 1
		db	1,2,15,29,12,10		;100 P 0
		db	1,2,14,29,12,10		;101 P 1
		db	2,2,18,29,13,10		;102 S 0
		db	2,2,16,29,13,10		;103 S 1
		db	1,2,1,31,6,3		;104 T 0
		db	1,2,0,31,6,3		;105 T 1
		db	1,1,3,31,7,3		;106 H 0
		db	1,1,2,31,7,3		;107 H 1
		db	1,2,5,31,8,2		;108 R 0
		db	1,2,4,31,8,2		;109 R 1
		db	1,2,7,31,9,2		;110 I 0
		db	1,2,6,31,9,2		;111 I 1
		db	1,2,9,31,10,2		;112 L 0
		db	1,2,8,31,10,2		;113 L 1
		db	1,2,11,31,11,2		;114 L 0
		db	1,2,10,31,11,2		;115 L 1
		db	1,2,13,31,12,2		;116 R 0
		db	1,2,12,31,12,2		;117 R 1
		db	1,2,15,31,13,2		;118 I 0
		db	1,2,14,31,13,2		;119 I 1
		db	1,1,17,31,14,3		;120 D 0
		db	1,1,16,31,14,3		;121 D 1
		db	1,2,19,31,15,3		;122 E 0
		db	1,2,18,31,15,3		;123 E 1
		db	1,1,1,33,8,15		;124 Thrill A 0
		db	1,1,0,33,8,15		;125 Thrill A 1
		db	1,1,3,33,8,16		;126 Thrill B 0
		db	1,1,2,33,8,16		;127 Thrill B 1
		db	1,1,5,33,9,15		;128 Thrill C 0
		db	1,1,4,33,9,15		;129 Thrill C 1
		db	1,1,7,33,9,16		;130 Thrill D 0
		db	1,1,6,33,9,16		;131 Thrill D 1
		db	1,1,1,34,10,15		;132 Thrill E 0
		db	1,1,0,34,10,15		;133 Thrill E 1
		db	1,1,3,34,10,16		;134 Thrill F 0
		db	1,1,2,34,10,16		;135 Thrill F 1
		db	1,1,5,34,11,15		;136 Thrill G 0
		db	1,1,4,34,11,15		;137 Thrill G 1
		db	1,1,7,34,11,16		;138 Thrill H 0
		db	1,1,6,34,11,16		;139 Thrill H 1
		db	1,1,1,35,12,15		;140 Thrill I 0
		db	1,1,0,35,12,15		;141 Thrill I 1
		db	1,1,3,35,12,16		;142 Thrill J 0
		db	1,1,2,35,12,16		;143 Thrill J 1
		db	1,1,5,35,13,15		;144 Thrill K 0
		db	1,1,4,35,13,15		;145 Thrill K 1
		db	1,1,7,35,13,16		;146 Thrill L 0
		db	1,1,6,35,13,16		;147 Thrill L 1
		db	3,2,6,21,5,25		;148 Left Loop 0
		db	3,2,0,21,5,25		;149 Left Loop 1 (yellow)
		db	3,2,3,21,5,25		;150 Left Loop 2 (red)
		db	3,2,12,6,5,25		;151 Left Loop 3 (combo)
		db	2,2,16,11,14,24		;152 Right Loop 0
		db	2,2,12,11,14,24		;153 Right Loop 1 (yellow)
		db	2,2,14,11,14,24		;154 Right Loop 2 (red)
		db	2,2,8,0,14,24		;155 Right Loop 3 (combo)
		db	2,2,4,11,6,12		;156 Left Scoop 0
		db	2,2,0,11,6,12		;157 Left Scoop 1 (yellow)
		db	2,2,2,11,6,12		;158 Left Scoop 2 (red)
		db	2,2,16,33,6,12		;159 Left Scoop 3 (lock)
		db	2,2,10,11,14,12		;160 Right Scoop 0
		db	2,2,6,11,14,12		;161 Right Scoop 1 (yellow)
		db	2,2,8,11,14,12		;162 Right Scoop 2 (red)
		db	2,2,16,33,14,12		;163 Right Scoop 3 (lock)
		db	3,3,9,13,8,24		;164 Left Ramp 0
		db	3,3,0,13,8,24		;165 Left Ramp 1 (yellow)
		db	3,3,3,13,8,24		;166 Left Ramp 2 (red)
		db	3,3,6,13,8,24		;167 Left Ramp 3 (jackpot)
		db	3,3,16,35,8,24		;168 Left Ramp 4 (super jackpot)
		db	3,3,12,0,8,24		;169 Left Ramp 5 (combo)
		db	2,2,6,16,17,24		;170 Right Ramp 0
		db	2,2,0,16,17,24		;171 Right Ramp 1 (yellow)
		db	2,2,2,16,17,24		;172 Right Ramp 2 (red)
		db	2,2,4,16,17,24		;173 Right Ramp 3 (jackpot)
		db	2,2,18,33,17,24		;174 Right Ramp 4 (super jackpot)
		db	2,2,8,3,17,24		;175 Right Ramp 5 (combo)
		db	2,2,8,19,11,24		;176 Center Scoop 0
		db	2,2,0,19,11,24		;177 Center Scoop 1 (yellow)
		db	2,2,2,19,11,24		;178 Center Scoop 2 (red)
		db	2,2,16,33,11,24		;179 Center Scoop 3 (lock)
		db	2,2,4,19,11,24		;180 Center Scoop 4 (extra ball)
		db	2,2,6,19,11,24		;181 Center Scoop 5 (award)
		db	2,2,13,3,11,24		;182 Center Scoop 6 (combo)
		db	1,2,0,36,11,29		;183 Left Counter 0
		db	1,2,1,36,11,29		;184 Left Counter 1
		db	1,2,2,36,11,29		;185 Left Counter 2
		db	1,2,3,36,11,29		;186 Left Counter 3
		db	1,2,4,36,11,29		;187 Left Counter 4
		db	1,2,5,36,11,29		;188 Left Counter 5
		db	1,2,6,36,11,29		;189 Left Counter 6
		db	1,2,7,36,11,29		;190 Left Counter 7
		db	1,2,8,36,11,29		;191 Left Counter 8
		db	1,2,9,36,11,29		;192 Left Counter 9
		db	1,2,0,38,12,29		;193 Right Counter 0
		db	1,2,1,38,12,29		;194 Right Counter 1
		db	1,2,2,38,12,29		;195 Right Counter 2
		db	1,2,3,38,12,29		;196 Right Counter 3
		db	1,2,4,38,12,29		;197 Right Counter 4
		db	1,2,5,38,12,29		;198 Right Counter 5
		db	1,2,6,38,12,29		;199 Right Counter 6
		db	1,2,7,38,12,29		;200 Right Counter 7
		db	1,2,8,38,12,29		;201 Right Counter 8
		db	1,2,9,38,12,29		;202 Right Counter 9
		db	2,4,4,7,19,35		;203 Right Kickback 0
		db	2,4,0,7,19,35		;204 Right Kickback 1
		db	2,4,2,7,19,35		;205 Right Kickback 2
		db	2,4,10,7,1,35		;206 Left Kickback 0
		db	2,4,6,7,1,35		;207 Left Kickback 1
		db	2,4,8,7,1,35		;208 Left Kickback 2

happy1:		ld	b,16
		jr	happy
happy2:		ld	b,8
		jr	happy
happy3:		ld	b,4
		jr	happy
happy4:		ld	b,2
		jr	happy
happy5:		ld	b,1
happy:
		ld	a,[b2_happydelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b2_happydelay],a
		ld	a,[b2_happy]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	$1f
		jr	nz,.notall
		ld	a,FX_HAPPYALL
		call	InitSfx
		call	advancebonus
		jr	lightfun
.notall:	call	board2happy
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_HAPPYBIT
		call	InitSfx
.delayed:	ret
lightfun:	xor	a
		ld	[b2_happy],a
		ld	[b2_happytimer],a
		ld	a,1
		ld	de,happyflash
		call	addtimed
		jp	tryfunzone

lightaward:	ld	a,[b2_awardready]
		or	a
		jp	nz,dorelit
		ld	a,1
		ld	[b2_awardready],a
		ld	a,TV_AWARDLIT
		jp	showtv

rides1:		ld	b,$10
		jr	rides
rides2:		ld	b,$08
		jr	rides
rides3:		ld	b,$04
		jr	rides
rides4:		ld	b,$02
		jr	rides
rides5:		ld	b,$01
rides:
		ld	a,[b2_ridesdelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b2_ridesdelay],a
		ld	a,[b2_rides]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	$1f
		jr	nz,.noincbonus
		ld	a,FX_RIDESALL
		call	InitSfx
		call	advancebonus
		jr	lightthrill
.noincbonus:	call	board2rides
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_RIDESBIT
		call	InitSfx
.delayed:	ret
lightthrill:	xor	a
		ld	[b2_rides],a
		ld	[b2_ridestimer],a
		ld	a,1
		ld	de,ridesflash
		call	addtimed
		jp	trythrillzone

board2happy:	ld	b,a
		ld	a,[b2_happy]
		cp	b
		ret	z
		ld	a,b
		ld	[b2_happy],a
happyshow:
		ld	e,B2_HAPPY5
		call	statebit
		ld	e,B2_HAPPY4
		call	statebit
		ld	e,B2_HAPPY3
		call	statebit
		ld	e,B2_HAPPY2
		call	statebit
		ld	e,B2_HAPPY1
statebit:	rrca
		push	af
		ld	d,0
		jr	nc,.dok
		inc	d
.dok:		call	newstate
		pop	af
		ret

board2rides:	ld	[b2_rides],a
ridesshow:
		ld	e,B2_LANE5
		call	statebit
		ld	e,B2_LANE4
		call	statebit
		ld	e,B2_LANE3
		call	statebit
		ld	e,B2_LANE2
		call	statebit
		ld	e,B2_LANE1
		jp	statebit


ridesflash:	ld	a,[b2_ridestimer]
		ld	c,a
		inc	a
		ld	[b2_ridestimer],a
		cp	11
		jr	nc,.incbonus
		rrca
		ld	a,0
		jr	c,.aok
		ld	a,$1f
.aok:		call	ridesshow
		ld	a,10
		ld	de,ridesflash
		jp	addtimed
.incbonus:	ld	a,[b2_rides]
		jp	ridesshow

happyflash:	ld	a,[b2_happytimer]
		ld	c,a
		inc	a
		ld	[b2_happytimer],a
		cp	11
		jr	nc,.dohappy
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,$1f
.aok:		call	happyshow
		ld	a,10
		ld	de,happyflash
		jp	addtimed
.dohappy:	ld	a,[b2_happy]
		jp	board2happy

shiftleft:	ld	a,[b2_rides]
		add	a
		cp	32
		jr	c,.aok3
		sub	31
.aok3:		call	board2rides

		ld	a,[b2_leftkick]
		or	a
		call	z,swapkickbacks

		ld	a,[b2_happy]
		add	a
		cp	32
		jr	c,.aok
		sub	31
.aok:		jp	board2happy

shiftright:	ld	a,[b2_rides]
		srl	a
		jr	nc,.aok3
		or	16
.aok3:		call	board2rides

		ld	a,[b2_rightkick]
		or	a
		call	z,swapkickbacks

		ld	a,[b2_happy]
		srl	a
		jr	nc,.aok
		or	16
.aok:		jp	board2happy


swapkickbacks:	ld	a,[b2_leftkick]
		push	af
		ld	a,[b2_rightkick]
		call	leftkickback
		pop	af
		jp	rightkickback

addthrilltime:
		ld	a,[b2_thrilladd]
		add	5
		cp	99-THRILLTIME
		jr	c,.aok
		ld	a,99-THRILLTIME
.aok:		ld	[b2_thrilladd],a
		ret

startthrillride:
		ld	a,[any_table]
		or	a
		ret	nz
		call	CountBalls
		or	a
		ret	z
		ld	a,[any_firing]
		or	a
		ret	nz
		ld	a,FX_THRILLRIDESTART
		call	InitSfx
		call	setthrilltime	;reset thrill timer
		ld	a,TABLEGAME_THRILL
		ld	hl,MSGTHRILLRIDE
		jp	starttable

startfantasy:	ld	a,[any_table]
		or	a
		ret	nz
		call	CountBalls
		or	a
		ret	z
		ld	a,[any_firing]
		or	a
		ret	nz
		ld	a,FX_FANTASYSTART
		call	InitSfx
		xor	a
		ld	[b2_thrillride],a
		ldh	a,[pin_difficulty]
		or	a
		jr	z,.bitscarryover
		dec	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_fantasybits]
		and	MASK_LEFTSCOOP|MASK_RIGHTSCOOP|MASK_SNACKBAR
.aok:		ld	[b2_fantasybits],a
.bitscarryover:
		call	nighton
		ld	a,TABLEGAME_FANTASY
		ld	hl,MSGFANTASY
		jr	starttable
starthide:	ld	a,[any_table]
		or	a
		ret	nz
		call	CountBalls
		or	a
		ret	z
		ld	a,[any_firing]
		or	a
		ret	nz
		xor	a
		ld	[b2_wanthide],a
		ld	[b2_hidedone],a
		ld	[b2_hidecollect],a
		call	newhider
		ld	a,FX_HIDESTART
		call	InitSfx	
		ld	a,TABLEGAME_HIDE
		ld	hl,MSGHIDE
		jr	starttable

startbumper:
		xor	a
		ld	[b2_fungame],a
		ld	[b2_bumpergone],a
		ld	hl,b2_bumperhits
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ld	hl,IDX_MAIN0028CHG
		call	MakeChanges
		ld	hl,IDX_MAIN0029CHG
		call	MakeChanges
		ld	hl,IDX_MAIN0030CHG
		call	MakeChanges
		ld	hl,IDX_MAIN0031CHG
		call	MakeChanges
		ld	hl,IDX_REDBUMPPKG
		call	IDXPalette4now
		ld	hl,IDX_GREENBUMPPKG
		call	IDXPalette5now
		ld	hl,IDX_YELLOWBUMPPKG
		call	IDXPalette6now
		ld	hl,IDX_BLUEBUMPPKG
		call	IDXPalette7now
		ld	a,1
		ldh	[hPalFlag],a
		ld	a,TV_BUMPER
		call	showtv
		ld	a,TABLEGAME_BUMPER
		ld	hl,MSGBUMPER
		jr	starttable

starttable:	ld	[any_table],a
		call	statusflash
		call	tablesong
		ld	hl,tabletimes
		ldh	a,[pin_difficulty]
		add	l
		ld	l,a
		jr	nz,.noinch
		inc	h
.noinch:	ld	a,[hl]
		ld	[any_tabletime],a
		ret

bumpercar:	ld	hl,b2_bumperhits
		ld	b,0
		push	bc
		add	hl,bc
		inc	[hl]
		ld	a,[hl]
		push	af
		cp	BUMPERHITS
		ld	hl,0
		jr	c,.notgone
		ld	hl,IDX_MAIN0028CHG
		add	hl,bc
		call	UndoChanges
		ld	a,FX_BUMPERCARGONE
		call	InitSfx
		ld	a,TV_BUMPER
		call	showtv
		ld	hl,b2_bumpergone
		inc	[hl]
		ld	a,[hl]
		ld	l,a
		swap	a
		ld	h,a
		add	a
		add	h
		add	l
		add	l
		ld	l,a
		ld	h,0
		jr	.gone
.notgone:	push	hl
		ld	a,FX_BUMPERCARHIT
		call	InitSfx
		pop	hl
.gone:		pop	af
		push	af
		add	a
		ld	c,a
		add	a
		add	a
		add	c
		ld	c,a
		ld	b,0
		add	hl,bc
		call	addthousandshlinform
		pop	af
		pop	bc
		cp	5
		ret	nc
		ld	hl,b2_bumperhits+4
		add	hl,bc
		ld	[hl],10
		sla	c
		ld	e,a
		ld	d,0
		ld	hl,.markpal
		push	hl
		ld	hl,bumpercalls
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	hl,bumperidx
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		add	hl,de
		ret
.markpal:	ld	a,1
		ldh	[hPalFlag],a
		ret
bumpercalls:	dw	IDXPalette4now
		dw	IDXPalette5now
		dw	IDXPalette6now
		dw	IDXPalette7now

bumperidx:	dw	IDX_REDBUMPPKG
		dw	IDX_GREENBUMPPKG
		dw	IDX_YELLOWBUMPPKG
		dw	IDX_BLUEBUMPPKG

;a=value to display
board2popups:
		push	af
		call	board2popupoff
		pop	af
		ld	[b2_popupstate],a
		ld	e,a
		ld	d,0
		ld	hl,IDX_MAIN0020CHG
		add	hl,de
		or	a
		call	nz,MakeChanges
		ld	a,[b2_popupstate]
		ld	e,B2_PC
		call	statebit
		ld	e,B2_PB
		call	statebit
		ld	e,B2_PA
		call	statebit
		ld	a,[b2_popupstate]
		cpl
board2popshow:
		ld	e,B2_CLIGHT
		call	statebit
		ld	e,B2_BLIGHT
		call	statebit
		ld	e,B2_ALIGHT
		jp	statebit
board2popupoff:
		ld	a,[b2_popupstate]
		or	a
		ret	z
		ld	e,a
		ld	d,0
		ld	hl,IDX_MAIN0020CHG
		add	hl,de
		jp	UndoChanges

clock:		ld	[b2_clock],a
clockshow:	ld	e,B2_CLOCKC
		call	statebit
		ld	e,B2_CLOCKB
		call	statebit
		ld	e,B2_CLOCKA
		jp	statebit
clockflash:	ld	a,[b2_clocktimer]
		ld	c,a
		inc	a
		ld	[b2_clocktimer],a
		cp	11
		jr	nc,.done
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,7
.aok:		call	clockshow
		ld	a,10
		ld	de,clockflash
		jp	addtimed
.done:		ld	a,[b2_clock]
		jr	clockshow


dropb:		ld	[b2_dropb],a
dropbshow:	ld	e,B2_B4
		call	statebit
		ld	e,B2_B3
		call	statebit
		ld	e,B2_B2
		call	statebit
		ld	e,B2_B1
		jp	statebit
dropbflash:	ld	a,[b2_dropbtimer]
		ld	c,a
		inc	a
		ld	[b2_dropbtimer],a
		cp	11
		jr	nc,.done
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,15
.aok:		call	dropbshow
		ld	a,10
		ld	de,dropbflash
		jp	addtimed
.done:		ld	a,[b2_dropb]
		jr	dropbshow



rightkickback:
		push	af
		ld	a,[b2_rightkick]
		or	a
		ld	hl,IDX_MAIN0019CHG
;;;		call	nz,UndoChanges
		pop	af
		ld	[b2_rightkick],a
		or	a
		ld	hl,IDX_MAIN0019CHG
;;;		call	nz,MakeChanges
		ld	a,[b2_rightkick]
		ld	d,a
		ld	e,B2_RIGHTKICK
		jp	newstate

leftkickback:
		push	af
		ld	a,[b2_leftkick]
		or	a
		ld	hl,IDX_MAIN0018CHG
;;;		call	nz,UndoChanges
		pop	af
		ld	[b2_leftkick],a
		or	a
		ld	hl,IDX_MAIN0018CHG
;;;		call	nz,MakeChanges
		ld	a,[b2_leftkick]
		ld	d,a
		ld	e,B2_LEFTKICK
		jp	newstate

b2popupflash:	ld	a,[b2_poptimer]
		ld	c,a
		inc	a
		ld	[b2_poptimer],a
		cp	11
		jr	nc,.lighttrap
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,7
.aok:		call	board2popshow
		ld	a,10
		ld	de,b2popupflash
		jp	addtimed
.lighttrap:	ld	a,7
		call	board2popshow
		ld	a,1
		ld	[b2_leftlocked],a
		ret

hitrightkick:	ld	a,[b2_rightkick]
		or	a
		ret	z
		ld	a,[b2_kicklock]
		or	a
		jr	nz,.locked
		ldh	a,[pin_difficulty]
		or	a
		jr	z,.locked	;easy never goes away
		ld	a,[any_ballsaver]
		or	a
		jr	nz,.locked
		ld	a,KICKDIE
		ld	[b2_kickdie],a
.locked:	ld	a,FX_KICKBACK
		call	InitSfx
		ld	a,TV_KICKBACK
		call	showtv
		ld	hl,MSGKICKBACK
		call	statusflash
		call	RumbleHigh
		ld	a,KICKBACKVEL&255
		ldh	[pin_vy],a
		ld	a,KICKBACKVEL>>8
		ldh	[pin_vy+1],a
		ret

hitleftkick:	ld	a,[b2_leftkick]
		or	a
		ret	z
		ld	a,[b2_kicklock]
		or	a
		jr	nz,.locked
		ldh	a,[pin_difficulty]
		or	a
		jr	z,.locked	;easy never goes away
		ld	a,[any_ballsaver]
		or	a
		jr	nz,.locked
		ld	a,KICKDIE
		ld	[b2_kickdie],a
.locked:	ld	a,FX_KICKBACK
		call	InitSfx
		ld	a,TV_KICKBACK
		call	showtv
		ld	hl,MSGKICKBACK
		call	statusflash
		call	RumbleHigh
		ld	a,KICKBACKVEL&255
		ldh	[pin_vy],a
		ld	a,KICKBACKVEL>>8
		ldh	[pin_vy+1],a
		ret

b2finishedmode:
		ld	hl,any_inmulti
		ld	a,[hl]
		or	a
		jr	z,.notmulti
		ld	[hl],0
		cp	TABLEGAME_ROLLERMULTI
		ret	z
.notmulti:
		ret

board2chances:
		db	6
		dw	award250k
		db	5
		dw	award500k
		db	4
		dw	award750k
		db	3
		dw	award1000k
		db	6
		dw	award25kjackpots
		db	5
		dw	award50kjackpots
		db	7
		dw	awardbonus1
		db	6
		dw	awardbonus2
		db	5
		dw	awardbonus3
		db	4
		dw	awardbonus4
		db	6
		dw	awardthrill
		db	6
		dw	awardfun
		db	6
		dw	awardadvancetop
		db	3
		dw	awardmaxtop
		db	4
		dw	awardholdbonus
		db	1
		dw	awardextraball
		db	4
		dw	awardholdpops
		db	5
		dw	award30saver
		db	4
		dw	award60saver
		db	8
		dw	awardkickback
		db	6
		dw	awardsuperkick
		db	5
		dw	awardrollerlock
		db	5
		dw	awardflumelock
		db	6
		dw	awardthrillpoint1
		db	5
		dw	awardthrillpoint2
		db	4
		dw	awardthrillpoint3
		db	3
		dw	awardthrillpoint4
		db	0

awardthrillpoint1:
		ld	hl,MSGTHRILL1POINT
		ld	c,1
		jr	awardthrillpoints
awardthrillpoint2:
		ld	hl,MSGTHRILL2POINTS
		ld	c,2
		jr	awardthrillpoints
awardthrillpoint3:
		ld	hl,MSGTHRILL3POINTS
		ld	c,3
		jr	awardthrillpoints
awardthrillpoint4:
		ld	hl,MSGTHRILL4POINTS
		ld	c,4
awardthrillpoints:
		ld	a,[any_table]
		or	a
		jp	nz,tryagain
		ld	a,[b2_thrillride]
		ld	b,a
		cp	10
		jp	z,tryagain
		add	c
		cp	10
		jr	c,.aok
		ld	a,10
		sub	b
		ld	c,a
		add	b
.aok:		ld	[b2_thrillride],a
		push	hl
		ld	a,c
		call	thrillpointbonus
		call	showthrillride
		ld	a,FX_THRILLLETTER
		call	InitSfx
		pop	hl
;tv
		jp	b2flashaccepted

thrillpointbonus:
		ld	c,a
		add	a
		add	a
		add	c
		ld	b,-1
.div10:		inc	b
		sub	10
		jr	nc,.div10
		add	10
		ld	c,a
		call	IncBonusVal	;5000 * # of thrill points
		ld	a,[b2_thrillride]
		or	a
		ret	z
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,thrillridetvs
		add	hl,bc
		ld	a,[hl]
		jp	showtv
thrillridetvs:	db	TV_T
		db	TV_H
		db	TV_R
		db	TV_I
		db	TV_L
		db	TV_L
		db	TV_R
		db	TV_I
		db	TV_D
		db	TV_E


awardrollerlock:
		ld	a,[any_table]
		or	a
		jp	nz,tryagain
		ld	a,[b2_leftlocked]
		or	a
		jp	nz,tryagain
		inc	a
		ld	[b2_leftlocked],a
		xor	a
		call	board2popups
		call	b2showlockopen
		jp	b2accepted

awardflumelock:
		ld	a,[any_table]
		or	a
		jp	nz,tryagain
		ld	a,[b2_rightlocked]
		or	a
		jp	nz,tryagain
		ld	[b2_rightramps],a
		inc	a
		ld	[b2_rightlocked],a
		call	b2showlockopen
		jp	b2accepted

awardkickback:
		ld	a,[b2_leftkick]
		or	a
		jp	nz,tryagain
		ld	a,[b2_rightkick]
		or	a
		jp	nz,tryagain
		ld	a,MAXKICKSPIN
		ld	[b2_kickspin],a
		ld	a,1
		call	leftkickback
		ld	a,FX_KICKLIT
		call	InitSfx
		ld	a,TV_KICKBACKLIT
		call	showtv
		ld	hl,MSGKICKBACKOPEN
		jp	b2flashaccepted

awardsuperkick:
		ld	a,[b2_kickdie]
		or	a
		jp	nz,tryagain
		ld	a,[b2_kicklock]
		or	a
		jp	nz,tryagain
		call	bothon
;tv super kickback
		ld	hl,MSGSUPERKICKBACK
		jp	b2flashaccepted

awardholdpops:	ld	a,[b2_holdpops]
		or	a
		jp	nz,tryagain
		inc	a
		ld	[b2_holdpops],a
		ld	a,TV_POPSHELD
		call	showtv
		jp	b2accepted

awardextraball:
		ld	a,[any_awardextra]
		or	a
		jp	nz,tryagain
		inc	a
		ld	[any_awardextra],a
		call	doextraopen
		jp	b2accepted

awardholdbonus:
		ld	a,[b2_holdmult]
		or	a
		jp	nz,tryagain
		call	b2showmultheld
		jp	b2accepted


awardthrill:	ld	a,[b2_ridestimer]
		or	a
		jp	nz,tryagain
		ld	a,[b2_thrillgame]
		or	a
		jp	nz,tryagain
		ld	a,[b2_thrillzone]
		cp	$1f
		jp	z,tryagain
		call	lightthrill
;tv thrill game lit
		ld	hl,MSGTHRILLGAMELIT
		jp	b2flashaccepted

awardfun:	ld	a,[b2_happytimer]
		or	a
		jp	nz,tryagain
		ld	a,[b2_fungame]
		or	a
		jp	nz,tryagain
		ld	a,[b2_funzone]
		cp	$1f
		jp	z,tryagain
		call	lightfun
;tv fun game lit
		ld	hl,MSGFUNGAMELIT
		jp	b2flashaccepted

awardadvancetop:
		call	advancetops
		jp	z,tryagain
		ld	a,TV_POPSADVANCED
		call	showtv
		ld	hl,MSGADVANCEDPOP
		jp	b2flashaccepted

awardmaxtop:
		ld	a,[b2_leftpops]
		cp	POPGREEN
		jr	c,.ok
		ld	a,[b2_centerpops]
		cp	POPGREEN
		jr	c,.ok
		ld	a,[b2_rightpops]
		cp	POPGREEN
		jr	c,.ok
		jp	tryagain
.ok:		ld	a,[b2_leftpops]
		cp	POPGREEN
		jr	nc,.noleft
		ld	a,POPGREEN
		ld	[b2_leftpops],a
		ld	de,(4<<8)+B2_LEFTPOP
		call	newstate
.noleft:	ld	a,[b2_centerpops]
		cp	POPGREEN
		jr	nc,.nocenter
		ld	a,POPGREEN
		ld	[b2_centerpops],a
		ld	de,(4<<8)+B2_CENTERPOP
		call	newstate
.nocenter:
		ld	a,[b2_rightpops]
		cp	POPGREEN
		jr	nc,.noright
		ld	a,POPGREEN
		ld	[b2_rightpops],a
		ld	de,(4<<8)+B2_RIGHTPOP
		call	newstate
.noright:
		ld	a,TV_POPSMAX
		call	showtv
		ld	hl,MSGPOPSTOMAX
		jp	b2flashaccepted



awardbonus1:	ld	c,1
		ld	hl,MSGBONUSP1
		jr	awardbonuses
awardbonus2:	ld	c,2
		ld	hl,MSGBONUSP2
		jr	awardbonuses
awardbonus3:	ld	c,3
		ld	hl,MSGBONUSP3
		jr	awardbonuses
awardbonus4:	ld	c,4
		ld	hl,MSGBONUSP4
awardbonuses:	ld	a,[b2_bonus]
		cp	MAXBONUS
		jp	z,tryagain
		add	c
		jp	c,tryagain
		cp	MAXBONUS
		jr	c,.fine
		jp	nz,tryagain
.fine:
		ld	[b2_bonus],a
		push	hl
		ld	a,TV_ADDBONUS
		call	showtv
		call	showbonus
		pop	hl
		jp	b2flashaccepted


award250k:	ld	hl,250
		jr	awardpoints
award500k:	ld	hl,500
		jr	awardpoints
award750k:	ld	hl,750
		jr	awardpoints
award1000k:	ld	hl,1000
awardpoints:	call	addthousandshlinform
		ld	a,TV_POINTS
		call	showtv
		jp	b2accepted

MAXJACK		EQU	1999

award25kjackpots:
		ld	c,25
		ld	hl,MSGJACKPOTP25K
		jr	increasejackpots
award50kjackpots:
		ld	c,50
		ld	hl,MSGJACKPOTP50K
increasejackpots:
		ld	b,0
		push	hl
		ld	hl,b2_rollerjack
		call	increasejack
		ld	hl,b2_flumejack
		call	increasejack
		ld	a,TV_JACKPOTADD
		call	showtv
		pop	hl
		jp	b2flashaccepted
increasejacka:	ld	c,a
		ld	b,0
		jr	increasejack
increasejack1:	ld	bc,1
increasejack:	ld	a,[hli]
		add	c
		ld	e,a
		ld	a,[hl]
		adc	b
		ld	d,a
		ld	a,e
		sub	MAXJACK&255
		ld	a,d
		sbc	MAXJACK>>8
		jr	c,.deok
		ld	de,MAXJACK
.deok:		ld	[hl],d
		dec	hl
		ld	[hl],e
		ret


b2showmultheld:	ld	a,1
		ld	[b2_holdmult],a
		ld	a,TV_BONUSHELD
		jp	showtv

award60saver:
		ld	b,60
		ld	c,TV_60SAVER
		ld	hl,MSG60SAVER
		jr	b2savers
award30saver:
		ld	b,30
		ld	c,TV_30SAVER
		ld	hl,MSG30SAVER
b2savers:	ld	a,[any_ballsaver]
		or	a
		jp	nz,tryagain
		ld	a,b
		ld	[any_ballsaver],a
		ld	a,c
		push	hl
		call	showtv
		pop	hl
		jp	b2flashaccepted

tryagain:	ld	a,1
		ret
b2flashaccepted:
		call	statusflash
b2accepted:	xor	a
		ret

;hl=list of chances
;de=where to put table
b2chanceinit:
		push	de
		inc	de
		ld	a,l
		ld	[de],a
		inc	de
		ld	a,h
		ld	[de],a
		inc	de
		ld	a,1
		ldh	[hTmpLo],a
		ld	c,0
.initlp:	ld	a,[hli]
		or	a
		jr	z,.initdone
		inc	hl
		inc	hl
		ld	b,a
		add	c
		ld	c,a
		ldh	a,[hTmpLo]
.fill:		ld	[de],a
		inc	de
		dec	b
		jr	nz,.fill
		add	3
		ldh	[hTmpLo],a
		jr	.initlp
.initdone:	pop	de
		ld	a,c
		ld	[de],a
		ret

board2giveaward:
		ld	a,[b2_leftkick]
		or	a
		jr	nz,.normal
		ld	a,[b2_rightkick]
		or	a
		jr	nz,.normal
		call	random
		and	1
		jp	z,awardkickback
.normal:	ld	hl,wChances
		jp	b2dochance

;hl=any_chances
b2dochance:	push	hl
		ld	b,[hl]
		inc	hl
.rnd:		call	random
		cp	b
		jr	nc,.rnd
		ld	c,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		ld	b,0
		add	hl,bc
		ld	l,[hl]
		ld	h,b
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		rst	1
;		ld	de,.chanceret
;		push	de
;		jp	[hl]
;.chanceret:
		or	a
		pop	hl
		jr	nz,b2dochance
		ret

doextraopen:
		ld	a,FX_LIT
		call	InitSfx
		ld	hl,any_extra
		inc	[hl]
		ret

b2showlockopen:
		ld	hl,MSGLOCKOPEN
		call	statusflash
		ld	a,TV_LOCKLIT
		call	showtv
		ld	a,FX_LOCKOPEN
		jp	InitSfx

startmulti:	ld	[any_inmulti],a
		xor	a
		ld	[any_1234],a
		inc	a
		ld	[b2_jackready],a
		ld	hl,multiballsavers
		call	saverdifficulty
		ld	a,FX_MULTIBALL
		call	InitSfx
		ret

tableprocess:	ld	a,[any_table]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(tableprocesses)
		ld	l,a
		ld	a,0
		adc	HIGH(tableprocesses)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
b2dummytable:	ret

tableprocesses:
		dw	thrillprocess		;1
		dw	rollermultiprocess	;2
		dw	happyprocess		;3
		dw	fantasyprocess		;4
		dw	flumemultiprocess	;5
		dw	hideprocess		;6
		dw	bumperprocess		;7

HIDECOLLECT	EQU	100

hideprocess:
		ld	a,[b2_hidecollect]
		or	a
		ret	nz
		ld	a,[b2_hideyoohoo]
		dec	a
		jr	nz,.aok
		ld	a,FX_HIDEAPPEAR
		call	InitSfx
		ld	a,YOOHOOTIME
.aok:		ld	[b2_hideyoohoo],a
		ret

bumperprocess:
		ld	hl,b2_bumperhits+4
		ld	a,[hl]
		or	a
		jr	z,.nodec0
		dec	[hl]
.nodec0:	inc	hl
		ld	a,[hl]
		or	a
		jr	z,.nodec1
		dec	[hl]
.nodec1:	inc	hl
		ld	a,[hl]
		or	a
		jr	z,.nodec2
		dec	[hl]
.nodec2:	inc	hl
		ld	a,[hl]
		or	a
		jr	z,.nodec3
		dec	[hl]
.nodec3:
		ld	hl,b2_bumperhits
		ld	a,[hli]
		cp	BUMPERHITS
		ret	c
		ld	a,[hli]
		cp	BUMPERHITS
		ret	c
		ld	a,[hli]
		cp	BUMPERHITS
		ret	c
		ld	a,[hl]
		cp	BUMPERHITS
		ret	c
		ld	hl,b2_funzone
		set	0,[hl]
		ld	hl,1000
		call	addthousandshlinform
		ld	hl,MSGBUMPERWON
		call	statusflash
		ld	a,FX_BUMPERCARWON
		call	InitSfx
		jp	endtable


;c=code
tryhidecollect:
		ld	a,[any_table]
		cp	TABLEGAME_HIDE
		ret	nz
		ld	a,[b2_hidecollect]
		or	a
		ret	nz
		ld	a,[b2_hide]
		cp	c
		ret	nz
		ld	hl,hidefound
		call	addtabletime
		ld	a,HIDECOLLECT
		ld	[b2_hidecollect],a
		ld	a,FX_HIDEFOUND
		jp	InitSfx

thrillprocess:
		ld	a,[b2_12guage]
		cp	MAXTHRILL
		ret	c
		sub	MAXTHRILL
		ld	[b2_12guage],a
		ld	c,1

		ld	a,[b2_thrillride]
		cp	10
		jr	nc,.nope
		inc	a
		ld	[b2_thrillride],a
		cp	10
		call	z,endtable
		call	showthrillride
		ld	a,FX_THRILLLETTER
		call	InitSfx
		ld	a,1
		call	thrillpointbonus
.nope:		ret

fantasyprocess:
		ld	a,[b2_fantasybits]
		cp	$fe
		ret	nz
		xor	a
		ld	[b2_fantasybits],a
		ld	a,FX_FANTASYWON
		call	InitSfx
		ld	hl,1000
		call	addthousandshlinform
		ld	a,1
		ld	[b2_fantasydone],a
		jr	endtable

happyprocess:
		ret

flumemultiprocess:
		ret
rollermultiprocess:
		ret


setthrilltime:	ld	a,[b2_thrilladd]
		add	THRILLTIME
		ld	[b2_thrilltimer],a
		ret

endtable:	ld	a,[any_table]
		or	a
		ret	z
		cp	TABLEGAME_THRILL
		jr	z,.thrillend
		cp	TABLEGAME_FANTASY
		jr	z,.fantasyend
		cp	TABLEGAME_ROLLERMULTI
		jr	z,.thrillmultiend
		cp	TABLEGAME_HIDE
		jr	z,.hideend
		cp	TABLEGAME_BUMPER
		jr	z,.bumperend
		cp	TABLEGAME_HAPPY
		jr	z,.happyend
		jr	b2quietend

.happyend:	call	nightoff
		jr	b2quietend

.bumperend:
		ld	hl,IDX_MAIN0028CHG
		call	UndoChanges
		ld	hl,IDX_MAIN0029CHG
		call	UndoChanges
		ld	hl,IDX_MAIN0030CHG
		call	UndoChanges
		ld	hl,IDX_MAIN0031CHG
		call	UndoChanges
		jr	b2quietend

.hideend:	xor	a
		ld	[b2_hidecollect],a
		ld	[b2_hide],a
		ld	[b2_hidedone],a
		ld	[b2_hideframe],a
		ld	[b2_wanthide],a
		jr	b2quietend
.thrillend:
		call	addthrilltime
		call	setthrilltime
		jr	b2quietend

.fantasyend:
		call	setthrilltime
		call	showthrillride
		call	nightoff
		jr	b2quietend

.thrillmultiend:
		ld	a,7
		call	board2popups
		ld	hl,MSGROLLERMULTIOVER
		jr	.anyend


.anyend:	call	statusflash
b2quietend:
		ld	a,SONG_TABLE
		call	PrefTune1
		xor	a
		ld	[any_table],a
		ld	[any_tabletime],a
		ld	a,[any_tvhold]
		or	a
		jr	nz,.ok
		ld	a,1
		ld	[any_tvhold],a
.ok:		jp	b2finishedmode


b2starthappy:
		xor	a
		ld	[wStartHappy],a
		ld	a,TABLEGAME_HAPPY
		call	startmulti
		ld	a,2
		ld	[any_happyfire],a
		call	b2triggerhappy
		ld	a,TABLEGAME_HAPPY
		ld	[any_table],a
		call	tablesong
		call	saver60
		ld	hl,MSGHAPPYMULTI
		jp	statusflash

b2happyfire:
		ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		call	AddBall
		ld	hl,any_happyfire
		dec	[hl]
		ret	z
b2triggerhappy:
		ld	de,b2happyfire
		ld	a,10
		jp	addtimed

b2doextraball:	ld	hl,any_extraball
		inc	[hl]
		jr	nz,.fine
		dec	[hl]
.fine:		ld	a,FX_EXTRABALL
		call	InitSfx
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
		ld	a,TV_EXTRABALL
		jp	showtv

SPINNERFRAMES	EQU	16
SPINNERCENTER	EQU	8
SPINNERX	EQU	142
SPINNERY	EQU	165

board2spinner:
		ldh	a,[pin_dspinner]
		ld	b,a
		ldh	a,[pin_spinner]
		ld	d,a
		add	b
		cp	SPINNERFRAMES*8
		jr	c,.aok2
		cp	(256+SPINNERFRAMES*8)/2
		jr	c,.above
		add	SPINNERFRAMES*8
		jr	.aok2
.above:		sub	SPINNERFRAMES*8
.aok2:		ldh	[pin_spinner],a
		cp	4*8
		jr	c,.nocredit
		cp	12*8
		jr	nc,.nocredit
		ld	e,a
		ld	a,d
		cp	4*8
		jr	c,.nocredit
		cp	12*8
		jr	nc,.nocredit
		xor	e
		and	8*8
		jr	z,.nocredit
;Spinner one credit
		ld	hl,b2_kickspin
		ld	a,[hl]
		cp	MAXKICKSPIN
		jr	z,.noincm
		add	KICKSPINADD
		cp	MAXKICKSPIN
		ld	[hl],a
		jr	c,.noincm
		ld	[hl],MAXKICKSPIN
		ld	a,[b2_rightkick]
		or	a
		jr	nz,.noincm
		ld	a,[b2_leftkick]
		or	a
		jr	nz,.noincm
		ld	a,FX_KICKLIT
		call	InitSfx
		ld	a,TV_KICKBACKLIT
		call	showtv
		ld	a,1
		call	rightkickback
.noincm:

		ld	a,FX_SPINNER
		call	InitSfx

		ld	hl,b2_flumejack
		ld	a,5
		call	increasejacka

		ld	de,spinnerscore
		call	addscore
.nocredit:
		ldh	a,[pin_dspinner]
		ld	b,a
		ld	a,[wTime]
		and	7
		jr	nz,.nochange
		ldh	a,[pin_spinner]
		srl	a
		srl	a
		srl	a
		jr	z,.nochange
		cp	SPINNERFRAMES>>1
		jr	c,.decb
		inc	b
		jr	.incb
.decb:		dec	b
.incb:
.nochange:
		ld	a,[wTime]
		and	15
		jr	nz,.nofriction
		ld	a,b
		or	a
		jr	z,.nofriction
		add	a
		jr	nc,.decb2
		inc	b
		jr	.incb2
.decb2:		dec	b
.incb2:
.nofriction	ld	a,b
		ldh	[pin_dspinner],a

		ld	a,[wMapXPos]
		and	$e0
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		ld	de,SPINNERX<<5
		ld	a,e
		sub	l
		ld	l,a
		ld	a,d
		sbc	h
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	d,h

		ld	a,[wMapYPos]
		and	$e0
		ld	l,a
		ld	a,[wMapYPos+1]
		dec	a
		ld	h,a
		ld	bc,SPINNERY<<5
		ld	a,c
		sub	l
		ld	l,a
		ld	a,b
		sbc	h
		inc	a
		ld	h,a

		add	hl,hl
		ret	c
		add	hl,hl
		ret	c
		add	hl,hl
		ret	c
		ld	a,h
		sub	8
		ld	e,a

		ldh	a,[pin_spinner]
		srl	a
		srl	a
		srl	a
		add	SPINNERCENTER
		cp	SPINNERFRAMES
		jr	c,.aok
		sub	SPINNERFRAMES
.aok:		ld	l,a
		add	255&IDX_SPINNER
		ld	c,a
		ld	a,0
		adc	IDX_SPINNER>>8
		ld	b,a
		ld	a,l
		sub	SPINNERCENTER+1
		jr	nc,.aok4
		add	SPINNERFRAMES
.aok4:		ld	a,GROUP_SPINNER
		jp	AddFigure

SPINNERMAXVEL	EQU	6
SPINNERBIAS	EQU	2
hitspinner:
		ld	h,-13
		ld	l,29
		call	passedby
		ld	a,d
		add	a
		ld	a,d
		jr	c,.neg
		add	SPINNERBIAS
		cp	SPINNERMAXVEL
		jr	c,.aok
		ld	a,SPINNERMAXVEL
		jr	.aok
.neg:		sub	SPINNERBIAS
		cp	-SPINNERMAXVEL
		jr	nc,.aok
		ld	a,-SPINNERMAXVEL
.aok:		add	a
		cpl
		inc	a
		ldh	[pin_dspinner],a
.nochange:	ret


tablesong:	ld	a,[any_table]
		ld	c,a
		ld	b,0
		ld	hl,songmap-1
		add	hl,bc
		ld	a,[hl]
		or	a
		ret	z
		jp	PrefTune2

songmap:	db	SONG_THRILL		;1
		db	SONG_ROLLERMULTI	;2
		db	SONG_HAPPY		;3 lights out
		db	SONG_FANTASY		;4
		db	SONG_FLUMEMULTI		;5
		db	SONG_HIDE		;6
		db	SONG_BUMPER		;7
		db	0
		db	0
		db	0
		db	0
		db	0
		db	0

tryswitch:
		call	AnyMessages
		ret	nz
		ld	hl,any_switchcount
		inc	[hl]
		ld	a,[hl]
		cp	SWITCHHOLD
		ret	c
		xor	a
		ld	[hl],a
		ld	[any_wantswitch],a
		call	board2popupoff
		call	SwitchPlayers
		call	b2restoreq
		ld	a,[any_ballsleft]
		or	a
		ret	z
		dec	a
		ld	[any_ballsleft],a
		call	PlayerReport

		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]

		ld	a,1
		ld	[any_wantfire],a
		ret

tvplayers:	db	TV_CHOCO
		db	TV_TWIZZLER
		db	TV_SYRUP
		db	TV_KISS

PlayerReport:
		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		ld	hl,tvplayers
		add	hl,bc
		push	hl
		ld	hl,MSGPLAYER1
		add	hl,bc
		call	statusflash
		pop	hl
		ld	a,[hl]
		jp	showtv


treattab:	db	39,43,22,42,44,34,25,36,23,11
		db	45,15,9,12,38,3,49,17,16,24
		db	30,8,14,21,29,35,13,2,40,18
		db	20,33,19,0,26,5,1,27,41,46
		db	10,31,6,4,47,37,32,48,28,7


treat:		ld	hl,b2_treatstaken
		inc	[hl]
		jr	nz,.mok
		dec	[hl]
.mok:
		ld	a,[b2_treat]
		cp	-1
		jr	nz,.norand
.r50:		call	random
		and	$3f
		cp	50
		jr	nc,.r50
		ld	[b2_treat],a
.norand:
		ld	c,a
		ld	b,0
		ld	hl,treattab
		add	hl,bc
		ld	c,[hl]
		ld	hl,treatvalues
		add	hl,bc
		ld	l,[hl]
		ld	h,0
		push	bc
		call	addthousandshlinform
		pop	bc
		push	bc
		ld	hl,MSGTREATS
		add	hl,bc
		call	statusflash
		ld	hl,b2_wanthide
		inc	[hl]
		pop	bc
		ld	a,c
		call	showtreat
		ld	a,FX_TREAT
		call	InitSfx
		ld	a,[b2_treat]
		inc	a
		cp	50
		jr	c,.aok
		xor	a
.aok:		ld	[b2_treat],a
		ret
treatvalues:	db	15,15,15,15,15,15,20,25,25,25,25,25,25
		db	35,40,40,45,45,50,50,50,50,50,50,60
		db	65,65,65,70,70,70,75,75,75,75,75,75,75,75,75
		db	80,80,85,85,90,90,100,125,150,150

;sets carry flag if not enough treats collected
enoughtreats:	ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,treatsneeded
		add	hl,bc
		ld	a,[b2_treatstaken]
		cp	[hl]
		ret
treatsneeded:	db	12,24,36

tryridephoto:	ld	hl,b2_nextphoto
		inc	[hl]
		ld	a,[hl]
		cp	3
		jr	z,.photo1
		cp	7
		jr	z,.photo2
		cp	12
		jr	z,.photo3
		cp	17
		jr	z,.photo4
		ret
.photo1:	ld	hl,100		;100k points
		jr	.restscore
.photo4:	ld	[hl],12
.photo2:	ld	hl,250		;250k points
		jr	.restscore
.photo3:	call	doextraopen
		jr	.rest
.restscore:	call	addthousandshlinform
.rest:		ld	hl,MSGRIDEPHOTO
		call	statusflash
		ld	a,TV_RIDEPHOTO
		call	showtv
		ld	a,FX_RIDEPHOTO
		call	InitSfx
		ld	bc,(1<<8)|5
		call	IncBonusVal
		ld	hl,b2_ridephotos
		inc	[hl]
		jr	nz,.mok
		dec	[hl]
.mok:		ret

trybrassring:	ld	hl,b2_nextring
		inc	[hl]
		ld	a,[hl]
		cp	3
		jr	z,.ring1
		cp	7
		jr	z,.ring2
		cp	12
		jr	z,.ring3
		cp	17
		jr	z,.ring4
		ret
.ring1:		ld	hl,100		;100k points
		jr	.restscore
.ring4:		ld	[hl],12
.ring2:		ld	hl,250		;250k points
		jr	.restscore
.ring3:		call	doextraopen
		jr	.rest
.restscore:	call	addthousandshlinform
.rest:		ld	hl,MSGBRASSRING
		call	statusflash
		ld	a,TV_BRASSRING
		call	showtv
		ld	a,FX_BRASSRING
		call	InitSfx
		ld	bc,(1<<8)|0
		call	IncBonusVal
		ld	hl,b2_brassrings
		inc	[hl]
		jr	nz,.mok
		dec	[hl]
.mok:		ret

incwarp:
		ld	hl,b2_warps
		inc	[hl]
		jr	nz,.mok
		dec	[hl]
.mok:		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		ld	hl,wWarps
		add	hl,bc
		inc	[hl]
		ret	nz
		dec	[hl]
		ret



board2_end::
