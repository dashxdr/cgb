; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** FIRE.ASM                                                              **
; **                                                                       **
; ** Last modified : 990803 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"fire",CODE,BANK[4]
		section 4

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;firework structure
;word timer (0=not used)
;word dx
;word x
;word dy
;word y

FIRE_SIZE	EQU	10

MAXFIRE		EQU	40
FIREBLOCK	EQU	$d000
GRAVITY		EQU	4

GLINTTIME	EQU	2


fire_top::

fire_flags	EQUS	"hTemp48+00"
fire_free	EQUS	"hTemp48+01" ;2 bytes
fire_glint	EQUS	"hTemp48+03"

FIREFLG_FIRST	EQU	0

Fire::
		call	fire_setup

fireloop:
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,firedone
		bit	JOY_A,a
		jp	nz,firedone

		ld	b,%10000011
		ldh	a,[fire_glint]
		or	a
		jr	z,.bok
		set	3,b
		dec	a
		ldh	[fire_glint],a
.bok:		ld	a,b
		ldh	[hVblLCDC],a

		call	random
		cp	16
		jr	nc,.skip
		ld	b,a
		and	$03
		swap	a
;		add	a
		add	32
		ld	d,a
		ld	a,b
		and	$0c
		add	a
		add	a
		add	$10
		ld	e,a
		call	random
		and	3
		add	a
		ld	b,a
		add	a
		add	b
		ld	b,a
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
		call	newfire
.skip:

		call	processfireworks
		LD	A,HIGH(wOamShadow)	;Signal VBL to update OAM RAM and
		ldh	[hOamFlag],a	;signal to dl OAM

		ld	hl,fire_flags
		bit	FIREFLG_FIRST,[hl]
		jr	z,.notfirst
		res	FIREFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ld	[hVbl8],a
.notfirst:	ld	a,8
		call	AccurateWait
		jp	fireloop
		


firepause:	call	fire_shutdown
		call	PauseMenu_B
		call	fire_setup
		jp	fireloop
firedone:	call	fire_shutdown
		ret

fire_setup:
		xor	a
		ldh	[fire_glint],a
		ld	a,%10010011
		ld	[wGmbPal2],a
		ld	hl,fire_flags
		set	FIREFLG_FIRST,[hl]

		ld	a,%10000011
		ldh	[hVblLCDC],a
		ld	hl,IDX_CCASTLEBG	;ccastlebg
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.hlok
		ld	hl,IDX_BCASTLEBG	;bcastlebg
.hlok:		call	BgInFileSys

		ld	hl,glintlist
		ld	bc,$c800+32*18
.doglints:	ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		jr	z,.doneglints
		res	2,d
		res	2,b
		ld	a,[bc]
		ld	[de],a
		set	2,d
		set	2,b
		ld	a,[bc]
		ld	[de],a
		inc	bc
		jr	.doglints
.doneglints:

		ld	hl,$c800
		ld	de,$9c00
		ld	c,36
		call	DumpChrs
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.nocgb2
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,$cc00
		ld	de,$9c00
		ld	c,36
		call	DumpChrs
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A
.nocgb2:





		ld	hl,IDX_FIRECHR	;firechr
		ld	de,$8000
		ld	c,FSSIZE_FIRECHR/16
		call	DumpChrsInFileSys

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.nocgb
		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		ld	hl,firergb
		ld	de,wOcpArcade
		ld	bc,64
		call	MemCopy

		LD	A,WRKBANK_NRM
		LDH	[hWrkBank],A		;bank.
		ldio	[rSVBK],a
.nocgb:

		ld	hl,FIREBLOCK
		ld	a,l
		ldh	[fire_free],a
		ld	a,h
		ldh	[fire_free+1],a
		ld	c,MAXFIRE-1
.ff:		ld	a,l
		add	255&FIRE_SIZE
		ld	e,a
		ld	a,h
		adc	FIRE_SIZE>>8
		ld	d,a
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],e
		inc	hl
		ld	[hl],d
		ld	h,d
		ld	l,e
		dec	c
		jr	nz,.ff
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a

		ret

fire_shutdown:	call	FadeOut
		jp	SprOff
