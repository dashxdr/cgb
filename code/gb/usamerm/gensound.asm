; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** GENSOUND.ASM                                                   MODULE **
; **                                                                       **
; ** Sound driver and music data.                                          **
; ** (included in sound1.asm and sound2.asm)                               **
; ** Last modified : 31 Oct 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;
; Music commands.
;
; *+ LOOP      ,n      Repeat next sequence 'n' times.
;                      n=[1 to 255,0=256].
;
; *+ TRANS     ,t      Transpose next sequence by 't' notes.
;                      t=[-128 to +127].
;
; *  JUMP      ,a      Jump to 16-bit address 'a'.
;
; *  END               End tune/fx/sequence.
;
;    LENGTH    ,l      Assume all notes have length 'l' until MANUAL.
;                      l=[1 to 255].
;
;    MANUAL            Assume each note is followed by a length.
;
;    TIE               Increase length of next note by 256.
;
;    REST              Play an empty note.
;
;    GLION     ,t,l    Glide to note from transpose 't'/2 over 'l' frames.
;                      'l' MUST be a power of 2.
;                      N.B. Cancels EFFON.
;
;    GLIOFF            Cancel GLION.
;
;    EFFON     ,t,l    Transpose notes by 't' for their 1st 'l' frames.
;                      N.B. Cancels GLION.
;
;    EFFOFF            Cancel EFFON.
;
;    ARPON     ,n      Arpeggio, using arpeggio table number 'n'.
;                      N.B. Cancels VIBON.
;
;    ARPOFF            Cancel ARPON.
;
;    VIBON     ,d,t,l  Vibrato, delay 'd', amplitude 't'/4, over 4'l' frames.
;                      N.B. Cancels ARPON.
;
;    VIBOFF            Cancel VIBON.
;
;    ENV       ,n      Use volume envelope 'n'.
;
;    DRUM      ,n      Play a 'drum'.
;
;    POKE      ,a,n    Poke location $FFaa with value 'n'.
;
;    WAVE      ,n,...  Set up the 16 bytes of waveform RAM and store ptr.
;
;    TMP_WAVE  ,n,...  Set up the waveform RAM.
;
;    OLD_WAVE          Set up the waveform RAM from the stored address.
;
;    DUTY      ,n      Set the duty register to 'n'.
;
;    SWEEP     ,v,l,n  Special glide. Sweep from note 'n' by subtracting
;                      'v' from the frequency (word value - hi/lo) for 'l'
;                      frames.
;
;    HWREGS    ,e,l,h  Set registers directly e=envelope, l,h=period.
;
; * Only these commands can be used in a sequence list.
; + These commands cannot be used in a sequence.
;
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

MAKE_NOISE	EQU	0

LOOP		EQU	$C0
TRANS		EQU	$C2
JUMP		EQU	$C4
END		EQU	$C6
EXIT		EQU	$C8
LENGTH		EQU	$CA
MANUAL		EQU	$CC
TIE		EQU	$CE
REST		EQU	$D0
GLION		EQU	$D2
GLIOFF		EQU	$D4
EFFON		EQU	$D6
EFFOFF		EQU	$D8
VIBON		EQU	$DA
VIBOFF		EQU	$DC
ARPON		EQU	$DE
ARPOFF		EQU	$E0
ENV		EQU	$E2
DRUM		EQU	$E4
POKE		EQU	$E6
WAVE		EQU	$E8
TMP_WAVE	EQU	$EA
OLD_WAVE	EQU	$EC
DUTY		EQU	$EE
SWEEP		EQU	$F0
HWREGS		EQU	$F2

;
; Note equates.
;

C1		EQU	0
CS1		EQU	1
D1		EQU	2
DS1		EQU	3
E1		EQU	4
F1		EQU	5
FS1		EQU	6
G1		EQU	7
GS1		EQU	8
A1		EQU	9
AS1		EQU	10
B1		EQU	11
C2		EQU	12
CS2		EQU	13
D2		EQU	14
DS2		EQU	15
E2		EQU	16
F2		EQU	17
FS2		EQU	18
G2		EQU	19
GS2		EQU	20
A2		EQU	21
AS2		EQU	22
B2		EQU	23
C3		EQU	24
CS3		EQU	25
D3		EQU	26
DS3		EQU	27
E3		EQU	28
F3		EQU	29
FS3		EQU	30
G3		EQU	31
GS3		EQU	32
A3		EQU	33
AS3		EQU	34
B3		EQU	35
C4		EQU	36
CS4		EQU	37
D4		EQU	38
DS4		EQU	39
E4		EQU	40
F4		EQU	41
FS4		EQU	42
G4		EQU	43
GS4		EQU	44
A4		EQU	45
AS4		EQU	46
B4		EQU	47
C5		EQU	48
CS5		EQU	49
D5		EQU	50
DS5		EQU	51
E5		EQU	52
F5		EQU	53
FS5		EQU	54
G5		EQU	55
GS5		EQU	56
A5		EQU	57
AS5		EQU	58
B5		EQU	59
C6		EQU	60
CS6		EQU	61
D6		EQU	62
DS6		EQU	63
E6		EQU	64
F6		EQU	65
FS6		EQU	66
G6		EQU	67
GS6		EQU	68
A6		EQU	69
AS6		EQU	70
B6		EQU	71
C7		EQU	72
CS7		EQU	73
D7		EQU	74
DS7		EQU	75
E7		EQU	76
F7		EQU	77
FS7		EQU	78
G7		EQU	79
GS7		EQU	80
A7		EQU	81
AS7		EQU	82
B7		EQU	83

C8		EQU	84
CS8		EQU	85
D8		EQU	86
DS8		EQU	87
E8		EQU	88
F8		EQU	89
FS8		EQU	90
G8		EQU	91
GS8		EQU	92
A8		EQU	93
AS8		EQU	94
B8		EQU	95

;
; MZ_STATUS bit settings.
;

MZ_FLG_ON	EQU	7

;
; MZ_FLAGS bit settings
;

MZ_FLG_EFF_V	EQU	0
MZ_FLG_GLI_V	EQU	1
MZ_FLG_DRUM	EQU	2
MZ_FLG_REST	EQU	3
MZ_FLG_EFF	EQU	4
MZ_FLG_GLI	EQU	5
MZ_FLG_VIB	EQU	6
MZ_FLG_ARP	EQU	7

;
; Channel related variables.
;

MZ_RET		EQU	0			;(W) Return address.
MZ_STATUS	EQU	2			;(B)
MZ_FLAGS	EQU	3			;(B)
MZ_SEQ_CURR	EQU	4			;(W)
MZ_LST_CURR	EQU	6			;(W)
MZ_SEQ_LOOP	EQU	8			;(B)
MZ_SEQ_TRAN	EQU	9			;(B)
MZ_NOTE		EQU	10			;(B)
MZ_EFF_TRAN	EQU	11			;(B)
MZ_EFF_LEN	EQU	12			;(B)
MZ_EFF_LEN_V	EQU	13			;(B)
MZ_ENVELOPE	EQU	14			;(B)
MZ_VOLUME	EQU	15			;(B)
MZ_PERIOD	EQU	16			;(W)
MZ_DUTY		EQU	18			;(B)
MZ_AUTO_LEN	EQU	19			;(B)
MZ_NOTE_LEN	EQU	20			;(W)
MZ_GLI_TRAN	EQU	22			;(B)
MZ_GLI_LEN	EQU	23			;(B)
MZ_GLI_LEN_V	EQU	24			;(B)
MZ_GLI_DELTA	EQU	25			;(W)
MZ_VIB_LEN	EQU	27			;(B)
MZ_VIB_LEN_V	EQU	28			;(B)
MZ_VIB_DELTA	EQU	29			;(W)
MZ_VIB_DEL_V	EQU	31			;(B)
MZ_VIB_DEL	EQU	32			;(B)
MZ_VIB_TRAN	EQU	33			;(B)
MZ_ARP_BASE	EQU	34			;(W)
MZ_ARP_CURR	EQU	36			;(W)
MZ_DRUM_CURR	EQU	38			;(W)

CHANNEL_LENGTH	EQU	40



; ***************************************************************************
; * KillAllSound ()                                                         *
; ***************************************************************************
; * Kill all music and sound effects                                        *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillAllSoundB:
		CALL	KillSfxB1
		CALL	KillTuneB1

		XOR	A
		LD	[wMzPlaying],A
		LDIO	[rNR30],A
		LDIO	[rNR50],A
		LDIO	[rNR51],A
		LDIO	[rNR52],A

		RET



; ***************************************************************************
; * KillTune ()                                                             *
; ***************************************************************************
; * Kill all music                                                          *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillTuneB:	XOR	A
		LD	[wMzNumber],A

		JP	InitTuneB1

;		LD	[wMzChannel1+MZ_STATUS],A
;		LD	[wMzChannel2+MZ_STATUS],A
;		LD	[wMzChannel3+MZ_STATUS],A
;		LD	[wMzChannel4+MZ_STATUS],A
;		LD	[wMzChannel1+MZ_VOLUME],A
;		LD	[wMzChannel2+MZ_VOLUME],A
;		LD	[wMzChannel3+MZ_VOLUME],A
;		LD	[wMzChannel4+MZ_VOLUME],A
;
;		RET



; ***************************************************************************
; * KillSfx ()                                                              *
; ***************************************************************************
; * Kill all sound effects                                                  *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

KillSfxB:	XOR	A
		LD	[wFxNumber],A
		LD	[wFxChannel1+MZ_STATUS],A
		LD	[wFxChannel2+MZ_STATUS],A
		LD	[wFxChannel3+MZ_STATUS],A
		LD	[wFxChannel4+MZ_STATUS],A

		RET



; ***************************************************************************
; * InitTune ()                                                             *
; ***************************************************************************
; * Start up a tune                                                         *
; ***************************************************************************
; * Inputs      A = Tune number                                             *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitTuneB:	OR	A			;
		JR	Z,.Skip0		;
		LD	L,A			;
		LD	A,[wMzNumber]		;
		CP	L			;
		RET	Z			;
		LD	A,L			;
.Skip0:		LD	[wMzNumber],A		;

		LD	L,A			;Multiply by 8 to get offset.
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;

		LD	A,L			;Use as index into MZ_TUNE_TABLE.
		LD	DE,TblMzTune
		ADD	E			;
		LD	E,A			;
		LD	A,0			;
		ADC	D			;
		LD	D,A			;

		LD	A,$80			;
		LDIO	[rNR52],A		;
		LD	A,$80			;
		LDIO	[rNR30],A		;
		LD	A,$00			;
		LDIO	[rNR10],A		;
		LD	A,$FF			;
		LDIO	[rNR51],A		;
		LD	A,$77			;
		LDIO	[rNR50],A		;

		LD	HL,wMzChannel1+MZ_STATUS;
		CALL	InitMzChannel		;
		LD	HL,wMzChannel2+MZ_STATUS;
		CALL	InitMzChannel		;
		LD	HL,wMzChannel3+MZ_STATUS;
		CALL	InitMzChannel		;
		LD	HL,wMzChannel4+MZ_STATUS;

InitMzChannel:	LD	A,[DE]			;Get the ptr to the sequence
		INC	DE			;list.
		LD	C,A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	B,A			;
		OR	C			;
		RET	Z			;Skip this channel if zero.

		LD	[HL],$80		;Initialize MZ_STATUS.
		INC	HL			;
		LD	[HL],$00		;Initialize MZ_FLAGS.
		INC	HL			;
		PUSH	BC
		LD	BC,DummyMzSeq
		LD	A,C			;Initialize MZ_SEQ_CURR.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		POP	BC
		DEC	BC			;Initialize MZ_LST_CURR.
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,1			;Initialize MZ_SEQ_REPEAT.
		LD	[HLI],A			;

		LD	BC,MZ_DUTY-MZ_SEQ_TRAN
		ADD	HL,BC

		XOR	A
		LD	[HLI],A			;Initialize MZ_DUTY
		LD	[HLI],A			;Initialize MZ_AUTO_LEN.
		INC	A			;
		LD	[HLI],A			;Initialize MZ_NOTE_LEN.
		LD	[HLI],A			;

		RET				;

DummyMzSeq:	DB	END			;



; ***************************************************************************
; * InitSfx ()                                                              *
; ***************************************************************************
; * Start up a sound effect                                                 *
; ***************************************************************************
; * Inputs      A = Effect number                                           *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

InitSfxB:	PUSH	AF

		LD	A,$80			;
		LDIO	[rNR52],A		;
		LD	A,$80			;
		LDIO	[rNR30],A		;
		LD	A,$00			;
		LDIO	[rNR10],A		;
		LD	A,$FF			;
		LDIO	[rNR51],A		;
		LD	A,$77			;
		LDIO	[rNR50],A		;

		IF	MAKE_NOISE
		LDIO	[rNR43],A		;Override noise.
		LD	A,$00			;
		LDIO	[rNR41],A		;
		LD	A,$F0			;
		LDIO	[rNR42],A		;
		LD	A,$80			;
		LDIO	[rNR44],A		;
		RET				;
		ENDC

		POP	AF			;

		OR	A			;
		RET	Z			;

		LD	[wFxNumber],A		;

		DEC	A			;Multiply by 8 to get offset.
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,HL			;
		ADD	HL,HL			;

		LD	A,L			;Use as index into MZ_FX_TABLE.
		LD	DE,TblFxList		;
		ADD	HL,DE			;
		LD	D,H			;
		LD	E,L			;

		LD	HL,wFxChannel1+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel2+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel3+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel4+MZ_STATUS;

InitFxChannel:	LD	A,[DE]			;Get the ptr to the sequence
		INC	DE			;list.
		LD	C,A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	B,A			;
		OR	C			;
		RET	Z			;Skip this channel if zero.

		LD	A,B			;Is this effect has bit 7
		AND	[HL]			;set and the channel is
		ADD	A			;already busy, then skip.
		RET	C			;

		RES	7,B			;Reset low-priority flag.

		LD	A,$80			;Initialize MZ_STATUS.
		LD	[HLI],A			;
		LD	A,$00			;Initialize MZ_FLAGS.
		LD	[HLI],A			;
		LD	A,C			;Initialize MZ_SEQ_CURR.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	BC,DummyFxLst-1
		LD	A,C			;Initialize MZ_LST_CURR.
		LD	[HLI],A			;
		LD	A,B			;better not cross page...
		LD	[HLI],A			;
		LD	A,1			;Initialize MZ_SEQ_REPEAT.
		LD	[HLI],A			;

		LD	BC,MZ_DUTY-MZ_SEQ_TRAN
		ADD	HL,BC

		XOR	A
		LD	[HLI],A			;Initialize MZ_DUTY
		LD	[HLI],A			;Initialize MZ_AUTO_LEN.
		INC	A			;
		LD	[HLI],A			;Initialize MZ_NOTE_LEN.
		LD	[HLI],A			;

		RET				;

DummyFxLst:	DB	END			;



; ***************************************************************************
; * PlayingSfx ()                                                           *
; ***************************************************************************
; * Check if a sound effect if playing                                      *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     NZ if still playing                                         *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

PlayingSfxB:	LD	A,[wFxChannel1+MZ_STATUS]
		OR	A
		RET	NZ
		LD	A,[wFxChannel2+MZ_STATUS]
		OR	A
		RET	NZ
		LD	A,[wFxChannel3+MZ_STATUS]
		OR	A
		RET	NZ
		LD	A,[wFxChannel4+MZ_STATUS]
		OR	A
		RET



; ***************************************************************************
; * MzRefresh ()                                                            *
; ***************************************************************************
; * 60Hz sound refresh routine                                              *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MzRefresh:	LD	HL,wMzShift
		RRC	[HL]
		JR	NC,MzRefreshSingle

MzRefreshDouble:CALL	MzRefreshFX
		JP	MzRefreshMZ

MzRefreshSingle:
MzRefreshFX:
		LD	[wMzSP],SP

		IF	MAKE_NOISE
		RET
		ENDC

		LD	SP,wFxChannel1+2
		LD	A,LOW(hShadowNR12)
		CALL	Mz60Hz
		LD	SP,wFxChannel2+2
		LD	A,LOW(hShadowNR22)
		CALL	Mz60Hz
		LD	SP,wFxChannel3+2
		LD	A,LOW(hShadowNR32)
		CALL	Mz60Hz
		LD	SP,wFxChannel4+2
		LD	A,LOW(hShadowNR42)
		CALL	Mz60Hz

		JR	MzRefreshMZb

MzRefreshMZ:	LD	[wMzSP],SP

		IF	MAKE_NOISE
		RET
		ENDC

MzRefreshMZb:
		XOR	A
		LD	[wMzPlaying],A

		LD	SP,wMzChannel1+2
		LD	A,LOW(hShadowNR12)
		CALL	Mz60Hz
		LD	SP,wMzChannel2+2
		LD	A,LOW(hShadowNR22)
		CALL	Mz60Hz
		LD	SP,wMzChannel3+2
		LD	A,LOW(hShadowNR32)
		CALL	Mz60Hz
		LD	SP,wMzChannel4+2
		LD	A,LOW(hShadowNR42)
		CALL	Mz60Hz

		LD	HL,wMzSP
		LD	A,[HLI]
		LD	H,[HL]
		LD	L,A
		LD	SP,HL

;		LD	HL,wFxChannel1+MZ_STATUS
;		LD	A,[HL]
;		OR	A
;		JR	NZ,.Skip0
;		LD	HL,wMzChannel1+MZ_STATUS
;.Skip0:	BIT	6,[HL]
;		JR	NZ,.Skip1
;		LD	DE,MZ_VOLUME-MZ_STATUS
;		ADD	HL,DE
;.Skip1:	LD	A,[HLI]
;		CP	$FF
;		JR	Z,.Skip2
;		LDIO	[rNR12],A
;		LDH	[hShadowNR12],A
;.Skip2:	LD	A,[HLI]
;		LDIO	[rNR13],A
;		LD	A,[HLI]
;		LDIO	[rNR14],A
;		LD	A,[HLI]
;		LDIO	[rNR11],A

		LD	HL,wFxChannel1+MZ_VOLUME
		LD	A,[wFxChannel1+MZ_STATUS]
		OR	A
		JR	NZ,MzRefresh1a
		LD	HL,wMzChannel1+MZ_VOLUME
MzRefresh1a:	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh1b
		LDIO	[rNR12],A
		LDH	[hShadowNR12],A
MzRefresh1b:	LD	A,[HLI]
		LDIO	[rNR13],A
		LD	A,[HLI]
		LDIO	[rNR14],A
		LD	A,[HLI]
		LDIO	[rNR11],A

		LD	HL,wFxChannel2+MZ_VOLUME
		LD	A,[wFxChannel2+MZ_STATUS]
		OR	A
		JR	NZ,MzRefresh2a
		LD	HL,wMzChannel2+MZ_VOLUME
MzRefresh2a:	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh2b
		LDIO	[rNR22],A
		LDH	[hShadowNR22],A
MzRefresh2b:	LD	A,[HLI]
		LDIO	[rNR23],A
		LD	A,[HLI]
		LDIO	[rNR24],A
		LD	A,[HLI]
		LDIO	[rNR21],A

		LD	HL,wFxChannel3+MZ_VOLUME
		LD	A,[wFxChannel3+MZ_STATUS]
		OR	A
		JR	NZ,MzRefresh3a
		LD	HL,wMzChannel3+MZ_VOLUME
MzRefresh3a:	LD	A,[HLI]
		CP	$FF

		IF	1
		JR	Z,MzRefresh3c
		AND	$60
		LDH	[hShadowNR32],A
		LDIO	[rNR32],A
		JR	MzRefresh3c
		ELSE
		JR	Z,MzRefresh3b
		AND	$60
		LDH	[hShadowNR32],A
		JR	Z,MzRefresh3b
		LDH	[hActualNR32],A
		LDIO	[rNR32],A
		JR	MzRefresh3c
MzRefresh3b:	LDH	A,[hShadowNR32]
		LD	C,A
		LDH	A,[hActualNR32]
		CP	C
		JR	Z,MzRefresh3c
		ADD	$20
		AND	$60
		LDH	[hActualNR32],A
		LDIO	[rNR32],A
		INC	HL
		SET	7,[HL]
		DEC	HL
		ENDC

MzRefresh3c:	LD	A,[HLI]
		LDIO	[rNR33],A
		LD	A,[HLI]
		AND	$7F
		LDIO	[rNR34],A
		XOR	A
		LDIO	[rNR31],A

		LD	HL,wFxChannel4+MZ_VOLUME
		LD	A,[wFxChannel4+MZ_STATUS]
		OR	A
		JR	NZ,MzRefresh4a
		LD	HL,wMzChannel4+MZ_VOLUME
MzRefresh4a:	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh4b
		LDIO	[rNR42],A
		LDH	[hShadowNR42],A
MzRefresh4b:	LD	A,[HLI]
		LDIO	[rNR43],A
		LD	A,[HLI]
		LDIO	[rNR44],A
		XOR	A
		LDIO	[rNR41],A

		LD	A,[wMzPlaying]		;
		OR	A			;
		RET	NZ			;
		LD	[wMzNumber],A		;
		RET				;



; ***************************************************************************
; * Mz60Hz ()                                                               *
; ***************************************************************************
; * 60Hz sound refresh routine                                              *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

Mz60Hz:	LDHL	SP,MZ_STATUS		;Test MZ_STATUS.
		BIT	MZ_FLG_ON,[HL]		;
		RET	Z			;

		LDH	[hChannelVol],A		;Preserve which channel.

		LD	[wMzPlaying],A		;Signal that a channel is on.

		LDHL	SP,MZ_FLAGS		;Get MZ_FLAGS.
		LD	B,[HL]			;

		LDHL	SP,MZ_VOLUME		;Cancel further volume writes.
		LD	[HL],$FF		;

		LDHL	SP,MZ_PERIOD+1		;Reset INITIAL flag.
		RES	7,[HL]			;

		LDHL	SP,MZ_NOTE_LEN		;Note finished ?
		DEC	[HL]			;
		JP	NZ,MzOldNote		;
		INC	HL			;
		DEC	[HL]			;
		DEC	HL			;
		JP	NZ,MzOldNote		;

;
; Read next byte in sequence.
;

		LD	A,B			;Clear MZ_FLG_DRUM, MZ_FLG_REST,
		AND	%11110000		;MZ_FLG_EFF_V and MZ_FLG_GLI_V.
		LD	B,A			;

		LDHL	SP,MZ_SEQ_CURR		;Get sequence ptr.
		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

MzReadSeq:	LD	A,[DE]			;Get next note.
		INC	DE			;
		CP	JUMP			;Or is it a command ?
		JP	C,MzNewNote		;

;
; Process command.
;

MzCommand:	LD	HL,TblMzCmd-JUMP
		ADD	L			;Use the command number to
		LD	L,A			;index into the jump table.
		LD	A,0
		ADC	A,H			;
		LD	H,A			;

		LD	A,[HLI]			;Get the address of the code.
		LD	H,[HL]			;
		LD	L,A			;

		JP	[HL]			;Execute the command.

TblMzCmd:	DW	MzCmdJump
		DW	MzCmdEnd
		DW	MzCmdExit
		DW	MzCmdLength
		DW	MzCmdManual
		DW	MzCmdTie
		DW	MzCmdRest
		DW	MzCmdGliOn
		DW	MzCmdGliOff
		DW	MzCmdEffOn
		DW	MzCmdEffOff
		DW	MzCmdVibOn
		DW	MzCmdVibOff
		DW	MzCmdArpOn
		DW	MzCmdArpOff
		DW	MzCmdEnv
		DW	MzCmdDrum
		DW	MzCmdPoke
		DW	MzCmdSetWave
		DW	MzCmdTmpWave
		DW	MzCmdOldWave
		DW	MzCmdSetDuty
		DW	MzCmdSweep
		DW	MzCmdHwRegs

;
; MZ_JUMP - Jump to address.
;

MzCmdJump:	LD	A,[DE]			;Read destination address.
		INC	DE			;
		LD	C,A			;
		LD	A,[DE]			;
		LD	E,C			;
		LD	D,A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_END - End of sequence.
;

MzCmdEnd:	LDHL	SP,MZ_LST_CURR		;Read sequence list ptr.
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	A,[DE]			;Test for active LOOP command.
		DEC	[HL]			;
		JR	NZ,MzNewSeq		;

		INC	DE			;

		LD	A,1			;Reset MZ_SEQ_LOOP count.
		LD	[HLI],A			;
		XOR	A			;Reset MZ_SEQ_TRAN transpose.
		LD	[HLD],A			;

MzReadLst:	LD	A,[DE]			;Get next cmd in the list.

MzLstLoop:	CP	LOOP			;LOOP next sequence ?
		JR	C,MzNewSeq		;Sequence number not command.
		JR	NZ,MzLstTran

		INC	DE			;Get repeat count.
		LD	A,[DE]			;
		LD	[HL],A			;Save it in MZ_SEQ_REPEAT.
		INC	DE			;
		JR	MzReadLst		;

MzLstTran:	CP	TRANS			;TRANSPOSE next sequence ?
		JR	NZ,MzLstJump		;

		INC	DE			;Get transpose value.
		LD	A,[DE]			;
		INC	HL			;Save it in MZ_SEQ_TRAN.
		LD	[HLD],A			;
		INC	DE			;
		JR	MzReadLst		;

MzLstJump:	CP	JUMP			;JUMP to address ?
		JR	NZ,MzLstEnd		;

		INC	DE			;Get address to jump to.
		LD	A,[DE]			;
		LD	C,A			;
		INC	DE			;
		LD	A,[DE]			;
		LD	E,C			;
		LD	D,A			;
		JR	MzReadLst		;

MzLstEnd:	LDH	A,[hChannelVol]		;Don't reset the channel's
		LD	C,A			;volume if it was already
		LD	A,[C]			;fading down. This should
		DEC	A			;avoid the nasty hardware
		AND	$0F			;click that happens if you
		CP	$07			;do.
		JR	C,MzCmdExit		;

		LDHL	SP,MZ_VOLUME		;
		LD	[HL],$00		;

		LDHL	SP,MZ_SEQ_CURR		;Get sequence ptr.
		LD	DE,MzDummyExit		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	[HL],D			;

		LDHL	SP,MZ_NOTE_LEN		;
		LD	[HL],$01		;
		INC	HL			;
		LD	[HL],$01		;

		RET				;

MzDummyExit:	DB	EXIT

MzLstExit:	LDHL	SP,MZ_STATUS		;END music processing on this
		LD	[HL],$00		;channel.
		RET				;

MzNewSeq:	DEC	HL			;Save position in MZ_LST_CURR.
		LD	[HL],D			;
		DEC	HL			;
		LD	[HL],E			;

		LD	DE,TblMzSeq		;Use the sequence number to
		LD	L,A			;index into the table of
		LD	H,0			;sequence addresses.
		ADD	HL,HL			;
		ADD	HL,DE			;

		LD	A,[HLI]			;Get the sequence's address.
		LD	D,[HL]			;
		LD	E,A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_EXIT - Stop this channel (for driver's use only).
;

MzCmdExit:	LDHL	SP,MZ_STATUS		;END music processing on this
		LD	[HL],$00		;channel.
		RET				;

;
; MZ_LENGTH - Set automatic length.
;

MzCmdLength:	LD	A,[DE]			;Get automatic note length.
		INC	DE			;
		LDHL	SP,MZ_AUTO_LEN		;Save it in MZ_AUTO_LEN.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_MANUAL - Set manual length.
;

MzCmdManual:	LDHL	SP,MZ_AUTO_LEN		;Clear MZ_AUTO_LEN.
		LD	[HL],0			;

		JP	MzReadSeq		;Read next command.

;
; MZ_TIE - Increase length of next note.
;

MzCmdTie:	LDHL	SP,MZ_NOTE_LEN+1	;Increment the length of the
		INC	[HL]			;next note by 256/60s.

		JP	MzReadSeq		;Read next command.

;
; REST  - Pause.
;

MzCmdRest:	SET	MZ_FLG_REST,B		;Set rest on next note.

		LDH	A,[hChannelVol]		;Don't reset the channel's
		LD	C,A			;volume if it was already
		LD	A,[C]			;fading down. This should
		DEC	A			;avoid the nasty hardware
		AND	$0F			;click that happens if you
		CP	$07			;do.
		JP	C,MzDurationRest	;

		LDHL	SP,MZ_VOLUME		;Set MZ_VOLUME to 0.
		LD	[HL],$00		;

		JP	MzDuration

;
; MZ_GLION - Set glide.
;

MzCmdGliOn:	SET	MZ_FLG_GLI,B		;Switch on glide and switch
		RES	MZ_FLG_EFF,B		;off effect.

		LDHL	SP,MZ_GLI_TRAN		;Get and save the values for
		LD	A,[DE]			;MZ_GLI_TRAN and MZ_GLI_LEN.
		INC	DE			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_GLIOFF - Stop glide.
;

MzCmdGliOff:	RES	MZ_FLG_GLI,B		;Switch off glide.

		JP	MzReadSeq		;Read next command.

;
; MZ_EFFECT - Set wierd transpose.
;

MzCmdEffOn:	SET	MZ_FLG_EFF,B		;Switch on effect and switch
		RES	MZ_FLG_GLI,B		;off glide.

		LDHL	SP,MZ_EFF_TRAN		;Get and save the values for
		LD	A,[DE]			;MZ_EFF_TRAN and MZ_EFF_LEN.
		INC	DE			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_EFFOFF - Stop wierd transpose.
;

MzCmdEffOff:	RES	MZ_FLG_EFF,B		;Switch off effect.

		JP	MzReadSeq		;Read next command.

;
; MZ_ARPON - Set arpeggio.
;

MzCmdArpOn:	SET	MZ_FLG_ARP,B		;Turn on arpeggio and turn
		RES	MZ_FLG_VIB,B		;off vibrato.

		LD	A,[DE]			;Get the arpeggio number.
		INC	DE

		ADD	A,A			;Use the arpeggio number to
		LD	HL,TblMzArp
		ADD	L			;index into a table of arpeggio
		LD	L,A			;addresses.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Get the address.
		LD	C,[HL]

		LDHL	SP,MZ_ARP_BASE		;Save MZ_ARP_BASE.
		LD	[HLI],A
		LD	[HL],C

		JP	MzReadSeq		;Read next command.

;
; MZ_ARPOFF - Stop arpeggio.
;

MzCmdArpOff:	RES	MZ_FLG_ARP,B		;Switch off arpeggio.

		JP	MzReadSeq		;Read next command.

;
; MZ_VIBON - Set vibrato.
;

MzCmdVibOn:	SET	MZ_FLG_VIB,B		;Turn on vibrato and turn
		RES	MZ_FLG_ARP,B		;off arpeggio.

		LDHL	SP,MZ_VIB_DEL
		LD	A,[DE]			;Get and save MZ_VIB_DEL.
		INC	DE
		LD	[HLI],A
		LD	A,[DE]			;Get and save MZ_VIB_TRAN.
		INC	DE
		LD	[HL],A

		LDHL	SP,MZ_VIB_LEN
		LD	A,[DE]			;Get and save MZ_VIB_LEN.
		INC	DE
		LD	[HL],A

		JP	MzReadSeq		;Read next command.

;
; MZ_VIBOFF - Stop vibrato.
;

MzCmdVibOff:	RES	MZ_FLG_VIB,B		;Switch off vibrato.

		JP	MzReadSeq		;Read next command.

;
; MZ_ENV - Set volume envelope.
;

MzCmdEnv:	LD	A,[DE]			;Get the envelope byte.
		INC	DE			;

		LDHL	SP,MZ_ENVELOPE		;Save it in MZ_ENVELOPE.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_DRUM -
;

MzCmdDrum:	SET	MZ_FLG_DRUM,B		;

		LD	A,[DE]			;Get drum number.
		INC	DE			;

		ADD	A,A			;Use it as an index into the drum
		LD	HL,TblMzDrum
		ADD	L			;table.
		LD	L,A			;
		LD	A,0			;
		ADC	H
		LD	H,A			;

		PUSH	DE

		LD	A,[HLI]			;Get the address of the drum.
		LD	D,[HL]			;
		LD	E,A			;

		LDHL	SP,MZ_VOLUME+2		;Read the initial volume.
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		INC	HL			;Read the initial frequency.
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLD],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HL],A			;

		LDHL	SP,MZ_DRUM_CURR+2	;Save the ptr to the next frequency.
		LD	A,E			;
		LD	[HLI],A			;
		LD	[HL],D			;

		POP	DE			;

		JP	MzDuration		;

;
; MZ_POKE - Put a value into a hardware register.
;

MzCmdPoke:	LD	A,[DE]			;Get the register number.
		INC	DE			;
		LD	C,A			;
		LD	A,[DE]			;
		INC	DE			;Get the value.
		LD	[C],A			;Do it.

		JP	MzReadSeq		;Read next command.

;
; MZ_SET_WAVE - Set up the waveform RAM and store the address.
;

MzCmdSetWave:	LD	HL,wMzWavePtr		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	[HL],D			;

;
; MZ_TMP_WAVE - Set up the waveform RAM.
;

MzCmdTmpWave:	XOR	A			;
		LDIO	[rNR31],A		;
		LDIO	[rNR30],A		;

		LD	C,255&$FF30		;

		LD	L,E			;
		LD	H,D			;

		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;

		LD	E,L			;
		LD	D,H			;

		LD	A,$80			;
		LDIO	[rNR30],A		;
		LDIO	[rNR34],A		;

		JP	MzReadSeq		;Read next command.

;
; MZ_OLD_WAVE - Set up the waveform RAM from stored address.
;

MzCmdOldWave:	LD	HL,wMzWavePtr		;
		LD	A,[HLI]			;
		LD	H,[HL]			;
		LD	L,A			;

		XOR	A			;
		LDIO	[rNR31],A		;
		LDIO	[rNR30],A		;

		LD	C,255&$FF30		;

		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;
		INC	C			;
		LD	A,[HLI]			;
		LD	[C],A			;

		LD	A,$80			;
		LDIO	[rNR30],A		;
		LDIO	[rNR34],A		;

		JP	MzReadSeq		;Read next command.

;
; MZ_SET_DUTY -
;

MzCmdSetDuty:	LD	A,[DE]			;Get the duty byte.
		INC	DE			;

		LDHL	SP,MZ_DUTY		;Save it.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_SWEEP -
;

MzCmdSweep:	SET	MZ_FLG_GLI_V,B

		LDHL	SP,MZ_GLI_DELTA+1
		LD	A,[DE]			;Get the hi-byte of the delta.
		INC	DE
		LD	[HLD],A
		LD	A,[DE]			;Get the lo-byte of the delta.
		INC	DE
		LD	[HLD],A
		LD	A,[DE]			;Get the length.
		INC	DE
		LD	[HLD],A

		LD	A,[DE]			;Get the note value.
		INC	DE

		PUSH	DE

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Get the frequency.
		LD	C,[HL]

		LDHL	SP,MZ_PERIOD+2		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],C

		JP	MzSetEnv

;
; HWREGS  - Set hardware directly.
;

MzCmdHwRegs:	SET	MZ_FLG_REST,B		;Set rest on next note.

		LDHL	SP,MZ_VOLUME		;Set MZ_VOLUME and MZ_PERIOD
		LD	A,[DE]			;values directly.
		INC	DE			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		LD	A,[DE]			;
		INC	DE			;
		LD	[HLI],A			;
		JP	MzDuration

;
; Process note.
;

MzNewNote:	PUSH	DE			;Save ptr to sequence.

		LDHL	SP,MZ_SEQ_TRAN+2	;Add on the sequence transpose.
		ADD	A,[HL]			;
		INC	HL			;Save as MZ_NOTE.
		LD	[HLI],A			;

;
;
;

MzSetEff:	BIT	MZ_FLG_EFF,B		;Is EFFECT switched on ?
		JR	Z,MzNewFrq

		SET	MZ_FLG_EFF_V,B

		ADD	A,[HL]			;Add on the effect transpose.
		INC	HL			;Make a working copy of the
		LD	C,[HL]			;effect length.
		INC	HL
		LD	[HL],C

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Get the frequency.
		LD	D,[HL]

		LDHL	SP,MZ_PERIOD+2		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],D

		JP	MzSetEnv

;
;
;

MzNewFrq:	ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Get the frequency.
		LD	D,[HL]

		LDHL	SP,MZ_PERIOD+2		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],D

;
;
;

MzSetGli:	BIT	MZ_FLG_GLI,B		;Is GLIDE switched on ?
		JR	Z,MzSetVib

		SET	MZ_FLG_GLI_V,B

		LD	E,A

		LDHL	SP,MZ_NOTE+2		;Get the current note value.
		LD	A,[HL]

		LDHL	SP,MZ_GLI_TRAN+2	;Add on the glide transpose.
		ADD	A,[HL]			;(Use full tones then /2 later.)

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Subtract the old frequency
		SUB	E			;from the new frequency.
		LD	E,A
		LD	A,[HLI]
		SBC	D
		LD	D,A

		LDHL	SP,MZ_GLI_LEN+2		;Get copies of MZ_GLI_LEN.
		LD	A,[HLI]
		LD	[HLI],A
		LD	C,A
		LD	A,E
		LD	E,C

MzGliDivide:	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzGliDivide		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_GLI_DELTA.

		LD	L,A			;Now multiply the number of
		LD	H,D			;steps by the delta-frequency
		SRL	E			;to get the exact frequency
		JR	C,MzGliPeriod		;change.
MzGliMultiply:	ADD	HL,HL
		SRL	E
		JR	NC,MzGliMultiply

MzGliPeriod:	LD	E,L
		LD	D,H

		LDHL	SP,MZ_PERIOD+2		;Alter the current frequency
		LD	A,[HL]			;by this amount.
		ADD	E
		LD	[HLI],A
		LD	A,[HL]
		ADC	D
		LD	[HLI],A

		JP	MzSetEnv

;
;
;

