; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BOARD1.ASM                                                            **
; **                                                                       **
; ** Created : 20000316 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		SECTION	03

board1_start::


SPINNERX	EQU	124
SPINNERY	EQU	114

GROUP_SPINNER	EQU	2
GROUP_SPINNERB	EQU	3
GROUP_TRIDENT	EQU	4
GROUP_REDFLIP	EQU	5

TRIDENTX	EQU	173<<5
TRIDENTY	EQU	305<<5


b1_cavesub	EQUS	"wTemp1024+00" ;subgame enabled
b1_scuttlesub	EQUS	"wTemp1024+01" ;subgame enabled
b1_scuttlepops	EQUS	"wTemp1024+02"
b1_stormsub	EQUS	"wTemp1024+03" ;subgame enabled
b1_smallloop	EQUS	"wTemp1024+04"
b1_leftloop	EQUS	"wTemp1024+05"
b1_rightloop	EQUS	"wTemp1024+06"
b1_innerloop	EQUS	"wTemp1024+07"
b1_ramp		EQUS	"wTemp1024+08"
b1_floundersub	EQUS	"wTemp1024+09" ;subgame enabled
b1_sharkdist	EQUS	"wTemp1024+10"
b1_ursulafire	EQUS	"wTemp1024+11"
b1_ursulasub	EQUS	"wTemp1024+12" ;subgame enabled
b1_trident	EQUS	"wTemp1024+13"
b1_gate		EQUS	"wTemp1024+14"
b1_stormjack	EQUS	"wTemp1024+15"
b1_holdpops	EQUS	"wTemp1024+16"
b1_sharkadd	EQUS	"wTemp1024+17"
b1_flotsamsub	EQUS	"wTemp1024+18" ;subgame enabled
b1_completed	EQUS	"wTemp1024+19"
b1_popcount	EQUS	"wTemp1024+20"
b1_rampcount	EQUS	"wTemp1024+21"
b1_scoop1	EQUS	"wTemp1024+22" ;don't
b1_scoop2	EQUS	"wTemp1024+23" ;change
b1_scoop3	EQUS	"wTemp1024+24" ;the
b1_scoop4	EQUS	"wTemp1024+25" ;order
b1_treasuresub	EQUS	"wTemp1024+26" ;subgame enabled
b1_2balljack	EQUS	"wTemp1024+27"
b1_kisstime	EQUS	"wTemp1024+28"
b1_kisssub	EQUS	"wTemp1024+29" ;subgame enabled
b1_holdmult	EQUS	"wTemp1024+30"
b1_kicklock	EQUS	"wTemp1024+31"
b1_popupstate	EQUS	"wTemp1024+32"
b1_seastate	EQUS	"wTemp1024+33"
b1_kickback	EQUS	"wTemp1024+34"
b1_award	EQUS	"wTemp1024+35"
b1_backtimer	EQUS	"wTemp1024+36"
b1_seatimer	EQUS	"wTemp1024+37"
b1_toplanes	EQUS	"wTemp1024+38"
b1_toptimer	EQUS	"wTemp1024+39"
b1_bonus	EQUS	"wTemp1024+40"
b1_topdelay	EQUS	"wTemp1024+41"
b1_awarddelay	EQUS	"wTemp1024+42"
b1_awardtimer	EQUS	"wTemp1024+43"
b1_ariel	EQUS	"wTemp1024+44"
b1_arieltimer	EQUS	"wTemp1024+45"
b1_poptimer	EQUS	"wTemp1024+46"
b1_trapped	EQUS	"wTemp1024+47"
b1_awardready	EQUS	"wTemp1024+48"
b1_locked	EQUS	"wTemp1024+49"
b1_seconds	EQUS	"wTemp1024+50"
b1_megapops	EQUS	"wTemp1024+51"
b1_outerenter	EQUS	"wTemp1024+52" ;4
b1_outerexit	EQUS	"wTemp1024+56" ;4
b1_innerenter	EQUS	"wTemp1024+60" ;4
b1_smallenter	EQUS	"wTemp1024+64" ;4
b1_ursulajack	EQUS	"wTemp1024+68" ;2
b1_litgame	EQUS	"wTemp1024+70"
b1_happyjack	EQUS	"wTemp1024+71" ;2

TABLEGAME_EXTRA	EQU	1
TABLEGAME_CAVE	EQU	2
TABLEGAME_SHARK	EQU	3
TABLEGAME_KISS	EQU	4
TABLEGAME_KICK	EQU	5
TABLEGAME_FLOTSAM EQU	6
TABLEGAME_TREASURE EQU	7
TABLEGAME_SCUTTLE EQU	8
TABLEGAME_STORM	EQU	9
TABLEGAME_URSULA EQU	10
TABLEGAME_HAPPY	EQU	11

TV_TREASURE	EQU	44
TV_SCUTTLE	EQU	28
TV_FLOTSAM	EQU	37
TV_KISS		EQU	36
TV_CAVE		EQU	39
TV_SHARK	EQU	28
TV_URSULA	EQU	32
TV_STORM	EQU	28
TV_HAPPY	EQU	40
TV_PEARL	EQU	23

CODE_LEFTLOOP	EQU	1
CODE_RIGHTLOOP	EQU	2
CODE_RAMP	EQU	3
CODE_INNERLOOP	EQU	4
CODE_SMALLLOOP	EQU	5

SCUTTLEWIN	EQU	12	;# of pops to win the scuttle tablegame
SCUTTLETIME	EQU	120	;# of seconds allowed for scuttle tablegame
TREASURETIME	EQU	180	;# of seconds allowed for treasure tablegame
CAVETIME	EQU	180	;# of seconds allowed for cave tablegame


board1info:	db	BANK(Nothing)		;wPinJmpHit
		dw	Nothing
		db	BANK(board1process)	;wPinJmpProcess
		dw	board1process
		db	BANK(board1sprites)	;wPinJmpSprites
		dw	board1sprites
		db	BANK(board1hitflipper)	;wPinJmpHitFlipper
		dw	board1hitflipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(board1hitbumper)	;wPinJmpHitBumper
		dw	board1hitbumper
		db	BANK(PinScore)		;wPinJmpScore
		dw	PinScore
		db	BANK(b1lostball)	;wPinJmpLost
		dw	b1lostball
		db	BANK(board1eject)	;wPinJmpEject
		dw	board1eject
		db	BANK(b1unchain)		;wPinJmpChainRet
		dw	b1unchain
		dw	CUTOFFY			;wPinCutoff
		dw	IDX_FLIPS001CHG		;lflippers
		dw	IDX_FLIPS009CHG		;rflippers
		db	BANK(board1info)	;wPinHitBank
		db	BANK(Char0a0)		;wPinCharBank

board1chances:
;MAKING hard like easy
;		db	7	; small points 100k-1M in 100k
;		dw	b1smallpoints
;		db	6	; big points 3M-10M in 1M
;		dw	b1bigpoints
;		db	7	; relight kickback (if unlit)
;		dw	b1relightkickback
;		db	7	; advance multiplier (if < 25)
;		dw	b1advancemultiplier
;		db	6	; Hold pops (if not held)
;		dw	b1holdpops
;		db	3	; Super pops (pop count -> 99 if below)
;		dw	b1superpops
;		db	4	; hold multiplier (if not held)
;		dw	b1holdmultiplier
;		db	5	; Light Lock (if not lit)
;		dw	b1lightlock
;		db	4	; 30 second ball saver (if not on)
;		dw	b130secondsaver
;		db	3	; Light Mode (ARIEL turned on if not in tablegm)
;		dw	b1lightmode
;		db	2	; 60 sec ball saver (if not on)
;		dw	b160secondsaver
;		db	5	; Mega pops (pops score 3M for 60 seconds)
;		dw	b1megapops
;		db	2	; Instant sub game (if no table game)
;		dw	b1instantsub
;		db	1	; Extra ball (once per game)
;		dw	b1extraball
;		db	0

board1chanceseasy:
		db	4	; small points 100k-1M in 100k
		dw	b1smallpoints
		db	3	; big points 3M-10M in 1M
		dw	b1bigpoints
		db	7	; relight kickback (if unlit)
		dw	b1relightkickback
		db	7	; advance multiplier (if < 25)
		dw	b1advancemultiplier
		db	4	; Hold pops (if not held)
		dw	b1holdpops
		db	2	; Super pops (pop count -> 99 if below)
		dw	b1superpops
		db	6	; hold multiplier (if not held)
		dw	b1holdmultiplier
		db	5	; Light Lock (if not lit)
		dw	b1lightlock
		db	6	; 30 second ball saver (if not on)
		dw	b130secondsaver
		db	5	; Light Mode (ARIEL turned on if not in tablegm)
		dw	b1lightmode
		db	5	; Pearl ball award
		dw	b1pearlball
		db	4	; 60 sec ball saver (if not on)
		dw	b160secondsaver
		db	4	; Mega pops (pops score 3M for 60 seconds)
		dw	b1megapops
		db	5	; Instant sub game (if no table game)
		dw	b1instantsub
		db	1	; Extra ball (once per game)
		dw	b1extraball
		db	0

b1smalllist:	dw	score100k
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
b1biglist:	dw	score3m
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


b1bigpoints:
		ld	a,20
		call	b1showtv
		ld	hl,b1biglist
		ld	bc,$0708
		jr	randomscore
b1smallpoints:
		ld	a,21
		call	b1showtv
		ld	hl,b1smalllist
		ld	bc,$0f0a
randomscore:	call	random
		and	b
		cp	c
		jr	nc,randomscore
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
		jp	b1flashaccepted

b1relightkickback:
		ld	a,[b1_kickback]
		or	a
		jp	nz,b1tryagain
		call	b1dokickbackopen
		jp	b1accepted

b1advancemultiplier:
		ld	a,[b1_bonus]
		cp	25
		jp	z,b1tryagain
		call	b1advancebonus
		jp	b1accepted
b1holdpops:	ld	a,[b1_holdpops]
		or	a
		jp	nz,b1tryagain
		inc	a
		ld	[b1_holdpops],a
		ld	a,13
		call	b1showtv
		jp	b1accepted
;		ld	hl,MSGHOLDPOPS
;		jp	b1flashaccepted
b1holdmultiplier:
		ld	a,[b1_holdmult]
		or	a
		jp	nz,b1tryagain
		call	b1showmultheld
		jp	b1accepted

b1showmultheld:
		ld	a,1
		ld	[b1_holdmult],a
		ld	a,18
		jp	b1showtv

b1extraball:
		ld	a,[any_awardextra]
		or	a
		jp	nz,b1tryagain
		inc	a
		ld	[any_awardextra],a
		call	b1doextraopen
		jp	b1accepted

b1lightlock:	ld	a,[any_table]
		or	a
		jp	nz,b1tryagain
		ld	a,[b1_locked]
		or	a
		jp	nz,b1tryagain
		inc	a
		ld	[b1_locked],a
		xor	a
		call	board1popups
		call	b1showlockopen
		jp	b1accepted

b1pearlball:	ld	a,[any_pearlball]
		or	a
		jp	nz,b1tryagain
		inc	a
		ld	[any_pearlball],a
		ld	a,TV_PEARL
		call	b1showtv
		ld	hl,MSGPEARLBALL2X
		jp	b1flashaccepted

b160secondsaver:
		ld	b,60
		ld	c,3
		ld	hl,MSG60SAVER
		jr	b1savers
b130secondsaver:
		ld	b,30
		ld	c,2
		ld	hl,MSG30SAVER
b1savers:	ld	a,[any_ballsaver]
		or	a
		jp	nz,b1tryagain
		ld	a,b
		ld	[any_ballsaver],a
		ld	a,c
		push	hl
		call	b1showtv
		pop	hl
		jp	b1flashaccepted

b1superpops:	ld	a,[b1_popcount]
		cp	99
		jp	nc,b1tryagain
		ld	a,99
		ld	[b1_popcount],a
		ld	a,14
		call	b1showtv
		ld	hl,MSGSUPERPOPS
		jp	b1flashaccepted

b1megapops:	ld	a,[b1_megapops]
		or	a
		jp	nz,b1tryagain
		ld	a,60
		ld	[b1_megapops],a
		ld	a,15
		call	b1showtv
		ld	hl,MSGMEGAPOPS
		jp	b1flashaccepted

b1lightmode:
		ld	a,[b1_arieltimer]
		or	a
		jp	nz,b1tryagain
		ld	a,[any_table]
		or	a
		jp	nz,b1tryagain
		call	b1forceariel
		jp	b1accepted

b1instantsub:
		ld	a,[any_table]
		or	a
		jr	nz,b1tryagain
.r:		call	random
		and	7
		inc	a
		cp	SUBGAME_URSULA
		jr	z,.r
		call	ChainSub
		jp	b1accepted

