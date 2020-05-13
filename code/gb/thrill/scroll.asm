; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SCROLL.ASM                                                            **
; **                                                                       **
; ** Last modified : 991115 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"

		SECTION	00

TUMESCROLL	EQU	0

		IF	TUMESCROLL

NUMX		EQU	21
NUMY		EQU	19

; ***************************************************************************
; * ProcessBGAnim                                                           *
; ***************************************************************************
; * Inputs:     None                                                        *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Deal with the background animation                          *
; ***************************************************************************

ProcessBGAnim::
		ld	a,[wMapBGAnimLo]
		ld	c,a
		ld	a,[wMapBGAnimHi]
		ld	b,a
		or	c
		ret	z
		ld	a,[wMapBGAnimListLo]
		ld	e,a
		ld	a,[wMapBGAnimListHi]
		ld	d,a
		ld	hl,wMapBGAnimPos
		ld	a,[hl]
		inc	[hl]
		ld	l,a
		ld	h,0
		add	hl,de
		ld	e,[hl]
		inc	hl
		ld	a,[hl]
		cp	255
		jr	nz,.noroll
		xor	a
		ld	[wMapBGAnimPos],a
.noroll:
		ld	a,e
		or	a
		ret	z
		call	StepBGAnim
		jp	ProcessBGAnim

StepBGAnim::	ldh	[hTmpLo],a
		ldh	[hTmpHi],a
		ldh	a,[hRomBank]
		push	af
		ld	h,b
		ld	l,c
		call	FindInFileSys
		ld	d,h
		ld	e,l
		ld	a,l
		ldh	[hTmp3Lo],a
		ld	a,h
		ldh	[hTmp3Hi],a
.look:		ld	a,[de]	;# of frames
		inc	de
		or	a
		jp	z,.invalid
		ld	c,a
		ld	a,[de]	;# of chrs
		inc	de
		ld	b,a
		ldh	a,[hTmpLo]
		dec	a
		ldh	[hTmpLo],a
		jr	z,.gotit
		ld	a,b
		inc	c
		add	a
		call	MultiplyBBW
		add	hl,de
		ld	d,h
		ld	e,l
		jr	.look
.gotit:		ldh	a,[hTmpHi]
		ld	hl,wMapBGAnimCounts-1
		call	addahl
		ld	a,[hl]
		inc	a
		cp	c
		jr	c,.aok
		xor	a
.aok:		ld	[hl],a
		add	a
		ld	l,a
		ldh	[hTmpLo],a	;which chr in cycle to use
		ld	a,c
		add	a
		sub	l
		ldh	[hTmp2Lo],a	;skip
		ld	h,d
		ld	l,e
		ld	a,b
.loop:		ldh	[hTmpHi],a	;# of chrs to deal with
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		xor	8
		add	$88
		ld	d,a
		cp	$98
		jr	c,.not2nd
		sub	$10
		ld	d,a
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
.not2nd:	ldh	a,[hTmpLo]
		ld	c,a
		ld	b,0
		add	hl,bc
		push	hl
		ld	a,[hli]
		ld	b,[hl]
		ld	c,a
		ld	hl,hTmp3Lo
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		add	hl,bc
.www:		ldio	a,[rLY]
		cp	140
		jr	nc,.www
		ld	b,%11
		CALL	CgbChrDump		;Dump a single chr.
		pop	hl
		ldh	a,[hTmp2Lo]
		ld	c,a
		ld	b,0
		add	hl,bc
		ldh	a,[hTmpHi]
		dec	a
		jr	nz,.loop
.invalid:	pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ret


; ***************************************************************************
; * LoadBigMap                                                              *
; ***************************************************************************
; * Inputs:     HL = list of IDX #'s                                        *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Load up a big map in ram banks 2-7                          *
; *             Order of IDX = CHR,RGB,HIT,CAN,Animlist,dm0-5               *
; ***************************************************************************





LoadBigMap::
		ld	a,7
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	d,h
		ld	e,l
		ld	a,[de]
		inc	de
		ld	l,a
		ld	a,[de]
		inc	de
		ld	h,a
		push	de
		ld	de,$c800
		call	SwdInFileSys
		ld	a,d
		sub	$c8
		ld	d,a
		srl	d
		rr	e
		srl	d
		rr	e
		srl	d
		rr	e
		srl	d
		rr	e

		ld	hl,$c800
		ld	de,$9000
		ld	c,128
		call	DumpChrs
		ld	de,$8800
		ld	c,128
		call	DumpChrs
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	de,$9000
		ld	c,128
		call	DumpChrs
		pop	de

		ld	a,[de]
		inc	de
		ld	l,a
		ld	a,[de]
		inc	de
		ld	h,a
		or	l
		jr	z,.nosecond
		push	de
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$8800
		ld	c,128
		call	DumpChrs
		pop	de
