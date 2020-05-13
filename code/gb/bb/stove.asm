; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** STOVE.ASM                                                             **
; **                                                                       **
; ** Last modified : 990321 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"stove",CODE,BANK[4]
		section 4
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

stove_top::


SONG_STOVE	EQU	11

SFX_STOVEEJECT	EQU	12
SFX_STOVEMOVE	EQU	73 ;17
SFX_STOVEBURN	EQU	18
SFX_STOVESPRAY	EQU	67
SFX_STOVENOWAT	EQU	15
SFX_STOVEFILL	EQU	66

STOVESTARTIME	EQU	50	;63 = MAX
STOVEDUSTTIME	EQU	25	;63 = MAX
STOVEDUSTFLICKER EQU	15

MAPSIZE		EQU	32*18
MAPORIG		EQU	$e000-4*MAPSIZE
ATTRORIG	EQU	$e000-3*MAPSIZE
MAPCOPY		EQU	$e000-2*MAPSIZE
ATTRCOPY	EQU	$e000-1*MAPSIZE

STOVEMAP	EQU	$c800

MAXWATER	EQU	5

SAFEKEG		EQU	7	;# of lines we can allow burn into a keg

;fire structure
;1 byte mode
;5 bytes data,varies with mode


stove_phase	EQUS	"hTemp48+00"
stove_flags	EQUS	"hTemp48+01"
stove_stovefrm	EQUS	"hTemp48+02"
stove_sneeze	EQUS	"hTemp48+03"
stove_pottslo	EQUS	"hTemp48+04"
stove_pottshi	EQUS	"hTemp48+05"
stove_stagepos	EQUS	"hTemp48+06"
stove_meter	EQUS	"hTemp48+07"
stove_fire0	EQUS	"hTemp48+08"	;8 bytes/struct
stove_fire1	EQUS	"hTemp48+16"	;8 bytes/struct
stove_fire2	EQUS	"hTemp48+24"	;8 bytes/struct
stove_fire3	EQUS	"hTemp48+32"	;8 bytes/struct
stove_pottspos	EQUS	"hTemp48+40"
stove_hit	EQUS	"hTemp48+41"
stove_sprayed	EQUS	"hTemp48+42"
stove_water	EQUS	"hTemp48+43"
stove_burnrate	EQUS	"hTemp48+44"
stove_spurtrnd	EQUS	"hTemp48+45"
stove_endcnt	EQUS	"hTemp48+46"
stove_star	EQUS	"hTemp48+47"

STOVEFLG_FIRST	EQU	0
STOVEFLG_LFCT	EQU	1
STOVEFLG_RFCT	EQU	2
STOVEFLG_FILLL	EQU	3
STOVEFLG_FILLR	EQU	4
STOVEFLG_WON	EQU	5
STOVEFLG_DUST	EQU	6
STOVEFLG_STAR	EQU	7

pick0a		equ	1
pickab		equ	2
pickac		equ	3
pickcd		equ	4
pickae		equ	5
pickef		equ	6
pick0g		equ	7
pickgh		equ	8
pickgi		equ	9
pickgj		equ	10
pickjk		equ	11
pickjl		equ	12
pickgm		equ	13
pickmn		equ	14
pick0o		equ	15
pickop		equ	16
pickoq		equ	17
pickqr		equ	18
pickos		equ	19
pickst		equ	20
pickou		equ	21
pickuv		equ	22
pick0w		equ	23
pickwx		equ	24
pickwy		equ	25
pickyz		equ	26
picky1		equ	27
pickw2		equ	28
pick23		equ	29



;each line has
;# of flames to spurt 1-20,burn rate 1-7,spurt frequency value 0-255

stovestagetab:
		db	10,4,255		;Easy    stage 1
		db	15,4,255		;Easy    stage 2
		db	15,4,255		;Easy    stage 3
		db	10,5,255		;Medium  stage 1
		db	15,5,255		;Medium  stage 2
		db	20,5,255		;Medium  stage 3
		db	10,7,255		;Hard    stage 1
		db	15,7,255		;Hard    stage 2
		db	20,7,255		;Hard    stage 3

SPECIALBURNRATE1 EQU	5
SPECIALSPURTRATE1 EQU	255
SPECIALBURNRATE2 EQU	7
SPECIALSPURTRATE2 EQU	255


Stove::
		ld	a,255
		ldh	[stove_star],a

		call	newstovestage
		ld	a,MAXWATER
		ldh	[stove_water],a

		ld	a,[wSubGaston]
		or	a
		jr	z,.nogaston
		ld	a,16
		ldh	[stove_fire0+7],a
		ldh	[stove_fire2+7],a
		ldh	[stove_fire3+7],a
		ld	a,48
		ldh	[stove_fire1+7],a


.nogaston:


		call	stove_setup


stoveloop::
		call	stovesong
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,stove_pause

		call	checkstoveend
		jp	nc,stoveover
		ldh	a,[stove_flags]
		bit	STOVEFLG_WON,a
		jp	nz,stoveover
		ldh	a,[stove_endcnt]
		or	a
		call	z,checkstovestage

		call	stovewinanim
		call	stoveinitrender
		ldh	a,[stove_stagepos]
		or	a
		jr	nz,.staging2
		call	trysneeze
		call	flickerbarrels
		ldh	a,[stove_phase]
		and	3
		jr	nz,.nofaucets
		call	leftfaucet
		call	rightfaucet
.nofaucets:
.staging2:
		ldh	a,[stove_stovefrm]
		call	renderstv
		call	stovecopy
		call	stoveflip


		call	InitFigures64


		ldh	a,[stove_stagepos]
		or	a
		jr	nz,.staging
		call	trybringstovestar
		ldh	a,[stove_star]
		cp	255
		call	nz,dostovestar
		call	processfires
		ld	a,[wJoy1Hit]
		ld	c,a
		ldh	a,[stove_hit]
		or	c
		ldh	[stove_hit],a
		ld	c,a
		call	mrspotts
.staging:	call	stovestage

		call	drawpotts
		call	OutFigures


		ld	hl,stove_flags
		bit	STOVEFLG_FIRST,[hl]
		jr	z,.nofade
		res	STOVEFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:
		ld	a,24
		call	AccurateWait
 xor a
 ldh [hVbl8],a
		jp	stoveloop

stove_pause:	call	stove_shutdown
		call	PauseMenu_B
		call	stove_setup
		jp	stoveloop

stovesong:	ld	a,[wMzPlaying]
		or	a
		ret	nz
		ld	a,SONG_STOVE
		jp	InitTunePref


stoveover:	ldh	a,[stove_flags]
		bit	STOVEFLG_WON,a
		jp	nz,.won
		call	stove_shutdown
;		ld	a,SONG_LOST
;		call	InitTune
		ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,IntroBoom
		call	TalkingHeads
;		ld	hl,IDX_STLOEBG	;stlosebg
;		ld	de,IDX_STLOSEBWBG	;stlosebwbg
;		call	bgwrapper
		ret
.won:		call	WaitForVBL
		ld	a,[wMzNumber]
		cp	SONG_WON
		jr	nz,.nowait
		ld	a,[wMzPlaying]
		or	a
		jr	nz,.won
.nowait:	jp	stove_shutdown

bgwrapper:	ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok
		ld	h,d
		ld	l,e
.hlok:		call	BgInFileSys
		call	FadeIn
.www:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	z,.www
		jp	FadeOut

stovestartab:	db	80-22,72-51
		db	80+22,72-51
		db	80-38,72-3
		db	80+38,72-3


stovepick:	db	3,1,3,2,0,2

trybringstovestar:
		ldh	a,[stove_flags]
		bit	STOVEFLG_STAR,a
		ret	nz
		ld	a,[wSubStage]
		dec	a
		ret	nz
		ldh	a,[stove_meter]
		cp	5
		ret	nc
		ldh	a,[stove_flags]
		set	STOVEFLG_STAR,a
		ldh	[stove_flags],a
		ldh	a,[stove_pottspos]
		ld	hl,stovepick
		call	addahl
		ld	a,[hl]
		swap	a
		add	a
		add	a
		ldh	[stove_star],a
		ret

stoveremap:	db	2,5,1,4

