; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** TRIVIAHI.ASM                                                   MODULE **
; **                                                                       **
; ** Trivia Game.                                                          **
; **                                                                       **
; ** Last modified : 21 Apr 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"triviahi",CODE,BANK[2]
		section 2

		IF	VERSION_USA

;
;
;

NUM_QUESTIONS	EQU	100

TRIVIA_CHEAT	EQU	0
TRIVIA_SEARCH	EQU	0

DELAY_EXIT	EQU	(255-5)

FLASH_SLOW	EQU	8

TRIVIA_CLK_LO	EQU	30
TRIVIA_CLK_HI	EQU	10

;
;
;

TriviaLvl2Clk::	DB	(2*TRIVIA_CLK_LO)/2
		DB	(2*TRIVIA_CLK_LO)/3
		DB	(1*TRIVIA_CLK_LO)/2
		DB	(1*TRIVIA_CLK_LO)/2

;
;
;

TriviaSlowScrn::DB	ICMD_FONT
		DW	FontLite
		DB	ICMD_NEWPKG
		DW	IDX_BTRIVIAPKG
		DW	IDX_CTRIVIAPKG
		DB	ICMD_FADEUP
		DB	ICMD_END

TriviaFastScrn::DB	ICMD_FONT
		DW	FontLite
		DB	ICMD_NEWPKG
		DW	IDX_BTRIVIAPKG
		DW	IDX_CTRIVIAPKG
		DB	ICMD_END

TriviaFastShow::DB	ICMD_FADEUP
		DB	ICMD_END

;
;
;

TblTriviaStr::	DB	29+(106/2)
		DB	78
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	1
		DW	wTriviaStrQ1

		DB	19+(116/2)
		DB	86
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	1
		DW	wTriviaStrQ2

		DB	10+(108/2)
		DB	94
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	1
		DW	wTriviaStrQ3

		DB	10+(104/2)
		DB	102
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	1
		DW	wTriviaStrQ4

		DB	22
		DB	117
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	wTriviaStrA1

		DB	22
		DB	125
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	wTriviaStrA2

		DB	22
		DB	133
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	wTriviaStrA3

		DB	22
		DB	141
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	wTriviaStrA4

		DB	$02
		DB	$08
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	wTriviaString+0

		DB	$02
		DB	$12
		DB	GMB_PALN+CGB_PALN+CGB_PAL0
		DB	0
		DW	hTriviaNumber+4

;
;
;

TriviaSprTime::	DW	wSprite0
		DB	60,70
		DW	DoTimeBit

TriviaSprRight::DW	wSprite1
		DB	14,115
		DW	DoAnsRight

TriviaSprWrong::DW	wSprite1
		DB	14,115
		DW	DoAnsWrong

;
;
;


; ***************************************************************************
; * TriviaGame ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaGame::	CALL	KillAllSound		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		XOR	A			;
		LD	[wSubStage],A		;

		LD	A,1			;
		LDH	[hTriviaLives],A	;

		XOR	A			;
		LD	[wTriviaSpeed],A	;
		LD	[wTriviaRight],A	;

		IF	TRIVIA_CHEAT		;
		XOR	A			;
		LDH	[hTriviaNumber],A	;
		ELSE				;
		CALL	random			;
		LD	C,NUM_QUESTIONS		;
		CALL	MultiplyBBW		;
		LD	A,H			;
		LDH	[hTriviaNumber],A	;
		ENDC				;

TriviaStage::	CALL	KillAllSound		;

		XOR	A			;
		LDH	[hTriviaOver],A		;
		LDH	[hTriviaCursor],A	;

		LD	HL,TriviaLvl2Clk	;
		LD	A,[wSubLevel]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LDH	[hTriviaTimerLo],A	;

		LD	A,TRIVIA_CLK_HI		;
		LDH	[hTriviaTimerHi],A	;

		LDH	A,[hTriviaNumber]	;
		LD	C,A			;
		XOR	A			;
		LDH	[hTriviaBad],A		;
		LD	B,A			;
		CALL	TriviaFind		;

		IF	TRIVIA_CHEAT		;
		JR	TriviaRestart		;
		ENDC				;