MzSetVib:	BIT	MZ_FLG_VIB,B		;Is VIBRATO switched on?
		JR	Z,MzSetArp

		LD	E,A

		LDHL	SP,MZ_NOTE+2		;Get the original note.
		LD	A,[HL]

		LDHL	SP,MZ_VIB_TRAN+2	;Add the vibrato transpose (use
		ADD	A,[HL]			;as full tones then /4 later).
		DEC	HL
		LD	C,[HL]			;Make a working copy of
		DEC	HL			;MZ_VIB_DEL.
		LD	[HL],C

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Subtract the old frequency
		SUB	E			;from the new frequency.
		LD	E,A
		LD	A,[HLI]
		SBC	D
		LD	D,A

		LDHL	SP,MZ_VIB_LEN+2		;Make a working copy of
		LD	A,[HLI]			;MZ_VIB_LEN.
		LD	[HLI],A
		LD	C,A
		LD	A,E

		SLA	C			;(Quarter-tones.)

MzVibDivide:	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzVibDivide		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_VIB_DELTA.

		JR	MzSetEnv

;
;
;

MzSetArp:	BIT	MZ_FLG_ARP,B		;Is ARPEGGIO switched on ?
		JR	Z,MzSetEnv

		LDHL	SP,MZ_ARP_BASE+2	;Get the ptr from MZ_ARP_BASE.
		LD	A,[HLI]
		LD	C,[HL]
		INC	HL
		LD	[HLI],A			;Save it in MZ_ARP_CURR.
		LD	[HL],C

;
;
;

MzSetEnv:	LDHL	SP,MZ_ENVELOPE+2	;Copy MZ_ENVELOPE into MZ_VOLUME.
		LD	A,[HLI]
		LD	[HL],A

		POP	DE			;Restore ptr to sequence.

;
; Find duration.
;

MzDuration:	LDHL	SP,MZ_PERIOD+1		;New note - initialize envelope.
		SET	7,[HL]			;

MzDurationRest:LDHL	SP,MZ_AUTO_LEN		;Get automatic duration.
		LD	A,[HLI]			;
		OR	A			;
		JR	NZ,MzSetLength		;Get manual duration if auto
		LD	A,[DE]			;duration is zero.
		INC	DE			;
MzSetLength:	ADD	A,[HL]			;Add on current duration (i.e.
		LD	[HLI],A			;from any TIE commands).
		LD	A,1			;
		ADC	[HL]			;
		LD	[HLI],A			;

		LDHL	SP,MZ_SEQ_CURR		;Save current sequence ptr.
		LD	[HL],E			;
		INC	HL			;
		LD	[HL],D			;

		JP	MzDone			;Skip standard note processing.

;
; Process current note.
;

MzOldNote:	BIT	MZ_FLG_DRUM,B		;Special processing for 'drum'.
		JP	NZ,MzDoDrum

		BIT	MZ_FLG_REST,B		;Halt processing during a
		JP	NZ,MzDone		;rest.

;
; Process glide.
;

MzDoGli:	BIT	MZ_FLG_GLI_V,B		;Is GLIDE active ?
		JR	Z,MzDoEff

		LDHL	SP,MZ_GLI_DELTA		;Get the delta-frequency.
		LD	A,[HLI]
		LD	D,[HL]
		LD	E,A

		LDHL	SP,MZ_PERIOD		;Add it onto the current
		LD	A,[HL]			;frequency.
		SUB	E
		LD	[HLI],A
		LD	E,A
		LD	A,[HL]
		SBC	D
		LD	[HLI],A

		LDHL	SP,MZ_GLI_LEN_V		;Last frame of glide ?
		DEC	[HL]
		JP	NZ,MzDone

		RES	MZ_FLG_GLI_V,B		;Reset the flag if so.

		LD	D,A

		JR	MzSetVibB

;
; Process effect.
;

MzDoEff:	BIT	MZ_FLG_EFF_V,B		;Is EFFECT active ?
		JR	Z,MzDoVib

		LDHL	SP,MZ_EFF_LEN_V		;Decrement the effect length.
		DEC	[HL]
		JP	NZ,MzDone

		RES	MZ_FLG_EFF_V,B

		LDHL	SP,MZ_NOTE		;Get the original MZ_NOTE.
		LD	A,[HL]

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Get the new note frequency.
		LD	D,[HL]

		LDHL	SP,MZ_PERIOD		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],D
		LD	E,A

;
;
;

MzSetVibB:	BIT	MZ_FLG_VIB,B		;Is VIBRATO switched on?
		JR	Z,MzSetArpB

		LDHL	SP,MZ_NOTE		;Get the original note.
		LD	A,[HL]

		LDHL	SP,MZ_VIB_TRAN		;Add the vibrato transpose (use
		ADD	A,[HL]			;as full tones then /4 later).
		DEC	HL
		LD	C,[HL]			;Make a working copy of
		DEC	HL			;MZ_VIB_DEL.
		LD	[HL],C

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H
		LD	H,A

		LD	A,[HLI]			;Subtract the old frequency
		SUB	E			;from the new frequency.
		LD	E,A
		LD	A,[HLI]
		SBC	D
		LD	D,A

		LDHL	SP,MZ_VIB_LEN		;Make a working copy of
		LD	A,[HLI]			;MZ_VIB_LEN.
		LD	[HLI],A
		LD	C,A
		LD	A,E

		SLA	C			;(Quarter-tones.)

MzVibDivideB:	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzVibDivideB		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_VIB_DELTA.

		JP	MzDone

;
;
;

MzSetArpB:	BIT	MZ_FLG_ARP,B		;Is ARPEGGIO switched on ?
		JP	Z,MzDone

		LDHL	SP,MZ_ARP_BASE		;Get the ptr from MZ_ARP_BASE.
		LD	A,[HLI]
		LD	C,[HL]
		INC	HL
		LD	[HLI],A			;Save it in MZ_ARP_CURR.
		LD	[HL],C

		JP	MzDone

;
; Process vibrato.
;

MzDoVib:	BIT	MZ_FLG_VIB,B		;Is VIBRATO active ?
		JR	Z,MzDoArp

		LDHL	SP,MZ_VIB_DEL_V		;Has the delay run out ?
		LD	A,[HLD]
		OR	A
		JR	NZ,MzDoVibWait

		LD	A,[HLD]			;Get the delta-frequency.
		LD	E,[HL]
		LD	D,A

		LDHL	SP,MZ_PERIOD		;Add it onto the current
		LD	A,[HL]			;frequency.
		ADD	E
		LD	[HLI],A
		LD	A,[HL]
		ADC	D
		LD	[HLI],A

		LDHL	SP,MZ_VIB_LEN		;Get MZ_VIB_LEN.
		LD	A,[HLI]
		DEC	[HL]			;Decrement MZ_VIB_LEN_V.
		JP	NZ,MzDone
		ADD	A,A			;Reset MZ_VIB_LEN_V for the
		LD	[HLI],A			;next half-cycle.

		XOR	A			;Negate MZ_VIB_DELTA.
		SUB	E
		LD	[HLI],A
		LD	A,0
		SBC	D
		LD	[HLI],A

		JP	MzDone

MzDoVibWait:	INC	HL			;Update delay timer.
		DEC	[HL]

		JP	MzDone

;
; Process arpeggio.
;

MzDoArp:	BIT	MZ_FLG_ARP,B
		JR	Z,MzDone

		LDHL	SP,MZ_ARP_CURR		;Get the ptr to the next
		LD	A,[HLI]			;arpeggio transpose.
		LD	D,[HL]
		LD	E,A

		LD	A,[DE]			;Get the transpose value.
		CP	$80			;End of list ?
		JR	NZ,MzDoArpTran

		LDHL	SP,MZ_ARP_BASE		;Get the ptr to the start
		LD	A,[HLI]			;of the transpose list.
		LD	D,[HL]
		LD	E,A
		LDHL	SP,MZ_ARP_CURR+1
		LD	A,[DE]			;Get the first value.

MzDoArpTran:	INC	DE			;Update MZ_ARP_CURR.
		LD	[HL],D
		DEC	HL
		LD	[HL],E

		LDHL	SP,MZ_NOTE		;Add on the base note value.
		ADD	A,[HL]

		ADD	A,A			;Use the note number to index
		LD	HL,TblMzFrq
		ADD	L			;into a table of frequency
		LD	L,A			;values.
		LD	A,0
		ADC	H			;
		LD	H,A			;

		LD	A,[HLI]			;Get the new note frequency.
		LD	C,[HL]

		LDHL	SP,MZ_PERIOD		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],C

;
; End of processing.
;

MzDone:	LDHL	SP,MZ_FLAGS		;Save MZ_FLAGS.
		LD	[HL],B			;

		RET				;

;
; Process 'drum' special effect.
;

MzDoDrum:	LDHL	SP,MZ_DRUM_CURR		;Get the ptr to the next frequency
		LD	A,[HLI]			;setting.
		LD	D,[HL]
		LD	E,A

		LD	A,[DE]			;Get the high byte of the frequency.
		CP	$FF			;End of list ?
		JR	Z,MzDrumDone

		LDHL	SP,MZ_PERIOD+1		;Copy the new frequency to MZ_PERIOD.
		LD	[HLD],A
		INC	DE
		LD	A,[DE]
		LD	[HL],A
		INC	DE

		LDHL	SP,MZ_DRUM_CURR		;Save the new ptr position.
		LD	A,E
		LD	[HLI],A
		LD	[HL],D

		JR	MzDone

MzDrumDone:	RES	MZ_FLG_DRUM,B
		SET	MZ_FLG_REST,B

		LDH	A,[hChannelVol]		;Don't reset the channel's
		LD	C,A			;volume if it was already
		LD	A,[C]			;fading down. This should
		DEC	A			;avoid the nasty hardware
		AND	$0F			;click that happens if you
		CP	$07			;do.
		JR	C,MzDone		;

		LDHL	SP,MZ_VOLUME		;Set the volume to zero.
		LD	[HL],$00		;

		JR	MzDone

;
; MZ_FRQ_TABLE - Table of frequencies for each note.
;
; Range of 8 octaves from C1=65Hz to B8=15804Hz.
;
; Calculated from f=131072/(2048-x).
;

TblMzFrq:	DW	2048-(2004/1)		;C1
		DW	2048-(1891/1)		;C#1
		DW	2048-(1785/1)		;D1
		DW	2048-(1685/1)		;D#1
		DW	2048-(1590/1)		;E1
		DW	2048-(1501/1)		;F1
		DW	2048-(1417/1)		;F#1
		DW	2048-(1337/1)		;G1
		DW	2048-(1262/1)		;G#1
		DW	2048-(1192/1)		;A1 (110Hz)
		DW	2048-(1125/1)		;A#1
		DW	2048-(1062/1)		;B1

		DW	2048-(2004/2)		;C2
		DW	2048-(1891/2)		;C#2
		DW	2048-(1785/2)		;D2
		DW	2048-(1685/2)		;D#2
		DW	2048-(1590/2)		;E2
		DW	2048-(1501/2)		;F2
		DW	2048-(1417/2)		;F#2
		DW	2048-(1337/2)		;G2
		DW	2048-(1262/2)		;G#2
		DW	2048-(1192/2)		;A2 (220Hz)
		DW	2048-(1125/2)		;A#2
		DW	2048-(1062/2)		;B2

		DW	2048-(2004/4)		;C3
		DW	2048-(1891/4)		;C#3
		DW	2048-(1785/4)		;D3
		DW	2048-(1685/4)		;D#3
		DW	2048-(1590/4)		;E3
		DW	2048-(1501/4)		;F3
		DW	2048-(1417/4)		;F#3
		DW	2048-(1337/4)		;G3
		DW	2048-(1262/4)		;G#3
		DW	2048-(1192/4)		;A3 (440Hz)
		DW	2048-(1125/4)		;A#3
		DW	2048-(1062/4)		;B3

		DW	2048-(2004/8)		;C4
		DW	2048-(1891/8)		;C#4
		DW	2048-(1785/8)		;D4
		DW	2048-(1685/8)		;D#4
		DW	2048-(1590/8)		;E4
		DW	2048-(1501/8)		;F4
		DW	2048-(1417/8)		;F#4
		DW	2048-(1337/8)		;G4
		DW	2048-(1262/8)		;G#4
		DW	2048-(1192/8)		;A4 (880Hz)
		DW	2048-(1125/8)		;A#4
		DW	2048-(1062/8)		;B4

		DW	2048-(2004/16)		;C5
		DW	2048-(1891/16)		;C#5
		DW	2048-(1785/16)		;D5
		DW	2048-(1685/16)		;D#5
		DW	2048-(1590/16)		;E5
		DW	2048-(1501/16)		;F5
		DW	2048-(1417/16)		;F#5
		DW	2048-(1337/16)		;G5
		DW	2048-(1262/16)		;G#5
		DW	2048-(1192/16)		;A5 (1760Hz)
		DW	2048-(1125/16)		;A#5
		DW	2048-(1062/16)		;B5

		DW	2048-(2004/32)		;C6
		DW	2048-(1891/32)		;C#6
		DW	2048-(1785/32)		;D6
		DW	2048-(1685/32)		;D#6
		DW	2048-(1590/32)		;E6
		DW	2048-(1501/32)		;F6
		DW	2048-(1417/32)		;F#6
		DW	2048-(1337/32)		;G6
		DW	2048-(1262/32)		;G#6
		DW	2048-(1192/32)		;A6 (3520Hz)
		DW	2048-(1125/32)		;A#6
		DW	2048-(1062/32)		;B6

		DW	2048-(2004/64)		;C7
		DW	2048-(1891/64)		;C#7
		DW	2048-(1785/64)		;D7
		DW	2048-(1685/64)		;D#7
		DW	2048-(1590/64)		;E7
		DW	2048-(1501/64)		;F7
		DW	2048-(1417/64)		;F#7
		DW	2048-(1337/64)		;G7
		DW	2048-(1262/64)		;G#7
		DW	2048-(1192/64)		;A7 (7040Hz)
		DW	2048-(1125/64)		;A#7
		DW	2048-(1062/64)		;B7

		DW	2048-(2004/128)		;C8
		DW	2048-(1891/128)		;C#8
		DW	2048-(1785/128)		;D8
		DW	2048-(1685/128)		;D#8
		DW	2048-(1590/128)		;E8
		DW	2048-(1501/128)		;F8
		DW	2048-(1417/128)		;F#8
		DW	2048-(1337/128)		;G8
		DW	2048-(1262/128)		;G#8
		DW	2048-(1192/128)		;A8 (14080Hz)
		DW	2048-(1125/128)		;A#8
		DW	2048-(1062/128)		;B8



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF DRIVER
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  START OF MUSIC DATA
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

;----------------------------------------------------------------------------
;TEMPO EQUATES
;-------------

TEMPO2          EQU     6                       ;  TEMPO CONTROL
DSQ2            EQU     TEMPO2/2                ;  DEMI-SEMI-QUAVER
SQ2             EQU     TEMPO2                  ;  SEMI-QUAVER
QV2             EQU     SQ2*2                   ;  QUAVER
DQV2            EQU     QV2+SQ2                 ;  DOTTED QUAVER
CR2             EQU     QV2*2                   ;  CROTCHET
QV2TRIP         EQU     CR2/3                   ;  CROTCHET
DCR2            EQU     CR2+QV2                 ;  DOTTED CROTCHET
MN2             EQU     CR2*2                   ;  MINIM
DMN2            EQU     MN2+CR2                 ;  DOTTED MINIM
SB2             EQU     MN2*2                   ;  SEMI-BREVE
DSB2            EQU     SB2+MN2                 ;  DOTTED SEMI-BREVE

TEMPO3          EQU     7                       ;  TEMPO CONTROL
DSQ3            EQU     TEMPO3/2                ;  DEMI-SEMI-QUAVER
SQ3             EQU     TEMPO3                  ;  SEMI-QUAVER
QV3             EQU     SQ3*2                   ;  QUAVER
DQV3            EQU     QV3+SQ3                 ;  DOTTED QUAVER
CR3             EQU     QV3*2                   ;  CROTCHET
QV3TRIP         EQU     CR3/3                   ;  CROTCHET
DCR3            EQU     CR3+QV3                 ;  DOTTED CROTCHET
MN3             EQU     CR3*2                   ;  MINIM
DMN3            EQU     MN3+CR3                 ;  DOTTED MINIM
MN3TRIP         EQU     MN3/3                   ;  DOTTED MINIM
SB3             EQU     MN3*2                   ;  SEMI-BREVE
DSB3            EQU     SB3+MN3                 ;  DOTTED SEMI-BREVE

TEMPO4          EQU     5                       ;  TEMPO CONTROL
DSQ4            EQU     TEMPO4/2                ;  DEMI-SEMI-QUAVER
SQ4             EQU     TEMPO4                  ;  SEMI-QUAVER
QV4             EQU     SQ4*2                   ;  QUAVER
DQV4            EQU     QV4+SQ4                 ;  DOTTED QUAVER
CR4             EQU     QV4*2                   ;  CROTCHET
QV4TRIP         EQU     CR4/3                   ;  CROTCHET
DCR4            EQU     CR4+QV4                 ;  DOTTED CROTCHET
MN4             EQU     CR4*2                   ;  MINIM
DMN4            EQU     MN4+CR4                 ;  DOTTED MINIM
MN4TRIP         EQU     MN4/3                   ;  DOTTED MINIM
SB4             EQU     MN4*2                   ;  SEMI-BREVE
DSB4            EQU     SB4+MN4                 ;  DOTTED SEMI-BREVE

;----------------------------------------------------------------------------
; DRUM - Special 'drum' or sound effect tables.
;
; MZ_DRUM_TABLE is a table of pointers to each drum definition.
;
; Each definition consists of a volume value followed by a series of frequency
; values to use on consecutive frames.  The list is terminated by an $FF byte.
;
; For example :
; MZ_DRUM_TABLE DW DRUM00
;
; DRUM00 DB $80,$03,$00,$04,$80,$FF
;
; This set the volume to 8, and the frequency to $300 for 1 frame; then sets
; the frequency to $480 for 1 frame; then the drum is silenced.
;

;[DRUMTABLE]

TblMzDrum:	DW      DRUM0,DRUM1,DRUM2,DRUM3
		DW      DRUM4,DRUM5,DRUM6,DRUM7
		DW      DRUM8,DRUM9,DRUM10,DRUM11
		DW      DRUM12,DRUM13,DRUM14,DRUM15
		DW      DRUM16,DRUM17,DRUM18,DRUM19
		DW      DRUM20,DRUM21


DRUM0:		DB      $72
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      $FF

;not used
DRUM1:
;		DB      $72
;		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
;		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
;		DB      $FF

DRUM2:		DB      $52
		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      $FF

DRUM3:		DB      $70
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      $FF

DRUM4:		DB      $A3
;		DB      0,$22,0,$22,0,$22,0,$22,0,$22
;		DB      0,$22,0,$22,0,$22,0,$22,0,$22
;		DB      0,$23,0,$23,0,$23,0,$23,0,$23
;		DB      0,$23,0,$23,0,$23,0,$23,0,$23
;		DB      0,$24,0,$24,0,$24,0,$24,0,$24
;		DB      0,$24,0,$24,0,$24,0,$24,0,$24
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
;		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB	0,$26
		DB      $FF

DRUM5:		DB      $75
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      $FF

DRUM6:		DB      $41                       ;MUSIC [save] soft snare
		DB      0,$60,0,$50,0,$40
		DB      $FF

DRUM7:		DB      $81
		DB      0,$60,0,$50,0,$40,0,$40,0,$40   ;MUSIC
		DB      $FF

DRUM8:		DB      $51
		DB      0,$02,0,$02,0,$06,0,$06,0,$06,0,$05     ;MUSIC
		DB      0,$05,0,$05,0,$05,0,$04,0,$04,0,$04
		DB      0,$04,0,$03,0,$03,0,$03,0,$02,0,$02
		DB      $FF

DRUM9:		DB      $83
		DB      0,$32,0,$32,0,$32,0,$32,0,$33
		DB      0,$33,0,$33,0,$33,0,$33,0,$33
		DB      0,$34,0,$34,0,$34,0,$34,0,$34
		DB      0,$34,0,$34,0,$34,0,$34,0,$34
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      0,$35,0,$35,0,$35,0,$35,0,$35
		DB      $FF


DRUM10:		DB      $81
		DB      0,$65,0,$43,0,$43,0,$43,0,$43,0,$43,0,$43
		DB      0,$43,0,$43,0,$43,0,$43,0,$43,0,$43,0,$43
		DB      $FF

;not used
DRUM11:
;		DB      $32
;		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
;		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
;		DB      $FF

;not used
DRUM12:
;		DB      $41
;		DB      0,$59,0,$5B,0,$5B,0,$5D,0,$5F,0,$60
;		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
;		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
;		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
;		DB      $FF

DRUM13:		DB      $6D
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      $FF

DRUM14:		DB      $C1
		DB      0,$59,0,$5B,0,$5B,0,$5D,0,$5F,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      $FF

DRUM15:		DB      $90
		DB      0,$05,0,$05,0,$05,0,$05
		DB      0,$04,0,$04,0,$04,0,$04
		DB      0,$03,0,$03,0,$03,0,$03
		DB      0,$02,0,$02,0,$02,0,$02
		DB      0,$01,0,$01,0,$01,0,$01
		DB      0,$00,0,$00,0,$00,0,$00
		DB      $FF

;not used
DRUM16:
;		DB      $60
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
;		DB      $FF

DRUM17:		DB      $C0
		DB      0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07
		DB      0,$06,0,$06,0,$06,0,$06
		DB      0,$05,0,$05,0,$05,0,$05
		DB      0,$05,0,$05,0,$05,0,$05
		DB      0,$04,0,$04,0,$04,0,$04
		DB      0,$03,0,$03,0,$03,0,$03
		DB      0,$03,0,$03,0,$03,0,$03
		DB      0,$02,0,$02,0,$02,0,$02
		DB      0,$01,0,$01,0,$01,0,$01
		DB      0,$01,0,$01,0,$01,0,$01
		DB      0,$00,0,$00,0,$00,0,$00
		DB      $FF

DRUM18:		DB      $A7
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      $FF

DRUM19:		DB      $81
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      $FF


DRUM20:		DB      $67
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      $FF

DRUM21:		DB      $67
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$30,0,$30,0,$30,0,$30,0,$30
		DB      0,$22,0,$22,0,$22,0,$22,0,$22
		DB      $FF




;-----------------------------------------------------------------------------
;
; ARP - Arpeggio lists.
;
; MZ_ARP_TABLE is a table of pointers to each arpeggio list.
;
; Each arpeggio list contains a sequence of transposition offsets, ending
; with a $80.  Each transpose is used for 1/60s and is taken from the base
; note.
;
; For example :
;
; MZ_ARP_TABLE DW ARP00
;
; ARP00  DB 0,1,0,-1,$80
;
; This plays the base note for a frame, then the base note + 1 for a frame,
; then the base note again, then the base note - 1.  When the $80 is read the
; list is started again from the first transpose value.
;

;-----------------------------------------------------------------------------
;ARPEGGIO PROGRAMS
;-----------------

MAJOR23         EQU     0
SEVENTH         EQU     1
MAJOR           EQU     2
MINOR           EQU     3
EDB             EQU     4
MAJ1            EQU     5
MAJ1DIM         EQU     6
MAJ1SUS2        EQU     7
MAJ2            EQU     8

MINR            EQU     9
MIN1            EQU     10
MIN2            EQU     11

FLASH           EQU     12
FLASH2          EQU     13
SUS417TH        EQU     14
SUS42           EQU     15

FIFTHS          EQU     16
FOURTHS         EQU     17
THIRDS          EQU     18
HAMMER2         EQU     19
DIM6TH          EQU     20
TRILL1          EQU     21
FIFTH2          EQU     22
MAJOR2          EQU     23
MINRS           EQU     24
SUS41S          EQU     25
MIN1S           EQU     26
MIN2S           EQU     27
SPECIAL         EQU     28
MINOR6          EQU     29
MAJ3			EQU	30
DIM1			EQU	31
DIM2			EQU	32


TblMzArp:	DW      ARP0,ARP1,ARP2,ARP3,ARP4,ARP5
		DW      ARP6,ARP7,ARP8,ARP9,ARP10,ARP11
		DW      ARP12,ARP13,ARP14,ARP15,ARP16,ARP17,ARP18
		DW      ARP19,ARP20,ARP21,ARP22,ARP23,ARP24,ARP25
		DW      ARP26,ARP27,ARP28,ARP29,ARP30,ARP31,ARP32

ARP0:	DB      24,24,12,12,0,0,0,0,0,0,0,0,$80

ARP1:	DB      7,7,4,4,0,0,10,10,$80           ;SEVENTH
ARP2:	DB      7,7,4,4,0,0,$80         ;MAJOR
ARP3:	DB      7,7,3,3,0,0,$80         ;MINOR
		DB      7,7,7,7,7,7,7,7,7,7,$80
ARP4:	DB      5,5,3,3,0,0     ;EDB THANG

		DB      5,5,5,5,5,5,5,5,5,5,$80
ARP5:	DB      7,7,12,12,16,16,$80     ;1ST MAJOR
ARP6:	DB      12,12,6,6,3,3,$80       ;1ST MAJOR DIM
ARP7:	DB      14,14,12,12,7,7,4,4,$80 ;1ST MAJOR SUS2
ARP8:	DB      12,12,7,7,4,4,$80       ;2ND MAJOR

ARP9:	DB      19,19,15,15,12,12,0,0,$80       ;ROOT MINOR + BASS
ARP10:	DB      7,7,12,12,15,15,$80     ;1ST MINOR
ARP11:	DB      12,12,7,7,3,3,$80       ;2ND MINOR

ARP12:	DB      7,7,5,5,3,3,0,0,$80             ;FLASH
ARP13:	DB      0,0,5,5,7,7,12,12,19,19,$80     ;FLASH2
ARP14:	DB      12,12,10,10,7,7,5,5,$80 ;1ST MAJOR SUS4 7TH
ARP15:	DB      17,17,12,12,7,7,$80     ;2ND MAJOR SUS4

ARP16:	DB      0,0,7,7,$80     ;FIFTHS
ARP17:	DB      0,0,5,5,$80             ;FOURTHS
ARP18:	DB      0,0,4,4,$80             ;THIRDS
ARP19:	DB      0,0,0,2,2,2,$80         ;HAMMER ON & PULL OFF TONE
ARP20:	DB      9,9,6,6,3,3,0,0,$80     ;DIMINISHED 6TH
ARP21:	DB      0,0,0,3,3,3,$80         ;
ARP22:	DB      0,7,$80            ;FIFTH2
ARP23:	DB      16,16,12,0,7,7,$80      ;2ND MAJOR
ARP24:	DB      7,7,3,3,0,0,$80         ;ROOT MINOR
ARP25:	DB      12,12,7,7,5,5,$80       ;1ST MAJOR SUS4
ARP26:	DB      12,12,7,7,3,3,$80       ;1ST MINOR
ARP27:	DB      15,15,12,12,7,7,$80     ;2ND MINOR
ARP28:	DB      0,0,3,3,5,5,7,7,0,0,3,3,5,5,7,7,12,12,
		DB      15,15,17,17,19,19,24,24,$80     ;SPECIAL
;ARP28:	DB      0,0,7,7,12,12,19,19,22,22,$80   ;SPECIAL
ARP29:	DB      0,0,3,3,7,7,$80         ;SIMPLE MINOR
ARP30:	DB      0,0,4,4,7,7,$80         ;SIMPLE MAJOR
ARP31:		DB	3,3,-3,-3,6,6,0,0,$80	;DIMINISHED UP/DOWN 1
ARP32:		DB	-3,-3,3,3,0,0,-6,-6,$80	;DIMINISHED UP/DOWN 2

;
;  FX - FX lists.
;


TblFxList:
		DW      0,0,FX01,0		;1
		DW      0,0,FX01,0              ;2  fifi - JUMP1
		DW      0,0,FX02,0              ;3  fifi - JUMP2
		DW      0,0,FX03,0              ;4  fifi - JUMP3
		DW      0,0,FX04,0              ;5  fifi - LAST JUMP
		DW      0,0,0,FX07              ;6  chopin' wood
		DW      0,0,0,FX08              ;7 PILE UP WOOD
		DW      0,0,0,FX08              ;8 PILE UP WOOD
		DW      0,0,0,FX08              ;9 PILE UP WOOD
		DW      0,0,0,FX08              ;10 PILE UP WOOD
		DW      0,0,0,FX08              ;11 PILE UP WOOD
		DW      FXKAOLD,0,0,0		;12 Spinner beep
		DW      0,0,0,0                 ;13 Duster NOISE
		DW      0,0,0,0                 ;14 Duster NOISE
		DW      0,0,0,FX13              ;15 Duster FUK-UP
		DW      0,0,0,0                 ;16 NOTHING,-OLD Duster FUK-UP
		DW      0,0,FX03,0              ;17 belle - JUMPS
		DW      0,0,0,FX16              ;18 belle - HIT WOLF
		DW      0,0,0,FX17              ;19 belle - HIT OBJECT
		DW      FX19,FX18,0,0           ;20 SHOOT - TARGETS CLEARED
		DW      0,0,0,FX20              ;21 SHOOTING NOISE
		DW      0,FX21,0,FX20           ;22 SHOOTING MISS
		DW      0,FX22,0,FX20           ;23 SHOOTING GOOD PICKUP
		DW      0,FX23,0,FX20           ;24 SHOOTING BAD PICKUP
		DW      FX19,FX18,0,0           ;25 CHIP - STAGE CLEAR
		DW      0,0,0,FX13              ;26 CHIP - WRONG CUP
		DW      0,0,FX24,0              ;27 CHIP - RIGHT CUP
		DW      0,0,FX01,0              ;28 CHIP CHOOSE CUP
		DW      0,0,FX02,0              ;29 CHIP CHOOSE CUP
		DW      0,0,FX03,0              ;30 CHIP CHOOSE CUP
		DW      0,0,0,FX08              ;31 PILE UP WOOD
		DW      0,0,0,FX08              ;32 PILE UP WOOD
		DW      0,0,0,FX08              ;33 PILE UP WOOD
		DW      0,0,0,FX08              ;34 PILE UP WOOD
		DW      0,0,0,FX08              ;35 PILE UP WOOD
		DW      0,0,0,FX08              ;36 ILE UP WOOD
		DW      0,0,0,FX08              ;37 PILE UP WOOD
		DW      0,0,0,FX08              ;38 PILE UP WOOD
		DW      0,0,0,FX08              ;39 PILE UP WOOD
		DW      0,0,0,FX08              ;40 PILE UP WOOD
		DW      0,0,0,FX08              ;41 PILE UP WOOD
		DW      FX05,FX05,0,0           ;42 STAGE DITTY
		DW      0,0,0,FX58              ;43 WOLF RUNS ON THE GROUND
		DW      FX59,0,0,0              ;44 SPITTING meter up
		DW      FX60,0,0,0              ;45 SPITTING meter down
		DW      0,0,FX61,0              ;46 SPITNOISE
		DW      0,0,0,FX62              ;47 WATER OUT
		DW      0,FX63,0,0              ;48 DROP START
		DW      0,FX65,0,FX64		;49 DROP HITS WATER
		DW      0,0,FX70,0              ;50 FILL UP TEAPOT
		DW      0,0,0,FX56              ;51 teapot sprays
		DW      0,0,0,0                 ;52 FIRE BACKGROUND
		DW      0,0,0,FX67              ;53 teapot quenches fire
		DW      FX71,0,0,0              ;54 ROLL 1 DIE
		DW      FX72,0,0,0              ;55 ROLL 2 DICE
		DW      0,0,FX69,FX68           ;56 FIRE BURNS THRU'
		DW	FXKA,0,0,0		;57 K2  cloktik
		DW	FXKB,0,0,0		;58 K4  free throw SHOT
		DW	FXKC,0,0,0		;59 K5  free throw GOOD
		DW	FXKD,0,0,0		;60 K10 1x
		DW	0,FXKE,0,0		;61 K11 out of turbo
		DW	0,0,0,FXKF		;62 K12 BLOCK
		DW	0,0,0,FXKG		;63 K13 RIM
		DW	0,0,0,FXKH		;64 K14 CHARGE
		DW	FXKI,0,0,0		;65 K16 turnover
		DW	0,0,0,FXKJ		;66 K18 NET
		DW	0,0,0,FXKL		;67 K20 SMALLCHEER
		DW	0,0,0,FXKM		;68 K24 PASS
		DW	0,FXKN,0,0		;69 K25 TURBO SOUND
		DW	FXKD2,0,0,0		;70 K10 2x
		DW	FXKD4,0,0,0		;71 K10 4x
		DW      FX192,FX182,0,0         ;72 SHOOT - TARGETS CLEARED 2x
		DW      FX193,FX183,0,0         ;73 SHOOT - TARGETS CLEARED 3x
		DW      FX194,FX184,0,0         ;74 SHOOT - TARGETS CLEARED 4x
		DW	0,0,FXKO,0		;75 TOGGLE

TblFxListEnd:


FX01:		DB      MANUAL,WAVE                             ;FIFI
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%00100000
		DB      GLION,-24,16,FS5,16
		DB      END

FX02:		DB      MANUAL,WAVE
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE         ;FIFI
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%00100000
		DB      GLION,-24,16,G5,16
		DB      END

FX03:		DB      MANUAL,WAVE
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE         ;FIFI
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%00100000
		DB      GLION,-24,16,GS5,16
		DB      END


FX04:		DB      MANUAL,WAVE                             ;FIFI FINAL
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%00100000,LENGTH,1
		DB      D6,CS6,C6,B5,AS5,A5,GS5
		DB      G5,FS5,F5,E5,DS5,D5,CS5,C5,B4,AS4,A4,GS4
		DB      ENV,%00000000
		DB      MANUAL
		DB      END

FX05:		DB      ENV,$82                                 ;DUSTER SCALE
		DB      LENGTH,SQ2
		DB      G3,G3,REST,G3
		DB      LENGTH,QV2
		DB      A3,AS3,B3,REST ;,G3
		DB      END

FX06:		DB      ENV,$82                                 ;DUSTER SCALE
		DB      LENGTH,SQ2
		DB      D4,D4,REST,D4
		DB      LENGTH,QV2
		DB      E4,F4,FS4,REST,D4
		DB      END

FX07:		DB      DRUM,8,10,DRUM,8,30                     ;CHOPIN WOOD
		DB      END


FX08:		DB      DRUM,0,10
		DB      END

FX09:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,B2,2,CS3,10
		DB      END

FX10:
FX11:
FX12:
FX25:
FX26:
FX27:
FX28:
FX29:
FX30:
FX31:
FX32:
FX33:
FX34:
FX35:
FX36:
FX37:
FX38:
FX39:
FX40:

FX13:		DB      DRUM,3,10,REST,1,DRUM,3,15       ;DUSTER MISTAKE
		DB      END

FX14:		DB      ENV,$82                                 ;DUSTER SCALE
		DB      LENGTH,QV2
		DB      E3,A2,E3
		DB      END

FX15:		DB      VIBON,8,1,4,ENV,$A8             ;DUSTER MISTAKE
		DB      B3,2,C4,QV2,G3,QV2+2,DS3,QV2+5,C3,CR2+12
		DB      END

FX16:		DB      DRUM,4,60               ;BELLE - HIT WOLF
		DB      END

FX17:		DB      DRUM,5,2,REST,2,DRUM,5,40       ;BELLE - HIT OBJECT
		DB      END

FX18:		DB      MANUAL,ENV,$A2          ;SHOOTING - CLEAR TARGETS
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      END
FX182:		DB      MANUAL,ENV,$A2          ;SHOOTING - CLEAR TARGETS
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      END

FX183:		DB      MANUAL,ENV,$A2          ;SHOOTING - CLEAR TARGETS
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      END
FX184:		DB      MANUAL,ENV,$A2          ;SHOOTING - CLEAR TARGETS
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2+23
		DB      END


FX19:		DB      ENV,$66,LENGTH,DCR2+5 ;46
		DB	G2,C3
		DB      END                     ;SHOOTING - CLEAR TARGETS
FX192:		DB      ENV,$66,LENGTH,DCR2+5 ;46
		DB	G2,C3
		DB	G2,C3
		DB      END                     ;SHOOTING - CLEAR TARGETS
FX193:		DB      ENV,$66,LENGTH,DCR2+5
		DB	G2,C3
		DB	G2,C3
		DB	G2,C3
		DB      END                     ;SHOOTING - CLEAR TARGETS
FX194:		DB      ENV,$66,LENGTH,DCR2+5
		DB	G2,C3
		DB	G2,C3
		DB	G2,C3
		DB	G2,C3
		DB      END                     ;SHOOTING - CLEAR TARGETS

FX20:		DB      DRUM,9,60       ;SHOOTING NOISE
		DB      END

FX21:		DB      REST,5,LENGTH,QV2       ;SHOOT - MISS
		DB      ENV,$F1,G2
		DB      END

FX22:		DB      REST,5,ENV,$B1,LENGTH,3,C3,E3,G3,C4 ;GOOD PICKUP
		DB      END

FX23:		DB      REST,5,ENV,$B1,LENGTH,3,C3,E3,B2,D3,A2,C3 ;BAD PICKUP
		DB      END

FX24:		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF ;CHIP RIGHT CUP
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%10111111
		DB      LENGTH,5,C5,E5,G5,C6,G5,E5
		DB      MANUAL,C5,20
		DB      END

FX41:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,C3,2,D3,10
		DB      END

FX42:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,CS3,2,DS3,10
		DB      END

FX43:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,D3,2,E3,10
		DB      END

FX44:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,DS3,2,F3,10
		DB      END

FX45:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,E3,2,FS3,10
		DB      END

FX46:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,F3,2,G3,10
		DB      END

FX47:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,FS3,2,GS3,10
		DB      END

FX48:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,G3,2,A3,10
		DB      END

FX49:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,GS3,2,AS3,10
		DB      END

FX50:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,A3,2,B3,10
		DB      END

FX51:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,AS3,2,C4,10
		DB      END

FX52:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,B3,2,CS4,10
		DB      END

FX53:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,C4,2,D4,10
		DB      END

FX54:		DB      ENV,$B1                                 ;WOOD STACK
		DB      MANUAL,CS4,2,DS4,10
		DB      END

FX55:		DB      ENV,$2E
		DB      MANUAL,DRUM,13,15,DRUM,14,30
		DB      END



