; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** MATCHHI.ASM                                                    MODULE **
; **                                                                       **
; ** Concentration game.                                                   **
; **                                                                       **
; ** Last modified : 05 Apr 1999 by John Brandwood                         **
; **                                                                       **
; ** N.B. MUST BE IN SAME BANK AS BITMAPHI.ASM                             **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"matchhi",CODE,BANK[5]
		section 5
;
;
;

DELAY_EXIT	EQU	(255-15)

;
;
;

;hMatchTbl	EQUS	"hTemp48"		;$03 bytes * 12
hMatchJmp	EQUS	"hTemp48+$24"		;$03 bytes * 1
hMatchLives	EQUS	"hTemp48+$27"		;$01 bytes * 1
hMatchPairs	EQUS	"hTemp48+$28"		;$01 bytes * 1
hMatchOver	EQUS	"hTemp48+$29"		;$01 bytes * 1
hMatchOldP	EQUS	"hTemp48+$2A"		;$01 bytes * 1
hMatchCurP	EQUS	"hTemp48+$2B"		;$01 bytes * 1
hMatchCurX	EQUS	"hTemp48+$2C"		;$01 bytes * 1
hMatchCurY	EQUS	"hTemp48+$2D"		;$01 bytes * 1
hMatchIconClk	EQUS	"hTemp48+$2E"		;$01 bytes * 1
hMatchIconFrm	EQUS	"hTemp48+$2F"		;$01 bytes * 1

;
;
;

MatchLvl2Clk::	DB	120,80,40,40		;

TblMCursorPos::	DB	$00,$00,$28,$00,$50,$00,$78,$00
		DB	$00,$30,$28,$30,$50,$30,$78,$30
		DB	$00,$60,$28,$60,$50,$60,$78,$60

TblMCursorOam::	DB	$0F,$08,$0C,$00
		DB	$35,$08,$0E,$00
		DB	$0F,$27,$10,$00
		DB	$35,$27,$12,$00

TblMHeartOam::	DB	$10,$08,$14,$11

;
;
;


; ***************************************************************************
; * Concentration ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

Concentration::	CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	KillAllSound		;

		LD	A,3			;Initialize lives.
		LDH	[hMatchLives],A		;

		XOR	A			;
		LD	[wSubStage],A		;

MatchStage::	CALL	RandomizeMatch		;Initial match.

		LD	A,$C3			;
		LDH	[hMatchJmp+0],A		;
		LD	A,LOW(MatchPickDoor)	;
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchPickDoor)	;
		LDH	[hMatchJmp+2],A		;

		CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_TGTCURSOR	;
		CALL	AddSpritePal		;
		LD	HL,PAL_TGTCURSOR	;
		CALL	AddSpritePal		;

.Skip0:		LD	HL,IDX_CCURSORPKG	;Setup cursor.
		LD	DE,$8080		;
		CALL	GetCursorGfx		;

		LD	HL,IDX_BGLASSPKG	;Setup background.
		LD	DE,IDX_CGLASSPKG	;
		CALL	XferBitmap		;

		LD	A,%11100100		;Initialize PAL data and
		LD	[wFadeVblBGP],A		;override palettes from
		LD	[wFadeLycBGP],A		;XferBitmap.
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	ShutMatchDoors		;Close all the doors.

		CALL	DumpAllMatch		;Dump all the positions.

		CALL	FadeInBlack		;Fade in from black.

		LD	A,SONG_MATCH		;
		CALL	InitTunePref		;

		CALL	MatchDisplay		;

		CALL	MatchLocate		;Init the cursor location.

		JP	MatchStart		;

MatchRestart::	CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_TGTCURSOR	;
		CALL	AddSpritePal		;
		LD	HL,PAL_TGTCURSOR	;
		CALL	AddSpritePal		;

.Skip0:		LD	HL,IDX_CCURSORPKG	;Setup cursor.
		LD	DE,$8080		;
		CALL	GetCursorGfx		;

		LD	HL,IDX_BGLASSPKG	;Setup background.
		LD	DE,IDX_CGLASSPKG	;
		CALL	XferBitmap		;

		LD	A,%11100100		;Initialize PAL data and
		LD	[wFadeVblBGP],A		;override palettes from
		LD	[wFadeLycBGP],A		;XferBitmap.
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	DumpAllMatch		;Dump all the positions.

		CALL	MatchSprites		;Dump the cursor sprite.

		CALL	FadeInBlack		;Fade in from black.

