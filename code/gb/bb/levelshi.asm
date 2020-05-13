; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** LEVELSHI.ASM                                                   MODULE **
; **                                                                       **
; ** Shell Difficulty Level Selection.                                     **
; **                                                                       **
; ** Last modified : 25 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ** N.B. MUST BE IN SAME BANK AS BITMAPHI.ASM                             **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"levelshi",CODE,BANK[$3F]
		section $3f
;
;
;

ATTR_WHT	EQU	0
ATTR_GRN	EQU	1
ATTR_YEL	EQU	2
ATTR_RED	EQU	3
ATTR_BLU	EQU	4

;
; TblAwardInfo - What each award actually does.
;

AWARD_BACK1	EQU	0
AWARD_PLUS0	EQU	1
AWARD_PLUS1	EQU	2
AWARD_PLUS2	EQU	3
AWARD_PLUS3	EQU	4
AWARD_PLUS4	EQU	5
AWARD_2DICE	EQU	6
AWARD_SHIELD	EQU	7
AWARD_HORSE	EQU	8
AWARD_AGAIN	EQU	9
AWARD_AGAIN2	EQU	10

;TblStg2Award::	DB	AWARD_PLUS0
;		DB	AWARD_PLUS1
;		DB	AWARD_PLUS2
;		DB	AWARD_2DICE

TblStg2Award::	DB	AWARD_BACK1
		DB	AWARD_PLUS1
		DB	AWARD_PLUS2
		DB	AWARD_PLUS4

TblAwardInfo::	DW	AwardStrBack1		;0
		DW	AwardStrPlus0		;1
		DW	AwardStrPlus1		;2
		DW	AwardStrPlus2		;3
		DW	AwardStrPlus3		;4
		DW	AwardStrPlus4		;5
		DW	AwardStr2Dice		;6
		DW	AwardStrShield		;7
		DW	AwardStrHorse		;8
		IF	VERSION_JAPAN
		DW	wString			;9
		DW	wString			;10
		ELSE
		DW	AwardStrAgain		;9
		DW	AwardStrAgain2		;10
		ENDC

AwardStrBack1::	DB	ICON_DIE6,ICON_SPACE,ICON_MINUS,ICON_SPACE,ICON_ZERO+1,0;0
AwardStrPlus0::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_ZERO+0,0	;1
AwardStrPlus1::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_ZERO+1,0	;2
AwardStrPlus2::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_ZERO+2,0	;3
AwardStrPlus3::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_ZERO+3,0	;4
AwardStrPlus4::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_ZERO+4,0	;5
AwardStr2Dice::	DB	ICON_DIE6,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_DIE6,0	;6
AwardStrShield::DB	ICON_SHIELD,0						;7
AwardStrHorse::	DB	ICON_SHOE,0						;8
AwardStrAgain::	DB	ICON_AGAIN,0						;9
AwardStrAgain2::DB	ICON_AGAIN,ICON_SPACE,ICON_PLUS,ICON_SPACE,ICON_SHIELD,0;10

TblAwardBonus::	DB	-1,0,1,2,3,4,$80,$81,$82,$83,$84;

TblAtrAwards::	DW	TblAtrAwardRed		;AWARD_BACK1
		DW	TblAtrAwardRed		;AWARD_PLUS0
		DW	TblAtrAwardYel		;AWARD_PLUS1
		DW	TblAtrAwardGrn		;AWARD_PLUS2
		DW	TblAtrAwardWht		;AWARD_PLUS3
		DW	TblAtrAwardWht		;AWARD_PLUS4
		DW	TblAtrAwardWht		;AWARD_2DICE
		DW	TblAtrAwardWht		;AWARD_SHIELD
		DW	TblAtrAwardWht		;AWARD_HORSE
		DW	TblAtrAwardWht		;AWARD_AGAIN
		DW	TblAtrAwardWht		;AWARD_AGAIN2

TblAtrAwardRed::DB	$0A,$06,$0A,$03,ATTR_RED;Stage
		DB	$0B,$09,$09,$03,ATTR_RED;Award
		DB	$FF

TblAtrAwardYel::DB	$0A,$06,$0A,$03,ATTR_YEL;Stage
		DB	$0B,$09,$09,$03,ATTR_YEL;Award
		DB	$FF

TblAtrAwardGrn::DB	$0A,$06,$0A,$03,ATTR_GRN;Stage
		DB	$0B,$09,$09,$03,ATTR_GRN;Award
		DB	$FF