.nosecond:	xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a

		ld	a,[de]
		ld	l,a
		inc	de
		ld	a,[de]
		inc	de
		ld	h,a
		push	de
		ldh	a,[hRomBank]
		push	af
		call	FindInFileSys
		call	LoadPalHL
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		pop	de

		ld	a,[de]
		inc	de
		ld	[wMapHitLo],a
		ld	a,[de]
		inc	de
		ld	[wMapHitHi],a

		ld	a,[de]
		inc	de
		ld	[wMapBGAnimLo],a
		ld	a,[de]
		inc	de
		ld	[wMapBGAnimHi],a

		ld	a,[de]
		inc	de
		ld	[wMapBGAnimListLo],a
		ld	a,[de]
		inc	de
		ld	[wMapBGAnimListHi],a

		ld	a,e
		ldh	[hTmp2Lo],a
		ld	a,d
		ldh	[hTmp2Hi],a


		xor	a
.lbmlp:		ldh	[hTmp3Lo],a
		ld	c,a
		ldh	a,[hTmp2Lo]
		ld	l,a
		ldh	a,[hTmp2Hi]
		ld	h,a
		ld	a,c
		add	a
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		jr	z,.lbmdone
		ld	a,c
		add	WRKBANK_MAP
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		ld	de,$d000
		call	SwdInFileSys

		ldh	a,[hTmp3Lo]
		inc	a
		cp	6
		jr	nz,.lbmlp
.lbmdone:
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[$d000]
		ld	[wMapXSize],a
		ld	a,[$d002]
		ld	[wMapYSize],a
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	hl,wMapBGAnimListLo
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		push	de
		ld	de,wTemp512
		ld	a,d
		ld	[hld],a
		ld	[hl],e
		ld	a,1
		ld	[de],a
		inc	e
		xor	a
		ld	[de],a
		inc	e
		ld	a,255
		ld	[de],a
		xor	a
		ld	[wMapBGAnimPos],a
.preloadbganim:
		call	ProcessBGAnim
		ld	a,[wTemp512]
		inc	a
		ld	[wTemp512],a
		cp	64
		jr	c,.preloadbganim

		xor	a
		ld	[wMapBGAnimPos],a
		pop	de
		ld	hl,wMapBGAnimListLo
		ld	a,e
		ld	[hli],a
		ld	[hl],d

		ldh	a,[hRomBank]
		push	af
		ld	hl,wMapAnimChars
		ld	bc,512
		call	MemClear
		ld	a,[wMapBGAnimLo]
		ld	l,a
		ld	a,[wMapBGAnimHi]
		ld	h,a
		call	FindInFileSys
		xor	a
		ldh	[hTmpLo],a
.marklp:	ld	a,[hli]
		or	a
		jr	z,.markdone
		ld	c,a
		inc	c
		ld	a,[hli]
		ldh	[hTmpHi],a
		add	a
		ld	d,h
		ld	e,l
		call	MultiplyBBW
		add	hl,de
		push	hl
		ld	a,[de]
		ld	l,a
		inc	de
		ld	a,[de]
		ld	h,a
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		ld	de,wMapAnimChars
		add	hl,de
		ldh	a,[hTmpHi]
		ld	c,a
		ldh	a,[hTmpLo]
		inc	a
		ldh	[hTmpLo],a
		ld	b,0
		call	MemFill
		pop	hl
		jr	.marklp
.markdone:	pop	af
		ldh	[hRomBank],A
		ld	[rMBC_ROM],A

		ret

; ***************************************************************************
; * CheckCollision                                                          *
; ***************************************************************************
; * Inputs:     DE = X pos in bits 5-15                                     *
; *             HL = Y pos in bits 5-15                                     *
; * Outputs:    A  = Collision bits for this pixel                          *
; *             BC = all 16 bits (C==A)                                     *
; * Preserves:  DE/HL                                                       *
; * Function:   See if this dot hits the background                         *
; ***************************************************************************

;0  none
;1  solid
;2  semi-solid
;3  ladder
;4  deadly
;5  slippery
;6  exit
;7  bouncy
;8  slope
;9  movable+semisolid
;10 movable+bouncy+semisolid
;11 movable

CollisionBits:
		dw	0
		dw	1<<COLLFLG_SOLID
		dw	1<<COLLFLG_SEMISOLID
		dw	1<<COLLFLG_LADDER
		dw	1<<COLLFLG_DEADLY
		dw	1<<COLLFLG_SLIPPERY
		dw	0
		dw	1<<COLLFLG_BOUNCY
		dw	0
		dw	(1<<COLLFLG_MOVABLE)|(1<<COLLFLG_SEMISOLID)
		dw	(1<<COLLFLG_BOUNCY)|(1<<COLLFLG_MOVABLE)|(1<<COLLFLG_SEMISOLID)
		dw	1<<COLLFLG_MOVABLE
		dw	0
		dw	0
		dw	0