MatchStart::	XOR	A			;Clear pause request flag.
		LD	[wWantToPause],A	;

		CALL	WaitForVBL		;Synchronize to the VBL.

MatchLoop::	LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LDH	A,[hMatchOver]		;Stage finished ?
		OR	A			;
		JR	Z,MatchTick		;
		INC	A			;
		JR	Z,MatchExit		;
		LDH	[hMatchOver],A		;
		INC	A			;
		JR	NZ,MatchTick		;

		LDH	A,[hMatchLives]		;All lives lost ?
		OR	A			;
		JR	Z,MatchLost		;

MatchWon::	LD	A,SONG_WON		;
		CALL	InitTune		;
		JR	MatchTick		;

MatchLost::	LD	A,SONG_LOST		;
		CALL	InitTune		;
		JR	MatchTick		;

MatchExit::	LD	A,[wMzPlaying]		;Wait for exit tune to
		OR	A			;finish.
		JR	NZ,MatchTick		;

		JP	MatchNext		;

MatchTick::	LD	A,[wWantToPause]	;Pause ?
		OR	A			;
		JP	NZ,MatchPause		;

		CALL	hMatchJmp		;

		CALL	DumpNewMatch		;Dump all the new positions.

		CALL	MatchSprites		;Dump the cursor sprite.

		CALL	WaitForVBL		;Synchronize to the VBL.

		JP	MatchLoop		;

;
;
;

MatchNext::	CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;
		CALL	WaitForVBL		;

		LDH	A,[hMatchPairs]		;Preserve pairs found.
		SUB	6			;
		CPL				;
		INC	A			;
		LD	[wSubCount],A		;
		INC	A			;
		SRL	A			;
		LD	[wSubStage],A		;

		JR	MatchFinished		;

;
;
;

MatchFinished::	CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;

;
;
;

MatchPause::	CALL	FadeOutBlack		;Fade out.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;Synchronize to the VBL.

		CALL	SetMachineJcb		;Reset machine to known state.

		CALL	PauseMenu_B		;Call the generic pause.

		JP	MatchRestart		;And then restart this game.

;
;
;

MatchMusic::	LD	A,[wMzNumber]		;
		CP	A,SONG_MATCH		;
		RET	Z			;
		LD	A,SONG_MATCH		;
		JP	InitTunePref		;



; ***************************************************************************
; * MatchDisplay ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchDisplay::	LD	A,30			;
		CALL	AnyWait			;

		LD	DE,hTemp48		;Reset the tables.

		LD	B,3
.Loop0:		LD	C,3
.Loop1:		PUSH	BC
		PUSH	DE			;
		CALL	.Open			;
		CALL	.Open			;
		CALL	.Open			;
		CALL	.Open			;
		CALL	DumpNewMatch		;
		LD	A,4			;
		CALL	AnyWait			;
		POP	DE			;
		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop1		;
		LD	A,E			;
		ADD	3*4			;
		LD	E,A			;
		DEC	B			;
		JR	NZ,.Loop0		;

		LD	HL,MatchLvl2Clk		;
		LD	A,[wSubLevel]		;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HL]			;
		CALL	AnyWait			;

		LD	DE,hTemp48		;Reset the tables.
		LD	B,3
.Loop2:		LD	C,3
.Loop3:		PUSH	BC
		PUSH	DE			;
		CALL	.Close			;
		CALL	.Close			;
		CALL	.Close			;
		CALL	.Close			;
		CALL	DumpNewMatch		;
		LD	A,4			;
		CALL	AnyWait			;
		POP	DE			;
		POP	BC			;
		DEC	C			;
		JR	NZ,.Loop3		;
		LD	A,E			;
		ADD	3*4			;
		LD	E,A			;
		DEC	B			;
		JR	NZ,.Loop2		;

		RET				;

.Open:		LD	HL,MATCH_FACE_TYP	;Open.
		ADD	HL,DE			;
		SET	7,[HL]			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,DE			;
		LD	A,[HL]			;
		INC	A			;
		AND	3			;
		LD	[HL],A			;
		LD	A,E			;
		ADD	3			;
		LD	E,A			;
		RET				;

