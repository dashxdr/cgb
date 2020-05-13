; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SPIT.ASM                                                              **
; **                                                                       **
; ** Last modified : 990327 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"spit",CODE,BANK[6]
		section 6

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


spit_top::


SONG_SPIT	EQU	10
SFX_ZIGRISE	EQU	60
SFX_ZIGFALL	EQU	61
SFX_SPIT	EQU	62

SPITSHOWTIME	EQU	60

MAPSIZE		EQU	32*18

GASTONMAP	EQU	$e000-MAPSIZE*2
GASTONATTR	EQU	$e000-MAPSIZE*1
JUDGE1MAP	EQU	$e000-MAPSIZE*4
JUDGE1ATTR	EQU	$e000-MAPSIZE*3
JUDGE2MAP	EQU	GASTONMAP
JUDGE2ATTR	EQU	GASTONATTR
MAPCOPY		EQU	$e000-MAPSIZE*6
ATTRCOPY	EQU	$e000-MAPSIZE*5
JUDGE3MAP	EQU	$e000-MAPSIZE*8
JUDGE3ATTR	EQU	$e000-MAPSIZE*7


SPITFLG_FIRST	EQU	0
SPITFLG_WON	EQU	1
SPITFLG_LAUNCH	EQU	2
SPITFLG_DONE	EQU	3

spit_mode	EQUS	"hTemp48+00"
spit_xscroll	EQUS	"hTemp48+01"
spit_flags	EQUS	"hTemp48+02"
spit_phase	EQUS	"hTemp48+03"
spit_animlo	EQUS	"hTemp48+04"
spit_animhi	EQUS	"hTemp48+05"
spit_animcnt	EQUS	"hTemp48+06"
spit_which	EQUS	"hTemp48+07"
spit_star	EQUS	"hTemp48+08"
spit_rock	EQUS	"hTemp48+09"
spit_gaston	EQUS	"hTemp48+10"
spit_lastx	EQUS	"hTemp48+11"
spit_lasty	EQUS	"hTemp48+12"

gastonchew:

	IFEQ	VERSION_JAPAN
		db	1,1,1,1,1,1,2,3,3,3,3,4,4,5,5,5,5,5,5,0
GASTONSPIT	EQU	@-gastonchew
		db	6,6,7,7,8,8,1,1,0
	ELSE
		db	1,1,1,2,2,2,3,3,3,2,2,2,0
GASTONSPIT	EQU	@-gastonchew
		db	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0
	ENDC


Spit::
.pickstar:	call	random
		and	7
		cp	5
		jr	nc,.pickstar
		ldh	[spit_star],a
		call	spit_setup

spitloop:	call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,spitpause
		ldh	a,[spit_flags]
		bit	SPITFLG_DONE,a
		jp	nz,spitdone

		call	InitFigures64
		call	spitanim
		call	spitgaston
		call	spitmakemap
		call	spitrock
		call	spitcopy
		ldh	a,[spit_xscroll]
		and	7
		ldh	[hVblSCX],a
		xor	a
		ldh	[hVblSCY],a
		ld	a,255
		ldh	[hPosFlag],a
		call	spitflip
		call	OutFigures
		ld	hl,spit_flags
		bit	SPITFLG_FIRST,[hl]
		jr	z,.nofade
		res	SPITFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.nofade:	ld	a,16
		call	AccurateWait
		jp	spitloop



spitpause:	call	spit_shutdown
		call	PauseMenu_B
		call	spit_setup
		jp	spitloop
spitdone:	call	spit_shutdown
		ret


coinpositions:	db	37,66-2
		db	38,64-2
		db	39,61-1


spitgaston:
		ldh	a,[spit_xscroll]
		cp	64
		ret	nc
		ldh	a,[spit_gaston]
.top:		ld	hl,gastonchew
		call	addahl
		ld	a,[hl]
		or	a
		jr	nz,.aok
	IFEQ	VERSION_JAPAN
		ld	a,9
	ELSE
		xor	a
	ENDC
		ldh	[spit_gaston],a
		jr	.top
.aok:		dec	a
	IFEQ	VERSION_JAPAN
		push	af
		add	255&IDX_GHEADB
		ld	c,a
		ld	a,0
		adc	IDX_GHEADB>>8
		ld	b,a
		ld	de,$1910
		ldh	a,[spit_xscroll]
		cpl
		add	d
		ld	d,a
		ld	a,[wGroup4]
		call	AddFigure
		pop	af
		add	255&IDX_GHEADA
		ld	c,a
		ld	a,0
		adc	IDX_GHEADA>>8
		ld	b,a
		ld	de,$1910
		ldh	a,[spit_xscroll]
		cpl
		add	d
		ld	d,a
		ld	a,[wGroup3]
		call	AddFigure
	ELSE
		push	af
		add	255&IDX_ARM
		ld	c,a
		ld	a,0
		adc	IDX_ARM>>8
		ld	b,a
		ld	de,$0434
		ldh	a,[spit_xscroll]
		cpl
		add	d
		ld	d,a
		ld	a,[wGroup4]
		call	AddFigure
		pop	bc
		ldh	a,[spit_gaston]
		cp	GASTONSPIT
		jr	nc,.nodup
		ld	a,b
		add	a
		ld	hl,coinpositions
		call	addahl
		ldh	a,[spit_xscroll]
		cpl
		add	[hl]
		ld	d,a
		inc	hl
		ld	e,[hl]
		ld	bc,IDX_COIN+2
		ld	a,[wGroup1]
		call	AddFigure
.nodup:
	ENDC


		ldh	a,[spit_phase]
		and	1
		ret	nz
		ldh	a,[spit_xscroll]
		or	a
		ret	nz
		ld	hl,spit_gaston
		ld	a,[hl]
		inc	[hl]
	IFEQ	VERSION_JAPAN
		cp	GASTONSPIT+2
	ELSE
		cp	GASTONSPIT
	ENDC
		jr	nz,.nopucker
		ld	hl,spit_flags
		res	SPITFLG_LAUNCH,[hl]
.nopucker:	ret





;spitanim modes:
;0 showing which is the target spittoon, scrolling gaston in
;1 zigzag bar, gaston chewing his cud
;2 Spit animation/scroll
;3 If went in, spittoon rocking
;4 judges showing their cards
;5 Final delay for ending if lose

spitrestart:	xor	a
		ldh	[spit_rock],a
		ldh	[spit_mode],a
		ldh	[spit_animcnt],a
		ldh	[spit_gaston],a
		ld	hl,spit_flags
		res	SPITFLG_WON,[hl]
		res	SPITFLG_LAUNCH,[hl]
