; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** TARGETHI.ASM                                                   MODULE **
; **                                                                       **
; ** LeFou's Target Range.                                                 **
; **                                                                       **
; ** Last modified : 10 Jun 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"targethi",CODE,BANK[2]
		section 2
;
;
;

DELAY_EXIT	EQU	(255-15)

;
;
;

hTgtScx		EQUS	"hTemp48+$00"		;$01 bytes * 1
hTgtScy		EQUS	"hTemp48+$01"		;$01 bytes * 1
hTgtChr		EQUS	"hTemp48+$02"		;$01 bytes * 1
hTgtFrm		EQUS	"hTemp48+$03"		;$01 bytes * 1

hTgtCurX	EQUS	"hTemp48+$04"		;$01 bytes * 1
hTgtCurY	EQUS	"hTemp48+$05"		;$01 bytes * 1

hTgtStageLo	EQUS	"hTemp48+$06"		;$01 bytes * 1
hTgtStageHi	EQUS	"hTemp48+$07"		;$01 bytes * 1
hTgtListLo	EQUS	"hTemp48+$08"		;$01 bytes * 1
hTgtListHi	EQUS	"hTemp48+$09"		;$01 bytes * 1
hTgtLoopLo	EQUS	"hTemp48+$0A"		;$01 bytes * 1
hTgtLoopHi	EQUS	"hTemp48+$0B"		;$01 bytes * 1

hTgtLives	EQUS	"hTemp48+$0C"		;$01 bytes * 1
hTgtClkLo	EQUS	"hTemp48+$0D"		;$01 bytes * 1
hTgtClkHi	EQUS	"hTemp48+$0E"		;$01 bytes * 1
hTgtCount	EQUS	"hTemp48+$0F"		;$01 bytes * 1
hTgtDelay	EQUS	"hTemp48+$10"		;$01 bytes * 1
hTgtScaleShow	EQUS	"hTemp48+$11"		;$01 bytes * 1
hTgtScaleNext	EQUS	"hTemp48+$12"		;$01 bytes * 1
hTgtScaleBoth	EQUS	"hTemp48+$13"		;$01 bytes * 1
hTgtShots	EQUS	"hTemp48+$14"		;$01 bytes * 1
hTgtHits	EQUS	"hTemp48+$15"		;$01 bytes * 1
hTgtMiss	EQUS	"hTemp48+$16"		;$01 bytes * 1
hTgtOver	EQUS	"hTemp48+$17"		;$01 bytes * 1

hTgtChrPut	EQUS	"hTemp48+$18"		;$01 bytes * 1
hTgtChrGet	EQUS	"hTemp48+$19"		;$01 bytes * 1
hTgtGfxPut	EQUS	"hTemp48+$1A"		;$01 bytes * 1
hTgtGfxGet	EQUS	"hTemp48+$1B"		;$01 bytes * 1
hTgtScrPut	EQUS	"hTemp48+$1C"		;$01 bytes * 1
hTgtScrGet	EQUS	"hTemp48+$1D"		;$01 bytes * 1

hTgtStgMsk	EQUS	"hTemp48+$1E"		;$01 bytes * 1
hTgtStgIdx	EQUS	"hTemp48+$1F"		;$01 bytes * 1

;
;
;

LEFOU_X		EQU	30

TGT_LIVES	EQU	3
TGT_CLKLO	EQU	120/2
TGT_CLKHI	EQU	12*2

TGT_HIT_BOMB	EQU	1		;Decrement life when hit bomb
TGT_HIT_HEART	EQU	1		;Increment life when hit heart
TGT_HIT_CLOCK	EQU	4		;Increment time when hit clock
TGT_MISS_TIME	EQU	1		;Decrement time when miss target

TGT_MAXIMUM	EQU	6
;
;
;

TGT_FLAGS	EQU	0
TGT_EXEC	EQU	1
TGT_TYPE	EQU	3
TGT_TYPE_FRM	EQU	4
TGT_DELAY	EQU	5

TGT_ANM_PTR	EQU	8
TGT_ANM_FRM	EQU	10
TGT_ANM_DLY	EQU	11
TGT_SCX		EQU	12
TGT_SCY		EQU	13
TGT_CHR		EQU	14
TGT_FRM		EQU	15

;
;
;

;Easy 1st & Nxt
;Hard 1st & Nxt

TblChallenge::	DB	((256*100)/100)-1,((256*95)/100)-1
		DB	((256*65)/100)-1,((256*90)/100)-1

;
;
;

TblStageClock::	DB	TGT_CLKHI-(13-4)	;Easy Stage 0
		DB	TGT_CLKHI-(12-4)	;Easy Stage 1
		DB	TGT_CLKHI-(13-4)	;Easy Stage 2
		DB	0			;Easy -
		DB	TGT_CLKHI-(14-3)	;Norm Stage 0
		DB	TGT_CLKHI-(13-3)	;Norm Stage 1
		DB	TGT_CLKHI-(13-3)	;Norm Stage 2
		DB	0			;Norm -
		DB	TGT_CLKHI-(17-3)	;Hard Stage 0
		DB	TGT_CLKHI-(15-2)	;Hard Stage 1
		DB	TGT_CLKHI-(17-2)	;Hard Stage 2
		DB	0			;Hard -
		DB	0			;Challenge Easy Stage 0
		DB	0			;Challenge Easy Stage 0
		DB	0			;Challenge Easy Stage 0
		DB	0			;Challenge Easy -
		DB	0			;Challenge Hard Stage 0
		DB	0			;Challenge Hard Stage 0
		DB	0			;Challenge Hard Stage 0
		DB	0			;Challenge Hard -

TblRnd0GoodPct::DB	$EA			;Easy Stage 0
		DB	$DD			;Easy Stage 1
		DB	$D0			;Easy Stage 2
		DB	0			;Easy -
		DB	$C3			;Norm Stage 0
		DB	$B6			;Norm Stage 1
		DB	$A9			;Norm Stage 2
		DB	0			;Norm -
		DB	$9C			;Hard Stage 0
		DB	$8F			;Hard Stage 1
		DB	$82			;Hard Stage 2
		DB	0			;Hard -

		DB	$9C			;Challenge Easy Stage 0
		DB	$8F			;Challenge Easy Stage 1
		DB	$82			;Challenge Easy Stage 2
		DB	0			;Challenge Easy -
		DB	$9C			;Challenge Hard Stage 0
		DB	$8F			;Challenge Hard Stage 1
		DB	$82			;Challenge Hard Stage 2
		DB	0			;Challenge Hard -

TblRnd1GoodPct::DB	$9F			;Easy Stage 0
		DB	$92			;Easy Stage 1
		DB	$85			;Easy Stage 2
		DB	0			;Easy -
		DB	$78			;Norm Stage 0
		DB	$6B			;Norm Stage 1
		DB	$5E			;Norm Stage 2
		DB	0			;Norm -
		DB	$51			;Hard Stage 0
		DB	$44			;Hard Stage 1
		DB	$37			;Hard Stage 2
		DB	0			;Hard -

		DB	$51			;Challenge Easy Stage 0
		DB	$44			;Challenge Easy Stage 1
		DB	$37			;Challenge Easy Stage 2
		DB	0			;Challenge Easy -
		DB	$51			;Challenge Hard Stage 0
		DB	$44			;Challenge Hard Stage 1
		DB	$37			;Challenge Hard Stage 2
		DB	0			;Challenge Hard -

TblRndHeartPct::DB	0			;With 0 lives (i.e. never)
		DB	$80			;With 1 life
		DB	$40			;With 2 lives
		DB	$00			;With 3 lives
		DB	$00			;With 4 lives
		DB	$00			;With 5 lives
		DB	$00			;With 6 lives
		DB	$00			;With 7 lives

TblTgtGood::	DB	0			;TGT_ANY
		DB	0			;TGT_CLOCK
		DB	0			;TGT_BOMB
		DB	0			;TGT_HEART
		DB	%011			;TGT_BLUE1
		DB	%001			;TGT_RED1
		DB	%111			;TGT_BLUE2
		DB	%101			;TGT_RED2

TblTgtBad::	DB	0			;TGT_ANY
		DB	0			;TGT_CLOCK
		DB	%111			;TGT_BOMB
		DB	0			;TGT_HEART
		DB	%100			;TGT_BLUE1
		DB	%110			;TGT_RED1
		DB	%000			;TGT_BLUE2
		DB	%010			;TGT_RED2

TblRndGoodTgt::	DB	TGT_BLUE1		;Stage 0
		DB	TGT_RED1		;Stage 0
		DB	TGT_BLUE2		;Stage 0
		DB	TGT_RED2		;Stage 0
		DB	TGT_BLUE1		;Stage 0
		DB	TGT_RED1		;Stage 0
		DB	TGT_BLUE2		;Stage 0
		DB	TGT_RED2		;Stage 0
		DB	TGT_BLUE1		;Stage 1
		DB	TGT_BLUE2		;Stage 1
		DB	TGT_BLUE1		;Stage 1
		DB	TGT_BLUE2		;Stage 1
		DB	TGT_BLUE1		;Stage 1
		DB	TGT_BLUE2		;Stage 1
		DB	TGT_BLUE1		;Stage 1
		DB	TGT_BLUE2		;Stage 1
		DB	TGT_BLUE2		;Stage 2
		DB	TGT_RED2		;Stage 2
		DB	TGT_BLUE2		;Stage 2
		DB	TGT_RED2		;Stage 2
		DB	TGT_BLUE2		;Stage 2
		DB	TGT_RED2		;Stage 2
		DB	TGT_BLUE2		;Stage 2
		DB	TGT_RED2		;Stage 2

TblRndBadTgt::	DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 0
		DB	TGT_BOMB		;Stage 1
		DB	TGT_BOMB		;Stage 1
		DB	TGT_RED1		;Stage 1
		DB	TGT_RED2		;Stage 1
		DB	TGT_RED1		;Stage 1
		DB	TGT_RED2		;Stage 1
		DB	TGT_RED1		;Stage 1
		DB	TGT_RED2		;Stage 1
		DB	TGT_BOMB		;Stage 2
		DB	TGT_BOMB		;Stage 2
		DB	TGT_RED1		;Stage 2
		DB	TGT_BLUE1		;Stage 2
		DB	TGT_RED1		;Stage 2
		DB	TGT_BLUE1		;Stage 2
		DB	TGT_RED1		;Stage 2
		DB	TGT_BLUE1		;Stage 2

TblTgtHitFnc::	DW	TgtHitNull		;TGT_ANY
		DW	TgtHitClock		;TGT_CLOCK
		DW	TgtHitBomb		;TGT_BOMB
		DW	TgtHitHeart		;TGT_HEART
		DW	TgtHitThing		;TGT_BLUE1
		DW	TgtHitThing		;TGT_RED1
		DW	TgtHitThing		;TGT_BLUE2
		DW	TgtHitThing		;TGT_RED2

;
;
;

TgtAnmIn::	DB	1,3,2,3,3,0

TgtAnmInBW::	DB	0,2,2,4,3,0

TgtAnmOut::	DB	2,3,1,3,0,20,0,1,0,0

TgtAnmOutBW::	DB	2,4,0,2,0,20,0,1,0,0

TgtAnmOutHit::	DB	8,3,9,3,10,20,0,1,0,0

TgtAnmHit::	DB	4,3,5,3,6,3,7,0

;
;
;

TgtAnmTaunt::	DB	13,2,14,2,15,2,16,6,17,4
		DB	18,4,19,4
		DB	20,4,21,4,22,4,23,4
		DB	20,4,21,4,22,4,23,4
		DB	24,4,25,4,26,2,27,2
		DB	0,1,0,0

TgtAnmAplIn::	DB	1,2,2,2,3,2,4,1,4,0

TgtAnmAplOut::	DB	3,2,2,2,1,2,0,1,0,0

TgtAnmAplHit::	DB	5,2,6,2,7,2,8,2,9,2,10,2
		DB	11,8,12,2,13,2,0,1,0,0

TgtAnmStar::	DB	1,2,2,2,3,2,4,2,5,2,6,2,7,2,8,2
		DB	1,2,2,2,3,2,4,2,5,2,6,2,7,2,8,2
		DB	1,1,0,1,2,1,0,1,3,1,0,1,4,1,0,1
		DB	5,1,0,1,6,1,0,1,7,1,0,1,8,1,0,1
		DB	0,1,0,0

;
;
;

TblTgtPos::	DB	$02,$04,$06,$04,$0A,$04,$0E,$04
		DB	$02,$08,$06,$08,$0A,$08,$0E,$08
		DB	$02,$0C,$06,$0C,$0A,$0C,$0E,$0C

TblTgtCurPos::	DB	$10,$20,$30,$20,$50,$20,$70,$20
		DB	$10,$40,$30,$40,$50,$40,$70,$40
		DB	$10,$60,$30,$60,$50,$60,$70,$60

TblTgtCurOam::	DB	$10,$08,$7C,$10
		DB	$20,$08,$7E,$10
		DB	$10,$20,$7C,$30
		DB	$20,$20,$7E,$30

;
;
;

; ***************************************************************************
; * TargetRange ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TargetRange::	CALL	KillAllSound		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,TGT_LIVES		;
		LDH	[hTgtLives],A		;

		LD	A,255			;
		LDH	[hTgtScaleBoth],A	;

;		XOR	A			;
;		LD	[wSubStage],A		;

		LD	A,[wSubGaston]		;Playing a Gaston game ?
		OR	A			;
		JR	Z,.Skip0		;

		LD	A,1			;
		LDH	[hTgtLives],A		;

		JR	TargetStage		;

