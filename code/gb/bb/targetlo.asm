; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** TARGETLO.ASM                                                   MODULE **
; **                                                                       **
; ** LeFou's Target Range.                                                 **
; **                                                                       **
; ** Last modified : 02 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"targetlo",HOME
		section 0

;
;
;

BGPKG_CHR	EQU	0
BGPKG_MAP	EQU	1
BGPKG_RGB	EQU	2

;
;
;

PAL_TGTCURSOR::	DW	$0000,$7FFF,$001F,$0000

;
;
;



; ***************************************************************************
; * ClrWorkspace ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ClrWorkspace::	LD	HL,wTemp512		;Clear the game's workspace.
		LD	BC,$0200		;
		CALL	MemClear		;
		LD	HL,hTemp48		;
		LD	BC,$0030		;
		JP	MemClear		;



; ***************************************************************************
; * CgbXferScreen ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the screen's PKG file in the filesys          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbXferScreen::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		CALL	FindInFileSys		;Locate PKG file.

		LD	HL,BGPKG_RGB		;Locate RGB data.
		CALL	FindInPkgFile		;

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	DE,wBcpArcade		;Setup court RGB data.
		LD	BC,64			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		LD	BC,$000A		;Read the length of the
		ADD	HL,BC			;CHR data.
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;

		SRL	B			;Divide by 16 to get the
		RRA				;number of characters.
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		LD	C,A			;
		LD	[wChrUsedLo],A		;
		LD	A,B			;
		LD	[wChrUsedHi],A		;

		LD	HL,BGPKG_MAP		;Locate MAP/ATR data.
		CALL	FindInPkgFile		;

		LD	DE,wTmpMap		;Decompress MAP/ATR data.
		CALL	SwdDecode		;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LD	HL,wTmpMap+17		;Copy ATR data to vram.
		LD	DE,$9800		;
		CALL	CgbDumpBG		;

		LD	A,0			;Page in MAP video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LD	HL,wTmpMap+16		;Copy MAP data to vram.
		LD	DE,$9800		;
		CALL	CgbDumpBG		;

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		CALL	DumpSwdChr		;Decompress CHR data.

;		LD	HL,PanelChrset		;Copy panel character set
;		LD	DE,$8D80		;$D8-$FF to vram.
;		LD	C,$28			;
;		CALL	DumpChrs		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * GmbXferScreen ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the screen's PKG file in the filesys          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GmbXferScreen::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		CALL	FindInFileSys		;Locate PKG file.

		LD	A,%11100100		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		LD	BC,$000A		;Read the length of the
		ADD	HL,BC			;CHR data.
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;

		SRL	B			;Divide by 16 to get the
		RRA				;number of characters.
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		LD	C,A			;

		LD	HL,BGPKG_MAP		;Locate MAP data.
		CALL	FindInPkgFile		;

		LD	DE,wTmpMap		;Decompress MAP data.
		CALL	SwdDecode		;

		LD	HL,wTmpMap+16		;Copy MAP data to vram.
		LD	DE,$9800		;
;		CALL	GmbDumpBG		;

		CALL	CgbDumpBG		;Use CGB map for now.

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		CALL	DumpSwdChr		;Decompress CHR data.

;		LD	HL,PanelChrset		;Copy panel character set
;		LD	DE,$8D80		;$D8-$FF to vram.
;		LD	C,$28			;
;		CALL	DumpChrs		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * CgbDumpBG ()                                                            *
; ***************************************************************************
; * Dump odd/even half of a 20x18x2 map to the screen                       *
; ***************************************************************************
; * Inputs      HL   = Ptr to 20x18x2 src data                              *
; *             DE   = Ptr to 32x32x1 dst vram                              *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at DE doesn't wrap.                 *
; ***************************************************************************

CgbDumpBG::	LD	B,18			;Dump 18 lines.

