; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SGB.ASM                                                        MODULE **
; **                                                                       **
; ** Super Gameboy functions.                                              **
; **                                                                       **
; ** Last modified : 03 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"sgb",CODE,BANK[2]
		section 2


; ***************************************************************************
; * SgbInitialize ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.                                                                    *
; ***************************************************************************

SgbInitialize::	XOR	A			;Reset SGB flag.
		LDH	[hSgb],A		;

		CALL	SgbCheck		;Is there really anything
		RET	NC			;on the other end ???

		LD	A,1			;Yes, there really is.
		LDH	[hSgb],A		;

		LD	HL,TblSgbMaskOn		;
		CALL	SgbRegXfer		;

		LD	HL,TblSgbInit1		;Send the SGB initialization
		CALL	SgbRegXfer		;commands.
		LD	HL,TblSgbInit2		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit3		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit4		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit5		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit6		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit7		;
		CALL	SgbRegXfer		;
		LD	HL,TblSgbInit8		;
		CALL	SgbRegXfer		;

		CALL	SgbBlackOut		;Blank out the GB display.

		LD	A,%00000001		;
		LDIO	[rLCDC],A		;

		LD	HL,SgbBorderMap		;Decompress SGB border map
		LD	DE,$C800		;and palettes.
		CALL	SwdDecode		;

		LD	DE,TblSgbPctTrn		;Transfer them to the SGB.
		LD	HL,$C800		;
		LD	BC,2048+96		;
		CALL	SgbVidXfer		;

		LD	HL,SgbBorderChr0	;Decompress SGB border chr
		LD	DE,$C800		;$00-$7F.
		CALL	SwdDecode		;

		LD	DE,TblSgbChr0Trn	;Transfer them to the SGB.
		LD	HL,$C800		;
		LD	BC,$1000		;
		CALL	SgbVidXfer		;

		LD	HL,SgbBorderChr1	;Decompress SGB border chr
		LD	DE,$C800		;$80-$FF.
		CALL	SwdDecode		;

		LD	DE,TblSgbChr1Trn	;Transfer them to the SGB.
		LD	HL,$C800		;
		LD	BC,$1000		;
		CALL	SgbVidXfer		;

		LD	HL,TblSgbAttrBlk	;Initialize SGB attributes
		CALL	SgbRegXfer		;for GB screen display.

		LD	HL,$8000		;Clear character and
		LD	BC,$2000		;background data.
		CALL	MemClear		;

		LD	A,%10000001		;
		LDIO	[rLCDC],A		;
		LD	A,%11111111		;
		LDH	[hVblBGP],A		;
		LDIO	[rBGP],A		;
		LDIO	[rOBP0],A		;
		LDIO	[rOBP1],A		;

		CALL	SgbWait4		;

		LD	HL,TblSgbMaskOff	;
		CALL	SgbRegXfer		;


		LD	DE,hTemp48		;
		LD	A,1
		LD	[DE],A			;
		INC	DE			;
		LD	HL,SgbPalettes		;
		LD	BC,15			;
		CALL	MemCopy			;
		LD	HL,hTemp48		;
		CALL	SgbRegXfer		;


		RET				;



; ***************************************************************************
; * SgbBlackOut ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.                                                                    *
; ***************************************************************************

SgbBlackOut::	LDH	A,[hSgb]		;Don't do anything if this
		OR	A			;isn't a Super Gameboy.
		RET	Z			;

;		LD	HL,SgbPalettes+6	;
;		LD	C,[HL]			;
;		INC	HL			;
;		LD	B,[HL]			;
		LD	BC,0

		LD	HL,hTemp48+1		;
		CALL	.Color			;
		CALL	.Color			;
		CALL	.Color			;
		CALL	.Color			;
		CALL	.Color			;
		CALL	.Color			;
		LD	[HL],0			;

		LD	HL,hTemp48		;
		LD	[HL],$00+1		;
		CALL	SgbRegXfer		;

		LD	HL,hTemp48		;
		LD	[HL],$08+1		;
		CALL	SgbRegXfer		;

		LD	HL,TblSgbMaskOn		;
		CALL	SgbRegXfer		;

		RET				;

.Color:		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		RET



; ***************************************************************************
; * SgbCheck ()                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      CF if machine is has SuperGameboy features, NC if not.      *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        While this routine is being executed it must not be         *
; *             interrupted by anything which uses rP1 such as a            *
; *             controller read routine.                                    *
; ***************************************************************************

SgbCheck::	CALL	SgbWait4		;Extra delay.

		LD	HL,TblSgb2Player	;2PLAY mode request
		CALL	SgbRegXfer		;

		LDIO	A,[rP1]			;
		AND	%00000011		;
		CP	3			;
		JR	NZ,SgbFoundSgb		;

		LD	A,$20			;controller read (dummy)
		LDIO	[rP1],A			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LD	A,$30			;
		LDIO	[rP1],A			;
		LD	A,$10			;
		LDIO	[rP1],A			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LD	A,$30			;
		LDIO	[rP1],A			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;
		LDIO	A,[rP1]			;

		LDIO	A,[rP1]			;
		AND	%00000011		;
		CP	3			;
		JR	NZ,SgbFoundSgb		;