spitanim:	ldh	a,[spit_mode]
		or	a
		jp	z,spitshow
		dec	a
		jp	z,spitzigzag
		dec	a
		jp	z,spitting
		dec	a
		jp	z,spitrocking
		dec	a
		jp	z,spitjudges
		dec	a
		jp	z,spitending
		ret

spitshow:	ld	hl,spit_animcnt
		ld	a,[hl]
		inc	[hl]
		cp	SPITSHOWTIME+1
		jr	z,.endshow
		sub	SPITSHOWTIME-20
		jr	c,.spithold
		add	a
		add	a
		add	a
		cpl
		add	160+1
		ldh	[spit_xscroll],a
		ret
.spithold:	ld	a,160
		ldh	[spit_xscroll],a
		ret
.endshow:	ld	a,1
		ldh	[spit_mode],a
		xor	a
		ldh	[spit_animcnt],a
		jp	spitanim

spitrocking:	ld	hl,spit_animcnt
		ld	a,[hl]
		cp	4*8-8
		jr	c,.stillrocking
		jp	tojudges
.stillrocking:	xor	a
		ldh	[spit_rock],a
		ld	a,[hl]
		add	8
		inc	[hl]
		srl	a
		srl	a
		srl	a
		srl	a
		ret	nc
		ld	e,a
		ld	hl,IDX_ROCK1PKG	;rock1pkg
		ld	bc,IDX_ROCK2PKG	;rock2pkg
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.bchlok2
		ld	hl,IDX_ROCK1BWPKG	;rock1bwpkg
		ld	bc,IDX_ROCK2BWPKG	;rock2bwpkg
.bchlok2:
		ldh	a,[spit_which]
		srl	a
		ld	d,a
		ldh	a,[spit_star]
		cp	d
		jr	nz,.bchlok
		ld	a,2
		ld	[wSubStage],a
		ld	hl,IDX_SROCK1PKG	;srock1pkg
		ld	bc,IDX_SROCK2PKG	;srock2pkg
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.bchlok
		ld	hl,IDX_SROCK1BWPKG	;srock1bwpkg
		ld	bc,IDX_SROCK2BWPKG	;srock2bwpkg
.bchlok:	srl	e
		ld	e,2
		jr	nc,.hlok
		ld	h,b
		ld	l,c
		dec	e
.hlok:		ld	a,d
		add	a
		add	a
		add	e
		ldh	[spit_rock],a
		ld	de,$9700
		ld	c,16
		call	DumpChrsInFileSys
		ret

spitrock:	ldh	a,[spit_rock]
		or	a
		ret	z
		ld	hl,MAPCOPY+00+13*$20-2
		call	addahl
		ld	de,32-3
		ld	a,$70
		ld	c,4
.y:		ld	[hli],a
		inc	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		inc	a
		ld	[hl],a
		inc	a
		add	hl,de
		dec	c
		jr	nz,.y
		ret

spitending:
	IF	VERSION_JAPAN
		ldh	a,[spit_lastx]
		ld	d,a
		ldh	a,[spit_lasty]
		ld	e,a
		ld	bc,IDX_COIN+4
		ld	a,[wGroup1]
		call	AddFigure
	ENDC

		ld	hl,spit_animcnt
		inc	[hl]
		ld	a,[hl]
		cp	20
		ret	nz
		ld	hl,spit_flags
		set	SPITFLG_DONE,[hl]
		ret

tojudges:	xor	a
		ldh	[spit_animcnt],a
		ldh	[spit_rock],a
		ld	a,4
		ldh	[spit_mode],a
		ld	hl,IDX_JUDGE2CHR	;judge2chr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok1
		ld	hl,IDX_JUDGE2BWCHR	;judge2bwchr
.hlok1:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$90
		call	DumpChrs
		ld	hl,IDX_JUDGE2MAP	;judge2map
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok2
		ld	hl,IDX_JUDGE2BWMAP	;judge2bwmap
.hlok2:		ld	de,JUDGE2MAP
		ld	c,$80
		call	spitmapfix
		xor	a
		ldh	[hVbl8],a
		jp	spitanim

getgrimmace:	ld	hl,IDX_JUDGE3CHR	;judge3chr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok1
		ld	hl,IDX_JUDGE3BWCHR	;judge3bwchr
.hlok1:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$9000
		ld	c,$10
		call	DumpChrs
		ld	hl,IDX_JUDGE3MAP	;judge3map
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok2
		ld	hl,IDX_JUDGE3BWMAP	;judge3bwmap
.hlok2:		ld	de,JUDGE3MAP
		ld	c,0
		call	spitmapfix
		xor	a
		ldh	[hVbl8],a
		ret
copygrimmace:	ld	hl,JUDGE3MAP+8+2*$20
		ld	de,JUDGE1MAP+8+2*$20
		call	.cg
		ld	hl,JUDGE3ATTR+8+2*$20
		ld	de,JUDGE1ATTR+8+2*$20

.cg:		ld	c,4
.cgy:		ld	b,4
.cgx:		ld	a,[hli]
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.cgx
		ld	a,l
		add	32-4
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ld	a,e
		add	32-4
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.cgy
		ret


spitjudges:	ldh	a,[spit_animcnt]
		inc	a
		ldh	[spit_animcnt],a
		ld	b,a
		and	15
		ret	nz
		ld	a,b
		cp	64
		jr	c,.newjudge
		ld	hl,spit_flags
		set	SPITFLG_DONE,[hl]
		ret
.newjudge:	swap	a
		dec	a
		call	swapjudge
		ret

swapjudge:	ld	b,6
		ld	de,0
		or	a
		jr	z,.take
		inc	b
		ld	e,6
		dec	a
		jr	z,.take
		ld	e,13
.take:		push	de
		call	.swap1
		pop	de
		ld	hl,MAPSIZE
		add	hl,de
		ld	d,h
		ld	e,l
;b=# of chars wide (6 or 7)
.swap1:
		ld	hl,JUDGE1MAP
		add	hl,de
		ld	a,e
		add	255&JUDGE2MAP
		ld	e,a
		ld	a,d
		adc	JUDGE2MAP>>8
		ld	d,a
		ld	a,32
		sub	b
		ld	c,a
		ld	a,8
.s1y:		ldh	[hTmpLo],a
		push	bc
.s1x:		ld	c,[hl]
		ld	a,[de]
		ld	[hli],a
		ld	a,c
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.s1x
		pop	bc
		ld	a,l
		add	c
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.s1y
		ret		



spitwhich:
		IFEQ	VERSION_JAPAN
		db	0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,12
		ELSE
		db	0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10
		ENDC