dostovestar:	ldh	a,[stove_star]
		ld	c,a
		swap	a
		srl	a
		and	6
		ld	hl,stovestartab
		call	addahl
		ld	a,[hli]
		ld	e,[hl]
		ld	d,a
		ldh	a,[stove_flags]
		bit	STOVEFLG_DUST,a
		jr	nz,.dust
		ld	a,c
		and	7
		add	255&IDX_STAR
		ld	c,a
		ld	a,0
		adc	IDX_STAR>>8
		ld	b,a
		ld	a,[wGroup5]
		call	AddFigure

		ldh	a,[stove_star]
		ld	c,a
		inc	a
		ldh	[stove_star],a
		and	$3f
		cp	STOVESTARTIME
		jr	z,.done
		ld	hl,stove_pottslo
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		inc	hl
		inc	hl
		ld	a,[hli]
		or	[hl]
		ret	nz

		ld	a,c
		swap	a
		srl	a
		srl	a
		and	3
		ld	hl,stoveremap
		call	addahl
		ldh	a,[stove_pottspos]
		cp	[hl]
		ret	nz
		ld	a,c
		and	$c0
		ldh	[stove_star],a
		ld	hl,stove_flags
		set	STOVEFLG_DUST,[hl]
		ld	hl,wSubStars
		inc	[hl]
		ld	a,SONG_GOTSTAR
		jp	InitTune
.done:		ld	a,255
		ldh	[stove_star],a
		ret
.dust:		ld	a,c
		and	$3f
		add	a
		cpl
		inc	a
		add	e
		ld	e,a
		ld	a,c
		and	7
		add	255&IDX_DUST
		ld	c,a
		ld	a,0
		adc	IDX_DUST>>8
		ld	b,a
		ldh	a,[stove_star]
		inc	a
		ldh	[stove_star],a
		and	$3f
		cp	STOVEDUSTTIME
		jr	z,.done
		cp	STOVEDUSTFLICKER
		jr	c,.noflicker
		srl	a
		ret	c
.noflicker:	ld	a,[wGroup5]
		jp	AddFigure

checkstovestage:
		ldh	a,[stove_stagepos]
		or	a
		ret	nz
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		ret	nc		;
		ldh	a,[stove_meter]
		or	a
		ret	nz
		ldh	a,[stove_fire0]
		or	a
		ret	nz
		ldh	a,[stove_fire1]
		or	a
		ret	nz
		ldh	a,[stove_fire2]
		or	a
		ret	nz
		ldh	a,[stove_fire3]
		or	a
		ret	nz
		ld	hl,wSubStage
		inc	[hl]
		ld	a,[hl]
		cp	3
		jr	z,stovewon
newstovestage:
		ld	a,LOW(pottsbase)
		ldh	[stove_pottslo],a
		ld	a,HIGH(pottsbase)
		ldh	[stove_pottshi],a
		ld	a,3
		ldh	[stove_pottspos],a
		ld	a,[wSubLevel]
		cp	3
		jr	nc,.special
		ld	c,a
		add	a
		add	c
		ld	c,a
		ld	a,[wSubStage]
		add	c
		ld	c,a
		add	a
		add	c
		ld	hl,stovestagetab
		call	addahl
		ld	a,[hli]
		ldh	[stove_meter],a
		ld	a,[hli]
		ldh	[stove_burnrate],a
		ld	a,[hli]
		ldh	[stove_spurtrnd],a
		ld	a,1
		ldh	[stove_stagepos],a
		jp	paintmeter
.special:	xor	a
		ldh	[stove_meter],a
		ld	b,SPECIALBURNRATE1
		ld	c,SPECIALSPURTRATE1
		ld	a,[wSubLevel]
		cp	3
		jr	z,.bcok
		ld	b,SPECIALBURNRATE2
		ld	c,SPECIALSPURTRATE2
.bcok:		ld	a,b
		ldh	[stove_burnrate],a
		ld	a,c
		ldh	[stove_spurtrnd],a
		jp	paintmeter

stovewon:	ld	a,1
		ldh	[stove_endcnt],a
		ld	a,SONG_WON
		call	InitTune
		ret

checkstoveend:	ldh	a,[stove_fire0+7]
		cp	40+SAFEKEG
		ret	nc
		ldh	a,[stove_fire1+7]
		cp	72+SAFEKEG
		ret	nc
		ldh	a,[stove_fire2+7]
		cp	40+SAFEKEG
		ret	nc
		ldh	a,[stove_fire3+7]
		cp	48+SAFEKEG
		ret


FIX		EQU	$80
stove_setup:
		ld	a,%10010011
		ld	[wGmbPal2],a
		xor	a
		ldh	[stove_hit],a
		ld	hl,stove_flags
		set	STOVEFLG_FIRST,[hl]

		ld	a,%10000111
		ldh	[hVblLCDC],a

		call	InitGroups
		ld	de,fireframes
		ld	a,BANK(fireframes)
		call	RegisterGroup
		or	$10
		ld	[wGroup1],a
		ld	hl,PAL_FIRE
		call	AddPalette
		or	$10
		ld	[wGroup2],a
		ld	de,pottsframes
		ld	a,BANK(pottsframes)
		call	RegisterGroup
		or	$10
		ld	[wGroup3],a
		ld	hl,PAL_STAGES
		call	AddPalette
		or	$10
		ld	[wGroup4],a
		ld	hl,PAL_STAR
		call	AddPalette
		or	$10
		ld	[wGroup5],a

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jp	nz,.gmb

		ld	hl,IDX_STOVEBGCHR	;stovebgchr
		ld	de,$C800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$9C
		call	DumpChrs
		ld	hl,stovepal
		call	LoadPalHL
		ld	hl,IDX_STOVEBGMAP	;stovebgmap
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800+8	;stovemap+8
		ld	de,MAPORIG
		ld	c,18
.y1:		ld	b,32
.x1:		ld	a,[hli]
		inc	hl
		add	FIX
		ld	[de],a
		inc	de
		dec	b
		jr	nz,.x1
		dec	c
		jr	nz,.y1

		ld	hl,$c800+8	;stovemap+8
		ld	de,ATTRORIG
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
		jp	.cgb
.gmb:
		ld	hl,IDX_STOVEBWCHR	;stovebwchr
		ld	de,$C800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$9C
		call	DumpChrs
		ld	hl,IDX_STOVEBWMAP	;stovebwmap
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800+8	;stovebwmap+8
		ld	de,MAPORIG
		ld	c,18
.bwy1:		ld	b,32
.bwx1:		ld	a,[hli]
		inc	hl
		add	FIX
		ld	[de],a
		inc	de
		dec	b
		jr	nz,.bwx1
		dec	c
		jr	nz,.bwy1
.cgb:

		call	buildfirelists
		call	rechar
		ldh	a,[stove_water]
		or	a
		jr	z,.nowaters
		ld	b,a
		xor	a
		ldh	[stove_water],a
.addwaters:	call	addwater
		dec	b
		jr	nz,.addwaters
.nowaters:
		call	paintmeter

		ret

stove_shutdown:
		ld	a,%11010010
		ld	[wGmbPal2],a
		call	FadeOut
		jp	SprOff

