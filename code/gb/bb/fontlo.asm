; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** FONTLO.ASM                                                     MODULE **
; **                                                                       **
; ** Bitmapped Font Functions.                                             **
; **                                                                       **
; ** Last modified : 23 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

;		SECTION	"fontlo",HOME
		section 0

;
;
;

; ***************************************************************************
; * SetFontBank ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SetFontBank::	LD	A,[wFontHi]		;
		CP	HIGH(FontOlde)		;
		LD	A,BANK(FontOlde)	;
		JR	Z,.Done			;

		IF	VERSION_JAPAN		;
		LD	A,[wFontHi]		;
		CP	HIGH(FontLite)		;
		LD	A,BANK(FontLite)	;
		JR	Z,.Done			;
		LD	A,[wFontHi]		;
		CP	HIGH(FontDark)		;
		LD	A,BANK(FontDark)	;
		JR	Z,.Done			;
		LD	A,[wFontHi]		;
		CP	HIGH(FontEnd)		;
		LD	A,BANK(FontEnd)		;
		JR	Z,.Done			;
		LD	A,[wFontHi]		;
		CP	HIGH(FontLarge)		;
		LD	A,BANK(FontLarge)	;
		JR	Z,.Done			;
		LD	A,[wFontHi]		;
		CP	HIGH(FontSmall)		;
		LD	A,BANK(FontSmall)	;
		JR	Z,.Done			;
		ENDC				;

		LD	A,BANK(FontLite)	;
.Done:		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		RET				;



; ***************************************************************************
; * SlowStringLstN ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SlowStringLstN::LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	SlowStringXYN		;
		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,SlowStringLstN	;
		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JR	Z,SlowStringLstN	;
		RET				;

SlowStringXYN::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;

		LD	E,[HL]			;
		INC	HL			;
		LD	D,[HL]			;
		INC	HL			;
		PUSH	HL			;
		PUSH	AF			;

		CALL	GetString		;
		LD	HL,wString		;

		POP	AF			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	CALL	SlowStringRgt		;
		POP	HL			;
		RET				;
.CtrJustify:	CALL	SlowStringCtr		;
		POP	HL			;
		RET				;
.LftJustify:	CALL	SlowStringLft		;
		POP	HL			;
		RET				;



; ***************************************************************************
; * SlowStringLstP ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SlowStringLstP::LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	SlowStringXYP		;
		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,SlowStringLstP	;
		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JR	Z,SlowStringLstP	;
		RET				;

SlowStringXYP::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;

		LD	E,[HL]			;
		INC	HL			;
		LD	D,[HL]			;
		INC	HL			;
		PUSH	HL			;

		LD	L,E			;
		LD	H,D			;

		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	CALL	SlowStringRgt		;
		POP	HL			;
		RET				;
.CtrJustify:	CALL	SlowStringCtr		;
		POP	HL			;
		RET				;
.LftJustify:	CALL	SlowStringLft		;
		POP	HL			;
		RET				;



; ***************************************************************************
; * SlowStringLst ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SlowStringLst::	LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	SlowStringXY		;
		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,SlowStringLst		;
		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JR	Z,SlowStringLst		;
		RET				;

SlowStringXY::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	JP	SlowStringRgt		;
.CtrJustify:	JP	SlowStringCtr		;
.LftJustify:	JP	SlowStringLft		;



; ***************************************************************************
; * SlowStringLft ()                                                        *
; ***************************************************************************
; * Slow draw a string left-justified at wStringX                           *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

SlowStringLft::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	SlowString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * SlowStringCtr ()                                                        *
; ***************************************************************************
; * Slow draw a string center-justified at wStringX                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

SlowStringCtr::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

		LD	A,[wStringW]		;Center justify the string.
		SRL	A			;
		LD	C,A			;
		LD	A,[wStringX]		;
		SUB	C			;
		LD	[wStringX],A		;

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	SlowString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * SlowStringRgt ()                                                        *
; ***************************************************************************
; * Slow draw a string right-justified at wStringX                          *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

SlowStringRgt::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

		LD	A,[wStringW]		;Right justify the string.
		LD	C,A			;
		LD	A,[wStringX]		;
		SUB	C			;
		LD	[wStringX],A		;

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	SlowString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * SlowString ()                                                           *
; ***************************************************************************
; * Slow draw a bitmapped string to the bitmap shadow buffer                *
; ***************************************************************************
; * Inputs      HL   = Ptr to string (must be $0000-$3FFF or in RAM)        *
; *                                                                         *
; *             wStringX = X coordinate (updated)                           *
; *             wStringY = Y coordinate (updated)                           *
; *                                                                         *
; *             wFontLo/Hi = Ptr to font                                    *
; *                                                                         *
; * Outputs     HL   = Updated string pointer                               *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

SlowString::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		CALL	SetFontBank		;Page in font data.

		LD	HL,wTmpString		;Draw the string.
		CALL	SlowStringHi		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * DrawStringLstP ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawStringLstN::LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	DrawStringXYN		;
		JR	DrawStringLstN		;

DrawStringXYN::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;

		LD	E,[HL]			;
		INC	HL			;
		LD	D,[HL]			;
		INC	HL			;
		PUSH	HL			;
		PUSH	AF			;

		CALL	GetString		;
		LD	HL,wString		;

		POP	AF			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	CALL	DrawStringRgt		;
		POP	HL			;
		RET				;
.CtrJustify:	CALL	DrawStringCtr		;
		POP	HL			;
		RET				;
