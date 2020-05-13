; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** LEVELSLO.ASM                                                   MODULE **
; **                                                                       **
; ** Shell Difficulty Level Selection.                                     **
; **                                                                       **
; ** Last modified : 25 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"levelslo",HOME
		section 0


; ***************************************************************************
; * LevelSelect ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelSelect::	IF	0
		LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(LevelSelectHi)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	LevelSelectHi		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		ENDC

		RET				;All Done.



; ***************************************************************************
; * LevelResult ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResult::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(LevelResultHi)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	LevelResultHi		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * LevelResultT ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultT::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(LevelResultTHi)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	LevelResultTHi		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * LevelResultM ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultM::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(LevelResultMHi)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	LevelResultMHi		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.




; ***************************************************************************
; * LevelResultS ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

LevelResultS::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(LevelResultSHi)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	LevelResultSHi		;Do the selection.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF LEVELSLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

