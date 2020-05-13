; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** BITMAPLO.ASM                                                   MODULE **
; **                                                                       **
; ** Bitmapped Font Functions.                                             **
; **                                                                       **
; ** Last modified : 24 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

;		SECTION	"bitmaplo",HOME
		section 0
;
;
;

TblOffset0120::	DW	$0120*0
		DW	$0120*1
		DW	$0120*2
		DW	$0120*3
		DW	$0120*4
		DW	$0120*5
		DW	$0120*6
		DW	$0120*7
		DW	$0120*8
		DW	$0120*9
		DW	$0120*10
		DW	$0120*11
		DW	$0120*12
		DW	$0120*13
		DW	$0120*14
		DW	$0120*15
		DW	$0120*16
		DW	$0120*17
		DW	$0120*18
		DW	$0120*19
		DW	$0120*20

TblOffset0140::	DW	$0140*0
		DW	$0140*1
		DW	$0140*2
		DW	$0140*3
		DW	$0140*4
		DW	$0140*5
		DW	$0140*6
		DW	$0140*7
		DW	$0140*8
		DW	$0140*9
		DW	$0140*10
		DW	$0140*11
		DW	$0140*12
		DW	$0140*13
		DW	$0140*14
		DW	$0140*15
		DW	$0140*16
		DW	$0140*17
		DW	$0140*18
		DW	$0140*19
		DW	$0140*20

;
;
;

BlankChr3::	DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

BlankTop::	DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		DB	$00,$00,$00,$00,$FF,$FF,$FF,$FF

BlankBtm::	DB	$FF,$FF,$FF,$FF,$00,$00,$00,$00
		DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;
;
;

; ***************************************************************************
; * XferBitmap ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Idx of the GMB screen's PKG file in the filesys      *
; *             DE   = Idx of the CGB screen's PKG file in the filesys      *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

XferBitmap::	LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		LD	A,%11010010		;Initialize GMB palettes
		LD	[wFadeVblBGP],A		;for a bitmap screen.
		LD	[wFadeLycBGP],A		;
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		LDH	A,[hMachine]		;Select which PKG to use.
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	L,E			;
		LD	H,D			;

.Skip0:		CALL	FindInFileSys		;Locate PKG file.

		LDH	A,[hMachine]		;Running on the CGB ?
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;

		LD	A,WRKBANK_PAL		;Page in work ram for
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

		LD	HL,1			;Locate ATR data.
		CALL	FindInPkgFile		;

		LD	DE,wAtrDecode		;Decompress attribute data.
		CALL	SwdDecode		;

		CALL	ReorderAtrMap		;Reorder it.

		LD	HL,2			;Locate RGB data.
		CALL	FindInPkgFile		;

		LD	DE,wBcpArcade		;Setup court RGB data.
		LD	BC,64			;
		CALL	MemCopy			;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

.Skip1:		LD	HL,0			;Locate bitmap data.
		CALL	FindInPkgFile		;

		LD	DE,$C800		;Decompress bitmap data.
		CALL	SwdDecode		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.

;
;
;

ReorderAtrMap::	LD	HL,wAtrDecode		;
		LD	DE,wAtrShadow		;
		LD	B,20			;
.Loop0:		LD	C,18			;
		PUSH	DE			;
.Loop1:		LD	A,[HLI]			;
		LD	[DE],A			;
		LD	A,E			;
		ADD	32			;
		LD	E,A			;
		JR	NC,.Skip0		;
		INC	D			;
.Skip0:		DEC	C			;
		JR	NZ,.Loop1		;
		POP	DE			;
		INC	DE			;
		DEC	B			;
		JR	NZ,.Loop0		;
		RET				;



; ***************************************************************************
; * EraseBitmap ()                                                          *
; ***************************************************************************
; * Clear the shadow bitmap workspace                                       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

EraseBitmap::	LD	HL,$C800		;
		LD	BC,$1800		;
		JP	MemClear		;