.Line:		PUSH	BC			;Preserve line count.

		LD	BC,$0304		;Dump 4 lots of 5 columns.

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

		LD	A,[HLI]			;Transfer 5 bytes of
		LD	[DE],A			;screen data.
		INC	E			;
		INC	HL			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		INC	HL			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		INC	HL			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		INC	HL			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		INC	HL			;

		EI				;Enable interrupts.

		DEC	C			;Do the next 5 columns.
		JR	NZ,.Hold		;

		LD	A,32-20			;Move the destination ptr
		ADD	E			;passed the border.
		LD	E,A			;
		JR	NC,.Skip		;
		INC	D			;

.Skip:		POP	BC			;Restore line count.

		DEC	B			;Do the next line.
		JR	NZ,.Line		;

		RET				;All Done.



; ***************************************************************************
; * GmbDumpBG ()                                                            *
; ***************************************************************************
; * Dump a 20x18x1 map to the screen                                        *
; ***************************************************************************
; * Inputs      HL   = Ptr to 20x18x1 src data                              *
; *             DE   = Ptr to 32x32x1 dst vram                              *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at DE doesn't wrap.                 *
; ***************************************************************************

GmbDumpBG::	LD	B,18			;Dump 18 lines.

.Line:		PUSH	BC			;Preserve line count.

		LD	BC,$0304		;Dump 4 lots of 5 columns.

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

		LD	A,[HLI]			;Transfer 5 bytes of
		LD	[DE],A			;screen data.
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;

		EI				;Enable interrupts.

		DEC	C			;Do the next 5 columns.
		JR	NZ,.Hold		;

		LD	A,32-20			;Move the destination ptr
		ADD	E			;passed the border.
		LD	E,A			;
		JR	NC,.Skip		;
		INC	D			;

.Skip:		POP	BC			;Restore line count.

		DEC	B			;Do the next line.
		JR	NZ,.Line		;

		RET				;All Done.



; ***************************************************************************
; * GetCursorGfx ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the screen's PKG file in the filesys          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetCursorGfx::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		PUSH	DE			;Preserve VRAM destination.

		CALL	FindInFileSys		;Locate PKG file.

		LD	HL,0			;Locate CHR data.
		CALL	FindInPkgFile		;

		LD	DE,wTmpChr		;Decompress CHR data.
		CALL	SwdDecode		;

		LD	HL,65535&(0-wTmpChr)	;Calc size of decompressed
		ADD	HL,DE			;data in bytes.
		LD	C,L			;
		LD	B,H			;

		SRL	B			;Calc size of decompressed
		RR	C			;data in chrs.
		SRL	B			;
		RR	C			;
		SRL	B			;
		RR	C			;
		SRL	B			;
		RR	C			;

		POP	DE			;Restore VRAM destination.

		LD	HL,wTmpChr		;
		CALL	DumpChrs		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * GetTargetGfx ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the screen's PKG file in the filesys          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetTargetGfx::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		CALL	FindInFileSys		;Locate PKG file.

		LD	HL,BGPKG_MAP		;Locate MAP/ATR data.
		CALL	FindInPkgFile		;

		LD	DE,wTmpChr		;Decompress MAP/ATR data.
		CALL	SwdDecode		;

		LD	HL,wTmpChr		;Reorder the map into
		LD	DE,wTmpMap		;individual 4x3 frames.
		CALL	ReorderTargets		;

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		PUSH	HL

		LD	BC,$000A		;Read the length of the
		ADD	HL,BC			;CHR data.
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;

		SRL	B			;Divide by 16 to get the
		RRA				;number of characters.
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		LD	C,A			;
		LD	[wChrUsedLo],A		;
		LD	A,B			;
		LD	[wChrUsedHi],A		;

		POP	HL			;Decompress CHR data.
		LD	DE,wTmpChr		;
		CALL	SwdDecode		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * ReorderTargets ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to src map                                       *
; *             DE   = Ptr to dst map                                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        This is a stub to call the real function in another bank.   *
; ***************************************************************************