CheckCollision::
		push	de
		push	hl
		ld	a,[wMapXSize]
		ld	c,a
		ld	a,h
		push	hl
		call	MultiplyBBW
		add	hl,hl
		ld	c,d
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	bc,$10
		add	hl,bc
		ld	a,h
		swap	a
		and	7
		add	WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,h
		and	15
		or	$d0
		ld	h,a
		ld	a,[hli]
		ld	b,[hl]
		ld	c,a
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,b
		bit	3,b
		ld	b,0
		jr	z,.bok
		inc	b
.bok:		ld	a,c
		add	LOW(wMapAnimChars)
		ld	l,a
		ld	a,b
		adc	HIGH(wMapAnimChars)
		ld	h,a
		ld	a,[hl]
		ld	[wMapAnimType],a
		pop	hl
		ld	d,e
		ld	e,l
		ld	h,a
		bit	5,h
		jr	z,.noxflip
		ld	a,d
		cpl
		ld	d,a
.noxflip:	bit	6,h
		jr	z,.noyflip
		ld	a,e
		cpl
		ld	e,a
.noyflip:	ld	a,e
		srl	a
		srl	a
		and	$38
		ld	e,a
		ld	a,d
		rlc	a
		rlc	a
		rlc	a
		and	7
		or	e
		ld	e,a
		ld	d,0
		ld	a,[wMapHitLo]
		ld	l,a
		ld	a,[wMapHitHi]
		ld	h,a
		ldh	a,[hRomBank]
		push	af
		call	FindInFileSys
		ld	a,[hli]
		push	hl
		add	hl,bc
		ld	b,a
		ld	c,d
		srl	b
		rr	c
		srl	b
		rr	c
		add	hl,bc
		ld	b,[hl]
		ld	c,d
		srl	b
		rr	c
		srl	b
		rr	c
		pop	hl
		add	hl,bc
		add	hl,de
		ld	e,[hl]
		ld	hl,CollisionBits
		add	hl,de
		add	hl,de
		ld	c,[hl]
		inc	hl
		ld	b,[hl]
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		pop	hl
		pop	de
		ld	a,c
		ret

; ***************************************************************************
; * FetchAnimType                                                           *
; ***************************************************************************
; * Inputs:     DE = X pos in bits 5-15                                     *
; *             HL = Y pos in bits 5-15                                     *
; * Outputs:    A = 8 bit anim info, as in which bg anim set                *
; * Preserves:  DE/HL                                                       *
; ***************************************************************************

FetchAnimType::
		call	FetchTileInfo
		xor	a
		bit	3,b
		jr	z,.aok
		inc	a
.aok:		ld	b,a
		ld	a,c
		add	LOW(wMapAnimChars)
		ld	c,a
		ld	a,b
		adc	HIGH(wMapAnimChars)
		ld	b,a
		ld	a,[bc]
		ret

; ***************************************************************************
; * FetchTileInfo                                                           *
; ***************************************************************************
; * Inputs:     DE = X pos in bits 5-15                                     *
; *             HL = Y pos in bits 5-15                                     *
; * Outputs:    BC = 16 bit tile info (C=CHR, B=ATTR)                       *
; * Preserves:  DE/HL                                                       *
; ***************************************************************************

FetchTileInfo::
		push	de
		push	hl
		ld	a,[wMapXSize]
		ld	c,a
		ld	a,h
		call	MultiplyBBW
		add	hl,hl
		ld	c,d
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	bc,$10
		add	hl,bc
		ld	a,h
		swap	a
		and	7
		add	WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,h
		and	15
		or	$d0
		ld	h,a
		ld	a,[hli]
		ld	b,[hl]
		ld	c,a
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	hl
		pop	de
		ret

; ***************************************************************************
; * StoreTileInfo                                                           *
; ***************************************************************************
; * Inputs:     DE = X pos in bits 5-15                                     *
; *             HL = Y pos in bits 5-15                                     *
; *             BC = 16 bit tile info (C=CHR, B=ATTR)                       *
; * Preserves:  DE/HL/BC                                                    *
; ***************************************************************************

