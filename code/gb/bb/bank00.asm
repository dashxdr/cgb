; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** GAMEBOY COURTSIDE                                             PROGRAM **
; **                                                                       **
; ** Last modified : 990218 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** Designed for an MBC5 with 64 banks of ROM and 1 bank of RAM.          **
; **                                                                       **
; ** Bank $00 -                         Bank $20 - FileSys                 **
; ** Bank $01 -                         Bank $21 - FileSys                 **
; ** Bank $02 - SGB Init                Bank $22 - FileSys                 **
; ** Bank $03 -                         Bank $23 - FileSys                 **
; ** Bank $04 - Sultan game             Bank $24 - FileSys                 **
; ** Bank $05 - Sound                   Bank $25 - FileSys                 **
; ** Bank $06 -                         Bank $26 - FileSys                 **
; ** Bank $07 -                         Bank $27 - FileSys                 **
; ** Bank $08 -                         Bank $28 - FileSys                 **
; ** Bank $09 -                         Bank $29 - FileSys                 **
; ** Bank $0A - Fonts                   Bank $2A - FileSys                 **
; ** Bank $0B - Sprites + Palettes      Bank $2B - FileSys                 **
; ** Bank $0C - Sprites                 Bank $2C - FileSys                 **
; ** Bank $0D - Sprites                 Bank $2D - FileSys                 **
; ** Bank $0E - Sprites                 Bank $2E - FileSys                 **
; ** Bank $0F - Sprites                 Bank $2F - FileSys                 **
; ** Bank $10 - Sprites                 Bank $30 - FileSys                 **
; ** Bank $11 - Sprites                 Bank $31 - FileSys                 **
; ** Bank $12 - Sprites                 Bank $32 - FileSys                 **
; ** Bank $13 - Sprites                 Bank $33 - FileSys                 **
; ** Bank $14 - Sprites                 Bank $34 - FileSys                 **
; ** Bank $15 - FileSys                 Bank $35 - FileSys                 **
; ** Bank $16 - FileSys                 Bank $36 - BBoard Chr              **
; ** Bank $17 - FileSys                 Bank $37 - BBoard Chr              **
; ** Bank $18 - FileSys                 Bank $38 - BBoard Chr              **
; ** Bank $19 - FileSys                 Bank $39 - BBoard Blk              **
; ** Bank $1A - FileSys                 Bank $3A - CBoard Chr              **
; ** Bank $1B - FileSys                 Bank $3B - CBoard Chr              **
; ** Bank $1C - FileSys                 Bank $3C - CBoard Chr              **
; ** Bank $1D - FileSys                 Bank $3D - CBoard Blk              **
; ** Bank $1E - FileSys                 Bank $3E - Strings                 **
; ** Bank $1F - FileSys                 Bank $3F - Strings                 **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"gamebank00",HOME
		section 0

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;
; ROM PAGE 0 ($0000-$3FFF) - MAIN PROGRAM CODE
;
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;
; INTERRUPT VECTORS ($0000-$00FF)
;
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;
; ERROR TRAP
;
; A=1          Run out of sprites in SPR_OAM_FWD.
; A=2          Run out of time in putting character bullets @ $E0 on screen.
; A=3          Run out of time in putting character bullets @ $F0 on screen.
;

VecReset::	DI
		JP	VecReset

		DCB	4,0

;
; $0008 - RST INDIRECT_HL
;

IndirectHL::	JP	[HL]

		DCB	7,0

;
; $0010 - RST INDIRECT_DE
;

IndirectDE::	PUSH	DE
		RET

		DCB	6,0

;
; $0018 - RST 3
;

		RET

		DCB	7,0

;
; $0020 - RST 4
;

		RET

		DCB	7,0

;
; $0028 - RST 5
;

		RET

		DCB	7,0

;
; $0030 - RST 6
;

		RET

		DCB	7,0

;
; $0038 - RST 7
;

		RET

		DCB	7,0

;
; $0040 - Vertical blank interrupt
;

VecVbl::	JR	VblInterrupt

		DCB	6,0

;
; $0048 - LCDC status interrupt.
;

VecLyc::	PUSH	AF
		JP	wJmpLycVector

		DCB	4,0

;
; $0050 - Timer overflow interrupt.
;

VecTimer::	RETI				;$0050

		DCB	7,0

;
; $0058 - SIO transfer interrupt.
;

VecSio::	RETI				;$0058

		DCB	7,0

;
; $0060 - Keyboard interrupt.
;

VecKbd::	RETI				;$0060

		DCB	7,0



;
; VBL interrupt main code.
;

VblInterrupt::	PUSH	AF			;4

		LDIO	A,[rLY]			;3   Confirm that we're at
		CP	144-1			;2   the start of vertical
		JR	C,VblMissed		;3/2 blank.
		CP	146+1			;2
		JR	NC,VblMissed		;3/2

		LDH	A,[hVblLCDC]		;3   Update rLCDC.
		LDIO	[rLCDC],A		;3

		LDH	A,[hRomBank]		;3   Preserve current banks.
		LDH	[hVblBank],A		;3

		PUSH	BC			;4   Preserve registers.
		PUSH	DE			;4
		PUSH	HL			;4

		LDH	A,[hOamFlag]		;3   Transfer OAM ram ?
		OR	A			;1
		CALL	NZ,hOamXfer		;174/3

		LDH	A,[hPalFlag]		;3   Transfer palettes ?
		OR	A			;1
		CALL	NZ,wJmpXferColor	;x,3

		CALL	wJmpVblVector		;?   Call user routine.

		EI				;Enable interrupts.

		LD	A,BANK(MzRefresh)	;Process 60Hz music refresh.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	MzRefresh		;

		LDH	A,[hVblBank]		;Restore cartridge bank
		LDH	[hRomBank],A		;registers.
		LD	[rMBC_ROM],A		;
		LDH	A,[hRamBank]		;
		LD	[rMBC_RAM],A		;

		LDH	A,[hMachine]		;Restore hardware bank
		CP	MACHINE_CGB		;registers.
		JR	NZ,VblFinished		;
		LDH	A,[hWrkBank]		;
		LDIO	[rSVBK],A		;
		LDH	A,[hVidBank]		;
		LDIO	[rVBK],A		;

VblFinished::	XOR	A			;Signal that the OAM and
		LDH	[hPalFlag],A		;palette data has been
		LDH	[hPosFlag],A		;transferred.
		LDH	[hOamFlag],A

		DEC	A			;Signal that a vbl has
		LDH	[hVblFlag],A		;occurred.

		LDH	A,[hVblCount]		;Increment frame count.
		INC	A			;
		LDH	[hVblCount],A		;

		LDH	A,[hVbl8]
		ADD	8
		LDH	[hVbl8],A

		POP	HL			;
		POP	DE			;
		POP	BC			;

VblAbort::	POP	AF			;
		RETI				;

VblMissed::	POP	AF			;
		RETI				;



; ***************************************************************************
; * StructSmodGmb                                                           *
; * StructSmodCgb                                                           *
; ***************************************************************************
; * Tabels of jump intructions used to self-modify program behaviour        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************

LENGTH_SMOD	EQU	$16

StructSmodGmb::	DB	0			;00 wStructSmod
		JP	VblDoNothing		;01 wJmpVblVector
		JP	LycDoNothing		;04 wJmpLycVector
		JP	GmbFadePalette		;07 wJmpFadeColor
		JP	GmbXferPalette		;0A wJmpXferColor
		JP	GmbSprDumpLRTB		;0D wJmpSprLRTB
		JP	GmbSprDumpRLTB		;10 wJmpSprRLTB
		JP	GmbSprDumpSmod		;13 wJmpSprDumpMod

StructSmodCgb::	DB	1			;00 wStructSmod
		JP	VblDoNothing		;01 wJmpVblVector
		JP	LycDoNothing		;04 wJmpLycVector
		JP	CgbFadePalette		;07 wJmpFadeColor
		JP	CgbXferPalette		;0A wJmpXferColor
		JP	CgbSprDumpLRTB		;0D wJmpSprLRTB
		JP	CgbSprDumpRLTB		;10 wJmpSprRLTB
		JP	CgbSprDumpSmod		;13 wJmpSprDumpMod

;
; Pad out to address $0100
;


PADDING::	DCB	$0100-(@-VecReset),0


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;
; CARTRIDGE REGISTRATION DATA ($0100-$014F)
;
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		NOP				;$0100 NULL byte.
		JP	ResetMachine		;$0101 Program start address.
		DB	$CE,$ED,$66,$66		;$0104 Nintendo character data.
		DB	$CC,$0D,$00,$0B
		DB	$03,$73,$00,$83
		DB	$00,$0C,$00,$0D
		DB	$00,$08,$11,$1F
		DB	$88,$89,$00,$0E
		DB	$DC,$CC,$6E,$E6
		DB	$DD,$DD,$D9,$99
		DB	$BB,$BB,$67,$63
		DB	$6E,$0E,$EC,$CC
		DB	$DD,$DC,$99,$9F
		DB	$BB,$B9,$33,$3E
		DB	"B","E","A","U"		;$0134 Game title.
		DB	"T","Y","B","E"
		DB	"A","S","T"
		IF	VERSION_USA		;
		DB	"A","V","U","E"		;$013F Game code.
		ENDC				;
		IF	VERSION_EUROPE		;
		DB	"A","V","U","P"		;$013F Game code.
		ENDC				;
		IF	VERSION_JAPAN		;
		DB	"A","V","U","J"		;$013F Game code.
		ENDC				;
		DB	$80			;$0143 CGB function code.
		DB	$30,$31			;$0144 Maker code.
		DB	$03			;$0146 SGB function code.
		DB	MBC5_BACKUP		;$0147 Cartridge type.
		DB	ROM_8M			;$0148 ROM size.
		DB	RAM_64K			;$0149 RAM size.
		IF	VERSION_JAPAN		;
		DB	JAPAN_CODE		;$014A Destination code.
		ELSE				;
		DB	WORLD_CODE		;$014A Destination code.
		ENDC				;
		DB	$33			;$014B SGB function code.
		DB	$00			;$014C Version number.
		DB	0			;$014D Complement check.
		DW	0			;$014E Check sum.