.Close:		LD	HL,MATCH_FACE_TYP	;Close.
		ADD	HL,DE			;
		SET	7,[HL]			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,DE			;
		LD	A,[HL]			;
		DEC	A			;
		AND	3			;
		LD	[HL],A			;
		LD	A,E			;
		ADD	3			;
		LD	E,A			;
		RET				;



; ***************************************************************************
; * RandomizeMatch ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

RandomizeMatch::LD	HL,hTemp48		;Reset the tables.
		LD	BC,12*3			;
		CALL	MemClear		;

		LD	HL,wTemp512		;Reset the temporary
		LD	BC,8			;face-used array.
		CALL	MemClear		;

		LD	A,6			;
		LDH	[hMatchPairs],A		;
		XOR	A			;
		LDH	[hMatchOver],A		;

		LD	BC,hTemp48		;
		LD	DE,wTemp512		;

		LD	A,6			;Initialize a total of 6
.Loop0:		LDH	[hTmpLo],A		;pairs.

		CALL	RndMatchTyp		;Pick a face type.

		CALL	RndMatchPos		;Pick a position for the 1st
		LD	HL,MATCH_FACE_TYP	;face.
		ADD	HL,BC			;
		LD	[HL],A			;
		LD	HL,MATCH_FACE_FRM	;
		ADD	HL,BC			;
		LD	[HL],1			;

		CALL	RndMatchPos		;Pick a position for the 2nd
		LD	HL,MATCH_FACE_TYP	;face.
		ADD	HL,BC			;
		LD	[HL],A			;
		LD	HL,MATCH_FACE_FRM	;
		ADD	HL,BC			;
		LD	[HL],1			;

		LDH	A,[hTmpLo]		;Loop around to initialize
		DEC	A			;another pair.
		JR	NZ,.Loop0		;

		RET				;

;
;
;

RndMatchPos::	PUSH	AF			;
		CALL	random			;
		SWAP	A			;
		AND	15			;
		ADD	5			;
.Loop0:		LDH	[hTmpHi],A		;
.Loop1:		LD	A,C			;
		ADD	3			;
		LD	C,A			;
		CP	A,LOW(hTemp48)+12*3	;
		JR	NZ,.Skip0		;
		LD	C,LOW(hTemp48)	;
.Skip0:		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,BC			;
		LD	A,[HL]			;
		OR	A			;
		JR	NZ,.Loop1		;
		LDH	A,[hTmpHi]		;
		DEC	A			;
		JR	NZ,.Loop0		;
		POP	AF			;
		RET				;

;
;
;

RndMatchTyp::	CALL	random			;
		SWAP	A			;
		AND	7			;
		INC	A			;
.Loop0:		LDH	[hTmpHi],A		;
.Loop1:		LD	A,E			;
		ADD	1			;
		LD	E,A			;
		CP	A,LOW(wTemp512)+8	;
		JR	NZ,.Skip0		;
		LD	E,LOW(wTemp512)	;
.Skip0:		LD	A,[DE]			;
		OR	A			;
		JR	NZ,.Loop1		;
		LDH	A,[hTmpHi]		;
		DEC	A			;
		JR	NZ,.Loop0		;
		DEC	A			;
		LD	[DE],A			;
		LD	A,E			;
		SUB	A,LOW(wTemp512)	;
		INC	A			;
		RET				;



; ***************************************************************************
; * ShutMatchDoors ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ShutMatchDoors::LD	DE,hTemp48		;Start at the beginning.

.Loop:		LD	HL,MATCH_FACE_TYP	;Is this position active ?
		ADD	HL,DE			;
		LD	A,[HL]			;
		AND	15			;
		JR	Z,.Next			;

		LD	HL,MATCH_FACE_FRM	;Set static face frame.
		ADD	HL,DE			;
		LD	[HL],1			;

		LD	HL,MATCH_DOOR_FRM	;Set closed door frame.
		ADD	HL,DE			;
		LD	[HL],1			;

.Next:		LD	A,E			;Move onto next position.
		ADD	3			;
		LD	E,A			;
		CP	A,LOW(hTemp48)+12*3	;
		JR	NZ,.Loop		;

		RET				;All Done.