stoveflip:	ldh	a,[stove_phase]
		inc	a
		ldh	[stove_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret


stoveinitrender:
		ld	hl,MAPORIG
		ld	de,MAPCOPY
		ld	bc,MAPSIZE*2
		jp	MemCopy

stovecopy:	ld	hl,MAPCOPY
		ldh	a,[stove_phase]
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

;00-96       = BG chars
;9C-CD,CE-FF = Stove
;All #'s must be XOR $80 of course...


;a=stove frame # 0-13
renderstv:	ld	e,a
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,e
		jr	z,.aok
		add	14
.aok:		push	af
		add	a
		ld	hl,stoveframes
		call	addahl
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		add	hl,de
		ld	de,MAPCOPY
		ldh	a,[stove_phase]
		srl	a
		ld	b,$1C ;$9C XOR $80
		jr	nc,.bok
		ld	b,$4E ;$CE XOR $80
.bok:		call	AnyApply
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.gmb
		ld	de,ATTRCOPY
		ld	b,0
		call	AnyApply
.gmb:		pop	af

;a=stove # 0-13
stvchars:	ld	e,a
		add	a
		add	e
		ld	e,a
		ld	d,0
		ld	hl,stvtbl
		add	hl,de
		ld	c,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[stove_phase]
		srl	a
		ld	de,$91C0
		jr	nc,.deok
		ld	de,$94E0
.deok:		jp	DumpChrsInFileSys


leftfaucet:	ldh	a,[stove_flags]
		bit	STOVEFLG_FILLL,a
		ret	z
		xor	1<<STOVEFLG_LFCT
		ldh	[stove_flags],a
		and	1<<STOVEFLG_LFCT
		jr	nz,leftfaucet2
leftfaucet1:	ld	a,[MAPORIG+20+12*$20]
		ld	[MAPORIG+00+12*$20],a
		ld	a,[MAPORIG+21+12*$20]
		ld	[MAPORIG+01+12*$20],a
		ld	a,[MAPORIG+22+12*$20]
		ld	[MAPORIG+02+12*$20],a
		ld	a,[MAPORIG+20+13*$20]
		ld	[MAPORIG+00+13*$20],a

		ld	a,[ATTRORIG+20+12*$20]
		ld	[ATTRORIG+00+12*$20],a
		ld	a,[ATTRORIG+21+12*$20]
		ld	[ATTRORIG+01+12*$20],a
		ld	a,[ATTRORIG+22+12*$20]
		ld	[ATTRORIG+02+12*$20],a
		ld	a,[ATTRORIG+20+13*$20]
		ld	[ATTRORIG+00+13*$20],a
		ret

leftfaucet2:	ld	a,[MAPORIG+20+14*$20]
		ld	[MAPORIG+00+12*$20],a
		ld	a,[MAPORIG+21+14*$20]
		ld	[MAPORIG+01+12*$20],a
		ld	a,[MAPORIG+22+14*$20]
		ld	[MAPORIG+02+12*$20],a
		ld	a,[MAPORIG+20+15*$20]
		ld	[MAPORIG+00+13*$20],a

		ld	a,[ATTRORIG+20+14*$20]
		ld	[ATTRORIG+00+12*$20],a
		ld	a,[ATTRORIG+21+14*$20]
		ld	[ATTRORIG+01+12*$20],a
		ld	a,[ATTRORIG+22+14*$20]
		ld	[ATTRORIG+02+12*$20],a
		ld	a,[ATTRORIG+20+15*$20]
		ld	[ATTRORIG+00+13*$20],a
		ret

rightfaucet:	ldh	a,[stove_flags]
		bit	STOVEFLG_FILLR,a
		ret	z
		xor	1<<STOVEFLG_RFCT
		ldh	[stove_flags],a
		and	1<<STOVEFLG_RFCT
		jr	nz,rightfaucet2
rightfaucet1:	ld	a,[MAPORIG+29+12*$20]
		ld	[MAPORIG+17+12*$20],a
		ld	a,[MAPORIG+30+12*$20]
		ld	[MAPORIG+18+12*$20],a
		ld	a,[MAPORIG+31+12*$20]
		ld	[MAPORIG+19+12*$20],a
		ld	a,[MAPORIG+31+13*$20]
		ld	[MAPORIG+19+13*$20],a

		ld	a,[ATTRORIG+29+12*$20]
		ld	[ATTRORIG+17+12*$20],a
		ld	a,[ATTRORIG+30+12*$20]
		ld	[ATTRORIG+18+12*$20],a
		ld	a,[ATTRORIG+31+12*$20]
		ld	[ATTRORIG+19+12*$20],a
		ld	a,[ATTRORIG+31+13*$20]
		ld	[ATTRORIG+19+13*$20],a
		ret

rightfaucet2:	ld	a,[MAPORIG+29+14*$20]
		ld	[MAPORIG+17+12*$20],a
		ld	a,[MAPORIG+30+14*$20]
		ld	[MAPORIG+18+12*$20],a
		ld	a,[MAPORIG+31+14*$20]
		ld	[MAPORIG+19+12*$20],a
		ld	a,[MAPORIG+31+15*$20]
		ld	[MAPORIG+19+13*$20],a

		ld	a,[ATTRORIG+29+14*$20]
		ld	[ATTRORIG+17+12*$20],a
		ld	a,[ATTRORIG+30+14*$20]
		ld	[ATTRORIG+18+12*$20],a
		ld	a,[ATTRORIG+31+14*$20]
		ld	[ATTRORIG+19+12*$20],a
		ld	a,[ATTRORIG+31+15*$20]
		ld	[ATTRORIG+19+13*$20],a
		ret

NUMFIRELISTS	EQU	16
FIRELISTBASE	EQU	$d000


buildfirelists:	ld	hl,stovetob
		ld	de,FIRELISTBASE+2*NUMFIRELISTS
		xor	a
.bfl:		ldh	[hTmpLo],a
		add	a
		add	255&FIRELISTBASE
		ld	c,a
		ld	b,FIRELISTBASE>>8
		ld	a,e
		ld	[bc],a
		inc	c
		ld	a,d
		ld	[bc],a
		push	hl
		inc	hl
		inc	hl
.bfl2:		ld	a,[hli]
		or	a
		jr	z,.done
		dec	a
		ld	c,a
		add	a
		add	c
		push	hl

		add	LOW(stovefiredata)
		ld	l,a
		ld	a,0
		adc	HIGH(stovefiredata)
		ld	h,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	h,[hl]
		inc	h
.addlist:	ld	a,c
		ld	[de],a
		inc	de
		ld	a,b
		ld	[de],a
		inc	de
		inc	bc
		dec	h
		jr	nz,.addlist
		pop	hl
		jr	.bfl2
.done:		pop	bc
		xor	a
		ld	[de],a
		inc	de
		ld	[de],a
		inc	de
		ld	a,[bc]
		ld	[de],a
		inc	bc
		inc	de
		ld	a,[bc]
		ld	[de],a
		inc	de

		ldh	a,[hTmpLo]
		inc	a
		cp	NUMFIRELISTS
		jr	c,.bfl
		ret


stovestage:	ld	hl,stove_stagepos
		ld	a,[wGroup4]
		jp	StdStage

;c=joypad data
mrspotts:	ldh	a,[stove_pottslo]
		ld	l,a
		ldh	a,[stove_pottshi]
		ld	h,a
mrspottsnew:	inc	hl
		inc	hl
		ld	a,[hli]
		or	[hl]
		jr	z,.endbusy
		dec	hl
		ld	a,l
		ldh	[stove_pottslo],a
		ld	a,h
		ldh	[stove_pottshi],a
		ret
.endbusy:	ld	hl,stove_flags
		ld	a,[hl]
		and	(1<<STOVEFLG_FILLL)|(1<<STOVEFLG_FILLR)
		jr	z,.noaddwater
		xor	[hl]
		ld	[hl],a
.addlp:		ldh	a,[stove_water]
		cp	MAXWATER
		jr	z,.noaddwater
		call	addwater
		jr	.addlp
.noaddwater:	ldh	a,[stove_sprayed]
		or	a
		jr	z,.nosprayed
		ld	e,a
		xor	a
		ldh	[stove_sprayed],a
		dec	e
		sla	e
		sla	e
		sla	e
		ld	d,0
		ld	hl,stove_fire0
		add	hl,de
		push	bc
		call	sprayfire
		pop	bc
.nosprayed:

pottsnotbusy:
		xor	a
		ldh	[stove_hit],a
		ldh	a,[stove_pottspos]
		add	a
		ld	hl,pottslist
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
.checkmove:	ld	a,[hli]
		ld	b,a
		and	c
		and	15
		cp	b
		jr	nz,.nomatch
		ld	a,[hli]
		ldh	[stove_pottspos],a
.chain:		ld	a,[hli]
		ld	h,[hl]
		ld	l,a

		IF	0	;skip directly to position
.skipto0:	ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		or	b
		jr	nz,.skipto0
		dec	hl
		dec	hl
		dec	hl
		dec	hl
		ENDC

		ld	a,l
		ldh	[stove_pottslo],a
		ld	a,h
		ldh	[stove_pottshi],a
		ld	a,SFX_STOVEMOVE
		call	InitSfx
		jp	mrspotts

.nomatch:	inc	hl
		inc	hl
		inc	hl
		ld	a,[hl]
		or	a
		jr	nz,.checkmove
		bit	JOY_A,c
		jr	nz,.pourfill
		bit	JOY_B,c
		jr	nz,.pourfill
		ret
.pourfill:	ldh	a,[stove_pottspos]
		or	a
		jr	z,.doit
		cp	3
		jr	z,.doit
		ldh	a,[stove_water]
		or	a
		ld	a,SFX_STOVENOWAT
		jp	z,InitSfx
		call	subwater
		ld	a,SFX_STOVESPRAY
		call	InitSfx
		ldh	a,[stove_pottspos]
.doit:		add	a
		ld	hl,pourfills
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]

