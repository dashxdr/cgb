; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BOARDLO.ASM                                                    MODULE **
; **                                                                       **
; ** Game Board.                                                           **
; **                                                                       **
; ** Last modified : 25 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"boardlo",HOME
		section 0
;
;
;

TblMarkerSprRgb::INCBIN	"res/john/marker/clmbeast.rgb"

;
;
;

TblPlyrInfo::	DW	PlyrInfoBeast		;PLYR_BEAST
		DW	PlyrInfoBelle		;PLYR_BELLE
		DW	PlyrInfoPotts		;PLYR_POTTS
		DW	PlyrInfoLumir		;PLYR_LUMIR
		DW	PlyrInfoGastn		;PLYR_GASTN

PlyrInfoBeast::	DW	wStructBeast		;PLYR_BEAST
		DW	wBoardBeast		;
		DW	BeastPlayICmd		;
		DW	BeastSkipICmd		;
		IF	VERSION_USA		;
		DW	IDX_BSMBEAST		;
		DB	1			;
		DW	IDX_BLMBEAST		;
		DB	1			;
		DW	IDX_CSMBEAST		;
		DB	1			;
		DW	IDX_CLMBEAST		;
		DB	2			;
		ELSE				;
		DW	IDX_BJMBEAST		;
		DB	1			;
		DW	IDX_BLMBEAST		;
		DB	1			;
		DW	IDX_CJMBEAST		;
		DB	1			;
		DW	IDX_CLMBEAST		;
		DB	2			;
		ENDC				;

PlyrInfoBelle::	DW	wStructBelle		;PLYR_BELLE
		DW	wBoardBelle		;
		DW	BellePlayICmd		;
		DW	BelleSkipICmd		;
		IF	VERSION_USA		;
		DW	IDX_BSMBELLE		;
		DB	1			;
		DW	IDX_BLMBELLE		;
		DB	1			;
		DW	IDX_CSMBELLE		;
		DB	1			;
		DW	IDX_CLMBELLE		;
		DB	3			;
		ELSE				;
		DW	IDX_BJMBELLE		;
		DB	1			;
		DW	IDX_BLMBELLE		;
		DB	1			;
		DW	IDX_CJMBELLE		;
		DB	1			;
		DW	IDX_CLMBELLE		;
		DB	3			;
		ENDC				;

PlyrInfoPotts::	DW	wStructPotts		;PLYR_POTTS
		DW	wBoardPotts		;
		DW	PottsPlayICmd		;
		DW	PottsSkipICmd		;
		IF	VERSION_USA		;
		DW	IDX_BSMPOTTS		;
		DB	1			;
		DW	IDX_BLMPOTTS		;
		DB	1			;
		DW	IDX_CSMPOTTS		;
		DB	1			;
		DW	IDX_CLMPOTTS		;
		DB	2			;
		ELSE				;
		DW	IDX_BJMPOTTS		;
		DB	1			;
		DW	IDX_BLMPOTTS		;
		DB	1			;
		DW	IDX_CJMPOTTS		;
		DB	1			;
		DW	IDX_CLMPOTTS		;
		DB	2			;
		ENDC				;

PlyrInfoLumir::	DW	wStructLumir		;PLYR_LUMIR
		DW	wBoardLumir		;
		DW	LumirPlayICmd		;
		DW	LumirSkipICmd		;
		IF	VERSION_USA		;
		DW	IDX_BSMLUMIR		;
		DB	1			;
		DW	IDX_BLMLUMIR		;
		DB	1			;
		DW	IDX_CSMLUMIR		;
		DB	1			;
		DW	IDX_CLMLUMIR		;
		DB	3			;
		ELSE				;
		DW	IDX_BJMLUMIR		;
		DB	1			;
		DW	IDX_BLMLUMIR		;
		DB	1			;
		DW	IDX_CJMLUMIR		;
		DB	1			;
		DW	IDX_CLMLUMIR		;
		DB	3			;
		ENDC				;

PlyrInfoGastn::	DW	wStructGastn		;PLYR_GASTN
		DW	wBoardGastn		;
		DW	0			;
		DW	0			;
		IF	VERSION_USA		;
		DW	IDX_BSMGASTN		;
		DB	1			;
		DW	IDX_BLMGASTN		;
		DB	1			;
		DW	IDX_CSMGASTN		;
		DB	1			;
		DW	IDX_CLMGASTN		;
		DB	5			;
		ELSE				;
		DW	IDX_BJMGASTN		;
		DB	1			;
		DW	IDX_BLMGASTN		;
		DB	1			;
		DW	IDX_CJMGASTN		;
		DB	1			;
		DW	IDX_CLMGASTN		;
		DB	5			;
		ENDC				;


;
;
;

TblGuardPos::	DB	GUARD1_NRM,48,20,3	;Guard 1 square,x,y,offset
		DB	GUARD1_ALT,42,16,7	;Guard 1 square,x,y,offset

		DB	GUARD2_NRM,53, 9,6	;Guard 2 square,x,y,offset
		DB	GUARD2_ALT,48,12,2	;Guard 2 square,x,y,offset

		DB	GUARD3_NRM,42, 9,5	;Guard 3 square,x,y,offset
		DB	GUARD3_ALT,36,12,1	;Guard 3 square,x,y,offset

		DB	GUARD4_NRM,25,12,0	;Guard 4 square,x,y,offset
		DB	GUARD4_ALT,31, 9,4	;Guard 4 square,x,y,offset

TblDoorPos::	DB	41,42,20,8		;Door square,x,y,offset

;
;
;

		IF	VERSION_USA
TblIconOffset::	DW	   0, 0
		DW	   1,18
		DW	1-10,18
		DW	1-20,18
		ELSE
TblIconOffset::	DW	   0, 0
		DW	   1,20
		DW	0-15,20
		DW	0-31,20
		ENDC

;
;
;


; ***************************************************************************
; * OverlayResult ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

OverlayResult::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	HL,IDX_CRESULTSCHR	;Locate overlay.
		CALL	FindInFileSys		;

		LD	DE,$C800+(12*$10)	;Copy chr data.
		LD	A,20			;
.Loop0:		PUSH	AF			;
		LD	BC,$40			;
		CALL	MemCopy			;
		LD	A,255&(14*$10)		;
		ADD	E			;
		LD	E,A			;
		LD	A,(14*$10)>>8		;
		ADC	D			;
		LD	D,A			;
		POP	AF			;
		DEC	A			;
		JR	NZ,.Loop0		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Done		;

		LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	HL,wAtrShadow+(12*$20)	;
		LD	B,4*$20			;
.Loop1:		LD	A,[HL]			;
		AND	$F8			;
		LD	[HLI],A			;
		DEC	B			;
		JR	NZ,.Loop1		;

		POP	AF			;Restore the original ram
		LDH	[hWrkBank],A		;bank.
		LDIO	[rSVBK],A		;

