; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** FONTHI.ASM                                                     MODULE **
; **                                                                       **
; ** Bitmapped Font Functions.                                             **
; **                                                                       **
; ** Last modified : 23 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

;		SECTION	"fonthi",CODE,BANK[10]
;		SECTION	"fonthi",HOME
		section 0


MAX_GLYPH_HGT	EQU	18

;
;
;

TblOffset0060::	DW	$0060*0
		DW	$0060*1
		DW	$0060*2
		DW	$0060*3
		DW	$0060*4
		DW	$0060*5
		DW	$0060*6
		DW	$0060*7
		DW	$0060*8
		DW	$0060*9
		DW	$0060*10
		DW	$0060*11
		DW	$0060*12
		DW	$0060*13
		DW	$0060*14
		DW	$0060*15
		DW	$0060*16
		DW	$0060*17
		DW	$0060*18
		DW	$0060*19
		DW	$0060*20

;
;
;



; ***************************************************************************
; * SlowStringHi ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SlowStrFail::	JR	SlowStrFail		;

SlowStringHi::	PUSH	HL			;Ensure that the sprite
		CALL	WaitForVBL		;stuff gets called at
		CALL	ReadJoypad		;least once.
		CALL	ProcIntroSpr		;
		CALL	WaitForVBL		;
		POP	HL			;

SlowStringLoop::LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	A,[HLI]			;Read the next chr from the
		OR	A			;string.
		RET	Z			;

		CP	ICON_AGAIN		;Translate the 'Roll Again'
		JR	NZ,.Wibble		;icon.
		LD	A,[wLanguage]		;
		ADD	ICON_AGAIN		;

.Wibble:	PUSH	HL			;Preserve str pointer.

		LDH	[hTmp2Lo],A		;Create a single character
		XOR	A			;temporary string.
		LDH	[hTmp2Hi],A		;

		LD	HL,hTmp2Lo		;Calc the string bounding
		CALL	CalcStringHi		;box.

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
		LD	HL,wBoxX		;
		LD	A,B			;
		LD	[HLI],A			;wBoxX
		LD	A,C			;
		LD	[HLI],A			;wBoxY
		LD	A,D			;
		LD	[HLI],A			;wBoxW
		LD	A,E			;
		LD	[HLI],A			;wBoxH

		LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LDH	A,[hTmp2Lo]		;Get character to draw.

		LD	HL,FHDR_CHR0		;Subtract number of first
		ADD	HL,DE			;glyph stored.
		SUB	[HL]			;
		JR	C,SlowStrFail		;

		LD	HL,FHDR_CHRN		;Compare with total number
		ADD	HL,DE			;of glyphs stored.
		CP	[HL]			;
		JR	NC,SlowStrFail		;

		PUSH	AF			;Preserve last chr drawn.

		ADD	3			;Locate last byte of this
		LD	L,A			;glyph's index data.
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		DEC	HL			;

		LD	DE,TblFontColNrm	;Select lo/hi or hi/lo
		LDH	A,[hMachine]		;(flipped) output.
		CP	MACHINE_CGB		;
		LD	A,[wFontPal]		;
		JR	NZ,.Skip0		;
		RRCA				;
.Skip0:		RRCA				;
		JR	NC,.Skip1		;
		LD	DE,TblFontColFlp	;

.Skip1:		LD	A,[HLD]			;Read FIDX_H.
		CP	MAX_GLYPH_HGT+1		;
		JP	NC,SlowStrFail		;
		ADD	A			;
		ADD	E			;
		LD	E,A			;
		JR	NC,.Skip2		;
		INC	D			;