FX58:		DB      DRUM,2,6,DRUM,2,6,DRUM,0,6,DRUM,2,6
		DB      DRUM,0,6,DRUM,2,6,DRUM,2,6,DRUM,2,6
		DB      END

FX59:		DB      LENGTH,2,ENV,$60
		REPT	3
		DB	D3,F3,AS3,D4,F4,AS4,D5,AS4,F4,D4,AS3,F3
		ENDR
		DB      END

FX60:		DB      LENGTH,1,ENV,$60
		DB      D4,CS4,C4,B3,AS3,A3,GS3,G3,FS3,F3,E3,DS3
		DB      D3,CS3,C3,B2,AS2,A2,GS2,G2,FS2,F2,E2,DS2
		DB      END

FX61:		DB      MANUAL,WAVE
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE         ;FIFI
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%00100000
		DB      GLION,64,32,B3,32
		DB      END

FX62:		DB      DRUM,21,60
		DB      END

FX63:		DB      MANUAL,ENV,$87
		DB      GLION,24,16,DS3,22
		DB	ENV,$00
		DB	DS3,5
		DB      END


FX64:		DB      DRUM,19,10,DRUM,20,50                   ;DROPHITWATER
		DB      END

FX65:		DB      ENV,$82                                 ;DROPHITWATER
		DB      MANUAL
		DB      F3,10
		DB      ENV,$87
		DB      D3,50
		DB      END

FX66:		DB      ENV,$82                                 ;DROPHITCANDLE
		DB      LENGTH,5
		DB      C3,E3,G3,C4
		DB      END

FX71:		DB      MANUAL,ENV,$B2,C2,20,ENV,$81,C2,3,REST,2,C2,15
		DB      END

FX72:		DB      MANUAL,ENV,$62,C2,3,REST,1,ENV,$C2,C2,15,REST,5
		DB      ENV,$81,C2,3,REST,2,C2,15
		DB      END


FX70:		DB      MANUAL,WAVE                             ;FIFI
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%01000000
		DB      LENGTH,5
		DB      G5,A5,B5,C6,D6
		DB      END

FX69:		DB      MANUAL,WAVE                             ;FIFI
		DB      $01,$23,$45,$56,$78,$9A,$BC,$DE
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      ENV,%01000000
		DB      E6,5,REST,2
		DB      E6,5,REST,2
		DB      E6,5,REST,2
		DB      E6,5,REST,2
		DB      E6,5,REST,2
		DB      END

FX68:		DB      MANUAL,DRUM,18,30
		DB      END

FX67:		DB      MANUAL,DRUM,17,48
		DB      END

FX56:		DB      MANUAL,DRUM,15,24
		DB      END

FX57:

FXKAOLD:

		DB	MANUAL			;CLOKTIK
		DB	ENV,$77
		DB	DUTY,%10000000
		DB	C4,5,C5,10
		DB	END

FXKA:
		DB	MANUAL			;CLOKTIK
		DB	ENV,$57
		DB	G3,5,C4,8
		DB	ENV,$00
		DB	C4,5
		DB	END
FXKB:		DB	MANUAL,ENV,$C1,C4,4,G4,4,C4,4,G4,4,C4,16
		DB	ENV,$00
		DB	C4,5
		DB	END				;FT SHOT
FXKC:		DB	MANUAL,ENV,$C1,C4,4,D4,4,E4,4,G4,6,C5,8
		DB	END				;FT GOOD
FXKD:		DB	ENV,$F2
		DB	DUTY,%11000000
		DB	ARPON,28
		DB	C4,28
		DB	END
FXKD2:		DB	ENV,$F2
		DB	DUTY,%11000000
		DB	ARPON,28
		DB	C4,28
		DB	C4,28
		DB	END
FXKD4:		DB	ENV,$F2
		DB	DUTY,%11000000
		DB	ARPON,28
		DB	C4,28
		DB	C4,28
		DB	C4,28
		DB	C4,28
		DB	END
FXKE:		DB	ENV,$C5,ARPON,FLASH,C3,16
		DB	END
FXKF:		DB	DRUM,7,30		;BALL
		DB	END
FXKG:		DB	DRUM,9,30               ;RIM1
		DB	END
FXKH:		DB	DRUM,10,30		;CHARGE
		DB	END
FXKI:		DB	ENV,$A5,ARPON,FLASH2,C4,20 ;GOOD SHOT
		DB	END
FXKJ:		DB	DRUM,17,CR2
		DB	END
FXKL:		DB	DRUM,19,30,DRUM,20,50                   ;SMALLCHEER
		DB	END
FXKM:		DB	DRUM,21,12
		DB	END
FXKN:		DB	ENV,$40,LENGTH,2
		DB	DUTY,%01000000
		DB	B4
		DB	AS4
		DB	A4
		DB	GS4
		DB	G4
		DB	FS4
		DB	F4
		DB	E4
		DB	DS4
		DB	D4
		DB	CS4
		DB	C4
		DB	B3
		DB	AS3
		DB	A3
		DB	GS3
		DB	G3
		DB	FS3
		DB	F3
		DB	E3
		DB	DS3
		DB	D3
		DB	CS3
		DB	C3
		DB	B2
		DB	AS2
		DB	A2
		DB	GS2
		DB	G2
		DB	FS2
		DB	F2
		DB	E2
		DB	DS2
		DB	D2
		DB	CS2
		DB	C2
		DB	B1
		DB	AS1
		DB	A1
		DB	GS1
		DB	G1
		DB	FS1
		DB	F1
		DB	E1
		DB	DS1
		DB	D1
		DB	CS1
		DB	C1
		DB	END
FXKO:		DB	MANUAL,WAVE			;PASS
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	D5,5
		DB	END


TblMzTune:			;[SONGLIST]
		DW	SILENCE,SILENCE,SILENCE,SILENCE		;0
		DW	MERM011,MERM012,MERM013,MERM014		;1
		DW	MERM021,MERM022,MERM023,MERM024		;2
		DW	MERM031,MERM032,MERM033,MERM034		;3
		DW	MERM041,MERM042,MERM043,MERM044		;4
		DW	MERM051,MERM052,MERM053,MERM054		;5
		DW	MERM061,MERM062,MERM063,MERM064		;6
		DW	MERM071,MERM072,MERM073,MERM074		;7
		DW	MERM081,MERM082,MERM083,MERM084		;8
		DW	NEW21,NEW22,NEW23,NEW24			;9
;the following are in the second bank
		DW	MERM091,MERM092,MERM093,MERM094		;9+1
		DW	MERM101,MERM102,MERM103,MERM104		;10+1
		DW	MERM111,MERM112,MERM113,MERM114		;11+1
		DW	MERM121,MERM122,MERM123,MERM124		;12+1
		DW	MERM131,MERM132,MERM133,MERM134		;13+1
		DW	MERM141,MERM142,MERM143,MERM144		;14+1
		DW	MERM151,MERM152,MERM153,MERM154		;15+1
		DW	MERM161,MERM162,MERM163,MERM164		;16+1
		DW	MERM171,MERM172,MERM173,MERM174		;17+1
		DW	MERM181,MERM182,MERM183,MERM184		;18+1
		DW	DITTY011,DITTY012,DITTY013,DITTY014	;19+1
		DW	NEW11,NEW12,NEW13,NEW14			;20+1
		DW	DITTY03A1,DITTY03A2,DITTY03A3,DITTY03A4	;21+1

TblMzTuneEnd:

;
; SEQ - Sequence lists.	[SEQLIST]
;

TblMzSeq:	DW      SEQ0
		DW      SEQ1
		DW      SEQ2	;
		DW      SEQ3	;[MERM01A,1]
		DW      SEQ4	;[MERM01A,2]
		DW      SEQ5	;[MERM01A,3]
		DW      SEQ6	;[SAVE-ATTACK PIANO/DITTY]
		DW      SEQ7	;[MERM01BC,1]
		DW      SEQ8	;[MERM01BC,2]
		DW      SEQ9	;[MERM01BC,3]
		DW      SEQ10	;[MERM02A,1]
		DW      SEQ11	;[MERM02A,2]
		DW      SEQ12	;[MERM02A,3]
		DW      SEQ13	;[MERM02BC,1]
		DW      SEQ14	;[MERM02BC,2]
		DW      SEQ15	;[MERM02BC,3]
		DW      SEQ16	;[MERM03AB,1]
		DW      SEQ17	;[MERM03AB,2]
		DW      SEQ18	;[MERM03AB,3]
		DW      SEQ19	;[MERM04AB,1]
		DW      SEQ20	;[MERM04AB,2]
		DW      SEQ21	;[MERM04AB,3]
		DW      SEQ22	;[MERM04AB,4]
		DW      SEQ23	;[MERM05AB,1]
		DW      SEQ24	;[MERM05AB,2]
		DW      SEQ25	;[MERM05AB,3]
		DW      SEQ26	;[MERM05AB,4]
		DW      SEQ27
		DW      SEQ28	;[SAVE-BANJO/GTR-SHORT ATTACK]
		DW      SEQ29	;[SAVE-SYNTH-ORGAN-W/VIBRATO]
		DW      SEQ30
		DW      SEQ31
		DW      SEQ32	;[SAVE-PIANO-ACCOMP/CHORDS]
		DW      SEQ33
		DW      SEQ34
		DW      SEQ35	;[SAVE-FLUTE-CLARINET]
		DW      SEQ36
		DW      SEQ37	;[SAVE-PIANO-ACCOMP/CHORDS]
		DW      SEQ38	;[SAVE-FLUTE-CLARINET]
		DW      SEQ39	;[SAVE-FLUTE-CLARINET]
		DW      SEQ40	;[MERM06A,1]
		DW      SEQ41	;[MERM06A,2]
		DW      SEQ42	
		DW      SEQ43	;[MERM06A,3]
		DW      SEQ44	;[MERM06BC,1]
		DW      SEQ45	;[MERM06BC,2]
		DW      SEQ46	;[MERM06BC,3]
		DW      SEQ47	;[MERM07A,1]
		DW      SEQ48	;[MERM07A,2]
		DW      SEQ49	;[MERM07A,3]
		DW      SEQ50	;[MERM07BC,1]
		DW      SEQ51	;[MERM07BC,2]
		DW      SEQ52	;[MERMO7BC,3]
		DW      SEQ53	;[MERM08A,1]
		DW      SEQ54	;[MERM08A,2]
		DW      SEQ55	;[MERM08A,3]
		DW      SEQ56	;[MERM08BC,1]
		DW      SEQ57	;[MERM08BC,2]
		DW      SEQ58	;[MERM08BC,3]
		DW      SEQ59	;[MERM08BC,4]
		DW      SEQ60	;[MERM09A,1]
		DW      SEQ61	;[MERM09A,2]
		DW      SEQ62	;[MERM09A,3]
		DW      SEQ63	;[MERM09B,1]
		DW      SEQ64	;[MERM09B,2]
		DW      SEQ65	;[MERM09B,3]
		DW      SEQ66	;[MERM10A,1]
		DW      SEQ67	;[MERM10A,2]
		DW      SEQ68	;[MERM10A,3]
		DW      SEQ69	;[MERM10B,1]
		DW      SEQ70	;[MERM10B,2]
		DW      SEQ71	;[MERM10B,3]
		DW      SEQ72	;[MERM10C,1]
		DW      SEQ73	;[MERM10C,2]
		DW      SEQ74	;[MERM10C,3]
		DW      SEQ75	;[MERM11A1,1]
		DW      SEQ76	;[MERM11A1,2]
		DW      SEQ77	;[MERM11A1,3]
		DW      SEQ78	;[MERM11A1,4]
		DW      SEQ79	;[MERM11A2,1]
		DW      SEQ80	;[MERM11A2,2]
		DW      SEQ81	;[MERM11A2,3]
		DW      SEQ82	;[MERM11A2,4]
		DW      SEQ83	;[MERM08A-REST]
		DW      SEQ84	;[MERM12A-REST]
		DW      SEQ85
		DW      SEQ86	;[SAVE-FLUTE-MELODY]
		DW      SEQ87	;[MERM11B,1]
		DW      SEQ88	;[MERM11B,2]
		DW      SEQ89	;[MERM11B,3]
		DW      SEQ90	;[MERM11B,4]
		DW      SEQ91	;[SAVE-BASS]
		DW      SEQ92	;[MERM11C,1]
		DW      SEQ93	;[MERM11C,2]
		DW      SEQ94	;[MERM11C,3]
		DW      SEQ95	;[MERM11C,4]
		DW      SEQ96	;New 1
		DW      SEQ97	;New 1
		DW      SEQ98	;New 1
		DW      SEQ99	;New 1
		DW      SEQ100	;New 1
		DW      SEQ101	;New 1
		DW      SEQ102	;New 1
		DW      SEQ103	;New 1
		DW      SEQ104	;New 1
		DW      SEQ105	;New 1
		DW      SEQ106	;New 1
		DW      SEQ107	;New 1
		DW      SEQ108	;New 1
		DW      SEQ109	;New 1
		DW      SEQ110	;New 1
		DW      SEQ111
		DW      SEQ112
		DW      SEQ113
		DW	SEQ114
		DW	SEQ115	;[MERM12A,2] (NO 12A,1)
		DW	SEQ116	;[MERM12A,3]
		DW	SEQ117	;[MERM12B,1]
		DW	SEQ118	;[MERM12B,2]
		DW	SEQ119	;[MERM12B,3]
		DW	SEQ120	;[MERM12B,4]
		DW	SEQ121	;[MERM12C,1]
		DW	SEQ122	;[MERM12C,2]
		DW	SEQ123	;[MERM12C,3]
		DW	SEQ124	;[MERM12C,4]
		DW	SEQ125	;[DITTY01,1]
		DW	SEQ126	;[DITTY01,2]
		DW	SEQ127	;[DITTY01,3]
		DW	SEQ128	;[DITTY02,1]
		DW	SEQ129	;[DITTY02,2]
		DW	SEQ130	;[DITTY02,3]
		DW	SEQ131	;[DITTY03A,1]
		DW	SEQ132	;[DITTY03A,2]
		DW	SEQ133
		DW	SEQ134
		DW	SEQ135
		DW	SEQ136
		DW	SEQ137
		DW	SEQ138
		DW	SEQ139
		DW	SEQ140	;
		DW	SEQ141	;[MERM13A,1]
		DW	SEQ142	;[MERM13A,2]
		DW	SEQ143	;[MERM13A,3]
		DW	SEQ144	;[MERM13B,1]
		DW	SEQ145	;[MERM13B,2]
		DW	SEQ146	;[MERM13B,3]
		DW	SEQ147	;[MERM14A,1]
		DW	SEQ148	;[MERM14A,2]
		DW	SEQ149	;[MERM14A,3]
		DW	SEQ150	;[MERM14B,1]
		DW	SEQ151	;[MERM14B,2]
		DW	SEQ152	;[MERM14B,3]
		DW	SEQ153	;[MERM14C,1]
		DW	SEQ154	;[MERM14C,2]
		DW	SEQ155	;[MERM14C,3]
		DW	SEQ156	;[MERM15A,1]
		DW	SEQ157	;[MERM15A,2]
		DW	SEQ158	;[MERM15B,3]
		DW	SEQ159	;[MERM15B,1]
		DW	SEQ160	;[MERM15B,2]
		DW	SEQ161	;[MERM15B,3]
		DW	SEQ162	;[MERM16A,1]
		DW	SEQ163	;[MERM16A,2]
		DW	SEQ164	;[MERM16A,3]
		DW	SEQ165	;[MERM16B,1]
		DW	SEQ166	;[MERM16B,2]
		DW	SEQ167	;[MERM16B,3]
		DW	SEQ168	;[MERM17A,1]
		DW	SEQ169	;[MERM17A,2]
		DW	SEQ170	;[MERM17A,3]
		DW	SEQ171	;[MERM17B,1]
		DW	SEQ172	;[MERM17B,2]
		DW	SEQ173	;[MERM17B,3]
		DW	SEQ174	;[MERM18A,1]
		DW	SEQ175	;[MERM18A,2]
		DW	SEQ176	;[MERM18A,3]
		DW	SEQ177	;[MERM18B,1]
		DW	SEQ178	;[MERM18B,2]
		DW	SEQ179	;[MERM18B,3]


SILENCE:	DB	0
		DW	END


SEQ0:	DB      MANUAL,REST,DSB3,END
SEQ1:	DB      MANUAL,REST,DSB3,END


SEQ2:





;--------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
; <<< BEGIN MERMAID 2 SEQ DATA >>>  <<< SEE BELOW >>>
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------

SEQ42:		DB      POKE,255&rNR52,$80	;[INITIALIZATION SEQUENCE - KEEP !]
		DB      POKE,255&rNR30,$80
		DB      POKE,255&rNR10,$00
		DB      POKE,255&rNR51,$FF
		DB      POKE,255&rNR50,$77
		DB      END

OLD1		EQU	0

		IF	SOUND1

 IF OLD1 ;OLD Song 1
