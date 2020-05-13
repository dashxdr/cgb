; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** MATCHLO.ASM                                                    MODULE **
; **                                                                       **
; ** Concentration game.                                                   **
; **                                                                       **
; ** Last modified : 05 Apr 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"matchlo",HOME
		section 0


; ***************************************************************************
; * PrepMatchFrame ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

PrepMatchFrame::LD	A,[hRomBank]		;Preserve original rom bank.
		PUSH	AF			;

		LD	HL,MATCH_DOOR_FRM	;Skip face if the door
		ADD	HL,BC			;is closed.
		LD	A,[HL]			;
		CP	1			;
		JR	Z,PrepMatchDoor		;

PrepMatchFace::	LD	HL,MATCH_FACE_TYP	;Locate the face's PKG file.
		ADD	HL,BC			;
		LD	A,[HL]			;
		ADD	A			;
		ADD	A			;
		LD	HL,TblMatch2Pkg		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;
		INC	HL			;
		INC	HL			;
.Skip1:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		CALL	FindInFileSys		;

		LD	HL,MATCH_FACE_FRM	;Locate the face's CHR file.
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,PrepMatchDoor		;
		DEC	A			;
		LD	L,A			;
		LD	H,0			;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip2		;
		ADD	HL,HL			;

.Skip2:		PUSH	BC			;Preserve structure ptr.

		CALL	FindInPkgFile		;Decompress CHR data.
		LD	DE,wMatchChr		;
;		CALL	SwdDecode		;
		CALL	MemCopy			;

		POP	BC			;Restore structure ptr.

		LDH	A,[hMachine]		;Only do the attributes on
		CP	MACHINE_CGB		;a CGB.
		JR	NZ,PrepMatchDoor	;

		LD	HL,MATCH_FACE_FRM	;Locate the face's ATR file.
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,PrepMatchDoor		;
		DEC	A			;
		ADD	A			;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		INC	HL			;

		PUSH	BC			;Preserve structure ptr.

		CALL	FindInPkgFile		;Decompress ATR data.
		LD	DE,wMatchAtr		;
;		CALL	SwdDecode		;
		CALL	MemCopy			;

		POP	BC			;Restore structure ptr.

PrepMatchDoor::	LD	HL,IDX_BMDOORPKG	;Locate the door's PKG file.
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	HL,IDX_CMDOORPKG	;
.Skip0:		CALL	FindInFileSys		;

		LD	HL,MATCH_DOOR_FRM	;Locate the door's CHR file.
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,PrepMatchDone		;
		DEC	A			;
		LD	L,A			;
		LD	H,0			;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip1		;
		ADD	HL,HL			;

.Skip1:		PUSH	BC			;Preserve structure ptr.

		CALL	FindInPkgFile		;Decompress CHR data.
		LD	DE,wMatchChr		;
;		CALL	SwdDecode		;
		CALL	MemCopy			;

		POP	BC			;Restore structure ptr.

		LDH	A,[hMachine]		;Only do the attributes on
		CP	MACHINE_CGB		;a CGB.
		JR	NZ,PrepMatchDone	;

		LD	HL,MATCH_DOOR_FRM	;Locate the face's ATR file.
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	Z,PrepMatchDone		;
		DEC	A			;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		INC	HL			;

		PUSH	BC			;Preserve structure ptr.

		CALL	FindInPkgFile		;Decompress ATR data.
		LD	DE,wMatchAtr		;
;		CALL	SwdDecode		;
		CALL	MemCopy			;

		POP	BC			;Restore structure ptr.

PrepMatchDone::	POP	AF			;Restore original rom bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.

;
;
;

TblMatch2Pkg::	DW	IDX_BMDOORPKG
		DW	IDX_CMDOORPKG
		DW	IDX_BMBEASTPKG
		DW	IDX_CMBEASTPKG
		DW	IDX_BMBELLEPKG
		DW	IDX_CMBELLEPKG
		DW	IDX_BMCHIPPKG
		DW	IDX_CMCHIPPKG
		DW	IDX_BMCOGSPKG
		DW	IDX_CMCOGSPKG
		DW	IDX_BMGASTNPKG
		DW	IDX_CMGASTNPKG
		DW	IDX_BMLEFOUPKG
		DW	IDX_CMLEFOUPKG
		DW	IDX_BMLUMIRPKG
		DW	IDX_CMLUMIRPKG
		DW	IDX_BMPOTTSPKG
		DW	IDX_CMPOTTSPKG
		DW	IDX_BMPROFPKG
		DW	IDX_CMPROFPKG
		DW	IDX_BMSULTNPKG
		DW	IDX_CMSULTNPKG

		DW	IDX_CMARROWPKG
		DW	IDX_CMARROWPKG



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF MATCHLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

