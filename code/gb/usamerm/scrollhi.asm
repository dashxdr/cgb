; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SCROLLHI.ASM                                                          **
; **                                                                       **
; ** Last modified : 20000214 by David Ashley                              **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

		SECTION	03

ProcessDirties::
		ld	d,0
		ld	a,[wMapDirty]
		or	a
		call	nz,.do8
		ld	d,8
		ld	a,[wMapDirty+1]
		or	a
		call	nz,.do8
		ld	d,16
		ld	a,[wMapDirty+2]
		or	a
		call	nz,.do8
		ld	d,24
		ld	a,[wMapDirty+3]
		or	a
		call	nz,.do8
		ld	d,32
		ld	a,[wMapDirty+4]
		or	a
		call	nz,.do8
		ld	d,40
		ld	a,[wMapDirty+5]
		or	a
		call	nz,.do8
		ld	hl,wMapDirty
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ret
.do8:		ld	e,a
.do8lp:		srl	e
		jr	nc,.notdirty
		push	de
		call	UpdateRowPals
		pop	de
.notdirty:	inc	d
		ld	a,e
		or	a
		jr	nz,.do8lp
		ret

;d=row to update
UpdateRowPals::	ld	a,d
.mod:		ld	e,a
		sub	NEWSCROLLHEIGHT
		jr	nc,.mod
		ld	l,d
		ld	h,0
		ld	b,h
		ld	c,l
		add	hl,hl
		add	hl,bc
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d0
		ld	h,a


		ld	b,0
		ld	a,e
		cp	10
		jr	c,.bok
		ld	b,8
.bok:
		push	de

		ld	a,WRKBANK_MAP
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

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

		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		pop	af
		and	$1f
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
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,$c800
		ld	c,2
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ret