; ***************************************************************************
; * SetBitmap20x18 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SetBitmap20x18::CALL	SetMachineJcb		;Reset machine to known state.

		LD	HL,$9800		;Clear screen data.
		LD	A,$00			;
		CALL	ClrScr32x32		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	HL,$9800		;Clear screen attr.
		LD	A,$00			;
		CALL	ClrAtr32x32		;

		CALL	InitShadowAtr		;Clear shadow attr.

.Skip0:		LD	HL,$9800		;Initialize screen for a
		CALL	SetMap20x18		;20x18 bitmap.

		LD	A,%11110111		;Bgd_chr8000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
		LD	A,%11100111		;Wnd_scr9C00,Wnd_on, then
		LDH	[hLycLCDC],A		;Bgd_chr9000,Obj_on.

		LD	A,LOW(LycNormal)		;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblNormal)		;
		LD	[wVblVector],A		;

		LD	A,70			;Enable LYC interrupt.
		LDIO	[rLYC],A		;

		XOR	A			;Use 20x18 font routines.
		LD	[wFontFlg],A		;

		RET				;



; ***************************************************************************
; * DmaBitmap20x18 ()                                                       *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DmaBitmap20x18::LD	HL,$C800		;
		LD	DE,$8000+((384-360)*16)	;

		LD	B,20			;Number of columns.

.Loop:		PUSH	BC			;

		PUSH	HL			;
		PUSH	DE			;

		LD	C,18			;Dump a single column.
		CALL	DmaBitmapCol20		;

		POP	HL			;

		LD	BC,$0010		;Move onto next dst column.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;

		LD	BC,$0120		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;

		DEC	B			;Next column in screen.
		JR	NZ,.Loop		;

		RET				;All Done.



; ***************************************************************************
; * DmaBitmapCol20 ()                                                       *
; ***************************************************************************
; * Dump a 1x18 column of bitmap data to display ram                        *
; ***************************************************************************
; * Inputs      HL = src address in workspace ram                           *
; *             DE = dst address in display ram                             *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DmaBitmapCol20::CALL	wChrXfer		;Dump a single chr.

		LD	A,E			;Move onto next line in
		ADD	255&((20-1)*16)		;the column.
		LD	E,A			;
		LD	A,D			;
		ADC	((20-1)*16)>>8		;
		LD	D,A			;

		DEC	C			;Loop until done.
		JR	NZ,DmaBitmapCol20	;

		RET				;All Done.



; ***************************************************************************
; * DmaBitbox20x18 ()                                                       *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      B    = X (0..31)                                            *
; *             C    = Y (0..31)                                            *
; *             D    = W (0..31)                                            *
; *             E    = H (0..31)                                            *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DmaBitbox20x18::PUSH	DE			;Preserve width and height.

		PUSH	BC			;Preserve position.

		LD	HL,TblOffset0140	;Calc dst offset as
		LD	A,C			;(X*$0010)+(Y*$0140)
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,B			;
		SWAP	A			;
		AND	$F0			;
		LD	C,A			;
		LD	A,B			;
		SWAP	A			;
		AND	$0F			;
		LD	B,A			;
		ADD	HL,BC			;

		LD	BC,$8000+((384-360)*16)	;Add starting addr of dst.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	BC			;Restore position.

		LD	HL,TblOffset0120	;Calc src offset as
		LD	A,B			;(X*$0120)+(Y*$0010)
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,C			;
		SWAP	A			;
		AND	$0F			;
		LD	B,A			;
		LD	A,C			;
		SWAP	A			;
		AND	$F0			;
		LD	C,A			;
		ADD	HL,BC			;

		LD	BC,$C800		;Add starting addr of src.
		ADD	HL,BC			;

		POP	BC			;Restore width and height.

.Loop0:		PUSH	BC			;Preserve width and height.

		PUSH	HL			;Preserve src ptr.
		PUSH	DE			;Preserve dst ptr.

