; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SWD.ASM                                                        MODULE **
; **                                                                       **
; ** Decompress from Elmer's Gameboy modified version of the SWD format.   **
; **                                                                       **
; ** Last modified : 23 Jul 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		SECTION	00


; ***************************************************************************
; * SwdDecode ()                                                            *
; ***************************************************************************
; * Decompress data in Elmer's Gameboy modified version of the SWD format.  *
; ***************************************************************************
; * Inputs      HL      Pointer to compressed data                          *
; *             DE      Pointer to destination buffer                       *
; *                                                                         *
; * Output      HL      Pointer to the end of the compressed data           *
; *             DE      Pointer to the end of the destination buffer        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

SwdDecode::	SCF				;1

;		LD	A,$7F			;2   Handle end-of-bank.
;		CP	H			;1
;		JR	NZ,			;3/2
;
;		LDH	A,[ROMBANK]		;3   Increment the ROM bank.
;		INC	A			;1
;		LDH	[ROMBANK],A		;3
;		LD	[rMBC_ROM],A		;4

Skip0:		LD	B,[HL]			;2   Read next cmd-byte.
		INC	HL			;2
		RR	B			;2

		JR	C,CopyCommand		;3/2 0=Byte, 1=Copy.

ByteCommand:	LD	A,[HLI]			;2

		LD	[DE],A			;2
		INC	DE			;2

ReadCommand:	SRL	B			;2   Read 1 bit.
		JR	Z,Skip0			;3/2

		JR	NC,ByteCommand		;3/2 0=Byte, 1=Copy.

CopyCommand:	LD	C,2			;2

		XOR	A			;1

		SRL	B			;2   Read 1 bit.
		JR	NZ,Skip1		;3/2

		LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2

Skip1:		JR	NC,GotLength		;3/2 0=Copy 2, 1=Copy N.

		CALL	Read2Bits		;x   Copy 3-5 ?
		JR	NZ,GotLength		;3/2

		LD	C,5

		CALL	Read4Bits		;x   Copy 6-20 ?
		JR	NZ,GotLength		;3/2

		LD	C,20

		LD	A,[HLI]			;3  Copy 21-256 ?

		OR	A			;1
		RET	Z			;5/2

GotLength:	ADD	C			;1
		LD	[DE],A			;2  Preserve length.

ReadOffset:	XOR	A			;1
		CALL	Read2Bits		;x

		JR	Z,GetOffset5		;3/2
		DEC	A			;1
		JR	Z,GetOffset7		;3/2
		DEC	A			;1
		JR	Z,GetOffset9		;3/2
		DEC	A			;1

GetOffset10:	CALL	Read2Bits		;x   Get top 2 bits.
		CPL				;1
		LD	C,A			;1

		LD	A,[HLI]			;2   Get btm 8 bits.
		CPL				;1

		PUSH	HL			;4   Preserve srcptr.

		SUB	$A0			;2
		LD	L,A			;1
		LD	A,C			;1
		SBC	$02			;2
		LD	H,A			;1

		JR	GotOffset

GetOffset9:	CALL	Read1Bit		;x
		CPL				;1
		LD	C,A			;1

		LD	A,[HLI]			;2   Get btm 8 bits.
		CPL				;1

		PUSH	HL			;4   Preserve srcptr.

		SUB	$A0			;2
		LD	L,A			;1
		LD	A,C			;1
		SBC	$00			;2
		LD	H,A			;1

		JR	GotOffset

GetOffset7:	CALL	Read7Bits		;x   Get all 7 bits.
		CPL				;1

		PUSH	HL			;4   Preserve srcptr.

		SUB	$20			;2
		LD	L,A			;1
		LD	A,$FF			;2
		SBC	$00			;2
		LD	H,A			;1

		JR	GotOffset

GetOffset5:	CALL	Read5Bits		;x   Get all 5 bits.
		CPL				;1

		PUSH	HL			;4   Preserve srcptr.

		LD	L,A			;1
		LD	H,$FF			;2

GotOffset:	ADD	HL,DE			;2   Convert offset to addr.

		LD	A,[DE]			;2   Restore length.
		LD	C,A			;1

CopyLoop:	LD	A,[HLI]			;3   LDIR
		LD	[DE],A			;2
		INC	DE			;2
		DEC	C			;1
		JR	NZ,CopyLoop		;3/2

		POP	HL			;3   Restore srcptr.

		JR	ReadCommand		;3

Read7Bits:	SRL	B			;2
		JR	Z,Next7Bits		;3/2
		RLA				;1
Read6Bits:	SRL	B			;2
		JR	Z,Next6Bits		;3/2
		RLA				;1
Read5Bits:	SRL	B			;2
		JR	Z,Next5Bits		;3/2
		RLA				;1
Read4Bits:	SRL	B			;2
		JR	Z,Next4Bits		;3/2
		RLA				;1
Read3Bits:	SRL	B			;2
		JR	Z,Next3Bits		;3/2
		RLA				;1
Read2Bits:	SRL	B			;2
		JR	Z,Next2Bits		;3/2
		RLA				;1
Read1Bit:	SRL	B			;2
		JR	Z,Next1Bit		;3/2
		RLA				;1
		OR	A			;1
		RET				;4

Next7Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast7Bits		;3
Next6Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast6Bits		;3
Next5Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast5Bits		;3
Next4Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast4Bits		;3
Next3Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast3Bits		;3
Next2Bits:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		JR	Fast2Bits		;3
Next1Bit:	LD	B,[HL]			;2
		INC	HL			;2
		RR	B			;2
		RLA				;1
		OR	A			;1
		RET				;4

Fast7Bits:	RLA				;1
		SRL	B			;2
Fast6Bits:	RLA				;1
		SRL	B			;2
Fast5Bits:	RLA				;1
		SRL	B			;2
Fast4Bits:	RLA				;1
		SRL	B			;2
Fast3Bits:	RLA				;1
		SRL	B			;2
Fast2Bits:	RLA				;1
		SRL	B			;2
		RLA				;1
		OR	A			;1
		RET				;4



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SWD.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

