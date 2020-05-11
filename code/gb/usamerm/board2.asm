; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BOARD2.ASM                                                            **
; **                                                                       **
; ** Created : 20000316 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		SECTION	32
board2_start::



b2_dashpops	EQUS	"wTemp1024+00"
b2_trident	EQUS	"wTemp1024+01"
b2_volcanojack	EQUS	"wTemp1024+02"
b2_gate		EQUS	"wTemp1024+03"
b2_poptimer	EQUS	"wTemp1024+04"
b2_seconds	EQUS	"wTemp1024+05"
b2_left		EQUS	"wTemp1024+06" ;4
b2_right	EQUS	"wTemp1024+10" ;4
b2_leftinner	EQUS	"wTemp1024+14" ;4
b2_rightinner	EQUS	"wTemp1024+18" ;4
b2_leftu	EQUS	"wTemp1024+22" ;4
b2_rightu	EQUS	"wTemp1024+26" ;4
b2_leftuloop	EQUS	"wTemp1024+30"
b2_leftloop	EQUS	"wTemp1024+31" ;do
b2_rightloop	EQUS	"wTemp1024+32" ;not
b2_leftinnerloop EQUS	"wTemp1024+33" ;change
b2_rightinnerloop EQUS	"wTemp1024+34" ;order
b2_rightuloop	EQUS	"wTemp1024+35" ;of
b2_ramp		EQUS	"wTemp1024+36" ;these
b2_cloaksub	EQUS	"wTemp1024+37" ;subgame enambled
b2_volcanosub	EQUS	"wTemp1024+38" ;subgame enambled
b2_morganasub	EQUS	"wTemp1024+39" ;subgame enambled
b2_tridentsub	EQUS	"wTemp1024+40" ;subgame enambled
b2_icecavesub	EQUS	"wTemp1024+41" ;subgame enambled
b2_undertowsub	EQUS	"wTemp1024+42" ;subgame enambled
b2_dashsub	EQUS	"wTemp1024+43" ;subgame enambled
b2_bearsub	EQUS	"wTemp1024+44" ;subgame enambled
b2_scoop1	EQUS	"wTemp1024+45" ;do
b2_scoop2	EQUS	"wTemp1024+46" ;not
b2_scoop3	EQUS	"wTemp1024+47" ;change
b2_scoop4	EQUS	"wTemp1024+48" ;order
b2_bonus	EQUS	"wTemp1024+49"
b2_award	EQUS	"wTemp1024+50"
b2_awarddelay	EQUS	"wTemp1024+51"
b2_toplanes	EQUS	"wTemp1024+52"
b2_topdelay	EQUS	"wTemp1024+53"
b2_awardtimer	EQUS	"wTemp1024+54"
b2_awardready	EQUS	"wTemp1024+55"
b2_toptimer	EQUS	"wTemp1024+56"
b2_seatimer	EQUS	"wTemp1024+57"
b2_melody	EQUS	"wTemp1024+58"
b2_morganafire	EQUS	"wTemp1024+59"
b2_beartime	EQUS	"wTemp1024+60"
b2_melodytimer	EQUS	"wTemp1024+61"
b2_seastate	EQUS	"wTemp1024+62"
b2_seatimer	EQUS	"wTemp1024+63"
b2_backtimer	EQUS	"wTemp1024+64"
b2_kickback	EQUS	"wTemp1024+65"
b2_kicklock	EQUS	"wTemp1024+66"
b2_litgame	EQUS	"wTemp1024+67"
b2_completed	EQUS	"wTemp1024+68"
b2_popcount	EQUS	"wTemp1024+69"
b2_holdpops	EQUS	"wTemp1024+70"
b2_holdmult	EQUS	"wTemp1024+71"
b2_locked	EQUS	"wTemp1024+72"
b2_popupstate	EQUS	"wTemp1024+73"
b2_trapped	EQUS	"wTemp1024+74"
b2_megapops	EQUS	"wTemp1024+75"
b2_rampcount	EQUS	"wTemp1024+76"
b2_2balljack	EQUS	"wTemp1024+77"
b2_morganajack	EQUS	"wTemp1024+78" ;2 bytes
b2_sharkadd	EQUS	"wTemp1024+80"
b2_sharkdist	EQUS	"wTemp1024+81"
b2_beartime	EQUS	"wTemp1024+82"
b2_happyjack	EQUS	"wTemp1024+83" ;2
b2_leftkicklock	EQUS	"wTemp1024+85"
b2_leftkickback	EQUS	"wTemp1024+86"
b2_leftbacktimer EQUS	"wTemp1024+87"

GROUP_SPINNER2	EQU	2
GROUP_SPINNER2B	EQU	3
GROUP_TRIDENT	EQU	4
GROUP_REDFLIP	EQU	5


TRIDENTX	EQU	173<<5
TRIDENTY	EQU	305<<5

CODE_LEFT	EQU	1
CODE_RIGHT	EQU	2
CODE_LEFTINNER	EQU	3
CODE_RIGHTINNER	EQU	4
CODE_LEFTU	EQU	5
CODE_RIGHTU	EQU	6
CODE_RAMP	EQU	7

DASHWIN		EQU	12	;# of pop to win the dash tablegame
DASHTIME	EQU	120	;# of seconds allowed for dash tablegame
ICETIME		EQU	180	;# of seconds allowed for icecave tablegame
TRIDENTTIME	EQU	180	;# of seconds allowed for trident tablegame


TABLEGAME_EXTRA	EQU	1
TABLEGAME_ICECAVE EQU	2
TABLEGAME_UNDERTOW EQU	3
TABLEGAME_TRIDENT EQU	4
TABLEGAME_KICK	EQU	5
TABLEGAME_CLOAK	EQU	6
TABLEGAME_DASH	EQU	7
TABLEGAME_BEAR	EQU	8
TABLEGAME_VOLCANO EQU	9
TABLEGAME_MORGANA EQU	10
TABLEGAME_HAPPY	EQU	11

TV_VOLCANO	EQU	28
TV_MORGANA	EQU	32
TV_CLOAK	EQU	37
TV_TRIDENT	EQU	44
TV_ICECAVE	EQU	39
TV_UNDERTOW	EQU	28
TV_DASH		EQU	28
TV_BEAR		EQU	36
TV_HAPPY	EQU	40
TV_PEARL	EQU	23

board2info:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(board2process)	;wPinJmpProcess
		dw	board2process
		db	BANK(board2sprites)	;wPinJmpSprites
		dw	board2sprites
		db	BANK(board2hitflipper)	;wPinJmpHitFlipper
		dw	board2hitflipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
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
		dw	CUTOFFY			;wPinCutoff
		dw	IDX_TWO001CHG		;lflippers
		dw	IDX_TWO009CHG		;rflippers
		db	BANK(board2info)	;wPinHitBank
		db	BANK(Char0b0)		;wPinCharBank

board2maplist:	db	$2b	;height
		dw	IDX_BOARD2RGB
		dw	IDX_BOARD2MAP


b2phasetable:	dw	phaseb2indicator0
		dw	phaseb2ramp
		dw	phaseb2leftkick
		dw	phaseb2volcano
		dw	phaseb2indicator1
		dw	phaseb2kick
		dw	phaseb2locklight
		dw	phaseb2left
		dw	phaseb2indicator2
		dw	0
		dw	phaseb2right
		dw	phaseb2indicator3
		dw	phaseb2saver
		dw	phaseb2jackpot
		dw	0
		dw	phaseb2castle
		dw	phaseb2indicator4
		dw	phaseb2grotto
		dw	phaseb2leftkick
		dw	0
		dw	phaseb2indicator5
		dw	phaseb2kick
		dw	phaseb2leftinner
		dw	phaseb2rightinner
		dw	phaseb2indicator6
		dw	phaseb2icecave
		dw	0
		dw	phaseb2indicator7
		dw	phaseb2saver
		dw	0
		dw	phaseb2indicatorcenter
		dw	0

phaseb2volcano:
		ld	e,B2_VOLCANO
		ld	a,[b2_scoop2]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_volcanosub]
.aok:		jp	phaseb2flashing

phaseb2leftinner:
		ld	e,B2_LEFTINNER
		ld	a,[any_inmulti]
		or	a
		jr	z,.notmulti
		ld	a,[any_1234]
		cp	3
		jr	c,.notmulti
		ld	c,2
		ld	a,1
		jr	.done
.notmulti:	ld	c,1
		ld	a,[any_combo1]
		cp	1
		jr	z,.cok
		dec	c
.cok:		ld	a,[b2_leftinnerloop]
		or	c
		ld	c,1
.done:		jp	phaseb2flashing2

phaseb2rightinner:
		ld	e,B2_RIGHTINNER
		ld	c,1
		ld	a,[any_table]
		cp	TABLEGAME_UNDERTOW
		jr	z,.cok
		ld	a,[any_combo2]
		cp	4
		jr	z,.cok
		dec	c
.cok:		ld	a,[b2_rightinnerloop]
		or	c
		jp	phaseb2flashing
phaseb2left:
		ld	e,B2_LEFT
		ld	a,[any_combo2]
		cp	2
		ld	a,1
		jr	z,.aok
		ld	a,[b2_leftloop]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_cloaksub]
		ld	hl,b2_scoop1
		or	[hl]
		ld	hl,b2_morganasub
		or	[hl]
		ld	hl,b2_icecavesub
		or	[hl]
		ld	hl,b2_undertowsub
		or	[hl]
		jr	z,.aok
		ld	a,1
		ld	c,2
		jp	phaseb2flashing2
.aok:		jp	phaseb2flashing

phaseb2right:
		ld	e,B2_RIGHT
		ld	c,1
		ld	a,[any_combo1]
		cp	3
		jr	z,.cok
		dec	c
.cok:		ld	a,[b2_rightloop]
		or	c
		jp	phaseb2flashing
phaseb2ramp:
		ld	e,B2_RAMP

		ld	c,0
		ld	a,[any_inmulti]
		or	a
		jr	z,.notmulti
		ld	a,[any_1234]
		cp	3
		jr	c,.incc
.notmulti:	ld	a,[any_combo1]
		cp	2
		jr	z,.incc
		ld	a,[any_combo2]
		cp	3
		jr	nz,.cok
.incc:		inc	c
.cok:		ld	a,[b2_ramp]
		or	c
		jp	phaseb2flashing


phaseb2jackpot:
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
		jp	phaseb2flashing


phaseb2kick:	ld	a,[b2_kicklock]
		or	a
		jr	nz,.kickon
		ld	a,[b2_kickback]
		or	a
		jr	z,.kickoff
		ld	a,[b2_backtimer]
		or	a
		jr	z,.kickon
		dec	a
		ld	[b2_backtimer],a
		jr	z,.kickclose
		srl	a
		jr	c,.kickoff
.kickon:	ld	de,(1<<8)|B2_KICKLIGHT
		jp	b2newstate
.kickclose:	xor	a
		call	board2kickback
.kickoff:	ld	de,B2_KICKLIGHT
		jp	b2newstate

phaseb2leftkick:
		ld	a,[b2_leftkicklock]
		or	a
		jr	nz,.kickon
		ld	a,[b2_leftkickback]
		or	a
		jr	z,.kickoff
		ld	a,[b2_leftbacktimer]
		or	a
		jr	z,.kickon
		dec	a
		ld	[b2_leftbacktimer],a
		jr	z,.kickclose
		srl	a
		jr	c,.kickoff
.kickon:	ld	de,(1<<8)|B2_LEFTKICKLIGHT
		jp	b2newstate
.kickclose:	xor	a
		call	board2leftkickback
.kickoff:	ld	de,B2_LEFTKICKLIGHT
		jp	b2newstate



phaseb2indicatorcenter:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		ld	a,[any_tvback]
		or	a
		ret	nz
		ld	e,B2_MODES+8
		ld	a,[any_gothappy]
		ld	d,a
		jp	b2newstate
phaseb2indicator0:
		ld	a,[any_tvhold]
		or	a
		jr	z,.nohold
		dec	a
		ld	[any_tvhold],a
		jr	nz,.nohold
;		ld	a,[any_tvshow]
;		cp	8
;		jr	c,.not123
;		cp	11
;		jr	nc,.not123
;		ld	a,11
;		jp	b2showtv
;.not123:
		ld	a,[any_tvsp]
		or	a
		jp	nz,b2tvpop
		ld	a,[any_tvback]
		or	a
		jp	nz,b2forcekeeptv
.nohold:	ld	c,1
		jr	b2indicators
phaseb2indicator1:
		ld	c,2
		jr	b2indicators
phaseb2indicator2:
		ld	c,3
		jr	b2indicators
phaseb2indicator3:
		ld	c,4
		jr	b2indicators
phaseb2indicator4:
		ld	c,5
		jr	b2indicators
phaseb2indicator5:
		ld	c,6
		jr	b2indicators
phaseb2indicator6:
		ld	c,7
		jr	b2indicators
phaseb2indicator7:
		ld	c,8
;c=# of indicator to process
b2indicators:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		ld	a,[any_tvback]
		or	a
		ret	nz
		ld	a,c
		add	B2_MODES-1
		ld	e,a
		ld	b,0
		ld	d,b
		ld	hl,Bits-1
		add	hl,bc
		ld	a,[b2_litgame]
		cp	c
		ld	a,[b2_completed]
		jr	z,.islitgame
		and	[hl]
		ld	d,0
		jr	z,.noflash
		inc	d
		jr	.noflash
.islitgame:	and	[hl]
		ld	hl,wStates
		add	hl,de
		ld	d,1
		or	a
		jr	nz,.noflash
.flash:		ld	a,[hl]
		and	1
		xor	1
		ld	d,a
.noflash:	jp	b2newstate


phaseb2saver:
		ld	a,[any_ballsaver]
		cp	3
		jr	c,.nosaver
		ld	d,1
		cp	5
		jr	nc,.dok2
		bit	4,b
		jr	z,.dok2
		ld	d,0
		jr	.dok2
.nosaver:
		ld	d,0
.dok2:
		ld	e,B2_EBSAVER
		jp	b2newstate

phaseb2locklight:
		ld	de,0
		ld	a,[any_table]
		or	a
		jr	nz,.noince
		ld	a,[b2_locked]
		or	a
		jr	z,.noince
		ld	e,2
