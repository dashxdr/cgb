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

		SECTION	00

;
;
;

TblOffset0120::	DW	$C800+$0120*0
		DW	$C800+$0120*1
		DW	$C800+$0120*2
		DW	$C800+$0120*3
		DW	$C800+$0120*4
		DW	$C800+$0120*5
		DW	$C800+$0120*6
		DW	$C800+$0120*7
		DW	$C800+$0120*8
		DW	$C800+$0120*9
		DW	$C800+$0120*10
		DW	$C800+$0120*11
		DW	$C800+$0120*12
		DW	$C800+$0120*13
		DW	$C800+$0120*14
		DW	$C800+$0120*15
		DW	$C800+$0120*16
		DW	$C800+$0120*17
		DW	$C800+$0120*18
		DW	$C800+$0120*19
		DW	$C800+$0120*20

TblOffsetColumn:
		DW	$8800+$0120*0
		DW	$8800+$0120*1
		DW	$8800+$0120*2
		DW	$8800+$0120*3
		DW	$8800+$0120*4
		DW	$8800+$0120*5
		DW	$8800+$0120*6
		DW	$8800+$0120*7
		DW	$8800+$0120*8
		DW	$8800+$0120*9
		DW	$8800+$0120*10
		DW	$8800+$0120*11
		DW	$8800+$0120*12
		DW	$8800+$0120*13
		DW	$8800+$0120*0
		DW	$8800+$0120*1
		DW	$8800+$0120*2
		DW	$8800+$0120*3
		DW	$8800+$0120*4
		DW	$8800+$0120*5


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
; * Inputs      DE   = Idx of the CGB screen's PKG file in the filesys      *
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

		LD	L,E			;
		LD	H,D			;

		CALL	FindInFileSys		;Locate PKG file.

		LD	A,WRKBANK_BM		;Page in work ram for
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

		LD	A,WRKBANK_BG		;NRM;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	HL,0			;Locate bitmap data.
		CALL	FindInPkgFile		;

		LD	DE,$C800		;Decompress bitmap data.
		CALL	SwdDecode		;

		POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LD	A,WRKBANK_NRM		;Restore normal work ram.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

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

		LD	HL,$9800		;Clear screen attr.
		LD	A,$00			;
		CALL	ClrAtr32x32		;

		CALL	InitShadowAtr		;Clear shadow attr.

		LD	HL,$9800		;Initialize screen for a
		CALL	SetMap20x18		;20x18 bitmap.

		LD	A,%11100111		;Bgd_chr8000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
;		LD	A,%11100111		;Wnd_scr9C00,Wnd_on, then
;		LDH	[hLycLCDC],A		;Bgd_chr9000,Obj_on.

		LD	A,LOW(LycNormal)		;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblNormal)		;
		LD	[wVblVector],A		;

;		LD	A,70			;Enable LYC interrupt.
;		LDIO	[rLYC],A		;

		LD	A,$20
		LD	[wFontStrideLo],a
		LD	A,$01
		LD	[wFontStrideHi],a


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

DmaBitmap20x18::
		LD	A,WRKBANK_BG		;point to bg work area.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	HL,$C800		;
		LD	D,0

		LD	B,20			;Number of columns.

.Loop:		PUSH	BC			;

		PUSH	DE			;
		PUSH	HL			;

		LD	A,D
		CP	14
		LD	A,0
		JR	C,.aok
		INC	A
.aok:		LDH	[hVidBank],A
		LDIO	[rVBK],A
		LD	HL,TblOffsetColumn	;Calc dst offset as
		LD	A,D			;(Y*$0010)+(Colum[X])
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A

		POP	HL
		PUSH	HL
		LD	C,18			;Dump a single column.
		CALL	DumpChrs

		POP	HL			;

		POP	DE			;
		INC	D

		LD	BC,$0120		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;

		DEC	B			;Next column in screen.
		JR	NZ,.Loop		;

		LD	A,WRKBANK_NRM		;Restore normal
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

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

DmaBitmapCol20::CALL	CgbChrDump		;Dump a single chr.

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

DmaBitbox20x18::

		LD	A,WRKBANK_BG		;
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		PUSH	DE			;Preserve width and height.

		LD	D,B
		LD	E,C
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
		AND	$F0
		LD	B,A
		XOR	C
		LD	C,A
		SWAP	B
		SWAP	C
		ADD	HL,BC			;

		POP	BC			;Restore width and height.