.Loop1:		CALL	wChrXfer		;Dump a single chr.

		LD	A,E			;Next dst in column.
		ADD	255&((20-1)*16)		;
		LD	E,A			;
		LD	A,D			;
		ADC	((20-1)*16)>>8		;
		LD	D,A			;

		DEC	C			;Next chr in column.
		JR	NZ,.Loop1		;

		POP	HL			;Restore dst ptr.

		LD	BC,$0010		;Move onto next dst column.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;Restore src ptr.

		LD	BC,$0120		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;Restore width and height.

		DEC	B			;Next column in box.
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * SetMap20x18 ()                                                          *
; ***************************************************************************
; * Setup a 32x32 screen map for a 20x18 bitmap                             *
; ***************************************************************************
; * Inputs      HL   = Ptr to 1KB screen ($9800 or $9C00)                   *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at HL doesn't wrap.                 *
; ***************************************************************************

SetMap20x18::	LD	B,24			;
		LD	C,1			;
		LD	D,18			;

.Loop:		PUSH	DE			;Preserve state.
		PUSH	HL			;

		CALL	SetScreenRow		;Dump a single column.

		DEC	B			;

		POP	HL			;Restore state.

		LD	DE,32			;
		ADD	HL,DE			;

		POP	DE			;

		DEC	D			;Do the next column.
		JR	NZ,.Loop		;

		RET				;All Done.



; ***************************************************************************
; * SetScreenRow ()                                                         *
; ***************************************************************************
; * Setup a 21x1 screen row for a bitmap                                    *
; ***************************************************************************
; * Inputs      HL   = Ptr to 1KB screen ($9800 or $9C00)                   *
; *             B    = Character number                                     *
; *             C    = Character number delta                               *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at HL doesn't wrap.                 *
; ***************************************************************************

SetScreenRow::	CALL	.Hold			;
		CALL	.Hold			;

.Hold:		LDIO	A,[rLY]			;Don't start the transfer
		DEC	A			;during vblank.
		CP	142			;
		JR	NC,.Hold		;

		DI				;Disable interrupts.

.Sync:		LDIO	A,[rSTAT]		;Wait until the current
		AND	%11			;HBL is finished.
		JR	Z,.Sync			;

.Wait:		LDIO	A,[rSTAT]		;Wait for the next HBL.
		AND	%11			;
		JR	NZ,.Wait		;

		LD	A,B			;

		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;
		LD	[HLI],A			;
		ADD	C			;

		LD	B,A			;

		EI				;Enable interrupts.

		RET				;All Done.



; ***************************************************************************
; * SloBitmap20x18 ()                                                       *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SloBitmap20x18::LD	HL,$C800		;
		LD	DE,$8000+((384-360)*16)	;

		LD	BC,wAtrShadow		;

.Loop0:		CALL	WaitForVBL		;

		LD	A,B			;Trigger the attribute
		LDH	[hIntroBlit+3],A	;dump.
		LD	A,C			;
		LDH	[hIntroBlit+2],A	;
		LD	A,$13			;
		LDH	[hIntroBlit+1],A	;
		LD	A,$02			;
		LDH	[hIntroBlit+0],A	;

.Loop1:		PUSH	BC			;

		PUSH	HL			;
		PUSH	DE			;

		LD	C,18			;Dump a single column.
		CALL	DmaBitmapCol20		;

		POP	HL			;

		LD	BC,$0010		;Move onto next dst column.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;

		LD	BC,$0120		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;

		INC	C			;Next column in screen.

		LD	A,20			;All Done ?
		CP	C			;
		JP	Z,WaitForVBL		;

		BIT	0,C			;
		JR	NZ,.Loop1		;

		JR	.Loop0			;



; ***************************************************************************
; * CgbAttrVbl ()                                                           *
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

CgbAttrVbl::	LD	HL,hIntroBlit		;Copy an YX rectangle.
		LD	A,[HL]			;
		OR	A			;
		RET	Z			;
		LD	B,A			;
		XOR	A			;
		LD	[HLI],A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,WRKBANK_PAL		;
		LDIO	[rSVBK],A		;
		LD	A,1			;
		LDIO	[rVBK],A		;
		CALL	BlitVideoYX		;
		LD	A,0			;
		LDIO	[rVBK],A		;
		RET				;



