; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SPRITES.ASM                                                    MODULE **
; **                                                                       **
; ** Sprite drawing functions.                                             **
; **                                                                       **
; ** Last modified : 05 Nov 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"sprites",HOME
		section 0


; ***************************************************************************
; * SprPlot ()                                                              *
; ***************************************************************************
; * Plot all sprites                                                        *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0

SprPlot::	LDH	A,[hSprMax]		;Calc next character number.
		ADD	40
		CP	40*4
		JR	NZ,SprPlotWrap
		LD	A,40
SprPlotWrap::	LDH	[hSprMax],A
		SUB	40
		LDH	[hSprNxt],A

		LD	L,A			;Calc next character address.
		LD	H,$80/16
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		ADD	HL,HL
		LD	C,L
		LD	B,H

		LD	[wSprPlotSP],SP

SprDumpPlyr::	LDH	A,[hCycleCount]		;Alternate which sprites to
		RRA				;dump, and the order to dump
		JR	C,SprDumpOdd		;them, every 4 cycles.

SprDumpEven::	JR	SprPlotOam		;

SprDumpOdd::	JR	SprPlotOam		;

SprPlotOam::	LDH	A,[hOamPointer]		;Locate OAM shadow buffer.
		LD	D,A			;
		LD	E,0			;

;call SprDraw various times...


SprPlotEnd::	LDH	A,[hOamPointer]		;Blank out the remaining OAM
		LD	H,A			;entries in the OAM buffer.
		LD	L,E			;
		LD	A,160
		SUB	L
		JR	Z,SprPlotExit
		RRCA
		RRCA
		LD	E,A
		XOR	A
SprPlotClr::	LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		DEC	E
		JR	NZ,SprPlotClr

SprPlotExit::	LD	HL,wSprPlotSP		;Restore stack pointer.
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL

		RET

SprPlot2nd::	LD	[wSprPlotSP],SP
		JP	SprPlotOam

		ENDC



; ***************************************************************************
; * SprDraw ()                                                              *
; ***************************************************************************
; * Update the complete screen edge of the background screen (at $9800)     *
; ***************************************************************************
; * Inputs      SP+2 = Sprite Control Block                                 *
; *             DE = Sprite OAM block to write to                           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Time taken is 21*7 horizontal blanks.                       *
; ***************************************************************************

SprDraw::	LDHL	SP,SPR_FLAGS+2		;Get flags.
		LD	A,[HL]			;
		BIT	FLG_PLOT,A		;Plot flag set (sprite) ?
		RET	Z			;Return Z to indicate OK.

		LDHL	SP,SPR_SCR_X+2		;

		LD	A,[HLI]			;Get SPR_SCR_X.
		LDH	[hSprXLo],A		;
		LD	A,[HLI]			;
		LDH	[hSprXHi],A		;

		LD	A,[HLI]			;Get SPR_SCR_Y.
		LDH	[hSprYLo],A		;
		LD	A,[HLI]			;
		LDH	[hSprYHi],A		;

		LDHL	SP,SPR_OAM_CNT+2	;Get SPR_OAM_CNT.
		LD	A,[HLI]			;
		OR	A			;
		RET	Z			;

		LD	C,[HL]			;Get SPR_OAM_LO/HI ptr
		INC	L			;to attribute data.
		LD	H,[HL]			;
		LD	L,C			;

SprDrawLoop::	LDH	[hSprCnt],A		;3

		LD	A,E			;1   OAM_BUFFER full ?
		CP	$A0			;2
		RET	Z			;5/2

		LD	A,[HLI]			;2   Get 16-bit Y offset.
		LD	C,A			;1
		ADD	A			;1
		SBC	A			;1
		LD	B,A			;1

		LDH	A,[hSprYLo]		;3   Add current Y coordinate.
		ADD	C			;1
		JR	Z,SprDrawFail		;3/2
		LD	[DE],A			;2
		LDH	A,[hSprYHi]		;3
		ADC	B			;1
		JR	NZ,SprDrawFail		;3/2
		LD	A,[DE]			;2
		INC	E			;1
		CP	144+16			;2
		JR	NC,SprDrawFail		;3/2

		LD	A,[HLI]			;2   Get 16-bit X offset.
		LD	C,A			;1
		ADD	A			;1
		SBC	A			;1
		LD	B,A			;1

		LDH	A,[hSprXLo]		;3   Add current X coordinate.
		ADD	C			;1
		JR	Z,SprDrawFail		;3/2
		LD	[DE],A			;2
		LDH	A,[hSprXHi]		;3
		ADC	B			;1
		JR	NZ,SprDrawFail		;3/2
		LD	A,[DE]			;2
		INC	E			;1
		CP	160+8			;2
		JR	NC,SprDrawFail		;3/2

		LD	A,[HLI]			;2   Copy character.
		LD	[DE],A			;2
		INC	E			;1

		LD	A,[HL]			;2   Copy flags.
		LD	[DE],A			;2
		INC	E			;1

		INC	L			;1   Don't change page.

		LD	A,[hSprCnt]		;3
		DEC	A			;1
		JR	NZ,SprDrawLoop		;3/2

		RET				;4