TblAtrAwardWht::DB	$0A,$06,$0A,$03,ATTR_WHT;Stage
		DB	$0B,$09,$09,$03,ATTR_WHT;Award
		DB	$FF

;
;
;

		IF	0
TblSpeedPhrase::DW	TblTime1
		DW	TblTime1
		DW	TblTime2
		DW	TblTime3
TblTime1::	DB	"Slow",0
TblTime2::	DB	"Normal",0
TblTime3::	DB	"Fast",0
		ELSE
TblSpeedPhrase::DW	117
		DW	117
		DW	118
		DW	119
		ENDC

;
;
;

TblMindPhrase::	DW	TblMind0
		DW	TblMind1
		DW	TblMind2
		DW	TblMind3
		DW	TblMind4
		DW	TblMind5
		DW	TblMind6
TblMind0::	DB	ICON_ZERO+0,0
TblMind1::	DB	ICON_ZERO+1,0
TblMind2::	DB	ICON_ZERO+2,0
TblMind3::	DB	ICON_ZERO+3,0
TblMind4::	DB	ICON_ZERO+4,0
TblMind5::	DB	ICON_ZERO+5,0
TblMind6::	DB	ICON_ZERO+6,0

;
;
;

		IF	0
TblSpitPhrase::	DW	TblSpit0
		DW	TblSpit1
		DW	TblSpit2
TblSpit0::	DB	"Miss",0
TblSpit1::	DB	"Hit",0
TblSpit2::	DB	"Star",0
		ELSE
TblSpitPhrase::	DW	123
		DW	124
		DW	125
		ENDC

;
;
;

		IF	0
TblAwardPhrase::DW	TblComment0		;AWARD_PLUS0
		DW	TblComment1		;AWARD_PLUS1
		DW	TblComment2		;AWARD_PLUS2
		DW	TblComment3		;AWARD_PLUS3
		DW	TblComment3		;AWARD_2DICE
		DW	TblComment3		;AWARD_SHIELD
		DW	TblComment3		;AWARD_HORSE
		DW	TblComment3		;AWARD_AGAIN
TblComment0::	DB	"Oh Dear !",0
TblComment1::	DB	"Good !",0
TblComment2::	DB	"Well Done !",0
TblComment3::	DB	"Superstar !",0
		ELSE
TblAwardPhrase::DW	113			;AWARD_BACK1
		DW	113			;AWARD_PLUS0
		DW	114			;AWARD_PLUS1
		DW	115			;AWARD_PLUS2
		DW	116			;AWARD_PLUS3
		DW	116			;AWARD_PLUS4
		DW	116			;AWARD_2DICE
		DW	116			;AWARD_SHIELD
		DW	116			;AWARD_HORSE
		DW	116			;AWARD_AGAIN
		DW	116			;AWARD_AGAIN2
		ENDC

;
;
;

TblResultStr::	DB	80, 45,GMB_PALF+CGB_PALN+CGB_PAL4,1
;		DB	"Results",0
		DW	107
		DB	4, 66,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Stage",0
		DW	108
		DB	4, 87,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Award",0
		DW	110
		DB	4,108,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Stars",0
		DW	111
		DB	0

TblResultStrT::	DB	80, 45,GMB_PALF+CGB_PALN+CGB_PAL4,1
;		DB	"Results",0
		DW	107
		DB	4, 66,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Time",0
		DW	112
		DB	4, 87,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Award",0
		DW	110
		DB	4,108,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Stars",0
		DW	111
		DB	0

TblResultStrM::	DB	80, 45,GMB_PALF+CGB_PALN+CGB_PAL4,1
;		DB	"Results",0
		DW	107
		DB	4, 66,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Pairs",0
		DW	120
		DB	4, 87,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Award",0
		DW	110
		DB	4,108,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Stars",0
		DW	111
		DB	0

TblResultStrS::	DB	80, 45,GMB_PALF+CGB_PALN+CGB_PAL4,1
;		DB	"Results",0
		DW	107
		DB	4, 66,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Spit",0
		DW	122
		DB	4, 87,GMB_PALF+CGB_PALN+CGB_PAL4,0
;		DB	"Award",0
		DW	110
		DB	0

TblStageOver::	DB	120,66,GMB_PALN+CGB_PALN+CGB_PAL4,1
;		DB	"Complete!",0
		DW	109
		DB	0


