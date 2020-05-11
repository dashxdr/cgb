; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SPRITESB.ASM                                                   MODULE **
; **                                                                       **
; ** Sprite drawing functions (banked).                                    **
; **                                                                       **
; ** Last modified : 05 Nov 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

		SECTION	03


; ***************************************************************************
; * CgbSprDumpLoop ()                                                       *
; ***************************************************************************
; * Dump sprite LRTB                                                        *
; ***************************************************************************
; * Inputs      BC = DstChr                                                 *
; *             DE = DstOam                                                 *
; *             SP = SrcSpr                                                 *
; *                                                                         *
; * Outputs     BC = Updated DstChr                                         *
; *             DE = Updated DstOam                                         *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This routine is $C1 bytes long.                             *
; ***************************************************************************

KC		EQUS	"(SprDumpLoop-CgbSprDumpLoop)"

;
; Dump 8x16 sprite LRTB.
;

CgbSprDumpLoop::LDH	A,[hSprNxt]		;3   Get sprite number.
CgbSprDumpMax::	CP	$80			;2
		JP	NC,CgbSprDumpDone+KC	;3/2 (07 cycles total)

		POP	HL			;3   Get sprite XY offsets.
CgbSprDumpYPos::LD	A,$10-$00		;2   Get Y coordinate.
		ADD	L			;1   Add Y offset.
		LD	[DE],A			;2
		INC	E			;1
CgbSprDumpXPos::LD	A,$08-$00		;2   Get X coordinate.
		ADD	H			;1   Add X offset.
;		LD	A,$08-$07		;2   Get X coordinate.
;		SUB	H			;1   Sub X offset.
		LD	[DE],A			;2
		INC	E			;1   (15 cycles total)

		POP	HL			;3   Get character address.
		LD	[CgbSprDumpNext+1+KC],SP;5
		LD	SP,HL			;3
		LD	L,C			;1
		LD	H,B			;1   (13 cycles total)

CgbSprDumpHbl0::POP	BC			;3   Read bytes 0&1.

.Sync0:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;1   HBL is finished.
		JR	Z,.Sync0		;3/2
.Wait0:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;1
		JR	NZ,.Wait0		;3/2 (15 cycles total)

		LD	A,C			;1   Copy bytes 0&1.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 2&3.
		LD	A,C			;1   Copy bytes 2&3.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 4&5.
		LD	A,C			;1   Copy bytes 4&5.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 6&7.
		LD	A,C			;1   Copy bytes 6&7.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 8&9.
		LD	A,C			;1   Copy bytes 8&9.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 10&11.
		LD	A,C			;1   Copy bytes 10&11.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 12&13.
		LD	A,C			;1   Copy bytes 12&13.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 14&15.
		LD	A,C			;1   Copy bytes 14&15.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2   (69 cycles total)

		LD	[CgbSprDumpIrq0+9+KC],SP;5   Make sure that we don't
		LD	SP,wSprDumpStack	;3   keep interrupts disabled
		EI				;1   for too long.
CgbSprDumpIrq0::LDIO	A,[rLY]			;3
		DEC	A			;1
		CP	140			;2
		JR	NC,CgbSprDumpIrq0	;3/2
		DI				;1
		LD	SP,0			;3   (21 cycles total)

		LDH	A,[hSprNxt]		;3   Get sprite number.
		LD	[DE],A			;2
		INC	E			;1
		ADD	2			;2
		LDH	[hSprNxt],A		;3
		LDH	A,[hSprPal]		;3   Get flags.
		LD	[DE],A			;2
		INC	E			;1   (17 cycles total)

CgbSprDumpHbl1::POP	BC			;3   Read bytes 0&1.

.Sync1:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;1   HBL is finished.
		JR	Z,.Sync1		;3/2
.Wait1:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;1
		JR	NZ,.Wait1		;3/2 (15 cycles total)

		LD	A,C			;1   Copy bytes 0&1.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 2&3.
		LD	A,C			;1   Copy bytes 2&3.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 4&5.
		LD	A,C			;1   Copy bytes 4&5.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 6&7.
		LD	A,C			;1   Copy bytes 6&7.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 8&9.
		LD	A,C			;1   Copy bytes 8&9.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 10&11.
		LD	A,C			;1   Copy bytes 10&11.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 12&13.
		LD	A,C			;1   Copy bytes 12&13.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2
		POP	BC			;3   Read bytes 14&15.
		LD	A,C			;1   Copy bytes 14&15.
		LD	[HLI],A			;2
		LD	A,B			;1
		LD	[HLI],A			;2   (69 cycles total)

CgbSprDumpNext::LD	SP,0			;3
		LD	C,L			;1
		LD	B,H			;1

		LDH	A,[hSprCnt]		;3
		DEC	A			;1
		LDH	[hSprCnt],A		;3
		JP	NZ,CgbSprDumpLoop+KC	;4/3 (10 cycles total)

CgbSprDumpDone::LD	SP,0			;3   Restore SP.
		EI				;1

		LD	A,E			;1   Update ring buffer.
		LDH	[hOamBufLo],A		;3

		LDHL	SP,SPR_OAM_LO+4		;3   Save attribute count.
		SUB	[HL]			;2
		RRCA				;1
		RRCA				;1
		DEC	L			;1
		LD	[HL],A			;2

		POP	AF			;3   Restore calling rom
		LDH	[hRomBank],A		;3   bank.
		LD	[rMBC_ROM],A		;4

		RET				;4   (24 cycles, 17 bytes)

CgbSprDumpExit::NOP



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SPRITESB.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
