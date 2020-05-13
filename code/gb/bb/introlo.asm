; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** INTROLO.ASM                                                    MODULE **
; **                                                                       **
; ** Subgame introductions.                                                **
; **                                                                       **
; ** Last modified : 31 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

;		SECTION	"introlo",HOME
		section 0


; ***************************************************************************
; * TalkingHeads ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TalkingHeads::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(IntroCellar)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		PUSH	HL			;

;		CALL	KillAllSound		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		CALL	InitIntro		;Init intro systems.

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;
		LD	HL,PAL_CBUBBLE		;
		CALL	AddSpritePal		;

.Skip0:		POP	HL			;

		CALL	ProcIntroSeq		;

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		RET				;All Done.



; ***************************************************************************
; * ProcIntroSeq ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcIntroSeq::	LD	A,L			;Preserve sequence ptr.
		LDH	[hIntroSeqLo],A		;
		LD	A,H			;
		LDH	[hIntroSeqHi],A		;

		XOR	A			;
		LDH	[hIntroDone],A		;
		LDH	[hIntroDelay],A		;
		LD	A,MSK_ABORTABLE		;
		LDH	[hIntroFlags],A		;

.Loop0:		CALL	ProcICmd		;

		CALL	ReadJoypad		;Update joypads.

		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,.Loop1		;

		LD	A,[wJoy1Cur]		;Abort pressed ?
		BIT	JOY_START,A		;
		JR	NZ,.Done		;

.Loop1:		CALL	WaitForVBL		;Synchronize to the VBL.
		CALL	WaitForVBL		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		LDH	A,[hIntroDone]		;
		OR	A			;
		JR	NZ,.Done		;

		CALL	ProcIntroSpr		;

		CALL	ReadJoypad		;Update joypads.

		LDH	A,[hIntroDelay]		;Is there a timeout for this
		OR	A			;screen ?
		JR	Z,.Skip1		;

		DEC	A			;If so, has it expired ?
		LDH	[hIntroDelay],A		;
		JR	Z,.Loop0		;

		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,.Loop1		;

.Skip1:		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JR	Z,.Skip2		;

		LD	A,[wJoy1Cur]		;Abort pressed ?
		BIT	JOY_START,A		;
		JR	NZ,.Done		;

.Skip2:		LD	A,[wJoy1Hit]		;Wait for a button press.
		AND	MSK_JOY_START|MSK_JOY_SELECT|MSK_JOY_A|MSK_JOY_B
		JR	Z,.Loop1		;

		CALL	WaitForRelease		;Wait for button release.

		XOR	A			;Disable screen's timeout.
		LDH	[hIntroDelay],A		;

		JR	.Loop0			;

.Done:		CALL	WaitForRelease		;Wait for button release.

		LDH	A,[hIntroFlags]		;Disable final fadeout ?
		BIT	FLG_NOENDFADE,A		;
		RET	NZ			;

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SetMachineJcb		;Reset machine to known state.

		RET				;All Done.



; ***************************************************************************
; * InitIntro ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitIntro::	XOR	A			;Reset all sprites.
		LD	[wSprite0+SPR_FLAGS],A	;
		LD	[wSprite1+SPR_FLAGS],A	;
		LD	[wSprite2+SPR_FLAGS],A	;
		LD	[wSprite3+SPR_FLAGS],A	;

		LD	[wSprite4+SPR_FLAGS],A	;

		XOR	A			;
		LDH	[hIntroBlit],A		;
		LDH	[hIntroFlags],A		;
		LDH	[hIntroDelay],A		;

		LD	A,LOW(LycIntro)		;Setup mode's LYC and VBL
		LD	[wLycVector],A		;interrupt routines.
		LD	A,LOW(VblIntro)		;
		LD	[wVblVector],A		;

		RET				;All Done.