;
;
;

ResultAllICmd::	DB	ICMD_NEWPKG
		DW	IDX_CBORDER2PKG
		DW	IDX_CBORDER2PKG
		DB	ICMD_ATTRLIST
		DW	TblAtrResults
		DB	ICMD_END

ResultBtnICmd::	DB	ICMD_SPRON
		DW	wSprite1
		DB	148,123
		DW	DoButtonIcon
ResultFadeICmd::DB	ICMD_FADEUP
		DB	ICMD_HALT
		DB	ICMD_END

ResultBtnICmd2::DB	ICMD_SPRON
		DW	wSprite1
		DB	148,123
		DW	DoButtonIcon
		DB	ICMD_HALT
		DB	ICMD_END

ResultDlyICmd::	DB	ICMD_FADEUP
		DB	ICMD_DELAY,SHOW_DICE_DELAY
		DB	ICMD_HALT
		DB	ICMD_END

;
;
;

TblAtrResults::	DB	$00,$01,$14,$03,ATTR_WHT;Title
		DB	$00,$04,$14,$03,ATTR_BLU;Lhs
		DB	$00,$07,$0B,$07,ATTR_BLU;Lhs
		DB	$00,$0E,$14,$03,ATTR_GRN;Comment
		DB	$FF

;
;
;

; ***************************************************************************
; * LevelSelectHi ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0
LevelSelectHi::	LD	A,[wSubChoose]		;Allow level selection ?
		OR	A			;
		RET	Z			;

		CALL	SetMachineJcb		;Reset machine to known state.

		LD	HL,IDX_BLEVELSPKG	;Setup background.
		LD	DE,IDX_CLEVELSPKG	;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	L,E			;
		LD	H,D			;
.Skip0:		LD	A,[wSubLevel]		;
		INC	A			;
		CALL	XferFullScreen		;

		CALL	FadeInBlack		;Fade in from black.

		CALL	InitAutoRepeat		;Reset auto-repeat.

		XOR	A			;Clear pause request flag.
		LD	[wWantToPause],A	;

LSelectLoop::	CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		CALL	LSelectInput		;Respond to the input.

		LD	A,[wWantToPause]	;
		OR	A			;
		JR	Z,LSelectLoop		;

LSelectDone::	CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;All Done.
		ENDC



; ***************************************************************************
; * LSelectInput ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0
LSelectInput::	LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	Z,.TestR		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestU:		BIT	JOY_U,C			;
		JR	Z,.TestD		;

		SET	JOY_L,C			;

.TestD:		BIT	JOY_D,C			;
		JR	Z,.TestR		;

		SET	JOY_R,C			;

.TestR:		BIT	JOY_R,C			;
		JR	Z,.TestL		;

		LD	A,[wSubLevel]		;
		INC	A			;
		AND	3			;
		JR	ChangeLSelect		;

.TestL:		BIT	JOY_L,C			;
		JR	Z,.TestExit		;

		LD	A,[wSubLevel]		;
		DEC	A			;
		AND	3			;
		JR	ChangeLSelect		;

.TestExit:	RET				;

ChangeLSelect::	LD	[wSubLevel],A		;Preserve level selection.

		INC	A			;Display it.
		JP	ShowFullScreen		;

		ENDC



; ***************************************************************************
; * AllResultInit ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

AllResultInit::	CALL	KillAllSound		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LD	A,%11010010		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;

.Skip0:		LD	BC,ResultAllICmd	;Setup background.
		CALL	NextICmd		;

		RET				;



; ***************************************************************************
; * AllResultProc ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

AllResultProc::	LD	HL,ResultBtnICmd	;
		LD	DE,ResultDlyICmd	;
		JP	BoardWhichICmd		;



; ***************************************************************************
; * LevelResultHi ()                                                        *
; ***************************************************************************
; * Display the subgame result                                              *
; ***************************************************************************
; * Inputs      HL   = Ptr to subgame's title string                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultHi::	PUSH	HL			;Preserve title string.

		LD	A,[wWhichPlyr]		;
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	Z,.Human		;

;
; Show CPU results.
;

