; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** CHOPPER.ASM                                                           **
; **                                                                       **
; ** Last modified : 990401 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"chopper",CODE,BANK[7]
		section 7

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

chopper_top::


SFX_CHOPCHOP	EQU	6
SFX_CHOPBOING	EQU	4
SFX_CHOPMISS	EQU	19
SONG_CHOP	EQU	7



MAPSIZE		EQU	32*18
MAPORIG		EQU	$e000-4*MAPSIZE
ATTRORIG	EQU	$e000-3*MAPSIZE
MAPCOPY		EQU	$e000-2*MAPSIZE
ATTRCOPY	EQU	$e000-1*MAPSIZE
CHOPINFOBLOCK	EQU	-512+MAPORIG
LINESAVE	EQU	-20+CHOPINFOBLOCK
CHOPCYCLEBLOCK	EQU	-256+LINESAVE

CHOPDUSTLIFE	EQU	30
CHOPDUSTFLICKER	EQU	20

MAXSTACKSHOW	EQU	34
STACKFIRST	EQU	19+16*$20

CHOP_BREAKX0	EQU	32
CHOP_BREAKX1	EQU	64
CHOP_BREAKX2	EQU	96
CHOP_BREAKX3	EQU	128
CHOP_BREAKY	EQU	128

CHOP_MRGHOST	EQU	3	;How long to behave as if maurice is there
				;after he leaves a position
CHOPENDDELAYTIME EQU	45

;log structure:3 bytes
;1 byte delta to add (shifted left 2 bits) to fraction. When carry, frame
;should increment
;2 byte frame and fraction (10 bits frame, 6 bits fraction)
;1 byte mask for this log
;fraction is the upper 6 bits of the 16 bit number
MAXLOGS		EQU	5

CHOPFLG_FIRST	EQU	0
CHOPFLG_ENDSTG	EQU	1
CHOPFLG_LOST	EQU	2
CHOPFLG_DUST	EQU	3
CHOPFLG_MISSED	EQU	4

chop_phase	EQUS	"hTemp48+00"
chop_mask	EQUS	"hTemp48+01"
chop_axe	EQUS	"hTemp48+02"
chop_flags	EQUS	"hTemp48+03"
chop_mrpos	EQUS	"hTemp48+04"
chop_logs	EQUS	"hTemp48+05" ;4 bytes per struct * 5 struct = 20 bytes
chop_count	EQUS	"hTemp48+25"
chop_stack	EQUS	"hTemp48+26"
chop_toadd	EQUS	"hTemp48+27"
chop_lives	EQUS	"hTemp48+28"
chop_break0	EQUS	"hTemp48+29"
chop_break1	EQUS	"hTemp48+30"
chop_break2	EQUS	"hTemp48+31"
chop_break3	EQUS	"hTemp48+32"
chop_mrthere0	EQUS	"hTemp48+33"
chop_mrthere1	EQUS	"hTemp48+34"
chop_mrthere2	EQUS	"hTemp48+35"
chop_mrthere3	EQUS	"hTemp48+36"
chop_boing	EQUS	"hTemp48+37"
chop_mrwant	EQUS	"hTemp48+38"
chop_takelo	EQUS	"hTemp48+39"
chop_takehi	EQUS	"hTemp48+40"
chop_wait	EQUS	"hTemp48+41"
chop_stagepos	EQUS	"hTemp48+42"
chop_delay	EQUS	"hTemp48+43"
chop_bonus	EQUS	"hTemp48+44"
chop_bonusx	EQUS	"hTemp48+45"
chop_bonusdelay	EQUS	"hTemp48+46"
chop_cycle	EQUS	"hTemp48+47"


MAUR_NORMAL	EQU	0
MAUR_DOWN	EQU	1
MAUR_UP		EQU	2
MAUR_LEFT	EQU	3
MAUR_RIGHT	EQU	4

mauricetbl:	db	0,1,2,3		;normal
		db	4,5,6,7		;looking down
		db	8,9,10,11	;looking up
		db	0,12,13,14	;looking left/down
		db	15,16,17,3	;looking right/down


axelist:	db	3,4,0,1,2


Chopper::
		call	initchopseq

		ld	a,[wSubGaston]
		or	a
		jr	nz,.nolives
		ld	a,[wSubLevel]	;Special
		cp	3		;
		ld	a,2		;
		jr	c,.aok		;
.nolives:	xor	a		;
.aok:		ldh	[chop_lives],a
		call	chopper_setup