.noince:	ld	a,[any_extra]
		or	a
		jr	z,.noincd
		inc	d
.noincd:	bit	5,b
		jr	z,.dok
		ld	d,e
.dok:		ld	e,B2_EXTRALOCK
		jp	b2newstate

phaseb2grotto:
		ld	e,B2_GROTTO
		ld	a,[any_mlock1]
		or	a
		jr	nz,.nomlock
		ld	a,[any_table]
		cp	TABLEGAME_VOLCANO
		jr	z,.maybemlock
		cp	TABLEGAME_MORGANA
		jr	nz,.nomlock
.maybemlock:	push	bc
		call	CountBalls
		pop	bc
		cp	2
		jr	c,.nomlock
		ld	a,1
		jr	.aok
.nomlock:	ld	a,[b2_awardready]
		or	a
		jr	nz,.aok
		ld	a,[b2_scoop4]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_tridentsub]
		or	c
		ld	c,a
		ld	a,[b2_dashsub]
		or	c
.aok:		or	a
		jr	nz,.norm
		ld	d,1
		ld	a,[any_mlock1]
		or	a
		jp	nz,b2newstate
.norm:		jp	phaseb2flashing

phaseb2flashing:
		ld	c,1
phaseb2flashing2:
		ld	d,0
		bit	5,b
		jr	z,.dok
		or	a
		jr	z,.dok
		ld	d,c
.dok:		jp	b2newstate

phaseb2castle:
		push	bc
		ld	a,[any_extra]
		or	a
		jr	nz,.aok
		ld	a,[any_inmulti]
		or	a
		jr	z,.notmulti
		cp	TABLEGAME_CLOAK
		ld	a,0
		jr	z,.aok
		call	CountBalls
		cp	2
		ld	a,0
		jr	c,.aok
		inc	a
		jr	.aok
.notmulti:
		ld	a,[b2_scoop3]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_locked]
		or	a
		jr	z,.aok
.a1:		ld	a,1
.aok:		push	af
		ld	hl,IDX_TWO019CHG
		or	a
		jr	z,.close
		call	MakeChanges
		jr	.open
.close:		call	UndoChanges
.open:
		pop	de
		push	de
		ld	e,B2_WALLGATE
		call	b2newstate
		pop	de
		pop	bc
		ld	a,[any_mlock2]
		or	a
		ld	c,d
		ld	e,B2_ULIGHT
		ld	d,1
		jp	nz,b2newstate
		ld	a,c
		or	a
		jr	nz,.done
		ld	a,[any_combo1]
		cp	4
		jr	z,.loop
		ld	a,[any_combo2]
		cp	1
		jr	z,.loop
		ld	a,[b2_rightuloop]
		or	a
		jr	nz,.loop
		xor	a
		jr	.done
.loop:		ld	c,2
		ld	a,1
		jp	phaseb2flashing2
.done:		jp	phaseb2flashing


phaseb2icecave:
		ld	a,[b2_scoop1]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b2_icecavesub]
		ld	c,a
		ld	a,[b2_morganasub]
		or	c
		ld	c,a
		ld	a,[b2_cloaksub]
		or	c
		ld	c,a
		ld	a,[b2_undertowsub]
		or	c
		ld	c,a
		ld	a,[b2_bearsub]
		or	c
.aok:		push	af
		ld	hl,IDX_TWO020CHG
		or	a
		jr	z,.close
		call	MakeChanges
		jr	.open
.close:		call	UndoChanges
.open:
		pop	de
		push	de
		ld	e,B2_ICEGATE
		call	b2newstate
		pop	de
		ret


b2toppop:	ld	de,B2_TOPPOP
		jp	b2newstate
b2middlepop:	ld	de,B2_MIDDLEPOP
		jp	b2newstate
b2bottompop:	ld	de,B2_BOTTOMPOP
		jp	b2newstate
b2leftbumper:	ld	de,B2_LEFTBUMPER
		jp	b2newstate
b2rightbumper:	ld	de,B2_RIGHTBUMPER
		jp	b2newstate


board2collisions:
		dw	b2firedown,185/2,37/2
		db	6,3
		dw	b2enterramp,98/2,329/2
		db	9,8
		dw	b2exitramp,63/2,522/2
		db	5,3
		dw	b2award1lane,35/2,528/2
		db	3,3
		dw	b2award2lane,63/2,528/2
		db	3,3
		dw	b2award3lane,260/2,528/2
		db	3,3
		dw	b2award4lane,288/2,528/2
		db	3,3
		dw	b2award5lane,316/2,528/2
		db	3,3
		dw	b2topleft,156/2,66/2
		db	5,4
		dw	b2topright,184/2,66/2
		db	5,4
		dw	b2kick,316/2,642/2
		db	4,4
		dw	b2leftkick,36/2,642/2
		db	4,4
		dw	entericecave,E1X>>5,E1Y>>5
		db	5,5
		dw	entervolcano,E2X>>5,E2Y>>5
		db	4,4
		dw	entercastle,E3X>>5,E3Y>>5
		db	4,4
		dw	entergrotto,E4X>>5,E4Y>>5
		db	5,5
		dw	b2leftinner,122/2,283/2
		db	4,4
		dw	b2rightinner,244/2,296/2
		db	4,4
		dw	b2left,65/2,355/2
		db	5,5
		dw	b2right,287/2,319/2
		db	5,5
		dw	b2leftu,165/2,244/2
		db	6,6
		dw	b2rightu,199/2,284/2
		db	6,6
		dw	b2hitspinner,248/2,284/2
		db	6,6
		dw	b2shoot,347/2,576/2
		db	6,6
;		dw	b2sebastianreact,42/2,148/2
;		db	6,6
;		dw	b2sebastianreact,143/2,42/2
;		db	6,6
		dw	0

b2sebastianreact:
		ld	a,[wStates+B2_SEBASTIAN]
		or	a
		ret	nz
		ld	de,(1<<8)|B2_SEBASTIAN
		call	b2newstate
		ld	de,b2sebastianoff
		ld	a,30
		jp	addtimed
b2sebastianoff:
		ld	de,B2_SEBASTIAN
		jp	b2newstate

b2left:		ld	de,b2_left
		call	saveclock
		ld	hl,b2_right
		ld	a,B2OUTERTIME
		call	timelimit
		ret	nz
		call	b2loopcredit
		ld	c,CODE_RIGHT
		ld	hl,b2_rightloop
		jp	b2didloop

b2right:	ld	de,b2_right
		call	saveclock
		ld	hl,b2_left
		ld	a,B2OUTERTIME
		call	timelimit
		ret	nz
		call	b2loopcredit
		ld	c,CODE_LEFT
		ld	hl,b2_leftloop
		jp	b2didloop

b2leftinner:	ld	de,b2_leftinner
		call	saveclock
		ld	hl,b2_rightinner
		ld	a,B2INNERTIME
		call	timelimit
		ret	nz
		call	b2loopcredit
		ld	c,CODE_RIGHTINNER
		ld	hl,b2_rightinnerloop
		jp	b2didloop

b2rightinner:	ld	de,b2_rightinner
		call	saveclock
		ld	hl,b2_leftinner
		ld	a,B2INNERTIME
		call	timelimit
		ret	nz
		call	b2loopcredit
		ld	c,CODE_LEFTINNER
		ld	hl,b2_leftinnerloop
		call	b2didloop
		ld	a,[any_1234]
		cp	3
		jr	nz,.normalleftinner
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalleftinner
		cp	TABLEGAME_VOLCANO
		jp	z,b2volcanojackpot
		cp	TABLEGAME_CLOAK
		jp	z,b2cloakjackpot
		cp	TABLEGAME_MORGANA
		jp	z,b2morganajackpot
		cp	TABLEGAME_HAPPY
		jp	z,b2happyjackpot
.normalleftinner:
		ret

b2leftu:	ld	de,b2_leftu
		call	saveclock
		ld	hl,b2_rightu
		ld	a,B2UTIME
		call	timelimit
		ret	nz
		ld	hl,b2_2balljack
		ld	e,50
		call	incmax1
		call	b2loopcredit
		ld	c,CODE_RIGHTU
		ld	hl,b2_rightuloop
		jp	b2didloop

b2rightu:	ld	de,b2_rightu
		call	saveclock
		ld	hl,b2_leftu
		ld	a,B2UTIME
		call	timelimit
		ret	nz
		ld	hl,b2_2balljack
		ld	e,50
		call	incmax1
		call	b2loopcredit
		ld	c,CODE_LEFTU
		ld	hl,b2_leftuloop
		jp	b2didloop

B2OUTERTIME	EQU	180
B2INNERTIME	EQU	120
B2UTIME		EQU	60

b2loopcredit:	ld	de,loopscore
		jp	addscoreh

b2didloop:
		xor	a
		ld	[any_rampfast],a
b2didloopramp:
		ld	a,COMBOCLEARTIME
		ld	[any_comboclear],a
		ld	a,c
		push	hl
		call	b2combocheck
		call	IncBonusVal
		pop	hl
		ld	a,[hl]
		or	a
		ret	z
		ld	[hl],0
		ld	a,FX_TABLEADVANCE
		call	InitSfx
		ld	a,[any_table]
		cp	TABLEGAME_TRIDENT
		jr	nz,.nottrident
		ld	hl,b2_leftloop
		ld	a,[hli]
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		push	af
		cpl
		add	TV_TRIDENT+6+1
		call	b2keeptv
		pop	af
		jr	nz,.moretrident
		ld	de,score50m
		call	addscore
		ld	a,1
		ld	[b2_tridentsub],a
;		ld	a,SUBGAME_TRIDENT
;		call	unlocksub
		call	b2sublit
		call	b2endtable
		ret
;		ld	hl,MSGTRIDENTWON
;		jp	statusflash
.moretrident:
		ld	de,score5m
		call	addscore
		ld	hl,MSGMORETRIDENT
		jp	statusflash

.nottrident:
		cp	TABLEGAME_BEAR
		jr	nz,.notbear
		ld	hl,MSGBEARWON
		call	statusflash
		ld	a,1
		ld	[b2_bearsub],a
;		ld	a,SUBGAME_BEAR
;		call	unlocksub
		call	b2sublit
		ld	a,[b2_beartime]
		ld	l,a
		xor	a
		ld	h,a
		ld	[b2_beartime],a
		call	addmillionshl
		jp	b2endtable

.notbear:
		ret


b2msglooplist:	dw	MSG2LOOPS
		dw	MSG3LOOPS
		dw	MSG4LOOPS
		dw	MSG5LOOPS
		dw	MSG6LOOPS
		dw	MSG7LOOPS
		dw	MSG8LOOPS
		dw	MSG9LOOPS
		dw	MSGUNREAL


;a=new event
b2combocheck:
		ld	c,a

		cp	CODE_RAMP
		jr	z,.clearloopcount
		ld	hl,any_loopcount
		inc	[hl]
		jr	nz,.no255
		dec	[hl]
.no255:		ld	a,[hl]
		sub	2
		jr	c,.nomessage
		cp	8
		jr	c,.less8
		ld	a,8
.less8:		push	bc
		ld	hl,b2msglooplist
		call	flashlist
		ld	a,[any_loopcount]
		ld	c,a
		ld	a,[any_nextextra]
		cp	c
		jr	nz,.nope
		ld	b,7
		cp	3
		jr	z,.bok
		ld	b,10
.bok:		add	b
		ld	[any_nextextra],a
		call	b2doextraopen
.nope:
		pop	bc
.nomessage:
		jr	.contloopcount
.clearloopcount:
		xor	a
		ld	[any_loopcount],a
.contloopcount:

		ld	d,0

		ld	hl,b2combo1
		ld	a,[any_combo1]
		ld	e,a
		add	hl,de
		ld	a,[hl]
		cp	c
		jr	nz,.fail1
		ld	a,[any_combo1]
		inc	a
		cp	2
		jr	c,.good1
		push	af
		sub	2
		push	af
		ld	hl,b2combomsgs1
		call	flashlist
		call	IncBonusVal
		ld	a,[any_combo1]
		call	ComboSound
		pop	af
		call	b2comboscore
		pop	af
		cp	5
		jr	c,.good1
.fail1:		xor	a
.good1:		ld	[any_combo1],a

		ld	hl,b2combo2
		ld	a,[any_combo2]
		ld	e,a
		add	hl,de
		ld	a,[hl]
		cp	c
		jr	nz,.fail2
		ld	a,[any_combo2]
		inc	a
		cp	2
		jr	c,.good2
		push	af
		sub	2
		push	af
		ld	hl,b2combomsgs2
		call	flashlist
		call	IncBonusVal
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

b2combo1:	db	CODE_LEFT
		db	CODE_LEFTINNER
		db	CODE_RAMP
		db	CODE_RIGHT
		db	CODE_RIGHTU

b2combomsgs1:	dw	MSGCOMBO
		dw	MSGDOUBLECOMBO
		dw	MSGTRIPLECOMBO
		dw	MSGSUPERCOMBO

b2combo2:	db	CODE_RIGHT
		db	CODE_RIGHTU
		db	CODE_LEFT
		db	CODE_RAMP
		db	CODE_LEFTINNER

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
.v1:		ld	de,score5m
		ld	hl,MSG5M
		jr	.any
.v2:		ld	de,score10m
		ld	hl,MSG10M
		jr	.any
.v3:		ld	de,score25m
		ld	hl,MSG25M
		jr	.any
.v4:		ld	de,score50m
		ld	hl,MSG50M
.any:		push	hl
		call	addscore
		pop	hl
		jp	statusflash




E1X		EQU	35<<4	;ice cave
E1Y		EQU	68<<4
E2X		EQU	135<<4	;volcano
E2Y		EQU	207<<4
E3X		EQU	219<<4	;castle
E3Y		EQU	171<<4
E4X		EQU	33<<4	;grotto
E4Y		EQU	387<<4

E1VX		EQU	0
E1VY		EQU	32
E2VX		EQU	-13
E2VY		EQU	-29
E3VX		EQU	--5
E3VY		EQU	31
E4VX		EQU	27
E4VY		EQU	18