.Skip0:		LD	A,[wSubLevel]		;Playing challenge mode ?
		SUB	3			;
		JR	C,TargetStage		;

		LD	HL,TblChallenge+0	;Initialize scaling.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HL]			;
		LDH	[hTgtScaleBoth],A	;

		LD	A,2			;Challenge game plays with
		LD	[wSubStage],A		;stage 2 targets and 1 life.
		LD	A,1			;
		LDH	[hTgtLives],A		;

TargetStage::	CALL	KillAllSound		;

		CALL	DisplayStage		;Inform user of the stage.

		LD	HL,TgtStages		;Init target stage ptr.
		LD	A,[wSubLevel]		;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[wSubStage]		;
		ADD	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LDH	[hTgtStageLo],A		;
		LDH	[hTgtLoopLo],A		;
		LD	A,[HLI]			;
		LDH	[hTgtStageHi],A		;
		LDH	[hTgtLoopHi],A		;

		LD	A,[wSubStage]		;
		INC	A			;
		LD	B,A			;
		LD	A,1			;
.Loop:		ADD	A			;
		DEC	B			;
		JR	NZ,.Loop		;
		SRL	A			;
		LDH	[hTgtStgMsk],A		;

		LD	A,[wSubLevel]		;
		ADD	A			;
		ADD	A			;
		LD	C,A			;
		LD	A,[wSubStage]		;
		ADD	C			;
		LDH	[hTgtStgIdx],A		;

		LD	HL,TblStageClock	;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;
		LDH	[hTgtClkHi],A		;
		LD	A,TGT_CLKLO		;
		LDH	[hTgtClkLo],A		;

		XOR	A			;
		LDH	[hTgtCount],A		;
		LDH	[hTgtShots],A		;
		LDH	[hTgtHits],A		;
		LDH	[hTgtOver],A		;

		CALL	ResetTargets		;Reset all targets.

		CALL	InitTgtList		;Init target sequence.

TargetRestart::	CALL	KillAllSound		;

		CALL	SetMachineJcb		;Reset machine to known state.

		LD	HL,wTgtGfxLst
		LD	A,L			;Reset the gfx update
		LDH	[hTgtGfxPut],A		;request lists.
		LDH	[hTgtGfxGet],A		;
		LD	HL,wTgtScrLst
		LD	A,L			;
		LDH	[hTgtScrPut],A		;
		LDH	[hTgtScrGet],A		;

		CALL	InitTgtChr		;Reset the gfx resource list.

		LD	HL,IDX_CCURSORPKG	;Setup cursor.
		LD	DE,$87C0		;
		CALL	GetCursorGfx		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	Z,TargetInitCgb		;

TargetInitGmb::	IF	VERSION_USA
		LD	HL,IDX_BRANGEPKG	;Setup background.
		ELSE
;		LD	HL,IDX_BRANGE2PKG	;Setup background.
		LD	HL,IDX_BRANGEPKG	;Setup background.
		ENDC
		CALL	GmbXferScreen		;

		LD	HL,IDX_BTARGETPKG	;Setup target graphics.
		CALL	GetTargetGfx		;

		JR	TargetInitBoth		;

TargetInitCgb::	IF	VERSION_USA
		LD	HL,IDX_CRANGEPKG	;Setup background.
		ELSE
;		LD	HL,IDX_CRANGE2PKG	;Setup background.
		LD	HL,IDX_CRANGEPKG	;Setup background.
		ENDC
		CALL	CgbXferScreen		;

		LD	HL,IDX_CTARGETPKG	;Setup target graphics.
		CALL	GetTargetGfx		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_TGTCURSOR	;
		CALL	AddSpritePal		;
		LD	HL,PAL_DUST		;
		CALL	AddSpritePal		;
		LD	HL,PAL_CLEFOUDK		;
		CALL	AddSpritePal		;
		LD	HL,PAL_CLEFOUNS		;
		CALL	AddSpritePal		;

TargetInitBoth::CALL	UpdatePanel		;Setup status panel.

		LD	A,LOW(LycTargetRange)	;Setup game's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblTargetRange)	;
		LD	[wVblVector],A		;

		CALL	DumpTargetAll		;Update all target graphics.

		CALL	FadeInBlack		;Fade in from black.

		CALL	InitAutoRepeat		;Reset auto-repeat.

		XOR	A			;Clear pause request flag.
		LD	[wWantToPause],A	;

		CALL	WaitForVBL		;Synchronize to the VBL.

TargetLoop::	LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LDH	A,[hTgtOver]		;Stage finished ?
		OR	A			;
		JR	Z,TargetUser		;
		INC	A			;
		JR	Z,TargetExit		;
		LDH	[hTgtOver],A		;
		INC	A			;
		JR	NZ,TargetTick		;

		LDH	A,[hTgtClkHi]		;Time over ?
		OR	A			;
		JR	Z,TargetLost		;

		LDH	A,[hTgtLives]		;All lives lost ?
		OR	A			;
		JR	Z,TargetLost		;

TargetWon::	LD	A,[wSubStage]		;
		CP	2			;
		JR	Z,.Skip0		;
		CALL	KillAllSound		;
		JR	TargetTick		;
.Skip0:		LD	A,SONG_WON		;
		CALL	InitTune		;
		JR	TargetTick		;

TargetLost::	LD	A,SONG_LOST		;
		CALL	InitTune		;
		JR	TargetTick		;

TargetExit::	LD	A,[wMzPlaying]		;Wait for exit tune to
		OR	A			;finish.
		JR	NZ,TargetTick		;

		JP	TargetNext		;

TargetUser::	CALL	TargetMusic		;Ensure that music is playing.

		CALL	TargetInput		;Get user input.

		LD	A,[wWantToPause]	;Pause ?
		OR	A			;
		JP	NZ,TargetPause		;

		CALL	UpdateClock		;Update clock.

		CALL	ProcTgtList		;Process the target sequence.

TargetTick::	LD	BC,wTgtSprite+$00	;Process the individual
		CALL	ProcTarget		;targets.
		LD	BC,wTgtSprite+$10	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$20	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$30	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$40	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$50	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$60	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$70	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$80	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$90	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$A0	;
		CALL	ProcTarget		;
		LD	BC,wTgtSprite+$B0	;
		CALL	ProcTarget		;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wTgtLeFou0		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wTgtLeFou1		;
		CALL	ProcSprite		;
		LD	SP,wTgtStar		;
		CALL	ProcSprite		;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		CALL	UpdatePanel		;

		CALL	DumpTargetGfx		;Update 3 targets a frame
		CALL	DumpTargetGfx		;at a maximum.
		CALL	DumpTargetGfx		;

		CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	DumpTgtSpr		;Update sprite graphics.
		CALL	DrawTgtSpr		;

		CALL	WaitForVBL		;Synchronize to the VBL.

		JP	TargetLoop		;

;
;
;

TargetNext::	CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;

		LDH	A,[hTgtClkHi]		;Time over ?
		OR	A			;
		JR	Z,TargetFinished	;

		LDH	A,[hTgtLives]		;All lives lost ?
		OR	A			;
		JR	Z,TargetFinished	;

		LD	A,[wSubStage]		;Increment stage.
		INC	A			;
		CP	3			;
		LD	[wSubStage],A		;
		JR	Z,TargetFinished	;

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		JP	TargetStage		;Do the next stage.

;
;
;

TargetFinished::CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;All Done.

;
;
;

TargetPause::	CALL	FadeOutBlack		;Fade out.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	SetMachineJcb		;Reset machine to known state.

		CALL	PauseMenu_B		;Call the generic pause.

		JP	TargetRestart		;And then restart this game.

;
;
;

TargetMusic::	LD	A,[wMzNumber]		;
		OR	A			;
		RET	NZ			;
;		LD	A,[wMzNumber]		;
;		CP	A,SONG_TARGET		;
;		RET	Z			;
		LD	A,SONG_TARGET		;
		JP	InitTunePref		;



; ***************************************************************************
; * InitTgtList ()                                                          *
; * ProcTgtList ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LoopTgtList::	LDH	A,[hTgtScaleBoth]	;Read the current delay
		LD	C,A			;multiplier.
		LD	B,0			;
		INC	BC			;

		LD	HL,TblChallenge+1	;Modify it.
		LD	A,[wSubLevel]		;
		SUB	3			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		INC	A			;
		CALL	MultiplyBWW		;
		LD	A,H			;
		OR	A			;
		JR	Z,.Skip1		;
		DEC	A			;
.Skip1:		LDH	[hTgtScaleBoth],A	;

		LDH	A,[hTgtLoopLo]		;Reset the target stage ptr
		LDH	[hTgtStageLo],A		;back to its initial setting.
		LDH	A,[hTgtLoopHi]		;
		LDH	[hTgtStageHi],A		;

InitTgtList::	LDH	A,[hTgtStageLo]		;Get target stage ptr.
		LD	E,A			;
		LDH	A,[hTgtStageHi]		;
		LD	D,A			;

		LD	A,[DE]			;Read the next delay scaling
		OR	A			;factor (zero marks end).
		JR	NZ,.Skip0		;

		LD	A,[wSubLevel]		;Playing challenge mode ?
		CP	3			;
		JR	NC,LoopTgtList		;

		LD	A,DELAY_EXIT		;Signal the end-of-list.
		LDH	[hTgtOver],A		;

		DEC	DE			;And use the previous
		DEC	DE			;set of random lists.
		DEC	DE			;
		DEC	DE			;

.Skip0:		LDH	A,[hTgtScaleBoth]	;Read the show delay scaling
		LD	C,A			;factor.
		LD	B,0			;
		INC	BC			;
		LD	A,[DE]			;
		INC	DE			;
		CALL	MultiplyBWW		;
		LD	A,H			;
		LDH	[hTgtScaleShow],A	;

		LDH	A,[hTgtScaleBoth]	;Read the next delay scaling
		LD	C,A			;factor.
		LD	B,0			;
		INC	BC			;
		LD	A,[DE]			;
		INC	DE			;
		CALL	MultiplyBWW		;
		LD	A,H			;
		LDH	[hTgtScaleNext],A	;

		LD	A,[DE]			;Read the ptr to the table
		INC	DE			;of lists.
		LD	L,A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	H,A			;

		LD	A,E			;Put target stage ptr.
		LDH	[hTgtStageLo],A		;
		LD	A,D			;
		LDH	[hTgtStageHi],A		;

		LD	A,[HLI]			;Randomly select 1 of the
		LD	C,A			;patterns from the list
		PUSH	HL			;of possible patterns.
		CALL	random			;
		CALL	MultiplyBBW		;
		LD	A,H			;
		ADD	A			;
		POP	HL			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;

.Skip1:		LD	A,[HLI]			;Get target list ptr.
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	A,[DE]			;Set initial next target
		INC	DE			;delay.
		LDH	[hTgtDelay],A		;

		LD	A,E			;Put target list ptr.
		LDH	[hTgtListLo],A		;
		LD	A,D			;
		LDH	[hTgtListHi],A		;

NextTgtList::	LDH	A,[hTgtScaleNext]	;Get scaling factor.
		LD	C,A			;
		LD	B,0			;

		LDH	A,[hTgtDelay]		;Scale next target delay.
		CP	$FF			;
		JR	Z,InitTgtList		;
		CALL	MultiplyBWW		;
		LD	BC,$0080		;
		ADD	HL,BC			;
		LD	A,H			;
		LDH	[hTgtDelay],A		;

ProcTgtList::	LDH	A,[hTgtDelay]		;Is the delay between
		OR	A			;targets over ?
		JR	Z,ReadTgtList		;
		DEC	A			;
		LDH	[hTgtDelay],A		;
		RET				;

ReadTgtList::	LDH	A,[hTgtCount]		;Maximum number of targets
		CP	TGT_MAXIMUM		;on screen already ?
		RET	NC			;

		LDH	A,[hTgtListLo]		;Get target list ptr.
		LD	C,A			;
		LDH	A,[hTgtListHi]		;
		LD	B,A			;

		LD	A,[BC]			;Read next target posn.
		INC	BC			;

		CP	$FF			;
		JP	Z,InitTgtList		;

		CP	12			;
		JP	NC,NextTgtFore		;

;
; Next target is in the background.
;

NextTgtBack::	LD	DE,wTgtSprite		;Calc next target struct
		SWAP	A			;address.
		ADD	E			;
		LD	E,A			;

		LD	HL,TGT_FLAGS		;Is the target already in
		ADD	HL,DE			;use ?
		BIT	FLG_EXEC,[HL]		;
		RET	NZ			;

		LD	[HL],MSK_EXEC		;Set target flags and
		INC	L			;function.
		LD	[HL],LOW(DoTgtIn)	;
		INC	L			;
		LD	[HL],HIGH(DoTgtIn)	;

		LD	HL,TGT_TYPE		;Set target type.
		ADD	HL,DE			;
		LD	A,[BC]			;
		INC	BC			;

		CP	TGT_CLOCK		;Don't bring up a clock
		JR	NZ,.Skip0		;target if in challenge
		LD	A,[wSubLevel]		;mode.
		CP	3			;
		LD	A,TGT_CLOCK		;
		JR	C,.Skip0		;
		LD	A,TGT_RND0		;

