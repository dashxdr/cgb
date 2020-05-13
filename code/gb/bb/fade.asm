; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** FADE.ASM                                                       MODULE **
; **                                                                       **
; ** Palette fade routines.                                                **
; **                                                                       **
; ** Last modified : 28 Oct 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"fade",HOME
		section 0


; ***************************************************************************
; * FadeInWhite ()                                                          *
; * FadeOutBlack ()                                                         *
; ***************************************************************************
; * Wait for screen to fade out to black                                    *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FadeInWhite::	LD	A,255&(0+0)		;Palettes must have already
		LD	[wFadeWanted],A		;been set up by caller.
		JR	FadeInUp		;

FadeOutBlack::	LD	A,%11111111		;
		LD	[wFadeVblBGP],A		;
		LD	[wFadeOBP0],A		;
		LD	[wFadeOBP1],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,255&(0-32)		;
		LD	[wFadeWanted],A		;

FadeInUp::	LD	A,FADE_DELAY		;Initialize fade delay.
		LD	[wFadeUpCount],A	;

.Wait:		CALL	wJmpFadeColor		;Process screen fade.

		CALL	WaitForVBL		;Wait for fade.

		LD	A,[wFadeUpCount]	;Fade finished ?
		OR	A			;
		JR	NZ,.Wait		;

		JP	WaitForVBL		;Wait for final update.



; ***************************************************************************
; * FadeInBlack ()                                                          *
; * FadeOutWhite ()                                                         *
; ***************************************************************************
; * Wait for screen to fade out to black                                    *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FadeInBlack::	LD	A,255&(0+0)		;Palettes must have already
		LD	[wFadeWanted],A		;been set up by caller.
		JR	FadeInDown		;

FadeOutWhite::	LD	A,%00000000		;
		LD	[wFadeVblBGP],A		;
		LD	[wFadeOBP0],A		;
		LD	[wFadeOBP1],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,255&(0+32)		;
		LD	[wFadeWanted],A		;

FadeInDown::	LD	A,FADE_DELAY		;Initialize fade delay.
		LD	[wFadeDnCount],A	;

.Wait:		CALL	wJmpFadeColor		;Process screen fade.

		CALL	WaitForVBL		;Wait for fade.

		LD	A,[wFadeDnCount]	;Fade finished ?
		OR	A			;
		JR	NZ,.Wait		;

		JP	WaitForVBL		;Wait for final update.



; ***************************************************************************
; * GmbFadePalette ()                                                       *
; ***************************************************************************
; * Process vlbank palette fade for GMB                                     *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * Duration    Minimum 15 cycles, maximum 119 cycles.                      *
; ***************************************************************************

GmbFadePalette::LD	A,[wFadeDnCount]
		OR	A
		JR	NZ,GmbFadeDn
		LD	A,[wFadeUpCount]
		OR	A
		JR	NZ,GmbFadeUp
		RET



; ***************************************************************************
; * FadeUpGmb ()                                                            *
; ***************************************************************************
; * Fade up all palettes to desired levels                                  *
; ***************************************************************************
; * Inputs      A    Current NZ value of FADE_UP_COUNT                      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * Duration    Minimum 9 cycles, maximum 104 cycles.                       *
; ***************************************************************************

GmbFadeUp::	DEC	A
		JR	NZ,GmbFadeUpDone

		LD	C,A

		LD	A,[wFadeOBP0]
		LD	D,A
		LDH	A,[hVblOBP0]
		CALL	GmbFadeUpValue
		LDH	[hVblOBP0],A

		LD	A,[wFadeOBP1]
		LD	D,A
		LDH	A,[hVblOBP1]
		CALL	GmbFadeUpValue
		LDH	[hVblOBP1],A

		LD	A,[wFadeVblBGP]
		LD	D,A
		LDH	A,[hVblBGP]
		CALL	GmbFadeUpValue
		LDH	[hVblBGP],A

		LD	A,[wFadeLycBGP]
		LD	D,A
		LDH	A,[hLycBGP]
		CALL	GmbFadeUpValue
		LDH	[hLycBGP],A

		LD	A,C
		OR	A
		JR	Z,GmbFadeUpDone

		LD	A,FADE_DELAY

