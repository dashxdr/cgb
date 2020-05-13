; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BOARDHI.ASM                                                    MODULE **
; **                                                                       **
; ** Game Board.                                                           **
; **                                                                       **
; ** Last modified : 25 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ** N.B. MUST BE IN SAME BANK AS BITMAPHI.ASM                             **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"boardhi",CODE,BANK[$3F]
		section $3F
;
;
;

DELAY_ONSQUARE	EQU	5

MAX_XSCROLL	EQU	8
MAX_YSCROLL	EQU	8

GMB_BOARD_XMIN	EQU	0
GMB_BOARD_XMAX	EQU	(528-160)
GMB_BOARD_YMIN	EQU	0
GMB_BOARD_YMAX	EQU	(1008-112)

CGB_BOARD_XMIN	EQU	0
CGB_BOARD_XMAX	EQU	(528-160)
CGB_BOARD_YMIN	EQU	0
CGB_BOARD_YMAX	EQU	(1008-144)
CGB_BOARD_MOVE	EQU	4

;
; Tables of Information for each board.
;

TblBoards::	DW	GmbBoardInfoS1		;Gmb Board 0
		DW	CgbBoardInfoS1		;Cgb Board 0

		DW	GmbBoardInfoS2		;Gmb Board 1
		DW	CgbBoardInfoS2		;Cgb Board 1

		DW	GmbBoardInfoS3		;Gmb Board 2
		DW	CgbBoardInfoS3		;Cgb Board 2

		DW	GmbBoardInfoM1		;Gmb Board 3
		DW	CgbBoardInfoM1		;Cgb Board 3

		DW	GmbBoardInfoM2		;Gmb Board 4
		DW	CgbBoardInfoM2		;Cgb Board 4

		DW	GmbBoardInfoM3		;Gmb Board 5
		DW	CgbBoardInfoM3		;Cgb Board 5

		DW	GmbBoardInfoM4		;Gmb Board 6
		DW	CgbBoardInfoM4		;Cgb Board 6

GmbBoardInfoS1::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$1B0	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$050	;
		DW	TblSquaresS1		;
		DW	TblNoGuards		;
		DW	BBOARDS1_MAP		;
		DW	IDX_BSMALLS1PKG		;
		DB	0-1,0-38		;Small board X/Y offsets.
		DB	150,99			;Small board button posn.

CgbBoardInfoS1::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$1B0	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$050	;
		DW	TblSquaresS1		;
		DW	TblNoGuards		;
		DW	CBOARDS1_MAP		;
		DW	IDX_CSMALLS1PKG		;
		DB	0-1,0-38		;Small board X/Y offsets.
		DB	150,99			;Small board button posn.

GmbBoardInfoS2::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$120	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$050	;
		DW	TblSquaresS2		;
		DW	TblNoGuards		;
		DW	BBOARDS2_MAP		;
		DW	IDX_BSMALLS2PKG		;
		DB	0-1,0-22		;Small board X/Y offsets.
		DB	150,115			;Small board button posn.

CgbBoardInfoS2::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$120	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$050	;
		DW	TblSquaresS2		;
		DW	TblNoGuards		;
		DW	CBOARDS2_MAP		;
		DW	IDX_CSMALLS2PKG		;
		DB	0-1,0-22		;Small board X/Y offsets.
		DB	150,115			;Small board button posn.

GmbBoardInfoS3::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$018	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$030	;
		DW	TblSquaresS3		;
		DW	TblNoGuards		;
		DW	BBOARDS3_MAP		;
		DW	IDX_BSMALLS3PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

CgbBoardInfoS3::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$018	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$030	;
		DW	TblSquaresS3		;
		DW	TblNoGuards		;
		DW	CBOARDS3_MAP		;
		DW	IDX_CSMALLS3PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

GmbBoardInfoM1::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$018	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$050	;
		DW	TblSquaresM1		;
		DW	TblGuardsM1		;
		DW	BBOARDM1_MAP		;
		DW	IDX_BSMALLM1PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

CgbBoardInfoM1::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$018	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$050	;
		DW	TblSquaresM1		;
		DW	TblGuardsM1		;
		DW	CBOARDM1_MAP		;
		DW	IDX_CSMALLM1PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

GmbBoardInfoM2::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$018	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$050	;
		DW	TblSquaresM2		;
		DW	TblGuardsM2		;
		DW	BBOARDM2_MAP		;
		DW	IDX_BSMALLM2PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	150,131			;Small board button posn.

CgbBoardInfoM2::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$018	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$050	;
		DW	TblSquaresM2		;
		DW	TblGuardsM2		;
		DW	CBOARDM2_MAP		;
		DW	IDX_CSMALLM2PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	150,131			;Small board button posn.

GmbBoardInfoM3::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$018	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$050	;
		DW	TblSquaresM3		;
		DW	TblGuardsM3		;
		DW	BBOARDM3_MAP		;
		DW	IDX_BSMALLM3PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

CgbBoardInfoM3::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$018	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$050	;
		DW	TblSquaresM3		;
		DW	TblGuardsM3		;
		DW	CBOARDM3_MAP		;
		DW	IDX_CSMALLM3PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

GmbBoardInfoM4::DW	GMB_BOARD_XMIN		;
		DW	GMB_BOARD_YMIN+$018	;
		DW	GMB_BOARD_XMAX		;
		DW	GMB_BOARD_YMAX-$030	;
		DW	TblSquaresM4		;
		DW	TblNoGuards		;
		DW	BBOARDM4_MAP		;
		DW	IDX_BSMALLM4PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

CgbBoardInfoM4::DW	CGB_BOARD_XMIN		;
		DW	CGB_BOARD_YMIN+$018	;
		DW	CGB_BOARD_XMAX		;
		DW	CGB_BOARD_YMAX-$030	;
		DW	TblSquaresM4		;
		DW	TblNoGuards		;
		DW	CBOARDM4_MAP		;
		DW	IDX_CSMALLM4PKG		;
		DB	0-1,0-6			;Small board X/Y offsets.
		DB	9,131			;Small board button posn.

;
; Offsets into wBoardBeast
;

PLYR_CUR_X	EQU	0
PLYR_CUR_Y	EQU	2
PLYR_NEW_X	EQU	4
PLYR_NEW_Y	EQU	6
PLYR_OLD_X	EQU	8
PLYR_OLD_Y	EQU	10
PLYR_MIX	EQU	12
PLYR_FOCUS	EQU	13

;
;
;

BeastPlayICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQBEASTPKG
		DW	IDX_CQBEASTPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BEAST'S TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	138
		DB	0
		ELSE
		DB	ICMD_WHOMSTR,138
		ENDC
		DB	ICMD_END

BeastSkipICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQBEASTPKG
		DW	IDX_CQBEASTPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BEAST SKIPS A TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DW	142
		DB	0
		ELSE
		DB	ICMD_FONTXOR,GMB_PALF+CGB_PALF+CGB_PAL0
		DB	ICMD_WHOMSTR,142
		ENDC
		DB	ICMD_END

BellePlayICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQBELLEPKG
		DW	IDX_CQBELLEPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BELLE'S TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	139
		DB	0
		ELSE
		DB	ICMD_WHOMSTR,139
		ENDC
		DB	ICMD_END

BelleSkipICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQBELLEPKG
		DW	IDX_CQBELLEPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BELLE SKIPS A TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DW	143
		DB	0
		ELSE
		DB	ICMD_FONTXOR,GMB_PALF+CGB_PALF+CGB_PAL0
		DB	ICMD_WHOMSTR,143
		ENDC
		DB	ICMD_END

PottsPlayICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQPOTTSPKG
		DW	IDX_CQPOTTSPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"MRS. POTTS' TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	140
		DB	0
		ELSE
		DB	ICMD_WHOMSTR,140
		ENDC
		DB	ICMD_END

PottsSkipICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQPOTTSPKG
		DW	IDX_CQPOTTSPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"MRS. POTTS SKIPS A TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DW	144
		DB	0
		ELSE
		DB	ICMD_FONTXOR,GMB_PALF+CGB_PALF+CGB_PAL0
		DB	ICMD_WHOMSTR,144
		ENDC
		DB	ICMD_END

LumirPlayICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQLUMIRPKG
		DW	IDX_CQLUMIRPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"LUMIERE'S TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	141
		DB	0
		ELSE
		DB	ICMD_WHOMSTR,141
		ENDC
		DB	ICMD_END

LumirSkipICmd::	DB	ICMD_FONT
		IF	VERSION_JAPAN
		DW	FontOlde
		ELSE
		DW	FontLite
		ENDC
		DB	ICMD_NEWPKG
		DW	IDX_BQLUMIRPKG
		DW	IDX_CQLUMIRPKG
		IF	0
		DB	ICMD_FASTSTR
		DB	80, 13,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"LUMIERE SKIPS A TURN",0
		DB	0
		ENDC
		IF	VERSION_JAPAN
		DB	ICMD_FASTSTRN
		DB	70, 16,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DW	145
		DB	0
		ELSE
		DB	ICMD_FONTXOR,GMB_PALF+CGB_PALF+CGB_PAL0
		DB	ICMD_WHOMSTR,145
		ENDC
		DB	ICMD_END

;
;
;

FadeDelayICmd::	DB	ICMD_FADEUP
WaitDelayICmd::	DB	ICMD_DELAY,SHOW_DICE_DELAY
		DB	ICMD_HALT
		DB	ICMD_END

WhomStarsICmd::	DB	ICMD_SPRON
		DW	wSprite0
		DB	8,25
		DW	InitMiniStar
		DB	ICMD_HALT
		DB	ICMD_END

WhomPressICmd::	DB	ICMD_SPRON
		DW	wSprite1
		DB	150,32
		DW	DoButtonIcon2
		IF	VERSION_USA
		ELSE
		DB	ICMD_SPRON
		DW	wSprite2
		DB	140,18
		DW	DoSmallMarker
		ENDC
		DB	ICMD_FADEUP
		DB	ICMD_HALT
		DB	ICMD_END

WhomDelayICmd::	IF	VERSION_USA
		ELSE
		DB	ICMD_SPRON
		DW	wSprite2
		DB	140,18
		DW	DoSmallMarker
		ENDC
		DB	ICMD_FADEUP
		DB	ICMD_DELAY,SHOW_DICE_DELAY
		DB	ICMD_HALT
		DB	ICMD_END

PosnPressICmd::	DB	ICMD_SPRON
		DW	wSprite0
		DB	150,134
		DW	DoButtonIcon2
		DB	ICMD_HALT
		DB	ICMD_END
;		DB	ICMD_FADEUP
;		DB	ICMD_HALT
;		DB	ICMD_NOENDFADE
;		DB	ICMD_END

LuckyPressICmd::DB	ICMD_SPRON
		DW	wSprite1
		DB	140,44
		DW	DoButtonIcon
		DB	ICMD_FADEUP
		DB	ICMD_HALT
		DB	ICMD_END

GastnPressICmd::DB	ICMD_SPRON
		DW	wSprite1
		DB	148,134
		DW	DoButtonIcon
		DB	ICMD_FADEUP
		DB	ICMD_HALT
		DB	ICMD_END

;
;
;

PlyrICmdRolled::DB	ICMD_FONT
		DW	FontOlde
		DB	ICMD_FASTSTR
		DB	80, 113,GMB_PALN+CGB_PALN+CGB_PAL0,1

;
;
;

TblStoryLucky::	DB	$1A			;$1A Roll Again
		DB	$1A			;$00 Swap Places
		DB	$34			;$1A Trivia Time
		DB	$4E			;$1A Horseback Ride
		DB	$4E			;$00 Skip A Turn
		DB	$80			;$32 Bonus Star
		DB	$C0			;$40 Magic Mirror
		DB	$DA			;$1A Shortcut
		DB	$FF			;$26 Gaston Shield

TblStoryGastn::	DB	$00			;$00 Out Hunting
		DB	$40			;$40 Gaston Strikes
		DB	$80			;$40 Gaston Loots
		DB	$C0			;$40 Gaston's Grip
		DB	$FF			;$40 Gaston's Trap
		DB	$FF			;$00 Gaston's Grief

TblMultiLucky::	DB	$0E			;$0E Roll Again
		DB	$27			;$19 Swap Places
		DB	$40			;$19 Trivia Time
		DB	$4E			;$0E Horseback Ride
		DB	$4E			;$00 Skip A Turn
		DB	$81			;$33 Bonus Star
		DB	$C1			;$40 Magic Mirror
		DB	$DA			;$19 Shortcut
		DB	$FF			;$26 Gaston Shield

TblMultiGastn::	DB	$00			;$00 Out Hunting
		DB	$33			;$33 Gaston Strikes
		DB	$66			;$33 Gaston Loots
		DB	$A6			;$40 Gaston's Grip
		DB	$D9			;$33 Gaston's Trap
		DB	$FF			;$27 Gaston's Grief

;
;
;

TblGastonStart::DB	1,1,1			;

TblGastonMoves::DB	5,6,7			;

;
;
;

; ***************************************************************************
; * SetupBoard ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SetupBoard::	LD	HL,TblBoards		;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		INC	HL			;
		INC	HL			;
.Skip0:		LD	A,[wBoardMap]		;
		ADD	A			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		LD	DE,wMapXMinLo		;Copy map limits.
		LD	BC,8			;
		CALL	MemCopy			;

		LD	DE,wBoardSqrLo		;Copy map pointers.
		LD	BC,12			;
		JP	MemCopy			;



; ***************************************************************************
; * BoardGame ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardGame::	LD	SP,wStackPointer	;Reset the stack.

		CALL	KillAllSound		;Stop all sound.
		CALL	WaitForVBL		;

		LD	A,[wWhichGame]		;Restarting a game ?
		CP	BACKUP_STORY		;
		JP	Z,StoryBelle		;
		CP	BACKUP_BOARD		;
		JP	Z,BoardPlyrTurn		;

;		XOR	A			;
;		LD	[wBoardMap],A		;

		XOR	A			;Check whether Dave has
		LD	HL,wStructBeast		;passed any game info.
		OR	[HL]			;
		LD	HL,wStructBelle		;
		OR	[HL]			;
		LD	HL,wStructPotts		;
		OR	[HL]			;
		LD	HL,wStructLumir		;
		OR	[HL]			;
		BIT	PFLG_PLAY,A		;
		IF	TRACE_BOARD
		ELSE
		JR	NZ,.Skip0		;
		ENDC

		LD	A,PMSK_PLAY
		LD	[wStructBeast+PLYR_FLAGS],A
		LD	[wStructBelle+PLYR_FLAGS],A
		XOR	A
		LD	[wStructPotts+PLYR_FLAGS],A
		LD	[wStructLumir+PLYR_FLAGS],A
		LD	[wStructGastn+PLYR_FLAGS],A

		XOR	A
		LD	[wStructBeast+PLYR_LEVEL],A
		LD	[wStructBelle+PLYR_LEVEL],A
		LD	[wStructPotts+PLYR_LEVEL],A
		LD	[wStructLumir+PLYR_LEVEL],A
		LD	[wStructGastn+PLYR_LEVEL],A

.Skip0:		CALL	ResetPlayers		;Initialize the game structs.

		IF	TRACE_BOARD
		LD	A,2
		LD	[wStructBeast+PLYR_SQUARE],A
		ENDC

		LD	A,PLYR_GASTN		;Select a random starting
		LD	[wWhichPlyr],A		;player.
		CALL	random			;
		AND	7			;
		INC	A			;
.Loop0:		PUSH	AF			;
		LD	A,[wWhichPlyr]		;
.Loop1:		CALL	FindNextPlyr		;
		CP	PLYR_GASTN		;
		JR	Z,.Loop1		;
		LD	[wWhichPlyr],A		;
		POP	AF			;
		DEC	A			;
		JR	NZ,.Loop0		;

;		CALL	BoardMusic		;Ensure that music is on.

BoardPlyrTurn::	LD	SP,wStackPointer	;Reset the stack.

		LD	A,BACKUP_BOARD		;Save the current game state.
		LD	[wWhichGame],A		;
		CALL	SaveBackup		;

		CALL	SetupBoard		;Locate which board we're on.

		CALL	FindGuardPos		;Locate guard positions.

		CALL	SetPlyrMusic		;Select the plyr's music.

		CALL	BoardMusic		;Ensure that music is on.

		IF	TRACE_BOARD		;
		ELSE				;
		CALL	PlyrShowWhom		;Show whose turn it is.
		ENDC				;

		LD	A,[wWhichPlyr]		;Does this plyr skip this
		CALL	GetPlyrInfo		;turn ?
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_SKIP,[HL]		;
		RES	PFLG_SKIP,[HL]		;
		JR	NZ,BoardPlyrNext	;

		LD	HL,PLYR_LEVEL		;Init this plyr's difficulty
		ADD	HL,BC			;level.
		LD	A,[HL]			;
		LD	[wSubLevel],A		;

		XOR	A			;
		LD	[wSubStage],A		;
		LD	[wSubStars],A		;
		LD	[wSubAward],A		;

		IF	TRACE_BOARD		;
		ELSE				;
		CALL	PlyrDiceShow		;Show the dice roll.
		ENDC				;

		IF	TRACE_BOARD		;Fake a dice roll.
		LD	A,2			;
		LD	[wPlyrMoves],A		;
		ENDC				;

		CALL	PlyrBigBoard		;Show the game board.

		IF	DEBUG			;
;		JR	BoardPlyrNext		;
		ENDC				;

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,[wWhichPlyr]		;Find out which type of
		LD	[wFocusPlyr],A		;square we're on.
		CALL	TypePlyrSquare		;

;		IF	DEBUG			;
;		LD	A,SQR_LUCKY		;*DEBUG* Override square.
;		LD	A,SQR_GASTN		;*DEBUG* Override square.
;		LD	A,SQR_COGGS		;*DEBUG* Override square.
;		LD	A,SQR_DOORS		;*DEBUG* Override square.
;		LD	A,SQR_POTTS		;*DEBUG* Override square.
;		ENDC				;

		CALL	BoardLaunch		;Launch the subgame.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		LD	A,[wWhichPlyr]		;Got 3 or more stars ?
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_STARS		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		SUB	MAX_STARS		;
		JR	C,BoardPlyrNext		;
		LD	[HL],A			;
		LD	[wSubStars],A		;