entericecave:	ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX
		ld	l,E1VY
		jr	b2traps
entervolcano:	ld	de,E2X
		ld	bc,E2Y
		ld	h,E2VX
		ld	l,E2VY
		jr	b2traps
entercastle:	ld	de,E3X
		ld	bc,E3Y
		ld	h,E3VX
		ld	l,E3VY
		jr	b2traps
entergrotto:	ld	de,E4X
		ld	bc,E4Y
		ld	h,E4VX
		ld	l,E4VY
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
		ld	a,c
		sub	255&E3X
		ld	e,a
		ld	a,b
		sbc	E3X>>8
		or	e
		jp	z,.take3
		jp	.take4
.take1:						;ice cave

		ld	a,[b2_scoop1]
		or	a
		jr	z,.noscoop1
		xor	a
		ld	[b2_scoop1],a
		ld	a,TV_ICECAVE+4
		call	b2keeptv
		ld	a,1
		ld	[b2_icecavesub],a
;		ld	a,SUBGAME_ICECAVE
;		call	unlocksub
		call	b2sublit
		ld	de,score50m
		call	addscore
		ld	hl,MSGICECAVEALL
		call	statusflash
		call	b2endtable
		jr	.done1
.noscoop1:
		ld	a,[any_table]
		or	a
		jr	nz,.done1

		ld	a,[b2_icecavesub]
		or	a
		jr	z,.noicecavesub
		xor	a
		ld	[b2_icecavesub],a
		ld	a,SUBGAME_ICECAVE
		call	ChainSub
		jr	.done1
.noicecavesub:
		ld	a,[b2_cloaksub]
		or	a
		jr	z,.nocloak
		xor	a
		ld	[b2_cloaksub],a
		ld	a,SUBGAME_CLOAK
		call	ChainSub
		jr	.done1
.nocloak:

		ld	a,[b2_undertowsub]
		or	a
		jr	z,.noundertow
		xor	a
		ld	[b2_undertowsub],a
		ld	a,SUBGAME_PRISON
		call	ChainSub
		jr	.done1
.noundertow:

		ld	a,[b2_bearsub]
		or	a
		jr	z,.nobear
		xor	a
		ld	[b2_bearsub],a
		ld	a,SUBGAME_BEAR
		call	ChainSub
		jr	.done1
.nobear:

		ld	a,[b2_morganasub]
		or	a
		jr	z,.nomorgana
		xor	a
		ld	[b2_morganasub],a
		ld	a,SUBGAME_MORGANA
		call	ChainSub
		jr	.done1
.nomorgana:

.done1:
		jp	b2set2

.take2:						;volcano
		ld	a,[b2_scoop2]
		or	a
		jr	z,.noscoop2
		xor	a
		ld	[b2_scoop2],a
		call	checkicecave
		jr	.done2
.noscoop2:
		ld	a,[any_table]
		or	a
		jr	nz,.nosubchain
		ld	a,[b2_volcanosub]
		or	a
		jr	z,.novolcanosub
		xor	a
		ld	[b2_volcanosub],a
		ld	a,SUBGAME_VOLCANO
		call	ChainSub
		jp	.done2
.novolcanosub:
		ld	a,[b2_locked]
		or	a
		jr	nz,.lockball

.nosubchain

.done2:
		jp	b2set2

.take3:						;castle
		ld	a,[any_extra]
		or	a
		jr	z,.noextra
		dec	a
		ld	[any_extra],a
		call	b2doextraball
		jp	.done3
.noextra:
		ld	a,[b2_scoop3]
		or	a
		jr	z,.noscoop3
		xor	a
		ld	[b2_scoop3],a
		call	checkicecave
		jp	.done3
.noscoop3:

		ld	a,[any_inmulti]
;		cp	TABLEGAME_HAPPY
;		jr	z,.trylock2
		cp	TABLEGAME_VOLCANO
		jr	z,.trylock2
		cp	TABLEGAME_MORGANA
		jr	nz,.nolock2
.trylock2:
		ld	a,[any_mlock2]
		or	a
		jr	nz,.nolock2
		call	CountBalls
		cp	2
		jr	c,.nolock2
		ld	a,1
		ld	[any_mlock2],a
		jp	b2lockedmulti
.nolock2:

		ld	a,[b2_locked]
		or	a
		jr	z,.notrap
		ld	a,[any_table]
		or	a
		jr	nz,.notrap
.lockball:
		xor	a
		ld	[b2_locked],a
		ld	hl,b2_trapped
		ld	a,[hl]
		cp	2
		jr	c,.not2
		call	RumbleHigh
		ld	a,TABLEGAME_VOLCANO
		call	b2startmulti
		ld	a,10
		call	b2showtv
		ld	a,11
		call	b2showtv
		ld	a,TV_VOLCANO
		ld	[any_tvback],a
		ld	[any_multibase],a
		ld	a,TABLEGAME_VOLCANO
		ld	[any_table],a
		call	b2tablesong
		call	saver20
		ld	hl,MSGVOLCANO
		call	statusflash
		ld	a,HOLDTIME/2+60
		ld	de,volcanoeject
		call	addtimed
		jp	.done2
.not2:		inc	[hl]
		ld	a,[hl]
		add	8-1
		call	b2showtv
		ld	a,11
		call	b2showtv
		ld	a,FX_BALLLOCKED
		call	InitSfx
		ld	a,7
		call	board2popups
		xor	a
		ldh	[pin_ballflags],a
		ld	a,1
		ld	[any_wantfire],a
;		ldh	a,[pin_difficulty]
	ld	a,1
		ld	[any_harder],a
;		ld	hl,MSGBALLLOCKED
;		call	statusflash
		ret
.notrap:
.done3:
		jp	b2set4

;		ld	de,E3X
;		ld	bc,E3Y
;		ld	h,E3VX*EJECTSPEED/8
;		ld	l,E3VY*EJECTSPEED/8
;		jr	.set

.take4:						;grotto/atlantica
		ld	a,[b2_scoop4]
		or	a
		jr	z,.noscoop4
		xor	a
		ld	[b2_scoop4],a
		call	checkicecave
		jr	.done4
.noscoop4:
		ld	a,[any_table]
		or	a
		jr	nz,.nosubs
		ld	a,[b2_tridentsub]
		or	a
		jr	z,.notridentsub
		xor	a
		ld	[b2_tridentsub],a
		ld	a,SUBGAME_TRIDENT
		call	ChainSub
		jr	.done4
.notridentsub:
		ld	a,[b2_dashsub]
		or	a
		jr	z,.nodashsub
		xor	a
		ld	[b2_dashsub],a
		ld	a,SUBGAME_DASH
		call	ChainSub
		jr	.done4
.nodashsub:

.nosubs:
		ld	a,[any_inmulti]
;		cp	TABLEGAME_HAPPY
;		jr	z,.trylock1
		cp	TABLEGAME_VOLCANO
		jr	z,.trylock1
		cp	TABLEGAME_MORGANA
		jr	nz,.nolock1
.trylock1:
		ld	a,[any_mlock1]
		or	a
		jr	nz,.nolock1
		call	CountBalls
		cp	2
		jr	c,.nolock1
		ld	a,1
		ld	[any_mlock1],a
		jp	b2lockedmulti
.nolock1:

		ld	a,[b2_awardready]
		or	a
		jr	z,.noaward
		xor	a
		ld	[b2_awardready],a
		call	board2giveaward
		jr	.done4
.noaward:

.done4:
		jp	b2set4

b2set1:		ld	de,E1X	;ice
		ld	bc,E1Y
		ld	h,E1VX*EJECTSPEED/8
		ld	l,E1VY*EJECTSPEED/8
		jp	b2set
b2out2:		call	b2outs
b2set2:		ld	de,E2X ;volcano
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		jr	b2set

b2outs:		ld	a,1<<BALLFLG_USED
		ldh	[pin_ballflags],a
		ld	a,HOLDTIME/2
		ldh	[pin_ballpause],a
		ret

b2set3:		ld	de,E3X ;castle
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8
		jr	b2set

b2out1:		call	b2outs
b2set4:		ld	de,E4X ;grotto
		ld	bc,E4Y
		ld	h,E4VX*EJECTSPEED/8
		ld	l,E4VY*EJECTSPEED/8
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

b2spit1:	ld	de,E4X		;grotto
		ld	bc,E4Y
		ld	h,E4VX*EJECTSPEED/8
		ld	l,E4VY*EJECTSPEED/8
		jr	b2spits
b2spit2:	ld	de,E2X		;volcano
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
b2spits:	call	AddBall
		ld	a,h
		or	l
		ret	z ;hack to fix japanese bug # 14
		ld	de,BALL_BALLPAUSE
		add	hl,de
		ld	[hl],HOLDTIME/2
		ret

b2lockedmulti:
		xor	a
		ldh	[pin_ballflags],a
		ldh	[pin_ballpause],a
		ret

b2advancetvback:
		dec	c
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
.aok2:		inc	a
		ld	b,a
		ld	a,[any_inmulti]
		cp	TABLEGAME_HAPPY
		jr	nz,.nothappy
		ld	a,[any_tvback]
		inc	a
		cp	c
		jr	nz,.ishappy
		push	af
		ld	de,score1000m
		call	addscore
		ld	hl,MSG1000M
		call	statusflash
		pop	af
		jr	.aok
.nothappy:	ld	a,[any_multibase]
		add	b
.ishappy:	ld	b,a
		ld	a,[any_tvback]
		cp	b
		jr	nc,.aok
		ld	a,b
		cp	c
		jr	c,.aok
		ld	a,c
.aok:		push	af
		ld	a,[any_1234]
		add	50
		call	b2showtv
		pop	af
		jp	b2keeptv

b2happyjackpot:
		ld	c,TV_HAPPY+10
		call	b2advancetvback
		ld	hl,b2_happyjack
		ld	e,[hl]
		ld	[hl],20
		jp	b2jackpot

b2morganajackpot:
		ld	c,TV_MORGANA+5
		call	b2advancetvback

		ld	a,[any_1234]
		cp	3
		jr	nz,.nosub
		ld	a,[b2_morganasub]
		or	a
		jr	nz,.nosub
		ld	hl,MSGMORGANALOCK
		call	statusflash
		ld	a,1
		ld	[b2_morganasub],a
;		ld	a,SUBGAME_MORGANA
;		call	unlocksub
		call	b2sublit
.nosub:		ld	hl,b2_morganajack
		ld	e,[hl]
		ld	[hl],20
		jr	b2jackpot

b2cloakjackpot:
		ld	c,TV_CLOAK+3
		call	b2advancetvback

		ld	a,[any_1234]
		cp	1
		jr	nz,.nosub
		ld	a,[b2_cloaksub]
		or	a
		jr	nz,.nosub
		ld	hl,MSGCLOAKLOCK
		call	statusflash
		ld	a,1
		ld	[b2_cloaksub],a
;		ld	a,SUBGAME_CLOAK
;		call	unlocksub
		call	b2sublit
.nosub:		ld	a,[b2_2balljack]
		ld	e,a
		ld	a,10
		ld	[b2_2balljack],a
		jr	b2jackpot

b2volcanojackpot:
		ld	c,TV_VOLCANO+4
		call	b2advancetvback

		ld	a,[any_1234]
		cp	2
		jr	nz,.nosub
		ld	a,[b2_volcanosub]
		or	a
		jr	nz,.nosub
		ld	hl,MSGVOLCANOLOCK
		call	statusflash
		ld	a,1
		ld	[b2_volcanosub],a
;		ld	a,SUBGAME_VOLCANO
;		call	unlocksub
		call	b2sublit
.nosub:		ld	a,[b2_volcanojack]
		ld	e,a
		ld	a,10
		ld	[b2_volcanojack],a

;e=value to add (in millions)
b2jackpot:	ld	a,1
		ld	[any_spitout],a
		ld	a,[any_1234]
		ld	b,a
		ld	c,FX_JACKPOT
;		ld	hl,MSGJACKPOT1X
		or	a
		jr	z,.hlok
;		ld	hl,MSGJACKPOT2X
		dec	a
		jr	z,.hlok
;		ld	hl,MSGJACKPOT3X
		dec	a
		jr	z,.hlok
;		ld	hl,MSGJACKPOT5X
		inc	b
		ld	c,FX_SUPERJACK
.hlok:		push	de
;		push	bc
;		call	statusflash
;		pop	bc
		ld	a,c
		push	bc
		call	InitSfx
		pop	bc
		pop	de
		inc	b
		ld	hl,0
		ld	d,h
.addlp:		add	hl,de
		dec	b
		jr	nz,.addlp
		call	addmillionshl
		ld	hl,MSGJACKVALUE
		call	statusflash
		ld	hl,any_1234
		inc	[hl]
		ld	a,[hl]
		cp	4
		jr	c,.mok
		xor	a
		ld	[hl],a
.mok:		ret


b2sublit:	ld	a,7
		jp	b2showtv


volcanoeject:	ld	de,E2X
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b2_trapped
		dec	[hl]
		ret	z
		ld	a,60
		ld	de,volcanoeject
		jp	addtimed










b2enterramp:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	98/2-20*2
		ld	d,a

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	329/2+20
		add	a
		add	d
		add	a
		ld	c,0
		jr	nc,.cok
		inc	c
.cok:
		ldh	a,[pin_ballflags]
		and	$fe
		or	c
		ldh	[pin_ballflags],a
		jp	b2setramp


b2exitramp:	ld	h,0
		ld	l,32
		call	passedby
		or	a
		ret	z
		ldh	a,[pin_ballflags]
		ld	b,a
		and	$fe
		ldh	[pin_ballflags],a
		cp	b
		ret	z
		call	b2ramp
		ld	de,rampscore
		call	addscoreh
		xor	a
		call	b2setramp
		ld	c,CODE_RAMP
		ld	hl,b2_ramp
		call	b2didloopramp
		ld	a,[any_1234]
		cp	3
		jr	z,.normalramp
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalramp
		cp	TABLEGAME_VOLCANO
		jp	z,b2volcanojackpot
		cp	TABLEGAME_CLOAK
		jp	z,b2cloakjackpot
		cp	TABLEGAME_MORGANA
		jp	z,b2morganajackpot
		cp	TABLEGAME_HAPPY
		jp	z,b2happyjackpot
