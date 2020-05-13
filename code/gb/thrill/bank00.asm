; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** GAMEBOY THRILLRIDE                                            PROGRAM **
; **                                                                       **
; ** Last modified : 990218 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

		SECTION	00


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
		add	a		; 1 Byte  0018
		pop	hl		; 1 Byte  0019
		add	l		; 1 Byte  001a
		ld	l,a		; 1 Byte  001b
		jr	nc,.noinch	; 1 Byte  001c
		inc	h		; 1 Byte  001e
.noinch:	ld	a,[hli]		; 1 Byte  001f
		ld	h,[hl]		; 1 Byte  0020
		ld	l,a		; 1 Byte  0021
		jp	[hl]		; 1 Byte  0022
		DCB	5,0

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

VecSio::
		RETI				;$0058
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
		CALL	NZ,CgbXferPalette	;x,3

		CALL	wJmpVblVector		;?   Call user routine.

		EI				;Enable interrupts.

		LD	A,BANK(SoundBase)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	SOUNDREFRESH		;

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
		DB	"T","H","R","I"		;$0134 Game title.
		DB	"L","L","R","I"
		DB	"D","E","!"
		DB	"V","U","P","E"		;$013F Game code.
		DB	$C0			;$0143 CGB function code.
		DB	$37,$44			;$0144 Maker code. (7D = sierra)
		DB	$00			;$0146 SGB function code.
		DB	$1E			;$0147 Cartridge type.
		DB	ROM_8M			;$0148 ROM size.
		DB	RAM_64K			;$0149 RAM size.
		DB	WORLD_CODE		;$014A Destination code.
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
; * TblDirn2Info                                                    00:0180 *
; ***************************************************************************
; * Xvert direction to sprite info index                                    *
; ***************************************************************************
; * N.B.        7 8 1         3 4 ~3         4 6 ~4                         *
; *              \|/           \|/            \|/                           *
; *             6-0-2   -->   2-0-~2   -->   2-0-~2                         *
; *              /|\           /|\            /|\                           *
; *             5 4 3         1 5 ~1         0 8 ~0                         *
; *                                                                         *
; *             This table MUST be 16-byte aligned.                         *
; ***************************************************************************

TblDirn2Info::	DB	$06			;0 (used on initialization)
		DB	$24			;1
		DB	$22			;2
		DB	$20			;3
		DB	$08			;4
		DB	$00			;5
		DB	$02			;6
		DB	$04			;7
		DB	$06			;8
		DB	$FF			;9 (illegal)
		DB	$FF			;A (illegal)
		DB	$FF			;B (illegal)
		DB	$FF			;C (illegal)
		DB	$FF			;D (illegal)
		DB	$FF			;E (illegal)
		DB	$FF			;F (illegal)


;Table of sprite structure locations
;Must not cross page boundary
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


;ALIGN ON PAGE BOUNDARY
RampAwards::	db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,3
		db      0,0,2,0,0,1,0,0,0,0,0,1,0,0,2,0
		db      0,1,0,0,0,0,0,1,0,0,2,0,0,1,0,0
		db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,1
		db      0,0,2,0,0,1,0,0,0,0,0,1,0,0,2,0
		db      0,1,0,0,0,3,0,1,0,0,2,0,0,1,0,0
		db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,1
		db      0,0,2,0,0,1,0,0,0,0,0,1,0,0,2,0
		db      0,1,0,0,0,0,0,1,0,0,2,0,0,1,0,0
		db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,1
		db      0,0,2,0,0,1,0,0,0,0,0,1,0,0,2,0
		db      0,1,0,0,0,0,0,1,0,0,2,0,0,1,0,0
		db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,1
		db      0,0,2,0,0,1,0,0,0,0,0,1,0,0,2,0
		db      0,0,0,0,0,0,0,1,0,0,2,0,0,1,0,0
		db      0,0,0,1,0,0,2,0,0,1,0,0,0,0,0,1




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
; * VblVectors                                                      00:0300 *
; ***************************************************************************
; * Table of jump addresses to VBL interrupt routines                       *
; ***************************************************************************
; * N.B.        This table MUST not cross a page boundary.                  *
; ***************************************************************************

VblDoNothing::	JP	DoVblNull
VblNormal::	JP	DoVblNormal