;		CALL	BoardMusic		;Ensure that music is on.

		CALL	BoardBonus		;Launch the bonus game.

BoardPlyrNext::	LD	A,[wWhichPlyr]		;Does this plyr roll again
		CALL	GetPlyrInfo		;this turn ?
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_AGAIN,[HL]		;
		RES	PFLG_AGAIN,[HL]		;
		JP	NZ,BoardPlyrTurn	;

		LD	A,[wWhichPlyr]		;Increment the player.
		CALL	FindNextPlyr		;
		LD	[wWhichPlyr],A		;

		JP	BoardPlyrTurn		;

BoardGameOver::	RET				;All Done.

;
;
;

TblPlyrTunes::	DB	17,9,18,16
		DB	17

SetPlyrMusic::	LD	HL,TblPlyrTunes		;
		LD	A,[wWhichPlyr]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		LD	[wBoardMz],A		;
		RET				;

SetRandMusic::	LD	HL,TblPlyrTunes		;
		CALL	random			;
		AND	3			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[wBoardMz]		;
		CP	[HL]			;
		JR	NZ,.Skip1		;
		INC	HL			;
.Skip1:		LD	A,[HL]			;
		LD	[wBoardMz],A		;
		RET				;

BoardMusic::	LD	HL,wBoardMz		;
		LD	A,[wMzNumber]		;
		CP	[HL]			;
		RET	Z			;
		LD	A,[HL]			;
		JP	InitTunePref		;

;
;
;

FindNextPlyr::	INC	A			;
		CP	5			;
		JR	C,.Skip0		;
		XOR	A			;
.Skip0:		PUSH	AF			;
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		POP	AF			;
		BIT	PFLG_PLAY,[HL]		;
		JR	Z,FindNextPlyr		;
		RET				;

;
;
;

ResetPlayers::	LD	DE,wStructBeast		;Initialize the game
		CALL	ResetPlayer		;structures.
		LD	DE,wStructBelle		;
		CALL	ResetPlayer		;
		LD	DE,wStructPotts		;
		CALL	ResetPlayer		;
		LD	DE,wStructLumir		;
		CALL	ResetPlayer		;
		LD	DE,wStructGastn		;
;		CALL	ResetPlayer		;

ResetPlayer::	LD	HL,PLYR_FLAGS		;
		ADD	HL,DE			;

		BIT	PFLG_PLAY,[HL]		;
		LD	A,1			;
		JR	NZ,.Skip0		;
		LD	A,0			;
.Skip0:		LD	HL,PLYR_SQUARE		;
		ADD	HL,DE			;
		LD	[HL],A			;

		XOR	A			;

		LD	HL,PLYR_STARS		;
		ADD	HL,DE			;
		LD	[HLI],A			;PLYR_STARS
		LD	[HLI],A			;PLYR_MODIFIER
		LD	[HLI],A			;PLYR_SHOETRAP
		LD	[HLI],A			;PLYR_SHIELD

		RET				;



; ***************************************************************************
; * PlyrShowWhom ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrShowWhom::	CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	A,WRKBANK_PAL		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		LD	HL,TblMarkerSprRgb	;
		LD	DE,wOcpArcade		;
		LD	BC,64			;
		CALL	MemCopy			;
		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	A,6			;
		LD	[wPalCount],A		;
		LD	HL,PAL_CMINISTR		;
		CALL	AddSpritePal		;

.Skip0:		CALL	InitShowWhom		;Initialize plyr sprites.

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;what to show (skip or play).
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_SKIP,[HL]		;
		LD	HL,PLYR_QSPLAY		;
		JR	Z,.Skip1		;
		LD	HL,PLYR_QSSKIP		;
.Skip1:		ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		CALL	NextICmd		;

		LD	A,LOW(DrawMiniStar)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DrawMiniStar)	;
		LD	[wJmpDraw+2],A		;

		LD	BC,WhomStarsICmd	;
		CALL	NextICmd		;

		LD	HL,WhomPressICmd	;Use wWhichPlyr to determine
		LD	DE,WhomDelayICmd	;whether to wait for a delay
		JP	BoardWhichICmd		;or a joypad.

;
; ICMD_WHOMSTR -
;

ICmdWhomStr::	LD	A,LOW(FontLite)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontLite)	;
		LD	[wFontHi],A		;

		IF	VERSION_USA		;
		LD	A,150			;Set intro text bounds.
		ELSE				;
		LD	A,130			;Set intro text bounds.
		ENDC				;
		LD	[wStringL1Width],A	;
		LD	[wStringL2Width],A	;
		XOR	A			;Set intro text bounds.
		LD	[wStringL3Width],A	;
		LD	[wStringL4Width],A	;
		LD	[wStringL5Width],A	;

		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		CALL	SplitString		;

		LD	BC,ICmdTurn2L		;
		LD	A,[wStringLine2]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdTurn1L		;

.Print:		CALL	NextICmd		;

		POP	BC			;

		JP	NextICmd		;

;
;
;

		IF	VERSION_USA

ICmdTurn2L::	DB	ICMD_FASTSTRP
		DB	80,  9+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	80,  9+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	0
		DB	ICMD_HALT

ICmdTurn1L::	DB	ICMD_FASTSTRP
		DB	80, 13+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	0
		DB	ICMD_HALT

		ELSE

ICmdTurn2L::	DB	ICMD_FASTSTRP
;		DB	70,  9+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	70, 10+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	70,  9+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	0
		DB	ICMD_HALT

ICmdTurn1L::	DB	ICMD_FASTSTRP
		DB	70, 13+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	0
		DB	ICMD_HALT

		ENDC



; ***************************************************************************
; * InitShowWhom ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitShowWhom::	RET				;All Done.



; ***************************************************************************
; * InitMiniStar ()                                                         *
; ***************************************************************************
; * Icon for miniature star                                                 *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

InitMiniStar::	LDHL	SP,SPR_FLIP+2		;
		LD	[HL],$00		;

		LDHL	SP,SPR_COLR+2		;
		LD	[HL],$06		;

		LD	DE,IDX_BMINISTR		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	DE,IDX_CMINISTR		;

.Skip0:		LDHL	SP,SPR_FRAME+2		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_DRAW

		RET				;



; ***************************************************************************
; * DrawMiniStr ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawMiniStar::	LD	[wSprPlotSP],SP		;Preserve SP.

		PUSH	DE			;

		LD	A,[wWhichPlyr]		;How many stars does this
		CALL	GetPlyrInfo		;player have ?
		LD	HL,PLYR_STARS		;
		ADD	HL,BC			;

		POP	DE			;

		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Skip0		;

		LDH	[hTmpLo],A		;Preserve counter.

		LD	SP,wSprite0		;Draw star sprites.

		LDHL	SP,SPR_FLAGS		;Enable sprite drawing.
		SET	FLG_PLOT,[HL]		;

		LDHL	SP,SPR_SCR_X		;
		LD	A,[HL]			;
		LDH	[hTmpHi],A		;

		LDH	A,[hTmpLo]		;Restore counter.

.Loop0:		LDH	[hTmpLo],A		;Preserve counter.

		CALL	SprDraw			;Draw the sprite.

		LDHL	SP,SPR_SCR_X		;
		LD	A,[HL]			;
		ADD	11			;
		LD	[HL],A			;

		LDH	A,[hTmpLo]		;Restore counter.
		DEC	A			;
		JR	NZ,.Loop0		;

		LDHL	SP,SPR_FLAGS		;Disable sprite drawing.
		RES	FLG_PLOT,[HL]		;

		LDHL	SP,SPR_SCR_X		;
		LDH	A,[hTmpHi]		;
		LD	[HL],A			;

.Skip0:		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * GmbBigBoard ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrBigBoard::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JP	Z,CgbBigBoard		;

		JP	GmbBigBoard		;



; ***************************************************************************
; * DrawBigBoard ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawBigBoard::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JP	Z,CgbBoardDraw		;

		JP	GmbBoardDraw		;



; ***************************************************************************
; * SetCameraToWho ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A  = Number of plyr to set camera to                        *
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SetCameraToWho::CALL	GetPlyrInfo		;

		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_CUR_X		;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	HL,0-80			;Offset.
		ADD	HL,BC			;
		CALL	CamCmpMinX		;

		LD	HL,0-112		;Offset.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	Z,.Skip0		;

		LD	HL,0-90			;Offset.

.Skip0:		ADD	HL,DE			;
		CALL	CamCmpMinY		;

		RET				;All Done.

;
;
;

CamCmpMinX::	LD	A,[wMapXMinLo]		;Calc DE = MinX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapXMinHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	NZ,CamCmpMaxX		;

		ADD	HL,BC			;Calc HL = MinX.

CamCmpMaxX::	LD	A,[wMapXMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapXMaxHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	Z,CamSavScrX		;

		ADD	HL,BC			;Calc HL = MaxX.

CamSavScrX::	LD	A,L			;Put Y coordinate.
		LDH	[hCamXLo],A		;
		LD	A,H			;
		LDH	[hCamXHi],A		;

		RET				;All Done.

;
;
;

CamCmpMinY::	LD	A,[wMapYMinLo]		;Calc DE = MinX - ScrX.
		SUB	L			;
		LD	E,A			;
		LD	A,[wMapYMinHi]		;
		SBC	H			;
		LD	D,A			;

		BIT	7,A			;Overflow ?
		JR	NZ,CamCmpMaxY		;

		ADD	HL,DE			;Calc HL = MinX.

CamCmpMaxY::	LD	A,[wMapYMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L			;
		LD	E,A			;
		LD	A,[wMapYMaxHi]		;
		SBC	H			;
		LD	D,A			;

		BIT	7,A			;Overflow ?
		JR	Z,CamSavScrY		;

		ADD	HL,DE			;Calc HL = MaxX.

CamSavScrY::	LD	A,L			;Put Y coordinate.
		LDH	[hCamYLo],A		;
		LD	A,H			;
		LDH	[hCamYHi],A		;

		RET				;All Done.



; ***************************************************************************
; * CgbMapToCamera ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbMapToCamera::LDH	A,[hCamXLo]		;
		LD	L,A			;
		LDH	A,[hCamXHi]		;
		LD	H,A			;
		CALL	ScrCmpMinX		;

		LDH	A,[hCamYLo]		;
		LD	L,A			;
		LDH	A,[hCamYHi]		;
		LD	H,A			;
		CALL	ScrCmpMinY		;

		LDH	A,[hScrXLo]		;
		AND	$F8			;
		LD	B,A			;
		LDH	A,[hScrXHi]		;
		AND	$07			;
		OR	B			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	B,A			;
		LDH	[hScxBlk],A		;

		LDH	A,[hScrYLo]		;
		AND	$F8			;
		LD	C,A			;
		LDH	A,[hScrYHi]		;
		AND	$07			;
		OR	C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	C,A			;
		LDH	[hScyBlk],A		;

		XOR	A			;
		LDH	[hScxChg],A		;
		LDH	[hScyChg],A		;

		RET				;



; ***************************************************************************
; * ScrollBoard ()                                                          *
; ***************************************************************************
; * Scroll the screen and reposition the sprites                            *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollBoard::	XOR	A			;
		LDH	[hScxChg],A		;
		LDH	[hScyChg],A		;

		CALL	ScrollBoardLR		;
		CALL	ScrollBoardUD		;

		LDH	A,[hScxBlk]		;Changed current X block
		LDH	[hScxOld],A		;position ?
		LD	D,A			;
		LDH	A,[hScrXLo]		;
		AND	$F8			;
		LD	B,A			;
		LDH	A,[hScrXHi]		;
		AND	$07			;
		OR	B			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hScxBlk],A		;

		LDH	A,[hScyBlk]		;Changed current Y block
		LDH	[hScyOld],A		;position ?
		LD	E,A			;
		LDH	A,[hScrYLo]		;
		AND	$F8			;
		LD	C,A			;
		LDH	A,[hScrYHi]		;
		AND	$07			;
		OR	C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hScyBlk],A		;

		LDH	A,[hScxOld]		;
		LD	C,A			;
		LDH	A,[hScxBlk]		;
		SUB	C			;
		CALL	NZ,IntroBoardLR		;

		LDH	A,[hScyOld]		;
		LD	C,A			;
		LDH	A,[hScyBlk]		;
		SUB	C			;
		CALL	NZ,IntroBoardUD		;

		RET				;All Done.



; ***************************************************************************
; * ScrollBoardLR ()                                                        *
; ***************************************************************************
; * Determine if the screen needs to be scrolled horizontally               *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollBoardLR::	LDH	A,[hScrXLo]		;Get ScrX.
		LD	L,A			;
		LDH	A,[hScrXHi]		;
		LD	H,A			;