TriviaStart::	CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LD	A,%11010010		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	InitTriviaSpr		;Initialize sprites.
		CALL	ProcTriviaSpr		;

		LD	BC,TriviaSlowScrn	;Display the trivia
		CALL	NextICmd		;background.

		XOR	A			;Disable abort button.
		LDH	[hIntroFlags],A		;

		XOR	A			;Print up the trivia
.Loop0:		PUSH	AF			;question.
		CALL	TriviaFont		;
		CALL	TriviaSlow		;
		POP	AF			;
		INC	A			;
;		CP	7			;
		CP	8			;
		JR	C,.Loop0		;

		LDH	A,[hTriviaCursor]	;
		CALL	ChangeAnswer		;
		CALL	UpdateAnswer		;

		JR	TriviaBoth		;

TriviaRestart::	CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LD	A,%11010010		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	InitTriviaSpr		;Initialize sprites.
		CALL	ProcTriviaSpr		;

		LD	BC,TriviaFastScrn	;Display the trivia
		CALL	NextICmd		;background.

		XOR	A			;Disable abort button.
		LDH	[hIntroFlags],A		;

		IF	TRIVIA_CHEAT		;
		CALL	TriviaNumber		;
		ENDC				;

		XOR	A			;Print up the trivia
.Loop0:		PUSH	AF			;question.
		CALL	TriviaFont		;
		CALL	TriviaDraw		;
		POP	AF			;
		INC	A			;
;		CP	7			;
		CP	8			;
		JR	C,.Loop0		;
		IF	TRIVIA_CHEAT		;
;		CP	9			;
		CP	10			;
		JR	C,.Loop0		;
		ENDC				;

		LDH	A,[hTriviaCursor]	;
		CALL	ChangeAnswer		;

		LD	BC,TriviaFastShow	;Display the trivia
		CALL	NextICmd		;background.

TriviaBoth::	XOR	A			;Clear pause request flag.
		LD	[wWantToPause],A	;

		CALL	WaitForVBL		;Synchronize to the VBL.

		LD	A,$FF			;Clear pending button presses.
		LD	[wJoy1Cur],A		;

TriviaLoop::	LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.

		LDH	A,[hTriviaOver]		;Stage finished ?
		OR	A			;
		JR	Z,TriviaUser		;
		INC	A			;
		JR	Z,TriviaExit		;
		LDH	[hTriviaOver],A		;
		INC	A			;
		JR	NZ,TriviaTick		;

		LDH	A,[hTriviaLives]	;All lives lost ?
		OR	A			;
		JR	Z,TriviaLost		;

TriviaWon::	NOP				;
;		LD	A,[wSubStage]		;
;		CP	3			;
;		JR	Z,.Skip0		;
;		CALL	KillAllSound		;
;		JR	TriviaTick		;
.Skip0:		LD	A,SONG_WON		;
		CALL	InitTune		;
		JR	TriviaTick		;

TriviaLost::	LD	A,SONG_LOST		;
		CALL	InitTune		;
		JR	TriviaTick		;

TriviaExit::	LD	A,[wMzPlaying]		;Wait for exit tune to
		OR	A			;finish.
		JR	NZ,TriviaTick		;

		JP	TriviaNext		;

TriviaUser::	CALL	TriviaMusic		;Ensure that music is playing.

		CALL	TriviaInput		;Get user input.

		CALL	FlashAnswer		;

		LD	A,[wWantToPause]	;Pause ?
		OR	A			;
		JP	NZ,TriviaPause		;

		CALL	TriviaClock		;

TriviaTick::	CALL	UpdateAnswer		;

		CALL	ProcTriviaSpr		;

		CALL	WaitForVBL		;Synchronize to the VBL.
		CALL	WaitForVBL		;Synchronize to the VBL.

		JP	TriviaLoop		;