SEQ3:		DB	MANUAL		;[MERM01A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	C5,7
		db	B4,7
		db	A4,7
		db	B4,7
		db	A4,7
		db	B4,7
		db	A4,7
		db	G4,7
		db	F4,7
		db	G4,7
		db	F4,7
		db	G4,7
		db	C5,7
		db	B4,7
		db	A4,7
		db	B4,7
		db	A4,7
		db	B4,7
		db	E5,7
		db	D5,7
		db	C5,7
		db	B4,7
		db	A4,7
		db	B4,7
		db	C5,7
		db	B4,7
		db	A4,7
		db	B4,10
		db	REST,10
		db	G3,21
		db	C4,21
		db	END

SEQ4:		db	MANUAL,GLIOFF	;[MERM01A,2]
		db	ENV,$37
		db	F3,7
		db	G3,7
		db	F3,7
		db	E3,7
		db	F3,7
		db	G3,7
		db	A3,7
		db	B3,7
		db	A3,7
		db	G3,7
		db	A3,7
		db	B3,7
		db	C4,7
		db	D4,7
		db	C4,7
		db	B3,7
		db	C4,7
		db	D4,7
		db	E4,7
		db	F4,7
		db	E4,7
		db	C4,7
		db	B3,7
		db	C4,7
		db	D4,7
		db	E4,7
		db	F4,7
		db	G4,52
		db	REST,10
		db	END

SEQ5:		db	MANUAL,GLIOFF	;[MERM01A,3]
		DB	ENV,$77
		db	G1,32
		db	REST,10
		db	G1,11
		db	REST,10
		db	G1,32
		db	REST,10
		db	G1,10
		db	REST,11
		db	G1,31
		db	REST,11
		db	G1,10
		db	REST,11
		db	G1,10
		db	REST,52
		db	END



SEQ6:
SEQ7:		DB	MANUAL		;[MERM01BC,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	D4,42
		db	C4,21
		db	G3,42
		db	E3,21
		db	G3,63
		db	REST,20
		db	G3,21
		db	B3,21
		db	C4,42
		db	B3,21
		db	D4,42
		db	C4,21
		db	F3,41
		db	E3,21
		db	F3,53
		db	REST,10
		db	E3,21
		db	A3,21
		db	E3,21
		db	D3,41
		db	E3,21
		db	F3,21
		db	B3,32
		db	A3,10
		db	G3,63
		db	F3,21
		db	E3,20
		db	F3,21
		db	G3,63
		db	A3,21
		db	GS3,21
		db	A3,42
		db	F4,21
		db	E4,20
		db	D4,63
		db	REST,21
		db	G3,21
		db	C4,21
		db	D4,42
		db	C4,20
		db	G3,42
		db	E3,21
		db	G3,63
		db	REST,21
		db	G3,21
		db	B3,21
		db	C4,41
		db	B3,21
		db	D4,42
		db	C4,21
		db	F3,42
		db	E3,21
		db	F3,52
		db	REST,10
		db	E3,21
		db	A3,21
		db	E3,21
		db	D3,42
		db	E3,21
		db	F3,21
		db	B3,31
		db	A3,10
		db	G3,63
		db	F3,21
		db	E3,21
		db	F3,21
		db	G3,62
		db	A3,21
		db	GS3,21
		db	A3,42
		db	F4,21
		db	E4,21
		db	D4,62
		db	REST,21
		db	A3,21
		db	B3,21
		db	CS4,42
		db	D4,21
		db	E4,42
		db	A3,20
		db	B3,84
		db	E4,21
		db	D4,21
		db	CS4,21
		db	E4,42
		db	GS4,20
		db	A4,42
		db	B3,21
		db	CS4,42
		db	D4,42
		db	CS4,10
		db	B3,11
		db	A3,41
		db	E3,21
		db	A3,52
		db	REST,11
		db	B3,42
		db	E3,21
		db	B3,21
		db	E4,20
		db	D4,21
		db	CS4,21
		db	B3,21
		db	A3,21
		db	B3,42
		db	E3,21
		db	A3,62
		db	REST,21
		db	G3,21
		db	C4,21
		db	END

SEQ8:		db	MANUAL,GLIOFF	;[MERM01BC,2]
		db	ENV,$47
		db	REST,21
		db	E3,11
		db	REST,10
		db	E3,11
		db	REST,10
		db	C3,52
		db	REST,32
		db	F2,10
		db	A2,11
		db	C3,10
		db	F3,11
		db	D3,20
		db	B2,21
		db	D3,21
		db	REST,21
		db	E3,11
		db	REST,10
		db	E3,10
		db	REST,11
		db	C3,21
		db	E3,21
		db	A3,10
		db	REST,11
		db	A2,10
		db	REST,10
		db	A2,11
		db	B2,10
		db	C3,11
		db	D3,10
		db	A2,21
		db	C3,21
		db	A2,21
		db	C3,42
		db	A2,21
		db	F2,21
		db	A2,20
		db	C3,21
		db	D3,42
		db	G2,21
		db	E3,21
		db	C3,21
		db	E3,21
		db	A2,31
		db	REST,10
		db	A2,21
		db	B2,21
		db	A2,21
		db	B2,21
		db	C3,31
		db	REST,11
		db	C3,21
		db	F3,21
		db	A3,21
		db	F3,20
		db	REST,21
		db	F2,11
		db	A2,10
		db	C3,11
		db	F3,10
		db	G3,21
		db	B2,21
		db	G3,21
		db	REST,21
		db	E3,10
		db	REST,11
		db	E3,10
		db	REST,10
		db	C3,53
		db	REST,31
		db	F2,11
		db	A2,10
		db	C3,10
		db	F3,11
		db	D3,21
		db	B2,21
		db	D3,21
		db	REST,20
		db	E3,11
		db	REST,10
		db	E3,11
		db	REST,10
		db	C3,21
		db	E3,21
		db	A3,10
		db	REST,11
		db	A2,10
		db	REST,11
		db	A2,10
		db	B2,11
		db	C3,10
		db	D3,11
		db	A2,20
		db	C3,21
		db	A2,21
		db	C3,42
		db	A2,21
		db	F2,21
		db	A2,21
		db	C3,21
		db	D3,41
		db	G2,21
		db	E3,21
		db	C3,21
		db	E3,21
		db	A2,31
		db	REST,11
		db	A2,21
		db	B2,21
		db	A2,20
		db	B2,21
		db	C3,32
		db	REST,10
		db	C3,21
		db	F3,21
		db	A3,21
		db	F3,21
		db	REST,21
		db	F2,10
		db	A2,11
		db	C3,10
		db	F3,10
		db	G3,21
		db	CS3,21
		db	D3,21
		db	REST,21
		db	E3,10
		db	REST,11
		db	E3,10
		db	REST,32
		db	A3,21
		db	E3,20
		db	REST,21
		db	D3,11
		db	FS3,10
		db	A3,11
		db	FS3,10
		db	GS3,63
		db	REST,21
		db	CS3,10
		db	E3,11
		db	A3,10
		db	E3,11
		db	CS4,41
		db	E3,21
		db	REST,21
		db	D3,11
		db	FS3,10
		db	A3,10
		db	FS3,11
		db	GS3,52
		db	REST,31
		db	CS3,11
		db	REST,10
		db	CS3,11
		db	REST,31
		db	CS3,11
		db	E3,10
		db	FS3,10
		db	E3,11
		db	REST,21
		db	E3,10
		db	REST,11
		db	B2,10
		db	REST,32
		db	B2,10
		db	E3,10
		db	GS3,11
		db	FS3,10
		db	E3,32
		db	REST,10
		db	E3,21
		db	GS3,42
		db	B2,21
		db	CS3,21
		db	A2,10
		db	CS3,10
		db	E3,11
		db	CS3,10
		db	F2,11
		db	A2,10
		db	C3,11
		db	F3,10
		db	A3,11
		db	G3,10
		db	END


SEQ9:		db	MANUAL,GLIOFF	;[MERM01BC,3]
		DB    ENV,$77
		db	C2,21
		db	G2,42
		db	E2,21
		db	C2,42
		db	REST,21
		db	G1,10
		db	REST,11
		db	G1,10
		db	REST,11
		db	G1,31
		db	REST,10
		db	G1,21
		db	E2,21
		db	C2,31
		db	REST,11
		db	G1,21
		db	C2,42
		db	D2,62
		db	G1,53
		db	REST,10
		db	A1,42
		db	B1,10
		db	C2,11
		db	D2,62
		db	G1,42
		db	A1,11
		db	B1,10
		db	C2,21
		db	E2,21
		db	C2,21
		db	F1,21
		db	C2,41
		db	G1,63
		db	A1,21
		db	E2,42
		db	D2,62
		db	REST,21
		db	G1,11
		db	REST,10
		db	G1,11
		db	REST,10
		db	G1,63
		db	C2,21
		db	G2,41
		db	E2,21
		db	C2,42
		db	REST,21
		db	G1,11
		db	REST,10
		db	G1,10
		db	REST,11
		db	G1,31
		db	REST,11
		db	G1,21
		db	E2,20
		db	C2,32
		db	REST,10
		db	G1,21
		db	C2,42
		db	D2,63
		db	G1,52
		db	REST,10
		db	A1,42
		db	B1,10
		db	C2,11
		db	D2,63
		db	G1,41
		db	A1,11
		db	B1,10
		db	C2,21
		db	E2,21
		db	C2,21
		db	F1,21
		db	C2,42
		db	G1,62
		db	A1,21
		db	E2,42
		db	D2,63
		db	REST,21
		db	G1,10
		db	REST,11
		db	G1,10
		db	REST,10
		db	G1,21
		db	FS1,21
		db	E1,21
		db	REST,21
		db	A1,10
		db	REST,11
		db	A1,10
		db	REST,32
		db	CS2,41
		db	REST,21
		db	B1,11
		db	REST,10
		db	B1,11
		db	REST,31
		db	E2,42
		db	A1,63
		db	REST,20
		db	E2,21
		db	CS2,21
		db	B1,52
		db	REST,11
		db	E2,21
		db	B1,21
		db	E2,21
		db	REST,20
		db	FS2,11
		db	REST,10
		db	FS2,11
		db	REST,31
		db	FS1,42
		db	REST,21
		db	GS2,10
		db	REST,11
		db	GS2,21
		db	REST,21
		db	GS1,20
		db	B1,21
		db	A1,42
		db	CS2,21
		db	E2,31
		db	REST,11
		db	E2,21
		db	A1,62
		db	G1,63
		db	END
 ELSE
SEQ3:
SEQ4:
SEQ5:
SEQ6:
SEQ7:
SEQ8:
SEQ9:
 ENDC


SEQ10:		db	MANUAL,GLIOFF	;[MERM02A,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	D4,6
		db	REST,6
		db	D4,3
		db	REST,2
		db	D4,3
		db	REST,3
		db	D4,6
		db	REST,5
		db	D4,11
		db	C4,12
		db	E4,5
		db	REST,6
		db	D4,6
		db	REST,5
		db	D4,3
		db	REST,3
		db	D4,3
		db	REST,2
		db	D4,6
		db	REST,6
		db	D4,11
		db	C4,11
		db	E4,6
		db	REST,5
		db	D4,34
		db	D3,6
		db	REST,5
		db	D3,6
		db	REST,6
		db	D3,5
		db	REST,6
		db	D3,28
		db	REST,6
		db	D3,11
		db	G3,11
		db	A3,11
		db	END

SEQ11:		db	MANUAL,GLIOFF	;[MERM02A,2]
		db	ENV,$77
		db	A3,6
		db	REST,6
		db	A3,3
		db	REST,2
		db	A3,3
		db	REST,3
		db	A3,3
		db	REST,8
		db	A3,11
		db	G3,12
		db	B3,5
		db	REST,6
		db	A3,6
		db	REST,5
		db	A3,3
		db	REST,3
		db	A3,3
		db	REST,2
		db	A3,3
		db	REST,9
		db	A3,11
		db	G3,11
		db	B3,6
		db	REST,5
		db	A3,23
		db	REST,11
		db	A2,3
		db	REST,8
		db	A2,3
		db	REST,9
		db	A2,3
		db	REST,8
		db	A2,31
		db	REST,3
		db	A2,5
		db	REST,28 ;filler
		db	END

SEQ12:		db	MANUAL,GLIOFF	;[MERM02A,3]
		db	ENV,$77
		db	D2,6
		db	REST,6
		db	D2,3
		db	REST,2
		db	D2,3
		db	REST,3
		db	D2,3
		db	REST,8
		db	D2,11
		db	C2,12
		db	E2,5
		db	REST,6
		db	D2,6
		db	REST,5
		db	D2,3
		db	REST,3
		db	D2,3
		db	REST,2
		db	D2,3
		db	REST,9
		db	D2,11
		db	C2,11
		db	E2,6
		db	REST,5
		db	D2,26
		db	REST,8
		db	D2,3
		db	REST,8
		db	D2,3
		db	REST,9
		db	D2,5
		db	REST,6
		db	D2,28
		db	REST,6
		db	D2,5
		db	REST,28 ;filler
		db	END

SEQ13:		db	MANUAL,GLIOFF	;[MERM02BC,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	G3,34
		db	A3,34
		db	B3,45
		db	A3,11
		db	G3,11
		db	A3,45
		db	D3,12
		db	B2,11
		db	D3,28
		db	REST,6
		db	D3,11
		db	E3,11
		db	FS3,11
		db	G3,34
		db	D4,34
		db	C4,22
		db	B3,12
		db	A3,11
		db	B3,11
		db	G3,11
		db	D4,90
		db	REST,12
		db	D4,11
		db	E4,11
		db	FS4,3
		db	REST,8
		db	G4,45
		db	FS4,12
		db	E4,11
		db	D4,45
		db	C4,11
		db	B3,11
		db	A3,45
		db	G3,12
		db	A3,11
		db	B3,34
		db	D3,33
		db	E3,45
		db	D3,11
		db	C3,12
		db	D3,45
		db	C3,11
		db	B2,11
		db	A2,62
		db	REST,6
		db	D3,11
		db	REST,22
		db	D3,12
		db	G3,11
		db	A3,11
		db	G3,34
		db	A3,34
		db	B3,45
		db	A3,11
		db	G3,11
		db	A3,45
		db	D3,11
		db	B2,12
		db	D3,28
		db	REST,5
		db	D3,12
		db	E3,11
		db	FS3,11
		db	G3,34
		db	D4,34
		db	C4,22
		db	B3,11
		db	A3,12
		db	B3,11
		db	G3,11
		db	D4,90
		db	REST,11
		db	D4,12
		db	E4,11
		db	FS4,3
		db	REST,8
		db	G4,45
		db	FS4,11
		db	E4,11
		db	D4,45
		db	C4,12
		db	B3,11
		db	A3,45
		db	G3,11
		db	A3,11
		db	B3,34
		db	D3,34
		db	E3,39
		db	REST,6
		db	D3,11
		db	E3,11
		db	FS3,34
		db	A3,34
		db	G3,90
		db	REST,11
		db	D3,34
		db	A3,39
		db	REST,6
		db	A3,8
		db	REST,3
		db	A3,6
		db	REST,5
		db	B3,34
		db	G3,34
		db	A3,101
		db	REST,34
		db	A3,42
		db	REST,3
		db	A3,8
		db	REST,3
		db	A3,11
		db	B3,34
		db	G3,34
		db	D4,90
		db	REST,11
		db	D4,11
		db	E4,11
		db	FS4,12
		db	G4,45
		db	FS4,11
		db	E4,11
		db	D4,45
		db	C4,11
		db	B3,12
		db	A3,45
		db	G3,11
		db	A3,11
		db	B3,34
		db	D3,34
		db	E3,45
		db	D3,11
		db	E3,11
		db	FS3,34
		db	D3,34
		db	G3,67
		db	REST,34
		db	D3,11
		db	G3,11
		db	A3,12
		db	END

SEQ14:		db	MANUAL,GLIOFF	;[MERM02BC,2]
		db	ENV,$37
		db	B2,34
		db	C3,34
		db	D3,22
		db	REST,12
		db	D3,22
		db	E3,11
		db	FS3,26
		db	REST,8
		db	FS3,11
		db	A2,12
		db	G2,11
		db	A2,11
		db	FS2,11
		db	A2,12
		db	FS2,22
		db	A2,9
		db	REST,2
		db	D3,34
		db	FS3,34
		db	E3,28
		db	REST,6
		db	E3,33
		db	FS3,34
		db	A2,23
		db	G2,8
		db	REST,3
		db	FS3,11
		db	E3,11
		db	D3,12
		db	FS3,11
		db	G3,11
		db	A3,11
		db	D4,34
		db	D3,34
		db	E3,67
		db	FS3,34
		db	D3,34
		db	REST,11
		db	D3,11
		db	E3,12
		db	B2,11
		db	G2,11
		db	B2,11
		db	C3,45
		db	B2,11
		db	A2,12
		db	B2,45
		db	A2,11
		db	G2,11
		db	FS2,23
		db	REST,11
		db	C3,11
		db	D3,11
		db	E3,12
		db	FS3,11
		db	REST,22
		db	A2,12
		db	B2,11
		db	D3,11
		db	B2,34
		db	C3,34
		db	D3,22
		db	REST,11
		db	D3,23
		db	E3,11
		db	FS3,25
		db	REST,9
		db	FS3,11
		db	A2,11
		db	G2,12
		db	A2,11
		db	FS2,11
		db	A2,11
		db	FS2,23
		db	A2,8
		db	REST,3
		db	D3,34
		db	FS3,34
		db	E3,28
		db	REST,5
		db	E3,34
		db	FS3,34
		db	A2,22
		db	G2,9
		db	REST,3
		db	FS3,11
		db	E3,11
		db	D3,11
		db	FS3,12
		db	G3,11
		db	A3,11
		db	D4,34
		db	D3,33
		db	E3,68
		db	FS3,34
		db	D3,33
		db	REST,12
		db	D3,11
		db	E3,11
		db	B2,11
		db	G2,12
		db	B2,11
		db	C3,39
		db	REST,6
		db	B2,11
		db	C3,11
		db	D3,34
		db	FS3,34
		db	D3,28
		db	REST,6
		db	D3,5
		db	REST,6
		db	D3,5
		db	REST,6
		db	D3,6
		db	REST,5
		db	D3,34
		db	B2,34
		db	A2,28
		db	REST,6
		db	FS2,5
		db	REST,6
		db	FS2,5
		db	REST,6
		db	FS2,11
		db	G2,34
		db	B2,34
		db	FS3,34
		db	A2,5
		db	REST,6
		db	A2,5
		db	REST,6
		db	A2,11
		db	FS3,34
		db	D3,34
		db	A2,33
		db	FS3,6
		db	REST,6
		db	FS3,5
		db	REST,6
		db	FS3,11
		db	G3,34
		db	B2,34
		db	FS3,33
		db	A2,6
		db	REST,6
		db	A2,5
		db	REST,6
		db	A2,11
		db	D3,62
		db	REST,6
		db	B2,33
		db	E3,34
		db	E3,68
		db	D3,33
		db	FS3,31
		db	REST,3
		db	D3,34
		db	B2,11
		db	A2,11
		db	G2,12
		db	C3,33
		db	G2,6
		db	REST,6
		db	G2,5
		db	REST,6
		db	G2,11
		db	A2,34
		db	FS2,34
		db	D3,28
		db	REST,5
		db	D3,12
		db	C3,11
		db	B2,11
		db	A2,62
		db	REST,6 ;filler
		db	END

SEQ15:		db	MANUAL,GLIOFF	;[MERM02BC,3]
		db	ENV,$77
		db	B1,34
		db	A1,34
		db	G1,28
		db	REST,6
		db	G2,22
		db	C2,11
		db	D2,40
		db	REST,5
		db	D2,12
		db	E2,11
		db	D2,28
		db	REST,6
		db	D2,33
		db	B1,34
		db	A1,34
		db	G1,34
		db	C2,33
		db	D2,34
		db	FS2,23
		db	E2,11
		db	D2,11
		db	C2,11
		db	B1,12
		db	A1,33
		db	E2,34
		db	B1,34
		db	C2,67
		db	D2,34
		db	FS1,34
		db	G1,67
		db	C2,34
		db	G2,34
		db	G1,33
		db	C2,34
		db	D2,28
		db	REST,6
		db	A1,11
		db	B1,11
		db	C2,12
		db	D2,11
		db	REST,56
		db	B1,34
		db	A1,34
		db	G1,28
		db	REST,5
		db	G2,23
		db	C2,11
		db	D2,39
		db	REST,6
		db	D2,11
		db	E2,12
		db	D2,28
		db	REST,5
		db	D2,34
		db	B1,34
		db	A1,34
		db	G1,33
		db	C2,34
		db	D2,34
		db	FS2,22
		db	E2,12
		db	D2,11
		db	C2,11
		db	B1,11
		db	A1,34
		db	E2,34
		db	B1,33
		db	C2,68
		db	D2,34
		db	FS1,33
		db	G1,68
		db	C2,34
		db	E2,33
		db	D2,29
		db	REST,5
		db	D2,34
		db	G1,34
		db	B2,5
		db	REST,6
		db	B2,5
		db	REST,6
		db	B2,11
		db	G2,34
		db	G1,34
		db	D2,28
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,9
		db	REST,2
		db	D2,28
		db	REST,6
		db	D2,6
		db	REST,5
		db	D2,6
		db	REST,6
		db	D2,8
		db	REST,3
		db	D2,28
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,8
		db	REST,3
		db	D2,34
		db	A1,34
		db	D2,28
		db	REST,5
		db	D2,6
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,8
		db	REST,3
		db	D2,34
		db	G1,34
		db	D2,28
		db	REST,5
		db	D2,6
		db	REST,6
		db	D2,5
		db	REST,6
		db	D2,8
		db	REST,3
		db	D2,34
		db	C2,34
		db	E2,33
		db	B1,34
		db	C2,34
		db	G1,34
		db	FS1,33
		db	D2,34
		db	G1,68
		db	C2,31
		db	REST,2
		db	C2,6
		db	REST,6
		db	C2,5
		db	REST,6
		db	C2,11
		db	D2,34
		db	A1,34
		db	B1,33
		db	G1,34
		db	D2,62
		db	REST,6 ;filler
		db	END

SEQ16:		db	MANUAL,GLIOFF	;[MERM03AB,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	F3,36
		db	A3,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,27
		db	E3,9
		db	C3,23
		db	REST,4
		db	C3,9
		db	F3,18
		db	A3,5
		db	REST,4
		db	A3,5
		db	REST,4
		db	C4,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,54
		db	A3,9
		db	REST,9
		db	AS3,36
		db	A3,27
		db	G3,9
		db	A3,18
		db	F3,9
		db	REST,9
		db	C3,18
		db	D3,18
		db	F3,36
		db	E3,27
		db	D3,9
		db	C3,45
		db	REST,9
		db	C3,9
		db	REST,9
		db	F3,31
		db	REST,5
		db	A3,9
		db	REST,9
		db	A3,18
		db	G3,27
		db	E3,9
		db	C3,18
		db	REST,9
		db	C3,9
		db	F3,17
		db	A3,5
		db	REST,4
		db	A3,5
		db	REST,4
		db	C4,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,54
		db	A3,9
		db	REST,9
		db	AS3,54
		db	A3,9
		db	G3,9
		db	A3,54
		db	G3,9
		db	F3,9
		db	G3,54
		db	A3,9
		db	F3,9
		db	G3,54
		db	C3,9
		db	REST,9
		db	F3,36
		db	A3,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,27
		db	E3,9
		db	C3,22
		db	REST,5
		db	C3,9
		db	F3,18
		db	A3,4
		db	REST,5
		db	A3,4
		db	REST,5
		db	C4,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,54
		db	A3,9
		db	REST,9
		db	AS3,35
		db	A3,27
		db	G3,9
		db	A3,18
		db	F3,9
		db	REST,9
		db	C3,18
		db	D3,18
		db	F3,36
		db	E3,27
		db	D3,9
		db	C3,45
		db	REST,9
		db	C3,9
		db	REST,9
		db	F3,32
		db	REST,4
		db	A3,9
		db	REST,9
		db	A3,18
		db	G3,27
		db	E3,9
		db	C3,18
		db	REST,9
		db	C3,9
		db	F3,18
		db	A3,4
		db	REST,5
		db	A3,4
		db	REST,5
		db	C4,9
		db	REST,9
		db	A3,9
		db	REST,9
		db	G3,54
		db	A3,9
		db	REST,9
		db	AS3,54
		db	A3,9
		db	G3,9
		db	A3,54
		db	G3,9
		db	F3,9
		db	G3,53
		db	A3,9
		db	F3,9
		db	G3,54
		db	C4,9
		db	REST,9
		db	C4,36
		db	AS3,27
		db	A3,9
		db	G3,54
		db	C4,9
		db	REST,9
		db	C4,36
		db	D4,27
		db	E4,9
		db	C4,54
		db	AS3,4
		db	REST,14
		db	A3,18
		db	F3,4
		db	REST,5
		db	F3,4
		db	REST,5
		db	F3,18
		db	A3,9
		db	REST,9
		db	G3,27
		db	E3,9
		db	C3,18
		db	F3,9
		db	REST,9
		db	A3,18
		db	F3,4
		db	REST,5
		db	F3,4
		db	REST,5
		db	F3,18
		db	A3,9
		db	REST,9
		db	G3,54
		db	C3,9
		db	REST,9
		db	F3,27
		db	REST,9
		db	A3,13
		db	REST,4
		db	A3,5
		db	REST,13
		db	G3,27
		db	E3,9
		db	C3,23
		db	REST,4
		db	C3,9
		db	F3,18
		db	A3,5
		db	REST,4
		db	A3,5
		db	REST,4
		db	C4,18
		db	A3,5
		db	REST,13
		db	G3,54
		db	A3,9
		db	REST,9
		db	AS3,54
		db	A3,9
		db	G3,9
		db	A3,54
		db	G3,9
		db	F3,9
		db	G3,54
		db	E3,9
		db	G3,9
		db	F3,54
		db	C3,13
		db	REST,5 ;filler
		db	END

SEQ17:		db	MANUAL,GLIOFF	;[MERM03AB,2]
		db	ENV,$57
		db	A2,54
		db	C3,5
		db	REST,13
		db	E3,27
		db	C3,9
		db	G2,27
		db	REST,9
		db	A2,18
		db	C3,5
		db	REST,4
		db	C3,5
		db	REST,4
		db	A3,18
		db	F3,9
		db	REST,9
		db	E3,18
		db	D3,9
		db	E3,9
		db	C3,18
		db	F3,9
		db	REST,9
		db	D3,54
		db	E3,18
		db	C3,36
		db	A2,27
		db	REST,27
		db	A2,9
		db	C3,9
		db	B2,18
		db	REST,9
		db	B2,9
		db	G2,54
		db	REST,18
		db	A2,54
		db	C3,13
		db	REST,5
		db	E3,27
		db	C3,9
		db	G2,31
		db	REST,5
		db	A2,17
		db	C3,5
		db	REST,4
		db	C3,5
		db	REST,4
		db	A3,18
		db	F3,9
		db	REST,9
		db	E3,18
		db	D3,9
		db	E3,9
		db	C3,18
		db	F3,18
		db	D3,54
		db	E3,18
		db	C3,41
		db	REST,13
		db	C3,9
		db	REST,9
		db	AS2,50
		db	REST,4
		db	C3,9
		db	D3,9
		db	E3,36
		db	G2,36
		db	A2,54
		db	C3,4
		db	REST,14
		db	E3,27
		db	C3,9
		db	G2,27
		db	REST,9
		db	A2,18
		db	C3,4
		db	REST,5
		db	C3,4
		db	REST,5
		db	A3,18
		db	F3,9
		db	REST,9
		db	E3,18
		db	D3,9
		db	E3,9
		db	C3,18
		db	F3,9
		db	REST,9
		db	D3,53
		db	E3,18
		db	C3,36
		db	A2,27
		db	REST,27
		db	A2,9
		db	C3,9
		db	B2,18
		db	REST,9
		db	B2,9
		db	G2,54
		db	REST,18
		db	A2,54
		db	C3,14
		db	REST,4
		db	E3,27
		db	C3,9
		db	G2,31
		db	REST,5
		db	A2,18
		db	C3,4
		db	REST,5
		db	C3,4
		db	REST,5
		db	A3,18
		db	F3,9
		db	REST,9
		db	E3,18
		db	D3,9
		db	E3,9
		db	C3,18
		db	F3,18
		db	D3,54
		db	E3,18
		db	C3,40
		db	REST,14
		db	C3,9
		db	REST,9
		db	AS2,49
		db	REST,4
		db	C3,9
		db	D3,9
		db	E3,59
		db	REST,13
		db	A3,36
		db	D3,36
		db	E3,14
		db	REST,4
		db	E3,5
		db	REST,4
		db	E3,5
		db	REST,4
		db	E3,18
		db	REST,18
		db	A3,36
		db	AS3,27
		db	A3,9
		db	E3,63
		db	REST,9
		db	D3,9
		db	REST,9
		db	D3,4
		db	REST,5
		db	D3,4
		db	REST,5
		db	D3,18
		db	F3,9
		db	REST,9
		db	E3,27
		db	C3,9
		db	G2,18
		db	C3,9
		db	REST,9
		db	D3,9
		db	REST,9
		db	D3,4
		db	REST,5
		db	D3,4
		db	REST,5
		db	D3,18
		db	F3,4
		db	REST,14
		db	E3,54
		db	C3,13
		db	REST,5
		db	A2,45
		db	REST,8
		db	C3,9
		db	REST,9
		db	E3,27
		db	C3,9
		db	G2,32
		db	REST,4
		db	A2,18
		db	C3,5
		db	REST,4
		db	C3,5
		db	REST,4
		db	A3,18
		db	F3,18
		db	E3,18
		db	D3,9
		db	E3,9
		db	C3,18
		db	F3,18
		db	D3,54
		db	E3,18
		db	C3,54
		db	A2,18
		db	AS2,36
		db	G2,36
		db	C3,58
		db	REST,14 ;filler
		db	END


SEQ18:		db	MANUAL,GLIOFF	;[MERM03AB,3]
		db	ENV,$55
		db	F2,45
		db	REST,9
		db	F2,9
		db	REST,9
		db	C2,72
		db	F2,36
		db	E2,18
		db	D2,18
		db	C2,54
		db	D2,18
		db	AS1,45
		db	REST,9
		db	C2,18
		db	F1,36
		db	F2,18
		db	E2,18
		db	D2,36
		db	G1,36
		db	C2,72
		db	F2,45
		db	REST,9
		db	F2,4
		db	REST,14
		db	C2,72
		db	F2,35
		db	E2,18
		db	D2,18
		db	C2,54
		db	D2,18
		db	AS1,54
		db	C2,18
		db	F1,36
		db	A1,36
		db	G1,36
		db	G2,36
		db	C2,36
		db	E2,36
		db	F2,45
		db	REST,9
		db	F2,9
		db	REST,9
		db	C2,72
		db	F2,36
		db	E2,18
		db	D2,18
		db	C2,54
		db	D2,18
		db	AS1,44
		db	REST,9
		db	C2,18
		db	F1,36
		db	F2,18
		db	E2,18
		db	D2,36
		db	G1,36
		db	C2,72
		db	F2,45
		db	REST,9
		db	F2,5
		db	REST,13
		db	C2,72
		db	F2,36
		db	E2,18
		db	D2,18
		db	C2,54
		db	D2,18
		db	AS1,54
		db	C2,18
		db	F1,36
		db	A1,36
		db	G1,36
		db	G2,35
		db	C2,63
		db	REST,9
		db	F2,36
		db	AS1,36
		db	C2,18
		db	G2,5
		db	REST,4
		db	G2,5
		db	REST,4
		db	G2,18
		db	C2,18
		db	F2,32
		db	REST,4
		db	F2,27
		db	E2,9
		db	G2,36
		db	C2,36
		db	D2,45
		db	REST,9
		db	D2,9
		db	REST,9
		db	C2,49
		db	REST,5
		db	C2,9
		db	REST,9
		db	D2,40
		db	REST,14
		db	D2,9
		db	REST,9
		db	C2,27
		db	AS1,9
		db	A1,18
		db	G1,18
		db	F1,36
		db	REST,17
		db	F1,9
		db	REST,9
		db	C2,72
		db	F2,36
		db	E2,18
		db	D2,18
		db	C2,54
		db	D2,18
		db	AS1,54
		db	C2,18
		db	F1,54
		db	C2,18
		db	G1,36
		db	C2,36
		db	F1,54
		db	C2,18
		db	END

SEQ19:		db	MANUAL,GLIOFF	;[MERM04AB,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A2,19
		db	REST,27
		db	CS3,9
		db	E3,27
		db	CS3,27
		db	D3,19
		db	REST,27
		db	FS3,27
		db	A3,9
		db	D3,18
		db	REST,9
		db	CS3,9
		db	REST,37
		db	E3,9
		db	A3,27
		db	E3,9
		db	REST,18
		db	GS3,27
		db	FS3,19
		db	E3,9
		db	REST,18
		db	D3,9
		db	B2,18
		db	REST,9
		db	A2,9
		db	REST,37
		db	CS3,9
		db	E3,27
		db	A3,18
		db	REST,9
		db	FS3,18
		db	REST,27
		db	A3,37
		db	FS3,18
		db	REST,9
		db	E3,18
		db	REST,27
		db	GS3,28
		db	A3,9
		db	B3,18
		db	REST,9
		db	A3,9
		db	REST,36
		db	E3,9
		db	D3,28
		db	B2,18
		db	REST,9
		db	A2,18
		db	REST,27
		db	CS3,9
		db	E3,27
		db	CS3,28
		db	D3,18
		db	REST,27
		db	FS3,27
		db	A3,9
		db	D3,19
		db	REST,9
		db	CS3,9
		db	REST,36
		db	E3,9
		db	A3,27
		db	E3,9
		db	REST,19
		db	GS3,27
		db	FS3,18
		db	E3,9
		db	REST,18
		db	D3,9
		db	B2,18
		db	REST,9
		db	A2,10
		db	REST,36
		db	CS3,9
		db	E3,27
		db	A3,18
		db	REST,9
		db	FS3,19
		db	REST,27
		db	A3,36
		db	FS3,18
		db	REST,9
		db	E3,18
		db	REST,28
		db	GS3,27
		db	A3,9
		db	B3,18
		db	REST,9
		db	A3,55
		db	REST,27
		db	A3,27
		db	FS3,27
		db	D3,18
		db	A2,10
		db	REST,18
		db	D3,9
		db	FS3,18
		db	REST,9
		db	E3,27
		db	CS3,18
		db	A2,9
		db	REST,19
		db	CS3,9
		db	E3,18
		db	REST,9
		db	GS3,27
		db	FS3,18
		db	E3,9
		db	REST,19
		db	D3,9
		db	B2,18
		db	REST,9
		db	CS3,27
		db	D3,18
		db	E3,9
		db	REST,28
		db	A2,27
		db	FS3,27
		db	D3,18
		db	A2,9
		db	REST,18
		db	D3,9
		db	FS3,19
		db	REST,9
		db	E3,27
		db	CS3,18
		db	A2,9
		db	REST,18
		db	CS3,9
		db	E3,9
		db	REST,19
		db	FS3,27
		db	GS3,18
		db	A3,9
		db	REST,18
		db	GS3,9
		db	FS3,18
		db	REST,9
		db	GS3,28
		db	FS3,18
		db	E3,27
		db	REST,9
		db	E3,18
		db	REST,9 ;filler
		db	END

SEQ20:		db	MANUAL,GLIOFF	;[MERM04AB,2]
		db	ENV,$47
		db	REST,28
		db	CS3,9
		db	REST,9
		db	CS3,9
		db	REST,27
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,28
		db	B2,9
		db	REST,9
		db	B2,9
		db	REST,27
		db	FS2,9
		db	REST,9
		db	FS2,9
		db	REST,28
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,27
		db	CS3,9
		db	REST,9
		db	CS3,9
		db	REST,27
		db	B2,10
		db	REST,9
		db	B2,9
		db	REST,27
		db	E2,9
		db	REST,9
		db	E2,9
		db	REST,27
		db	A2,9
		db	REST,10
		db	A2,9
		db	REST,27
		db	CS3,9
		db	REST,9
		db	CS3,9
		db	REST,27
		db	B2,9
		db	REST,9
		db	B2,10
		db	REST,27
		db	D3,9
		db	REST,9
		db	D3,9
		db	A2,9
		db	REST,36
		db	B2,28
		db	E3,9
		db	GS3,18
		db	REST,9
		db	CS3,27
		db	REST,109
		db	CS3,9
		db	REST,9
		db	CS3,9
		db	REST,27
		db	A2,10
		db	REST,9
		db	A2,9
		db	REST,27
		db	B2,9
		db	REST,9
		db	B2,9
		db	REST,27
		db	FS2,9
		db	REST,10
		db	FS2,9
		db	REST,27
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,27
		db	CS3,9
		db	REST,9
		db	CS3,10
		db	REST,27
		db	B2,9
		db	REST,9
		db	B2,9
		db	REST,27
		db	E2,9
		db	REST,9
		db	E2,9
		db	REST,28
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,27
		db	CS3,9
		db	REST,9
		db	CS3,9
		db	REST,28
		db	B2,9
		db	REST,9
		db	B2,9
		db	REST,27
		db	D3,9
		db	REST,9
		db	D3,9
		db	A2,9
		db	REST,37
		db	B2,27
		db	E3,9
		db	GS3,18
		db	REST,9
		db	CS3,27
		db	REST,109
		db	FS2,9
		db	REST,9
		db	FS2,10
		db	REST,27
		db	A2,18
		db	D3,9
		db	REST,27
		db	E2,9
		db	REST,9
		db	E2,9
		db	REST,28
		db	CS3,18
		db	A2,9
		db	REST,27
		db	GS2,9
		db	REST,9
		db	GS2,9
		db	REST,28
		db	GS2,18
		db	E2,9
		db	REST,27
		db	GS2,18
		db	A2,9
		db	REST,28
		db	E2,9
		db	REST,9
		db	E2,9
		db	REST,27
		db	FS2,9
		db	REST,9
		db	FS2,9
		db	REST,27
		db	A2,19
		db	D3,9
		db	REST,27
		db	E2,9
		db	REST,9
		db	E2,9
		db	REST,27
		db	CS3,18
		db	A2,10
		db	REST,27
		db	B2,18
		db	DS3,9
		db	REST,18
		db	E3,9
		db	DS3,9
		db	REST,18
		db	B2,28
		db	A2,18
		db	GS2,9
		db	REST,54 ;filler
		db	END

SEQ21:		db	MANUAL,GLIOFF	;[MERM04AB,3]
		db	ENV,$56
		db	A1,19
		db	REST,27
		db	CS2,36
		db	A1,27
		db	B1,19
		db	REST,27
		db	D2,36
		db	B1,27
		db	A1,18
		db	REST,28
		db	CS2,36
		db	A1,18
		db	REST,9
		db	E2,9
		db	REST,37
		db	E1,9
		db	REST,18
		db	FS1,9
		db	GS1,18
		db	REST,9
		db	A1,18
		db	REST,28
		db	CS2,36
		db	A1,27
		db	B1,18
		db	REST,27
		db	D2,37
		db	B1,27
		db	CS2,45
		db	E2,28
		db	CS2,9
		db	E2,27
		db	A2,18
		db	REST,27
		db	CS2,9
		db	E2,55
		db	A1,18
		db	REST,27
		db	CS2,36
		db	A1,28
		db	B1,18
		db	REST,27
		db	D2,36
		db	B1,28
		db	A1,18
		db	REST,27
		db	CS2,36
		db	A1,18
		db	REST,10
		db	E2,9
		db	REST,36
		db	E1,9
		db	REST,18
		db	FS1,9
		db	GS1,18
		db	REST,9
		db	A1,19
		db	REST,27
		db	CS2,36
		db	A1,27
		db	B1,19
		db	REST,27
		db	D2,36
		db	B1,27
		db	CS2,46
		db	E2,27
		db	CS2,9
		db	E2,27
		db	A2,18
		db	REST,28
		db	E2,9
		db	A1,27
		db	CS2,27
		db	D2,9
		db	REST,36
		db	D2,10
		db	FS2,27
		db	D2,18
		db	REST,9
		db	CS2,9
		db	REST,36
		db	CS2,9
		db	A1,28
		db	CS2,27
		db	B1,9
		db	REST,36
		db	B1,9
		db	E2,28
		db	GS1,27
		db	A1,9
		db	REST,18
		db	B1,18
		db	CS2,9
		db	REST,18
		db	E2,10
		db	CS2,27
		db	D2,9
		db	REST,36
		db	D2,9
		db	FS2,27
		db	D2,19
		db	REST,9
		db	CS2,9
		db	REST,36
		db	CS2,9
		db	A1,27
		db	CS2,28
		db	B1,9
		db	REST,36
		db	FS2,9
		db	DS2,27
		db	B1,27
		db	E2,10
		db	REST,36
		db	E2,9
		db	B1,27
		db	E2,27
		db	END

SEQ22:		db	MANUAL,GLIOFF	;[MERM04AB,4]
		db	ENV,$F1
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,134
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,19
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,8,9
		db	REST,10
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,10
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	DRUM,8,18
		db	REST,37
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,28
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,8,9
		db	REST,9
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,10
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,9
		db	REST,10
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	DRUM,8,18
		db	REST,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,10
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,28
		db	DRUM,8,9
		db	REST,9
		db	DRUM,8,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,28
		db	DRUM,6,18
		db	DRUM,8,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,10
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,19
		db	DRUM,8,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,8,9
		db	REST,9
		db	DRUM,8,10
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	DRUM,6,10
		db	REST,18
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	DRUM,6,9
		db	REST,18 ;filler
		db	END

SEQ23:		db	MANUAL,GLIOFF	;[MERM05AB,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	G3,13
		db	REST,26
		db	G3,13
		db	REST,13
		db	G3,13
		db	F3,6
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	D3,13
		db	REST,12
		db	D3,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	G3,12
		db	REST,13
		db	G3,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,25
		db	G3,13
		db	D3,26
		db	F3,19
		db	REST,7
		db	G3,12
		db	REST,26
		db	G3,13
		db	REST,13
		db	G3,13
		db	F3,6
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	D3,13
		db	REST,13
		db	D3,12
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	G3,6
		db	REST,19
		db	G3,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,25
		db	B3,7
		db	REST,19
		db	B3,13
		db	A3,13
		db	REST,13
		db	G3,12
		db	REST,26
		db	G3,13
		db	REST,13
		db	G3,13
		db	F3,6
		db	REST,7
		db	F3,12
		db	G3,13
		db	REST,26
		db	D3,13
		db	REST,13
		db	D3,12
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	G3,13
		db	REST,12
		db	G3,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,25
		db	G3,13
		db	D3,26
		db	F3,19
		db	REST,7
		db	G3,13
		db	REST,25
		db	G3,13
		db	REST,13
		db	G3,13
		db	F3,6
		db	REST,7
		db	F3,12
		db	G3,13
		db	REST,26
		db	D3,13
		db	REST,13
		db	D3,13
		db	F3,6
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,26
		db	G3,6
		db	REST,19
		db	G3,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	G3,13
		db	REST,25
		db	B3,7
		db	REST,19
		db	B3,13
		db	A3,13
		db	REST,13
		db	G4,6
		db	REST,7
		db	G4,12
		db	F4,13
		db	D4,7
		db	REST,19
		db	D4,13
		db	C4,13
		db	D4,6
		db	REST,6
		db	B3,13
		db	G3,13
		db	E3,13
		db	FS3,13
		db	REST,13
		db	D4,13
		db	C4,12
		db	D4,13
		db	B3,13
		db	G3,7
		db	REST,19
		db	F3,38
		db	REST,13
		db	C4,7
		db	D4,6
		db	B3,13
		db	G3,6
		db	REST,20
		db	F3,38
		db	G3,13
		db	REST,13
		db	G4,6
		db	REST,7
		db	G4,12
		db	F4,13
		db	D4,7
		db	REST,19
		db	D4,13
		db	C4,13
		db	D4,6
		db	REST,7
		db	B3,12
		db	G3,13
		db	E3,13
		db	FS3,13
		db	REST,13
		db	D4,13
		db	C4,12
		db	D4,13
		db	B3,13
		db	G3,7
		db	REST,19
		db	F3,38
		db	REST,13
		db	C4,7
		db	D4,6
		db	B3,13
		db	C4,13
		db	CS4,13
		db	D4,6
		db	REST,19
		db	D3,13
		db	E3,13
		db	D3,6
		db	REST,7 ;filler
		db	END

SEQ24:		db	MANUAL,GLIOFF	;[MERM05AB,2]
		db	ENV,$57
		db	REST,255
		db	REST,157
		db	B3,12
		db	REST,26
		db	B3,13
		db	REST,13
		db	B3,13
		db	A3,6
		db	REST,6
		db	A3,13
		db	B3,7
		db	REST,32
		db	F3,13
		db	REST,13
		db	F3,12
		db	A3,7
		db	REST,6
		db	A3,13
		db	B3,13
		db	REST,26
		db	B3,12
		db	REST,13
		db	B3,13
		db	A3,7
		db	REST,6
		db	A3,6
		db	REST,7
		db	B3,13
		db	REST,25
		db	D4,13
		db	REST,13
		db	D4,13
		db	C4,13
		db	REST,13
		db	B2,12
		db	REST,26
		db	B2,7
		db	REST,32
		db	C3,25
		db	B2,7
		db	REST,32
		db	B2,6
		db	REST,32
		db	C3,26
		db	B2,7
		db	REST,32
		db	B2,6
		db	REST,32
		db	C3,26
		db	B2,6
		db	REST,32
		db	B2,13
		db	A2,26
		db	C3,13
		db	REST,13
		db	B3,13
		db	REST,25
		db	B3,13
		db	REST,13
		db	B3,13
		db	A3,6
		db	REST,7
		db	A3,12
		db	B3,7
		db	REST,32
		db	F3,13
		db	REST,13
		db	F3,13
		db	A3,6
		db	REST,6
		db	A3,13
		db	B3,13
		db	REST,26
		db	B3,13
		db	REST,12
		db	B3,13
		db	A3,7
		db	REST,6
		db	A3,7
		db	REST,6
		db	B3,13
		db	REST,25
		db	D4,13
		db	REST,13
		db	D4,13
		db	C4,13
		db	REST,13
		db	B3,6
		db	REST,7
		db	B3,12
		db	A3,13
		db	B3,7
		db	REST,19
		db	B3,13
		db	A3,13
		db	B3,12
		db	G3,13
		db	E3,13
		db	C3,13
		db	D3,13
		db	REST,13
		db	B3,13
		db	A3,12
		db	B3,13
		db	G3,13
		db	E3,7
		db	REST,19
		db	D3,38
		db	REST,26
		db	G3,13
		db	E3,6
		db	REST,20
		db	D3,32
		db	REST,6
		db	D3,7
		db	REST,19
		db	B3,6
		db	REST,7
		db	B3,12
		db	A3,13
		db	B3,7
		db	REST,19
		db	B3,13
		db	A3,13
		db	B3,13
		db	G3,12
		db	E3,13
		db	C3,13
		db	D3,13
		db	REST,13
		db	B3,13
		db	A3,12
		db	B3,13
		db	G3,13
		db	E3,7
		db	REST,19
		db	D3,38
		db	REST,26
		db	D3,13
		db	E3,13
		db	F3,13
		db	FS3,6
		db	REST,58 ;filler
		db	END

SEQ25:		db	MANUAL,GLIOFF	;[MERM05AB,3]
		db	ENV,$76
		db	G2,13
		db	REST,26
		db	G2,13
		db	REST,26
		db	F2,25
		db	G2,7
		db	REST,32
		db	D2,13
		db	REST,25
		db	F2,26
		db	G2,13
		db	REST,26
		db	G2,12
		db	REST,26
		db	F2,26
		db	G2,6
		db	REST,32
		db	G2,13
		db	D2,26
		db	F2,13
		db	REST,13
		db	G2,6
		db	REST,32
		db	D3,13
		db	REST,26
		db	C3,12
		db	REST,13
		db	D3,13
		db	REST,26
		db	B2,13
		db	REST,13
		db	G2,12
		db	C3,7
		db	REST,19
		db	G2,13
		db	REST,26
		db	D3,6
		db	REST,19
		db	D3,13
		db	C3,13
		db	F2,6
		db	REST,7
		db	G2,13
		db	REST,25
		db	G2,13
		db	REST,13
		db	G2,13
		db	F2,13
		db	FS2,13
		db	G2,12
		db	REST,26
		db	G2,13
		db	REST,26
		db	F2,25
		db	G2,7
		db	REST,32
		db	D2,13
		db	REST,25
		db	F2,26
		db	G2,13
		db	REST,26
		db	G2,13
		db	REST,25
		db	F2,26
		db	G2,6
		db	REST,32
		db	G2,13
		db	D2,26
		db	F2,13
		db	REST,13
		db	G2,6
		db	REST,32
		db	D3,13
		db	REST,26
		db	C3,13
		db	REST,12
		db	D3,13
		db	REST,26
		db	B2,13
		db	REST,13
		db	G2,13
		db	C3,6
		db	REST,19
		db	G2,13
		db	REST,26
		db	D3,6
		db	REST,19
		db	D3,13
		db	C3,13
		db	F2,7
		db	REST,6
		db	G2,13
		db	REST,25
		db	G2,13
		db	REST,13
		db	G2,13
		db	F2,13
		db	FS2,13
		db	G2,25
		db	REST,13
		db	G2,7
		db	REST,19
		db	G2,26
		db	REST,12
		db	C2,39
		db	D2,51
		db	REST,13
		db	D2,13
		db	G2,7
		db	REST,19
		db	A2,13
		db	F2,12
		db	C3,13
		db	A2,13
		db	F2,13
		db	D2,13
		db	G2,6
		db	REST,20
		db	A2,25
		db	F2,13
		db	B2,13
		db	REST,13
		db	G2,25
		db	REST,13
		db	G2,7
		db	REST,19
		db	G2,26
		db	REST,13
		db	C2,38
		db	D2,51
		db	REST,13
		db	D2,13
		db	G2,7
		db	REST,19
		db	A2,13
		db	F2,13
		db	C3,12
		db	A2,13
		db	F2,13
		db	G2,13
		db	A2,13
		db	DS2,13
		db	D2,6
		db	REST,19
		db	D2,39
		db	END

SEQ26:		db	MANUAL,GLIOFF	;[MERM05AB,4]
		db	ENV,$F1
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,70
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,7
		db	REST,19
		db	DRUM,6,6
		db	DRUM,6,7
		db	DRUM,8,13
		db	DRUM,6,6
		db	REST,19
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,6
		db	REST,7
		db	DRUM,6,6
		db	REST,20
		db	DRUM,6,6
		db	REST,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,7
		db	DRUM,6,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,6
		db	REST,20
		db	DRUM,8,6
		db	REST,19
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,19
		db	DRUM,8,6
		db	REST,7
		db	DRUM,6,6
		db	REST,19
		db	DRUM,8,7
		db	REST,19
		db	DRUM,6,7
		db	DRUM,6,6
		db	DRUM,8,6
		db	REST,33
		db	DRUM,6,6
		db	REST,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,7
		db	REST,19
		db	DRUM,6,6
		db	DRUM,6,7
		db	DRUM,8,13
		db	DRUM,6,6
		db	REST,19
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,6
		db	REST,20
		db	DRUM,6,6
		db	REST,7
		db	DRUM,8,6
		db	REST,6
		db	DRUM,6,7
		db	DRUM,6,6
		db	DRUM,8,7
		db	REST,6
		db	DRUM,6,6
		db	REST,20
		db	DRUM,8,6
		db	REST,19
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,19
		db	DRUM,8,6
		db	REST,7
		db	DRUM,6,6
		db	REST,19
		db	DRUM,8,7
		db	REST,19
		db	DRUM,6,7
		db	DRUM,6,6
		db	DRUM,8,6
		db	REST,33
		db	DRUM,6,6
		db	REST,6
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,70
		db	DRUM,6,7
		db	REST,6
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,6
		db	REST,58
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,19
		db	DRUM,8,6
		db	REST,58
		db	DRUM,6,6
		db	REST,7
		db	DRUM,8,6
		db	REST,20
		db	DRUM,8,6
		db	REST,32
		db	DRUM,8,7
		db	REST,32
		db	DRUM,6,6
		db	REST,6
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,70
		db	DRUM,6,7
		db	REST,6
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,57
		db	DRUM,6,7
		db	REST,6
		db	DRUM,8,7
		db	REST,19
		db	DRUM,8,6
		db	REST,58
		db	DRUM,6,6
		db	REST,7
		db	DRUM,6,6
		db	REST,7
		db	DRUM,8,6
		db	REST,7
		db	DRUM,8,6
		db	REST,58 ;filler
		db	END

SEQ27:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	REST,27
		db	G3,53
		db	B3,13
		db	A3,26
		db	B3,40
		db	REST,53
		db	G3,10
		db	REST,3
		db	G3,10
		db	REST,3
		db	G3,14
		db	A3,13
		db	B3,26
		db	A3,13
		db	B3,66
		db	REST,53
		db	C4,14
		db	B3,13
		db	C4,13
		db	G3,13
		db	C4,27
		db	G3,13
		db	E3,13
		db	REST,13
		db	E3,13
		db	G3,14
		db	E3,26
		db	C4,27
		db	D4,13
		db	E4,39
		db	D4,53
		db	REST,79
		db	C4,14
		db	D4,13
		db	E4,26
		db	D4,14
		db	REST,13
		db	D4,26
		db	E4,13
		db	C4,14
		db	D4,13
		db	REST,13
		db	C4,13
		db	REST,13
		db	C4,27
		db	B3,13
		db	D4,13
		db	C4,14
		db	REST,13
		db	C4,13
		db	REST,13
		db	D4,13
		db	B3,53
		db	REST,106 ;filler
		db	END
;total time = 1269
SEQ28:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	REST,27
		db	D3,13
		db	B2,13
		db	REST,14
		db	B2,13
		db	D3,26
		db	REST,27
		db	D3,13
		db	B2,13
		db	REST,13
		db	B2,13
		db	D3,14
		db	REST,39
		db	D3,14
		db	B2,13
		db	REST,13
		db	D3,13
		db	G3,13
		db	REST,40
		db	D3,13
		db	G3,13
		db	REST,14
		db	G3,13
		db	B3,13
		db	REST,40
		db	G3,13
		db	E3,13
		db	REST,13
		db	G3,14
		db	C3,26
		db	REST,26
		db	C3,14
		db	G2,13
		db	REST,13
		db	C3,13
		db	E3,14
		db	REST,39
		db	D3,13
		db	G3,14
		db	REST,13
		db	G3,13
		db	B3,13
		db	REST,40
		db	D3,13
		db	G3,13
		db	REST,13
		db	G3,14
		db	B3,13
		db	REST,53
		db	FS3,26
		db	A3,13
		db	FS3,14
		db	REST,52
		db	G3,27
		db	FS3,13
		db	E3,13
		db	REST,40
		db	D3,13
		db	B2,13
		db	REST,14
		db	G3,13
		db	D3,13
		db	REST,13
		db	B3,27
		db	G3,13
		db	D3,13
		db	REST,13
		db	B3,14
		db	FS3,13
		db	REST,13 ;filler
		db	END
;total time = 1269
SEQ29:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	G2,37
		db	REST,3
		db	G2,13
		db	D2,27
		db	G2,26
		db	B2,40
		db	D2,26
		db	G2,13
		db	D2,14
		db	REST,13
		db	G1,40
		db	D2,13
		db	E2,26
		db	D2,13
		db	REST,14
		db	G2,39
		db	D2,13
		db	REST,14
		db	B1,13
		db	G1,26
		db	C2,37
		db	REST,3
		db	C2,13
		db	E2,27
		db	G1,26
		db	C2,26
		db	REST,14
		db	C2,13
		db	REST,13
		db	G1,13
		db	C2,14
		db	REST,13
		db	G1,39
		db	B1,40
		db	D2,26
		db	G2,27
		db	D2,13
		db	B1,13
		db	REST,13
		db	D2,14
		db	G1,13
		db	REST,13
		db	D2,36
		db	REST,4
		db	D2,13
		db	A1,26
		db	D2,27
		db	C2,39
		db	E2,27
		db	D2,13
		db	C2,13
		db	REST,14
		db	G1,26
		db	REST,13
		db	D2,13
		db	E2,27
		db	D2,26
		db	G2,27
		db	D2,13
		db	B1,13
		db	REST,13
		db	G1,14
		db	D2,26
		db	END
;total time = 1269


SEQ30:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	REST,27
		db	D4,10
		db	REST,3
		db	D4,10
		db	REST,3
		db	D4,14
		db	B3,13
		db	C4,13
		db	D4,13
		db	E4,13
		db	FS4,14
		db	REST,13
		db	G4,26
		db	FS4,13
		db	G4,14
		db	E4,13
		db	D4,13
		db	E4,13
		db	REST,14
		db	D4,26
		db	B3,13
		db	C4,13
		db	D4,14
		db	REST,13
		db	E4,13
		db	REST,13
		db	C4,13
		db	D4,40
		db	REST,40
		db	D4,10
		db	REST,3
		db	D4,10
		db	REST,3
		db	D4,13
		db	B3,14
		db	C4,13
		db	D4,13
		db	E4,13
		db	FS4,13
		db	REST,14
		db	G4,26
		db	FS4,13
		db	G4,14
		db	E4,13
		db	D4,39
		db	E4,14
		db	D4,26
		db	C4,26
		db	B3,27
		db	A3,13
		db	G3,66
		db	END
;total time = 846
SEQ31:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	REST,40
		db	B2,40
		db	D3,13
		db	REST,53
		db	C3,39
		db	E3,14
		db	REST,53
		db	G3,39
		db	D3,13
		db	REST,53
		db	FS3,40
		db	A3,13
		db	REST,53
		db	B2,40
		db	D3,13
		db	REST,53
		db	C3,39
		db	E3,14
		db	REST,52
		db	D3,40
		db	FS3,13
		db	REST,13
		db	D3,27
		db	FS3,13
		db	B2,66
		db	END
;total time = 846
SEQ32:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	G1,27
		db	B1,13
		db	D2,40
		db	G1,26
		db	C2,27
		db	G2,13
		db	E2,39
		db	C2,27
		db	G2,26
		db	D2,14
		db	B1,26
		db	D2,13
		db	G1,27
		db	D2,33
		db	REST,6
		db	D2,40
		db	FS2,26
		db	G2,27
		db	B1,13
		db	D2,40
		db	G1,26
		db	C2,26
		db	G2,14
		db	E2,39
		db	C2,27
		db	D2,39
		db	A1,40
		db	D2,26
		db	G1,27
		db	B1,13
		db	D2,40
		db	B1,13
		db	D2,13
		db	END
;total time = 846

SEQ33:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	REST,27
		db	D4,10
		db	REST,3
		db	D4,27
		db	B3,13
		db	D4,13
		db	E4,26
		db	D4,93
		db	B3,46
		db	REST,7
		db	B3,26
		db	C4,13
		db	D4,119
		db	REST,40
		db	E4,40
		db	C4,13
		db	G3,39
		db	G4,14
		db	FS4,30
		db	E4,18
		db	D4,18
		db	B3,26
		db	E4,13
		db	D4,66
		db	REST,66
		db	G3,14
		db	A3,13
		db	B3,40
		db	A3,13
		db	FS3,66
		db	REST,39
		db	A3,14
		db	D4,17
		db	C4,18
		db	B3,18
		db	A3,39
		db	G3,119
		db	REST,53 ;filler
		db	END
;total time = 1269
SEQ34:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	B2,27
		db	REST,13
		db	B2,53
		db	REST,13
		db	B2,27
		db	REST,13
		db	B2,53
		db	REST,13
		db	D3,26
		db	REST,14
		db	D3,52
		db	REST,14
		db	G2,26
		db	REST,13
		db	G2,53
		db	REST,13
		db	E3,40
		db	G2,66
		db	E3,40
		db	C3,66
		db	D3,39
		db	G2,53
		db	REST,13
		db	B2,33
		db	REST,7
		db	B2,40
		db	D3,13
		db	FS3,53
		db	A2,53
		db	REST,13
		db	A2,39
		db	FS3,14
		db	A3,17
		db	G3,18
		db	FS3,18
		db	D3,39
		db	B2,119
		db	REST,53 ;filler
		db	END
;total time = 1269
SEQ35:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	G2,27
		db	REST,13
		db	G2,66
		db	D2,40
		db	G2,39
		db	D2,27
		db	G2,40
		db	D2,13
		db	G2,53
		db	D2,33
		db	REST,6
		db	D2,13
		db	G1,27
		db	B1,26
		db	C2,33
		db	REST,7
		db	C2,59
		db	REST,7
		db	C2,40
		db	G2,39
		db	C2,27
		db	G1,39
		db	B1,40
		db	D2,26
		db	G2,40
		db	D2,40
		db	G1,13
		db	D2,46
		db	REST,7
		db	D2,53
		db	REST,13
		db	D2,39
		db	A1,14
		db	FS2,17
		db	E2,18
		db	D2,18
		db	G1,39
		db	D2,13
		db	B1,27
		db	D2,26
		db	G2,40
		db	D2,26
		db	E2,14
		db	FS2,26
		db	END
;total time = 1269

SEQ36:
SEQ37:
SEQ38:
SEQ39:
SEQ40:

SEQ41:		db	MANUAL,GLIOFF	;[MERM06A,2]
		db	ENV,$47
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,13
		db	C3,13
		db	AS3,12
		db	G3,13
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,6
		db	REST,6
		db	G3,13
		db	F3,26
		db	C3,13
		db	G3,6
		db	REST,20
		db	C3,12
		db	G3,13
		db	C3,13
		db	AS3,13
		db	G3,13
		db	C3,13
		db	G3,6
		db	REST,19
		db	C3,13
		db	G3,7
		db	REST,6
		db	G3,13
		db	F3,26
		db	END

SEQ43:		db	MANUAL,GLIOFF	;[MERM06A,3]
		db	ENV,$87
		db	C2,13
		db	REST,26
		db	E2,13
		db	REST,13
		db	A2,13
		db	G2,12
		db	E2,13
		db	REST,13
		db	C2,13
		db	D2,13
		db	E2,38
		db	AS1,20
		db	REST,6
		db	C2,13
		db	REST,26
		db	E2,12
		db	REST,13
		db	A2,13
		db	G2,13
		db	E2,13
		db	REST,13
		db	C2,12
		db	D2,13
		db	E2,39
		db	AS1,19
		db	REST,7 ;filler
		db	END

SEQ44:		db	MANUAL,GLIOFF	;[MERM06BC,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	E4,26
		db	D4,13
		db	C4,6
		db	REST,20
		db	E4,13
		db	D4,12
		db	E4,13
		db	C4,26
		db	D4,13
		db	E4,6
		db	REST,19
		db	E4,13
		db	D4,13
		db	F4,13
		db	A4,13
		db	G4,13
		db	F4,13
		db	E4,6
		db	REST,19
		db	C4,26
		db	REST,13
		db	A4,13
		db	G4,12
		db	F4,13
		db	E4,7
		db	REST,19
		db	D4,26
		db	E4,13
		db	C4,12
		db	REST,26
		db	C4,19
		db	REST,7
		db	C4,13
		db	AS3,12
		db	D4,13
		db	C4,13
		db	E4,13
		db	D4,13
		db	C4,6
		db	REST,20
		db	AS3,25
		db	REST,13
		db	E4,26
		db	D4,13
		db	C4,6
		db	REST,19
		db	E4,13
		db	D4,13
		db	E4,13
		db	C4,26
		db	D4,12
		db	E4,7
		db	REST,19
		db	E4,13
		db	D4,13
		db	F4,13
		db	A4,12
		db	G4,13
		db	F4,13
		db	E4,7
		db	REST,19
		db	C4,26
		db	REST,12
		db	A4,13
		db	G4,13
		db	F4,13
		db	E4,6
		db	REST,20
		db	D4,25
		db	E4,13
		db	C4,13
		db	REST,26
		db	C4,19
		db	REST,6
		db	C4,13
		db	AS3,13
		db	D4,13
		db	C4,13
		db	E4,13
		db	D4,12
		db	C4,7
		db	REST,19
		db	AS3,26
		db	REST,13
		db	D4,25
		db	C4,13
		db	AS3,7
		db	REST,19
		db	D4,13
		db	C4,13
		db	D4,12
		db	AS3,26
		db	C4,13
		db	D4,6
		db	REST,20
		db	D4,13
		db	C4,12
		db	DS4,13
		db	G4,13
		db	F4,13
		db	DS4,13
		db	D4,6
		db	REST,19
		db	AS3,26
		db	REST,13
		db	G4,13
		db	F4,13
		db	DS4,12
		db	D4,7
		db	REST,19
		db	C4,26
		db	D4,13
		db	AS3,13
		db	REST,25
		db	AS3,20
		db	REST,6
		db	AS3,13
		db	GS3,13
		db	C4,12
		db	AS3,13
		db	D4,13
		db	C4,13
		db	AS3,6
		db	REST,20
		db	GS3,25
		db	REST,13 ;filler
		db	END



SEQ45:		db	MANUAL,GLIOFF	;[MERM06BC,2]
		db	ENV,$57
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,13
		db	C3,13
		db	AS3,12
		db	G3,13
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,6
		db	REST,6
		db	G3,13
		db	F3,26
		db	C3,13
		db	G3,6
		db	REST,20
		db	C3,12
		db	G3,13
		db	C3,13
		db	AS3,13
		db	G3,13
		db	C3,13
		db	G3,6
		db	REST,19
		db	C3,13
		db	G3,7
		db	REST,6
		db	G3,13
		db	F3,26
		db	C3,12
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,13
		db	E3,13
		db	G3,12
		db	AS3,13
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,6
		db	REST,7
		db	G3,12
		db	F3,26
		db	C3,13
		db	G3,6
		db	REST,20
		db	C3,12
		db	G3,13
		db	C3,13
		db	AS3,13
		db	G3,13
		db	C3,13
		db	G3,6
		db	REST,19
		db	C3,13
		db	G3,7
		db	REST,6
		db	G3,13
		db	F3,26
		db	C3,12
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,13
		db	C3,13
		db	AS3,13
		db	G3,12
		db	C3,13
		db	G3,7
		db	REST,19
		db	C3,13
		db	G3,6
		db	REST,7
		db	G3,12
		db	F3,26
		db	C3,13
		db	G3,6
		db	REST,20
		db	C3,13
		db	G3,12
		db	E3,13
		db	G3,13
		db	AS3,13
		db	C3,13
		db	G3,6
		db	REST,19
		db	C3,13
		db	G3,7
		db	REST,6
		db	G3,13
		db	F3,26
		db	AS2,13
		db	F3,6
		db	REST,19
		db	AS2,13
		db	F3,13
		db	AS2,13
		db	GS3,13
		db	F3,12
		db	AS2,13
		db	F3,7
		db	REST,19
		db	AS2,13
		db	F3,6
		db	REST,7
		db	F3,13
		db	DS3,25
		db	AS2,13
		db	F3,6
		db	REST,20
		db	AS2,13
		db	F3,12
		db	AS2,13
		db	GS3,13
		db	F3,13
		db	AS2,13
		db	F3,6
		db	REST,19
		db	AS2,13
		db	F3,7
		db	REST,6
		db	F3,13
		db	DS3,26
		db	AS2,13
		db	F3,6
		db	REST,19
		db	AS2,13
		db	F3,13
		db	D3,13
		db	F3,13
		db	GS3,12
		db	AS2,13
		db	F3,7
		db	REST,19
		db	AS2,13
		db	F3,6
		db	REST,7
		db	F3,13
		db	DS3,25
		db	END

SEQ46:		db	MANUAL,GLIOFF	;[MERM06BC,3]
		db	ENV,$77
		db	C2,13
		db	REST,26
		db	E2,13
		db	REST,13
		db	A2,13
		db	G2,12
		db	REST,13
		db	E2,26
		db	D2,13
		db	C2,6
		db	REST,19
		db	C2,13
		db	AS1,20
		db	REST,6
		db	C2,13
		db	REST,26
		db	C2,12
		db	REST,13
		db	E2,13
		db	REST,13
		db	D2,13
		db	C2,13
		db	REST,25
		db	G2,7
		db	REST,19
		db	C2,13
		db	AS1,19
		db	REST,7
		db	E2,12
		db	REST,26
		db	E2,13
		db	REST,13
		db	G2,13
		db	REST,12
		db	F2,13
		db	E2,13
		db	REST,26
		db	E2,6
		db	REST,20
		db	C2,12
		db	D2,13
		db	F2,13
		db	C2,13
		db	REST,26
		db	E2,12
		db	REST,13
		db	A2,13
		db	G2,13
		db	REST,13
		db	E2,26
		db	D2,12
		db	C2,7
		db	REST,19
		db	C2,13
		db	AS1,19
		db	REST,7
		db	C2,12
		db	REST,26
		db	C2,13
		db	REST,13
		db	E2,13
		db	REST,13
		db	D2,12
		db	C2,13
		db	REST,26
		db	G2,6
		db	REST,20
		db	C2,12
		db	AS1,20
		db	REST,6
		db	E2,13
		db	REST,26
		db	E2,13
		db	REST,12
		db	G2,13
		db	REST,13
		db	F2,13
		db	E2,13
		db	REST,25
		db	E2,7
		db	REST,19
		db	C2,13
		db	D2,13
		db	F2,13
		db	AS1,13
		db	REST,25
		db	D2,13
		db	REST,13
		db	G2,13
		db	F2,13
		db	REST,12
		db	D2,26
		db	C2,13
		db	AS1,6
		db	REST,20
		db	AS1,13
		db	GS1,19
		db	REST,6
		db	AS1,13
		db	REST,26
		db	AS1,13
		db	REST,12
		db	D2,13
		db	REST,13
		db	C2,13
		db	AS1,13
		db	REST,25
		db	F2,7
		db	REST,19
		db	AS1,13
		db	GS1,19
		db	REST,7
		db	D2,13
		db	REST,25
		db	D2,13
		db	REST,13
		db	F2,13
		db	REST,13
		db	DS2,12
		db	D2,13
		db	REST,26
		db	D2,6
		db	REST,20
		db	AS1,13
		db	C2,12
		db	DS2,13
		db	END


SEQ47:		db	MANUAL,GLIOFF	;[MERM07A,1-TACET]
		db	ENV,$77     
		DB    REST,255,REST,255,REST,255,REST,107
		DB    END


SEQ48:		db	MANUAL,GLIOFF	;[MERM07A,2]
		db	ENV,$57
		db	AS2,19
		db	D3,9
		db	F3,18
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	F3,18
		db	D3,9
		db	AS2,9
		db	REST,10
		db	AS2,9
		db	DS3,9
		db	REST,9
		db	G3,9
		db	AS3,27
		db	G3,27
		db	C3,18
		db	F3,10
		db	A3,18
		db	C4,18
		db	REST,9
		db	C4,9
		db	A3,18
		db	F3,18
		db	REST,9
		db	AS2,9
		db	D3,19
		db	F3,9
		db	AS3,54
		db	AS2,18
		db	D3,9
		db	F3,19
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	F3,18
		db	D3,9
		db	AS2,9
		db	REST,9
		db	AS2,9
		db	DS3,9
		db	REST,9
		db	G3,10
		db	AS3,27
		db	G3,27
		db	C3,18
		db	F3,9
		db	A3,18
		db	C4,19
		db	REST,9
		db	C4,9
		db	A3,18
		db	F3,18
		db	REST,9
		db	AS2,9
		db	D3,18
		db	F3,9
		db	AS3,55
		db	END
SEQ49:		db	MANUAL,GLIOFF	;[MERM07A,3]
		db	ENV,$77
		db	AS1,19
		db	REST,27
		db	D2,36
		db	AS1,27
		db	DS2,19
		db	REST,27
		db	DS2,63
		db	F2,18
		db	REST,28
		db	A2,36
		db	F2,27
		db	AS1,27
		db	REST,19
		db	D3,9
		db	AS2,27
		db	F2,27
		db	AS1,19		
		db	REST,27
		db	D2,36
		db	AS1,27
		db	DS2,18
		db	REST,27
		db	DS2,64
		db	F2,18
		db	REST,27
		db	A2,37
		db	F2,27
		db	AS1,27
		db	REST,18
		db	D3,9
		db	AS2,28
		db	F2,27 
		db	END

SEQ50:		db	MANUAL,GLIOFF	;[MERM07BC,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	F4,28
		db	D4,18
		db	C4,18
		db	REST,9
		db	D4,9
		db	AS3,27
		db	G3,46
		db	AS3,9
		db	G4,27
		db	DS4,27
		db	A4,28
		db	G4,18
		db	F4,18
		db	REST,9
		db	DS4,9
		db	F4,18
		db	C4,9
		db	AS3,46
		db	C4,9
		db	D4,27
		db	F3,27
		db	F4,27
		db	D4,19
		db	C4,18
		db	REST,9
		db	D4,9
		db	AS3,27
		db	G3,45
		db	AS3,10
		db	G4,27
		db	DS4,27
		db	A4,27
		db	G4,18
		db	F4,19
		db	REST,9
		db	DS4,9
		db	F4,18
		db	C4,9
		db	D4,27
		db	DS4,18
		db	D4,18
		db	REST,9
		db	C4,10
		db	AS3,27
		db	DS4,18
		db	REST,27
		db	G4,36
		db	AS4,19
		db	REST,9
		db	A4,18
		db	REST,27
		db	F4,27
		db	A3,9
		db	C4,19
		db	D4,9
		db	DS4,18
		db	REST,27
		db	G4,36
		db	AS4,18
		db	REST,10
		db	A4,27
		db	G4,18
		db	F4,18
		db	REST,9
		db	DS4,9
		db	C4,27
		db	DS4,19
		db	REST,27
		db	G4,36
		db	AS4,18
		db	REST,9
		db	C5,28
		db	A4,18
		db	F4,18
		db	REST,18
		db	C5,27
		db	AS4,18
		db	REST,28
		db	F4,27
		db	D4,9
		db	F4,18
		db	D4,9
		db	DS4,27
		db	REST,19
		db	DS4,36
		db	C4,27
		db	DS4,18
		db	REST,27
		db	G4,37
		db	AS4,18
		db	REST,9
		db	A4,18
		db	REST,27
		db	F4,28
		db	A3,9
		db	C4,18
		db	D4,9
		db	DS4,18
		db	REST,27
		db	G4,37
		db	AS4,18
		db	REST,9
		db	A4,27
		db	G4,18
		db	F4,18
		db	REST,9
		db	DS4,10
		db	C4,27
		db	DS4,18
		db	REST,27
		db	G4,36
		db	AS4,19
		db	REST,9
		db	C5,27
		db	A4,18
		db	F4,18
		db	REST,18
		db	C5,28
		db	AS4,18
		db	REST,27
		db	F4,27
		db	D4,9
		db	F4,18
		db	D4,9
		db	DS4,28
		db	REST,18
		db	DS4,36
		db	C4,27
		db	END

SEQ51:		db	MANUAL,GLIOFF	;[MERM07BC,2]
		db	ENV,$57
		db	AS2,19
		db	D3,9
		db	F3,18
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	F3,18
		db	D3,9
		db	AS2,9
		db	REST,10
		db	AS2,9
		db	DS3,18
		db	G3,9
		db	AS3,27
		db	G3,27
		db	C3,18
		db	F3,10
		db	A3,18
		db	C4,18
		db	REST,9
		db	C4,9
		db	A3,18
		db	F3,18
		db	REST,9
		db	AS2,9
		db	D3,19
		db	F3,9
		db	AS3,54
		db	AS2,18
		db	D3,9
		db	F3,19
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	F3,18
		db	D3,9
		db	AS2,9
		db	REST,9
		db	AS2,9
		db	DS3,9
		db	REST,9
		db	G3,10
		db	AS3,27
		db	G3,27
		db	C3,18
		db	F3,9
		db	A3,18
		db	C4,19
		db	REST,9
		db	C4,9
		db	A3,18
		db	F3,18
		db	REST,9
		db	AS2,9
		db	D3,18
		db	F3,9
		db	AS3,55
		db	AS2,18
		db	DS3,9
		db	G3,18
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	G3,19
		db	DS3,18
		db	REST,9
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,27
		db	A3,19
		db	REST,9
		db	AS2,18
		db	DS3,9
		db	G3,18
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	G3,18
		db	DS3,19
		db	REST,9
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,27
		db	A3,18
		db	F3,9
		db	AS2,19
		db	DS3,9
		db	G3,18
		db	AS3,18
		db	REST,9
		db	AS3,9
		db	G3,18
		db	DS3,9
		db	REST,19
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,27
		db	A3,18
		db	REST,9
		db	D3,9
		db	REST,37
		db	D3,27
		db	F3,9
		db	AS3,18
		db	REST,27
		db	C3,9
		db	DS3,19
		db	GS3,9
		db	C4,27
		db	GS3,18
		db	DS3,9
		db	AS2,18
		db	DS3,9
		db	G3,18
		db	AS3,19
		db	REST,9
		db	AS3,9
		db	G3,18
		db	DS3,18
		db	REST,9
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,28
		db	A3,18
		db	REST,9
		db	AS2,18
		db	DS3,9
		db	G3,18
		db	AS3,18
		db	REST,10
		db	AS3,9
		db	G3,18
		db	DS3,9
		db	REST,18
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,28
		db	A3,18
		db	F3,9
		db	AS2,18
		db	DS3,9
		db	G3,18
		db	AS3,9
		db	REST,18
		db	AS3,9
		db	G3,19
		db	DS3,9
		db	REST,18
		db	C3,9
		db	F3,18
		db	A3,9
		db	C4,27
		db	A3,18
		db	REST,10
		db	D3,9
		db	REST,36
		db	D3,27
		db	F3,9
		db	AS3,18
		db	REST,28
		db	C3,9
		db	DS3,18
		db	GS3,9
		db	C4,27
		db	GS3,18
		db	DS3,9
		db	END

SEQ52:		db	MANUAL,GLIOFF	;[MERM07BC,3]
		db	ENV,$77
		db	AS1,19
		db	REST,27
		db	D2,36
		db	F2,27
		db	DS2,19
		db	REST,27
		db	DS2,63
		db	F2,18
		db	REST,28
		db	A2,36
		db	F2,27
		db	AS1,18
		db	REST,37
		db	AS2,27
		db	F2,27
		db	REST,46
		db	D2,36
		db	F2,27
		db	DS2,18
		db	REST,27
		db	DS2,64
		db	F2,18
		db	REST,27
		db	A2,37
		db	F2,27
		db	AS1,18
		db	REST,36
		db	AS2,28
		db	F2,27
		db	REST,45
		db	DS2,55
		db	REST,9
		db	F2,18
		db	REST,27
		db	C2,9
		db	A2,27
		db	F2,28
		db	DS2,18
		db	REST,27
		db	DS2,64
		db	F2,18
		db	REST,27
		db	C2,36
		db	F2,27
		db	DS2,19
		db	REST,27
		db	DS2,63
		db	F2,19
		db	REST,27
		db	C2,9
		db	A2,27
		db	F2,27
		db	AS2,18
		db	REST,9
		db	F2,19
		db	AS1,36
		db	AS2,27
		db	GS2,18
		db	REST,9
		db	C3,19
		db	GS2,27
		db	REST,9
		db	GS2,27
		db	DS2,18
		db	REST,27
		db	DS2,55
		db	REST,9
		db	F2,18
		db	REST,27
		db	C2,9
		db	A2,28
		db	F2,27
		db	DS2,18
		db	REST,27
		db	DS2,64
		db	F2,18
		db	REST,27
		db	C2,37
		db	F2,27
		db	DS2,18
		db	REST,27
		db	DS2,64
		db	F2,18
		db	REST,27
		db	C2,9
		db	A2,27
		db	F2,28
		db	AS2,18
		db	REST,9
		db	F2,18
		db	AS1,36
		db	AS2,27
		db	GS2,19
		db	REST,9
		db	C3,18
		db	GS2,27
		db	REST,9
		db	GS2,27
		db	END


SEQ53:		db    MANUAL	;[MERM08A,1-TACET]
		db	ENV,$57                
		DB	REST,255,REST,181
		DB    END

SEQ54:		db	MANUAL,GLIOFF	;[MERM08A,2]
		db	ENV,$57
		db	A2,19
		db	C3,9
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	G2,19
		db	B2,9
		db	D3,18
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,18
		db	REST,9
		db	A2,18
		db	C3,10
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	G2,18
		db	B2,9
		db	D3,19
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,27
		db	END

SEQ55:		db    MANUAL	;[MERM08A,3-TACET]
		db	ENV,$57                
		DB	REST,255,REST,181
		DB    END

SEQ56:		db	MANUAL,GLIOFF	;[MERM08BC,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	E3,19
		db	REST,27
		db	E3,9
		db	A3,18
		db	A3,9
		db	C4,18
		db	REST,9
		db	B3,28
		db	D3,18
		db	G3,9
		db	REST,18
		db	B3,9
		db	A3,18
		db	G3,9
		db	A3,28
		db	REST,18
		db	E3,9
		db	G3,18
		db	A3,9
		db	C4,18
		db	REST,9
		db	D4,27
		db	B3,19
		db	G3,9
		db	REST,18
		db	D3,9
		db	G3,18
		db	REST,9
		db	C3,18
		db	REST,28
		db	F3,9
		db	A3,9
		db	REST,9
		db	A3,9
		db	C4,18
		db	REST,9
		db	C3,18
		db	REST,27
		db	E3,10
		db	G3,9
		db	REST,9
		db	G3,9
		db	C4,18
		db	REST,9
		db	D3,18
		db	REST,27
		db	FS3,9
		db	A3,10
		db	REST,9
		db	A3,9
		db	C4,18
		db	REST,9
		db	B3,27
		db	A3,18
		db	G3,9
		db	REST,18
		db	F3,10
		db	D3,18
		db	REST,9
		db	E3,18
		db	REST,27
		db	E3,9
		db	A3,18
		db	A3,9
		db	C4,19
		db	REST,9
		db	B3,27
		db	D3,18
		db	G3,9
		db	REST,18
		db	B3,9
		db	A3,19
		db	G3,9
		db	A3,27
		db	REST,18
		db	E3,9
		db	G3,18
		db	A3,9
		db	C4,18
		db	REST,10
		db	D4,27
		db	B3,18
		db	G3,9
		db	REST,18
		db	D3,9
		db	G3,18
		db	REST,9
		db	C3,19
		db	REST,27
		db	F3,9
		db	A3,9
		db	REST,9
		db	A3,9
		db	C4,18
		db	REST,9
		db	C3,19
		db	REST,27
		db	E3,9
		db	G3,9
		db	REST,9
		db	G3,9
		db	C4,18
		db	REST,9
		db	D3,18
		db	REST,28
		db	E3,9
		db	F3,18
		db	G3,9
		db	A3,18
		db	B3,9
		db	C4,27
		db	G3,19
		db	C3,9
		db	REST,18
		db	D3,9
		db	E3,18
		db	REST,9
		db	F3,27
		db	C3,18
		db	A3,10
		db	REST,18
		db	A3,9
		db	F3,18
		db	REST,9
		db	E3,27
		db	C3,18
		db	G3,9
		db	REST,19
		db	G3,9
		db	E3,18
		db	REST,9
		db	F3,27
		db	C3,18
		db	A3,9
		db	REST,19
		db	B3,9
		db	C4,18
		db	REST,9
		db	G3,45
		db	E3,9
		db	C3,28
		db	E3,18
		db	REST,9
		db	F3,27
		db	C3,18
		db	A3,9
		db	REST,18
		db	A3,9
		db	F3,19
		db	REST,9
		db	E3,27
		db	C3,18
		db	G3,9
		db	REST,18
		db	G3,9
		db	E3,18
		db	REST,10
		db	FS3,27
		db	D3,18
		db	A3,9
		db	REST,18
		db	B3,9
		db	C4,18
		db	REST,9
		db	B3,28
		db	A3,18
		db	G3,9
		db	REST,18
		db	F3,9
		db	D3,18
		db	REST,9 ;filler
		db	END

SEQ57:		db	MANUAL,GLIOFF	;[MERM08BC,2]
		db	ENV,$57
		db	A2,19
		db	C3,9
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	G2,19
		db	B2,9
		db	D3,18
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,18
		db	REST,9
		db	A2,18
		db	C3,10
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	G2,18
		db	B2,9
		db	D3,19
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,18
		db	G2,9
		db	F2,18
		db	A2,9
		db	C3,19
		db	A2,9
		db	REST,18
		db	F2,9
		db	A2,18
		db	REST,9
		db	E2,18
		db	G2,9
		db	C3,18
		db	G2,10
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	FS2,18
		db	A2,9
		db	D3,18
		db	A2,9
		db	REST,19
		db	FS2,9
		db	A2,18
		db	D3,9
		db	G2,18
		db	B2,9
		db	D3,18
		db	B2,9
		db	REST,18
		db	G2,10
		db	B2,18
		db	REST,9
		db	A2,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,19
		db	C3,9
		db	G2,18
		db	B2,9
		db	D3,18
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,19
		db	REST,9
		db	A2,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,10
		db	G2,18
		db	B2,9
		db	D3,18
		db	B2,9
		db	REST,18
		db	G2,9
		db	B2,18
		db	G2,9
		db	F2,19
		db	A2,9
		db	C3,18
		db	A2,9
		db	REST,18
		db	F2,9
		db	A2,18
		db	REST,9
		db	E2,19
		db	G2,9
		db	C3,18
		db	G2,9
		db	REST,18
		db	C3,9
		db	E3,18
		db	C3,9
		db	B2,18
		db	D3,9
		db	B2,19
		db	G2,9
		db	REST,18
		db	B2,9
		db	D3,18
		db	REST,9
		db	E3,27
		db	C3,19
		db	G2,9
		db	REST,18
		db	B2,9
		db	C3,18
		db	REST,36
		db	A2,18
		db	F3,10
		db	REST,27
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,27
		db	G2,18
		db	E3,9
		db	REST,28
		db	C3,9
		db	REST,9
		db	C3,9
		db	REST,27
		db	A2,18
		db	F3,9
		db	REST,28
		db	A2,9
		db	REST,9
		db	A2,9
		db	REST,27
		db	G2,18
		db	C3,9
		db	REST,28
		db	C3,9
		db	REST,9
		db	C3,9
		db	REST,27
		db	A2,18
		db	F3,9
		db	REST,27
		db	A2,10
		db	REST,9
		db	A2,9
		db	REST,27
		db	G2,18
		db	E3,9
		db	REST,27
		db	C3,9
		db	REST,9
		db	C3,10
		db	REST,27
		db	A2,18
		db	FS3,9
		db	REST,27
		db	FS3,9
		db	REST,9
		db	FS3,9
		db	G3,28
		db	C3,18
		db	B2,9
		db	REST,18
		db	A2,9
		db	B2,18
		db	REST,9 ;filler
		db	END


SEQ58:		db	MANUAL,GLIOFF	;[MERM08BC,3]
		db	ENV,$A6
		db	A1,10
		db	REST,36
		db	A1,9
		db	REST,18
		db	E2,9
		db	A1,18
		db	REST,9
		db	G1,9
		db	REST,37
		db	D2,9
		db	REST,18
		db	D2,9
		db	G1,18
		db	REST,9
		db	A1,9
		db	REST,37
		db	A1,9
		db	REST,18
		db	E2,9
		db	A1,9
		db	REST,18
		db	G1,9
		db	REST,37
		db	D2,9
		db	B1,27
		db	G1,18
		db	REST,9
		db	F1,9
		db	REST,37
		db	C2,9
		db	REST,18
		db	C2,9
		db	F1,18
		db	REST,9
		db	E1,18
		db	REST,27
		db	C2,10
		db	REST,18
		db	E2,9
		db	C2,18
		db	REST,9
		db	D2,18
		db	REST,27
		db	D2,9
		db	A1,28
		db	D2,18
		db	REST,9
		db	G1,18
		db	REST,9
		db	B1,18
		db	D2,9
		db	REST,18
		db	B1,10
		db	G1,18
		db	REST,9
		db	A1,9
		db	REST,36
		db	A1,9
		db	REST,18
		db	E2,9
		db	A1,19
		db	REST,9
		db	G1,9
		db	REST,36
		db	D2,9
		db	REST,18
		db	D2,9
		db	G1,19
		db	REST,9
		db	A1,9
		db	REST,36
		db	A1,9
		db	REST,18
		db	E2,9
		db	A1,9
		db	REST,19
		db	G1,9
		db	REST,36
		db	D2,9
		db	B1,27
		db	G1,18
		db	REST,9
		db	F1,10
		db	REST,36
		db	C2,9
		db	REST,18
		db	C2,9
		db	F1,18
		db	REST,9
		db	E1,19
		db	REST,27
		db	C2,9
		db	REST,18
		db	E2,9
		db	C2,18
		db	REST,9
		db	G1,9
		db	REST,37
		db	B1,9
		db	D2,27
		db	G1,27
		db	C2,27
		db	D2,19
		db	E2,9
		db	REST,18
		db	D2,9
		db	C2,18
		db	REST,9
		db	F1,9
		db	REST,36
		db	C2,10
		db	F2,27
		db	F1,27
		db	C2,9
		db	REST,36
		db	C2,9
		db	E2,28
		db	G1,27
		db	F1,9
		db	REST,36
		db	C2,9
		db	F2,28
		db	F1,27
		db	C2,9
		db	REST,36
		db	G1,9
		db	E2,28
		db	G1,18
		db	REST,9
		db	F1,9
		db	REST,36
		db	C2,9
		db	F2,27
		db	F1,28
		db	C2,9
		db	REST,36
		db	C2,9
		db	E2,27
		db	C2,18
		db	REST,10
		db	D2,9
		db	REST,36
		db	D2,9
		db	A1,27
		db	D2,18
		db	REST,9
		db	G1,28
		db	D2,18
		db	G2,9
		db	REST,18
		db	D2,9
		db	G1,27
		db	END

SEQ59:		db	MANUAL,GLIOFF	;[MERM08BC,4]
		db	ENV,$F1
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,255
		db	REST,240
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,10
		db	REST,18
		db	DRUM,6,9
		db	DRUM,8,9
		db	REST,9
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,28
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,19
		db	DRUM,6,9
		db	DRUM,8,9
		db	REST,9
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,28
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	REST,18
		db	DRUM,6,9
		db	DRUM,8,10
		db	REST,9
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,27
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,10
		db	REST,27
		db	DRUM,6,18
		db	DRUM,8,9
		db	REST,18
		db	DRUM,8,9
		db	DRUM,6,9
		db	REST,9
		db	DRUM,6,9
		db	DRUM,8,10
		db	REST,99 ;filler
		db	END
SEQ83:		DB	REST,227	;[MERM08A-REST]
		DB	REST,200
		DB	END

	IF	!OLD1

SEQ111:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	D4,105
		db	E4,104
		db	F4,52
		db	D4,52
		db	AS3,13
		db	F4,13
		db	AS4,13
		db	AS3,13
		db	E4,18
		db	F4,17
		db	G4,17
		db	END
;total time = 417
SEQ112:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	AS4,14
		db	C5,13
		db	D5,13
		db	F5,13
		db	AS4,13
		db	C5,13
		db	D5,13
		db	F5,13
		db	C5,13
		db	D5,13
		db	E5,13
		db	G5,13
		db	C5,13
		db	D5,13
		db	E5,13
		db	G5,13
		db	AS4,13
		db	C5,13
		db	D5,13
		db	F5,13
		db	AS4,13
		db	C5,13
		db	D5,13
		db	F5,13
		db	D5,5
		db	AS4,4
		db	F4,4
		db	D4,5
		db	AS3,4
		db	F3,4
		db	D3,5
		db	F3,4
		db	AS3,4
		db	D4,5
		db	F4,4
		db	AS4,4
		db	G4,18
		db	A4,17
		db	AS4,17
		db	END
;total time = 417
SEQ113:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	AS3,255
		db	REST,6
		db	F3,52
		db	C3,52
		db	C2,52
		db	END
;total time = 417

SEQ114:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	A4,53
		db	G4,17
		db	F4,17
		db	A4,13
		db	REST,5
		db	A4,52
		db	F4,17
		db	G4,18
		db	A4,17
		db	C5,26
		db	AS4,20
		db	REST,6
		db	AS4,17
		db	A4,18
		db	C5,17
		db	AS4,35
		db	REST,17
		db	AS4,18
		db	A4,17
		db	F4,17
		db	C4,53
		db	A4,17
		db	G4,17
		db	F4,18
		db	C4,52
		db	G4,17
		db	F4,17
		db	E4,18
		db	F4,139
		db	REST,17
		db	A4,18
		db	G4,17
		db	F4,17
		db	END
;total time = 834
SEQ133:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	F3,14
		db	G3,13
		db	A3,13
		db	C4,13
		db	F3,13
		db	G3,13
		db	A3,13
		db	C4,13
		db	F3,13
		db	G3,13
		db	A3,13
		db	C4,13
		db	F3,13
		db	G3,13
		db	A3,13
		db	C4,13
		db	D3,13
		db	F3,13
		db	AS3,13
		db	F3,13
		db	D4,17
		db	C4,18
		db	F3,17
		db	AS3,13
		db	F3,13
		db	CS4,13
		db	AS3,13
		db	F3,52
		db	A3,13
		db	AS3,13
		db	C4,27
		db	C3,52
		db	E3,13
		db	F3,13
		db	G3,26
		db	E3,17
		db	F3,17
		db	G3,18
		db	F3,13
		db	G3,13
		db	A3,13
		db	C4,13
		db	F3,13
		db	G3,13
		db	A3,13
		db	C4,13
		db	F3,13
		db	G3,13
		db	A3,26
		db	C4,52
		db	END
;total time = 834
SEQ134:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	F2,70
		db	A2,17
		db	F2,18
		db	DS2,69
		db	F2,18
		db	DS2,17
		db	D2,69
		db	F2,18
		db	D2,17
		db	CS2,70
		db	AS2,17
		db	CS3,17
		db	C3,53
		db	F2,52
		db	C2,104
		db	F2,104
		db	A2,13
		db	G2,13
		db	F2,78
		db	END
;total time = 834


SEQ135:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	F4,53
		db	D4,17
		db	E4,17
		db	F4,18
		db	G4,43
		db	REST,9
		db	G4,17
		db	F4,18
		db	E4,17
		db	D4,17
		db	C4,87
		db	REST,52
		db	A4,18
		db	F4,17
		db	G4,17
		db	F4,53
		db	D4,17
		db	E4,17
		db	F4,18
		db	G4,52
		db	E4,17
		db	F4,17
		db	G4,18
		db	A4,104
		db	C4,52
		db	A4,18
		db	G4,17
		db	F4,17
		db	D4,52
		db	F4,18
		db	E4,17
		db	F4,18
		db	G4,52
		db	E4,17
		db	F4,17
		db	G4,18
		db	REST,17
		db	AS4,17
		db	A4,14
		db	REST,4
		db	A4,17
		db	E4,18
		db	G4,17
		db	F4,52
		db	REST,26
		db	D4,13
		db	F4,13
		db	A4,13
		db	G4,39
		db	REST,26
		db	E4,13
		db	F4,13
		db	A4,13
		db	G4,40
		db	D4,17
		db	E4,17
		db	F4,18
		db	G4,156
		db	REST,52 ;filler
		db	END
;total time = 1668
SEQ136:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	D3,40
		db	AS3,13
		db	F3,52
		db	E3,39
		db	C4,13
		db	E3,17
		db	F3,18
		db	G3,17
		db	E3,39
		db	A3,13
		db	G3,52
		db	F3,39
		db	D4,13
		db	C4,18
		db	A3,17
		db	F3,17
		db	D3,39
		db	AS3,14
		db	F3,52
		db	E3,39
		db	C4,13
		db	G3,17
		db	D3,17
		db	E3,18
		db	C4,13
		db	D4,13
		db	E4,26
		db	C4,13
		db	B3,13
		db	A3,26
		db	DS3,13
		db	F3,13
		db	G3,26
		db	F3,18
		db	DS3,17
		db	C3,17
		db	AS2,13
		db	C3,13
		db	D3,13
		db	F3,13
		db	AS2,13
		db	C3,13
		db	D3,13
		db	F3,14
		db	C3,13
		db	D3,13
		db	E3,13
		db	G3,13
		db	C3,13
		db	D3,13
		db	E3,13
		db	G3,13
		db	CS3,13
		db	DS3,13
		db	E3,13
		db	G3,13
		db	CS3,13
		db	DS3,13
		db	E3,13
		db	G3,13
		db	A3,17
		db	C3,18
		db	D3,17
		db	F3,52
		db	C3,13
		db	D3,13
		db	F3,13
		db	G3,13
		db	B2,13
		db	D3,13
		db	G3,13
		db	D3,13
		db	C3,13
		db	D3,13
		db	F3,13
		db	G3,14
		db	B2,17
		db	C3,17
		db	D3,18
		db	DS3,52
		db	AS3,17
		db	G3,17
		db	DS3,18
		db	D3,13
		db	F3,13
		db	AS3,13
		db	D4,13
		db	E4,26
		db	G3,26
		db	END
;total time = 1668
SEQ137:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	AS2,70
		db	G2,17
		db	A2,18
		db	AS2,69
		db	C3,18
		db	AS2,17
		db	A2,52
		db	G2,17
		db	F2,18
		db	E2,17
		db	D2,52
		db	D3,52
		db	AS2,70
		db	REST,17
		db	A2,18
		db	AS2,69
		db	A2,17
		db	C3,18
		db	A2,52
		db	E2,52
		db	C2,52
		db	F2,52
		db	AS1,52
		db	F2,53
		db	AS2,104
		db	A2,104
		db	D2,52
		db	A2,26
		db	D3,26
		db	G2,39
		db	D2,13
		db	G2,39
		db	B2,13
		db	G2,39
		db	D2,14
		db	G2,34
		db	F2,18
		db	DS2,39
		db	AS2,13
		db	G2,17
		db	DS2,17
		db	AS1,18
		db	C2,39
		db	G2,13
		db	C3,52
		db	END
;total time = 1668

SEQ138:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	F4,10
		db	REST,4
		db	F4,13
		db	E4,13
		db	F4,39
		db	G4,13
		db	A4,13
		db	C4,26
		db	D4,26
		db	C4,45
		db	REST,7
		db	C4,10
		db	REST,3
		db	C4,13
		db	AS3,13
		db	C4,39
		db	D4,13
		db	AS3,13
		db	C4,26
		db	D4,26
		db	E4,26
		db	G4,26
		db	F4,10
		db	REST,3
		db	F4,13
		db	E4,13
		db	F4,27
		db	REST,13
		db	G4,13
		db	A4,13
		db	C4,26
		db	D4,26
		db	C4,52
		db	G4,156
		db	E4,18
		db	F4,17
		db	G4,17
		db	END
;total time = 834
SEQ139:
		db	MANUAL,GLIOFF
		db	ENV,$47
		db	A3,27
		db	C4,26
		db	A3,26
		db	F3,26
		db	E3,39
		db	G3,13
		db	A3,13
		db	G3,13
		db	E3,13
		db	F3,13
		db	D3,26
		db	F3,26
		db	D3,26
		db	AS2,26
		db	E3,39
		db	G3,13
		db	C4,13
		db	AS3,13
		db	A3,13
		db	G3,13
		db	A3,26
		db	D3,27
		db	C3,26
		db	F3,26
		db	E3,39
		db	G3,13
		db	A3,13
		db	G3,13
		db	E3,13
		db	F3,13
		db	AS3,26
		db	F3,26
		db	D3,26
		db	AS3,26
		db	E3,17
		db	G3,18
		db	C4,17
		db	G3,18
		db	A3,17
		db	AS3,17
		db	END
;total time = 834
SEQ140:
		db	MANUAL,GLIOFF
		db	ENV,$77
		db	F2,79
		db	C3,13
		db	AS2,13
		db	A2,78
		db	G2,13
		db	A2,13
		db	AS2,78
		db	F2,26
		db	C3,78
		db	F2,13
		db	E2,13
		db	D2,79
		db	D3,13
		db	C3,13
		db	A2,78
		db	G2,13
		db	A2,13
		db	C3,52
		db	G2,52
		db	C2,46
		db	REST,6
		db	C2,18
		db	D2,17
		db	E2,17
		db	END
;total time = 834
	ENDC


		ELSE

SEQ3:
SEQ4:
SEQ5:
SEQ6:
SEQ7:
SEQ8:
SEQ9:
SEQ10:
SEQ11:
SEQ12:
SEQ13:
SEQ14:
SEQ15:
SEQ16:
SEQ17:
SEQ18:
SEQ19:
SEQ20:
SEQ21:
SEQ22:
SEQ23:
SEQ24:
SEQ25:
SEQ26:
SEQ27:
SEQ28:
SEQ29:
SEQ30:
SEQ31:
SEQ32:
SEQ33:
SEQ34:
SEQ35:
SEQ36:
SEQ37:
SEQ38:
SEQ39:
SEQ40:
SEQ41:
SEQ43:
SEQ44:
SEQ45:
SEQ46:
SEQ47:
SEQ48:
SEQ49:
SEQ50:
SEQ51:
SEQ52:
SEQ53:
SEQ54:
SEQ55:
SEQ56:
SEQ57:
SEQ58:
SEQ59:
SEQ83:
SEQ111:
SEQ112:
SEQ113:
SEQ114:
SEQ133:
SEQ134:
SEQ135:
SEQ136:
SEQ137:
SEQ138:
SEQ139:
SEQ140:

		
		ENDC

		IF	SOUND2

SEQ60:		db	MANUAL,GLIOFF	;[MERM09A,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	G4,11
		db	FS4,11
		db	E4,11
		db	D4,10
		db	E4,11
		db	C4,11
		db	D4,32
		db	G3,5
		db	REST,5
		db	A3,6
		db	REST,5
		db	B3,5
		db	REST,6
		db	C4,32
		db	B3,21
		db	A3,11
		db	B3,32
		db	G3,11
		db	B3,10
		db	D4,11
		db	E4,32
		db	D4,22
		db	CS4,10
		db	D4,11
		db	C4,11
		db	B3,10
		db	A3,75
		db	B3,11
		db	G3,11
		db	D4,10
		db	C4,11
		db	B3,11
		db	A3,42
		db	B3,11
		db	C4,11
		db	D4,32
		db	C4,21
		db	B3,11
		db	A3,43
		db	D3,5
		db	REST,5
		db	D3,11
		db	A3,75
		db	G3,11
		db	FS3,10
		db	G3,32
		db	REST,193
		db	A3,11
		db	FS4,10
		db	E4,11
		db	END


SEQ61:		db	MANUAL,GLIOFF	;[MERM09A,2]
		db	ENV,$47
		db	B2,22
		db	REST,11
		db	B2,21
		db	E3,11
		db	G3,21
		db	D3,5
		db	REST,6
		db	B2,5
		db	REST,5
		db	A2,6
		db	REST,5
		db	G2,11
		db	E3,32
		db	G3,21
		db	C3,11
		db	G3,11
		db	FS3,10
		db	E3,11
		db	D3,21
		db	A2,11
		db	G3,22
		db	REST,10
		db	G3,32
		db	FS3,22
		db	G3,10
		db	C3,11
		db	D3,11
		db	E3,10
		db	D3,11
		db	C3,11
		db	B2,11
		db	D3,21
		db	REST,11
		db	FS3,10
		db	E3,11
		db	D3,11
		db	FS3,21
		db	C3,5
		db	REST,6
		db	B2,21
		db	A2,11
		db	G2,21
		db	A2,11
		db	E3,21
		db	G3,6
		db	REST,5
		db	C3,11
		db	D3,10
		db	E3,11
		db	FS3,43
		db	A2,11
		db	B2,10
		db	C3,11
		db	D3,11
		db	E3,10
		db	D3,22
		db	A2,10
		db	B2,11
		db	C3,11
		db	D3,5
		db	REST,5
		db	G3,11
		db	A3,11
		db	B3,11
		db	E3,10
		db	FS3,11
		db	E3,11
		db	G3,10
		db	A3,11
		db	G3,11
		db	B3,10
		db	C4,11
		db	D4,11
		db	B3,10
		db	A3,11
		db	G3,11
		db	FS3,11
		db	G3,10
		db	FS3,11
		db	E3,11
		db	D3,10
		db	C3,11
		db	END

SEQ62:		db	MANUAL,GLIOFF	;[MERM09A,3]
		db	ENV,$77
		db	G1,22
		db	REST,11
		db	G1,21
		db	A1,11
		db	B1,32
		db	D2,32
		db	C2,32
		db	E2,32
		db	D2,32
		db	G2,21
		db	FS2,11
		db	E2,32
		db	A1,32
		db	D2,22
		db	E2,10
		db	FS2,32
		db	G2,33
		db	B1,21
		db	C2,11
		db	D2,26
		db	REST,6
		db	A1,21
		db	D2,11
		db	G1,32
		db	B1,21
		db	C2,11
		db	A1,32
		db	A2,32
		db	D2,27
		db	REST,5
		db	D2,16
		db	REST,6
		db	D2,10
		db	A1,32
		db	D2,27
		db	REST,5
		db	G1,32
		db	B1,33
		db	C2,21
		db	G2,11
		db	E2,21
		db	C2,11
		db	G1,32
		db	D2,21
		db	G2,11
		db	D2,32
		db	C2,11
		db	B1,10
		db	A1,11
		db	END

SEQ63:		db	MANUAL,GLIOFF	;[MERM09B,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,22
		db	REST,11
		db	A3,21
		db	G3,11
		db	FS3,10
		db	G3,11
		db	A3,11
		db	D3,10
		db	E3,11
		db	FS3,11
		db	G3,32
		db	C4,21
		db	D4,11
		db	B3,11
		db	A3,10
		db	G3,11
		db	D3,11
		db	E3,10
		db	G3,11
		db	A3,22
		db	REST,10
		db	A3,22
		db	G3,10
		db	FS3,11
		db	G3,11
		db	A3,10
		db	B3,11
		db	C4,11
		db	D4,10
		db	E4,33
		db	G4,32
		db	FS4,10
		db	G4,11
		db	E4,11
		db	D4,26
		db	REST,6 ;filler
		db	END

SEQ64:		db	MANUAL,GLIOFF	;[MERM09B,2]
		db	ENV,$47
		db	FS3,22
		db	REST,11
		db	FS3,21
		db	E3,11
		db	D3,32
		db	A2,26
		db	REST,6
		db	E3,27
		db	REST,5
		db	E3,21
		db	FS3,11
		db	D3,11
		db	C3,10
		db	B2,11
		db	G2,21
		db	E3,11
		db	FS3,27
		db	REST,5
		db	D3,22
		db	B2,10
		db	A2,32
		db	FS3,32
		db	G3,33
		db	C3,32
		db	A3,32
		db	FS3,21
		db	REST,11 ;filler
		db	END



SEQ65:		db	MANUAL,GLIOFF	;[MERM09B,3]
		db	ENV,$77
		db	D2,33
		db	A1,32
		db	D2,32
		db	FS2,10
		db	E2,11
		db	D2,11
		db	C2,27
		db	REST,5
		db	C2,11
		db	B1,10
		db	A1,11
		db	G1,32
		db	B1,21
		db	C2,11
		db	D2,32
		db	FS2,22
		db	E2,10
		db	D2,43
		db	A1,11
		db	B1,10
		db	C2,33
		db	E2,21
		db	C2,11
		db	D2,32
		db	C2,10
		db	B1,11
		db	A1,11
		db	END





SEQ66:		;DB      WAVE	;[MERM10A,1-TACET]
		;DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		;DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		;DB      ENV,%11011111
		;DB      MANUAL
		;DB      LENGTH,QV4,REST,REST
		;DB      G5,F5,G5,F5,REST,G5
		;DB      REST,F5,G5,F5,G5,F5,DS5,D5
		;DB      END

SEQ67:		db	MANUAL,GLIOFF	;[MERM10A,2]
		db	ENV,$47
		db	E3,12
		db	B2,5
		db	REST,17
		db	B2,6
		db	REST,17
		db	B2,11
		db	E3,11
		db	B2,11
		db	D3,12
		db	A2,5
		db	REST,17
		db	A2,6
		db	REST,28
		db	D3,11
		db	A2,11
		db	C3,12
		db	G2,5
		db	REST,17
		db	G2,6
		db	REST,17
		db	G2,11
		db	C3,11
		db	G2,11
		db	B2,34
		db	C3,11
		db	B2,12
		db	C3,11
		db	D3,11
		db	DS3,11
		db	E3,12
		db	B2,5
		db	REST,17
		db	B2,6
		db	REST,17
		db	B2,11
		db	E3,11
		db	B2,11
		db	D3,12
		db	A2,5
		db	REST,17
		db	A2,6
		db	REST,28
		db	D3,11
		db	A2,11
		db	C3,12
		db	G2,5
		db	REST,17
		db	G2,11
		db	REST,12
		db	G2,11
		db	C3,11
		db	G2,11
		db	B2,34
		db	C3,11
		db	B2,12
		db	A2,11
		db	G2,11
		db	FS2,11
		db	END

SEQ68:		db	MANUAL,GLIOFF	;[MERM10A,3]
		db	ENV,$77
		db	E2,23
		db	REST,11
		db	E2,11
		db	REST,12
		db	G2,11
		db	E2,11
		db	REST,11
		db	D2,23
		db	REST,11
		db	D2,11
		db	REST,12
		db	D2,11
		db	REST,22
		db	C2,23
		db	REST,11
		db	C2,11
		db	REST,12
		db	C2,28
		db	REST,5
		db	B1,23
		db	REST,11
		db	B1,51
		db	REST,5
		db	E2,23
		db	REST,11
		db	E2,11
		db	REST,12
		db	G2,11
		db	E2,11
		db	REST,11
		db	FS2,23
		db	REST,11
		db	FS2,6
		db	REST,17
		db	E2,11
		db	D2,11
		db	REST,11
		db	E2,23
		db	REST,11
		db	C2,11
		db	REST,12
		db	C2,28
		db	REST,5
		db	B1,34
		db	A1,11
		db	B1,40
		db	REST,5 ;filler
		db	END

SEQ69:		db	MANUAL,GLIOFF	;[MERM10B,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	VIBON,2,2,2,B3,34
		db	VIBOFF,G3,6
		db	REST,28
		db	B3,11
		db	G3,11
		db	VIBON,2,2,2,A3,34
		db	VIBOFF,FS3,6
		db	REST,17
		db	FS3,11
		db	A3,11
		db	FS3,11
		db	VIBON,2,2,2,G3,34
		db	VIBOFF,E3,6
		db	REST,17
		db	E3,5
		db	REST,17
		db	G3,11
		db	FS3,34
		db	E3,11
		db	DS3,12
		db	E3,11
		db	F3,11
		db	FS3,11
		db	VIBON,2,2,2,G3,29
		db	REST,5
		db	VIBOFF,G3,6
		db	REST,17
		db	A3,11
		db	B3,11
		db	G3,11
		db	VIBON,2,2,2,A3,34
		db	VIBOFF,C4,6
		db	REST,17
		db	A3,11
		db	FS3,22
		db	VIBON,2,2,2,G3,34
		db	VIBOFF,E4,11
		db	REST,12
		db	C4,11
		db	E4,11
		db	D4,11
		db	VIBON,2,2,2,DS4,23
		db	VIBOFF,B3,11
		db	A3,6
		db	REST,17
		db	C4,11
		db	B3,11
		db	A3,11
		db	END



SEQ70:		db	MANUAL,GLIOFF	;[MERM10B,2]
		db	ENV,$47
		db	E3,12
		db	B2,5
		db	REST,17
		db	B2,6
		db	REST,17
		db	B2,11
		db	E3,11
		db	B2,11
		db	D3,12
		db	A2,5
		db	REST,17
		db	A2,6
		db	REST,28
		db	D3,11
		db	A2,11
		db	C3,12
		db	G2,5
		db	REST,17
		db	G2,6
		db	REST,17
		db	G2,11
		db	C3,11
		db	G2,11
		db	B2,34
		db	C3,11
		db	B2,12
		db	C3,11
		db	D3,11
		db	DS3,11
		db	E3,12
		db	B2,5
		db	REST,17
		db	B2,6
		db	REST,17
		db	B2,11
		db	E3,11
		db	B2,11
		db	D3,12
		db	A2,5
		db	REST,17
		db	A2,6
		db	REST,28
		db	D3,11
		db	A2,11
		db	C3,12
		db	G2,5
		db	REST,17
		db	G2,11
		db	REST,12
		db	G2,11
		db	C3,11
		db	G2,11
		db	B2,34
		db	C3,11
		db	B2,12
		db	A2,11
		db	G2,11
		db	FS2,11
		db	END

SEQ71:		db	MANUAL,GLIOFF	;[MERM10B,3]
		db	ENV,$77
		db	E2,23
		db	REST,11
		db	E2,11
		db	REST,12
		db	G2,11
		db	E2,11
		db	REST,11
		db	D2,23
		db	REST,11
		db	D2,11
		db	REST,12
		db	D2,11
		db	REST,22
		db	C2,23
		db	REST,11
		db	C2,11
		db	REST,12
		db	C2,28
		db	REST,5
		db	B1,23
		db	REST,11
		db	B1,51
		db	REST,5
		db	E2,23
		db	REST,11
		db	E2,11
		db	REST,12
		db	G2,11
		db	E2,11
		db	REST,11
		db	FS2,23
		db	REST,11
		db	FS2,6
		db	REST,17
		db	E2,11
		db	D2,11
		db	REST,11
		db	E2,23
		db	REST,11
		db	C2,11
		db	REST,12
		db	C2,28
		db	REST,5
		db	B1,34
		db	A1,11
		db	B1,40
		db	REST,5 ;filler
		db	END

SEQ72:		db	MANUAL,GLIOFF	;[MERM10C,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	B3,12
		db	G3,5
		db	REST,17
		db	G3,34
		db	B3,11
		db	G3,11
		db	CS4,12
		db	A3,5
		db	REST,17
		db	E3,23
		db	A3,11
		db	CS4,11
		db	REST,11
		db	D4,12
		db	G3,5
		db	REST,17
		db	G3,23
		db	A3,11
		db	B3,11
		db	REST,11
		db	A3,12
		db	E3,5
		db	REST,17
		db	E3,23
		db	FS3,11
		db	G3,11
		db	REST,11
		db	A3,12
		db	FS3,5
		db	REST,17
		db	FS3,23
		db	G3,11
		db	A3,22
		db	B3,12
		db	G3,5
		db	REST,17
		db	G3,23
		db	A3,11
		db	B3,22
		db	C4,12
		db	G3,5
		db	REST,17
		db	E4,23
		db	D4,11
		db	C4,22
		db	B3,34
		db	A3,23
		db	G3,11
		db	FS3,17
		db	REST,5 ;filler
		db	END

SEQ73:		db	MANUAL,GLIOFF	;[MERM10C,2]
		db	ENV,$47
		db	G2,34
		db	B2,34
		db	D3,11
		db	B2,11
		db	A2,34
		db	CS3,34
		db	E3,11
		db	A2,11
		db	G2,12
		db	B2,5
		db	REST,17
		db	D3,45
		db	REST,11
		db	E2,12
		db	A2,5
		db	REST,17
		db	CS3,23
		db	D3,11
		db	CS3,11
		db	REST,11
		db	FS2,12
		db	A2,11
		db	REST,11
		db	D3,56
		db	G2,12
		db	B2,5
		db	REST,17
		db	D3,56
		db	E3,34
		db	C3,56
		db	DS3,34
		db	FS3,23
		db	E3,11
		db	DS3,17
		db	REST,5 ;filler
		db	END

SEQ74:		db	MANUAL,GLIOFF	;[MERM10C,3]
		db	ENV,$77
		db	G1,12
		db	B1,5
		db	REST,17
		db	D2,34
		db	G1,22
		db	A1,12
		db	CS2,5
		db	REST,17
		db	E2,34
		db	A1,22
		db	B1,12
		db	D2,5
		db	REST,17
		db	B1,34
		db	G1,11
		db	D2,11
		db	CS2,34
		db	A1,28
		db	REST,6
		db	A1,11
		db	REST,11
		db	D2,6
		db	REST,6
		db	D2,5
		db	REST,17
		db	A2,34
		db	D2,22
		db	G1,12
		db	D2,11
		db	REST,11
		db	B1,23
		db	A1,11
		db	G1,22
		db	C2,34
		db	G2,34
		db	C2,22
		db	B1,23
		db	REST,11
		db	B1,56
		db	END


SEQ75:		db	MANUAL,GLIOFF	;[MERM11A1,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,13
		db	REST,5
		db	A3,8
		db	FS3,17
		db	D3,9
		db	REST,17
		db	A3,9
		db	FS3,17
		db	D3,8
		db	B3,18
		db	G3,8
		db	REST,17
		db	E3,9
		db	REST,17
		db	B3,9
		db	REST,17
		db	D4,8
		db	CS4,13
		db	REST,4
		db	CS4,9
		db	B3,17
		db	A3,9
		db	REST,17
		db	G3,8
		db	REST,18
		db	E3,8
		db	FS3,17
		db	G3,9
		db	REST,17
		db	A3,9
		db	REST,17
		db	B3,8
		db	A3,13
		db	REST,13
		db	D4,26
		db	A3,17
		db	FS3,8
		db	REST,18
		db	D4,8
		db	REST,17
		db	A3,9
		db	B3,17
		db	G3,9
		db	REST,17
		db	E3,8
		db	REST,17
		db	E3,9
		db	D3,13
		db	REST,13
		db	CS3,17
		db	B3,8
		db	REST,18
		db	A3,8
		db	REST,17
		db	A3,9
		db	B3,17
		db	CS4,9
		db	D4,12
		db	REST,5
		db	D4,8
		db	A3,17
		db	D4,9
		db	REST,17
		db	FS3,9
		db	G3,25
		db	END

SEQ76:		db	MANUAL,GLIOFF	;[MERM11A1,2]
		db	ENV,$47
		db	FS3,26
		db	D3,17
		db	A2,9
		db	REST,51
		db	D3,18
		db	CS3,8
		db	REST,17
		db	G2,9
		db	REST,51
		db	E3,26
		db	G3,17
		db	FS3,9
		db	REST,51
		db	A2,17
		db	CS3,9
		db	REST,17
		db	FS3,9
		db	REST,51
		db	FS3,43
		db	A2,8
		db	REST,18
		db	FS3,8
		db	REST,17
		db	FS3,9
		db	D3,38
		db	REST,5
		db	B2,8
		db	REST,17
		db	G2,9
		db	B2,13
		db	REST,13
		db	G2,38
		db	REST,5
		db	CS3,8
		db	REST,17
		db	E3,9
		db	D3,13
		db	REST,4
		db	E3,9
		db	FS3,25
		db	REST,17
		db	FS3,9
		db	REST,51 ;filler
		db	END

SEQ77:		db	MANUAL,GLIOFF	;[MERM11A1,3]
		db	ENV,$86
		db	D2,26
		db	A1,17
		db	D2,9
		db	REST,17
		db	FS2,9
		db	D2,13
		db	REST,12
		db	G1,18
		db	A1,8
		db	REST,17
		db	B1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	G1,8
		db	A1,22
		db	REST,4
		db	E2,17
		db	CS2,9
		db	REST,17
		db	E2,8
		db	A1,22
		db	REST,4
		db	D2,13
		db	REST,4
		db	A1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	D2,8
		db	A1,13
		db	REST,13
		db	D2,39
		db	REST,4
		db	D2,8
		db	REST,52
		db	G1,34
		db	REST,9
		db	G1,4
		db	REST,56
		db	A1,38
		db	REST,5
		db	A1,4
		db	REST,21
		db	CS2,9
		db	B1,17
		db	A1,9
		db	D2,38
		db	REST,4
		db	D2,9
		db	REST,51 ;filler
		db	END

SEQ78:		db	MANUAL,GLIOFF	;[MERM11A1,4]
		db	ENV,$A1
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,9
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	END

SEQ79:		db	MANUAL,GLIOFF	;[MERM11A2,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,13
		db	REST,5
		db	A3,8
		db	FS3,17
		db	D3,9
		db	REST,17
		db	A3,9
		db	FS3,17
		db	D3,8
		db	B3,18
		db	G3,8
		db	REST,17
		db	E3,9
		db	REST,17
		db	B3,9
		db	REST,17
		db	D4,8
		db	CS4,13
		db	REST,4
		db	CS4,9
		db	B3,17
		db	A3,9
		db	REST,17
		db	G3,8
		db	REST,18
		db	E3,8
		db	FS3,17
		db	G3,9
		db	REST,17
		db	A3,9
		db	REST,17
		db	B3,8
		db	A3,13
		db	REST,13
		db	D4,26
		db	A3,17
		db	FS3,8
		db	REST,18
		db	D4,8
		db	REST,17
		db	A3,9
		db	B3,17
		db	G3,9
		db	REST,17
		db	E3,8
		db	REST,17
		db	E3,9
		db	D3,13
		db	REST,13
		db	CS3,17
		db	B3,8
		db	REST,18
		db	A3,8
		db	REST,17
		db	A3,9
		db	B3,17
		db	CS4,9
		db	D4,12
		db	REST,5
		db	D4,8
		db	A3,17
		db	D4,9
		db	REST,26
		db	A3,25
		db	END

SEQ80:		db	MANUAL,GLIOFF	;[MERM11A2,2]
		db	ENV,$47
		db	FS3,26
		db	D3,17
		db	A2,9
		db	REST,51
		db	D3,18
		db	CS3,8
		db	REST,17
		db	G2,9
		db	REST,51
		db	E3,26
		db	G3,17
		db	FS3,9
		db	REST,51
		db	A2,17
		db	CS3,9
		db	REST,17
		db	FS3,9
		db	REST,51
		db	FS3,43
		db	A2,8
		db	REST,18
		db	FS3,8
		db	REST,17
		db	FS3,9
		db	D3,38
		db	REST,5
		db	B2,8
		db	REST,17
		db	G2,9
		db	B2,13
		db	REST,13
		db	G2,38
		db	REST,5
		db	CS3,8
		db	REST,17
		db	E3,9
		db	D3,13
		db	REST,4
		db	E3,9
		db	FS3,25
		db	REST,17
		db	FS3,9
		db	REST,26
		db	FS3,17
		db	REST,8 ;filler
		db	END

SEQ81:		db	MANUAL,GLIOFF	;[MERM11A2,3]
		db	ENV,$86
		DB	D2,26
		db	A1,17
		db	D2,9
		db	REST,17
		db	FS2,9
		db	D2,13
		db	REST,12
		db	G1,18
		db	A1,8
		db	REST,17
		db	B1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	G1,8
		db	A1,22
		db	REST,4
		db	E2,17
		db	CS2,9
		db	REST,17
		db	E2,8
		db	A1,22
		db	REST,4
		db	D2,13
		db	REST,4
		db	A1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	D2,8
		db	A1,13
		db	REST,13
		db	D2,39
		db	REST,4
		db	D2,8
		db	REST,52
		db	G1,34
		db	REST,9
		db	G1,4
		db	REST,56
		db	A1,38
		db	REST,5
		db	A1,4
		db	REST,21
		db	CS2,9
		db	B1,17
		db	A1,9
		db	D2,38
		db	REST,4
		db	D2,9
		db	REST,26
		db	D2,17
		db	REST,8 ;filler
		db	END

SEQ82:		db	MANUAL,GLIOFF	;[MERM11A2,4]
		db	ENV,$A1
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,9
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	END



SEQ84:		DB	REST,255	;[MERM12A-REST]
		DB	REST,181
		DB	END


SEQ85:		;DB      ENV,$95,MANUAL
		;DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		;DB	G3,A3,B3,MANUAL
		;DB	C4,DMN4,LENGTH,QV4,D4,C4,D4,C4,LENGTH,CR4,C4,G3
		;DB	REST,MANUAL
		;DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		;DB	G3,A3,B3,MANUAL
		;DB	C4,MN4,G3,MN4,F3,CR4,E3,CR4,C3,MN4
		;DB      END


SEQ86:		;DB      MANUAL,WAVE		;[save] flute/melody
		;DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		;DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		;DB      ENV,%10111111,LENGTH,QV4
		;DB	C5,G5,G5,C5,G5,G5,C5,G5
		;DB	G5,C5,A5,REST,G5,G5,REST,REST
		;DB	C5,G5,G5,C5,G5,G5,C5,G5
		;DB	REST,C5,E5,F5,E5,D5,C5,D5
		;DB	C5,G5,G5,C5,G5,G5,C5,G5
		;DB	G5,C5,A5,REST,G5,G5,REST,REST
		;DB	C6,C6,C6,C6,G5,G5,G5,G5
		;DB	F5,F5,E5,E5,C5,C5,C5,C5
		;DB      END


SEQ87:		db	MANUAL,GLIOFF	;[MERM11B,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	G3,13
		db	REST,5
		db	G3,8
		db	REST,43
		db	E3,9
		db	G3,17
		db	E3,8
		db	FS3,13
		db	REST,5
		db	FS3,8
		db	REST,17
		db	B3,9
		db	REST,17
		db	B3,9
		db	A3,21
		db	REST,4
		db	G3,13
		db	REST,4
		db	G3,9
		db	REST,17
		db	B3,9
		db	REST,17
		db	A3,8
		db	G3,13
		db	REST,5
		db	E3,8
		db	A3,26
		db	G3,17
		db	FS3,9
		db	REST,17
		db	G3,8
		db	A3,13
		db	REST,13
		db	B3,13
		db	REST,4
		db	B3,9
		db	REST,43
		db	G3,8
		db	B3,17
		db	G3,9
		db	A3,17
		db	B3,9
		db	CS4,17
		db	D4,34
		db	B3,17
		db	A3,9
		db	B3,13
		db	REST,4
		db	B3,8
		db	REST,18
		db	D4,8
		db	REST,17
		db	CS4,9
		db	B3,8
		db	CS4,9
		db	GS3,9
		db	A3,25
		db	G3,17
		db	E3,9
		db	REST,17
		db	E3,9
		db	G3,17
		db	REST,8 ;filler
		db	END

SEQ88:		db	MANUAL,GLIOFF	;[MERM11B,2]
		db	ENV,$47
		db	B2,9
		db	REST,9
		db	B2,8
		db	REST,17
		db	B2,9
		db	REST,51
		db	A2,9
		db	REST,9
		db	A2,8
		db	REST,17
		db	A2,9
		db	REST,51
		db	CS3,13
		db	REST,4
		db	CS3,9
		db	REST,17
		db	CS3,9
		db	REST,17
		db	D3,8
		db	A2,18
		db	REST,8
		db	FS3,26
		db	E3,17
		db	D3,9
		db	REST,17
		db	E3,8
		db	FS3,17
		db	REST,9
		db	D3,13
		db	REST,4
		db	D3,9
		db	REST,17
		db	B2,13
		db	REST,47
		db	FS3,17
		db	E3,9
		db	REST,17
		db	FS3,51
		db	REST,9
		db	GS3,13
		db	REST,4
		db	GS3,8
		db	REST,18
		db	GS3,8
		db	REST,17
		db	GS3,9
		db	E3,17
		db	REST,9
		db	CS3,21
		db	REST,4
		db	E3,17
		db	A2,9
		db	REST,26
		db	CS3,17
		db	REST,8 ;filler
		db	END

SEQ89:		db	MANUAL,GLIOFF	;[MERM11B,3]
		db	ENV,$86
		db	G1,13
		db	REST,5
		db	G1,8
		db	REST,17
		db	G1,9
		db	REST,51
		db	D2,13
		db	REST,5
		db	D2,8
		db	REST,17
		db	D2,9
		db	REST,17
		db	D2,9
		db	CS2,12
		db	REST,5
		db	B1,8
		db	A1,13
		db	REST,4
		db	A1,9
		db	REST,17
		db	A1,9
		db	REST,17
		db	B1,8
		db	CS2,18
		db	REST,8
		db	D2,43
		db	A1,9
		db	REST,17
		db	A1,8
		db	D2,26
		db	G1,13
		db	REST,4
		db	G1,9
		db	REST,17
		db	G1,8
		db	REST,52
		db	D2,17
		db	CS2,9
		db	REST,17
		db	B1,60
		db	E2,13
		db	REST,4
		db	E2,8
		db	REST,18
		db	E2,34
		db	E1,26
		db	A1,25
		db	B1,17
		db	CS2,9
		db	REST,26
		db	A1,25
		db	END

SEQ90:		db	MANUAL,GLIOFF	;[MERM11B,4]
		db	ENV,$A1
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,19
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	END



SEQ91:		;DB      ENV,$85	;[save] bass
 		;DB	LENGTH,QV3
		;DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		;DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		;DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		;DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		;DB	D2,D2,D2,F2,REST,D2,F2,REST
		;DB	AS2,F2,D2,A2,REST,AS1,B1,C2
		;DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		;DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		;DB      END

SEQ92:		db	MANUAL,GLIOFF	;[MERM11C,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,13
		db	REST,5
		db	A3,8
		db	FS3,17
		db	D3,9
		db	REST,17
		db	A3,9
		db	FS3,17
		db	D3,8
		db	B3,18
		db	G3,8
		db	REST,17
		db	E3,9
		db	REST,17
		db	B3,9
		db	REST,17
		db	D4,8
		db	CS4,13
		db	REST,4
		db	CS4,9
		db	B3,17
		db	A3,9
		db	REST,17
		db	G3,8
		db	REST,18
		db	E3,8
		db	FS3,17
		db	G3,9
		db	REST,17
		db	A3,9
		db	REST,17
		db	B3,8
		db	A3,13
		db	REST,13
		db	D4,26
		db	A3,17
		db	FS3,8
		db	REST,18
		db	D4,8
		db	REST,17
		db	A3,9
		db	B3,17
		db	G3,9
		db	REST,17
		db	E3,8
		db	REST,17
		db	E3,9
		db	D3,13
		db	REST,13
		db	CS3,17
		db	B3,8
		db	REST,18
		db	A3,8
		db	REST,17
		db	B3,9
		db	CS4,17
		db	D4,9
		db	REST,17
		db	A3,8
		db	REST,17
		db	A3,5
		db	REST,4
		db	A3,13
		db	REST,13
		db	B3,13
		db	REST,12 ;filler
		db	END

SEQ93:		db	MANUAL,GLIOFF	;[MERM11C,2]
		db	ENV,$47
		db	FS3,26
		db	D3,17
		db	A2,9
		db	REST,51
		db	D3,18
		db	CS3,8
		db	REST,17
		db	G2,9
		db	REST,51
		db	E3,26
		db	G3,17
		db	FS3,9
		db	REST,51
		db	A2,17
		db	CS3,9
		db	REST,17
		db	FS3,9
		db	REST,51
		db	FS3,43
		db	A2,8
		db	REST,18
		db	FS3,8
		db	REST,17
		db	FS3,9
		db	D3,38
		db	REST,5
		db	B2,8
		db	REST,17
		db	G2,9
		db	B2,13
		db	REST,13
		db	G2,43
		db	CS3,8
		db	REST,17
		db	D3,9
		db	E3,17
		db	FS3,9
		db	REST,17
		db	E3,8
		db	REST,17
		db	D3,9
		db	CS3,47
		db	REST,4 ;filler
		db	END

SEQ94:		db	MANUAL,GLIOFF	;[MERM11C,3]
		db	ENV,$86
		db	D2,26
		db	A1,17
		db	D2,9
		db	REST,17
		db	FS2,9
		db	D2,13
		db	REST,12
		db	G1,18
		db	A1,8
		db	REST,17
		db	B1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	G1,8
		db	A1,22
		db	REST,4
		db	E2,17
		db	CS2,9
		db	REST,17
		db	E2,8
		db	A1,22
		db	REST,4
		db	D2,13
		db	REST,4
		db	A1,9
		db	REST,17
		db	D2,9
		db	REST,17
		db	D2,8
		db	A1,13
		db	REST,13
		db	D2,39
		db	REST,4
		db	D2,8
		db	REST,52
		db	G1,34
		db	REST,9
		db	G1,8
		db	REST,52
		db	A1,34
		db	REST,9
		db	A1,8
		db	REST,17
		db	B1,9
		db	CS2,17
		db	D2,9
		db	REST,17
		db	CS2,8
		db	REST,17
		db	B1,9
		db	A1,51
		db	END

SEQ95:		db	MANUAL,GLIOFF	;[MERM11C,4]
		db	ENV,$A1
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,40
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,9
		db	DRUM,6,10
		db	REST,20
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	REST,20
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,6,10
		db	DRUM,8,10
		db	REST,10
		db	DRUM,8,10
		db	DRUM,6,10
		db	REST,10
		db	DRUM,8,10
		db	END

OLD19		EQU	1

SEQ96:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
	IF	OLD19
		db	E3,11
		db	G3,10
		db	B3,11
		db	C4,10
		db	REST,11
		db	E4,10
		db	REST,11
		db	C4,10
		db	D4,11
		db	REST,10
		db	F4,10
		db	REST,11
		db	E4,21
		db	G4,10
		db	REST,11
		db	C3,10
		db	E3,11
		db	G3,10
		db	C4,10
		db	REST,11
		db	B3,10
		db	A3,11
		db	G3,10
		db	B3,11
		db	REST,10
		db	D4,11
		db	REST,10
	DB	VIBON,2,1,2
		db	C4,42
	DB	VIBOFF
		db	END
	ELSE
		db	E3,10
		db	G3,10
		db	C4,10
		db	E4,10
		db	REST,9
		db	E4,10
		db	REST,10
		db	C4,10
		db	D4,9
		db	REST,10
		db	F4,10
		db	REST,10
		db	E4,19
		db	G4,10
		db	REST,10
		db	C3,10
		db	E3,9
		db	G3,10
		db	C4,10
		db	REST,10
		db	C4,9
		db	REST,10
		db	G3,10
		db	B3,10
		db	REST,10
		db	D4,9
		db	REST,10
	db	VIBON,2,1,2
		db	C4,39
	db	VIBOFF
		db	END
	ENDC
;total time = 335
SEQ97:
		db	MANUAL,GLIOFF
		db	ENV,$47
	IF	OLD19
		db	C3,11
		db	E3,10
		db	G3,11
		db	E3,10
		db	REST,11
		db	G3,10
		db	REST,11
		db	E3,10
		db	F3,11
		db	REST,10
		db	B3,10
		db	REST,11
		db	C4,21
		db	E4,10
		db	REST,11
		db	G2,10
		db	C3,11
		db	E3,10
		db	G3,10
		db	REST,11
		db	G3,10
		db	F3,11
		db	E3,10
		db	D3,11
		db	REST,10
		db	F3,11
		db	REST,10
		db	E3,31
		db	REST,11 ;filler
		db	END
	ELSE
		db	C3,10
		db	E3,10
		db	G3,10
		db	C4,10
		db	REST,9
		db	C4,10
		db	REST,10
		db	A3,10
		db	F3,9
		db	REST,10
		db	B3,10
		db	REST,10
		db	C4,19
		db	E4,10
		db	REST,10
		db	G2,10
		db	C3,9
		db	E3,10
		db	G3,10
		db	REST,10
		db	G3,9
		db	REST,10
		db	E3,10
		db	D3,10
		db	REST,10
		db	F3,9
		db	REST,10
	DB	VIBON,2,1,2
		db	E3,29
	DB	VIBOFF
		db	REST,10 ;filler
		db	END
	ENDC
;total time = 335
SEQ98:
		db	MANUAL,GLIOFF
		db	ENV,$77
	IF	OLD19
		db	C2,21
		db	REST,11
		db	G2,10
		db	REST,11
		db	C2,10
		db	REST,11
		db	E2,10
		db	B1,11
		db	REST,10
		db	G1,10
		db	REST,11
		db	C2,21
		db	C3,10
		db	REST,11
		db	C2,21
		db	REST,10
		db	E2,10
		db	REST,11
		db	E2,10
		db	REST,11
		db	C2,10
		db	G1,11
		db	REST,10
		db	B1,11
		db	REST,10
		db	C2,31
		db	REST,11 ;filler
		db	END
	ELSE
		db	C2,20
		db	REST,10
		db	G2,10
		db	REST,9
		db	C2,10
		db	REST,10
		db	E2,10
		db	B1,9
		db	REST,10
		db	G1,10
		db	REST,10
		db	C2,19
		db	C3,10
		db	REST,10
		db	C2,19
		db	REST,10
		db	E2,10
		db	REST,10
		db	E2,9
		db	REST,10
		db	C2,10
		db	G1,10
		db	REST,10
		db	B1,9
		db	REST,10
	DB	VIBON,2,1,2
		db	C2,29
	DB	VIBOFF
		db	REST,10 ;filler
		db	END
	ENDC
;total time = 335
SEQ99:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
	IF	OLD19
		db	REST,21
		db	C4,8
		db	REST,3
		db	C4,8
		db	REST,13
		db	E4,10
		db	REST,11
		db	C4,10
		db	B3,11
		db	REST,10
		db	D4,10
		db	REST,11
		db	E4,21
		db	G3,21
		db	REST,21
		db	G3,7
		db	REST,3
		db	G3,8
		db	REST,13
		db	C4,10
		db	REST,11
		db	E4,10
		db	F4,11
		db	REST,10
		db	D4,11
		db	REST,10
	DB	VIBON,2,1,2
		db	E4,42
	DB	VIBOFF
		db	END
	ELSE
		db	REST,20
		db	C4,7
		db	REST,3
		db	C4,7
		db	REST,12
		db	C4,10
		db	REST,10
		db	G3,10
		db	B3,9
		db	REST,10
		db	D4,10
		db	REST,10
		db	C4,19
		db	G3,20
		db	REST,19
		db	G3,8
		db	REST,2
		db	G3,7
		db	REST,13
		db	G3,9
		db	REST,10
		db	C4,10
		db	D4,10
		db	REST,10
		db	F4,9
		db	REST,10
	DB	VIBON,2,1,2
		db	E4,39
	DB	VIBOFF
		db	END
	ENDC
;total time = 335
SEQ100:
		db	MANUAL,GLIOFF
		db	ENV,$47
	IF	OLD19
		db	G2,11
		db	C3,10
		db	E3,11
		db	G3,10
		db	REST,11
		db	G3,10
		db	REST,11
		db	E3,10
		db	G3,11
		db	REST,10
		db	F3,10
		db	REST,11
		db	G3,21
		db	E3,10
		db	REST,11
		db	G2,10
		db	C3,11
		db	E3,10
		db	C3,10
		db	REST,11
		db	E3,10
		db	REST,11
		db	G3,10
		db	B3,11
		db	REST,10
		db	F3,11
		db	REST,10
		db	G3,42
		db	END
	ELSE
		db	G2,10
		db	C3,10
		db	E3,10
		db	G3,10
		db	REST,9
		db	E3,10
		db	REST,10
		db	C3,10
		db	G3,9
		db	REST,10
		db	F3,10
		db	REST,10
		db	E3,19
		db	C3,10
		db	REST,10
		db	G2,10
		db	C3,9
		db	E3,10
		db	C3,10
		db	REST,10
		db	E3,9
		db	REST,10
		db	E3,10
		db	B3,10
		db	REST,10
		db	D3,9
		db	REST,10
	DB	VIBON,2,1,2
		db	G3,39
	DB	VIBOFF
		db	END
	ENDC
;total time = 335
SEQ101:
		db	MANUAL,GLIOFF
		db	ENV,$77
	IF	OLD19
		db	C2,21
		db	REST,11
		db	E2,10
		db	REST,11
		db	C2,10
		db	REST,11
		db	E2,10
		db	D2,11
		db	REST,10
		db	G1,10
		db	REST,11
		db	C2,31
		db	REST,11
		db	C2,21
		db	REST,10
		db	E2,10
		db	REST,11
		db	G2,10
		db	REST,11
		db	C2,10
		db	D2,11
		db	REST,10
		db	G2,11
		db	REST,10
		db	C2,21
		db	G1,21
		db	END
	ELSE
		db	C2,20
		db	REST,10
		db	E2,10
		db	REST,9
		db	C2,10
		db	REST,10
		db	E2,10
		db	D2,9
		db	REST,10
		db	G1,10
		db	REST,10
		db	C2,29
		db	REST,10
		db	C2,19
		db	REST,10
		db	E2,10
		db	REST,10
		db	G2,9
		db	REST,10
		db	C2,10
		db	G2,10
		db	REST,10
		db	B1,9
		db	REST,10
		db	C2,20
		db	G1,19
		db	END
	ENDC
;total time = 335

SEQ102:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
	IF	OLD19
		db	REST,21
		db	C4,8
		db	REST,3
		db	C4,10
		db	REST,11
		db	A3,10
		db	C4,11
		db	A3,10
		db	G3,21
		db	C4,21
		db	E4,21
		db	C4,21
		db	REST,21
		db	D4,7
		db	REST,3
		db	D4,10
		db	REST,11
		db	G4,10
		db	D4,11
		db	C4,10
		db	E4,21
		db	D4,21
	DB	VIBON,2,1,2
		db	C4,31
	DB	VIBOFF
		db	REST,11 ;filler
		db	END
	ELSE
		db	REST,20
		db	C4,7
		db	REST,3
		db	C4,10
		db	REST,9
		db	C4,10
		db	REST,10
		db	A3,10
		db	G3,19
		db	C4,20
		db	G3,19
		db	C4,20
		db	REST,19
		db	D4,8
		db	REST,2
		db	D4,10
		db	REST,10
		db	D4,9
		db	REST,10
		db	C4,10
		db	E4,20
		db	D4,19
	DB	VIBON,2,1,2
		db	C4,29
	DB	VIBOFF
		db	REST,10 ;filler
		db	END
	ENDC
;total time = 335
SEQ103:
		db	MANUAL,GLIOFF
		db	ENV,$47
	IF	OLD19
		db	C3,11
		db	F3,10
		db	A3,11
		db	F3,10
		db	REST,11
		db	C3,10
		db	REST,42
		db	E3,21
		db	G3,21
		db	E3,21
		db	D3,10
		db	G3,11
		db	B3,10
		db	G3,10
		db	REST,11
		db	B3,10
		db	REST,21
		db	G3,21
		db	F3,21
		db	E3,31
		db	REST,11 ;filler
		db	END
	ELSE
		db	C3,10
		db	F3,10
		db	A3,10
		db	F3,10
		db	REST,9
		db	A3,10
		db	REST,39
		db	E3,10
		db	REST,10
		db	E3,19
		db	G3,20
		db	D3,10
		db	G3,9
		db	B3,10
		db	G3,10
		db	REST,10
		db	B3,9
		db	REST,20
		db	G3,20
		db	F3,19
		db	E3,29
		db	REST,10 ;filler
		db	END
	ENDC
;total time = 335
SEQ104:
		db	MANUAL,GLIOFF
		db	ENV,$77
	IF	OLD19
		db	F1,21
		db	C2,11
		db	F2,10
		db	REST,11
		db	F2,10
		db	REST,21
		db	C2,11
		db	REST,10
		db	G2,10
		db	REST,11
		db	C2,42
		db	G1,21
		db	D2,10
		db	B1,10
		db	REST,11
		db	D2,10
		db	REST,11
		db	G1,10
		db	C2,11
		db	REST,10
		db	A2,11
		db	REST,10
		db	G2,21
		db	C2,21
		db	END
	ELSE
		db	F1,20
		db	C2,10
		db	F2,10
		db	REST,9
		db	F2,10
		db	REST,20
		db	C2,9
		db	REST,10
		db	G2,10
		db	REST,10
		db	C2,39
		db	G1,19
		db	D2,10
		db	B1,10
		db	REST,10
		db	D2,9
		db	REST,10
		db	G1,10
		db	C2,10
		db	REST,10
		db	A2,9
		db	REST,10
		db	G2,20
		db	C2,19
		db	END
	ENDC
;total time = 335

SEQ105:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
	IF	OLD19
		db	REST,42
		db	E4,14
		db	D4,14
		db	E4,14
		db	END
	ELSE
		db	REST,40
		db	E4,13
		db	D4,13
		db	C4,13
		db	END
	ENDC
;total time = 84
SEQ106:
		db	MANUAL,GLIOFF
		db	ENV,$47
	IF	OLD19
		db	C3,11
		db	REST,10
		db	E3,21
		db	C3,14
		db	F3,14
		db	G3,14
		db	END
	ELSE
		db	C3,10
		db	REST,10
		db	E3,20
		db	C3,13
		db	F3,13
		db	E3,13
		db	END
	ENDC
;total time = 84
SEQ107:
		db	MANUAL,GLIOFF
		db	ENV,$77
	IF	OLD19
		db	G1,11
		db	REST,10
		db	C2,63
		db	END
	ELSE
		db	G1,10
		db	REST,10
		db	C2,59
		db	END
	ENDC
;total time = 84

SEQ108:
		db	MANUAL,GLIOFF
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
	IF	OLD19
	DB	VIBON,2,1,2
		db	C4,84
	DB	VIBOFF
		db	REST,42
		db	D4,14
		db	E4,14
		db	C4,14
	DB	VIBON,2,1,2
		db	D4,83
	DB	VIBOFF
		db	REST,42	;F4,21
		db	G4,14	;A3,11
		db	F4,14	;C4,10
		db	E4,14	;G4,10
		db	F4,21	;F4,4
		db	A3,10	;F4,7
		db	C4,21	;C4,7
		db	F4,11	;E4,14  ;84 total
		db	C4,21	;

		db	B3,21
		db	G3,10
		db	D4,21
		db	C4,10
		db	D4,21
	DB	VIBON,2,1,2
		db	E4,84
	DB	VIBOFF
		db	REST,42
		db	E4,14
		db	D4,14
		db	E4,14
		db	C4,20
		db	A3,11
		db	C4,10
		db	REST,11
		db	A3,10
		db	REST,11
	DB	VIBON,2,1,2
		db	D4,36
	DB	VIBOFF
		db	REST,5
		db	D4,11
		db	REST,10
		db	E4,11
		db	D4,10
		db	C4,32
		db	D4,10
		db	E4,10
		db	REST,11
		db	C4,10
		db	REST,11
	DB	VIBON,2,1,2
		db	D4,42
	DB	VIBOFF
		db	REST,10
		db	E4,14
		db	D4,14
		db	C4,14
		db	A3,21
		db	F4,10
		db	E4,11
		db	REST,10
		db	D4,11
		db	C4,10
		db	REST,10
		db	G4,14
		db	F4,14
		db	G4,14
		db	D4,14
		db	E4,14
		db	D4,14
		db	END
	ELSE
	DB	VIBON,2,1,2
		db	A3,79
	DB	VIBOFF
		db	REST,39
		db	E4,13
		db	D4,13
		db	C4,13
	DB	VIBON,2,1,2
		db	D4,78
	DB	VIBOFF
		db	REST,39
		db	E4,13
		db	D4,13
		db	C4,13
		db	A3,20
		db	F3,9
		db	E4,20
		db	D4,10
		db	C4,19
		db	B3,20
		db	G3,10
		db	E4,19
		db	D4,10
		db	C4,20
	DB	VIBON,2,1,2
		db	E4,78
	DB	VIBOFF
		db	REST,39
		db	E4,13
		db	D4,13
		db	C4,13
		db	A3,19
		db	C4,8
		db	REST,2
		db	C4,10
		db	REST,10
		db	A3,9
		db	REST,10
	DB	VIBON,2,1,2
		db	D4,34
	DB	VIBOFF
		db	REST,5
		db	D4,10
		db	REST,10
		db	C4,10
		db	D4,9
		db	E4,25
		db	REST,5
		db	E4,9
		db	D4,10
		db	REST,10
		db	C4,10
		db	REST,10
	DB	VIBON,2,1,2
		db	D4,39
	DB	VIBOFF
		db	REST,9
		db	E4,13
		db	D4,13
		db	C4,14
		db	A3,14
		db	REST,5
		db	A3,10
		db	E4,10
		db	REST,9
		db	D4,10
		db	C4,10
		db	REST,10
		db	A4,13
		db	G4,9
		db	REST,4
		db	G4,13
		db	E4,13
		db	C4,13
		db	D4,13
		db	END
	ENDC
;total time = 1087
SEQ109:
		db	MANUAL,GLIOFF
		db	ENV,$47
	IF	OLD19
		db	A3,27
		db	REST,5
		db	A3,10
		db	REST,11
		db	A3,10
		db	REST,21	;84

		db	G3,21
		db	E3,21
		db	F3,14
		db	G3,14
		db	E3,14	;84

		db	B3,26
		db	REST,5
		db	B3,10
		db	REST,11
		db	B3,10
		db	REST,21 ;83

		db	G3,21	;
		db	C3,21	;
		db	E3,14	;
		db	F3,14	;
		db	G3,14	;84

		db	A3,27	;G3,21
		db	REST,5	;C3,11
		db	A3,10	;A3,10
		db	REST,11	;E3,10
		db	A3,10	;A3,4
		db	REST,21	;F3,7
				;REST,7
				;G3,14

		db	G3,31
		db	B3,11
		db	REST,10
		db	G3,10
		db	REST,21
		db	G3,42
		db	F3,42
		db	E3,42
		db	AS3,42
		db	A3,20
		db	F3,11
		db	A3,10
		db	REST,11
		db	F3,10
		db	REST,11
		db	B3,31
		db	REST,10
		db	B3,11
		db	REST,10
		db	G3,11
		db	F3,10
		db	E3,32
		db	D3,10
		db	C3,10
		db	REST,11
		db	E3,10
		db	REST,11
		db	FS3,42
		db	REST,10
		db	C4,14
		db	B3,14
		db	A3,14
		db	F3,21
		db	A3,10
		db	G3,11
		db	REST,10
		db	F3,11
		db	A3,10
		db	REST,10
		db	B3,14
		db	D4,14
		db	B3,14
		db	F3,14
		db	G3,14
		db	F3,14
		db	END
	ELSE
		db	C3,25
		db	REST,5
		db	C3,10
		db	REST,9
		db	C3,10
		db	REST,20
		db	G3,19
		db	E3,20
		db	G3,13
		db	F3,13
		db	E3,13
		db	B3,24
		db	REST,5
		db	B3,10
		db	REST,10
		db	B3,9
		db	REST,20
		db	G3,20
		db	C3,19
		db	G3,13
		db	F3,13
		db	E3,13
		db	C3,20
		db	REST,9
		db	A3,10
		db	REST,10
		db	A3,10
		db	REST,19
		db	G3,30
		db	B3,9
		db	REST,10
		db	G3,10
		db	REST,20
		db	G3,39
		db	F3,39
		db	E3,39
		db	AS3,39
		db	C3,19
		db	A3,8
		db	REST,2
		db	A3,10
		db	REST,10
		db	F3,9
		db	REST,10
		db	B3,30
		db	REST,9
		db	B3,10
		db	REST,10
		db	E3,10
		db	F3,9
		db	C3,27
		db	REST,3
		db	C3,7
		db	REST,2
		db	C3,10
		db	REST,10
		db	E3,10
		db	REST,10
		db	FS3,39
		db	REST,9
		db	C4,13
		db	B3,13
		db	A3,14
		db	F3,17
		db	REST,2
		db	F3,10
		db	G3,10
		db	REST,9
		db	F3,10
		db	A3,10
		db	REST,10
		db	F3,13
		db	B3,9
		db	REST,4
		db	B3,13
		db	G3,13
		db	E3,13
		db	B2,13
		db	END
	ENDC
;total time = 1087
SEQ110:
		db	MANUAL,GLIOFF
		db	ENV,$77
	IF	OLD19
		db	F2,21
		db	REST,11
		db	F2,10
		db	REST,11
		db	F2,10
		db	E2,11
		db	D2,10	;84

		db	E2,11
		db	REST,10
		db	G1,10
		db	REST,11
		db	C2,42	;84

		db	G2,21
		db	REST,10
		db	G2,10
		db	REST,11
		db	D2,10
		db	G2,11
		db	F2,10	;83

		db	E2,21	;E2,11
		db	G2,21	;REST,10
		db	C2,42	;G2,11
				;F2,10
				;C2,10
				;F2,11
				;REST,21 ;84 total

		db	F2,26	;
		db	REST,5	;
		db	F2,10	;
		db	REST,11	;
		db	F2,10	;
		db	REST,22	;84

		db	G2,26
		db	REST,5
		db	G2,11
		db	REST,10
		db	G2,10
		db	REST,21
		db	C2,21
		db	G2,11
		db	A2,10
		db	REST,11
		db	A2,10
		db	G2,11
		db	REST,10
		db	C2,21
		db	E2,21
		db	G2,21
		db	C2,21
		db	F2,20
		db	REST,11
		db	F2,10
		db	REST,11
		db	C2,10
		db	F2,11
		db	G2,31
		db	REST,10
		db	G2,11
		db	REST,10
		db	C2,11
		db	B1,10
		db	A1,42
		db	A2,10
		db	REST,11
		db	A2,10
		db	G2,11
		db	D2,31
		db	A1,21
		db	D2,14
		db	E2,14
		db	FS2,14
		db	F2,21
		db	C2,10
		db	A2,11
		db	REST,10
		db	D2,11
		db	F2,10
		db	REST,10
		db	G2,42
		db	G1,42
		db	END
;total time = 1087
	ELSE
		db	F2,20
		db	REST,10
		db	F2,10
		db	REST,9
		db	F2,10
		db	E2,10
		db	D2,10
		db	E2,9
		db	REST,10
		db	G1,10
		db	REST,10
		db	C2,39
		db	G2,19
		db	REST,10
		db	G2,10
		db	REST,10
		db	D2,9
		db	G2,10
		db	F2,10
		db	E2,10
		db	REST,10
		db	G2,9
		db	REST,10
		db	C2,39
		db	F2,20
		db	REST,9
		db	F2,10
		db	REST,10
		db	F2,10
		db	REST,19
		db	G2,25
		db	REST,5
		db	G2,9
		db	REST,10
		db	G2,10
		db	REST,20
		db	C2,19
		db	G2,10
		db	A2,10
		db	REST,9
		db	A2,10
		db	G2,10
		db	REST,10
		db	C2,19
		db	E2,20
		db	G2,19
		db	C2,20
		db	F2,19
		db	REST,10
		db	F2,10
		db	REST,10
		db	C2,9
		db	F2,10
		db	G2,30
		db	REST,9
		db	G2,10
		db	REST,10
		db	C2,10
		db	B1,9
		db	A1,39
		db	A2,10
		db	REST,10
		db	A2,10
		db	G2,10
		db	D2,29
		db	A1,19
		db	D2,13
		db	E2,13
		db	FS2,14
		db	F2,19
		db	C2,10
		db	A2,10
		db	REST,9
		db	D2,10
		db	F2,10
		db	REST,10
		db	G2,39
		db	G1,39
		db	END
	ENDC

SEQ115:		db	MANUAL,GLIOFF	;[MERM12A,2 - NO 12A,1]
		DB    ENV,$A6
		db	A2,14
		db	CS3,14
		db	E3,7
		db	REST,20
		db	G2,14
		db	B2,13
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,14
		db	E3,6
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,14
		db	B2,7
		db	REST,6
		db	A2,14
		db	CS3,14
		db	E3,6
		db	REST,21
		db	G2,13
		db	B2,14
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,14
		db	B2,6
		db	REST,7 ;filler
		db	END

SEQ116:		db	MANUAL,GLIOFF	;[MERM12A,3]
		db	ENV,$77
		db	A1,14
		db	REST,41
		db	G1,14
		db	REST,40
		db	A1,14
		db	REST,27
		db	G1,41
		db	E1,21
		db	REST,6
		db	A1,14
		db	REST,41
		db	G1,13
		db	REST,41
		db	A1,14
		db	REST,27
		db	G1,41
		db	E1,27
		db	END

SEQ117:		db	MANUAL,GLIOFF	;[MERM12B,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	CS4,28
		db	A3,13
		db	CS4,14
		db	B3,14
		db	G3,6
		db	REST,48
		db	A3,14
		db	CS4,13
		db	B3,27
		db	G3,14
		db	FS3,14
		db	E3,7
		db	REST,6
		db	E3,14
		db	A3,14
		db	CS4,13
		db	B3,27
		db	G3,14
		db	REST,14
		db	E3,13
		db	A3,14
		db	E3,13
		db	A3,14
		db	G3,61
		db	REST,7
		db	CS4,21
		db	REST,6
		db	A3,14
		db	CS4,14
		db	B3,13
		db	G3,7
		db	REST,48
		db	A3,13
		db	CS4,14
		db	D4,41
		db	B3,13
		db	G3,7
		db	REST,21
		db	A3,13
		db	CS4,14
		db	B3,20
		db	REST,7
		db	G3,14
		db	REST,13
		db	E3,14
		db	A3,13
		db	E3,14
		db	A3,14
		db	G3,41
		db	B3,13
		db	G3,14
		db	END

SEQ118:		db	MANUAL,GLIOFF	;[MERM12B,2]
		db	ENV,$57
		db	A2,14
		db	CS3,14
		db	E3,7
		db	REST,20
		db	G2,14
		db	B2,13
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,14
		db	E3,6
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,14
		db	B2,7
		db	REST,6
		db	A2,14
		db	CS3,14
		db	E3,6
		db	REST,21
		db	G2,13
		db	B2,14
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,14
		db	B2,6
		db	REST,7
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,21
		db	G2,13
		db	B2,14
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,13
		db	B2,7
		db	REST,7
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,20
		db	G2,14
		db	B2,14
		db	D3,6
		db	REST,21
		db	A2,13
		db	CS3,14
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,13
		db	B2,7
		db	REST,7 ;filler
		db	END

SEQ119:		db	MANUAL,GLIOFF	;[MERM12B,3]
		db	ENV,$77
		db	A1,14
		db	REST,41
		db	G1,14
		db	REST,40
		db	A1,14
		db	REST,27
		db	G1,41
		db	A2,14
		db	G2,13
		db	A1,14
		db	REST,41
		db	G1,13
		db	REST,41
		db	CS2,14
		db	REST,27
		db	B1,41
		db	G1,20
		db	REST,7
		db	A1,14
		db	REST,41
		db	G1,13
		db	REST,41
		db	A1,14
		db	REST,27
		db	G1,41
		db	G2,13
		db	D2,14
		db	A1,14
		db	REST,40
		db	G1,14
		db	REST,41
		db	CS2,13
		db	REST,28
		db	B1,41
		db	G1,20
		db	REST,7 ;filler
		db	END

SEQ120:		db	MANUAL,GLIOFF	;[MERM12B,4]
		db	ENV,$F1
		db	REST,14
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,28
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,14
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,13
		db	DRUM,8,14
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,14
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,28
		db	DRUM,6,13
		db	DRUM,8,14
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,14
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,28
		db	DRUM,8,13
		db	DRUM,6,14
		db	END

SEQ121:		db	MANUAL,GLIOFF	;[MERM12C,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	FS3,14
		db	A3,7
		db	REST,20
		db	C4,28
		db	D4,13
		db	C4,14
		db	REST,13
		db	FS4,14
		db	D4,14
		db	A3,13
		db	E4,27
		db	C4,14
		db	G3,14
		db	REST,13
		db	FS3,14
		db	A3,7
		db	REST,20
		db	C4,27
		db	E4,14
		db	C4,7
		db	REST,7
		db	G3,6
		db	REST,7
		db	FS3,14
		db	A3,13
		db	D4,14
		db	C4,41
		db	G3,14
		db	E3,6
		db	REST,7
		db	CS4,21
		db	REST,6
		db	A3,14
		db	CS4,14
		db	B3,13
		db	G3,7
		db	REST,48
		db	A3,13
		db	CS4,14
		db	D4,41
		db	B3,13
		db	G3,7
		db	REST,21
		db	A3,13
		db	CS4,14
		db	B3,20
		db	REST,7
		db	G3,14
		db	REST,13
		db	E3,14
		db	A3,13
		db	E3,14
		db	A3,14
		db	G3,41
		db	D4,13
		db	DS4,14
		db	E4,27
		db	GS3,14
		db	A3,68
		db	C4,27
		db	E3,14
		db	F3,68
		db	REST,13
		db	A3,14
		db	CS4,13
		db	B3,14
		db	REST,14
		db	G3,13
		db	REST,14
		db	B3,14
		db	CS4,13
		db	A3,14
		db	CS4,13
		db	B3,28
		db	D4,13
		db	B3,14
		db	G3,13
		db	END

SEQ122:		db	MANUAL,GLIOFF	;[MERM12C,2]
		db	ENV,$57
		db	A2,14
		db	D3,14
		db	FS3,7
		db	REST,20
		db	G2,14
		db	C3,13
		db	E3,7
		db	REST,20
		db	A2,14
		db	D3,14
		db	FS3,6
		db	REST,7
		db	G2,27
		db	E3,14
		db	C3,14
		db	G2,13
		db	A2,14
		db	D3,14
		db	FS3,6
		db	REST,21
		db	G2,13
		db	C3,14
		db	E3,7
		db	REST,20
		db	A2,14
		db	D3,13
		db	FS3,7
		db	REST,7
		db	G2,27
		db	E3,14
		db	C3,14
		db	G2,13
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,21
		db	G2,13
		db	B2,14
		db	D3,7
		db	REST,20
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,13
		db	B2,7
		db	REST,7
		db	A2,14
		db	CS3,13
		db	E3,7
		db	REST,20
		db	G2,14
		db	B2,14
		db	D3,6
		db	REST,21
		db	A2,13
		db	CS3,14
		db	E3,7
		db	REST,7
		db	G2,27
		db	B2,14
		db	D3,13
		db	B2,7
		db	REST,7
		db	GS3,13
		db	E3,14
		db	B2,14
		db	FS3,27
		db	D3,13
		db	A2,14
		db	D3,14
		db	E3,13
		db	C3,14
		db	G2,14
		db	D3,27
		db	AS2,13
		db	F2,14
		db	AS2,14
		db	A2,13
		db	CS3,14
		db	E3,13
		db	REST,14
		db	G2,14
		db	B2,13
		db	D3,14
		db	REST,14
		db	A2,13
		db	CS3,14
		db	E3,13
		db	G3,28
		db	B3,13
		db	G3,14
		db	E3,13
		db	END

SEQ123:		db	MANUAL,GLIOFF	;[MERM12C,3]
		db	ENV,$77
		db	D2,14
		db	REST,41
		db	C2,14
		db	REST,40
		db	D2,14
		db	REST,27
		db	C2,41
		db	E2,14
		db	C2,13
		db	D2,14
		db	REST,41
		db	C2,13
		db	REST,41
		db	D2,14
		db	REST,27
		db	E2,34
		db	REST,7
		db	E2,14
		db	C2,13
		db	A1,14
		db	REST,41
		db	G1,13
		db	REST,41
		db	A1,14
		db	REST,27
		db	B1,41
		db	G1,13
		db	D2,14
		db	A1,14
		db	REST,40
		db	G1,14
		db	REST,41
		db	A1,13
		db	REST,28
		db	B1,41
		db	G2,13
		db	FS2,14
		db	E2,13
		db	REST,28
		db	D2,68
		db	C2,13
		db	REST,28
		db	AS1,61
		db	REST,7
		db	A1,13
		db	REST,41
		db	G1,20
		db	REST,35
		db	A1,13
		db	REST,27
		db	G1,28
		db	G2,13
		db	D2,14
		db	G1,13
		db	END

SEQ124:		db	MANUAL,GLIOFF	;[MERM12C,4]
		db	ENV,$F1
		db	REST,14
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,28
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,14
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,13
		db	DRUM,8,14
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,14
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,28
		db	DRUM,6,13
		db	DRUM,8,14
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,14
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,28
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,13
		db	DRUM,6,14
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,14
		db	DRUM,6,13
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,14
		db	REST,13
		db	DRUM,6,14
		db	DRUM,8,13
		db	REST,28
		db	DRUM,6,13
		db	DRUM,8,14
		db	REST,27
		db	DRUM,6,14
		db	DRUM,8,13
		db	DRUM,6,14
		db	REST,27
		db	DRUM,8,14
		db	DRUM,6,13
		db	END




SEQ125:		db	MANUAL,GLIOFF	;[DITTY01,1]
		DB    WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    POKE,255&rNR51,$FF
		DB    VIBON,2,1,2
		DB    ENV,%00100000
		db	A3,28
		db	FS3,7
		db	A3,6
		db	B3,14
		db	GS3,14
		db	B3,6
		db	REST,7
		db	C4,27
		db	A3,7
		db	C4,7
		db	D4,14
		db	B3,13
		db	D4,7
		db	REST,7
		db	E4,48
		db	END

SEQ126:		db	MANUAL,GLIOFF	;[DITTY01,2]
		db	ENV,$47
		db	FS3,28
		db	D3,7
		db	FS3,6
		db	GS3,14
		db	E3,14
		db	GS3,6
		db	REST,7
		db	A3,27
		db	F3,7
		db	A3,7
		db	B3,14
		db	G3,13
		db	B3,7
		db	REST,7
		db	CS4,122
		db	END

SEQ127:		DB	MANUAL	;[DITTY01,3]
		DB    ENV,$86
		db	D2,28
		db	A1,13
		db	E2,21
		db	REST,7
		db	E2,6
		db	REST,7
		db	F2,27
		db	C2,14
		db	G2,27
		db	D2,7
		db	REST,7
		db	A2,122
		db	END

SEQ128:
SEQ129:
SEQ130:


SEQ131:		db	MANUAL,GLIOFF	;[DITTY03A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	A2,11
		db	E3,10
		db	A3,11
		db	CS4,10
		db	DS4,11
		db	CS4,10
		db	A3,11
		db	E3,10
		db	A2,11
		db	E3,10
		db	A3,10
		db	CS4,11
		db	DS4,10
		db	CS4,11
		db	A3,10
		db	E3,11
		db	A2,10
		db	FS3,11
		db	B3,10
		db	DS4,10
		db	E4,11
		db	DS4,10
		db	B3,11
		db	FS3,10
		db	A2,11
		db	FS3,10
		db	B3,11
		db	DS4,10
		db	E4,10
		db	DS4,11
		db	B3,10
		db	FS3,11
		db	END

SEQ132:		db	MANUAL	;[DITTY03A,3]
		DB  	ENV,$27
		db	REST,11
		db	E2,31
		db	A2,32
		db	CS3,31
		db	E3,31
		db	A2,32
		db	REST,10
		db	FS2,31
		db	B2,32
		db	DS3,31
		db	FS3,31
		db	B2,32
		db	END


SEQ141:		db	MANUAL,GLIOFF	;[MERM13A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	E4,28
		db	C4,13
		db	G3,55
		db	F3,13
		db	G3,14
		db	A3,14
		db	B3,13
		db	G3,14
		db	E3,13
		db	F3,14
		db	D3,14
		db	E3,54
		db	D3,14
		db	E3,13
		db	F3,14
		db	G3,14
		db	D3,13
		db	E3,55
		db	D3,13
		db	E3,14
		db	F3,54
		db	E3,14
		db	F3,14
		db	G3,54
		db	F3,14
		db	G3,13
		db	A3,14
		db	F3,14
		db	A3,13
		db	B3,27
		db	D4,14
		db	END

SEQ142:		db	MANUAL,GLIOFF	;[MERM13A,2]
		DB    ENV,$47
		db	REST,14
		db	C3,14
		db	D3,13
		db	E3,28
		db	C3,13
		db	D3,27
		db	B2,14
		db	D3,27
		db	B2,14
		db	C3,27
		db	B2,14
		db	C3,27
		db	G2,14
		db	B2,40
		db	G2,28
		db	B2,13
		db	C3,14
		db	B2,13
		db	C3,14
		db	G2,41
		db	A2,14
		db	C3,13
		db	A2,14
		db	C3,27
		db	D3,14
		db	E3,13
		db	D3,14
		db	E3,13
		db	C3,41
		db	D3,41
		db	G3,27
		db	F3,14
		db	END

SEQ143:		db	MANUAL,GLIOFF	;[MERM13A,3]
		DB    ENV,$56
		db	C2,28
		db	G2,13
		db	C2,41
		db	G1,27
		db	D2,14
		db	G2,41
		db	C2,27
		db	G2,14
		db	G1,27
		db	C2,14
		db	G2,40
		db	B1,28
		db	G1,13
		db	C2,27
		db	G1,14
		db	C2,41
		db	F2,27
		db	C2,14
		db	A2,27
		db	F2,14
		db	C2,40
		db	E2,28
		db	C2,13
		db	G1,41
		db	G2,41
		db	END

SEQ144:		db	MANUAL,GLIOFF	;[MERM13B,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	E4,28
		db	C4,13
		db	G3,41
		db	REST,14
		db	E4,13
		db	D4,14
		db	F4,14
		db	E4,13
		db	D4,14
		db	E4,54
		db	C4,14
		db	E4,14
		db	F4,40
		db	D4,41
		db	G4,55
		db	F4,13
		db	E4,14
		db	D4,41
		db	E4,41
		db	C4,81
		db	REST,14
		db	G3,14
		db	E3,13
		db	A3,14
		db	G3,13
		db	D4,14
		db	END

SEQ145:		db	MANUAL,GLIOFF	;[MERM13B,2]
		DB    ENV,$47
		db	C3,28
		db	E3,13
		db	C3,14
		db	D3,14
		db	E3,13
		db	F3,41
		db	A3,27
		db	F3,14
		db	C3,27
		db	B2,14
		db	A2,68
		db	D3,13
		db	B2,41
		db	REST,14
		db	E3,13
		db	F3,14
		db	G3,41
		db	A3,41
		db	B3,27
		db	F3,14
		db	E3,27
		db	F3,13
		db	G3,14
		db	F3,14
		db	E3,13
		db	D3,28
		db	C3,13
		db	D3,27
		db	B2,14
		db	END

SEQ146:		db	MANUAL,GLIOFF	;[MERM13B,3]
		DB    ENV,$56
		db	A2,21
		db	REST,7
		db	A2,13
		db	E2,14
		db	B1,14
		db	C2,13
		db	D2,27
		db	A1,14
		db	D2,14
		db	F2,13
		db	A2,14
		db	A1,27
		db	B1,14
		db	C2,27
		db	A2,14
		db	D2,40
		db	G1,41
		db	C2,27
		db	D2,14
		db	E2,27
		db	C2,14
		db	F2,27
		db	A2,14
		db	G2,41
		db	C2,27
		db	D2,13
		db	E2,14
		db	D2,14
		db	C2,13
		db	G1,41
		db	B1,14
		db	D2,13
		db	G2,14
		db	END

SEQ147:		db	MANUAL,GLIOFF	;[MERM14A,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,15
		db	C4,8
		db	REST,22
		db	A3,15
		db	C4,8
		db	REST,7
		db	C4,15
		db	D4,15
		db	C4,15
		db	A3,15
		db	C4,8
		db	REST,22
		db	A3,15
		db	B3,15
		db	C4,15
		db	DS4,15
		db	E4,15
		db	A3,15
		db	C4,8
		db	REST,22
		db	B3,15
		db	C4,15
		db	D4,15
		db	C4,15
		db	B3,15
		db	A3,45
		db	C4,15
		db	B3,30
		db	GS3,23
		db	REST,7 ;filler
		db	END

SEQ148:		db	MANUAL,GLIOFF	;[MERM14A,2]
		DB    ENV,$57
		db	REST,15
		db	E2,8
		db	REST,7
		db	C3,8
		db	REST,7
		db	E3,8
		db	REST,22
		db	E3,15
		db	A2,30
		db	REST,15
		db	A2,8
		db	REST,7
		db	E3,8
		db	REST,7
		db	C3,8
		db	REST,7
		db	DS3,30
		db	B2,23
		db	REST,22
		db	E3,8
		db	REST,7
		db	A2,8
		db	REST,7
		db	G2,8
		db	REST,22
		db	B2,15
		db	A2,30
		db	REST,15
		db	C3,8
		db	REST,7
		db	D3,8
		db	REST,7
		db	E3,8
		db	REST,7
		db	D3,30
		db	E3,23
		db	REST,7 ;filler
		db	END

SEQ149:		db	MANUAL,GLIOFF	;[MERM14A,3]
		DB    ENV,$76
		db	A1,15
		db	REST,30
		db	C2,15
		db	E2,8
		db	REST,52
		db	C2,15
		db	REST,30
		db	E2,15
		db	B1,15
		db	REST,15
		db	GS2,15
		db	REST,15
		db	A2,15
		db	REST,30
		db	E2,15
		db	A1,15
		db	REST,15
		db	E2,15
		db	REST,15
		db	A2,15
		db	REST,15
		db	C2,15
		db	REST,15
		db	GS2,15
		db	REST,15
		db	E2,15
		db	D2,15
		db	END

SEQ150:		db	MANUAL,GLIOFF	;[MERM14B,1]
		DB	WAVE
		DB    $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB    $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB    ENV,%10111111
		db	A3,15
		db	C4,8
		db	REST,22
		db	E4,15
		db	F4,30
		db	E4,15
		db	D4,15
		db	C4,15
		db	E4,8
		db	REST,22
		db	C4,15
		db	B3,30
		db	D4,30
		db	C4,15
		db	E4,15
		db	C4,30
		db	B3,15
		db	D4,15
		db	B3,30
		db	A3,60
		db	GS3,30
		db	B3,30
		db	END

SEQ151:		db	MANUAL,GLIOFF	;[MERM14B,2]
		DB    ENV,$57
		db	REST,15
		db	E3,15
		db	A2,30
		db	REST,15
		db	D3,15
		db	F3,30
		db	REST,15
		db	C3,15
		db	A2,30
		db	REST,15
		db	D3,15
		db	FS3,30
		db	A3,15
		db	C4,15
		db	A3,30
		db	GS3,15
		db	B3,15
		db	GS3,30
		db	REST,15
		db	E3,15
		db	D3,15
		db	C3,15
		db	B2,30
		db	D3,30
		db	END

SEQ152:		db	MANUAL,GLIOFF	;[MERM14B,3]
		DB	ENV,$76
		db	C2,15
		db	REST,30
		db	A1,15
		db	D2,15
		db	REST,45
		db	A1,15
		db	REST,30
		db	E2,15
		db	FS2,15
		db	REST,15
		db	B1,15
		db	REST,15
		db	E2,15
		db	REST,30
		db	A1,15
		db	E2,15
		db	REST,45
		db	A2,15
		db	REST,30
		db	A2,15
		db	E2,15
		db	REST,15
		db	GS1,15
		db	REST,15 ;filler
		db	END

SEQ153:		db	MANUAL,GLIOFF	;[MERM14C,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	CS4,15
		db	A3,15
		db	CS4,30
		db	REST,15
		db	B3,15
		db	GS3,15
		db	B3,15
		db	A3,15
		db	FS3,15
		db	A3,30
		db	REST,15
		db	GS3,15
		db	E3,15
		db	GS3,15
		db	FS3,15
		db	A3,8
		db	REST,22
		db	FS3,15
		db	E3,30
		db	A3,30
		db	B3,45
		db	A3,15
		db	GS3,53
		db	REST,7 ;filler
		db	END

SEQ154:		db	MANUAL,GLIOFF	;[MERM14C,2]
		DB	ENV,$57
		db	REST,15
		db	CS3,15
		db	E3,15
		db	A3,15
		db	E3,60
		db	REST,15
		db	A2,15
		db	CS3,15
		db	FS3,15
		db	B2,60
		db	REST,15
		db	FS2,15
		db	A2,15
		db	D3,15
		db	CS3,53
		db	REST,7
		db	D3,45
		db	FS3,15
		db	D3,30
		db	B2,23
		db	REST,7 ;filler
		db	END

SEQ155:		db	MANUAL,GLIOFF	;[MERM14C,3]
		DB	ENV,$76
		db	A1,45
		db	E2,15
		db	GS2,30
		db	E2,30
		db	FS2,45
		db	CS2,15
		db	E2,30
		db	GS2,15
		db	B1,15
		db	D2,30
		db	CS2,15
		db	B1,15
		db	A1,30
		db	E2,15
		db	A1,15
		db	B1,60
		db	E2,60
		db	END


SEQ156:		db	MANUAL,GLIOFF	;[MERM15A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	E4,12
		db	DS4,12
		db	D4,12
		db	AS3,12
		db	D4,12
		db	CS4,11
		db	C4,12
		db	GS3,12
		db	C4,12
		db	B3,12
		db	AS3,12
		db	FS3,11
		db	AS3,12
		db	A3,12
		db	DS3,12
		db	F3,12
		db	E3,35
		db	G3,12
		db	AS3,36
		db	A3,11
		db	G3,36
		db	A3,12
		db	AS3,12
		db	C4,11
		db	CS4,12
		db	DS4,12
		db	E4,12
		db	DS4,12
		db	D4,12
		db	AS3,11
		db	D4,12
		db	CS4,12
		db	C4,12
		db	GS3,12
		db	C4,12
		db	B3,11
		db	AS3,12
		db	FS3,12
		db	AS3,12
		db	A3,12
		db	AS3,12
		db	B3,11
		db	C4,36
		db	B3,12
		db	A3,35
		db	B3,12
		db	C4,36
		db	D4,11
		db	DS4,24
		db	B3,12
		db	REST,12 ;filler
		db	END

SEQ157:		db	MANUAL,GLIOFF	;[MERM15A,2]
		DB	ENV,$37
		db	G3,36
		db	FS3,12
		db	E3,41
		db	REST,6
		db	E3,36
		db	D3,11
		db	G2,48
		db	B2,35
		db	E3,12
		db	G3,36
		db	FS3,11
		db	E3,36
		db	FS3,12
		db	G3,41
		db	REST,6
		db	B3,36
		db	G3,11
		db	FS3,36
		db	D3,12
		db	G3,35
		db	B2,12
		db	G2,36
		db	FS2,11
		db	E2,12
		db	F2,12
		db	FS2,12
		db	G2,12
		db	C3,12
		db	CS3,11
		db	D3,12
		db	DS3,12
		db	E3,12
		db	F3,12
		db	FS3,12
		db	G3,11
		db	FS3,36
		db	E3,12
		db	END

SEQ158:		db	MANUAL,GLIOFF	;[MERM15A,3]
		DB	ENV,$57
		db	E2,36
		db	DS2,12
		db	G2,23
		db	E2,24
		db	G2,36
		db	B1,11
		db	E2,24
		db	A2,24
		db	G2,12
		db	E2,11
		db	FS2,12
		db	G2,12
		db	E2,12
		db	CS2,12
		db	D2,12
		db	DS2,11
		db	E2,36
		db	DS2,12
		db	E2,41
		db	REST,6
		db	G2,36
		db	E2,11
		db	A2,36
		db	F2,12
		db	E2,35
		db	DS2,12
		db	E2,36
		db	D2,11
		db	A1,36
		db	C2,12
		db	E2,35
		db	FS2,12
		db	A2,36
		db	FS2,11
		db	B1,36
		db	FS2,12
		db	END

SEQ159:		db	MANUAL,GLIOFF	;[MERM15B,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	C4,12
		db	B3,12
		db	A3,36
		db	B3,11
		db	A3,12
		db	G3,12
		db	FS3,12
		db	G3,12
		db	A3,18
		db	REST,5
		db	A3,12
		db	B3,12
		db	C4,24
		db	E4,12
		db	C4,11
		db	B3,12
		db	A3,12
		db	C4,12
		db	B3,12
		db	A3,12
		db	G3,11
		db	B3,12
		db	A3,12
		db	G3,12
		db	FS3,12
		db	A3,12
		db	G3,11
		db	FS3,12
		db	G3,12
		db	E3,36
		db	G3,11
		db	B3,36
		db	G3,12
		db	A3,35
		db	B3,12
		db	C4,36
		db	A3,11
		db	B3,36
		db	C4,12
		db	B3,35
		db	C4,12
		db	B3,12
		db	C4,12
		db	B3,12
		db	A3,11
		db	G3,12
		db	A3,12
		db	G3,12
		db	FS3,12
		db	E3,71
		db	G3,12
		db	AS3,11
		db	B3,48
		db	DS4,41
		db	REST,6 ;filler
		db	END

SEQ160:		db	MANUAL,GLIOFF	;[MERM15B,2]
		DB	ENV,$37
		db	E3,36
		db	D3,12
		db	C3,35
		db	E3,12
		db	D3,24
		db	D3,12
		db	C3,11
		db	E3,48
		db	C3,35
		db	D3,12
		db	E3,36
		db	D3,11
		db	C3,36
		db	B2,12
		db	C3,35
		db	REST,12
		db	B2,12
		db	D3,12
		db	C3,12
		db	B2,11
		db	G2,12
		db	G3,12
		db	FS3,12
		db	E3,12
		db	C3,12
		db	E3,11
		db	D3,12
		db	C3,12
		db	A2,12
		db	A3,12
		db	G3,12
		db	FS3,11
		db	DS3,36
		db	E3,12
		db	DS3,35
		db	E3,12
		db	DS3,12
		db	E3,12
		db	DS3,12
		db	C3,11
		db	B2,12
		db	C3,12
		db	B2,12
		db	DS3,12
		db	G2,35
		db	A2,12
		db	B2,36
		db	E3,11
		db	DS3,24
		db	A2,24
		db	B2,41
		db	REST,6 ;filler
		db	END

SEQ161:		db	MANUAL,GLIOFF	;[MERM15B,3]
		DB	ENV,$57
		db	A1,36
		db	F2,12
		db	E2,47
		db	A2,36
		db	E2,11
		db	C2,24
		db	A1,24
		db	A2,35
		db	F2,12
		db	A2,36
		db	B2,11
		db	E2,36
		db	D2,12
		db	E2,23
		db	D2,12
		db	C2,12
		db	G2,36
		db	D2,11
		db	E2,48
		db	A1,35
		db	G2,12
		db	E2,24
		db	C2,23
		db	B1,36
		db	G2,12
		db	FS2,35
		db	G2,12
		db	FS2,47
		db	B1,48
		db	E2,47
		db	G2,24
		db	E2,23
		db	FS2,24
		db	DS2,24
		db	B1,23
		db	FS2,24
		db	END

SEQ162:		db	MANUAL,GLIOFF	;[MERM16A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	B3,15
		db	FS3,7
		db	REST,7
		db	FS3,14
		db	B3,15
		db	D4,43
		db	B3,14
		db	AS3,43
		db	FS3,14
		db	G3,43
		db	E3,14
		db	FS3,14
		db	B3,15
		db	CS4,14
		db	D4,14
		db	CS4,15
		db	B3,14
		db	G3,14
		db	FS3,14
		db	AS3,43
		db	G3,15
		db	D4,14
		db	C4,14
		db	AS3,14
		db	A3,15
		db	G3,14
		db	FS3,14
		db	G3,15
		db	A3,14
		db	AS3,14
		db	A3,14
		db	AS3,15
		db	C4,14
		db	D4,43
		db	B3,14
		db	FS4,43
		db	E4,14
		db	D4,15
		db	CS4,14
		db	B3,14
		db	AS3,14
		db	G3,15
		db	FS3,14
		db	E3,14
		db	D3,15
		db	CS3,43
		db	E3,14
		db	G3,28
		db	AS3,22
		db	REST,7
		db	A3,14
		db	D4,7
		db	REST,8
		db	D4,14
		db	A3,14
		db	AS3,43
		db	G3,14
		db	A3,43
		db	F3,14
		db	E3,43
		db	CS3,15
		db	D3,42
		db	FS3,15
		db	D4,28
		db	CS4,29
		db	B3,57
		db	FS3,57
		db	END


SEQ163:		db	MANUAL,GLIOFF	;[MERM16A,2]
		db	ENV,$47
		db	REST,15
		db	D3,7
		db	REST,7
		db	D3,14
		db	FS3,15
		db	B2,28
		db	FS3,29
		db	E3,28
		db	CS3,29
		db	E3,29
		db	AS2,28
		db	D3,29
		db	E3,28
		db	FS3,29
		db	B2,28
		db	REST,15
		db	D3,7
		db	REST,7
		db	D3,14
		db	AS2,15
		db	G2,28
		db	D3,72
		db	AS2,14
		db	CS3,28
		db	AS2,29
		db	REST,14
		db	FS3,7
		db	REST,8
		db	FS3,14
		db	D3,14
		db	B3,29
		db	D3,28
		db	B2,29
		db	D3,28
		db	AS2,29
		db	G2,29
		db	E2,28
		db	G2,29
		db	A2,28
		db	CS3,29
		db	REST,14
		db	F3,7
		db	REST,8
		db	F3,14
		db	D3,7
		db	REST,7
		db	D3,29
		db	AS2,28
		db	D3,29
		db	A2,28
		db	G2,29
		db	AS2,29
		db	REST,14
		db	FS2,7
		db	REST,7
		db	FS2,14
		db	D3,15
		db	B2,28
		db	AS2,29
		db	REST,14
		db	CS3,14
		db	D3,15
		db	E3,14
		db	REST,14
		db	CS3,15
		db	B2,14
		db	AS2,14
		db	END


SEQ164:		db	MANUAL,GLIOFF	;[MERM16A,3]
		db	ENV,$67
		db	B1,43
		db	D2,15
		db	FS2,28
		db	D2,29
		db	FS2,43
		db	CS2,14
		db	FS1,57
		db	B1,29
		db	CS2,28
		db	D2,43
		db	FS1,14
		db	G1,29
		db	D2,29
		db	AS1,28
		db	G2,29
		db	AS2,28
		db	G2,29
		db	FS2,14
		db	E2,14
		db	D2,15
		db	CS2,14
		db	B1,43
		db	FS2,14
		db	D2,29
		db	B1,28
		db	FS1,29
		db	B1,28
		db	E2,29
		db	AS1,29
		db	A1,57
		db	CS2,28
		db	E2,15
		db	A1,14
		db	D2,43
		db	F2,14
		db	G2,29
		db	D2,28
		db	F2,29
		db	D2,28
		db	CS2,29
		db	FS2,29
		db	B1,57
		db	FS2,28
		db	FS1,29
		db	B1,43
		db	CS2,14
		db	D2,43
		db	FS2,14
		db	END


SEQ165:		db	MANUAL,GLIOFF	;[MERM16B,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	G3,15
		db	FS3,14
		db	G3,14
		db	A3,15
		db	B3,43
		db	G3,14
		db	E4,43
		db	D4,14
		db	CS4,43
		db	AS3,14
		db	G3,43
		db	F3,14
		db	E3,43
		db	D3,14
		db	G3,15
		db	A3,14
		db	AS3,14
		db	C4,15
		db	D4,42
		db	C4,15
		db	AS3,14
		db	F3,7
		db	REST,7
		db	F3,15
		db	AS3,14
		db	CS4,43
		db	C4,14
		db	AS3,43
		db	F3,14
		db	FS3,43
		db	DS3,14
		db	F3,43
		db	D3,14
		db	A3,43
		db	F3,15
		db	CS4,43
		db	A3,14
		db	D4,14
		db	A3,7
		db	REST,7
		db	A3,15
		db	D4,14
		db	END


SEQ166:		db	MANUAL,GLIOFF	;[MERM16B,2]
		db	ENV,$47
		db	B2,15
		db	A2,14
		db	B2,14
		db	CS3,15
		db	E3,43
		db	B2,14
		db	G3,43
		db	A3,14
		db	G3,43
		db	FS3,14
		db	AS2,43
		db	A2,14
		db	G2,43
		db	AS2,14
		db	D3,15
		db	CS3,14
		db	D3,14
		db	E3,15
		db	AS3,28
		db	E3,29
		db	REST,14
		db	CS3,7
		db	REST,7
		db	CS3,15
		db	F3,14
		db	AS3,28
		db	CS3,29
		db	F3,43
		db	CS3,14
		db	AS2,36
		db	REST,7
		db	AS2,14
		db	A2,43
		db	F2,14
		db	D3,43
		db	A2,15
		db	G3,43
		db	C3,14
		db	F3,28
		db	D3,29
		db	END


SEQ167:		db	MANUAL,GLIOFF	;[MERM16B,3]
		db	ENV,$67
		db	E2,43
		db	B1,15
		db	G2,28
		db	E2,29
		db	B1,28
		db	G2,15
		db	FS2,14
		db	E2,29
		db	D2,28
		db	G2,43
		db	D2,14
		db	AS1,29
		db	G1,28
		db	AS1,43
		db	D2,15
		db	G1,28
		db	A1,29
		db	AS1,43
		db	CS2,14
		db	F2,28
		db	AS1,29
		db	CS2,29
		db	AS1,28
		db	DS2,29
		db	CS2,28
		db	D2,57
		db	F2,29
		db	D2,29
		db	E2,28
		db	A1,29
		db	D2,28
		db	F2,29
		db	END


SEQ168:		db	MANUAL,GLIOFF	;[MERM17A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	D4,22
		db	REST,7
		db	A3,7
		db	REST,7
		db	A3,15
		db	C4,7
		db	REST,7
		db	C4,14
		db	REST,15
		db	A3,14
		db	D4,7
		db	REST,7
		db	D4,14
		db	REST,15
		db	A3,14
		db	F4,7
		db	REST,7
		db	F4,15
		db	E4,14
		db	C4,14
		db	D4,29
		db	REST,14
		db	A3,14
		db	C4,7
		db	REST,8
		db	C4,14
		db	D4,14
		db	E4,14
		db	F4,8
		db	REST,7
		db	F4,14
		db	REST,14
		db	F4,15
		db	E4,7
		db	REST,7
		db	E4,14
		db	CS4,14
		db	A3,15
		db	END


SEQ169:		db	MANUAL,GLIOFF	;[MERM17A,2]
		db	ENV,$57
		db	F3,36
		db	REST,7
		db	F3,15
		db	E3,7
		db	REST,7
		db	E3,14
		db	REST,15
		db	E3,14
		db	F3,7
		db	REST,7
		db	F3,14
		db	REST,15
		db	F3,14
		db	D3,43
		db	E3,14
		db	F3,29
		db	REST,14
		db	F3,14
		db	E3,7
		db	REST,8
		db	E3,14
		db	F3,14
		db	G3,14
		db	A3,8
		db	REST,7
		db	A3,14
		db	REST,14
		db	A3,15
		db	CS4,7
		db	REST,7
		db	CS4,14
		db	G3,14
		db	E3,15
		db	END


SEQ170:		db	MANUAL,GLIOFF	;[MERM17A,3]
		db	ENV,$77
		db	D2,29
		db	A1,14
		db	D2,15
		db	C2,28
		db	A1,29
		db	D2,28
		db	A1,15
		db	D2,14
		db	AS1,29
		db	C2,28
		db	D2,29
		db	A1,14
		db	D2,14
		db	C2,43
		db	A1,14
		db	D2,29
		db	A2,14
		db	D2,15
		db	A1,28
		db	E2,14
		db	CS2,15
		db	END


SEQ171:		db	MANUAL,GLIOFF	;[MERM17B,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	AS3,15
		db	A3,14
		db	AS3,14
		db	A3,15
		db	G3,28
		db	AS3,15
		db	A3,14
		db	AS3,14
		db	A3,14
		db	G3,22
		db	REST,7
		db	G3,14
		db	F3,15
		db	G3,14
		db	A3,14
		db	AS3,14
		db	A3,15
		db	AS3,14
		db	A3,14
		db	G3,15
		db	A3,14
		db	AS3,14
		db	C4,14
		db	CS4,29
		db	A3,7
		db	REST,7
		db	A3,15
		db	AS3,7
		db	REST,7
		db	AS3,14
		db	G3,29
		db	A3,14
		db	AS3,14
		db	A3,15
		db	G3,14
		db	A3,14
		db	AS3,14
		db	C4,15
		db	CS4,14
		db	D4,43
		db	A3,14
		db	AS3,14
		db	A3,15
		db	G3,28
		db	A3,15
		db	AS3,14
		db	A3,14
		db	G3,14
		db	F3,29
		db	A3,29
		db	END


SEQ172:		db	MANUAL,GLIOFF	;[MERM17B,2]
		db	ENV,$47
		db	G3,15
		db	F3,14
		db	G3,14
		db	F3,15
		db	AS2,28
		db	G3,15
		db	F3,14
		db	G3,14
		db	F3,14
		db	AS2,22
		db	REST,7
		db	AS2,14
		db	A2,15
		db	AS2,14
		db	C3,14
		db	D3,14
		db	C3,15
		db	D3,14
		db	C3,14
		db	AS2,15
		db	C3,14
		db	D3,14
		db	F3,14
		db	E3,43
		db	F3,15
		db	G3,14
		db	D3,14
		db	E3,29
		db	CS3,43
		db	E3,14
		db	CS3,43
		db	E3,14
		db	F3,36
		db	REST,7
		db	F3,14
		db	G3,14
		db	F3,15
		db	D3,28
		db	CS3,43
		db	E3,14
		db	D3,29
		db	CS3,29
		db	END


SEQ173:		db	MANUAL,GLIOFF	;[MERM17B,3]
		db	ENV,$77
		db	G2,36
		db	REST,7
		db	AS1,15
		db	D2,43
		db	G2,14
		db	D2,43
		db	G2,14
		db	D2,43
		db	F2,14
		db	G2,43
		db	F2,14
		db	G2,15
		db	F2,14
		db	G2,14
		db	D2,14
		db	A2,29
		db	CS2,14
		db	D2,15
		db	E2,42
		db	AS2,15
		db	A2,43
		db	CS2,14
		db	E2,43
		db	G2,14
		db	A2,29
		db	D2,28
		db	G2,29
		db	AS2,28
		db	A2,29
		db	E2,14
		db	CS2,14
		db	A1,29
		db	A2,29
		db	END


SEQ174:		db	MANUAL,GLIOFF	;[MERM18A,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	D4,30
		db	AS3,15
		db	D4,15
		db	CS4,15
		db	AS3,15
		db	F3,30
		db	G3,45
		db	A3,15
		db	AS3,15
		db	A3,15
		db	G3,30
		db	REST,15
		db	D4,15
		db	AS3,15
		db	D4,15
		db	CS4,15
		db	A3,15
		db	FS3,15
		db	A3,15
		db	G3,45
		db	D4,15
		db	AS3,30
		db	G3,30
		db	C4,45
		db	AS3,15
		db	A3,45
		db	G3,15
		db	FS3,45
		db	A3,15
		db	D3,30
		db	A3,15
		db	AS3,15
		db	C4,45
		db	AS3,15
		db	A3,30
		db	G3,15
		db	A3,15
		db	FS3,45
		db	DS4,15
		db	D4,15
		db	C4,15
		db	AS3,15
		db	A3,15
		db	END


SEQ175:		db	MANUAL,GLIOFF	;[MERM18A,2]
		db	ENV,$57
		db	AS2,38
		db	REST,7
		db	C3,15
		db	F3,30
		db	CS3,30
		db	AS2,45
		db	F3,15
		db	G3,15
		db	F3,15
		db	AS2,30
		db	D3,30
		db	G3,15
		db	AS3,15
		db	A3,15
		db	FS3,15
		db	CS3,15
		db	FS3,15
		db	AS2,45
		db	A2,15
		db	G2,30
		db	AS2,30
		db	DS3,45
		db	G3,15
		db	F3,45
		db	C3,15
		db	A2,45
		db	C3,15
		db	A2,30
		db	FS3,30
		db	DS3,45
		db	G3,15
		db	F3,30
		db	DS3,30
		db	C3,45
		db	G3,15
		db	FS3,15
		db	DS3,15
		db	D3,15
		db	C3,15
		db	END


SEQ176:		db	MANUAL,GLIOFF	;[MERM18A,3]
		db	ENV,$77
		db	G1,45
		db	A1,15
		db	AS1,60
		db	G1,30
		db	AS1,30
		db	D2,60
		db	G2,30
		db	AS2,15
		db	G2,15
		db	FS2,60
		db	G2,45
		db	F2,15
		db	DS2,30
		db	D2,30
		db	C2,45
		db	D2,15
		db	DS2,60
		db	D2,30
		db	A1,30
		db	D2,60
		db	C2,45
		db	D2,15
		db	DS2,30
		db	C2,30
		db	D2,120
		db	END


SEQ177:		db	MANUAL,GLIOFF	;[MERM18B,1]
		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%10111111
		db	G3,45
		db	FS3,15
		db	E3,45
		db	B3,15
		db	A3,15
		db	G3,15
		db	FS3,15
		db	E3,15
		db	DS3,15
		db	FS3,15
		db	E3,15
		db	C3,15
		db	B2,45
		db	E3,15
		db	G3,45
		db	B3,15
		db	A3,45
		db	C4,15
		db	B3,15
		db	A3,15
		db	G3,15
		db	FS3,15
		db	G3,45
		db	FS3,15
		db	E3,45
		db	B3,15
		db	C4,45
		db	B3,15
		db	A3,30
		db	G3,15
		db	A3,15
		db	B3,15
		db	G3,15
		db	B3,30
		db	FS3,15
		db	DS3,15
		db	FS3,30
		db	E3,45
		db	FS3,15
		db	G3,15
		db	A3,15
		db	AS3,15
		db	C4,15
		db	END


SEQ178:		db	MANUAL,GLIOFF	;[MERM18B,2]
		db	ENV,$57
		db	B2,30
		db	C3,15
		db	D3,15
		db	G2,15
		db	B2,15
		db	E3,30
		db	C3,15
		db	B2,15
		db	A2,15
		db	G2,15
		db	FS2,15
		db	A2,15
		db	G2,15
		db	A2,15
		db	G2,30
		db	A2,15
		db	B2,15
		db	E3,15
		db	D3,15
		db	B2,30
		db	DS3,45
		db	A3,15
		db	G3,15
		db	FS3,15
		db	E3,15
		db	DS3,15
		db	B2,45
		db	D3,15
		db	G2,45
		db	G3,15
		db	E3,45
		db	D3,15
		db	C3,60
		db	G2,60
		db	A2,60
		db	G2,45
		db	D3,15
		db	B2,30
		db	FS3,30
		db	END


SEQ179:		db	MANUAL,GLIOFF	;[MERM18B,3]
		db	ENV,$77
		db	E2,45
		db	G2,15
		db	B1,60
		db	E2,30
		db	D2,15
		db	C2,15
		db	B1,30
		db	C2,15
		db	D2,15
		db	E2,45
		db	G2,15
		db	B2,30
		db	E2,30
		db	B1,60
		db	DS2,30
		db	B1,30
		db	E2,45
		db	G2,15
		db	B1,30
		db	E2,30
		db	A2,30
		db	G2,15
		db	FS2,15
		db	E2,30
		db	A2,30
		db	E2,60
		db	B1,60
		db	E2,45
		db	B1,15
		db	E2,30
		db	D2,30
		db	END


		ELSE

SEQ60:
SEQ61:
SEQ62:
SEQ63:
SEQ64:
SEQ65:
SEQ66:
SEQ67:
SEQ68:
SEQ69:
SEQ70:
SEQ71:
SEQ72:
SEQ73:
SEQ74:
SEQ75:
SEQ76:
SEQ77:
SEQ78:
SEQ79:
SEQ80:
SEQ81:
SEQ82:
SEQ84:
SEQ85:
SEQ86:
SEQ87:
SEQ88:
SEQ89:
SEQ90:
SEQ91:
SEQ92:
SEQ93:
SEQ94:
SEQ95:
SEQ96:
SEQ97:
SEQ98:
SEQ99:
SEQ100:
SEQ101:
SEQ102:
SEQ103:
SEQ104:
SEQ105:
SEQ106:
SEQ107:
SEQ108:
SEQ109:
SEQ110:
SEQ115:
SEQ116:
SEQ117:
SEQ118:
SEQ119:
SEQ120:
SEQ121:
SEQ122:
SEQ123:
SEQ124:


SEQ125:
SEQ126:
SEQ127:
SEQ128:
SEQ129:
SEQ130:
SEQ131:
SEQ132:
SEQ141:
SEQ142:
SEQ143:
SEQ144:
SEQ145:
SEQ146:
SEQ147:
SEQ148:
SEQ149:
SEQ150:
SEQ151:
SEQ152:
SEQ153:
SEQ154:
SEQ155:
SEQ156:
SEQ157:
SEQ158:
SEQ159:
SEQ160:
SEQ161:
SEQ162:
SEQ163:
SEQ164:
SEQ165:
SEQ166:
SEQ167:
SEQ168:
SEQ169:
SEQ170:
SEQ171:
SEQ172:
SEQ173:
SEQ174:
SEQ175:
SEQ176:
SEQ177:
SEQ178:
SEQ179:

		ENDC



;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------

;----------------------------------------------------------------------------------
;MERMAID 2 SONG LIST STARTS HERE - SEE BELOW - NOTE: MELODY IS TRACK 3,BASS=TRACK 1
;----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;MERMAID2/22 DITTY 01 / game won / level complete #1
;-----------------------------------------------------------------------------

DITTY011:	db	42  
		DB	127
		DB	END

DITTY012:	db	126
		DB	END

DITTY013:	db	TRANS,12,125
		DB	END

DITTY014:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/24 DITTY 03A / LEVEL-ADVANCE (looping) - lo-cal version
;-----------------------------------------------------------------------------

DITTY03A1:	DB	42
		DB	END

DITTY03A2:	DB	LOOP,255,132
		DB	END

DITTY03A3:	DB	LOOP,255,TRANS,12,131
		DB	END

DITTY03A4:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/29 MAIN THEME 1 "TITLE-SCREEN-MENU" OR "TABLE 1" (a la "For A Moment")
;-----------------------------------------------------------------------------

		IF	OLD1

MERM011:
		DB	42
;		DB	5
.top:		DB	9
		DB	JUMP
		DW	.top
MERM012:
;		DB	4
.top:		DB	8
		DB	JUMP
		DW	.top
MERM013:
;		DB	TRANS,12,3
.top:		DB	TRANS,12,7
		DB	JUMP
		DW	.top
		DB	END
		
MERM014:	DB	END

		ELSE
MERM011:
		db	42
		db	112
.top:		db	133,136,139
		db	JUMP
		dw	.top

MERM012:
		db	113
.top:		db	134,137,140
		db	JUMP
		dw	.top
MERM013:
		db	TRANS,12,111
.top:		db	TRANS,12,114
		db	TRANS,12,135
		db	TRANS,12,138
		db	JUMP
		dw	.top

MERM014:
		db	END
		ENDC


NEW11:
		DB	42
.top:
		DB	97,97,100,100,103,103,106,109
		DB	JUMP
		DW	.top
NEW12:
.top:
		DB	98,98,101,101,104,104,107,110
		DB	JUMP
		DW	.top
NEW13:
.top:
		DB	TRANS,12
		DB	96
		DB	TRANS,12
		DB	96
		DB	TRANS,12
		DB	99
		DB	TRANS,12
		DB	99
		DB	TRANS,12
		DB	102
		DB	TRANS,12
		DB	102
		DB	TRANS,12
		DB	105
		DB	TRANS,12
		DB	108
		DB	JUMP
		DW	.top
		
NEW14:		db	END

;----------------------------------+-------------------------------------------
;MERMAID2/30 MAIN THEME 2 / "TABLE 2" (a la "Down To The Sea")
;-----------------------------------------------------------------------------
		

MERM021:	db	42
		DB	12,LOOP,255,15
		DB	END

MERM022:	db	11,LOOP,255,14
		DB	END

MERM023:
		DB	TRANS,12,10,TRANS,12,LOOP,255,13
		DB	END

MERM024:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/31 "STORM" SUB-GAME (SAILOR THEME)
;-----------------------------------------------------------------------------
	
MERM031:	db	42
		DB	LOOP,255,18
		DB	END

MERM032:	db	LOOP,255,17
		DB	END

MERM033:	db	LOOP,255,TRANS,12,16
		DB	END
		

MERM034:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/32 "POLAR BEAR" SUB-GAME (REGGAE)
;-----------------------------------------------------------------------------
		

MERM041:	db	42
		DB	LOOP,255,21 
		DB	END

MERM042:	db	LOOP,255,20
		DB	END

MERM043:	db	LOOP,255,TRANS,12,19
		DB	END
		

MERM044:	db	LOOP,255,22  
		DB	END
		

;-----------------------------------------------------------------------------
;MERMAID2/33 "ICE BLOCKS" (QUIRKY)
;-----------------------------------------------------------------------------


MERM051:	db	42
		DB	LOOP,255,25
		DB	END

MERM052:	db	LOOP,255,24
		DB	END

MERM053:	db	LOOP,255,TRANS,12,23
		DB	END
		

MERM054:	db	LOOP,255,26
		DB	END
		

;-----------------------------------------------------------------------------
;MERMAID2/34 "CLAMS" SUB-GAME (QUIRKY)
;-----------------------------------------------------------------------------

MERM061:	db	42
		DB	43,LOOP,255,46
		DB	END

MERM062:	db	41,LOOP,255,45
		DB	END

MERM063:	db	TRANS,12,40,TRANS,12,LOOP,255,TRANS,12,44
		DB	END
		

MERM064:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/35 "SCUTTLE" (CALYPSO)
;-----------------------------------------------------------------------------

MERM071:	db	42
		DB	49,LOOP,255,52
		DB	END

MERM072:	db	48,LOOP,255,51
		DB	END

MERM073:	db	47,LOOP,255,TRANS,12,50
		DB	END

MERM074:	db	END

;-----------------------------------------------------------------------------
;MERMAID2/36 "TRIDENT" (REGGAE)
;-----------------------------------------------------------------------------

MERM081:	db	42
		DB	TRANS,5,55,TRANS,5,LOOP,255,58
		DB	END

MERM082:	db	TRANS,5,54,TRANS,5,LOOP,255,57
		DB	END

MERM083:	db	TRANS,17,53,TRANS,17,LOOP,255,56
		DB	END

MERM084:	db	83,LOOP,255,59
		DB	END

;-----------------------------------------------------------------------------
;NEW2
;-----------------------------------------------------------------------------

NEW21:		DB	42
.top:
		DB	31,28,31 ;34,31
		DB	JUMP
		DW	.top
NEW22:
.top:
		DB	32,29,32 ;,35,32
		DB	JUMP
		DW	.top
NEW23:
.top:
		DB	TRANS,12
		DB	30
		DB	TRANS,12
		DB	27
		DB	TRANS,12
		DB	30
;		DB	TRANS,12
;		DB	33
;		DB	TRANS,12
;		DB	30
		DB	JUMP
		DW	.top
NEW24:		DB	END



;-----------------------------------------------------------------------------
;MERMAID2/37 "TREASURE HUNT" SUB-GAME (PLAYFUL)
;-----------------------------------------------------------------------------

MERM091:	db	42
		DB	62,62,65
		DB	JUMP
		DW	MERM091

MERM092:	db	61,61,64
		DB	JUMP
		DW	MERM092

MERM093:	db	TRANS,12,60,TRANS,12,60,TRANS,12,63
		DB	JUMP
		DW	MERM093

MERM094:	db	END
;-----------------------------------------------------------------------------
;MERMAID2/38 "FLOTSAM AND JETSAM" SUB-GAME (QUIRKY)
;-----------------------------------------------------------------------------

MERM101:	db	42
		DB	68,71,71,74
		DB	JUMP
		DW	MERM101

MERM102:	DB	67,70,70,73
		DB	JUMP
		DW	MERM102

MERM103:	DB	TRANS,12,66,TRANS,12,69,TRANS,12,69,TRANS,12,72
		DB	JUMP
		DW	MERM103

MERM104:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/39 "ICE PRISON" SUB-GAME (JAMAICAN)
;-----------------------------------------------------------------------------

MERM111:	DB	42
		DB	77,81,89,94
		DB	JUMP
		DW	MERM111

MERM112:	DB	76,80,88,93
		DB	JUMP
		DW	MERM112

MERM113:	DB	TRANS,12,75,TRANS,12,79,TRANS,12,87,TRANS,12,92
		DB	JUMP
		DW	MERM113

MERM114:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/40 "CLOAK AND DAGGER" SUB-GAME (QUIRKY)
;-----------------------------------------------------------------------------

MERM121:	DB	42
		DB	TRANS,5,116,TRANS,5,119,TRANS,5,123
		DB	JUMP
		DW	MERM121
		

MERM122:	DB	TRANS,5,115,TRANS,5,118,TRANS,5,122
		DB	JUMP
		DW	MERM122

MERM123:	DB	84,TRANS,17,117,TRANS,17,121
		DB	JUMP
		DW	MERM123

MERM124:	DB	84,120,124
		DB	JUMP
		DW	MERM124
		
;-----------------------------------------------------------------------------
;MERMAID2/41 "KISS THE GIRL" SUB-GAME (PLAYFUL)
;-----------------------------------------------------------------------------

MERM131:	DB	42
		DB	143,143,146
		DB	JUMP
		DW	MERM131

MERM132:	DB	142,142,145
		DB	JUMP
		DW	MERM132

MERM133:	DB	TRANS,12,141,TRANS,12,141,TRANS,12,144
		DB	JUMP
		DW	MERM133

MERM134:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/42 "FLOUNDER" SUB-GAME
;-----------------------------------------------------------------------------

MERM141:	DB	42
		DB	149,149,152,149,149,152,155,155
		DB	JUMP
		DW	MERM141

MERM142:	DB	148,148,151,148,148,151,154,154
		DB	JUMP
		DW	MERM142

MERM143:	DB	TRANS,12,147,TRANS,12,147,TRANS,12,150,TRANS,12,147,TRANS,12,147,TRANS,12,150,TRANS,12,153,TRANS,12,153
		DB	JUMP
		DW	MERM143

MERM144:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/43 "MORGANA" SUB-GAME
;-----------------------------------------------------------------------------

MERM151:	DB	42
		DB	158,158,161
		DB	JUMP
		DW	MERM151

MERM152:	DB	157,157,160
		DB	JUMP
		DW	MERM152

MERM153:	DB	TRANS,12,156,TRANS,12,156,TRANS,12,159
		DB	JUMP
		DW	MERM153

MERM154:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/44 "URSULA" SUB-GAME
;-----------------------------------------------------------------------------

MERM161:	DB	42
		DB	164,164,167
		DB	JUMP
		DW	MERM161

MERM162:	DB	163,163,166
		DB	JUMP
		DW	MERM162

MERM163:	DB	TRANS,12,162,TRANS,12,162,TRANS,12,165
		DB	JUMP
		DW	MERM163

MERM164:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/45 "VOLCANO" SUB-GAME
;-----------------------------------------------------------------------------

MERM171:	DB	42
		DB	170,170,173,170
		DB	JUMP
		DW	MERM171

MERM172:	DB	169,169,172,169
		DB	JUMP
		DW	MERM172

MERM173:	DB	TRANS,12,168,TRANS,12,168,TRANS,12,171,TRANS,12,168
		DB	JUMP
		DW	MERM173

MERM174:	DB	END

;-----------------------------------------------------------------------------
;MERMAID2/46 "LOST SOULS" SUB-GAME
;-----------------------------------------------------------------------------

MERM181:	DB	42
		DB	176,176,179
		DB	JUMP
		DW	MERM181

MERM182:	DB	175,175,178
		DB	JUMP
		DW	MERM182

MERM183:	DB	TRANS,12,174,TRANS,12,174,TRANS,12,177
		DB	JUMP
		DW	MERM183

MERM184:	DB	END


;-----------------------------------------------------------------------------

END_COD:

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF MUSIC DATA
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************




; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SOUND.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