StoreTileInfo::
		push	de
		push	hl
		push	bc
		ld	a,[wMapXSize]
		ld	c,a
		ld	a,h
		call	MultiplyBBW
		add	hl,hl
		ld	c,d
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	bc,$10
		add	hl,bc
		ld	a,h
		swap	a
		and	7
		add	WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,h
		and	15
		or	$d0
		ld	h,a
		pop	bc
		ld	[hl],c
		inc	l
		ld	[hl],b
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	hl
		pop	de
		ret



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;de=xy
;returns hl pointing to that position, and correct hWrkBank bank selected
FindMapCoords::
		ld	a,[wMapXSize]
		ld	l,a
		ld	h,0
		add	hl,hl
		ld	b,h
		ld	c,l
		ld	a,e
		call	MultiplyBWW
		ld	c,d
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	bc,$10
		add	hl,bc
		ld	a,h
		swap	a
		and	7
		add	WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,h
		and	15
		or	$d0
		ld	h,a
		ret

setupscroll:
		ld	a,e
		ld	[wMapXPos],a
		rlca
		rlca
		rlca
		and	7
		ld	e,a
		ld	a,[wMapXPos+1]
		ld	b,a
		ld	a,d
		sub	b
		ld	[wMapDX],a
		add	a
		add	a
		add	a
		ld	b,a
		ldh	a,[hVblSCX]
		and	$f8
		add	b
		or	e
		ldh	[hVblSCX],a

		ld	a,l
		ld	[wMapYPos],a
		rlca
		rlca
		rlca
		and	7
		ld	l,a
		ld	a,[wMapYPos+1]
		ld	b,a
		ld	a,h
		sub	b
		ld	[wMapDY],a
		add	a
		add	a
		add	a
		ld	b,a
		ldh	a,[hVblSCY]
		and	$f8
		add	b
		or	l
		ldh	[hVblSCY],a
		ret

;de=x,hl=y
HandleScroll::
		ld	a,[wMapXSize]
		sub	20
		ld	b,a
		ld	c,0
		ld	a,c
		sub	e
		ld	a,b
		sbc	d
		jr	nc,.deok
		ld	e,c
		ld	d,b
.deok:
		ld	a,[wMapYSize]
		sub	18
		ld	b,a
		ld	c,0
		ld	a,c
		sub	l
		ld	a,b
		sbc	h
		jr	nc,.hlok
		ld	l,c
		ld	h,b
.hlok:




		call	setupscroll
		call	fixdx
fixdy:		ld	a,[wMapDY]
		or	a
		ret	z
		add	a
		jr	c,.up
.down:		ld	hl,wMapYPos+1
		inc	[hl]
		call	newbottomrow
		ld	hl,wMapDY
		dec	[hl]
		jr	nz,.down
		ret

.up:		ld	hl,wMapYPos+1
		dec	[hl]
		call	newtoprow
		ld	hl,wMapDY
		inc	[hl]
		jr	nz,.up
		ret

fixdx:		ld	a,[wMapDX]
		or	a
		ret	z
		add	a
		jr	c,.left
.right:		ld	hl,wMapXPos+1
		inc	[hl]
		call	newrightcolumn
		ld	hl,wMapDX
		dec	[hl]
		jr	nz,.right
		ret
.left:		ld	hl,wMapXPos+1
		dec	[hl]
		call	newleftcolumn
		ld	hl,wMapDX
		inc	[hl]
		jr	nz,.left
		ret

RefreshScroll::	ld	a,[wMapXPos+1]
		ld	d,a
		ld	a,[wMapYPos+1]
		ld	e,a
		ld	a,[wMapUpperLeft]
		ld	c,a
		ld	a,[wMapUpperLeft+1]
		ld	b,a
		ld	h,19
.reflp:		push	bc
		push	de
		push	hl
		push	bc
		call	FindMapCoords
		pop	bc
		ld	e,c
		ld	a,b
		and	3
		add	$c8
		ld	d,a
		call	refrow
		pop	hl
		pop	de
		pop	bc
		ld	a,c
		add	$20
		ld	c,a
		ld	a,b
		adc	0
		ld	b,a
		inc	e
		dec	h
		jr	nz,.reflp
		ret

newtoprow:
		ld	a,[wMapXPos+1]
		ld	d,a
		ld	a,[wMapYPos+1]
		ld	e,a
		call	FindMapCoords
		ld	a,[wMapUpperLeft]
		sub	$20
		ld	e,a
		ld	[wMapUpperLeft],a
		ld	a,[wMapUpperLeft+1]
		sbc	0
		and	$03
		ld	[wMapUpperLeft+1],a
		add	$c8
		ld	d,a
refrow:
		call	wraprow
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,e
		and	$e0
		ld	l,a
		ld	e,a
		ld	h,d
		ld	a,d
		sub	$30
		ld	d,a	;$c800 -> $9800
		push	de
		push	hl
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		set	2,h
		ld	c,2
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		pop	hl
		pop	de
		ld	c,2
		jp	DumpChrs