ReorderTargets::LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		LD	A,BANK(ReorderTargets_B);Bank in the routine.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		PUSH	HL			;
		LD	L,E			;
		LD	H,D			;

		CALL	ReadNullTarget_B	;

		LD	E,L			;
		LD	D,H			;
		POP	HL			;

		CALL	ReorderTargets_B	;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * DumpSwdChr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to file                                          *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpSwdChr::	LD	A,$90			;Initialize destination.
		LDH	[hTmpLo],A		;

		PUSH	HL			;Preserve ptr to file.

		LD	BC,$000A		;Locate total file length.
		ADD	HL,BC			;

		LD	A,[HLI]			;Calculate number of 2KB
		LD	D,A			;chunks in the file.
		LD	A,[HLI]			;
		ADD	$FF			;
		LD	A,D			;
		ADC	$07			;
		SRL	A			;
		SRL	A			;
		SRL	A			;
		RET	Z			;

DumpSwdChrLoop::LDH	[hTmpHi],A		;Preserve chunk count.

		INC	HL			;Get offset to chunk of
		LD	A,[HLI]			;compressed character data.
		LD	E,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		SRL	E			;
		RR	B			;
		RRA				;
		SRL	E			;
		RR	B			;
		RRA				;
		SRL	E			;
		RR	B			;
		RRA				;
		SRL	E			;
		RR	B			;
		RRA				;
		LD	C,A			;

		LD	E,L			;
		LD	D,H			;

		POP	HL			;Get address of chunk of
		PUSH	HL			;compressed character data.
		PUSH	DE			;
		ADD	HL,BC			;

		LD	DE,$D800		;Decompress the chunk of
		CALL	SwdDecode		;character data.

		LD	HL,65535&(0-$D800)	;Find out how many characters
		ADD	HL,DE			;were decompressed.
		LD	A,L			;
		SRL	H			;
		RRA				;
		SRL	H			;
		RRA				;
		SRL	H			;
		RRA				;
		SRL	H			;
		RRA				;
		LD	C,A			;

		LD	A,[hMachine]		;Color Gameboy ?
		CP	MACHINE_CGB		;
		JR	NZ,DumpSwdChrXfer	;

		LDH	A,[hTmpLo]		;Select vram bank.
		RRCA				;
		AND	$01			;
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

DumpSwdChrXfer::LD	HL,$D800		;Copy character data to
		LDH	A,[hTmpLo]		;vram.
		AND	$F8			;
		LD	D,A			;
		LD	E,0			;
		CALL	DumpChrs		;

		POP	HL			;

		LDH	A,[hTmpLo]		;
		XOR	$18			;
		INC	A			;
		LDH	[hTmpLo],A		;

		LDH	A,[hTmpHi]		;Any more chunks to dump
		DEC	A			;to vram ?
		JR	NZ,DumpSwdChrLoop	;

		POP	HL			;Remove ptr to file.

		RET				;All done.



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

		LD	[wFontPalXor],A		;*** SAFETY MEASURE ***

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
		LD	A,HIGH(wOamBuffer)	;
		LDH	[hOamBufHi],A		;

		LD	A,LOW(DoNothing)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DoNothing)	;
		LD	[wJmpDraw+2],A		;

		LD	A,WRKBANK_NRM		;Page in normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * DoVblTarget ()                                                          *
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

DoVblTarget::	LD	A,BANK(TargetRange)	;Bank in the routine.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	DumpPanelScr		;Update status panel.

		CALL	DumpTargetScr		;Update 3 targets a frame
		CALL	DumpTargetScr		;at a maximum.
		CALL	DumpTargetScr		;

		RET				;



; ***************************************************************************
; * DumpTgtSpr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpTgtSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,[wFigPhase]		;Calc next character number.
		XOR	62			;
		LD	[wFigPhase],A		;
		LDH	[hSprNxt],A		;
		ADD	62			;
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

		LD	SP,wTgtStar		;
		CALL	SprDump			;
		LD	SP,wTgtLeFou0		;
		CALL	SprDump			;
		LD	SP,wTgtLeFou1		;
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
; * DrawTgtSpr ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawTgtSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LDH	A,[hOamPointer]		;Locate OAM shadow buffer.
		LD	D,A			;
		LD	E,0			;

		CALL	DrawTgtCursor		;
		LD	SP,wTgtStar		;
		CALL	SprDraw			;
		LD	SP,wTgtLeFou0		;
		CALL	SprDraw			;
		LD	SP,wTgtLeFou1		;
		CALL	SprDraw			;

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
; * ProcSprite ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcSprite::	LDHL	SP,SPR_FLAGS+2		;
		BIT	FLG_EXEC,[HL]		;
		RET	Z			;
		LDHL	SP,SPR_EXEC+2		;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		JP	[HL]			;