; ***************************************************************************
; * InitIntroSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to sprite's init data                            *
; *                                                                         *
; * Outputs     BC   = Updated                                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitIntroSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,[BC]			;Identify which sprite to
		INC	BC			;use.
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;
		LD	SP,HL			;

		LDHL	SP,SPR_SCR_X		;Init sprite position.
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS		;Init sprite flags.
		LD	[HL],MSK_EXEC		;

		LDHL	SP,SPR_EXEC		;Init sprite function.
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;

		XOR	A			;

		LDHL	SP,SPR_FRAME		;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LDHL	SP,SPR_COLR		;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLIP		;
		LD	[HLI],A			;

		LDHL	SP,SPR_OAM_CNT		;
		LD	[HLI],A			;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * ProcIntroSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcIntroSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wSprite0		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite1		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite2		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite3		;Process the individual
		CALL	ProcSprite		;sprites.

		LD	SP,wSprite4		;Process the individual
		CALL	ProcSprite		;sprites.

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		CALL	DumpIntroSpr		;Update sprite graphics.

		CALL	DrawIntroSpr		;

		RET				;All Done.



; ***************************************************************************
; * DumpIntroSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpIntroSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,[wFigPhase]		;Calc next character number.
		XOR	12			;
;		XOR	A
		LD	[wFigPhase],A		;
		LDH	[hSprNxt],A		;
		ADD	12			;
;		ADD	24			;
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

		LD	SP,wSprite0		;
		CALL	SprDump			;
		LD	SP,wSprite1		;
		CALL	SprDump			;
		LD	SP,wSprite2		;
		CALL	SprDump			;
		LD	SP,wSprite3		;
		CALL	SprDump			;

		LD	SP,wSprite4		;
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
; * DrawIntroSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawIntroSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LDH	A,[hOamPointer]		;Locate OAM shadow buffer.
		LD	D,A			;
		LD	E,0			;

		CALL	wJmpDraw		;Draw special sprites.

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wSprite0		;Draw regular sprites.
		CALL	SprDraw			;
		LD	SP,wSprite1		;
		CALL	SprDraw			;
		LD	SP,wSprite2		;
		CALL	SprDraw			;
		LD	SP,wSprite3		;
		CALL	SprDraw			;

		LD	SP,wSprite4		;
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
; * InitDaveAnim ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      BC   = Ptr to Dave's AS2 animation data                     *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitDaveAnim::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,LOW(DoNothing)	;Setup special sprite drawing
		LD	[wJmpDraw+1],A		;function.
		LD	A,HIGH(DoNothing)	;
		LD	[wJmpDraw+2],A		;

		XOR	A			;Reset all sprites.
		LD	[wSprite0+SPR_FLAGS],A	;
		LD	[wSprite1+SPR_FLAGS],A	;
		LD	[wSprite2+SPR_FLAGS],A	;
		LD	[wSprite3+SPR_FLAGS],A	;
		LD	[wSprite4+SPR_FLAGS],A	;

		LDH	[hDaveAnimRemap],A	;Reset frame 0 remapping.
		LDH	[hDaveAnimXFlip],A	;
		LDH	[hDaveAnimYFlip],A	;
		LDH	[hDaveAnimXMove],A	;
		LDH	[hDaveAnimYMove],A	;

		LD	A,[BC]			;
		INC	BC			;
		LDH	[hDaveAnimCnt],A	;
		LDH	[hTmpLo],A		;

		DI				;

		LD	SP,wSprite0		;

.Loop0:		LD	A,[BC]			;
		INC	BC			;
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;
		PUSH	BC			;
		CALL	AddSpritePal		;
		POP	BC			;

		LDHL	SP,SPR_ANM_1ST		;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLAGS		;
		LD	[HL],MSK_DRAW|MSK_PLOT	;

		XOR	A			;

		LDHL	SP,SPR_FRAME		;
		LD	[HLI],A			;
		LD	[HLI],A			;

		LDHL	SP,SPR_COLR		;
		LD	[HLI],A			;

		LDHL	SP,SPR_FLIP		;
		LD	[HLI],A			;

		LDHL	SP,SPR_OAM_CNT		;
		LD	[HLI],A			;

		LDHL	SP,SPR_SCR_X		;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;

		ADD	SP,$30			;

		LDH	A,[hTmpLo]		;
		DEC	A			;
		LDH	[hTmpLo],A		;
		JR	NZ,.Loop0		;

		EI				;

		LD	A,C			;
		LDH	[hDaveAnimTblLo],A	;
		LD	A,B			;
		LDH	[hDaveAnimTblHi],A	;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * MakeDaveAnim ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      A    = Frame number                                         *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MakeDaveAnim::	LD	[wSprPlotSP],SP		;Preserve SP.

		PUSH	AF			;
		LDH	A,[hDaveAnimCnt]	;
		LDH	[hTmpLo],A		;
		ADD	A			;
		ADD	A			;
		LD	C,A			;
		POP	AF			;
		DEC	A			;
		CALL	MultiplyBBW		;

		LDH	A,[hDaveAnimTblLo]	;
		LD	C,A			;
		LDH	A,[hDaveAnimTblHi]	;
		LD	B,A			;

		ADD	HL,BC			;
		LD	C,L			;
		LD	B,H			;

		DI				;

		LD	SP,wSprite0		;

