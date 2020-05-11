; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** GMBCHOKE.ASM                                                          **
; **                                                                       **
; ** Last modified : 991105 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

		SECTION	03

gmbwait:	ld	b,5
.www1:		ldio	a,[rLY]
		cp	144
		jr	nz,.www1
.www2:		ldio	a,[rLY]
		cp	144
		jr	z,.www2
		dec	b
		jr	nz,.www1
		ld	a,c
		ldio	[rBGP],a
		ret

GmbChoke::
		di
		ld	sp,$c800
		ld	c,%11100100
		call	gmbwait
		ld	c,%10010000
		call	gmbwait
		ld	c,%01000000
		call	gmbwait
		ld	c,%00000000
		call	gmbwait
		call	gmbwait

		xor	a
		ldio	[rLCDC],a
		ldio	[rSCX],a
		ldio	[rSCY],a
		ld	hl,IDX_CHOKECHR
		ld	de,$8000
		call	SwdInFileSys
		ld	hl,IDX_CHOKEMAP
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c808
		ld	de,$9800
		ld	c,18
.y:		ld	b,20
.x:		ld	a,[hli]
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.x
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.y
		ld	a,%10010001
		ldio	[rLCDC],a

		ld	c,%00000000
		call	gmbwait
		ld	c,%01000000
		call	gmbwait
		ld	c,%10010000
		call	gmbwait
		ld	c,%11100100
		call	gmbwait
.die:		halt
		jr	.die




; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
