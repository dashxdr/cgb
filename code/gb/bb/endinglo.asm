; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** ENDINGLO.ASM                                                   MODULE **
; **                                                                       **
; ** End-of-Game.                                                          **
; **                                                                       **
; ** Last modified : 27 May 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"endinglo",HOME
		section 0


; ***************************************************************************
; * StoryFinish ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

		GLOBAL	Kiss

StoryFinish::	LD	A,[wWhichPlyr]		;win sequence.
		CP	PLYR_GASTN		;
		JR	Z,StoryLose		;

StoryWin::	LD	A,[wBoardMap]		;Completed which board ?
		OR	A			;
		JR	Z,StoryWin1		;
		DEC	A			;
		JR	Z,StoryWin2		;
		JR	StoryWin3		;

;
;
;

StoryWin1::	CALL	StoryUnlock		;Unlock this board.

		LD	HL,IntroFinish1		;Finished village board.
		CALL	TalkingHeads		;

		CALL	StoryUnlocked		;Was a board unlocked ?

		LD	A,BANK(StoryGame)	;Start next board.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		JP	StoryGame		;

;
;
;

StoryWin2::	CALL	StoryUnlock		;Unlock this board.

		LD	HL,IntroFinish2		;Finished forest board.
		CALL	TalkingHeads		;

		CALL	StoryUnlocked		;Was a board unlocked ?

		LD	A,BANK(StoryGame)	;Start next board.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		JP	StoryGame		;

;
;
;

StoryWin3::	CALL	StoryUnlock		;Unlock this board.

		LD	HL,IntroStoryWin	;Finished castle board.
		CALL	TalkingHeads		;

		LD	A,BANK(Kiss)		;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;
		CALL	Kiss			;

		CALL	StoryUnlocked		;Was a board unlocked ?

		JP	AbortGame		;Reset the game.

;
;
;

StoryUnlock::	LD	HL,wStoryUnlocked	;
;		LD	A,[wStructBelle+PLYR_LEVEL]
;		ADD	L			;
;		LD	L,A			;
;		JR	NC,.Skip0		;
;		INC	H			;

.Skip0:		LD	A,[wBoardMap]		;Increment board.
		INC	A			;
		LD	[wBoardMap],A		;

		LD	B,A			;Make the completed board
		XOR	A			;number into a mask.
		LD	[wSubAward],A		;
		SCF				;
.Loop0:		ADC	A			;
		DEC	B			;
		JR	NZ,.Loop0		;

		OR	[HL]			;Mask in the new permission.
		CP	[HL]			;
		RET	Z			;
		LD	[HL],A			;

		LD	[wSubAward],A		;Signal something unlocked.

		LD	A,BACKUP_NONE		;Save the unlocked state.
		LD	[wWhichGame],A		;
		JP	SaveBackup		;

StoryUnlocked::	LD	HL,IntroUnlockMap	;
		LD	A,[wSubAward]		;
		OR	A			;
		JP	NZ,TalkingHeads		;
		RET				;

;
;
;

StoryLose::	LD	HL,IntroStoryLose	;
		CALL	TalkingHeads		;

		JP	AbortGame		;Reset the game.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF ENDINGLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