.Loop0:		LDHL	SP,SPR_ANM_1ST		;
		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;
		LD	A,[BC]			;Get frm number.
		INC	BC			;
		OR	A			;
		JR	NZ,.Skip0		;
		LDH	A,[hDaveAnimRemap]	;
.Skip0:		CP	-1			;
		JR	NZ,.Skip1		;
		LD	DE,0			;
		JR	.Skip2			;
.Skip1:		ADD	E			;
		LD	E,A
		JR	NC,.Skip2		;
		INC	D			;
.Skip2:		LDHL	SP,SPR_FRAME		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDH	A,[hDaveAnimXFlip]	;
		LD	E,A			;

		LDHL	SP,SPR_FLIP		;
		LD	[HL],$20		;
		LD	A,[BC]			;
		XOR	E			;
		AND	$80			;
		JR	NZ,.Skip3		;
		LD	[HL],A			;
.Skip3:		NOP				;

		LDHL	SP,SPR_COLR		;
		LD	A,[BC]			;
		AND	$7F			;
		LD	[HL],A			;

		INC	BC			;

		LDHL	SP,SPR_SCR_X		;
		LDH	A,[hDaveAnimXMove]	;
		LD	D,A			;
		LDH	A,[hDaveAnimYMove]	;
		LD	E,A			;

.GetX:		LDH	A,[hDaveAnimXFlip]	;
		OR	A			;
		JR	NZ,.FlippedX		;
.RegularX:	LD	A,[BC]			;
		INC	BC			;
		JR	.GotX			;
.FlippedX:	LD	A,[BC]			;
		INC	BC			;
		CPL				;
		INC	A			;
.GotX:		ADD	D			;
		ADD	80			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;

.GetY:		LDH	A,[hDaveAnimYFlip]	;
		OR	A			;
		JR	NZ,.FlippedY		;
.RegularY:	LD	A,[BC]			;
		INC	BC			;
		JR	.GotY			;
.FlippedY:	LD	A,[BC]			;
		INC	BC			;
		CPL				;
		INC	A			;
.GotY:		ADD	E			;
		ADD	72			;
		LD	[HLI],A			;
		XOR	A			;
		LD	[HLI],A			;

		ADD	SP,-$30			;

		LDH	A,[hTmpLo]		;
		DEC	A			;
		LDH	[hTmpLo],A		;
		JR	NZ,.Loop0		;

		EI				;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		RET				;All Done.



; ***************************************************************************
; * IncDaveAnim ()                                                          *
; * SetDaveAnim ()                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IncDaveAnim::	LDH	A,[hDaveAnimDly]	;Frame delay finished ?
		DEC	A			;
		LDH	[hDaveAnimDly],A	;
		RET	NZ			;

		LDH	A,[hDaveAnimPtrLo]	;Get animation pointer.
		LD	C,A			;
		LDH	A,[hDaveAnimPtrHi]	;
		LD	B,A			;

SetDaveAnim::	LD	A,[BC]			;Read next frame offset.
		INC	BC			;
		LD	[hDaveAnimFrm],A	;

		LD	A,[BC]			;Read next frame delay.
		INC	BC			;
		LDH	[hDaveAnimDly],A	;

		OR	A			;Or has the animation
		JR	NZ,.Skip0		;finished ?

		XOR	A			;Reset all sprites.
		LDH	[hDaveAnimCnt],A	;

		RET				;

.Skip0:		LD	A,C			;Put animation pointer.
		LDH	[hDaveAnimPtrLo],A	;
		LD	A,B			;
		LDH	[hDaveAnimPtrHi],A	;

		LDH	A,[hDaveAnimFrm]	;
		OR	A			;
		RET	Z			;
		JP	MakeDaveAnim		;



