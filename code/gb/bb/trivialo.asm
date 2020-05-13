; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** TRIVIALO.ASM                                                   MODULE **
; **                                                                       **
; ** Trivia Game.                                                          **
; **                                                                       **
; ** Last modified : 21 Apr 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

		IF	VERSION_USA

;		SECTION	"trivialo",HOME
		section 0

;
;
;

TblClockSprRgb::INCBIN	"res/john/trivia/ctimebit.rgb" ;RES/JOHN/TRIVIA/CTIMEBIT.RGB"

;
;
;

; ***************************************************************************
; * TriviaGameLo ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaGameLo::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(TriviaGame)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	TriviaGame		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * TriviaFind ()                                                           *
; ***************************************************************************
; *                                                                         *
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

TriviaFind::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	DE,FontLite		;Initialize font.
		LD	A,E			;
		LD	[wFontLo],A		;
		LD	A,D			;
		LD	[wFontHi],A		;

		LD	HL,IDX_TRIVIATXT	;Locate questions file.
		CALL	FindInFileSys		;

		LD	E,C			;
		LD	D,B			;

.Loop0:		LD	A,D			;Found the correct string ?
		OR	E			;
		JR	Z,.Skip0		;

		CALL	TriviaSkipStr		;Skip the question.
		CALL	TriviaSkipStr		;Skip the 1st answer.
		CALL	TriviaSkipStr		;Skip the 2nd answer.
		CALL	TriviaSkipStr		;Skip the 3rd answer.
		CALL	TriviaSkipStr		;Skip the 4th answer.
		INC	HL			;Skip the correct number.
		INC	HL			;Skip the EOL.

		DEC	DE			;Loop around for the next
		JR	.Loop0			;string.

.Skip0:		LD	DE,wTriviaStrA1		;Copy question to temporary
		CALL	TriviaCopyStr		;workspace.

		PUSH	HL			;Preserve ptr to 1st answer.

		LD	HL,wTriviaStrA1		;Chop the string up into
		LD	DE,wTriviaStrQ1		;a number of lines.
		LD	BC,106			;
		CALL	TriviaChopStr		;
		LD	DE,wTriviaStrQ2		;
		LD	BC,116			;
		CALL	TriviaChopStr		;
		LD	DE,wTriviaStrQ3		;
		LD	BC,110			;
		CALL	TriviaChopStr		;
		LD	DE,wTriviaStrQ4		;
		LD	BC,106			;
		CALL	TriviaChopStr		;
		LDH	A,[hTriviaBad]		;
		OR	[HL]			;
		LDH	[hTriviaBad],A		;

		LD	A,BANK(TblTriviaFlip4)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	random			;
;		LD	C,6			;
		LD	C,24			;
		CALL	MultiplyBBW		;
		LD	L,H			;
		LD	H,0			;
		ADD	HL,HL			;
		LD	BC,TblTriviaFlip4	;
		ADD	HL,BC			;
		LD	C,[HL]			;
		INC	HL			;
		LD	B,[HL]			;

		POP	HL			;Restore ptr to 1st answer.

		CALL	TriviaChopAns		;
		CALL	TriviaChopAns		;
		CALL	TriviaChopAns		;
		CALL	TriviaChopAns		;

		LD	A,[wFileBank]		;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[HLI]			;
		SUB	$31			;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,BC			;

		LD	A,BANK(TblTriviaFlip4)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[HL]			;
		DEC	A			;
		LDH	[hTriviaAnswer],A	;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.

;
;
;

TriviaChopAns::	LD	A,[wFileBank]		;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	DE,wTriviaString	;
		CALL	TriviaCopyStr		;
		PUSH	HL			;
		LD	A,BANK(TblTriviaFlip4)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	HL,wTriviaString	;
		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	D,A			;
		PUSH	BC			;
		LD	BC,112			;
		CALL	TriviaChopStr		;
		LDH	A,[hTriviaBad]		;
		OR	[HL]			;
		LDH	[hTriviaBad],A		;
		POP	BC			;
		POP	HL			;
		RET				;

;
;
;

TriviaSkipStr::	LD	C,$09			;
.Loop0:		LD	A,[HLI]			;
		SUB	C			;
		JR	NZ,.Loop0		;
		RET				;

;
;
;

TriviaCopyStr::	PUSH	BC			;
		LD	C,$09			;
.Loop0:		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	DE			;
		SUB	C			;
		JR	NZ,.Loop0		;
		DEC	DE			;
		LD	[DE],A			;
		INC	DE			;
		POP	BC			;
		RET				;