drawpotts:	ldh	a,[stove_pottslo]
		ld	l,a
		ldh	a,[stove_pottshi]
		ld	h,a
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		ld	a,[wGroup3]
		ld	b,a
		jp	AddFrame

pourfills:	dw	pourfill0
		dw	pourfill1
		dw	pourfill2
		dw	pourfill3
		dw	pourfill4
		dw	pourfill5
		dw	pourfill6

pourfill0:	ldh	a,[stove_water]
		cp	MAXWATER
		ret	z
		ld	a,SFX_STOVEFILL
		call	InitSfx
		ld	hl,stove_flags
		set	STOVEFLG_FILLL,[hl]
		ld	hl,pottsfill0
		jp	mrspottsnew
pourfill3:	ldh	a,[stove_water]
		cp	MAXWATER
		ret	z
		ld	a,SFX_STOVEFILL
		call	InitSfx
		ld	hl,stove_flags
		set	STOVEFLG_FILLR,[hl]
		ld	hl,pottsfill3
		jp	mrspottsnew
pourfill1:	ld	a,3
		ldh	[stove_sprayed],a
		ldh	a,[stove_fire2+7]
		ld	hl,pottspour1a
		cp	16
		jp	c,mrspottsnew
		ld	hl,pottspour1b
		jp	mrspottsnew
pourfill2:	ld	a,1
		ldh	[stove_sprayed],a
		ldh	a,[stove_fire0+7]
		ld	hl,pottspour2a
		cp	16
		jp	c,mrspottsnew
		ld	hl,pottspour2b
		jp	mrspottsnew
pourfill5:	ld	a,2
		ldh	[stove_sprayed],a
		ldh	a,[stove_fire1+7]
		ld	hl,pottspour5a
		cp	24
		jp	c,mrspottsnew
		ld	hl,pottspour5b
		cp	48
		jp	c,mrspottsnew
		ld	hl,pottspour5c
		jp	mrspottsnew
pourfill4:	ld	a,4
		ldh	[stove_sprayed],a
		ldh	a,[stove_fire3+7]
		ld	hl,pottspour4a
		cp	16
		jp	c,mrspottsnew
		ld	hl,pottspour4b
		jp	mrspottsnew
pourfill6:	ld	hl,pottspour6
		jp	mrspottsnew





;mode 0 = nothing
;mode 1 = initial flight to position
;mode 2 = quick burn down to get to last burn spot
;mode 3 = spread out to cover platform, 1 2 or 3 wide
;mode 4 = slow burn, damage being inflicted
;mode 5 = fire going out
;mode 6 = recovering from douse


;global struct data
;+0 = mode
;+7 = cumulative damage


processfires:
		ld	hl,stove_fire0
		call	processfire
		ld	hl,stove_fire1
		call	processfire
		ld	hl,stove_fire2
		call	processfire
		ld	hl,stove_fire3
;hl=stove_fire# struct
processfire:	ld	a,l
		ldh	[hTmpLo],a
		ld	a,[hli]
		or	a
		ret	z
		dec	a
		jp	z,firegoing
		dec	a
		jp	z,quickdown
		dec	a
		jp	z,spreading
		dec	a
		jp	z,burning
		dec	a
		jp	z,goingout
		dec	a
		jp	z,recovering
		ret
firerestart:	ldh	a,[hTmpLo]
		ld	l,a
		ld	h,$ff
		jr	processfire

goingouttab:
GOINGOUT3	EQU	@-goingouttab
		db	47,48,49,50,51,52
		db	66,67,68,69,70,71
GOINGOUT2	EQU	@-goingouttab
		db	41,42,43,44,45,46
		db	72,73,74,75,76,77
GOINGOUT1	EQU	@-goingouttab
		db	35,36,37,38,39,40
KILL1		EQU	@-goingouttab
		db	78,79,80,81,82,83
ENDOUT		equ	@-goingouttab


;+0 = 5
;+1 = # of rows
;+2 = width of chars of this platform
;+3 = xpos
;+4 = ypos
;+5 = anim counter
goingout:	inc	l
		inc	l
		ld	d,[hl]	;xpos
		inc	l
		ld	e,[hl]	;ypos
		inc	l
		ld	a,[hl]
		inc	[hl]
		cp	ENDOUT
		jr	z,.gone
		add	LOW(goingouttab)
		ld	c,a
		ld	a,0
		adc	HIGH(goingouttab)
		ld	b,a
		ld	a,[bc]
		dec	a
		dec	a
		add	255&IDX_FIRE
		ld	c,a
		ld	a,0
		adc	IDX_FIRE>>8
		ld	b,a
		ld	a,l
		ld	l,stove_fire0
		sub	l
;		sub	stove_fire0
		bit	3,a
		ld	a,[wGroup2]
		jr	z,.aok
		or	$80	;xflip right hand ones
		dec	d	;fix lazy Robert's problem.
.aok:		jp	AddFigure
.gone:		ldh	a,[hTmpLo]
		ld	l,a
		ld	[hl],0
		ret




;+0 = 2
;+1 = # of rows
;+2 = width of chars of this platform
;+3 = xpos
;+4 = ypos
;+5 = anim counter in low 3 bits, # to burn down in
;+6 = damage
quickdown:
		inc	l
		inc	l
		ld	c,35-2
		ld	d,[hl]	;xpos
		inc	l
		ld	e,[hl]	;ypos

		inc	e
		ld	[hl],e
		inc	l
		ld	a,[hl]
		and	$f8
		sub	8
		jr	z,endquick
		ld	a,[hl]
		sub	8
		ld	[hl],a
		inc	[hl]	;step anim frame
		ld	a,[hl]
		and	7
		cp	6
		jr	c,.aok
		xor	[hl]
		ld	[hl],a
		xor	a
.aok:		add	c
		add	255&IDX_FIRE
		ld	c,a
		ld	a,0
		adc	IDX_FIRE>>8
		ld	b,a
		ld	a,l
		ld	l,stove_fire0
		sub	l
;		sub	255&stove_fire0
		bit	3,a
		ld	a,[wGroup2]
		jr	z,.aok2
		or	$80	;xflip right hand ones
		dec	d	;fix lazy Robert's problem.
.aok2:		jp	AddFigure


spreadtab:	db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
SPREAD1to2	EQU	@-spreadtab
		db	53,54,55,56,57,58
END1to2		EQU	@-spreadtab
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
SPREAD2to3	EQU	@-spreadtab
		db	59,60,61,62,63,64,65
END2to3		EQU	@-spreadtab

endquick:	ldh	a,[hTmpLo]
		ld	l,a
		inc	l
		inc	l
		ld	a,[hld]	;# of chars in this object
		dec	l
		dec	a
		jr	z,nospread
		xor	a
spread:		ld	[hl],3	;spreading mode
		inc	l
		inc	l
		inc	l
		inc	l
		inc	l
		ld	[hl],a	;anim counter
		jp	firerestart
nospread:	ld	[hl],4
		inc	l
		inc	l
		inc	l
		inc	l
		inc	l
		ld	[hl],0	;anim counter
		jp	firerestart





;+0 = 3
;+1 = # of rows in this object
;+2 = width in chars of this platform
;+3 = xpos
;+4 = ypos
;+5 = anim counter
;+6 = damage (unused but must be preserved)

spreading:	inc	l
		ld	c,[hl]	;width in chars
		inc	l
		ld	d,[hl]
		inc	l
		ld	e,[hl]
		inc	l
		ld	a,END1to2
		dec	c
		dec	c
		jr	z,.aok
		ld	a,END2to3