.Skip2:		LD	A,[DE]			;
		LD	[wJmpTemporary+1],A	;
		INC	DE			;
		LD	A,[DE]			;
		LD	[wJmpTemporary+2],A	;

		LD	A,[HLD]			;Read FIDX_W.
		ADD	$07			;
		AND	$F8			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hSprCnt],A		;

		LD	A,[wStringX]		;
		LD	D,A			;
		LD	A,[wStringY]		;
		LD	E,A			;

		LD	A,[HLD]			;Read FIDX_Y.
		ADD	E			;
		LDH	[hSprYLo],A		;

		LD	A,[HLD]			;Read FIDX_X.
		ADD	D			;
		LDH	[hSprXLo],A		;

		LD	A,[HLD]			;Read FIDX_DX.
		ADD	D			;
		LD	[wStringX],A		;

		DEC	HL			;Skip FIDX_PAD.

		LD	A,[HLD]			;Read FIDX_P and calculate
		LD	D,A			;the address of the font
		LD	E,[HL]			;data.
		ADD	HL,DE			;

		CALL	DrawFnt0120		;Draw this character.

		POP	BC			;Restore last chr drawn.

		POP	HL			;Read the next chr in
		LD	C,[HL]			;the string.
		PUSH	HL			;

		LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	HL,FHDR_KRNP		;Locate the kerning table
		ADD	HL,DE			;(if there is one).
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		OR	H			;
		JR	Z,.KernDone		;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		LD	L,B			;Locate the kerning info
		LD	H,0			;for the last chr drawn
		ADD	HL,DE			;(if there is any).
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.KernDone		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,DE			;

.KernLoop:	LD	A,[HLI]			;Search the kern list for
		OR	A			;the next chr to draw.
		JR	Z,.KernDone		;
		CP	C			;
		LD	A,[HLI]			;
		JR	NZ,.KernLoop		;

		LD	HL,wStringX		;Modify the X coordinate
		ADD	[HL]			;by the kerning delta.
		LD	[HL],A			;

.KernDone:	LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,.Skip3		;

		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JR	NZ,.Abort		;

.Skip3:		LD	A,[wJoy1Cur]		;
		AND	MSK_JOY_A|MSK_JOY_B|MSK_JOY_START|MSK_JOY_SELECT
		JR	NZ,.Skip4		;

		CALL	WaitForVBL		;
		CALL	ReadJoypad		;
		CALL	ProcIntroSpr		;
		CALL	WaitForVBL		;

.Skip4:		LD	HL,wBoxX		;
		LD	A,[HLI]			;wBoxX
		LD	B,A			;
		LD	A,[HLI]			;wBoxY
		LD	C,A			;
		LD	A,[HLI]			;wBoxW
		LD	D,A			;
		LD	A,[HLI]			;wBoxH
		LD	E,A			;

		LD	A,B			;Don't do it if there will
		CP	20			;be an overflow.
		JR	NC,.Skip5		;
		ADD	D			;
		CP	20+1			;
		JR	NC,.Skip5		;

		CALL	DmaBitbox20x18		;

.Skip5:		POP	HL			;Restore str pointer.

		JP	SlowStringLoop		;Next character.

.Abort:		POP	HL			;Abort slow print.
		RET				;



; ***************************************************************************
; * DrawStringHi ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to string (must be $0000-$3FFF or in RAM)          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawStrFail::	JR	DrawStrFail		;

DrawStringHi::	LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	A,[HLI]			;Read the next chr from the
		OR	A			;string.
		RET	Z			;

		CP	ICON_AGAIN		;Translate the 'Roll Again'
		JR	NZ,.Wibble		;icon.
		LD	A,[wLanguage]		;
		ADD	ICON_AGAIN		;

.Wibble:	PUSH	HL			;Preserve str pointer.

		LD	HL,FHDR_CHR0		;Subtract number of first
		ADD	HL,DE			;glyph stored.
		SUB	[HL]			;
		JR	C,DrawStrFail		;

		LD	HL,FHDR_CHRN		;Compare with total number
		ADD	HL,DE			;of glyphs stored.
		CP	[HL]			;
		JR	NC,DrawStrFail		;

		PUSH	AF			;Preserve last chr drawn.

		ADD	3			;Locate last byte of this
		LD	L,A			;glyph's index data.
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		DEC	HL			;

		LD	DE,TblFontColNrm	;Select lo/hi or hi/lo
		LDH	A,[hMachine]		;(flipped) output.
		CP	MACHINE_CGB		;
		LD	A,[wFontPal]		;
		JR	NZ,.Skip0		;
		RRCA				;