GmbFadeUpDone::	LD	[wFadeUpCount],A

		LD	A,255			;Signal that there is a new
		LDH	[hPalFlag],A		;palette to dump.

		RET

GmbFadeUpValue::LD	E,A
		XOR	D
		LD	D,A
		RRCA
		OR	D
		AND	%01010101
		JR	Z,.Skip
		INC	C
.Skip:		ADD	E
		RET



; ***************************************************************************
; * FadeDnGmb ()                                                            *
; ***************************************************************************
; * Fade down all palettes to desired levels                                *
; ***************************************************************************
; * Inputs      A    Current NZ value of FADE_DN_COUNT                      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * Duration    Minimum 9 cycles, maximum 112 cycles.                       *
; ***************************************************************************

GmbFadeDn::	DEC	A
		JR	NZ,GmbFadeDnDone

		LD	C,A

		LD	A,[wFadeOBP0]
		LD	D,A
		LDH	A,[hVblOBP0]
		CALL	GmbFadeDnValue
		LDH	[hVblOBP0],A

		LD	A,[wFadeOBP1]
		LD	D,A
		LDH	A,[hVblOBP1]
		CALL	GmbFadeDnValue
		LDH	[hVblOBP1],A

		LD	A,[wFadeVblBGP]
		LD	D,A
		LDH	A,[hVblBGP]
		CALL	GmbFadeDnValue
		LDH	[hVblBGP],A

		LD	A,[wFadeLycBGP]
		LD	D,A
		LDH	A,[hLycBGP]
		CALL	GmbFadeDnValue
		LDH	[hLycBGP],A

		LD	A,C
		OR	A
		JR	Z,GmbFadeDnDone

		LD	A,FADE_DELAY

GmbFadeDnDone::	LD	[wFadeDnCount],A

		LD	A,255			;Signal that there is a new
		LDH	[hPalFlag],A		;palette to dump.

		RET

GmbFadeDnValue::LD	E,A
		XOR	D
		LD	D,A
		RRCA
		OR	D
		AND	%01010101
		JR	Z,.Skip
		INC	C
.Skip:		SUB	E
		CPL
		INC	A
		RET



; ***************************************************************************
; * CgbFadePalette ()                                                       *
; ***************************************************************************
; * Process vlbank palette fade for CGB                                     *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * Duration    Approx 6000 cycles (very slow).                             *
; ***************************************************************************

		DB	 0, 0, 0, 0, 0, 0, 0, 0
		DB	 0, 0, 0, 0, 0, 0, 0, 0
		DB	 0, 0, 0, 0, 0, 0, 0, 0
		DB	 0, 0, 0, 0, 0, 0, 0, 0
TblFadeOffset::	DB	 0, 1, 2, 3, 4, 5, 6, 7
		DB	 8, 9,10,11,12,13,14,15
		DB	16,17,18,19,20,21,22,23
		DB	24,25,26,27,28,29,30,31
		DB	31,31,31,31,31,31,31,31
		DB	31,31,31,31,31,31,31,31
		DB	31,31,31,31,31,31,31,31
		DB	31,31,31,31,31,31,31,31
		DB	31

CgbFadePalette::LD	A,[wFadeDnCount]	;
		OR	A			;
		JR	NZ,CgbFadeCompare	;
		LD	A,[wFadeUpCount]	;
		OR	A			;
		JR	NZ,CgbFadeCompare	;
		RET

CgbFadeCompare::LD	A,[wFadeOffset]		;Fade finished ?
		LD	B,A			;
		LD	A,[wFadeWanted]		;
		SUB	B			;
		JR	NZ,CgbFadeProcess	;

		XOR	A			;Signal that the fade is
		LD	[wFadeUpCount],A	;finished.
		LD	[wFadeDnCount],A	;
		DEC	A			;
		LDH	[hPalFlag],A		;
		RET				;