b1tryagain:	ld	a,1
		ret
b1flashaccepted:
		call	statusflash
b1accepted:	xor	a
		ret

;hl=list of chances
;de=where to put table
chanceinit:
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

;hl=any_chances
dochance:	push	hl
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
		jr	nz,dochance
		ret
b1swaptop:	ld	a,[b1_toplanes]
		srl	a
		jr	nc,.aok
		or	2
.aok:		jp	board1toplanes



award1left:	call	b1swaptop
;		ld	a,FX_FLIPPER
;		call	InitSfx

;DEBUG
		ld	a,[b1_ariel]
		add	a
		cp	32
		jr	c,.aok2
		sub	31
.aok2:		call	board1ariel

		ld	a,[b1_award]
		add	a
		cp	32
		jr	c,.aok
		sub	31
.aok:		jp	board1award

award1right:	call	b1swaptop
;		ld	a,FX_FLIPPER
;		call	InitSfx

		ld	a,[b1_ariel]
		srl	a
		jr	nc,.aok2
		or	16
.aok2:		call	board1ariel

		ld	a,[b1_award]
		srl	a
		jr	nc,.aok
		or	16
.aok:		jp	board1award

SPINNERFRAMES	EQU	32
SPINNERCENTER	EQU	7
board1spinner:	ldh	a,[pin_dspinner]
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
		call	b1advancebonus
.noincbonus:
		ld	hl,b1_sharkadd
		ld	a,[hl]
		add	4
		ld	[hl],a
;spinner jackpots
		ld	hl,any_quarter
		inc	[hl]
		ld	a,[hl]
		and	3
		jr	nz,.noincjack
		ld	hl,b1_stormjack
		ld	e,100
		call	incmax1
.noincjack:

; ld a,[b1_stormjack] ;DEBUG
; ld l,a
; ld h,0
; call hltolastjack
; ld	hl,MSGJACKVALUE
; call	statusflash

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
		ld	de,SPINNERX<<4 ;86
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
		ld	bc,SPINNERY<<4 ;157
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
.aok4:		cp	SPINNERFRAMES/2
		ld	a,GROUP_SPINNERB
		jr	c,.aok5
		ld	a,GROUP_SPINNER
.aok5:
		jp	AddFigure

board1sprites:
		call	board1flippers
		call	board1trident
		jp	board1spinner

board1trident:
		ld	a,[b1_trident]
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
		ld	a,[b1_trident]
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
.novisible:	ld	hl,b1_trident
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



board1flippers:
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
		ld	de,FLIPPERY>>5
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
		ld	a,LFLIPPERX>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS+18)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(RFLIPPERX-LFLIPPERX)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS+18)>>8
		ld	b,a
		ld	a,$80+GROUP_FLIPPERS
		call	AddFigure
.nobottoms:	pop	hl
		push	hl
		ld	de,(FLIPPERY3>>5)+16
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
		ld	a,FLIPPERX3>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,GROUP_REDFLIP ;GROUP_FLIPPERS
		call	AddFigure
.noflipper3:	pop	hl
		ld	de,(FLIPPERY4>>5)+32
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		jr	nz,.noflipper4
		ld	a,e
		cp	176
		jr	nc,.noflipper4
		sub	32
		ld	e,a
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,FLIPPERX4>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS+9)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS+9)>>8
		ld	b,a
		ld	a,GROUP_REDFLIP ;GROUP_FLIPPERS
		call	AddFigure
.noflipper4:
		ret


b1lostball:
		ld	a,[any_ballsaver]
		or	a
		jr	z,.nosaver
		ld	a,FX_BALLSAVED
		call	InitSfx
		call	autofire
		ld	a,1
		jp	b1showtv
.nosaver:
		ld	a,1
		ld	[any_spitout],a

		ld	a,[any_inmulti]
		or	a
		jp	nz,b1multiend

		ld	a,[any_mlock1]
		or	a
		jr	z,.nolock1
		xor	a
		ld	[any_mlock1],a
		jp	b1out2
.nolock1:

		ld	a,[any_mlock2]
		or	a
		jr	z,.nolock2
		xor	a
		ld	[any_mlock2],a
		jp	b1out4
.nolock2:

 ld	a,[wDemoMode]
 or	a
 jp	nz,AnyQuit


		xor	a
		ld	[any_pearlball],a

		ld	a,FX_LOSTBALL
		call	InitSfx

		call	b1endtable
		ld	a,[any_table]
		cp	TABLEGAME_URSULA
		ret	z

		ld	a,1
		ld	[any_bonusinfo1],a

		ld	a,[b1_bonus]
		ld	[any_bonusmul],a

		ret


b1finishloseball:

		xor	a
		ld	[any_combo1],a
		ld	[any_combo2],a
		ld	[any_combo3],a
		ld	[any_loopcount],a
		ld	[any_comboclear],a
		ld	[any_rampfast],a

		ld	a,[b1_holdmult]
		or	a
		jr	nz,.noresetmult
		ld	a,1
		ld	[b1_bonus],a
		call	board1bonus
.noresetmult:	xor	a
		ld	[b1_holdmult],a

		ld	hl,any_bonusval
		ld	bc,5
		call	MemClear


		ld	a,[b1_holdpops]
		or	a
		jr	nz,.noresetpops
		xor	a
		ld	[b1_popcount],a
.noresetpops:	xor	a
		ld	[b1_holdpops],a

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

		ld	a,[b1_kicklock]
		or	a
		jr	z,.nokicklock
		xor	a
		ld	[b1_kicklock],a
		ld	hl,MSGLOSTKICK
		call	statusflash
.nokicklock:

		ld	a,1
		ld	[any_wantswitch],a

		ret

b1multiend:	call	CountBalls
		dec	a
		ld	c,a
		ld	a,[any_inmulti]
		cp	TABLEGAME_URSULA
		jr	z,.ursulaend
		cp	TABLEGAME_FLOTSAM
		jr	z,.flotsamend
		cp	TABLEGAME_STORM
		jr	z,.stormend
.happyend:	ld	a,[any_happyfire]
		jr	.stormurs
.stormend:	ld	a,[b1_trapped]
.stormurs:	or	a
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
		jp	b1endtable
.ursulaend	ld	a,[b1_ursulafire]
		jr	.stormurs
.flotsamend:	jp	b1endtable


board1giveaward:
		ld	hl,any_chances
		jp	dochance


board1maplist:	db	$2b	;height
		dw	IDX_BOARD1RGB
		dw	IDX_BOARD1MAP
b1orange:	ld	de,B1_ORANGE
		jp	newstate
b1pink:		ld	de,B1_PINK
		jp	newstate
b1purple:	ld	de,B1_PURPLE
		jp	newstate
b1left:		ld	de,B1_LEFTBUMPER
		jp	newstate
b1right:	ld	de,B1_RIGHTBUMPER
		jp	newstate
b1flounder0:	ld	de,B1_FLOUNDERBOD
		jp	newstate
b1flounder1:	ld	de,(1<<8)|B1_FLOUNDERBOD
		jp	newstate

b1ursulareact:
		ld	a,[wStates+B1_URSULALOOK]
		or	a
		ret	nz
		ld	de,(1<<8)|B1_URSULALOOK
		call	newstate
		ld	de,b1ursulaoff
		ld	a,30
		jp	addtimed
b1ursulaoff:
		ld	de,B1_URSULALOOK
		jp	newstate

board1hitbumper:
		ld	h,b
		ld	l,c
		ldh	a,[pin_y+1]
		ld	e,a
		ldh	a,[pin_y]
		add	a
		rl	e
		add	a
		rl	e
		add	a
		rl	e
		jr	c,.bottoms
		ld	a,e
		cp	242
		jr	nc,.bottoms
		ldh	a,[pin_x+1]
		ld	d,a
		ldh	a,[pin_x]
		add	a
		rl	d
		add	a
		rl	d
		add	a
		rl	d
		ld	a,e
		cp	105
		jp	nc,.notop3
		cp	76
		jr	nc,.notupper
		ld	a,d
		cp	98
		jr	c,.upper
.notupper:	ld	a,d
		sub	22
		sub	e
		jr	c,.lower
.middle:	ld	b,B1_ORANGE
		ld	de,b1orange
		jr	.bumps
.lower:		ld	b,B1_PURPLE
		ld	de,b1purple
		jr	.bumps
.bottoms:	ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
		ldh	a,[pin_x]
		sub	(92<<5)&255
		ldh	a,[pin_x+1]
		sbc	(92<<5)>>8
		jr	c,.bottomleft
.bottomright:	ld	b,B1_RIGHTBUMPER
		ld	de,b1right
		jr	.bumps
.bottomleft:	ld	b,B1_LEFTBUMPER
		ld	de,b1left
		jr	.bumps
.upper:		ld	b,B1_PINK
		ld	de,b1pink
.bumps:		ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
;HIT A POP BUMPER
		push	de
		ld	e,b
		ld	d,1
		call	newstate
		pop	de
		ld	a,15
		call	addtimed
.anypop:
		call	RumbleMedium
		call	IncBonusVal

		ld	hl,b1_popcount
		ld	e,99
		call	incmax1

	ld	hl,b1_ursulajack
	ld	e,200
	call	incmax1
	ld	hl,b1_happyjack
	ld	e,200
	call	incmax1

		ld	a,[any_table]
		cp	TABLEGAME_SCUTTLE
		jp	z,scuttlecredit
		ld	b,FX_SUPERPOP
		ld	de,megapopperscore
		ld	a,[b1_megapops]
		or	a
		jr	nz,.gotpopscore
		ld	de,popper99score
		ld	a,[b1_popcount]
		cp	99
		jr	nc,.gotpopscore
		ld	b,FX_BUMPER
		ld	de,popperscore
.gotpopscore:	push	bc
		call	addscore
		pop	af
		call	InitSfx
		jp	b1switchmode
.notop3:	ld	a,d
		cp	148
		jr	nc,.right2
		ld	a,e
		cp	151
		jr	c,.pops
		ld	a,d
		cp	53
		jp	c,b1sea
		cp	98
		jr	c,.lettera
		cp	120
		jr	c,.letterr
.letteri:	ld	b,4
		jp	b1ariel
.lettera:	ld	b,16
		jp	b1ariel
.letterr:	ld	b,8
		jp	b1ariel
.right2:	ld	a,e
		cp	222
		jr	c,.lettere
.letterl:	ld	b,1
		jp	b1ariel
.lettere:	ld	b,2
		jp	b1ariel
.nohit:		jr	noimpulse
.pops:		ld	a,d
		add	135-63
		sub	e
		jr	c,.pop8
		ld	a,d
		add	128-79
		sub	e
		jr	c,.pop4
		ld	a,d
		add	121-95
		sub	e
		jr	c,.pop2
.pop1:		ld	b,$fe
		jr	b1pops
.pop2:		ld	b,$fd
		jr	b1pops
.pop4:		ld	b,$fb
		jr	b1pops
.pop8:		ld	b,$f7
b1pops:		ld	a,[b1_popupstate]
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
		ld	[b1_poptimer],a
		ld	a,1
		ld	de,b1popupflash
		call	addtimed
		call	b1showlockopen
		xor	a
.notall:	call	board1popups
		ld	a,FX_DROP
		call	InitSfx
		call	RumbleLow
		ld	de,dropscore
		call	addscore
		jr	noimpulse

noimpulse:	ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret

b1sea:		ld	a,[b1_seastate]
		scf
		adc	a
		cp	7
		jr	nz,.aok
		ld	de,scorestandupunlit
		call	addscore
		ld	a,FX_SEALIT
		call	InitSfx
		call	RumbleLow
		xor	a
		ld	[b1_seatimer],a
		ld	[b1_seastate],a
		ld	a,1
		ld	de,b1seaflash
		call	addtimed
		ld	a,[b1_kickback]
		or	a
		jr	z,.newkickback
		ld	a,[b1_backtimer]
		or	a
		jr	nz,.newkickback
.haskickback:	call	dorelit
		jr	.seaflash
.newkickback:
		xor	a
		ld	[b1_backtimer],a
		call	b1dokickbackopen
		jr	.seaflash
.aok:		call	board1sea
.seaflash:	jr	noimpulse



b1dokickbackopen:
		ld	a,1
		call	board1kickback
;		ld	hl,MSGKICKBACKOPEN
;		call	statusflash
		ld	a,6
		jp	b1showtv

b1ariel:	ld	a,[b1_ariel]
		ld	c,a
		or	b
		cp	$1f
		jr	z,.complete
		cp	c
		jr	z,.finished
		jr	.nofinish
.complete:	call	b1forceariel
		jr	.finished
.nofinish:	call	board1ariel
		ld	a,[any_table]
		or	a
		ld	a,19
		call	z,b1showtv
		ld	de,scorestandupunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
		call	RumbleLow