.Skip0:		RRCA				;
		JR	NC,.Skip1		;
		LD	DE,TblFontColFlp	;

.Skip1:		LD	A,[HLD]			;Read FIDX_H.
		CP	MAX_GLYPH_HGT+1		;
		JR	NC,DrawStrFail		;
		ADD	A			;
		ADD	E			;
		LD	E,A			;
		JR	NC,.Skip2		;
		INC	D			;
.Skip2:		LD	A,[DE]			;
		LD	[wJmpTemporary+1],A	;
		INC	DE			;
		LD	A,[DE]			;
		LD	[wJmpTemporary+2],A	;

		LD	A,[HLD]			;Read FIDX_W.
		ADD	$07			;
		AND	$F8			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hSprCnt],A		;

		LD	A,[wStringX]		;
		LD	D,A			;
		LD	A,[wStringY]		;
		LD	E,A			;

		LD	A,[HLD]			;Read FIDX_Y.
		ADD	E			;
		LDH	[hSprYLo],A		;

		LD	A,[HLD]			;Read FIDX_X.
		ADD	D			;
		LDH	[hSprXLo],A		;

		LD	A,[HLD]			;Read FIDX_DX.
		ADD	D			;
		LD	[wStringX],A		;

		DEC	HL			;Skip FIDX_PAD.

		LD	A,[HLD]			;Read FIDX_P and calculate
		LD	D,A			;the address of the font
		LD	E,[HL]			;data.
		ADD	HL,DE			;

		CALL	DrawFnt0120		;Draw this character.

		POP	BC			;Restore last chr drawn.

		POP	HL			;Read the next chr in
		LD	C,[HL]			;the string.
		PUSH	HL			;Preserve str pointer.

		LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	HL,FHDR_KRNP		;Locate the kerning table
		ADD	HL,DE			;(if there is one).
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		OR	H			;
		JR	Z,.KernDone		;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		LD	L,B			;Locate the kerning info
		LD	H,0			;for the last chr drawn
		ADD	HL,DE			;(if there is any).
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.KernDone		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,DE			;

.KernLoop:	LD	A,[HLI]			;Search the kern list for
		OR	A			;the next chr to draw.
		JR	Z,.KernDone		;
		CP	C			;
		LD	A,[HLI]			;
		JR	NZ,.KernLoop		;

		LD	HL,wStringX		;Modify the X coordinate
		ADD	[HL]			;by the kerning delta.
		LD	[HL],A			;

.KernDone:	POP	HL			;Restore str pointer.

		JP	DrawStringHi		;Next character.



; ***************************************************************************
; * CalcStringHi ()                                                         *
; ***************************************************************************
; *                                                                         *
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
; ***************************************************************************

CalcStrFail::	JR	CalcStrFail		;

CalcStringHi::	XOR	A			;
		LDH	[hTmpLo],A		;
		LDH	[hTmpHi],A		;

CalcStringLoop::LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	A,[HLI]			;Read the next chr from the
		OR	A			;string.
		JR	Z,CalcStringDone	;

		CP	ICON_AGAIN		;Translate the 'Roll Again'
		JR	NZ,.Wibble		;icon.
		LD	A,[wLanguage]		;
		ADD	ICON_AGAIN		;

.Wibble:	PUSH	HL			;Preserve str pointer.

		LD	HL,FHDR_CHR0		;Subtract number of first
		ADD	HL,DE			;glyph stored.
		SUB	[HL]			;
		JR	C,CalcStrFail		;

		LD	HL,FHDR_CHRN		;Compare with total number
		ADD	HL,DE			;of glyphs stored.
		CP	[HL]			;
		JR	NC,CalcStrFail		;

		PUSH	AF			;Preserve last chr drawn.

		ADD	3			;Locate last byte of this
		LD	L,A			;glyph's index data.
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		DEC	HL			;

		DEC	HL			;Skip FIDX_H.

		LD	A,[HLD]			;Read FIDX_W.
		LD	E,A			;

		DEC	HL			;Skip FIDX_Y.

		LD	A,[HLD]			;Read FIDX_X and calc
		ADD	E			;actual end offset of
		SUB	[HL]			;the glyph graphic.
		LDH	[hTmpHi],A		;

		LDH	A,[hTmpLo]		;Read FIDX_DX.
		ADD	[HL]			;
		JR	NC,.Skip0		;
		LD	A,255			;