; ***************************************************************************
; * DumpAllMatch ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpAllMatch::	LD	BC,hTemp48		;

		LD	E,$00			;
.Loop0:		LD	D,$00			;

.Loop1:		LD	HL,MATCH_FACE_TYP	;Dump the frame.
		ADD	HL,BC			;
		RES	7,[HL]			;
		CALL	DumpOneMatch		;

		LD	A,C			;
		ADD	3			;
		LD	C,A			;

		LD	A,D			;Do next face on line.
		ADD	5			;
		LD	D,A			;
		CP	5*4			;
		JR	NZ,.Loop1		;

		LD	A,E			;Do next line on screen.
		ADD	6			;
		LD	E,A			;
		CP	6*3			;
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * DumpNewMatch ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpNewMatch::	LD	BC,hTemp48		;

		LD	E,$00			;
.Loop0:		LD	D,$00			;

.Loop1:		LD	HL,MATCH_FACE_TYP	;Does this position need to
		ADD	HL,BC			;be updated ?
		BIT	7,[HL]			;
		JR	Z,.Skip0		;

		RES	7,[HL]			;
		CALL	DumpOneMatch		;

.Skip0:		LD	A,C			;
		ADD	3			;
		LD	C,A			;

		LD	A,D			;Do next face on line.
		ADD	5			;
		LD	D,A			;
		CP	5*4			;
		JR	NZ,.Loop1		;

		LD	A,E			;Do next line on screen.
		ADD	6			;
		LD	E,A			;
		CP	6*3			;
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * DumpOneMatch ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to target's info structure                       *
; *             D    = X character posn on screen                           *
; *             E    = Y character posn on screen                           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; ***************************************************************************

DumpOneMatch::	LD	HL,MATCH_FACE_TYP	;Dump a face frame or just
		ADD	HL,BC			;the background glass ?
		LD	A,[HL]			;
		AND	15			;
		JR	Z,.Glass		;

.Frame:		PUSH	BC			;Preserve structure ptr.
		PUSH	DE			;Preserve coordinates.

		CALL	PrepMatchFrame		;Prepare the frame's data.

		POP	BC			;Copy the frame's CHR data.
		PUSH	BC			;
		LD	HL,wMatchChr		;
		CALL	MatchChr5x6		;

		POP	BC			;Copy the frame's ATR data.
		PUSH	BC			;
		LD	HL,wMatchAtr		;
		CALL	MatchAtr5x6		;

		POP	DE			;Restore coordinates.
		POP	BC			;Restore structure ptr.

		RET				;

.Glass:		PUSH	BC			;Preserve structure ptr.
		PUSH	DE			;Preserve coordinates.

		POP	BC			;Copy the glass's CHR data.
		PUSH	BC			;
		LD	DE,$0506		;
		CALL	DmaBitbox20x18		;

		POP	BC			;Copy the glass's ATR data.
		PUSH	BC			;
		CALL	MatchScr5x6		;

		POP	DE			;Restore coordinates.
		POP	BC			;Restore structure ptr.

		RET				;



; ***************************************************************************
; * MatchChr5x6 ()                                                          *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      HL   = Src bitmap ptr                                       *
; *             B    = Dst screen X (0..31)                                 *
; *             C    = Dst screen Y (0..31)                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchChr5x6::	PUSH	HL			;Preserve src ptr.

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
		LD	E,A			;
		LD	A,B			;
		SWAP	A			;
		AND	$0F			;
		LD	D,A			;
		ADD	HL,DE			;

		LD	DE,$8000+((384-360)*16)	;Add starting addr of dst.
		ADD	HL,DE			;
		LD	E,L			;
		LD	D,H			;

		POP	HL			;Restore src ptr.

		LD	BC,$0506		;Restore width and height.

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

		LD	BC,$0060		;Move onto next src column.
		ADD	HL,BC			;

		POP	BC			;Restore width and height.

		DEC	B			;Next column in box.
		JR	NZ,.Loop0		;

		RET				;All Done.