chopperloop::	call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,chop_pause
		ldh	a,[chop_stagepos]
		or	a
		jr	nz,.inhibit
		call	inctime
		call	choptrybonus
.inhibit:	call	initrender
		call	domaurice
		call	mrghost
		ld	hl,chop_axe
		ld	a,[hl]
		or	a
		jr	z,.aok
		inc	a
		cp	5
		jr	c,.aok
		xor	a
.aok:		ld	[hl],a
		ld	hl,axelist
		call	addahl
		ld	a,[hl]
		call	renderaxe
		call	chopcopy
		call	chopflip
		call	InitFigures64
		call	chopdobonus
		call	chopdostage
		call	plotlogs
		call	plotbreaks
		call	OutFigures
		call	steplogs
		call	processhits
		call	doboing
		ld	hl,chop_flags
		bit	CHOPFLG_FIRST,[hl]
		jr	z,.notfirst
		res	CHOPFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.notfirst:
.addstacks:	ldh	a,[chop_toadd]
		or	a
		jr	z,.nomore
		dec	a
		ldh	[chop_toadd],a
		call	addstack
		call	IncScore
;		ld	hl,wScoreLo
;		inc	[hl]
;		jr	nz,.addstacks
;		inc	hl
;		inc	[hl]
		jr	.addstacks
.nomore:
		call	chopcheckdone
		jr	z,.notdone
		ld	hl,chop_delay
		inc	[hl]
		ld	a,[hl]
		cp	CHOPENDDELAYTIME
		jp	nc,chop_done
.notdone:
		call	chopstartsong

		ld	a,24
		call	AccurateWait
		jp	chopperloop


chop_pause:	call	chopper_shutdown
		call	PauseMenu_B
		call	chopper_setup
		jp	chopperloop

chop_done:	jp	chopper_shutdown

chopstartsong:
startsong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_CHOP
		jp	InitTunePref


chopcheckdone:	ld	a,[wSubStage]
		cp	3
		jr	z,.isdone
		ldh	a,[chop_flags]
		bit	CHOPFLG_LOST,a
		jr	nz,.isdone
		bit	CHOPFLG_ENDSTG,a
		jr	z,.notdone
		ld	hl,chop_logs
		ld	c,MAXLOGS
		ld	de,4
.anylogs:	ld	a,[hl]
		or	a
		jr	nz,.notdone
		add	hl,de
		dec	c
		jr	nz,.anylogs
		ld	a,[wSubLevel]	;Special stage
		cp	3		;
		jr	nc,.special	;
		ld	hl,wSubStage
		inc	[hl]
		ld	a,[hl]
		cp	3
		jr	z,.wongame
.special:	call	initchopseq
		jr	.notdone
.wongame:	ld	a,SONG_WON
		call	InitTune
.isdone:	xor	a
		inc	a
		ret
.notdone:	xor	a
		ret