.Loop0:		PUSH	BC			;Preserve width and height.
		PUSH	DE			;Preserve dst coords.
		PUSH	HL			;Preserve src ptr.

		LD	A,D
		CP	14
		LD	A,0
		JR	C,.aok
		INC	A
.aok:		LDH	[hVidBank],A
		LDIO	[rVBK],A

		LD	HL,TblOffsetColumn	;Calc dst offset as
		LD	A,D			;(Y*$0010)+(Colum[X])
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	A,E			;
		AND	$F0
		LD	D,A
		XOR	E
		LD	E,A
		SWAP	D
		SWAP	E
		ADD	HL,DE			;

		LD	D,H			;
		LD	E,L			;

		POP	HL
		PUSH	HL

		CALL	DumpChrs

		POP	HL			;Restore src ptr.
		POP	DE			;Restore dst coords.
		INC	D

		LD	BC,$0120		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;Restore width and height.

		DEC	B			;Next column in box.
		JR	NZ,.Loop0		;

		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		LDH	[hWrkBank],A		;palettes.
		LDIO	[rSVBK],A		;

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

SetMap20x18::	LD	B,0			;
		PUSH	DE

		LD	C,20
.Loop:		PUSH	HL			;

		PUSH	BC
		LD	A,B
		XOR	$80
		LD	B,A
		CALL	SetScreenRow		;Dump a single column.
		POP	BC
		LD	A,B
		ADD	18
		CP	18*14
		JR	C,.aok
		XOR	A
.aok:		LD	B,A

		POP	HL			;Restore state.

		INC	L

		DEC	C			;Do the next column.
		JR	NZ,.Loop		;
		POP	DE			;

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

SetScreenRow::
		LD	DE,$20

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

		LD	A,B			;1
		REPT	18
		LD	[HL],A			;2
		INC	A			;1
		ADD	HL,DE			;2
		ENDR
		LD	B,A			;1

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
		AND	$1F			;
		SUB	B			;
		INC	A			;
		LD	D,A			;

		LD	A,E			;Calc YH chr.
		RRCA				;
		RRCA				;
		RRCA				;
		AND	$1F			;
		SUB	C			;
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

DumpShadowAtr::	LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_BM		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		PUSH	DE
		LD	HL,wAtrShadow
		LD	B,32
		LD	DE,12
.repair:	REPT	14
		RES	3,[HL]
		INC	L
		ENDR
		REPT	6
		SET	3,[HL]
		INC	L
		ENDR
		ADD	HL,DE
		DEC	B
		JR	NZ,.repair
		POP	DE

		LD	HL,wAtrShadow		;
		LD	C,(32*18)/16		;
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

InitShadowAtr::
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
		OR	HIGH(wAtrShadow)		;
		LD	H,A			;

		LD	BC,32			;

		POP	AF			;Restore fill value.
		LD	D,A			;

		LDH	A,[hWrkBank]		;Preserve the current ram
		PUSH	AF			;bank.

		LD	A,WRKBANK_BM		;Page in the palettes.
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

FillShadowLst::

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

		LD	HL,$9800		;Clear screen attr.
		LD	A,$00			;
		CALL	ClrAtr32x32		;

		CALL	InitShadowAtr		;Clear shadow attr.

		LD	HL,$9800		;Initialize screen for a
		CALL	SetMap21x14		;21x14 bitmap.

		LD	HL,BlankChr3		;
		LD	DE,$8540		;
		CALL	CgbChrDump		;
		LD	HL,BlankTop		;
		LD	DE,$8550		;
		CALL	CgbChrDump		;
		LD	HL,BlankBtm		;
		LD	DE,$97E0		;
		CALL	CgbChrDump		;
		LD	HL,BlankChr3		;
		LD	DE,$97F0		;
		CALL	CgbChrDump		;

		LD	A,%11100111		;Bgd_chr8000,Obj_on,
		LDH	[hVblLCDC],A		;Bgd_scr9800,Bgd_on,
;		LD	A,%11100111		;Wnd_scr9C00,Wnd_on, then
;		LDH	[hLycLCDC],A		;Bgd_chr9000,Obj_on.

		LD	A,LOW(LycNormal)		;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblNormal)		;
		LD	[wVblVector],A		;

;		LD	A,64			;Enable LYC interrupt.
;		LDIO	[rLYC],A		;

		LD	A,$20
		LD	[wFontStrideLo],a
		LD	A,$01
		LD	[wFontStrideHi],a

		RET				;




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

DmaBitmapCol21::CALL	CgbChrDump		;Dump a single chr.

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
; ***************************************************************************
; ***************************************************************************
;  END OF BITMAPLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