LycDoNothing::	JP	DoLycNull
LycNormal::	JP	DoLycNormal
LycStatus::	JP	DoLycStatus
LycIntro::	JP	DoLycNormal
LycScroll::	JP	DoLycNormal
LycTargetRange::JP	DoLycNull



; ***************************************************************************
; * StructSmodCgb                                                           *
; ***************************************************************************
; * Tabels of jump intructions used to self-modify program behaviour        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************

LENGTH_SMOD	EQU	$6


StructSmodCgb::	JP	VblDoNothing		;01 wJmpVblVector
		JP	LycDoNothing		;04 wJmpLycVector


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

		LDH	A,[hMachine]		;

ResetMachine::	DI				;Disable interrupts.

		LDH	[hMachine],A		;Save entry code.

		LD	SP,$FFFC		;Set up temporary stack.

		XOR	A			;Enable writes to cartridge
		LD	[rMBC5_RAM],A		;ram and select bank 0.
		LD	[rMBC5_ROMH],A		;
		INC	A			;
		LD	[rMBC5_ROML],A		;
		LD	A,$0A			;
		LD	[rMBC5_GATE],A		;

		LDH	A,[hMachine]
		CP	MACHINE_CGB
		JR	Z,.IsCGB
		LD	A,BANK(GmbChoke)
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		JP	GmbChoke
.IsCGB:

ResetWaitVbl::	LDIO	A,[rLY]			;Wait for VBLANK.
		CP	145			;
		JR	NZ,ResetWaitVbl		;

		LDIO	A,[rLCDC]		;Stop LCD display.
		AND	%01111111		;
		LDIO	[rLCDC],A		;

		call	checkpagecrossings

		LD	HL,$FF80		;Clear internal work
		LD	BC,$007A		;RAM.
		CALL	MemClear		;

		LD	A,$FF			;??? Dave's ???
		LDH	[hCutoff],A		;

		LD	HL,$C000		;Clear external work
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

		LD	HL,CgbChrDumpFinish	;Copy DumpChrs() to internal
		LD	DE,wChrFinish		;memory.
		LD	BC,CgbChrDumpFinishEnd-CgbChrDumpFinish
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

		LD	A,BANK(SoundBase)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		LD	E,0
		CALL	SOUNDTUNE		;

		XOR	A			;Clear hardware timer.
		LDIO	[rTAC],A		;
		LDIO	[rSCX],A		;
		LDIO	[rSCY],A		;

		XOR	A			;Clear all palettes.
		LDIO	[rBGP],A		;
		LDIO	[rOBP0],A		;
		LDIO	[rOBP1],A		;

		LD	A,BANK(RandInit)	;Init random # table.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	BBRAMInit
		CALL	RandInit		;

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

MainLoop::

		CALL	FadeOutBlack		;Fade out whole screen to black.

		LD	A,15			;
		CALL	AnyWait			;

		LD	A,LOW(VblNormal)		;
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
; * N.B.        bLanguage is used to find the current language              *
; ***************************************************************************

		GLOBAL	TblStrings

GetString::	LDH	A,[hRomBank]		;Preserve bank.
		PUSH	AF			;

		LD	A,BANK(TblStrings)	;Page in the strings.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	HL,TblStrings		;Locate the table for
		LD	A,[bLanguage]		;this language.
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
		ADD	BANK(TblStrings)	;
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
		ld	a,WRKBANK_BG
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		LD	DE,$C800
		CALL	SwdDecode
		LD	A,BANK(loadbg)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	loadbg
		ld	a,WRKBANK_NRM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
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
 expon
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
.Loop:
		LD	[HLI],A			;2
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

.WaitCGB:	LDIO	A,[rKEY1]		;Switching speed ?
		RRA				;
		JR	NC,.WaitNormal		;

		LD	HL,hVblFlag		;
		XOR	A			;
		LD	[HL],A			;
.WaitCGBLoop:	OR	[HL]			;
		JR	Z,.WaitCGBLoop		;
		POP	HL			;
		POP	AF			;
		RET				;

.WaitNormal:	LD	HL,hVblFlag		;
		XOR	A			;
		LD	[HL],A			;
.WaitNormalLoop:
		HALT				;
		NOP				;
		OR	[HL]			;
		JR	Z,.WaitNormalLoop	;
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

ReadJoypad::
		LD	HL,rP1			;Read current keystate.

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