glintlist:	dw	$c800+14+2*32
		dw	$c800+14+3*32
		dw	$c800+14+4*32
		dw	$c800+13+5*32
		dw	$c800+12+6*32
		dw	$c800+13+6*32
		dw	$c800+12+7*32
		dw	$c800+13+7*32
		dw	$c800+12+8*32
		dw	$c800+12+9*32
		dw	$c800+10+10*32
		dw	$c800+12+10*32
		dw	$c800+10+11*32
		dw	$c800+12+11*32
		dw	$c800+10+12*32
		dw	$c800+11+12*32
		dw	$c800+12+12*32
		dw	$c800+9+13*32
		dw	$c800+10+13*32
		dw	0		

processfireworks:
		ld	hl,wOamShadow
		ld	c,160/8
		xor	a
.clr:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.clr
		ld	hl,FIREBLOCK
		xor	a
.pflp:		ldh	[hTmpLo],a
		ld	a,[hli]
		or	a
		jr	z,.next
		push	hl
		ld	b,[hl]
		dec	hl
		ld	c,[hl]
		dec	c
		ld	a,c
		cp	48
		jr	z,.cull
		cp	16
		jr	nz,.noglint
		ld	a,GLINTTIME
		ldh	[fire_glint],a
.noglint:	inc	[hl]
		inc	hl
		inc	hl

		ld	a,c
		srl	a
		srl	a
		srl	a
		add	b
		ld	c,a
		ld	b,0

		ld	a,[hli]
		ld	d,[hl]
		inc	hl
		add	[hl]
		ld	[hli],a
		ld	a,d
		adc	[hl]
		ld	[hli],a
		ld	d,a

		ld	a,GRAVITY
		add	[hl]
		ld	[hli],a
		ld	a,0
		adc	[hl]
		ld	[hld],a

		ld	a,[hli]
		ld	e,[hl]
		inc	hl
		add	[hl]
		ld	[hli],a
		ld	a,e
		adc	[hl]
		ld	[hli],a
		ld	e,a
		ld	hl,firemap+8
;		inc	bc
		add	hl,bc
		add	hl,bc
		ld	c,[hl]
		inc	hl
		ld	b,[hl]
		ld	h,HIGH(wOamShadow)
		ldh	a,[hTmpLo]
		ld	l,a
		ld	[hl],e
		inc	l
		ld	[hl],d
		inc	l
		ld	[hl],c
		inc	l
		ld	a,b
		and	7
		ld	[hl],a
		jr	.nocull
.cull:		pop	hl
		dec	hl
		xor	a
		ld	[hli],a
		ld	[hli],a
		ldh	a,[fire_free]
		ld	[hli],a
		ldh	a,[fire_free+1]
		ld	[hld],a
		dec	hl
		dec	hl
		ld	a,l
		ldh	[fire_free],a
		ld	a,h
		ldh	[fire_free+1],a
		inc	hl
		jr	.next
.nocull:	pop	hl
.next:		ld	bc,FIRE_SIZE-1
		add	hl,bc
		ldh	a,[hTmpLo]
		add	4
		cp	160
		jr	nz,.pflp
		ret




;de=xy
;b=palette to use 0,6,12 or 18
newfire:	ld	a,b
		ldh	[hTmpLo],a
		ld	hl,fire_free
		ld	c,[hl]
		inc	l
		ld	b,[hl]
		dec	l
		ld	a,b
		or	c
		jr	z,.nospace
		inc	bc
		inc	bc
		ld	a,[bc]
		ld	[hli],a
		inc	bc
		ld	a,[bc]
		ld	[hl],a
		dec	bc
		dec	bc
		dec	bc
		ld	h,b
		ld	l,c

		ld	a,1
		ld	[hli],a
		ldh	a,[hTmpLo]
		ld	[hli],a

		push	de
		push	hl	;dx
		inc	hl
		inc	hl
		xor	a
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		inc	hl
		inc	hl
		xor	a
		ld	[hli],a
		ld	a,e
		ld	[hld],a
		call	random
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		ld	bc,fdxdy
		add	hl,bc
		pop	de
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hli]
		ld	[de],a
		inc	de
		inc	de
		inc	de
		ld	a,[hli]
		ld	[de],a
		inc	de
		ld	a,[hl]
		ld	[de],a
		pop	de