.finished:	jp	noimpulse

scuttlecredit:	ld	hl,b1_scuttlepops
		inc	[hl]
		ld	a,[hl]
		srl	a
		cp	6
		jr	c,.aok
		ld	a,6
.aok:		add	TV_SCUTTLE
		call	b1keeptv
		ld	a,[b1_scuttlepops]
		cp	SCUTTLEWIN
		jr	c,.noscuttlewon
		ld	a,1
		ld	[b1_scuttlesub],a
;		ld	a,SUBGAME_SCUTTLE
;		call	unlocksub
		call	b1sublit
		ld	hl,MSGSCUTTLEWON
		call	statusflash
		ld	de,score50m
		call	addscore
		jp	b1quietend
.noscuttlewon:	ld	hl,MSGSCUTTLEPOP
		call	statusflash
		ld	a,FX_SUPERPOP
		call	InitSfx
		ld	de,score5m
		jp	addscore

b1forceariel:
		ld	a,0
		call	b1showtv
		ld	a,FX_LIT
		call	InitSfx

		xor	a
		ld	[b1_ariel],a
		ld	a,1
		ld	[b1_arieltimer],a
		ld	a,1
		ld	de,b1arielflash
		call	addtimed
		ld	a,[any_table]
		or	a
		jr	z,.starttable
		jp	dorelit
.starttable:				;start table game
		ld	a,[b1_litgame]
; ld a,TABLEGAME_FLOTSAM ;DEBUG
		cp	TABLEGAME_EXTRA
		jp	z,.extra
		cp	TABLEGAME_CAVE
		jp	z,.cave
		cp	TABLEGAME_SHARK
		jp	z,.shark
		cp	TABLEGAME_KISS
		jr	z,.kiss
		cp	TABLEGAME_KICK
		jp	z,.kick
		cp	TABLEGAME_FLOTSAM
		jr	z,.flotsam
		cp	TABLEGAME_TREASURE
		jr	z,.treasure
		cp	TABLEGAME_SCUTTLE
		jp	z,.scuttle
		ret

.starttable2:	ld	[any_table],a
		call	statusflash
		call	b1tablesong
		jp	saver5
.flotsam:
		ld	a,TABLEGAME_FLOTSAM
		call	b1startmulti
		ld	a,TV_FLOTSAM
		ld	[any_multibase],a
		call	b1keeptv
		call	autofire
		ld	a,TABLEGAME_FLOTSAM
		ld	hl,MSGFLOTSAM
		jr	.starttable2
.treasure:
		ld	a,TREASURETIME
		call	settabletime
		ld	hl,IDX_TV2MAP
		call	OtherPage2
		ld	a,TV_TREASURE
		call	b1keeptv
		ld	a,1
		ld	[b1_ramp],a
		ld	[b1_innerloop],a
		ld	[b1_leftloop],a
		ld	[b1_rightloop],a
		ld	[b1_smallloop],a
		ld	a,TABLEGAME_TREASURE
		ld	hl,MSGTREASURE
		jr	.starttable2
.kiss:		ld	a,29
		ld	[b1_kisstime],a
		ld	a,1
		ld	[b1_rightloop],a
		ld	hl,IDX_TV4MAP
		call	OtherPage2
		ld	a,TV_KISS
		call	b1keeptv
		ld	a,TABLEGAME_KISS
		ld	hl,MSGKISS
		jr	.starttable2
.extra:
		call	b1doextraopen
		jp	b1finishedmode
.kick:		ld	a,1
		ld	[b1_kicklock],a
		xor	a
		ld	[b1_backtimer],a
		ld	a,1
		call	board1kickback
		ld	hl,MSGKICKLOCK
		call	statusflash
		jp	b1finishedmode
.cave:		ld	a,CAVETIME
		call	settabletime
		ld	a,1
		ld	[b1_scoop2],a
		ld	[b1_scoop3],a
		ld	[b1_scoop4],a
		ld	hl,IDX_TV2MAP
		call	OtherPage2

		ld	a,TV_CAVE
		call	b1keeptv
		ld	a,TABLEGAME_CAVE
		ld	hl,MSGCAVE
		jp	.starttable2
.scuttle:
		xor	a
		ld	[b1_scuttlepops],a
		ld	a,SCUTTLETIME
		call	settabletime
		ld	hl,IDX_TV4MAP
		call	OtherPage2
		ld	a,TV_SCUTTLE
		call	b1keeptv
		ld	a,TABLEGAME_SCUTTLE
		ld	hl,MSGSCUTTLE
		jp	.starttable2
.shark:		ld	a,60
		ld	[b1_sharkdist],a
		xor	a
		ld	[b1_sharkadd],a
		ld	hl,IDX_TV2MAP
		call	OtherPage2
;		ld	a,TV_SHARK
;		call	b1keeptv
		ld	a,TABLEGAME_SHARK
		ld	hl,MSGSHARK
		jp	.starttable2

b1doextraopen:
		ld	a,FX_LIT
		call	InitSfx
		ld	hl,any_extra
		inc	[hl]
		ld	a,4
		jp	b1showtv
;		ld	hl,MSGEXTRAOPEN
;		jp	statusflash

b1doextraball:	ld	hl,any_ballsleft
		inc	[hl]
		jr	nz,.fine
		dec	[hl]
.fine:		ld	a,FX_EXTRABALL
		call	InitSfx
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
		ld	a,16
		jp	b1showtv

b1startursula:
		ld	a,TABLEGAME_URSULA
		call	b1startmulti
		ld	a,TV_URSULA
		ld	[any_multibase],a
		call	b1keeptv		
		ld	a,3
		ld	[b1_ursulafire],a
		call	b1triggerursula
		ld	a,TABLEGAME_URSULA
		ld	[any_table],a
		call	b1tablesong
		ld	hl,MSGURSULAMULTI
		jp	statusflash

b1starthappy:
		xor	a
		ld	[wStartHappy],a
		inc	a
		ld	[wHappyMode],a
		call	b1doextraopen
		call	saver60
		ld	a,TABLEGAME_HAPPY
		call	b1startmulti
		ld	a,TV_HAPPY
		ld	[any_multibase],a
		call	b1keeptv		
		ld	a,2
		ld	[any_happyfire],a
		call	b1triggerhappy
		ld	a,TABLEGAME_HAPPY
		ld	[any_table],a
		call	b1tablesong
		ld	hl,MSGHAPPYMULTI
		jp	statusflash

b1happyfire:
		call	b1fire
		ld	hl,any_happyfire
		dec	[hl]
		ret	z
b1triggerhappy:
		ld	de,b1happyfire
		ld	a,10
		jp	addtimed

tempaddball:

		xor	a
		ld	[any_wantfire],a

		ld	a,[any_harder]
		or	a
		jr	nz,.harder
		ld	a,1
		call	board1kickback
		xor	a
		ld	[b1_backtimer],a
.harder:
 ld a,[wDemoMode]
 or a
 jp nz,b1fire

		ld	a,1
		ld	[any_firing],a
		ld	[b1_trident],a

		ld	de,170<<5
		ld	bc,280<<5
		ld	hl,0
		call	AddBall
		ld	a,h
		or	l
		ret	z	;just for safety
		set	BALLFLG_LAYER,[hl]
		ret

b1fire:		xor	a
		call	board1gate
		ld	a,5
		ldh	[pin_firedelay],a
		ld	a,50
		ld	de,b1close
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

b1shoot:	ld	a,[any_firing]
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


b1firing:	ld	hl,any_firing
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
		ld	[b1_trident],a
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
		call	board1gate
		ld	a,100
		ld	de,b1close
		call	addtimed
;		ld	a,[any_harder]
;		or	a
;		call	z,saver20
		call	saver20
		xor	a
		ld	[any_harder],a
		ld	a,9
		ld	[b1_trident],a

		ld	a,SKILLTIME
		ld	[any_skill],a

		call	RumbleHigh
		ld	a,FX_BALLFIRE
		jp	InitSfx
b1tryswitch:
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
		call	board1popupoff
		call	SwitchPlayers
		call	b1restoreq
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

board1process:
		ld	hl,any_skill
		ld	a,[hl]
		or	a
		jr	z,.noskill
		ld	a,[wTime]
		and	3
		jr	nz,.noskill
		dec	[hl]
.noskill:	ld	a,[wStartHappy]
		or	a
		call	nz,b1starthappy
		ld	a,[any_wantswitch]
		or	a
		call	nz,b1tryswitch
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
		call	b1spit2
.nospit1:
		ld	a,[any_mlock2]
		or	a
		jr	z,.nospit2
		xor	a
		ld	[any_mlock2],a
		call	b1spit4
.nospit2:
.nospitout:
		ldh	a,[pin_firedelay]
		or	a
		jr	z,.nochangefd
		dec	a
		ldh	[pin_firedelay],a
.nochangefd:

		call	BonusProcess
		call	nz,b1finishloseball

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

		call	processtimed

		ld	a,[wJoy1Hit]
;		bit	JOY_SELECT,a
;		call	nz,tempaddball

		ld	a,[any_wantfire]
		or	a
		call	nz,tempaddball

		call	b1firing

		ld	a,[wJoy1Hit]
		bit	JOY_L,a
		call	nz,award1left
		ld	a,[wJoy1Hit]
		bit	JOY_A,a
		call	nz,award1right

		ld	a,[any_tofire]
		or	a
		jr	z,.nofire
		ldh	a,[pin_firedelay]
		or	a
		jr	nz,.nofire
		xor	a
		ld	[any_tofire],a
		call	b1fire
.nofire:
		ld	a,[b1_topdelay]
		or	a
		jr	z,.nodectopdelay
		dec	a
		ld	[b1_topdelay],a
.nodectopdelay:
		ld	a,[b1_awarddelay]
		or	a
		jr	z,.nodecawarddelay
		dec	a
		ld	[b1_awarddelay],a
.nodecawarddelay:
		ld	a,[wTime]
		ld	b,a
		and	$1f
		add	a
		add	LOW(b1phasetable)
		ld	l,a
		ld	a,0
		adc	HIGH(b1phasetable)
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
		ld	hl,b1_seconds
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
.nodecsaver:	ld	hl,b1_megapops
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
		call	b1tableprocess
		ret

b1startmulti:	ld	[any_inmulti],a
		ld	a,$55
		ld	[wMzShift],a
		xor	a
		ld	[any_1234],a
		call	saver30
		ld	a,FX_MULTIBALL
		call	InitSfx
		ld	a,SAMPLE_MULTIBALL
		ld	[any_samplewant],a
		ld	hl,IDX_TV3MAP
		jp	OtherPage2

b1phasetable:	dw	phaseb1indicator0
		dw	phaseb1ramp
		dw	phaseb1innerloop
		dw	0
		dw	phaseb1indicator1
		dw	phaseb1kick
		dw	phaseb1locklight
		dw	phaseb1flounder
		dw	phaseb1indicator2
		dw	0
		dw	phaseb1jackpot
		dw	phaseb1indicator3
		dw	phaseb1extrasaver
		dw	0
		dw	phaseb1ursula
		dw	0
		dw	phaseb1indicator4
		dw	phaseb1grotto
		dw	phaseb1wrecklight
		dw	0
		dw	phaseb1indicator5
		dw	phaseb1kick
		dw	phaseb1smallloop
		dw	0
		dw	phaseb1indicator6
		dw	0
		dw	phaseb1leftloop
		dw	phaseb1indicator7
		dw	phaseb1extrasaver
		dw	phaseb1rightloop
		dw	phaseb1indicatorcenter
		dw	0

phaseb1ursula:
		ld	c,1
		ld	a,[b1_scoop1]
		or	a
		jr	nz,.cok
		dec	c
		ld	a,[any_table]
		or	a
		jr	nz,.cok
		ld	a,[b1_flotsamsub]
		ld	c,a
		ld	a,[b1_ursulasub]
		or	c
		ld	c,a
		ld	a,[b1_cavesub]
		or	c
		ld	c,a
.cok:		ld	a,c
		ld	e,B1_URSULA
		jp	phaseb1flashing
phaseb1wrecklight:
		ld	a,[b1_scoop3]
		or	a
		ld	a,1
		jr	nz,.aok
		ld	a,[any_extra]
		or	a
		ld	a,1
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b1_stormsub]
		ld	hl,b1_treasuresub
		or	[hl]
		ld	hl,b1_scuttlesub
		or	[hl]
		ld	hl,b1_locked
		or	[hl]
.aok:		ld	e,B1_WRECK
		jp	phaseb1flashing
phaseb1flounder:
		ld	e,B1_FLOUNDER
		ld	d,1
		ld	a,[any_mlock1]
		or	a
		jp	nz,newstate
		ld	a,[any_table]
		cp	TABLEGAME_STORM
		jr	z,.maybemlock
		cp	TABLEGAME_URSULA
		jr	z,.maybemlock
		or	a
		ld	a,[b1_scoop2]
		jr	nz,.aok
		ld	c,a
		ld	a,[b1_floundersub]
		or	c