ReadJoypadNoReset::

		LD	HL,rP1			;Read current keystate.

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

.Loop:		CALL	FastDumpChr		;Dump a single chr.

		ld	a,e
		add	$10
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,l
		add	$10
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a

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

		CALL	FastDumpChr		;Dump a single chr.

		ld	a,e
		add	$10
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,l
		add	$10
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a

		DEC	C			;Loop until done.
		JR	NZ,.Loop		;

		RET				;All Done.

FastDumpChr::
		LDIO	A,[rLY]			;3   Don't start the transfer
		DEC	A			;1   during vblank.
		CP	140			;2
		JR	NC,FastDumpChr		;3/2
		di
		ld	b,3
.w1:		ldio	a,[rSTAT]
		and	b
		jr	z,.w1
.w2:		ldio	a,[rSTAT]
		and	b
		jr	nz,.w2

		ld	a,e
		ldio	[rHDMA4],a
		ld	a,d
		ldio	[rHDMA3],a
		ld	a,l
		ldio	[rHDMA2],a
		ld	a,h
		ldio	[rHDMA1],a
		ld	a,$80
		ldio	[rHDMA5],a
		ei
		ret


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


CgbChrDump::
		LDIO	A,[rLY]			;3   Don't start the transfer
		DEC	A			;1   during vblank.
		CP	140			;2
		JR	NC,CgbChrDump		;3/2

		LD	[wChrFinish+1],SP
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

		JP	wChrFinish

CgbChrDumpFinish:
		LD	SP,0
		EI
		RET
CgbChrDumpFinishEnd:


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
		LD	A,BANK(SoundBase)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		LD	E,0
		CALL	SOUNDTUNE
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
		LD	A,BANK(SoundBase)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		LD	E,0
		CALL	SOUNDTUNE
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

InitTune::
		LD	E,A
;		OR	A
;		JR	Z,.silence
		LD	A,[wTune]
		CP	E
		RET	Z
		LD	A,E
.silence:	LD	[wTune],A
		LDH	A,[hRomBank]
		PUSH	AF
		LD	A,B
		LD	A,BANK(SoundBase)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	SOUNDTUNE
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

InitSfx::	OR	A
		RET	Z
		LD	E,A
		LDH	A,[hRomBank]
		PUSH	AF
		LD	A,BANK(SoundBase)
		LDH	[hRomBank],a
		LD	[rMBC_ROM],a
		CALL	SOUNDFX
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
;		LDH	A,[hLycBGP]		;3
;		LDIO	[rBGP],A		;3
		POP	AF			;3
		RETI				;4

DoLycStatus::

		push	hl
		push	bc
		ld	hl,wPanelRGB
		ld	c,255&rBCPD
		ld	b,%11110100
;.wait:		ldio	a,[rSTAT]
;		and	3
;		jr	nz,.wait
		ld	a,$80		;2
		ldio	[rBCPS],a	;3
		call	.block
		call	.block

		ld	a,1
		ldh	[hPalFlag],a
		pop	bc
		pop	hl
		pop	af
		reti
.block:
.wait2:		ldio	a,[rSTAT]
		and	3
		jr	z,.wait2
.wait3:		ldio	a,[rSTAT]
		and	3
		jr	nz,.wait3
		REPT	24
		ld	a,[hli]	;2
		ld	[c],a	;2
		ENDR
		ret

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
		ld	[wFigPhase],a
		ld	[wPalCount],a
		ret

; ***************************************************************************
; * AddPalette                                                              *
; ***************************************************************************
; * Inputs      HL=Palette                                                  *
; * Outputs     A=Pal # used for sprite structure                           *
; * Preserves   None                                                        *
; * Function    Loads up color table                                        *
; ***************************************************************************

AddPalette::
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
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	hl,wPalCount
		ld	a,[hl]
		inc	[hl]
		ret

Palette3now::
		ld	de,wOcpShadow+8*3
		jr	allpalettesnow
Palette4now::
		ld	de,wOcpShadow+8*4
		jr	allpalettesnow
Palette5now::
		ld	de,wOcpShadow+8*5
		jr	allpalettesnow
Palette6now::
		ld	de,wOcpShadow+8*6
		jr	allpalettesnow
Palette7now::
		ld	de,wOcpShadow+8*7