;
;
;

TriviaChopStr::	LD	A,E			;
		LDH	[hTmp2Lo],A		;
		LD	A,D			;
		LDH	[hTmp2Hi],A		;
		LD	A,C			;
		LDH	[hTmp3Lo],A		;

		XOR	A			;Handle an empty string.
		LD	[DE],A			;
		OR	A,[HL]			;
		RET	Z			;

.Loop0:		LD	A,[HLI]			;Skip leading spaces.
		CP	$20			;
		JR	Z,.Loop0		;
		DEC	HL			;

.Loop1:		PUSH	HL			;
		PUSH	DE			;

.Loop2:		LD	A,[HLI]			;Copy string up until the
		CP	$20			;next blank character.
		JR	Z,.Skip2		;
		CP	$00			;
		JR	Z,.Skip2		;
		LD	[DE],A			;
		INC	DE			;
		JR	.Loop2			;

.Skip2:		DEC	HL			;
		XOR	A			;
		LD	[DE],A			;

		PUSH	HL			;
		PUSH	DE			;

		LDH	A,[hTmp2Lo]		;Find out the width of the
		LD	L,A			;string.
		LDH	A,[hTmp2Hi]		;
		LD	H,A			;
		CALL	CalcString		;

		POP	DE			;
		POP	HL			;

		LD	A,[wStringW]		;
		LD	C,A			;
		LDH	A,[hTmp3Lo]		;
		CP	C			;
		JR	C,.DoneMax		;

		ADD	SP,4			;

.Loop3:		LD	A,[HLI]			;Skip trailing spaces.
		CP	$20			;
		JR	Z,.Loop3		;
		DEC	HL			;
		OR	A			;
		JR	Z,.DoneEnd		;

		PUSH	HL			;
		PUSH	DE			;

		LD	A,$20			;
		LD	[DE],A			;
		INC	DE			;

		JR	.Loop2			;

.DoneEnd:	XOR	A			;
		LD	[DE],A			;
		INC	DE			;
		RET				;

.DoneMax:	POP	DE			;
		POP	HL			;
		XOR	A			;
		LD	[DE],A			;
		INC	DE			;
		RET				;



; ***************************************************************************
; * DrawTriviaSpr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawTriviaSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LDH	A,[hTriviaTimerHi]	;
		OR	A			;
		JR	Z,.Skip1		;

		LD	SP,wSprite0		;Draw regular sprites.

		LDHL	SP,SPR_FLAGS		;Enable sprite drawing.
		LD	[HL],MSK_DRAW+MSK_PLOT	;

		LDHL	SP,SPR_SCR_X		;
		LD	[HL],12			;
		INC	L			;
		LD	[HL],0			;
		LDHL	SP,SPR_SCR_Y		;
		LD	[HL],108		;
		INC	L			;
		LD	[HL],0			;

.Loop0:		LDH	[hTriviaTmp],A		;Preserve counter.

		LDHL	SP,SPR_COLR		;
		LD	[HL],$02		;
		CP	4			;
		JR	C,.Skip0		;
		LD	[HL],$03		;
		CP	7			;
		JR	C,.Skip0		;
		LD	[HL],$04		;

.Skip0:		CALL	SprDraw			;Draw the sprite.

		LDHL	SP,SPR_SCR_X		;
		LD	A,[HL]			;
		ADD	13			;
		LD	[HL],A			;

		LDH	A,[hTriviaTmp]		;Restore counter.
		DEC	A			;
		JR	NZ,.Loop0		;

		LDHL	SP,SPR_FLAGS		;Disable further drawing.
		LD	[HL],MSK_DRAW		;

.Skip1:		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * DoTimeBit ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

DoTimeBit::	LD	DE,IDX_CTIMEBIT		;

		LDHL	SP,SPR_FRAME+2		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_DRAW		;

		RET				;

DoAnsRight::	LD	DE,IDX_CRIGHT		;
		LD	A,$00			;

		JR	DoAnsBoth		;

DoAnsWrong::	LD	DE,IDX_CWRONG		;
		LD	A,$01			;

DoAnsBoth::	LDHL	SP,SPR_COLR+2		;
		LD	[HL],A			;

		LDHL	SP,SPR_FRAME+2		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_SCR_Y+2		;
		LDH	A,[hTriviaCursor]	;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		ADD	A,[HL]			;
		LD	[HL],A			;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_DRAW+MSK_PLOT	;

		RET				;

;
;
;

		ENDC

;
;
;

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF TRIVIALO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