.Skip0:		CP	TGT_RND0		;Handle special target
		CALL	Z,GetRndTgtRnd0		;types.
		CP	TGT_RND1		;
		CALL	Z,GetRndTgtRnd1		;
		CP	TGT_RNDH		;
		CALL	Z,GetRndTgtRndH		;
		CP	TGT_GOOD		;
		CALL	Z,GetRndTgtGood		;
		CP	TGT_BAD			;
		CALL	Z,GetRndTgtBad		;
		LD	[HL],A			;

		LD	HL,TGT_DELAY		;Set show target delay.
		ADD	HL,DE			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HL],A			;

		LD	A,[BC]			;Set next target delay.
		INC	BC			;
		LDH	[hTgtDelay],A		;

		LD	A,C			;Put target list ptr.
		LDH	[hTgtListLo],A		;
		LD	A,B			;
		LDH	[hTgtListHi],A		;

		LD	HL,TGT_TYPE		;Calc TGT_TYPE_FRM.
		ADD	HL,DE			;
		LD	A,[HL]			;
		DEC	A			;
		LD	C,TGT_F			;
		CALL	MultiplyBBW		;
		LD	A,L			;
		LD	HL,TGT_TYPE_FRM		;
		ADD	HL,DE			;
		LD	[HL],A			;

		XOR	A			;

		LD	HL,TGT_CHR		;Reset TGT_CHR.
		ADD	HL,DE			;
		LD	[HL],A			;

		LD	HL,TGT_FRM		;Reset TGT_FRM.
		ADD	HL,DE			;
		LD	[HL],A			;

		LD	HL,hTgtCount		;Increment number of targets
		INC	[HL]			;on screen.

		LDH	A,[hTgtScaleShow]	;Get scaling factor.
		LD	C,A			;
		LD	B,0			;

		LD	HL,TGT_DELAY		;Scale show target delay.
		ADD	HL,DE			;
		LD	A,[HL]			;
		CALL	MultiplyBWW		;
		LD	BC,$0080		;
		ADD	HL,BC			;
		LD	A,H			;
		LD	HL,TGT_DELAY		;
		ADD	HL,DE			;
		LD	[HL],A			;

		JP	NextTgtList		;Scale next target delay.

;
; Next target is in the foreground.
;

NextTgtFore::	LD	HL,wTgtLeFou0+SPR_FLAGS	;Is the target already in
		BIT	FLG_EXEC,[HL]		;use ?
		RET	NZ			;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wTgtLeFou0		;Must use the LeFou sprite.

		LDHL	SP,SPR_SCR_X		;Calc and save the target's
		AND	3			;position.
		SWAP	A			;
		ADD	A			;
		ADD	LEFOU_X			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;
		LD	A,130			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;

		LDHL	SP,SPR_TYPE		;Set target type.
		LD	A,[BC]			;
		INC	BC			;
		LD	[HL],A			;

		LD	DE,DoTgtTaunt		;Set target type's function.
		CP	TGT_TAUNT		;
		JR	Z,.Skip0		;
		LD	DE,DoTgtApple		;
.Skip0:		LDHL	SP,SPR_EXEC		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_DELAY		;Set show target delay.
		LD	A,[BC]			;
		INC	BC			;
		LD	[HL],A			;

		LD	A,[BC]			;Set next target delay.
		INC	BC			;
		LDH	[hTgtDelay],A		;

		LD	A,C			;Put target list ptr.
		LDH	[hTgtListLo],A		;
		LD	A,B			;
		LDH	[hTgtListHi],A		;

		LD	A,[wSubGaston]		;Abort LeFou if in Gaston
		OR	A			;mode.
		JR	NZ,SkipTgtFore		;

		LD	A,[wSubLevel]		;Abort LeFou if in challenge
		CP	3			;mode.
		JR	NC,SkipTgtFore		;

		LDHL	SP,SPR_FLAGS		;
		LD	[HL],MSK_EXEC+MSK_DRAW+MSK_PLOT

		XOR	A			;

		LDHL	SP,SPR_FRAME		;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLIP		;
		LD	[HLI],A			;

		LDHL	SP,SPR_OAM_CNT		;
		LD	[HLI],A			;

		LD	HL,hTgtCount		;Increment number of targets
		INC	[HL]			;on screen.

		LDH	A,[hTgtScaleShow]	;Get scaling factor.
		LD	C,A			;
		LD	B,0			;

		LDHL	SP,SPR_DELAY		;Scale show target delay.
		LD	A,[HL]			;
		CALL	MultiplyBWW		;
		LD	BC,$0080		;
		ADD	HL,BC			;
		LD	A,H			;
		LDHL	SP,SPR_DELAY		;
		LD	[HL],A			;

		PUSH	HL			;Does he have a nose ?
		CALL	TheNoseSprite		;(Correcting stack depth.)
		POP	HL			;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		JP	NextTgtList		;Scale next target delay.

SkipTgtFore::	LDHL	SP,SPR_FLAGS		;Skip this target if in
		LD	[HL],0			;challenge mode.

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		JP	ReadTgtList		;Scale next target delay.
;		JP	NextTgtList		;Scale next target delay.

;
;
;

GetRndTgtRnd0::	LD	HL,TblRnd0GoodPct	;
		JR	GetRndTgtRnd		;

GetRndTgtRnd1::	LD	HL,TblRnd1GoodPct	;
		JR	GetRndTgtRnd		;

GetRndTgtRnd::	LDH	A,[hTgtStgIdx]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		CALL	random			;
		CP	1			;
		JR	C,.Skip1		;
		DEC	A			;
		CP	[HL]			;
.Skip1:		LD	A,TGT_GOOD		;
		JR	C,.Skip2		;
		LD	A,TGT_BAD		;
.Skip2:		LD	HL,TGT_TYPE		;
		ADD	HL,DE			;
		RET				;

GetRndTgtRndH::	LD	A,[wSubGaston]		;
		OR	A			;
		JR	NZ,.Skip1		;
		LD	A,[wSubLevel]		;
		CP	3			;
		JR	NC,.Skip1		;
		LD	HL,TblRndHeartPct	;
		LDH	A,[hTgtLives]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		CALL	random			;
		CP	[HL]			;
		LD	A,TGT_HEART		;
		JR	C,.Skip2		;
.Skip1:		LD	A,TGT_GOOD		;
.Skip2:		LD	HL,TGT_TYPE		;
		ADD	HL,DE			;
		RET				;

GetRndTgtGood::	LD	HL,TblRndGoodTgt	;
		JR	GetRndTgtBoth		;

GetRndTgtBad::	LD	HL,TblRndBadTgt		;
		JR	GetRndTgtBoth		;

GetRndTgtBoth::	PUSH	BC			;
		LD	B,0			;
		LD	A,[wSubStage]		;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LD	C,A			;
		ADD	HL,BC			;
		CALL	random			;
		AND	7			;
		LD	C,A			;
		ADD	HL,BC			;
		LD	A,[HL]			;
		POP	BC			;
		LD	HL,TGT_TYPE		;
		ADD	HL,DE			;
		RET				;



; ***************************************************************************
; * DoTgtXxxx ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

;
;
;

DoTgtIn::	LD	DE,TgtAnmIn		;Initialize the appearance
		LDH	A,[hMachine]		;animation.
		CP	MACHINE_CGB		;
		JR	Z,.Skip0		;
		LD	DE,TgtAnmInBW		;
.Skip0:		CALL	SetTargetAnm		;

		LD	DE,DoTgtInWait		;
		JP	SetTargetFnc		;

;
;
;

DoTgtInWait::	LD	HL,TGT_FLAGS		;Wait until animation is
		ADD	HL,BC			;finished.
		BIT	FLG_ANM,[HL]		;
		RET	NZ			;

		SET	FLG_CHK,[HL]		;Enable shot detection.

		LD	DE,DoTgtInPosn		;
		JP	SetTargetFnc		;

;
;
;

DoTgtInPosn::	LD	HL,TGT_DELAY		;Wait for the popup delay
		ADD	HL,BC			;to end.
		LD	A,[HL]			;
		OR	A			;
		JR	Z,DoTgtOut		;
		DEC	[HL]			;
		RET				;

DoTgtOut::	LD	HL,TGT_FLAGS		;Wait until animation is
		ADD	HL,BC			;finished.
		BIT	FLG_ANM,[HL]		;
		RET	NZ			;

		RES	FLG_CHK,[HL]		;Disable shot detection.

		LD	DE,TgtAnmOutHit		;
		BIT	FLG_HIT,[HL]		;
		JR	NZ,DoTgtExit		;

DoTgtMiss::	LDH	A,[hTgtOver]		;
		OR	A			;
		JR	NZ,.Skip3		;

		LD	HL,TGT_TYPE		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		LD	HL,TblTgtGood		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LDH	A,[hTgtStgMsk]		;
		AND	[HL]			;
		JR	Z,.Skip3		;

		LDH	A,[hTgtClkHi]		;
		SUB	TGT_MISS_TIME		;
		JR	NC,.Skip1		;
		XOR	A			;
.Skip1:		LDH	[hTgtClkHi],A		;
		OR	A			;
		JR	NZ,.Skip2		;

		LD	A,DELAY_EXIT		;
		LDH	[hTgtOver],A		;

.Skip2:		PUSH	BC			;
		LD	A,FX_NOT_SHOT		;
		CALL	InitSfx			;
		POP	BC			;

.Skip3:		LD	DE,TgtAnmOut		;Initialize the disappearance
		LDH	A,[hMachine]		;animation.
		CP	MACHINE_CGB		;
		JR	Z,DoTgtExit		;
		LD	DE,TgtAnmOutBW		;

DoTgtExit::	CALL	SetTargetAnm		;

		LD	DE,DoTgtOutWait		;
		JP	SetTargetFnc		;

;
;
;

DoTgtOutWait::	LD	HL,TGT_FLAGS		;Wait until animation is
		ADD	HL,BC			;finished.
		BIT	FLG_ANM,[HL]		;
		RET	NZ			;

		LD	[HL],0			;Disable this target.

		LD	HL,hTgtCount		;Decrement target count.
		DEC	[HL]			;

		RET				;All Done.

;
;
;

; ***************************************************************************
; * InitTarget ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *             DE   = Control function                                     *
; *             A    = Target type                                          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

InitTarget::	LD	HL,TGT_TYPE		;Set target type.
		ADD	HL,BC			;
		LD	[HL],A			;

		LD	DE,DoTgtIn

		LD	HL,TGT_FLAGS		;Set target flags.
		ADD	HL,BC			;
		LD	[HL],MSK_EXEC		;
		INC	L			;
		LD	[HL],E			;
		INC	L			;
		LD	[HL],D			;

		LD	HL,TGT_TYPE		;Get target type.
		ADD	HL,BC			;
		LD	A,[HL]			;
		DEC	A			;

		LD	E,C			;
		LD	D,B			;

		LD	C,TGT_F			;
		CALL	MultiplyBBW		;
		LD	A,L			;

		LD	C,E			;
		LD	B,D			;

		LD	HL,TGT_TYPE_FRM		;Set target type 1st frame.
		ADD	HL,BC			;
		LD	[HL],A			;

		XOR	A			;

		LD	HL,TGT_CHR		;
		ADD	HL,BC			;
		LD	[HL],A			;

		LD	HL,TGT_FRM		;
		ADD	HL,BC			;
		LD	[HL],A			;

		LD	HL,TGT_DELAY		;
		ADD	HL,BC			;
		LD	[HL],60			;

		LD	HL,hTgtCount		;Increment target count.
		INC	[HL]			;

		RET				;All Done.



; ***************************************************************************
; * ProcTarget ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

ProcTarget::	LD	HL,TGT_FLAGS		;Is this target active ?
		ADD	HL,BC			;
		LD	A,[HLI]			;
		BIT	FLG_EXEC,A		;
		RET	Z			;

		PUSH	BC			;Preserve structure ptr.

		LD	A,[HLI]			;Execute the target's
		LD	H,[HL]			;control routine.
		LD	L,A			;
		CALL	IndirectHL		;

		LD	HL,TGT_FLAGS		;Animating ?
		ADD	HL,BC			;
		BIT	FLG_ANM,[HL]		;
		CALL	NZ,IncTargetAnm		;

		LD	HL,TGT_FLAGS		;New frame ?
		ADD	HL,BC			;
		BIT	FLG_NEW,[HL]		;
		CALL	NZ,NewTargetFrm		;

		POP	BC			;Restore structure ptr.

		RET				;All Done.



; ***************************************************************************
; * SetTargetFnc ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *             DE   = Ptr to function                                      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

SetTargetFnc::	LD	HL,TGT_EXEC		;
		ADD	HL,BC			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * NewTargetFrm ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

NewTargetFrm::	PUSH	BC			;Preserve structure ptr.

		LD	HL,TGT_FLAGS		;Reset new frm signal.
		ADD	HL,BC			;
		RES	FLG_NEW,[HL]		;

		LD	HL,TGT_CHR		;Free old chr number.
		ADD	HL,BC			;
		CALL	FreeTgtChr		;

		LD	HL,TGT_ANM_FRM		;Calc new frm number.
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Skip0		;

		LD	HL,TGT_TYPE_FRM		;
		ADD	HL,BC			;
		ADD	[HL]			;

.Skip0:		LD	HL,TGT_FRM		;
		ADD	HL,BC			;
		LD	[HL],A			;

		LD	HL,TGT_CHR		;Free old chr number.
		ADD	HL,BC			;
		OR	A			;
		CALL	NZ,NextTgtChr		;

		LD	HL,TGT_SCX		;Copy frm to the request
		ADD	HL,BC			;list.

		LDH	A,[hTgtGfxPut]		;Get the output list ptr.
		LD	DE,wTgtGfxLst
		LD	C,E
		LD	E,A			;

		ADD	$04			;Update the list ptr.
		AND	wTgtGfxMsk		;
		OR	C			;
		LDH	[hTgtGfxPut],A		;

		LD	A,[HLI]			;hTgtScx
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;hTgtScy
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;hTgtChr
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;hTgtFrm
		LD	[DE],A			;
		INC	E			;

		POP	BC			;Restore structure ptr.

		RET				;All Done.



; ***************************************************************************
; * IncTargetAnm ()                                                         *
; * SetTargetAnm ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

IncTargetAnm::	LD	HL,TGT_ANM_DLY		;
		ADD	HL,BC			;
		DEC	[HL]			;
		RET	NZ			;

		LD	HL,TGT_ANM_PTR		;
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