.Skip0:		LDH	[hTmpLo],A		;

		POP	BC			;Restore last chr drawn.

		POP	HL			;Read the next chr in
		LD	C,[HL]			;the string.
		PUSH	HL			;Preserve str pointer.

		LD	A,[wFontLo]		;Locate the font to use.
		LD	E,A			;
		LD	A,[wFontHi]		;
		LD	D,A			;

		LD	HL,FHDR_KRNP		;Locate the kerning table
		ADD	HL,DE			;(if there is one).
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		OR	H			;
		JR	Z,.KernDone		;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		LD	L,B			;Locate the kerning info
		LD	H,0			;for the last chr drawn
		ADD	HL,DE			;(if there is any).
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.KernDone		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,DE			;

.KernLoop:	LD	A,[HLI]			;Search the kern list for
		OR	A			;the next chr to draw.
		JR	Z,.KernDone		;
		CP	C			;
		LD	A,[HLI]			;
		JR	NZ,.KernLoop		;

		LD	HL,hTmpLo		;Modify the X coordinate
		ADD	[HL]			;by the kerning delta.
		LD	[HL],A			;

.KernDone:	POP	HL			;Restore str pointer.

		JP	CalcStringLoop		;Next character.

CalcStringDone::LDH	A,[hTmpHi]		;Compensate for difference
		LD	C,A			;between DX value and the
		LDH	A,[hTmpLo]		;actual drawn width of the
		ADD	C			;final character.
		LD	[wStringW],A		;

		PUSH	HL			;Preserve str pointer.

		LD	HL,FHDR_YBTM		;Calc hSprYLo = box height.
		ADD	HL,DE			;
		LD	A,[HL]			;
		LD	HL,FHDR_YTOP		;
		ADD	HL,DE			;
		ADD	A,[HL]			;
		LD	[wStringH],A		;
		LD	A,[HL]			;Calc hSprYHi = box Y offset.
		CPL				;
		ADD	2			;
		LD	[wStringT],A		;

		POP	HL			;Restore str pointer.

		RET				;All Done.



; ***************************************************************************
; * DrawFnt0120 ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to chr data                                      *
; *                                                                         *
; *             also ...                                                    *
; *                                                                         *
; *             hSprXLo       = X coordinate                                *
; *             hSprYLo       = Y coordinate                                *
; *             hSprCnt       = # of 8-pixel wide strips                    *
; *             wJmpTemporary = ptr to function to dump a column            *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawFnt0120::	IF	1			;Test for X overflow.
		LDH	A,[hSprXLo]		;
		CP	160			;
		RET	NC			;
		SRL	A			;
		SRL	A			;
		SRL	A			;
		LD	E,A			;
		LDH	A,[hSprCnt]		;
		ADD	E			;
		CP	21			;
		RET	NC			;
		ENDC				;

		LD	A,[wFontFlg]		;Dave's credits ?
		BIT	0,A			;
		JR	NZ,DrawFnt0060		;

		LD	C,L			;Copy src data ptr to BC.
		LD	B,H			;

		LD	HL,TblOffset0120	;Calc X chr offset.
		LDH	A,[hSprXLo]		;
		CP	160			;
		JR	NC,.Error		;
		AND	$F8			;
		RRCA				;
		RRCA				;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

		LDH	A,[hSprYLo]		;Calc Y pxl offset.
		CP	144			;
		JR	NC,.Error		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;

		ADD	HL,DE			;Sum offsets.

		LD	DE,$C800		;Finally, add on the starting
		ADD	HL,DE			;address of the shadow.

		LDH	A,[hSprXLo]		;Caluclate which rotation
		AND	7			;tables to use.
		ADD	A			;
		ADD	HIGH(TblRotations)	;
		LD	D,A			;