newbottomrow:
		ld	a,[wMapXPos+1]
		ld	d,a
		ld	a,[wMapYPos+1]
		add	NUMY-1
		ld	e,a
		call	FindMapCoords
		ld	a,[wMapUpperLeft]
		add	$20
		ld	e,a
		ld	[wMapUpperLeft],a
		ld	a,[wMapUpperLeft+1]
		adc	0
		and	$03
		ld	[wMapUpperLeft+1],a
		ld	d,a
		ld	a,e
		add	255&((NUMY-1)*$20)
		ld	e,a
		ld	a,d
		adc	((NUMY-1)*$20)>>8
		and	$03
		add	$c8
		ld	d,a
		call	wraprow
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,e
		and	$e0
		ld	l,a
		ld	e,a
		ld	h,d
		ld	a,d
		sub	$30
		ld	d,a	;$c800 -> $9800
		push	de
		push	hl
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		set	2,h
		ld	c,2
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		pop	hl
		pop	de
		ld	c,2
		jp	DumpChrs

wraprow:
		ld	c,NUMX
.cp:		ld	a,[hli]
		res	2,d
		ld	[de],a
		ld	a,[hli]
		set	2,d
		ld	[de],a
		inc	e
		ld	a,e
		and	$1f
		jr	nz,.fine
		ld	a,e
		sub	$20
		ld	e,a
.fine:		bit	5,h
		jr	z,.nocarry
		ld	a,h
		sub	$10
		ld	h,a
		ldh	a,[hWrkBank]
		inc	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.nocarry:	dec	c
		jr	nz,.cp
		res	2,d
		ret

sync:		ldio	a,[rLY]
		dec	a
		cp	140
		jr	nc,sync
		di
.sync1a:	ldio	a,[rSTAT]
		and	3
		jr	z,.sync1a
.sync1b:	ldio	a,[rSTAT]
		and	3
		jr	nz,.sync1b
		ret


newrightcolumn:
		ld	a,[wMapXPos+1]
		add	NUMX-1
		ld	d,a
		ld	a,[wMapYPos+1]
		ld	e,a
		call	FindMapCoords

		ld	a,[wMapUpperLeft]
		inc	a
		ld	e,a
		and	$1f
		ld	a,e
		jr	nz,.aok
		sub	$20
.aok:		ld	[wMapUpperLeft],a
		call	wrapcol
		ld	a,[wMapUpperLeft]
		add	NUMX-1
		jr	newcolumn

newleftcolumn:
		ld	a,[wMapXPos+1]
		ld	d,a
		ld	a,[wMapYPos+1]
		ld	e,a
		call	FindMapCoords


		ld	a,[wMapUpperLeft]
		ld	e,a
		dec	e
		and	$1f
		ld	a,e
		jr	nz,.aok
		add	$20
.aok:		ld	[wMapUpperLeft],a

		call	wrapcol

		ld	a,[wMapUpperLeft]
newcolumn:	and	$1f
		ld	l,a
		ld	h,$98
		ld	bc,$20
		ld	de,$c800
		push	hl
		call	column
		pop	hl
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		call	column
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ret

column:		ld	a,4
.top:		ldh	[hTmpLo],a
		call	sync
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		inc	e	;1
		add	hl,bc	;2
		ld	a,[de]	;2
		ld	[hl],a	;2
		ei
		inc	e	;1
		add	hl,bc	;2
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.top
		ret

wrapcol:	ld	a,[wMapUpperLeft]
		ld	e,a
		ld	a,[wMapUpperLeft+1]
		ld	d,a
		sla	e
		rl	d
		sla	e
		rl	d
		sla	e
		rl	d
		ld	e,d
		ld	d,$c8
		ld	a,[wMapXSize]
		ld	c,a
		ld	b,0
		sla	c
		rl	b
		ld	a,NUMY
.cp:		ldh	[hTmpLo],a
		ld	a,[hli]
		res	5,e
		ld	[de],a
		ld	a,[hld]
		set	5,e
		ld	[de],a
		res	5,e
		inc	e
		add	hl,bc
		ld	a,h
		cp	$e0
		jr	c,.nocarry
		sub	$10
		ld	h,a
		ldh	a,[hWrkBank]
		inc	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.nocarry:	ldh	a,[hTmpLo]
		dec	a
		jr	nz,.cp
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

;de,hl = x,y of where to view
InitScroll::
		xor	a
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a
		ld	[wMapXPos+1],a
		ld	[wMapYPos+1],a
		ld	[wMapUpperLeft],a
		ld	[wMapUpperLeft+1],a

		call	setupscroll

		ld	a,[wMapDX]
		ld	[wMapXPos+1],a
		ld	d,a
		ld	a,[wMapDY]
		ld	[wMapYPos+1],a
		ld	e,a
		xor	a
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a

		call	FindMapCoords

		ld	de,$c800
		call	dummy20x18

		ld	hl,$c800
		ld	de,$9800
		ld	c,38
		call	DumpChrs

		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,$cc00
		ld	de,$9800
		ld	c,38
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a


		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ret