.Cpu:		CALL	CalcAwardStg		;
		CALL	GiveAward		;

		LD	A,[wSubAward]		;
		LD	[wSubPhrase],A		;

		CALL	AllResultInit		;

		LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		POP	HL			;Restore title string.

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStr		;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultStage		;Display stage reached.

		CALL	ResultAward		;Display stage reached.

		CALL	ResultStars		;Display bonus stars.

		CALL	ResultPhrase		;Display result comment.

		JP	AllResultProc		;

;
; Show human results.
;

.Human:		CALL	CalcAwardStg		;
		CALL	GiveAward		;

		LD	A,[wSubAward]		;
		LD	[wSubPhrase],A		;

		LD	A,[wSubStage]		;
		PUSH	AF			;
		XOR	A			;
		LD	[wSubStage],A		;

		CALL	AllResultInit		;

		CALL	CalcAwardStg		;

		CALL	DrawNoResults		;

		LD	BC,ResultFadeICmd	;
		CALL	NextICmd		;

.Loop0:		IF	DUMP_TEXT		;
		LD	A,5			;
		ELSE				;
		LD	A,20			;
		ENDC				;
		CALL	AnyWait			;

		LD	BC,ResultAllICmd	;Setup background.
		CALL	NextICmd		;

		CALL	CalcAwardStg		;

		CALL	DrawResults		;

		CALL	WaitForVBL		;

		LD	A,[wSubStage]		;
		ADD	76			;
		CALL	InitSfx			;

		CALL	SloBitmap20x18		;Copy the bitmap to vram.

		LDHL	SP,1			;
		LD	A,[wSubStage]		;
		CP	[HL]			;
		JR	Z,.Done			;
		INC	A			;
		LD	[wSubStage],A		;

		JR	.Loop0			;

.Done:		ADD	SP,4			;Remove junk.

		LD	HL,ResultBtnICmd2	;
		JP	ProcIntroSeq		;

;
;
;

DrawResults::	LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		LDHL	SP,4			;Restore title string.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStr		;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultStage		;Display stage reached.

		CALL	ResultAward		;Display stage reached.

		CALL	ResultStars		;Display bonus stars.

		JP	ResultPhrase		;Display result comment.

;
;
;

DrawNoResults::	LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		LDHL	SP,4			;Restore title string.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStr		;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultNoStage		;Display stage reached.

		CALL	ResultStars		;Display bonus stars.

		JP	ResultPhrase		;Display result comment.



; ***************************************************************************
; * CalcAwardStg ()                                                         *
; ***************************************************************************
; * Calculate the player's award from his subgame results                   *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CalcAwardStg::	LD	HL,TblStg2Award		;Setup award from stage.
		LD	A,[wSubStage]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wSubAward],A		;
		RET				;



; ***************************************************************************
; * CalcAward ()                                                            *
; ***************************************************************************
; * Calculate the player's award from his subgame results                   *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GiveAward::	LD	HL,TblPlyrInfo		;Locate this plyr's info.
		LD	A,[wWhichPlyr]		;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	HL,PLYR_RAM		;
		ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	[wStructRamLo],A	;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	[wStructRamHi],A	;

		LD	HL,PLYR_STARS		;Calculate the total number
		ADD	HL,DE			;of bonus stars (and clamp
		LD	A,[wSubStars]		;the displayed value to 4).
		ADD	[HL]			;
		LD	[HL],A			;
		CP	SEE_STARS+1		;
		JR	C,.Skip1		;
		LD	A,SEE_STARS		;
.Skip1:		LD	[wSubStars],A		;

		LD	HL,TblAwardBonus	;Lookup the die modifier
		LD	A,[wSubAward]		;for this result.
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;
.Skip2:		LD	A,[HL]			;
		BIT	7,A			;
		JR	Z,.Modifier		;
		CP	$F0			;
		JR	C,.Special0		;

.Modifier:	LD	HL,PLYR_MODIFIER	;Simple modifier.
		ADD	HL,DE			;
		ADD	A,[HL]			;
		LD	[HL],A			;
		RET				;

.Special0:	AND	$7F			;2 dice ?
		JR	NZ,.Special1		;

		LD	HL,PLYR_FLAGS		;Award 2 dice.
		ADD	HL,DE			;
		SET	PFLG_2DICE,[HL]		;
		RET				;

.Special1:	DEC	A			;Shield ?
		JR	NZ,.Special2		;

		LD	HL,PLYR_SHIELD		;Increment number of Gaston
		ADD	HL,DE			;Shields.
		INC	[HL]			;
		RET				;

