; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** KISS.ASM                                                              **
; **                                                                       **
; ** Last modified : 990809 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"kiss",CODE,BANK[6]
		section 7

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

kiss_top::


SONG_KISS	EQU	14


KISSFLG_FIRST	EQU	0

kiss_phase	EQUS	"hTemp48+00"
kiss_flags	EQUS	"hTemp48+01"
kiss_count	EQUS	"hTemp48+02"
kiss_num	EQUS	"hTemp48+03"
kiss_maplo	EQUS	"hTemp48+04"
kiss_maphi	EQUS	"hTemp48+05"
kiss_chrlo	EQUS	"hTemp48+06"
kiss_chrhi	EQUS	"hTemp48+07"
kiss_pallo	EQUS	"hTemp48+08"
kiss_palhi	EQUS	"hTemp48+09"
kiss_type	EQUS	"hTemp48+10"
kiss_wait	EQUS	"hTemp48+11"
kiss_exitok	EQUS	"hTemp48+12"

MAPSIZE		EQU	$20*18
MAP		EQU	$e000-MAPSIZE*2
ATTR		EQU	$e000-MAPSIZE*1


kisstab:	db	0,0,0,0,0,0,0,0
		db	1,2,3,4,5,6,7
		db	7,7,7,7,7,7,7,7
		db	7,7,7,7,7,7,7
		db	255


Kiss::
		ld	hl,hTemp48
		ld	bc,48
		call	MemClear

		ldh	a,[hMachine]
		cp	MACHINE_CGB
;		jp	nz,kissgmb

		ld	a,64
		ldh	[kiss_wait],a

		ld	bc,IDX_CKISS000MAP	;ckiss000map
		ld	de,IDX_CKISS000CHR	;ckiss000chr
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	z,.bcdeok
		ld	bc,IDX_BKISS000MAP	;bkiss000map
		ld	de,IDX_BKISS000CHR	;bkiss000chr
.bcdeok:
		ld	a,c
		ldh	[kiss_maplo],a
		ld	a,b
		ldh	[kiss_maphi],a
		ld	a,e
		ldh	[kiss_chrlo],a
		ld	a,d
		ldh	[kiss_chrhi],a

		xor	a
		ldh	[kiss_count],a

		call	kiss_setup
kissloop::
		call	ReadJoypad

		ldh	a,[kiss_count]
		inc	a
		ldh	[kiss_count],a
		dec	a
		ld	hl,kisstab
		call	addahl
		ld	a,[hl]
		cp	255
		jr	z,kissdone
.cont:		call	kissrender
		call	kisscopy
		call	kissflip
		ld	hl,kiss_flags
		bit	KISSFLG_FIRST,[hl]
		jr	z,.notfirst
		res	KISSFLG_FIRST,[hl]
		LD	A,%10010011		;Initialize screen fade.
		LD	[wFadeVblBGP],A
		LD	[wFadeOBP0],A
		LD	[wFadeLycBGP],A
		LD	A,[wGmbPal2]
		LD	[wFadeOBP1],A

		call	FadeIn	;Black
		xor	a
		ldh	[hVbl8],a
.notfirst:

		ldh	a,[kiss_wait]
		call	AccurateWait
 xor a
 ldh [hVbl8],a
		jr	kissloop

kissdone:	call	kiss_shutdown
		ret


kiss_setup:
		ld	hl,kisspal
		call	LoadPalHL

		ld	hl,kiss_flags
		set	KISSFLG_FIRST,[hl]
		ret

kiss_shutdown:	call	FadeOut	;Black
		ret



kisscopy:	ld	hl,MAP
		ldh	a,[kiss_phase]
		srl	a
		ld	de,$9800
		jr	nc,.deok
		ld	de,$9c00
.deok:		ld	c,3*12
		push	de
		call	DumpChrs
		pop	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,ATTR
		ld	c,3*12
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret

kissrender:
		ld	l,a
		push	hl
		ldh	a,[kiss_maplo]
		add	l
		ld	l,a
		ldh	a,[kiss_maphi]
		adc	0
		ld	h,a

		ld	de,MAP
		ld	c,0
		ldh	a,[kiss_phase]
		srl	a
		jr	nc,.cok
		ld	c,$40
.cok:		call	kissmapfix

		pop	hl
		ldh	a,[kiss_chrlo]
		add	l
		ld	l,a
		ldh	a,[kiss_chrhi]
		adc	0
		ld	h,a
		ld	de,$d000
		call	SwdInFileSys
		ld	hl,$d000
		ldh	a,[kiss_phase]
		srl	a
		jr	c,.broken
		ld	de,$8000
		ld	c,$af
		jr	.onepiece
.broken:	ld	de,$9000
		ld	c,$80
		call	DumpChrs
		ld	de,$8c00
		ld	c,$2f
.onepiece:	jp	DumpChrs



		

kissflip:	ldh	a,[kiss_phase]
		inc	a
		ldh	[kiss_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10010111
.aok:		ldh	[hVblLCDC],a
		ret


;hl=id #
;de=dest
;c=add value for map (only for map # > $80)
kissmapfix:	push	de
		push	bc
		ld	de,$c800
		call	SwdInFileSys
		pop	bc
		ld	a,c
		ldh	[hTmpLo],a
		pop	de
		ld	hl,$c800+8
		ld	c,18
.y1:		ld	b,20
.x1:		ld	a,[hl]
		cp	$80
		jr	c,.aok
		ldh	a,[hTmpLo]
		add	[hl]
.aok:		inc	hl
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


kissgmb:	ld	de,MAP
		ld	hl,IDX_BKISS007MAP	;bkiss007map
		ld	c,0
		call	kissmapfix
		ld	hl,IDX_BKISS007CHR	;bkiss007chr
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8000
		ld	c,$a0
		call	DumpChrs
		call	kisscopy
		call	kissflip
		call	FadeIn
		ld	c,180
.gmbwait:	call	WaitForVBL
		dec	c
		jr	nz,.gmbwait
.out:		jp	FadeOut



kisspal:	incbin	"res/dave/kiss/ckiss000.rgb"

kiss_end::