dummy20x18:	call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
		call	.dummyline
.dummyline:	ld	c,NUMX
		ld	b,0
.cp:		ld	a,[hli]
		res	2,d
		ld	[de],a
		ld	a,[hli]
		set	2,d
		ld	[de],a
		inc	e
		bit	5,h
		jr	z,.nocarry
		ld	a,h
		sub	$10
		ld	h,a
		ldh	a,[hWrkBank]
		inc	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.nocarry:
		dec	c
		jr	nz,.cp
		ld	a,[wMapXSize]
		sub	NUMX
		ld	c,a
		add	hl,bc
		add	hl,bc
		ld	a,h
		cp	$e0
		jr	c,.nocarry2
		sub	$10
		ld	h,a
		ldh	a,[hWrkBank]
		inc	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.nocarry2:
		ld	a,e
		add	32-NUMX
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		ret


		ENDC
;**********************************************************************
;**********************************************************************
;* New scroll routines                                                *
;*                                                                    *
;*                                                                    *
;*                                                                    *
;**********************************************************************
;**********************************************************************


;de=x
;hl=y
NewInitScroll::
		ld	a,d
		cp	$e0
		jr	c,.deok
		ld	de,0
.deok:		ld	a,e
		ld	[wMapXPos],a
		ld	a,d
 inc a
		ld	[wMapXPos+1],a
		rl	e
		rl	d
		rl	e
		rl	d
		rl	e
		rl	d
		ld	a,d
		ldh	[hVblSCX],a
		ld	a,l
		ld	[wMapYPos],a
		ld	a,h
 inc a
		ld	[wMapYPos+1],a
		ld	d,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ldh	[hVblSCY],a
		ld	a,d
		ld	[wMapDown],a
		ld	e,NEWSCROLLHEIGHT
.initput:	push	de
		call	SendRow
		pop	de
		inc	d
		dec	e
		jr	nz,.initput
		ld	hl,wMapDirty
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ret

NewScroll::
		ld	a,d
		cp	$e0
		jr	c,.deok
		ld	de,0
.deok:		ld	a,e
		ld	[wMapXPos],a
		ld	a,d
 inc a
		ld	[wMapXPos+1],a
		rl	e
		rl	d
		rl	e
		rl	d
		rl	e
		rl	d
		ld	a,d
		ldh	[hVblSCX],a

		ld	a,[wMapYPos]
		ld	c,a
		sub	l
		ld	a,[wMapYPos+1]
 dec a
		ld	b,a
		sbc	h
		jr	c,.down
		ld	a,b
		sub	1
		ld	b,a
		jr	nc,.bcok
		ld	bc,0
.bcok:
		ld	a,c
		sub	l
		ld	a,b
		sbc	h
		jr	c,.hlok
		ld	h,b
		ld	l,c
		jr	.hlok
.down:		inc	b
		ld	a,l
		sub	c
		ld	a,h
		sbc	b
		jr	c,.hlok
		ld	h,b
		ld	l,c
.hlok:

		ld	a,l
		ld	[wMapYPos],a
		ld	a,h
 inc a
		ld	[wMapYPos+1],a
		ld	d,h
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		ldh	[hVblSCY],a

		ld	a,[wMapDown]
		sub	d
		ret	z
		jr	nc,.ups
.downs:		push	af
		call	pindown1
		pop	af
		inc	a
		jr	nz,.downs
		ret
.ups:		push	af
		call	pinup1
		pop	af
		dec	a
		jr	nz,.ups
		ret
pindown1:	ld	a,[wMapDown]
		add	NEWSCROLLHEIGHT
		ld	d,a
		call	SendRow
		ld	a,[wMapDown]
		inc	a
		ld	[wMapDown],a
		ret
pinup1:		ld	a,[wMapDown]
		dec	a
		ld	[wMapDown],a
		ld	d,a
		jp	SendRow

SecondHalf::	ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d800
		call	SwdInFileSys
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

OtherPage1::	ld	a,WRKBANK_MAP2
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d000
		call	SwdInFileSys
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

OtherPage2::	ld	a,WRKBANK_MAP2
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d000+7*4*6*6*2
		call	SwdInFileSys
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

OtherPage3::	ld	a,WRKBANK_MAP3
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d000
		call	SwdInFileSys
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

OtherPage4::	ld	a,WRKBANK_MAP3
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d000+7*4*6*6*2
		call	SwdInFileSys
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret



;hl=list, consisting of
;1 byte  = height of bitmap (width is assumed to be 24)
;2 bytes = rgb IDX
;2 bytes = map IDX
NewLoadMap::
		ld	a,[hli]
		ld	[wMapYSize],a

		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		push	hl
		ld	l,e
		ld	h,a
		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopyInFileSys
		pop	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a

		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	de,$d000
		call	SwdInFileSys

		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