.aok:		jp	phaseb1flashing
.maybemlock:	push	bc
		call	CountBalls
		pop	bc
		cp	2
		ld	a,0
		jr	c,.aok
		inc	a
		jr	.aok

phaseb1grotto:
		ld	e,B1_GROTTO
		ld	a,[any_mlock2]
		or	a
		jr	nz,.nomlock
		ld	a,[any_table]
		cp	TABLEGAME_STORM
		jr	z,.maybemlock
		cp	TABLEGAME_URSULA
		jr	nz,.nomlock
.maybemlock:	push	bc
		call	CountBalls
		pop	bc
		cp	2
		jr	c,.nomlock
		ld	a,1
		jr	.aok
.nomlock:	ld	a,[b1_awardready]
		or	a
		jr	nz,.aok
		ld	a,[b1_scoop4]
		or	a
		jr	nz,.aok
		ld	a,[any_table]
		or	a
		ld	a,0
		jr	nz,.aok
		ld	a,[b1_kisssub]
.aok:		or	a
		jr	nz,.norm
		ld	d,1
		ld	a,[any_mlock2]
		or	a
		jp	nz,newstate
.norm:		jp	phaseb1flashing

phaseb1smallloop:
		ld	c,1
		ld	a,[any_combo1]
		cp	4
		jr	z,.cok
		ld	a,[any_combo2]
		cp	1
		jr	z,.cok
		dec	c
.cok:
		ld	a,[b1_smallloop]
		or	c
		ld	e,B1_SMALLLOOP
		jp	phaseb1flashing
phaseb1leftloop:
		ld	c,1
		ld	a,[any_combo1]
		cp	3
		jr	z,.cok
		dec	c
.cok:
		ld	a,[b1_leftloop]
		or	c
		ld	e,B1_LEFTLOOP
		jp	phaseb1flashing
phaseb1rightloop:
		ld	c,1
		ld	a,[any_combo2]
		cp	2
		jr	z,.cok
		dec	c
.cok:
		ld	a,[b1_rightloop]
		or	c
		ld	e,B1_RIGHTLOOP
		jr	phaseb1flashing
phaseb1innerloop:
		ld	c,1
		ld	a,[any_inmulti]
		or	a
		jr	z,.notmulti
		ld	a,[any_1234]
		cp	3
		jr	nz,.notmulti
		ld	c,2
		ld	a,c
		jr	.done
.notmulti:	ld	a,[any_combo1]
		cp	1
		jr	z,.cok2
		ld	a,[any_combo2]
		cp	4
		jr	z,.cok2
		ld	a,[any_combo3]
		cp	1
		jr	z,.cok2
		dec	c
.cok2:
		ld	a,[any_table]
		cp	TABLEGAME_SHARK
		jr	nz,.cok
		inc	c
.cok:		ld	a,[b1_innerloop]
		or	c
		ld	c,1
.done:		ld	e,B1_INNERLOOP
		jr	phaseb1flashing2

phaseb1ramp:
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
.cok:		ld	a,[b1_ramp]
		or	c
		ld	e,B1_RAMP
phaseb1flashing:
		ld	c,1
phaseb1flashing2:
		ld	d,0
		bit	5,b
		jr	z,.dok
		or	a
		jr	z,.dok
		ld	d,c
.dok:		jp	newstate

phaseb1jackpot:
		ld	e,B1_JACKPOT
		ld	a,[any_inmulti]
		or	a
		jr	z,.aok
		ld	a,[any_1234]
		cp	3
		ld	a,0
		jr	nc,.aok
		inc	a
.aok:		jr	phaseb1flashing


phaseb1locklight:
		ld	de,0
		ld	a,[any_table]
		or	a
		jr	nz,.noince
		ld	a,[b1_locked]
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
.dok:		ld	e,B1_LOCK
		jp	newstate

phaseb1extrasaver:
		ld	c,0
		ld	a,[any_ballsaver]
		cp	3
		jr	c,.nosaver
		ld	d,2
		cp	5
		jr	nc,.dok
		bit	4,b
		jr	z,.dok
		ld	d,c
		jr	.dok
.nosaver:	ld	d,c
.dok:		ld	e,B1_EBSAVER
		jp	newstate

b1tableprocess:	ld	a,[any_table]
		or	a
		ret	z
		dec	a
		add	a
		add	LOW(b1tableprocesses)
		ld	l,a
		ld	a,0
		adc	HIGH(b1tableprocesses)
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
b1dummytable:	ret

b1tableprocesses:
		dw	b1dummytable
		dw	b1caveprocess
		dw	b1sharkprocess
		dw	b1kissprocess
		dw	b1dummytable
		dw	b1flotsamprocess
		dw	b1treasureprocess
		dw	b1scuttleprocess
		dw	b1stormprocess
		dw	b1ursulaprocess
		dw	b1happyprocess

b1ursulafire:
		ld	de,E3X
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b1_ursulafire
		dec	[hl]
		ret	z
b1triggerursula:
		ld	de,b1ursulafire
		ld	a,60
		jp	addtimed


b1happyprocess:
		ret
b1ursulaprocess:
		ret
b1stormprocess:
		ret
b1flotsamprocess:
		ret

b1sharkmsglist:
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

b1sharkprocess:
		call	CountBalls
		or	a
		jp	z,b1endtable
		ld	c,0
		ld	hl,b1_sharkadd
		ld	a,[hl]
		or	a
		jr	z,.cok
		dec	[hl]
		inc	c
.cok:		ld	hl,b1_sharkdist
		ld	a,[hl]
		add	c
		ld	[hl],a
		cp	110
		jr	nc,.sharkwon
		ld	a,c
		or	a
		jr	nz,.nodec
		ld	a,[b1_seconds]
		or	a
		ret	nz
;		ld	a,[wTime]
;		and	$7f
;		ret	nz
		dec	[hl]
		jp	z,b1endtable
.nodec:		ld	a,[hl]
		call	b1sharkshow
		ld	a,[b1_sharkdist]
		ld	bc,$5ff
.div5:		inc	c
		sub	b
		ret	c
		jr	nz,.div5
		ld	b,0
		ld	hl,b1sharkmsglist
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	statusflash
		ld	hl,MSGSHARK
		jp	statusflash

.sharkwon:	ld	a,1
		ld	[b1_floundersub],a
;		ld	a,SUBGAME_FLOUNDER
;		call	unlocksub
		ld	de,score50m
		call	addscore
		call	b1sublit
		ld	hl,MSGSHARKWON
		call	statusflash
		jp	b1quietend
b1sharkshow:
		cp	105
		jr	c,.aok
		ld	a,105
.aok:		ld	c,a
		ld	b,0
		ld	hl,b1sharkmap
		add	hl,bc
		ld	a,[hl]
		add	TV_SHARK
		jp	b1keeptv

b1sublit:	ld	a,7
		jp	b1showtv


b1sharkmap:	db	0,0,0,0,0
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



b1kissmsglist:
		dw	MSG5M
		dw	MSG10M
		dw	MSG15M
		dw	MSG20M
		dw	MSG25M
b1kissprocess:
		ld	a,[wTime]
		and	$7f
		ret	nz
		ld	hl,b1_kisstime
		dec	[hl]
		jr	z,.endkiss
		ld	a,[hl]
		ld	bc,$5ff
.even5:		inc	c
		sub	b
		ret	c
		jr	nz,.even5
		ld	b,0
		push	bc
		ld	a,TV_KISS+5
		sub	c
		call	b1keeptv
		pop	bc
		ld	hl,b1kissmsglist
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	statusflash
		ld	hl,MSGKISS
		jp	statusflash
.endkiss:	ld	a,1
		ld	[b1_kisstime],a
		ld	a,TV_KISS+6
		call	b1keeptv
		jr	b1endtable

b1scuttleprocess:
b1treasureprocess:
b1caveprocess:
		ld	a,[any_tabletime]
		or	a
		jr	z,.endwithfx
		call	CountBalls
		or	a
		ret	nz
		jr	b1endtable
.endwithfx:	ld	a,FX_LOSETABLE
		call	InitSfx
		jr	b1endtable

b1endtable:	xor	a
		ld	[wMzShift],a
		ld	a,[any_table]
		or	a
		ret	z
		cp	TABLEGAME_CAVE
		jr	z,.caveend
		cp	TABLEGAME_SHARK
		jr	z,.sharkend
		cp	TABLEGAME_FLOTSAM
		jr	z,.flotsamend
		cp	TABLEGAME_TREASURE
		jr	z,.treasureend
		cp	TABLEGAME_KISS
		jr	z,.kissend
		cp	TABLEGAME_SCUTTLE
		jr	z,.scuttleend
		cp	TABLEGAME_STORM
		jr	z,.stormend
		cp	TABLEGAME_URSULA
		jr	z,.ursulaend
		jr	b1quietend
.treasureend:
		xor	a
		ld	[b1_ramp],a
		ld	[b1_innerloop],a
		ld	[b1_leftloop],a
		ld	[b1_rightloop],a
		ld	[b1_smallloop],a
		ld	hl,MSGTREASUREOVER
		jr	.anyend
.flotsamend:	ld	hl,MSGFLOTSAMOVER
		jr	.anyend
.stormend:	ld	a,15
		call	board1popups
		ld	hl,MSGSTORMOVER
		jr	.anyend
.kissend:	xor	a
		ld	[b1_rightloop],a
		ld	a,[b1_kisstime]
		or	a
		jr	z,b1quietend
		ld	hl,MSGKISSOVER
		jr	.anyend
.caveend:
		xor	a
		ld	hl,b1_scoop1
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ld	a,[b1_cavesub]
		or	a
		jr	nz,b1quietend
		ld	hl,MSGCAVELOST
		jr	.anyend
.scuttleend:	ld	hl,MSGSCUTTLEOVER
		jr	.anyend
.sharkend:	ld	hl,MSGSHARKLOST
		jr	.anyend
.ursulaend:	ld	hl,MSGURSULAOVER
		jr	.anyend

.anyend:	call	statusflash
b1quietend:
		ld	a,SONG_TABLE1
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
.ok:		jp	b1finishedmode



b1close:	ld	a,1
board1gate:
		ld	[b1_gate],a
		or	a
		jr	nz,.b1close
.b1open:	ld	de,B1_ENTRANCE
		jp	newstate
.b1close:	ld	de,(1<<8)|B1_ENTRANCE
		jp	newstate

b1showlockopen:
		ld	a,FX_LOCKOPEN
		call	InitSfx
;		ld	hl,MSGLOCKOPEN
;		call	statusflash
		ld	a,5
		jp	b1showtv

b1advancebonus:
		ld	a,[b1_bonus]
		cp	25
		jp	z,dorelit
		ld	a,17
		call	b1showtv
;		ld	hl,MSGBONUSP1
;		call	statusflash
		ld	a,[b1_bonus]
		inc	a
board1bonus:	cp	25
		jr	z,.to25
		jr	c,.less25
		ret
.to25:		ld	a,[b1_bonus]
		cp	25
		jr	z,.less25
		ld	a,[any_to25]
		or	a
		jr	nz,.noextra
		inc	a
		ld	[any_to25],a
		call	b1doextraopen
.noextra:	ld	a,25
.less25:
		ld	[b1_bonus],a
		or	a
		jr	z,.bonus0
		push	af
		ld	de,$012f
		call	newstate
		pop	af
		ld	d,0
.mod10:		inc	d
		sub	10
		jr	nc,.mod10
		add	10
		push	de
		inc	a
		ld	d,a
		ld	e,48
		call	newstate
		pop	de
		ld	e,49
		jp	newstate
.bonus0:	ld	de,$002f
		call	newstate
		ld	de,$0030
		call	newstate
		ld	de,$0031
		jp	newstate

board1toplanes:	ld	[b1_toplanes],a
board1topshow:	rrca
		push	af
		ld	a,0
		adc	a
		ld	d,a
		ld	e,B1_RIGHTLANE
		call	newstate
		pop	af
		rrca
		ld	a,0
		adc	a
		ld	d,a
		ld	e,B1_LEFTLANE
		jp	newstate

;a=value to display
board1popups:	push	af
		call	board1popupoff
		pop	af
		ld	[b1_popupstate],a
		ld	e,a
		ld	d,0
		ld	hl,IDX_FLIPS018CHG
		add	hl,de
		or	a
		call	nz,MakeChanges
		ld	a,[b1_popupstate]
		ld	e,B1_D
		call	statebit
		ld	e,B1_C
		call	statebit
		ld	e,B1_B
		call	statebit
		ld	e,B1_A
		call	statebit
		ld	a,[b1_popupstate]
		cpl