.normalramp:	ret

B2RAMPTIME	EQU	90

b2rampxlist:	dw	MSGRAMP1X
		dw	MSGRAMP2X
		dw	MSGRAMP4X

b2ramp:		ld	hl,any_rampfast
		ld	a,[hl]
		ld	e,a
		inc	a
		cp	3
		jr	nz,.tooslow
		dec	a
.tooslow:	ld	[hl],a
		ld	d,0
		ld	hl,b2rampxlist
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	de
		call	statusflash
		pop	de
		push	de
		ld	a,e
		or	a
		ld	a,FX_RAMP1
		jr	z,.aok
		ld	a,FX_RAMP2
		dec	e
		jr	z,.aok
		ld	a,FX_RAMP4
.aok:		call	InitSfx

		pop	de

		ld	a,e
		ld	b,1
		or	a
		jr	z,.bok
		inc	b
		dec	a
		jr	z,.bok
		inc	b
		inc	b
.bok:		ld	a,[b2_rampcount]
		ld	c,a
.rampcredits:	inc	c
		ld	e,c
		ld	d,HIGH(RampAwards)
		ld	a,[de]
		or	a
		jr	z,.next
		dec	a
		jr	nz,.nobonus
		push	bc
		call	b2advancebonus
		pop	bc
		jr	.next
.nobonus:	dec	a
		jr	nz,.nohold
		push	bc
		call	b2showmultheld
		pop	bc
		jr	.next
.nohold:	push	bc
		call	b2doextraopen
		pop	bc
		jr	.next
.something:	push	bc
		call	statusflash
		pop	bc
.next:		dec	b
		jr	nz,.rampcredits
		ld	a,c
		ld	[b2_rampcount],a
		ret



B2RAMPLOC	EQU	$d000+18*24*2+3*2
b2setramp:	srl	a
		jr	c,b2rampdown
b2rampup:	ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	z
		res	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,B2RAMPLOC
		ld	de,24*2-2
		ld	c,13
.lp:		set	3,[hl]
		inc	l
		inc	l
		set	3,[hl]
		add	hl,de
		dec	c
		jr	nz,.lp
		jr	b2rampmarks
b2rampdown:	ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	nz
		set	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,B2RAMPLOC
		ld	de,24*2-2
		ld	c,13
.lp:		res	3,[hl]
		inc	l
		inc	l
		res	3,[hl]
		add	hl,de
		dec	c
		jr	nz,.lp
b2rampmarks:	ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,18
.lp:		push	af
		call	MarkDirty
		pop	af
		inc	a
		cp	18+13
		jr	c,.lp
		ret


b2lostball:
		ld	a,[any_ballsaver]
		or	a
		jr	z,.nosaver
		ld	a,FX_BALLSAVED
		call	InitSfx
		call	b2autofire
		ld	a,1
		jp	b2showtv
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
		jp	b2out1
.nolock1:

		ld	a,[any_mlock2]
		or	a
		jr	z,.nolock2
		xor	a
		ld	[any_mlock2],a
		jp	b2out2
.nolock2:

 ld	a,[wDemoMode]
 or	a
 jp	nz,AnyQuit

		xor	a
		ld	[any_pearlball],a

		ld	a,FX_LOSTBALL
		call	InitSfx

		call	b2endtable
		ld	a,[any_table]
		cp	TABLEGAME_MORGANA
		ret	z

		ld	a,1
		ld	[any_bonusinfo1],a

		ld	a,[b2_bonus]
		ld	[any_bonusmul],a
		ret

b2finishloseball:

		xor	a
		ld	[any_combo1],a
		ld	[any_combo2],a
		ld	[any_combo3],a
		ld	[any_loopcount],a
		ld	[any_comboclear],a
		ld	[any_rampfast],a

		ld	a,[b2_holdmult]
		or	a
		jr	nz,.noresetmult
		ld	a,1
		ld	[b2_bonus],a
		call	board2bonus
.noresetmult:	xor	a
		ld	[b2_holdmult],a

		ld	hl,any_bonusval
		ld	bc,5
		call	MemClear

		ld	a,[b2_holdpops]
		or	a
		jr	nz,.noresetpops
		xor	a
		ld	[b2_popcount],a
.noresetpops:	xor	a
		ld	[b2_holdpops],a

		ld	a,[any_ballsleft]
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

		ld	a,1
		ld	[any_wantswitch],a

		ret

b2multiend:	call	CountBalls
		dec	a
		ld	c,a
		ld	a,[any_inmulti]
		cp	TABLEGAME_MORGANA
		jr	z,.morganaend
		cp	TABLEGAME_CLOAK
		jr	z,.cloakend
		cp	TABLEGAME_VOLCANO
		jr	z,.volcanoend
.happyend:	ld	a,[any_happyfire]
		jr	.volcmorg
.volcanoend:	ld	a,[b2_trapped]
.volcmorg:	or	a
		ret	nz
		ld	a,[any_mlock1]
		add	c
		ld	c,a
		ld	a,[any_mlock2]
		add	c
		cp	2
		ret	nc
		xor	a
		ld	[wHappyMode],a
		jp	b2endtable
.morganaend:	ld	a,[b2_morganafire]
		jr	.volcmorg
.cloakend:	jp	b2endtable


b2autofire:	ld	a,1
		ld	[any_tofire],a
		ret

b2keeptv:	ld	c,a
		ld	a,[any_tvhold]
		or	a
		jr	z,.doit
		ld	a,c
		ld	[any_tvback],a
		ret
.doit:		ld	a,[any_tvback]
		cp	c
		ret	z
		ld	a,c
b2forcekeeptv:	ld	[any_tvback],a
		call	TVSet
		xor	a
		jr	b2anytv

b2showtv:	ld	c,a
		ld	a,[any_tvsp]
		cp	4
		ret	z
		ld	e,a
		ld	d,0
		inc	a
		ld	[any_tvsp],a
		ld	hl,any_tvshow
		add	hl,de
		ld	[hl],c
		ld	a,[any_tvhold]
		or	a
		jr	z,b2tvpop
		ld	a,1
		ld	a,[any_tvhold],a
		ret
b2tvpop:	ld	a,[any_tvsp]
		or	a
		ret	z
		dec	a
		ld	[any_tvsp],a
		ld	de,any_tvshow
		ld	hl,any_tvshow+1
		ld	a,[de]
		ld	c,a
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hl]
		ld	[de],a
		ld	a,c
		call	TVSet
		ld	a,[any_tvsp]
		or	a
		ld	a,5
		jr	z,.a5
		ld	a,1
.a5:

b2anytv:	ld	[any_tvhold],a
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


		ld	a,[any_harder]
		or	a
		jr	nz,.harder
		ld	a,1
		call	board2kickback
		xor	a
		ld	[b2_backtimer],a
		ld	a,1
		call	board2leftkickback
		xor	a
		ld	[b2_leftbacktimer],a
.harder:
 ld a,[wDemoMode]
 or a
 jp nz,b2fire

		ld	a,1
		ld	[any_firing],a
		ld	[b2_trident],a

		ld	de,170<<5
		ld	bc,280<<5
		ld	hl,0
		call	AddBall
		ld	a,h
		or	l
		ret	z	;just for safety
		set	BALLFLG_LAYER,[hl]
		ret

b2shoot:	ld	a,[any_firing]
		or	a
		ret	nz
		ldh	a,[pin_vy+1]
		add	a
		ret	c
		ld	a,AUTOFIRERATE&255
		ldh	[pin_vy],a
		ld	a,$ff
		ldh	[pin_vy+1],a
		ld	hl,pin_ballflags
		set	BALLFLG_LAYER,[hl]
		ret

b2firing:	ld	hl,any_firing
		ld	a,[hl]
		or	a
		ret	z
		cp	1
		jr	nz,.pulling
		xor	a
		ld	[wBalls+BALL_THETA],a
		ld	a,[wJoy1Hit]
		bit	JOY_SELECT,a
		ret	z
		inc	[hl]
		ld	a,2
		ld	[b2_trident],a
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
		ld	[hl],0
		cpl
		inc	a
		ld	[wBalls+BALL_VY],a
		ld	a,$ff
		ld	[wBalls+BALL_VY+1],a
		xor	a
		call	board2gate
		ld	a,100
		ld	de,b2close
		call	addtimed
;		ld	a,[any_harder]
;		or	a
;		call	z,saver20
		call	saver20
		xor	a
		ld	[any_harder],a
		ld	a,9
		ld	[b2_trident],a
		call	RumbleHigh
		ld	a,FX_BALLFIRE
		jp	InitSfx

b2fire:		xor	a
		call	board2gate
		ld	a,50
		ld	de,b2close
		call	addtimed
		call	RumbleHigh
		ld	a,FX_BALLFIRE
		call	InitSfx
		ld	de,170<<5
		ld	bc,280<<5
		ld	hl,AUTOFIRERATE
		call	AddBall
		ld	a,h
		or	l
		ret	z	;just for safety
		set	BALLFLG_LAYER,[hl]
		ret


board2process:
		ld	a,[wStartHappy]
		or	a
		call	nz,b2starthappy
		ld	a,[any_wantswitch]
		or	a
		call	nz,b2tryswitch
		ld	a,[any_spitout]
		or	a
		jr	z,.nospitout
		xor	a
		ld	[any_spitout],a
		ld	a,[any_mlock1]
		or	a
		jr	z,.nospit1
		xor	a
		ld	[any_mlock1],a
		call	b2spit1
.nospit1:
		ld	a,[any_mlock2]
		or	a
		jr	z,.nospit2
		xor	a
		ld	[any_mlock2],a
		call	b2spit2
.nospit2:
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
		ld	[any_combo3],a
		ld	[any_loopcount],a
.nodechist:

		call	BonusProcess
		call	nz,b2finishloseball

		ld	a,[wJoy1Hit]
		bit	JOY_L,a
		call	nz,award2left
		ld	a,[wJoy1Hit]
		bit	JOY_A,a
		call	nz,award2right


		ld	a,[b2_topdelay]
		or	a
		jr	z,.nodectopdelay
		dec	a
		ld	[b2_topdelay],a
.nodectopdelay:
		ld	a,[b2_awarddelay]
		or	a
		jr	z,.nodecawarddelay
		dec	a
		ld	[b2_awarddelay],a
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
.nodecsaver:	ld	hl,b2_megapops
		ld	a,[hl]
		or	a
		jr	z,.nodecmegapops
		dec	a
		ld	[hl],a
		and	$7f
		jr	nz,.nodecmegapops
		ld	[hl],a
.nodecmegapops:
		ld	hl,any_tabletime
		ld	a,[hl]
		or	a
		jr	z,.nodectabletime
		dec	[hl]
		ldh	a,[pin_flags]
		set	PINFLG_SCORE,a
		ldh	[pin_flags],a
.nodectabletime:

.notyet:

		call	b2tableprocess

		ret


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
		jr	c,.bottoms
		ld	a,e
		cp	480>>1
		jr	nc,.bottoms
		cp	241>>1
		jp	nc,.middles
.pops:		cp	150>>1
		jr	nc,.pop23
		ld	a,d
		cp	151>>1
		jr	c,.pop23
;top pop (#1)
.pop1:		ld	b,B2_TOPPOP
		ld	de,b2toppop
		jr	.toppops
.pop23:		ld	a,d
		sub	144>>1
		add	e
		sub	163>>1
		add	a
		jr	nc,.pop3
.pop2:		ld	b,B2_MIDDLEPOP
		ld	de,b2middlepop
		jr	.toppops
.pop3:		ld	b,B2_BOTTOMPOP
		ld	de,b2bottompop
		jr	.toppops
.bottoms:	ldh	a,[pin_x]
		sub	(84<<5)&255
		ldh	a,[pin_x+1]
		sbc	(84<<5)>>8
		jr	c,.bottomleft
.bottomright:	ld	b,B2_RIGHTBUMPER
		ld	de,b2rightbumper
		jr	.bumps
.bottomleft:	ld	b,B2_LEFTBUMPER
		ld	de,b2leftbumper
.bumps:
.toppops:	ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
;HIT A POP BUMPER
		push	de
		ld	e,b
		ld	d,1
		call	b2newstate
		pop	de
		ld	a,15
		call	addtimed
.anypop:
		call	RumbleMedium
		call	IncBonusVal

		ld	hl,b2_popcount
		ld	e,99
		call	incmax1

	ld	hl,b2_morganajack
	ld	e,200
	call	incmax1
	ld	hl,b2_happyjack
	ld	e,200
	call	incmax1

		ld	a,[any_table]
		cp	TABLEGAME_DASH
		jp	z,dashcredit
		ld	b,FX_SUPERPOP
		ld	de,megapopperscore
		ld	a,[b2_megapops]
		or	a
		jr	nz,.gotpopscore
		ld	de,popper99score
		ld	a,[b2_popcount]
		cp	99
		jr	nc,.gotpopscore
		ld	b,FX_BUMPER
		ld	de,popperscore
.gotpopscore:	push	bc
		call	addscore
		pop	af
		call	InitSfx
		jp	b2switchmode

.middles:	cp	388>>1
		jr	c,.upper4
		ld	a,d
		cp	180>>1
		jp	c,.mel
		ld	a,e
		add	a
		add	d
		sub	$35
		bit	7,a
		jr	nz,.lettert
		cp	$1d
		jr	c,.letteri
		jr	.letterp
.lettert:	ld	b,255-4
		jr	.tip
.letteri:	ld	b,255-2
		jr	.tip
.letterp:	ld	b,255-1
.tip:		ld	a,[b2_popupstate]
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
		call	b2showlockopen
		xor	a
.notall:	call	board2popups
		ld	a,FX_DROP
		call	InitSfx
		call	RumbleLow
		ld	de,dropscore
		call	addscore
		jp	.b2soft

.upper4:	ld	a,d
		cp	119>>1
		jr	c,.lettero
		cp	182>>1
		jr	c,.letterd
		cp	239>>1
		jr	c,.lettery
.sea:		ld	a,[b2_seastate]
		scf
		adc	a,a
		cp	7
		jr	nz,.aok
		ld	de,scorestandupunlit
		call	addscore
		ld	a,FX_SEALIT
		call	InitSfx
		call	RumbleLow
		xor	a
		ld	[b2_seatimer],a
		ld	[b2_seastate],a
		ld	a,1
		ld	de,b2seaflash
		call	addtimed

		ld	a,[b2_leftkickback]
		or	a
		jr	z,.newkickback
		ld	a,[b2_kickback]
		or	a
		jr	z,.newkickback
		ld	a,[b2_leftbacktimer]
		or	a
		jr	nz,.newkickback
		ld	a,[b2_backtimer]
		or	a
		jr	nz,.newkickback
.haskickback:	call	dorelit
		jr	.seaflash
.newkickback:
		xor	a
		ld	[b2_backtimer],a
		ld	[b2_leftbacktimer],a
		call	b2dokickbackopen
		jr	.seaflash
.aok:		call	board2sea
.seaflash:	jr	.b2soft
.mel:		ld	a,e
		add	a
		sub	d
		sub	$9b
		bit	7,a
		jr	nz,.letterl
		cp	16
		jr	c,.lettere
.letterm:	ld	b,32
		jr	.melody
.lettere:	ld	b,16
		jr	.melody
.letterl:	ld	b,8
		jr	.melody
.lettero:	ld	b,4
		jr	.melody
.letterd:	ld	b,2
		jr	.melody
.lettery:	ld	b,1
.melody:	ld	a,[b2_melody]
		ld	c,a
		or	b
		cp	$3f
		jr	nz,.nofinish
		call	b2forcemelody
		jr	.finished
.nofinish:	cp	c
		jr	z,.finished
		call	board2melody
		ld	a,[any_table]
		or	a
		ld	a,19
		call	z,b2showtv
		ld	de,scorestandupunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
		call	RumbleLow
.finished:	jr	.b2soft

.b2soft:	ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

b2unchain:	call	saver20
		call	b2autofire
		jp	b2endtable


board2sprites:
		call	board2flippers
		call	board2trident
		call	board2spinner

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
		add	255&(IDX_FLIPPERS2+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS2+18)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(FLIPPERX2B2-FLIPPERX1B2)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS2+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS2+18)>>8
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
		jr	nz,.noflipper3
		ld	a,e
		cp	176
		jr	nc,.noflipper3
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
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS2)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS2)>>8
		ld	b,a
		ld	a,GROUP_REDFLIP+$80 ;GROUP_FLIPPERS+$80
		call	AddFigure