NewMapOffsets::	dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400,$9580
		dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400	;,$9580

		dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400,$9580
		dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400	;,$9580

		dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400,$9580
		dw	$8800,$8980,$8b00,$8c80,$8e00
		dw	$8f80,$9100,$9280,$9400	;,$9580

;d=row to send
SendRow:
		ldh	a,[hRomBank]
		push	af

		ld	a,d
.mod:		ld	e,a
		sub	NEWSCROLLHEIGHT
		jr	nc,.mod
		push	de

		ld	a,e
		cp	10
		ld	a,0
		jr	c,.aok
		inc	a
.aok:		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	a,e
		add	a
		add	LOW(NewMapOffsets)
		ld	l,a
		ld	a,0
		adc	HIGH(NewMapOffsets)
		ld	h,a
		ld	c,d
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	l,c
		ld	h,0
		ld	b,h
		add	hl,hl
		add	hl,bc
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d0
		ld	h,a

		push	hl
		ld	a,e
		ldio	[rHDMA4],a
		ld	a,d
		ldio	[rHDMA3],a
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1
		call	Send1

		pop	hl
		pop	bc
		push	bc
		ld	b,0
		ld	a,c
		cp	10
		jr	c,.bok
		ld	b,8
.bok:

		ld	c,24
		ld	de,$c800
.row2:		ld	a,[hl]
		and	7
		bit	3,[hl]
		jr	z,.nodepth
		or	$80
.nodepth:	or	b
		ld	[de],a
		inc	e
		inc	hl
		inc	hl
		dec	c
		jr	nz,.row2
		pop	bc
		ld	e,c
		ld	d,0
		ld	hl,.newmaplows
		add	hl,de
		ld	a,[hl]
		ld	hl,$c820
		ld	c,24
.row1:		ld	[hli],a
		inc	a
		dec	c
		jr	nz,.row1

		ld	a,b
		and	31
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$98
		ld	d,a
		ld	e,l
		push	de
		ld	hl,$c800
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	c,2
		call	DumpChrs
		pop	de
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	c,2
		call	DumpChrs

		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret
.newmaplows:	db	128,152,176,200,224
		db	248,16,40,64,88
		db	128,152,176,200,224
		db	248,16,40,64,88


Send1:
		ld	a,[wPinCharBank]
		ld	b,a
		ld	a,[hli]
		and	$f0
		ld	c,a
		ld	a,[hl]
		rlc	a
		rlc	a
		and	3
		add	b
;		add	BANK(Char00)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a

		ld	a,[hli]
		push	hl
		and	$3f
		add	$40
		ld	h,a
		ld	l,c

.wa:	ldio	a,[rLY]
	dec	a
	cp	140
	jr	nc,.wa

	di
	ld	b,3
.w1:	ldio	a,[rSTAT]
	and	b
	jr	z,.w1
.w2:	ldio	a,[rSTAT]
	and	b
	jr	nz,.w2

	ld	a,l
	ldio	[rHDMA2],a
	ld	a,h
	ldio	[rHDMA1],a
	ld	a,$80
	ldio	[rHDMA5],a
	ei

		pop	hl
		ret

;a=frame number, in 6x6 blocks, 4 wide, 7 high
;hl=where to put
TV::		ld	c,a
		sub	56
		jr	nc,.aok
		ld	a,c
.aok:		ld	e,a
		and	3
		add	a
		ld	d,a
		add	a
		add	d
		ld	d,a
		ld	a,e
		and	$fc
		ld	e,a
		srl	a
		add	e
		ld	e,a
		ld	a,c
		ld	bc,$0606
		ld	hl,$091b

;hl=dest   xy
;de=source xy
;bc=size   xy
		cp	56
		ld	a,WRKBANK_MAP2
		jr	c,anyrect
		ld	a,WRKBANK_MAP3
		jr	anyrect
BGRect::	ld	a,WRKBANK_MAP
anyrect:	ldh	[hTmp4Lo],a

		ld	a,[hRomBank]
		push	af
		ld	a,h
		ldh	[hTmp3Lo],a	;xpos
		ld	a,l
		ldh	[hTmp3Hi],a	;ypos
		ld	a,b
		ldh	[hTmp2Lo],a	;width
		ld	a,c
		ldh	[hTmp2Hi],a	;height
		ld	a,h
		ld	h,0
		ld	b,h
		ld	c,l
		add	hl,hl
		add	hl,bc
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	c,a
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	a,h
		add	$d0
		ld	h,a
		push	hl
		ld	a,d
		ld	l,e
		ld	h,0
		ld	b,h
		ld	c,l
		add	hl,hl
		add	hl,bc
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	c,a
		ld	b,0
		add	hl,bc
		add	hl,bc
		ldh	a,[hTmp4Lo]
		cp	WRKBANK_MAP
		ld	a,$d8
		jr	z,.aok
		ld	a,$d0