; ***************************************************************************
; * MatchAtr5x6 ()                                                          *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      HL   = Src bitmap ptr                                       *
; *             B    = Dst screen X (0..31)                                 *
; *             C    = Dst screen Y (0..31)                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchAtr5x6::	LDH	A,[hMachine]		;Only do this on the CGB.
		CP	MACHINE_CGB		;
		RET	NZ			;

		LD	A,1			;Page in ATR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		LD	A,C			;Calc the destination scr
		SWAP	A			;address ($9800-$9BFF)
		RLCA				;and preserve it for later.
		LD	D,A			;
		AND	$E0			;
		LD	E,A			;
		LD	A,B			;
		AND	$1F			;
		OR	A,E			;
		LD	E,A			;
		LD	A,D			;
		AND	$03			;
		OR	$9800>>8		;
		LD	D,A			;

		LD	B,6			;Dump 6 lines.

.Line:		PUSH	HL			;Preserve src ptr.

		LD	C,1			;Dump 1 lots of 5 columns.

.Hold:		LDIO	A,[rLY]			;Don't start the transfer
		DEC	A			;during vblank.
		CP	140			;
		JR	NC,.Hold		;

		PUSH	BC			;Preserve count.

		LD	BC,6			;

		DI				;Disable interrupts.

.Sync:		LDIO	A,[rSTAT]		;Wait until the current
		AND	%11			;HBL is finished.
		JR	Z,.Sync			;

.Wait:		LDIO	A,[rSTAT]		;Wait for the next HBL.
		AND	%11			;
		JR	NZ,.Wait		;

		LD	A,[HL]			;Transfer 5 bytes of
		LD	[DE],A			;screen data.
		ADD	HL,BC			;
		INC	E			;
		LD	A,[HL]			;
		LD	[DE],A			;
		ADD	HL,BC			;
		INC	E			;
		LD	A,[HL]			;
		LD	[DE],A			;
		ADD	HL,BC			;
		INC	E			;
		LD	A,[HL]			;
		LD	[DE],A			;
		ADD	HL,BC			;
		INC	E			;
		LD	A,[HL]			;
		LD	[DE],A			;
		ADD	HL,BC			;
		INC	E			;

		EI				;Enable interrupts.

		POP	BC			;Restore count.

		DEC	C			;Do the next 5 columns.
		JR	NZ,.Hold		;

		POP	HL			;Move the src ptr onto the
		INC	HL			;next line.

		LD	A,32-5			;Move the dst ptr onto the
		ADD	E			;next line.
		LD	E,A			;
		JR	NC,.Skip		;
		INC	D			;

.Skip:		DEC	B			;Do the next line.
		JR	NZ,.Line		;

		LD	A,0			;Page in CHR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * MatchScr5x6 ()                                                          *
; ***************************************************************************
; * Copy characters to display RAM, coping with the wierd mapping           *
; ***************************************************************************
; * Inputs      B    = Dst screen X (0..31)                                 *
; *             C    = Dst screen Y (0..31)                                 *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchScr5x6::	LDH	A,[hMachine]		;Only do this on the CGB.
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

		LD	A,C			;Calc the destination scr
		SWAP	A			;address ($9800-$9BFF)
		RLCA				;and preserve it for later.
		LD	D,A			;
		LD	H,A			;
		AND	$E0			;
		LD	E,A			;
		LD	A,B			;
		AND	$1F			;
		OR	A,E			;
		LD	E,A			;
		LD	L,A			;
		LD	A,D			;
		AND	$03			;
		OR	$9800>>8		;
		LD	D,A			;
		LD	A,H			;
		AND	$03			;
		OR	HIGH(wAtrShadow)	;
		LD	H,A			;

		LD	B,6			;Dump 6 lines.

.Line:		LD	C,1			;Dump 1 lots of 5 columns.

.Hold:		LDIO	A,[rLY]			;Don't start the transfer
		DEC	A			;during vblank.
		CP	140			;
		JR	NC,.Hold		;

		DI				;Disable interrupts.

.Sync:		LDIO	A,[rSTAT]		;Wait until the current
		AND	%11			;HBL is finished.
		JR	Z,.Sync			;

.Wait:		LDIO	A,[rSTAT]		;Wait for the next HBL.
		AND	%11			;
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

		LD	A,32-5			;Move the dst ptr onto the
		ADD	L			;next line.
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;

.Skip0:		LD	A,32-5			;Move the dst ptr onto the
		ADD	E			;next line.
		LD	E,A			;
		JR	NC,.Skip1		;
		INC	D			;