; ***************************************************************************
; * ClrAtr32x32 ()                                                          *
; * ClrScr32x32 ()                                                          *
; ***************************************************************************
; * Clear a 32x32 screen map to a single byte value                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to 1KB screen ($9800 or $9C00)                   *
; *             A    = Byte to write to screen                              *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at HL doesn't wrap.                 *
; ***************************************************************************

ClrAtr32x32::	PUSH	AF			;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		POP	AF			;

		CALL	ClrScr32x32		;

		LD	A,0			;Page in CHR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		RET				;All Done.

ClrScr32x32::	LD	C,A			;

		LD	B,%11			;

		CALL	.Quad			;
		CALL	.Quad			;
		CALL	.Quad			;
		CALL	.Quad			;

		CALL	.Quad			;
		CALL	.Quad			;
		CALL	.Quad			;

.Quad:		CALL	.Line			;
		CALL	.Line			;
		CALL	.Line			;

.Line:		CALL	.Hold			;

.Hold:		LDIO	A,[rLY]			;Don't start the transfer
		DEC	A			;during vblank.
		CP	142			;
		JR	NC,.Hold		;

		DI				;Disable interrupts.

.Sync:		LDIO	A,[rSTAT]		;Wait until the current
		AND	B			;HBL is finished.
		JR	Z,.Sync			;

.Wait:		LDIO	A,[rSTAT]		;Wait for the next HBL.
		AND	B			;
		JR	NZ,.Wait		;

		LD	A,C			;

		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;

		EI				;Enable interrupts.

		RET				;



; ***************************************************************************
; * PxlBox2ChrBox ()                                                        *
; ***************************************************************************
; * Convert XYWH bounding box from pixel to character coordinates           *
; ***************************************************************************
; * Inputs      B    = X (0..255)                                           *
; *             C    = Y (0..255)                                           *
; *             D    = W (0..255)                                           *
; *             E    = H (0..255)                                           *
; *                                                                         *
; * Outputs     B    = X (0..31)                                            *
; *             C    = Y (0..31)                                            *
; *             D    = W (0..31)                                            *
; *             E    = H (0..31)                                            *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PxlBox2ChrBox::	LD	A,D			;Calc XR pxl.
		ADD	B			;
		DEC	A			;
		LD	D,A			;

		LD	A,E			;Calc YB pxl.
		ADD	C			;
		DEC	A			;
		LD	E,A			;

		LD	A,B			;Calc XL chr.
		RRCA				;
		RRCA				;
		RRCA				;
		AND	$1F			;
		LD	B,A			;

		LD	A,C			;Calc YT chr.
		RRCA				;
		RRCA				;
		RRCA				;
		AND	$1F			;
		LD	C,A			;

		LD	A,D			;Calc XW chr.
		RRCA				;
		RRCA				;
		RRCA				;
		SUB	B			;
		AND	$1F			;
		INC	A			;
		LD	D,A			;

		LD	A,E			;Calc YH chr.
		RRCA				;
		RRCA				;
		RRCA				;
		SUB	C			;
		AND	$1F			;
		INC	A			;
		LD	E,A			;

		RET				;All Done.



; ***************************************************************************
; * DumpShadowAtr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      DE = destination address (should be display RAM).           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpShadowAtr::	LDH	A,[hMachine]		;Only do this on a CGB.
		CP	MACHINE_CGB		;
		RET	NZ			;

		LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LD	HL,wAtrShadow		;
		LD	C,(32*32)/16		;
		CALL	DumpChrs		;

		LD	A,0			;Page in CHR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		POP	AF			;Restore the original ram
		LDH	[hWrkBank],A		;bank.
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * InitShadowAtr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitShadowAtr::	LDH	A,[hMachine]		;Only do this on a CGB.
		CP	MACHINE_CGB		;
		RET	NZ			;

		LD	BC,$0000		;
		LD	DE,$2020		;
		XOR	A			;
		JP	FillShadowAtr		;