.Loop0:		PUSH	BC			;Preserve src ptr.

		PUSH	HL			;Preserve dst ptr.

		CALL	wJmpTemporary		;Write a column of data.

		POP	HL			;Restore dst ptr.

		LD	BC,$0120		;Goto next dst column.
		ADD	HL,BC			;

		POP	BC			;Restore src ptr.

		PUSH	HL			;Preserve dst ptr.

		INC	D			;Switch rotation page.

		CALL	wJmpTemporary		;Write a column of data.

		DEC	D			;Switch rotation page.

		POP	HL			;Restore dst ptr.

		LDH	A,[hSprCnt]		;Do another column ?
		DEC	A			;
		LDH	[hSprCnt],A		;
		JR	NZ,.Loop0		;

		RET				;All Done.

.Error:		JR	.Error			;



; ***************************************************************************
; * DrawFnt0060 ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to chr data                                      *
; *                                                                         *
; *             also ...                                                    *
; *                                                                         *
; *             hSprXLo       = X coordinate                                *
; *             hSprYLo       = Y coordinate                                *
; *             hSprCnt       = # of 8-pixel wide strips                    *
; *             wJmpTemporary = ptr to function to dump a column            *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawFnt0060::	LD	C,L			;Copy src data ptr to BC.
		LD	B,H			;

		LD	HL,TblOffset0060	;Calc X chr offset.
		LDH	A,[hSprXLo]		;
		CP	160			;
		JR	NC,.Error		;
		AND	$F8			;
		RRCA				;
		RRCA				;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

		LDH	A,[hSprYLo]		;Calc Y pxl offset.
		CP	48			;
		JR	NC,.Error		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;

		ADD	HL,DE			;Sum offsets.

		LD	DE,$C800		;Finally, add on the starting
		ADD	HL,DE			;address of the shadow.

		LDH	A,[hSprXLo]		;Caluclate which rotation
		AND	7			;tables to use.
		ADD	A			;
		ADD	HIGH(TblRotations)	;
		LD	D,A			;

.Loop0:		PUSH	BC			;Preserve src ptr.

		PUSH	HL			;Preserve dst ptr.

		CALL	wJmpTemporary		;Write a column of data.

		POP	HL			;Restore dst ptr.

		LD	BC,$0060		;Goto next dst column.
		ADD	HL,BC			;

		POP	BC			;Restore src ptr.

		PUSH	HL			;Preserve dst ptr.

		INC	D			;Switch rotation page.

		CALL	wJmpTemporary		;Write a column of data.

		DEC	D			;Switch rotation page.

		POP	HL			;Restore dst ptr.

		LDH	A,[hSprCnt]		;Do another column ?
		DEC	A			;
		LDH	[hSprCnt],A		;
		JR	NZ,.Loop0		;

		RET				;All Done.

.Error:		JR	.Error			;



; ***************************************************************************
; * CodeFntColNrm ()                                                        *
; ***************************************************************************
; * Write a column to the shadow bitmap                                     *
; ***************************************************************************
; * Inputs      BC   = Ptr to src data                                      *
; *             HL   = Ptr to dst data                                      *
; *             D    = Ptr to rotation table                                *
; *                                                                         *
; * Outputs     BC   = Ptr to src data (updated)                            *
; *             HL   = Ptr to dst data (updated)                            *
; *                                                                         *
; * Preserved   D                                                           *
; ***************************************************************************

CodeFntColNrm::	REPT	18			;12 bytes per repeat.

		LD	A,[BC]			;Write lo-byte.
		INC	BC			;
		LD	E,A			;
		LD	A,[DE]			;
		OR	[HL]			;
		LD	[HLI],A			;
		LD	A,[BC]			;Write hi-byte.
		INC	BC			;
		LD	E,A			;
		LD	A,[DE]			;
		OR	[HL]			;
		LD	[HLI],A			;

		ENDR				;

		RET				;All Done.