.Skip1:		DEC	B			;Do the next line.
		JR	NZ,.Line		;

		LD	A,0			;Page in CHR video bank.
		LDH	[hVidBank],A		;
		LDIO	[rVBK],A		;

		POP	AF			;Restore the original ram
		LDH	[hWrkBank],A		;bank.
		LDIO	[rSVBK],A		;

		RET				;All Done.



; ***************************************************************************
; * MatchSprites ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchSprites::	CALL	InitIntro		;Init intro systems.

		LD	A,LOW(DrawMatchSpr)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DrawMatchSpr)	;
		LD	[wJmpDraw+2],A		;

		CALL	ProcIntroSpr		;Process the sprites.

		RET				;All Done.

;
;
;

DrawMatchSpr::	LDH	A,[hMatchIconFrm]	;Should the cursor be
		OR	A			;displayed ?
		RET	Z			;

DrawMatchLife::	LDH	A,[hMatchCurY]		;Calc the cursor coordinates
		ADD	A			;from its X and Y position.
		ADD	A			;
		LD	L,A			;
		LDH	A,[hMatchCurX]		;
		ADD	L			;
		ADD	A			;
		LD	HL,TblMCursorPos	;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		ADD	$15			;
		LD	B,A			;
		LD	A,[HLI]			;
		ADD	$28			;
		LD	C,A			;

		LDH	A,[hMatchLives]		;
		OR	A			;
		JR	Z,DrawMatchPosn		;
		DEC	A			;
		JR	Z,DrawMatchPosn		;

.Loop0:		PUSH	AF			;

		LD	HL,TblMHeartOam		;Dump the sprite attributes
		CALL	DrawMatchOam		;to the OAM shadow.

		LD	A,B			;
		SUB	10			;
		LD	B,A			;

		POP	AF			;
		DEC	A			;
		JR	NZ,.Loop0		;

DrawMatchPosn::	LDH	A,[hMatchIconClk]	;Flash the cursor.
		OR	A			;
		JR	NZ,.Skip1		;
		LDH	A,[hMatchIconFrm]	;
		INC	A			;
		CP	4			;
		JR	C,.Skip0		;
		LD	A,1			;
.Skip0:		LDH	[hMatchIconFrm],A	;
		LD	A,3			;
.Skip1:		DEC	A			;
		LDH	[hMatchIconClk],A	;

		LDH	A,[hMatchCurY]		;Calc the cursor coordinates
		ADD	A			;from its X and Y position.
		ADD	A			;
		LD	L,A			;
		LDH	A,[hMatchCurX]		;
		ADD	L			;
		ADD	A			;
		LD	HL,TblMCursorPos	;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip2		;
		INC	H			;
.Skip2:		LD	A,[HLI]			;
		LD	B,A			;
		LD	C,[HL]			;

		LD	HL,TblMCursorOam	;Dump the sprite attributes
		CALL	DrawMatchOam		;to the OAM shadow.
		CALL	DrawMatchOam		;
		CALL	DrawMatchOam		;
DrawMatchOam::	LD	A,[HLI]			;
		ADD	C			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		ADD	B			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		LD	A,[HLI]			;
		LD	[DE],A			;
		INC	E			;
		RET				;



; ***************************************************************************
; * MatchLocate ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchLocate::	XOR	A			;
		LDH	[hMatchIconClk],A	;
		INC	A			;
		LDH	[hMatchIconFrm],A	;

		RET				;Return NZ.



; ***************************************************************************
; * MatchPickDoor ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchPickDoor::	CALL	MatchMusic		;Ensure that music is playing.

		LD	A,[wJoy1Hit]		;
		OR	A			;
		LD	A,FX_DOOR_MOVE		;
		CALL	NZ,InitSfx		;

		LD	A,[wJoy1Hit]		;
		LD	C,A			;

.TestStart:	BIT	JOY_START,C		;
		JR	Z,.TestR		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.TestR:		BIT	JOY_R,C			;
		JR	Z,.TestL		;

		LDH	A,[hMatchCurX]		;
		INC	A			;
		CP	4			;
		JR	C,.SkipR		;
		XOR	A			;
.SkipR:		LDH	[hMatchCurX],A		;