ScrGetXChg::	LDH	A,[hCamXLo]		;Calc BC = CamX - ScrX.
		SUB	L			;
		LD	C,A			;
		LDH	A,[hCamXHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,B			;
		JR	NZ,ScrNegXChg		;

ScrPosXChg::	OR	A			;
		JR	NZ,ScrMaxXChg		;
		LD	A,C			;
		SUB	MAX_XSCROLL		;
		JR	C,ScrAddXChg		;
ScrMaxXChg::	LD	BC,0+MAX_XSCROLL	;
		JR	ScrAddXChg		;

ScrNegXChg::	INC	A			;
		JR	NZ,ScrMinXChg		;
		LD	A,C			;
		ADD	MAX_XSCROLL		;
		JR	C,ScrAddXChg		;
ScrMinXChg::	LD	BC,0-MAX_XSCROLL	;

ScrAddXChg::	LD	A,C			;Preserve change in position.
		LDH	[hScxChg],A		;

		ADD	HL,BC			;Calc HL = new ScrX.

ScrCmpMinX::	LD	A,[wMapXMinLo]		;Calc DE = MinX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapXMinHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	NZ,ScrCmpMaxX		;

		ADD	HL,BC			;Calc HL = MinX.

ScrCmpMaxX::	LD	A,[wMapXMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapXMaxHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	Z,ScrSavScrX		;

		ADD	HL,BC			;Calc HL = MaxX.

ScrSavScrX::	LD	A,H			;Save new scroll position.
		LDH	[hScrXHi],A		;
		LD	A,L			;
		LDH	[hScrXLo],A		;

		RET				;All Done.




; ***************************************************************************
; * ScrollBoardUD ()                                                        *
; ***************************************************************************
; * Determine if the screen needs to be scrolled vertically                 *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollBoardUD::	LDH	A,[hScrYLo]		;Get ScrX.
		LD	L,A			;
		LDH	A,[hScrYHi]		;
		LD	H,A			;

ScrGetYChg::	LDH	A,[hCamYLo]		;Calc BC = CamX - ScrX.
		SUB	L			;
		LD	C,A			;
		LDH	A,[hCamYHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,B			;
		JR	NZ,ScrNegYChg		;

ScrPosYChg::	OR	A			;
		JR	NZ,ScrMaxYChg		;
		LD	A,C			;
		SUB	MAX_YSCROLL		;
		JR	C,ScrAddYChg		;
ScrMaxYChg::	LD	BC,0+MAX_YSCROLL	;
		JR	ScrAddYChg		;

ScrNegYChg::	INC	A			;
		JR	NZ,ScrMinYChg		;
		LD	A,C			;
		ADD	MAX_YSCROLL		;
		JR	C,ScrAddYChg		;
ScrMinYChg::	LD	BC,0-MAX_YSCROLL	;

ScrAddYChg::	LD	A,C			;Preserve change in position.
		LDH	[hScyChg],A		;

		ADD	HL,BC			;Calc HL = new ScrX.

ScrCmpMinY::	LD	A,[wMapYMinLo]		;Calc DE = MinX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapYMinHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	NZ,ScrCmpMaxY		;

		ADD	HL,BC			;Calc HL = MinX.

ScrCmpMaxY::	LD	A,[wMapYMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L			;
		LD	C,A			;
		LD	A,[wMapYMaxHi]		;
		SBC	H			;
		LD	B,A			;

		BIT	7,A			;Overflow ?
		JR	Z,ScrSavScrY		;

		ADD	HL,BC			;Calc HL = MaxX.

ScrSavScrY::	LD	A,H			;Save new scroll position.
		LDH	[hScrYHi],A		;
		LD	A,L			;
		LDH	[hScrYLo],A		;

		RET				;All Done.



; ***************************************************************************
; * IntroBoardLR ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroBoardLR::	ADD	A			;
		JR	NC,IntroBoardRhs	;

;
; Board moved left.
;

IntroBoardLhs::	LDH	A,[hScxOld]		;Free up the old rhs column.
		ADD	20			;
		LD	B,A			;
		LDH	A,[hScyOld]		;
		LD	C,A			;
		LD	DE,$0113		;
		CALL	CgbMapFree		;

		LDH	A,[hScxBlk]		;Make up the new lhs column.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;

		JR	IntroBoardCol		;

;
; Board moved right.
;

IntroBoardRhs::	LDH	A,[hScxOld]		;Free up the old lhs column.
		LD	B,A			;
		LDH	A,[hScyOld]		;
		LD	C,A			;
		LD	DE,$0113		;
		CALL	CgbMapFree		;

		LDH	A,[hScxBlk]		;Make up the new rhs column.
		ADD	20			;
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;

		JR	IntroBoardCol		;

;
; Board changed column.
;

IntroBoardCol::	PUSH	BC			;
		LD	DE,$0113		;
		CALL	CgbMapAlloc		;
		POP	BC			;
		PUSH	BC			;
		LD	DE,$0113		;
		CALL	CgbMapPaint		;
		POP	BC			;

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

		LD	HL,hBlitYX+3		;
		LD	A,D			;
		LD	[HLD],A			;
		LD	A,E			;
		LD	[HLD],A			;
		LD	A,$13			;
		LD	[HLD],A			;
		LD	A,$01			;
		LD	[HLD],A			;

		RET				;All Done.



; ***************************************************************************
; * IntroBoardUD ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroBoardUD::	ADD	A			;
		JR	NC,IntroBoardBtm	;

;
; Board moved up.
;

IntroBoardTop::	LDH	A,[hScxOld]		;Free up the old btm row.
		LD	B,A			;
		LDH	A,[hScyOld]		;
		ADD	18			;
		LD	C,A			;
		LD	DE,$1501		;
		CALL	CgbMapFree		;

		LDH	A,[hScxBlk]		;Make up the new top row.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;

		JR	IntroBoardRow		;

;
; Board moved down.
;

IntroBoardBtm::	LDH	A,[hScxOld]		;Free up the old top row.
		LD	B,A			;
		LDH	A,[hScyOld]		;
		LD	C,A			;
		LD	DE,$1501		;
		CALL	CgbMapFree		;

		LDH	A,[hScxBlk]		;Make up the new btm row.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		ADD	18			;
		LD	C,A			;

		JR	IntroBoardRow		;

;
; Board changed row.
;

IntroBoardRow::	PUSH	BC			;
		LD	DE,$1501		;
		CALL	CgbMapAlloc		;
		POP	BC			;
		PUSH	BC			;
		LD	DE,$1501		;
		CALL	CgbMapPaint		;
		POP	BC			;

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

		LD	HL,hBlitXY+3		;
		LD	A,D			;
		LD	[HLD],A			;
		LD	A,E			;
		LD	[HLD],A			;
		LD	A,$01			;
		LD	[HLD],A			;
		LD	A,$15			;
		LD	[HLD],A			;

		RET				;All Done.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BOARDHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


; ***************************************************************************
; * CgbBigBoard ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbBigBoard::	LD	A,[wWhichPlyr]		;
		LD	[wFocusPlyr],A		;

		CALL	CgbBoardDraw		;Draw the big board.

		LD	A,[wWhichPlyr]		;
		SUB	PLYR_GASTN		;
		LDH	[hFirstMove],A		;

		LD	A,$FF			;
		LD	[wJoy1Cur],A		;

		LD	A,20			;
		CALL	AnyWait			;

		CALL	CgbBoardAuto		;

		CALL	CgbBoardUser		;

		CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SetMachineJcb		;Reset machine to known state.

		LD	A,WRKBANK_NRM		;Page in normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		RET				;All Done.

;
;
;

CgbBoardDraw::	CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,[wWhichPlyr]		;
		LD	[wFocusPlyr],A		;

		LD	A,BUTTON_UP_DELAY*2	;
		LDH	[hButtonDelay],A	;
		XOR	A			;
		LDH	[hButtonFrame],A	;

		XOR	A			;
		LDH	[hCamXLo],A		;
		LDH	[hCamXHi],A		;
		LDH	[hCamYLo],A		;
		LDH	[hCamYHi],A		;

		CALL	SetMachineJcb		;Reset machine to known state.

		LD	A,%11010010		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	InitBoardPlyrs		;Initialize the players.
		CALL	CalcBoardPosn		;

		CALL	InitBoardSpr		;

		CALL	CgbInitBoard		;Initialize the board gfx.

		CALL	DrawGuardPos		;Superimpose the guards.

		LD	A,[wFocusPlyr]		;Set camera position.
		CALL	SetCameraToWho		;

		CALL	CgbMapToCamera		;Use camera position.

		LDH	A,[hScxBlk]		;Draw the complete screen.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;
		CALL	CgbMapRefresh		;

		CALL	MakeBoardSpr		;
		CALL	DumpBoardSpr		;
		CALL	WaitForVBL		;
		CALL	DrawBoardSpr		;

		LDH	A,[hScrXLo]		;Init scroll position.
		LDH	[hVblSCX],A		;
		LDH	A,[hScrYLo]		;
		LDH	[hVblSCY],A		;
		LD	A,$FF			;
		LDH	[hPosFlag],A		;

		JP	FadeInBlack		;Fade in from black.

;
;
;

CgbBoardAuto::	XOR	A			;
		LDH	[hInPosition],A		;

.Loop1:		CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		CALL	TestPosition		;

		LD	A,[wFocusPlyr]		;
		CALL	SetCameraToWho		;
		CALL	ScrollBoard		;
		CALL	MakeBoardSpr		;
		CALL	DrawBoardSpr		;

		LDH	A,[hScrXLo]		;Init scroll position.
		LDH	[hVblSCX],A		;
		LDH	A,[hScrYLo]		;
		LDH	[hVblSCY],A		;
		LD	A,$FF			;
		LDH	[hPosFlag],A		;

		LDH	A,[hInPosition]		;
		CP	DELAY_ONSQUARE		;
		JR	C,.Loop1		;

.Move:		LD	A,[wPlyrMoves]		;
		OR	A			;
		RET	Z			;

		BIT	7,A			;
		JR	NZ,.Backwards		;

.Forewards:	DEC	A			;
		LD	[wPlyrMoves],A		;
		CALL	NextPlyrSquare		;
		JR	Z,.Move			;
		CALL	ShowPlyrSquare		;
		JR	CgbBoardAuto		;

.Backwards:	INC	A			;
		LD	[wPlyrMoves],A		;
		CALL	PrevPlyrSquare		;
		JR	Z,.Move			;
		CALL	ShowPlyrSquare		;
		JR	CgbBoardAuto		;

;
;
;

CgbBoardUser::	XOR	A			;
		LDH	[hIntroDelay],A		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to wait for a delay
		LD	HL,PLYR_FLAGS		;or a joypad.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	Z,.Loop0		;

		LD	A,SHOW_DICE_DELAY*2	;
		LDH	[hIntroDelay],A		;

.Loop0:		CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to wait for a delay
		LD	HL,PLYR_FLAGS		;or a joypad.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,.Skip0		;

		CALL	CgbBoardInput		;

		CALL	ScrollBoard		;

		CALL	MoveBoardSpr		;
		CALL	ShowBoardBtn		;
		CALL	DrawBoardSpr		;

.Skip0:		LDH	A,[hScrXLo]		;Init scroll position.
		LDH	[hVblSCX],A		;
		LDH	A,[hScrYLo]		;
		LDH	[hVblSCY],A		;
		LD	A,$FF			;
		LDH	[hPosFlag],A		;

		LDH	A,[hIntroDelay]		;
		OR	A			;
		JR	Z,.Skip1		;
		DEC	A			;
		JR	Z,.Done			;
		LDH	[hIntroDelay],A		;

.Skip1:		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_A|MSK_JOY_B
		JR	Z,.Loop0		;

.Done:		RET				;

;
;
;

TestPosition::	LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Skip0		;
		DEC	A			;
		LD	[HL],A			;

		LD	A,[wFocusPlyr]		;
		CALL	MixPlyrPos		;

		JR	.Skip2			;

.Skip0:		LD	HL,hCamXLo		;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	HL,hScrXLo		;
		LD	A,[HLI]			;
		CP	C			;
		JR	NZ,.Skip2		;
		LD	A,[HLI]			;
		CP	B			;
		JR	NZ,.Skip2		;
		LD	A,[HLI]			;
		CP	E			;
		JR	NZ,.Skip2		;
		LD	A,[HLI]			;
		CP	D			;
		JR	NZ,.Skip2		;

		LDH	A,[hInPosition]		;
		INC	A			;
		JR	NZ,.Skip1		;
		DEC	A			;
.Skip1:		LDH	[hInPosition],A		;
		RET				;

.Skip2:		XOR	A			;
		LDH	[hInPosition],A		;
		RET				;


; ***************************************************************************
; * CgbBoardInput ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbBoardInput::	LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	BIT	JOY_START,C		;
		JR	Z,.TestSelect		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestSelect:	BIT	JOY_SELECT,C		;
		JR	Z,.TestShoot		;

		LD	A,[wFocusPlyr]		;Switch focus.
		CALL	FindNextPlyr		;
		LD	[wFocusPlyr],A		;

		LD	A,[wFocusPlyr]		;
		JP	SwitchBoardSpr		;

.TestShoot:	AND	MSK_JOY_A|MSK_JOY_B	;Shoot ?
		JR	Z,.TestDirection	;

		JR	.TestDirection		;

.TestDirection:

.TestR:		LD	A,[wJoy1Cur]		;
		BIT	JOY_R,A			;
		JR	Z,.TestL		;

		LDH	A,[hCamXLo]		;
		LD	C,A			;
		LDH	A,[hCamXHi]		;
		LD	B,A			;
		LD	HL,0+CGB_BOARD_MOVE	;
		ADD	HL,BC			;
		CALL	CamCmpMinX		;

.TestL:		LD	A,[wJoy1Cur]		;
		BIT	JOY_L,A			;
		JR	Z,.TestU		;

		LDH	A,[hCamXLo]		;
		LD	C,A			;
		LDH	A,[hCamXHi]		;
		LD	B,A			;
		LD	HL,0-CGB_BOARD_MOVE	;
		ADD	HL,BC			;
		CALL	CamCmpMinX		;

.TestU:		LD	A,[wJoy1Cur]		;
		BIT	JOY_U,A			;
		JR	Z,.TestD		;

		LDH	A,[hCamYLo]		;
		LD	E,A			;
		LDH	A,[hCamYHi]		;
		LD	D,A			;
		LD	HL,0-CGB_BOARD_MOVE	;
		ADD	HL,DE			;
		CALL	CamCmpMinY		;

.TestD:		LD	A,[wJoy1Cur]		;
		BIT	JOY_D,A			;
		JR	Z,.TestDone		;

		LDH	A,[hCamYLo]		;
		LD	E,A			;
		LDH	A,[hCamYHi]		;
		LD	D,A			;
		LD	HL,0+CGB_BOARD_MOVE	;
		ADD	HL,DE			;
		CALL	CamCmpMinY		;

.TestDone:	RET				;



; ***************************************************************************
; * NumPlyrSquare ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if unable to move                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

NumPlyrSquare::	LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		RET				;



; ***************************************************************************
; * TypePlyrSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if unable to move                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TypePlyrSquare::LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		LD	C,A			;Multiply by 9.
		LD	B,0			;
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;

		LD	BC,4			;
		ADD	HL,BC			;
		LD	A,[HL]			;

		RET				;



; ***************************************************************************
; * NextPlyrSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if unable to move                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

NextPlyrSquare::LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		IF	TRACE_BOARD		;
		INC	[HL]			;
		RET				;
		ENDC				;

		PUSH	HL			;Preserve ptr to plyr's info.

		LD	C,A			;Multiply by 9.
		LD	B,0			;
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;
		LD	BC,2			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Get 1st next square.
		LD	B,A			;
		LD	A,[HLI]			;Get alt next square.
		LD	C,A			;

;		JR	.TakeShort		;allow them to take shortcut.

		LDH	A,[hFirstMove]		;If this is a plyr's first
		OR	A			;move on this roll then
		JR	NZ,.TakeShort		;allow them to take shortcut.

		LD	A,[wStructRamLo]	;Is the auto-shortcut
		ADD	PLYR_FLAGS		;enabled ?
		LD	L,A			;
		LD	A,[wStructRamHi]	;
		LD	H,A			;
		BIT	PFLG_SHORT,[HL]		;
		JR	Z,.SkipShort		;

.TakeShort:	LD	A,C			;Is there a shortcut ?
		OR	A			;
		JR	Z,.SkipShort		;

		LD	C,B			;Take shortcut.
		LD	B,A			;

		LDH	A,[hFirstMove]		;If this is a plyr's first
		OR	A			;move on this roll then
		JR	NZ,.SkipShort		;don't take away the auto.

		LD	A,[wStructRamLo]	;Disable auto-shortcut.
		ADD	PLYR_FLAGS		;
		LD	L,A			;
		LD	A,[wStructRamHi]	;
		LD	H,A			;
		RES	PFLG_SHORT,[HL]		;

.SkipShort:	XOR	A			;Signal not the first move
		LDH	[hFirstMove],A		;anymore.

.Guards:	LD	DE,256			;Run into guard 1 ?
		LD	A,[wGuard1Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,128			;Run into guard 2 ?
		LD	A,[wGuard2Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,64			;Run into guard 3 ?
		LD	A,[wGuard3Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,32			;Run into guard 4 ?
		LD	A,[wGuard4Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,16			;Run into guard 5 ?
		LD	A,[wGuard5Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,8			;Run into guard 6 ?
		LD	A,[wGuard6Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,4			;Run into guard 7 ?
		LD	A,[wGuard7Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,2			;Run into guard 8 ?
		LD	A,[wGuard8Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;
		LD	DE,1			;Run into guard 8 ?
		LD	A,[wGuard9Sqr]		;
		CP	B			;
		JR	Z,.MoveGuard		;

.Done:		POP	HL			;Restore ptr to plyr's info.
		LD	A,[HL]			;
		LD	[HL],B			;
		CP	B			;
		RET				;

.MoveGuard:	PUSH	BC			;Preserve squares.

		LD	A,[wGuardPosnLo]	;
		OR	E			;
		LD	[wGuardPosnLo],A	;
		LD	A,[wGuardPosnHi]	;
		OR	D			;
		LD	[wGuardPosnHi],A	;

		LD	A,30			;
		CALL	AnyWait			;

		CALL	FadeOutBlack		;Fade out to black.

		LD	HL,IntroKnight		;Display the guard screen.
		CALL	TalkingHeads		;

		CALL	DrawBigBoard		;Display the board screen.

		XOR	A			;Signal not the first move
		LDH	[hFirstMove],A		;anymore.

		POP	BC			;Restore squares.

		JP	.Done			;

.Skip3:		LD	A,C			;Run into a guard, take the
		OR	A			;alternate route if there
		JR	Z,.Skip4		;is one.
		LD	B,C			;
		LD	C,0			;
		JP	.Guards			;

.Skip4:		POP	HL			;Or just stay in the same
		PUSH	HL			;spot.
		LD	B,[HL]			;
		JP	.Done			;



; ***************************************************************************
; * PrevPlyrSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if unable to move                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PrevPlyrSquare::LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		PUSH	HL			;Preserve ptr to plyr's info.

		LD	C,A			;Multiply by 9.
		LD	B,0			;
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;
		LD	BC,5			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Get 1st next square.
		LD	B,A			;
		LD	A,[HLI]			;Get alt next square.
		LD	C,A			;

.Done:		POP	HL			;Restore ptr to plyr's info.
		LD	A,[HL]			;
		LD	[HL],B			;
		CP	B			;
		RET				;



; ***************************************************************************
; * FindNextSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A = Type of square to look for                              *
; *                                                                         *
; * Outputs     ZF if no more squares of that type                          *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Do not call if on SQR_END.                                  *
; ***************************************************************************

FindNextSquare::PUSH	BC			;

		PUSH	AF			;Preserve desired square type.

		LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;
		LD	C,A			;
		INC	C			;

		POP	AF			;Restore desired square type.
		LD	B,A			;

		PUSH	HL			;Preserve ptr to plyr's square.

.Loop:		LD	E,C			;Multiply by 9.
		LD	D,0			;
		LD	L,E			;
		LD	H,D			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	E,A			;
		LD	A,[wBoardSqrHi]		;
		LD	D,A			;
		ADD	HL,DE			;
		LD	DE,4			;
		ADD	HL,DE			;

		LD	A,[HL]			;Get square type.

		CP	SQR_END			;End of board ?
		JR	NC,.Abort		;

		CP	B			;Found desired square ?
		JR	Z,.Found		;

		INC	C			;Try the next square.
		JR	.Loop			;

.Found:		POP	HL			;Restore ptr to plyr's square.

		LD	A,C			;Return square number.
		OR	A			;

		POP	BC			;
		RET				;

.Abort:		POP	HL			;Restore ptr to plyr's square.

		XOR	A			;Return failure code.

		POP	BC			;
		RET				;



; ***************************************************************************
; * FindPrevSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A = Type of square to look for                              *
; *                                                                         *
; * Outputs     ZF if no more squares of that type                          *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Do not call if on SQR_START.                                *
; ***************************************************************************

FindPrevSquare::PUSH	BC			;

		PUSH	AF			;Preserve desired square type.

		LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;
		LD	C,A			;
		DEC	C			;

		POP	AF			;Restore desired square type.
		LD	B,A			;

		PUSH	HL			;Preserve ptr to plyr's square.

.Loop:		LD	E,C			;Multiply by 9.
		LD	D,0			;
		LD	L,E			;
		LD	H,D			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	E,A			;
		LD	A,[wBoardSqrHi]		;
		LD	D,A			;
		ADD	HL,DE			;
		LD	DE,4			;
		ADD	HL,DE			;

		LD	A,[HL]			;Get square type.

		CP	SQR_START		;End of board ?
		JR	Z,.Abort		;

		CP	B			;Found desired square ?
		JR	Z,.Found		;

		DEC	C			;Try the last square.
		JR	.Loop			;

.Found:		POP	HL			;Restore ptr to plyr's square.

		LD	A,C			;Return square number.
		OR	A			;

		POP	BC			;
		RET				;

.Abort:		POP	HL			;Restore ptr to plyr's square.

		XOR	A			;Return failure code.


		POP	BC			;
		RET				;



; ***************************************************************************
; * FindLastGuard ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if no more squares of that type                          *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FindLastGuard::	LD	A,[wFocusPlyr]		;Locate
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	C,[HL]			;

		LD	A,[wBoardGrdLo]		;Locate the last guard.
		LD	L,A			;
		LD	A,[wBoardGrdHi]		;
		LD	H,A			;
		LD	A,[HL]			;
		OR	A			;
		RET	Z			;

		LD	E,A			;Multiply by 9.
		LD	D,0			;
		LD	L,E			;
		LD	H,D			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,[wBoardSqrLo]		;Locate the previous square.
		LD	E,A			;
		LD	A,[wBoardSqrHi]		;
		LD	D,A			;
		ADD	HL,DE			;
		LD	DE,5			;
		ADD	HL,DE			;

		LD	A,C			;Set carry flag if not yet
		CP	[HL]			;got to that square.

		RET				;



; ***************************************************************************
; * StepPlyrSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

StepPlyrSquare::LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		INC	A			;
		CP	66+1			;
		JR	C,.Skip0		;
		LD	A,1			;
.Skip0:		LD	[HL],A			;

		RET				;



; ***************************************************************************
; * ShowPlyrSquare ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShowPlyrSquare::LD	A,[wFocusPlyr]		;
		CALL	NewPlyrPos		;

		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	[HL],16			;

		LD	A,[wFocusPlyr]		;
		CALL	MixPlyrPos		;

		RET				;



; ***************************************************************************
; * ShowBoardBtn ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShowBoardBtn::	LDH	A,[hButtonDelay]	;
		DEC	A			;
		LDH	[hButtonDelay],A	;
		JR	NZ,.Skip1		;
		LDH	A,[hButtonFrame]	;
		XOR	1			;
		LDH	[hButtonFrame],A	;
		LD	A,BUTTON_UP_DELAY*2	;
		JR	Z,.Skip0		;
		LD	A,BUTTON_DN_DELAY*2	;
.Skip0:		LDH	[hButtonDelay],A	;
.Skip1:		LDH	A,[hButtonFrame]	;
		OR	A			;
		JR	NZ,.Skip2		;
		LD	A,MSK_DRAW+MSK_PLOT	;
		LD	[wBoardSpr0+SPR_FLAGS],A;
		LD	A,MSK_DRAW		;
		LD	[wBoardSpr1+SPR_FLAGS],A;
		RET				;
.Skip2:		LD	A,MSK_DRAW		;
		LD	[wBoardSpr0+SPR_FLAGS],A;
		LD	A,MSK_DRAW+MSK_PLOT	;
		LD	[wBoardSpr1+SPR_FLAGS],A;
		RET				;



; ***************************************************************************
; * SwitchBoardSpr ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SwitchBoardSpr::PUSH	AF			;Remove old sprites.
		CALL	SprOff			;
		CALL	WaitForVBL		;
		POP	AF			;

		PUSH	AF			;
		CALL	NewPlyrPos		;
		POP	AF			;
		CALL	SetCameraToWho		;

		CALL	CalcBoardPosn		;

		CALL	InitBoardSpr		;Update new sprites.
		CALL	MakeBoardSpr		;
		CALL	DumpBoardSpr		;
		CALL	WaitForVBL		;
		CALL	ShowBoardBtn		;
		CALL	DrawBoardSpr		;
		JP	WaitForVBL		;



; ***************************************************************************
; * MakeBoardSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MakeBoardSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wBoardSpr0		;

		LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		IF	VERSION_USA		;
		LD	BC,0+14			;
		LD	DE,0+11			;
		ELSE				;
		LD	BC,0+0			;
		LD	DE,0+13			;
;		LD	BC,0+22			;For 3-in-a-row.
;		LD	DE,0+13			;
		ENDC				;
		CALL	BoardIconPos		;
		LD	A,0			;
		CALL	BoardIconBtn		;
		ADD	SP,-$20			;
		LD	A,1			;
	       	CALL	BoardIconBtn		;

		LD	SP,wBoardSpr6		;

		LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_BLMARK		;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Machine0		;
		LD	HL,PLYR_CLMARK		;
.Machine0:	ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	[hTmpLo],A		;
		LD	A,[HLI]			;
		LD	[hTmpHi],A		;
		LD	A,[HLI]			;
		LD	BC,0			;
		LD	DE,0			;

		CALL	BoardIconPos		;
.Loop0:		PUSH	AF			;
		CALL	BoardIconSpr		;
		POP	AF			;
		ADD	SP,-$20			;
		DEC	A			;
		JR	NZ,.Loop0		;

		LD	SP,wBoardSpr2		;

		XOR	A			;
.Loop1:		LD	[hTmp2Lo],A		;

		CALL	GetPlyrInfo		;

		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_PLAY,[HL]		;
		JR	Z,.Skip1		;

		LD	HL,PLYR_BSMARK		;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Machine1		;
		LD	HL,PLYR_CSMARK		;
.Machine1:	ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	[hTmpLo],A		;
		LD	A,[HLI]			;
		LD	[hTmpHi],A		;
		LD	A,[HLI]			;

		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_FOCUS		;
		LD	L,A			;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Skip1		;

		LD	HL,TblIconOffset	;
		ADD	A			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	A,1			;
		CALL	BoardIconPos		;
.Loop2:		PUSH	AF			;
		CALL	BoardIconSpr		;
		POP	AF			;
		ADD	SP,-$20			;
		DEC	A			;
		JR	NZ,.Loop2		;

.Skip1:		LD	A,[hTmp2Lo]		;
		INC	A			;
		CP	5			;
		JR	NZ,.Loop1		;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.

;
;
;

BoardIconPos::	PUSH	AF			;

		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_CUR_X		;
		LD	L,A			;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[HLI]			;
		ADD	C			;
		LD	C,A			;
		LD	A,[HLI]			;
		ADC	B			;
		LD	B,A			;
		LD	A,[HLI]			;
		ADD	E			;
		LD	E,A			;
		LD	A,[HLI]			;
		ADC	D			;
		LD	D,A			;

		LDH	A,[hScrXLo]		;
		CPL				;
		LD	L,A			;
		LDH	A,[hScrXHi]		;
		CPL				;
		LD	H,A			;
		ADD	HL,BC			;
		LD	BC,1			;
		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;

		LDH	A,[hScrYLo]		;
		CPL				;
		LD	L,A			;
		LDH	A,[hScrYHi]		;
		CPL				;
		LD	H,A			;
		ADD	HL,DE			;
		LD	DE,1			;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		POP	AF			;

		RET				;

;
;
;

BoardIconSpr::	LDHL	SP,SPR_SCR_X+4		;Init sprite position.
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FRAME+4		;
		LD	A,[hTmpLo]		;
		LD	[HLI],A			;
		LD	A,[hTmpHi]		;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS+4		;Init sprite flags.
		LD	[HL],MSK_PLOT+MSK_DRAW	;

		XOR	A			;

		LDHL	SP,SPR_COLR+4		;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLIP+4		;
		LD	[HLI],A			;

;		LDHL	SP,SPR_OAM_CNT+4	;
;		LD	[HLI],A			;

		LDH	A,[hTmpLo]		;
		ADD	1			;
		LDH	[hTmpLo],A		;
		LDH	A,[hTmpHi]		;
		ADC	0			;
		LDH	[hTmpHi],A		;

		RET				;All Done.

;
;
;

BoardIconBtn::	LDHL	SP,SPR_FRAME+2		;
		ADD	255&IDX_CPRESS		;
		LD	[HLI],A			;
		LD	A,0			;
		ADC	IDX_CPRESS>>8		;
		LD	[HLI],A			;

;		LD	BC,140			;
;		LD	DE,100			;

		LDHL	SP,SPR_SCR_X+2		;Init sprite position.
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS+2		;Init sprite flags.
		LD	[HL],MSK_DRAW		;

		LD	A,3			;

		LDHL	SP,SPR_COLR+2		;
		LD	[HLI],A			;

		XOR	A			;

		LDHL	SP,SPR_FLIP+2		;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * MoveBoardSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MoveBoardSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LDH	A,[hScxChg]		;
		CPL				;
		INC	A			;
		LD	C,A			;
		ADD	A			;
		SBC	A			;
		LD	B,A			;
		LDH	A,[hScyChg]		;
		CPL				;
		INC	A			;
		LD	E,A			;
		ADD	A			;
		SBC	A			;
		LD	D,A			;

		LD	SP,wBoardSpr0		;
		LD	A,12			;
.Loop0:		CALL	.Scroll			;
		ADD	SP,-$20			;
		DEC	A			;
		JR	NZ,.Loop0		;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.

.Scroll:	PUSH	AF			;
		LDHL	SP,SPR_FLAGS+4		;
		BIT	FLG_DRAW,[HL]		;
		JR	Z,.Skip0		;
		LDHL	SP,SPR_SCR_X+4		;
		LD	A,[HL]			;
		ADD	C			;
		LD	[HLI],A			;
		LD	A,[HL]			;
		ADC	B			;
		LD	[HLI],A			;
		LD	A,[HL]			;
		ADD	E			;
		LD	[HLI],A			;
		LD	A,[HL]			;
		ADC	D			;
		LD	[HLI],A			;
.Skip0:		POP	AF			;
		RET				;



; ***************************************************************************
; * InitBoardPlyrs ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitBoardPlyrs::LD	A,PLYR_BEAST		;
		CALL	InitBoardPlyr		;
		LD	A,PLYR_BELLE		;
		CALL	InitBoardPlyr		;
		LD	A,PLYR_POTTS		;
		CALL	InitBoardPlyr		;
		LD	A,PLYR_LUMIR		;
		CALL	InitBoardPlyr		;
		LD	A,PLYR_GASTN		;
;		CALL	InitBoardPlyr		;

InitBoardPlyr::	CALL	NewPlyrPos		;

		RET				;All Done.



; ***************************************************************************
; * NewPlyrPos ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A  = Number of plyr                                         *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

NewPlyrPos::	CALL	GetPlyrInfo		;

		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_NEW_X		;
		LD	L,A			;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;

		LD	A,[HLI]			;Load PLYR_NEW_X/Y.
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	A,C			;Save PLYR_OLD_X/Y.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	A,[wStructRamLo]	;
		LD	C,A			;
		LD	A,[wStructRamHi]	;
		LD	B,A			;

		LD	HL,PLYR_SQUARE		;Get number of current square.
		ADD	HL,BC			;
		LD	A,[HL]			;

		LD	C,A			;Multiply by 9.
		LD	B,0			;
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Get X coordinate.
		LD	B,0			;
		ADD	A			;
		RL	B			;
		ADD	A			;
		RL	B			;
		ADD	A			;
		RL	B			;
		LD	C,A			;

		LD	A,[HLI]			;Get Y coordinate.
		LD	D,0			;
		ADD	A			;
		RL	D			;
		ADD	A			;
		RL	D			;
		ADD	A			;
		RL	D			;
		LD	E,A			;

;		LD	A,[wBoardLrgX]		;Offset X coordinate.
		LD	A,24			;
		LD	L,A			;
		ADD	A			;
		SBC	A			;
		LD	H,A			;
		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;

;		LD	A,[wBoardLrgY]		;Offset Y coordinate.
		LD	A,24			;
		LD	L,A			;
		ADD	A			;
		SBC	A			;
		LD	H,A			;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_CUR_X		;
		LD	L,A			;

		LD	A,C			;Save PLYR_CUR_X/Y.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	A,C			;Save PLYR_NEW_X/Y.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	A,[wBoardTmpLo]		;Save PLYR_MIX.
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	[HL],0			;

		RET				;All Done.



; ***************************************************************************
; * MixPlyrPos ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A  = Number of plyr                                         *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MixPlyrPos::	CALL	GetPlyrInfo		;

		LD	A,[wBoardTmpHi]		;PLYR_OLD_XY * (PLYR_MIX)
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_OLD_X		;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	A,[HL]			;
		PUSH	AF			;
		CALL	MultiplyBWW		;
		POP	AF			;
		PUSH	HL			;
		LD	C,E			;
		LD	B,D			;
		CALL	MultiplyBWW		;
		PUSH	HL			;

		LD	A,[wBoardTmpHi]		;PLYR_NEW_XY * (16 - PLYR_MIX)
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_NEW_X		;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	A,[HL]			;
		SUB	16			;
		CPL				;
		INC	A			;
		PUSH	AF			;
		CALL	MultiplyBWW		;
		POP	AF			;
		PUSH	HL			;
		LD	C,E			;
		LD	B,D			;
		CALL	MultiplyBWW		;
		PUSH	HL			;

		POP	DE			;
		POP	BC			;

		POP	HL			;Mix Y components.
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;Mix X components.
		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;

		SRL	B			;Normalize the X result.
		RR	C			;
		SRL	B			;
		RR	C			;
		SRL	B			;
		RR	C			;
		SRL	B			;
		RR	C			;

		SRL	D			;Normalize the Y result.
		RR	E			;
		SRL	D			;
		RR	E			;
		SRL	D			;
		RR	E			;
		SRL	D			;
		RR	E			;

		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_CUR_X		;
		LD	L,A			;

		LD	A,C			;Save PLYR_CUR_X/Y.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * CalcBoardPosn ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Intputs     None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CalcBoardPosn::	LD	HL,wBoardBusy		;Clear the usage counts.
		LD	B,12			;
		XOR	A			;
.Loop0:		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		DEC	B			;
		JR	NZ,.Loop0		;

		LD	A,[wFocusPlyr]		;
		INC	A			;
		LD	B,A			;

		DEC	B
		LD	A,B
		JR	Z,.CountBeast
		LD	A,[wStructBeast+PLYR_SQUARE]
		OR	A
		JR	Z,.CountBeast
		LD	L,A
		LD	A,[HL]
		INC	A
		LD	[HL],A
.CountBeast:	LD	[wBoardBeast+PLYR_FOCUS],A

		DEC	B
		LD	A,B
		JR	Z,.CountBelle
		LD	A,[wStructBelle+PLYR_SQUARE]
		OR	A
		JR	Z,.CountBelle
		LD	L,A
		LD	A,[HL]
		INC	A
		LD	[HL],A
.CountBelle:	LD	[wBoardBelle+PLYR_FOCUS],A

		DEC	B
		LD	A,B
		JR	Z,.CountPotts
		LD	A,[wStructPotts+PLYR_SQUARE]
		OR	A
		JR	Z,.CountPotts
		LD	L,A
		LD	A,[HL]
		INC	A
		LD	[HL],A
.CountPotts:	LD	[wBoardPotts+PLYR_FOCUS],A

		DEC	B
		LD	A,B
		JR	Z,.CountLumir
		LD	A,[wStructLumir+PLYR_SQUARE]
		OR	A
		JR	Z,.CountLumir
		LD	L,A
		LD	A,[HL]
		INC	A
		LD	[HL],A
.CountLumir:	LD	[wBoardLumir+PLYR_FOCUS],A

		DEC	B
		LD	A,B
		JR	Z,.CountGastn
		LD	A,[wStructGastn+PLYR_SQUARE]
		OR	A
		JR	Z,.CountGastn
		LD	L,A
		LD	A,[HL]
		INC	A
		LD	[HL],A
.CountGastn:	LD	[wBoardGastn+PLYR_FOCUS],A

		RET				;All Done.



; ***************************************************************************
; * BoardLucky ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardLucky::	CALL	LuckyMusic		;

		LD	A,[wWhichPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,TblMultiLucky

		LD	A,[wStructGastn+PLYR_FLAGS]
		OR	A
		JR	Z,.Roll

		LD	HL,TblStoryLucky

.Roll:		CALL	random			;Pick a random card.

		IF	TRACE_BOARD		;
		JP	.LuckyStar		;
		ENDC				;

;
;
;

.Skip0:		CP	[HL]			;Roll Again ?
		INC	HL			;
		JR	NC,.Skip1		;

.LuckyRoll:	LD	BC,PlyrICmdLucky0	;Roll Again
		CALL	ShowCardLucky		;

		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		SET	PFLG_AGAIN,[HL]		;

		RET				;

;
;
;

.Skip1:		CP	[HL]			;Swap Places ?
		INC	HL			;
		JR	NC,.Skip2		;

.LuckySwap:	CALL	FindLeadPlyr		;Find the lead plyr.

		PUSH	BC			;Is this plyr already on
		LD	A,[wWhichPlyr]		;that square ?
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_SQUARE		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		POP	BC			;
		CP	C			;
		JR	Z,.LuckyStar		;

		PUSH	BC			;Preserve lead plyr.

		LD	BC,PlyrICmdLucky1	;Swap Places
		CALL	ShowCardLucky		;

		POP	BC			;Restore lead plyr.

		JP	SwapPosition		;

;
;
;

.Skip2:		CP	[HL]			;Trivia Time ?
		INC	HL			;
		JR	NC,.Skip3		;

.LuckyTrivia:	IF	VERSION_USA		;

		LD	HL,PLYR_FLAGS		;CPU players don't do this.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,.LuckyMirror		;

		LD	A,[wWhichPlyr]		;Is there a trivia square
		LD	[wFocusPlyr],A		;ahead ?
		LD	A,SQR_COGGS		;
		CALL	FindNextSquare		;
		JR	Z,.LuckyMirror		;

		LD	BC,PlyrICmdLucky2	;Trivia Time
		CALL	ShowCardLucky		;

		CALL	TriviaGameLo		;Ask the question.

		LD	A,[wTriviaRight]	;Was the answer correct ?
		OR	A			;
		RET	Z			;

		LD	A,[wWhichPlyr]		;Move forward to the next
		LD	[wFocusPlyr],A		;trivia square.
		LD	A,SQR_COGGS		;
		CALL	FindNextSquare		;
		LD	[HL],A			;

		RET				;

		ELSE				;

		JR	.LuckyMirror		;Removed from international.

		ENDC

;
;
;

.Skip3:		CP	[HL]			;Horseback Ride ?
		INC	HL			;
		JR	NC,.Skip4		;

.LuckyRide:	LD	BC,PlyrICmdLucky3	;Horseback Ride
		CALL	ShowCardLucky		;

		LD	HL,PLYR_SHOETRAP	;
		ADD	HL,BC			;
		LD	[HL],2			;

		RET				;

;
;
;

.Skip4:		CP	[HL]			;Skip A Turn ?
		INC	HL			;
		JR	NC,.Skip5		;

.LuckySkip:	LD	BC,PlyrICmdLucky4	;Skip A Turn
		CALL	ShowCardLucky		;

		NOP				;

		RET				;

;
;
;

.Skip5:		CP	[HL]			;Bonus Star ?
		INC	HL			;
		JR	NC,.Skip6		;

.LuckyStar:	LD	BC,PlyrICmdLucky5	;Bonus Star
		CALL	ShowCardLucky		;

		LD	HL,PLYR_STARS		;
		ADD	HL,BC			;
		INC	[HL]			;

		RET				;

;
;
;

.Skip6:		CP	[HL]			;Magic Mirror ?
		INC	HL			;
		JR	NC,.Skip7		;

.LuckyMirror:	LD	BC,PlyrICmdLucky6	;Magic Mirror
		CALL	ShowCardLucky		;

		CALL	MirrorSelect		;Select a game.

		JP	BoardLaunch		;Launch it.

;
;
;

.Skip7:		CP	[HL]			;Shortcut ?
		INC	HL			;
		JR	NC,.Skip8		;

.LuckyShort:	LD	A,[wWhichPlyr]		;Is there a guard square
		LD	[wFocusPlyr],A		;ahead ?
		CALL	FindLastGuard		;
		JR	NC,.LuckyMirror		;

		LD	BC,PlyrICmdLucky7	;Shortcut
		CALL	ShowCardLucky		;

		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		SET	PFLG_SHORT,[HL]		;

		RET				;

;
;
;

.Skip8:		CP	[HL]			;Gaston Shield ?
		INC	HL			;
;		JR	NC,.Skip9		;

.LuckyShield:	LD	BC,PlyrICmdLucky8	;Gaston Shield
		CALL	ShowCardLucky		;

		LD	HL,PLYR_SHIELD		;
		ADD	HL,BC			;
		INC	[HL]			;

		RET				;

;
;
;

LuckyMusic::	LD	A,[wMzPlaying]		;
		OR	A			;
		RET	NZ			;
		LD	A,SONG_WOLF		;
		JP	InitTunePref		;



; ***************************************************************************
; * BoardStar ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardStar::	LD	A,[wWhichPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_STARS		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		ADD	3			;
		LD	[HL],A			;

		LD	HL,IntroStarSqr		;
		JP	TalkingHeads		;



; ***************************************************************************
; * BoardGastn ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardGastn::	CALL	GastnMusic		;

		LD	A,[wWhichPlyr]		;
		LD	[wFocusPlyr],A		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_SHIELD		;Find this plyr's shield
		ADD	HL,BC			;count.

		LD	A,[HL]			;Does this plyr have a
		OR	A			;Gaston's Shield ?
		IF	TRACE_BOARD		;
		ELSE				;
		JR	Z,.NoShield		;
		ENDC				;

		DEC	[HL]			;Decrement shield count.

		LD	BC,PlyrICmdGastnX	;Gaston Shield
		CALL	ShowCardGastn		;

		RET				;

.NoShield:	LD	A,[wWhichPlyr]		;CPU or human plyr ?
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,.Challenge		;

		LD	BC,PlyrICmdGastnC	;Announce Gaston's Challenge
		CALL	ShowCardGastn		;

.Challenge:	CALL	TryToBeatGastn		;Play the Gaston game.

		LD	A,[wSubStage]		;Did the plyr beat it ?
		CP	3			;
		JR	NZ,.RandomCard		;

		LD	BC,PlyrICmdGastnB	;Gaston Beaten
		CALL	ShowCardGastn		;

		RET				;

.RandomCard:	LD	HL,TblMultiGastn

		LD	A,[wStructGastn+PLYR_FLAGS]
		OR	A
		JR	Z,.Roll

		LD	HL,TblStoryGastn

.Roll:		LD	A,[wStructRamLo]	;
		LD	C,A			;
		LD	A,[wStructRamHi]	;
		LD	B,A			;

		CALL	random			;Pick a random card.

;
;
;

.Skip0:		CP	[HL]			;Out Hunting ?
		INC	HL			;
		JR	NC,.Skip1		;

.GastnOut:	LD	BC,PlyrICmdGastn0	;Out Hunting
		CALL	ShowCardGastn		;

		RET				;

;
;
;

.Skip1:		CP	[HL]			;Gaston Strikes ?
		INC	HL			;
		JR	NC,.Skip2		;

.GastnStrikes:	LD	A,[wWhichPlyr]		;Is there a previous Gaston
		LD	[wFocusPlyr],A		;Square ?
		LD	A,SQR_GASTN		;
		CALL	FindPrevSquare		;
		JR	Z,.GastnTrap		;

		LD	BC,PlyrICmdGastn1	;Gaston Strikes
		CALL	ShowCardGastn		;

		LD	A,[wWhichPlyr]		;Move backward to the last
		LD	[wFocusPlyr],A		;Gaston square.
		LD	A,SQR_GASTN		;
		CALL	FindPrevSquare		;
		LD	[HL],A			;

		RET				;

;
;
;

.Skip2:		CP	[HL]			;Gaston Loots ?
		INC	HL			;
		JR	NC,.Skip3		;

.GastnLoots:	LD	HL,PLYR_STARS		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JP	Z,.GastnTrap		;
		DEC	[HL]			;

.Uggy:		LD	BC,PlyrICmdGastn2	;Gaston Loots
		CALL	ShowCardGastn		;

		RET				;

;
;
;

.Skip3:		CP	[HL]			;Gaston's Grip ?
		INC	HL			;
		JR	NC,.Skip4		;

.GastnGrip:	LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		SET	PFLG_SKIP,[HL]		;

		LD	BC,PlyrICmdGastn3	;Gaston's Grip
		CALL	ShowCardGastn		;

		RET				;

;
;
;

.Skip4:		CP	[HL]			;Gaston's Trap ?
		INC	HL			;
		JR	NC,.Skip5		;

.GastnTrap:	LD	HL,PLYR_SHOETRAP	;
		ADD	HL,BC			;
		LD	[HL],-2			;

		LD	BC,PlyrICmdGastn4	;Gaston's Trap
		CALL	ShowCardGastn		;

		RET				;

;
;
;

.Skip5:		CP	[HL]			;Gaston's Grief ?
		INC	HL			;
;		JR	NC,.Skip6		;

.GastnGrief:	CALL	FindLastPlyr		;Find the last plyr.

		PUSH	BC			;Is this plyr already on
		LD	A,[wWhichPlyr]		;that square ?
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_SQUARE		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		POP	DE			;
		CP	C			;
		JR	Z,.GastnLoots		;

		PUSH	DE			;Preserve last plyr.

		LD	BC,PlyrICmdGastn5	;Gaston's Grief
		CALL	ShowCardGastn		;

		POP	BC			;Restore lead plyr.

		JP	SwapPosition		;

;
;
;

GastnMusic::	LD	A,[wMzPlaying]		;
		OR	A			;
		RET	NZ			;
		LD	A,SONG_WOLF		;
		JP	InitTunePref		;



; ***************************************************************************
; * ShowCardLucky ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShowCardLucky::
		LD	A,BANK(ShowCardLucky)	;DEBUG CRAP
		CP	BANK(PlyrICmdLucky)	;
		JR	NZ,ShowCardLucky	;

		PUSH	BC			;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;

.Skip0:		POP	BC			;
		CALL	NextICmd		;

		LD	HL,LuckyPressICmd	;Use wWhichPlyr to determine
		LD	DE,FadeDelayICmd	;whether to wait for a delay
		CALL	BoardWhichICmd		;or a joypad.

		LD	A,[wWhichPlyr]		;
		JP	GetPlyrInfo		;



; ***************************************************************************
; * PlyrICmdLucky ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrICmdLucky::	DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;
		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BENCHNTPKG		;
		DW	IDX_CENCHNTPKG		;
		DB	ICMD_RETN		;All Done.

;PlyrICmdLuckyC:DB	ICMD_CALL		;
;		DW	PlyrICmdLucky		;
;		IF	0
;		DB	ICMD_FASTSTR
;		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"Challenge",0
;		DB	0
;		DB	ICMD_FONT		;Setup font.
;		DW	FontLite		;
;		DB	ICMD_FASTSTR
;		DB	96,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"DEFEAT MY",0
;		DB	96,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"CHALLENGE AND",0
;		DB	96,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"I WILL REWARD",0
;		DB	96,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"YOU",0
;		DB	0
;		ELSE
;		DB	ICMD_FASTSTRN
;		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DW	207
;		DB	0
;		DB	ICMD_LUCKYSTR,208
;		ENDC
;		DB	ICMD_END		;All Done.

;PlyrICmdLuckyF:DB	ICMD_CALL		;
;		DW	PlyrICmdLucky		;
;		IF	0
;		DB	ICMD_FASTSTR
;		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"You Lost!",0
;		DB	0
;		DB	ICMD_FONT		;Setup font.
;		DW	FontLite		;
;		DB	ICMD_FASTSTR
;		DB	96,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"YOU DID NOT DO",0
;		DB	96,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"WELL ENOUGH",0
;		DB	96,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"TO EARN MY",0
;		DB	96,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DB	"REWARD",0
;		DB	0
;		ELSE
;		DB	ICMD_FASTSTRN
;		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
;		DW	209
;		DB	0
;		DB	ICMD_LUCKYSTR,210
;		ENDC
;		DB	ICMD_END		;All Done.

PlyrICmdLucky0::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Roll Again",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,113+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU GET TO",0
		DB	96,113+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ROLL AGAIN",0
		DB	96,113+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"THIS TURN",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	1
		DB	0
		DB	ICMD_LUCKYSTR,2
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky1::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Swap Places",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SWITCH PLACES",0
		DB	96,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"WITH THE PLAYER",0
		DB	96,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"WHO IS IN",0
		DB	96,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"FIRST PLACE",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	3
		DB	0
		DB	ICMD_LUCKYSTR,4
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky2::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Trivia Time",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GET THE RIGHT",0
		DB	96,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ANSWER TO MOVE",0
		DB	96,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ON TO THE NEXT",0
		DB	96,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"TRIVIA SQUARE",0
		DB	0
		DB	ICMD_END		;All Done.

PlyrICmdLucky3::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Horse Ride",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,113+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ADD 2 TO THE",0
		DB	96,113+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"NEXT 2 DIE",0
		DB	96,113+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ROLLS",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	5
		DB	0
		DB	ICMD_LUCKYSTR,6
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky4::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Skip A Turn",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,113+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"CHOOSE ANOTHER",0
		DB	96,113+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"PLAYER TO LOSE",0
		DB	96,113+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"THEIR NEXT TURN",0
		DB	0
		DB	ICMD_END		;All Done.

PlyrICmdLucky5::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Bonus Star",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,118+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU RECEIVE A",0
		DB	96,118+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BONUS STAR",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	7
		DB	0
		DB	ICMD_LUCKYSTR,8
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky6::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Magic Mirror",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,118+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SELECT A GAME",0
		DB	96,118+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"OF YOUR CHOICE",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	9
		DB	0
		DB	ICMD_LUCKYSTR,10
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky7::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Shortcut",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,118+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"TAKE THE NEXT",0
		DB	96,118+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SHORTCUT PATH",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	11
		DB	0
		DB	ICMD_LUCKYSTR,12
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdLucky8::DB	ICMD_CALL		;
		DW	PlyrICmdLucky		;
		IF	0
		DB	ICMD_FASTSTR
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston Shield",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	96,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"PROTECTS YOU",0
		DB	96,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"FROM THE NEXT",0
		DB	96,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GASTON'S GRIEF",0
		DB	96,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SQUARE",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	13
		DB	0
		DB	ICMD_LUCKYSTR,14
		ENDC
		DB	ICMD_END		;All Done.



; ***************************************************************************
; * ShowCardGastn ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShowCardGastn::	LD	A,BANK(ShowCardGastn)	;DEBUG CRAP
		CP	BANK(PlyrICmdGastn)	;
		JR	NZ,ShowCardGastn	;

		PUSH	BC			;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;

.Skip0:		POP	BC			;
		CALL	NextICmd		;

		LD	HL,GastnPressICmd	;Use wWhichPlyr to determine
		LD	DE,FadeDelayICmd	;whether to wait for a delay
		CALL	BoardWhichICmd		;or a joypad.

		LD	A,[wWhichPlyr]		;
		JP	GetPlyrInfo		;

;
; ICMD_GASTNSTR -
;

ICmdGastnStr::	LD	A,LOW(FontLite)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontLite)	;
		LD	[wFontHi],A		;

		LD	A,118			;Set intro text bounds.
		LD	[wStringL1Width],A	;
		LD	[wStringL2Width],A	;
		LD	[wStringL3Width],A	;
		LD	[wStringL4Width],A	;
		LD	[wStringL5Width],A	;

		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		CALL	SplitString		;

		LD	BC,ICmdGastn4L		;
		LD	A,[wStringLine4]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdGastn3L		;
		LD	A,[wStringLine3]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdGastn2L		;
		LD	A,[wStringLine2]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdGastn1L		;

.Print:		CALL	NextICmd		;

		POP	BC			;

		JP	NextICmd		;

ICmdGastn4L::	DB	ICMD_FASTSTRP
		DB	64,108+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	64,108+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	64,108+2*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	64,108+3*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine4
		DB	0
		DB	ICMD_HALT

ICmdGastn3L::	DB	ICMD_FASTSTRP
		DB	64,113+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	64,113+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	64,113+2*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	0
		DB	ICMD_HALT

ICmdGastn2L::	DB	ICMD_FASTSTRP
		DB	64,118+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	64,118+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	0
		DB	ICMD_HALT

ICmdGastn1L::	DB	ICMD_FASTSTRP
		DB	64,123+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	0
		DB	ICMD_HALT



; ***************************************************************************
; * PlyrICmdGastn ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrICmdGastn::	DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;
		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGRIEFPKG		;
		DW	IDX_CGRIEFPKG		;
		DB	ICMD_RETN		;All Done.

PlyrICmdBeaten::DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;
		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BBEATPKG		;
		DW	IDX_CBEATPKG		;
		DB	ICMD_RETN		;All Done.

PlyrICmdGastnX::DB	ICMD_CALL		;
		DW	PlyrICmdBeaten		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston Shield",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOUR SHIELD",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"PROTECTS YOU",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"FROM GASTON",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"THIS TURN",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	15
		DB	0
		DB	ICMD_GASTNSTR,16
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastnC::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Challenge",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"DEFEAT MY",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"CHALLENGE AND",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"I WILL LET YOU",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GO UNHARMED",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	17
		DB	0
		DB	ICMD_GASTNSTR,18
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastnB::DB	ICMD_CALL		;
		DW	PlyrICmdBeaten		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston Loses",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU COMPLETED",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"THE GAME AND",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GASTON LETS",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU GO",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	19
		DB	0
		DB	ICMD_GASTNSTR,20
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastn0::DB	ICMD_CALL		;
		DW	PlyrICmdBeaten		;
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Out Hunting",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"IT IS YOUR",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"LUCKY DAY,",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GASTON IS",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"TOO BUSY",0
		DB	0
		DB	ICMD_END		;All Done.

PlyrICmdGastn1::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston Strikes",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"MOVE BACK TO",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"THE LAST",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GASTON'S GRIEF",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SQUARE",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	21
		DB	0
		DB	ICMD_GASTNSTR,22
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastn2::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston Loots",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,113+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"GASTON TAKES",0
		DB	64,113+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ONE OF YOUR",0
		DB	64,113+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"BONUS STARS",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	23
		DB	0
		DB	ICMD_GASTNSTR,24
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastn3::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston's Grip",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,118+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU LOSE YOUR",0
		DB	64,118+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"NEXT TURN",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	25
		DB	0
		DB	ICMD_GASTNSTR,26
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastn4::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston's Trap",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SUBTRACT 2",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"FROM YOUR",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"NEXT 2",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"DIE ROLLS",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	27
		DB	0
		DB	ICMD_GASTNSTR,28
		ENDC
		DB	ICMD_END		;All Done.

PlyrICmdGastn5::DB	ICMD_CALL		;
		DW	PlyrICmdGastn		;
		IF	0
		DB	ICMD_FASTSTR
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston's Grief",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	64,108+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"SWITCH PLACES",0
		DB	64,108+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"WITH THE PLAYER",0
		DB	64,108+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"WHO IS IN",0
		DB	64,108+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"LAST PLACE",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	64, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	29
		DB	0
		DB	ICMD_GASTNSTR,30
		ENDC
		DB	ICMD_END		;All Done.



; ***************************************************************************
; * FindLeadPlyr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FindLeadPlyr::	LD	BC,$0000		;
		LD	DE,$0000		;

.Loop0:		PUSH	BC			;
		PUSH	DE			;

		LD	A,D			;Locate this plyr's info.
		CALL	GetPlyrInfo		;

		POP	DE			;

		LD	HL,PLYR_SQUARE		;Read plyr square.
		ADD	HL,BC			;
		LD	E,[HL]			;

		LD	HL,PLYR_FLAGS		;Read plyr flags.
		ADD	HL,BC			;

		POP	BC			;

		BIT	PFLG_PLAY,[HL]		;Is this plyr in the game ?
		JR	Z,.Skip0		;

		LD	A,C			;Is this plyr ahead of the
		CP	E			;current best plyr ?
		JR	NC,.Skip0		;

		LD	C,E			;Setup this plyr as the
		LD	B,D			;best so far.

.Skip0:		INC	D			;Next plyr.

		LD	A,D			;End of list ?
		CP	4			;
		JR	NZ,.Loop0		;

		RET				;



; ***************************************************************************
; * FindLastPlyr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FindLastPlyr::	LD	BC,$00FF		;
		LD	DE,$0000		;

.Loop0:		PUSH	BC			;
		PUSH	DE			;

		LD	A,D			;Locate this plyr's info.
		CALL	GetPlyrInfo		;

		POP	DE			;

		LD	HL,PLYR_SQUARE		;Read plyr square.
		ADD	HL,BC			;
		LD	E,[HL]			;

		LD	HL,PLYR_FLAGS		;Read plyr flags.
		ADD	HL,BC			;

		POP	BC			;

		BIT	PFLG_PLAY,[HL]		;Is this plyr in the game ?
		JR	Z,.Skip0		;

		LD	A,C			;Is this plyr behind the
		CP	E			;current worst plyr ?
		JR	C,.Skip0		;
		JR	Z,.Skip0		;

		LD	C,E			;Setup this plyr as the
		LD	B,D			;best so far.

.Skip0:		INC	D			;Next plyr.

		LD	A,D			;End of list ?
		CP	4			;
		JR	NZ,.Loop0		;

		RET				;



; ***************************************************************************
; * SwapPosition ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SwapPosition::	PUSH	BC			;
		LD	A,[wWhichPlyr]		;
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_SQUARE		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		POP	BC			;
		LD	[HL],C			;
		LD	C,A			;
		PUSH	BC			;
		LD	A,B			;
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_SQUARE		;
		ADD	HL,BC			;
		POP	BC			;
		LD	[HL],C			;
		RET				;



; ***************************************************************************
; * BoardBonus ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

BoardBonus::	CALL	KillAllSound		;Stop all sound.
		CALL	WaitForVBL		;

		LD	HL,IntroBonus		;
		CALL	TalkingHeads		;

		LD	A,GAME_SPIT		;Trigger the bonus game.
		JP	BoardSubGame		;



; ***************************************************************************
; * StoryGame ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

StoryGame::	LD	SP,wStackPointer	;Reset the stack.

		CALL	KillAllSound		;Stop all sound.
		CALL	WaitForVBL		;

		IF	DUMP_TEXT
		CALL	DumpText		;Stop all sound.
		ENDC

		LD	A,[wWhichGame]		;Restarting a game ?
		CP	BACKUP_STORY		;
		JP	Z,StoryBelle		;
		CP	BACKUP_BOARD		;
		JP	Z,BoardPlyrTurn		;

;		XOR	A			;
;		LD	[wBoardMap],A		;

		CALL	SetupBoard		;Locate which board we're on.

		LD	A,PMSK_PLAY
		LD	[wStructBelle+PLYR_FLAGS],A
		LD	A,PMSK_PLAY|PMSK_CPU
		LD	[wStructGastn+PLYR_FLAGS],A
		LD	A,[wSubLevel]
		LD	[wStructBelle+PLYR_LEVEL],A
		LD	[wStructGastn+PLYR_LEVEL],A

		XOR	A
		LD	[wStructBeast+PLYR_FLAGS],A
		LD	[wStructPotts+PLYR_FLAGS],A
		LD	[wStructLumir+PLYR_FLAGS],A
		LD	[wStructBeast+PLYR_LEVEL],A
		LD	[wStructPotts+PLYR_LEVEL],A
		LD	[wStructLumir+PLYR_LEVEL],A

		CALL	ResetPlayers

;		LD	A,65
;		LD	[wStructBelle+PLYR_SQUARE],A

		LD	HL,TblGastonStart
		LD	A,[wStructBelle+PLYR_LEVEL]
		ADD	L
		LD	L,A
		JR	NC,.Skip0
		INC	H
.Skip0:		LD	A,[HL]
		LD	[wStructGastn+PLYR_SQUARE],A

		LD	A,SONG_TITLE		;Title music plays during
		LD	[wBoardMz],A		;intro.

		LD	A,[wBoardMap]		;Play board introduction.
		OR	A			;
		LD	HL,IntroStory1		;
		JR	Z,.Skip1		;
		DEC	A			;
		LD	HL,IntroStory2		;
		JR	Z,.Skip1		;
		LD	HL,IntroStory3		;
.Skip1:		CALL	TalkingHeads		;

StoryGastn::	LD	SP,wStackPointer	;Reset the stack.

		CALL	SetupBoard		;Locate which board we're on.

		CALL	FindGuardPos		;Locate guard positions.

		CALL	SetRandMusic		;Select random music.

		CALL	BoardMusic		;Ensure that music is on.

		LD	A,PLYR_GASTN		;Gaston's turn.
		LD	[wWhichPlyr],A		;

		LD	HL,TblGastonMoves	;Find Gaston's movement on
		LD	A,[wBoardMap]		;this board.
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;
;		LD	A,3			;
		LD	[wPlyrMoves],A		;
		LDH	[hIntroDone],A		;

StoryGastnShow::CALL	PlyrBigBoard		;Show the game board.

		LD	A,PLYR_GASTN		;Did Gaston reach the end ?
		LD	[wWhichPlyr],A		;
		LD	[wFocusPlyr],A		;
		CALL	TypePlyrSquare		;
		CP	SQR_END			;
		JP	NC,BoardFinish		;

StoryBelle::	LD	SP,wStackPointer	;Reset the stack.

		LD	A,PLYR_BELLE		;Belle's turn.
		LD	[wWhichPlyr],A		;

		LD	A,BACKUP_STORY		;Save the current game state.
		LD	[wWhichGame],A		;
		CALL	SaveBackup		;

		CALL	SetupBoard		;Locate which board we're on.

		CALL	FindGuardPos		;Locate guard positions.

		CALL	SetRandMusic		;Select random music.

		CALL	BoardMusic		;Ensure that music is on.

;		CALL	PlyrShowWhom		;Show whose turn it is.

		LD	A,[wWhichPlyr]		;Does this plyr skip this
		CALL	GetPlyrInfo		;turn ?
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_SKIP,[HL]		;
		RES	PFLG_SKIP,[HL]		;
		JR	NZ,StoryGameNext	;

		LD	HL,PLYR_LEVEL		;Init this plyr's difficulty
		ADD	HL,BC			;level.
		LD	A,[HL]			;
		LD	[wSubLevel],A		;

		XOR	A			;
		LD	[wSubStage],A		;
		LD	[wSubStars],A		;
		LD	[wSubAward],A		;

		CALL	PlyrDiceShow		;Show the dice roll.

		CALL	PlyrBigBoard		;Show the game board.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,[wWhichPlyr]		;Find out which type of
		LD	[wFocusPlyr],A		;square we're on.
		CALL	TypePlyrSquare		;

		CALL	BoardLaunch		;Launch the subgame.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		LD	A,[wWhichPlyr]		;Got 3 or more stars ?
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_STARS		;
		ADD	HL,BC			;
		LD	A,[HL]			;
		SUB	MAX_STARS		;
		JR	C,StoryGameNext		;
		LD	[HL],A			;
		LD	[wSubStars],A		;

;		CALL	BoardMusic		;Ensure that music is on.

		CALL	BoardBonus		;Launch the bonus game.

StoryGameNext::	LD	A,[wWhichPlyr]		;Does this plyr roll again
		CALL	GetPlyrInfo		;this turn ?
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_AGAIN,[HL]		;
		RES	PFLG_AGAIN,[HL]		;
		JP	NZ,StoryBelle		;

		JP	StoryGastn		;

StoryGameOver::	RET				;All Done.



; ***************************************************************************
; * PlyrDiceShow ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrDiceShow::	CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,-1			;Clear focus so that the
		LD	[wFocusPlyr],A		;overlap calculation works.

		CALL	CalcOverlap		;

		CALL	random			;Roll 1st die.
		LD	C,6			;
		CALL	MultiplyBBW		;
		LD	A,H			;
		INC	A			;
		LDH	[hDie1Roll],A		;
		XOR	A			;
		LDH	[hDie2Roll],A		;

		LD	A,[wWhichPlyr]		;Should this plyr roll a
		CALL	GetPlyrInfo		;2nd die ?
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_2DICE,[HL]		;
		JR	Z,.Skip0		;
		RES	PFLG_2DICE,[HL]		;

		CALL	random			;Roll 2nd die.
		LD	C,6			;
		CALL	MultiplyBBW		;
		LD	A,H			;
		INC	A			;
		LDH	[hDie2Roll],A		;

.Skip0:		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

;		LD	BC,PlyrICmdSmall	;Dump background.
;		CALL	NextICmd		;

		LD	A,[wBoardDieLo]		;Locate the small map for
		LD	L,A			;the current board.
		LD	E,A			;
		LD	A,[wBoardDieHi]		;
		LD	H,A			;
		LD	D,A			;
		CALL	XferBitmap		;

		LD	A,%01100000		;Setup dice palette.
		LD	[wFadeOBP1],A		;

		CALL	DmaBitmap20x18		;Copy the bitmap to vram.

		LD	DE,$9800		;Copy the colors to vram.
		CALL	DumpShadowAtr		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;

		LD	A,WRKBANK_PAL		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		LD	HL,TblMarkerSprRgb	;
		LD	DE,wOcpArcade		;
		LD	BC,64			;
		CALL	MemCopy			;
		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,[wWhichPlyr]		;CPU players skip straight
		CALL	GetPlyrInfo		;to the dice roll.
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	Z,.Skip1		;

		CALL	FadeInBlack		;Fade in from black.
		JP	PlyrDiceRoll		;

.Skip1:		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip2		;

		LD	A,WRKBANK_PAL		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		LD	HL,TblMarkerSprRgb	;
		LD	DE,wOcpArcade		;
		LD	BC,64			;
		CALL	MemCopy			;
		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

.Skip2:		LD	HL,PosnPressICmd	;Initialize "Press Button"
		LD	DE,wBoardBusy		;sprite.
		LD	BC,16			;
		CALL	MemCopy			;
		LD	A,[wBoardBtnX]		;
		LD	[wBoardBusy+3],A	;
		LD	A,[wBoardBtnY]		;
		LD	[wBoardBusy+4],A	;
		LD	BC,wBoardBusy		;
		CALL	NextICmd		;

		CALL	MakeIconSpr		;

		LD	A,[wWhichPlyr]		;Initialize focus.
		LD	[wFrontPlyr],A		;

		CALL	ProcStaticSpr		;Update sprite graphics.

		CALL	FadeInBlack		;Fade in from black.

		CALL	ReadJoypad		;Update joypads.

		XOR	A			;
		LDH	[hCycleCount],A		;

.Loop0:		CALL	WaitForVBL		;Synchronize to the VBL.
		CALL	WaitForVBL		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;
		AND	$1F			;
		JR	NZ,.Skip4		;

		LD	A,[wFrontPlyr]		;
		PUSH	AF			;
.Loop1:		LD	A,[wFrontPlyr]		;
		CALL	FindNextPlyr		;
		LD	[wFrontPlyr],A		;
		LDHL	SP,1			;
		CP	[HL]			;
		JR	Z,.Skip3		;
		CALL	GetPlyrInfo		;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_FOCUS		;
		LD	L,A			;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[HL]			;
		CP	2			;
		JR	C,.Loop1		;
.Skip3:		ADD	SP,2			;

.Skip4:		CALL	ProcStaticSpr		;

		CALL	ReadJoypad		;Update joypads.

		LD	A,[wJoy1Cur]		;Abort pressed ?
		BIT	JOY_START,A		;
		JP	NZ,PlyrDiceAbort	;

		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	Z,.Loop0		;

		CALL	WaitForRelease		;Wait for button release.

		CALL	InitIntro		;Remove current sprites.
		CALL	SprOff			;
		CALL	WaitForVBL		;

		XOR	A			;
		LD	[wFigPhase],A		;

PlyrDiceRoll::	CALL	WaitForVBL		;

		LDH	A,[hMachine]		;Update palettes for CGB
		CP	MACHINE_CGB		;dice ?
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CDIETOP		;
		CALL	AddSpritePal		;

		LD	A,WRKBANK_PAL		;Copy the fade palettes
		LDH	[hWrkBank],A		;to the shadow palettes.
		LDIO	[rSVBK],A		;
		LD	HL,wOcpArcade		;
		LD	DE,wOcpShadow		;
		LD	BC,64			;
		CALL	MemCopy			;
		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,1			;Signal that the palette
		LDH	[hPalFlag],A		;needs updating.

		CALL	WaitForVBL		;Synchronize to the VBL.

.Skip0:		LD	A,[wWhichPlyr]		;
		ADD	A			;
		ADD	A			;
		LD	HL,TblPlyr2Roll		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		PUSH	HL			;
		CALL	InitDaveAnim		;
		POP	HL			;
		LD	A,[HLI]			;
		LDH	[hDaveAnimXFlip],A	;
		LD	A,[HLI]			;
		LDH	[hDieRemap],A		;

		LD	A,6			;
		LDH	[hDaveAnimRemap],A	;

		LDH	A,[hDie1Roll]		;
		CALL	FixDieRemap		;

		LD	BC,AnmDiceRoll		;
		CALL	SetDaveAnim		;

		LD	A,LOW(FixDiceSpr)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(FixDiceSpr)	;
		LD	[wJmpDraw+2],A		;
		XOR	A			;
		LD	[hDieFixup],A		;

.Loop0:		CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		LDH	A,[hDaveAnimCnt]	;
		OR	A			;
		JR	Z,.Skip3		;

		CALL	IncDaveAnim		;

		CALL	ProcIntroSpr		;

		CALL	ReadJoypad		;Update joypads.

		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	Z,.Loop0		;

		JP	PlyrDiceAbort		;

.Skip3:

;		LD	A,[wBoardDieLo]		;Locate the small map for
;		LD	L,A			;the current board.
;		LD	E,A			;
;		LD	A,[wBoardDieHi]		;
;		LD	H,A			;
;		LD	D,A			;
;		CALL	XferBitmap		;

		LD	A,%01100000		;Setup dice palette.
		LD	[wFadeOBP1],A		;

		CALL	OverlayResult		;Overlay text box.

		CALL	PlyrDiceResult		;Calculate dice results.

		LD	BC,wTemp512		;Print out the result.
		CALL	NextICmd		;

		LD	A,$FF			;
		LD	[wJoy1Cur],A		;

		LD	A,SHOW_DICE_DELAY	;
		LDH	[hDieDelay],A		;

.Loop1:		CALL	WaitForVBL		;Synchronize to the VBL.
		CALL	WaitForVBL		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ProcIntroSpr		;

		CALL	ReadJoypad		;Update joypads.

		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	NZ,PlyrDiceDone		;

		LDH	A,[hDieDelay]		;
		DEC	A			;
		LDH	[hDieDelay],A		;
		JR	NZ,.Loop1		;

PlyrDiceDone::	CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;All Done.

PlyrDiceAbort::	CALL	PlyrDiceResult		;Calculate dice results.

		JR	PlyrDiceDone		;

;
;
;

FixDieRemap::	LD	HL,TblDiceRemap		;
		DEC	A			;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LDH	A,[hDieRemap]		;
		LD	C,A			;
		LD	B,0			;
		ADD	HL,BC			;
		LD	A,[HL]			;
		LDH	[hDaveAnimRemap],A	;
		RET				;



; ***************************************************************************
; * MakeIconSpr ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MakeIconSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wSprite1		;

		LD	A,PLYR_BEAST		;
		LD	[wFrontPlyr],A		;

.Loop0:		LDH	[hTmpLo],A		;

		CALL	GetPlyrInfo		;

		LD	HL,PLYR_FLAGS		;Is this plyr active in
		ADD	HL,BC			;this game ?
		BIT	PFLG_PLAY,[HL]		;
		JR	Z,.Skip0		;

		LDH	A,[hTmpLo]		;
		LD	[wFrontPlyr],A		;

		LD	HL,PLYR_BSMARK		;Locate the plyr's small
		LDH	A,[hMachine]		;icon sprite.
		CP	MACHINE_CGB		;
		JR	NZ,.Machine0		;
		LD	HL,PLYR_CSMARK		;
.Machine0:	ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	HL,PLYR_SQUARE		;Locate the plyr's square
		ADD	HL,BC			;number.
		LD	A,[HL]			;

		LD	C,A			;Multiply by 9.
		LD	B,0			;
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[wBoardSqrLo]		;Locate info for this square.
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;
		LD	BC,7			;
		ADD	HL,BC			;

		LD	A,[wBoardSmlX]		;Read square's X position.
		ADD	[HL]			;
		IF	VERSION_USA		;
		ELSE				;
		SUB	6			;
		ENDC				;
		INC	HL			;
		LD	B,A			;
		LD	A,[wBoardSmlY]		;Read square's Y position.
		ADD	[HL]			;
		IF	VERSION_USA		;
		ELSE				;
		ADD	4			;
		ENDC				;
		INC	HL			;
		LD	C,A			;

		LDHL	SP,SPR_SCR_X		;Save sprite position.
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,0			;
		LD	[HLI],A			;
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,0			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FRAME		;Save sprite frame.
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS		;Save sprite flags.
		LD	[HL],MSK_PLOT+MSK_DRAW	;

		XOR	A			;
		LDHL	SP,SPR_COLR		;
		LD	[HLI],A			;
		LDHL	SP,SPR_FLIP		;
		LD	[HLI],A			;
		LDHL	SP,SPR_OAM_CNT		;
		LD	[HLI],A			;

.Skip0:		ADD	SP,-$30			;

		LD	HL,0
		ADD	HL,SP
		LD	DE,wSprite5
		LD	A,E
		SUB	L
		LD	A,D
		SBC	H
		JR	NZ,.Skip1
;		LD	HL,$FFFF&(0-wSprite5)	;
;		ADD	HL,SP			;
;		LD	A,H			;
;		OR	L			;
;		JR	NZ,.Skip1		;

		LD	SP,wSprite1		;

.Skip1:		LD	A,[hTmpLo]		;
		INC	A			;
		CP	PLYR_GASTN+1		;
		JP	NZ,.Loop0		;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * CalcOverlap ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Intputs     None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CalcOverlap::	LD	HL,wBoardBusy		;Clear the usage counts.
		LD	B,12			;
		XOR	A			;
.Loop0:		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		DEC	B			;
		JR	NZ,.Loop0		;

		LD	A,[wFocusPlyr]		;Find out which plyr is
		INC	A			;in focus (for the big
		LD	B,A			;board display only).

.Skip0:		DEC	B			;Don't count the focus plyr
		JR	Z,.Skip1		;who is using the large icon.

		LD	A,[wStructBeast+PLYR_SQUARE]
		LD	L,A
		INC	[HL]

.Skip1:		DEC	B			;Don't count the focus plyr
		JR	Z,.Skip2		;who is using the large icon.

		LD	A,[wStructBelle+PLYR_SQUARE]
		LD	L,A
		INC	[HL]

.Skip2:		DEC	B			;Don't count the focus plyr
		JR	Z,.Skip3		;who is using the large icon.

		LD	A,[wStructPotts+PLYR_SQUARE]
		LD	L,A
		INC	[HL]

.Skip3:		DEC	B			;Don't count the focus plyr
		JR	Z,.Skip4		;who is using the large icon.

		LD	A,[wStructLumir+PLYR_SQUARE]
		LD	L,A
		INC	[HL]

.Skip4:		DEC	B			;Don't count the focus plyr
		JR	Z,.Skip5		;who is using the large icon.

		LD	A,[wStructGastn+PLYR_SQUARE]
		LD	L,A
		INC	[HL]

.Skip5:		XOR	A			;Don't count people not in
		LD	[wBoardBusy],A		;the game.

		LD	A,[wStructBeast+PLYR_SQUARE]
		LD	L,A
		LD	A,[HL]
		LD	[wBoardBeast+PLYR_FOCUS],A

		LD	A,[wStructBelle+PLYR_SQUARE]
		LD	L,A
		LD	A,[HL]
		LD	[wBoardBelle+PLYR_FOCUS],A

		LD	A,[wStructPotts+PLYR_SQUARE]
		LD	L,A
		LD	A,[HL]
		LD	[wBoardPotts+PLYR_FOCUS],A

		LD	A,[wStructLumir+PLYR_SQUARE]
		LD	L,A
		LD	A,[HL]
		LD	[wBoardLumir+PLYR_FOCUS],A

		LD	A,[wStructGastn+PLYR_SQUARE]
		LD	L,A
		LD	A,[HL]
		LD	[wBoardGastn+PLYR_FOCUS],A

		RET				;All Done.



; ***************************************************************************
; * PlyrDiceResult ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlyrDiceResult::LD	A,[wWhichPlyr]		;Locate the plyr's info.
		CALL	GetPlyrInfo		;2nd die ?

		LD	HL,PlyrICmdRolled	;Dump background.
		LD	DE,wTemp512		;
		LD	BC,8			;
		CALL	MemCopy			;

		LD	C,0			;Initialize accumulator.

.Dice1:		LDH	A,[hDie1Roll]		;
		OR	A			;
		JR	Z,.Dice2		;
		ADD	C			;
		LD	C,A			;
		ADD	ICON_DIE1-1		;
		LD	[DE],A			;
		INC	DE			;

.Dice2:		LDH	A,[hDie2Roll]		;
		OR	A			;
		JR	Z,.Bonus		;
		ADD	C			;
		LD	C,A			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_PLUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LDH	A,[hDie2Roll]		;
		ADD	ICON_DIE1-1		;
		LD	[DE],A			;
		INC	DE			;

.Bonus:		LD	A,[wStructRamLo]	;
		ADD	PLYR_MODIFIER		;
		LD	L,A			;
		LD	A,[wStructRamHi]	;
		LD	H,A			;
		LD	A,[HL]			;
		OR	A			;
;		JR	Z,.ShoeTrap		;
		ADD	C			;
		LD	C,A			;
		BIT	7,[HL]			;
		JR	NZ,.BonusNeg		;

.BonusPos:	LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_PLUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HL]			;
		LD	[HL],0			;
		CALL	PrintDecimal		;
		JR	.ShoeTrap		;

.BonusNeg:	LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_MINUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HL]			;
		LD	[HL],0			;
		CPL				;
		INC	A			;
		CALL	PrintDecimal		;

.ShoeTrap:	LD	A,[wStructRamLo]	;
		ADD	PLYR_SHOETRAP		;
		LD	L,A			;
		LD	A,[wStructRamHi]	;
		LD	H,A			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Total		;
		BIT	7,A			;
		JR	NZ,.Trap		;

.Shoe:		DEC	[HL]			;
		LD	A,0+2			;
		ADD	C			;
		LD	C,A			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_PLUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SHOE		;
		LD	[DE],A			;
		INC	DE			;
		JR	.Total			;

.Trap:		INC	[HL]			;
		LD	A,0-2			;
		ADD	C			;
		LD	C,A			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_PLUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_TRAP		;
		LD	[DE],A			;
		INC	DE			;

.Total:		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_EQUALS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;

		LD	A,C			;
		LD	[wPlyrMoves],A		;
		BIT	7,A			;
		JR	Z,.Skip0		;
		LD	A,ICON_MINUS		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICON_SPACE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,C			;
		CPL				;
		INC	A			;
.Skip0:		CALL	PrintDecimal		;

		LD	A,0			;
		LD	[DE],A			;
		INC	DE			;
		LD	A,0			;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICMD_WIPE		;
		LD	[DE],A			;
		INC	DE			;
		LD	A,ICMD_END		;
		LD	[DE],A			;
		INC	DE			;

		RET				;All Done.

;
;
;

PrintDecimal::	PUSH	BC			;
		LD	B,0			;
.Loop0:		SUB	10			;
		JR	C,.Skip0		;
		INC	B			;
		JR	.Loop0			;
.Skip0:		ADD	10			;
		LD	C,A			;
		LD	A,B			;
		OR	A			;
		JR	Z,.Skip1		;
		ADD	ICON_ZERO		;
		LD	[DE],A			;
		INC	DE			;
.Skip1:		LD	A,C			;
		OR	A			;
		ADD	ICON_ZERO		;
		LD	[DE],A			;
		INC	DE			;
		POP	BC			;
		RET				;



; ***************************************************************************
; * FixDiceSpr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FixDiceSpr::	LDH	A,[hDie2Roll]		;Is a 2nd die sprite needed ?
		OR	A			;
		RET	Z			;

		LD	HL,FixDiceTbl		;
		LDH	A,[hDieFixup]		;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		JP	[HL]			;

FixDiceTbl::	DW	FixDiceSpr0		;
		DW	FixDiceSpr1		;
		DW	FixDiceSpr2		;

		NOP				;
		NOP				;
		NOP				;

;
;
;

FixDiceSpr0::	CALL	FixDiceSpr2		;

		LD	A,[wSprite0+SPR_OAM_CNT];
		LD	[wSprite1+SPR_OAM_CNT],A;
		LD	A,[wSprite0+SPR_OAM_LO]	;
		LD	[wSprite1+SPR_OAM_LO],A	;
		LD	A,[wSprite0+SPR_OAM_HI]	;
		LD	[wSprite1+SPR_OAM_HI],A	;

		LD	A,MSK_PLOT+MSK_DRAW	;
		LD	[wSprite0+SPR_FLAGS],A	;
		LD	A,MSK_PLOT		;
		LD	[wSprite1+SPR_FLAGS],A	;

		LD	A,[hDaveAnimFrm]	;
		CP	26
		RET	NZ			;

		PUSH	DE			;Preserve OAM pointer.

		LDH	A,[hDie2Roll]		;
		CALL	FixDieRemap		;

		LDH	A,[hDaveAnimFrm]	;
		CALL	MakeDaveAnim		;

		POP	DE			;Restore OAM pointer.

		LD	A,1			;
		LDH	[hDieFixup],A		;

		RET				;

FixDiceSpr1::	CALL	FixDiceSpr2		;

		LD	A,MSK_PLOT		;
		LD	[wSprite0+SPR_FLAGS],A	;
		LD	A,MSK_PLOT		;
		LD	[wSprite1+SPR_FLAGS],A	;

		LD	A,1			;
		LDH	[hDieFixup],A		;

		RET				;

FixDiceSpr2::	LDH	A,[hDaveAnimXFlip]	;
		OR	A			;
		JR	NZ,.Flipped		;

.Regular:	LD	A,[wSprite0+SPR_SCR_X]	;
		ADD	$E4			;
		LD	[wSprite1+SPR_SCR_X],A	;
		JR	.Skip0

.Flipped:	LD	A,[wSprite0+SPR_SCR_X]	;
		SUB	$E4			;
		LD	[wSprite1+SPR_SCR_X],A	;

.Skip0:		LD	A,[wSprite0+SPR_SCR_Y]	;
		ADD	$F8			;
		LD	[wSprite1+SPR_SCR_Y],A	;

		LD	A,[wSprite0+SPR_FLIP]	;
		LD	[wSprite1+SPR_FLIP],A	;
		LD	A,[wSprite0+SPR_COLR]	;
		LD	[wSprite1+SPR_COLR],A	;

		RET				;



; ***************************************************************************
; * TblDiceBeast                                                            *
; * TblDiceBelle                                                            *
; * TblDicePotts                                                            *
; * TblDiceLumiere                                                          *
; ***************************************************************************

TblPlyr2Roll::	DW	TblRollTop		;Beast
		DB	$00,0			;
		DW	TblRollTop		;Belle
		DB	$80,0			;
		DW	TblRollBtm		;Potts
		DB	$80,6			;
		DW	TblRollBtm		;Lumiere
		DB	$00,6			;

TblDiceRemap::	DB	6,11,12,13,14,1		;Remap for top animation.
		DB	8,11,12,13,14,3		;Remap for btm animation.

AnmDiceRoll::	DB	$01,3,$02,3,$03,3,$04,3,$05,3,$06,3,$07,3,$08,3
		DB	$09,3,$0A,3,$0B,3,$0C,3,$0D,3,$0E,3,$0F,3,$10,3
		DB	$11,3,$12,3,$13,3,$14,3,$15,3,$16,3,$17,3,$18,3
		DB	$19,3,$1A,3,$1B,3,$1C,3,$1D,3,$1E,3,$1F,3
		DB	0,0

TblRollTop::	DB	1
		DW	PAL_CDIETOP
		DW	IDX_CDIETOP
		DB	9,0,-88,-33
		DB	10,0,-84,-33
		DB	1,0,-80,-33
		DB	2,0,-76,-48
		DB	3,0,-72,-57
		DB	4,0,-68,-62
		DB	5,0,-64,-65
		DB	6,0,-60,-66
		DB	7,0,-56,-65
		DB	8,0,-52,-61
		DB	9,0,-48,-57
		DB	10,0,-44,-49
		DB	1,0,-40,-39
		DB	2,0,-37,-27
		DB	3,0,-35,-14
		DB	4,0,-32,-24
		DB	5,0,-28,-30
		DB	6,0,-24,-33
		DB	7,0,-20,-33
		DB	8,0,-16,-30
		DB	9,0,-12,-24
		DB	10,0,-8,-12
		DB	1,0,-5,-3
		DB	4,0,-1,-1
		DB	5,0,2,1
		DB	0,0,5,3
		DB	0,0,7,4
		DB	0,0,9,5
		DB	0,0,10,5
		DB	0,0,11,6
		DB	0,0,11,6

TblRollBtm::	DB	1
		DW	PAL_CDIEBTM
		DW	IDX_CDIEBTM
		DB	3,0,-88,44
		DB	4,0,-84,44
		DB	5,0,-80,44
		DB	6,0,-76,18
		DB	7,0,-72,2
		DB	8,0,-68,-9
		DB	9,0,-64,-16
		DB	10,0,-60,-21
		DB	1,0,-56,-25
		DB	2,0,-52,-26
		DB	3,0,-48,-25
		DB	4,0,-44,-21
		DB	5,0,-40,-16
		DB	6,0,-37,-10
		DB	7,0,-33,2
		DB	8,0,-30,14
		DB	9,0,-26,-2
		DB	10,0,-22,-9
		DB	1,0,-18,-13
		DB	2,0,-14,-13
		DB	3,0,-10,-11
		DB	4,0,-7,-7
		DB	5,0,-5,-3
		DB	6,0,-1,-5
		DB	7,0,2,-6
		DB	0,0,4,-7
		DB	0,0,6,-8
		DB	0,0,7,-9
		DB	0,0,8,-9
		DB	0,0,9,-9
		DB	0,0,9,-9





; ***************************************************************************
; * GmbMapToCamera ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbMapToCamera::LDH	A,[hCamXLo]		;
		AND	$F8			;
		LD	C,A			;
		LDH	A,[hCamXHi]		;
		LD	B,A			;
		AND	$07			;
		OR	C			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hScxBlk],A		;

		LD	HL,0			;
		ADD	HL,BC			;
		LD	A,L			;
		LDH	[hScrXLo],A		;
		LD	A,H			;
		LDH	[hScrXHi],A		;

		LDH	A,[hCamYLo]		;
		LD	E,A			;
		AND	$F8			;
		LD	L,A			;
		LDH	A,[hCamYHi]		;
		LD	D,A			;
		AND	$07			;
		OR	L			;
		RRCA				;
		RRCA				;
		RRCA				;
		LDH	[hScyBlk],A		;

		LD	HL,0-16			;
		ADD	HL,DE			;
		LD	A,L			;
		LDH	[hScrYLo],A		;
		LD	A,H			;
		LDH	[hScrYHi],A		;

		XOR	A			;
		LDH	[hScxChg],A		;
		LDH	[hScyChg],A		;

		RET				;



; ***************************************************************************
; * GmbBoardInput ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbBoardInput::	LD	A,1			;
		LDH	[hTmpLo],A		;

		LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	BIT	JOY_START,C		;
		JR	Z,.TestSelect		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestSelect:	BIT	JOY_SELECT,C		;
		JR	Z,.TestShoot		;

		LD	A,[wFocusPlyr]		;Switch focus.
		CALL	FindNextPlyr		;
		LD	[wFocusPlyr],A		;

		LD	A,[wFocusPlyr]		;
		JP	GmbFocusBoard		;

.TestShoot:	AND	MSK_JOY_A|MSK_JOY_B	;Shoot ?
		JR	Z,.TestDirection	;

		JR	.TestDirection		;

.TestDirection:

.TestR:		LD	A,[wJoy1Cur]		;
		BIT	JOY_R,A			;
		JR	Z,.TestL		;

		CALL	GmbBoardPushR		;

.TestL:		LD	A,[wJoy1Cur]		;
		BIT	JOY_L,A			;
		JR	Z,.TestU		;

		CALL	GmbBoardPushL		;

.TestU:		LD	A,[wJoy1Cur]		;
		BIT	JOY_U,A			;
		JR	Z,.TestD		;

		CALL	GmbBoardPushU		;

.TestD:		LD	A,[wJoy1Cur]		;
		BIT	JOY_D,A			;
		JR	Z,.TestDone		;

		CALL	GmbBoardPushD		;

.TestDone:	JP	GmbBoardPushed		;

;		RET				;




; ***************************************************************************
; * GmbBigBoard ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbBigBoard::	LD	A,[wWhichPlyr]		;
		LD	[wFocusPlyr],A		;

		CALL	GmbBoardDraw		;Draw the big board.

		LD	A,[wWhichPlyr]		;
		SUB	PLYR_GASTN		;
		LDH	[hFirstMove],A		;

		LD	A,$FF			;
		LD	[wJoy1Cur],A		;

		LD	A,20			;
		CALL	AnyWait			;

		CALL	GmbBoardAuto		;

		LD	A,10			;
		CALL	AnyWait			;

		CALL	GmbFinalFocus		;

		CALL	GmbBoardUser		;

		CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;All Done.

;
;
;

GmbBoardDraw::	CALL	ClrWorkspace		;Clear the game's workspace.

		LD	A,[wWhichPlyr]		;
		LD	[wFocusPlyr],A		;

		LD	A,BUTTON_UP_DELAY*2	;
		LDH	[hButtonDelay],A	;
		XOR	A			;
		LDH	[hButtonFrame],A	;

		XOR	A			;
		LDH	[hCamXLo],A		;
		LDH	[hCamXHi],A		;
		LDH	[hCamYLo],A		;
		LDH	[hCamYHi],A		;

		CALL	SetMachineJcb		;Reset machine to known state.

;		LD	A,%11010010		;Initialize PAL data.
		LD	A,%11100100		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	InitBoardPlyrs		;Initialize the players.
		CALL	CalcBoardPosn		;

		CALL	InitBoardSpr		;

		CALL	GmbInitBoard		;Initialize the board gfx.

		CALL	DrawGuardPos		;Superimpose the guards.

		LD	A,[wFocusPlyr]		;Set camera position.
		CALL	SetCameraToWho		;

		CALL	GmbMapToCamera		;Use camera position.

		LDH	A,[hScxBlk]		;Draw the complete screen.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;
		CALL	GmbMapRefresh		;

		CALL	MakeBoardSpr		;
		CALL	DumpBoardSpr		;
		CALL	WaitForVBL		;
		CALL	DrawBoardSpr		;

		LD	A,0			;Init scroll position.
		LDH	[hVblSCX],A		;
		LD	A,0			;
		LDH	[hVblSCY],A		;
		LD	A,$FF			;
		LDH	[hPosFlag],A		;

		JP	FadeInBlack		;Fade in from black.

;
;
;

GmbBoardAuto::	XOR	A			;
		LDH	[hInPosition],A		;

.Loop1:		CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	GmbTrackFocus		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		CALL	GmbTstPosition		;

		CALL	MakeBoardSpr		;
		CALL	DrawBoardSpr		;

		LDH	A,[hInPosition]		;
		CP	DELAY_ONSQUARE		;
		JR	C,.Loop1		;

;		CALL	GmbTrackFocus		;

.Move:		LD	A,[wPlyrMoves]		;
		OR	A			;
		RET	Z			;

		BIT	7,A			;
		JR	NZ,.Backwards		;

.Forewards:	DEC	A			;
		LD	[wPlyrMoves],A		;
		CALL	NextPlyrSquare		;
		JR	Z,.Move			;
		CALL	ShowPlyrSquare		;
		JR	GmbBoardAuto		;

.Backwards:	INC	A			;
		LD	[wPlyrMoves],A		;
		CALL	PrevPlyrSquare		;
		JR	Z,.Move			;
		CALL	ShowPlyrSquare		;
		JR	GmbBoardAuto		;

;
;
;

GmbBoardUser::	XOR	A			;
		LDH	[hIntroDelay],A		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to wait for a delay
		LD	HL,PLYR_FLAGS		;or a joypad.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	Z,.Loop0		;

		LD	A,SHOW_DICE_DELAY*2	;
		LDH	[hIntroDelay],A		;

.Loop0:		CALL	WaitForVBL		;Synchronize to the VBL.

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to wait for a delay
		LD	HL,PLYR_FLAGS		;or a joypad.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		JR	NZ,.Skip0		;

		CALL	GmbBoardInput		;

		CALL	ShowBoardBtn		;
		CALL	DrawBoardSpr		;

.Skip0:		LDH	A,[hIntroDelay]		;
		OR	A			;
		JR	Z,.Skip1		;
		DEC	A			;
		JR	Z,.Done			;
		LDH	[hIntroDelay],A		;

.Skip1:		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_A|MSK_JOY_B
		JR	Z,.Loop0		;

.Done:		RET				;

;
;
;

GmbTstPosition::LD	A,[wFocusPlyr]		;
		CALL	GetPlyrInfo		;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_MIX		;
		LD	L,A			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Skip0		;
		DEC	A			;
		LD	[HL],A			;

		LD	A,[wFocusPlyr]		;
		CALL	MixPlyrPos		;

		JR	.Skip2			;

.Skip0:		LDH	A,[hInPosition]		;
		INC	A			;
		JR	NZ,.Skip1		;
		DEC	A			;
.Skip1:		LDH	[hInPosition],A		;
		RET				;

.Skip2:		XOR	A			;
		LDH	[hInPosition],A		;
		RET				;

;
;
;

GmbFocusBoard::	PUSH	AF			;Remove old sprites.
		CALL	SprOff			;
		CALL	WaitForVBL		;
		POP	AF			;

		PUSH	AF			;
		CALL	NewPlyrPos		;
		POP	AF			;
		CALL	SetCameraToWho		;

		CALL	CalcBoardPosn		;

		CALL	GmbMapToCamera		;Use camera position.

		LDH	A,[hScxBlk]		;Draw the complete screen.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;
		CALL	GmbMapRefresh		;

		CALL	InitBoardSpr		;Update new sprites.
		CALL	MakeBoardSpr		;
		CALL	DumpBoardSpr		;
		CALL	WaitForVBL		;
;		CALL	ShowBoardBtn		;
		CALL	DrawBoardSpr		;
		JP	WaitForVBL		;

;
;
;

GmbTrackFocus::	LD	A,1			;
		LDH	[hTmpLo],A		;

		LD	A,[wFocusPlyr]		;Locate the plyr.
		CALL	GetPlyrInfo		;

		LD	A,[wBoardTmpLo]		;
		ADD	PLYR_CUR_X		;
		LD	L,A			;
		LD	A,[wBoardTmpHi]		;
		LD	H,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		PUSH	DE			;

		LDH	A,[hScrXLo]		;
		CPL				;
		LD	L,A			;
		LDH	A,[hScrXHi]		;
		CPL				;
		LD	H,A			;
		ADD	HL,BC			;
		LD	BC,1			;
		ADD	HL,BC			;

		PUSH	HL			;
		LD	BC,0+8			;
		ADD	HL,BC			;
		BIT	7,H			;
		CALL	NZ,GmbBoardPushL	;

		POP	HL			;
		LD	BC,0-(152)		;
		ADD	HL,BC			;
		BIT	7,H			;
		CALL	Z,GmbBoardPushR		;

		POP	DE			;

		LDH	A,[hScrYLo]		;
		CPL				;
		LD	L,A			;
		LDH	A,[hScrYHi]		;
		CPL				;
		LD	H,A			;
		ADD	HL,DE			;
		LD	DE,1			;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		PUSH	HL			;
		LD	DE,0-32			;
		ADD	HL,DE			;
		BIT	7,H			;
		CALL	NZ,GmbBoardPushU	;

		POP	HL			;
		LD	DE,0-(160)		;
		ADD	HL,DE			;
		BIT	7,H			;
		CALL	Z,GmbBoardPushD		;

;		RET				;

GmbBoardPushed::LDH	A,[hTmpLo]		;
		OR	A			;
		RET	NZ			;

		CALL	SprOff			;
		CALL	WaitForVBL		;

		CALL	GmbMapToCamera		;Use camera position.

		LDH	A,[hScxBlk]		;Draw the complete screen.
		LD	B,A			;
		LDH	A,[hScyBlk]		;
		LD	C,A			;
		CALL	GmbMapRefresh		;

		CALL	InitBoardSpr		;Update new sprites.
		CALL	MakeBoardSpr		;
		CALL	DumpBoardSpr		;
		CALL	WaitForVBL		;
		CALL	DrawBoardSpr		;

;		LD	A,20			;
;		JP	AnyWait			;

		JP	WaitForVBL		;

GmbBoardPushL::	LD	A,[hCamXLo]		;
		LD	E,A			;
		LD	A,[hCamXHi]		;
		LD	D,A			;
		LD	HL,0-144		;
		ADD	HL,DE			;
		JR	GmbBoardPushX		;

GmbBoardPushR::	LD	A,[hCamXLo]		;
		LD	E,A			;
		LD	A,[hCamXHi]		;
		LD	D,A			;
		LD	HL,0+144		;
		ADD	HL,DE			;
;		JR	GmbBoardPushX		;

GmbBoardPushX::	CALL	CamCmpMinX		;
		LD	A,L			;
		CP	E			;
		JR	NZ,.Skip0		;
		LD	A,H			;
		CP	D			;
		JR	NZ,.Skip0		;
		RET				;
.Skip0:		XOR	A			;
		LDH	[hTmpLo],A		;
		RET				;

GmbBoardPushU::	LD	A,[hCamYLo]		;
		LD	C,A			;
		LD	A,[hCamYHi]		;
		LD	B,A			;
		LD	HL,0-96			;
		ADD	HL,BC			;
		JR	GmbBoardPushY		;

GmbBoardPushD::	LD	A,[hCamYLo]		;
		LD	C,A			;
		LD	A,[hCamYHi]		;
		LD	B,A			;
		LD	HL,0+96			;
		ADD	HL,BC			;
;		JR	GmbBoardPushY		;

GmbBoardPushY::	CALL	CamCmpMinY		;
		LD	A,L			;
		CP	C			;
		JR	NZ,.Skip0		;
		LD	A,H			;
		CP	B			;
		JR	NZ,.Skip0		;
		RET				;
.Skip0:		XOR	A			;
		LDH	[hTmpLo],A		;
		RET				;

;
;
;

GmbFinalFocus::	LD	HL,hCamXLo		;Save the current camera
		LD	A,[HLI]			;position.
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		PUSH	BC			;
		PUSH	DE			;

		LD	A,[wFocusPlyr]		;Calc the ideal camera
		CALL	SetCameraToWho		;position.

		POP	DE			;
		POP	BC			;
		PUSH	BC			;
		PUSH	DE			;

		LD	HL,hCamXLo		;Calc the difference
		LD	A,[HLI]			;between the two.
		SUB	C			;
		LD	C,A			;
		LD	A,[HLI]			;
		SBC	B			;
		LD	B,A			;
		LD	A,[HLI]			;
		SUB	E			;
		LD	E,A			;
		LD	A,[HLI]			;
		SBC	D			;
		LD	D,A			;

		LD	HL,48			;Allow +/- 40 deltaX.
		ADD	HL,BC			;
		LD	BC,0-96			;
		ADD	HL,BC			;
		JR	C,.ReFocus		;

		LD	HL,24			;Allow +/- 24 deltaY.
		ADD	HL,DE			;
		LD	DE,0-48			;
		ADD	HL,BC			;
		JR	C,.ReFocus		;

.Done:		POP	DE			;
		POP	BC			;

		LD	HL,hCamXLo		;
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		RET				;All Done.

.ReFocus:	LD	A,[wFocusPlyr]		;
		CALL	GmbFocusBoard		;
		JR	.Done			;



; ***************************************************************************
; * FindGuardPos ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     ZF if unable to move                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FindGuardPos::	XOR	A			;Reset guard positions.
		LD	[wGuardPosnLo],A	;
		LD	[wGuardPosnHi],A	;
		LD	[wGuard1Sqr],A		;
		LD	[wGuard2Sqr],A		;
		LD	[wGuard3Sqr],A		;
		LD	[wGuard4Sqr],A		;
		LD	[wGuard5Sqr],A		;
		LD	[wGuard6Sqr],A		;
		LD	[wGuard7Sqr],A		;
		LD	[wGuard8Sqr],A		;
		LD	[wGuard9Sqr],A		;

		LD	A,[wBoardGrdLo]		;
		LD	L,A			;
		LD	A,[wBoardGrdHi]		;
		LD	H,A			;

		LD	DE,wGuard1Sqr		;
		LD	BC,256			;

.Loop:		LD	A,[HLI]			;Read next guard's position.
		OR	A			;
		RET	Z			;

		PUSH	BC			;

		LD	C,A			;
		LD	[DE],A			;
		INC	DE			;

		PUSH	BC			;
		PUSH	HL			;

		LD	B,0			;Locate info for this square.
		LD	L,C			;
		LD	H,B			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;
		LD	A,[wBoardSqrLo]		;
		LD	C,A			;
		LD	A,[wBoardSqrHi]		;
		LD	B,A			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Get square's X and Y.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	DE			;

		POP	HL			;
		POP	BC			;

		LD	A,[HLI]			;Get offset's X and Y.
		LD	[DE],A			;
		INC	DE			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	DE			;

		LD	A,[wStructBeast+PLYR_SQUARE]
		CP	C
		JR	Z,.Move
		LD	A,[wStructBelle+PLYR_SQUARE]
		CP	C
		JR	Z,.Move
		LD	A,[wStructPotts+PLYR_SQUARE]
		CP	C
		JR	Z,.Move
		LD	A,[wStructLumir+PLYR_SQUARE]
		CP	C
		JR	Z,.Move

		JR	.Next			;

.Move:		POP	BC			;
		LD	A,[wGuardPosnLo]	;
		OR	C			;
		LD	[wGuardPosnLo],A	;
		LD	A,[wGuardPosnHi]	;
		OR	B			;
		LD	[wGuardPosnHi],A	;
		PUSH	BC			;

.Next:		POP	BC			;
		SRL	B			;
		RR	C			;
		JR	.Loop			;



; ***************************************************************************
; * DrawGuardPos ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawGuardPos::	LD	HL,wGuard1Sqr		;
		LD	BC,256			;

.Loop:		PUSH	BC			;Preserve counters.
		PUSH	HL			;

		LD	A,[HLI]			;Is this guard active ?
		OR	A			;
		JR	Z,.Next			;

		LD	A,[HLI]			;Get guard's normal posn.
		LD	D,A			;
		LD	A,[HLI]			;
		LD	E,A			;

		LD	A,[wGuardPosnLo]	;
		AND	C			;
		JR	NZ,.Skip0		;
		LD	A,[wGuardPosnHi]	;
		AND	B			;
		JR	Z,.Skip1		;

.Skip0:		LD	A,[HLI]			;Get guard's alternate posn.
		ADD	D			;
		LD	D,A			;
		LD	A,[HLI]			;
		ADD	E			;
		LD	E,A			;

.Skip1:		LD	H,HIGH(wTblDivide3)	;Convert chr coordinates to
		LD	L,D			;blk coordinates (x2).
		LD	D,[HL]			;
		LD	L,E			;
		LD	E,[HL]			;

		LD	HL,wTblMapLine		;Use blk coordinates to
		LD	A,E			;calc map address.
		ADD	L			;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		ADD	D			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;

.Skip2:		LD	BC,GmbGuardBlocks	;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip3		;
		LD	BC,CgbGuardBlocks	;

.Skip3:		LD	A,[BC]			;Modify the top 2 blks of
		INC	BC			;the guard.
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;

		LD	A,[wMapData+6]		;Move to next row in map.
		SUB	4			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip4		;
		INC	H			;

.Skip4:		LD	A,[BC]			;Modify the btm 2 blks of
		INC	BC			;the guard.
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;

.Next:		POP	HL			;Next guard.
		LD	DE,5			;
		ADD	HL,DE			;
		POP	BC			;
		SRL	B			;
		RR	C			;
		LD	A,B			;
		OR	C			;
		JR	NZ,.Loop		;

		RET				;All Done.

GmbGuardBlocks::DW	(BBOARDS_BLK+$00)-$4000
		DW	(BBOARDS_BLK+$12)-$4000
		DW	(BBOARDS_BLK+$24)-$4000
		DW	(BBOARDS_BLK+$36)-$4000

CgbGuardBlocks::DW	(CBOARDS_BLK+$00)-$4000
		DW	(CBOARDS_BLK+$12)-$4000
		DW	(CBOARDS_BLK+$24)-$4000
		DW	(CBOARDS_BLK+$36)-$4000



; ***************************************************************************
; * DumpText ()                                                             *
; ***************************************************************************
; * Display all the game text.                                              *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpText::	NOP

		LD	HL,MultiWinBeast
		CALL	TalkingHeads
		LD	HL,MultiWinBelle
		CALL	TalkingHeads
		LD	HL,MultiWinPotts
		CALL	TalkingHeads
		LD	HL,MultiWinLumir
		CALL	TalkingHeads

		LD	A,PLYR_BEAST
		CALL	DumpWhom
		LD	A,PLYR_BELLE
		CALL	DumpWhom
		LD	A,PLYR_POTTS
		CALL	DumpWhom
		LD	A,PLYR_LUMIR
		CALL	DumpWhom

		LD	HL,IntroStory1
		CALL	TalkingHeads
		LD	HL,IntroFinish1
		CALL	TalkingHeads
		LD	HL,IntroStory2
		CALL	TalkingHeads
		LD	HL,IntroFinish2
		CALL	TalkingHeads
		LD	HL,IntroStory3
		CALL	TalkingHeads

		LD	HL,IntroStoryWin
		CALL	TalkingHeads
		LD	HL,IntroStoryLose
		CALL	TalkingHeads

		LD	HL,IntroKnight
		CALL	TalkingHeads
		LD	HL,IntroStarSqr
		CALL	TalkingHeads

		LD	HL,IntroUnlockMap
		CALL	TalkingHeads

		LD	HL,IntroCellar
		CALL	TalkingHeads
		LD	HL,IntroChip
		CALL	TalkingHeads
		LD	HL,IntroChopper
		CALL	TalkingHeads
		LD	HL,IntroRide
		CALL	TalkingHeads
		LD	HL,IntroStove
		CALL	TalkingHeads
		LD	HL,IntroSultan
		CALL	TalkingHeads
		LD	HL,IntroTarget
		CALL	TalkingHeads
		LD	HL,IntroWhack
		CALL	TalkingHeads

		LD	HL,IntroBonus
		CALL	TalkingHeads
		LD	HL,IntroMind
		CALL	TalkingHeads
		LD	HL,IntroSpit
		CALL	TalkingHeads

		LD	A,0
		CALL	DisplayStageN
		LD	A,1
		CALL	DisplayStageN
		LD	A,2
		CALL	DisplayStageN
		LD	A,3
		CALL	DisplayStageN

		LD	BC,PlyrICmdLucky0
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky1
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky3
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky5
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky6
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky7
		CALL	ShowCardLucky
		LD	BC,PlyrICmdLucky8
		CALL	ShowCardLucky

		LD	BC,PlyrICmdGastnX
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastnC
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastnB
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastn1
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastn2
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastn3
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastn4
		CALL	ShowCardGastn
		LD	BC,PlyrICmdGastn5
		CALL	ShowCardGastn

		LD	A,PLYR_BEAST		;
		LD	[wWhichPlyr],A		;
		CALL	GetPlyrInfo		;
		LD	HL,PLYR_FLAGS		;
		ADD	HL,BC			;
		RES	PFLG_CPU,[HL]		;

		LD	E,152
		LD	A,0
		LD	[wStructBeast+PLYR_STARS],A
		CALL	DumpResult
		LD	E,153
		LD	A,1
		LD	[wStructBeast+PLYR_STARS],A
		CALL	DumpResult
		LD	E,154
		LD	A,2
		LD	[wStructBeast+PLYR_STARS],A
		CALL	DumpResult
		LD	E,155
		LD	A,3
		LD	[wStructBeast+PLYR_STARS],A
		CALL	DumpResult
		LD	E,156
		XOR	A
		CALL	DumpResult
		LD	E,157
		XOR	A
		CALL	DumpResult
		LD	E,158
		XOR	A
		CALL	DumpResult
		LD	E,159
		XOR	A
		CALL	DumpResult

		LD	A,0
		LD	[wSubStage],A
		CALL	DumpSpit
		LD	A,1
		LD	[wSubStage],A
		CALL	DumpSpit
		LD	A,2
		LD	[wSubStage],A
		CALL	DumpSpit

		RET

DumpSpit::	XOR	A
		LD	[wSubStars],A
		LD	DE,162
		CALL	GetString
		LD	HL,wString
		LD	DE,wStringLine2
		CALL	StrCpy
		LD	HL,wStringLine2
		JP	LevelResultS

DumpResult::	LD	[wSubStage],A
		XOR	A
		LD	[wSubStars],A
		LD	D,0
		CALL	GetString
		LD	HL,wString
		LD	DE,wStringLine2
		CALL	StrCpy
		LD	HL,wStringLine2
		JP	LevelResult

DumpWhom::	LD	[wWhichPlyr],A
		LD	A,[wWhichPlyr]
		CALL	GetPlyrInfo
		LD	HL,PLYR_FLAGS
		ADD	HL,BC
		SET	PFLG_SKIP,[HL]
		CALL	PlyrShowWhom
		LD	A,[wWhichPlyr]
		CALL	GetPlyrInfo
		LD	HL,PLYR_FLAGS
		ADD	HL,BC
		RES	PFLG_SKIP,[HL]
		JP	PlyrShowWhom



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;
; Board Layouts.
;

		IF	VERSION_USA
		INCLUDE	"boardusa.asm"
		ELSE
		INCLUDE	"boardjap.asm"
		ENDC

;
;square, movex, movey
;

TblNoGuards::	DB	0

TblGuardsM1::	DB	76,0+0,0+6
		DB	67,0+0,0-6
		DB	58,0+0,0+6
		DB	49,0+0,0-6
		DB	26,0-6,0+0		;Robert Hates This
		DB	12,0+6,0+0		;Robert Hates This
		DB	0

TblGuardsM2::	DB	81,0+0,0+6
		DB	75,0+0,0-6
		DB	69,0+0,0+6
		DB	62,0+0,0-6
		DB	61,0+6,0-0
		DB	60,0+0,0-6
		DB	41,0-6,0+0		;Robert Hates This
		DB	27,0+6,0+0		;Robert Hates This
		DB	13,0-6,0+0		;Robert Hates This
		DB	0

TblGuardsM3::	DB	65,0+0,0-6
		DB	59,0+0,0-6
		DB	55,0+0,0-6
		DB	32,0-6,0+0		;Robert Hates This
		DB	31,0+0,0-6		;Robert Hates This
		DB	15,0+6,0+0		;Robert Hates This
		DB	14,0+0,0-6		;Robert Hates This
		DB	0