.aok:		cp	[hl]
		jr	z,.spreaded
		ld	a,[hl]
		inc	[hl]
		add	LOW(spreadtab)
		ld	c,a
		ld	a,0
		adc	HIGH(spreadtab)
		ld	b,a
		ld	a,[bc]
		dec	a
		dec	a
		add	255&IDX_FIRE
		ld	c,a
		ld	a,0
		adc	IDX_FIRE>>8
		ld	b,a
		ld	a,l
		ld	l,stove_fire0
		sub	l
;		sub	255&stove_fire0
		bit	3,a
		ld	a,[wGroup2]
		jr	z,.aok2
		or	$80	;xflip right hand ones
		dec	d	;fix lazy Robert's problem.
.aok2:		jp	AddFigure

.spreaded:	ld	[hl],0
		dec	l
		dec	l
		dec	l
		dec	l
		dec	l
		ld	[hl],4	;burning mode
		jp	firerestart


;+0 = 4
;+1 = # of rows in this object
;+2 = width in chars of this platform
;+3 = xpos
;+4 = ypos
;+5 = anim counter in low 5 bits, step fraction in upper 3
;+6 = damage counter (increases)
burning:	inc	l
		ld	a,[hli]	;width in chars
		add	a
		ld	c,a
		add	a
		add	c
		add	35-6-2
		ld	c,a
		ld	d,[hl]	;xpos
		inc	l
		ld	e,[hl]	;ypos
		inc	l
		inc	[hl]	;step anim frame
		ld	a,[hl]
		and	31
		cp	6
		jr	c,.aok
		xor	[hl]
		ld	[hl],a
		ldh	a,[stove_burnrate]
		swap	a
		add	a
		add	[hl]
		ld	[hl],a
		jr	nc,.nostepdown
		inc	l
		inc	l
		inc	[hl]	;+7 = total damage for this platform
		dec	l
		inc	[hl]
		ld	a,[hl]
		and	7
		jr	nz,.nochar
		push	bc
		push	de
		push	hl
		call	dochar
		ld	a,SFX_STOVEBURN
		call	InitSfx
		pop	hl
		pop	de
		pop	bc
.nochar:
		ld	a,[hl]
		dec	l
		dec	l
		inc	e
		ld	[hl],e
		dec	l
		dec	l
		dec	l
		cp	[hl]
		jr	z,.endburn

.nostepdown:	xor	a
.aok:		add	c
		add	255&IDX_FIRE
		ld	c,a
		ld	a,0
		adc	IDX_FIRE>>8
		ld	b,a
		ld	a,l
		ld	l,stove_fire0
		sub	l
;		sub	255&stove_fire0
		bit	3,a
		ld	a,[wGroup2]
		jr	z,.aok2
		or	$80	;xflip right hand ones
		dec	d	;fix lazy Robert's problem.
.aok2:		jp	AddFigure

.endburn:	dec	l
		ld	[hl],5	;+0 = mode = going out
		inc	l
		inc	l
		ld	b,[hl]
		inc	l
		inc	l
		inc	l
		ld	a,GOINGOUT1
		dec	b
		jr	z,.aok3
		ld	a,GOINGOUT2
		dec	b
		jr	z,.aok3
		ld	a,GOINGOUT3
.aok3:		ld	[hl],a
		jp	firerestart



;+0 = 1
;+1 = sequence take lo
;+2 = sequence take hi
firegoing:	ld	c,[hl]
		inc	l
		ld	b,[hl]
		dec	l
		ld	a,[bc]
		inc	bc
		ld	e,a
		ld	a,[bc]
		inc	bc
		ld	d,a
		or	e
		jr	nz,.framede
		ld	a,[bc]
		inc	bc
		ld	[hli],a		;struct +1 = # of rows
		ld	a,[bc]
		dec	bc
		ld	[hli],a		;struct +2 = width in chars
		push	hl
		dec	bc
		dec	bc
		dec	bc
		ld	a,[bc]
		dec	bc
		ld	h,a
		ld	a,[bc]
		ld	l,a
		dec	hl
		add	hl,hl
		add	hl,hl
		ld	de,fireframes+5+2	;look up xypos in the AS2 data
		add	hl,de
		ld	a,[hli]
		add	80
		ld	d,a
		ld	a,[hl]
		add	72
		ld	e,a
		pop	hl
		ld	[hl],d		;struct +3 = x pos
		inc	l
		ld	[hl],e		;struct +4 = y pos
		inc	l
		inc	l
		ld	a,[hl]		;+6 = damage done, set up at launch
		add	a
		add	a
		add	a
		dec	l
		ld	[hl],a
		ld	c,a
		ldh	a,[hTmpLo]
		ld	l,a
		ld	[hl],2		;+0 = mode = quick burn down
		ld	a,c
		or	a
		jp	nz,firerestart
		jp	endquick
.framede:	ld	[hl],c
		inc	l
		ld	[hl],b
		ld	a,[wGroup1]
		ld	b,a
		jp	AddFrame


recoveringtab:
RECOVERING2	EQU	@-recoveringtab
		db	66,67,68,69,70,71
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	41,42,43,44,45,46
		db	0
RECOVERING1	EQU	@-recoveringtab
		db	72,73,74,75,76,77
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
		db	35,36,37,38,39,40
RECOVERING0	EQU	@-recoveringtab


;+0 = 6
;+1 = # of rows in this object
;+2 = width in chars of this platform
;+3 = xpos
;+4 = ypos
;+5 = anim counter
;+6 = damage counter (increases)

recovering:	inc	l
		inc	l
		ld	d,[hl]	;xpos
		inc	l
		ld	e,[hl]	;ypos
		inc	l
		ld	a,[hl]
		inc	[hl]
		cp	RECOVERING1-1
		jr	z,.recovered2
		cp	RECOVERING0-1
		jr	z,.recovered1
		add	LOW(recoveringtab)
		ld	c,a
		ld	a,0
		adc	HIGH(recoveringtab)
		ld	b,a
		ld	a,[bc]
		dec	a
		dec	a
		add	255&IDX_FIRE
		ld	c,a
		ld	a,0
		adc	IDX_FIRE>>8
		ld	b,a
		ld	a,l
		ld	l,stove_fire0
		sub	l
;		sub	255&stove_fire0
		bit	3,a
		ld	a,[wGroup2]
		jr	z,.aok
		or	$80	;xflip right hand ones
		dec	d	;fix lazy Robert's problem.
.aok:		jp	AddFigure
.recovered1:	ldh	a,[hTmpLo]
		ld	l,a
		ld	a,SPREAD1to2
		jp	spread
.recovered2:	ldh	a,[hTmpLo]
		ld	l,a
		ld	a,SPREAD2to3
		jp	spread

;hl=fire structure
sprayfire:
		ld	a,[hl]
		or	a
		ret	z
		cp	1	;initial flight to position
		jp	z,douse0
		cp	2	;quick burn
		jp	z,fire6a
		cp	3	;spreading out
		jp	z,douse3
		cp	4	;burning
		jp	z,douse4
		cp	5	;fire going out already
		ret	z
		cp	6
		jp	z,douse6
		ld	[hl],0
		ret

douse0:		inc	l
		ld	c,[hl]
		inc	l
		ld	b,[hl]
		inc	l
		push	hl
.retry:		ld	a,[bc]
		ld	l,a
		inc	bc
		ld	a,[bc]
		ld	h,a
		or	l
		jr	nz,.indexok
		dec	bc
		dec	bc
		dec	bc
		jr	.retry	;crappy code just in case we're point to the 0
.indexok:	dec	hl
		add	hl,hl
		add	hl,hl
		ld	de,fireframes+5+2	;look up xypos in the AS2 data
		add	hl,de
		ld	a,[hli]
		add	80
		ld	d,a
		ld	a,[hl]
		add	72
		ld	e,a
		pop	hl
		ld	[hl],d
		inc	l
		ld	[hl],e
		dec	l
		dec	l
		dec	l
		dec	l
		jr	creditfire6a


douse3:		ld	e,l
		inc	l
		inc	l
		inc	l
		inc	l
		inc	l
		ld	a,[hl]
		ld	l,e
		cp	END1to2
		jr	c,creditfire6a