chopflip:	ldh	a,[chop_phase]
		inc	a
		ldh	[chop_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret




logstarttab:	dw	1,42,73,154,200,301


CHOP1		EQU	1
CHOP2		EQU	2
CHOP3		EQU	4
CHOP4		EQU	8
CHOPEND		EQU	16

collisiondata:	db	9-1,17-1,25-1,33-1
		db	0,54-42,0,66-42
		db	89-73,105-73,121-73,137-73
		db	0,172-154,0,190-154
		db	220-200,240-200,260-200,280-200
		db	0,325-301,0,349-301




logdata:	dw	9
		db	CHOP1
		dw	17
		db	CHOP2
		dw	25
		db	CHOP3
		dw	33
		db	CHOP4
		dw	42
		db	CHOPEND
		dw	54
		db	CHOP2
		dw	66
		db	CHOP4
		dw	73
		db	CHOPEND
		dw	89
		db	CHOP1
		dw	105
		db	CHOP2
		dw	121
		db	CHOP3
		dw	137
		db	CHOP4
		dw	154
		db	CHOPEND
		dw	172
		db	CHOP2
		dw	190
		db	CHOP4
		dw	200
		db	CHOPEND
		dw	220
		db	CHOP1
		dw	240
		db	CHOP2
		dw	260
		db	CHOP3
		dw	280
		db	CHOP4
		dw	301
		db	CHOPEND
		dw	325
		db	CHOP2
		dw	349
		db	CHOP4
		dw	362
		db	CHOPEND
		dw	0

makechopinfo:	ld	hl,CHOPINFOBLOCK
		ld	bc,512
		call	MemClear
		ld	hl,logdata
.mcilp:		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		ret	z
		ld	a,e
		add	255&CHOPINFOBLOCK
		ld	e,a
		ld	a,d
		adc	CHOPINFOBLOCK>>8
		ld	d,a
		ld	a,[hli]
		ld	[de],a
		jr	.mcilp


;b=log type 0-5
;c=speed 1-64
addlog:		ld	a,1
		ldh	[chop_axe],a
		ld	hl,logstarttab
		ld	a,b
		add	a
		call	addahl
		ld	e,[hl]
		inc	hl
		ld	d,[hl]

		ld	hl,chop_logs
		ld	b,MAXLOGS
.findlog:	ld	a,[hl]
		or	a
		jr	z,.foundlog
		inc	l
		inc	l
		inc	l
		inc	l
		dec	b
		jr	nz,.findlog
		ret	;too many logs
.foundlog:	ld	[hl],c
		inc	l
		ld	[hl],e
		inc	l
		ld	[hl],d
		inc	l
		ld	[hl],0
		ld	a,SFX_CHOPCHOP
		jp	InitSfx

boingtab:	db	MAUR_DOWN
		db	MAUR_NORMAL
		db	MAUR_UP


;return a=MAUR_* types
pickmaurice:	ldh	a,[chop_boing]
		or	a
		jr	nz,.boinging
		ld	hl,chop_break0
		ld	c,-1
		call	.anybreak
		jr	nz,.abreak
		call	.anybreak
		jr	nz,.abreak
		call	.anybreak
		jr	nz,.abreak
		call	.anybreak
		jr	nz,.abreak
.normal:	ld	a,MAUR_NORMAL
		ret
.abreak:	ldh	a,[chop_mrpos]
		cp	c
		jr	z,.normal
		jr	c,.right
		ld	a,MAUR_LEFT
		ret
.right:		ld	a,MAUR_RIGHT
		ret
.anybreak:	inc	c
		ld	a,[hli]
		or	a
		ret


.boinging:	dec	a
		srl	a
		ld	hl,boingtab
		call	addahl
		ld	a,[hl]
		ret

choptrybonus:	ldh	a,[chop_phase]
		and	15
		ret	nz
		ld	hl,chop_bonusdelay
		ld	a,[hl]
		or	a
		ret	z
		dec	[hl]
		ret	nz
		call	random
		and	96
		inc	a
		ldh	[chop_bonus],a
		ret

chopdobonus:	ldh	a,[chop_bonus]
		or	a
		ret	z
		ld	c,a
		inc	a
		ldh	[chop_bonus],a
		dec	c
		ld	hl,chop_flags
		bit	CHOPFLG_DUST,[hl]
		jr	nz,.dust
		ld	b,0
		ld	hl,chopbonus1
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
		add	80
		ld	d,a
		ldh	[chop_bonusx],a
		ld	a,[hl]
		add	72
		ld	e,a
		ld	a,c
		and	7
		add	255&IDX_STAR
		ld	c,a
		ld	a,0
		adc	IDX_STAR>>8
		ld	b,a
		ld	a,[wGroup4]
		call	AddFigure
		ldh	a,[chop_bonus]
		sub	2
		ld	c,a
		and	$1f
		cp	$1f
		ret	nz
		xor	c
		swap	a
		srl	a
		ld	c,a
		ld	b,0
		ld	hl,chop_mrthere0
		add	hl,bc
		ld	a,[hl]
		or	a
		jr	z,.missedbonus
.gotbonus:	ld	a,1
		ldh	[chop_bonus],a
		ld	hl,chop_flags
		set	CHOPFLG_DUST,[hl]
		ld	hl,wSubStars
		inc	[hl]
		ld	a,SONG_GOTSTAR
		call	InitTune
		ret
.dustover:
.missedbonus:	xor	a
		ldh	[chop_bonus],a
		ret
.dust:		ld	a,c
		cp	CHOPDUSTLIFE
		jr	z,.dustover
		cp	CHOPDUSTFLICKER
		jr	c,.noflicker
		srl	a
		ret	c
.noflicker:	ldh	a,[chop_bonusx]
		ld	d,a
		ld	a,39+72
		sub	c
		sub	c
		ld	e,a
		ld	a,c
		and	7
		add	255&IDX_DUST
		ld	c,a
		ld	a,0
		adc	IDX_DUST>>8
		ld	b,a
		ld	a,[wGroup4]
		jp	AddFigure



doboing:	ld	hl,chop_boing
		ld	a,[hl]
		or	a
		ret	z
		cp	2*3
		jr	z,.boingoff
		inc	[hl]
		ret
.boingoff:	ld	[hl],0
		ret

steplogs:	xor	a
		ldh	[chop_mask],a
		ld	hl,chop_logs
		ld	a,MAXLOGS
.sllp:		ldh	[chop_count],a
		ld	a,[hli]
		ld	e,[hl]
		inc	l
		ld	d,[hl]
		inc	l
		inc	l
		or	a
		jr	z,.next
		dec	l
		dec	l
		dec	l
		cp	64
		jr	nc,.incremented
		add	a
		add	a
		add	d
		ld	d,a
		ld	b,0
		jr	nc,.store
.incremented:	inc	de
		ld	a,d
		and	3
		ld	b,a
		ld	a,e
		add	255&CHOPINFOBLOCK
		ld	c,a
		ld	a,b
		adc	CHOPINFOBLOCK>>8
		ld	b,a
		ld	a,[bc]
		or	a
		ld	b,a
		jr	z,.store
		cp	CHOPEND
		jr	z,.disable
		ldh	a,[chop_mask]
		or	b
		ldh	[chop_mask],a
		jr	.store
.disable:
		ldh	a,[chop_toadd]
		inc	a
		ldh	[chop_toadd],a
		dec	l
		xor	a
		ld	[hli],a
.store:		ld	a,e
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		ld	a,b
		ld	[hli],a
.next:		ldh	a,[chop_count]
		dec	a
		jr	nz,.sllp
		ret


plotbreaks:	ld	d,CHOP_BREAKX0
		ld	hl,chop_break0
		call	plotbreak
		ld	d,CHOP_BREAKX1
		ld	hl,chop_break1
		call	plotbreak
		ld	d,CHOP_BREAKX2
		ld	hl,chop_break2
		call	plotbreak
		ld	d,CHOP_BREAKX3
		ld	hl,chop_break3
plotbreak:	ld	a,[hl]
		or	a
		ret	z
		inc	[hl]
		dec	a
		cp	4*6
		jr	z,.breakover
		srl	a
		srl	a
		add	255&(IDX_LOG+2)
		ld	c,a
		ld	a,0
		adc	(IDX_LOG+2)>>8
		ld	b,a
		ld	a,[wGroup2]
		ld	e,CHOP_BREAKY
		jp	AddFigure
.breakover:	ld	[hl],0
		ret

mrghost:	ld	hl,chop_mrthere0
		call	mrghost1
		inc	l
		call	mrghost1
		inc	l
		call	mrghost1
		inc	l
		call	mrghost1
		ld	hl,chop_mrthere0
		ldh	a,[chop_mrpos]
		call	addahl
		ld	[hl],CHOP_MRGHOST
		ret
mrghost1:	ld	a,[hl]
		or	a
		ret	z
		dec	[hl]
		ret

chopbits:	db	CHOP1,CHOP2,CHOP3,CHOP4

processhits:	ldh	a,[chop_mask]
		ld	b,a
		ld	c,0
		call	processhit1
		call	processhit1
		call	processhit1
		call	processhit1
		ld	hl,chop_flags
		bit	CHOPFLG_MISSED,[hl]
		ret	z
		res	CHOPFLG_MISSED,[hl]
		ld	a,SFX_CHOPMISS
		jp	InitSfx
processhit1:	ld	e,c
		inc	c
		srl	b
		ret	nc
		ld	d,0
		ld	hl,chop_mrthere0
		add	hl,de
		ld	a,[hl]
		or	a
		jr	nz,.hit
		ld	hl,chop_break0
		add	hl,de
		ld	[hl],1
		ld	hl,chopbits
		add	hl,de
		ld	e,[hl]
		ld	hl,chop_logs+3
		ld	d,MAXLOGS
.findlog	ld	a,[hl]
		and	e
		jr	z,.next
		ld	[hl],0
		dec	l
		dec	l
		dec	l
		ld	[hl],0
		inc	l
		inc	l
		inc	l
		call	lostlog
.next:		inc	l
		inc	l
		inc	l
		inc	l
		dec	d
		jr	nz,.findlog
;lost one or more logsSFX_CHOP_MISS
		ld	hl,chop_flags
		set	CHOPFLG_MISSED,[hl]
		ret
.hit:		ld	a,1
		ldh	[chop_boing],a
;hit a log successfullySFX_CHOP_HIT
		ld	a,SFX_CHOPBOING
		jp	InitSfx





plotlogs:	xor	a
.pllp:		ldh	[chop_count],a
		ld	e,a
		ld	d,0
		ld	hl,chop_logs
		add	hl,de
		ld	a,[hli]
		or	a
		jr	z,.nolog
		ld	a,[hli]
		ld	e,a
		ld	a,[hl]
		and	3
		ld	d,a
		ld	a,[wGroup1]
		ld	b,a
		call	AddFrame
.nolog:		ldh	a,[chop_count]
		add	4
		cp	MAXLOGS*4
		jr	c,.pllp
		ret




FIX		EQU	$80

domaurice:
		call	pickmaurice
		add	a
		add	a
		ld	e,a
		ld	hl,chop_mrpos
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
.noleft:	bit	JOY_A,c
		jr	nz,.goright
		bit	JOY_R,c
		jr	z,.noright
.goright:	ld	a,[hl]
		cp	3
		jr	z,.noright
		inc	[hl]
.noright:	bit	JOY_A,c
		jr	z,.noa
		nop
.noa:		bit	JOY_B,c
		jr	z,.nob
		nop
.nob:		ld	a,[hl]
		and	3
		ld	[hl],a
		ld	hl,mauricetbl
		ld	d,0
		add	hl,de
		ld	e,a
		add	hl,de
		ld	a,[hl]
		jp	rendermr



chopper_setup:
		ld	hl,chop_flags
		set	CHOPFLG_FIRST,[hl]

		ld	a,%10000111
		ldh	[hVblLCDC],a

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.gmb

		ld	hl,IDX_MR000CHR	;mr000chr
		ld	de,$C800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,160
		call	DumpChrs
		ld	hl,chopperpal
		call	LoadPalHL
		ld	hl,IDX_MR000MAP	;mr000map
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800+8
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

		ld	hl,$c800+8
		ld	de,ATTRORIG
		ld	c,18
.y2:		ld	b,20
.x2:		inc	hl
		ld	a,[hli]
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

		jr	.cgb
.gmb:
		ld	hl,IDX_MRBW000CHR	;mrbw000chr
		ld	de,$C800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,160
		call	DumpChrs
		ld	hl,IDX_MRBW000MAP	;mrbw000map
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800+8
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

		call	InitGroups

		ld	de,logframes
		ld	a,BANK(logframes)
		call	RegisterGroup
		ld	[wGroup1],a
		ld	hl,PAL_LOG
		call	AddPalette
		ld	[wGroup2],a
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup3],a
		ld	hl,PAL_STAR
		call	AddPalette
		or	$10
		ld	[wGroup4],a

		call	initrender
		xor	a
		call	rendermr
		call	chopcopy
		call	makechopinfo
		ld	hl,MAPORIG+17*$20
		ld	de,LINESAVE
		ld	bc,20
		call	MemCopy
		ld	a,[LINESAVE+19]
		ld	b,a
		ld	a,[LINESAVE+3]
		ld	[LINESAVE+19],a
		ld	hl,MAPORIG+17*$20+19
		ld	[hl],a
		ldh	a,[chop_lives]
		or	a
		jr	z,.nolives
		ld	c,a
		ld	a,b