.nospace:	ldh	a,[hTmpLo]
		ld	b,a
		ret



fdxdy::
		dw	$0,$c
		dw	$4,$b
		dw	$8,$8
		dw	$b,$4
		dw	$b,$0
		dw	$b,$fffc
		dw	$8,$fff8
		dw	$4,$fff5
		dw	$0,$fff5
		dw	$fffc,$fff5
		dw	$fff8,$fff8
		dw	$fff5,$fffc
		dw	$fff5,$0
		dw	$fff5,$4
		dw	$fff8,$8
		dw	$fffc,$b
		dw	$0,$18
		dw	$9,$16
		dw	$10,$10
		dw	$16,$9
		dw	$17,$0
		dw	$16,$fff7
		dw	$10,$fff0
		dw	$9,$ffea
		dw	$0,$ffe9
		dw	$fff7,$ffea
		dw	$fff0,$fff0
		dw	$ffea,$fff7
		dw	$ffe9,$0
		dw	$ffea,$9
		dw	$fff0,$10
		dw	$fff7,$16
		dw	$0,$24
		dw	$d,$21
		dw	$19,$19
		dw	$21,$d
		dw	$23,$0
		dw	$21,$fff3
		dw	$19,$ffe7
		dw	$d,$ffdf
		dw	$0,$ffdd
		dw	$fff3,$ffdf
		dw	$ffe7,$ffe7
		dw	$ffdf,$fff3
		dw	$ffdd,$0
		dw	$ffdf,$d
		dw	$ffe7,$19
		dw	$fff3,$21
		dw	$0,$30
		dw	$12,$2c
		dw	$21,$21
		dw	$2c,$12
		dw	$2f,$0
		dw	$2c,$ffee
		dw	$21,$ffdf
		dw	$12,$ffd4
		dw	$0,$ffd1
		dw	$ffee,$ffd4
		dw	$ffdf,$ffdf
		dw	$ffd4,$ffee
		dw	$ffd1,$0
		dw	$ffd4,$12
		dw	$ffdf,$21
		dw	$ffee,$2c
		dw	$0,$3c
		dw	$16,$37
		dw	$2a,$2a
		dw	$37,$16
		dw	$3b,$0
		dw	$37,$ffea
		dw	$2a,$ffd6
		dw	$16,$ffc9
		dw	$0,$ffc5
		dw	$ffea,$ffc9
		dw	$ffd6,$ffd6
		dw	$ffc9,$ffea
		dw	$ffc5,$0
		dw	$ffc9,$16
		dw	$ffd6,$2a
		dw	$ffea,$37
		dw	$0,$48
		dw	$1b,$42
		dw	$32,$32
		dw	$42,$1b
		dw	$47,$0
		dw	$42,$ffe5
		dw	$32,$ffce
		dw	$1b,$ffbe
		dw	$0,$ffb9
		dw	$ffe5,$ffbe
		dw	$ffce,$ffce
		dw	$ffbe,$ffe5
		dw	$ffb9,$0
		dw	$ffbe,$1b
		dw	$ffce,$32
		dw	$ffe5,$42
		dw	$0,$54
		dw	$20,$4d
		dw	$3b,$3b
		dw	$4d,$20
		dw	$53,$0
		dw	$4d,$ffe0
		dw	$3b,$ffc5
		dw	$20,$ffb3
		dw	$0,$ffad
		dw	$ffe0,$ffb3
		dw	$ffc5,$ffc5
		dw	$ffb3,$ffe0
		dw	$ffad,$0
		dw	$ffb3,$20
		dw	$ffc5,$3b
		dw	$ffe0,$4d
		dw	$0,$60
		dw	$24,$58
		dw	$43,$43
		dw	$58,$24
		dw	$5f,$0
		dw	$58,$ffdc
		dw	$43,$ffbd
		dw	$24,$ffa8
		dw	$0,$ffa1
		dw	$ffdc,$ffa8
		dw	$ffbd,$ffbd
		dw	$ffa8,$ffdc
		dw	$ffa1,$0
		dw	$ffa8,$24
		dw	$ffbd,$43
		dw	$ffdc,$58
		dw	$0,$6c
		dw	$29,$63
		dw	$4c,$4c
		dw	$63,$29
		dw	$6b,$0
		dw	$63,$ffd7
		dw	$4c,$ffb4
		dw	$29,$ff9d
		dw	$0,$ff95
		dw	$ffd7,$ff9d
		dw	$ffb4,$ffb4
		dw	$ff9d,$ffd7
		dw	$ff95,$0
		dw	$ff9d,$29
		dw	$ffb4,$4c
		dw	$ffd7,$63
		dw	$0,$78
		dw	$2d,$6e
		dw	$54,$54
		dw	$6e,$2d
		dw	$77,$0
		dw	$6e,$ffd3
		dw	$54,$ffac
		dw	$2d,$ff92
		dw	$0,$ff89
		dw	$ffd3,$ff92
		dw	$ffac,$ffac
		dw	$ff92,$ffd3
		dw	$ff89,$0
		dw	$ff92,$2d
		dw	$ffac,$54
		dw	$ffd3,$6e
		dw	$0,$84
		dw	$32,$79
		dw	$5d,$5d
		dw	$79,$32
		dw	$83,$0
		dw	$79,$ffce
		dw	$5d,$ffa3
		dw	$32,$ff87
		dw	$0,$ff7d
		dw	$ffce,$ff87
		dw	$ffa3,$ffa3
		dw	$ff87,$ffce
		dw	$ff7d,$0
		dw	$ff87,$32
		dw	$ffa3,$5d
		dw	$ffce,$79
		dw	$0,$90
		dw	$37,$85
		dw	$65,$65
		dw	$85,$37
		dw	$8f,$0
		dw	$85,$ffc9
		dw	$65,$ff9b
		dw	$37,$ff7b
		dw	$0,$ff71
		dw	$ffc9,$ff7b
		dw	$ff9b,$ff9b
		dw	$ff7b,$ffc9
		dw	$ff71,$0
		dw	$ff7b,$37
		dw	$ff9b,$65
		dw	$ffc9,$85
		dw	$0,$9c
		dw	$3b,$90
		dw	$6e,$6e
		dw	$90,$3b
		dw	$9b,$0
		dw	$90,$ffc5
		dw	$6e,$ff92
		dw	$3b,$ff70
		dw	$0,$ff65
		dw	$ffc5,$ff70
		dw	$ff92,$ff92
		dw	$ff70,$ffc5
		dw	$ff65,$0
		dw	$ff70,$3b
		dw	$ff92,$6e
		dw	$ffc5,$90
		dw	$0,$a8
		dw	$40,$9b
		dw	$76,$76
		dw	$9b,$40
		dw	$a7,$0
		dw	$9b,$ffc0
		dw	$76,$ff8a
		dw	$40,$ff65
		dw	$0,$ff59
		dw	$ffc0,$ff65
		dw	$ff8a,$ff8a
		dw	$ff65,$ffc0
		dw	$ff59,$0
		dw	$ff65,$40
		dw	$ff8a,$76
		dw	$ffc0,$9b
		dw	$0,$b4
		dw	$44,$a6
		dw	$7f,$7f
		dw	$a6,$44
		dw	$b3,$0
		dw	$a6,$ffbc
		dw	$7f,$ff81
		dw	$44,$ff5a
		dw	$0,$ff4d
		dw	$ffbc,$ff5a
		dw	$ff81,$ff81
		dw	$ff5a,$ffbc
		dw	$ff4d,$0
		dw	$ff5a,$44
		dw	$ff81,$7f
		dw	$ffbc,$a6
		dw	$0,$c0
		dw	$49,$b1
		dw	$87,$87
		dw	$b1,$49
		dw	$bf,$0
		dw	$b1,$ffb7
		dw	$87,$ff79
		dw	$49,$ff4f
		dw	$0,$ff41
		dw	$ffb7,$ff4f
		dw	$ff79,$ff79
		dw	$ff4f,$ffb7
		dw	$ff41,$0
		dw	$ff4f,$49
		dw	$ff79,$87
		dw	$ffb7,$b1

firergb:	incbin	"res/dave/fire/fire.rgb"
firemap:	incbin	"res/dave/fire/fire.map"


fire_end::