allpalettesnow:
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		push	hl
		ld	bc,8
		call	MemCopy
		ld	hl,wOcpArcade-wOcpShadow-8
		add	hl,de
		ld	d,h
		ld	e,l
		pop	hl
		ld	bc,8
		call	MemCopy
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ret

IDXPalette4now:
		ld	de,wOcpShadow+8*4
		jr	allidxpalettesnow
IDXPalette5now::
		ld	de,wOcpShadow+8*5
		jr	allidxpalettesnow
IDXPalette6now::
		ld	de,wOcpShadow+8*6
		jr	allidxpalettesnow
IDXPalette7now::
		ld	de,wOcpShadow+8*7
allidxpalettesnow:
		ld	bc,8
		push	de
		call	MemCopyInFileSys
		pop	bc
		ld	hl,wOcpArcade-wOcpShadow
		add	hl,bc
		ld	d,h
		ld	e,l
		ld	h,b
		ld	l,c
		ld	bc,8
		jp	MemCopy


Palette6::
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	de,wOcpArcade+8*6
		ld	bc,8
		call	MemCopy
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ret

Palette7::
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	de,wOcpArcade+8*7
		ld	bc,8
		call	MemCopy
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ret

; ***************************************************************************
; * ReplacePalette                                                          *
; ***************************************************************************
; * Inputs      HL=Palette, A=Palette # as returned by AddPalette           *
; * Outputs     None                                                        *
; * Preserves   None                                                        *
; * Function    Loads up replacement color table                            *
; ***************************************************************************
ReplacePalette::
		add	a
		add	a
		add	a
		ld	de,wOcpArcade
		add	e
		ld	e,a
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(AllPalettes)	;Get AllPalettes ROM Bank
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		push	hl
		ld	bc,8
		call	MemCopy
		pop	hl
		ld	bc,wOcpShadow-wOcpArcade-8
		ld	a,c
		add	e
		ld	e,a
		ld	a,b
		adc	d
		ld	d,a
		ld	bc,8
		call	MemCopy
		pop	af
		LDH	[hRomBank],A
		LD	[rMBC_ROM],A
		ld	a,1
		ldh	[hPalFlag],a
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
; * AddFigure                                                               *
; ***************************************************************************
; * Inputs:     A=Sprite color add value                                    *
; *               $80 bit = FLIP X                                          *
; *               $08 bit = priority bit                                    *
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
		ld	a,e
		cp	200
		ccf
		ld	a,0
		sbc	a
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
		and	$7f
		bit	3,a
		jr	z,.aok2
		or	$80
.aok2:		and	$97
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
		di
		ldh	a,[hVbl8]
		sub	b
		jr	c,.fine
		xor	a
		sub	b
.fine:		ldh	[hVbl8],a
		ei
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
; * Function:   Fades                                                       *
; ***************************************************************************

FadeIn::
		jp	FadeInBlack
FadeOut::
		jp	FadeOutBlack


; ***************************************************************************
; * LoadPalHL                                                               *
; ***************************************************************************
; * Inputs HL=64 colors                                                     *
; * Load up the CGB BG palette                                              *
; ***************************************************************************

LoadPalHL::

		ld	de,wBcpArcade
		ld	bc,64
		jp	MemCopy

; ***************************************************************************
; * MakeChanges/UndoChanges                                                 *
; ***************************************************************************
; * Inputs HL=IDX of CHG list                                               *
; ***************************************************************************

;hl=change list IDX from file system
MakeChanges:	ldh	a,[hRomBank]
		push	af
		call	FindInFileSys
		ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.chlp:		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		and	e
		inc	a
		jr	z,.done
		ld	a,d
		add	$d0
		ld	d,a
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hli]
		ld	[de],a
		inc	hl
		inc	hl
		jr	.chlp
.done:		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

UndoChanges:	ldh	a,[hRomBank]
		push	af
		ld	[rMBC_ROM],a
		call	FindInFileSys
		ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
.udlp:		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		and	e
		inc	a
		jr	z,.done
		ld	a,d
		add	$d0
		ld	d,a
		inc	hl
		inc	hl
		ld	a,[hli]
		ld	[de],a
		inc	e
		ld	a,[hli]
		ld	[de],a
		jr	.udlp
.done:		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

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

picklite::	ld	a,LOW(FontLite)
		ld	[wFontLo],a
		ld	a,HIGH(FontLite)
		ld	[wFontHi],a
		ret