.putlives:	ld	[hld],a
		dec	c
		jr	nz,.putlives
.nolives:
		ldh	a,[chop_stack]
		or	a
		jr	z,.nostack
		ldh	[chop_count],a
		xor	a
		ldh	[chop_stack],a
.incstack:	call	addstack
		ld	hl,chop_count
		dec	[hl]
		jr	nz,.incstack
.nostack:
		jp	loadcycle

lostlog:	ldh	a,[chop_lives]
		or	a
		jr	z,.lostgame
		dec	a
		ldh	[chop_lives],a
		push	bc
		push	hl
		ld	c,a
		ld	hl,LINESAVE+19
		ld	a,l
		sub	c
		ld	l,a
		ld	b,[hl]
		ld	hl,MAPORIG+17*$20+19
		ld	a,l
		sub	c
		ld	l,a
		ld	[hl],b
		pop	hl
		pop	bc
		ret
.lostgame:	ldh	a,[chop_flags]
		set	CHOPFLG_LOST,a
		ldh	[chop_flags],a
		push	bc
		push	de
		push	hl
		ld	a,SONG_LOST
		call	InitTune
		pop	hl
		pop	de
		pop	bc
		ret


initrender:	ld	hl,MAPORIG
		ld	de,MAPCOPY
		ld	bc,MAPSIZE*2
		jp	MemCopy