; ***************************************************************************
; * ProcICmd ()                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcICmd::	LDH	A,[hIntroSeqLo]		;Load sequence ptr.
		LD	C,A			;
		LDH	A,[hIntroSeqHi]		;
		LD	B,A			;

NextICmd::	XOR	A			;Signal intro-in-progress.
		LDH	[hIntroDone],A		;

		LD	HL,TblICmdVectors	;
		LD	A,[BC]			;
		INC	BC			;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		JP	[HL]			;

;
;
;

TblICmdVectors::DW	ICmdEnd
		DW	ICmdHalt
		DW	ICmdFadeDn
		DW	ICmdFadeUp
		DW	ICmdFadeUpScr
		DW	ICmdDump
		DW	ICmdWipe
		DW	ICmdKillSound
		DW	ICmdPlayMusic
		DW	ICmdPrefMusic
		DW	ICmdFont
		DW	ICmdFontXor
		DW	ICmdNewPkg
		DW	ICmdUsePkg
		DW	ICmdSlowStr
		DW	ICmdFastStr
		DW	ICmdSlowStrP
		DW	ICmdFastStrP
		DW	ICmdSlowStrN
		DW	ICmdFastStrN
		DW	ICmdSprOn
		DW	ICmdSprOff
		DW	ICmdAttrList
		DW	ICmdAbortOff
		DW	ICmdAbortOn
		DW	ICmdDelay
		DW	ICmdJump
		DW	ICmdCall
		DW	ICmdRetn
		DW	ICmdNoEndFade
		DW	ICmdStrBounds
		DW	ICmdGetStr
		DW	ICmdSplitStr
		DW	ICmdIntroStr
		DW	ICmdLuckyStr
		DW	ICmdGastnStr
		DW	ICmdWhomStr

;
; ICMD_END -
;

ICmdEnd::	LD	A,$FF			;Signal end of intro.
		LDH	[hIntroDone],A		;

		XOR	A			;SAFETY MEASURE TO ENSURE
		LD	[wFontPalXor],A		;THAT OLD CODE WORKS

		DEC	BC			;Hang up on this command.
		JR	ICmdHalt		;

;
; ICMD_HALT -
;

ICmdHalt::	LD	A,C			;Save sequence ptr.
		LDH	[hIntroSeqLo],A		;
		LD	A,B			;
		LDH	[hIntroSeqHi],A		;

		XOR	A			;SAFETY MEASURE TO ENSURE
		LD	[wFontPalXor],A		;THAT OLD CODE WORKS

		RET				;All Done.

;
; ICMD_FADEDN -
;

ICmdFadeDn::	PUSH	BC			;

		CALL	FadeOutBlack		;Fade out to black.

		CALL	SprBlank		;Remove sprites.
		LDH	A,[hOamPointer]		;
		LDH	[hOamFlag],A		;
		CALL	WaitForVBL		;

		POP	BC			;

		XOR	A			;SAFETY MEASURE TO ENSURE
		LD	[wFontPalXor],A		;THAT OLD CODE WORKS

		JP	NextICmd		;

;
; ICMD_FADEUP -
;

ICmdFadeUp::	PUSH	BC			;

		CALL	DmaBitmap20x18		;Copy the bitmap to vram.

		LD	DE,$9800		;Copy the colors to vram.
		CALL	DumpShadowAtr		;

		CALL	ProcIntroSpr		;Update sprite graphics.

		CALL	FadeInBlack		;Fade in from black.

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_FADEUPSCR -
;

ICmdFadeUpScr::	PUSH	BC			;

		CALL	ProcIntroSpr		;Update sprite graphics.

		CALL	FadeInBlack		;Fade in from black.

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_DUMP -
;

ICmdDump::	PUSH	BC			;

		CALL	DmaBitmap20x18		;Copy the bitmap to vram.

		LD	DE,$9800		;Copy the colors to vram.
		CALL	DumpShadowAtr		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_WIPE -
;

ICmdWipe::	PUSH	BC			;

		CALL	ProcIntroSpr		;Update sprite graphics.
		CALL	WaitForVBL		;

		CALL	SloBitmap20x18		;Copy the bitmap to vram.

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_KILLSOUND -
;