SetTargetAnm::	LD	HL,TGT_ANM_FRM		;
		ADD	HL,BC			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HL],A			;

		LD	HL,TGT_ANM_DLY		;
		ADD	HL,BC			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HL],A			;

		LD	HL,TGT_FLAGS		;
		ADD	HL,BC			;
		SET	FLG_ANM,[HL]		;
		SET	FLG_NEW,[HL]		;

		OR	A			;
		JR	NZ,.Skip		;

		RES	FLG_ANM,[HL]		;

.Skip:		LD	HL,TGT_ANM_PTR		;
		ADD	HL,BC			;
		LD	[HL],E			;
		INC	L			;
		LD	[HL],D			;

		RET				;All Done.



; ***************************************************************************
; * UpdateClock ()                                                          *
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

UpdateClock::	LD	A,[wSubLevel]		;Don't update the clock
		CP	3			;in challenge mode.
		RET	NC			;

		LD	HL,hTgtClkHi		;
		LD	A,[HLD]			;
		OR	A			;
		JR	Z,.Skip0		;

		DEC	[HL]			;
		RET	NZ			;

		LD	A,TGT_CLKLO		;
		LD	[HLI],A			;
		DEC	[HL]			;
		RET				;

.Skip0:		LD	A,DELAY_EXIT		;
		LDH	[hTgtOver],A		;
		RET				;



; ***************************************************************************
; * UpdatePanel ()                                                          *
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

PNL_CHR_BLANK	EQU	1
PNL_CHR_HEART	EQU	2
PNL_CHR_TIME2	EQU	3
PNL_CHR_TIME1	EQU	4

UpdatePanel::	LD	HL,wTgtPnlBuf		;Reset the panel.
		LD	A,PNL_CHR_BLANK		;
		REPT	16			;
		LD	[HLI],A			;
		ENDR				;

		LDH	A,[hTgtLives]		;
		OR	A			;
		JR	Z,.Skip0		;
		DEC	A			;
		JR	Z,.Skip0		;
		LD	HL,wTgtPnlBuf+$0F	;
		LD	B,A			;
		LD	A,PNL_CHR_HEART		;
.Loop0:		LD	[HLD],A			;
		DEC	B			;
		JR	NZ,.Loop0		;

.Skip0:		LDH	A,[hTgtClkHi]		;
		OR	A			;
		JR	Z,.Skip2		;
		LD	HL,wTgtPnlBuf+$00	;
		LD	C,A			;
		SRL	A			;
		JR	Z,.Skip1		;
		LD	B,A			;
		LD	A,PNL_CHR_TIME2		;
.Loop1:		LD	[HLI],A			;
		DEC	B			;
		JR	NZ,.Loop1		;
.Skip1:		SRL	C			;
		JR	NC,.Skip2		;
		LD	[HL],PNL_CHR_TIME1	;

.Skip2:		RET				;



; ***************************************************************************
; * DrawTgtCursor ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      DE   = Ptr to OAM shadow buffer                             *
; *                                                                         *
; * Outputs     DE   = Updated                                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawTgtCursor::	LDH	A,[hTgtCurY]		;Calc the cursor coordinates
		ADD	A			;from its X and Y position.
		ADD	A			;
		LD	L,A			;
		LDH	A,[hTgtCurX]		;
		ADD	L			;
		ADD	A			;
		LD	HL,TblTgtCurPos		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	B,A			;
		LD	C,[HL]			;

		LD	HL,TblTgtCurOam		;Dump the sprite attributes
		CALL	.Skip1			;to the OAM shadow.
		CALL	.Skip1			;
		CALL	.Skip1			;
.Skip1:		LD	A,[HLI]			;
		ADD	C			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		ADD	B			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		RET				;


; ***************************************************************************
; * ResetTargets ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResetTargets::	LD	HL,wTgtSprite		;Clear the targets.
		LD	BC,$10*12		;
		CALL	MemClear		;

		LD	HL,wTgtSprite+TGT_SCX	;Setup the target positions.
		LD	DE,TblTgtPos		;
		LD	B,12			;

.Loop0:		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLD],A			;
		LD	A,L			;
		ADD	$10			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		DEC	B			;
		JR	NZ,.Loop0		;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	DE,IDX_DUST		;
		LD	A,$11			;
		LD	SP,wTgtStar		;
		CALL	.Init			;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		LD	DE,IDX_CLEFOUDK		;
		LD	A,$02			;
		JR	Z,.Skip1		;
		LD	DE,IDX_BLEFOU		;
		LD	A,$02			;
.Skip1:		LD	SP,wTgtLeFou0		;
		CALL	.Init			;

		LD	DE,IDX_CLEFOUNS		;
		LD	A,$03			;
		LD	SP,wTgtLeFou1		;
		CALL	.Init			;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.

.Init:		LDHL	SP,SPR_COLR+2		;
		LD	[HL],A			;
		LDHL	SP,SPR_ANM_1ST+2	;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;
		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],0			;
		RET				;



; ***************************************************************************
; * InitTgtChr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitTgtChr::	LD	HL,wTgtChrLst		;

		LD	A,L			;
		LDH	[hTgtChrGet],A		;

		LD	A,$F4			;
		LD	B,9			;
.Loop:		LD	[HLI],A			;
		SUB	A,$0C			;
		DEC	B			;
		JR	NZ,.Loop		;

		LD	A,L			;
		LDH	[hTgtChrPut],A		;

		RET				;All Done.



; ***************************************************************************
; * FreeTgtChr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FreeTgtChr::	LDH	A,[hTgtChrPut]		;
		LD	DE,wTgtChrLst
		LD	E,A			;
		LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		LD	[HL],0			;
		LD	[DE],A			;
		INC	E			;
		LD	A,E			;
		AND	wTgtChrMsk		;
		LD	DE,wTgtChrLst
		OR	E			;
		LDH	[hTgtChrPut],A		;

		RET				;



; ***************************************************************************
; * NextTgtChr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

NextTgtChr::	LD	DE,wTgtChrLst
		LDH	A,[hTgtChrGet]		;
		LD	E,A			;
		LDH	A,[hTgtChrPut]		;
		CP	E			;
		JR	Z,.Fail			;

		LD	A,[DE]			;
		LD	[HL],A			;
		XOR	A			;
		LD	[DE],A			;
		INC	E			;
		LD	A,E			;
		AND	wTgtChrMsk		;
		LD	DE,wTgtChrLst
		OR	E
		LDH	[hTgtChrGet],A		;

		RET				;

.Fail:		JR	.Fail			;



; ***************************************************************************
; * DumpTargetAll ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpTargetAll::	CALL	.Dump			;Process pending requests.

		CALL	InitTgtChr		;Reset free chr list.

		LD	BC,wTgtSprite+$00	;Go through all the targets
		LD	A,12			;forcing an update on all
.Loop:		PUSH	AF			;displayed targets.
		LD	HL,TGT_CHR		;
		ADD	HL,BC			;
		LD	[HL],0			;
		LD	HL,TGT_FLAGS		;
		ADD	HL,BC			;
		BIT	FLG_EXEC,[HL]		;
		JR	Z,.Next			;
		SET	FLG_NEW,[HL]		;
		CALL	NewTargetFrm		;
.Next:		LD	A,$10			;
		ADD	C			;
		LD	C,A			;
		LD	A,$00			;
		ADD	B			;
		LD	B,A			;
		POP	AF			;
		DEC	A			;
		JR	NZ,.Loop		;

		CALL	.Dump			;Process pending requests.

		CALL	DumpTgtSpr		;Update sprite graphics.
		CALL	DrawTgtSpr		;

		JP	WaitForVBL		;Synchronize to the VBL.

;
;
;

.Dump:		CALL	WaitForVBL		;Synchronize to the VBL.

.Wait:		CALL	DumpTargetGfx		;Update 3 targets a frame
		CALL	DumpTargetGfx		;at a maximum.
		CALL	DumpTargetGfx		;

		CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hTgtGfxPut]		;Get the screen gfx list ptr
		LD	L,A			;and abort if the list is
		LDH	A,[hTgtGfxGet]		;empty.
		CP	L			;
		JR	NZ,.Wait		;

		RET				;All Done.



; ***************************************************************************
; * DumpTargetGfx ()                                                        *
; ***************************************************************************
; * Process a single target graphics update request                         *
; ***************************************************************************
; * Inputs      Taken from the hTgtGfxLst ring buffer                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at DE doesn't wrap.                 *
; ***************************************************************************

DumpTargetGfx::	LDH	A,[hTgtGfxPut]		;Get the screen gfx list ptr
		LD	L,A			;and abort if the list is
		LDH	A,[hTgtGfxGet]		;empty.
		CP	L			;
		RET	Z			;

		LD	HL,wTgtGfxLst
		LD	C,L
		LD	L,A			;

		ADD	$04			;Update the list ptr.
		AND	wTgtGfxMsk		;
		OR	C			;
		LDH	[hTgtGfxGet],A		;

		LD	A,[HLI]			;Copy the target parameters
		LDH	[hTgtScx],A		;from the list.
		LD	A,[HLI]			;
		LDH	[hTgtScy],A		;
		LD	A,[HLI]			;
		LDH	[hTgtChr],A		;
		LD	A,[HLI]			;
		LDH	[hTgtFrm],A		;

		OR	A			;Blank frame ?
		JR	NZ,.Skip0		;

		LD	BC,wTmpMap+(TGT_W*TGT_H);
		JR	.Skip2			;

.Skip0:		LDH	A,[hTgtFrm]		;Locate the map for this
		LD	C,TGT_W*TGT_H*2		;frame.
		CALL	MultiplyBBW		;
		LD	BC,wTmpMap		;
		ADD	HL,BC			;

		LD	C,L			;Put the map ptr in BC.
		LD	B,H			;

		LDH	A,[hTgtChr]		;
		OR	A			;
		JR	Z,.Skip1		;

		LD	L,A			;Calc the destination chr
		LD	H,$08			;address ($8000-$8FF0).
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
;		BIT	3,H			;
;		JR	NZ,.Skip1		;
;		SET	4,H			;

.Skip1:		LD	E,L			;Dump the bitmap to vram.
		LD	D,H			;
		CALL	DumpTargetChr		;

.Skip2:		LDH	A,[hTgtScrPut]		;Get the output list ptr.
		LD	DE,wTgtScrLst
		LD	E,A			;

		LDH	A,[hTgtScy]		;Calc the destination scr
		SWAP	A			;address ($9800-$9BFF)
		RLCA				;and preserve it for later.
		LD	H,A			;
		AND	$E0			;
		LD	L,A			;
		LDH	A,[hTgtScx]		;
		AND	$1F			;
		OR	L			;
		LD	L,A			;
		LD	[DE],A			;
		INC	E			;
		LD	A,H			;
		AND	$03			;
		OR	$9800>>8		;
		LD	H,A			;
		LD	[DE],A			;
		INC	E			;

		LD	A,C			;Get frame's attribute ptr
		LD	[DE],A			;and preserve it for later.
		INC	E			;
		LD	A,B			;
		LD	[DE],A			;
		INC	E			;

		LDH	A,[hTgtChr]		;Get frame's destination chr
		LD	[DE],A			;and preserve it for later.

		LD	A,E			;Update the output list ptr.
		ADD	$04			;
		AND	wTgtScrMsk		;
		LD	DE,wTgtScrLst
		OR	E
		LDH	[hTgtScrPut],A		;

		RET				;All Done.



; ***************************************************************************
; * DumpTargetChr ()                                                        *
; ***************************************************************************
; * Dump a target's bitmap data to vram                                     *
; ***************************************************************************
; * Inputs      BC   = Ptr to frame's map data                              *
; *             DE   = Ptr to dst vram                                      *
; *                                                                         *
; * Outputs     BC   = Updated to point to frame's atr data                 *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpTargetChr::	REPT	TGT_H-1			;x   Dump a complete frame.
		CALL	DumpTargetRow		;x
		ENDR				;x

DumpTargetRow::	LDIO	A,[rLY]			;3   Don't start the transfer
		DEC	A			;1   too close to vblank.
		CP	144-12			;2
		JR	NC,DumpTargetRow	;3/2

		REPT	TGT_W			;x   Dump 1 row of 4x3 frame.

		LD	A,[BC]			;2   Read chr byte.
		INC	BC			;2

		LD	L,A			;1   Calc src character addr.
		LD	H,255&(wTmpChr>>12)	;2
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,HL			;2

		CALL	wChrXfer+7		;6   Copy the chr to vram.

		ENDR				;x

		RET				;



; ***************************************************************************
; * DumpTargetScr ()                                                        *
; ***************************************************************************
; * Dump a target's map info to vram                                        *
; ***************************************************************************
; * Inputs      Taken from the hTgtScrLst ring buffer                       *
; *             (DW scrptr, DW atrptr, DB chrnum)                           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL since it writes to the screen.    *
; ***************************************************************************

DumpTargetScr::	LDH	A,[hTgtScrPut]		;Get the screen map list ptr
		LD	E,A			;and abort if the list is
		LDH	A,[hTgtScrGet]		;empty.
		CP	E			;
		RET	Z			;

		LD	DE,wTgtScrLst
		LD	L,E
		LD	E,A			;

		ADD	$08			;Update the list ptr.
		AND	wTgtScrMsk		;

		OR	L			;
		LDH	[hTgtScrGet],A		;

		LD	A,[DE]			;Get dst scr address.
		INC	E			;
		LD	L,A			;
		LD	A,[DE]			;
		INC	E			;
		LD	H,A			;

		LD	A,[DE]			;Get src atr address.
		INC	E			;
		LD	C,A			;
		LD	A,[DE]			;
		INC	E			;
		LD	B,A			;

		LDH	A,[hMachine]		;Transfer attributes ?
		CP	MACHINE_CGB		;
		JR	NZ,DumpTargetMap	;