;00-9F       = BG chars
;A0-B7,B8-CF = Maurice
;D0-E3,E4-F7 = Axe
;All #'s must be XOR $80 of course...


;a=maurice frame # 0-17
rendermr:	ld	e,a
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,e
		jr	z,.aok
		add	18
.aok:		push	af
		add	a
		ld	hl,mrframes
		call	addahl
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		add	hl,de
		ld	de,MAPCOPY
		ldh	a,[chop_phase]
		srl	a
		ld	b,$20 ;$A0 XOR $80
		jr	nc,.bok
		ld	b,$38 ;$B8 XOR $80
.bok:		call	chapply
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.gmb
		ld	de,ATTRCOPY
		ld	b,0
		call	chapply
.gmb:		pop	af

;a=maurice # 0-17
mrchars:	ld	e,a
		add	a
		add	e
		ld	e,a
		ld	d,0
		ld	hl,mrtbl
		add	hl,de
		ld	c,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[chop_phase]
		srl	a
		ld	de,$9200
		jr	nc,.deok
		ld	de,$9380
.deok:		jp	DumpChrsInFileSys


;a=axe frame # 0-4
renderaxe:	ld	e,a
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,e
		jr	z,.aok
		add	5
.aok:		push	af
		add	a
		ld	hl,axeframes
		call	addahl
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		add	hl,de
		ld	de,MAPCOPY
		ldh	a,[chop_phase]
		srl	a
		ld	b,$50 ;$D0 XOR $80
		jr	nc,.bok
		ld	b,$64 ;$E4 XOR $80