.LftJustify:	CALL	DrawStringLft		;
		POP	HL			;
		RET				;



; ***************************************************************************
; * DrawStringLstP ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawStringLstP::LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	DrawStringXYP		;
		JR	DrawStringLstP		;

DrawStringXYP::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;

		LD	E,[HL]			;
		INC	HL			;
		LD	D,[HL]			;
		INC	HL			;
		PUSH	HL			;

		LD	L,E			;
		LD	H,D			;

		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	CALL	DrawStringRgt		;
		POP	HL			;
		RET				;
.CtrJustify:	CALL	DrawStringCtr		;
		POP	HL			;
		RET				;
.LftJustify:	CALL	DrawStringLft		;
		POP	HL			;
		RET				;



; ***************************************************************************
; * DrawStringLst ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string list                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawStringLst::	LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		CALL	DrawStringXY		;
		JR	DrawStringLst		;

DrawStringXY::	LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[wFontPalXor]		;
		XOR	[HL]			;
		INC	HL			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	JP	DrawStringRgt		;
.CtrJustify:	JP	DrawStringCtr		;
.LftJustify:	JP	DrawStringLft		;



; ***************************************************************************
; * DrawStringLft ()                                                        *
; ***************************************************************************
; * Draw a string left-justified at wStringX                                *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

DrawStringLft::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	DrawString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * DrawStringCtr ()                                                        *
; ***************************************************************************
; * Draw a string center-justified at wStringX                              *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

DrawStringCtr::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

		LD	A,[wStringW]		;Center justify the string.
		SRL	A			;
		LD	C,A			;
		LD	A,[wStringX]		;
		SUB	C			;
		LD	[wStringX],A		;

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	DrawString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * DrawStringRgt ()                                                        *
; ***************************************************************************
; * Draw a string right-justified at wStringX                               *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

DrawStringRgt::	LD	DE,wTmpString		;Copy the string to RAM.
		CALL	StrCpy			;

		PUSH	HL			;Preserve end-of-string.

		LD	HL,wTmpString		;Calc the string bounding
		CALL	CalcString		;box.

		LD	A,[wStringW]		;Right justify the string.
		LD	C,A			;
		LD	A,[wStringX]		;
		SUB	C			;
		LD	[wStringX],A		;

;		LDH	A,[hMachine]		;Set CGB shadow attributes.
;		CP	MACHINE_CGB		;
;		CALL	Z,DrawStringAtr		;

		LD	HL,wTmpString		;Draw the string.
		CALL	DrawString		;

		POP	HL			;Restore end-of-string.

		RET				;All Done.



; ***************************************************************************
; * DrawString ()                                                           *
; ***************************************************************************
; * Draw a bitmapped string to the bitmap shadow buffer                     *
; ***************************************************************************
; * Inputs      HL   = Ptr to string (must be $0000-$3FFF or in RAM)        *
; *                                                                         *
; *             wStringX = X coordinate (updated)                           *
; *             wStringY = Y coordinate (updated)                           *
; *                                                                         *
; *             wFontLo/Hi = Ptr to font                                    *
; *                                                                         *
; * Outputs     HL   = Updated string pointer                               *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

DrawString::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		CALL	SetFontBank		;Page in font data.

		LD	HL,wTmpString		;Draw the string.
		CALL	DrawStringHi		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * CalcString ()                                                           *
; ***************************************************************************
; * Calculate the bounding box for a bitmapped string                       *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     wStringW = width                                            *
; *             wStringH = height                                           *
; *             wStringT = Y offset from baseline to top                    *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses hTmpLo and hTmpHi.                                     *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

CalcString::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		CALL	SetFontBank		;Page in font data.

		CALL	CalcStringHi		;Calc the string's size.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * DrawStringAtr ()                                                        *
; ***************************************************************************
; * Draw a bitmapped string to the bitmap shadow buffer                     *
; ***************************************************************************
; * Inputs      HL   = Ptr to string (must be $0000-$3FFF or in RAM)        *
; *                                                                         *
; *             wStringX = X coordinate (updated)                           *
; *             wStringY = Y coordinate (updated)                           *
; *                                                                         *
; *             wFontLo/Hi = Ptr to font                                    *
; *                                                                         *
; * Outputs     HL   = Updated string pointer                               *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Uses wTmpString as temporary string buffer                  *
; ***************************************************************************

DrawStringAtr::	RET

		IF	0

		LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	HL,wStringX		;
		LD	A,[HLI]			;wStringX
		LD	B,A			;
		LD	A,[HLI]			;wStringY
		LD	C,A			;
		LD	A,[HLI]			;wStringW
		LD	D,A			;
		LD	A,[HLI]			;wStringH
		LD	E,A			;
		LD	A,[HLI]			;wStringT
		ADD	C			;
		LD	C,A			;
		CALL	PxlBox2ChrBox		;

		LD	A,BANK(FillShadowAtr)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[wFontPal]		;
		RRCA				;
		RRCA				;
		AND	7			;
		CALL	FillShadowAtr		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.

		ENDC



; ***************************************************************************
; * StrCpy ()                                                               *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to src string                                    *
; *             DE   = Ptr to dst string                                    *
; *                                                                         *
; * Outputs     HL   = Updated                                              *
; *             DE   = Updated                                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

StrCpy::	LD	A,[HLI]
		LD	[DE],A
		INC	DE
		OR	A
		JR	NZ,StrCpy
		RET



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF FONTLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

