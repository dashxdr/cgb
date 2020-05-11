; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** GROUPS.ASM                                                            **
; **                                                                       **
; ** Last modified : 991115 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

  IF 0

		include	"equates.equ"

		section	00

; ***************************************************************************
; * RegisterGroup                                                           *
; ***************************************************************************
; * Inputs      DE=Group List structure,                                    *
;               A=BANK # of list                                            *
; * Outputs     A=ID # to be used for bringing up sprite frames             *
; * Preserves   None                                                        *
; * Function    Register a group structure                                  *
;               Loads up color table for appropriate sprite                 *
; ***************************************************************************
;Group structure is 8 bytes
;1 byte bank of list
;1 byte sprite value (for color map)
;2 bytes pointer to list
;4 bytes spare
RegisterGroup::
		ld	b,a
		ld	hl,wGroupCount
		ld	a,[hl]
		inc	[hl]
		ld	hl,wGroups
		ld	c,a
		add	a
		add	a
		add	a
		call	addahl
		ld	[hl],b	;BANK
		inc	hl
		ld	a,[wPalCount]
		ld	[hli],a	;sprite color value
		ld	[hl],e	;Pointer Lo
		inc	hl
		ld	[hl],d	;Pointer Hi
		inc	hl
		ld	a,[de]	;# of cels in this anim
		ldh	[hTmp2Lo],a
		inc	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.nocolor
		ldh	a,[hRomBank]
		push	af

.sendpallp:
		LD	A,B
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,[de]	;Get Palette pointer from anim list
		ld	l,a
		inc	de
		ld	a,[de]
		ld	h,a
		inc	de
		inc	de
		inc	de
		push	de
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,[wPalCount]
		inc	a
		ld	[wPalCount],a
		dec	a
		add	a
		add	a
		add	a
		ld	de,wOcpArcade
		add	e
		ld	e,a
		push	bc
		ld	bc,8
		call	MemCopy
		pop	bc
		pop	de
		ldh	a,[hTmp2Lo]
		dec	a
		ldh	[hTmp2Lo],a
		jr	nz,.sendpallp

		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
.nocolor:	ld	a,c
		ret

; ***************************************************************************
; * AddFrame                                                                *
; ***************************************************************************
; * Inputs:     B=Fig group ID #                                            *
; *             DE=Frame # within the group (1 is first)                    *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Adds a frame to the figure list                             *
; ***************************************************************************

AddFrame::	ld	a,d
		or	e
		ret	z
		dec	de
		ldh	a,[hRomBank]
		push	af

		ld	hl,wGroups
		ld	a,b
		and	7
		add	a
		add	a
		add	a
		call	addahl
		ld	a,[hli]	;Group's ROM bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,b
		and	$10
		ld	b,a
		ld	a,[hli]	;Sprite color value
		or	b
		ldh	[hTmp2Lo],a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hli]	;# of cels per frame
		ld	[wCelsPerFrame],a
		ldh	[hTmp2Hi],a
		ld	b,d
		ld	c,e
		ld	d,h
		ld	e,l
		inc	de
		inc	de
		add	a
		add	a
		call	addahl
		sla	c
		rl	b
		sla	c
		rl	b
		ldh	a,[hTmp2Hi]
.mul3:		add	hl,bc
		dec	a
		jr	nz,.mul3
.addfiglp:	ld	a,[hli]
		ldh	[hTmp3Lo],a	;sprite #
		ld	a,[hli]
		ldh	[hTmp3Hi],a	;sprite palette and xflip
		ld	a,[hli]
		ldh	[hTmp4Lo],a	;x
		ld	a,[hli]
		ldh	[hTmp4Hi],a	;y
		ldh	a,[hTmp3Lo]
		cp	255
		jp	z,.skip

		push	de
		push	hl
		ld	[wSprPlotSP],sp

		ld	hl,wFigCount
		ld	a,[hl]
		inc	[hl]
		add	a
		add	LOW(FigureTable)
		ld	l,a
		ld	h,HIGH(FigureTable)
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	sp,hl

		LDHL	SP,SPR_SCR_X
		ldh	a,[hTmp4Lo]
		add	80
		ld	[hli],a
		cp	80+128
		ld	a,0
		jr	c,.aok1
		dec	a
.aok1:		ld	[hli],a
		ldh	a,[hTmp4Hi]
		add	72
		ld	[hli],a
		cp	72+128
		ld	a,0
		jr	c,.aok2
		dec	a
.aok2:		ld	[hl],a
		LDHL	SP,SPR_FLAGS
		ld	a,(1<<FLG_DRAW)|(1<<FLG_PLOT)
		ld	[hl],a

		ldh	a,[hTmp3Hi]	;Sprite's X flip bit (0x80)
		and	$80
		srl	a
		srl	a
		LDHL	SP,SPR_FLIP
		ld	[hli],a ;SPR_FLIP
		ldh	a,[hTmp3Hi]
		ld	c,a
		ldh	a,[hTmp2Lo]
		add	c
		and	$1f
		ld	[hl],a	;SPR_COLR

		ld	a,c
		add	a
		add	a
		push	de
		add	e
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,[de]
		ld	c,a
		inc	de
		ld	a,[de]
		ld	d,a
		ld	e,c
		LDHL	SP,SPR_FRAME+2
		ldh	a,[hTmp3Lo]	;sprite #
		add	e
		ld	[hli],a
		ld	a,d
		adc	0
		ld	[hl],a
		pop	de

		ldh	a,[hSprNxt]
		ld	l,a
		ld	h,$80>>4
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	b,h
		ld	c,l
		call	SprDump
		LD	HL,wSprPlotSP		;Restore stack pointer.
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL
		pop	hl
		pop	de
.skip:		ldh	a,[hTmp2Hi]
		dec	a
		ldh	[hTmp2Hi],a
		jp	nz,.addfiglp

		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A

		ret

  ENDC