.bok:		call	chapply
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.gmb
		ld	de,ATTRCOPY
		ld	b,0
		call	chapply
.gmb:		pop	af

;a=axe # 0-5
axechars:	ld	e,a
		add	a
		add	e
		ld	e,a
		ld	d,0
		ld	hl,axetbl
		add	hl,de
		ld	c,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[chop_phase]
		srl	a
		ld	de,$9500
		jr	nc,.deok
		ld	de,$9640
.deok:		jp	DumpChrsInFileSys


chopstacksfx:	db	7,8,9,10,11,47,48,49,50,51,52,53,54,55,56,57



addstack:	ldh	a,[chop_stack]
		and	15
		ld	hl,chopstacksfx
		call	addahl
		ld	a,[hl]
		call	InitSfx

		ld	hl,chop_stack
		inc	[hl]
		ld	a,[hl]
		cp	MAXSTACKSHOW
		ret	nc
		ld	hl,MAPORIG+STACKFIRST
		ld	b,[hl]
		ld	de,-$20
		srl	a
		jr	nc,.nodec
		dec	hl
.nodec:		or	a
		jr	z,.nosub
.sublp:		add	hl,de
		dec	a
		jr	nz,.sublp
.nosub:		ld	[hl],b
		ld	de,ATTRORIG-MAPORIG
		add	hl,de
		ld	a,[ATTRORIG+STACKFIRST]
		ld	[hl],a
		ret


chapply:	ld	a,[hli]
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
		jr	chapply


chopcopy:	ld	hl,MAPCOPY
		ldh	a,[chop_phase]
		srl	a
		ld	de,$9800
		jr	nc,.deok
		ld	de,$9c00
.deok:		ld	bc,$20*18
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
		ld	bc,$20*18
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret


chopper_shutdown:
		call	FadeOut
		jp	SprOff

initchopseq:	ld	hl,chop_flags
		res	CHOPFLG_ENDSTG,[hl]
		ld	a,[wSubLevel]	;Special
		cp	3		;
		jr	nc,.nostagepos	;
		ld	a,1
		ldh	[chop_stagepos],a
		ld	a,[wSubStage]
		ld	d,a
		jr	.yesstagepos
.nostagepos:	call	random
		and	3
		jr	z,.nostagepos
		dec	a
		ld	d,a
.yesstagepos:	call	random
		and	3
		ld	c,a
		swap	a
		sub	c
		ld	c,a	;c=0,15,30 or 45
		ld	a,[wSubLevel]
		ld	b,a
		add	a
		add	b	;a=wSubLevel*3
		add	c
		add	d
;		ld	c,a
;		ld	a,[wSubStage]
;		add	c

		ldh	[chop_cycle],a
		call	loadcycle

		ld	a,[hl]
		inc	a
		ldh	[chop_wait],a
		ld	a,l
		ldh	[chop_takelo],a
		ld	a,h
		ldh	[chop_takehi],a
		ld	a,[wSubStage]
		cp	1
		jr	nz,.nobonus
;only do bonus in middle stage
		call	random
		and	31
		add	16
		ldh	[chop_bonusdelay],a
.nobonus:
		ret