; ***************************************************************************
; * SetSpriteFnc ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+4 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

SetSpriteFnc::	LDHL	SP,SPR_EXEC+4		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * IncSpriteAnm ()                                                         *
; * SetSpriteAnm ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      SP+4 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

IncSpriteAnm::	LDHL	SP,SPR_ANM_DLY+4	;Frame delay finished ?
		DEC	[HL]			;
		RET	NZ			;

		LDHL	SP,SPR_ANM_PTR+4	;Get animation pointer.
		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

SetSpriteAnm::	LDHL	SP,SPR_ANM_FRM+4	;Read next frame offset.
		LD	A,[DE]			;
		INC	DE			;
		LD	[HL],A			;

		LDHL	SP,SPR_ANM_DLY+4	;Read next frame delay.
		LD	A,[DE]			;
		INC	DE			;
		LD	[HL],A			;

		LDHL	SP,SPR_FLAGS+4		;Signal new frame and still
		SET	FLG_ANM,[HL]		;animating.
		SET	FLG_NEW,[HL]		;

		OR	A			;Or has the animation
		JR	NZ,.Skip		;finished ?

		RES	FLG_ANM,[HL]		;

.Skip:		LDHL	SP,SPR_ANM_PTR+4	;Put animation pointer.
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_ANM_FRM+4	;Calc new frame number
		LD	A,[HL]			;from the base and offset.
		LD	E,A			;
		LD	D,0			;
		OR	A			;
		JR	Z,.Skip0		;

		DEC	E			;

		LDHL	SP,SPR_ANM_1ST+4	;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

.Skip0:		LDHL	SP,SPR_FRAME+4		;Save new frame number.
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		RET				;All Done.



; ***************************************************************************
; * CgbSprPalette ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the palette's RGB file in the filesys         *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CgbSprPalette::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		CALL	FindInFileSys		;Locate RGB file.

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	DE,wOcpArcade		;Setup sprite RGB data.
		LD	BC,64			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * ResSpritePal ()                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ResSpritePal::	XOR	A			;
		LD	[wPalCount],A		;

		RET				;All Done.



; ***************************************************************************
; * AddSpritePal ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the palette's RGB data in AllPalettes         *
; *                                                                         *
; * Outputs     A    = Palette number                                       *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

AddSpritePal::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		LD	A,0			;
		RET	NZ			;

		LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(AllPalettes)	;Page in AllPalettes data.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	A,[wPalCount]		;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LD	DE,wOcpArcade		;
		ADD	E			;
		LD	E,A			;
		LD	BC,8			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,[wPalCount]		;Increment palette count.
		INC	A			;
		LD	[wPalCount],A		;
		DEC	A			;

		RET				;All Done.



; ***************************************************************************
; * DisplayStage ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the GMB screen's PKG file in the filesys      *
; *             DE   = Idx of the CGB screen's PKG file in the filesys      *
; *                                                                         *
; *             Also uses wSubStage variable                                *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0

DisplayStage::	LDH	A,[hMachine]		;Select which PKG to use.
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	L,E			;
		LD	H,D			;
.Skip0:		PUSH	HL			;

		CALL	SetMachineJcb		;Reset machine to known state.

		CALL	InitIntro		;Init intro systems.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;

.Skip1:		POP	HL			;Setup background.

		LD	A,[wSubGaston]		;
		OR	A			;
		LD	A,4+1			;
		JR	NZ,.Skip2		;
		LD	A,[wSubLevel]		;
		CP	3			;
		LD	A,3+1			;
		JR	NC,.Skip2		;
		LD	A,[wSubStage]		;
		INC	A			;
.Skip2:		CALL	XferFullScreen		;

		LD	HL,TargetStgICmd	;
		JP	ProcIntroSeq		;

TargetStgICmd::	DB	ICMD_SPRON
		DW	wSprite0
		DB	140,123
		DW	DoButtonIcon
		DB	ICMD_FADEUPSCR
		DB	ICMD_HALT
		DB	ICMD_END

		ENDC