board1popshow:	ld	e,B1_DLIGHT
		call	statebit
		ld	e,B1_CLIGHT
		call	statebit
		ld	e,B1_BLIGHT
		call	statebit
		ld	e,B1_ALIGHT
		jp	statebit
board1popupoff:	ld	a,[b1_popupstate]
		or	a
		ret	z
		ld	e,a
		ld	d,0
		ld	hl,IDX_FLIPS018CHG
		add	hl,de
		jp	UndoChanges

		
board1sea:	ld	[b1_seastate],a
board1seashow:	ld	e,B1_SEA1
		rrca
		push	af
		call	.seastate
		ld	e,B1_SEA2
		pop	af
		rrca
		push	af
		call	.seastate
		ld	e,B1_SEA3
		pop	af
		rrca
.seastate:	ld	d,0
		jr	nc,.dok
		inc	d
.dok:		jp	newstate


board1kickback:
		push	af
		ld	a,[b1_kickback]
		or	a
		ld	hl,IDX_FLIPS017CHG
		call	nz,UndoChanges
		pop	af
		ld	[b1_kickback],a
		or	a
		ld	hl,IDX_FLIPS017CHG
		call	nz,MakeChanges
		ld	a,[b1_kickback]
		ld	d,a
		ld	e,B1_KICKBACK
		jp	newstate


board1award:	ld	b,a
		ld	a,[b1_award]
		cp	b
		ret	z
		ld	a,b
		ld	[b1_award],a
board1awardshow:
		ld	e,B1_AWARD5
		call	statebit
		ld	e,B1_AWARD4
		call	statebit
		ld	e,B1_AWARD3
		call	statebit
		ld	e,B1_AWARD2
		call	statebit
		ld	e,B1_AWARD1
statebit:	rrca
		push	af
		ld	d,0
		jr	nc,.dok
		inc	d
.dok:		call	newstate
		pop	af
		ret

board1ariel:	ld	b,a
		ld	a,[b1_ariel]
		cp	b
		ret	z
		ld	a,b
board1arielforce:
		ld	[b1_ariel],a
board1arielshow:
		ld	e,B1_ARIEL5
		call	statebit
		ld	e,B1_ARIEL4
		call	statebit
		ld	e,B1_ARIEL3
		call	statebit
		ld	e,B1_ARIEL2
		call	statebit
		ld	e,B1_ARIEL1
		jr	statebit
;e=state #
;d=new value
newstate:	ld	a,d
		ld	d,0
		ld	hl,wStates
		add	hl,de
		cp	[hl]
		ret	z
		ld	[hl],a
		ld	hl,statestarts
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
		ld	de,statelist
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

B1_ENTRANCE	EQU	0
B1_LEFTLANE	EQU	1
B1_RIGHTLANE	EQU	2
B1_PINK		EQU	3
B1_ORANGE	EQU	4
B1_PURPLE	EQU	5
B1_A		EQU	6
B1_B		EQU	7
B1_C		EQU	8
B1_D		EQU	9
B1_ALIGHT	EQU	10
B1_BLIGHT	EQU	11
B1_CLIGHT	EQU	12
B1_DLIGHT	EQU	13
B1_URSULA	EQU	14
B1_ARIEL1	EQU	15
B1_ARIEL2	EQU	16
B1_ARIEL3	EQU	17
B1_ARIEL4	EQU	18
B1_ARIEL5	EQU	19
B1_WRECK	EQU	20
B1_RAMP		EQU	21
B1_LEFTLOOP	EQU	22
B1_JACKPOT	EQU	23
B1_RIGHTLOOP	EQU	24
B1_SEA1		EQU	25
B1_SEA2		EQU	26
B1_SEA3		EQU	27
B1_SMALLLOOP	EQU	28
B1_FLOUNDER	EQU	29
B1_GROTTO	EQU	30
B1_MODES	EQU	31
B1_AWARD1	EQU	40
B1_AWARD2	EQU	41
B1_AWARD3	EQU	42
B1_AWARD4	EQU	43
B1_AWARD5	EQU	44
B1_KICKBACK	EQU	45
B1_KICKLIGHT	EQU	46
B1_EBSAVER	EQU	50
B1_INNERLOOP	EQU	51
B1_LOCK		EQU	52
B1_LEFTBUMPER	EQU	53
B1_RIGHTBUMPER	EQU	54
B1_FLOUNDERBOD	EQU	55
B1_URSULALOOK	EQU	56

statestarts:	db	0	;0,seaweed gate
		db	2	;1,left x
		db	4	;2,right x
		db	6	;3,pink popper
		db	8	;4,orange popper
		db	10	;5,purple popper
		db	12	;6,drop a
		db	14	;7,drop b
		db	16	;8,drop c
		db	18	;9,drop d
		db	20	;10,k
		db	22	;11,i
		db	24	;12,s
		db	26	;13,s
		db	28	;14,ursula's light
		db	30	;15,a
		db	32	;16,r
		db	34	;17,i
		db	36	;18,e
		db	38	;19,l
		db	40	;20,wreck
		db	42	;21,ramp
		db	44	;22,left loop
		db	46	;23,jackpot
		db	48	;24,right loop
		db	50	;25,s
		db	52	;26,e
		db	54	;27,a
		db	56	;28,small loop
		db	58	;29,flounder
		db	60	;30,grotto
		db	62	;31,mode a
		db	64	;32,mode b
		db	66	;33,mode c
		db	68	;34,mode d
		db	70	;35,mode e
		db	72	;36,mode f
		db	74	;37,mode g
		db	76	;38,mode h
		db	78	;39,mode i
		db	80	;40,a
		db	82	;41,w
		db	84	;42,a
		db	86	;43,r
		db	88	;44,d
		db	90	;45,kickback gate
		db	92	;46,kickback light
		db	94	;47,bonus top part
		db	96	;48,bonus 1's digit
		db	107	;49,bonus 10's digit
		db	111	;50,eb/saver
		db	114	;51,inner loop
		db	117	;52,eb lit
		db	120	;53,left bumper
		db	122	;54,right bumper
		db	124	;55,flounder
		db	126	;56,ursula

;xsize,ysize,xsrc,ysrc,xdest,ydest
statelist:	db	10,12,10,0,12,0	;0,Seaweed gate 0
		db	10,12,0,0,12,0	;1,Seaweed gate 1
		db	1,1,21,0,9,2	;2,Left X light 0
		db	1,1,20,0,9,2	;3,Left X light 1
		db	1,1,21,0,11,2	;4,Right X light 0
		db	1,1,20,0,11,2	;5,Right X light 1
		db	4,5,4,12,9,5	;6,Pink popper 0
		db	4,5,0,12,9,5	;7,Pink popper 1
		db	4,4,8,17,12,7	;8,Orange popper 0
		db	4,4,8,13,12,7	;9,Orange popper 1
		db	1,1,13,20,8,11	;10,Purple popper 0
		db	1,1,12,20,8,11	;11,Purple popper 1
		db	2,2,2,34,6,16	;12,Drop A 0
		db	2,2,0,34,6,16	;13,Drop A 1
		db	2,1,6,34,8,16	;14,Drop B 0
		db	2,1,4,34,8,16	;15,Drop B 1
		db	2,1,10,34,10,15	;16,Drop C 0
		db	2,1,8,34,10,15	;17,Drop C 1
		db	2,1,14,34,12,14	;18,Drop D 0
		db	2,1,12,34,12,14	;19,Drop D 1
		db	1,1,23,0,7,18	;20,K 0
		db	1,1,22,0,7,18	;21,K 1
		db	1,1,21,1,9,17	;22,I 0
		db	1,1,20,1,9,17	;23,I 1
		db	1,1,23,1,11,16	;24,S 0
		db	1,1,22,1,11,16	;25,S 1
		db	1,1,23,1,13,15	;26,S 0
		db	1,1,22,1,13,15	;27,S 1
		db	2,2,8,21,8,20	;28,Ursula's light 0
		db	2,2,6,21,8,20	;29,Ursula's light 1
		db	2,1,22,2,10,20	;30,A 0
		db	2,1,20,2,10,20	;31,A 1
		db	1,2,21,3,13,21	;32,R 0
		db	1,2,20,3,13,21	;33,R 1
		db	2,2,22,5,15,22	;34,I 0
		db	2,2,20,5,15,22	;35,I 1
		db	1,1,21,7,19,27	;36,E 0
		db	1,1,20,7,19,27	;37,E 1
		db	1,2,23,7,19,28	;38,L 0
		db	1,2,22,7,19,28	;39,L 1
		db	2,2,12,21,11,21	;40,Wreck light 0
		db	2,2,10,21,11,21	;41,Wreck light 1
		db	1,2,15,21,14,22	;42,Ramp light 0
		db	1,2,14,21,14,22	;43,Ramp light 1
		db	2,2,18,21,7,23	;44,Left loop light 0
		db	2,2,16,21,7,23	;45,Left loop light 1
		db	2,2,8,23,13,24	;46,Jackpot light 0
		db	2,2,6,23,13,24	;47,Jackpot light 1
		db	2,2,12,23,15,25	;48,Right loop light 0
		db	2,2,10,23,15,25	;49,Right loop light 1
		db	1,2,21,9,5,23	;50,S 0
		db	1,2,20,9,5,23	;51,S 1
		db	1,2,23,9,6,24	;52,E 0
		db	1,2,22,9,6,24	;53,E 1
		db	1,2,23,11,7,25	;54,A 0
		db	1,2,22,11,7,25	;55,A 1
		db	2,2,20,23,6,27	;56,Small loop light 0
		db	2,2,18,23,6,27	;57,Small loop light 1
		db	2,2,22,21,4,29	;58,Flounder light 0
		db	2,2,20,21,4,29	;59,Flounder light 1
		db	2,2,16,23,15,27	;60,Grotto light 0
		db	2,2,14,23,15,27	;61,Grotto light 1
		db	2,2,2,25,9,27	;62,Mode light A 0
		db	2,2,0,25,9,27	;63,Mode light A 1
		db	2,2,6,25,11,27	;64,Mode light B 0
		db	2,2,4,25,11,27	;65,Mode light B 1
		db	2,2,10,25,13,27	;66,Mode light C 0
		db	2,2,8,25,13,27	;67,Mode light C 1
		db	2,2,22,25,13,29	;72,Mode light F 0
		db	2,2,20,25,13,29	;73,Mode light F 1
		db	2,2,10,27,13,31	;78,Mode light I 0
		db	2,2,8,27,13,31	;79,Mode light I 1
		db	2,2,6,27,11,31	;76,Mode light H 0
		db	2,2,4,27,11,31	;77,Mode light H 1
		db	2,2,2,27,9,31	;74,Mode light G 0
		db	2,2,0,27,9,31	;75,Mode light G 1
		db	2,2,14,25,9,29	;68,Mode light D 0
		db	2,2,12,25,9,29	;69,Mode light D 1
		db	2,2,18,25,11,29	;70,Mode light E 0
		db	2,2,16,25,11,29	;71,Mode light E 1
		db	2,1,10,31,1,31	;80,A 0
		db	2,1,8,31,1,31	;81,A 1
		db	2,1,14,31,3,31	;82,W 0
		db	2,1,12,31,3,31	;83,W 1
		db	2,1,10,32,5,31	;84,A 0
		db	2,1,8,32,5,31	;85,A 1
		db	2,1,14,32,17,31	;86,R 0
		db	2,1,12,32,17,31	;87,R 1
		db	2,1,10,33,19,31	;88,D 0
		db	2,1,8,33,19,31	;89,D 1
		db	4,4,4,17,17,35	;90,Kickback gate 0
		db	4,4,0,17,17,35	;91,Kickback gate 1
		db	2,1,18,31,19,35	;92,Kickback light 0
		db	2,1,16,31,19,35	;93,Kickback light 1
		db	4,1,4,31,10,33	;94,Bonus top half off
		db	4,1,0,31,10,33	;95,Bonus top half on
		db	2,2,6,32,12,34	;96,Bonus off 0 digit
		db	2,2,0,29,12,34	;97,Bonus 0 digit
		db	2,2,2,29,12,34	;98,Bonus 1 digit
		db	2,2,4,29,12,34	;99,Bonus 2 digit
		db	2,2,6,29,12,34	;100,Bonus 3 digit
		db	2,2,8,29,12,34	;101,Bonus 4 digit
		db	2,2,10,29,12,34	;102,Bonus 5 digit
		db	2,2,12,29,12,34	;103,Bonus 6 digit
		db	2,2,14,29,12,34	;104,Bonus 7 digit
		db	2,2,16,29,12,34	;105,Bonus 8 digit
		db	2,2,18,29,12,34	;106,Bonus 9 digit
		db	2,2,4,32,10,34	;107,Bonus off 10 digit
		db	2,2,0,32,10,34	;108,Bonus 00 digit
		db	2,2,20,29,10,34	;109,Bonus 10 digit
		db	2,2,22,29,10,34	;110,Bonus 20 digit
		db	2,3,21,37,11,36	;111,EB / Saver light 0
		db	2,3,21,31,11,36	;112,EB / Saver light 1
		db	2,3,21,34,11,36	;113,EB / Saver light 2
		db	2,2,4,21,4,19	;114,Inner loop light 0
		db	2,2,0,21,4,19	;115,Inner loop light 1
		db	2,2,2,21,4,19	;116,Inner loop light 2
		db	2,2,4,23,10,24	;117,EB lit / Lock light 0
		db	2,2,0,23,10,24	;118,EB lit / Lock light 1
		db	2,2,2,23,10,24	;119,EB lit / Lock light 2
		db	4,6,0,36,5,30	;120,left bumper off
		db	4,6,4,36,5,30	;121,left bumper on
		db	4,6,8,36,14,30	;122,right bumper off
		db	4,6,12,36,14,30	;123,right bumper on
		db	5,5,16,37,1,24	;124,flounder 0
		db	5,5,16,32,1,24	;125,flounder 1
		db	5,6,12,12,0,0	;126,ursula 0
		db	5,6,17,12,0,0	;127,ursula 1