spitzigzag:	ldh	a,[spit_animcnt]
		or	a
		jr	nz,.norise
		ld	a,SFX_ZIGRISE
		call	InitSfx
		jr	.somesfx
.norise:	cp	24
		jr	nz,.nofall
		ld	a,SFX_ZIGFALL
		call	InitSfx
.nofall:
.somesfx:

		ld	hl,spit_animcnt
		ld	a,[hl]
		cp	24
		jr	c,.aok
		cpl
		add	47+1
.aok:		ld	c,a
		ld	a,[wJoy1Hit]
		and	(1<<JOY_A)|(1<<JOY_B)
		jr	z,.stillzigzag
		ld	[hl],0
		ld	a,GASTONSPIT
		ldh	[spit_gaston],a
		ld	hl,spit_flags
		set	SPITFLG_LAUNCH,[hl]
		ld	a,c
		add	LOW(spitwhich)
		ld	c,a
		ld	a,0
		adc	HIGH(spitwhich)
		ld	b,a
		ld	a,[bc]
		ldh	[spit_which],a
		bit	0,a
		jr	z,.notin
		set	SPITFLG_WON,[hl]
.notin:		add	a
		add	a
		ld	hl,spitseqs
		call	addahl
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		dec	de
		ld	a,e
		ldh	[spit_animlo],a
		ld	a,d
		ldh	[spit_animhi],a
		ld	a,[hli]
		sub	e
		ldh	[spit_animcnt],a
		ld	a,2
		ldh	[spit_mode],a
		ld	a,SFX_SPIT
		call	InitSfx
		jp	spitanim

.stillzigzag:	inc	[hl]
		ld	a,[hl]
		cp	48
		jr	c,.mok
		ld	[hl],0
.mok:		ld	a,c
		add	a
		add	a
		add	c
		add	42
		ld	d,a
		ld	e,144-4
		ld	bc,IDX_BAR
		ld	a,[wGroup2]
		call	AddFigure
		ret

spitting:	ldh	a,[spit_flags]
		bit	SPITFLG_LAUNCH,a
		ret	nz
		ld	hl,spit_animcnt
		ld	a,[hl]
		or	a
		jr	nz,.stillspitting
		ldh	a,[spit_flags]
		bit	SPITFLG_WON,a
		jr	z,.nowin
		ldh	a,[spit_xscroll]
		cp	160
		jr	nz,.stillscrolling
		ld	a,1
		ld	[wSubStage],a
		ld	a,3
		ldh	[spit_mode],a
		jp	spitanim
.nowin:		xor	a
		ldh	[spit_animcnt],a
		ld	a,5
		ldh	[spit_mode],a
		jp	spitending
.stillscrolling:
		add	8
		cp	160
		jr	c,.aok
		ld	a,160
.aok:		ldh	[spit_xscroll],a
		ret
.stillspitting:	dec	[hl]
		ldh	a,[spit_animlo]
		ld	l,a
		ldh	a,[spit_animhi]
		ld	h,a
		inc	hl
		ld	a,l
		ldh	[spit_animlo],a
		ld	a,h
		ldh	[spit_animhi],a
		dec	hl
		ld	a,l
	IFEQ	VERSION_JAPAN
GRIMFRAME	EQU	307
	ELSE
GRIMFRAME	EQU	2000
	ENDC

		sub	255&GRIMFRAME
		ld	a,h
		sbc	GRIMFRAME>>8
		push	af
		add	hl,hl
		add	hl,hl
		ld	de,spitframes
		add	hl,de
		ld	a,[hli]
		ld	[spit_xscroll],a
		ld	a,[hli]
	IFEQ	VERSION_JAPAN
		add	255&IDX_SPIT
		ld	c,a
		ld	a,0
		adc	IDX_SPIT>>8
	ELSE
		add	255&IDX_COIN
		ld	c,a
		ld	a,0
		adc	IDX_COIN>>8
	ENDC
		ld	b,a
		ld	a,[hli]
		add	80
		ld	d,a
		ldh	[spit_lastx],a
		ld	a,[hl]
		add	72
		ld	e,a
		ldh	[spit_lasty],a
		ld	a,[wGroup1]
		call	AddFigure
		pop	af
		ret	c
		jp	copygrimmace