; ***************************************************************************
; * XferFullScreen ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the screen's PKG file in the filesys          *
; *             A    = Map number within PKG's map file (1=first)           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0

XferFullScreen::PUSH	AF			;Preserve map number.

		LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		CALL	FindInFileSys		;Locate PKG file.

		LD	A,%11010010		;Initialize PAL data.
		LD	[wFadeVblBGP],A		;
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		LDH	A,[hMachine]		;Running on the CGB ?
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	HL,BGPKG_RGB		;Locate RGB data.
		CALL	FindInPkgFile		;

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	DE,wBcpArcade		;Setup court RGB data.
		LD	BC,64			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

.Skip0:		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		PUSH	HL			;Preserve ptr.

		LD	BC,$000A		;Read the length of the
		ADD	HL,BC			;CHR data.
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;

		SRL	B			;Divide by 16 to get the
		RRA				;number of characters.
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		SRL	B			;
		RRA				;
		LD	C,A			;
		LD	[wChrUsedLo],A		;
		LD	A,B			;
		LD	[wChrUsedHi],A		;

		POP	HL			;Restore ptr.

		LD	HL,BGPKG_CHR		;Locate CHR data.
		CALL	FindInPkgFile		;

		CALL	DumpSwdChr		;Decompress CHR data.

		LD	HL,BGPKG_MAP		;Locate MAP/ATR data.
		CALL	FindInPkgFile		;

		LD	DE,wTmpMap		;Decompress MAP/ATR data.
		CALL	SwdDecode		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		POP	AF			;Restore map number.

		JP	ShowFullScreen		;Now dump the map.

		ENDC



; ***************************************************************************
; * ShowFullScreen ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A    = Map number within PKG's map file (1=first)           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		IF	0

ShowFullScreen::PUSH	AF			;Preserve map number.

		LDH	A,[hMachine]		;Running on the CGB ?
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LDHL	SP,1			;Copy ATR data to vram.
		LD	A,[HL]			;
		CALL	FindMapInMem		;
		INC	HL			;
		LD	DE,$9800		;
		CALL	CgbDumpBG		;

		LD	A,0			;Page in MAP video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

.Skip0:		LDHL	SP,1			;Copy MAP data to vram.
		LD	A,[HL]			;
		CALL	FindMapInMem		;
		LD	DE,$9800		;
		CALL	CgbDumpBG		;

		POP	AF			;Restore map number.

		RET				;All Done.

;
;
;

FindMapInMem::	LD	L,A			;Find offset.
		LD	H,0			;
		LD	BC,wTmpMap		;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,BC			;

		LD	A,[HLI]			;Read offset.
		LD	H,[HL]			;
		LD	L,A			;
		ADD	HL,BC			;

		LD	BC,6			;Skip header.
		ADD	HL,BC			;
		RET				;

		ENDC



; ***************************************************************************
; * DisplayStage ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the GMB screen's PKG file in the filesys      *
; *             DE   = Idx of the CGB screen's PKG file in the filesys      *
; *                                                                         *
; *             Also uses wSubStage variable                                *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DisplayStage::	LD	HL,hTemp48		;
		LD	DE,wSaveTemp48		;
		LD	BC,$0030		;
		CALL	MemCopy			;

		LD	A,[wSubGaston]		;
		OR	A			;
		LD	A,4+1			;
		JR	NZ,.Skip0		;
		LD	A,[wSubLevel]		;
		CP	3			;
		LD	A,3+1			;
		JR	NC,.Skip0		;
		LD	A,[wSubStage]		;
		INC	A			;
.Skip0:		DEC	A			;

DisplayStageN::	LD	HL,.Table		;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	TalkingHeads		;

		LD	HL,wSaveTemp48		;
		LD	DE,hTemp48		;
		LD	BC,$0030		;
		JP	MemCopy			;

.Table:		DW	TargetStg1ICmd
		DW	TargetStg2ICmd
		DW	TargetStg3ICmd
		DW	TargetStg4ICmd
		DW	TargetStg5ICmd



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF TARGETLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