.Done:		RET				;All Done.



; ***************************************************************************
; * BoardWhichICmd ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardWhichICmd::PUSH	HL			;Use wWhichPlyr to determine
		PUSH	DE			;whether to wait for a delay
		LD	A,[wWhichPlyr]		;or a joypad.
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		POP	DE			;
		POP	HL
		JR	Z,.Skip0		;
		LD	L,E			;
		LD	H,D			;
.Skip0:		JP	ProcIntroSeq		;



; ***************************************************************************
; * GetPlyrInfo ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetPlyrInfo::	PUSH	HL			;
		LD	HL,TblPlyrInfo		;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	E,A			;
		LD	[wBoardInfoLo],A	;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	[wBoardInfoHi],A	;
		LD	HL,PLYR_TMP		;
		ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	[wBoardTmpLo],A		;
		LD	A,[HLI]			;
		LD	[wBoardTmpHi],A		;
		LD	HL,PLYR_RAM		;
		ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	[wStructRamLo],A	;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	[wStructRamHi],A	;
		POP	HL			;
		RET				;



; ***************************************************************************
; * BoardLaunch ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardLaunch::	CP	SQR_MIRRO		;Do the magic-mirror thing
		JP	Z,BoardMirror		;to get a random game.

		CP	SQR_GASTN		;Special-case "Gaston's Grief".
		JP	Z,BoardGastn		;

		CP	SQR_LUCKY		;Special-case "Lucky Day".
		JP	Z,BoardLucky		;

		CP	SQR_STAR		;Special-case "Star".
		JP	Z,BoardStar		;

		CP	SQR_END			;Special-case end-of-game.
		JP	Z,BoardFinish		;

		LD	HL,TblSqr2Game		;Convert the square number to
		LD	C,A			;Dave's game number.
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;

		CP	-1			;No game ?
		RET	Z			;

		OR	A			;Or a random game ?
		JR	NZ,BoardSubGame		;

		CALL	random			;
		LD	C,8			;
		CALL	MultiplyBBW		;
		LD	A,H			;

		LD	HL,TblMirror2Typ	;
		ADD	A			;
		INC	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;
		JR	BoardLaunch		;

BoardSubGame::	PUSH	AF			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,BANK(LaunchGame)	;Page in Dave's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to play or fake
		LD	HL,PLYR_FLAGS		;the game.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,BoardSubFake		;

		POP	AF			;
		CALL	LaunchGame		;

		LD	A,BANK(BoardGame)	;Page in John's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;

BoardSubFake::	POP	AF			;

		CP	A,GAME_MIND		;Fake up a bonus game.
		JR	Z,BoardFakeMind		;

		CP	A,GAME_SPIT		;Fake up a bonus game.
		JR	Z,BoardFakeSpit		;

		PUSH	AF			;

		XOR	A			;Clear stars.
		LD	[wSubStars],A		;

		LD	DE,RndCpuResults	;Award a random result.
		CALL	RandomResult		;
		LD	[wSubStage],A		;
		LD	[wTriviaRight],A	;

		OR	A			;Definitely no star if the
		JR	Z,.Skip0		;game was screwed.

		POP	AF			;

		CP	A,GAME_TRIVIA		;Trivia game gives no stars.
		JR	Z,BoardFakeShow		;

		PUSH	AF			;

		LD	DE,RndCpuStars		;Award a random star.
		CALL	RandomResult		;
		LD	[wSubStars],A		;

.Skip0:		POP	AF			;

BoardFakeShow::	ADD	A			;Show the game result.
		LD	C,A			;
		LD	B,0			;
		CALL	ShowGameResult		;

BoardFakeDone::	LD	A,BANK(BoardGame)	;Page in John's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;

BoardFakeMind::	LD	DE,RndCpuMind		;Fake a result for the
		CALL	RandomResult		;matching game.
		LD	[wSubCount],A		;
		INC	A			;
		SRL	A			;
		LD	[wSubStage],A		;

		LD	A,GAME_MIND		;Show the result.
		JR	BoardFakeShow		;

BoardFakeSpit::	LD	DE,RndCpuSpit		;Fake a result for the
		CALL	RandomResult		;spitting game.
		LD	[wSubStage],A		;

		LD	A,GAME_SPIT		;Show the result.
		JR	BoardFakeShow		;

;
;
;

RandomResult::	LD	HL,PLYR_LEVEL		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		ADD	E			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	D			;
.Skip1:		LD	H,D			;
		LD	E,-1			;
		CALL	random			;
		OR	A			;
		JR	Z,.Loop1		;
		DEC	A			;
.Loop1:		INC	E			;
		CP	[HL]			;
		INC	HL			;
		JR	NC,.Loop1		;
		LD	A,E			;
		RET				;

;
;
;

PCTRES:		MACRO
PCTACC		ESET	0
		ENDM
PCTVAL:		MACRO
PCTACC		ESET	PCTACC+\1
		DB	(255*PCTACC)/100
		ENDM

RndCpuResults::
		PCTRES
		PCTVAL	10			;AI-Weak
		PCTVAL	60			;
		PCTVAL	20			;
		PCTVAL	10			;
		DB	0,0,0,0			;
		PCTRES
		PCTVAL	00			;AI-Normal
		PCTVAL	20			;
		PCTVAL	60			;
		PCTVAL	20			;
		DB	0,0,0,0			;
		PCTRES
		PCTVAL	00			;AI-Strong
		PCTVAL	10			;
		PCTVAL	20			;
		PCTVAL	70			;
		DB	0,0,0,0			;

RndCpuStars::
		PCTRES
		PCTVAL	75			;AI-Weak
		PCTVAL	25			;
		DB	0,0,0,0,0,0		;
		PCTRES
		PCTVAL	50			;AI-Normal
		PCTVAL	50			;
		DB	0,0,0,0,0,0		;
		PCTRES
		PCTVAL	25			;AI-Strong
		PCTVAL	75			;
		DB	0,0,0,0,0,0		;

RndCpuMind::
		PCTRES
		PCTVAL	5			;AI-Weak
		PCTVAL	5			;
		PCTVAL	30			;
		PCTVAL	30			;
		PCTVAL	20			;
		PCTVAL	0			;
		PCTVAL	10			;
		DB	0			;
		PCTRES
		PCTVAL	00			;AI-Normal
		PCTVAL	00			;
		PCTVAL	10			;
		PCTVAL	10			;
		PCTVAL	60			;
		PCTVAL	0			;
		PCTVAL	20			;
		DB	0			;
		PCTRES
		PCTVAL	00			;AI-Strong
		PCTVAL	00			;
		PCTVAL	5			;
		PCTVAL	5			;
		PCTVAL	30			;
		PCTVAL	0			;
		PCTVAL	60			;
		DB	0			;