InitTunePref::	ld	b,a
		ld	a,[bMusicOff]
		or	a
		ret	nz
		ld	a,b
		jp	InitTune


; ***************************************************************************
; * SetMachineJcb ()                                                        *
; ***************************************************************************
; * Reset the hardware to a default state                                   *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the LCD is on, and all palettes are faded out. *
; ***************************************************************************

SetMachineJcb::	DI				;Vector LYC and VBL irqs to
		LD	A,LOW(LycDoNothing)	;harmless code (using full
		LD	[wLycVector+0],A	;16-bit addresses in case
		LD	A,HIGH(LycDoNothing)	;Dave's code changed the
		LD	[wLycVector+1],A	;hi-byte).
		LD	A,LOW(VblDoNothing)	;
		LD	[wVblVector+0],A	;
		LD	A,HIGH(VblDoNothing)	;
		LD	[wVblVector+1],A	;
		EI				;

		XOR	A			;
		LDH	[hPosFlag],A		;
		LDH	[hOamFlag],A		;

		LDIO	[rSCX],A		;Reset scroll position.
		LDIO	[rSCY],A		;

		DEC	A			;Disable LYC interrupt.
		LDIO	[rLYC],A		;

		LD	A,7			;Reset window position.
		LDIO	[rWX],A			;
		LD	A,144			;
		LDIO	[rWY],A			;
		LDH	[hWndY],A		;

		LD	A,%11100111		;Bgd_chr9000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
		LD	A,%11100111		;Wnd_scr9C00,Wnd_on.
		LDH	[hLycLCDC],A		;

		LD	A,HIGH(wOamShadow)	;Initialize the OAM shadow
		LDH	[hOamPointer],A		;buffer.
		CALL	SprBlank		;

		LD	A,HIGH(wOamShadow)	;And copy it to the OAM RAM.
		LDH	[hOamFlag],A		;

		CALL	WaitForVBL		;Wait for the update.

		XOR	A			;
		LD	[wJoy1Hit],A		;
		DEC	A			;
		LD	[wJoy1Cur],A		;

		XOR	A			;
		LD	[wFigCount],A		;
		LD	[wFigPhase],A		;

		LD	A,LOW(wOamBuffer)	;
		LDH	[hOamBufLo],A		;
		LD	A,HIGH(wOamBuffer)		;
		LDH	[hOamBufHi],A		;

		LD	A,LOW(DoNothing)		;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DoNothing)		;
		LD	[wJmpDraw+2],A		;

		LD	A,WRKBANK_NRM		;Page in normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		RET				;All Done.

initstuff:

		XOR	A
		ldio	[rWX],a
		ldio	[rWY],a

		LDH	[hPosFlag],A
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a

		XOR	A
		LDIO	[rSCX],A		;Reset scroll position.
		LDIO	[rSCY],A
		DEC	A
		LD	[wJoy1Cur],A
		LDIO	[rLYC],A		;disable interrupt

		LD	A,LOW(LycDoNothing)	;Vector LYC and VBL interrupts to
		LD	[wLycVector],A		;harmless code.
		LD	A,LOW(VblDoNothing)
		LD	[wVblVector],A

		LD	A,$40			;Set LCDC interrupt to LYC
		LDIO	[rSTAT],A		;detection, and then clear
		XOR	A			;out pending interrupts.
		LDIO	[rIF],A			;

		LD	A,%10000111
		LDH	[hLycLCDC],A
		LD	A,%10000111
		LDH	[hVblLCDC],A

		LD	A,LOW(LycNormal)
		LD	[wLycVector],A
		LD	A,LOW(VblNormal)
		LD	[wVblVector],A

		LD	A,HIGH(wOamShadow)	;Initialize OAM shadow
		LDH	[hOamPointer],A		;buffer.

		CALL	SprBlank		;Blank out the OAM_BUFFER.

		LD	A,HIGH(wOamShadow)	;And copy it to the OAM RAM.
		LDH	[hOamFlag],A

		LD	A,$FF			;Enable pause mode.
		LD	[wJoy1Cur],A

		LD	A,HIGH(wOamShadow)	;Signal VBL to update OAM RAM and
		LDH	[hOamFlag],A		;character sprites.
		LDH	[hPosFlag],A

		call	InitAutoRepeat

		ret