;
;
;

TriviaNext::	CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;

		JR	TriviaFinished		;

;		LDH	A,[hTriviaLives]	;All lives lost ?
;		OR	A			;
;		JR	Z,TriviaFinished	;
;
;		LD	A,[wSubStage]		;Increment stage.
;		INC	A			;
;		CP	4			;
;		JR	Z,TriviaFinished	;
;		LD	[wSubStage],A		;
;
;		CALL	FadeOutBlack		;Fade out to black.
;
;		CALL	KillAllSound		;
;		CALL	WaitForVBL		;
;
;		JP	TriviaStage		;Do the next stage.

;
;
;

TriviaFinished::CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	SetMachineJcb		;Reset machine to known state.

		LD	HL,TblClk2Award		;Reward based upon speed
		LD	A,[wTriviaSpeed]	;of answer.
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wSubStage],A		;

		RET				;All Done.

TblClk2Award::	DB	0,1,1,1,2,2,2,2,3,3,3	;

;
;
;

TriviaPause::	CALL	FadeOutBlack		;Fade out.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	SetMachineJcb		;Reset machine to known state.

		CALL	PauseMenu_B		;Call the generic pause.

		JP	TriviaRestart		;And then restart this game.

;
;
;

TriviaMusic::	LD	A,[wMzNumber]		;
		CP	A,SONG_TRIVIA		;
		RET	Z			;
		LD	A,SONG_TRIVIA		;
		JP	InitTunePref		;



; ***************************************************************************
; * TriviaClock ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL since it writes to the screen.    *
; ***************************************************************************

TriviaClock::	IF	TRIVIA_CHEAT		;
		RET				;
		ENDC				;

		LD	HL,hTriviaTimerHi	;
		LD	A,[HLD]			;
		OR	A			;
		JR	Z,.Skip1		;

		DEC	[HL]			;
		RET	NZ			;

		LD	BC,TriviaLvl2Clk	;
		LD	A,[wSubLevel]		;
		ADD	C			;
		LD	C,A			;
		JR	NC,.Skip0		;
		INC	B			;
.Skip0:		LD	A,[BC]			;
		LD	[HLI],A			;
		DEC	[HL]			;
		RET				;

.Skip1:		LD	A,DELAY_EXIT		;
		LDH	[hTriviaOver],A		;

		XOR	A			;
		LDH	[hTriviaLives],A	;

		LDH	A,[hTriviaCursor]	;Make sure that the answer
		JP	ChangeAnswer		;is displayed.



; ***************************************************************************
; * TriviaFont ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A  = Number of trivia line to print (0..6)                  *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaFont::	PUSH	AF			;
		LD	A,LOW(FontLite)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontLite)	;
		LD	[wFontHi],A		;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	Z,.Done			;
		POP	AF			;
		CP	4			;
		RET	C			;
		PUSH	AF			;
		LD	A,LOW(FontDark)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontDark)	;
		LD	[wFontHi],A		;
.Done:		POP	AF			;
		RET				;



; ***************************************************************************
; * TriviaDraw ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A  = Number of trivia line to print (0..6)                  *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaDraw::	ADD	A			;
		LD	C,A			;
		LD	B,0			;
		LD	L,B			;
		LD	H,B			;
		ADD	HL,BC			;
		ADD	HL,BC			;
		ADD	HL,BC			;
		LD	BC,TblTriviaStr		;
		ADD	HL,BC			;

		LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[HLI]			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;
		LD	C,A			;

		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		LD	A,C			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	JP	DrawStringRgt		;
.CtrJustify:	JP	DrawStringCtr		;
.LftJustify:	JP	DrawStringLft		;



