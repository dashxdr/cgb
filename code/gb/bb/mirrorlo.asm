; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** MIRRORLO.ASM                                                   MODULE **
; **                                                                       **
; ** Magic Mirror random game selection.                                   **
; **                                                                       **
; ** Last modified : 06 May 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"mirrorlo",HOME
		section 0

;
;
;

MIRROR_X	EQU	7
MIRROR_Y	EQU	5

;
;
;

TblMirror2Typ::	DB	MATCH_BEAST,SQR_BEAST
		DB	MATCH_BELLE,SQR_BELLE
		DB	MATCH_CHIP ,SQR_CHIP
		DB	MATCH_LEFOU,SQR_LEFOU
		DB	MATCH_LUMIR,SQR_LUMIR
		DB	MATCH_POTTS,SQR_POTTS
		DB	MATCH_POPPA,SQR_POPPA
		DB	MATCH_SULTN,SQR_SULTN

;
;
;

; ***************************************************************************
; * MirrorGame ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MirrorCPU::	LD	A,[wWhichPlyr]		;Use wWhichPlyr to determine
		CALL	GetPlyrInfo		;whether to play or fake
		LD	HL,PLYR_FLAGS		;the game.
		ADD	HL,BC			;
		BIT	PFLG_CPU,[HL]		;
		RET	Z			;

		ADD	SP,2			;Remove return address.

		LD	HL,TblMirror2Typ	;Select a random game.
		CALL	random			;
		SWAP	A			;
		AND	7			;
		ADD	A			;
		INC	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;

		RET				;All Done.



; ***************************************************************************
; * MirrorGame ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

hMirrorFaceTyp	EQUS	"hTemp48+$00"		;$01 bytes * 1
hMirrorFaceFrm	EQUS	"hTemp48+$01"		;$01 bytes * 1
hMirrorDoorFrm	EQUS	"hTemp48+$02"		;$01 bytes * 1
hMirrorFaceSqr	EQUS	"hTemp48+$03"		;$01 bytes * 1
hMirrorFrame	EQUS	"hTemp48+$04"		;$01 bytes * 1
hMirrorDelay	EQUS	"hTemp48+$05"		;$01 bytes * 1
hMirrorDelayLo	EQUS	"hTemp48+$06"		;$01 bytes * 1
hMirrorDelayHi	EQUS	"hTemp48+$07"		;$01 bytes * 1

MirrorGame::	CALL	MirrorCPU		;Called by CPU player ?

		LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(DumpOneMatch)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		LD	HL,IDX_CMIRROR4PKG	;Setup background.
		LD	DE,IDX_CMIRROR4PKG	;
		CALL	XferBitmap		;

		CALL	DmaBitmap20x18		;Copy the bitmap to vram.

		LD	DE,$9800		;Copy the colors to vram.
		CALL	DumpShadowAtr		;

		LD	A,%11100100		;Initialize PAL data and
		LD	[wFadeVblBGP],A		;override palettes from
		LD	[wFadeLycBGP],A		;XferBitmap.
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		CALL	FadeInBlack		;Fade in from black.

		LD	A,10			;
		CALL	AnyWait			;

		CALL	random			;Select a random starting
		SWAP	A			;face.
		AND	7			;
		LDH	[hMirrorFrame],A	;

		LD	HL,TblMirrorDly		;

.Loop0:		CALL	WaitForVBL		;

		LD	A,[HLI]			;
		OR	A			;
		JR	Z,.Done			;
		LDH	[hMirrorDelay],A	;
		LD	A,L			;
		LDH	[hMirrorDelayLo],A	;
		LD	A,H			;
		LDH	[hMirrorDelayHi],A	;

		LDH	A,[hMirrorFrame]	;
		INC	A			;
		AND	7			;
		LDH	[hMirrorFrame],A	;

		LD	HL,TblMirror2Typ	;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LDH	[hMirrorFaceTyp],A	;
		LD	A,[HLI]			;
		LDH	[hMirrorFaceSqr],A	;
		LD	A,1			;
		LDH	[hMirrorFaceFrm],A	;
		XOR	A			;
		LDH	[hMirrorDoorFrm],A	;

		LD	BC,hMirrorFaceTyp	;Dump this face to the screen.
		LD	D,MIRROR_X		;
		LD	E,MIRROR_Y		;
		CALL	DumpOneMatch		;

.Loop1:		CALL	WaitForVBL		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LDH	A,[hMirrorDelay]	;
		DEC	A			;
		LDH	[hMirrorDelay],A	;
		OR	A			;
		JR	NZ,.Loop1		;

		LDH	A,[hMirrorDelayLo]	;
		LD	L,A			;
		LDH	A,[hMirrorDelayHi]	;
		LD	H,A			;

		JR	.Loop0			;

.Done:		LD	A,60			;
		CALL	AnyWait			;

		CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	SetMachineJcb		;Reset machine to known state.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LDH	A,[hMirrorFaceSqr]	;

		RET				;All Done.

;
;
;

MirrorMusic::	LD	A,[wMzNumber]		;
		CP	A,SONG_TITLE		;
		RET	Z			;
		LD	A,SONG_TITLE		;
		JP	InitTunePref		;

;
;
;

TblMirrorDly::	DB	3,3,3,3,3,3,3,4,5,6,7,9,10,12,15,18,21,26,31
		DB	0