.TestL:		BIT	JOY_L,C			;
		JR	Z,.TestU		;

		LDH	A,[hMatchCurX]		;
		SUB	1			;
		JR	NC,.SkipL		;
		LD	A,3			;
.SkipL:		LDH	[hMatchCurX],A		;

.TestU:		BIT	JOY_U,C			;
		JR	Z,.TestD		;

		LDH	A,[hMatchCurY]		;
		SUB	1			;
		JR	NC,.SkipU		;
		LD	A,2			;
.SkipU:		LDH	[hMatchCurY],A		;

.TestD:		BIT	JOY_D,C			;
		JR	Z,.TestShoot		;

		LDH	A,[hMatchCurY]		;
		INC	A			;
		CP	3			;
		JR	C,.SkipD		;
		XOR	A			;
.SkipD:		LDH	[hMatchCurY],A		;

.TestShoot:	AND	MSK_JOY_A|MSK_JOY_B	;Shoot ?
		RET	Z			;

		LD	HL,hMatchCurY		;Locate the frame displayed
		LD	A,[HLD]			;at this position.
		ADD	A			;
		ADD	A			;
		ADD	[HL]			;
		LD	C,A			;
		ADD	A			;
		ADD	C			;
		LD	C,A			;
		LD	B,0			;
		LD	HL,hTemp48		;
		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;

		LD	HL,MATCH_FACE_TYP	;Is this frame empty ?
		ADD	HL,BC			;
		LD	A,[HL]			;
		AND	15			;
		JR	Z,.TestEmpty		;

		LDH	A,[hMatchOldP]		;Has this door already been
		OR	A			;picked ?
		JR	Z,.TestFound		;
		CP	C			;
		JR	Z,.TestEmpty		;

.TestFound:	LD	A,C			;
		LDH	[hMatchCurP],A		;

		LD	A,LOW(MatchOpenDoor)	;
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchOpenDoor)	;
		LDH	[hMatchJmp+2],A		;

		LD	A,FX_DOOR_OPEN		;
		JP	InitSfx			;

		RET				;All Done.

.TestEmpty:	RET				;

.TestSound:	LDH	A,[hMatchCurX]		;
		LDH	[hTmpLo],A		;
		LDH	A,[hMatchCurY]		;
		LDH	[hTmpHi],A		;

.TestMoved:	LD	A,FX_DOOR_MOVE		;
		JP	NZ,InitSfx		;



; ***************************************************************************
; * MatchOpenDoor ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchOpenDoor::	CALL	MatchMusic		;Ensure that music is playing.

		LD	A,[wJoy1Hit]		;Pause wanted ?
		BIT	JOY_START,A		;
		JR	Z,.Skip0		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.Skip0:		LDH	A,[hMatchOldP]		;Has a door already been
		OR	A			;picked ?
		JR	Z,.Skip1		;

		XOR	A			;Disable cursor.
		LDH	[hMatchIconFrm],A	;

.Skip1:		LDH	A,[hMatchCurP]		;
		LD	C,A			;
		LD	B,HIGH(hTemp48)	;

		LDH	A,[hMatchIconClk]	;Animate the door.
		OR	A			;
		JR	NZ,.Skip2		;

		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,BC			;
		SET	7,[HL]			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,BC			;
		LD	A,[HL]			;
		INC	A			;
		AND	3			;
		LD	[HL],A			;
		JR	Z,.Skip3		;
		LD	A,3			;

.Skip2:		DEC	A			;
		LDH	[hMatchIconClk],A	;
		RET				;

.Skip3:		LDH	A,[hMatchOldP]		;Has a door already been
		OR	A			;picked ?
		JR	NZ,.Skip4		;

		LDH	A,[hMatchCurP]		;Save this door.
		LDH	[hMatchOldP],A		;

		LD	A,1			;Enable cursor.
		LDH	[hMatchIconFrm],A	;

		LD	A,LOW(MatchPickDoor)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchPickDoor)	;
		LDH	[hMatchJmp+2],A		;

		RET				;All Done.

.Skip4:		LD	A,LOW(MatchWaitDoor)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchWaitDoor)	;
		LDH	[hMatchJmp+2],A		;

		LD	A,60			;
		LDH	[hMatchIconClk],A	;

		RET				;All Done.