; ***************************************************************************
; * TriviaSlow ()                                                           *
; ***************************************************************************
; * Display a line                                                          *
; ***************************************************************************
; * Inputs      A  = Number of trivia line to print (0..6)                  *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaSlow::	ADD	A			;
		LD	C,A			;
		LD	B,0			;
		LD	L,B			;
		LD	H,B			;
		ADD	HL,BC			;
		ADD	HL,BC			;
		ADD	HL,BC			;
		LD	BC,TblTriviaStr		;
		ADD	HL,BC			;

		LD	A,[HLI]			;
		LD	[wStringX],A		;
		LD	A,[HLI]			;
		LD	[wStringY],A		;

		LD	A,[HLI]			;
		LD	[wFontPal],A		;

		LD	A,[HLI]			;
		LD	C,A			;

		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		LD	A,C			;
		OR	A			;
		JR	Z,.LftJustify		;
		DEC	A			;
		JR	Z,.CtrJustify		;

.RgtJustify:	JP	SlowStringRgt		;
.CtrJustify:	JP	SlowStringCtr		;
.LftJustify:	JP	SlowStringLft		;



; ***************************************************************************
; * TriviaInput ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaInput::	LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	BIT	JOY_START,C		;
		JR	Z,.TestR		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestR:		BIT	JOY_R,C			;
		JR	Z,.TestL		;

.TestL:		BIT	JOY_L,C			;
		JR	Z,.TestU		;

.TestU:		BIT	JOY_U,C			;
		JR	Z,.TestD		;

		LDH	A,[hTriviaCursor]	;
		SUB	1			;
		JP	NC,ChangeAnswer		;
;		LD	A,2			;
		LD	A,3			;
		JP	ChangeAnswer		;

.TestD:		BIT	JOY_D,C			;
		JR	Z,.TestCheat		;

		LDH	A,[hTriviaCursor]	;
		INC	A			;
;		CP	3			;
		CP	4			;
		JR	NZ,ChangeAnswer		;
		XOR	A			;
		JR	ChangeAnswer		;

.TestCheat:	IF	TRIVIA_CHEAT		;
		BIT	JOY_SELECT,C		;
		JR	Z,.TestShoot		;
		JP	TriviaSearch		;
		ENDC

.TestShoot:	AND	MSK_JOY_A|MSK_JOY_B	;Shoot ?
		RET	Z			;

		LD	C,0			;
.Loop0:		PUSH	BC			;
		LDH	A,[hTriviaCursor]	;
		CP	C			;
		JR	Z,.Skip0		;
		LD	A,C			;
		CALL	ClrAnswer		;
		CALL	CpyAnswer		;

.Skip0:		POP	BC			;
		INC	C			;
;		LD	A,3			;
		LD	A,4			;
		CP	C			;
		JR	NZ,.Loop0		;

		LDH	A,[hTriviaCursor]	;Make sure that the answer
		CALL	ChangeAnswer		;is displayed.

		LD	A,DELAY_EXIT		;
		LDH	[hTriviaOver],A		;

		LDH	A,[hTriviaTimerHi]	;Preserve the speed of the
		LD	[wTriviaSpeed],A	;answer.

		LDH	A,[hTriviaCursor]	;Make sure that the answer
		LD	C,A			;
		LDH	A,[hTriviaAnswer]	;
		CP	C			;
		JR	Z,.RightAnswer		;

.WrongAnswer:	XOR	A			;
		LDH	[hTriviaLives],A	;

		XOR	A			;
		LD	[wSubStage],A		;

		LD	BC,TriviaSprWrong	;
		JP	InitIntroSpr		;

.RightAnswer:	LD	A,[wTriviaRight]	;
		INC	A			;
		LD	[wTriviaRight],A	;

		LD	BC,TriviaSprRight	;
		JP	InitIntroSpr		;

;
;
;

FlashAnswer::	LDH	A,[hTriviaFlashLo]	;
		OR	A			;
		JR	Z,.Skip0		;
		DEC	A			;
		LDH	[hTriviaFlashLo],A	;
		RET				;