ICmdKillSound::	PUSH	BC			;

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_PLAYMUSIC -
;

ICmdPlayMusic::	LD	A,[BC]			;Read tune number.
		INC	BC			;

		PUSH	BC			;

		CALL	InitTune		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_PREFMUSIC -
;

ICmdPrefMusic::	LD	A,[BC]			;Read tune number.
		INC	BC			;

		PUSH	BC			;

		CALL	InitTunePref		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_FONT -
;

ICmdFont::	LD	A,[BC]			;Initialize font.
		INC	BC			;
		LD	[wFontLo],A		;
		LD	A,[BC]			;
		INC	BC			;
		LD	[wFontHi],A		;

		JP	NextICmd		;

;
; ICMD_FONTXOR -
;

ICmdFontXor::	LD	A,[BC]			;Initialize font palette
		INC	BC			;override.
		LD	[wFontPalXor],A		;

		JP	NextICmd		;

;
; ICMD_NEWPKG -
;

ICmdNewPkg::	LD	A,[BC]			;Read GMB and CGB PKG id's.
		INC	BC			;
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	D,A			;

		LDH	A,[hMachine]		;Select which PKG to use.
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	L,E			;
		LD	H,D			;

.Skip0:		LD	A,L			;Save PKG file id.
		LDH	[hIntroPkgLo],A		;
		LD	A,H			;
		LDH	[hIntroPkgHi],A		;

		JR	ICmdUsePkg		;

;
; ICMD_USEPKG -
;

ICmdUsePkg::	PUSH	BC			;

		LDH	A,[hIntroPkgLo]		;
		LD	L,A			;
		LD	E,A			;
		LDH	A,[hIntroPkgHi]		;
		LD	H,A			;
		LD	D,A			;
		CALL	XferBitmap		;

		LD	A,%01100000		;
		LD	[wFadeOBP1],A		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_SLOWSTR -
;

ICmdSlowStr::	LD	L,C			;
		LD	H,B			;

		CALL	SlowStringLst		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		LD	A,[hIntroDone]		;Was the slow-print aborted ?
		OR	A			;
		JP	NZ,ICmdHalt		;

		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JP	Z,NextICmd		;

		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JP	Z,NextICmd		;

		INC	BC			;
		JP	ICmdEnd			;

;
; ICMD_FASTSTR -
;

ICmdFastStr::	LD	L,C			;
		LD	H,B			;

		CALL	DrawStringLst		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		JP	NextICmd		;

;
; ICMD_SLOWSTRP -
;

ICmdSlowStrP::	LD	L,C			;
		LD	H,B			;

		CALL	SlowStringLstP		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		LD	A,[hIntroDone]		;Was the slow-print aborted ?
		OR	A			;
		JP	NZ,ICmdHalt		;

		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JP	Z,NextICmd		;

		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JP	Z,NextICmd		;

		INC	BC			;
		JP	ICmdEnd			;

;
; ICMD_FASTSTRP -
;

ICmdFastStrP::	LD	L,C			;
		LD	H,B			;

		CALL	DrawStringLstP		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		JP	NextICmd		;

;
; ICMD_SLOWSTRN -
;

ICmdSlowStrN::	LD	L,C			;
		LD	H,B			;

		CALL	SlowStringLstN		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		LD	A,[hIntroDone]		;Was the slow-print aborted ?
		OR	A			;
		JP	NZ,ICmdHalt		;

		LDH	A,[hIntroFlags]		;Abort allowed ?
		BIT	FLG_ABORTABLE,A		;
		JP	Z,NextICmd		;

		LD	A,[wJoy1Cur]		;
		BIT	JOY_START,A		;
		JP	Z,NextICmd		;

		INC	BC			;
		JP	ICmdEnd			;

;
; ICMD_FASTSTRN -
;

ICmdFastStrN::	LD	L,C			;
		LD	H,B			;

		CALL	DrawStringLstN		;
		INC	HL			;

		LD	C,L			;
		LD	B,H			;

		JP	NextICmd		;

;
; ICMD_SPRON -
;

ICmdSprOn::	CALL	InitIntroSpr		;Initialize the sprite.

		JP	NextICmd		;

;
; ICMD_SPROFF -
;