.aok:		add	h
		ld	h,a
		push	hl
		ldh	a,[hTmp3Hi]
		ld	b,a
		ldh	a,[hTmp2Hi]
		ld	c,a
.marks:		ld	a,b
		push	bc
		call	MarkDirty
		pop	bc
		inc	b
		dec	c
		jr	nz,.marks


		pop	hl
		pop	de
.bgry:		ld	a,[wMapDown]
		ld	c,a
		ldh	a,[hTmp3Hi]
		sub	c
		jr	c,.skip
		cp	NEWSCROLLHEIGHT
		jr	nc,.skip
		ldh	a,[hTmp2Lo]
.bgrx:		ldh	[hTmpLo],a
		ldh	a,[hTmp4Lo]	;Bank
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		and	c
		inc	a
		jr	z,.same
		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[de]
		cp	c
		jr	nz,.diff
		inc	e
		ld	a,[de]
		dec	e
		cp	b
		jr	z,.same
.diff:		push	de
		ld	a,c
		ld	[de],a
		inc	e
		ld	a,b
		ld	[de],a
		ldh	a,[hTmp3Hi]
		ld	e,a
		ldh	a,[hTmp3Lo]
		ld	d,a
		push	hl
		call	bgentry
		pop	hl
.offscreen:	pop	de
.same:		inc	de
		inc	de
		ldh	a,[hTmp3Lo]
		inc	a
		ldh	[hTmp3Lo],a
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.bgrx
		jr	.noskip
.skip:		ldh	a,[hTmp2Lo]
.fastcopy:	ldh	[hTmpLo],a
		ldh	a,[hTmp4Lo]
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		and	c
		inc	a
		jr	nz,.diff2
		inc	de
		jr	z,.same2
.diff2:		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,c
		ld	[de],a
		inc	de
		ld	a,b
		ld	[de],a
.same2:		inc	de
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.fastcopy
		ldh	a,[hTmp2Lo]
		ld	c,a
		jr	.cont
.noskip:	ldh	a,[hTmp2Lo]
		ld	c,a
		ldh	a,[hTmp3Lo]
		sub	c
		ldh	[hTmp3Lo],a	;xpos
.cont:		ld	a,48
		sub	c
		sub	c
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		ldh	a,[hTmp3Hi]
		inc	a
		ldh	[hTmp3Hi],a	;ypos
		ldh	a,[hTmp2Hi]
		dec	a
		ldh	[hTmp2Hi],a
		jp	nz,.bgry
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

bgentrymap:	db	0,0,0,0,0,0,0,0,0,0
		db	1,1,1,1,1,1,1,1,1
		db	0,0,0,0,0,0,0,0,0,0
		db	1,1,1,1,1,1,1,1,1
		db	0,0,0,0,0,0,0,0,0,0
		db	1,1,1,1,1,1,1,1,1

;bc=char #
;de=xy on new map
bgentry:
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

;		ld	a,e
;.mod:		sub	NEWSCROLLHEIGHT
;		jr	nc,.mod
;		add	NEWSCROLLHEIGHT
;		cp	10
;		ld	a,0
;		jr	c,.cok
;		inc	a
;.cok:
		ld	hl,bgentrymap
		ld	a,d
		ld	d,0
		add	hl,de
		ld	d,a
		ld	a,[hl]
		ldh	[hVidBank],a
		ldio	[rVBK],a

		ld	hl,NewMapOffsets
		ld	a,d
		ld	d,0
		add	hl,de
		add	hl,de
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de
		ld	d,h
		ld	e,l

		ld	a,c
		and	$f0
		ld	l,a
		ld	a,b
		and	$3f
		or	$40
		ld	h,a

		ld	a,[wPinCharBank]
		ld	c,a
		ld	a,b
		rlca
		rlca
		and	3
		add	c
;		add	BANK(Char00)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a

		jp	FastDumpChr


Bits::		db	1,2,4,8,16,32,64,128
;a=row to mark
MarkDirty:	ld	c,a
		ld	hl,wMapDown
		sub	[hl]
		ret	c
		cp	NEWSCROLLHEIGHT
		ret	nc
		ld	a,c
		srl	c
		srl	c
		srl	c
		ld	b,0
		ld	d,b
		and	7
		ld	e,a
		ld	hl,Bits
		add	hl,de
		ld	a,[hl]
		ld	hl,wMapDirty
		add	hl,bc
		or	[hl]
		ld	[hl],a
		ret