.Special2:	DEC	A			;Horse ?
		JR	NZ,.Special3		;

		LD	HL,PLYR_SHOETRAP	;Award a horseshoe.
		ADD	HL,DE			;
		LD	[HL],3			;
		RET				;

.Special3:	DEC	A			;Again ?
		JR	NZ,.Special4		;

		LD	HL,PLYR_FLAGS		;Award roll-again.
		ADD	HL,DE			;
		SET	PFLG_AGAIN,[HL]		;

		RET				;

.Special4:	DEC	A			;Again ?
		JR	NZ,.Special5		;

		IF	VERSION_JAPAN		;
		ELSE				;
		LD	HL,PLYR_SHIELD		;Increment number of Gaston
		ADD	HL,DE			;Shields (but not on the
		INC	[HL]			;japanese).
		ENDC				;

		LD	HL,PLYR_FLAGS		;Award roll-again.
		ADD	HL,DE			;
		SET	PFLG_AGAIN,[HL]		;

		RET				;

.Special5:	RET				;



; ***************************************************************************
; * ResultTitle ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultTitle::	LD	A,LOW(FontOlde)		;Initialize font.
		LD	[wFontLo],A		;
		LD	A,HIGH(FontOlde)	;
		LD	[wFontHi],A		;

		LD	A,80			;
		LD	[wStringX],A		;
		LD	A,24			;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL0
		LD	[wFontPal],A		;

		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultNoStage ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultNoStage::	LD	B,$0C			;.. or print the icons.
		LD	C,$07			;
		LD	D,96+8			;
		LD	A,66			;
		LD	[wStringY],A		;

		LD	A,GMB_PALN+CGB_PALN+CGB_PAL4
		LD	[wFontPal],A		;

		LD	HL,wTmpString		;
		LD	A,ICON_BALL0		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLD],A			;

		LD	E,3			;
.Loop0:		CALL	ShowIcon		;
		DEC	E			;
		JR	NZ,.Loop0		;

		RET				;



; ***************************************************************************
; * ResultStage ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultStage::	LD	HL,TblStageOver		;Either print "Complete!" ...
		LD	A,[wSubStage]		;
		CP	3			;
		JP	NC,DrawStringLstN	;

		LD	B,$0C			;.. or print the icons.
		LD	C,$07			;
		LD	D,96+8			;
		LD	A,66			;
		LD	[wStringY],A		;

		LD	HL,TblStagePal		;
		LD	A,[wSubStage]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wFontPal],A		;

		LD	HL,wTmpString		;
		LD	A,ICON_BALL1		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLD],A			;

		LD	A,[wSubStage]		;
		INC	A			;
		OR	A			;
		JR	Z,.Skip1		;
		LD	E,A			;
.Loop0:		CALL	ShowIcon		;
		DEC	E			;
		JR	NZ,.Loop0		;

.Skip1:		LD	A,GMB_PALN+CGB_PALN+CGB_PAL4
		LD	[wFontPal],A		;

		LD	HL,wTmpString		;
		LD	A,ICON_BALL0		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLD],A			;

		LD	A,[wSubStage]		;
		INC	A			;
		SUB	3			;
		CPL				;
		INC	A			;
		JR	Z,.Skip2		;
		LD	E,A			;
.Loop1:		CALL	ShowIcon		;
		DEC	E			;
		JR	NZ,.Loop1		;

.Skip2:		RET				;

TblStagePal::	DB	GMB_PALN+CGB_PALN+(ATTR_RED<<2)
		DB	GMB_PALN+CGB_PALN+(ATTR_YEL<<2)
		DB	GMB_PALN+CGB_PALN+(ATTR_GRN<<2)
		DB	GMB_PALN+CGB_PALN+(ATTR_WHT<<2)