SgbFoundGmb::	LD	HL,TblSgb1Player	;C=0 when work on GMB
		CALL	SgbRegXfer		;
		CALL	SgbWait4		;Extra delay.
		SUB	A			;
		RET				;

SgbFoundSgb::	LD	HL,TblSgb1Player	;C=1 when work on SGB
		CALL	SgbRegXfer		;
		CALL	SgbWait4		;Extra delay.
		SCF				;
		RET				;



; ***************************************************************************
; * SgbWait5/4/2/1 ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   BC,HL                                                       *
; *                                                                         *
; * N.B.        While this routine is being executed it must not be         *
; *             interrupted by anything which uses rP1 such as a            *
; *             controller read routine.                                    *
; ***************************************************************************

SgbWait5::	LD	DE,1750*5		;
		JR	SgbWaitLoop		;
SgbWait4::	LD	DE,1750*4		;
		JR	SgbWaitLoop		;
SgbWait2::	LD	DE,1750*2		;
		JR	SgbWaitLoop		;
SgbWait1::	LD	DE,1750*1		;

SgbWaitLoop::	NOP				;Delay for 10 cycle per loop.
		NOP				;
		NOP				;
		DEC	DE			;
		LD	A,D			;
		OR	E			;
		JR	NZ,SgbWaitLoop		;
		RET				;



; ***************************************************************************
; * SgbRegXfer ()                                                           *
; ***************************************************************************
; * Transfer data to the SGB using the register file only                   *
; ***************************************************************************
; * Inputs      HL   = Command data address                                 *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        While this routine is being executed it must not be         *
; *             interrupted by anything which uses rP1 such as a            *
; *             controller read routine.                                    *
; ***************************************************************************

SgbRegXfer::	LD	A,[HL]			;Read the number of packets
		AND	%00000111		;to send.
		RET	Z			;
		LD	B,A			;
		LD	C,255&rP1		;

SgbRegXferPkt::	PUSH	BC			;Preserve packet count.

		LD	A,$00			;Signal start of packet.
		LD	[C],A			;
		NOP				;
		LD	A,$30			;
		LD	[C],A			;

		LD	B,$10			;Transfer 16 bytes.

SgbRegXferByt::	LD	E,8			;Transfer 8 bits.
		LD	A,[HLI]			;
		LD	D,A			;

SgbRegXferBit::	BIT	0,D			;
		LD	A,$10			;P14=hi, P15=lo (output "1").
		JR	NZ,.Skip0		;
		LD	A,$20			;P14=lo, P15=hi (output "0").
.Skip0:		LD	[C],A			;
		NOP				;
		LD	A,$30			;P14=hi, P15=hi.
		LD	[C],A			;
		RR	D			;Shift 1 bit to right.
		DEC	E			;
		JR	NZ,SgbRegXferBit	;

		DEC	B			;
		JR	NZ,SgbRegXferByt	;

		LD	A,$20			;Signal end of packet.
		LD	[C],A			;
		NOP				;
		LD	A,$30			;
		LD	[C],A			;

		CALL	SgbWait4		;Force a delay between pkts.

		POP	BC			;Restore packet count.

		DEC	B			;Have all packets been sent ?
		JR	NZ,SgbRegXferPkt	;

		RET				;All Done.



; ***************************************************************************
; * SgbVidXfer ()                                                           *
; ***************************************************************************
; * Transfer data to the SGB using the video signal                         *
; ***************************************************************************
; * Inputs      DE   = Command data address                                 *
; *             HL   = Ptr to data to transfer to SGB                       *
; *             BC   = Len of data to transfer to SGB                       *
; *                                                                         *
; * Output      None                                                        *
; *                                                                         *
; * Preserved   BC,HL                                                       *
; *                                                                         *
; * N.B.        Assumes that interrupts are disabled but that the screen    *
; *             is enabled.                                                 *
; ***************************************************************************

SgbVidXfer::	LDIO	A,[rLCDC]		;Is the display enabled ?
		ADD	A			;
		JR	NC,.Skip0		;

.Sync0:		LDIO	A,[rLY]			;Wait for the start of the
		CP	145			;next VBL.
		JR	NZ,.Sync0		;

.Skip0:		LD	A,%00000001		;Stop the LCD.
		LDIO	[rLCDC],A		;

		LD	A,%11100100		;Reset palette.
		LDIO	[rBGP],A		;

		XOR	A			;Reset scroll position.
		LDIO	[rSCX],A		;
		LDIO	[rSCY],A		;

		PUSH	DE			;Preserve SGB command ptr.

		LD	DE,$8800		;Copy the data to transfer
		CALL	MemCopy			;to vram at $8800-$97FF.

		LD	HL,$9800		;Set up the 1st 256 displayed
		LD	DE,32-20		;characters of the screen at
		LD	A,$80			;$9800 to point to the 4KB of
		LD	C,13			;character data $8800-$97FF.