SprDrawFail::	LD	A,L			;1
		ADD	$03			;2
		AND	$FC			;2
		LD	L,A			;1
		LD	A,E			;1
		AND	$FC			;2
		LD	E,A			;1

		LD	A,[hSprCnt]		;3
		DEC	A			;1
		JR	NZ,SprDrawLoop		;3/2

		RET				;4



; ***************************************************************************
; * SprDumpInit ()                                                          *
; ***************************************************************************
; * Copy the appropriate sprite dumping code to ram                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KG		EQUS	"(SprDumpLoop-GmbSprDumpLoop)"
KC		EQUS	"(SprDumpLoop-CgbSprDumpLoop)"

SprDumpInit::	LDH	A,[hRomBank]
		PUSH	AF

		LDH	A,[hMachine]
		CP	MACHINE_CGB

		IFEQ	USE_GMB_SPR
		JR	Z,SprDumpInitCgb
		ENDC

SprDumpInitGmb::LD	A,BANK(GmbSprDumpLoop)
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		LD	HL,GmbSprDumpLoop
		LD	DE,SprDumpLoop
		LD	BC,GmbSprDumpExit-GmbSprDumpLoop
		CALL	MemCopy
		POP	AF
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		RET

SprDumpInitCgb::LD	A,BANK(CgbSprDumpLoop)
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		LD	HL,CgbSprDumpLoop
		LD	DE,SprDumpLoop
		LD	BC,CgbSprDumpExit-CgbSprDumpLoop
		CALL	MemCopy
		POP	AF
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		RET



; ***************************************************************************
; * SprDumpSmod ()                                                          *
; ***************************************************************************
; * Modify the dumping code to pause and enable irqs on a certain scanline  *
; ***************************************************************************
; * Inputs      A = scanline that you need interrupts to be enabled on      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbSprDumpSmod::
		IFEQ	USE_GMB_SPR
		SUB	5
		LD	[CgbSprDumpIrq0+4+KC],A	;4
		LDH	[hCutoff],A
		RET
		ENDC

GmbSprDumpSmod::
		SUB	6
		LD	[GmbSprDumpIrq0+4+KG],A	;4
		LD	[GmbSprDumpIrq1+4+KG],A	;4
		LD	[GmbSprDumpIrq2+4+KG],A	;4
		LDH	[hCutoff],A
		RET




; ***************************************************************************
; * SprDump ()                                                              *
; ***************************************************************************
; * Dump a new sprite frame to VRAM and update the sprite's SPR_OAM_BUF     *
; ***************************************************************************
; * Inputs      SP+2 = Sprite Control Block                                 *
; *             BC   = DstChr                                               *
; *                                                                         *
; * Outputs     BC   = updated DstChr                                       *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SprDump::	LDHL	SP,SPR_FLAGS+2		;Get flags.
		LD	A,[HL]			;
		BIT	FLG_DRAW,A		;Draw flag set (sprite) ?
		RET	Z			;Return Z to indicate OK.

		LDHL	SP,SPR_OAM_CNT+2	;Clear sprite count.
		XOR	A			;
		LD	[HLI],A			;

		LDH	A,[hOamBufLo]		;Get destination buffer.
		LD	[HLI],A			;
		LD	E,A			;
		LDH	A,[hOamBufHi]		;
		LD	[HLI],A			;
		LD	D,A