; ***************************************************************************
; * MatchWaitDoor ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchWaitDoor::	CALL	MatchMusic		;Ensure that music is playing.

		LD	A,[wJoy1Hit]		;Pause wanted ?
		BIT	JOY_START,A		;
		JR	Z,.Skip0		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.Skip0:		LDH	A,[hMatchIconClk]	;
		DEC	A			;
		LDH	[hMatchIconClk],A	;
		RET	NZ			;

		LDH	A,[hMatchCurP]		;
		LD	C,A			;
		LD	B,HIGH(hTemp48)	;
		LDH	A,[hMatchOldP]		;
		LD	E,A			;
		LD	D,HIGH(hTemp48)	;

		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,BC			;
		LD	A,[HL]			;
		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,DE			;
		XOR	A,[HL]			;
		AND	15			;
		JR	Z,MatchFoundPair	;

MatchWrongPair::LD	A,LOW(MatchCloseDoor)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchCloseDoor)	;
		LDH	[hMatchJmp+2],A		;

		LDH	A,[hMatchLives]		;
		DEC	A			;
		LDH	[hMatchLives],A		;

		LD	A,FX_DOOR_OPEN		;
		JP	NZ,InitSfx		;

		JR	MatchGameOver		;Signal game over.

MatchFoundPair::LD	HL,MATCH_FACE_TYP	;
		ADD	HL,BC			;
		LD	[HL],$80		;
		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,DE			;
		LD	[HL],$80		;

		XOR	A			;
		LDH	[hMatchCurP],A		;
		LDH	[hMatchOldP],A		;

		LD	A,1			;Enable cursor.
		LDH	[hMatchIconFrm],A	;

		LD	A,LOW(MatchPickDoor)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchPickDoor)	;
		LDH	[hMatchJmp+2],A		;

		LDH	A,[hMatchPairs]		;
		DEC	A			;
		LDH	[hMatchPairs],A		;
		RET	NZ			;

		JR	MatchGameOver		;Signal game over.

MatchGameOver::	LD	A,DELAY_EXIT		;Initialize end delay.
		LD	[hMatchOver],A		;

		XOR	A			;Disable cursor.
		LDH	[hMatchIconFrm],A	;

		LD	A,LOW(MatchNoInput)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchNoInput)	;
		LDH	[hMatchJmp+2],A		;

MatchNoInput::	RET				;All Done.



; ***************************************************************************
; * MatchCloseDoor ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MatchCloseDoor::CALL	MatchMusic		;Ensure that music is playing.

		LD	A,[wJoy1Hit]		;Pause wanted ?
		BIT	JOY_START,A		;
		JR	Z,.Skip0		;

		LD	A,$FF			;
		LD	[wWantToPause],A	;
		RET				;

.Skip0:		XOR	A			;Disable cursor.
		LDH	[hMatchIconFrm],A	;

		LDH	A,[hMatchIconClk]	;Animate the door.
		OR	A			;
		JR	NZ,.Skip1		;

		LDH	A,[hMatchCurP]		;
		LD	C,A			;
		LD	B,HIGH(hTemp48)	;
		LDH	A,[hMatchOldP]		;
		LD	E,A			;
		LD	D,HIGH(hTemp48)	;

		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,BC			;
		SET	7,[HL]			;
		LD	HL,MATCH_FACE_TYP	;
		ADD	HL,DE			;
		SET	7,[HL]			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,BC			;
		LD	A,[HL]			;
		DEC	A			;
		AND	3			;
		LD	[HL],A			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,BC			;
		LD	[HL],A			;
		LD	HL,MATCH_DOOR_FRM	;
		ADD	HL,DE			;
		LD	[HL],A			;
		CP	1			;
		JR	Z,.Skip2		;
		LD	A,3			;

.Skip1:		DEC	A			;
		LDH	[hMatchIconClk],A	;
		RET				;

.Skip2:		XOR	A			;
		LDH	[hMatchCurP],A		;
		LDH	[hMatchOldP],A		;

		LD	A,1			;Enable cursor.
		LDH	[hMatchIconFrm],A	;

		LD	A,LOW(MatchPickDoor)	;Pick next door.
		LDH	[hMatchJmp+1],A		;
		LD	A,HIGH(MatchPickDoor)	;
		LDH	[hMatchJmp+2],A		;

		RET				;All Done.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF MATCHHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