; ***************************************************************************
; * FillShadowAtr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B    = X (0..31)                                            *
; *             C    = Y (0..31)                                            *
; *             D    = W (0..31)                                            *
; *             E    = H (0..31)                                            *
; *             A    = Fill value                                           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FillShadowAtr::	PUSH	AF			;Preserve fill value.

		LD	HL,CodeWriteAtr		;Calc write routine address
		LD	A,32			;from the box width.
		SUB	D			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,L			;
		LD	[wJmpTemporary+1],A	;
		LD	A,H			;
		LD	[wJmpTemporary+2],A	;

		LD	A,C			;Calc the destination scr
		SWAP	A			;address ($9800-$9BFF)
		RLCA				;and preserve it for later.
		LD	H,A			;
		AND	$E0			;
		LD	L,A			;
		LD	A,B			;
		AND	$1F			;
		OR	L			;
		LD	L,A			;
		LD	A,H			;
		AND	$03			;
		OR	HIGH(wAtrShadow)	;
		LD	H,A			;

		LD	BC,32			;

		POP	AF			;Restore fill value.
		LD	D,A			;

		LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,D			;Restore fill value.

.Loop0:		PUSH	HL			;Preserve shadow ptr.

		CALL	wJmpTemporary		;Write a row.

		POP	HL			;Restore shadow ptr.

		ADD	HL,BC			;Move onto next line.

.Skip1:		DEC	E			;Any more lines to write ?
		JR	NZ,.Loop0		;

		POP	AF			;Restore the original ram
		LDH	[hWrkBank],A		;bank.
		LDIO	[rSVBK],A		;

		RET				;All Done.

;
;
;

CodeWriteAtr::	REPT	32
		LD	[HLI],A
		ENDR
		RET



; ***************************************************************************
; * FillShadowLst ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to atr box list                                  *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

FillShadowLst::	LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		RET	NZ			;

.Loop:		LD	A,[HLI]			;
		BIT	7,A			;
		RET	NZ			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	D,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		PUSH	HL			;
		CALL	FillShadowAtr		;
		POP	HL			;
		JR	.Loop			;



; ***************************************************************************
; * SetBitmap21x14 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SetBitmap21x14::CALL	SetMachineJcb		;Reset machine to known state.

		LD	HL,$9800		;Clear screen data.
		LD	A,$00			;
		CALL	ClrScr32x32		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		LD	HL,$9800		;Clear screen attr.
		LD	A,$00			;
		CALL	ClrAtr32x32		;

		CALL	InitShadowAtr		;Clear shadow attr.

.Skip0:		LD	HL,$9800		;Initialize screen for a
		CALL	SetMap21x14		;21x14 bitmap.

		LD	HL,BlankChr3		;
		LD	DE,$8540		;
		CALL	wChrXfer		;
		LD	HL,BlankTop		;
		LD	DE,$8550		;
		CALL	wChrXfer		;
		LD	HL,BlankBtm		;
		LD	DE,$97E0		;
		CALL	wChrXfer		;
		LD	HL,BlankChr3		;
		LD	DE,$97F0		;
		CALL	wChrXfer		;

		LD	A,%11110111		;Bgd_chr8000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
		LD	A,%11100111		;Wnd_scr9C00,Wnd_on, then
		LDH	[hLycLCDC],A		;Bgd_chr9000,Obj_on.

		LD	A,LOW(LycNormal)	;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,HIGH(VblNormal)	;
		LD	[wVblVector],A		;

		LD	A,64			;Enable LYC interrupt.
		LDIO	[rLYC],A		;

		XOR	A			;Use 20x18 font routines.
		LD	[wFontFlg],A		;

		RET				;



; ***************************************************************************
; * DmaBitmap21x14 ()                                                       *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DmaBitmap21x14::LD	HL,$C800		;
		LD	DE,$8000+(86*16)	;

		LDH	A,[hScrYLo]		;
		AND	7			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;

		LD	B,21			;Number of columns.