mainboardfirst::
		xor	a
		ld	[wHappyMode],a
		ld	[wStartHappy],a
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]

		ld	a,3
		ld	[any_nextextra],a	;loop count for next extra ball

		ld	a,0
; ld a,$ff ;DEBUG
		ld	[b1_completed],a

		ld	a,0
		ld	[any_wantfire],a
		ld	a,[wNumBalls]
		ld	[any_ballsleft],a

		call	random
		and	7
		inc	a
		ld	[b1_litgame],a
		call	b1switchmode

		ld	a,15
		ld	[b1_popupstate],a
		xor	a
		ld	[b1_seastate],a
		ld	a,1
		ld	[b1_kickback],a
		ld	a,1
		ld	[b1_bonus],a
		xor	a
		ld	[b1_award],a
		xor	a
		ld	[b1_toplanes],a
		xor	a
; ld a,$1f ;DEBUG
		ld	[b1_ariel],a

		xor	a
		ld	[b1_gate],a
		xor	a
; ld a,2 ;DEBUG
; ld [b1_locked],a ;DEBUG
		ld	[b1_trapped],a	;# of trapped balls (for multiball)

		ld	hl,wScore
		ld	bc,16
		call	MemClear

		ld	a,10
		ld	[b1_stormjack],a
		ld	[b1_2balljack],a
		ld	a,20
		ld	[b1_ursulajack],a
		ld	[b1_happyjack],a

		ld	a,5
		ld	[any_clock+3],a

		call	InitBalls

		ld	a,MINFLIPPER
		ldh	[pin_lflipper],a
		ldh	[pin_rflipper],a

		call	PlayerReport

		ret



mainboardinit::

		ld	hl,board1info
		call	SetPinInfo

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_SPINNER
		call	AddPalette
		ld	hl,PAL_SPINNERB
		call	AddPalette
		ld	hl,PAL_TRIDENT
		call	AddPalette
		ld	hl,PAL_REDFLIP
		call	AddPalette

		ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_FLIPS000PMP
		ld	de,$d000
		call	SwdInFileSys
		ld	a,WRKBANK_PINMAP2
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_L2PMP
		ld	de,$d000
		call	SwdInFileSys
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	hl,IDX_FLIPS018CHG	;close off entrance
		call	MakeChanges

		ld	hl,board1maplist
		call	NewLoadMap
		ld	hl,IDX_LIGHTS1MAP
		call	SecondHalf
		ld	hl,IDX_TV1MAP
		ld	a,[bLanguage]
		ld	e,a
		ld	d,0
		add	hl,de
		call	OtherPage

		call	b1restore

 xor	a
 call	b1showtv	;DEBUG

		ld	hl,board1chances
		ldh	a,[pin_difficulty]
		or	a
		jr	nz,.hlok
		ld	hl,board1chanceseasy
.hlok:
		ld	de,any_chances
		call	chanceinit

		ld	hl,board1collisions
		jp	MakeCollisions

b1restore:
		ld	hl,wStates
		ld	bc,64
		call	MemClear

b1restoreq:
	ld	a,[b1_popupstate]
	call	board1popups
	ld	a,[b1_seastate]
	call	board1sea
	ld	a,[b1_kickback]
	call	board1kickback
	ld	a,[b1_kickback]
	ld	d,a
	ld	e,B1_KICKLIGHT
	call	newstate
	ld	a,[b1_bonus]
	call	board1bonus
	ld	a,[b1_award]
	call	board1awardshow
	ld	a,[b1_toplanes]
	call	board1toplanes
	ld	a,[b1_ariel]
	call	board1arielforce
	ld	a,[b1_gate]
	call	board1gate
	ret


b1keeptv:	ld	c,a
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
b1forcekeeptv:	ld	[any_tvback],a
		call	TVSet
		xor	a
		jr	b1anytv
b1showtv:	ld	c,a
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
		jr	z,b1tvpop
		ld	a,1
		ld	a,[any_tvhold],a
		ret
b1tvpop:	ld	a,[any_tvsp]
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
b1anytv:	ld	[any_tvhold],a
		ld	hl,wStates+B1_MODES
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

phaseb1indicatorcenter:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		ld	a,[any_tvback]
		or	a
		ret	nz
		ld	e,B1_MODES+8
		ld	a,[any_gothappy]
		ld	d,a
		jp	newstate
phaseb1indicator0:
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
;		jp	b1showtv
;.not123:
		ld	a,[any_tvsp]
		or	a
		jp	nz,b1tvpop
		ld	a,[any_tvback]
		or	a
		jp	nz,b1forcekeeptv
.nohold:	ld	c,1
		jr	b1indicators
phaseb1indicator1:
		ld	c,2
		jr	b1indicators
phaseb1indicator2:
		ld	c,3
		jr	b1indicators
phaseb1indicator3:
		ld	c,4
		jr	b1indicators
phaseb1indicator4:
		ld	c,5
		jr	b1indicators
phaseb1indicator5:
		ld	c,6
		jr	b1indicators
phaseb1indicator6:
		ld	c,7
		jr	b1indicators
phaseb1indicator7:
		ld	c,8

;c=# of indicator to process
b1indicators:
		ld	a,[any_tvhold]
		or	a
		ret	nz
		ld	a,[any_tvback]
		or	a
		ret	nz
		ld	a,c
		add	B1_MODES-1
		ld	e,a
		ld	b,0
		ld	d,b
		ld	hl,Bits-1
		add	hl,bc
		ld	a,[b1_litgame]
		cp	c
		ld	a,[b1_completed]
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
.noflash:	jp	newstate


b1finishedmode:

		ld	hl,any_inmulti
		ld	a,[hl]
		or	a
		jr	z,.notmulti
		ld	[hl],0
		cp	TABLEGAME_STORM
		ret	z
.notmulti:
		ld	a,[b1_litgame]
		or	a
		jr	nz,.normalfinish
		ld	a,[b1_completed]
		inc	a
		ret	z
		call	random
		and	7
		inc	a
		ld	[b1_litgame],a
		jp	b1switchmode

.normalfinish:
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,Bits
		add	hl,bc
		ld	a,[hl]
		ld	hl,b1_completed
		or	[hl]
		ld	[hl],a
		cp	$ff
		jr	nz,b1switchmode
		xor	a
		ld	[hl],a
		ld	[b1_litgame],a
		jp	b1startursula
b1switchmode:	ld	a,[any_table]
		or	a
		ret	nz
		ld	a,[b1_litgame]
		or	a
		ret	z
		dec	a
		ld	c,a
		ld	b,0
		ld	hl,Bits
		add	hl,bc
		ld	b,[hl]
		ld	a,[b1_completed]
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
.isff:		ld	[b1_litgame],a
		ret

enterramp:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	124-20*2
		ld	d,a

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		sub	164-20
		add	a
		sub	d
		ld	c,0
		jr	nc,.down
		inc	c
.down:
		ldh	a,[pin_ballflags]
		and	$fe
		or	c
		ldh	[pin_ballflags],a
		jp	setramp
exitramp:	ld	h,0
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
		call	b1ramp
		ld	de,rampscore
		call	addscoreh
		xor	a
		call	setramp
		ld	c,CODE_RAMP
		ld	hl,b1_ramp
		call	b1didloopramp
		ld	a,[any_1234]
		cp	3
		jr	z,.normalramp
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalramp
		cp	TABLEGAME_STORM
		jp	z,b1stormjackpot
		cp	TABLEGAME_FLOTSAM
		jp	z,b1flotsamjackpot
		cp	TABLEGAME_URSULA
		jp	z,b1ursulajackpot
		cp	TABLEGAME_HAPPY
		jp	z,b1happyjackpot
.normalramp:	ret
;		ld	hl,MSGLOOP3
;		jp	statusflash
b1firedown:	ld	hl,pin_ballflags
		res	BALLFLG_LAYER,[hl]
		ret

B1RAMPTIME	EQU	90

b1rampxlist:	dw	MSGRAMP1X
		dw	MSGRAMP2X
		dw	MSGRAMP4X

b1ramp:		ld	hl,any_rampfast
		ld	a,[hl]
		ld	e,a
		inc	a
		cp	3
		jr	nz,.tooslow
		dec	a
.tooslow:	ld	[hl],a
		ld	d,0
		ld	hl,b1rampxlist
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
.bok:		ld	a,[b1_rampcount]
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
		call	b1advancebonus
		pop	bc
		jr	.next
.nobonus:	dec	a
		jr	nz,.nohold
		push	bc
		call	b1showmultheld
		pop	bc
		jr	.next
.nohold:	push	bc
		call	b1doextraopen
		pop	bc
		jr	.next
.something:	push	bc
		call	statusflash
		pop	bc
.next:		dec	b
		jr	nz,.rampcredits
		ld	a,c
		ld	[b1_rampcount],a
		ret

b1advancetvback:
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
		pop	af
		ld	hl,MSG1000M
		call	statusflash
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
		call	b1showtv
		pop	af
		jp	b1keeptv

b1ursulajackpot:
		ld	c,TV_URSULA+5
		call	b1advancetvback

		ld	a,[any_1234]
		cp	3
		jr	nz,.nosub
		ld	a,[b1_ursulasub]
		or	a
		jr	nz,.nosub
		ld	hl,MSGURSULALOCK
		call	statusflash
		ld	a,1
		ld	[b1_ursulasub],a
;		ld	a,SUBGAME_URSULA
;		call	unlocksub
		call	b1sublit
.nosub:		ld	hl,b1_ursulajack
		ld	e,[hl]
		ld	[hl],20
		jr	b1jackpot

b1happyjackpot:
		ld	c,TV_HAPPY+10
		call	b1advancetvback
		ld	hl,b1_happyjack
		ld	e,[hl]
		ld	[hl],20
		jr	b1jackpot

b1flotsamjackpot:
		ld	c,TV_FLOTSAM+3
		call	b1advancetvback

		ld	a,[any_1234]
		cp	1
		jr	nz,.nosub
		ld	a,[b1_flotsamsub]
		or	a
		jr	nz,.nosub
		ld	hl,MSGFLOTSAMLOCK
		call	statusflash
		ld	a,1
		ld	[b1_flotsamsub],a
;		ld	a,SUBGAME_FLOTSAM
;		call	unlocksub
		call	b1sublit
.nosub:		ld	a,[b1_2balljack]
		ld	e,a
		ld	a,10
		ld	[b1_2balljack],a
		jr	b1jackpot

b1stormjackpot:
		ld	c,TV_STORM+4
		call	b1advancetvback

		ld	a,[any_1234]
		cp	2
		jr	nz,.nosub
		ld	a,[b1_stormsub]
		or	a
		jr	nz,.nosub
.h:		ld	hl,MSGSTORMLOCK
		call	statusflash
		ld	a,1
		ld	[b1_stormsub],a
		call	b1sublit
.nosub:		ld	a,[b1_stormjack]
		ld	e,a
		ld	a,10
		ld	[b1_stormjack],a

;e=value to add (in millions)
b1jackpot:	ld	a,1
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
;		ld	a,[any_mlock1]
;		ld	b,a
;		ld	a,[any_mlock2]
;		add	b
		xor	a
		ld	[hl],a
.mok:		ret

entertop:	ld	de,E1X
		ld	bc,E1Y
		ld	h,E1VX
		ld	l,E1VY
		jr	traps
enterleft:	ld	de,E2X
		ld	bc,E2Y
		ld	h,E2VX
		ld	l,E2VY
		jr	traps