ICmdSprOff::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,[BC]			;Identify which sprite to
		INC	BC			;use.
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;
		LD	SP,HL			;

		LDHL	SP,SPR_FLAGS		;Init sprite flags.
		LD	[HL],0			;

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		JP	NextICmd		;

;
; ICMD_ATTRLIST -
;

ICmdAttrList::	LD	A,[BC]			;Locate attribute list.
		INC	BC			;
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;

		PUSH	BC			;

		CALL	FillShadowLst		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_ABORTOFF -
;

ICmdAbortOff::	LD	HL,hIntroFlags		;Disable abort detection.
		RES	FLG_ABORTABLE,[HL]	;

		JP	NextICmd		;

;
; ICMD_ABORTON -
;

ICmdAbortOn::	LD	HL,hIntroFlags		;Disable abort detection.
		SET	FLG_ABORTABLE,[HL]	;

		JP	NextICmd		;

;
; ICMD_DELAY -
;

ICmdDelay::	LD	A,[BC]			;Read delay time.
		INC	BC			;
		LDH	[hIntroDelay],A		;

		JP	NextICmd		;

;
; ICMD_JUMP -
;

ICmdJump::	LD	A,[BC]			;Read jump address.
		INC	BC			;
		LD	L,A			;
		LD	A,[BC]			;
		LD	C,L			;
		LD	B,A			;

		JP	NextICmd		;

;
; ICMD_CALL -
;

ICmdCall::	LD	A,[BC]			;Read jump address.
		INC	BC			;
		LD	L,A			;
		LD	A,[BC]			;
		INC	BC			;
		LD	H,A			;

		LD	A,C			;
		LDH	[hIntroRtsLo],A		;
		LD	A,B			;
		LDH	[hIntroRtsHi],A		;

		LD	C,L			;
		LD	B,H			;

		JP	NextICmd		;

;
; ICMD_RETN -
;

ICmdRetn::	LDH	A,[hIntroRtsLo]		;
		LD	C,A			;
		LDH	A,[hIntroRtsHi]		;
		LD	B,A			;

		JP	NextICmd		;

;
; ICMD_NOENDFADE -
;

ICmdNoEndFade::	LD	HL,hIntroFlags		;Disable final fadeout.
		SET	FLG_NOENDFADE,[HL]	;

		JP	NextICmd		;

;
; ICMD_STRBOUNDS -
;

ICmdStrBounds::	LD	A,[BC]			;
		INC	BC			;
		LD	[wStringL1Width],A	;
		LD	A,[BC]			;
		INC	BC			;
		LD	[wStringL2Width],A	;
		LD	A,[BC]			;
		INC	BC			;
		LD	[wStringL3Width],A	;
		LD	A,[BC]			;
		INC	BC			;
		LD	[wStringL4Width],A	;
		LD	A,[BC]			;
		INC	BC			;
		LD	[wStringL5Width],A	;

		JP	NextICmd		;

;
; ICMD_GETSTR -
;

ICmdGetStr::	LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_SPLITSTR -
;

ICmdSplitStr::	LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		CALL	SplitString		;

		POP	BC			;

		JP	NextICmd		;

;
; ICMD_INTROSTR -
;

ICmdIntroStr::	LD	A,156			;Set intro text bounds.
		LD	[wStringL1Width],A	;
		LD	[wStringL2Width],A	;
		LD	[wStringL3Width],A	;
		LD	[wStringL4Width],A	;
		LD	[wStringL5Width],A	;

		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		CALL	SplitString		;

		LD	BC,ICmdIntro4L		;
		LD	A,[wStringLine4]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdIntro3L		;
		LD	A,[wStringLine3]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdIntro2L		;
		LD	A,[wStringLine2]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdIntro1L		;

.Print:		CALL	NextICmd		;

		POP	BC			;

		JP	NextICmd		;

ICmdIntro4L::	DB	ICMD_SLOWSTRP
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine4
		DB	0
		DB	ICMD_HALT

ICmdIntro3L::	DB	ICMD_SLOWSTRP
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	0
		DB	ICMD_HALT

ICmdIntro2L::	DB	ICMD_SLOWSTRP
		DB	80, 29+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	80, 29+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	0
		DB	ICMD_HALT

ICmdIntro1L::	DB	ICMD_SLOWSTRP
		DB	80, 37+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	0
		DB	ICMD_HALT