.noflipper3:
		ret



board2first::
		xor	a
		ld	[wHappyMode],a
		ld	[wStartHappy],a
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]

		ld	a,3
		ld	[any_nextextra],a	;loop count for next extra ball

		ld	a,10
		ld	[b2_2balljack],a
		ld	[b2_volcanojack],a
		ld	a,20
		ld	[b2_morganajack],a
		ld	[b2_happyjack],a

		ld	a,5
		ld	[any_clock+3],a

		ld	hl,wScore
		ld	bc,16
		call	MemClear

		call	InitBalls

		ld	a,0
		ld	[any_wantfire],a
		ld	a,[wNumBalls]
		ld	[any_ballsleft],a
		ld	a,1
		ld	[b2_bonus],a

		ld	a,0
; ld	a,$ff-2 ;DEBUG
		ld	[b2_completed],a

		call	random
		and	7
		inc	a
		ld	[b2_litgame],a
		call	b2switchmode

		ld	a,7
		ld	[b2_popupstate],a

		ld	a,0
; ld a,$3f ;DEBUG
		ld	[b2_melody],a

; ld a,2
; ld [b2_trapped],a ;DEBUG
; ld [b2_locked],a

; ld a,1
; ld [b2_cloaksub],a ;DEBUG

		call	PlayerReport

		ret



board2init::
		ld	hl,board2info
		call	SetPinInfo

		ld	hl,PAL_FLIPPERS2
		call	AddPalette
		ld	hl,PAL_SPINNER2
		call	AddPalette
		ld	hl,PAL_SPINNER2B
		call	AddPalette
		ld	hl,PAL_TRIDENT
		call	AddPalette
		ld	hl,PAL_REDFLIP
		call	AddPalette

		ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_TWO000PMP
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

		ld	hl,IDX_TWO018CHG	;close off entrance
		call	MakeChanges

		ld	hl,board2maplist
		call	NewLoadMap
		ld	hl,IDX_LIGHTS2MAP
		call	SecondHalf
		ld	hl,IDX_TV5MAP
		ld	a,[bLanguage]
		ld	e,a
		ld	d,0
		add	hl,de
		call	OtherPage

		call	b2restore
 xor	a
 call	b2showtv	;DEBUG

		ld	hl,board2chances
		ldh	a,[pin_difficulty]
		or	a
		jr	nz,.hlok
		ld	hl,board2chanceseasy
.hlok:
		ld	de,any_chances
		call	b2chanceinit

		ld	hl,board2collisions
		jp	MakeCollisions

b2restore:

		ld	hl,wStates
		ld	bc,64
		call	MemClear

b2restoreq:
		call	b2rampdown
		call	b2rampup

		ld	a,[b2_bonus]
		call	board2bonus
		ld	a,[b2_popupstate]
		call	board2popups
		ld	a,[b2_seastate]
		call	board2sea
		ld	a,[b2_kickback]
		call	board2kickback
		ld	a,[b2_kickback]
		ld	d,a
		ld	e,B2_KICKLIGHT
		call	b2newstate

		ld	a,[b2_leftkickback]
		call	board2leftkickback
		ld	a,[b2_leftkickback]
		ld	d,a
		ld	e,B2_LEFTKICKLIGHT
		call	b2newstate

		ld	a,[b2_award]
		call	board2awardshow
		ld	a,[b2_toplanes]
		call	board2toplanes
		ld	a,[b2_melody]
		call	board2melodyforce
		ld	a,[b2_gate]
		call	board2gate
		ret


board2trident:
		ld	a,[b2_trident]
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
		ld	de,TRIDENTY>>5
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
		ld	a,TRIDENTX>>5
		sub	h
		ld	d,a
		ld	a,[b2_trident]
		dec	a
		cp	15
		jr	c,.aok
		xor	a
.aok:		add	IDX_TRIDENT&255
		ld	c,a
		ld	a,0
		adc	IDX_TRIDENT>>8
		ld	b,a
		ld	a,GROUP_TRIDENT
		call	AddFigure
.novisible:	ld	hl,b2_trident
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



b2advancebonus:
		ld	a,[b2_bonus]
		cp	25
		jp	z,dorelit
		ld	a,17
		call	b2showtv
;		ld	hl,MSGBONUSP1
;		call	statusflash
		ld	a,[b2_bonus]
		inc	a
board2bonus:	cp	25
		jr	z,.to25
		jr	c,.less25
		ret
.to25:		ld	a,[b2_bonus]
		cp	25
		jr	z,.less25
		ld	a,[any_to25]
		or	a
		jr	nz,.noextra
		inc	a
		ld	[any_to25],a
		call	b2doextraopen
.noextra:	ld	a,25
.less25:
		ld	[b2_bonus],a
		or	a
		jr	z,.bonus0
		push	af
		ld	de,$0100+B2_BONUSTOP
		call	b2newstate
		pop	af
		ld	d,0
.mod10:		inc	d
		sub	10
		jr	nc,.mod10
		add	10
		push	de
		inc	a
		ld	d,a
		ld	e,B2_BONUS1S
		call	b2newstate
		pop	de
		ld	e,B2_BONUS10S
		jp	b2newstate
.bonus0:	ld	de,$0000+B2_BONUSTOP
		call	b2newstate
		ld	de,$0000+B2_BONUS1S
		call	b2newstate
		ld	de,$0000+B2_BONUS10S
		jp	b2newstate



;e=state #
;d=new value
b2newstate:	ld	a,d
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

B2_ENTRANCE	EQU	0
B2_LEFTLANE	EQU	1
B2_RIGHTLANE	EQU	2
B2_ALIGHT	EQU	3
B2_BLIGHT	EQU	4
B2_CLIGHT	EQU	5
B2_MELODY1	EQU	6
B2_MELODY2	EQU	7
B2_MELODY3	EQU	8
B2_MELODY4	EQU	9
B2_MELODY5	EQU	10
B2_MELODY6	EQU	11
B2_SEA1		EQU	12
B2_SEA2		EQU	13
B2_SEA3		EQU	14
B2_TOPPOP	EQU	15
B2_MIDDLEPOP	EQU	16
B2_BOTTOMPOP	EQU	17
B2_KICKBACK	EQU	18
B2_ICEGATE	EQU	19
B2_WALLGATE	EQU	20
B2_VOLCANO	EQU	21
B2_RIGHTINNER	EQU	22
B2_RIGHT	EQU	23
B2_RAMP		EQU	24
B2_GROTTO	EQU	25
B2_RIGHTBUMPER	EQU	26
B2_EBSAVER	EQU	27
B2_LEFTBUMPER	EQU	28
B2_JACKPOT	EQU	29
B2_KICKLIGHT	EQU	30
B2_AWARD1	EQU	31
B2_AWARD2	EQU	32
B2_AWARD3	EQU	33
B2_AWARD4	EQU	34
B2_AWARD5	EQU	35
B2_MODES	EQU	36
B2_T		EQU	45
B2_I		EQU	46
B2_P		EQU	47
B2_BONUSTOP	EQU	48
B2_BONUS1S	EQU	49
B2_BONUS10S	EQU	50
B2_LEFTINNER	EQU	51
B2_ULIGHT	EQU	52
B2_EXTRALOCK	EQU	53
B2_LEFT		EQU	54
B2_SEBASTIAN	EQU	55
B2_LEFTKICK	EQU	56
B2_LEFTKICKLIGHT EQU	57

b2statestarts:	db	0	; 0,seaweed gate
		db	2	; 1,left x
		db	4	; 2,right x
		db	6	; 3,T
		db	8	; 4,I
		db	10	; 5,P
		db	12	; 6,M
		db	14	; 7,E
		db	16	; 8,L
		db	18	; 9,O
		db	20	;10,D
		db	22	;11,Y
		db	24	;12,S
		db	26	;13,E
		db	28	;14,A
		db	30	;15,top Clam
		db	32	;16,middle Clam
		db	34	;17,bottom Clam
		db	36	;18,Kickback gate
		db	38	;19,Ice gate
		db	40	;20,Wall gate
		db	42	;21,Volcano scoop
		db	44	;22,Inner loop right
		db	46	;23,Right loop
		db	48	;24,Ramp
		db	50	;25,Atlantica
		db	52	;26,right bumper
		db	54	;27,Ball saver
		db	56	;28,Left Bumper
		db	58	;29,Jackpot
		db	60	;30,Kickback light
		db	62	;31,A
		db	64	;32,W
		db	66	;33,A
		db	68	;34,R
		db	70	;35,D
		db	72	;36,Mode 1
		db	74	;37,Mode 2
		db	76	;38,Mode 3
		db	78	;39,Mode 4
		db	80	;40,Mode 5
		db	82	;41,Mode 6
		db	84	;42,Mode 7
		db	86	;43,Mode 8
		db	88	;44,Mode 9
		db	90	;45,T Target
		db	92	;46,I Target
		db	94	;47,P Target
		db	96	;48,Bonus top
		db	98	;49,Bonus 1's
		db	109	;50,Bonus 10's
		db	113	;51,Inner loop left
		db	116	;52,U bend
		db	119	;53,eb/lock light
		db	122	;54,left loop
		db	125	;55,Sebastian
		db	127	;56,Left kick gate
		db	129	;57,Left kick light