loadcycle:	ldh	a,[chop_cycle]
		ld	c,a
		ld	b,0
		ld	hl,chopperbin
		add	hl,bc
		add	hl,bc
		ld	c,[hl]
		inc	hl
		ld	b,[hl]
		add	hl,bc
		ret

;		ld	hl,cyclelengths
;		add	hl,bc
;		ld	a,[hl]
;		ld	hl,IDX_CHOP00BIN	;chop00bin
;		add	hl,bc
;		ld	c,a
;		ld	de,CHOPCYCLEBLOCK
;		jp	MemCopyInFileSys


chopdostage:	ld	hl,chop_stagepos
		ld	a,[wGroup3]
		jp	StdStage

inctime:	ld	hl,chop_wait
		ld	a,[hl]
		cp	255
		jr	z,.endmark
		dec	[hl]
		ret	nz
.top:		ldh	a,[chop_takelo]
		ld	l,a
		ldh	a,[chop_takehi]
		ld	h,a
		inc	hl
		ld	b,[hl]	;type
		inc	hl
		ld	c,[hl]
		inc	hl
		ld	a,[hl]
		ldh	[chop_wait],a
		ld	a,l
		ldh	[chop_takelo],a
		ld	a,h
		ldh	[chop_takehi],a
		call	addlog
		ldh	a,[chop_wait]
		or	a
		jr	z,.top
		ret
.endmark:	ldh	[chop_wait],a
		ld	hl,chop_flags
		set	CHOPFLG_ENDSTG,[hl]
		ret



mrtbl:
		db	FSSIZE_MR001CHR>>4
		dw	IDX_MR001CHR
		db	FSSIZE_MR002CHR>>4
		dw	IDX_MR002CHR
		db	FSSIZE_MR003CHR>>4
		dw	IDX_MR003CHR
		db	FSSIZE_MR004CHR>>4
		dw	IDX_MR004CHR
		db	FSSIZE_MR005CHR>>4
		dw	IDX_MR005CHR
		db	FSSIZE_MR006CHR>>4
		dw	IDX_MR006CHR
		db	FSSIZE_MR007CHR>>4
		dw	IDX_MR007CHR
		db	FSSIZE_MR008CHR>>4
		dw	IDX_MR008CHR
		db	FSSIZE_MR009CHR>>4
		dw	IDX_MR009CHR
		db	FSSIZE_MR010CHR>>4
		dw	IDX_MR010CHR
		db	FSSIZE_MR011CHR>>4
		dw	IDX_MR011CHR
		db	FSSIZE_MR012CHR>>4
		dw	IDX_MR012CHR
		db	FSSIZE_MR013CHR>>4
		dw	IDX_MR013CHR
		db	FSSIZE_MR014CHR>>4
		dw	IDX_MR014CHR
		db	FSSIZE_MR015CHR>>4
		dw	IDX_MR015CHR
		db	FSSIZE_MR016CHR>>4
		dw	IDX_MR016CHR
		db	FSSIZE_MR017CHR>>4
		dw	IDX_MR017CHR
		db	FSSIZE_MR018CHR>>4
		dw	IDX_MR018CHR

		db	FSSIZE_MRBW001CHR>>4
		dw	IDX_MRBW001CHR
		db	FSSIZE_MRBW002CHR>>4
		dw	IDX_MRBW002CHR
		db	FSSIZE_MRBW003CHR>>4
		dw	IDX_MRBW003CHR
		db	FSSIZE_MRBW004CHR>>4
		dw	IDX_MRBW004CHR
		db	FSSIZE_MRBW005CHR>>4
		dw	IDX_MRBW005CHR
		db	FSSIZE_MRBW006CHR>>4
		dw	IDX_MRBW006CHR
		db	FSSIZE_MRBW007CHR>>4
		dw	IDX_MRBW007CHR
		db	FSSIZE_MRBW008CHR>>4
		dw	IDX_MRBW008CHR
		db	FSSIZE_MRBW009CHR>>4
		dw	IDX_MRBW009CHR
		db	FSSIZE_MRBW010CHR>>4
		dw	IDX_MRBW010CHR
		db	FSSIZE_MRBW011CHR>>4
		dw	IDX_MRBW011CHR
		db	FSSIZE_MRBW012CHR>>4
		dw	IDX_MRBW012CHR
		db	FSSIZE_MRBW013CHR>>4
		dw	IDX_MRBW013CHR
		db	FSSIZE_MRBW014CHR>>4
		dw	IDX_MRBW014CHR
		db	FSSIZE_MRBW015CHR>>4
		dw	IDX_MRBW015CHR
		db	FSSIZE_MRBW016CHR>>4
		dw	IDX_MRBW016CHR
		db	FSSIZE_MRBW017CHR>>4
		dw	IDX_MRBW017CHR
		db	FSSIZE_MRBW018CHR>>4
		dw	IDX_MRBW018CHR