;
; ICMD_LUCKYSTR -
;

ICmdLuckyStr::	LD	A,LOW(FontLite)		;
		LD	[wFontLo],A		;
		LD	A,HIGH(FontLite)	;
		LD	[wFontHi],A		;

		LD	A,118			;Set intro text bounds.
		LD	[wStringL1Width],A	;
		LD	[wStringL2Width],A	;
		LD	[wStringL3Width],A	;
		LD	[wStringL4Width],A	;
		LD	[wStringL5Width],A	;

		LD	A,[BC]			;
		INC	BC			;
		LD	E,A			;
		LD	D,0			;

		PUSH	BC			;

		CALL	GetString		;Get the string.

		CALL	SplitString		;

		LD	BC,ICmdLucky4L		;
		LD	A,[wStringLine4]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdLucky3L		;
		LD	A,[wStringLine3]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdLucky2L		;
		LD	A,[wStringLine2]	;
		OR	A			;
		JR	NZ,.Print		;

		LD	BC,ICmdLucky1L		;

.Print:		CALL	NextICmd		;

		POP	BC			;

		JP	NextICmd		;

ICmdLucky4L::	DB	ICMD_FASTSTRP
		DB	96,108+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	96,108+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	96,108+2*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	96,108+3*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine4
		DB	0
		DB	ICMD_HALT

ICmdLucky3L::	DB	ICMD_FASTSTRP
		DB	96,113+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	96,113+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	96,113+2*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	0
		DB	ICMD_HALT

ICmdLucky2L::	DB	ICMD_FASTSTRP
		DB	96,118+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	96,118+1*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	0
		DB	ICMD_HALT

ICmdLucky1L::	DB	ICMD_FASTSTRP
		DB	96,123+0*10,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	0
		DB	ICMD_HALT



; ***************************************************************************
; * DoBubbleLhs ()                                                          *
; * DoBubbleRhs ()                                                          *
; ***************************************************************************
; * Speech bubble sprite                                                    *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

DoBubbleLhs::	LDHL	SP,SPR_FLIP+2		;
		LD	[HL],$00		;

		JR	DoBubbleBoth		;

DoBubbleRhs::	LDHL	SP,SPR_FLIP+2		;
		LD	[HL],$20		;

		JR	DoBubbleBoth		;

DoBubbleBoth::	LDHL	SP,SPR_COLR+2		;
		LD	[HL],$11		;

		LD	DE,IDX_CBUBBLE		;

		LDHL	SP,SPR_ANM_1ST+2	;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	DE,AnmBubble		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		LD	DE,DoSprAnimWait	;
		LD	DE,DoSprAnimHalt	;
		CALL	SetSpriteFnc		;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_EXEC+MSK_DRAW+MSK_PLOT

DoSprAnimHalt::	RET				;

DoSprAnimWait::	CALL	IncSpriteAnm		;Update animation.

		LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		LD	[HL],0			;Disable this sprite.

		RET				;All Done.

AnmBubble::	DB	1,1,1,0



; ***************************************************************************
; * DoButtonIcon ()                                                         *
; ***************************************************************************
; * Icon for "Press a Button"                                               *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

DoButtonIcon2::	LD	A,3			;
		JR	DoButtonBoth		;

DoButtonIcon::	XOR	A			;

DoButtonBoth::	LDHL	SP,SPR_COLR+2		;
		LD	[HL],A			;

		LDHL	SP,SPR_FLIP+2		;
		LD	[HL],$00		;

		LD	DE,IDX_CPRESS		;

		LDHL	SP,SPR_ANM_1ST+2	;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LD	DE,AnmButton		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		LD	DE,DoButtonAnim		;
		CALL	SetSpriteFnc		;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_EXEC+MSK_DRAW+MSK_PLOT

		RET				;

DoButtonAnim::	CALL	IncSpriteAnm		;Update animation.

		LDHL	SP,SPR_FLAGS+2		;Wait until animation is
		BIT	FLG_ANM,[HL]		;finished.
		RET	NZ			;

		LD	DE,AnmButton		;Initialize the appearance
		CALL	SetSpriteAnm		;animation.

		RET				;All Done.

AnmButton::	DB	1,BUTTON_UP_DELAY
		DB	2,BUTTON_DN_DELAY
		DB	2,0