CgbFadeProcess::ADD	A			;Move the offset towards the
		SBC	A			;desired value.
		ADD	A			;
		INC	A			;
		ADD	A			;
		ADD	B			;
		LD	[wFadeOffset],A		;

		LD	HL,TblFadeOffset	;Locate the table of offsets.
		LD	C,A			;
		ADD	A			;
		SBC	A			;
		LD	B,A			;
		ADD	HL,BC			;

		LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	DE,wTblColorFade	;Construct the fade offset
		LD	BC,32			;table.
		CALL	MemCopy			;

		LD	HL,wBcpShadow		;Fade 8 background palettes.
		LD	DE,wBcpArcade		;
		CALL	FadeColorSet		;

		LD	HL,wOcpShadow		;Fade 8 foreground palettes.
		LD	DE,wOcpArcade		;
		CALL	FadeColorSet		;

;		LD	HL,wBcpShadowTop	;Fade top panel palette.
;		LD	DE,wBcpArcadeTop	;
;		CALL	FadeColorPal		;

;		LD	HL,wBcpShadowBtm	;Fade btm panel palette.
;		LD	DE,wBcpArcadeBtm	;
;		CALL	FadeColorPal		;

		POP	AF			;Restore the original ram
		LDH	[hWrkBank],A		;bank.
		LDIO	[rSVBK],A		;

		LD	A,255			;Signal that there is a new
		LDH	[hPalFlag],A		;palette to dump.

		RET				;



; ***************************************************************************
; * FadeColorSet ()                                                         *
; * FadeColorPal ()                                                         *
; * FadeColorReg ()                                                         *
; ***************************************************************************
; * Fade a color palette by a specific offset according to wTblColorFade    *
; ***************************************************************************
; * Inputs      DE   = Ptr to src palette                                   *
; *             HL   = Ptr to dst palette                                   *
; *                                                                         *
; * Outputs     DE   = Updated ptr to src palette                           *
; *             HL   = Updated ptr to dst palette                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses 32-byte TblColorFade lookup table for each rgb value   *
; *                                                                         *
; *             298 cycles per palette, 2490 cycles per 8-palette set.      *
; ***************************************************************************

FadeColorSet::	CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312
		CALL	FadeColorPal		;312

FadeColorPal::	CALL	FadeColorReg		;78
		CALL	FadeColorReg		;78
		CALL	FadeColorReg		;78

FadeColorReg::	LD	A,[DE]			;2   Read lo-byte.
		LD	C,A			;1
		INC	E			;1
		LD	A,[DE]			;2   Read hi-byte.
		LD	B,A			;1
		INC	E			;1   (08 cycles total)

		PUSH	DE			;4   Preserve src pointer.
		LD	D,HIGH(wTblColorFade);2

		LD	A,C			;1   Translate red component.
		AND	%00011111		;2
		LD	E,A			;1
		LD	A,[DE]			;2
		LD	[HLI],A			;2   (08 cycles total)

		LD	A,B			;1   Translate blu component.
		AND	%01111100		;2
		RRCA				;1
		RRCA				;1
		LD	E,A			;1
		LD	A,[DE]			;2
		RLCA				;1
		RLCA				;1
		LD	[HLD],A			;2   (12 cycles total)

		LD	A,C			;1   Translate grn component.
		AND	%11100000		;2
		LD	C,A			;1
		LD	A,B			;1
		AND	%00000011		;2
		OR	C			;1
		RLCA				;1
		RLCA				;1
		RLCA				;1
		LD	E,A			;1
		LD	A,[DE]			;2   (14 cycles total)

		RRCA				;1   Sum the result.
		RRCA				;1
		RRCA				;1
		LD	B,A			;1
		AND	%11100000		;2
		OR	[HL]			;2
		LD	[HLI],A			;2
		LD	A,B			;1
		AND	%00000011		;2
		OR	[HL]			;2
		LD	[HLI],A			;2   (17 cycles total)

		POP	DE			;3   Restore src pointer.

		RET				;4   (72 cycles total)