; ***************************************************************************
; * TblJoyA2Dirn                                                    00:0150 *
; ***************************************************************************
; * Xvert hardware joypad direction into game direction (Robert's mapping)  *
; ***************************************************************************
; * N.B.          U           7 8 1                                         *
; *              \|/           \|/                                          *
; *             L-0-R   -->   6-0-2                                         *
; *              /|\           /|\                                          *
; *               D           5 4 3                                         *
; *                                                                         *
; *             This table MUST be 16-byte aligned.                         *
; ***************************************************************************

TblJoyA2Dirn::	DB	0			;----
		DB	2			;---R
		DB	6			;--L-
		DB	0			;--LR
		DB	8			;-U--
		DB	1			;-U-R
		DB	7			;-UL-
		DB	8			;-ULR
		DB	4			;D---
		DB	3			;D--R
		DB	5			;D-L-
		DB	4			;D-LR
		DB	0			;DU--
		DB	2			;DU-R
		DB	6			;DUL-
		DB	0			;DULR


; ***************************************************************************
; * TblJoyB2Dirn                                                    00:0160 *
; ***************************************************************************
; * Xvert hardware joypad direction into game direction (Elmer's mapping)   *
; ***************************************************************************
; * N.B.          U           8 1 2                                         *
; *              \|/           \|/                                          *
; *             L-0-R   -->   7-0-3                                         *
; *              /|\           /|\                                          *
; *               D           6 5 4                                         *
; *                                                                         *
; *             This table MUST be 16-byte aligned.                         *
; ***************************************************************************

TblJoyB2Dirn::	DB	0			;----
		DB	3			;---R
		DB	7			;--L-
		DB	0			;--LR
		DB	1			;-U--
		DB	2			;-U-R
		DB	8			;-UL-
		DB	1			;-ULR
		DB	5			;D---
		DB	4			;D--R
		DB	6			;D-L-
		DB	5			;D-LR
		DB	0			;DU--
		DB	3			;DU-R
		DB	7			;DUL-
		DB	0			;DULR



; ***************************************************************************
; * TblDirn2DULR                                                    00:0170 *
; ***************************************************************************
; * Xvert normalized game direction to normalized joypad direction          *
; ***************************************************************************
; * N.B.        8 1 2           U     U = +ve X                             *
; *              \|/           \|/    R = +ve Y                             *
; *             7-0-3   -->   L-0-R   D = -ve X                             *
; *              /|\           /|\    L = -ve Y                             *
; *             6 5 4           D                                           *
; *                                                                         *
; *             This table MUST be 16-byte aligned.                         *
; ***************************************************************************

TblDirn2DULR::	DB	%0000			;0
		DB	%0100			;1
		DB	%0101			;2
		DB	%0001			;3
		DB	%1001			;4
		DB	%1000			;5
		DB	%1010			;6
		DB	%0010			;7
		DB	%0110			;8
		DB	%0000			;9 (illegal)
		DB	%0000			;A (illegal)
		DB	%0000			;B (illegal)
		DB	%0000			;C (illegal)
		DB	%0000			;D (illegal)
		DB	%0000			;E (illegal)
		DB	%0000			;F (illegal)



; ***************************************************************************
; * VblVectors                                                      00:0180 *
; ***************************************************************************
; * Table of jump addresses to VBL interrupt routines                       *
; ***************************************************************************
; * N.B.        This table MUST not cross a page boundary.                  *
; ***************************************************************************

VblDoNothing::	JP	DoVblNull
VblNormal::	JP	DoVblNormal
VblIntro::	JP	DoVblIntro
VblScroll::	JP	DoVblScroll
VblTargetRange::JP	DoVblTarget
VblGmbBoard::	JP	DoVblGmbBoard

LycDoNothing::	JP	DoLycNull
LycNormal::	JP	DoLycNormal
LycIntro::	JP	DoLycNormal
LycScroll::	JP	DoLycNormal
LycTargetRange::JP	DoLycNull
LycGmbBoard0::	JP	DoLycGmbBoard0
LycGmbBoard1::	JP	DoLycGmbBoard1
LycGmbBoard2::	JP	DoLycGmbBoard2

;
;Table of sprite structure locations
;Must not cross page boundary
;

FigureTable::	DW	wTemp512+SIZE_SPR*01
		DW	wTemp512+SIZE_SPR*02
		DW	wTemp512+SIZE_SPR*03
		DW	wTemp512+SIZE_SPR*04
		DW	wTemp512+SIZE_SPR*05
		DW	wTemp512+SIZE_SPR*06
		DW	wTemp512+SIZE_SPR*07
		DW	wTemp512+SIZE_SPR*08
		DW	wTemp512+SIZE_SPR*09
		DW	wTemp512+SIZE_SPR*10
		DW	wTemp512+SIZE_SPR*11
		DW	wTemp512+SIZE_SPR*12
		DW	wTemp512+SIZE_SPR*13
		DW	wTemp512+SIZE_SPR*14
		DW	wTemp512+SIZE_SPR*15
		DW	wTemp512+SIZE_SPR*16
		DW	wTemp512+SIZE_SPR*17
		DW	wTemp512+SIZE_SPR*18
		DW	wTemp512+SIZE_SPR*19
		DW	wTemp512+SIZE_SPR*20
		DW	wTemp512+SIZE_SPR*21
		DW	wTemp512+SIZE_SPR*22
		DW	wTemp512+SIZE_SPR*23



;
; Pad out to address $0200
;

Page01End::	DCB	$0200-(@-VecReset),0



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;
; PROGRAM CODE
;
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; * ResetMachine ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

RebootMachine::	CALL	FadeOutBlack		;Fade out screen to black.

		CALL	KillAllSound		;Stop any music and sound
		CALL	WaitForVBL		;effects.

		CALL	CgbSingleSpeed		;Reset CGB to single speed.

		DI				;Disable interrupts.

		XOR	A			;Throw away any pending
		LDIO	[rIF],A			;interrupts.
		LDIO	[rIE],A			;
		DEC	A			;
		LDIO	[rLYC],A

		LD	A,LOW(VblDoNothing)	;Disable interrupt vectors.
		LD	[wVblVector],A		;
		LD	A,LOW(LycDoNothing)	;
		LD	[wLycVector],A		;

		LD	A,BANK(SgbBlackOut)	;Black out SuperGB screen.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	SgbBlackOut		;

		LDH	A,[hMachine]		;

ResetMachine::	DI				;Disable interrupts.

		LDH	[hMachine],A		;Save entry code.

		LD	SP,$FFFC		;Set up temporary stack.

ResetWaitVbl::	LDIO	A,[rLY]			;Wait for VBLANK.
		CP	145			;
		JR	NZ,ResetWaitVbl		;

		LDIO	A,[rLCDC]		;Stop LCD display.
		AND	%01111111		;
		LDIO	[rLCDC],A		;

		XOR	A			;Enable writes to cartridge
		LD	[rMBC5_RAM],A		;ram and select bank 0.
		LD	[rMBC5_ROMH],A		;
		INC	A			;
		LD	[rMBC5_ROML],A		;
		LD	A,$0A			;
		LD	[rMBC5_GATE],A		;

		LD	HL,$FF80		;Clear internal work
		LD	BC,$007A		;RAM.
		CALL	MemClear		;

		LD	A,$FF			;??? Dave's ???
		LDH	[hCutoff],A		;

		LDH	A,[hMachine]		;Is this a CGB ?
		CP	MACHINE_CGB		;
		JR	Z,ResetCgbWram		;

ResetGmbWram::	LD	HL,$C000		;Clear external work
		LD	BC,$2000		;RAM.
		CALL	MemClear		;

		LD	HL,$8000		;Clear character and
		LD	BC,$2000		;background data.
		CALL	MemClear		;

ResetGmbCode::	LD	HL,StructSmodGmb	;Customize code for GMB.
		LD	DE,wStructSmod		;
		LD	BC,LENGTH_SMOD		;
		CALL	MemCopy			;

		LD	HL,GmbChrDump		;Copy DumpChrs() to internal
		LD	DE,wChrXfer		;memory.
		LD	BC,GmbChrDumpDone-GmbChrDump
		CALL	MemCopy

		JR	ResetCopyCode

ResetCgbWram::	LD	HL,$C000		;Clear external work
		LD	BC,$1000		;RAM (bank 0).
		CALL	MemClear		;

		LD	E,7			;Clear external work
ResetCgbLoop::	LD	A,E			;RAM (bank 1-7).
		LDIO	[rSVBK],A		;
		LD	HL,$D000		;
		LD	BC,$1000		;
		CALL	MemClear		;
		DEC	E			;
		JR	NZ,ResetCgbLoop		;

		LD	A,1			;Clear character and
		LDIO	[rVBK],A		;background data.
		LD	HL,$8000		;
		LD	BC,$2000		;
		CALL	MemClear		;

		LD	A,0			;Clear character and
		LDIO	[rVBK],A		;background data.
		LD	HL,$8000		;
		LD	BC,$2000		;
		CALL	MemClear		;

		XOR	A			;Turn off infra-red LED.
		LDIO	[rRP],A			;

ResetCgbCode::	LD	HL,StructSmodCgb	;Customize code for CGB.
		LD	DE,wStructSmod		;
		LD	BC,LENGTH_SMOD		;
		CALL	MemCopy			;

		LD	HL,CgbChrDump		;Copy DumpChrs() to internal
		LD	DE,wChrXfer		;memory.
		LD	BC,CgbChrDumpDone-CgbChrDump
		CALL	MemCopy

ResetCopyCode::	LD	SP,wStackPointer	;Initialize the stack.

		LD	A,$C3			;Initialize vectored jumps.
		LD	[wJmpTemporary],A	;
		LD	[wJmpDraw],A		;

		LD	A,HIGH(wOamShadow)	;Initialize OAM shadow
		LDH	[hOamPointer],A		;buffer.

		LD	HL,RomOamDma		;Copy OAM_DMA to internal RAM.
		LD	DE,hOamXfer		;
		LD	BC,$08			;
		CALL	MemCopy			;

		CALL	KillAllSound		;Initialize sound driver.

		XOR	A			;Clear hardware timer.
		LDIO	[rTAC],A		;
		LDIO	[rSCX],A		;
		LDIO	[rSCY],A		;

		XOR	A			;Clear all palettes.
		LDH	[hVblBGP],A		;
		LDH	[hVblOBP0],A		;
		LDH	[hVblOBP1],A		;
		LDH	[hLycBGP],A		;
		LDIO	[rBGP],A		;
		LDIO	[rOBP0],A		;
		LDIO	[rOBP1],A		;

		LD	A,BANK(RandInit)	;Init random # table.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	RandInit		;

		LD	A,BANK(SgbInitialize)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	SgbInitialize		;

		LD	A,7			;Reset window position.
		LDIO	[rWX],A			;
		LD	A,144			;
		LDIO	[rWY],A			;
		LDH	[hWndY],A		;

		LD	A,$40			;Set LCDC interrupt to LYC
		LDIO	[rSTAT],A		;detection, and then clear
		XOR	A			;out pending interrupts.
		LDIO	[rIF],A			;

		LD	A,%01011		;Enable VBL, LYC and SERIAL
		LDIO	[rIE],A			;interrupts.

		LD	A,%11100111		;Bgd_chr9000,Obj_on,
		LDH	[hLycLCDC],A		;Bgd_scr9800,Bgd_on,
		LD	A,%11100111		;Wnd_scr9C00,Wnd_on.
		LDH	[hVblLCDC],A		;
		LDIO	[rLCDC],A		;

		EI				;Enable interrupts.

		CALL	WaitForVBL		;Delay for stuff to settle.

		CALL	CgbDoubleSpeed		;Reset CGB to double speed.

		XOR	A
		JR	ForceIntro



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

AbortGame::	LD	A,1

ForceIntro::	LD	[wAvoidIntro],A

		LD	SP,wStackPointer

		CALL	SprDumpInit

		LD	A,LOW(wOamBuffer)
		LDH	[hOamBufLo],A
		LD	A,HIGH(wOamBuffer)
		LDH	[hOamBufHi],A

MainLoop::	CALL	SramVerify		;Has SRAM been initialized ?

		CALL	LoadBackup		;Is there a game in progress ?

		CALL	FadeOutBlack		;Fade out whole screen to black.

		LD	A,15			;
		CALL	AnyWait			;

;		LD	A,2
;		CALL	InitTune

		LD	A,LOW(VblNormal)	;
		LD	[wVblVector],A		;
		LD	A,LOW(LycNormal)		;
		LD	[wLycVector],A		;

		CALL	ShellCode

MainEnter::	CALL	FadeOutBlack		;Fade out whole screen to black.

		CALL	KillAllSound		;

		CALL	ArcadeStart		;Then play the game.

		JR	MainLoop		;Then do it all again.

MainDelay::	CALL	WaitForVBL
		DEC	A
		JR	NZ,MainDelay

DoNothing::	RET



; ***************************************************************************
; * ArcadeStart ()                                                          *
; ***************************************************************************

ArcadeStart::	RET


; ***************************************************************************
; * SramVerify ()                                                           *
; ***************************************************************************
; * Locate (and page in) a file in the file system                          *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; *                                                                         *
; * Outputs     HL   = Ptr to file                                          *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; *                                                                         *
; * N.B.        Changes ROM bank.                                           *
; ***************************************************************************

Signature::	DB	"BeauTy13",0

SramVerify::	LD	HL,wSramSignature	;
		LD	DE,Signature		;
.Test:		LD	A,[DE]			;
		OR	A			;
		RET	Z			;
		CP	[HL]			;
		JR	NZ,.Fail		;
		INC	DE			;
		INC	HL			;
		JR	.Test			;

.Fail:		DI				;

		LD	HL,wSramSignature	;
		LD	BC,$0100		;
		CALL	MemClear		;

		LD	HL,Signature		;
		LD	DE,wSramSignature	;
		LD	BC,8			;
		CALL	MemCopy			;

		EI				;

		RET				;



; ***************************************************************************
; * SaveBackup ()                                                           *
; ***************************************************************************
; * Backup the current board/story game                                     *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SaveBackup::	LD	A,[wBackupWhich]	;Which backup should we use.
		XOR	1			;
		AND	1			;
		LD	DE,wBackupSave0		;
		JR	Z,.Skip0		;
		LD	DE,wBackupSave1		;

.Skip0:		PUSH	DE			;

		LD	HL,wWhichGame		;Copy backup data.
		LD	BC,48-1			;
		CALL	MemCopy			;
		XOR	A			;
		LD	[DE],A			;

		POP	HL			;

		LD	B,48			;Checksum backup data.
		XOR	A			;
.Loop0:		ADC	[HL]			;
		INC	HL			;
		DEC	B			;
		JR	NZ,.Loop0		;

		CPL				;
		INC	A			;
		LD	[DE],A			;

		LD	A,[wBackupWhich]	;Signal which backup data
		XOR	1			;to use.
		AND	1			;
		LD	[wBackupWhich],A	;

		RET				;



; ***************************************************************************
; * LoadBackup ()                                                           *
; ***************************************************************************
; * Backup the current board/story game                                     *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LoadBackup::	XOR	A			;Signal no game in progress.
		LD	[wWhichGame],A		;

		LD	A,[wBackupWhich]	;Which backup should we use.
		AND	1			;
		LD	HL,wBackupSave0		;
		JR	Z,.Skip0		;
		LD	HL,wBackupSave1		;

.Skip0:		PUSH	HL			;

		LD	B,48			;Test backup data.
		XOR	A			;
.Loop0:		ADC	[HL]			;
		INC	HL			;
		DEC	B			;
		JR	NZ,.Loop0		;

		POP	HL			;

		OR	A			;Corrupted ?
		RET	NZ			;

		LD	DE,wWhichGame		;Copy backup data.
		LD	BC,48-1			;
		CALL	MemCopy			;

		RET				;



; ***************************************************************************
; * GetString ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      DE      = String number                                     *
; *                                                                         *
; * Outputs     wString = String                                            *
; *                                                                         *
; * Preserved   BC                                                          *
; *                                                                         *
; * N.B.        wLanguage is used to find the current language              *
; ***************************************************************************

		GLOBAL	TblStrings

GetString::	LDH	A,[hRomBank]		;Preserve bank.
		PUSH	AF			;

		LD	A,BANK(TblStrings)	;Page in the strings.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	HL,TblStrings		;Locate the table for
		LD	A,[wLanguage]		;this language.
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		ADD	HL,DE			;Locate the index for
		ADD	HL,DE			;this string.
		ADD	HL,DE			;

		LD	A,[HLI]			;Read the address of
		LD	E,A			;this string.
		LD	A,[HLI]			;
		LD	D,A			;
		LD	A,[HLI]			;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	HL,wString		;Copy the string to RAM.
.Loop:		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		OR	A			;
		JR	NZ,.Loop		;

		POP	AF			;Restore the original bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * FindInFileSys ()                                                        *
; ***************************************************************************
; * Locate (and page in) a file in the file system                          *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; *                                                                         *
; * Outputs     HL   = Ptr to file                                          *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; *                                                                         *
; * N.B.        Changes ROM bank.                                           *
; ***************************************************************************

FindInFileSys::	PUSH	DE			;Preserve DE.

		LD	DE,FileSys		;Locate the file system's
		ADD	HL,HL			;directory header list.
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,BANK(FileSys)		;Page in file system bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[HLI]			;Locate the file's bank
		LD	[wFileAddr+0],A		;and address.
		LD	E,A			;
		LD	A,[HLI]			;
		LD	[wFileAddr+1],A		;
		LD	D,A			;
		LD	A,[HLI]			;
		LD	[wFileBank],A		;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	L,E			;
		LD	H,D			;

		POP	DE			;Restore DE.

		RET				;All Done.



; ***************************************************************************
; * FindInPkgFile ()                                                        *
; ***************************************************************************
; * Locate (and page in) a data chunk within a PKG file                     *
; ***************************************************************************
; * Inputs      HL   = File index number within PKG                         *
; *                                                                         *
; * Outputs     HL   = Ptr to file                                          *
; *             BC   = Len of file                                          *
; *                                                                         *
; * Preserved   DE                                                          *
; *                                                                         *
; * N.B.        Changes ROM bank.                                           *
; *                                                                         *
; *             The PKG file must have previously been located with the     *
; *             routine FindInFileSys().                                    *
; *                                                                         *
; *             Subsequent calls to FindInFileSys() will destroy the file   *
; *             info that this routine needs to locate the PKG file.        *
; ***************************************************************************

FindInPkgFile::	PUSH	DE			;Preserve DE.

		LD	DE,8+5			;Calc offset to file info
		ADD	HL,HL			;(hi-byte of file length).
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,[wFileBank]		;Get pkg file bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[wFileAddr+0]		;Get pkg file addr.
		LD	E,A			;
		LD	A,[wFileAddr+1]		;
		LD	D,A			;

		ADD	HL,DE			;

		LD	A,[HLD]			;Get file size.
		LD	B,A			;
		LD	A,[HLD]			;
		LD	C,A			;

		DEC	HL			;Get file addr.
		DEC	HL			;
		LD	A,[HLD]			;
		LD	L,[HL]			;
		LD	H,A			;
		ADD	HL,DE			;

		POP	DE			;Restore DE.

		RET				;All Done.



; ***************************************************************************
; * SwdInFileSys ()                                                         *
; ***************************************************************************
; * Find and decompress from file system                                    *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; *             DE   = Destination to uncompress data                       *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        None                                                        *
; ***************************************************************************

SwdInFileSys::	LDH	A,[hRomBank]
		PUSH	AF
		CALL	FindInFileSys
		CALL	SwdDecode
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET

; ***************************************************************************
; * DumpChrsInFileSys ()                                                    *
; ***************************************************************************
; * Find and dump chrs from file system                                     *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; *             DE   = Destination to dump chrs                             *
; *             C    = # of chars                                           *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        None                                                        *
; ***************************************************************************

DumpChrsInFileSys::
		LDH	A,[hRomBank]
		PUSH	AF
		CALL	FindInFileSys
		CALL	DumpChrs
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET


; ***************************************************************************
; * BgInFileSys ()                                                          *
; ***************************************************************************
; * Find and decompress bg to C800 then call loadbg                         *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        None                                                        *
; ***************************************************************************

BgInFileSys::	LDH	A,[hRomBank]
		PUSH	AF
		CALL	FindInFileSys
		LD	DE,$C800
		CALL	SwdDecode
		LD	A,BANK(loadbg)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	loadbg
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET

; ***************************************************************************
; * MemCopyInFileSys ()                                                     *
; ***************************************************************************
; * Find and copy item from filesys                                         *
; ***************************************************************************
; * Inputs      HL   = File index number                                    *
; * Inputs      DE   = Destination pointer                                  *
; * Inputs      BC   = # of bytes to copy                                   *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        None                                                        *
; ***************************************************************************

MemCopyInFileSys::
		LDH	A,[hRomBank]
		PUSH	AF
		CALL	FindInFileSys
		CALL	MemCopy
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



;############################################################################
;############################################################################
;############################################################################
;
; GENERAL ROUTINES
;
;############################################################################
;############################################################################
;############################################################################



; ***************************************************************************
; * MultiplyBBW ()                                                          *
; * MultiplyBWW ()                                                          *
; ***************************************************************************
; * Calculate byte * byte = word                                            *
; * Calculate byte * word = word                                            *
; ***************************************************************************
; * Inputs      A    =  8-bit multiplior                                    *
; *             BC   = 16-bit multipicand                                   *
; *                                                                         *
; * Outputs     HL   = 16-bit result                                        *
; *                                                                         *
; * Preserved   DE                                                          *
; ***************************************************************************

MultiplyBBW::	LD	B,0			;2

MultiplyBWW::	LD	HL,0			;3
		SRL	A			;2
		JR	NC,.Skip		;3/2
		ADD	HL,BC			;2
		RET	Z			;5/2
.Loop:		SLA	C			;2
		RL	B			;2
		SRL	A			;2
		JR	NC,.Skip		;3/2
		ADD	HL,BC			;2
.Skip:		JR	NZ,.Loop		;3/2
		RET				;4



; ***************************************************************************
; * SDivideWWW ()                                                           *
; * UDivideWWW ()                                                           *
; ***************************************************************************
; * Calculate word / word = word                                            *
; ***************************************************************************
; * Inputs      BC   = Dividend                                             *
; *             DE   = Divisor                                              *
; *                                                                         *
; * Outputs     BC   = Quotient                                             *
; *             HL   = Remainder                                            *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

Div16Macro:	MACRO
		RL	C		;2   Rotate acc-result left
		RL	B		;2
		RL	L		;2   Rotate remainder left
		RL	H		;2

		ADD	HL,DE		;2
		JR	C,.skip\@	;3/2

		LD	A,L		;1
		SUB	E		;1
		LD	L,A		;1
		LD	A,H		;1
		SBC	D		;1
		LD	H,A		;1
.skip\@:
		ENDM

SDivideWWW::	BIT	7,B		;2
		JR	Z,UDivideWWW	;3/2

		XOR	A		;1
		SUB	C		;1
		LD	C,A		;1
		LD	A,$00		;2
		SBC	B		;1
		LD	B,A		;1

		CALL	UDivideWWW	;n

		XOR	A		;1
		SUB	C		;1
		LD	C,A		;1
		LD	A,$00		;2
		SBC	B		;1
		LD	B,A		;1

		RET			;4

UDivideWWW::	XOR	A		;1
		LD	L,A		;1
		LD	H,A		;1
		SUB	E		;1
		LD	E,A		;1
		LD	A,$00		;2
		SBC	D		;1
		LD	D,A		;1

		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18

		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18

		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18

		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18
		Div16Macro		;13/18

		RL	C		;2
		RL	B		;2

		RET



; ***************************************************************************
; * MemClear ()                                                             *
; * MemFill ()                                                              *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = dst-pointer                                          *
; *             BC   = bytes to copy ($0001...$FFFF)                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MemClear::	XOR	A			;1

MemFill::	INC	B			;1
		DEC	BC			;2
		INC	C			;1
.Loop:		LD	[HLI],A			;2
		DEC	C			;1
		JR	NZ,.Loop		;3/2
		DEC	B			;1
		JR	NZ,.Loop		;3/2
		RET				;4



; ***************************************************************************
; * MemCopy ()                                                              *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = src-pointer                                          *
; *             DE   = dst-pointer                                          *
; *             BC   = bytes to copy ($0001...$FFFF)                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MemCopy::	INC	B			;1
		DEC	BC			;2
		INC	C			;1
.Loop:		LD	A,[HLI]			;2
		LD	[DE],A			;2
		INC	DE			;2
		DEC	C			;1
		JR	NZ,.Loop		;3/2
		DEC	B			;1
		JR	NZ,.Loop		;3/2
		RET				;4



; ***************************************************************************
; * WriteByteList ()                                                        *
; ***************************************************************************
; * Write a list of data bytes to ram                                       *
; ***************************************************************************
; * Inputs      HL   = Ptr to addr/data list                                *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Modifies current rom bank number.                           *
; ***************************************************************************

WriteByteList::	LD	A,[HLI]			;Get # of addresses.
		OR	A
		RET	Z
		LD	B,A
		LD	A,[HLI]			;Get # of bytes per address.
		LD	C,A
		PUSH	BC
WriteByteAddr::	LD	A,[HLI]			;Get address lo.
		LD	E,A
		LD	A,[HLI]			;Get address hi.
		LD	D,A
WriteByteData::	LD	A,[HLI]			;Get data byte.
		LD	[DE],A
		INC	DE
		DEC	C
		JR	NZ,WriteByteData
		POP	BC
		DEC	B
		JR	NZ,WriteByteAddr
		JR	WriteByteList



; ***************************************************************************
; * WaitForVBL ()                                                           *
; ***************************************************************************
; * Wait for the next vblank                                                *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

WaitForVBL::	PUSH	AF
		CALL	random
		PUSH	HL

		LDH	A,[hMachine]
		CP	MACHINE_CGB
		JR	NZ,.WaitGMB

.WaitCGB:	LDIO	A,[rKEY1]		;Switching speed ?
		RRA				;
		JR	NC,.WaitGMB		;

		LD	HL,hVblFlag		;
		XOR	A			;
		LD	[HL],A			;
.WaitCGBLoop:	OR	[HL]			;
		JR	Z,.WaitCGBLoop		;
		POP	HL			;
		POP	AF			;
		RET				;

.WaitGMB:	LD	HL,hVblFlag		;
		XOR	A			;
		LD	[HL],A			;
.WaitGMBLoop:	HALT				;
		NOP				;
		OR	[HL]			;
		JR	Z,.WaitGMBLoop		;
		POP	HL			;
		POP	AF			;
		RET				;



; ***************************************************************************
; * ReadJoypad ()                                                           *
; ***************************************************************************
; * Read current joypad status.                                             *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        7 Start                                                     *
; *             6 Select                                                    *
; *             5 B                                                         *
; *             4 A                                                         *
; *             3 Down                                                      *
; *             2 Up                                                        *
; *             1 Left                                                      *
; *             0 Right                                                     *
; ***************************************************************************

ReadJoypad::	LD	HL,rP1			;Read current keystate.

		LD	[HL],$10		;P14=1,P15=0 : Read SSBA
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		CPL
		AND	$0F

		SWAP	A
		LD	B,A

		LD	[HL],$20		;P14=0,P15=1 : Read DULR
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		LD	A,[HL]
		CPL
		AND	$0F

		LD	[HL],$30		;P14=1,P15=1 : Read none

		ADD	LOW(TblJoyB2Dirn)
		LD	L,A
		LD	H,HIGH(TblJoyB2Dirn)
		LD	A,[HL]
		OR	B

		LD	B,A
		LD	H,HIGH(TblDirn2DULR)
		AND	$0F
		LD	[wJoy1Dir],A
		ADD	LOW(TblDirn2DULR)
		LD	L,A
		LD	A,[wJoy1Cur]
		CPL
		LD	D,A
		LD	A,B
		AND	$F0
		OR	[HL]
		LD	[wJoy1Cur],A
		AND	D
		LD	[wJoy1Hit],A

		LD	B,MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_B|MSK_JOY_A
		LD	A,[wJoy1Cur]
		AND	B
		CP	B
		JP	Z,RebootMachine

		RET



; ***************************************************************************
; * WaitForRelease ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

WaitForRelease::CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	ReadJoypad		;Update joypads.

		LD	A,[wJoy1Cur]		;Wait for the button release.
		AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	NZ,WaitForRelease

		RET				;



; ***************************************************************************
; * InitAutoRepeat ()                                                       *
; ***************************************************************************
; * Initialize auto-repeat for the direction buttons.                       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitAutoRepeat::LD	HL,wJoy1Rpt		;3
		LD	BC,4			;3
		JP	MemClear		;6



; ***************************************************************************
; * ProcAutoRepeat ()                                                       *
; ***************************************************************************
; * Process auto-repeat for the direction buttons.                          *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        7 Start                                                     *
; *             6 Select                                                    *
; *             5 B                                                         *
; *             4 A                                                         *
; *             3 Down                                                      *
; *             2 Up                                                        *
; *             1 Left                                                      *
; *             0 Right                                                     *
; ***************************************************************************

REPT_VAL	EQU	$16
REPT_NXT	EQU	$10

ProcAutoRepeat::LD	HL,wJoy1Rpt		;3

		LD	A,[wJoy1Cur]		;4
		LD	D,A			;1
		LD	A,[wJoy1Hit]		;4
		LD	E,A			;1

		LD	C,$08			;2

AutoReptLoop::	LD	A,C			;1
		AND	D			;1
		JR	Z,AutoReptNext		;3/2

		LD	A,[HL]			;2
		INC	A			;1
		CP	REPT_VAL		;2
		JR	C,AutoReptNext		;3/2

		LD	A,E			;1
		OR	C			;1
		LD	E,A			;1

		LD	A,REPT_NXT		;2

AutoReptNext::	LD	[HLI],A			;2   Save JoyRpt

		SRL	C			;2
		JR	NZ,AutoReptLoop		;3/2

		LD	A,E			;1
		LD	[wJoy1Hit],A		;4

		RET				;4



; ***************************************************************************
; * ClrDisplay  () - Set 32x32 display screen at HL ($9800 or $9C00) to $00 *
; * SetDisplay  () - Set 32x32 display screen at HL ($9800 or $9C00) to $FF *
; * FillDisplay () - Set 32x32 display screen at HL ($9800 or $9C00) to A   *
; * FillLine    () - Set C lines at HL to A                                 *
; ***************************************************************************
; * Inputs      HL  = Ptr to screen.                                        *
; *             A   = (for FillDisplay and FillLine) value.                 *
; *             C   = (for FillLine) number of lines.                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ClrDisplay::	XOR	A
		JR	FillDisplay

SetDisplay::	XOR	A
		DEC	A

FillDisplay::	LD	C,32
FillLine::	SLA	C
		RET	Z
FillHalfLine::	DI
		PUSH	AF
FillSync0::	LDIO	A,[rSTAT]
		AND	%11
		JR	Z,FillSync0
FillSync1::	LDIO	A,[rSTAT]
		AND	%11
		JR	NZ,FillSync1
		POP	AF
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		EI
		DEC	C
		JR	NZ,FillHalfLine
		RET



; ***************************************************************************
; * DumpChrset ()                                                           *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      HL = source address (NOT display RAM).-                     *
; *             DE = destination address (N.B. $8000 or $9000 only).        *
; *             C  = number of characters to copy ($00=256).                *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Interrupts are switched off during execution.               *
; ***************************************************************************

DumpChrset::	BIT	7,C
		JP	Z,DumpChrs
		PUSH	BC
		LD	C,128
		CALL	DumpChrs
		POP	BC
		RES	7,C
		LD	DE,$8800
		JP	DumpChrs



; ***************************************************************************
; * DumpChrs ()                                                             *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      HL = source address (NOT display RAM).-                     *
; *             DE = destination address (N.B. $8000 or $9000 only).        *
; *             C  = number of characters to copy ($00=256).                *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Interrupts are switched off during execution.               *
; ***************************************************************************

DumpChrs::	LD	B,%11			;Initialize flag.

.Loop:		CALL	wChrXfer		;Dump a single chr.

		DEC	C			;Loop until done.
		JR	NZ,.Loop		;

		RET				;All Done.

SafeDumpChrs::
.Loop:
		LDH	A,[hCutoff]
		LD	B,A
		LDIO	A,[rLY]
		CP	B
		JR	NC,.Loop
		LD	B,%11			;Initialize flag.

		CALL	wChrXfer		;Dump a single chr.

		DEC	C			;Loop until done.
		JR	NZ,.Loop		;

		RET				;All Done.

; ***************************************************************************
; * RomOamDma ()                                                            *
; ***************************************************************************
; * Do hardware DMA to OAM RAM (only during vblank)                         *
; ***************************************************************************
; * Inputs      HL = source address (NOT display RAM).                      *
; *             DE = destination address (should be display RAM).           *
; *             C  = number of characters to copy ($01...$80).              *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Interrupts are switched off during execution.               *
; *                                                                         *
; *             Takes 168 cycles.                                           *
; ***************************************************************************

RomOamDma:	LDIO	[rDMA],A		;3
		LD	A,40			;2
.Loop:		DEC	A			;1
		JR	NZ,.Loop		;3/2
		RET				;4



; ***************************************************************************
; * GmbChrDump ()                                                           *
; ***************************************************************************
; * Dump a single character from HL to vram at DE during HBL(s)             *
; ***************************************************************************
; * Inputs      HL = source address (NOT display RAM).                      *
; *             DE = destination address (should be display RAM).           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   BC                                                          *
; *                                                                         *
; * N.B.        Interrupts are switched off during execution.               *
; *                                                                         *
; *             This routine is $57 bytes long.                             *
; *                                                                         *
; * N.B.B.      LET JOHN KNOW BEFORE MODIFYING THIS CODE (11 Mar 99)        *
; ***************************************************************************

KG		EQUS	"(wChrXfer-GmbChrDump)"

GmbChrDump::	LDIO	A,[rLY]			;3   Don't start the transfer
		DEC	A			;1   during vblank.
		CP	139			;2
		JR	NC,GmbChrDump		;3/2

		LD	[.Smod+1+KG],SP		;5   Preserve SP.

		DI				;1   Disable interrupts.

		LD	SP,HL			;2   Put dst-ptr in SP.
		LD	L,E			;1   Put src-ptr in HL.
		LD	H,D			;1

		POP	DE			;3   Read bytes 0&1.

.Sync0:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;2   HBL is finished.
		JR	Z,.Sync0		;3/2

.Wait0:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;2
		JR	NZ,.Wait0		;3/2 (15 cycles total)

		LD	A,E			;1   Copy bytes 0&1.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 2&3.
		LD	A,E			;1   Copy bytes 2&3.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 4&5.
		LD	A,E			;1   Copy bytes 4&5.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 6&7.
		LD	A,E			;1   Copy bytes 6&7.
		LD	[HLI],A			;2
		LD	[HL],D			;2
		INC	HL			;2   (34 cycles total)

		POP	DE			;3   Read bytes 0&1.

.Sync1:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;2   HBL is finished.
		JR	Z,.Sync1		;3/2

.Wait1:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;2
		JR	NZ,.Wait1		;3/2 (15 cycles total)

		LD	A,E			;1   Copy bytes 0&1.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 2&3.
		LD	A,E			;1   Copy bytes 2&3.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 4&5.
		LD	A,E			;1   Copy bytes 4&5.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 6&7.
		LD	A,E			;1   Copy bytes 6&7.
		LD	[HLI],A			;2
		LD	[HL],D			;2
		INC	HL			;2   (34 cycles total)

		LD	E,L			;1   Put dst-ptr in DE.
		LD	D,H			;1
		LDHL	SP,0			;3   Put src-ptr in HL.

.Smod:		LD	SP,0			;3   Restore SP.

		EI				;1   Enable interrupts.

		RET				;4   All Done.

GmbChrDumpDone::NOP



; ***************************************************************************
; * CgbChrDump ()                                                           *
; ***************************************************************************
; * Dump a single character from HL to vram at DE during HBL(s)             *
; ***************************************************************************
; * Inputs      HL = source address (NOT display RAM).                      *
; *             DE = destination address (should be display RAM).           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   BC                                                          *
; *                                                                         *
; * N.B.        Interrupts are switched off during execution.               *
; *                                                                         *
; *             This routine is $4B bytes long.                             *
; *                                                                         *
; * N.B.B.      Requires that the CGB is in double-speed mode.              *
; *                                                                         *
; * N.B.B.B.    LET JOHN KNOW BEFORE MODIFYING THIS CODE (11 Mar 99)        *
; ***************************************************************************

KC		EQUS	"(wChrXfer-CgbChrDump)"

CgbChrDump::	LDIO	A,[rLY]			;3   Don't start the transfer
		DEC	A			;1   during vblank.
		CP	140			;2
		JR	NC,CgbChrDump		;3/2

		LD	[.Smod+1+KC],SP		;5   Preserve SP.

		DI				;1   Disable interrupts.

		LD	SP,HL			;2   Put dst-ptr in SP.
		LD	L,E			;1   Put src-ptr in HL.
		LD	H,D			;1

		POP	DE			;3   Read bytes 0&1.

.Sync0:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;2   HBL is finished.
		JR	Z,.Sync0		;3/2

.Wait0:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;2
		JR	NZ,.Wait0		;3/2 (15 cycles total)

		LD	A,E			;1   Copy bytes 0&1.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 2&3.
		LD	A,E			;1   Copy bytes 2&3.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 4&5.
		LD	A,E			;1   Copy bytes 4&5.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 6&7.
		LD	A,E			;1   Copy bytes 6&7.
		LD	[HLI],A			;2
		LD	[HL],D			;2
		INC	HL			;2   (34 cycles total)

		POP	DE			;3   Read bytes 8&9.
		LD	A,E			;1   Copy bytes 8&9.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 10&11.
		LD	A,E			;1   Copy bytes 10&11.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 12&13.
		LD	A,E			;1   Copy bytes 12&13.
		LD	[HLI],A			;2
		LD	A,D			;1
		LD	[HLI],A			;2
		POP	DE			;3   Read bytes 14&15.
		LD	A,E			;1   Copy bytes 14&15.
		LD	[HLI],A			;2
		LD	[HL],D			;2
		INC	HL			;2   (34 cycles total)

		LD	E,L			;1   Put dst-ptr in DE.
		LD	D,H			;1
		LDHL	SP,0			;3   Put src-ptr in HL.

.Smod:		LD	SP,0			;3   Restore SP.

		EI				;1   Enable interrupts.

		RET				;4   All Done.

CgbChrDumpDone::NOP



; ***************************************************************************
; * CgbSingleSpeed ()                                                       *
; * CgbDoubleSpeed ()                                                       *
; ***************************************************************************
; * Switch Color Gameboy to single/double speed mode                        *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbSingleSpeed::LDH	A,[hMachine]		;Confirm that we're on a CGB.
		CP	MACHINE_CGB		;
		RET	NZ			;

		LDIO	A,[rKEY1]		;Already in single speed ?
		ADD	A			;
		RET	NC			;

		LD	B,%00000000		;Desired rKEY1.

		JR	CgbChangeSpeed		;

CgbDoubleSpeed::LDH	A,[hMachine]		;Confirm that we're on a CGB.
		CP	MACHINE_CGB		;
		RET	NZ			;

		LDIO	A,[rKEY1]		;Already in double speed ?
		ADD	A			;
		RET	C			;

		LD	B,%10000000		;Desired rKEY1.

		JR	CgbChangeSpeed		;

CgbChangeSpeed::LDIO	A,[rIE]			;Preserve interrupt enable
		PUSH	AF			;flags.

		XOR	A			;Disable interrupts.
		LDIO	[rIE],A

		LD	A,%00000001		;Enable speed switching
		LDIO	[rKEY1],A		;

		LD	A,%00110000		;Ensure that the joypad is
		LDIO	[rP1],A			;not being read.

		STOP				;Switch speed.
		NOP				;

CgbChangeWait::	LDIO	A,[rKEY1]		;Wait for the speed to change.
		XOR	B			;
		BIT	7,A			;
		JR	NZ,CgbChangeWait	;

		BIT	0,A			;Wait for hardware to reset
		JR	NZ,CgbChangeWait	;the change request flag.

		XOR	A			;Trash pending interrupts.
		LDIO	[rIF],A			;

		POP	AF			;Restore interrupt enable
		LDIO	[rIE],A			;flags.

		RET				;All done.



; ***************************************************************************
; * KillAllSound ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillAllSound::	LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(KillAllSoundB)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	KillAllSoundB
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



; ***************************************************************************
; * KillTune ()                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillTune::	LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(KillTuneB)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	KillTuneB
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



; ***************************************************************************
; * KillSfx ()                                                              *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillSfx::	LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(KillSfxB)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	KillSfxB
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



; ***************************************************************************
; * InitTune ()                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A = Tune number                                             *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitTune::	LD	B,A
		LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(InitTuneB)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		LD	A,B
		CALL	InitTuneB
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



; ***************************************************************************
; * InitSfx ()                                                              *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A = Sound effect number                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitSfx::	LD	B,A
		LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(InitSfxB)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		LD	A,B
		CALL	InitSfxB
		POP	AF
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		RET



; ***************************************************************************
; * BANKED ()                                                               *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A = Sound effect number                                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		BANKED	PauseMenu



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;BANK0_END:

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BANK0.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************





; ***************************************************************************
; * DoVblNull ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DoVblNull::	RET				;4



; ***************************************************************************
; * DoVblNormal ()                                                          *
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

DoVblNormal::	LDH	A,[hPosFlag]		;Update ?
		OR	A			;
		RET	Z			;

		LDH	A,[hVblSCX]		;Update scroll position.
		LDIO	[rSCX],A		;
		LDH	A,[hVblSCY]		;
		LDIO	[rSCY],A		;

		RET				;



; ***************************************************************************
; * DoVblIntro ()                                                           *
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

DoVblIntro::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,DoVblNormal		;

		CALL	CgbAttrVbl		;

		JR	DoVblNormal		;



; ***************************************************************************
; * DoVblScroll ()                                                          *
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

DoVblScroll::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,DoVblNormal		;

		CALL	CgbBlitVbl		;

		JR	DoVblNormal		;



; ***************************************************************************
; * DoLycNull ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DoLycNull::	POP	AF			;3
		RETI				;4



; ***************************************************************************
; * DoLycNormal ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      -                                                           *
; *                                                                         *
; * Outputs     -                                                           *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DoLycNormal::	LDIO	A,[rSTAT]		;3   Wait for next HBL.
		AND	%11			;2
		JR	NZ,DoLycNormal		;3/2

		LDH	A,[hLycLCDC]		;3   Update rLCDC and rBGP.
		LDIO	[rLCDC],A               ;3
		LDH	A,[hLycBGP]		;3
		LDIO	[rBGP],A		;3
		POP	AF			;3
		RETI				;4


; ***************************************************************************
; * SprBlank ()                                                             *
; ***************************************************************************
; * Blank out the wOamShadow shadow OAM memory                              *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SprBlank::	LDH	A,[hOamPointer]
		LD	H,A
		XOR	A
		LD	L,A
		LD	C,160/4
.Loop:		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		DEC	C
		JR	NZ,.Loop
		RET

; ***************************************************************************
; * SprOff ()                                                               *
; ***************************************************************************
; * Blank out the wOamShadow shadow OAM memory and update to OAM            *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SprOff::	CALL	SprBlank
		LDH	A,[hOamPointer]
		LDH	[hOamFlag],A
		RET

; ***************************************************************************
; * InitGroups                                                              *
; ***************************************************************************
; * Inputs      None                                                        *
; * Outputs     None                                                        *
; * Preserves   All but A                                                   *
; * Function    Init sprite grouping, call before RegisterGroup             *
; ***************************************************************************

InitGroups::
		xor	a
		ld	[wGroupCount],a
		ld	[wFigPhase],a
		ld	[wPalCount],a
		ret

; ***************************************************************************
; * RegisterGroup                                                           *
; ***************************************************************************
; * Inputs      DE=Group List structure,                                    *
;               A=BANK # of list                                            *
; * Outputs     A=ID # to be used for bringing up sprite frames             *
; * Preserves   None                                                        *
; * Function    Register a group structure                                  *
;               Loads up color table for appropriate sprite                 *
; ***************************************************************************
;Group structure is 8 bytes
;1 byte bank of list
;1 byte sprite value (for color map)
;2 bytes pointer to list
;4 bytes spare
RegisterGroup::
		ld	b,a
		ld	hl,wGroupCount
		ld	a,[hl]
		inc	[hl]
		ld	hl,wGroups
		ld	c,a
		add	a
		add	a
		add	a
		call	addahl
		ld	[hl],b	;BANK
		inc	hl
		ld	a,[wPalCount]
		ld	[hli],a	;sprite color value
		ld	[hl],e	;Pointer Lo
		inc	hl
		ld	[hl],d	;Pointer Hi
		inc	hl
		ld	a,[de]	;# of cels in this anim
		ldh	[hTmp2Lo],a
		inc	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.nocolor
		ldh	a,[hRomBank]
		push	af

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

.sendpallp:
		LD	A,B
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,[de]	;Get Palette pointer from anim list
		ld	l,a
		inc	de
		ld	a,[de]
		ld	h,a
		inc	de
		inc	de
		inc	de
		push	de
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,[wPalCount]
		inc	a
		ld	[wPalCount],a
		dec	a
		add	a
		add	a
		add	a
		ld	de,wOcpArcade
		add	e
		ld	e,a
		push	bc
		ld	bc,8
		call	MemCopy
		pop	bc
		pop	de
		ldh	a,[hTmp2Lo]
		dec	a
		ldh	[hTmp2Lo],a
		jr	nz,.sendpallp

		LD	A,WRKBANK_NRM		;Restore ram bank to 00
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
.nocolor:	ld	a,c
		ret

; ***************************************************************************
; * AddPalette                                                              *
; ***************************************************************************
; * Inputs      HL=Palette                                                  *
; * Outputs     A=Pal # used for sprite structure                           *
; * Preserves   None                                                        *
; * Function    Loads up color table                                        *
; ***************************************************************************

AddPalette::	ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,0
		ret	nz
		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,[wPalCount]
		add	a
		add	a
		add	a
		ld	de,wOcpArcade
		add	e
		ld	e,a
		ld	bc,8
		call	MemCopy
		LD	A,WRKBANK_NRM		;Restore ram bank to 00
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	hl,wPalCount
		ld	a,[hl]
		inc	[hl]
		ret


; ***************************************************************************
; * InitFigures                                                             *
; ***************************************************************************
; * Inputs:      None                                                       *
; * Outputs:     None                                                       *
; * Preserves:   All but A                                                  *
; * Function:    Call this before each frame                                *
; ***************************************************************************
InitFigures::
		xor	a
		ld	[wFigCount],a
		ld	a,LOW(wOamBuffer)
		ldh	[hOamBufLo],a
		ld	a,HIGH(wOamBuffer)
		ldh	[hOamBufHi],a
		ld	a,[wFigPhase]
		xor	80
		ld	[wFigPhase],a
		ldh	[hSprNxt],a
		add	80
		ldh	[hSprMax],a
		ret
;InitFigures64 is for when there are only
;128 sprite characters rather than 160
InitFigures64::
		xor	a
		ld	[wFigCount],a
		ld	a,LOW(wOamBuffer)
		ldh	[hOamBufLo],a
		ld	a,HIGH(wOamBuffer)
		ldh	[hOamBufHi],a
		ld	a,[wFigPhase]
		xor	64
		ld	[wFigPhase],a
		ldh	[hSprNxt],a
		add	64
		ldh	[hSprMax],a
		ret

; ***************************************************************************
; * AddFrame                                                                *
; ***************************************************************************
; * Inputs:     B=Fig group ID #                                            *
; *             DE=Frame # within the group (1 is first)                    *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Adds a frame to the figure list                             *
; ***************************************************************************

AddFrame::	ld	a,d
		or	e
		ret	z
		dec	de
		ldh	a,[hRomBank]
		push	af

		ld	hl,wGroups
		ld	a,b
		and	7
		add	a
		add	a
		add	a
		call	addahl
		ld	a,[hli]	;Group's ROM bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,b
		and	$10
		ld	b,a
		ld	a,[hli]	;Sprite color value
		or	b
		ldh	[hTmp2Lo],a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hli]	;# of cels per frame
		ld	[wCelsPerFrame],a
		ldh	[hTmp2Hi],a
		ld	b,d
		ld	c,e
		ld	d,h
		ld	e,l
		inc	de
		inc	de
		add	a
		add	a
		call	addahl
		sla	c
		rl	b
		sla	c
		rl	b
		ldh	a,[hTmp2Hi]
.mul3:		add	hl,bc
		dec	a
		jr	nz,.mul3
.addfiglp:	ld	a,[hli]
		ldh	[hTmp3Lo],a	;sprite #
		ld	a,[hli]
		ldh	[hTmp3Hi],a	;sprite palette and xflip
		ld	a,[hli]
		ldh	[hTmp4Lo],a	;x
		ld	a,[hli]
		ldh	[hTmp4Hi],a	;y
		ldh	a,[hTmp3Lo]
		cp	255
		jp	z,.skip

		push	de
		push	hl
		ld	[wSprPlotSP],sp

		ld	hl,wFigCount
		ld	a,[hl]
		inc	[hl]
		add	a
		add	LOW(FigureTable)
		ld	l,a
		ld	h,HIGH(FigureTable)
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	sp,hl

		LDHL	SP,SPR_SCR_X
		ldh	a,[hTmp4Lo]
		add	80
		ld	[hli],a
		cp	80+128
		ld	a,0
		jr	c,.aok1
		dec	a
.aok1:		ld	[hli],a
		ldh	a,[hTmp4Hi]
		add	72
		ld	[hli],a
		cp	72+128
		ld	a,0
		jr	c,.aok2
		dec	a
.aok2:		ld	[hl],a
		LDHL	SP,SPR_FLAGS
		ld	a,(1<<FLG_DRAW)|(1<<FLG_PLOT)
		ld	[hl],a

		ldh	a,[hTmp3Hi]	;Sprite's X flip bit (0x80)
		and	$80
		srl	a
		srl	a
		LDHL	SP,SPR_FLIP
		ld	[hli],a ;SPR_FLIP
		ldh	a,[hTmp3Hi]
		ld	c,a
		ldh	a,[hTmp2Lo]
		add	c
		and	$1f
		ld	[hl],a	;SPR_COLR

		ld	a,c
		add	a
		add	a
		push	de
		add	e
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,[de]
		ld	c,a
		inc	de
		ld	a,[de]
		ld	d,a
		ld	e,c
		LDHL	SP,SPR_FRAME+2
		ldh	a,[hTmp3Lo]	;sprite #
		add	e
		ld	[hli],a
		ld	a,d
		adc	0
		ld	[hl],a
		pop	de

		ldh	a,[hSprNxt]
		ld	l,a
		ld	h,$80>>4
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	b,h
		ld	c,l
		call	SprDump
		LD	HL,wSprPlotSP		;Restore stack pointer.
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL
		pop	hl
		pop	de
.skip:		ldh	a,[hTmp2Hi]
		dec	a
		ldh	[hTmp2Hi],a
		jp	nz,.addfiglp

		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A

		ret

; ***************************************************************************
; * AddFigure                                                               *
; ***************************************************************************
; * Inputs:     A=Sprite color add value                                    *
; *               $80 bit = FLIP X                                          *
; *             BC=Sprite #                                                 *
; *             DE=XY                                                       *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Adds a figure to the figure list                            *
; ***************************************************************************

AddFigure::	ldh	[hTmp2Lo],a	;Sprite color value
		ldh	a,[hRomBank]
		push	af

		ld	[wSprPlotSP],sp

		ld	a,[wFigCount]
		inc	a
		ld	[wFigCount],a
		dec	a
		add	a
		add	LOW(FigureTable)
		ld	l,a
		ld	h,HIGH(FigureTable)
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	sp,hl

		LDHL	SP,SPR_SCR_X
		ld	[hl],d	;Sprite's X pos
		inc	hl
		ld	a,d
		cp	208
		ccf
		ld	a,0
		sbc	a
		ld	[hli],a
		ld	[hl],e	;Sprite's Y pos
		inc	hl
		xor	a
		ld	[hli],a
		LDHL	SP,SPR_FLAGS
		ld	[hl],(1<<FLG_DRAW)|(1<<FLG_PLOT)
		ldh	a,[hTmp2Lo]	;Sprite's X flip bit (0x80)
		and	$80
		srl	a
		srl	a
		LDHL	SP,SPR_FLIP
		ld	[hli],a ;SPR_FLIP
		ldh	a,[hTmp2Lo]
		and	$17
		ld	[hl],a	;SPR_COLR

		LDHL	SP,SPR_FRAME
		ld	[hl],c
		inc	hl
		ld	[hl],b

		ldh	a,[hSprNxt]
		ld	l,a
		ld	h,$80>>4
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	b,h
		ld	c,l
		call	SprDump
		LD	HL,wSprPlotSP		;Restore stack pointer.
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ret



; ***************************************************************************
; * OutFigures                                                              *
; ***************************************************************************
; * Inputs:     None                                                        *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Displays all the figures                                    *
; ***************************************************************************

OutFigures::
		call	OutFiguresPassive
		LD	A,HIGH(wOamShadow)	;Signal VBL to update OAM RAM and
		LDH	[hOamFlag],A		;character sprites.
		ret

OutFiguresPassive::
		ld	[wSprPlotSP],sp
		xor	a
		ld	[wFigTake],a
		ld	de,wOamShadow
.oflp:
		ld	a,[wFigCount]
		ld	b,a
		ld	hl,wFigTake
		ld	a,[hl]
		inc	[hl]
		cp	b
		jr	z,.ofdone
		add	a
		add	LOW(FigureTable)
		ld	l,a
		ld	h,HIGH(FigureTable)
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	sp,hl
		call	SprDraw
		jr	.oflp
.ofdone:
		LD	L,E			;Blank out the remaining OAM
		LD	H,HIGH(wOamShadow)	;entries in the OAM buffer.
		LD	A,160
		SUB	L
		jr	z,.noclr
		RRCA
		RRCA
		LD	E,A
		XOR	A
.clr		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		LD	[HLI],A
		DEC	E
		JR	NZ,.clr
.noclr:
		LD	HL,wSprPlotSP		;Restore stack pointer.
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL
		ret


; ***************************************************************************
; * AnyWait                                                                 *
; ***************************************************************************
; * Inputs:     A=# of 60ths to wait                                        *
; * Outputs:    None                                                        *
; * Preserves:  All                                                         *
; * Function:   Delay for a while                                           *
; ***************************************************************************

Wait15:		ld	a,15
		jr	AnyWait
Wait30:		ld	a,30
		jr	AnyWait
Wait60:		ld	a,60
AnyWait:	push	af
		call	WaitForVBL
		pop	af
		dec	a
		jr	nz,AnyWait
		ret

; ***************************************************************************
; * AccurateWait                                                            *
; ***************************************************************************
; * Inputs:     A/8 = # of 60ths to wait                                    *
; * Outputs:    None                                                        *
; * Preserves:  All                                                         *
; * Function:   Delay for a while                                           *
; ***************************************************************************

AccurateWait:	push	bc
		ld	b,a
		ldh	a,[hVbl8]
		sub	b
		ldh	[hVbl8],a
.acw:		ldh	a,[hVbl8]
		add	a
		jr	c,.acw
		pop	bc
		ret

; ***************************************************************************
; * FadeIn and FadeOut                                                      *
; ***************************************************************************
; * Inputs:     None                                                        *
; * Outputs:    None                                                        *
; * Preserves:  None                                                        *
; * Function:   Fades with proper GMB palette included                      *
; ***************************************************************************

FadeIn::
		call	normalgmbfade
		jp	FadeInBlack
FadeOut::
		call	normalgmbfade
		jp	FadeOutBlack


; ***************************************************************************
; * RideVector#                                                             *
; ***************************************************************************
; * Vectors related to the parallax scrolling on Belle's Wild Ride          *
; ***************************************************************************

RideVector0:	ld	a,[wParallax0]
		ldio	[rSCX],a
		xor	a
		ldio	[rSCY],a
		SETLYC	RideVector1
		ld	a,16
		ldio	[rLYC],a
		jp	wJmpSprDumpMod
RideVector1:
		ld	a,[wParallax1]
		ldio	[rSCX],a
		SETLYC	RideVector2
		ld	a,[wParallax1]
		ldio	[rSCX],a
		ld	a,112
		ldio	[rLYC],a
		call	wJmpSprDumpMod
		pop	af
		reti
RideVector2:
		ld	a,[wParallax2]
		ldio	[rSCX],a
		SETLYC	RideVector3
		ld	a,136
		ldio	[rLYC],a
		call	wJmpSprDumpMod
		pop	af
		reti
RideVector3:	xor	a
		ldio	[rSCX],a
		ld	a,8
		ldio	[rSCY],a
		ld	a,192
		ldio	[rLYC],a
		ld	a,140+5
		call	wJmpSprDumpMod
		pop	af
		reti

CellarVector0::	xor	a
		ldio	[rSCX],a
		ld	a,[$CF00]
		ldio	[rLYC],a
		jp	wJmpSprDumpMod
CellarVector1::	ldio	a,[rLY]
		push	hl
		ld	l,a
		ld	h,$CF
		ld	a,[hl]
		ldio	[rSCX],a
		ld	a,l
		inc	a
		inc	a
		ldio	[rLYC],a
		cp	$8c+2
		jr	c,.aok
		ld	a,$c0
		ldio	[rLYC],a
.aok:		pop	hl
.ignore:	pop	af
		reti


; ***************************************************************************
; * StdStage                                                                *
; ***************************************************************************
; * Inputs A=group ID #                                                     *
; *       HL=counter                                                        *
; * Do the standard stage indicator sprite                                  *
; ***************************************************************************

STD_STAGE_CYCLE	EQU	48
STD_STAGE_PH1	EQU	16
STD_STAGE_PH2	EQU	32
STD_STAGEY	EQU	36


SFX_STAGEDITTY	EQU	58

StdStage::	ld	e,a
		ld	a,[hl]
		or	a
		ret	z
;		dec	a
;		jr	nz,.noditty
;		push	hl
;		ld	a,SFX_STAGEDITTY
;		call	InitSfx
;		pop	hl
;.noditty:
		ld	a,[wSubGaston]
		or	a
		jr	z,.nogaston
		ld	[hl],0
		ret
.nogaston:	inc	[hl]
		ld	a,[hl]
		cp	STD_STAGE_CYCLE
		jr	c,.noover
		ld	[hl],0
		ret
.noover:	cp	STD_STAGE_PH1
		jr	c,.ph1
		cp	STD_STAGE_PH2
		jr	c,.ph2
		sub	STD_STAGE_PH2
		add	a
		add	a
		add	a
		cpl
		add	80+1
		jr	.gota
.ph1:		add	a
		add	a
		add	a
		cpl
		add	80+128+1
		jr	.gota
.ph2:		ld	a,80
.gota:		ld	d,a
		ld	a,[wLanguage]
		ld	c,a
		add	a
		add	c
		ld	c,a
		ld	a,[wSubStage]
		add	c
		add	255&IDX_STAGES
		ld	c,a
		ld	a,0
		adc	IDX_STAGES>>8
		ld	b,a
;		ld	a,[wSubGaston]
;		or	a
;		jr	z,.bcok
;		ld	bc,IDX_STAGES+3
;.bcok:
		ld	a,e
		ld	e,STD_STAGEY
		jp	AddFigure

; ***************************************************************************
; * LoadPalHL                                                               *
; ***************************************************************************
; * Inputs HL=64 colors                                                     *
; * Load up the CGB BG palette                                              *
; ***************************************************************************

LoadPalHL::
		LDH	A,[hMachine]
		CP	MACHINE_CGB
		RET	NZ
		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopy

		LD	A,WRKBANK_NRM		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;
		RET
; ***************************************************************************
; * AnyApply                                                                *
; ***************************************************************************
; * Inputs HL=source data                                                   *
; *        DE=map to apply                                                  *
; ***************************************************************************

AnyApply::	ld	a,[hli]
		or	a
		ret	z
		ld	c,a
		ld	a,[hli]
		add	e
		ld	e,a
		ld	a,[hli]
		adc	d
		ld	d,a
.copylp:	ld	a,[hli]
		add	b
		ld	[de],a
		inc	e	;won't cross 32 byte line
		dec	c
		jr	nz,.copylp
		jr	AnyApply

; ***************************************************************************
; * SumBBRam                                                                *
; ***************************************************************************
; * Inputs   None                                                           *
; * Outputs  None                                                           *
; * Function Correct the BBRAM checksum(s)                                  *
; ***************************************************************************

SumBBRam::
		ld	hl,wHighScores1
		call	Sum256
		ld	hl,wHighScores2
Sum256:		ld	de,0
		jr	.enter
.lp:		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
.enter:		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	a,l
		or	a
		jr	nz,.lp
		dec	hl
		dec	hl
		ld	a,e
		ld	[hli],a
		ld	[hl],d
		ret

; ***************************************************************************
; * CheckBBRam                                                              *
; ***************************************************************************
; * Inputs   None                                                           *
; * Outputs  None                                                           *
; * Function Check BBRAM checksum(s) , init and reset if failure            *
; ***************************************************************************

CheckBBRam::
		ld	hl,wHighScores1
		call	Check256
		jp	nz,InitBBRam
		ld	hl,wHighScores2
		call	Check256
		jp	nz,InitBBRam
		ret
Check256:	ld	de,0
		jr	.enter
.lp:		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
.enter:		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	a,l
		or	a
		jr	nz,.lp
		ld	a,e
		sub	c
		ret	nz
		ld	a,d
		sbc	b
		ret

; ***************************************************************************
; * InitBBRam                                                               *
; ***************************************************************************
; * Inputs   None                                                           *
; * Outputs  None                                                           *
; * Function Init BBRAM                                                     *
; ***************************************************************************

InitBBRam::
		ld	hl,wLockState
		ld	bc,16
		call	MemClear
		call	LockStories
ReInitBBRam::
		ld	hl,wSelect4
		ld	a,1
		ld	[hli],a
		inc	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		xor	a
		ld	[wMusicOff],a
		ld	hl,wHighScores1
		ld	bc,256
		call	MemClear
		ld	hl,wHighScores2
		ld	bc,256
		call	MemClear
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(PresetHighs)
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		call	PresetHighs
		pop	af
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		jp	SumBBRam


; ***************************************************************************
; * IncScore                                                                *
; ***************************************************************************
; * Inputs   None                                                           *
; * Outputs  None                                                           *
; * Function Increment wScoreLo and wScoreHi                                *
; ***************************************************************************

IncScore::	ld	hl,wScoreLo
		ld	a,[hl]
		cp	255&9999
		jr	nz,.doinc
		inc	hl
		ld	a,[hld]
		cp	9999>>8
		ret	z
.doinc:		inc	[hl]
		ret	nz
		inc	hl
		inc	[hl]
		ret

pickolde::	ld	a,LOW(FontOlde)
		ld	[wFontLo],a
		ld	a,HIGH(FontOlde)
		ld	[wFontHi],a
		ret
pickend::	ld	a,LOW(FontEnd)
		ld	[wFontLo],a
		ld	a,HIGH(FontEnd)
		ld	[wFontHi],a
		ret
picklite::	ld	a,LOW(FontLite)
		ld	[wFontLo],a
		ld	a,HIGH(FontLite)
		ld	[wFontHi],a
		ret
pickdark::	ld	a,LOW(FontDark)
		ld	[wFontLo],a
		ld	a,HIGH(FontDark)
		ld	[wFontHi],a
		ret

InitTunePref::	ld	b,a
		ld	a,[wMusicOff]
		or	a
		ret	nz
		ld	a,b
		jp	InitTune


randtunes:	db	7,13,11,6,12,4,5,10

RandTunePref::
		ld	a,[wMusicOff]
		or	a
		ret	nz
		call	random
		and	7
		ld	hl,randtunes
		call	addahl
		ld	a,[hl]
		jp	InitTune



; ***************************************************************************
; * SplitString ()                                                          *
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

		IF	VERSION_JAPAN

;
;
;

SplitString::	LD	HL,wString		;Chop the string up.

		LD	DE,wStringLine1		;
		CALL	SplitChunk		;
		LD	DE,wStringLine2		;
		CALL	SplitChunk		;
		LD	DE,wStringLine3		;
		CALL	SplitChunk		;
		LD	DE,wStringLine4		;
		CALL	SplitChunk		;

		LD	A,[wStringBad]		;
		OR	[HL]			;
		LD	[wStringBad],A		;

		RET				;All Done.

;
;
;

SplitChunk::	LD	B,24			;

.Loop:		LD	A,[HL]			;
		OR	A			;
		JR	Z,.Done			;
		INC	HL			;
		CP	$01			;
		JR	Z,.Done			;

		CP	ICON_SPACE		;
		JR	NZ,.Copy		;
.Skip:		LD	A,[HLI]			;
		CP	ICON_SPACE		;
		JR	Z,.Skip			;
		DEC	HL			;
		LD	A,ICON_SPACE		;

.Copy:		LD	[DE],A			;
		INC	DE			;
		DEC	B			;
		JR	NZ,.Loop		;

.Done:		XOR	A			;
		LD	[DE],A			;
		INC	DE			;
		RET				;

;
;
;

		ELSE

;
;
;

SplitString::	LD	HL,wString		;Chop the string up.

		LD	DE,wStringL1Width	;

		LD	A,[DE]			;
		LD	C,A			;
		LD	B,0			;
		PUSH	DE			;
		LD	DE,wStringLine1		;
		CALL	SplitChunk		;
		POP	DE			;

		LD	A,[DE]			;
		LD	C,A			;
		LD	B,0			;
		PUSH	DE			;
		LD	DE,wStringLine2		;
		CALL	SplitChunk		;
		POP	DE			;

		LD	A,[DE]			;
		LD	C,A			;
		LD	B,0			;
		PUSH	DE			;
		LD	DE,wStringLine3		;
		CALL	SplitChunk		;
		POP	DE			;

		LD	A,[DE]			;
		LD	C,A			;
		LD	B,0			;
		PUSH	DE			;
		LD	DE,wStringLine4		;
		CALL	SplitChunk		;
		POP	DE			;

		LD	A,[DE]			;
		LD	C,A			;
		LD	B,0			;
		PUSH	DE			;
		LD	DE,wStringLine5		;
		CALL	SplitChunk		;
		POP	DE			;

		LD	A,[wStringBad]		;
		OR	[HL]			;
		LD	[wStringBad],A		;

		RET				;All Done.

;
;
;

SplitChunk::	LD	A,E			;
		LDH	[hTmp2Lo],A		;
		LD	A,D			;
		LDH	[hTmp2Hi],A		;
		LD	A,C			;
		LDH	[hTmp3Lo],A		;

.StripLeadSpc:	LD	A,[HLI]			;Skip leading spaces.
		CP	$20			;
		JR	Z,.StripLeadSpc		;
		DEC	HL			;

		XOR	A			;Handle an empty string.
		LD	[DE],A			;
		OR	[HL]			;
		RET	Z			;

		PUSH	HL			;
		PUSH	DE			;

.Loop2:		LD	A,[HLI]			;Copy string up until the
		OR	A			;next blank character.
		JR	Z,.Skip0		;
		CP	$20			;
		JR	Z,.Skip0		;
		LD	[DE],A			;
		INC	DE			;
		JR	.Loop2			;

.Skip0:		DEC	HL			;
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

.StripTailSpc:	LD	A,[HLI]			;Skip trailing spaces.
		CP	$20			;
		JR	Z,.StripTailSpc		;
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

		ENDC



; ***************************************************************************
; * HashLanguage                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; * Outputs     None                                                        *
; * Preserves   BC, DE                                                      *
; * Function    Copy wLanguage to wLanguageH1-H3 in modified form           *                                                                        *
; ***************************************************************************

LB1		EQU	$DA
LB2		EQU	$57
LB3		EQU	$AA


HashLanguage::
		ld	a,[wLanguage]
		xor	LB1
		ld	hl,wLanguageH1
		ld	[hli],a
		xor	LB1^LB2
		ld	[hli],a
		xor	LB2^LB3
		ld	[hli],a
		ret

; ***************************************************************************
; * CheckLanguage                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; * Outputs     None                                                        *
; * Preserves   BC, DE                                                      *
; * Function    Set Z flag if wLanguage has been set                        *                                                                        *
; ***************************************************************************

CheckLanguage::
		IF	VERSION_EUROPE
		ld	a,[wLanguage]
		cp	5
		jr	c,.maybeok
		dec	a	;set NZ flag
		jr	.bad
.maybeok:	ld	hl,wLanguageH1
		xor	LB1
		cp	[hl]
		jr	nz,.bad
		inc	hl
		xor	LB1^LB2
		cp	[hl]
		jr	nz,.bad
		inc	hl
		xor	LB2^LB3
		cp	[hl]
.bad:		ret
		ELSE
		xor	a
		ld	[wLanguage],a
		ret
		ENDC

; ***************************************************************************
; * noisyReadJoypad                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A=JS MASK, 1 = make noise                                   *
; * Outputs     None                                                        *
; * Preserves   None                                                        *
; * Function    Make noise on user input                                    *                                                                        *
; ***************************************************************************

SFX_MOVEBEEP	EQU	80
SFX_SELBEEP	EQU	75

noisyReadJoypad::
		push	af
		call	ReadJoypad
		pop	af
		push	hl
		ld	hl,wJoy1Hit
		and	[hl]
		pop	hl
		ret	z
		and	15
		ld	a,SFX_MOVEBEEP
		jp	nz,InitSfx
		ld	a,SFX_SELBEEP
		jp	InitSfx