fire6b:		ld	b,RECOVERING1
		jr	anyrecover
fire6c:		ld	b,RECOVERING2
anyrecover:	ld	[hl],6
		inc	l
		inc	l
		inc	l
		inc	l
		inc	l
		ld	[hl],b
		ret
creditfire6a:	push	hl
		call	creditflame
		pop	hl
fire6a:		ld	[hl],5
		ld	a,l
		add	5
		ld	l,a
		ld	[hl],KILL1
		ret


douse4:		inc	l
		inc	l
		ld	a,[hl]
		dec	l
		dec	l
		dec	a
		jr	z,creditfire6a
		dec	a
		jr	z,fire6b
		jr	fire6c

douse6:		ld	e,l
		inc	l
		inc	l
		inc	l
		inc	l
		inc	l
		ld	a,[hl]
		ld	l,e
		cp	RECOVERING1
		jr	c,fire6b
		jr	creditfire6a



launchfire:
		ld	e,a
		ld	d,0
		ld	hl,launchstarts
		add	hl,de
		ld	c,[hl]
		add	a
		add	a
		add	a
		ld	e,a
		ld	hl,stove_fire0
		add	hl,de
		ld	a,[hl]
		or	a
		ret	nz
		push	hl
		ld	a,l
		add	7
		ld	l,a
		ld	a,[hl]
		ld	hl,firesubs
		add	hl,de
.dec:		sub	[hl]
		jr	c,.decdone
		inc	hl
		inc	c
		jr	.dec
.decdone:	add	[hl]
		ld	d,a	;damage already done to this thing
		ld	a,[hl]
		pop	hl
		ld	a,c
		add	a
		add	255&FIRELISTBASE
		ld	c,a
		ld	a,0
		adc	FIRELISTBASE>>8
		ld	b,a
		ld	a,1
		ld	[hli],a	;+0 = mode = goingout
		ld	a,[bc]
		inc	bc
		ld	[hli],a	;+1 = take lo
		ld	a,[bc]
		ld	[hli],a ;+2 = take hi
		inc	l
		inc	l
		inc	l
		ld	[hl],d	;+6 = damage already done
		ld	a,SFX_STOVEEJECT
		call	InitSfx
		jp	decmeter
firesubs:	db	16,24,16,0,0,0,0,0
		db	24,24,24,16,0,0,0,0
		db	16,24,16,0,0,0,0,0
		db	16,32,16,0,0,0,0,0
;		db	8,8,8,16,16,0,0,0
;		db	16,16,16,16,0,0,0,0
launchstarts:	db	0,3,7,10
;launchstarts:	db	0,3,7,12


rechar:		ld	hl,stove_fire0
		call	rechar1
		ld	hl,stove_fire1
		call	rechar1
		ld	hl,stove_fire2
		call	rechar1
		ld	hl,stove_fire3
rechar1:	ld	a,l
		ldh	[hTmpLo],a
		add	7
		ld	l,a
		ld	a,[hl]
		push	af
		ld	[hl],0
		ldh	[hTmpHi],a
.rechar1lp:	ldh	a,[hTmpHi]
		sub	8
		jr	c,.rechared
		ldh	[hTmpHi],a
		ld	a,[hl]
		add	8
		ld	[hl],a
		push	hl
		call	dochar
		pop	hl
		jr	.rechar1lp
.rechared:	pop	af
		ld	[hl],a
		ret



dochar:		ld	hl,stove_fire0
		ldh	a,[hTmpLo]
		ld	e,a
		add	7
		ld	l,a
		ld	c,[hl]	;total damage
		ld	a,e
		ld	e,stove_fire0
		sub	e
;		sub	255&stove_fire0
		srl	a
		srl	a
		ld	hl,platforms
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,c
		sub	8
		srl	a
		ld	b,a
		srl	a
		srl	a
		add	b
		call	addahl
		ld	a,[hli]
		add	255&MAPORIG
		ld	e,a
		ld	a,[hli]
		adc	MAPORIG>>8
		ld	d,a
		ld	a,[hli]
		add	255&MAPORIG
		ld	c,a
		ld	a,[hli]
		ld	b,[hl]
		adc	MAPORIG>>8
		ld	h,a
		ld	l,c
		push	de
		push	hl
		call	copyb
		pop	hl
		pop	de
		ld	a,e
		add	255&MAPSIZE
		ld	e,a
		ld	a,d
		adc	MAPSIZE>>8
		ld	d,a
		ld	a,l
		add	255&MAPSIZE
		ld	l,a
		ld	a,h
		adc	MAPSIZE>>8
		ld	h,a
		call	copyb
		ret

copyb:		ld	c,b
.lp:		ld	a,[hli]
		ld	[de],a
		inc	e
		dec	c
		jr	nz,.lp
		ret



platforms:	dw	platform0,platform1,platform2,platform3


platform0:	dw	05+02*$20,23+02*$20
		db	2
		dw	05+03*$20,23+03*$20
		db	2
		dw	02+01*$20,20+01*$20
		db	3
		dw	02+02*$20,20+02*$20
		db	3
		dw	02+03*$20,20+03*$20
		db	3

platform1:	dw	13+01*$20,27+01*$20
		db	3
		dw	13+02*$20,27+02*$20
		db	3
		dw	13+03*$20,27+03*$20
		db	3
		dw	16+01*$20,30+01*$20
		db	1
		dw	16+02*$20,30+02*$20
		db	1
		dw	16+03*$20,30+03*$20
		db	1
		dw	17+01*$20,31+01*$20
		db	1
		dw	17+02*$20,31+02*$20
		db	1
		dw	17+03*$20,31+03*$20
		db	1

platform2:	dw	04+08*$20,22+08*$20
		db	1
		dw	04+09*$20,22+09*$20
		db	1
		dw	02+07*$20,20+07*$20
		db	2
		dw	02+08*$20,20+08*$20
		db	2
		dw	02+09*$20,20+09*$20
		db	2

platform3:	dw	15+08*$20,29+08*$20
		db	1
		dw	15+09*$20,29+09*$20
		db	1
		dw	16+06*$20,30+06*$20
		db	2
		dw	16+07*$20,30+07*$20
		db	2
		dw	16+08*$20,30+08*$20
		db	2
		dw	16+09*$20,30+09*$20
		db	2


flickerbarrels:	ldh	a,[stove_phase]
		srl	a
		srl	a
		ret	nc
		ldh	a,[stove_fire0]
		cp	1
		jr	c,.noflicker0
		ldh	a,[stove_fire0+7]
		cp	40
		jr	c,.noflicker0
		ld	de,MAPCOPY+00+02*$20
		call	copywhitebarrel
.noflicker0:
		ldh	a,[stove_fire1]
		cp	1
		jr	c,.noflicker1
		ldh	a,[stove_fire1+7]
		cp	72
		jr	c,.noflicker1
		ld	de,MAPCOPY+18+02*$20
		call	copywhitebarrel
.noflicker1:
		ldh	a,[stove_fire2]
		cp	1
		jr	c,.noflicker2
		ldh	a,[stove_fire2+7]
		cp	40
		jr	c,.noflicker2
		ld	de,MAPCOPY+00+08*$20
		call	copywhitebarrel
.noflicker2:
		ldh	a,[stove_fire3]
		cp	1
		jr	c,.noflicker3
		ldh	a,[stove_fire3+7]
		cp	48
		jr	c,.noflicker3
		ld	de,MAPCOPY+18+08*$20
		call	copywhitebarrel
.noflicker3:		ret

copywhitebarrel:
		ld	hl,MAPORIG+24+06*$20
		push	de
		call	.cwb1
		pop	hl
		ld	de,ATTRCOPY-MAPCOPY
		add	hl,de
		ld	d,h
		ld	e,l
		ld	hl,ATTRCOPY+24+06*$20
.cwb1:		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hld]
		ld	[de],a
		dec	e
		ld	bc,$20
		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		add	hl,bc
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hl]
		ld	[de],a
		ret

sneezeframes:
SNEEZE1		EQU	@-sneezeframes
		db	1,2,3,2,2,3,3,4,3,3,4,4,5,6,6,5,5,6,6,7,8,9,10,0