; ***************************************************************************
; * MirrorSelect ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MirrorICmd::	DB	ICMD_SPRON
		DW	wSprite0
		DB	76,100
		DW	DoButtonIcon
		DB	ICMD_END

MirrorSelect::	CALL	MirrorCPU		;Called by CPU player ?

		LDH	A,[hRomBank]		;Preserve ROM bank.
		PUSH	AF			;

		LD	A,BANK(DumpOneMatch)	;
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		CALL	ClrWorkspace		;Clear the game's workspace.

		CALL	KillAllSound		;

		CALL	SetBitmap20x18		;Reset machine for bitmap.

		LD	HL,IDX_CMIRROR4PKG	;Setup background.
		LD	DE,IDX_CMIRROR4PKG	;
		CALL	XferBitmap		;

		CALL	DmaBitmap20x18		;Copy the bitmap to vram.

		LD	DE,$9800		;Copy the colors to vram.
		CALL	DumpShadowAtr		;

		LD	A,MATCH_ARROW		;Dump the arrow markers
		LDH	[hMirrorFaceTyp],A	;to the screen.
		LD	A,0			;
		LDH	[hMirrorFaceSqr],A	;
		LD	A,1			;
		LDH	[hMirrorFaceFrm],A	;
		XOR	A			;
		LDH	[hMirrorDoorFrm],A	;
		LD	BC,hMirrorFaceTyp	;
		LD	D,MIRROR_X		;
		LD	E,MIRROR_Y-2		;
		CALL	DumpOneMatch		;

		CALL	InitIntro		;Init intro systems.

		LD	A,%11100100		;Initialize PAL data and
		LD	[wFadeVblBGP],A		;override palettes from
		LD	[wFadeLycBGP],A		;XferBitmap.
		LD	A,%11010000		;
		LD	[wFadeOBP0],A		;
		LD	A,%10010000		;
		LD	[wFadeOBP1],A		;

		LDH	A,[hMachine]		;
		CP	MACHINE_CGB		;
		JR	NZ,.Skip0		;

		CALL	ResSpritePal		;Initialize sprite palettes.
		LD	HL,PAL_CPRESS		;
		CALL	AddSpritePal		;

.Skip0:		LD	BC,MirrorICmd		;
		CALL	NextICmd		;

		CALL	FadeInBlack		;Fade in from black.

		XOR	A			;
		LDH	[hMirrorFrame],A	;

.Loop0:		LD	HL,wSprite0		;
		LD	DE,$DFD0		;
		LD	BC,$0030		;
		CALL	MemCopy			;

		LD	HL,TblMirror2Typ	;
		LDH	A,[hMirrorFrame]	;
		ADD	A			;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip1		;
		INC	H			;
.Skip1:		LD	A,[HLI]			;
		LDH	[hMirrorFaceTyp],A	;
		LD	A,[HLI]			;
		LDH	[hMirrorFaceSqr],A	;
		LD	A,1			;
		LDH	[hMirrorFaceFrm],A	;
		XOR	A			;
		LDH	[hMirrorDoorFrm],A	;

		LD	BC,hMirrorFaceTyp	;Dump this face to the screen.
		LD	D,MIRROR_X		;
		LD	E,MIRROR_Y		;
		CALL	DumpOneMatch		;

		LD	HL,$DFD0		;
		LD	DE,wSprite0		;
		LD	BC,$0030		;
		CALL	MemCopy			;
		XOR	A			;
		LD	[wSprite1+SPR_FLAGS],A	;
		LD	[wSprite2+SPR_FLAGS],A	;
		LD	[wSprite3+SPR_FLAGS],A	;
		LD	[wSprite4+SPR_FLAGS],A	;

.Loop1:		CALL	WaitForVBL		;
		CALL	WaitForVBL		;

		LDH	A,[hCycleCount]		;
		INC	A			;
		LDH	[hCycleCount],A		;

		CALL	ProcIntroSpr		;

		CALL	ReadJoypad		;Update joypads.
		CALL	ProcAutoRepeat		;

		LD	A,[wJoy1Hit]		;Wait for a button press.
		OR	A			;
		JR	Z,.Loop1		;

		BIT	JOY_L,A			;
		JR	NZ,.Left		;
		BIT	JOY_U,A			;
		JR	NZ,.Left		;
		BIT	JOY_R,A			;
		JR	NZ,.Right		;
		BIT	JOY_D,A			;
		JR	NZ,.Right		;

.Done:		CALL	WaitForRelease		;Wait for button release.

		CALL	FadeOutBlack		;Fade out to black.

		CALL	KillAllSound		;
		CALL	WaitForVBL		;

		CALL	SetMachineJcb		;Reset machine to known state.

		POP	AF			;Restore ROM bank.
		LDH	[hRomBank],A		;
		LD	[rMBC_ROM],A		;

		LDH	A,[hMirrorFaceSqr]	;

		RET				;All Done.

;
;
;

.Left:		LDH	A,[hMirrorFrame]	;
		DEC	A			;
		AND	7			;
		LDH	[hMirrorFrame],A	;
		JP	.Loop0			;

.Right:		LDH	A,[hMirrorFrame]	;
		INC	A			;
		AND	7			;
		LDH	[hMirrorFrame],A	;
		JP	.Loop0			;



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF MIRRORLO.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