; ***************************************************************************
; * ResultAward ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultAward::	LD	A,120			;
		LD	[wStringX],A		;
		LD	A,108-21		;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL1
		LD	[wFontPal],A		;

		IF	VERSION_JAPAN		;
		LD	DE,126			;
		CALL	GetString		;
		ENDC				;

		LD	HL,TblAwardInfo		;
		LD	A,[wSubAward]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultSpeed ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultSpeed::	LD	A,120			;
		LD	[wStringX],A		;
		LD	A,66			;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL1
		LD	[wFontPal],A		;

		LD	HL,TblSpeedPhrase	;
		LD	A,[wSubStage]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		CALL	GetString		;

		LD	HL,wString		;
		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultMind ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultMind::	LD	A,120			;
		LD	[wStringX],A		;
		LD	A,66			;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL1
		LD	[wFontPal],A		;

		LD	HL,TblMindPhrase	;
		LD	A,[wSubCount]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultSpit ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultSpit::	LD	A,120			;
		LD	[wStringX],A		;
		LD	A,66			;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL1
		LD	[wFontPal],A		;

		LD	HL,TblSpitPhrase	;
		LD	A,[wSubStage]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		CALL	GetString		;

		LD	HL,wString		;
		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultPhrase ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultPhrase::	LD	A,80			;
		LD	[wStringX],A		;
		LD	A,129			;
		LD	[wStringY],A		;
		LD	A,GMB_PALN+CGB_PALN+CGB_PAL1
		LD	[wFontPal],A		;

		LD	HL,TblAwardPhrase	;
		LD	A,[wSubPhrase]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		CALL	GetString		;

		LD	HL,wString		;
		JP	DrawStringCtr		;



; ***************************************************************************
; * ResultStars ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResultStars::	LD	A,[wSubStars]		;Clamp displayed bonus.
		CP	SEE_STARS+1		;
		JR	C,.Skip0		;
		LD	A,SEE_STARS		;
		LD	[wSubStars],A		;

.Skip0:		LD	B,$0C			;
		LD	C,$0C			;
		LD	D,96+8			;
		LD	A,87+21			;
		LD	[wStringY],A		;

		LD	A,GMB_PALN+CGB_PALN+CGB_PAL2
		LD	[wFontPal],A		;

		LD	HL,wTmpString		;
		LD	A,ICON_STAR1		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLD],A			;

		LD	A,[wSubStars]		;
		OR	A			;
		JR	Z,.Skip1		;
		LD	E,A			;
.Loop0:		CALL	ShowIcon		;
		DEC	E			;
		JR	NZ,.Loop0		;

.Skip1:		LD	A,GMB_PALN+CGB_PALN+CGB_PAL4
		LD	[wFontPal],A		;

		LD	HL,wTmpString		;
		LD	A,ICON_STAR0		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLD],A			;

		LD	A,[wSubStars]		;
		SUB	SEE_STARS		;
		CPL				;
		INC	A			;
		JR	Z,.Skip2		;
		LD	E,A			;
.Loop1:		CALL	ShowIcon		;
		DEC	E			;
		JR	NZ,.Loop1		;

.Skip2:		RET				;



; ***************************************************************************
; * ShowIcon ()                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShowIcon::	PUSH	BC			;
		PUSH	DE			;

		LD	A,D			;
		LD	[wStringX],A		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	A,[wFontPal]		;
		RRCA				;
		RRCA				;
		AND	7			;
		LD	D,$02			;
		LD	E,$02			;
		CALL	FillShadowAtr		;

.Skip0:		LD	HL,wTmpString		;
		CALL	DrawStringCtr		;

		POP	DE			;
		POP	BC			;

		LD	A,2			;
		ADD	B			;
		LD	B,A			;

		LD	A,16			;
		ADD	D			;
		LD	D,A			;

		RET				;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF LEVELSHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; * LevelResultTHi ()                                                       *
; ***************************************************************************
; * Display the subgame result                                              *
; ***************************************************************************
; * Inputs      HL   = Ptr to subgame's title string                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultTHi::PUSH	HL			;Preserve title string.

		XOR	A			;Clear reward.
		LD	[wSubAward],A		;

		LD	A,[wTriviaRight]	;No reward if a wrong
		OR	A			;answer.
		JR	Z,.Skip1		;

		CALL	CalcAwardStg		;

.Skip1:		CALL	GiveAward		;

		CALL	AllResultInit		;

		LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;
.Skip2:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		POP	HL			;Restore title string.

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStrT	;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultSpeed		;Display stage reached.

		CALL	ResultAward		;Display stage reached.

		CALL	ResultStars		;Display bonus stars.

		LD	A,[wSubAward]		;
		LD	[wSubPhrase],A		;

		CALL	ResultPhrase		;Display result comment.

		JP	AllResultProc		;