;xsize,ysize,xsrc,ysrc,xdest,ydest
b2statelist:
		db	10,12,10,0,12,0		; 0  Seaweed gate open,
		db	10,12,0,0,12,0		; 1  Seaweed gate closed,
		db	1,1,21,0,9,2		; 2  X light left off,
		db	1,1,20,0,9,2		; 3  X light left on,
		db	1,1,21,0,11,2		; 4  X light right off,
		db	1,1,20,0,11,2		; 5  X light right on,
		db	2,1,20,1,15,26		; 6  T off,
		db	2,1,22,0,15,26		; 7  T on,
		db	2,2,20,2,16,27		; 9  I off,
		db	2,2,22,1,16,27		; 8  I on,
		db	1,1,23,3,17,29		;10  P off,
		db	1,1,22,3,17,29		;11  P on,
		db	1,1,21,4,2,28		;12  M off,
		db	1,1,20,4,2,28		;13  M on,
		db	1,1,23,4,2,27		;14  E off,
		db	1,1,22,4,2,27		;15  E on,
		db	1,1,21,5,2,26		;16  L off,
		db	1,1,20,5,2,26		;17  L on,
		db	2,2,22,6,5,22		;18  O off,
		db	2,2,20,6,5,22		;19  O on,
		db	2,1,22,8,8,18		;20  D off,
		db	2,1,20,8,8,18		;21  D on,
		db	1,2,21,9,13,18		;22  Y off,
		db	1,2,20,9,13,18		;23  Y on,
		db	2,1,22,11,15,20		;24  S off,
		db	2,1,20,11,15,20		;25  S on,
		db	1,1,21,12,15,22		;26  E off,
		db	1,1,20,12,15,22		;27  E on,
		db	2,1,20,13,14,24		;28  A off,
		db	2,1,22,12,14,24		;29  A on,
		db	4,3,10,12,9,6		;30  top clam off,
		db	4,3,6,12,9,6		;31  top clam on,
		db	3,3,3,12,6,7		;32  middle clam off,
		db	3,3,0,12,6,7		;33  middle clam on,
		db	3,3,3,15,9,10		;34  bottom clam off,
		db	3,3,0,15,9,10		;35  bottom clam on,
		db	2,3,20,14,19,35		;36  Kickback gate closed,
		db	2,3,22,14,19,35		;37  Kickback gate open,
		db	3,5,9,15,1,5		;38  Ice gate closed,
		db	3,5,6,15,1,5		;39  Ice gate open,
		db	3,5,17,12,12,11		;40  Wall gate closed,
		db	3,5,14,12,12,11		;41  Wall gate open,
		db	2,2,2,20,5,10		;42  Volcano scoop off,
		db	2,2,0,20,5,10		;43  Volcano scoop on,
		db	2,3,10,22,12,22		;44  Inner loop right off,
		db	2,3,12,22,12,22		;45  Inner loop right on,
		db	2,3,10,33,13,27		;46  Right loop off,
		db	2,3,12,33,13,27		;47  Right loop on,
		db	2,2,4,20,7,22		;48  Ramp off,
		db	2,2,6,20,7,22		;49  Ramp on,
		db	1,2,3,22,5,25		;50  Atlantica off,
		db	1,2,2,22,5,25		;51  Atlantica on,
		db	4,6,8,36,12,30		;52  right bumper off
		db	4,6,12,36,12,30		;53  right bumper on
		db	2,3,22,32,9,36		;54  Saver off
		db	2,3,22,35,9,36		;55  Saver on
		db	4,6,0,36,4,30		;56  left bumper off
		db	4,6,4,36,4,30		;57  left bumper on
		db	2,2,20,17,7,24		;58  Jackpot off,
		db	2,2,22,17,7,24		;59  Jackpot on,
		db	2,2,16,17,19,33		;60  Kickback off,
		db	2,2,18,17,19,33		;61  Kickback on,
		db	2,1,10,31,1,31		;62  A off,
		db	2,1,8,31,1,31		;63  A on,
		db	2,1,14,31,3,31		;64  W off,
		db	2,1,12,31,3,31		;65  W on,
		db	2,1,18,31,15,31		;66  A off,
		db	2,1,16,31,15,31		;67  A on,
		db	2,1,22,31,17,31		;68  R off,
		db	2,1,20,31,17,31		;69  R on,
		db	2,1,10,32,19,31		;70  D off,
		db	2,1,8,32,19,31		;71  D on,
		db	2,2,2,25,7,27		;72  Mode 1 off,
		db	2,2,0,25,7,27		;73  Mode 1 on,
		db	2,2,6,25,9,27		;74  Mode 2 off,
		db	2,2,4,25,9,27		;75  Mode 2 on,
		db	2,2,10,25,11,27		;76  Mode 3 off,
		db	2,2,8,25,11,27		;77  Mode 3 on,
		db	2,2,22,25,11,29		;78  Mode 6 off,
		db	2,2,20,25,11,29		;79  Mode 6 on,
		db	2,2,10,27,11,31		;80  Mode 9 off,
		db	2,2,8,27,11,31		;81  Mode 9 on ,
		db	2,2,6,27,9,31		;82  Mode 8 off,
		db	2,2,4,27,9,31		;83  Mode 8 on,
		db	2,2,2,27,7,31		;84  Mode 7 off,
		db	2,2,0,27,7,31		;85  Mode 7 on,
		db	2,2,14,25,7,29		;86  Mode 4 off,
		db	2,2,12,25,7,29		;87  Mode 4 on,
		db	2,2,18,25,9,29		;88  Mode 5 off,
		db	2,2,16,25,9,29		;89  Mode 5 on,
		db	2,2,2,34,17,24		;90  T target down,
		db	2,2,0,34,17,24		;91  T target up,
		db	1,2,5,34,18,26		;92  I target down,
		db	1,2,4,34,18,26		;93  I target up,
		db	2,2,8,34,18,28		;94  P target down,
		db	2,2,6,34,18,28		;95  P target up,
		db	4,1,4,31,8,33		;96  Bonus off,
		db	4,1,0,31,8,33		;97  Bonus on,
		db	2,2,6,32,10,34		;98  Bonus off 0 digit
		db	2,2,0,29,10,34		;99  0 on,
		db	2,2,2,29,10,34		;100  1 on,
		db	2,2,4,29,10,34		;101  2 on,
		db	2,2,6,29,10,34		;102  3 on,
		db	2,2,8,29,10,34		;103  4 on,
		db	2,2,10,29,10,34		;104  5 on,
		db	2,2,12,29,10,34		;105  6 on,
		db	2,2,14,29,10,34		;106  7 on,
		db	2,2,16,29,10,34		;107  8 on,
		db	2,2,18,29,10,34		;108  9 on,
		db	2,2,4,32,8,34		;109  Tens off
		db	2,2,0,32,8,34		;110  00 digit
		db	2,2,20,29,8,34		;111  10 digit
		db	2,2,22,29,8,34		;112  20 digit
		db	2,3,4,22,8,20		;113  Inner loop off (left),
		db	2,3,6,22,8,20		;114  Inner loop on 2 (left),
		db	2,3,8,22,8,20		;115  Inner loop on 1 (Super Jackpot),
		db	2,2,8,20,10,22		;116  U-bend off,
		db	2,2,12,20,10,22		;117  U-bend on 1 (Castle scoop),
		db	2,2,10,20,10,22		;118  U-bend on 2,
		db	2,2,13,27,10,24		;119  EB/Lock off
		db	2,2,16,27,10,24		;120  EB/Lock (EB)
		db	2,2,19,27,10,24		;121  EB/Lock (lock)
		db	2,2,0,18,5,27		;122  Left loop off,
		db	2,2,2,18,5,27		;123  Left loop 1, (white)
		db	2,2,4,18,5,27		;124  Left Loop 2 (yellow)
		db	6,5,16,37,16,15		;125  Sebastian 0
		db	6,5,16,32,16,15		;126  Sebastian 1
		db	4,5,20,20,1,35		;127  Left kick closed
		db	4,5,16,20,1,35		;128  Left kick open
		db	2,2,12,17,1,33		;129  Left kick light off
		db	2,2,14,17,1,33		;130  Left kick light on


b2award1lane:	ld	b,16
		jr	b2lanes
b2award2lane:	ld	b,8
		jr	b2lanes
b2award3lane:	ld	b,4
		jr	b2lanes
b2award4lane:	ld	b,2
		jr	b2lanes
b2award5lane:	ld	b,1
b2lanes:
		ld	a,[b2_awarddelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b2_awarddelay],a
		ld	a,[b2_award]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	$1f
		jr	nz,.notall
		ld	a,FX_AWARDLIT
		call	InitSfx
		xor	a
		ld	[b2_award],a
		ld	[b2_awardtimer],a
		ld	a,1
		ld	de,b2awardflash
		call	addtimed
		ld	a,[b2_awardready]
		or	a
		jr	z,.newaward
		call	dorelit
		jr	.delayed
.newaward:	ld	a,1
		ld	[b2_awardready],a
;		ld	hl,MSGAWARD
;		call	statusflash
		ld	a,22
		call	b2showtv
		jr	.delayed
.notall:	call	board2award
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
.delayed:	ret
b2topleft:	ld	b,2
		jr	b2toplanes
b2topright:	ld	b,1
b2toplanes:
		ld	a,[b2_topdelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b2_topdelay],a
		ld	a,[b2_toplanes]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	3
		jr	nz,.noincbonus
		xor	a
		ld	[b2_toplanes],a
		ld	[b2_toptimer],a
		ld	de,b2topflash
		ld	a,1
		call	addtimed
		ld	a,FX_MULTP1
		call	InitSfx
		jp	b2advancebonus
.noincbonus:	call	board2toplanes
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
.nochange:

.delayed:	ret

board2melody:	ld	b,a
		ld	a,[b2_melody]
		cp	b
		ret	z
		ld	a,b
board2melodyforce:
		ld	[b2_melody],a
board2melodyshow:
		ld	e,B2_MELODY6
		call	b2statebit
		ld	e,B2_MELODY5
		call	b2statebit
		ld	e,B2_MELODY4
		call	b2statebit
		ld	e,B2_MELODY3
		call	b2statebit
		ld	e,B2_MELODY2
		call	b2statebit
		ld	e,B2_MELODY1
		jr	b2statebit

board2award:	ld	b,a
		ld	a,[b2_award]
		cp	b
		ret	z
		ld	a,b
		ld	[b2_award],a
board2awardshow:
		ld	e,B2_AWARD5
		call	b2statebit
		ld	e,B2_AWARD4
		call	b2statebit
		ld	e,B2_AWARD3
		call	b2statebit
		ld	e,B2_AWARD2
		call	b2statebit
		ld	e,B2_AWARD1
b2statebit:	rrca
		push	af
		ld	d,0
		jr	nc,.dok
		inc	d
.dok:		call	b2newstate
		pop	af
		ret

board2toplanes:	ld	[b2_toplanes],a
board2topshow:	rrca
		push	af
		ld	a,0
		adc	a
		ld	d,a
		ld	e,B2_RIGHTLANE
		call	b2newstate
		pop	af
		rrca
		ld	a,0
		adc	a
		ld	d,a
		ld	e,B2_LEFTLANE
		jp	b2newstate

b2topflash:	ld	a,[b2_toptimer]
		ld	c,a
		inc	a
		ld	[b2_toptimer],a
		cp	11
		jr	nc,.incbonus
		rrca
		ld	a,0
		jr	c,.aok
		ld	a,3
.aok:		call	board2topshow
		ld	a,10
		ld	de,b2topflash
		jp	addtimed
.incbonus:	ld	a,[b2_toplanes]
		jp	board2topshow
b2awardflash:	ld	a,[b2_awardtimer]
		ld	c,a
		inc	a
		ld	[b2_awardtimer],a
		cp	11
		jr	nc,.doaward
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,$1f
.aok:		call	board2awardshow
		ld	a,10
		ld	de,b2awardflash
		jp	addtimed
.doaward:	ld	a,[b2_award]
		jp	board2award

b2swaptop:	ld	a,[b2_toplanes]
		srl	a
		jr	nc,.aok
		or	2
.aok:		jp	board2toplanes

award2left:	call	b2swaptop
;		ld	a,FX_FLIPPER
;		call	InitSfx

;DEBUG
		ld	a,[b2_melody]
		add	a
		cp	64
		jr	c,.aok2
		sub	63
.aok2:		call	board2melody

		ld	a,[b2_award]
		add	a
		cp	32
		jr	c,.aok
		sub	31
.aok:		jp	board2award

award2right:	call	b2swaptop
;		ld	a,FX_FLIPPER
;		call	InitSfx

		ld	a,[b2_melody]
		srl	a
		jr	nc,.aok2
		or	32
.aok2:		call	board2melody

		ld	a,[b2_award]
		srl	a
		jr	nc,.aok
		or	16
.aok:		jp	board2award


b2forcemelody:
		ld	a,0
		call	b2showtv
		ld	a,FX_LIT
		call	InitSfx

		xor	a
		ld	[b2_melody],a
		ld	a,1
		ld	[b2_melodytimer],a
		ld	a,1
		ld	de,b2melodyflash
		call	addtimed
		ld	a,[any_table]
		or	a
		jr	z,.starttable
		jp	dorelit
.starttable:				;start table game
		ld	a,[b2_litgame]
; ld a,TABLEGAME_BEAR ;DEBUG
		cp	TABLEGAME_EXTRA
		jr	z,.extra
		cp	TABLEGAME_ICECAVE
		jr	z,.icecave
		cp	TABLEGAME_KICK
		jr	z,.kick
		cp	TABLEGAME_DASH
		jp	z,.dash
		cp	TABLEGAME_CLOAK
		jr	z,.cloak
		cp	TABLEGAME_UNDERTOW
		jp	z,.undertow
		cp	TABLEGAME_BEAR
		jp	z,.bear
		cp	TABLEGAME_TRIDENT
		jp	z,.trident
		ret

.extra:		call	b2doextraopen
		jp	b2finishedmode
.kick:		ld	a,1
		ld	[b2_kicklock],a
		xor	a
		ld	[b2_backtimer],a
		ld	a,1
		call	board2kickback
		ld	hl,MSGKICKLOCK
		call	statusflash
		jp	b2finishedmode
.trident:
		ld	a,TRIDENTTIME
		call	settabletime
		ld	hl,IDX_TV6MAP
		call	OtherPage2
		ld	a,TV_TRIDENT
		call	b2keeptv
		ld	a,1
		ld	[b2_ramp],a
		ld	[b2_leftinnerloop],a
		ld	[b2_rightinnerloop],a
		ld	[b2_leftloop],a
		ld	[b2_rightloop],a
		ld	[b2_rightuloop],a
		ld	a,TABLEGAME_TRIDENT
		ld	hl,MSGTRIDENT
		jp	.starttable2
.icecave:
		ld	a,ICETIME
		call	settabletime
		ld	hl,IDX_TV6MAP
		call	OtherPage2
		ld	a,TV_ICECAVE
		call	b2keeptv
		ld	a,1
		ld	[b2_scoop2],a
		ld	[b2_scoop3],a
		ld	[b2_scoop4],a
		ld	a,TABLEGAME_ICECAVE
		ld	hl,MSGICECAVE
		jr	.starttable2

.cloak:
		ld	a,TABLEGAME_CLOAK
		call	b2startmulti
		ld	a,TV_CLOAK
		ld	[any_multibase],a
		call	b2keeptv
		call	b2autofire
		ld	a,TABLEGAME_CLOAK
		ld	hl,MSGCLOAK
		jr	.starttable2

.undertow:
		ld	a,60
		ld	[b2_sharkdist],a
		xor	a
		ld	[b2_sharkadd],a
		ld	hl,IDX_TV6MAP
		call	OtherPage2
		ld	a,TABLEGAME_UNDERTOW
		ld	hl,MSGUNDERTOW
		jp	.starttable2
.bear:		ld	a,29
		ld	[b2_beartime],a
		ld	a,1
		ld	[b2_rightloop],a
		ld	hl,IDX_TV8MAP
		call	OtherPage2
		ld	a,TV_BEAR
		call	b2keeptv
		ld	a,TABLEGAME_BEAR
		ld	hl,MSGBEAR
		jr	.starttable2
.dash:
		xor	a
		ld	[b2_dashpops],a
		ld	a,DASHTIME
		call	settabletime
		ld	hl,IDX_TV8MAP
		call	OtherPage2
		ld	a,TV_DASH
		call	b2keeptv
		ld	a,TABLEGAME_DASH
		ld	hl,MSGDASH
		jp	.starttable2




.starttable2:	ld	[any_table],a
		call	statusflash
		call	b2tablesong
		jp	saver5