DumpTargetAtr::	PUSH	HL			;Preserve src and dst ptrs.
		PUSH	DE			;

		LD	A,1			;Page in hi video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LD	DE,32-TGT_W		;
		REPT	TGT_H			;
		REPT	TGT_W			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		ENDR				;
		ADD	HL,DE			;
		ENDR				;

		LD	A,0			;Page in lo video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		POP	DE			;Restore src and dst ptrs.
		POP	HL			;

DumpTargetMap::	LD	A,[DE]			;Get src chr number.
		INC	E			;

		OR	A			;
		JR	Z,DumpTargetClr		;

		LD	BC,32-TGT_W		;
		REPT	TGT_H			;
		REPT	TGT_W			;
		LD	[HLI],A			;
		INC	A			;
		ENDR				;
		ADD	HL,BC			;
		ENDR				;

		RET				;

DumpTargetClr::	LD	DE,wTmpMap		;

		LD	BC,32-TGT_W		;
		REPT	TGT_H			;
		REPT	TGT_W			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		ENDR				;
		ADD	HL,BC			;
		ENDR				;

;		LD	BC,32-TGT_W		;
;		REPT	TGT_H			;
;		REPT	TGT_W			;
;		LD	[HLI],A			;
;		ENDR				;
;		ADD	HL,BC			;
;		ENDR				;

		RET				;



; ***************************************************************************
; * DumpPanelScr ()                                                         *
; ***************************************************************************
; * Dump the status panel map info to vram                                  *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL since it writes to the screen.    *
; ***************************************************************************

DumpPanelScr::	LD	HL,wTgtPnlBuf		;
		LD	DE,$9800+(2*1)+(16*32)	;

		REPT	16			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		ENDR				;

		RET				;



; ***************************************************************************
; * ReadNullTarget ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to dst buffer                                    *
; *                                                                         *
; * Outputs     HL   = Updated                                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ReadNullTarget_B::
		LD	DE,$9800+(2*1)+(4*32)	;Copy MAP data to vram.
		CALL	GmbReadBG		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

.Skip0:		LD	DE,$9800+(2*1)+(4*32)	;Copy ATR data to vram.
		CALL	GmbReadBG		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;

		LD	A,0			;Page in MAP video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

.Skip1:		RET				;All Done.



; ***************************************************************************
; * GmbReadBG ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to   4x3x1 dst data                              *
; *             DE   = Ptr to 32x32x1 src vram                              *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at DE doesn't wrap.                 *
; ***************************************************************************

GmbReadBG::	LD	B,3			;Read 3 lines.

.Line:		PUSH	BC			;Preserve line count.

		LD	BC,$0301		;Dump 1 lots of 4 columns.

.Hold:		LDIO	A,[rLY]			;Don't start the transfer
		DEC	A			;during vblank.
		CP	140			;
		JR	NC,.Hold		;

		DI				;Disable interrupts.

.Sync:		LDIO	A,[rSTAT]		;Wait until the current
		AND	B			;HBL is finished.
		JR	Z,.Sync			;

.Wait:		LDIO	A,[rSTAT]		;Wait for the next HBL.
		AND	B			;
		JR	NZ,.Wait		;

		LD	A,[DE]			;Transfer 4 bytes of
		INC	E			;screen data.
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	E			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	E			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	E			;
		LD	[HLI],A			;

		EI				;Enable interrupts.

		DEC	C			;Do the next lot of columns.
		JR	NZ,.Hold		;

		LD	A,32-4			;Move the destination ptr
		ADD	E			;passed the border.
		LD	E,A			;
		JR	NC,.Skip		;
		INC	D			;

.Skip:		POP	BC			;Restore line count.

		DEC	B			;Do the next line.
		JR	NZ,.Line		;

		RET				;All Done.



; ***************************************************************************
; * ReorderTargets_B ()                                                     *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to src map                                       *
; *             DE   = Ptr to dst map                                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ReorderTargets_B::
		LD	BC,8			;Skip map header.
		ADD	HL,BC			;

		PUSH	HL			;Preserve src and dst ptrs.
		PUSH	DE			;

		CALL	TgtOrderAll		;Reorder lo-byte of map.

		POP	DE			;Restore src and dst ptrs.
		POP	HL			;

		INC	HL			;Move to next src half.

		LD	A,TGT_W*TGT_H		;Move to next dst half.
		ADD	E			;
		LD	E,A			;
		JR	NC,.Skip0		;
		INC	D			;

.Skip0:		JP	TgtOrderAll		;Reorder hi-byte of map.

TgtOrderAll::	LD	C,TGT_N			;Number of target animations.

.Loop:		PUSH	BC			;Reorder a single target's
		PUSH	HL			;set of animations.
		CALL	TgtOrderCol		;
		POP	HL			;
		LD	BC,2*TGT_W		;
		ADD	HL,BC			;
		POP	BC			;

		DEC	C			;Next target.
		JR	NZ,.Loop		;

		RET				;All Done.

TgtOrderCol::	LD	BC,2*TGT_W*(TGT_N-1)	;

		REPT	TGT_F-1			;Reorder n frames of a target
		CALL	TgtOrderFrm		;animation.
		ENDR				;

TgtOrderFrm::	REPT	TGT_H			;Reorder n rows of a 4x3
		CALL	TgtOrderRow		;target frame.
		ENDR				;

		LD	A,TGT_W*TGT_H		;Move to next dst frm.
		ADD	E			;
		LD	E,A			;
		RET	NC			;
		INC	D			;
		RET				;

TgtOrderRow::	REPT	TGT_W			;Reorder 1 row of 4x3 chr
		LD	A,[HLI]			;frame (8-bytes).
		INC	HL			;
		LD	[DE],A			;
		INC	DE			;
		ENDR				;

		ADD	HL,BC			;Move to next src row.

		RET				;



; ***************************************************************************
; * TheNoseSprite ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+4 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TheNoseSprite::	LDH	A,[hMachine]		;Only do this on a CGB.
		CP	MACHINE_CGB		;
		RET	NZ

		LDHL	SP,SPR_FLAGS+4+48	;Initialize LeFou1 nose.
		LD	[HL],MSK_DRAW+MSK_PLOT	;

		LDHL	SP,SPR_SCR_X+4		;Copy LeFou0's position.
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		LDHL	SP,SPR_SCR_X+4+48	;
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLIP+4		;Copy LeFou0's flip.
		LD	A,[HLI]			;
		LDHL	SP,SPR_FLIP+4+48	;
		LD	[HLI],A			;

		LDHL	SP,SPR_FRAME+4		;Copy LeFou0's frame
		LD	A,[HLI]			;(compensating for a the
		LD	C,A			;offset to the nose frames).
		LD	A,[HLI]			;
		LD	B,A			;
		OR	C			;
		JR	Z,.Skip0		;
		LD	HL,IDX_CLEFOUNS-IDX_CLEFOUDK
		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;
.Skip0:		LDHL	SP,SPR_FRAME+4+48	;
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * DoTgtXxxx ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

;
;
;

DoTgtTaunt::	LD	DE,TgtAnmTaunt		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		CALL	TheNoseSprite		;Does he have a nose ?

		LD	DE,DoTauntWait		;
		CALL	SetSpriteFnc		;

		RET				;

DoTauntWait::	CALL	IncSpriteAnm		;Update animation.

		CALL	TheNoseSprite		;Does he have a nose ?

DoTauntExit::	LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		LD	[HL],0			;Disable this target.

		LD	HL,hTgtCount		;Decrement target count.
		DEC	[HL]			;

		RET				;All Done.

;
;
;

DoTgtApple::	LD	DE,TgtAnmAplIn		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		CALL	TheNoseSprite		;Does he have a nose ?

		LD	DE,DoAplInWait		;
		CALL	SetSpriteFnc		;

		RET				;

DoAplInWait::	CALL	IncSpriteAnm		;Update animation.

		CALL	TheNoseSprite		;Does he have a nose ?

		LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		SET	FLG_CHK,[HL]		;Enable shot detection.

		LD	DE,DoAplInPosn		;
		CALL	SetSpriteFnc		;

		RET				;

DoAplInPosn::	LDHL	SP,SPR_FLAGS+2		;Has the apple been hit ?
		BIT	FLG_HIT,[HL]		;
		JR	NZ,DoAplHit		;

		LDHL	SP,SPR_DELAY+2		;Wait for the popup delay
		LD	A,[HL]			;to end.
		OR	A			;
		JR	Z,DoAplOut		;
		DEC	[HL]			;
		RET				;

DoAplHit::	LD	DE,TgtAnmAplHit		;Set the exit animation.
		JR	DoAplOutAnm		;

DoAplOut::	LD	DE,TgtAnmAplOut		;Set the exit animation.

DoAplOutAnm::	CALL	SetSpriteAnm		;animation.

		LDHL	SP,SPR_FLAGS+2		;Disable shot detection.
		RES	FLG_CHK,[HL]		;

		CALL	TheNoseSprite		;Does he have a nose ?

		LD	DE,DoAplOutWait		;
		CALL	SetSpriteFnc		;

		RET				;

DoAplOutWait::	CALL	IncSpriteAnm		;Update animation.

		CALL	TheNoseSprite		;Does he have a nose ?

		LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		LD	[HL],0			;Disable this target.

		LD	HL,hTgtCount		;Decrement target count.
		DEC	[HL]			;

		RET				;All Done.

;
;
;

DoTgtStar::	LD	DE,TgtAnmStar		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		LD	DE,DoTgtStarMove	;
		CALL	SetSpriteFnc		;

		PUSH	BC			;
		LD	A,SONG_GOTSTAR		;
		CALL	InitTune		;
		POP	BC			;

		RET				;

DoTgtStarMove::	LDH	A,[hCycleCount]
		RRCA
		JR	C,.Skip0

		LDHL	SP,SPR_SCR_Y+2		;Move it up.
		DEC	[HL]			;

.Skip0:		CALL	IncSpriteAnm		;Update animation.

		LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		LD	[HL],0			;Disable this target.

		RET				;All Done.



; ***************************************************************************
; * TargetInput ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TargetInput::	LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	BIT	JOY_START,C		;
		JR	Z,.TestR		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestR:		BIT	JOY_R,C			;
		JR	Z,.TestL		;

		LDH	A,[hTgtCurX]		;
		INC	A			;
		CP	4			;
		JR	C,.SkipR		;
;		XOR	A			;
		LD	A,3			;
.SkipR:		LDH	[hTgtCurX],A		;

.TestL:		BIT	JOY_L,C			;
		JR	Z,.TestU		;

		LDH	A,[hTgtCurX]		;
		SUB	1			;
		JR	NC,.SkipL		;
;		LD	A,3			;
		XOR	A			;
.SkipL:		LDH	[hTgtCurX],A		;

.TestU:		BIT	JOY_U,C			;
		JR	Z,.TestD		;

		LDH	A,[hTgtCurY]		;
		SUB	1			;
		JR	NC,.SkipU		;
;		LD	A,2			;
		XOR	A			;
.SkipU:		LDH	[hTgtCurY],A		;

.TestD:		BIT	JOY_D,C			;
		JR	Z,.TestShoot		;

		LDH	A,[hTgtCurY]		;
		INC	A			;
		CP	3			;
		JR	C,.SkipD		;
;		XOR	A			;
		LD	A,2			;
.SkipD:		LDH	[hTgtCurY],A		;

.TestShoot:	AND	MSK_JOY_A|MSK_JOY_B	;Shoot ?
		RET	Z			;

		LD	HL,hTgtShots		;Increment shot count.
		INC	[HL]			;
		JR	NZ,TargetChkSpr		;
		DEC	[HL]			;

TargetChkSpr::	LDH	A,[hTgtCurY]		;Is the cursor on the bottom
		CP	2			;row ?
		JR	NZ,TargetChkTgt		;

		LD	BC,wTgtLeFou0		;Locate LeFou sprite.

		LD	HL,SPR_FLAGS		;Is his collision enabled ?
		ADD	HL,BC			;
		BIT	FLG_CHK,[HL]		;
		JR	Z,TargetChkTgt		;

		LD	HL,SPR_SCR_X		;Convert his X coordinate
		ADD	HL,BC			;into a 0..3 position.
		LD	A,[HL]			;
		SUB	LEFOU_X			;
		SRL	A			;
		SWAP	A			;

		LD	HL,hTgtCurX		;And see if that is where
		CP	[HL]			;the cursor is.
		JR	Z,TargetHitSpr		;

TargetChkTgt::	LDH	A,[hTgtCurY]		;Which target have we shot ?
		ADD	A			;
		ADD	A			;
		LD	C,A			;
		LDH	A,[hTgtCurX]		;
		ADD	C			;

		LD	BC,wTgtSprite		;Locate target's sprite
		SWAP	A			;structure.
		ADD	C			;
		LD	C,A			;

		LD	HL,TGT_FLAGS		;Is there a target at this
		ADD	HL,BC			;location ?
		BIT	FLG_EXEC,[HL]		;
		JR	Z,TargetMiss		;

		BIT	FLG_CHK,[HL]		;Hit detection enabled ?
		JR	Z,TargetMiss		;

TargetHitTgt::	RES	FLG_CHK,[HL]		;Disable future detection.

		SET	FLG_HIT,[HL]		;Signal that it was hit.

		LD	DE,TgtAnmHit		;Play the hit animation.
		CALL	SetTargetAnm		;

		LD	HL,TGT_TYPE		;Execute the action code
		ADD	HL,BC			;for hitting this target.
		LD	A,[HL]			;
		ADD	A			;
		LD	HL,TblTgtHitFnc		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	IndirectHL		;

		LD	HL,hTgtHits		;Increment hit count.
		INC	[HL]			;

		RET				;