SNEEZE2		EQU	@-sneezeframes
		db	1,2,3,2,2,3,3,4,3,3,4,4,5,6,6,5,5,6,6,7,8,9,10
		db	7,8,9,10,0
SNEEZE3		EQU	@-sneezeframes
		db	1,2,3,2,2,3,3,4,3,3,4,4,5,6,6,5,5,6,6
		db	7,8,9,10
		db	7,8,9,10
		db	7,8,9,10
		db	0

sneezes:	db	SNEEZE1+1
		db	SNEEZE1+1
		db	SNEEZE2+1
		db	SNEEZE3+1

trysneeze:	ldh	a,[stove_phase]
		srl	a
		ret	nc
		ld	hl,stove_sneeze
		ld	a,[hl]
		or	a
		jr	z,.notsneezing
		inc	[hl]
		dec	a
		ld	c,a
		ld	hl,sneezeframes
		call	addahl
		ld	a,[hl]
		or	a
		jr	z,.sneezeover
		dec	a
		ldh	[stove_stovefrm],a
		cp	7-1
		ret	nz
		call	random
		ld	b,4
.look:		and	3*8
		ld	e,a
		ld	d,0
		ld	hl,stove_fire0
		add	hl,de
		ld	a,[hl]
		or	a
		jr	z,.found
		ld	a,e
		add	8
		dec	b
		jr	nz,.look
		ret

.found:		ld	a,e
		srl	a
		srl	a
		srl	a
		jp	launchfire
.sneezeover:	xor	a
		ldh	[stove_sneeze],a
		ldh	[stove_stovefrm],a
		ret
.notsneezing:
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		jr	nc,.cansneeze	;
		ldh	a,[stove_meter]
		or	a
		ret	z
.cansneeze:	ldh	a,[stove_spurtrnd]
		ld	b,a
		call	random
		cp	b
		ret	nc
		call	random
		and	3
		ld	c,a
		ld	a,[wSubLevel]	;Special mode
		cp	3		;
		ld	a,c		;
		jr	c,.aok2		;
		or	2
.aok2:		ld	hl,sneezes
		call	addahl
		ld	a,[hl]
		ldh	[stove_sneeze],a
		ret

stovewinframes:	db	11
		db	12
		db	13
		db	14,14,14,14
		db	0


stovewinanim:	ld	hl,stove_endcnt
		ld	a,[hl]
		or	a
		ret	z
		inc	[hl]
		dec	a
		srl	a
		ld	hl,stovewinframes
		call	addahl
		ld	a,[hl]
		or	a
		jr	z,.stovewon
		dec	a
		ldh	[stove_stovefrm],a
		ret

.stovewon:	ld	hl,stove_flags
		set	STOVEFLG_WON,[hl]
		ret



SPAREWATER	EQU	20+17*$20

addwater:	ldh	a,[stove_water]
		cp	MAXWATER
		ret	z
		push	bc
		inc	a
		ldh	[stove_water],a
		add	a
		cpl
		inc	a
		add	255&(SPAREWATER+MAPORIG)
		ld	e,a
		ld	d,(SPAREWATER+MAPORIG)>>8
		ld	hl,MAPORIG+SPAREWATER+5
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hld]
		ld	[de],a
		dec	e
		ld	bc,ATTRORIG-MAPORIG
		add	hl,bc
		ld	a,c
		add	e
		ld	e,a
		ld	a,b
		adc	d
		ld	d,a
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hl]
		ld	[de],a
		pop	bc
		ret
subwater:	ldh	a,[stove_water]
		or	a
		ret	z
		dec	a
		ldh	[stove_water],a
		inc	a
		add	a
		cpl
		inc	a
		add	255&(SPAREWATER+MAPORIG)
		ld	e,a
		ld	d,(SPAREWATER+MAPORIG)>>8
		ld	hl,MAPORIG+SPAREWATER+7
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hld]
		ld	[de],a
		dec	e
		ld	bc,ATTRORIG-MAPORIG
		add	hl,bc
		ld	a,c
		add	e
		ld	e,a
		ld	a,b
		adc	d
		ld	d,a
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hl]
		ld	[de],a
		ret


METERLOC	EQU	00+17*$20
METERLEN	EQU	10

creditflame:	ld	a,[wSubLevel]
		cp	3
		ret	c
		call	IncScore
		ldh	a,[stove_meter]
		cp	255
		ret	z
		inc	a
		ldh	[stove_meter],a
		jr	paintmeter

decmeter:	ld	a,[wSubLevel]	;Special
		cp	3		;
		ret	nc		;used to inc flame here
		ldh	a,[stove_meter]
		or	a
		jr	z,paintmeter
		dec	a
		ldh	[stove_meter],a
paintmeter:	ld	hl,ATTRORIG+METERLOC
		ld	a,[ATTRORIG+METERLOC+20]
		ld	c,METERLEN
.attr:		ld	[hli],a
		dec	c
		jr	nz,.attr
		ldh	a,[stove_meter]
		add	a
		ld	b,a
		ld	hl,MAPORIG+METERLOC
		ld	c,METERLEN
.map:		ld	a,b
		cp	5
		jr	c,.aok
		ld	a,4
.aok:		add	255&(MAPORIG+METERLOC+20)
		ld	e,a
		ld	d,(MAPORIG+METERLOC+20)>>8
		ld	a,[de]
		ld	[hli],a
		ld	a,b
		sub	4
		jr	nc,.aok2
		xor	a
.aok2:		ld	b,a
		dec	c
		jr	nz,.map
		ret


stvtbl:
		db	FSSIZE_STV001CHR>>4
		dw	IDX_STV001CHR
		db	FSSIZE_STV002CHR>>4
		dw	IDX_STV002CHR
		db	FSSIZE_STV003CHR>>4
		dw	IDX_STV003CHR
		db	FSSIZE_STV004CHR>>4
		dw	IDX_STV004CHR
		db	FSSIZE_STV005CHR>>4
		dw	IDX_STV005CHR
		db	FSSIZE_STV006CHR>>4
		dw	IDX_STV006CHR
		db	FSSIZE_STV007CHR>>4
		dw	IDX_STV007CHR
		db	FSSIZE_STV008CHR>>4
		dw	IDX_STV008CHR
		db	FSSIZE_STV009CHR>>4
		dw	IDX_STV009CHR
		db	FSSIZE_STV010CHR>>4
		dw	IDX_STV010CHR
		db	FSSIZE_STV011CHR>>4
		dw	IDX_STV011CHR
		db	FSSIZE_STV012CHR>>4
		dw	IDX_STV012CHR
		db	FSSIZE_STV013CHR>>4
		dw	IDX_STV013CHR
		db	FSSIZE_STV014CHR>>4
		dw	IDX_STV014CHR

		db	FSSIZE_STBW001CHR>>4
		dw	IDX_STBW001CHR
		db	FSSIZE_STBW002CHR>>4
		dw	IDX_STBW002CHR
		db	FSSIZE_STBW003CHR>>4
		dw	IDX_STBW003CHR
		db	FSSIZE_STBW004CHR>>4
		dw	IDX_STBW004CHR
		db	FSSIZE_STBW005CHR>>4
		dw	IDX_STBW005CHR
		db	FSSIZE_STBW006CHR>>4
		dw	IDX_STBW006CHR
		db	FSSIZE_STBW007CHR>>4
		dw	IDX_STBW007CHR
		db	FSSIZE_STBW008CHR>>4
		dw	IDX_STBW008CHR
		db	FSSIZE_STBW009CHR>>4
		dw	IDX_STBW009CHR
		db	FSSIZE_STBW010CHR>>4
		dw	IDX_STBW010CHR
		db	FSSIZE_STBW011CHR>>4
		dw	IDX_STBW011CHR
		db	FSSIZE_STBW012CHR>>4
		dw	IDX_STBW012CHR
		db	FSSIZE_STBW013CHR>>4
		dw	IDX_STBW013CHR
		db	FSSIZE_STBW014CHR>>4
		dw	IDX_STBW014CHR

pottslist:	dw	potts0,potts1,potts2
		dw	potts3,potts4,potts5
;		dw	potts6

potts0:		db	1<<JOY_R,3
		dw	potts03
		db	1<<JOY_U,1
		dw	potts01
		db	0