axetbl:
		db	FSSIZE_AXE001CHR>>4
		dw	IDX_AXE001CHR
		db	FSSIZE_AXE002CHR>>4
		dw	IDX_AXE002CHR
		db	FSSIZE_AXE003CHR>>4
		dw	IDX_AXE003CHR
		db	FSSIZE_AXE004CHR>>4
		dw	IDX_AXE004CHR
		db	FSSIZE_AXE005CHR>>4
		dw	IDX_AXE005CHR

		db	FSSIZE_AXBW001CHR>>4
		dw	IDX_AXBW001CHR
		db	FSSIZE_AXBW002CHR>>4
		dw	IDX_AXBW002CHR
		db	FSSIZE_AXBW003CHR>>4
		dw	IDX_AXBW003CHR
		db	FSSIZE_AXBW004CHR>>4
		dw	IDX_AXBW004CHR
		db	FSSIZE_AXBW005CHR>>4
		dw	IDX_AXBW005CHR

chopbonus1:
		db	-79,39
		db	-78,30
		db	-77,21
		db	-76,14
		db	-75,6
		db	-74,0
		db	-73,-6
		db	-72,-11
		db	-71,-16
		db	-70,-20
		db	-69,-24
		db	-68,-26
		db	-67,-29
		db	-66,-30
		db	-65,-31
		db	-64,-31
		db	-63,-31
		db	-62,-31
		db	-61,-30
		db	-60,-29
		db	-59,-26
		db	-58,-24
		db	-57,-20
		db	-56,-16
		db	-55,-11
		db	-54,-6
		db	-53,0
		db	-52,6
		db	-51,14
		db	-50,21
		db	-49,30
		db	-48,39
chopbonus2:
		db	-78,39
		db	-76,30
		db	-74,21
		db	-72,14
		db	-70,6
		db	-68,0
		db	-66,-6
		db	-64,-11
		db	-62,-16
		db	-60,-20
		db	-58,-24
		db	-56,-26
		db	-54,-29
		db	-52,-30
		db	-50,-31
		db	-48,-31
		db	-46,-31
		db	-44,-31
		db	-42,-30
		db	-40,-29
		db	-38,-26
		db	-36,-24
		db	-34,-20
		db	-32,-16
		db	-30,-11
		db	-28,-6
		db	-26,0
		db	-24,6
		db	-22,14
		db	-20,21
		db	-18,30
		db	-16,39
chopbonus3:
		db	-77,39
		db	-74,30
		db	-71,21
		db	-68,14
		db	-65,6
		db	-62,0
		db	-59,-6
		db	-56,-11
		db	-53,-16
		db	-50,-20
		db	-47,-24
		db	-44,-26
		db	-41,-29
		db	-38,-30
		db	-35,-31
		db	-32,-31
		db	-29,-31
		db	-26,-31
		db	-23,-30
		db	-20,-29
		db	-17,-26
		db	-14,-24
		db	-11,-20
		db	-8,-16
		db	-5,-11
		db	-2,-6
		db	1,0
		db	4,6
		db	7,14
		db	10,21
		db	13,30
		db	16,39
chopbonus4:
		db	-76,39
		db	-72,30
		db	-68,21
		db	-64,14
		db	-60,6
		db	-56,0
		db	-52,-6
		db	-48,-11
		db	-44,-16
		db	-40,-20
		db	-36,-24
		db	-32,-26
		db	-28,-29
		db	-24,-30
		db	-20,-31
		db	-16,-31
		db	-12,-31
		db	-8,-31
		db	-4,-30
		db	0,-29
		db	4,-26
		db	8,-24
		db	12,-20
		db	16,-16
		db	20,-11
		db	24,-6
		db	28,0
		db	32,6
		db	36,14
		db	40,21
		db	44,30
		db	48,39


logframes:
		include	"res/dave/chopper/chop.as2"


mrframes:	incbin	"res/dave/chopper/mr.bin"
axeframes:	incbin	"res/dave/chopper/axe.bin"
chopperpal:	incbin	"res/dave/chopper/mr000.rgb"
chopperbin:	incbin	"res/dave/chopper/chopdat.bin"

chopper_end::