.Loop:		PUSH	BC			;

		PUSH	HL			;
		PUSH	DE			;

		LD	C,14			;Dump a single column.
		CALL	DmaBitmapCol21		;

		POP	HL			;

		LD	BC,$0010		;Move onto next dst column.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;

		LD	BC,$00F0		;Move onto next src column
		ADD	HL,BC			;(actually 15 high).

		POP	BC			;

		DEC	B			;Next column in screen.
		JR	NZ,.Loop		;

		RET				;All Done.



; ***************************************************************************
; * DmaBitmapCol21 ()                                                       *
; ***************************************************************************
; * Dump a 1x15 column of bitmap data to display ram                        *
; ***************************************************************************
; * Inputs      HL = src address in workspace ram                           *
; *             DE = dst address in display ram                             *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DmaBitmapCol21::CALL	wChrXfer		;Dump a single chr.

		LD	A,E			;Move onto next line in
		ADD	255&((21-1)*16)		;the column.
		LD	E,A			;
		LD	A,D			;
		ADC	((21-1)*16)>>8		;
		LD	D,A			;

		DEC	C			;Loop until done.
		JR	NZ,DmaBitmapCol21	;

		RET				;All Done.



; ***************************************************************************
; * SetMap21x14 ()                                                          *
; ***************************************************************************
; * Setup a 32x32 screen map for a 21x15 bitmap                             *
; ***************************************************************************
; * Inputs      HL   = Ptr to 1KB screen ($9800 or $9C00)                   *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Assumes that the screen at HL doesn't wrap.                 *
; ***************************************************************************

SetMap21x14::	LD	B,84			;
		LD	C,0			;
		LD	D,1			;
		CALL	.Loop			;

		LD	B,85			;
		LD	C,0			;
		LD	D,1			;
		CALL	.Loop			;

		LD	B,86			;
		LD	C,1			;
		LD	D,14			;
		CALL	.Loop			;

		LD	B,126			;
		LD	C,0			;
		LD	D,1			;
		CALL	.Loop			;

		LD	B,127			;
		LD	C,0			;
		LD	D,1			;
;		CALL	.Loop			;

.Loop:		PUSH	DE			;Preserve state.
		PUSH	HL			;

		CALL	SetScreenRow		;Dump a single column.

		POP	HL			;Restore state.

		LD	DE,32			;
		ADD	HL,DE			;

		POP	DE			;

		DEC	D			;Do the next column.
		JR	NZ,.Loop		;

		RET				;All Done.



; ***************************************************************************
; * SloBitmap21x14 ()                                                       *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SloBitmap21x14::LD	HL,$C800		;
		LD	DE,$8000+(86*16)	;

		LDH	A,[hScrYLo]		;
		AND	7			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;

		LD	BC,wAtrShadow		;

.Loop0:		CALL	WaitForVBL		;

		LD	A,B			;Trigger the attribute
		LDH	[hIntroBlit+3],A	;dump.
		LD	A,C			;
		LDH	[hIntroBlit+2],A	;
		LD	A,$13			;
		LDH	[hIntroBlit+1],A	;
		LD	A,$02			;
		LDH	[hIntroBlit+0],A	;

.Loop1:		PUSH	BC			;

		PUSH	HL			;
		PUSH	DE			;

		LD	C,14			;Dump a single column.
		CALL	DmaBitmapCol21		;

		POP	HL			;

		LD	BC,$0010		;Move onto next dst column.
		ADD	HL,BC			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;

		LD	BC,$00F0		;Move onto next src column
		ADD	HL,BC			;(actually 15 high).

		POP	BC			;

		INC	C			;Next column in screen.

		LD	A,21			;All Done ?
		CP	C			;
		JP	Z,WaitForVBL		;

		BIT	0,C			;
		JR	NZ,.Loop1		;

		JR	.Loop0			;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BITMAPLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