RndCpuSpit::
		PCTRES
		PCTVAL	50			;AI-Weak
		PCTVAL	25			;
		PCTVAL	25			;
		DB	0,0,0,0,0		;
		PCTRES
		PCTVAL	25			;AI-Normal
		PCTVAL	25			;
		PCTVAL	50			;
		DB	0,0,0,0,0		;
		PCTRES
		PCTVAL	00			;AI-Strong
		PCTVAL	25			;
		PCTVAL	75			;
		DB	0,0,0,0,0		;

;
;
;

TblSqr2Game::	DB	0			;---
		DB	-1			;SQR_START
		DB	GAME_BEAST		;SQR_BEAST
		DB	GAME_RIDE		;SQR_BELLE
		DB	GAME_CHIP		;SQR_CHIP
		DB	GAME_TRIVIA		;SQR_COGGS
		DB	0			;SQR_GASTN
		DB	GAME_SHOOTING		;SQR_LEFOU
		DB	GAME_CELLAR		;SQR_LUMIR
		DB	GAME_BEAST		;SQR_MIRRO
		DB	GAME_CHOPPER		;SQR_POPPA
		DB	GAME_STOVE		;SQR_POTTS
		DB	0			;SQR_LUCKY
		DB	GAME_SULTAN		;SQR_SULTN
		DB	GAME_MIND		;SQR_DOORS
		DB	0			;SQR_STAR
		DB	-1			;SQR_END

;
;
;

BoardMirror::	CALL	MirrorGame		;
		JP	BoardLaunch		;