ShellCode::

		call	initstuff

		ld	a,BANK(doshell)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		jp	doshell


sprblank::	ld	hl,wOamShadow
		ld	c,160/8
		xor	a
.blp:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.blp
		LD	A,HIGH(wOamShadow)	;And copy it to the OAM RAM.
		LDH	[hOamFlag],A
		ret

;returns a=random # 00-ff
;preserves everything else
random::	push	hl
		push	de
		ld	hl,wRandTake
		inc	[hl]
		ld	a,[hl]
		cp	55
		jr	c,.mok
		xor	a
		ld	[hl],a
.mok:		ld	hl,wRandomBlock
		ld	d,h
		ld	e,l
		add	l
		ld	l,a
		ld	a,[wRandTake]
		sub	31
		jr	nc,.aok
		add	55
.aok:		add	e
		ld	e,a
		ld	a,[de]
		xor	[hl]
		ld	[hl],a
		pop	de
		pop	hl
		xor	$DA
		ret





addahl::	add	l
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ret


bank_link::	ldh	a,[hRomBank]
		push	af
		ld	a,[wShellVect+3]
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,[wShellAcc]
		call	wShellVect
		ld	[wShellVect+3],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,[wShellVect+3]
		ret

; ***************************************************************************
; * FetchPinInfo                                                            *
; ***************************************************************************
; * Inputs:     HL = tile #                                                 *
; *             E  = 6 bit offset into tile (y*8+x)                         *
; * Outputs:    A  = Byte                                                   *
; * Preserves:  BC,E                                                        *
; ***************************************************************************

FetchPinInfo::
		ldh	a,[hRomBank]
		push	af

		ld	a,h
		add	BANK(PinTiles)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	d,$40
		add	hl,de
		ld	d,[hl]

		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,d
		ret



checkpagecrossings:
		ld	a,HIGH(wShellLastVariable)
		cp	$c6
		jr	nc,.die
		ret
.die:		jr	.die

;****************************************************************************
;* BBRAMInit                                                                *
;****************************************************************************
;* Deal with setting up BBRAM to some known state                           *
;****************************************************************************
;* INPUTS:  None                                                            *
;* OUTPUTS: None                                                            *
;****************************************************************************

BBRAMZap::
		ld	a,[bLanguage]
		cp	5
		jr	nc,bbramcorrupt
		push	af
		call	bbramcorrupt
		pop	af
		ld	[bLanguage],a
		xor	$da
		ld	[bLanguageHash],a
		ret
BBRAMInit::
		ld	hl,bKey
		ld	de,bbramkey
		ld	c,8
.cmp:		ld	a,[de]
		cp	[hl]
		jr	nz,bbramcorrupt
		inc	de
		inc	hl
		dec	c
		jr	nz,.cmp
		ret
bbramcorrupt:
		ld	d,0
		ld	a,[bLanguage]
		cp	5
		jr	nc,.dok
		ld	e,a
		ld	a,[bLanguageHash]
		xor	$DA
		cp	e
		jr	nz,.dok
		ld	d,e
.dok:		ld	hl,$a000
		ld	bc,$2000
		call	MemClear
		xor	a
		ld	[bLanguage],a
		ld	[bLanguageHash],a
		ld	hl,bbramkey
		ld	de,bKey
		ld	bc,8
		jp	MemCopy
bbramkey:	db	"DAVE"
		db	$dd,$ca,$ba,$aa



; ***************************************************************************
; * RandInit                                                                *
; ***************************************************************************
; * Sets up the random # generator table + pointer                          *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

RandInit::	ld	hl,randomtable
		ld	de,wRandomBlock
		ld	bc,55
		call	MemCopy
		ld	a,5-1
		ld	[wRandTake],a
		ret

randomtable:	DB	$42,$BE,$D6,$E7,$05,$54,$22,$79
		DB	$68,$D4,$27,$1D,$F4,$35,$00,$20
		DB	$ED,$2A,$60,$4C,$A4,$1D,$2A,$64
		DB	$55,$DA,$40,$18,$14,$6C,$8C,$29
		DB	$69,$5B,$DB,$CF,$C3,$7E,$8C,$15
		DB	$F0,$5B,$FD,$A3,$19,$76,$8B,$2F
		DB	$D2,$1C,$37,$74,$0B,$F9,$FC