; ***************************************************************************
; * GmbXferPalette ()                                                       *
; ***************************************************************************
; * Dump palette data from memory to GMB palette registers                  *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Can only be called during VBLANK.                           *
; *                                                                         *
; *             Takes 22 cycles.                                            *
; ***************************************************************************

GmbXferPalette::LDH	A,[hVblBGP]		;3   Set up colour palettes.
		LDIO	[rBGP],A		;3
		LDH	A,[hVblOBP0]		;3
		LDIO	[rOBP0],A		;3
		LDH	A,[hVblOBP1]		;3
		LDIO	[rOBP1],A		;3

		RET				;4



; ***************************************************************************
; * CgbXferPalette ()                                                       *
; ***************************************************************************
; * Dump palette data from memory to CGB palette registers                  *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Can only be called during VBLANK.                           *
; *                                                                         *
; *             Takes 629 cycles.                                           *
; ***************************************************************************

CgbXferPalette::LD	A,WRKBANK_PAL		;2   Page in the palettes.
		LDIO	[rSVBK],A		;3

		LD	HL,wBcpShadow		;3   Dump complete CGB BCP.
		LD	BC,$0800		;3
		CALL	DumpCgbBcp		;302

		LD	HL,wOcpShadow		;3   Dump complete CGB OCP.
		LD	BC,$0800		;3
		CALL	DumpCgbOcp		;302

		RET				;4



; ***************************************************************************
; * DumpCgbOcp ()                                                           *
; * DumpCgbBcp ()                                                           *
; ***************************************************************************
; * Dump palette data from memory to CGB palette registers                  *
; ***************************************************************************
; * Inputs      HL = source address                                         *
; *             B  = number of complete palettes to copy                    *
; *             C  = palette select                                         *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Can only be called during VBLANK.                           *
; *                                                                         *
; *             Takes 302 cycles for a set of 8 palettes.                   *
; ***************************************************************************

DumpCgbOcp::	LD	A,C			;1
		OR	$80			;2
		LDIO	[rOCPS],A		;3
		LD	C,255&(rOCPD)		;2
		JR	DumpCgbPal		;3

DumpCgbBcp::	LD	A,C			;1
		OR	$80			;2
		LDIO	[rBCPS],A		;3
		LD	C,255&(rBCPD)		;2
		JR	DumpCgbPal		;3

DumpCgbPal::	LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		LD	A,[HLI]			;2
		LD	[C],A			;2
		DEC	B			;1
		JR	NZ,DumpCgbPal		;3/2 (36 cycles total)
		RET				;4



; ***************************************************************************
; * ReadCgbOcp ()                                                           *
; * ReadCgbBcp ()                                                           *
; ***************************************************************************
; * Read palette data from CGB palette registers to memory                  *
; ***************************************************************************
; * Inputs      DE = destination address (must not cross a page boundary)   *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Can only be called during VBLANK.                           *
; *                                                                         *
; *             Takes 302 cycles for a set of 8 palettes.                   *
; ***************************************************************************

ReadCgbOcp::	LD	HL,rOCPS		;3
		JR	ReadCgbPal		;3

ReadCgbBcp::	LD	HL,rBCPS		;3
		JR	ReadCgbPal		;3

ReadCgbPal::	LD	C,64			;2
		LD	A,E			;1
		ADD	C			;1
		LD	E,A			;1

.Loop:		DEC	E			;1
		DEC	C			;1
		LD	A,C			;1
		LD	[HLI],A			;2
		LD	A,[HLD]			;2
		LD	[DE],A			;2
		JR	NZ,.Loop		;3/2

		RET				;4



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF FADE.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