;		LDHL	SP,SPR_FLAGS+2		;Get flags.
;		LD	A,[HL]			;
;		BIT	FLG_DRAW,A		;Draw flag set (sprite) ?
;		RET	Z			;Return Z to indicate OK.

		LDHL	SP,SPR_FLIP+2		;Get SPR_FLIP + SPR_PALETTE.
		LD	A,[HLI]			;
		OR	[HL]			;
		LDH	[hSprPal],A		;

		LDH	A,[hRomBank]		;Preserve calling rom bank.
		PUSH	AF			;

		PUSH	BC			;Preserve DstChr ptr.

		LD	BC,AllSprites		;Get SPR_TABLE_ADDR.
		LD	A,BANK(AllSprites)	;Get SPR_TABLE_BANK.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LDHL	SP,SPR_FRAME+6		;Get SPR_FRAME.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		ADD	HL,HL			;Index into SPR_TABLE.
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Get sprite data addr.
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;

		LD	A,[HLI]			;Get sprite data bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	L,C			;
		LD	H,B			;

		POP	BC			;Restore DstChr ptr.

		LDH	A,[hSprPal]		;Is the sprite X-flipped ?
		BIT	5,A			;
		JP	Z,wJmpSprLRTB		;

		JP	wJmpSprRLTB		;



; ***************************************************************************
; * GmbDumpLRTB ()                                                          *
; ***************************************************************************
; * Dump sprite LRTB                                                        *
; ***************************************************************************
; * Inputs      BC = DstChr                                                 *
; *             DE = DstOam                                                 *
; *             HL = SrcSpr                                                 *
; *                                                                         *
; * Outputs     BC = Updated DstChr                                         *
; *             DE = Updated DstOam                                         *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbSprDumpLRTB::LD	A,$08-$00		;2
		LD	[GmbSprDumpXPos+1+KG],A	;4
		LD	A,$84			;2
		LD	[GmbSprDumpXPos+2+KG],A	;4

		JR	GmbSprDumpCode		;3

GmbSprDumpRLTB::LD	A,$08-$07		;2
		LD	[GmbSprDumpXPos+1+KG],A	;4
		LD	A,$94			;2
		LD	[GmbSprDumpXPos+2+KG],A	;4

GmbSprDumpCode::LDH	A,[hSprMax]		;3
		LD	[GmbSprDumpMax+1+KG],A	;4

		DI				;1   Set HL=DstChr
		LD	[GmbSprDumpDone+1+KG],SP;5   Set DE=DstOam
		LD	SP,HL			;3

		POP	HL			;3   Get sprite's count.

		LDH	A,[hSprPal]		;3   Get SPR_PALETTE.
		OR	L			;1
		LDH	[hSprPal],A		;3

		LD	A,H			;1   Get SPR_OAM_CNT.
		SRL	A			;2
		JP	Z,GmbSprDumpDone+KG	;3/2

		LDH	[hSprCnt],A		;3

;		JP	NC,GmbLRTB1_Loop	;4/3 Process 1x1 sprite.
;		JP	C,GmbLRTB2_Loop		;4/3 Process 1x2 sprite.

		JP	SprDumpLoop		;4   Goto self-modifying code.



; ***************************************************************************
; * CgbDumpLRTB ()                                                          *
; ***************************************************************************
; * Dump sprite LRTB                                                        *
; ***************************************************************************
; * Inputs      BC = Dst chr address                                        *
; *             DE = Dst oam address                                        *
; *             HL = Src spr address                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbSprDumpLRTB::LD	A,$08-$00		;2
		LD	[CgbSprDumpXPos+1+KC],A	;4
		LD	A,$84			;2
		LD	[CgbSprDumpXPos+2+KC],A	;4

		JR	CgbSprDumpCode		;3

CgbSprDumpRLTB::LD	A,$08-$07		;2
		LD	[CgbSprDumpXPos+1+KC],A	;4
		LD	A,$94			;2
		LD	[CgbSprDumpXPos+2+KC],A	;4

CgbSprDumpCode::LDH	A,[hSprMax]		;3
		LD	[CgbSprDumpMax+1+KC],A	;4

		DI				;1   Set HL=DstChr
		LD	[CgbSprDumpDone+1+KC],SP;5   Set DE=DstOam
		LD	SP,HL			;3

		POP	HL			;3   Get sprite's count.

		LDH	A,[hSprPal]		;3   Get SPR_PALETTE.
		OR	L			;1
		LDH	[hSprPal],A		;3

		LD	A,H			;1   Get SPR_OAM_CNT.
		SRL	A			;2
		JP	Z,CgbSprDumpDone+KC	;3/2

		LDH	[hSprCnt],A		;3

;		JP	NC,CgbLRTB1_Loop	;4/3 Process 1x1 sprite.
;		JP	C,CgbLRTB2_Loop		;4/3 Process 1x2 sprite.

		JP	SprDumpLoop		;4   Goto self-modifying code.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SPRITES.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