; ***************************************************************************
; * CgbMapRefresh ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen is black (because this routine      *                                                          *
; ***************************************************************************

CgbMapRefresh::	PUSH	BC			;Preserve scroll position.

		CALL	CgbMapInit		;Init dynamic allocation.

		POP	BC			;Alloc the complete screen.
		PUSH	BC			;
		LD	DE,$1513		;
		CALL	CgbMapAlloc		;

		POP	BC			;Paint the complete screen.
		PUSH	BC			;
		LD	DE,$1513		;
		CALL	CgbMapPaint		;

		IF	1

		POP	BC			;Blit the complete screen.
		PUSH	BC			;
		CALL	CgbBlitScreen		;

		ELSE

		CALL	WaitForVBL		;Turn the screen off.
		LDH	A,[hVblLCDC]		;
		AND	$7F			;
		LDH	[hVblLCDC],A		;
		LDIO	[rLCDC],A		;

		POP	BC			;
		PUSH	BC			;
		LD	DE,$1513		;
		CALL	CgbMapXfer		;

		LDH	A,[hVblLCDC]		;Turn the screen on.
		OR	$80			;
		LDH	[hVblLCDC],A		;
		LDIO	[rLCDC],A		;
		CALL	WaitForVBL		;

		ENDC

		ADD	SP,2			;

		RET				;All Done.



; ***************************************************************************
; * CgbMapInit ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapInit::	LD	A,WRKBANK_QUEUE		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	HL,SCROLL_QUEUE		;
		LD	BC,$01FF		;

		LD	A,L			;
		LDH	[hListGetLo],A		;
		LD	A,H			;
		LDH	[hListGetHi],A		;
.Loop:		LD	A,C			;
		CP	$00			;
		JR	Z,.Next			;
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
.Next:		DEC	BC			;
		LD	A,B			;
		OR	A,C			;
		JR	NZ,.Loop		;
		LD	A,L			;
		LDH	[hListPutLo],A		;
		LD	A,H			;
		LDH	[hListPutHi],A		;

		LD	HL,SCROLL_SCR_LO	;
		LD	BC,$0800		;
		CALL	MemClear		;

		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * CgbMapFree ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapFree::	PUSH	DE			;Preserve width and height.

		LD	A,WRKBANK_QUEUE		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,B			;Calc offset into screen.
		AND	$1F			;
		LD	E,A			;
		LD	A,C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	D,A			;
		AND	$E0			;
		OR	A,E			;
		LD	E,A			;
		LD	A,D			;
		AND	$03			;
		OR	SCROLL_SCR_LO>>8	;
		LD	D,A			;

		LDH	A,[hListPutLo]		;Get the output ptr.
		LD	L,A			;
		LDH	A,[hListPutHi]		;
		LD	H,A			;

		POP	BC			;Restore width and height.

.Loop0:		PUSH	BC			;
		PUSH	DE			;

.Loop1:		LD	A,[DE]			;Get the character number
		OR	A			;from the map.
		JR	Z,.Skip0		;
		LD	[HLI],A			;
		XOR	A			;
		LD	[DE],A			;
		SET	2,D			;
		LD	A,[DE]			;
		RRCA				;
		RRCA				;
		RRCA				;
		AND	$01			;
		LD	[HLI],A			;
;		XOR	A			;
;		LD	[DE],A			;
		RES	2,D			;

		LD	A,H			;
		AND	$03			;
		OR	SCROLL_QUEUE>>8		;
		LD	H,A			;

.Skip0:		INC	E			;Move to next screen col.
		LD	A,E			;
		AND	$1F			;
		JR	NZ,.Skip1		;
		LD	A,E			;
		SUB	$20			;
		LD	E,A			;

.Skip1:		DEC	B			;
		JR	NZ,.Loop1		;

		POP	DE			;

		LD	A,E			;Move to next screen row.
		ADD	$20			;
		LD	E,A			;
		JR	NC,.Skip2		;
		INC	D			;
		RES	2,D			;

.Skip2:		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop0		;

		LD	A,L			;Put the output ptr.
		LDH	[hListPutLo],A		;
		LD	A,H			;
		LDH	[hListPutHi],A		;

		LD	A,WRKBANK_NRM		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * CgbMapAlloc ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapAlloc::	PUSH	DE			;Preserve width and height.

		LD	A,WRKBANK_QUEUE		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,B			;Calc offset into screen.
		AND	$1F			;
		LD	E,A			;
		LD	A,C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	D,A			;
		AND	$E0			;
		OR	A,E			;
		LD	E,A			;
		LD	A,D			;
		AND	$03			;
		OR	SCROLL_SCR_LO>>8	;
		LD	D,A			;

		LDH	A,[hListGetLo]		;Get the output ptr.
		LD	L,A			;
		LDH	A,[hListGetHi]		;
		LD	H,A			;

		POP	BC			;Restore width and height.

.Loop0:		PUSH	BC			;
		PUSH	DE			;

.Loop1:		LD	A,[DE]			;Chk the character number
		OR	A			;from the map.
		JR	NZ,.Skip0		;

		LD	A,[HLI]			;Put the character number
		LD	[DE],A			;into the map.
		LD	A,[HLI]			;
		RLCA				;
		RLCA				;
		RLCA				;
		SET	2,D			;
		LD	[DE],A			;
		RES	2,D			;

		LD	A,H			;
		AND	$03			;
		OR	SCROLL_QUEUE>>8		;
		LD	H,A			;

.Skip0:		INC	E			;Move to next screen col.
		LD	A,E			;
		AND	$1F			;
		JR	NZ,.Skip1		;
		LD	A,E			;
		SUB	$20			;
		LD	E,A			;

.Skip1:		DEC	B			;
		JR	NZ,.Loop1		;

		POP	DE			;

		LD	A,E			;Move to next screen row.
		ADD	$20			;
		LD	E,A			;
		JR	NC,.Skip2		;
		INC	D			;
		RES	2,D			;

.Skip2:		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop0		;

		LD	A,L			;Put the output ptr.
		LDH	[hListGetLo],A		;
		LD	A,H			;
		LDH	[hListGetHi],A		;

		LD	A,WRKBANK_NRM		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * CgbMapXfer ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapXfer::	LD	A,B			;Calc offset into screen.
		AND	$1F			;
		LD	L,A			;
		LD	A,C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	H,A			;
		AND	$E0			;
		OR	A,L			;
		LD	L,A			;
		LD	A,H			;
		AND	$03			;
		OR	SCROLL_SCR_LO>>8	;
		LD	H,A			;

		LD	C,E			;
		LD	B,D			;

		PUSH	BC			;
		PUSH	HL			;

		SET	2,H			;

		LD	A,1			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		CALL	BlitRectXY		;

		POP	HL			;
		POP	BC			;

		LD	A,0			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		JP	BlitRectXY		;



; ***************************************************************************
; * CgbBlitScreen ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbBlitScreen::	LD	A,B			;Calc offset into screen.
		AND	$1F			;
		LD	E,A			;
		LD	A,C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	D,A			;
		AND	$E0			;
		OR	A,E			;
		LD	E,A			;
		LD	A,D			;
		AND	$03			;
		OR	SCROLL_SCR_LO>>8	;
		LD	D,A			;

		LD	B,21/3			;Dump in blocks of 3 columns.

.Loop0:		LD	HL,hBlitYX+3		;
		LD	A,D			;
		LD	[HLD],A			;
		LD	A,E			;
		LD	[HLD],A			;
		LD	A,$13			;
		LD	[HLD],A			;
		LD	A,$03			;
		LD	[HLD],A			;
.Loop1:		CALL	WaitForVBL		;
		LDH	A,[hBlitYX]		;
		OR	A			;
		JR	NZ,.Loop1		;

		LD	A,E			;
		AND	$E0			;
		LD	C,A			;
		LD	A,E			;
		ADD	$03			;
		AND	$1F			;
		OR	C			;
		LD	E,A			;

		DEC	B			;
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * CgbBlitVbl ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL or when the screen is off.        *
; ***************************************************************************

CgbBlitVbl::	LD	HL,hBlitXY		;Copy an XY rectangle.
		LD	A,[HLI]			;
		OR	A			;
		JR	Z,.Skip0		;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,1			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;
		SET	2,H			;
		CALL	BlitRectXY		;
		LD	HL,hBlitXY		;
		LD	B,[HL]			;
		XOR	A			;
		LD	[HLI],A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,0			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;
		CALL	BlitRectXY		;

.Skip0:		LD	HL,hBlitYX		;Copy an YX rectangle.
		LD	A,[HLI]			;
		OR	A			;
		RET	Z			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,1			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;
		SET	2,H			;
		CALL	BlitVideoYX		;
		LD	HL,hBlitYX		;
		LD	B,[HL]			;
		XOR	A			;
		LD	[HLI],A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,0			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;
		JP	BlitVideoYX		;



; ***************************************************************************
; * BlitRectXY ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to shadow screen (on a 1KB boundary)               *
; *             B  = Width                                                  *
; *             C  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL or when the screen is off.        *
; ***************************************************************************

BlitRectXY::	LD	E,L			;
		LD	A,H			;
		AND	$03			;
		OR	($9800)>>8		;
		LD	D,A			;

.Loop0:		PUSH	BC			;
		PUSH	DE			;

.Loop1:		LD	A,[HL]			;Copy byte to vram.
		LD	[DE],A			;

		INC	E			;Move to next screen col.
		LD	A,E			;
		AND	$1F			;
		JR	NZ,.Skip0		;
		LD	A,E			;
		SUB	$20			;
		LD	E,A			;
.Skip0:		LD	L,E			;

		DEC	B			;
		JR	NZ,.Loop1		;

		POP	DE			;

		LD	A,E			;Move to next screen row.
		ADD	$20			;
		LD	E,A			;
		LD	L,A			;
		JR	NC,.Skip1		;
		LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;

.Skip1:		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * BlitRectYX ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to shadow screen (on a 1KB boundary)               *
; *             B  = Width                                                  *
; *             C  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL or when the screen is off.        *
; ***************************************************************************

BlitRectYX::	LD	E,L			;
		LD	A,H			;
		AND	$03			;
		OR	($9800)>>8		;
		LD	D,A			;

.Loop0:		PUSH	BC			;
		PUSH	DE			;

		LD	A,H			;
		SUB	A,D			;
		LD	B,A			;

.Loop1:		LD	A,[HL]			;Copy byte to vram.
		LD	[DE],A			;

		LD	A,E			;Move to next screen row.
		ADD	$20			;
		LD	E,A			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	D			;
		RES	2,D			;
		LD	A,B			;
		ADD	A,D			;
		LD	H,A			;

.Skip0:		DEC	C			;
		JR	NZ,.Loop1		;

		POP	DE			;

		INC	E			;Move to next screen col.
		LD	A,E			;
		AND	$1F			;
		JR	NZ,.Skip1		;
		LD	A,E			;
		SUB	$20			;
		LD	E,A			;
.Skip1:		LD	L,E			;

		POP	BC			;
		DEC	B			;
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * BlitVideoYX ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to shadow screen (on a 1KB boundary)               *
; *             B  = Number of columns to blit                              *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Must be called during VBL or when the screen is off.        *
; ***************************************************************************

BlitVideoYX::	PUSH	HL			;

		LD	E,L			;
		LD	A,H			;
		AND	$03			;
		OR	($9800)>>8		;
		LD	D,A			;

		LD	C,$20			;
		JR	.Copy01			;

.Wrap01:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy02			;
.Wrap02:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy03			;
.Wrap03:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy04			;
.Wrap04:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy05			;
.Wrap05:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy06			;
.Wrap06:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy07			;
.Wrap07:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy08			;
.Wrap08:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy09			;
.Wrap09:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0A			;

.Copy01:	LD	A,[HL]			;Copy byte $01 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap01		;
.Copy02:	LD	A,[HL]			;Copy byte $02 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap02		;
.Copy03:	LD	A,[HL]			;Copy byte 03 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap03		;
.Copy04:	LD	A,[HL]			;Copy byte 04 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap04		;
.Copy05:	LD	A,[HL]			;Copy byte 05 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap05		;
.Copy06:	LD	A,[HL]			;Copy byte 06 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap06		;
.Copy07:	LD	A,[HL]			;Copy byte 07 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap07		;
.Copy08:	LD	A,[HL]			;Copy byte 08 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap08		;
.Copy09:	LD	A,[HL]			;Copy byte 09 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap09		;
.Copy0A:	LD	A,[HL]			;Copy byte 0A to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0A		;
.Copy0B:	LD	A,[HL]			;Copy byte 0B to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0B		;
.Copy0C:	LD	A,[HL]			;Copy byte 0C to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0C		;
.Copy0D:	LD	A,[HL]			;Copy byte 0D to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0D		;
.Copy0E:	LD	A,[HL]			;Copy byte 0E to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0E		;
.Copy0F:	LD	A,[HL]			;Copy byte 0F to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap0F		;
.Copy10:	LD	A,[HL]			;Copy byte 10 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap10		;
.Copy11:	LD	A,[HL]			;Copy byte 11 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap11		;
.Copy12:	LD	A,[HL]			;Copy byte 12 to vram.
		LD	[DE],A			;
		LD	A,E			;
		ADD	A,C			;
		LD	E,A			;
		LD	L,A			;
		JR	C,.Wrap12		;
.Copy13:	LD	A,[HL]			;Copy byte 13 to vram.
		LD	[DE],A			;

		POP	HL			;

		INC	L			;
		LD	A,L			;
		AND	$1F			;
		JR	NZ,.Next		;
		LD	A,L			;
		SUB	$20			;
		LD	L,A			;

.Next:		DEC	B			;
		JP	NZ,BlitVideoYX		;

		RET				;

.Wrap0A:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0B			;
.Wrap0B:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0C			;
.Wrap0C:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0D			;
.Wrap0D:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0E			;
.Wrap0E:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy0F			;
.Wrap0F:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy10			;
.Wrap10:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy11			;
.Wrap11:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy12			;
.Wrap12:	LD	A,H			;
		SUB	A,D			;
		INC	D			;
		RES	2,D			;
		ADD	A,D			;
		LD	H,A			;
		JR	.Copy13			;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BOARDLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; * InitBoardSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitBoardSpr::	XOR	A			;Reset all sprites.
		LD	[wBoardSpr0+SPR_FLAGS],A;
		LD	[wBoardSpr1+SPR_FLAGS],A;
		LD	[wBoardSpr2+SPR_FLAGS],A;
		LD	[wBoardSpr3+SPR_FLAGS],A;
		LD	[wBoardSpr4+SPR_FLAGS],A;
		LD	[wBoardSpr5+SPR_FLAGS],A;
		LD	[wBoardSpr6+SPR_FLAGS],A;
		LD	[wBoardSpr7+SPR_FLAGS],A;
		LD	[wBoardSpr8+SPR_FLAGS],A;
		LD	[wBoardSpr9+SPR_FLAGS],A;
		LD	[wBoardSprA+SPR_FLAGS],A;
		LD	[wBoardSprB+SPR_FLAGS],A;

		LD	[wBoardSpr0+SPR_OAM_CNT],A;
		LD	[wBoardSpr1+SPR_OAM_CNT],A;
		LD	[wBoardSpr2+SPR_OAM_CNT],A;
		LD	[wBoardSpr3+SPR_OAM_CNT],A;
		LD	[wBoardSpr4+SPR_OAM_CNT],A;
		LD	[wBoardSpr5+SPR_OAM_CNT],A;
		LD	[wBoardSpr6+SPR_OAM_CNT],A;
		LD	[wBoardSpr7+SPR_OAM_CNT],A;
		LD	[wBoardSpr8+SPR_OAM_CNT],A;
		LD	[wBoardSpr9+SPR_OAM_CNT],A;
		LD	[wBoardSprA+SPR_OAM_CNT],A;
		LD	[wBoardSprB+SPR_OAM_CNT],A;

		XOR	A			;
		LDH	[hBlitXY],A		;
		LDH	[hBlitYX],A		;

		RET				;All Done.



; ***************************************************************************
; * DumpBoardSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpBoardSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	[wSprPlotSP],SP		;Preserve SP.

;		LD	A,[wFigPhase]		;Calc next character number.
;		XOR	64			;
;		LD	[wFigPhase],A		;
;		LDH	[hSprNxt],A		;
;		ADD	64			;
;		LDH	[hSprMax],A		;

		LD	A,[wFigPhase]		;Calc next character number.
		XOR	0			;
		LD	[wFigPhase],A		;
		LDH	[hSprNxt],A		;
		ADD	128			;
		LDH	[hSprMax],A		;

		LDH	A,[hSprNxt]		;Calc next character address.
		LD	L,A			;
		LD	H,$80/16		;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		LD	C,L			;
		LD	B,H			;

		LD	SP,wBoardSpr0		;
		CALL	SprDump			;
		LD	SP,wBoardSpr1		;
		CALL	SprDump			;
		LD	SP,wBoardSpr2		;
		CALL	SprDump			;
		LD	SP,wBoardSpr3		;
		CALL	SprDump			;
		LD	SP,wBoardSpr4		;
		CALL	SprDump			;
		LD	SP,wBoardSpr5		;
		CALL	SprDump			;
		LD	SP,wBoardSpr6		;
		CALL	SprDump			;
		LD	SP,wBoardSpr7		;
		CALL	SprDump			;
		LD	SP,wBoardSpr8		;
		CALL	SprDump			;
		LD	SP,wBoardSpr9		;
		CALL	SprDump			;
		LD	SP,wBoardSprA		;
		CALL	SprDump			;
		LD	SP,wBoardSprB		;
		CALL	SprDump			;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * DrawBoardSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawBoardSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LDH	A,[hOamPointer]		;Locate OAM shadow buffer.
		LD	D,A			;
		LD	E,0			;

;		CALL	wJmpDraw		;Draw special sprites.

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wBoardSpr0		;Draw regular sprites.
		CALL	SprDraw			;
		LD	SP,wBoardSpr1		;
		CALL	SprDraw			;

		LD	SP,wBoardSpr6		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr7		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr8		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr9		;
		CALL	SprDraw			;
		LD	SP,wBoardSprA		;
		CALL	SprDraw			;
		LD	SP,wBoardSprB		;
		CALL	SprDraw			;

		IF	VERSION_USA		;
		LD	SP,wBoardSpr2		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr3		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr4		;
		CALL	SprDraw			;
		LD	SP,wBoardSpr5		;
		CALL	SprDraw			;
		ENDC				;

		LDH	A,[hOamPointer]		;Blank out the remaining OAM
		LD	H,A			;entries in the OAM buffer.
		LD	L,E			;
		LD	A,160			;
		SUB	L			;
		JR	Z,.Done			;
		RRCA				;
		RRCA				;
		LD	E,A			;
		XOR	A			;
.Loop:		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		DEC	E			;
		JR	NZ,.Loop		;

.Done:		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LDH	A,[hOamPointer]		;Signal VBL to update OAM RAM and
		LDH	[hOamFlag],A		;character sprites.

		RET				;All Done.



; ***************************************************************************
; * DrawGuardMap ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL = Ptr to guard info                                      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0

DrawGuardMap::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,[HLI]			;Skip square number.

		LD	A,[HLI]			;Read X coordinate.
		LD	E,A			;
		LD	A,[HLI]			;Read Y coordinate.
		LD	D,A			;

		LD	A,[HLI]			;Read frame number.

		LD	BC,96			;
		CALL	MultiplyBWW		;
		LD	C,L			;
		LD	B,H			;

		LD	L,D			;Calc dst map address.
		LD	H,0			;
		LD	D,H			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		LD	DE,SCROLL_MAP_LO	;
		ADD	HL,DE			;
		PUSH	HL			;

;		LD	HL,IDX_CGUARDPKG	;
		CALL	FindInFileSys		;
		ADD	HL,BC			;

		POP	DE			;

		LD	BC,$0806		;Copy an 8x6 rectangle.

.Loop0:		PUSH	BC			;Preserve counters.

		PUSH	DE			;Preserve dst line ptr.

.Loop1:		LD	A,[HLI]			;Check for a zero word.
		OR	[HL]			;
		JR	Z,.Skip0		;

		LD	A,WRKBANK_CHRHI		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	A,[HLD]			;Write the hi byte.
		LD	[DE],A			;

		LD	A,WRKBANK_CHRLO		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	A,[HLI]			;Write the lo byte.
		LD	[DE],A			;

.Skip0:		INC	HL			;
		INC	DE			;

		DEC	B			;Next chr in row.
		JR	NZ,.Loop1		;

		POP	DE			;Restore dst line ptr.

		LD	A,64			;Move onto the next line of
		ADD	E			;the destination map.
		LD	E,A			;
		JR	NC,.Skip1		;
		INC	D			;

.Skip1:		POP	BC			;Restore counters.

		DEC	C			;Next row of chrs.
		JR	NZ,.Loop0		;

		LD	A,WRKBANK_NRM		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.

		ENDC



; ***************************************************************************
; * TryToBeatGastn ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TryToBeatGastn::CALL	random			;Select a random game square.
		LD	C,8			;
		CALL	MultiplyBBW		;
		LD	A,H			;
		LD	HL,TblMirror2Typ	;
		ADD	A			;
		INC	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;

		LD	HL,TblSqr2Game		;Convert the square number to
		LD	C,A			;Dave's game number.
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;

;		LD	A,GAME_SHOOTING		;

		PUSH	AF			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,BANK(LaunchGaston)	;Page in Dave's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to play or fake
		LD	HL,PLYR_FLAGS		;the game.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,.Fake		;

.Real:		POP	AF			;
		CALL	LaunchGaston		;

		LD	A,BANK(BoardGame)	;Page in John's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;

.Fake:		ADD	SP,2			;

		LD	DE,RndCpuResults	;Award a random result.
		CALL	RandomResult		;
		LD	[wSubStage],A		;

		LD	A,BANK(BoardGame)	;Page in John's code.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;



; ***************************************************************************
; * GmbInitBoard ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbInitBoard::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		CALL	SetBitmap21x14		;

		LD	A,LOW(VblGmbBoard)	;
		LD	[wVblVector],A		;

		LD	A,%11110101		;Bgd_chr8000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
		LD	A,%11100101		;Wnd_scr9C00,Wnd_on, then
		LDH	[hLycLCDC],A		;Bgd_chr9000,Obj_on.

		LD	A,BANK(BBOARDS1_MAP)	;Locate MAP data.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	A,[wBoardMapLo]		;
		LD	L,A			;
		LD	A,[wBoardMapHi]		;
		LD	H,A			;

		LD	DE,wMapData		;Decompress map data.
		CALL	SwdDecode		;

		LD	A,BANK(BBOARDS_CHR)	;
		LDH	[hChrBank],A		;

		LD	A,BANK(BBOARDS_BLK)	;
		LDH	[hBlkBank],A		;

		LD	HL,BBOARDS_BLK		;&$3FFF
		LD	A,L			;
		LD	[hTmpLo],A		;
		LD	A,H			;
		AND	$3F
		LD	[hTmpHi],A		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		JP	FixupBoard		;



; ***************************************************************************
; * GmbMapRefresh ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen is black (because this routine      *                                                          *
; ***************************************************************************

GmbMapRefresh::	LD	D,21			;Width
		LD	E,15			;Height
		CALL	GmbMapPaint		;

;		CALL	DmaBitmap21x14		;Blit the complete screen.

		CALL	SloBitmap21x14		;Blit the complete screen.

		RET				;All Done.



; ***************************************************************************
; * GmbMapPaint ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbMapPaint::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,D			;
		LD	[wColCnt],A		;
		LD	A,E			;
		LD	[wRowCnt],A		;

		LD	H,HIGH(wTblDivide3)	;Convert chr coordinates to
		LD	L,B			;blk coordinates (x2).
		LD	D,[HL]			;
		LD	L,C			;
		LD	E,[HL]			;

		LD	HL,wTblMapLine		;Use blk coordinates to
		LD	A,E			;calc map address.
		ADD	L			;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		ADD	D			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;

.Skip0:		LD	A,D			;Calc X cols left in block.
		RRCA				;
		ADD	D			;
		SUB	B			;
		CPL				;
		INC	A			;
;		ADD	3			;
		LD	B,A			;

		LD	A,E			;Calc Y rows left in block.
		RRCA				;
		ADD	E			;
		SUB	C			;
		CPL				;
		INC	A			;
;		ADD	3			;
		LD	C,A			;

		LD	DE,$C800		;Start at top-lft of bitmap.

.Loop0:		PUSH	DE			;Preserve scr ptr.

		PUSH	HL			;Preserve map ptr.
		PUSH	BC			;Preserve blk XY.

		LD	A,[wRowCnt]		;
		LD	[wRowTmp],A		;

.Loop1:		PUSH	HL			;Preserve map ptr.
		PUSH	BC			;Preserve blk XY.

		LD	A,[HLI]			;Get the blk address from the
		LD	H,[HL]			;map.
		LD	L,A			;

		LDH	A,[hBlkBank]		;Bank in the blk data.
		BIT	6,H			;
		JR	Z,.Skip1		;
		INC	A			;
.Skip1:		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		RES	7,H			;
		SET	6,H			;

		LD	A,C			;Add on the XY offset within
		ADD	A			;the blk.
		ADD	C			;
		ADD	B			;
		ADD	A			;
		INC	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;

.Skip2:		LD	A,[HLD]			;Get the chr number from the
		LD	C,A			;blk.
		AND	$07			;
		LD	B,A			;
		LD	L,[HL]			;

		LD	A,C			;Calc source chr bank.
		AND	$E0			;
		RLCA				;
		RLCA				;
		RLCA				;
		LD	H,A			;
		LDH	A,[hChrBank]		;
		ADD	H			;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,C			;Calc source chr addr.
		AND	$18			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	H,A			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		SET	6,H			;

		LD	A,[HLI]			;Copy byte $0.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $1.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $2.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $3.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $4.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $5.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $6.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $7.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $8.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $9.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $A.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $B.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $C.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $D.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $E.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;Copy byte $F.
		LD	[DE],A			;
		INC	DE			;

		POP	BC			;Restore blk XY.
		POP	HL			;Restore map ptr.

		LD	A,3			;Move to next row in blk.
		INC	C			;
		SUB	C			;
		JR	NZ,.Skip3		;
		LD	C,A			;

		LD	A,[wMapData+6]		;Move to next row in map.
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip3		;
		INC	H			;

.Skip3:		LD	A,[wRowTmp]		;Any more rows ?
		DEC	A			;
		LD	[wRowTmp],A		;
		JP	NZ,.Loop1		;

		POP	BC			;Restore blk XY.
		POP	HL			;Restore map ptr.

		LD	A,3			;Move to next col in blk.
		INC	B			;
		SUB	B			;
		JR	NZ,.Skip4		;
		LD	B,A			;

		INC	HL			;Move to next col in map.
		INC	HL			;

.Skip4:		POP	DE			;Restore scr ptr.

		LD	A,255&$00F0		;Move to next col in scr
		ADD	E			;assuming a 15 chr high
		LD	E,A			;dst bitmap.
		LD	A,$00F0>>8		;
		ADC	D			;
		LD	D,A			;

		LD	A,[wColCnt]		;Any more columns ?
		DEC	A			;
		LD	[wColCnt],A		;
		JP	NZ,.Loop0		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * DoVblGmbBoard ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This routine MUST be in the same page as VblDoNothing().    *
; ***************************************************************************

DoVblGmbBoard::	LD	A,%11110101		;Bgd_chr8000,Obj_off,
		LDIO	[rLCDC],A		;Bgd_scr9800,Bgd_on,

		LD	A,15			;
		LDIO	[rLYC],A		;

		LD	A,LOW(LycGmbBoard0)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.

		RET				;All Done.


; ***************************************************************************
; * DoLycGmbBoard0 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This routine MUST be in the same page as VblDoNothing().    *
; ***************************************************************************

DoLycGmbBoard0::LDIO	A,[rSTAT]		;Wait for next HBL.
		AND	%11			;
		JR	NZ,DoLycGmbBoard0	;

		LD	A,%11110111		;Bgd_chr8000,Obj_on,
		LDIO	[rLCDC],A		;Bgd_scr9800,Bgd_on,

		LD	A,64			;
		LDIO	[rLYC],A		;

		LD	A,LOW(LycGmbBoard1)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.

		POP	AF			;
		RETI				;



; ***************************************************************************
; * DoLycGmbBoard1 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This routine MUST be in the same page as VblDoNothing().    *
; ***************************************************************************

DoLycGmbBoard1::LDIO	A,[rSTAT]		;Wait for next HBL.
		AND	%11			;
		JR	NZ,DoLycGmbBoard1	;

		LD	A,%11100111		;Bgd_chr9000,Obj_on,
		LDIO	[rLCDC],A		;Bgd_scr9800,Bgd_on,

		LD	A,127			;
		LDIO	[rLYC],A		;

		LD	A,LOW(LycGmbBoard2)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.

		POP	AF			;
		RETI				;



; ***************************************************************************
; * DoLycGmbBoard2 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This routine MUST be in the same page as VblDoNothing().    *
; ***************************************************************************

DoLycGmbBoard2::LDIO	A,[rSTAT]		;Wait for next HBL.
		AND	%11			;
		JR	NZ,DoLycGmbBoard2	;

		LD	A,%11100101		;Bgd_chr9000,Obj_off,
		LDIO	[rLCDC],A		;Bgd_scr9800,Bgd_on,

		LD	A,15			;
		LDIO	[rLYC],A		;

		LD	A,LOW(LycGmbBoard0)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.

		POP	AF			;
		RETI				;



; ***************************************************************************
; * CgbInitBoard ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbInitBoard::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

;		LD	HL,IDX_CBOARDSRGB	;Locate RGB data.
;		CALL	FindInFileSys		;

		LD	A,BANK(CBOARDS_RGB)	;Locate RGB data.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	HL,CBOARDS_RGB		;

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	DE,wBcpArcade		;Transfer RGB data.
		LD	BC,64			;
		CALL	MemCopy			;

		LD	HL,TblMarkerSprRgb	;Transfer RGB data.
		LD	DE,wOcpArcade		;
		LD	BC,64			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

;		LD	A,[wBoardMapLo]		;Locate MAP data.
;		LD	L,A			;
;		LD	A,[wBoardMapHi]		;
;		LD	H,A			;
;		CALL	FindInFileSys		;

		LD	A,BANK(CBOARDS1_MAP)	;Locate MAP data.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	A,[wBoardMapLo]		;
		LD	L,A			;
		LD	A,[wBoardMapHi]		;
		LD	H,A			;

		LD	DE,wMapData		;Decompress map data.
		CALL	SwdDecode		;

		LD	A,BANK(CBOARDS_CHR)	;
		LDH	[hChrBank],A		;

		LD	A,BANK(CBOARDS_BLK)	;
		LDH	[hBlkBank],A		;

		LD	HL,CBOARDS_BLK		;&$3FFF
		LD	A,L			;
		LD	[hTmpLo],A		;
		LD	A,H			;
		AND	$3F
		LD	[hTmpHi],A		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		XOR	A			;
		LDH	[hBlitXY],A		;
		LDH	[hBlitYX],A		;

		LD	A,LOW(LycScroll)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblScroll)	;
		LD	[wVblVector],A		;

		JP	FixupBoard		;

;
;
;

FixupBoard::	LD	HL,wTblDivide3		;Create the divide-by-3
		LD	B,85			;lookup table for mapping
		XOR	A			;chr coords to blk coords.
.Loop0:		LD	[HLI],A			;Actually stores 2*(n/3).
		LD	[HLI],A			;
		LD	[HLI],A			;
		INC	A			;
		INC	A			;
		DEC	B			;
		JR	NZ,.Loop0		;

		LD	A,[wMapData+6]		;Create the lookup table for
		INC	A			;finding the start of each
		ADD	A			;line of the map.
		LD	C,A			;
		LD	B,0			;
		LD	A,[wMapData+7]		;
		INC	A			;
		LD	HL,wMapData+8		;
		LD	DE,wTblMapLine		;
.Loop1:		PUSH	AF			;
		LD	A,L			;
		LD	[DE],A			;
		INC	E			;
		LD	A,H			;
		LD	[DE],A			;
		INC	E			;
		ADD	HL,BC			;
		POP	AF			;
		DEC	A			;
		JR	NZ,.Loop1		;

		LD	A,[wMapData+6]		;Convert map data itself from
		INC	A			;blk numbers to blk addresses
		LD	C,A			;(assuming a 3x3 blk).
		LD	A,[wMapData+7]		;
		INC	A			;
		LD	B,A			;
		LD	DE,wMapData+8		;
.Loop2:		PUSH	BC			;
.Loop3:		PUSH	BC			;
		LD	A,[DE]			;
		INC	DE			;
		LD	L,A			;
		LD	A,[DE]			;
		DEC	DE			;
		LD	H,A			;
		ADD	HL,HL			;
		LD	C,L			;
		LD	B,H			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;
		LD	A,[hTmpLo]		;
		ADD	L			;
		LD	[DE],A			;
		INC	DE			;
		LD	A,[hTmpHi]		;
		ADC	H			;
		LD	[DE],A			;
		INC	DE			;
		POP	BC			;
		DEC	B			;
		JR	NZ,.Loop3		;
		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop2		;

		LD	A,[wMapData+6]		;
		INC	A			;
		ADD	A			;
		LD	[wMapData+6],A		;
		LD	A,[wMapData+7]		;
		INC	A			;
		LD	[wMapData+7],A		;

		RET				;



; ***************************************************************************
; * CgbMapPaint ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B  = X chr coordinate                                       *
; *             C  = Y chr coordinate                                       *
; *             D  = Width                                                  *
; *             E  = Height                                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapPaint::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,D			;
		LD	[wColCnt],A		;
		LD	A,E			;
		LD	[wRowCnt],A		;

		LD	H,HIGH(wTblDivide3)	;Convert chr coordinates to
		LD	L,B			;blk coordinates (x2).
		LD	D,[HL]			;
		LD	L,C			;
		LD	E,[HL]			;

		LD	HL,wTblMapLine		;Use blk coordinates to
		LD	A,E			;calc map address.
		ADD	L			;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		ADD	D			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;

.Skip0:		LD	A,D			;Calc X cols left in block.
		RRCA				;
		ADD	D			;
		SUB	B			;
		CPL				;
		INC	A			;
;		ADD	3			;
		LD	D,A			;

		LD	A,E			;Calc Y rows left in block.
		RRCA				;
		ADD	E			;
		SUB	C			;
		CPL				;
		INC	A			;
;		ADD	3			;
		LD	E,A			;

		PUSH	DE			;Preserve blk XY.

		LD	A,B			;Calc offset into scr.
		AND	$1F			;
		LD	E,A			;
		LD	A,C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	D,A			;
		AND	$E0			;
		OR	A,E			;
		LD	E,A			;
		LD	A,D			;
		AND	$03			;
		OR	SCROLL_SCR_LO>>8	;
		LD	D,A			;

		POP	BC			;Restore blk XY.

.Loop0:		PUSH	DE			;Preserve scr ptr.

		PUSH	HL			;Preserve map ptr.
		PUSH	BC			;Preserve blk XY.

		LD	A,[wColCnt]		;
		LD	[wColTmp],A		;

.Loop1:		PUSH	DE			;Preserve scr ptr.

		PUSH	HL			;Preserve map ptr.
		PUSH	BC			;Preserve blk XY.

		LD	A,[HLI]			;Get the blk address from the
		LD	H,[HL]			;map.
		LD	L,A			;

		LDH	A,[hBlkBank]		;Bank in the blk data.
		BIT	6,H			;
		JR	Z,.Skip1		;
		INC	A			;
.Skip1:		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		RES	7,H			;
		SET	6,H			;

		LD	A,C			;Add on the XY offset within
		ADD	A			;the blk.
		ADD	C			;
		ADD	B			;
		ADD	A			;
		INC	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;

.Skip2:		LD	A,[HLD]			;Get the chr number from the
		LD	C,A			;blk.
		AND	$07			;
		LD	B,A			;
		LD	L,[HL]			;

		LD	A,C			;Calc source chr bank.
		AND	$E0			;
		RLCA				;
		RLCA				;
		RLCA				;
		LD	H,A			;
		LDH	A,[hChrBank]		;
		ADD	H			;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,C			;Calc source chr addr.
		AND	$18			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	H,A			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		SET	6,H			;

		LD	A,[DE]			;Get the character number
		LD	C,A			;from the scr.
		SET	2,D			;
		LD	A,[DE]			;
		AND	$08			;
		OR	B			;
		LD	[DE],A			;
		RES	2,D			;
		RRCA				;
		RRCA				;
		RRCA				;
		AND	$01			;
		LD	B,A			;

		LD	A,C			;Calc vram addr.
		SWAP	A			;
		AND	$F0			;
		LD	E,A			;
		LD	A,C			;
		SWAP	A			;
		AND	$0F			;
		XOR	$08			;
		ADD	$88			;
		LD	D,A			;

		LD	A,B			;Page in the vram bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		CALL	wChrXfer		;Dump a single chr.

		POP	BC			;Restore blk XY.
		POP	HL			;Restore map ptr.

		LD	A,3			;Move to next col in blk.
		INC	B			;
		SUB	B			;
		JR	NZ,.Skip3		;
		LD	B,A			;

		INC	HL			;Move to next col in map.
		INC	HL			;

.Skip3:		POP	DE			;Restore scr ptr.

		INC	E			;Move to next col in scr.
		LD	A,E			;
		AND	$1F			;
		JR	NZ,.Skip4		;
		LD	A,E			;
		SUB	$20			;
		LD	E,A			;

.Skip4:		LD	A,[wColTmp]		;Any more columns ?
		DEC	A			;
		LD	[wColTmp],A		;
		JP	NZ,.Loop1		;

		POP	BC			;Restore blk XY.
		POP	HL			;Restore map ptr.

		LD	A,3			;Move to next row in blk.
		INC	C			;
		SUB	C			;
		JR	NZ,.Skip5		;
		LD	C,A			;

		LD	A,[wMapData+6]		;Move to next row in map.
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip5		;
		INC	H			;

.Skip5:		POP	DE			;Restore scr ptr.

		LD	A,E			;Move to next scr row.
		ADD	32			;
		LD	E,A			;
		JR	NC,.Skip6		;
		INC	D			;
		RES	2,D			;

.Skip6:		LD	A,[wRowCnt]		;Any more rows ?
		DEC	A			;
		LD	[wRowCnt],A		;
		JP	NZ,.Loop0		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * UnlockStories ()                                                        *
; * LockStories ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

UnlockStories::	LD	A,7			;
		JR	SaveStoryLock		;

LockStories::	XOR	A			;

SaveStoryLock::	LD	HL,wStoryUnlocked	;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LD	A,BACKUP_NONE		;Save the unlocked state.
		LD	[wWhichGame],A		;
		JP	SaveBackup		;