; ***************************************************************************
; * DoSmallMarker ()                                                        *
; ***************************************************************************
; * Icon for plyr's small marker                                            *
; ***************************************************************************
; * Inputs      SP+2 = Ptr to sprite's info structure                       *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   BC                                                          *
; ***************************************************************************

DoSmallMarker::	LD	A,[wWhichPlyr]		;
		CALL	GetPlyrInfo		;

		LD	HL,PLYR_BSMARK		;
		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;
		LD	HL,PLYR_CSMARK		;
.Skip0:		ADD	HL,DE			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LDHL	SP,SPR_FRAME+2		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	A,D			;
		LD	[HLI],A			;

		LDHL	SP,SPR_COLR+2		;
		LD	[HL],$00		;

		LDHL	SP,SPR_FLIP+2		;
		LD	[HL],$00		;

		LDHL	SP,SPR_FLAGS+2		;
		LD	[HL],MSK_DRAW+MSK_PLOT	;

		RET				;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF INTROLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************




; ***************************************************************************
; * ProcStaticSpr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ProcStaticSpr::	LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wSprite0		;Process the individual
		CALL	ProcSprite		;sprites.

		LD	SP,wSprite1		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite2		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite3		;Process the individual
		CALL	ProcSprite		;sprites.
		LD	SP,wSprite4		;Process the individual
		CALL	ProcSprite		;sprites.

		LD	HL,wSprPlotSP		;Restore SP.
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;
		LD	SP,HL			;

		CALL	DumpStaticSpr		;Update sprite graphics.

		CALL	DrawStaticSpr		;

		RET				;All Done.



; ***************************************************************************
; * DumpStaticSpr ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DumpStaticSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	A,[wFigPhase]		;Calc next character number.
		XOR	4			;
		LD	[wFigPhase],A		;
		LDH	[hSprNxt],A		;
		ADD	4			;
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

		LD	SP,wSprite0		;
		CALL	SprDump			;

		LD	A,8			;Calc next character number.
		LDH	[hSprNxt],A		;
		LD	A,24			;
		LDH	[hSprMax],A		;

		LD	BC,$8080		;

		LD	SP,wSprite1		;
		CALL	SprDump			;
		LD	SP,wSprite2		;
		CALL	SprDump			;
		LD	SP,wSprite3		;
		CALL	SprDump			;
		LD	SP,wSprite4		;
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
; * DrawStaticSpr ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

DrawStaticSpr::	LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LDH	A,[hOamPointer]		;Locate OAM shadow buffer.
		LD	D,A			;
		LD	E,0			;

		CALL	wJmpDraw		;Draw special sprites.

		LD	[wSprPlotSP],SP		;Preserve SP.

		LD	SP,wSprite0		;Draw regular sprites.
		CALL	SprDraw			;

		LD	SP,wSprite1		;Locate the frontmost icon.
		LD	A,[wFrontPlyr]		;
		AND	3			;
		JR	Z,.Skip0		;
.Loop0:		ADD	SP,-$30			;
		DEC	A			;
		JR	NZ,.Loop0		;

.Skip0:		LD	A,4			;Draw the 4 icon sprites.
.Loop1:		LD	[wFrontLoop],A		;
		CALL	SprDraw			;
		ADD	SP,-$30			;
		LD	HL,0
		ADD	HL,SP
		LD	BC,wSprite5
		LD	A,C
		SUB	L
		LD	A,B
		SBC	H
		JR	NZ,.Skip1
;		LD	HL,$FFFF&(0-wSprite5)	;
;		ADD	HL,SP			;
;		LD	A,H			;
;		OR	L			;
;		JR	NZ,.Skip1		;
		LD	SP,wSprite1		;
.Skip1:		LD	A,[wFrontLoop]		;
		DEC	A			;
		JR	NZ,.Loop1		;

;		LD	SP,wSprite1		;
;		CALL	SprDraw			;
;		LD	SP,wSprite2		;
;		CALL	SprDraw			;
;		LD	SP,wSprite3		;
;		CALL	SprDraw			;
;		LD	SP,wSprite4		;
;		CALL	SprDraw			;

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
.Loop2:		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		LD	[HLI],A			;
		DEC	E			;
		JR	NZ,.Loop2		;

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