.Skip0:		LD	A,1			;
		LDH	[hTriviaChange],A	;
		LD	A,FLASH_SLOW		;
		LDH	[hTriviaFlashLo],A	;
		LDH	A,[hTriviaFlashHi]	;
		INC	A			;
		AND	3			;
		LDH	[hTriviaFlashHi],A	;
		LDH	A,[hTriviaCursor]	;
		JP	Z,DrawAnswerLo		;
		JP	DrawAnswerHi		;

;
;
;

ChangeAnswer::	PUSH	AF			;
		LD	A,1			;
		LDH	[hTriviaChange],A	;
		LD	A,FLASH_SLOW		;
		LDH	[hTriviaFlashLo],A	;
		LD	A,0			;
		LDH	[hTriviaFlashHi],A	;
		LDH	A,[hTriviaCursor]	;
		CALL	DrawAnswerLo		;
		POP	AF			;
		LDH	[hTriviaCursor],A	;
		JP	DrawAnswerHi		;

;
;
;

DrawAnswerLo::	LD	C,A			;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		LD	A,C			;
		JR	Z,CgbAnswerLo		;

GmbAnswerLo::	PUSH	AF			;
		LD	A,LOW(FontDark)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontDark)	;
		LD	[wFontHi],A		;
		POP	AF			;
		CALL	ClrAnswer		;
		PUSH	AF			;
		ADD	4			;
		CALL	TriviaDraw		;
		POP	AF			;
		JP	CpyAnswer		;

CgbAnswerLo::	LD	BC,$010E		;Get base screen position.
		LD	DE,$1001		;
		ADD	C			;
		LD	C,A			;
		LD	A,2			;Write the lolite attribute.
		JP	FillShadowAtr		;

DrawAnswerHi::	LD	C,A			;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		LD	A,C			;
		JR	Z,CgbAnswerHi		;

GmbAnswerHi::	PUSH	AF			;
		LD	A,LOW(FontLite)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontLite)	;
		LD	[wFontHi],A		;
		POP	AF			;
		CALL	ClrAnswer		;
		PUSH	AF			;
		ADD	4			;
		CALL	TriviaDraw		;
		POP	AF			;
		JP	CpyAnswer		;

CgbAnswerHi::	LD	BC,$010E		;Get base screen position.
		LD	DE,$1001		;
		ADD	C			;
		LD	C,A			;
		LD	A,1			;Write the hilite attribute.
		JP	FillShadowAtr		;

;
;
;

UpdateAnswer::	LDH	A,[hTriviaChange]	;
		OR	A			;
		RET	Z			;
		XOR	A			;
		LDH	[hTriviaChange],A	;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	Z,.UpdateCgb		;

.UpdateGmb:	NOP				;

.UpdateCgb:	LD	DE,$9800		;
		JP	DumpShadowAtr		;

;
;
;

ClrAnswer::	PUSH	AF			;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		ADD	112			;
		LDH	[hSprYLo],A		;
		LD	A,8			;
		LDH	[hSprXLo],A		;
		LD	A,128			;
		LD	[wStringW],A		;
		LD	A,8			;
		LD	[wStringH],A		;
		CALL	ClrRect18		;
		POP	AF			;
		RET				;

;
;
;

CpyAnswer::	PUSH	AF			;
		LD	BC,$010E		;
		LD	DE,$1001		;
		ADD	C			;
		LD	C,A			;
		CALL	DmaBitbox20x18		;
		POP	AF			;
		RET				;