b2melodyflash:	ld	a,[b2_melodytimer]
		ld	c,a
		inc	a
		ld	[b2_melodytimer],a
		cp	11
		jr	nc,.domelody
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,$3f
.aok:		call	board2melodyshow
		ld	a,10
		ld	de,b2melodyflash
		jp	addtimed
.domelody:	xor	a
		ld	[b2_melodytimer],a
		ld	a,[b2_melody]
		jp	board2melody


;a=value to display
board2popups:	push	af
		call	board2popupoff
		pop	af
		ld	[b2_popupstate],a
		ld	e,a
		ld	d,0
		ld	hl,IDX_TWO020CHG
		add	hl,de
		or	a
		call	nz,MakeChanges
		ld	a,[b2_popupstate]
		ld	e,B2_P
		call	b2statebit
		ld	e,B2_I
		call	b2statebit
		ld	e,B2_T
		call	b2statebit
		ld	a,[b2_popupstate]
		cpl
board2popshow:
		ld	e,B2_CLIGHT
		call	b2statebit
		ld	e,B2_BLIGHT
		call	b2statebit
		ld	e,B2_ALIGHT
		jp	b2statebit
board2popupoff:	ld	a,[b2_popupstate]
		or	a
		ret	z
		ld	e,a
		ld	d,0
		ld	hl,IDX_TWO020CHG
		add	hl,de
		jp	UndoChanges


board2sea:	ld	[b2_seastate],a
board2seashow:	ld	e,B2_SEA1
		rrca
		push	af
		call	.seastate
		ld	e,B2_SEA2
		pop	af
		rrca
		push	af
		call	.seastate
		ld	e,B2_SEA3
		pop	af
		rrca
.seastate:	ld	d,0
		jr	nc,.dok
		inc	d
.dok:		jp	b2newstate


board2kickback:
		push	af
		ld	a,[b2_kickback]
		or	a
		ld	hl,IDX_TWO017CHG
		call	nz,UndoChanges
		pop	af
		ld	[b2_kickback],a
		or	a
		ld	hl,IDX_TWO017CHG
		call	nz,MakeChanges
		ld	a,[b2_kickback]
		ld	d,a
		ld	e,B2_KICKBACK
		jp	b2newstate

board2leftkickback:
		push	af
		ld	a,[b2_leftkickback]
		or	a
		ld	hl,IDX_TWO028CHG
		call	nz,UndoChanges
		pop	af
		ld	[b2_leftkickback],a
		or	a
		ld	hl,IDX_TWO028CHG
		call	nz,MakeChanges
		ld	a,[b2_leftkickback]
		ld	d,a
		ld	e,B2_LEFTKICK
		jp	b2newstate

b2seaflash:	ld	a,[b2_seatimer]
		ld	c,a
		inc	a
		ld	[b2_seatimer],a
		cp	15
		jr	nc,.openkickback
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,7
.aok:		call	board2seashow
		ld	a,10
		ld	de,b2seaflash
		jp	addtimed
.openkickback:
		ld	a,[b2_seastate]
		call	board2sea
		ld	de,(1<<8)|B2_KICKLIGHT
		jp	b2newstate

b2popupflash:	ld	a,[b2_poptimer]
		ld	c,a
		inc	a
		ld	[b2_poptimer],a
		cp	11
		jr	nc,.lighttrap
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,15
.aok:		call	board2popshow
		ld	a,10
		ld	de,b2popupflash
		jp	addtimed
.lighttrap:	xor	a
		call	board2popshow
		ld	a,1
		ld	[b2_locked],a
		ret


b2dokickbackopen:
		ld	a,1
		call	board2kickback
		ld	a,1
		call	board2leftkickback
;		ld	hl,MSGKICKBACKOPEN
;		call	statusflash
		ld	a,6
		jp	b2showtv

b2kick:		ld	a,[b2_kicklock]
		or	a
		jr	nz,.locked
		ld	a,[any_ballsaver]
		or	a
		jr	nz,.locked
		ld	a,[b2_backtimer]
		cp	BACKCLOSETIME*3/4
		jr	nc,.aok
		ld	a,BACKCLOSETIME*3/4
.aok:		ld	[b2_backtimer],a
.locked:	ld	a,1
		call	board2kickback
		ld	a,FX_KICKBACK
		call	InitSfx
		ld	hl,MSGKICKBACK
		call	statusflash
		call	RumbleHigh
		ld	a,KICKBACKVEL&255
		ldh	[pin_vy],a
		ld	a,KICKBACKVEL>>8
		ldh	[pin_vy+1],a
		ret

b2leftkick:	ld	a,[b2_kicklock]
		or	a
		jr	nz,.locked
		ld	a,[any_ballsaver]
		or	a
		jr	nz,.locked
		ld	a,[b2_leftbacktimer]
		cp	BACKCLOSETIME*3/4
		jr	nc,.aok
		ld	a,BACKCLOSETIME*3/4
.aok:		ld	[b2_leftbacktimer],a
.locked:	ld	a,1
		call	board2leftkickback
		ld	a,FX_KICKBACK
		call	InitSfx
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
		cp	TABLEGAME_VOLCANO
		ret	z
.notmulti:
		ld	a,[b2_litgame]
		or	a
		jr	nz,.normalfinish
		ld	a,[b2_completed]
		inc	a
		ret	z
		call	random
		and	7
		inc	a
		ld	[b2_litgame],a
		jp	b2switchmode

.normalfinish:
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,Bits
		add	hl,bc
		ld	a,[hl]
		ld	hl,b2_completed
		or	[hl]
		ld	[hl],a
		cp	$ff
		jr	nz,b2switchmode
		xor	a
		ld	[hl],a
		ld	[b2_litgame],a
		jp	b2startmorgana

b2switchmode:	ld	a,[any_table]
		or	a
		ret	nz
		ld	a,[b2_litgame]
		or	a
		ret	z
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,Bits
		add	hl,bc
		ld	b,[hl]
		ld	a,[b2_completed]
		ld	d,a
		inc	a
		jr	z,.isff
.find:		rlc	b
		inc	c
		ld	a,d
		and	b
		jr	nz,.find
		ld	a,c
		and	7
		inc	a
.isff:		ld	[b2_litgame],a
		ret



board2chances:
;MAKING hard like easy
;		db	7	; small points 100k-1M in 100k
;		dw	b2smallpoints
;		db	6	; big points 3M-10M in 1M
;		dw	b2bigpoints
;		db	7	; relight kickback (if unlit)
;		dw	b2relightkickback
;		db	7	; advance multiplier (if < 25)
;		dw	b2advancemultiplier
;		db	6	; Hold pops (if not held)
;		dw	b2holdpops
;		db	3	; Super pops (pop count -> 99 if below)
;		dw	b2superpops
;		db	3	; hold multiplier (if not held)
;		dw	b2holdmultiplier
;		db	4	; Light Lock (if not lit)
;		dw	b2lightlock
;		db	3	; 30 second ball saver (if not on)
;		dw	b230secondsaver
;		db	2	; Light Mode (MELODY turned on if not in tablegm)
;		dw	b2lightmode
;		db	1	; 60 sec ball saver (if not on)
;		dw	b260secondsaver
;		db	5	; Mega pops (pops score 3M for 60 seconds)
;		dw	b2megapops
;		db	2	; Instant sub game (if no table game)
;		dw	b2instantsub
;		db	1	; Extra ball (once per game)
;		dw	b2extraball
;		db	0

board2chanceseasy:
		db	4	; small points 100k-1M in 100k
		dw	b2smallpoints
		db	3	; big points 3M-10M in 1M
		dw	b2bigpoints
		db	7	; relight kickback (if unlit)
		dw	b2relightkickback
		db	7	; advance multiplier (if < 25)
		dw	b2advancemultiplier
		db	4	; Hold pops (if not held)
		dw	b2holdpops
		db	2	; Super pops (pop count -> 99 if below)
		dw	b2superpops
		db	6	; hold multiplier (if not held)
		dw	b2holdmultiplier
		db	5	; Light Lock (if not lit)
		dw	b2lightlock
		db	6	; 30 second ball saver (if not on)
		dw	b230secondsaver
		db	5	; Light Mode (ARIEL turned on if not in tablegm)
		dw	b2lightmode
		db	5	; Pearl ball award
		dw	b2pearlball
		db	4	; 60 sec ball saver (if not on)
		dw	b260secondsaver
		db	4	; Mega pops (pops score 3M for 60 seconds)
		dw	b2megapops
		db	5	; Instant sub game (if no table game)
		dw	b2instantsub
		db	1	; Extra ball (once per game)
		dw	b2extraball
		db	0


b2smalllist:	dw	score100k
		dw	MSG100K
		dw	score200k
		dw	MSG200K
		dw	score300k
		dw	MSG300K
		dw	score400k
		dw	MSG400K
		dw	score500k
		dw	MSG500K
		dw	score600k
		dw	MSG600K
		dw	score700k
		dw	MSG700K
		dw	score800k
		dw	MSG800K
		dw	score900k
		dw	MSG900K
		dw	score1m
		dw	MSG1M
b2biglist:	dw	score3m
		dw	MSG3M
		dw	score4m
		dw	MSG4M
		dw	score5m
		dw	MSG5M
		dw	score6m
		dw	MSG6M
		dw	score7m
		dw	MSG7M
		dw	score8m
		dw	MSG8M
		dw	score9m
		dw	MSG9M
		dw	score10m
		dw	MSG10M


b2bigpoints:
		ld	a,20
		call	b2showtv
		ld	hl,b2biglist
		ld	bc,$0708
		jr	b2randomscore
b2smallpoints:
		ld	a,21
		call	b2showtv
		ld	hl,b2smalllist
		ld	bc,$0f0a
b2randomscore:	call	random
		and	b
		cp	c
		jr	nc,b2randomscore
		add	a
		add	a
		add	l
		ld	l,a
		ld	a,0
		adc	h
		ld	h,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		push	hl
		call	addscore
		pop	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	b2flashaccepted

b2relightkickback:
		ld	a,[b2_leftkickback]
		or	a
		jr	z,.doit
		ld	a,[b2_kickback]
		or	a
		jp	nz,b2tryagain
.doit:		call	b2dokickbackopen
		jp	b2accepted

b2advancemultiplier:
		ld	a,[b2_bonus]
		cp	25
		jp	z,b2tryagain
		call	b2advancebonus
		jp	b2accepted
b2holdpops:	ld	a,[b2_holdpops]
		or	a
		jp	nz,b2tryagain
		inc	a
		ld	[b2_holdpops],a
		ld	a,13
		call	b2showtv
		jp	b2accepted
;		ld	hl,MSGHOLDPOPS
;		jp	b2flashaccepted
b2holdmultiplier:
		ld	a,[b2_holdmult]
		or	a
		jp	nz,b2tryagain
		call	b2showmultheld
		jp	b2accepted

b2showmultheld:	ld	a,1
		ld	[b2_holdmult],a
		ld	a,18
		jp	b2showtv

b2extraball:
		ld	a,[any_awardextra]
		or	a
		jp	nz,b2tryagain
		inc	a
		ld	[any_awardextra],a
		call	b2doextraopen
		jp	b2accepted

b2lightlock:	ld	a,[any_table]
		or	a
		jp	nz,b2tryagain
		ld	a,[b2_locked]
		or	a
		jp	nz,b2tryagain
		inc	a
		ld	[b2_locked],a
		xor	a
		call	board2popups
		call	b2showlockopen
		jp	b2accepted

b2pearlball:	ld	a,[any_pearlball]
		or	a
		jp	nz,b2tryagain
		inc	a
		ld	[any_pearlball],a
		ld	a,TV_PEARL
		call	b2showtv
		ld	hl,MSGPEARLBALL2X
		jp	b2flashaccepted

b260secondsaver:
		ld	b,60
		ld	c,3
		ld	hl,MSG60SAVER
		jr	b2savers
b230secondsaver:
		ld	b,30
		ld	c,2
		ld	hl,MSG30SAVER
b2savers:	ld	a,[any_ballsaver]
		or	a
		jp	nz,b2tryagain
		ld	a,b
		ld	[any_ballsaver],a
		ld	a,c
		push	hl
		call	b2showtv
		pop	hl
		jp	b2flashaccepted

b2superpops:	ld	a,[b2_popcount]
		cp	99
		jp	nc,b2tryagain
		ld	a,99
		ld	[b2_popcount],a
		ld	a,14
		call	b2showtv
		ld	hl,MSGSUPERPOPS
		jp	b2flashaccepted

b2megapops:	ld	a,[b2_megapops]
		or	a
		jp	nz,b2tryagain
		ld	a,60
		ld	[b2_megapops],a
		ld	a,15
		call	b2showtv
		ld	hl,MSGMEGAPOPS
		jp	b2flashaccepted

b2lightmode:
		ld	a,[b2_melodytimer]
		or	a
		jp	nz,b2tryagain
		ld	a,[any_table]
		or	a
		jp	nz,b2tryagain
		call	b2forcemelody
		jp	b2accepted

b2instantsub:
		ld	a,[any_table]
		or	a
		jr	nz,b2tryagain
.r:		call	random
		and	7
		add	10
		cp	SUBGAME_MORGANA
		jr	z,.r
		call	ChainSub
		jp	b2accepted

b2tryagain:	ld	a,1
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
		ld	hl,any_chances
		jp	b2dochance

;hl=any_chances
b2dochance:	push	hl
		ld	b,[hl]
		inc	hl
.rnd:		call	random
		and	127
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
		ld	de,.chanceret
		push	de
		jp	[hl]
.chanceret:	or	a
		pop	hl
		jr	nz,b2dochance
		ret

b2doextraopen:
		ld	a,FX_LIT
		call	InitSfx
		ld	hl,any_extra
		inc	[hl]
		ld	a,4
		jp	b2showtv
;		ld	hl,MSGEXTRAOPEN
;		jp	statusflash

b2showlockopen:
		ld	a,FX_LOCKOPEN
		call	InitSfx
;		ld	hl,MSGLOCKOPEN
;		call	statusflash
		ld	a,5
		jp	b2showtv