potts1:
;		db	(1<<JOY_R)|(1<<JOY_U),6
;		dw	potts16
		db	1<<JOY_R,4
		dw	potts14
		db	1<<JOY_U,2
		dw	potts12
		db	1<<JOY_D,0
		dw	potts10
		db	0
potts2:
;		db	(1<<JOY_R)|(1<<JOY_D),6
;		dw	potts26
		db	1<<JOY_R,5
		dw	potts25
		db	1<<JOY_D,1
		dw	potts21
		db	0
potts3:		db	1<<JOY_L,0
		dw	potts30
		db	1<<JOY_U,4
		dw	potts34
		db	0
potts4:
;		db	(1<<JOY_L)|(1<<JOY_U),6
;		dw	potts46
		db	1<<JOY_L,1
		dw	potts41
		db	1<<JOY_U,5
		dw	potts45
		db	1<<JOY_D,3
		dw	potts43
		db	0
potts5:
;		db	(1<<JOY_L)|(1<<JOY_D),6
;		dw	potts56
		db	1<<JOY_L,2
		dw	potts52
		db	1<<JOY_D,4
		dw	potts54
		db	0
;potts6:		db	(1<<JOY_R)|(1<<JOY_U),5
;		dw	potts65
;		db	(1<<JOY_L)|(1<<JOY_U),2
;		dw	potts62
;		db	(1<<JOY_L)|(1<<JOY_D),1
;		dw	potts61
;		db	(1<<JOY_R)|(1<<JOY_D),4
;		dw	potts64
;		db	0


potts10:	dw	177,174,173,172,171,170,169,168,0
potts30:	dw	310,311,312,315,316,317,318,319
		dw	320,321,322,323,0


potts21:	dw	185,184,183,182,181,180,177,0
potts01:	dw	168,170,171,172,173,174,175,177,0
potts61:	dw	212,211,210,209,208,207,206,205,204,203,202,0

potts52:	dw	44,45,46,49,50,51,52,53,54,56,0

potts12:	dw	177,180,181,182,183,184,185,0
potts03:	dw	270,271,272,275,276,277,278,279,280,281
		dw	282,283,0

potts43:	dw	32,29,28,27,26,25,24,23,0
potts34:	dw	23,25,26,27,28,29,30,31,32,0

potts64:	dw	68,67,66,65,64,63,62,61,60,59,58,57,0

potts54:	dw	42,39,38,37,36,35,34,0
potts45:	dw	32,35,36,37,38,39,40,42,0

potts25:	dw	189,190,191,194,195,196,197,198,199,0

potts41:	dw	341,342,343,346,347,348,349,350
		dw	351,352,353,0
potts14:	dw	326,327,328,331,332,333,334,335,336
		dw	337,338,0

potts46:	dw	57,58,59,60,61,62,63,64,65,67,68,0

potts16:	dw	202,203,204,205,206,207,208,209,210,211,212,213,0

potts56:	dw	78,77,76,75,74,73,72,71,70,69,68,0

potts65:	dw	68,69,70,71,72,73,74,75,76,77,78,0

potts62:	dw	213,214,215,216,217,218,219,220,221,222,223,0
potts26:	dw	223,222,221,220,219,218,217,216,215,214,213,0

pottspour1a:	dw	224,225,226,227,228,229,230,231,232,0
pottspour1b:	dw	233,234,235,236,237,238,239,240,241,242,243,244,0
pottspour2a:	dw	245,246,247,248,249,250,251,252,253,254,255,256,0
pottspour2b:	dw	257,258,259,260,261,262,263,264,265,266,267,268,269,0
pottspour4a:	dw	79,80,81,82,83,84,85,86,87,0
pottspour4b:	dw	88,89,90,91,92,93,94,95,96,97,98,99,0
pottspour5a:	dw	100,101,102,103,104,105,106,107,108,109,110,111,0
pottspour5b:	dw	112,113,114,115,116,117,118,119,120,121,122,123,124,0
pottspour5c:	dw	125,126,127,128,129,130,131,132,133,134,135,136,137,0
pottspour6:	dw	138,139,140,141,142,143,144,145,0


pottsfill0:	dw	146,147,148,149,150,151,152,153,154,155,156,157
		dw	158,159,160,161,162,163,164,165,166,167,168,0
pottsfill3:	dw	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
		dw	21,22,23,0

pottsbase:	dw	23,0




stovetob:	db	16,2,pick0a,pickab,0
stovetod:	db	24,3,pick0a,pickac,pickcd,0
stovetof:	db	16,2,pick0a,pickae,pickef,0
stovetop:	db	24,3,pick0o,pickop,0
stovetor:	db	24,1,pick0o,pickoq,pickqr,0
stovetot:	db	24,1,pick0o,pickos,pickst,0
stovetov:	db	16,2,pick0o,pickou,pickuv,0
stovetoh:	db	16,1,pick0g,pickgh,0
;stovetoi:	db	8,1,pick0g,pickgi,0
stovetok:	db	24,2,pick0g,pickgj,pickjk,0
;stovetol:	db	16,2,pick0g,pickgj,pickjl,0
stoveton:	db	16,2,pick0g,pickgm,pickmn,0
stovetox:	db	16,1,pick0w,pickwx,0
stovetoz:	db	32,2,pick0w,pickwy,pickyz,0
;stoveto1:	db	16,2,pick0w,pickwy,picky1,0
stoveto3:	db	16,2,pick0w,pickw2,pick23,0

;stovetob:	db	16,2,pick0a,pickab,0
;stovetod:	db	24,3,pick0a,pickac,pickcd,0
;stovetof:	db	16,2,pick0a,pickae,pickef,0
;stovetop:	db	24,3,pick0o,pickop,0
;stovetor:	db	24,1,pick0o,pickoq,pickqr,0
;stovetot:	db	24,1,pick0o,pickos,pickst,0
;stovetov:	db	16,2,pick0o,pickou,pickuv,0
;stovetoh:	db	8,1,pick0g,pickgh,0
;stovetoi:	db	8,1,pick0g,pickgi,0
;stovetok:	db	8,2,pick0g,pickgj,pickjk,0
;stovetol:	db	16,2,pick0g,pickgj,pickjl,0
;stoveton:	db	16,2,pick0g,pickgm,pickmn,0
;stovetox:	db	16,1,pick0w,pickwx,0
;stovetoz:	db	16,2,pick0w,pickwy,pickyz,0
;stoveto1:	db	16,2,pick0w,pickwy,picky1,0
;stoveto3:	db	16,2,pick0w,pickw2,pick23,0



stovefiredata:
stove0a:	dw	1
		db	14-1
stoveab:	dw	14
		db	25-14
stoveac:	dw	26
		db	43-26
stovecd:	dw	43
		db	55-43
stoveae:	dw	56
		db	97-56
stoveef:	dw	97
		db	108-97
stove0g:	dw	109
		db	120-109
stovegh:	dw	120
		db	131-120
stovegi:	dw	132
		db	143-132
stovegj:	dw	144
		db	153-144
stovejk:	dw	153
		db	165-153
stovejl:	dw	166
		db	178-166
stovegm:	dw	179
		db	205-179
stovemn:	dw	205
		db	216-205
stove0o:	dw	217
		db	230-217
stoveop:	dw	230
		db	242-230
stoveoq:	dw	243
		db	270-243
stoveqr:	dw	270
		db	282-270
stoveos:	dw	283
		db	318-283
stovest:	dw	318
		db	330-318
stoveou:	dw	331
		db	374-331
stoveuv:	dw	374
		db	385-374
stove0w:	dw	386
		db	397-386
stovewx:	dw	397
		db	408-397
stovewy:	dw	409
		db	420-409
stoveyz:	dw	420
		db	432-420
stovey1:	dw	433
		db	444-433
stovew2:	dw	445
		db	472-445
stove23:	dw	472
		db	483-472





fireframes:
		include	"res/dave/stove/fire.as2"
pottsframes:
		include	"res/dave/stove/potts.as2"

stovepal:	incbin	"res/dave/stove/stovebg.rgb"
;stovemap:	incbin	"res/dave/stove/stovebg.map"
stoveframes:	incbin	"res/dave/stove/stv.bin"
;stovebwmap:	incbin	"res/dave/stove/stovebw.map"

stove_end::