; ***************************************************************************
; * InitTriviaSpr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitTriviaSpr::	XOR	A			;Reset all sprites.
		LD	[wSprite0+SPR_FLAGS],A	;
		LD	[wSprite1+SPR_FLAGS],A	;
		LD	[wSprite2+SPR_FLAGS],A	;
		LD	[wSprite3+SPR_FLAGS],A	;
		LD	[wSprite4+SPR_FLAGS],A	;

		LD	BC,TriviaSprTime	;Initialize the sprite.
		CALL	InitIntroSpr		;

		LD	A,LOW(DrawTriviaSpr)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DrawTriviaSpr)	;
		LD	[wJmpDraw+2],A		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		RET	NZ			;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CRIGHT		;
		CALL	AddSpritePal		;
		LD	HL,PAL_CWRONG		;
		CALL	AddSpritePal		;
		LD	HL,TblClockSprRgb	;
		CALL	AddSpritePal		;
		CALL	AddSpritePal		;
		CALL	AddSpritePal		;

		RET				;All Done.



; ***************************************************************************
; * ProcTriviaSpr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcTriviaSpr::	LD	HL,TblClockColr		;
		LDH	A,[hTriviaTimerHi]	;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wSprite0+SPR_COLR],A	;

		CALL	ProcIntroSpr		;Process the sprites.

		RET				;All Done.

TblClockColr::	DB	4,4,4,4,4,3,3,3,2,2,2

		NOP
		NOP



; ***************************************************************************
; * TriviaNumber ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TriviaNumber::	LD	DE,wTriviaString	;
		LDH	A,[hTriviaNumber]	;
		INC	A			;
		CALL	PrintHexByte		;
		XOR	A			;
		LD	[DE],A			;

		LD	A,$00			;
		LDH	[hSprXLo],A		;
		LD	A,$00			;
		LDH	[hSprYLo],A		;
		LD	A,$20			;
		LD	[wStringW],A		;
		LD	A,$18			;
		LD	[wStringH],A		;
		CALL	ClrRect18		;

		LD	HL,TblAtrTrivia		;
		CALL	FillShadowLst		;

		XOR	A			;
		LDH	[hTriviaNumber+4],A	;

		LDH	A,[hTriviaBad]		;
		OR	A			;
		RET	Z			;

		LD	HL,StringBad		;
		LD	DE,hTriviaNumber+4	;
		JP	StrCpy			;

TblAtrTrivia::	DB	$00,$00,$04,$03,0,$FF	;Title

PrintHexByte::	PUSH	AF
		SWAP	A
		CALL	PrintHexNibble
		POP	AF
PrintHexNibble::AND	$0F
		ADD	$30
		CP	$3A
		JR	C,.Skip
		ADD	$41-$3A
.Skip:		LD	[DE],A
		INC	DE
		RET

StringBad::	DB	"BAD",0

;
;
;

TriviaSearch::	LDH	A,[hTriviaNumber]	;
		PUSH	AF			;

.Loop0:		LDH	A,[hTriviaNumber]	;
		INC	A			;
		CP	NUM_QUESTIONS		;
		JR	C,.Skip0		;
		XOR	A			;
.Skip0:		LDH	[hTriviaNumber],A	;

		IF	TRIVIA_SEARCH

		LDHL	SP,0			;
		CP	[HL]			;
		JR	Z,.None			;

		LDH	A,[hTriviaNumber]	;
		LD	C,A			;
		XOR	A			;
		LDH	[hTriviaBad],A		;
		LD	B,A			;
		CALL	TriviaFind		;

		LDH	A,[hTriviaBad]		;
		OR	A			;
		JR	Z,.Loop0		;

		ENDC

		ADD	SP,4			;

		CALL	FadeOutBlack		;

		JP	TriviaStage		;

.None:		POP	AF			;
		RET				;



; ***************************************************************************
; * TblTriviaFlip3 ()                                                       *
; * TblTriviaFlip4 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

;
;
;

		IF	0

TblTriviaFlip3::DW	.Flip0			;
		DW	.Flip1			;
		DW	.Flip2			;
		DW	.Flip3			;
		DW	.Flip4			;
		DW	.Flip5			;

.Flip0:		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DB	1,2,3,0			;

.Flip1:		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DB	1,3,2,0			;

.Flip2:		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DB	2,1,3,0			;