.SetRow:	LD	B,20			;
.SetCol:	LD	[HLI],A			;
		INC	A			;
		DEC	B			;
		JR	NZ,.SetCol		;
		ADD	HL,DE			;
		DEC	C			;
		JR	NZ,.SetRow		;

		LD	A,%10000001		;Start the LCD enabling only
		LDIO	[rLCDC],A		;the BG map at $9800.

		CALL	SgbWait5		;Wait for the data to xfer.

		POP	HL			;Send the SGB command that
		CALL	SgbRegXfer		;uses the data just sent.

		CALL	SgbWait2		;Wait an extra 2 frames.

.Sync1:		LDIO	A,[rLY]			;Wait for the start of the
		CP	145			;next VBL.
		JR	NZ,.Sync1		;

		LD	A,%00000001		;Stop the LCD.
		LDIO	[rLCDC],A		;

		RET



; ***************************************************************************
; * Super Gameboy Command Data                                              *
; ***************************************************************************

		IF	0
TblSgbInit1::	DB	$79,$5D,$08,$00,$0B,$8C,$D0,$F4,$60,$00,$00,$00,$00,$00,$00,$00
TblSgbInit2::	DB	$79,$52,$08,$00,$0B,$A9,$E7,$9F,$01,$C0,$7E,$E8,$E8,$E8,$E8,$E0
TblSgbInit3::	DB	$79,$47,$08,$00,$0B,$C4,$D0,$16,$A5,$CB,$C9,$05,$D0,$10,$A2,$28
TblSgbInit4::	DB	$79,$3C,$08,$00,$0B,$F0,$12,$A5,$C9,$C9,$C8,$D0,$1C,$A5,$CA,$C9
TblSgbInit5::	DB	$79,$31,$08,$00,$0B,$0C,$A5,$CA,$C9,$7E,$D0,$06,$A5,$CB,$C9,$7E
TblSgbInit6::	DB	$79,$26,$08,$00,$0B,$39,$CD,$48,$0C,$D0,$34,$A5,$C9,$C9,$80,$D0
TblSgbInit7::	DB	$79,$1B,$08,$00,$0B,$EA,$EA,$EA,$EA,$EA,$A9,$01,$CD,$4F,$0C,$D0
TblSgbInit8::	DB	$79,$10,$08,$00,$0B,$4C,$20,$08,$EA,$EA,$EA,$EA,$EA,$60,$EA,$EA
		ENDC

TblSgbInit1::	DB      $78+1,$1B,$08,$00,$0B,$EA,$EA,$EA,$EA,$EA,$A9,$01,$CD,$4F,$0C,$D0
TblSgbInit2::	DB      $78+1,$26,$08,$00,$0B,$39,$CD,$48,$0C,$D0,$34,$A5,$C9,$C9,$80,$D0
TblSgbInit3::	DB      $78+1,$31,$08,$00,$0B,$0C,$A5,$CA,$C9,$7E,$D0,$06,$A5,$CB,$C9,$7E
TblSgbInit4::	DB      $78+1,$3C,$08,$00,$0B,$F0,$12,$A5,$C9,$C9,$C8,$D0,$1C,$A5,$CA,$C9
TblSgbInit5::	DB      $78+1,$47,$08,$00,$0B,$C4,$D0,$16,$A5,$CB,$C9,$05,$D0,$10,$A2,$28
TblSgbInit6::	DB      $78+1,$52,$08,$00,$0B,$A9,$E7,$9F,$01,$C0,$7E,$E8,$E8,$E8,$E8,$E0
TblSgbInit7::	DB      $78+1,$5D,$08,$00,$0B,$8C,$D0,$F4,$60,$00,$00,$00,$00,$00,$00,$00
TblSgbInit8::	DB      $78+1,$10,$08,$00,$0B,$4C,$20,$08,$EA,$EA,$EA,$EA,$EA,$60,$EA,$EA

TblSgbMaskOn::	DB	$B8+1,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
TblSgbMaskOff::	DB	$B8+1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

TblSgb1Player::	DB	$88+1,$00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TblSgb2Player::	DB	$88+1,$01,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TblSgbPctTrn::	DB	$A0+1,$00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TblSgbChr0Trn::	DB	$98+1,$00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TblSgbChr1Trn::	DB	$98+1,$01,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TblSgbIconEn::	DB	$70+1,$01,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TblSgbPal01::	DB	$00+1			;
		DW	$7FFF,$56B5,$2D6B,$0000	;Palette 0
		DW	$0000,$7C84,$0000	;Palette 1
		DB	0

TblSgbAttrBlk::	DB      $20+1
		DB      $01
		DB      %011,%0000
		DB      $00,$00,$13,$11
		DB      0,0
		DB      0,0,0,0
		DB      0,0



; ***************************************************************************
; * Super Gameboy Background Data                                           *
; ***************************************************************************

SgbBorderMap::	incbin	"res/dave/sgb/testmap.swd"
SgbBorderChr0::	incbin	"res/dave/sgb/testchr1.swd"
SgbBorderChr1::	incbin	"res/dave/sgb/testchr2.swd"
SgbPalettes::	incbin	"res/dave/sgb/superpal.rgb"



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SGB.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