b2close:	ld	a,1
board2gate:
		ld	[b2_gate],a
		or	a
		jr	nz,.close
.open:		ld	de,B2_ENTRANCE
		jp	b2newstate
.close:		ld	de,(1<<8)|B2_ENTRANCE
		jp	b2newstate

b2startmulti:	ld	[any_inmulti],a
		ld	a,$55
		ld	[wMzShift],a
		xor	a
		ld	[any_1234],a
		ld	a,SAMPLE_MULTIBALL
		ld	[any_samplewant],a
		call	saver30
		ld	a,FX_MULTIBALL
		call	InitSfx
		ld	hl,IDX_TV7MAP
		jp	OtherPage2

b2tableprocess:	ld	a,[any_table]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(b2tableprocesses)
		ld	l,a
		ld	a,0
		adc	HIGH(b2tableprocesses)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
b2dummytable:	ret

b2tableprocesses:
		dw	b2dummytable		;1
		dw	b2icecaveprocess	;2
		dw	b2undertowprocess	;3
		dw	b2tridentprocess	;4
		dw	b2dummytable		;5
		dw	b2cloakprocess		;6
		dw	b2dashprocess		;7
		dw	b2bearprocess		;8
		dw	b2volcanoprocess	;9
		dw	b2morganaprocess	;10
		dw	b2happyprocess		;11

b2bearmsglist:
		dw	MSG5M
		dw	MSG10M
		dw	MSG15M
		dw	MSG20M
		dw	MSG25M
b2bearprocess:
		ld	a,[wTime]
		and	$7f
		ret	nz
;		jr	z,.norm
;		cp	$40
;		ret	nz
;		ld	a,[b2_beartime]
;		ld	b,5
;.mod5:		sub	b
;		jr	nc,.mod5
;		add	b
;		cp	3
;		ret	nz
;		jr	.bearmsg
;.norm:
		ld	hl,b2_beartime
		dec	[hl]
		jr	z,.endbear
		ld	a,[hl]
		ld	bc,$5ff
.even5:		inc	c
		sub	b
		ret	c
		jr	nz,.even5
		ld	b,0
		push	bc
		ld	a,TV_BEAR+5
		sub	c
		call	b2keeptv
		pop	bc
		ld	hl,b2bearmsglist
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	statusflash
.bearmsg:	ld	hl,MSGBEAR
		jp	statusflash
.endbear:	ld	a,1
		ld	[b2_beartime],a
		ld	a,TV_BEAR+6
		call	b2keeptv
		jp	b2endtable

		

b2undertowmsglist:
		dw	MSGDIST5
		dw	MSGDIST10
		dw	MSGDIST15
		dw	MSGDIST20
		dw	MSGDIST25
		dw	MSGDIST30
		dw	MSGDIST35
		dw	MSGDIST40
		dw	MSGDIST45
		dw	MSGDIST50
		dw	MSGDIST55
		dw	MSGDIST60
		dw	MSGDIST65
		dw	MSGDIST70
		dw	MSGDIST75
		dw	MSGDIST80
		dw	MSGDIST85
		dw	MSGDIST90
		dw	MSGDIST95
		dw	MSGDIST100
		dw	MSGDIST105
		dw	MSGDIST110
		dw	MSGDIST115
		dw	MSGDIST120

b2undertowprocess:
		ld	c,0
		ld	hl,b2_sharkadd
		ld	a,[hl]
		or	a
		jr	z,.cok
		dec	[hl]
		inc	c
.cok:		ld	hl,b2_sharkdist
		ld	a,[hl]
		add	c
		ld	[hl],a
		cp	110
		jr	nc,.undertowwon
		ld	a,c
		or	a
		jr	nz,.nodec
		ld	a,[b2_seconds]
		or	a
		ret	nz
		dec	[hl]
		jp	z,b2endtable
.nodec:		ld	a,[hl]
		call	b2sharkshow
		ld	a,[b2_sharkdist]
		ld	bc,$5ff
.div5:		inc	c
		sub	b
		ret	c
		jr	nz,.div5
		ld	b,0
		ld	hl,b2undertowmsglist
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	statusflash
		ld	hl,MSGUNDERTOW
		jp	statusflash
.undertowwon:	ld	a,1
		ld	[b2_undertowsub],a
;		ld	a,SUBGAME_PRISON
;		call	unlocksub
		call	b2sublit
		ld	de,score50m
		call	addscore
		ld	hl,MSGUNDERTOWWON
		call	statusflash
		jp	b2quietend
b2sharkshow:
		cp	105
		jr	c,.aok
		ld	a,105
.aok:		ld	c,a
		ld	b,0
		ld	hl,b2undertowmap
		add	hl,bc
		ld	a,[hl]
		add	TV_UNDERTOW
		jp	b2keeptv


b2undertowmap:	db	0,0,0,0,0
		db	1,1,1,1,1,1,1,1,1,1
		db	2,2,2,2,2,2,2,2,2,2
		db	3,3,3,3,3,3,3,3,3,3
		db	4,4,4,4,4,4,4,4,4,4
		db	5,5,5,5,5,5,5,5,5,5
		db	6,6,6,6,6,6,6,6,6,6
		db	7,7,7,7,7,7,7,7,7,7
		db	8,8,8,8,8,8,8,8,8,8
		db	9,9,9,9,9,9,9,9,9,9
		db	10,10,10,10,10,10,10,10,10,10
		db	10,10,10,10,10,10,10,10,10,10
		db	10,10,10,10,10,10,10,10,10,10



b2tridentprocess:
b2dashprocess:
b2icecaveprocess:
		ld	a,[any_tabletime]
		or	a
		jr	z,b2endwithfx
		ret

b2endwithfx:	ld	a,FX_LOSETABLE
		call	InitSfx
		jr	b2endtable


b2happyprocess:
		ret
b2cloakprocess:
		ret
b2volcanoprocess:
		ret
b2morganaprocess:
		ret


b2endtable:	xor	a
		ld	[wMzShift],a
		ld	a,[any_table]
		or	a
		ret	z
		cp	TABLEGAME_VOLCANO
		jr	z,.volcanoend
		cp	TABLEGAME_DASH
		jr	z,.dashend
		cp	TABLEGAME_ICECAVE
		jr	z,.icecaveend
		cp	TABLEGAME_UNDERTOW
		jr	z,.undertowend
		cp	TABLEGAME_BEAR
		jr	z,.bearend
		cp	TABLEGAME_TRIDENT
		jr	z,.tridentend
		cp	TABLEGAME_CLOAK
		jr	z,.cloakend
		jr	b2quietend
.cloakend:	ld	hl,MSGCLOAKOVER
		jr	.anyend

.volcanoend:	ld	a,7
		call	board2popups
		ld	hl,MSGVOLCANOOVER
		jr	.anyend
.tridentend:
		xor	a
		ld	[b2_ramp],a
		ld	[b2_leftinnerloop],a
		ld	[b2_rightinnerloop],a
		ld	[b2_leftloop],a
		ld	[b2_rightloop],a
		ld	[b2_rightuloop],a

		ld	a,[b2_tridentsub]
		or	a
		ld	hl,MSGTRIDENTOVER
		jr	z,.anyend
		ld	hl,MSGTRIDENTWON
		jr	.anyend
.icecaveend:
		xor	a
		ld	[b2_scoop1],a
		ld	[b2_scoop2],a
		ld	[b2_scoop3],a
		ld	[b2_scoop4],a
		ld	hl,MSGICECAVEOVER
		ld	a,[b2_icecavesub]
		or	a
		jr	z,.anyend
		jr	b2quietend
.undertowend:
		ld	hl,MSGUNDERTOWLOST
		jr	.anyend
.bearend:
		xor	a
		ld	[b2_rightloop],a
		ld	a,[b2_beartime]
		or	a
		jr	z,b2quietend
		ld	hl,MSGBEAROVER
		jr	.anyend
.dashend:
		ld	hl,MSGDASHOVER
		jr	.anyend


.anyend:	call	statusflash
b2quietend:
		ld	a,SONG_TABLE2
		call	PrefTune1
		xor	a
		ld	[any_table],a
		ld	[any_tabletime],a
		ld	[any_tvback],a
		ld	a,[any_tvhold]
		or	a
		jr	nz,.ok
		ld	a,1
		ld	[any_tvhold],a
.ok:		jp	b2finishedmode


b2starthappy:
		xor	a
		ld	[wStartHappy],a
		inc	a
		ld	[wHappyMode],a
		call	b2doextraopen
		ld	a,TABLEGAME_HAPPY
		call	b2startmulti
		ld	a,TV_HAPPY
		ld	[any_multibase],a
		call	b2keeptv		
		ld	a,2
		ld	[any_happyfire],a
		call	b2triggerhappy
		ld	a,TABLEGAME_HAPPY
		ld	[any_table],a
		call	b2tablesong
		ld	hl,MSGHAPPYMULTI
		jp	statusflash

b2happyfire:
		call	b2fire
		ld	hl,any_happyfire
		dec	[hl]
		ret	z
b2triggerhappy:
		ld	de,b2happyfire
		ld	a,10
		jp	addtimed

b2startmorgana:
		ld	a,TABLEGAME_MORGANA
		call	b2startmulti
		ld	a,TV_MORGANA
		ld	[any_multibase],a
		call	b2keeptv
		ld	a,3
		ld	[b2_morganafire],a
		call	b2triggermorgana
		ld	a,TABLEGAME_MORGANA
		ld	[any_table],a
		call	b2tablesong
		ld	hl,MSGMORGANAMULTI
		jp	statusflash
b2morganafire:
		ld	de,E2X
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b2_morganafire
		dec	[hl]
		ret	z
b2triggermorgana:
		ld	de,b2morganafire
		ld	a,60
		jp	addtimed

b2doextraball:	ld	hl,any_ballsleft
		inc	[hl]
		jr	nz,.fine
		dec	[hl]
.fine:		ld	a,FX_EXTRABALL
		call	InitSfx
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
		ld	a,16
		jp	b2showtv

SPINNERFRAMES	EQU	32
SPINNERCENTER	EQU	7
board2spinner:	ldh	a,[pin_dspinner]
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
		cp	8*8
		jr	c,.nocredit
		cp	$18*8
		jr	nc,.nocredit
		ld	e,a
		ld	a,d
		cp	8*8
		jr	c,.nocredit
		cp	$18*8
		jr	nc,.nocredit
		xor	e
		and	$10*8
		jr	z,.nocredit
;Spinner one credit
		call	b2sebastianreact
		call	IncBonusVal
		ld	a,FX_SPINNER
		call	InitSfx

;		ldh	a,[pin_difficulty]	;MAKING hard like easy
;		or	a
;		jr	nz,.noincbonus
		ld	hl,any_spinbonus
		inc	[hl]
		ld	a,[hl]
		cp	SPINNERBONUS
		jr	c,.noincbonus
		ld	[hl],0
		call	b2advancebonus
.noincbonus:
		ld	hl,b2_sharkadd
		ld	a,[hl]
		add	4
		ld	[hl],a

		ld	hl,any_quarter
		inc	[hl]
		ld	a,[hl]
		and	3
		jr	nz,.noincjack
		ld	hl,b2_volcanojack
		ld	e,100
		call	incmax1
.noincjack:

		ld	de,spinnerscore
		call	addscoreh
.nocredit:
		ldh	a,[pin_dspinner]
		ld	b,a
		ld	a,[wTime]
		and	3
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
		and	7
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
		ld	de,248<<4
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
		ld	bc,284<<4
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
		add	255&IDX_SPINNER2
		ld	c,a
		ld	a,0
		adc	IDX_SPINNER2>>8
		ld	b,a
		ld	a,l
		sub	SPINNERCENTER+1
		jr	nc,.aok4
		add	SPINNERFRAMES
.aok4:		cp	SPINNERFRAMES/2
		ld	a,GROUP_SPINNER2B
		jr	c,.aok5
		ld	a,GROUP_SPINNER2
.aok5:
		jp	AddFigure

SPINNERMAXVEL	EQU	6
SPINNERBIAS	EQU	2
b2hitspinner:
		ld	h,-9
		ld	l,31
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
		add	a
		cpl
		inc	a
		ldh	[pin_dspinner],a
.nochange:	ret

checkicecave:	ld	a,FX_TABLEADVANCE
		call	InitSfx
		ld	de,score10m
		call	addscore
		ld	hl,b2_scoop2
		ld	a,[hli]
		add	[hl]
		inc	hl
		add	[hl]
		push	af
		cpl
		add	TV_ICECAVE+3+1
		call	b2keeptv
		pop	af
		jr	nz,.icecavecont
		ld	a,1
		ld	[b2_scoop1],a
		ld	hl,MSGICECAVECLOSE
		jp	statusflash
.icecavecont:	ld	hl,MSGMOREICECAVE
		jp	statusflash

dashcredit:	ld	hl,b2_dashpops
		inc	[hl]
		ld	a,[hl]
		srl	a
		cp	6
		jr	c,.aok
		ld	a,6
.aok:		add	TV_DASH
		call	b2keeptv
		ld	a,[b2_dashpops]
		cp	DASHWIN
		jr	c,.nodashwon
		ld	a,1
		ld	[b2_dashsub],a
;		ld	a,SUBGAME_DASH
;		call	unlocksub
		call	b2sublit
		ld	hl,MSGDASHALL
		call	statusflash
		ld	de,score50m
		call	addscore
		jp	b2quietend
.nodashwon:	ld	hl,MSGDASHPOP
		call	statusflash
		ld	a,FX_SUPERPOP
		call	InitSfx
		ld	de,score5m
		jp	addscore
b2tablesong:	ld	a,[any_table]
		ld	c,a
		ld	b,0
		ld	hl,b2songmap
		add	hl,bc
		ld	a,[hl]
		or	a
		ret	z
		jp	PrefTune2

b2songmap:	db	0
		db	0
		db	SONG_ICECAVE
		db	SONG_PRISON
		db	SONG_TRIDENT
		db	0
		db	SONG_CLOAK
		db	SONG_DASH
		db	SONG_BEAR
		db	SONG_VOLCANO
		db	SONG_MORGANA
		db	SONG_HAPPY2

b2tryswitch:
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


board2_end::