entercenter:	ld	de,E3X
		ld	bc,E3Y
		ld	h,E3VX
		ld	l,E3VY
		jr	traps
enterright:	ld	de,E4X
		ld	bc,E4Y
		ld	h,E4VX
		ld	l,E4VY
traps:		push	de
		push	bc
		call	passedby
		pop	bc
		pop	de
		or	a
		ret	nz
		jp	Eject

b1award1lane:	ld	b,16
		jr	b1lanes
b1award2lane:	ld	b,8
		jr	b1lanes
b1award3lane:	ld	b,4
		jr	b1lanes
b1award4lane:	ld	b,2
		jr	b1lanes
b1award5lane:	ld	b,1
b1lanes:
		ld	a,[b1_awarddelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b1_awarddelay],a
		ld	a,[b1_award]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	$1f
		jr	nz,.notall
		ld	a,FX_AWARDLIT
		call	InitSfx
		xor	a
		ld	[b1_award],a
		ld	[b1_awardtimer],a
		ld	a,1
		ld	de,b1awardflash
		call	addtimed
		ld	a,[b1_awardready]
		or	a
		jr	z,.newaward
		call	dorelit
		jr	.delayed
.newaward:	ld	a,1
		ld	[b1_awardready],a
;		ld	hl,MSGAWARD
;		call	statusflash
		ld	a,22
		call	b1showtv
		jr	.delayed
.notall:	call	board1award
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
.delayed:	ret
b1topleft:	ld	b,2
		jr	b1toplanes
b1topright:	ld	b,1
b1toplanes:
		ld	a,[b1_topdelay]
		or	a
		jr	nz,.delayed
		ld	a,LANEDELAY
		ld	[b1_topdelay],a
		ld	a,[b1_toplanes]
		ld	c,a
		or	b
		cp	c
		ret	z
		cp	3
		jr	nz,.noincbonus
		xor	a
		ld	[b1_toplanes],a
		ld	[b1_toptimer],a
		ld	de,b1topflash
		ld	a,1
		call	addtimed
		ld	a,FX_MULTP1
		call	InitSfx
		jp	b1advancebonus
.noincbonus:	call	board1toplanes
		ld	de,scorerolloverunlit
		call	addscore
		ld	a,FX_LIGHTON
		call	InitSfx
;.nochange:

.delayed:	ret


b1outerenter:	ld	de,b1_outerenter
		call	saveclock
		ld	hl,b1_outerexit
		ld	a,B1OUTERTIME
		call	timelimit
		ret	nz
		call	loopcredit
		ld	c,CODE_RIGHTLOOP
		ld	hl,b1_rightloop
		jp	b1didloop

b1outerexit:	ld	de,b1_outerexit
		call	saveclock
		ld	hl,b1_outerenter
		ld	a,B1OUTERTIME
		call	timelimit
		ret	nz
		call	loopcredit
		ld	c,CODE_LEFTLOOP
		ld	hl,b1_leftloop
		jp	b1didloop


B1OUTERTIME	EQU	120
B1INNERTIME	EQU	120
B1SMALLTIME	EQU	60


b1smallenter:	ld	de,b1_smallenter
		jp	saveclock
b1smallexit:	ld	a,B1SMALLTIME
		ld	hl,b1_smallenter
		call	timelimit
		ret	nz
		call	loopcredit
		ld	hl,b1_2balljack
		ld	e,50
		call	incmax1
		ld	c,CODE_SMALLLOOP
		ld	hl,b1_smallloop
		jp	b1didloop

b1innerenter:	ld	de,b1_innerenter
		jp	saveclock

b1innerexit:	ld	hl,b1_innerenter
		ld	a,B1INNERTIME
		call	timelimit
		ret	nz
		call	loopcredit
		ld	a,[any_skill]
		or	a
		jr	z,.noskill
		xor	a
		ld	[any_skill],a
		ld	a,12
		call	b1showtv
		ld	hl,any_skillcount
		inc	[hl]
		ld	a,[hl]
		add	a
		add	a
		add	[hl]
		ld	l,a
		ld	h,0
		call	addmillionshl
		ld	hl,MSGJACKVALUE
		call	statusflash
.noskill:	ld	c,CODE_INNERLOOP
		ld	hl,b1_innerloop
		call	b1didloop
		ld	a,[any_1234]
		cp	3
		jr	nz,.normalinner
		ld	a,[any_inmulti]
		or	a
		jr	z,.normalinner
		cp	TABLEGAME_STORM
		jp	z,b1stormjackpot
		cp	TABLEGAME_FLOTSAM
		jp	z,b1flotsamjackpot
		cp	TABLEGAME_URSULA
		jp	z,b1ursulajackpot
		cp	TABLEGAME_HAPPY
		jp	z,b1happyjackpot
.normalinner:	ret
loopcredit:	ld	de,loopscore
		jp	addscoreh

b1didloop:
		xor	a
		ld	[any_rampfast],a
b1didloopramp:
		ld	a,COMBOCLEARTIME
		ld	[any_comboclear],a
		ld	a,c
		push	hl
		call	b1combocheck
		call	IncBonusVal
		pop	hl
		ld	a,[hl]
		or	a
		ret	z
		ld	[hl],0
		ld	a,FX_TABLEADVANCE
		call	InitSfx
		ld	a,[any_table]
		cp	TABLEGAME_TREASURE
		jr	nz,.nottreasure
		ld	hl,b1_smallloop
		xor	a
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
		add	TV_TREASURE+5+1
		call	b1keeptv
		pop	af
		jr	nz,.moretreasure
		ld	de,score50m
		call	addscore
		ld	a,1
		ld	[b1_treasuresub],a
;		ld	a,SUBGAME_TREASURE
;		call	unlocksub
		call	b1sublit
		call	b1endtable
		ld	hl,MSGTREASUREALL
		jp	statusflash
.moretreasure:
		ld	de,score5m
		call	addscore
		ld	hl,MSGMORETREASURE
		jp	statusflash
		
.nottreasure:	cp	TABLEGAME_KISS
		jr	nz,.notkiss
		ld	hl,MSGKISSED
		call	statusflash
		ld	a,[b1_kisstime]
		ld	l,a
		xor	a
		ld	h,a
		ld	[b1_kisstime],a
		call	addmillionshl
		ld	a,1
		ld	[b1_kisssub],a
;		ld	a,SUBGAME_KISS
;		call	unlocksub
		call	b1sublit
		jp	b1endtable

.notkiss:
		ret


msglooplist:	dw	MSG2LOOPS
		dw	MSG3LOOPS
		dw	MSG4LOOPS
		dw	MSG5LOOPS
		dw	MSG6LOOPS
		dw	MSG7LOOPS
		dw	MSG8LOOPS
		dw	MSG9LOOPS
		dw	MSGUNREAL


;a=new event
b1combocheck:
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
		ld	hl,msglooplist
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
		call	b1doextraopen
.nope:
		pop	bc
.nomessage:
		jr	.contloopcount
.clearloopcount:
		xor	a
		ld	[any_loopcount],a
.contloopcount:

		ld	d,0

		ld	hl,b1combo1
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
		ld	hl,b1combomsgs1
		call	flashlist
		call	IncBonusVal
		ld	a,[any_combo1]
		call	ComboSound
		pop	af
		call	b1comboscore
		pop	af
		cp	5
		jr	c,.good1
.fail1:		xor	a
.good1:		ld	[any_combo1],a

		ld	hl,b1combo2
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
		ld	hl,b1combomsgs2
		call	flashlist
		call	IncBonusVal
		ld	a,[any_combo2]
		call	ComboSound
		pop	af
		call	b1comboscore
		pop	af
		cp	5
		jr	c,.good2
.fail2:		xor	a
.good2:		ld	[any_combo2],a

		ret

b1combo1:	db	CODE_RIGHTLOOP
		db	CODE_INNERLOOP
		db	CODE_RAMP
		db	CODE_LEFTLOOP
		db	CODE_SMALLLOOP

b1combomsgs1:	dw	MSGCOMBO
		dw	MSGDOUBLECOMBO
		dw	MSGTRIPLECOMBO
		dw	MSGSUPERCOMBO

b1combo2:	db	CODE_LEFTLOOP
		db	CODE_SMALLLOOP
		db	CODE_RIGHTLOOP
		db	CODE_RAMP
		db	CODE_INNERLOOP

b1combomsgs2:	dw	MSGREVERSECOMBO
		dw	MSGREVERSEDOUBLECOMBO
		dw	MSGREVERSETRIPLECOMBO
		dw	MSGREVERSESUPERCOMBO

b1comboscore:	or	a
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

b1kick:		ld	a,[b1_kicklock]
		or	a
		jr	nz,.locked
		ld	a,[any_ballsaver]
		or	a
		jr	nz,.locked
		ld	a,[b1_backtimer]
		cp	BACKCLOSETIME*3/4
		jr	nc,.aok
		ld	a,BACKCLOSETIME*3/4
.aok:		ld	[b1_backtimer],a
.locked:	ld	a,1
		call	board1kickback
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

b1seaflash:	ld	a,[b1_seatimer]
		ld	c,a
		inc	a
		ld	[b1_seatimer],a
		cp	15
		jr	nc,.openkickback
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,7
.aok:		call	board1seashow
		ld	a,10
		ld	de,b1seaflash
		jp	addtimed
.openkickback:
		ld	a,[b1_seastate]
		call	board1sea
		ld	de,(1<<8)|B1_KICKLIGHT
		jp	newstate

b1topflash:	ld	a,[b1_toptimer]
		ld	c,a
		inc	a
		ld	[b1_toptimer],a
		cp	11
		jr	nc,.incbonus
		rrca
		ld	a,0
		jr	c,.aok
		ld	a,3
.aok:		call	board1topshow
		ld	a,10
		ld	de,b1topflash
		jp	addtimed
.incbonus:	ld	a,[b1_toplanes]
		jp	board1topshow

b1popupflash:	ld	a,[b1_poptimer]
		ld	c,a
		inc	a
		ld	[b1_poptimer],a
		cp	11
		jr	nc,.lighttrap
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,15
.aok:		call	board1popshow
		ld	a,10
		ld	de,b1popupflash
		jp	addtimed
.lighttrap:	xor	a
		call	board1popshow
		ld	a,1
		ld	[b1_locked],a
		ret
b1awardflash:	ld	a,[b1_awardtimer]
		ld	c,a
		inc	a
		ld	[b1_awardtimer],a
		cp	11
		jr	nc,.doaward
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,$1f
.aok:		call	board1awardshow
		ld	a,10
		ld	de,b1awardflash
		jp	addtimed
.doaward:	ld	a,[b1_award]
		jp	board1award

b1arielflash:	ld	a,[b1_arieltimer]
		ld	c,a
		inc	a
		ld	[b1_arieltimer],a
		cp	11
		jr	nc,.doariel
		rrca
		ld	a,0
		jr	nc,.aok
		ld	a,$1f
.aok:		call	board1arielshow
		ld	a,10
		ld	de,b1arielflash
		jp	addtimed
.doariel:	xor	a
		ld	[b1_arieltimer],a
		ld	a,[b1_ariel]
		jp	board1ariel


stormeject:	ld	de,E3X
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8
		call	AddBall
		ld	hl,b1_trapped
		dec	[hl]
		ret	z
		ld	a,60
		ld	de,stormeject
		jp	addtimed

phaseb1kick:	ld	a,[b1_kicklock]
		or	a
		jr	nz,.kickon
		ld	a,[b1_kickback]
		or	a
		jr	z,.kickoff
		ld	a,[b1_backtimer]
		or	a
		jr	z,.kickon
		dec	a
		ld	[b1_backtimer],a
		jr	z,.kickclose
		srl	a
		jr	c,.kickoff
.kickon:	ld	de,(1<<8)|B1_KICKLIGHT
		jp	newstate
.kickclose:	xor	a
		call	board1kickback
.kickoff:	ld	de,B1_KICKLIGHT
		jp	newstate

SPINNERMAXVEL	EQU	6
SPINNERBIAS	EQU	2
hitspinner:
		ld	h,-29	;-9
		ld	l,15	;31
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

board1eject:	ld	l,0
		ldh	a,[pin_x]
		ld	c,a
		sub	255&E1X
		ld	e,a
		ldh	a,[pin_x+1]
		ld	b,a
		sbc	E1X>>8
		or	e
		jr	z,.take
		inc	l
		ld	a,c
		sub	255&E2X
		ld	e,a
		ld	a,b
		sbc	E2X>>8
		or	e
		jr	z,.take
		inc	l
		ld	a,c
		sub	255&E3X
		ld	e,a
		ld	a,b
		sbc	E3X>>8
		or	e
		jr	z,.take
		inc	l