TargetMiss::	LD	HL,hTgtMiss		;Increment miss count.
		INC	[HL]			;

		LD	A,FX_SHOT_MISS		;
		JP	InitSfx			;

TargetHitSpr::	LD	HL,SPR_FLAGS		;Signal the target that it
		ADD	HL,BC			;has been hit.
		RES	FLG_CHK,[HL]		;
		SET	FLG_HIT,[HL]		;

		LD	HL,SPR_SCR_X		;Read target's position.
		ADD	HL,BC			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	HL,wTgtStar+SPR_SCR_X	;Add offset and save as the
		LD	A,C			;star's position.
		ADD	$01			;
		LD	[HLI],A			;
		LD	A,B			;
		ADC	$00			;
		LD	[HLI],A			;
		LD	A,E			;
		SUB	$22			;
		LD	[HLI],A			;
		LD	A,D			;
		SBC	$00			;
		LD	[HLI],A			;

		LD	HL,wTgtStar+SPR_EXEC	;Set target type's function.
		LD	DE,DoTgtStar		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	HL,wTgtStar+SPR_FLAGS	;
		LD	[HL],MSK_EXEC+MSK_DRAW+MSK_PLOT

		XOR	A			;

		LD	HL,wTgtStar+SPR_FRAME	;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LD	HL,wTgtStar+SPR_FLIP	;
		LD	[HLI],A			;

		LD	HL,wTgtStar+SPR_OAM_CNT	;
		LD	[HLI],A			;

		LD	HL,hTgtHits		;Increment hit count.
		INC	[HL]			;

		LD	HL,wSubStars		;Increment star count.
		INC	[HL]			;

		LD	A,FX_SHOT_GOOD		;
		JP	InitSfx			;



; ***************************************************************************
; * TgtHitNull ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

TgtHitNull::	RET				;All Done.

TgtHitClock::	LDH	A,[hTgtClkHi]		;
		ADD	TGT_HIT_CLOCK		;
		CP	A,TGT_CLKHI		;
		JR	C,.Skip0		;
		LD	A,TGT_CLKHI		;
.Skip0:		LDH	[hTgtClkHi],A		;
		LD	A,FX_SHOT_GOOD		;
		JP	InitSfx			;

TgtHitBomb::	LDH	A,[hTgtLives]		;
		SUB	TGT_HIT_BOMB		;
		JR	NC,.Skip0		;
		XOR	A			;
.Skip0:		LDH	[hTgtLives],A		;
		OR	A			;
		JR	NZ,.Skip1		;
		LD	A,DELAY_EXIT		;
		LDH	[hTgtOver],A		;
.Skip1:		LD	A,FX_SHOT_BAD		;
		JP	InitSfx			;

TgtHitHeart::	LDH	A,[hTgtLives]		;
		ADD	TGT_HIT_HEART		;
		CP	A,TGT_LIVES		;
		JR	C,.Skip0		;
		LD	A,TGT_LIVES		;
.Skip0:		LDH	[hTgtLives],A		;
		LD	A,FX_SHOT_GOOD		;
		JP	InitSfx			;

TgtHitThing::	LD	HL,TGT_TYPE		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		LD	HL,TblTgtBad		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LDH	A,[hTgtStgMsk]		;
		AND	[HL]			;
		JR	NZ,TgtHitBomb		;

		LD	A,[wSubLevel]		;If in challenge mode, inc
		CP	3			;the number of targets hit.
		CALL	NC,IncScore		;

		LD	A,FX_SHOT_GOOD		;
		JP	InitSfx			;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  TARGET DATA
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;
; Overall Stages.
;

TgtStages::	DW	TgtEasyStg1		;Easy Stage 0
		DW	TgtEasyStg2		;Easy Stage 1
		DW	TgtEasyStg3		;Easy Stage 2
		DW	TgtEasyStg3		;Easy -
		DW	TgtNormStg1		;Norm Stage 0
		DW	TgtNormStg2		;Norm Stage 1
		DW	TgtNormStg3		;Norm Stage 2
		DW	TgtNormStg3		;Norm -
		DW	TgtHardStg1		;Hard Stage 0
		DW	TgtHardStg2		;Hard Stage 1
		DW	TgtHardStg3		;Hard Stage 2
		DW	TgtHardStg3		;Hard -

		DW	TgtChallenge		;Challenge Easy Stage 0
		DW	TgtChallenge		;Challenge Easy Stage 1
		DW	TgtChallenge		;Challenge Easy Stage 2
		DW	TgtChallenge		;Challenge Easy -
		DW	TgtChallenge		;Challenge Hard Stage 0
		DW	TgtChallenge		;Challenge Hard Stage 1
		DW	TgtChallenge		;Challenge Hard Stage 2
		DW	TgtChallenge		;Challenge Hard -

;
;
;

TgtChallenge::	DB	255,255			;Scale Show/Wait
		DW	TgtGroupD		;Group
		DB	0			;End

;
; Difficulty Level 1 - Easy
;

TgtEasyStg1::	DB	235,235			;Scale Show/Wait
		DW	TgtGroupA		;Group

		DB	235,235			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	235,235			;Scale Show/Wait
		DW	TgtGroupT1		;Group

		DB	230,230			;Scale Show/Wait
		DW	TgtGroupA

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtEasyStg2::	DB	225,225			;Scale Show/Wait
		DW	TgtGroupB		;Group

		DB	225,225			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	225,225			;Scale Show/Wait
		DW	TgtGroupT2		;Group

		DB	220,220			;Scale Show/Wait
		DW	TgtGroupB

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtEasyStg3::	DB	215,215			;Scale Show/Wait
		DW	TgtGroupC		;Group

		DB	215,215			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	215,215			;Scale Show/Wait
		DW	TgtGroupT3		;Group

		DB	210,210			;Scale Show/Wait
		DW	TgtGroupC

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

;
; Difficulty Level 2 - Normal
;

TgtNormStg1::	DB	195,195			;Scale Show/Wait
		DW	TgtGroupA		;Group

		DB	195,195			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	195,195			;Scale Show/Wait
		DW	TgtGroupT1		;Group

		DB	190,190			;Scale Show/Wait
		DW	TgtGroupA		;Group

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtNormStg2::	DB	185,185			;Scale Show/Wait
		DW	TgtGroupB		;Group

		DB	185,185			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	180,180			;Scale Show/Wait
		DW	TgtGroupB		;Group

		DB	180,180			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	180,180			;Scale Show/Wait
		DW	TgtGroupT2		;Group

		DB	180,180			;Scale Show/Wait
		DW	TgtGroupB

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtNormStg3::	DB	175,175			;Scale Show/Wait
		DW	TgtGroupC		;Group

		DB	175,175			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	170,170			;Scale Show/Wait
		DW	TgtGroupC		;Group

		DB	170,170			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	165,165			;Scale Show/Wait
		DW	TgtGroupC

		DB	165,165			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	165,165			;Scale Show/Wait
		DW	TgtGroupT3		;Group

		DB	160,160			;Scale Show/Wait
		DW	TgtGroupC

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

;
; Difficulty Level 1 - Hard
;

TgtHardStg1::	DB	155,155			;Scale Show/Wait
		DW	TgtGroupA		;Group

		DB	155,155			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	150,150			;Scale Show/Wait
		DW	TgtGroupA

		DB	150,150			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	150,150			;Scale Show/Wait
		DW	TgtGroupT1		;Group

		DB	135,135			;Scale Show/Wait
		DW	TgtGroupA

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtHardStg2::	DB	150,150			;Scale Show/Wait
		DW	TgtGroupB		;Group

		DB	150,150			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	145,145			;Scale Show/Wait
		DW	TgtGroupB

		DB	145,145			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	140,140			;Scale Show/Wait
		DW	TgtGroupB

		DB	140,140			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	140,140			;Scale Show/Wait
		DW	TgtGroupT2		;Group

		DB	135,135			;Scale Show/Wait
		DW	TgtGroupB

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

TgtHardStg3::	DB	140,140			;Scale Show/Wait
		DW	TgtGroupC		;Group

		DB	140,140			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	135,135			;Scale Show/Wait
		DW	TgtGroupC

		DB	135,135			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	130,130			;Scale Show/Wait
		DW	TgtGroupC

		DB	130,130			;Scale Show/Wait
		DW	TgtGroupCLK		;Group

		DB	125,125			;Scale Show/Wait
		DW	TgtGroupC

		DB	125,125			;Scale Show/Wait
		DW	TgtGroupCLK		;Group
		DB	125,125			;Scale Show/Wait
		DW	TgtGroupT3		;Group

		DB	120,120			;Scale Show/Wait
		DW	TgtGroupC

		DB	255,255			;Scale Show/Wait
		DW	TgtGroupExit		;Finish
		DB	0			;End

;
; Groups of patterns (1 pattern selected randomly each time used).
;

TgtGroup0::	DB	12
	 	DW	TgtPattern0		;0
	 	DW	TgtPattern1		;1
	 	DW	TgtPattern2		;2
	 	DW	TgtPattern3		;3
	 	DW	TgtPattern4		;4
	 	DW	TgtPattern5		;5
	 	DW	TgtPattern6		;6
	 	DW	TgtPattern7		;7
		DW	TgtPattern8		;8
	 	DW	TgtPattern9		;9
	 	DW	TgtPattern10		;10
	 	DW	TgtPattern11		;11

TgtGroup1::	DB	10
	 	DW	TgtPattern12		;12
		DW	TgtPattern13		;13
		DW	TgtPattern14		;14
		DW	TgtPattern15		;15
	 	DW	TgtPattern16		;16
	 	DW	TgtPattern17		;17
	 	DW	TgtPattern18		;18
	 	DW	TgtPattern19		;19
	 	DW	TgtPattern20		;20
	 	DW	TgtPattern21		;21

TgtGroup2::	DB	6
	 	DW	TgtPattern44		;44
		DW	TgtPattern45		;45
		DW	TgtPattern46		;46
		DW	TgtPattern47		;47
		DW	TgtPattern48		;48
		DW	TgtPattern49		;49

TgtGroup3::	DB	4
	 	DW	TgtPattern22		;22
		DW	TgtPattern23		;23
		DW	TgtPattern24		;24
		DW	TgtPattern25		;25

TgtGroup4::	DB	6
	 	DW	TgtPattern26		;26
		DW	TgtPattern27		;27
		DW	TgtPattern28		;28
		DW	TgtPattern29		;29
		DW	TgtPattern30		;30
		DW	TgtPattern31		;31

TgtGroup5::	DB	4
	 	DW	TgtPattern32		;32
		DW	TgtPattern33		;33
		DW	TgtPattern34		;34
		DW	TgtPattern35		;35

TgtGroup6B::	DB	4
		DW	TgtPattern40		;40
		DW	TgtPattern41		;41
		DW	TgtPattern42		;42
		DW	TgtPattern43		;43

TgtGroup6A::	DB	4
	 	DW	TgtPattern36		;36
		DW	TgtPattern37		;37
		DW	TgtPattern38		;38
		DW	TgtPattern39		;39


TgtGroupD::	DB	44
	 	DW	TgtPattern0		;0
	 	DW	TgtPattern1		;1
	 	DW	TgtPattern2		;2
	 	DW	TgtPattern3		;3
	 	DW	TgtPattern4		;4
	 	DW	TgtPattern5		;5
	 	DW	TgtPattern6		;6
	 	DW	TgtPattern7		;7
		DW	TgtPattern8		;8
	 	DW	TgtPattern9		;9
	 	DW	TgtPattern10		;10
	 	DW	TgtPattern11		;11
		DW	TgtPattern12		;12
		DW	TgtPattern13		;13
	       	DW	TgtPattern16		;16
	 	DW	TgtPattern17		;17
	 	DW	TgtPattern18		;18
	 	DW	TgtPattern19		;19
	 	DW	TgtPattern20		;20
	 	DW	TgtPattern21		;21
		DW	TgtPattern22		;22
		DW	TgtPattern23		;23
		DW	TgtPattern24		;24
		DW	TgtPattern25		;25
	 	DW	TgtPattern26		;26
		DW	TgtPattern27		;27
		DW	TgtPattern28		;28
		DW	TgtPattern29		;29
		DW	TgtPattern30		;30
		DW	TgtPattern31		;31
		DW	TgtPattern36		;36
		DW	TgtPattern37		;37
		DW	TgtPattern38		;38
		DW	TgtPattern39		;39
		DW	TgtPattern40		;40
		DW	TgtPattern41		;41
		DW	TgtPattern42		;42
		DW	TgtPattern43		;43
		DW	TgtPattern44		;44
		DW	TgtPattern45		;45
		DW	TgtPattern46		;46
		DW	TgtPattern47		;47
		DW	TgtPattern48		;48
		DW	TgtPattern49		;49

TgtGroupA::	DB	26
	 	DW	TgtPattern0		;0
	 	DW	TgtPattern1		;1
	 	DW	TgtPattern2		;2
	 	DW	TgtPattern3		;3
	 	DW	TgtPattern4		;4
	 	DW	TgtPattern5		;5
	 	DW	TgtPattern6		;6
	 	DW	TgtPattern7		;7
		DW	TgtPattern8		;8
	 	DW	TgtPattern9		;9
	 	DW	TgtPattern10		;10
	 	DW	TgtPattern11		;11
		DW	TgtPattern12		;12
		DW	TgtPattern13		;13
	       	DW	TgtPattern16		;16
	 	DW	TgtPattern17		;17
	 	DW	TgtPattern18		;18
	 	DW	TgtPattern19		;19
	 	DW	TgtPattern20		;20
	 	DW	TgtPattern21		;21
	       	DW	TgtPattern44		;44
		DW	TgtPattern45		;45
		DW	TgtPattern46		;46
		DW	TgtPattern47		;47
		DW	TgtPattern48		;48
		DW	TgtPattern49		;49