.Flip3:		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DB	2,3,1,0			;

.Flip4:		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DB	3,1,2,0			;

.Flip5:		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DB	3,2,1,0			;

		ENDC

;
;
;

TblTriviaFlip4::DW	.Flip10			;
		DW	.Flip11			;
		DW	.Flip12			;
		DW	.Flip13			;
		DW	.Flip14			;
		DW	.Flip15			;
		DW	.Flip20			;
		DW	.Flip21			;
		DW	.Flip22			;
		DW	.Flip23			;
		DW	.Flip24			;
		DW	.Flip25			;
		DW	.Flip30			;
		DW	.Flip31			;
		DW	.Flip32			;
		DW	.Flip33			;
		DW	.Flip34			;
		DW	.Flip35			;
		DW	.Flip40			;
		DW	.Flip41			;
		DW	.Flip42			;
		DW	.Flip43			;
		DW	.Flip44			;
		DW	.Flip45			;

.Flip10:	DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DB	1,2,3,4			;

.Flip11:	DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DB	1,2,4,3			;

.Flip12:	DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DB	1,3,2,4			;

.Flip13:	DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DB	1,3,4,2			;

.Flip14:	DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DB	1,4,2,3			;

.Flip15:	DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DB	1,4,3,2			;

.Flip20:	DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DB	2,1,3,4			;

.Flip21:	DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DB	2,1,4,3			;

.Flip22:	DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DB	2,3,1,4			;

.Flip23:	DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DB	2,3,4,1			;

.Flip24:	DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DB	2,4,1,3			;

.Flip25:	DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DB	2,4,3,1			;

.Flip30:	DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DB	3,1,2,4			;

.Flip31:	DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DB	3,1,4,2			;

.Flip32:	DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA4		;
		DB	3,2,1,4			;

.Flip33:	DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DB	3,2,4,1			;

.Flip34:	DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DB	3,4,1,2			;

.Flip35:	DW	wTriviaStrA3		;
		DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DB	3,4,2,1			;

.Flip40:	DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DB	4,1,2,3			;

.Flip41:	DW	wTriviaStrA4		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DB	4,1,3,2			;

.Flip42:	DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA3		;
		DB	4,2,1,3			;

.Flip43:	DW	wTriviaStrA4		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DB	4,2,3,1			;

.Flip44:	DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA1		;
		DW	wTriviaStrA2		;
		DB	4,3,1,2			;

.Flip45:	DW	wTriviaStrA4		;
		DW	wTriviaStrA3		;
		DW	wTriviaStrA2		;
		DW	wTriviaStrA1		;
		DB	4,3,2,1			;



; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		ELSE

TriviaGame::	RET

		ENDC



; ***************************************************************************
; * ClrRect18 ()                                                            *
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

ClrRect18::	LD	DE,CodeClrColumn	;Calc address of the dump
		LD	A,[wStringH]		;code for a single column.
		SUB	80+1			;
		JR	NC,.Error		;
		CPL				;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		LD	A,L			;
		LD	[wJmpTemporary+1],A	;
		LD	A,H			;
		LD	[wJmpTemporary+2],A	;

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

		LD	DE,$0120		;Set delta to next dst column.

		LD	A,[wStringW]		;Calc number of columns
		ADD	$07			;to clear.
		AND	$F8			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	B,A			;

.Loop0:		PUSH	HL			;Preserve dst ptr.

		XOR	A			;

		CALL	wJmpTemporary		;Write a column of data.

		POP	HL			;Restore dst ptr.

		ADD	HL,DE			;Goto next dst column.

		DEC	B			;Do another column ?
		JR	NZ,.Loop0		;

		RET				;All Done.

.Error:		JR	.Error			;

;
;
;

CodeClrColumn::	REPT	80			;2 bytes per line repeat.

		LD	[HLI],A			;
		LD	[HLI],A			;

		ENDR				;

		RET				;All Done.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF TRIVIAHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