.take:
		ld	a,l
		or	a
		jr	z,.take1
		dec	a
		jr	z,.take2
		dec	a
		jp	z,.take3
		jp	.take4
.take1:						;ursula's cave
		ld	a,[b1_scoop1]
		or	a
		jr	z,.noscoop1
		ld	a,FX_TABLEADVANCE
		call	InitSfx
		xor	a
		ld	[b1_scoop1],a
		ld	a,TV_CAVE+4
		call	b1keeptv
		ld	a,1
		ld	[b1_cavesub],a
;		ld	a,SUBGAME_CAVE
;		call	unlocksub
		ld	de,score50m
		call	addscore
		call	b1sublit
		ld	hl,MSGCAVEDONE
		call	statusflash
		call	b1endtable
		jr	.done1
.noscoop1:
		ld	a,[any_table]
		or	a
		jr	nz,.done1

		ld	a,[b1_cavesub]
		or	a
		jr	z,.nocavesub
		xor	a
		ld	[b1_cavesub],a
		ld	a,SUBGAME_CAVE
		call	ChainSub
		jr	.done1
.nocavesub:
		ld	a,[b1_flotsamsub]
		or	a
		jr	z,.noflotsam
		xor	a
		ld	[b1_flotsamsub],a
		ld	a,SUBGAME_FLOTSAM
		call	ChainSub
		jr	.done1
.noflotsam:
		ld	a,[b1_ursulasub]
		or	a
		jr	z,.noursula
		xor	a
		ld	[b1_ursulasub],a
		ld	a,SUBGAME_URSULA
		call	ChainSub
		jr	.done1
.noursula:

.done1:
		jp	b1set2

;		ld	de,E1X
;		ld	bc,E1Y
;		ld	h,E1VX*EJECTSPEED/8
;		ld	l,E1VY*EJECTSPEED/8
;		jp	.set
.take2:						;flounder
		ld	a,[b1_scoop2]
		or	a
		jr	z,.noscoop2
		xor	a
		ld	[b1_scoop2],a
		call	checkcave
		jr	.done2
.noscoop2:
		ld	a,[any_table]
		or	a
		jr	nz,.nofloundersub
		ld	a,[b1_floundersub]
		or	a
		jr	z,.nofloundersub
		xor	a
		ld	[b1_floundersub],a
		ld	a,SUBGAME_FLOUNDER
		call	ChainSub
		jr	.done2
.nofloundersub:
;		cp	TABLEGAME_HAPPY
;		jr	z,.trylockflounder
		cp	TABLEGAME_STORM
		jr	z,.trylockflounder
		cp	TABLEGAME_URSULA
		jr	nz,.nolockflounder
.trylockflounder:
		ld	a,[any_mlock1]
		or	a
		jr	nz,.nolockflounder
		call	CountBalls
		cp	2
		jr	c,.nolockflounder
		ld	a,1
		ld	[any_mlock1],a
		jp	b1lockedmulti
.nolockflounder:

.done2:
		jp	b1set2

.take3:						;wreck

		ld	a,[any_extra]
		or	a
		jr	z,.noextra
		dec	a
		ld	[any_extra],a
		call	b1doextraball
		jp	.done3
.noextra:
		ld	a,[b1_scoop3]
		or	a
		jr	z,.noscoop3
		xor	a
		ld	[b1_scoop3],a
		call	checkcave
		jp	.done3
.noscoop3:
		ld	a,[any_table]
		or	a
		jr	nz,.noscuttlesub
		ld	a,[b1_scuttlesub]
		or	a
		jr	z,.noscuttlesub
		xor	a
		ld	[b1_scuttlesub],a
		ld	a,SUBGAME_SCUTTLE
		call	ChainSub
		jp	.done3
.noscuttlesub:
		ld	a,[any_table]
		or	a
		jr	nz,.notreasuresub
		ld	a,[b1_treasuresub]
		or	a
		jr	z,.notreasuresub
		xor	a
		ld	[b1_treasuresub],a
		ld	a,SUBGAME_TREASURE
		call	ChainSub
		jp	.done3
.notreasuresub:
		ld	a,[any_table]
		or	a
		jr	nz,.nostormsub
		ld	a,[b1_stormsub]
		or	a
		jr	z,.nostormsub
		xor	a
		ld	[b1_stormsub],a
		ld	a,SUBGAME_SHIP
		call	ChainSub
		jr	.done3
.nostormsub:
		ld	a,[b1_locked]
		or	a
		jr	z,.notrap
		ld	a,[any_table]
		or	a
		jr	nz,.notrap
		xor	a
		ld	[b1_locked],a
		ld	hl,b1_trapped
		ld	a,[hl]
		cp	2
		jr	c,.not2
		call	RumbleHigh
		ld	a,TABLEGAME_STORM
		call	b1startmulti
		ld	a,10
		call	b1showtv
		ld	a,11
		call	b1showtv
		ld	a,TV_STORM
		ld	[any_multibase],a
		ld	[any_tvback],a
		ld	[any_tvback],a
		ld	a,TABLEGAME_STORM
		ld	[any_table],a
		call	b1tablesong
		ld	hl,MSGSTORM
		call	statusflash
		ld	a,HOLDTIME/2+60
		ld	de,stormeject
		call	addtimed
		jr	.done3
.not2:		inc	[hl]
		ld	a,[hl]
		add	8-1
		call	b1showtv
		ld	a,11
		call	b1showtv
		ld	a,FX_BALLLOCKED
		call	InitSfx
		ld	a,15
		call	board1popups
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
		jp	b1set3

.take4:
		ld	a,[b1_scoop4]
		or	a
		jr	z,.noscoop4
		xor	a
		ld	[b1_scoop4],a
		call	checkcave
		jr	.done4
.noscoop4:
		ld	a,[any_table]
		or	a
		jr	nz,.nokisssub
		ld	a,[b1_kisssub]
		or	a
		jr	z,.nokisssub
		xor	a
		ld	[b1_kisssub],a
		ld	a,SUBGAME_KISS
		call	ChainSub
		jr	.done4
.nokisssub:
;		cp	TABLEGAME_HAPPY
;		jr	z,.trylockgrotto
		cp	TABLEGAME_STORM
		jr	z,.trylockgrotto
		cp	TABLEGAME_URSULA
		jr	nz,.nolockgrotto
.trylockgrotto:
		ld	a,[any_mlock2]
		or	a
		jr	nz,.nolockgrotto
		call	CountBalls
		cp	2
		jr	c,.nolockgrotto
		ld	a,1
		ld	[any_mlock2],a
		jp	b1lockedmulti
.nolockgrotto:



		ld	a,[b1_awardready]
		or	a
		jr	z,.noaward
		xor	a
		ld	[b1_awardready],a
		call	board1giveaward
		jr	.done4
.noaward:
.done4:
		jp	b1set4


b1lockedmulti:
		xor	a
		ldh	[pin_ballflags],a
		ldh	[pin_ballpause],a
		ret

b1outs:		ld	a,1<<BALLFLG_USED
		ldh	[pin_ballflags],a
		ld	a,HOLDTIME/2
		ldh	[pin_ballpause],a
		ret

b1out2:		call	b1outs
b1set2:
		ld	de,b1flounder1
		ld	a,HOLDTIME/2
		call	addtimed
		ld	de,b1flounder0
		ld	a,15+HOLDTIME/2
		call	addtimed


		ld	de,E2X		;flounder
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		jr	b1set
b1set3:		ld	de,E3X		;wreck
		ld	bc,E3Y
		ld	h,E3VX*EJECTSPEED/8
		ld	l,E3VY*EJECTSPEED/8
		jr	b1set
b1out4:		call	b1outs
b1set4:		ld	de,E4X		;grotto
		ld	bc,E4Y
		ld	h,E4VX*EJECTSPEED/8
		ld	l,E4VY*EJECTSPEED/8
b1set:		ld	a,e
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

b1spit2:	ld	de,E2X		;flounder
		ld	bc,E2Y
		ld	h,E2VX*EJECTSPEED/8
		ld	l,E2VY*EJECTSPEED/8
		jr	b1spits
b1spit4:	ld	de,E4X		;grotto
		ld	bc,E4Y
		ld	h,E4VX*EJECTSPEED/8
		ld	l,E4VY*EJECTSPEED/8
b1spits:	call	AddBall
		ld	a,h
		or	l
		ret	z ;hack to fix japanese bug # 14
		ld	de,BALL_BALLPAUSE
		add	hl,de
		ld	[hl],HOLDTIME/2
		ret



checkcave:	ld	a,FX_TABLEADVANCE
		call	InitSfx
		ld	de,score10m
		call	addscore
		ld	hl,b1_scoop2
		ld	a,[hli]
		add	[hl]
		inc	hl
		add	[hl]
		push	af
		cpl
		add	TV_CAVE+3+1
		call	b1keeptv
		pop	af
		jr	nz,.cavecont
		ld	a,1
		ld	[b1_scoop1],a
		ld	hl,MSGCAVECLOSE
		jp	statusflash
.cavecont:	ld	hl,MSGCAVECONT
		jp	statusflash


E1X		EQU	140<<4
E1Y		EQU	211<<4
E2X		EQU	63<<4
E2Y		EQU	438<<4
E3X		EQU	205<<4
E3Y		EQU	316<<4
E4X		EQU	314<<4
E4Y		EQU	413<<4

E1VX		EQU	10
E1VY		EQU	30
E2VX		EQU	14
E2VY		EQU	28
E3VX		EQU	-10
E3VY		EQU	30
E4VX		EQU	-28
E4VY		EQU	14


board1collisions:
		dw	enterramp,124,164
		db	10,9
		dw	exitramp,287/2,498/2
		db	4,4
		dw	entertop,E1X>>5,E1Y>>5
		db	3,3
		dw	enterleft,E2X>>5,E2Y>>5
		db	3,3
		dw	entercenter,E3X>>5,E3Y>>5
		db	3,3
		dw	enterright,E4X>>5,E4Y>>5
		db	3,3
		dw	hitspinner,58,44	;70/2,152/2
		db	4,6
		dw	hitspinner,62,57	;86/2,157/2
		db	4,6
		dw	hitspinner,66,70	;102/2,162/2
		db	4,6
		dw	b1kick,158,323
		db	3,3
		dw	b1award1lane,17,261
		db	3,3
		dw	b1award2lane,31,261
		db	3,3
		dw	b1award3lane,45,261
		db	3,3
		dw	b1award4lane,144,261
		db	3,3
		dw	b1award5lane,158,261
		db	3,3
		dw	b1topleft,77,32
		db	5,4
		dw	b1topright,92,32
		db	5,4
		dw	b1outerenter,34,136
		db	8,4
		dw	b1outerexit,153,129
		db	8,4
		dw	b1smallenter,28,190
		db	3,4
		dw	b1smallexit,16,223
		db	3,4
		dw	b1innerenter,189/2,260/2
		db	5,9
		dw	b1innerexit,88/2,158/2
		db	12,5
		dw	b1firedown,185/2,37/2
		db	6,4
		dw	b1ursulareact,42/2,148/2
		db	6,6
		dw	b1ursulareact,143/2,42/2
		db	6,6
		dw	b1shoot,347/2,576/2
		db	6,6
		dw	0


RAMPLOC		EQU	$d000+18*24*2+17*2
setramp:	srl	a
		jr	c,rampdown
rampup:		ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	z
		res	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,RAMPLOC
		ld	de,24*2-2
		ld	c,13
.lp:		set	3,[hl]
		inc	l
		inc	l
		set	3,[hl]
		add	hl,de
		dec	c
		jr	nz,.lp
		jr	rampmarks
rampdown:	ld	hl,pin_flags
		bit	PINFLG_RAMPDOWN,[hl]
		ret	nz
		set	PINFLG_RAMPDOWN,[hl]
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,RAMPLOC
		ld	de,24*2-2
		ld	c,13
.lp:		res	3,[hl]
		inc	l
		inc	l
		res	3,[hl]
		add	hl,de
		dec	c
		jr	nz,.lp
rampmarks:	ld	a,WRKBANK_NRM
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

b1unchain:	call	saver20
		call	autofire
		jp	b1endtable

autofire:	ld	a,1
		ld	[any_tofire],a
		ret

b1tablesong:	ld	a,[any_table]
		ld	c,a
		ld	b,0
		ld	hl,b1songmap
		add	hl,bc
		ld	a,[hl]
		or	a
		ret	z
		jp	PrefTune2

b1songmap:	db	0
		db	0
		db	SONG_CAVE
		db	SONG_FLOUNDER
		db	SONG_KISS
		db	0
		db	SONG_FLOTSAM
		db	SONG_TREASURE
		db	SONG_SCUTTLE
		db	SONG_SHIP
		db	SONG_URSULA
		db	SONG_HAPPY1

board1_end::