TgtGroupB::	DB	16
		DW	TgtPattern22		;22
		DW	TgtPattern23		;23
		DW	TgtPattern24		;24
		DW	TgtPattern25		;25
	 	DW	TgtPattern26		;26
		DW	TgtPattern27		;27
		DW	TgtPattern28		;28
		DW	TgtPattern29		;29
		DW	TgtPattern30		;30
		DW	TgtPattern31		;31
		DW	TgtPattern44		;44
		DW	TgtPattern45		;45
		DW	TgtPattern46		;46
		DW	TgtPattern47		;47
		DW	TgtPattern48		;48
		DW	TgtPattern49		;49

TgtGroupC::	DB	18
		DW	TgtPattern22		;22
		DW	TgtPattern23		;23
		DW	TgtPattern24		;24
		DW	TgtPattern25		;25
		DW	TgtPattern26		;26
		DW	TgtPattern27		;27
		DW	TgtPattern28		;28
		DW	TgtPattern29		;29
		DW	TgtPattern30		;30
		DW	TgtPattern31		;31
		DW	TgtPattern36		;36
		DW	TgtPattern37		;37
		DW	TgtPattern38		;38
		DW	TgtPattern39		;39
		DW	TgtPattern40		;40
		DW	TgtPattern41		;41
		DW	TgtPattern42		;42
		DW	TgtPattern43		;43

TgtGroupCLK::	DB	12
	 	DW	TgtPattern50		;50
		DW	TgtPattern51		;50
		DW	TgtPattern52		;50
		DW	TgtPattern53		;50
		DW	TgtPattern54		;50
		DW	TgtPattern55		;50
		DW	TgtPattern56		;50
		DW	TgtPattern57		;50
		DW	TgtPattern58		;50
		DW	TgtPattern59		;50
		DW	TgtPattern60		;50
		DW	TgtPattern61		;50

TgtGroupT1::	DB	16
	 	DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62
		DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62
		DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62

		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62

TgtGroupT2::	DB	16
	 	DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62
		DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62

		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62
		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62

TgtGroupT3::	DB	16
	 	DW	TgtPattern62		;62
	       	DW	TgtPattern63		;62
	       	DW	TgtPattern64		;62
	       	DW	TgtPattern65		;62

		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62
		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62
		DW	TgtPattern66		;62
	       	DW	TgtPattern67		;62
	       	DW	TgtPattern68		;62
	       	DW	TgtPattern69		;62

TgtGroupExit::	DB	1
		DW	TblTgtExit		;0

TblTgtExit::	DB	60			;Wait
		DB	-1			;End

;
; Target patterns.
;

TgtPattern0::	DB	60			;Wait
		DB	TGT_POS00,TGT_GOOD,65	;Posn,Type,Show
		DB	58			;Wait
		DB	TGT_POS01,TGT_GOOD,63	;Posn,Type,Show
		DB	56			;Wait
		DB	TGT_POS02,TGT_GOOD,61	;Posn,Type,Show
		DB	54			;Wait
		DB	TGT_POS03,TGT_RND1,59	;Posn,Type,Show

		DB	53 			;Wait
		DB	TGT_POS07,TGT_GOOD,57	;Posn,Type,Show
		DB	52			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS05,TGT_GOOD,53	;Posn,Type,Show
		DB	48			;Wait
		DB	TGT_POS04,TGT_RNDH,51	;Posn,Type,Show


		DB	-1			;End

TgtPattern1::	DB	60 			;Wait
		DB	TGT_POS11,TGT_GOOD,65	;Posn,Type,Show
		DB	48			;Wait
		DB	TGT_POS10,TGT_GOOD,63	;Posn,Type,Show
		DB	46			;Wait
		DB	TGT_POS09,TGT_GOOD,61	;Posn,Type,Show
		DB	44			;Wait
		DB	TGT_POS08,TGT_RND0,59	;Posn,Type,Show

		DB	43 			;Wait
		DB	TGT_POS04,TGT_GOOD,57	;Posn,Type,Show
		DB	42			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS06,TGT_GOOD,53	;Posn,Type,Show
		DB	38			;Wait
		DB	TGT_POS07,TGT_RND1,51	;Posn,Type,Show

		DB	-1			;End

TgtPattern2::	DB	60			;Wait
		DB	TGT_POS03,TGT_GOOD,65	;Posn,Type,Show
		DB	48			;Wait
		DB	TGT_POS02,TGT_GOOD,63	;Posn,Type,Show
		DB	46			;Wait
		DB	TGT_POS01,TGT_GOOD,61	;Posn,Type,Show
		DB	44			;Wait
		DB	TGT_POS00,TGT_RND1,59	;Posn,Type,Show

		DB	43 			;Wait
		DB	TGT_POS04,TGT_GOOD,57	;Posn,Type,Show
		DB	42			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS06,TGT_GOOD,53	;Posn,Type,Show
		DB	38			;Wait
		DB	TGT_POS07,TGT_RND0,51	;Posn,Type,Show


		DB	-1			;End

TgtPattern3::	DB	60 			;Wait
		DB	TGT_POS08,TGT_GOOD,65	;Posn,Type,Show
		DB	48			;Wait
		DB	TGT_POS09,TGT_GOOD,63	;Posn,Type,Show
		DB	46			;Wait
		DB	TGT_POS10,TGT_GOOD,61	;Posn,Type,Show
		DB	44			;Wait
		DB	TGT_POS11,TGT_RND0,59	;Posn,Type,Show

		DB	43 			;Wait
		DB	TGT_POS07,TGT_GOOD,57	;Posn,Type,Show
		DB	42			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS05,TGT_GOOD,53	;Posn,Type,Show
		DB	38			;Wait
		DB	TGT_POS04,TGT_RND1,51	;Posn,Type,Show

		DB	-1			;End

TgtPattern4::	DB	70			;Wait
	    	DB	TGT_POS00,TGT_GOOD,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS04,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS08,TGT_RNDH,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS09,TGT_GOOD,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS01,TGT_RND0,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern5::	DB	70 			;Wait
		DB	TGT_POS11,TGT_GOOD,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS07,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS03,TGT_RND1,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS02,TGT_GOOD,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS10,TGT_RND0,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern6::	DB	70			;Wait
		DB	TGT_POS08,TGT_RND1,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS04,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS00,TGT_RND0,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS01,TGT_GOOD,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS09,TGT_RND0,53	;Posn,Type,Show


		DB	-1			;End

TgtPattern7::	DB	70 			;Wait
		DB	TGT_POS03,TGT_RND0,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS07,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS11,TGT_RND0,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS10,TGT_RND1,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS02,TGT_RND0,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern8::	DB	70			;Wait
		DB	TGT_POS01,TGT_RNDH,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS05,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS09,TGT_RND0,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS10,TGT_RND1,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS02,TGT_GOOD,53	;Posn,Type,Show


		DB	-1			;End

TgtPattern9::	DB	70 			;Wait
		DB	TGT_POS02,TGT_RND1,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS06,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS10,TGT_GOOD,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS09,TGT_RND0,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS01,TGT_GOOD,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern10::	DB	70			;Wait
		DB	TGT_POS10,TGT_RND0,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS06,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS02,TGT_RND1,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS01,TGT_RND0,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS05,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS09,TGT_RND1,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern11::	DB	70 			;Wait
		DB	TGT_POS09,TGT_GOOD,65	;Posn,Type,Show
		DB	68			;Wait
		DB	TGT_POS05,TGT_GOOD,63	;Posn,Type,Show
		DB	66			;Wait
		DB	TGT_POS01,TGT_RND0,61	;Posn,Type,Show

		DB	63 			;Wait
		DB	TGT_POS02,TGT_GOOD,57	;Posn,Type,Show
		DB	62			;Wait
		DB	TGT_POS06,TGT_GOOD,55	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS10,TGT_RND1,53	;Posn,Type,Show

		DB	-1			;End

TgtPattern12::	DB	60			;Wait
		DB	TGT_POS00,TGT_GOOD,80	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS02,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_RND0,75	;Posn,Type,Show

		DB	70 			;Wait
		DB	TGT_POS07,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS06,TGT_GOOD,70	;Posn,Type,Show
		DB	65			;Wait
		DB	TGT_POS05,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_RNDH,65	;Posn,Type,Show

		DB	60 			;Wait
		DB	TGT_POS08,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS10,TGT_GOOD,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_RND1,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern13::	DB	60 			;Wait
		DB	TGT_POS11,TGT_GOOD,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS10,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS09,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS08,TGT_RND0,75	;Posn,Type,Show

		DB	70 			;Wait
		DB	TGT_POS04,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,70	;Posn,Type,Show
		DB	65			;Wait
		DB	TGT_POS06,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_RND1,65	;Posn,Type,Show

		DB	60			;Wait
		DB	TGT_POS03,TGT_GOOD,60	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS02,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS01,TGT_GOOD,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS00,TGT_RND0,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern14::	DB	60			;Wait
		DB	-1			;End

TgtPattern15::	DB	60 			;Wait
		DB	-1			;End

TgtPattern16::	DB	60			;Wait
		DB	TGT_POS03,TGT_GOOD,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS02,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS01,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS00,TGT_RND1,75	;Posn,Type,Show

		DB	70 			;Wait
		DB	TGT_POS04,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,70	;Posn,Type,Show
		DB	65			;Wait
		DB	TGT_POS06,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_RNDH,65	;Posn,Type,Show

		DB	60 			;Wait
		DB	TGT_POS11,TGT_GOOD,60	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS10,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS09,TGT_GOOD,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS08,TGT_RND0,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern17::	DB	60 			;Wait
		DB	TGT_POS08,TGT_GOOD,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS10,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_RND1,75	;Posn,Type,Show

		DB	70 			;Wait
		DB	TGT_POS07,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS06,TGT_GOOD,70	;Posn,Type,Show
		DB	65			;Wait
		DB	TGT_POS05,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_RND0,65	;Posn,Type,Show

		DB	60			;Wait
		DB	TGT_POS00,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS02,TGT_GOOD,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_RND0,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern18::	DB	60			;Wait
		DB	TGT_POS00,TGT_GOOD,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS01,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS04,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,75	;Posn,Type,Show
		DB	70 			;Wait
		DB	TGT_POS08,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_RND0,70	;Posn,Type,Show

		DB	65			;Wait
		DB	TGT_POS10,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_GOOD,65	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS06,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS02,TGT_GOOD,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_RND1,55	;Posn,Type,Show


		DB	-1			;End

TgtPattern19::	DB	60 			;Wait
		DB	TGT_POS10,TGT_GOOD,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS11,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	70 			;Wait
		DB	TGT_POS02,TGT_RND0,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_RND1,70	;Posn,Type,Show

		DB	65			;Wait
		DB	TGT_POS00,TGT_GOOD,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,65	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS04,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS08,TGT_RND0,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_RND0,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern20::	DB	60			;Wait
		DB	TGT_POS08,TGT_RND0,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS04,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,75	;Posn,Type,Show
		DB	70 			;Wait
		DB	TGT_POS00,TGT_GOOD,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_RNDH,70	;Posn,Type,Show

		DB	65			;Wait
		DB	TGT_POS02,TGT_RND0,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_GOOD,65	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS06,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS10,TGT_RND0,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_RND1,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern21::	DB	60 			;Wait
		DB	TGT_POS02,TGT_RND0,80	;Posn,Type,Show
		DB	0			;Wait
		DB	TGT_POS03,TGT_GOOD,80	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	70 			;Wait
		DB	TGT_POS10,TGT_RND0,70	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_RND1,70	;Posn,Type,Show

		DB	65			;Wait
		DB	TGT_POS08,TGT_RND0,65	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,65	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS04,TGT_GOOD,60	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_GOOD,60	;Posn,Type,Show
		DB	55			;Wait
		DB	TGT_POS00,TGT_RND0,55	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_RND1,55	;Posn,Type,Show

		DB	-1			;End

TgtPattern22::	DB	60			;Wait
		DB	TGT_POS00,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS01,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS05,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS04,TGT_RND0,100	;Posn,Type,Show

		DB	105 			;Wait
		DB	TGT_POS06,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS10,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS09,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS05,TGT_RND0,90	;Posn,Type,Show

		DB	95 			;Wait
		DB	TGT_POS07,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS03,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS02,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS06,TGT_RND1,80	;Posn,Type,Show

		DB	-1			;End

TgtPattern23::	DB	60 			;Wait
		DB	TGT_POS03,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS02,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS06,TGT_RND0,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS07,TGT_RND0,100	;Posn,Type,Show

		DB	105 			;Wait
		DB	TGT_POS05,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS09,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS10,TGT_RND0,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS06,TGT_RND1,90	;Posn,Type,Show

		DB	95 			;Wait
		DB	TGT_POS04,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS00,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS01,TGT_RND0,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS05,TGT_RND0,80	;Posn,Type,Show

		DB	-1			;End

TgtPattern24::	DB	60			;Wait
		DB	TGT_POS05,TGT_RND0,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS09,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS08,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS04,TGT_RND1,100	;Posn,Type,Show

		DB	105			;Wait
		DB	TGT_POS06,TGT_RND0,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS02,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS01,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS05,TGT_GOOD,90	;Posn,Type,Show

		DB	95 			;Wait
		DB	TGT_POS07,TGT_RND0,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS11,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS10,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS06,TGT_RNDH,80	;Posn,Type,Show

		DB	-1			;End