;
;
;

TblFontColNrm::	DW	CodeFntColNrm+12*18	;Write $00 lines.
		DW	CodeFntColNrm+12*17	;Write $01 lines.
		DW	CodeFntColNrm+12*16	;Write $02 lines.
		DW	CodeFntColNrm+12*15	;Write $03 lines.
		DW	CodeFntColNrm+12*14	;Write $04 lines.
		DW	CodeFntColNrm+12*13	;Write $05 lines.
		DW	CodeFntColNrm+12*12	;Write $06 lines.
		DW	CodeFntColNrm+12*11	;Write $07 lines.
		DW	CodeFntColNrm+12*10	;Write $08 lines.
		DW	CodeFntColNrm+12*9	;Write $09 lines.
		DW	CodeFntColNrm+12*8	;Write $0A lines.
		DW	CodeFntColNrm+12*7	;Write $0B lines.
		DW	CodeFntColNrm+12*6	;Write $0C lines.
		DW	CodeFntColNrm+12*5	;Write $0D lines.
		DW	CodeFntColNrm+12*4	;Write $0E lines.
		DW	CodeFntColNrm+12*3	;Write $0F lines.
		DW	CodeFntColNrm+12*2	;Write $10 lines.
		DW	CodeFntColNrm+12*1	;Write $11 lines.
		DW	CodeFntColNrm+12*0	;Write $12 lines.



; ***************************************************************************
; * CodeFntColFlp ()                                                        *
; ***************************************************************************
; * Write a column to the shadow bitmap (flipping lo and hi bytes)          *
; ***************************************************************************
; * Inputs      BC   = Ptr to src data                                      *
; *             HL   = Ptr to dst data                                      *
; *             D    = Ptr to rotation table                                *
; *                                                                         *
; * Outputs     BC   = Ptr to src data (updated)                            *
; *             HL   = Ptr to dst data (updated)                            *
; *                                                                         *
; * Preserved   D                                                           *
; ***************************************************************************

CodeFntColFlp::	REPT	18			;14 bytes per repeat.

		LD	A,[BC]			;Write lo-byte as hi-byte.
		INC	BC			;
		LD	E,A			;
		LD	A,[DE]			;
		INC	L			;
		OR	[HL]			;
		LD	[HLD],A			;
		LD	A,[BC]			;Write hi-byte as lo-byte.
		INC	BC			;
		LD	E,A			;
		LD	A,[DE]			;
		OR	[HL]			;
		LD	[HLI],A			;
		INC	HL			;

		ENDR				;

		RET				;All Done.

;
;
;

TblFontColFlp::	DW	CodeFntColFlp+14*18	;Write $00 lines.
		DW	CodeFntColFlp+14*17	;Write $01 lines.
		DW	CodeFntColFlp+14*16	;Write $02 lines.
		DW	CodeFntColFlp+14*15	;Write $03 lines.
		DW	CodeFntColFlp+14*14	;Write $04 lines.
		DW	CodeFntColFlp+14*13	;Write $05 lines.
		DW	CodeFntColFlp+14*12	;Write $06 lines.
		DW	CodeFntColFlp+14*11	;Write $07 lines.
		DW	CodeFntColFlp+14*10	;Write $08 lines.
		DW	CodeFntColFlp+14*9	;Write $09 lines.
		DW	CodeFntColFlp+14*8	;Write $0A lines.
		DW	CodeFntColFlp+14*7	;Write $0B lines.
		DW	CodeFntColFlp+14*6	;Write $0C lines.
		DW	CodeFntColFlp+14*5	;Write $0D lines.
		DW	CodeFntColFlp+14*4	;Write $0E lines.
		DW	CodeFntColFlp+14*3	;Write $0F lines.
		DW	CodeFntColFlp+14*2	;Write $10 lines.
		DW	CodeFntColFlp+14*1	;Write $11 lines.
		DW	CodeFntColFlp+14*0	;Write $12 lines.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF FONTHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