; ***************************************************************************
; * LevelResultMHi ()                                                       *
; ***************************************************************************
; * Display the subgame result (bonus concentration game)                   *
; ***************************************************************************
; * Inputs      HL   = Ptr to subgame's title string                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultMHi::PUSH	HL			;Preserve title string.

		IF	0

		LD	A,[wSubCount]		;

.Skip0:		OR	A			;0 pairs.
		JR	NZ,.Skip1		;
		LD	A,AWARD_PLUS1		;
		LD	[wSubAward],A		;
		LD	A,0			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip1:		DEC	A			;1 pairs.
		JR	NZ,.Skip2		;
		LD	A,AWARD_PLUS2		;
		LD	[wSubAward],A		;
		LD	A,0			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip2:		DEC	A			;2 pairs.
		JR	NZ,.Skip3		;
		LD	A,AWARD_PLUS2		;
		LD	[wSubAward],A		;
		LD	A,1			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip3:		DEC	A			;3 pairs.
		JR	NZ,.Skip4		;
		LD	A,AWARD_SHIELD		;
		LD	[wSubAward],A		;
		LD	A,1			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip4:		DEC	A			;4 pairs.
		JR	NZ,.Skip5		;
		LD	A,AWARD_PLUS3		;
		LD	[wSubAward],A		;
		LD	A,2			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip5:		DEC	A			;5 pairs.
		JR	NZ,.Skip6		;
		LD	A,AWARD_HORSE		;
		LD	[wSubAward],A		;
		LD	A,2			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip6:		DEC	A			;6 pairs.
;		JR	NZ,.Skip7		;
		LD	A,AWARD_AGAIN		;
		LD	[wSubAward],A		;
		LD	A,3			;
		LD	[wSubPhrase],A		;
		JR	.Skip7			;

.Skip7:		CALL	GiveAward		;

		ELSE

		LD	HL,TblStg2Award		;Setup award from stage.
		LD	A,[wSubStage]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wSubAward],A		;
		LD	[wSubPhrase],A		;

		CALL	GiveAward		;

		ENDC

		CALL	AllResultInit		;

		LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip8		;
		INC	H			;
.Skip8:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		POP	HL			;Restore title string.

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStrM	;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultMind		;Display stage reached.

		CALL	ResultAward		;Display stage reached.

		CALL	ResultStars		;Display bonus stars.

		CALL	ResultPhrase		;Display result comment.

		JP	AllResultProc		;



; ***************************************************************************
; * LevelResultSHi ()                                                       *
; ***************************************************************************
; * Display the subgame result (bonus spitting game)                        *
; ***************************************************************************
; * Inputs      HL   = Ptr to subgame's title string                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultSHi::PUSH	HL			;Preserve title string.

		XOR	A			;
		LD	[wSubStars],A		;

		LD	A,[wSubStage]		;

.Skip0:		OR	A			;
		JR	NZ,.Skip1		;
		LD	A,AWARD_PLUS2		;
		LD	[wSubAward],A		;
		LD	A,0			;
		LD	[wSubPhrase],A		;
		JR	.Skip3			;

.Skip1:		DEC	A			;
		JR	NZ,.Skip2		;
		LD	A,AWARD_HORSE		;
		LD	[wSubAward],A		;
		LD	A,2			;
		LD	[wSubPhrase],A		;
		JR	.Skip3			;

.Skip2:		DEC	A			;
		JR	NZ,.Skip3		;

		LD	A,[wWhichGame]		;Restarting a game ?
		CP	BACKUP_STORY		;
		LD	A,AWARD_AGAIN		;
		JR	Z,.SkipX		;
		LD	A,AWARD_AGAIN2		;
.SkipX:		LD	[wSubAward],A		;
		LD	A,3			;
		LD	[wSubPhrase],A		;
		JR	.Skip3			;

.Skip3:		CALL	GiveAward		;

		CALL	AllResultInit		;

		LD	HL,TblAtrAwards		;Setup award and comment
		LD	A,[wSubAward]		;palettes.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip4		;
		INC	H			;
.Skip4:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FillShadowLst		;

		POP	HL			;Restore title string.

		CALL	ResultTitle		;Display game title.

		LD	HL,TblResultStrS	;Display static text.
		CALL	DrawStringLstN		;

		CALL	ResultSpit		;Display stage reached.

		CALL	ResultAward		;Display stage reached.

		CALL	ResultPhrase		;Display result comment.

		JP	AllResultProc		;