TgtPattern25::	DB	60 			;Wait
		DB	TGT_POS06,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS10,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS11,TGT_GOOD,100	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS07,TGT_RND1,100	;Posn,Type,Show

		DB	105 			;Wait
		DB	TGT_POS05,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS01,TGT_GOOD,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS02,TGT_RND0,90	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS06,TGT_GOOD,90	;Posn,Type,Show

		DB	95 			;Wait
		DB	TGT_POS04,TGT_RND0,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS08,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	20			;Wait
		DB	TGT_POS05,TGT_RND1,80	;Posn,Type,Show

		DB	-1			;End

TgtPattern26::	DB	100			;Wait
		DB	TGT_POS00,TGT_GOOD,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS01,TGT_RND0,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS05,TGT_RND0,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,110	;Posn,Type,Show
		DB	100 			;Wait
		DB	TGT_POS11,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS10,TGT_RND0,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,100	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS06,TGT_RND1,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_GOOD,90	;Posn,Type,Show


		DB	-1			;End

TgtPattern27::	DB	100 			;Wait
		DB	TGT_POS11,TGT_GOOD,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS10,TGT_RND0,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS06,TGT_RND0,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_GOOD,110	;Posn,Type,Show
		DB	100			;Wait
		DB	TGT_POS00,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS01,TGT_RND1,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,100	;Posn,Type,Show
		DB	40 			;Wait
		DB	TGT_POS05,TGT_RND0,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,90	;Posn,Type,Show


		DB	-1			;End

TgtPattern28::	DB	100			;Wait
		DB	TGT_POS01,TGT_RNDH,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS02,TGT_RND1,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS10,TGT_GOOD,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS06,TGT_RND0,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_GOOD,110	;Posn,Type,Show
		DB	100 			;Wait
		DB	TGT_POS08,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS10,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS09,TGT_RND0,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,100	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS05,TGT_RND1,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,90	;Posn,Type,Show

		DB	-1			;End

TgtPattern29::	DB	100 			;Wait
		DB	TGT_POS08,TGT_GOOD,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS10,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS09,TGT_RND0,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS05,TGT_RND1,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,110	;Posn,Type,Show
		DB	100			;Wait
		DB	TGT_POS01,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS03,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS02,TGT_RND0,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS10,TGT_GOOD,100	;Posn,Type,Show
		DB	40 			;Wait
		DB	TGT_POS06,TGT_RND0,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS04,TGT_GOOD,90	;Posn,Type,Show

		DB	-1			;End

TgtPattern30::	DB	100			;Wait
		DB	TGT_POS00,TGT_GOOD,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS08,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS04,TGT_RND0,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS06,TGT_GOOD,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS10,TGT_GOOD,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,110	;Posn,Type,Show
		DB	100 			;Wait
		DB	TGT_POS03,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS07,TGT_GOOD,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_RND1,100	;Posn,Type,Show
		DB	40			;Wait
		DB	TGT_POS01,TGT_GOOD,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,90	;Posn,Type,Show

		DB	-1			;End

TgtPattern31::	DB	100 			;Wait
		DB	TGT_POS03,TGT_GOOD,120	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS11,TGT_GOOD,120	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS07,TGT_RND0,115	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS05,TGT_RND1,115	;Posn,Type,Show
		DB	55 			;Wait
		DB	TGT_POS09,TGT_GOOD,110	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,110	;Posn,Type,Show
		DB	100			;Wait
		DB	TGT_POS00,TGT_GOOD,105	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS08,TGT_GOOD,105	;Posn,Type,Show
		DB	50			;Wait
		DB	TGT_POS04,TGT_GOOD,100	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS06,TGT_RND0,100	;Posn,Type,Show
		DB	40 			;Wait
		DB	TGT_POS10,TGT_GOOD,90	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS02,TGT_GOOD,90	;Posn,Type,Show

		DB	-1			;End

TgtPattern32::	DB	60 			;Wait
		DB	TGT_POS00,TGT_RNDH,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS04,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS01,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS08,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS05,TGT_RND0,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS02,TGT_GOOD,80	;Posn,Type,Show
		DB	80			;Wait
		DB	TGT_POS09,TGT_GOOD,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS06,TGT_RND0,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS03,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS10,TGT_GOOD,60	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS07,TGT_GOOD,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS11,TGT_RND1,45	;Posn,Type,Show

		DB	-1			;End

TgtPattern33::	DB	60 			;Wait
		DB	TGT_POS11,TGT_GOOD,60 	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS10,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS06,TGT_RND1,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS03,TGT_GOOD,80	;Posn,Type,Show
		DB	80			;Wait
		DB	TGT_POS08,TGT_GOOD,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS05,TGT_RND0,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS02,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS04,TGT_GOOD,60	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS01,TGT_GOOD,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS00,TGT_RND0,45	;Posn,Type,Show

		DB	-1			;End

TgtPattern34::	DB	60 			;Wait
		DB	TGT_POS08,TGT_RND1,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS04,TGT_GOOD,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS09,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS00,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS05,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS10,TGT_GOOD,80	;Posn,Type,Show
		DB	80			;Wait
		DB	TGT_POS01,TGT_RND0,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS06,TGT_RND0,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS11,TGT_RND0,75	;Posn,Type,Show
		DB	80			;Wait
		DB	TGT_POS02,TGT_GOOD,60	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS07,TGT_GOOD,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS03,TGT_RND0,45	;Posn,Type,Show

		DB	-1			;End

TgtPattern35::	DB	60 			;Wait
		DB	TGT_POS03,TGT_RND1,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS02,TGT_RND0,75	;Posn,Type,Show
		DB	00			;Wait
		DB	TGT_POS07,TGT_RND0,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS01,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS06,TGT_GOOD,80	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS11,TGT_GOOD,80	;Posn,Type,Show
		DB	80			;Wait
		DB	TGT_POS00,TGT_GOOD,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS05,TGT_GOOD,75	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS10,TGT_GOOD,75	;Posn,Type,Show
		DB	75			;Wait
		DB	TGT_POS04,TGT_RND0,60	;Posn,Type,Show
		DB	00 			;Wait
		DB	TGT_POS09,TGT_RND0,60	;Posn,Type,Show
		DB	60			;Wait
		DB	TGT_POS08,TGT_RND1,45	;Posn,Type,Show

		DB	-1			;End

TgtPattern36::	DB      90	       		;Wait
		DB	TGT_POS05,TGT_GOOD,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS01,TGT_RNDH,90	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS04,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,110	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_RND0,120	;Posn,Type,Show
		DB	130
		DB	TGT_POS02,TGT_GOOD,85	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS00,TGT_GOOD,95	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS08,TGT_GOOD,105	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_RND1,115	;Posn,Type,Show

		DB	-1			;End

TgtPattern37::	DB      90	       		;Wait
		DB	TGT_POS05,TGT_RND1,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS02,TGT_GOOD,90	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS08,TGT_GOOD,110	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS00,TGT_RND1,120	;Posn,Type,Show
		DB	130			;Wait
		DB	TGT_POS01,TGT_GOOD,85	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_GOOD,95	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,105	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS04,TGT_RND0,115	;Posn,Type,Show

		DB	-1			;End

TgtPattern38::	DB      90	       		;Wait
		DB	TGT_POS06,TGT_RND0,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS02,TGT_RND0,90	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_GOOD,110	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS07,TGT_GOOD,120	;Posn,Type,Show
		DB	130
		DB	TGT_POS03,TGT_RND1,85	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS01,TGT_GOOD,95	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,105	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS11,TGT_RND0,115	;Posn,Type,Show

		DB	-1			;End

TgtPattern39::	DB      90	       		;Wait
		DB	TGT_POS06,TGT_RND1,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS01,TGT_GOOD,90	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS11,TGT_GOOD,110	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS03,TGT_RND1,120	;Posn,Type,Show
		DB	130
		DB	TGT_POS02,TGT_GOOD,85	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,95	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_GOOD,105	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS07,TGT_RND0,115	;Posn,Type,Show

		DB	-1			;End

TgtPattern40::	DB      80 	       		;Wait
		DB	TGT_POS00,TGT_RND0,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS01,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS04,TGT_RND0,100	;Posn,Type,Show
		DB	115
		DB	TGT_POS08,TGT_RND1,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS02,TGT_RNDH,125	;Posn,Type,Show

		DB	-1			;End

TgtPattern41::	DB      80 	       		;Wait
		DB	TGT_POS03,TGT_GOOD,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS02,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS07,TGT_RND1,100	;Posn,Type,Show
	       	DB	115
		DB	TGT_POS11,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS10,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS01,TGT_RND0,125	;Posn,Type,Show

		DB	-1			;End

TgtPattern42::	DB      80 	       		;Wait
		DB	TGT_POS11,TGT_RND1,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS10,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS07,TGT_RND0,100	;Posn,Type,Show
		DB	115
		DB	TGT_POS03,TGT_RND0,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS02,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS01,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_RND1,125	;Posn,Type,Show

		DB	-1			;End

TgtPattern43::	DB      80	       		;Wait
		DB	TGT_POS08,TGT_RND0,65	;Posn,Type,Show

		DB	80			;Wait
		DB	TGT_POS04,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS05,TGT_GOOD,100	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS09,TGT_RND0,100	;Posn,Type,Show
		DB	115
		DB	TGT_POS10,TGT_RND1,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS06,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS02,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS01,TGT_GOOD,125	;Posn,Type,Show
		DB	15			;Wait
		DB	TGT_POS00,TGT_RND0,125	;Posn,Type,Show

		DB	-1			;End

TgtPattern44::	DB	60     	       		;Wait
		DB	TGT_POS00,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS01,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS02,TGT_RND1,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_RND0,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS08,TGT_GOOD,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS10,TGT_RND0,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS06,TGT_RND0,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_RNDH,85	;Posn,Type,Show
		DB	-1			;End

TgtPattern45::	DB	60   	  		;Wait
		DB	TGT_POS01,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS02,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS03,TGT_RND0,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_RND1,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS09,TGT_GOOD,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS10,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS11,TGT_RND0,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS07,TGT_GOOD,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_RND0,85	;Posn,Type,Show
		DB	-1			;End

TgtPattern46::	DB	60    	 		;Wait
		DB	TGT_POS08,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS09,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS10,TGT_RND0,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_RND0,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS00,TGT_GOOD,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS01,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS02,TGT_RND1,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS06,TGT_RND0,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_RND0,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_RND0,85	;Posn,Type,Show
		DB	-1			;End

TgtPattern47::	DB	60  	   		;Wait
		DB	TGT_POS09,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS10,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS11,TGT_RND0,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_RND0,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS01,TGT_GOOD,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS02,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS03,TGT_RND0,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS07,TGT_GOOD,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_RND1,85	;Posn,Type,Show
	       	DB	-1			;End

TgtPattern48::	DB	60   	  		;Wait
		DB	TGT_POS00,TGT_RNDH,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS08,TGT_GOOD,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS09,TGT_RND1,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS01,TGT_GOOD,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS02,TGT_RND0,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS10,TGT_GOOD,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS11,TGT_RND0,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS07,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS03,TGT_GOOD,85	;Posn,Type,Show
		DB	-1			;End

TgtPattern49::	DB	60    	 		;Wait
		DB	TGT_POS03,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS07,TGT_GOOD,90	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS11,TGT_RND0,100	;Posn,Type,Show
		DB	90

		DB	TGT_POS10,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS06,TGT_GOOD,85	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS02,TGT_RND0,95	;Posn,Type,Show
		DB	85

		DB	TGT_POS01,TGT_GOOD,70	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS05,TGT_GOOD,80	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS09,TGT_RND0,90	;Posn,Type,Show
		DB	80

		DB	TGT_POS08,TGT_RND1,65	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS04,TGT_GOOD,75	;Posn,Type,Show
		DB	05			;Wait
		DB	TGT_POS00,TGT_RND0,85	;Posn,Type,Show
		DB	-1			;End

TgtPattern50::	DB	30			;Wait
		DB	TGT_POS00,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern51::	DB	30			;Wait
		DB	TGT_POS01,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern52::	DB	30			;Wait
		DB	TGT_POS02,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern53::	DB	30			;Wait
		DB	TGT_POS03,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern54::	DB	30			;Wait
		DB	TGT_POS04,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern55::	DB	30			;Wait
		DB	TGT_POS05,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern56::	DB	30			;Wait
		DB	TGT_POS06,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern57::	DB	30			;Wait
		DB	TGT_POS07,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern58::	DB	30			;Wait
		DB	TGT_POS08,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern59::	DB	30			;Wait
		DB	TGT_POS09,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern60::	DB	30			;Wait
		DB	TGT_POS10,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End
TgtPattern61::	DB	30			;Wait
		DB	TGT_POS11,TGT_CLOCK,45	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern62::	DB	20			;Wait
		DB	TGT_POS12,TGT_TAUNT,1	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern63::	DB	20			;Wait
		DB	TGT_POS13,TGT_TAUNT,1	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern64::	DB	20			;Wait
		DB	TGT_POS14,TGT_TAUNT,1	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern65::	DB	20			;Wait
		DB	TGT_POS15,TGT_TAUNT,1	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern66::	DB	30			;Wait
		DB	TGT_POS12,TGT_APPLE,35	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern67::	DB	30			;Wait
		DB	TGT_POS13,TGT_APPLE,35	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern68::	DB	30			;Wait
		DB	TGT_POS14,TGT_APPLE,35	;Posn,Type,Show
		DB	10

		DB	-1			;End

TgtPattern69::	DB	30			;Wait
		DB	TGT_POS15,TGT_APPLE,35	;Posn,Type,Show
		DB	10

		DB	-1			;End

;
;
;

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF TARGETHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