spitflip:	ldh	a,[spit_phase]
		inc	a
		ldh	[spit_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret


spitcopy:	ld	hl,MAPCOPY
		ldh	a,[spit_phase]
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

spit_setup:	ld	a,SONG_SPIT
		call	InitTunePref
		ld	a,%10000111
		ldh	[hVblLCDC],a
		ld	hl,spit_flags
		set	SPITFLG_FIRST,[hl]

		call	InitGroups
		ld	hl,PAL_BAR
		call	AddPalette
		ld	[wGroup2],a
	IFEQ	VERSION_JAPAN
		ld	hl,PAL_SPIT
		call	AddPalette
		ld	[wGroup1],a
		ld	hl,PAL_GHEADA
		call	AddPalette
		or	$10
		ld	[wGroup3],a
		ld	hl,PAL_GHEADB
		call	AddPalette
		or	$10
		ld	[wGroup4],a
	ELSE
		ld	hl,PAL_COIN
		call	AddPalette
		ld	[wGroup1],a
		ld	hl,PAL_ARM
		call	AddPalette
		or	$10
		ld	[wGroup4],a
	ENDC

		ld	hl,spitpal
		call	LoadPalHL

		ld	hl,IDX_JUDGE1CHR	;judge1chr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok1
		ld	hl,IDX_JUDGE1BWCHR	;judge1bwchr
.hlok1:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$9100
		ld	c,$60
		call	DumpChrs
		ld	hl,IDX_JUDGE1MAP	;judge1map
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok2
		ld	hl,IDX_JUDGE1BWMAP	;judge1bwmap
.hlok2:		ld	de,JUDGE1MAP
		ld	c,$10
		call	spitmapfix

		ldh	a,[spit_mode]
		cp	4
		jr	nz,.nojudge2

		ld	hl,IDX_JUDGE2CHR	;judge2chr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok3
		ld	hl,IDX_JUDGE2BWCHR	;judge2bwchr
.hlok3:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$90
		call	DumpChrs
		ld	hl,IDX_JUDGE2MAP	;judge2map
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok4
		ld	hl,IDX_JUDGE2BWMAP	;judge2bwmap
.hlok4:		ld	de,JUDGE2MAP
		ld	c,$80
		call	spitmapfix
		ldh	a,[spit_animcnt]
		ld	b,a
		ld	c,0
.swapagain:	ld	a,b
		sub	16
		ld	b,a
		jr	c,.swapped
		push	bc
		ld	a,c
		call	swapjudge
		pop	bc
		inc	c
		ld	a,c
		cp	3
		jr	c,.swapagain
.swapped:	jr	.yesjudge2
.nojudge2:
	IFEQ	VERSION_JAPAN
		ld	hl,IDX_GASTONCHR	;gastonchr
	ELSE
		ld	hl,IDX_GASTNWCHR	;gastnwchr
	ENDC
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok5
	IFEQ	VERSION_JAPAN
		ld	hl,IDX_GASTONBWCHR	;gastonbwchr
	ELSE
		ld	hl,IDX_GASTNWBWCHR	;gastnwbwchr
	ENDC
.hlok5:		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,$90
		call	DumpChrs
	IFEQ	VERSION_JAPAN
		ld	hl,IDX_GASTONMAP	;gastonmap
	ELSE
		ld	hl,IDX_GASTNWMAP	;gastnwmap
	ENDC
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok6
	IFEQ	VERSION_JAPAN
		ld	hl,IDX_GASTONBWMAP	;gastonbwmap
	ELSE
		ld	hl,IDX_GASTNWBWMAP	;gastnwbwmap
	ENDC
.hlok6:		ld	de,GASTONMAP
		ld	c,$80
		call	spitmapfix
		call	getgrimmace
.yesjudge2:
		call	spitswapstar
		SETVBL	VblNormal
		ret


spitswapstar:	ldh	a,[spit_star]
		cp	2
		ret	z
		add	a
		add	a
		add	255&(JUDGE1MAP+13*$20)
		ld	l,a
		ld	a,0
		adc	(JUDGE1MAP+13*$20)>>8
		ld	h,a
		push	hl
		ld	de,JUDGE1MAP+08+13*$20
		call	.swap1
		pop	hl
		ld	de,JUDGE1ATTR-JUDGE1MAP
		add	hl,de
		ld	de,JUDGE1ATTR+08+13*$20
.swap1:		ld	a,4
.s1y:		ldh	[hTmpLo],a
		ld	b,4
.s1x:		ld	c,[hl]
		ld	a,[de]
		ld	[hli],a
		ld	a,c
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.s1x
		ld	bc,32-4
		add	hl,bc
		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.s1y
		ret		






spit_shutdown:	call	FadeOut
		xor	a
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a
		dec	a
		ldh	[hPosFlag],a
		ret


spitmakemap:
		ldh	a,[spit_xscroll]
		srl	a
		srl	a
		srl	a
		cp	20
		jr	nc,.only2
		ld	c,a
		add	255&GASTONMAP
		ld	l,a
		ld	h,GASTONMAP>>8
		ld	a,20
		sub	c
		ld	c,a
		ldh	[hTmpLo],a
		ld	a,32
		sub	c
		ld	b,a
		ld	de,MAPCOPY
		push	hl
		call	spitmake2
		pop	hl
		ld	de,GASTONATTR-GASTONMAP
		add	hl,de
		ld	de,ATTRCOPY
		call	spitmake2
.only2:		ldh	a,[spit_xscroll]
		srl	a
		srl	a
		srl	a
		ld	c,a
		ld	a,20
		sub	c
		add	255&MAPCOPY
		ld	e,a
		ld	d,MAPCOPY>>8
		inc	c
		ld	a,c
		ldh	[hTmpLo],a
		ld	a,32
		sub	c
		ld	b,a
		push	de
		ld	hl,JUDGE1MAP
		call	spitmake2
		pop	de
		ld	hl,GASTONATTR-GASTONMAP
		add	hl,de
		ld	d,h
		ld	e,l
		ld	hl,JUDGE1ATTR
spitmake2:	ld	a,18
.sm2y:		ldh	[hTmpHi],a
		ldh	a,[hTmpLo]
		ld	c,a
.sm2x:		ld	a,[hli]
		ld	[de],a
		inc	e
		dec	c
		jr	nz,.sm2x
		ld	a,e
		add	b
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,l
		add	b
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ldh	a,[hTmpHi]
		dec	a
		jr	nz,.sm2y
		ret
		



spitmapfix:	push	de
		ld	a,c
		ldh	[hTmpLo],a
		ld	de,$c800
		call	SwdInFileSys
		pop	de
		ld	hl,$c800+8
		ld	c,18
.y1:		ld	b,20
.x1:		ldh	a,[hTmpLo]
		add	[hl]
		inc	hl
		inc	hl
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
		ret

spitseqs:

		IFEQ	VERSION_JAPAN
		dw	1,15
		dw	173,186
		dw	16,40
		dw	187,204
		dw	41,68
		dw	205,227
		dw	69,101
		dw	228,254
		dw	102,138
		dw	255,285
		dw	139,172
		dw	286,313
		dw	286,313
		ELSE
		dw	241,278
		dw	1,32
		dw	279,324
		dw	33,72
		dw	325,378
		dw	73,120
		dw	379,440
		dw	121,176
		dw	441,510
		dw	177,240
		dw	511,588
		ENDC

;x scroll value
;figure #
;dx
;dy

		IFEQ	VERSION_JAPAN
spitframes:
		db	0,0,-19,-55
		db	0,1,-11,-53
		db	0,4,-3,-48
		db	8,4,-3,-38
		db	16,5,-3,-25
		db	24,6,-3,-6
		db	32,7,-3,30
		db	32,7,0,55
		db	32,8,0,55
		db	32,9,0,55
		db	32,10,0,55
		db	32,11,0,55
		db	32,12,0,55
		db	32,13,0,55
		db	32,14,0,55
		db	0,0,-19,-55
		db	0,0,-11,-56
		db	0,0,-3,-56
		db	8,1,-3,-55
		db	16,1,-3,-54
		db	24,1,-3,-51
		db	32,2,-3,-48
		db	40,2,-3,-44
		db	48,3,-3,-40
		db	56,3,-3,-34
		db	64,3,-3,-28
		db	72,4,-3,-21
		db	80,4,-3,-13
		db	88,4,-3,-3
		db	96,5,-3,7
		db	104,5,-3,21
		db	112,6,-3,37
		db	112,6,2,55
		db	112,8,3,55
		db	112,9,3,55
		db	112,10,3,55
		db	112,11,3,55
		db	112,12,3,55
		db	112,13,3,55
		db	112,14,3,55
		db	0,0,-11,-55
		db	0,0,-3,-57
		db	0,0,5,-57
		db	8,0,5,-56
		db	16,1,5,-55
		db	24,1,5,-54
		db	32,1,5,-52
		db	40,1,5,-49
		db	48,2,5,-46
		db	56,2,5,-43
		db	64,3,5,-39
		db	72,3,5,-35
		db	80,3,5,-29
		db	88,3,5,-23
		db	96,4,5,-17
		db	104,4,5,-10
		db	112,4,5,-1
		db	120,5,5,9
		db	128,5,5,20
		db	136,6,5,35
		db	144,6,4,55
		db	144,8,4,55
		db	144,9,4,55
		db	144,10,4,55
		db	144,11,4,55
		db	144,12,4,55
		db	144,13,4,55
		db	144,14,4,55
		db	0,0,-19,-55
		db	0,0,-11,-56
		db	0,0,-3,-58
		db	0,0,5,-58
		db	8,0,5,-58
		db	16,0,5,-58
		db	24,0,5,-57
		db	32,1,5,-56
		db	40,1,5,-55
		db	48,1,5,-54
		db	56,1,5,-51
		db	64,2,5,-48
		db	72,2,5,-46
		db	80,2,5,-43
		db	88,3,5,-39
		db	96,3,5,-35
		db	104,3,5,-31
		db	112,3,5,-26
		db	120,3,5,-20
		db	128,3,5,-15
		db	136,4,5,-7
		db	144,4,5,1
		db	152,4,5,9
		db	160,5,5,20
		db	160,6,13,34
		db	160,6,20,55
		db	160,8,20,55
		db	160,9,20,55
		db	160,10,20,55
		db	160,11,20,55
		db	160,12,20,55
		db	160,13,20,55
		db	160,14,20,55
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-58
		db	0,0,5,-59
		db	8,0,5,-59
		db	16,0,5,-59
		db	24,0,5,-58
		db	32,1,5,-58
		db	40,1,5,-57
		db	48,1,5,-56
		db	56,1,5,-54
		db	64,1,5,-53
		db	72,1,5,-51
		db	80,2,5,-49
		db	88,2,5,-47
		db	96,2,5,-44
		db	104,2,5,-42
		db	112,2,5,-38
		db	120,2,5,-34
		db	128,3,5,-30
		db	136,3,5,-26
		db	144,3,5,-21
		db	152,3,5,-16
		db	160,3,5,-10
		db	160,4,13,-3
		db	160,4,21,4
		db	160,4,29,12
		db	160,5,37,22
		db	160,5,45,35
		db	160,6,52,55
		db	160,8,52,55
		db	160,9,52,55
		db	160,10,52,55
		db	160,11,52,55
		db	160,12,52,55
		db	160,13,52,55
		db	160,14,52,55
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-59
		db	0,0,5,-59
		db	8,0,5,-60
		db	16,0,5,-60
		db	24,0,5,-60
		db	32,0,5,-59
		db	40,1,5,-59
		db	48,1,5,-58
		db	56,1,5,-58
		db	64,1,5,-57
		db	72,1,5,-56
		db	80,1,5,-55
		db	88,1,5,-54
		db	96,1,5,-52
		db	104,1,5,-51
		db	112,1,5,-49
		db	120,1,5,-47
		db	128,1,5,-45
		db	136,2,5,-43
		db	144,2,5,-40
		db	152,2,5,-38
		db	160,2,5,-35
		db	160,2,13,-32
		db	160,2,21,-29
		db	160,2,29,-25
		db	160,2,37,-22
		db	160,3,45,-17
		db	160,3,53,-14
		db	160,3,61,-9
		db	160,3,69,-4
		db	160,3,77,2
		db	160,3,84,7
		db	0,0,-19,-55
		db	12,0,-21,-56
		db	24,1,-29,-55
		db	36,1,-31,-53
		db	49,2,-35,-50
		db	61,2,-41,-47
		db	73,3,-45,-43
		db	86,3,-49,-38
		db	98,3,-53,-32
		db	110,4,-57,-25
		db	123,4,-62,-17
		db	135,4,-67,-9
		db	147,5,-71,2
		db	160,6,-72,24
		db	0,0,-19,-55
		db	0,0,-11,-56
		db	0,0,-3,-57
		db	0,1,5,-57
		db	8,1,5,-56
		db	16,1,5,-54
		db	24,1,5,-53
		db	32,2,5,-50
		db	40,2,5,-48
		db	48,2,5,-44
		db	56,3,5,-39
		db	64,3,5,-36
		db	72,3,5,-30
		db	80,3,5,-24
		db	88,4,5,-17
		db	96,4,5,-8
		db	104,5,5,2
		db	112,6,9,25
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-57
		db	0,0,5,-58
		db	8,0,5,-58
		db	16,1,5,-57
		db	24,1,5,-57
		db	32,1,5,-55
		db	40,1,5,-53
		db	48,1,5,-52
		db	56,1,5,-50
		db	64,2,5,-47
		db	72,2,5,-44
		db	80,2,5,-41
		db	88,3,5,-36
		db	96,3,5,-32
		db	104,3,5,-28
		db	112,3,5,-22
		db	120,4,5,-16
		db	128,4,5,-8
		db	136,4,5,0
		db	144,5,5,12
		db	152,6,3,25
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-58
		db	0,0,5,-59
		db	8,0,5,-59
		db	16,0,5,-60
		db	24,0,5,-59
		db	32,1,5,-59
		db	40,1,5,-58
		db	48,1,5,-57
		db	56,1,5,-55
		db	64,1,5,-54
		db	72,1,5,-52
		db	80,1,5,-50
		db	88,2,5,-47
		db	96,2,5,-45
		db	104,2,5,-42
		db	112,2,5,-38
		db	120,3,5,-35
		db	128,3,5,-30
		db	136,3,5,-26
		db	144,4,5,-20
		db	152,4,5,-14
		db	160,4,5,-7
		db	160,4,13,1
		db	160,5,21,12
		db	160,6,27,25
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-58
		db	0,0,5,-59
		db	8,0,5,-60
		db	16,0,5,-60
		db	24,0,5,-60
		db	32,0,5,-60
		db	40,1,5,-59
		db	48,1,5,-59
		db	56,1,5,-58
		db	64,1,5,-57
		db	72,1,5,-56
		db	80,1,5,-54
		db	88,1,5,-53
		db	96,2,5,-52
		db	104,2,5,-49
		db	112,2,5,-47
		db	120,2,5,-44
		db	128,2,5,-42
		db	136,3,5,-39
		db	144,2,5,-35
		db	152,3,5,-31
		db	160,3,5,-27
		db	160,3,13,-22
		db	160,3,21,-17
		db	160,4,29,-11
		db	160,4,37,-4
		db	160,4,45,4
		db	160,5,51,12
		db	160,6,57,25
		db	0,0,-19,-55
		db	0,0,-11,-57
		db	0,0,-3,-59
		db	0,0,5,-59
		db	8,0,5,-60
		db	16,0,5,-60
		db	24,0,5,-60
		db	32,0,5,-59
		db	40,1,5,-59
		db	48,1,5,-58
		db	56,1,5,-58
		db	64,1,5,-57
		db	72,1,5,-56
		db	80,1,5,-55
		db	88,1,5,-54
		db	96,1,5,-52
		db	104,1,5,-51
		db	112,1,5,-49
		db	120,1,5,-47
		db	128,1,5,-45
		db	136,2,5,-43
		db	144,15,5,-40
		db	152,16,-3,-39
		db	160,17,-11,-39
		db	160,18,-11,-38
		db	160,19,-11,-38
		db	160,20,-11,-38
		db	160,21,-12,-38
		ELSE
spitframes:
		db	0,0,-33,-23
		db	5,1,-34,-26
		db	10,2,-35,-29
		db	15,3,-36,-31
		db	20,4,-37,-33
		db	25,5,-38,-35
		db	30,6,-39,-36
		db	35,7,-40,-37
		db	40,0,-41,-39
		db	45,1,-42,-39
		db	50,2,-43,-40
		db	55,3,-44,-40
		db	60,4,-45,-41
		db	65,5,-46,-41
		db	70,6,-47,-40
		db	75,7,-48,-40
		db	80,0,-49,-39
		db	85,1,-50,-38
		db	90,2,-51,-37
		db	95,3,-52,-36
		db	100,4,-53,-34
		db	105,5,-54,-32
		db	110,6,-55,-30
		db	115,7,-56,-28
		db	120,0,-57,-25
		db	125,1,-58,-21
		db	130,2,-59,-17
		db	135,3,-60,-12
		db	140,4,-61,-7
		db	145,5,-62,0
		db	150,6,-63,10
		db	155,7,-64,28
		db	0,0,-33,-23
		db	0,1,-29,-27
		db	0,2,-25,-30
		db	1,3,-22,-32
		db	2,4,-19,-35
		db	3,5,-16,-37
		db	4,6,-13,-39
		db	5,7,-10,-41
		db	6,0,-7,-42
		db	11,1,-8,-43
		db	16,2,-9,-45
		db	21,3,-10,-46
		db	26,4,-11,-46
		db	31,5,-12,-47
		db	36,6,-13,-47
		db	41,7,-14,-48
		db	46,0,-15,-48
		db	51,1,-16,-48
		db	56,2,-17,-48
		db	61,3,-18,-47
		db	66,4,-19,-47
		db	71,5,-20,-46
		db	76,6,-21,-45
		db	81,7,-22,-44
		db	86,0,-23,-43
		db	91,1,-24,-41
		db	96,2,-25,-39
		db	101,3,-26,-37
		db	105,4,-27,-35
		db	111,5,-28,-33
		db	116,6,-29,-30
		db	121,7,-30,-26
		db	126,0,-31,-23
		db	131,1,-32,-19
		db	136,2,-33,-15
		db	141,3,-34,-10
		db	146,4,-35,-4
		db	151,5,-36,3
		db	156,6,-37,13
		db	161,7,-38,28
		db	0,0,-33,-23
		db	0,1,-29,-27
		db	0,2,-25,-30
		db	0,3,-21,-33
		db	0,4,-17,-36
		db	0,5,-13,-39
		db	0,6,-9,-41
		db	0,7,-5,-43
		db	0,0,-1,-45
		db	4,1,-1,-47
		db	8,2,-1,-48
		db	12,3,-1,-50
		db	16,4,-1,-51
		db	20,5,-1,-52
		db	24,6,-1,-53
		db	28,7,-1,-54
		db	32,0,-1,-54
		db	36,1,-1,-55
		db	40,2,-1,-55
		db	44,3,-1,-55
		db	48,4,-1,-55
		db	52,5,-1,-55
		db	56,6,-1,-55
		db	60,7,-1,-55
		db	64,0,-1,-54
		db	68,1,-1,-54
		db	72,2,-1,-53
		db	76,3,-1,-52
		db	80,4,-1,-51
		db	84,5,-1,-50
		db	88,6,-1,-48
		db	92,7,-1,-47
		db	96,0,-1,-45
		db	100,1,-1,-43
		db	104,2,-1,-41
		db	108,3,-1,-38
		db	112,4,-1,-36
		db	116,5,-1,-33
		db	120,6,-1,-30
		db	124,7,-1,-26
		db	128,0,-1,-22
		db	132,1,-1,-18
		db	136,2,-1,-13
		db	140,3,-1,-8
		db	144,4,-1,-2
		db	148,5,-1,6
		db	152,6,-1,15
		db	156,7,-1,28
		db	0,0,-33,-24
		db	0,1,-29,-28
		db	0,2,-25,-31
		db	0,3,-21,-34
		db	0,4,-17,-37
		db	0,5,-13,-40
		db	0,6,-9,-43
		db	0,7,-5,-45
		db	0,0,-1,-47
		db	4,1,-1,-49
		db	8,2,-1,-51
		db	12,3,-1,-53
		db	16,4,-1,-54
		db	20,5,-1,-56
		db	24,6,-1,-57
		db	28,7,-1,-58
		db	32,0,-1,-59
		db	36,1,-1,-60
		db	40,2,-1,-61
		db	44,3,-1,-62
		db	48,4,-1,-62
		db	52,5,-1,-62
		db	56,6,-1,-63
		db	60,7,-1,-63
		db	64,0,-1,-63
		db	68,1,-1,-63
		db	72,2,-1,-63
		db	76,3,-1,-62
		db	80,4,-1,-62
		db	84,5,-1,-61
		db	88,6,-1,-61
		db	92,7,-1,-60
		db	96,0,-1,-59
		db	100,1,-1,-58
		db	104,2,-1,-57
		db	108,3,-1,-56
		db	112,4,-1,-54
		db	116,5,-1,-52
		db	120,6,-1,-51
		db	124,7,-1,-49
		db	128,0,-1,-47
		db	132,1,-1,-44
		db	136,2,-1,-42
		db	140,3,-1,-39
		db	144,4,-1,-36
		db	148,5,-1,-33
		db	152,6,-1,-29
		db	156,7,-1,-26
		db	160,0,-1,-21
		db	160,1,3,-17
		db	160,2,7,-12
		db	160,3,11,-6
		db	160,4,15,0
		db	160,5,19,7
		db	160,6,23,16
		db	160,7,27,28
		db	0,0,-33,-24
		db	0,1,-29,-28
		db	0,2,-25,-32
		db	0,3,-21,-35
		db	0,4,-17,-38
		db	0,5,-13,-41
		db	0,6,-9,-44
		db	0,7,-5,-47
		db	0,0,-1,-49
		db	4,1,-1,-51
		db	8,2,-1,-53
		db	12,3,-1,-55
		db	16,4,-1,-57
		db	20,5,-1,-59
		db	24,6,-1,-60
		db	28,7,-1,-62
		db	32,0,-1,-63
		db	36,1,-1,-64
		db	40,2,-1,-66
		db	44,3,-1,-67
		db	48,4,-1,-67
		db	52,5,-1,-68
		db	56,6,-1,-69
		db	60,7,-1,-69
		db	64,0,-1,-70
		db	68,1,-1,-70
		db	72,2,-1,-70
		db	76,3,-1,-71
		db	80,4,-1,-71
		db	84,5,-1,-71
		db	88,6,-1,-70
		db	92,7,-1,-70
		db	96,0,-1,-70
		db	100,1,-1,-69
		db	104,2,-1,-69
		db	108,3,-1,-68
		db	112,4,-1,-67
		db	116,5,-1,-66
		db	120,6,-1,-65
		db	124,7,-1,-64
		db	128,0,-1,-63
		db	132,1,-1,-61
		db	136,2,-1,-60
		db	140,3,-1,-58
		db	144,4,-1,-56
		db	148,5,-1,-55
		db	152,6,-1,-52
		db	156,7,-1,-50
		db	160,0,-1,-48
		db	160,1,3,-45
		db	160,2,7,-42
		db	160,3,11,-39
		db	160,4,15,-36
		db	160,5,19,-33
		db	160,6,23,-29
		db	160,7,27,-25
		db	160,0,31,-21
		db	160,1,35,-16
		db	160,2,39,-11
		db	160,3,43,-5
		db	160,4,47,2
		db	160,5,51,8
		db	160,6,55,17
		db	160,7,59,28
		db	0,0,-33,-23
		db	0,1,-29,-26
		db	0,2,-25,-28
		db	0,3,-21,-30
		db	0,4,-17,-31
		db	0,5,-13,-32
		db	0,6,-9,-33
		db	0,7,-5,-34
		db	0,0,-1,-34
		db	4,1,-1,-34
		db	8,2,-1,-34
		db	12,3,-1,-33
		db	16,4,-1,-32
		db	20,5,-1,-31
		db	24,6,-1,-30
		db	28,7,-1,-28
		db	32,0,-1,-26
		db	36,1,-1,-23
		db	40,2,-1,-20
		db	44,3,-1,-17
		db	48,4,-1,-13
		db	52,5,-1,-8
		db	56,6,-1,-3
		db	60,7,-1,3
		db	64,0,-1,11
		db	68,1,-1,19
		db	72,2,-1,31
		db	76,6,-1,58
		db	76,2,-1,58
		db	76,6,-1,58
		db	76,7,-1,59
		db	76,1,-1,59
		db	76,7,-1,59
		db	76,4,-1,60
		db	76,4,-1,60
		db	76,4,-1,60
		db	76,4,-1,60
		db	76,4,-1,60
		db	0,0,-33,-23
		db	0,1,-29,-26
		db	0,2,-25,-29
		db	0,3,-21,-31
		db	0,4,-17,-34
		db	0,5,-13,-35
		db	0,6,-9,-37
		db	0,7,-5,-38
		db	0,0,-1,-39
		db	4,1,-1,-40
		db	8,2,-1,-40
		db	12,3,-1,-40
		db	16,4,-1,-41
		db	20,5,-1,-40
		db	24,6,-1,-40
		db	28,7,-1,-39
		db	32,0,-1,-39
		db	36,1,-1,-38
		db	40,2,-1,-36
		db	44,3,-1,-35
		db	48,4,-1,-33
		db	52,5,-1,-31
		db	56,6,-1,-29
		db	60,7,-1,-26
		db	64,0,-1,-23
		db	68,1,-1,-20
		db	72,2,-1,-17
		db	76,3,-1,-13
		db	80,4,-1,-8
		db	84,5,-1,-3
		db	88,6,-1,2
		db	92,7,-1,9
		db	96,0,-1,16
		db	100,1,-1,25
		db	104,2,-1,37
		db	108,6,-1,58
		db	108,2,-1,58
		db	108,6,-1,58
		db	108,7,-1,59
		db	108,1,-1,59
		db	108,7,-1,59
		db	108,4,-1,60
		db	108,4,-1,60
		db	108,4,-1,60
		db	108,4,-1,60
		db	108,4,-1,60
		db	0,0,-33,-23
		db	0,1,-29,-27
		db	0,2,-25,-30
		db	0,3,-21,-33
		db	0,4,-17,-35
		db	0,5,-13,-37
		db	0,6,-9,-39
		db	0,7,-5,-41
		db	0,0,-1,-42
		db	4,1,-1,-44
		db	8,2,-1,-45
		db	12,3,-1,-46
		db	16,4,-1,-46
		db	20,5,-1,-47
		db	24,6,-1,-47
		db	28,7,-1,-47
		db	32,0,-1,-47
		db	36,1,-1,-47
		db	40,2,-1,-47
		db	44,3,-1,-46
		db	48,4,-1,-45
		db	52,5,-1,-44
		db	56,6,-1,-43
		db	60,7,-1,-42
		db	64,0,-1,-41
		db	68,1,-1,-39
		db	72,2,-1,-37
		db	76,3,-1,-35
		db	80,4,-1,-33
		db	84,5,-1,-30
		db	88,6,-1,-28
		db	92,7,-1,-25
		db	96,0,-1,-21
		db	100,1,-1,-18
		db	104,2,-1,-14
		db	108,3,-1,-9
		db	112,4,-1,-5
		db	116,5,-1,0
		db	120,6,-1,6
		db	124,7,-1,13
		db	128,0,-1,20
		db	132,1,-1,29
		db	136,2,-1,41
		db	140,6,-1,58
		db	140,2,-1,58
		db	140,6,-1,58
		db	140,7,-1,59
		db	140,1,-1,59
		db	140,7,-1,59
		db	140,4,-1,60
		db	140,4,-1,60
		db	140,4,-1,60
		db	140,4,-1,60
		db	140,4,-1,60
		db	0,0,-33,-23
		db	0,1,-29,-27
		db	0,2,-25,-30
		db	0,3,-21,-33
		db	0,4,-17,-36
		db	0,5,-13,-39
		db	0,6,-9,-41
		db	0,7,-5,-43
		db	0,0,-1,-45
		db	4,1,-1,-47
		db	8,2,-1,-48
		db	12,3,-1,-50
		db	16,4,-1,-51
		db	20,5,-1,-52
		db	24,6,-1,-53
		db	28,7,-1,-53
		db	32,0,-1,-54
		db	36,1,-1,-54
		db	40,2,-1,-54
		db	44,3,-1,-54
		db	48,4,-1,-54
		db	52,5,-1,-54
		db	56,6,-1,-54
		db	60,7,-1,-53
		db	64,0,-1,-52
		db	68,1,-1,-52
		db	72,2,-1,-51
		db	76,3,-1,-50
		db	80,4,-1,-48
		db	84,5,-1,-47
		db	88,6,-1,-45
		db	92,7,-1,-44
		db	96,0,-1,-42
		db	100,1,-1,-40
		db	104,2,-1,-38
		db	108,3,-1,-35
		db	112,4,-1,-32
		db	116,5,-1,-30
		db	120,6,-1,-26
		db	124,7,-1,-23
		db	128,0,-1,-20
		db	132,1,-1,-16
		db	136,2,-1,-12
		db	140,3,-1,-7
		db	144,4,-1,-2
		db	148,5,-1,4
		db	152,6,-1,9
		db	156,7,-1,16
		db	160,0,-1,23
		db	160,1,3,32
		db	160,2,7,43
		db	160,6,11,58
		db	160,2,11,58
		db	160,6,11,58
		db	160,7,11,59
		db	160,1,11,59
		db	160,7,11,59
		db	160,4,11,60
		db	160,4,11,60
		db	160,4,11,60
		db	160,4,11,60
		db	160,4,11,60
		db	0,0,-33,-24
		db	0,1,-29,-27
		db	0,2,-25,-31
		db	0,3,-21,-34
		db	0,4,-17,-37
		db	0,5,-13,-40
		db	0,6,-9,-43
		db	0,7,-5,-45
		db	0,0,-1,-47
		db	4,1,-1,-49
		db	8,2,-1,-51
		db	12,3,-1,-53
		db	16,4,-1,-54
		db	20,5,-1,-56
		db	24,6,-1,-57
		db	28,7,-1,-58
		db	32,0,-1,-59
		db	36,1,-1,-60
		db	40,2,-1,-60
		db	44,3,-1,-61
		db	48,4,-1,-61
		db	52,5,-1,-61
		db	56,6,-1,-62
		db	60,7,-1,-62
		db	64,0,-1,-61
		db	68,1,-1,-61
		db	72,2,-1,-61
		db	76,3,-1,-60
		db	80,4,-1,-60
		db	84,5,-1,-59
		db	88,6,-1,-58
		db	92,7,-1,-57
		db	96,0,-1,-56
		db	100,1,-1,-55
		db	104,2,-1,-54
		db	108,3,-1,-52
		db	112,4,-1,-51
		db	116,5,-1,-49
		db	120,6,-1,-47
		db	124,7,-1,-45
		db	128,0,-1,-43
		db	132,1,-1,-40
		db	136,2,-1,-38
		db	140,3,-1,-35
		db	144,4,-1,-32
		db	148,5,-1,-29
		db	152,6,-1,-26
		db	156,7,-1,-22
		db	160,0,-1,-18
		db	160,1,3,-14
		db	160,2,7,-10
		db	160,3,11,-5
		db	160,4,15,0
		db	160,5,19,5
		db	160,6,23,11
		db	160,7,27,18
		db	160,0,31,25
		db	160,1,35,34
		db	160,2,39,44
		db	160,6,43,58
		db	160,2,43,58
		db	160,6,43,58
		db	160,7,43,59
		db	160,1,43,59
		db	160,7,43,59
		db	160,4,43,60
		db	160,4,43,60
		db	160,4,43,60
		db	160,4,43,60
		db	160,4,43,60
		db	0,0,-33,-24
		db	0,1,-29,-28
		db	0,2,-25,-32
		db	0,3,-21,-35
		db	0,4,-17,-39
		db	0,5,-13,-42
		db	0,6,-9,-44
		db	0,7,-5,-47
		db	0,0,-1,-49
		db	4,1,-1,-52
		db	8,2,-1,-54
		db	12,3,-1,-56
		db	16,4,-1,-57
		db	20,5,-1,-59
		db	24,6,-1,-60
		db	28,7,-1,-62
		db	32,0,-1,-63
		db	36,1,-1,-64
		db	40,2,-1,-65
		db	44,3,-1,-66
		db	48,4,-1,-67
		db	52,5,-1,-67
		db	56,6,-1,-68
		db	60,7,-1,-68
		db	64,0,-1,-69
		db	68,1,-1,-69
		db	72,2,-1,-69
		db	76,3,-1,-69
		db	80,4,-1,-69
		db	84,5,-1,-69
		db	88,6,-1,-68
		db	92,7,-1,-68
		db	96,0,-1,-67
		db	100,1,-1,-67
		db	104,2,-1,-66
		db	108,3,-1,-65
		db	112,4,-1,-64
		db	116,5,-1,-63
		db	120,6,-1,-62
		db	124,7,-1,-61
		db	128,0,-1,-59
		db	132,1,-1,-58
		db	136,2,-1,-56
		db	140,3,-1,-54
		db	144,4,-1,-52
		db	148,5,-1,-50
		db	152,6,-1,-48
		db	156,7,-1,-46
		db	160,0,-1,-43
		db	160,1,3,-41
		db	160,2,7,-38
		db	160,3,11,-35
		db	160,4,15,-32
		db	160,5,19,-28
		db	160,6,23,-25
		db	160,7,27,-21
		db	160,0,31,-17
		db	160,1,35,-13
		db	160,2,39,-8
		db	160,3,43,-4
		db	160,4,47,2
		db	160,5,51,7
		db	160,6,55,13
		db	160,7,59,20
		db	160,0,63,27
		db	160,1,67,35
		db	160,2,71,45
		db	160,6,75,58
		db	160,2,75,58
		db	160,6,75,58
		db	160,7,75,59
		db	160,1,75,59
		db	160,7,75,59
		db	160,4,75,60
		db	160,4,75,60
		db	160,4,75,60
		db	160,4,75,60
		db	160,4,75,60
		ENDC


spitpal:
		IFEQ	VERSION_JAPAN
		incbin	"res/dave/spit/gaston.rgb"
		ELSE
		incbin	"res/dave/spit/gastnw.rgb"
		ENDC

spit_end::
