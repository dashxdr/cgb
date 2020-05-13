; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SOUND.ASM                                                      MODULE **
; **                                                                       **
; ** Sound driver and music data.                                          **
; **                                                                       **
; ** Last modified : 31 Oct 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"sound",CODE,BANK[5]
		section 5

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

KillAllSoundB::	CALL	KillSfxB
		CALL	KillTuneB

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

KillTuneB::	XOR	A
		LD	[wMzNumber],A

		JP	InitTuneB

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

KillSfxB::	XOR	A
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

InitTuneB::	OR	A			;
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
		ADD	A,LOW(TblMzTune)	;
		LD	E,A			;
		LD	A,H			;
		ADC	A,HIGH(TblMzTune)	;
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

InitMzChannel::	LD	A,[DE]			;Get the ptr to the sequence
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
		LD	A,LOW(DummyMzSeq)	;Initialize MZ_SEQ_CURR.
		LD	[HLI],A			;
		LD	A,HIGH(DummyMzSeq)	;
		LD	[HLI],A			;
		DEC	BC			;Initialize MZ_LST_CURR.
		LD	A,C			;
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,1			;Initialize MZ_SEQ_REPEAT.
		LD	[HLI],A			;

		LD	BC,MZ_AUTO_LEN-MZ_SEQ_TRAN
		ADD	HL,BC

		XOR	A			;Initialize MZ_AUTO_LEN.
		LD	[HLI],A			;
		INC	A			;
		LD	[HLI],A			;Initialize MZ_NOTE_LEN.
		LD	[HLI],A			;

		RET				;

DummyMzSeq::	DB	END			;



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

InitSfxB::	PUSH	AF

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
		ADD	A,LOW(TblFxList)	;
		LD	E,A			;
		LD	A,H			;
		ADC	A,HIGH(TblFxList)	;
		LD	D,A			;

		LD	HL,wFxChannel1+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel2+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel3+MZ_STATUS;
		CALL	InitFxChannel		;
		LD	HL,wFxChannel4+MZ_STATUS;

InitFxChannel::	LD	A,[DE]			;Get the ptr to the sequence
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
		ld	BC,DummyFxLst-1
		LD	A,C			;Initialize MZ_LST_CURR.
		LD	[HLI],A			;
		LD	A,B			;
		LD	[HLI],A			;
		LD	A,1			;Initialize MZ_SEQ_REPEAT.
		LD	[HLI],A			;

		LD	BC,MZ_AUTO_LEN-MZ_SEQ_TRAN
		ADD	HL,BC

		XOR	A			;Initialize MZ_AUTO_LEN.
		LD	[HLI],A			;
		INC	A			;
		LD	[HLI],A			;Initialize MZ_NOTE_LEN.
		LD	[HLI],A			;

		RET				;

DummyFxLst::	DB	END			;



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

PlayingSfxB::	LD	A,[wFxChannel1+MZ_STATUS]
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

MzRefresh::	LD	[wMzSP],SP

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
MzRefresh1a::	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh1b
		LDIO	[rNR12],A
		LDH	[hShadowNR12],A
MzRefresh1b::	LD	A,[HLI]
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
MzRefresh2a::	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh2b
		LDIO	[rNR22],A
		LDH	[hShadowNR22],A
MzRefresh2b::	LD	A,[HLI]
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
MzRefresh3a::	LD	A,[HLI]
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
MzRefresh3b::	LDH	A,[hShadowNR32]
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
MzRefresh4a::	LD	A,[HLI]
		CP	$FF
		JR	Z,MzRefresh4b
		LDIO	[rNR42],A
		LDH	[hShadowNR42],A
MzRefresh4b::	LD	A,[HLI]
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

Mz60Hz::	LDHL	SP,MZ_STATUS		;Test MZ_STATUS.
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

MzReadSeq::	LD	A,[DE]			;Get next note.
		INC	DE			;
		CP	JUMP			;Or is it a command ?
		JP	C,MzNewNote		;

;
; Process command.
;

MzCommand::	SUB	JUMP
		ADD	A,LOW(TblMzCmd)	;Use the command number to
		LD	L,A			;index into the jump table.
		LD	A,HIGH(TblMzCmd)	;
		ADC	0			;
		LD	H,A			;

		LD	A,[HLI]			;Get the address of the code.
		LD	H,[HL]			;
		LD	L,A			;

		JP	[HL]			;Execute the command.

TblMzCmd::	DW	MzCmdJump
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

MzCmdJump::	LD	A,[DE]			;Read destination address.
		INC	DE			;
		LD	C,A			;
		LD	A,[DE]			;
		LD	E,C			;
		LD	D,A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_END - End of sequence.
;

MzCmdEnd::	LDHL	SP,MZ_LST_CURR		;Read sequence list ptr.
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

MzReadLst::	LD	A,[DE]			;Get next cmd in the list.

MzLstLoop::	CP	LOOP			;LOOP next sequence ?
		JR	C,MzNewSeq		;Sequence number not command.
		JR	NZ,MzLstTran

		INC	DE			;Get repeat count.
		LD	A,[DE]			;
		LD	[HL],A			;Save it in MZ_SEQ_REPEAT.
		INC	DE			;
		JR	MzReadLst		;

MzLstTran::	CP	TRANS			;TRANSPOSE next sequence ?
		JR	NZ,MzLstJump		;

		INC	DE			;Get transpose value.
		LD	A,[DE]			;
		INC	HL			;Save it in MZ_SEQ_TRAN.
		LD	[HLD],A			;
		INC	DE			;
		JR	MzReadLst		;

MzLstJump::	CP	JUMP			;JUMP to address ?
		JR	NZ,MzLstEnd		;

		INC	DE			;Get address to jump to.
		LD	A,[DE]			;
		LD	C,A			;
		INC	DE			;
		LD	A,[DE]			;
		LD	E,C			;
		LD	D,A			;
		JR	MzReadLst		;

MzLstEnd::	LDH	A,[hChannelVol]		;Don't reset the channel's
		LD	C,A			;volume if it was already
		LD	A,[C]			;fading down. This should
		DEC	A			;avoid the nasty hardware
		AND	$0F			;click that happens if you
		CP	$07			;do.
		JR	C,MzCmdExit		;

		LDHL	SP,MZ_VOLUME		;
		LD	[HL],$00		;

		LDHL	SP,MZ_SEQ_CURR		;Get sequence ptr.
		LD	A,LOW(MzDummyExit)	;
		LD	[HLI],A			;
		LD	A,HIGH(MzDummyExit)	;
		LD	[HLI],A			;

		LDHL	SP,MZ_NOTE_LEN		;
		LD	[HL],$01		;
		INC	HL			;
		LD	[HL],$01		;

		RET				;

MzDummyExit::	DB	EXIT

MzLstExit::	LDHL	SP,MZ_STATUS		;END music processing on this
		LD	[HL],$00		;channel.
		RET				;

MzNewSeq::	DEC	HL			;Save position in MZ_LST_CURR.
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

MzCmdExit::	LDHL	SP,MZ_STATUS		;END music processing on this
		LD	[HL],$00		;channel.
		RET				;

;
; MZ_LENGTH - Set automatic length.
;

MzCmdLength::	LD	A,[DE]			;Get automatic note length.
		INC	DE			;
		LDHL	SP,MZ_AUTO_LEN		;Save it in MZ_AUTO_LEN.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_MANUAL - Set manual length.
;

MzCmdManual::	LDHL	SP,MZ_AUTO_LEN		;Clear MZ_AUTO_LEN.
		LD	[HL],0			;

		JP	MzReadSeq		;Read next command.

;
; MZ_TIE - Increase length of next note.
;

MzCmdTie::	LDHL	SP,MZ_NOTE_LEN+1	;Increment the length of the
		INC	[HL]			;next note by 256/60s.

		JP	MzReadSeq		;Read next command.

;
; REST  - Pause.
;

MzCmdRest::	SET	MZ_FLG_REST,B		;Set rest on next note.

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

MzCmdGliOn::	SET	MZ_FLG_GLI,B		;Switch on glide and switch
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

MzCmdGliOff::	RES	MZ_FLG_GLI,B		;Switch off glide.

		JP	MzReadSeq		;Read next command.

;
; MZ_EFFECT - Set wierd transpose.
;

MzCmdEffOn::	SET	MZ_FLG_EFF,B		;Switch on effect and switch
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

MzCmdEffOff::	RES	MZ_FLG_EFF,B		;Switch off effect.

		JP	MzReadSeq		;Read next command.

;
; MZ_ARPON - Set arpeggio.
;

MzCmdArpOn::	SET	MZ_FLG_ARP,B		;Turn on arpeggio and turn
		RES	MZ_FLG_VIB,B		;off vibrato.

		LD	A,[DE]			;Get the arpeggio number.
		INC	DE

		ADD	A,A			;Use the arpeggio number to
		ADD	A,LOW(TblMzArp)	;index into a table of arpeggio
		LD	L,A			;addresses.
		LD	A,HIGH(TblMzArp)
		ADC	0
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

MzCmdArpOff::	RES	MZ_FLG_ARP,B		;Switch off arpeggio.

		JP	MzReadSeq		;Read next command.

;
; MZ_VIBON - Set vibrato.
;

MzCmdVibOn::	SET	MZ_FLG_VIB,B		;Turn on vibrato and turn
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

MzCmdVibOff::	RES	MZ_FLG_VIB,B		;Switch off vibrato.

		JP	MzReadSeq		;Read next command.

;
; MZ_ENV - Set volume envelope.
;

MzCmdEnv::	LD	A,[DE]			;Get the envelope byte.
		INC	DE			;

		LDHL	SP,MZ_ENVELOPE		;Save it in MZ_ENVELOPE.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_DRUM -
;

MzCmdDrum::	SET	MZ_FLG_DRUM,B		;

		LD	A,[DE]			;Get drum number.
		INC	DE			;

		ADD	A,A			;Use it as an index into the drum
		ADD	A,LOW(TblMzDrum)	;table.
		LD	L,A			;
		LD	A,0			;
		ADC	A,HIGH(TblMzDrum);
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

MzCmdPoke::	LD	A,[DE]			;Get the register number.
		INC	DE			;
		LD	C,A			;
		LD	A,[DE]			;
		INC	DE			;Get the value.
		LD	[C],A			;Do it.

		JP	MzReadSeq		;Read next command.

;
; MZ_SET_WAVE - Set up the waveform RAM and store the address.
;

MzCmdSetWave::	LD	HL,wMzWavePtr		;
		LD	A,E			;
		LD	[HLI],A			;
		LD	[HL],D			;

;
; MZ_TMP_WAVE - Set up the waveform RAM.
;

MzCmdTmpWave::	XOR	A			;
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

MzCmdOldWave::	LD	HL,wMzWavePtr		;
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

MzCmdSetDuty::	LD	A,[DE]			;Get the duty byte.
		INC	DE			;

		LDHL	SP,MZ_DUTY		;Save it.
		LD	[HL],A			;

		JP	MzReadSeq		;Read next command.

;
; MZ_SWEEP -
;

MzCmdSweep::	SET	MZ_FLG_GLI_V,B

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
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
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

MzCmdHwRegs::	SET	MZ_FLG_REST,B		;Set rest on next note.

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

MzNewNote::	PUSH	DE			;Save ptr to sequence.

		LDHL	SP,MZ_SEQ_TRAN+2	;Add on the sequence transpose.
		ADD	A,[HL]			;
		INC	HL			;Save as MZ_NOTE.
		LD	[HLI],A			;

;
;
;

MzSetEff::	BIT	MZ_FLG_EFF,B		;Is EFFECT switched on ?
		JR	Z,MzNewFrq

		SET	MZ_FLG_EFF_V,B

		ADD	A,[HL]			;Add on the effect transpose.
		INC	HL			;Make a working copy of the
		LD	C,[HL]			;effect length.
		INC	HL
		LD	[HL],C

		ADD	A,A			;Use the note number to index
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
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

MzNewFrq::	ADD	A,A			;Use the note number to index
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
		LD	H,A

		LD	A,[HLI]			;Get the frequency.
		LD	D,[HL]

		LDHL	SP,MZ_PERIOD+2		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],D

;
;
;

MzSetGli::	BIT	MZ_FLG_GLI,B		;Is GLIDE switched on ?
		JR	Z,MzSetVib

		SET	MZ_FLG_GLI_V,B

		LD	E,A

		LDHL	SP,MZ_NOTE+2		;Get the current note value.
		LD	A,[HL]

		LDHL	SP,MZ_GLI_TRAN+2	;Add on the glide transpose.
		ADD	A,[HL]			;(Use full tones then /2 later.)

		ADD	A,A			;Use the note number to index
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
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

MzGliDivide::	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzGliDivide		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_GLI_DELTA.

		LD	L,A			;Now multiply the number of
		LD	H,D			;steps by the delta-frequency
		SRL	E			;to get the exact frequency
		JR	C,MzGliPeriod		;change.
MzGliMultiply::	ADD	HL,HL
		SRL	E
		JR	NC,MzGliMultiply

MzGliPeriod::	LD	E,L
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

MzSetVib::	BIT	MZ_FLG_VIB,B		;Is VIBRATO switched on?
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
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
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

MzVibDivide::	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzVibDivide		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_VIB_DELTA.

		JR	MzSetEnv

;
;
;

MzSetArp::	BIT	MZ_FLG_ARP,B		;Is ARPEGGIO switched on ?
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

MzSetEnv::	LDHL	SP,MZ_ENVELOPE+2	;Copy MZ_ENVELOPE into MZ_VOLUME.
		LD	A,[HLI]
		LD	[HL],A

		POP	DE			;Restore ptr to sequence.

;
; Find duration.
;

MzDuration::	LDHL	SP,MZ_PERIOD+1		;New note - initialize envelope.
		SET	7,[HL]			;

MzDurationRest::LDHL	SP,MZ_AUTO_LEN		;Get automatic duration.
		LD	A,[HLI]			;
		OR	A			;
		JR	NZ,MzSetLength		;Get manual duration if auto
		LD	A,[DE]			;duration is zero.
		INC	DE			;
MzSetLength::	ADD	A,[HL]			;Add on current duration (i.e.
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

MzOldNote::	BIT	MZ_FLG_DRUM,B		;Special processing for 'drum'.
		JP	NZ,MzDoDrum

		BIT	MZ_FLG_REST,B		;Halt processing during a
		JP	NZ,MzDone		;rest.

;
; Process glide.
;

MzDoGli::	BIT	MZ_FLG_GLI_V,B		;Is GLIDE active ?
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

MzDoEff::	BIT	MZ_FLG_EFF_V,B		;Is EFFECT active ?
		JR	Z,MzDoVib

		LDHL	SP,MZ_EFF_LEN_V		;Decrement the effect length.
		DEC	[HL]
		JP	NZ,MzDone

		RES	MZ_FLG_EFF_V,B

		LDHL	SP,MZ_NOTE		;Get the original MZ_NOTE.
		LD	A,[HL]

		ADD	A,A			;Use the note number to index
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)
		ADC	0
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

MzSetVibB::	BIT	MZ_FLG_VIB,B		;Is VIBRATO switched on?
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
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)	;
		ADC	0
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

MzVibDivideB::	SRA	D			;Divide the delta-frequency
		RRA				;by the number of steps per
		SRL	C			;quarter cycle + 1 (to correct
		JR	NC,MzVibDivideB		;for using full tones earlier).

		LD	[HLI],A			;Save delta-frequency in
		LD	[HL],D			;MZ_VIB_DELTA.

		JP	MzDone

;
;
;

MzSetArpB::	BIT	MZ_FLG_ARP,B		;Is ARPEGGIO switched on ?
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

MzDoVib::	BIT	MZ_FLG_VIB,B		;Is VIBRATO active ?
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

MzDoVibWait::	INC	HL			;Update delay timer.
		DEC	[HL]

		JP	MzDone

;
; Process arpeggio.
;

MzDoArp::	BIT	MZ_FLG_ARP,B
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

MzDoArpTran::	INC	DE			;Update MZ_ARP_CURR.
		LD	[HL],D
		DEC	HL
		LD	[HL],E

		LDHL	SP,MZ_NOTE		;Add on the base note value.
		ADD	A,[HL]

		ADD	A,A			;Use the note number to index
		ADD	A,LOW(TblMzFrq)	;into a table of frequency
		LD	L,A			;values.
		LD	A,HIGH(TblMzFrq)	;
		ADC	0			;
		LD	H,A			;

		LD	A,[HLI]			;Get the new note frequency.
		LD	C,[HL]

		LDHL	SP,MZ_PERIOD		;Save it in MZ_PERIOD.
		LD	[HLI],A
		LD	[HL],C

;
; End of processing.
;

MzDone::	LDHL	SP,MZ_FLAGS		;Save MZ_FLAGS.
		LD	[HL],B			;

		RET				;

;
; Process 'drum' special effect.
;

MzDoDrum::	LDHL	SP,MZ_DRUM_CURR		;Get the ptr to the next frequency
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

MzDrumDone::	RES	MZ_FLG_DRUM,B
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

TblMzFrq::	DW	2048-(2004/1)		;C1
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

TEMPO2		EQU	6			;  TEMPO CONTROL
DSQ2		EQU	TEMPO2/2		;  DEMI-SEMI-QUAVER
SQ2		EQU	TEMPO2			;  SEMI-QUAVER
QV2		EQU	SQ2*2			;  QUAVER
DQV2		EQU	QV2+SQ2			;  DOTTED QUAVER
CR2		EQU	QV2*2			;  CROTCHET
QV2TRIP		EQU	CR2/3			;  CROTCHET
DCR2		EQU	CR2+QV2			;  DOTTED CROTCHET
MN2		EQU	CR2*2			;  MINIM
DMN2		EQU	MN2+CR2			;  DOTTED MINIM
SB2		EQU	MN2*2			;  SEMI-BREVE
DSB2		EQU	SB2+MN2			;  DOTTED SEMI-BREVE

TEMPO3		EQU	7			;  TEMPO CONTROL
DSQ3		EQU	TEMPO3/2		;  DEMI-SEMI-QUAVER
SQ3		EQU	TEMPO3			;  SEMI-QUAVER
QV3		EQU	SQ3*2			;  QUAVER
DQV3		EQU	QV3+SQ3			;  DOTTED QUAVER
CR3		EQU	QV3*2			;  CROTCHET
QV3TRIP		EQU	CR3/3			;  CROTCHET
DCR3		EQU	CR3+QV3			;  DOTTED CROTCHET
MN3		EQU	CR3*2			;  MINIM
DMN3		EQU	MN3+CR3			;  DOTTED MINIM
MN3TRIP		EQU	MN3/3			;  DOTTED MINIM
SB3		EQU	MN3*2			;  SEMI-BREVE
DSB3		EQU	SB3+MN3			;  DOTTED SEMI-BREVE

TEMPO4		EQU	5			;  TEMPO CONTROL
DSQ4		EQU	TEMPO4/2		;  DEMI-SEMI-QUAVER
SQ4		EQU	TEMPO4			;  SEMI-QUAVER
QV4		EQU	SQ4*2			;  QUAVER
DQV4		EQU	QV4+SQ4			;  DOTTED QUAVER
CR4		EQU	QV4*2			;  CROTCHET
QV4TRIP		EQU	CR4/3			;  CROTCHET
DCR4		EQU	CR4+QV4			;  DOTTED CROTCHET
MN4		EQU	CR4*2			;  MINIM
DMN4		EQU	MN4+CR4			;  DOTTED MINIM
MN4TRIP		EQU	MN4/3			;  DOTTED MINIM
SB4		EQU	MN4*2			;  SEMI-BREVE
DSB4		EQU	SB4+MN4			;  DOTTED SEMI-BREVE

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

TblMzDrum::	DW	DRUM0,DRUM1,DRUM2,DRUM3
		DW	DRUM4,DRUM5,DRUM6,DRUM7
		DW	DRUM8,DRUM9,DRUM10,DRUM11
		DW	DRUM12,DRUM13,DRUM14,DRUM15
		DW	DRUM16,DRUM17,DRUM18,DRUM19
		DW	DRUM20,DRUM21


DRUM0::		DB      $72
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      0,$2B,0,$2B,0,$2B,0,$2B,0,$2B,0,$2B
		DB      $FF

DRUM1::		DB      $72
		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      $FF

DRUM2::		DB      $52
		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      $FF

DRUM3::		DB      $70
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      0,$68,0,$68,0,$68,0,$68,0,$68
		DB      $FF

DRUM4::		DB      $A3
		DB      0,$22,0,$22,0,$22,0,$22,0,$22
		DB      0,$22,0,$22,0,$22,0,$22,0,$22
		DB      0,$23,0,$23,0,$23,0,$23,0,$23
		DB      0,$23,0,$23,0,$23,0,$23,0,$23
		DB      0,$24,0,$24,0,$24,0,$24,0,$24
		DB      0,$24,0,$24,0,$24,0,$24,0,$24
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      0,$26,0,$26,0,$26,0,$26,0,$26
		DB      $FF

DRUM5::		DB      $75
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      0,$2E,0,$2E,0,$2E,0,$2E,0,$2E,0,$2E
		DB      $FF

DRUM6::		DB      $61				     ;MUSIC
		DB      0,$60,0,$50,0,$40
		DB      $FF

DRUM7::		DB      $81
		DB      0,$60,0,$50,0,$40,0,$40,0,$40   ;MUSIC
		DB      $FF

DRUM8::		DB      $D1
		DB      0,$02,0,$02,0,$06,0,$06,0,$06,0,$05     ;MUSIC
		DB      0,$05,0,$05,0,$05,0,$04,0,$04,0,$04
		DB      0,$04,0,$03,0,$03,0,$03,0,$02,0,$02
		DB      $FF

DRUM9::		DB      $83
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


DRUM10::	DB      $41
		DB      0,$65,0,$43,0,$43,0,$43,0,$43,0,$43,0,$43
		DB      0,$43,0,$43,0,$43,0,$43,0,$43,0,$43,0,$43
		DB      $FF

DRUM11::	DB      $32
		DB      0,$60,0,$50,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      0,$40,0,$40,0,$40,0,$40,0,$40,0,$40,0,$40
		DB      $FF

DRUM12::	DB      $41
		DB      0,$59,0,$5B,0,$5B,0,$5D,0,$5F,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      $FF

DRUM13::	DB      $6D
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      0,$08,0,$00,0,$08,0,$00,0,$08,0,$00
		DB      $FF

DRUM14::	DB      $C1
		DB      0,$59,0,$5B,0,$5B,0,$5D,0,$5F,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      0,$60,0,$60,0,$60,0,$60,0,$60,0,$60
		DB      $FF

DRUM15::	DB      $90
		DB      0,$05,0,$05,0,$05,0,$05
		DB      0,$04,0,$04,0,$04,0,$04
		DB      0,$03,0,$03,0,$03,0,$03
		DB      0,$02,0,$02,0,$02,0,$02
		DB      0,$01,0,$01,0,$01,0,$01
		DB      0,$00,0,$00,0,$00,0,$00
		DB      $FF

DRUM16::	DB      $60
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      0,$44,0,$44,0,$44,0,$44,0,$44,0,$44
		DB      $FF

DRUM17::	DB      $C0
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

DRUM18::	DB      $A7
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      0,$17,0,$17,0,$17,0,$17,0,$17,0,$17
		DB      $FF

DRUM19::	DB      $81
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      0,$07,0,$07,0,$07,0,$07,0,$07,0,$07
		DB      $FF


DRUM20::	DB      $67
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

DRUM21::	DB      $67
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

MAJOR23		EQU     0
SEVENTH		EQU     1
MAJOR		EQU     2
MINOR		EQU     3
EDB		EQU     4
MAJ1		EQU     5
MAJ1DIM		EQU     6
MAJ1SUS2	EQU     7
MAJ2		EQU     8

MINR		EQU     9
MIN1		EQU     10
MIN2		EQU     11

FLASH		EQU     12
FLASH2		EQU     13
SUS417TH	EQU     14
SUS42		EQU     15

FIFTHS		EQU     16
FOURTHS		EQU     17
THIRDS		EQU     18
HAMMER2		EQU     19
DIM6TH		EQU     20
TRILL1		EQU     21
FIFTH2		EQU     22
MAJOR2		EQU     23
MINRS		EQU     24
SUS41S		EQU     25
MIN1S		EQU     26
MIN2S		EQU     27
SPECIAL		EQU     28
MINOR6		EQU     29

TblMzArp::      DW      ARP0,ARP1,ARP2,ARP3,ARP4,ARP5
		DW      ARP6,ARP7,ARP8,ARP9,ARP10,ARP11
		DW      ARP12,ARP13,ARP14,ARP15,ARP16,ARP17,ARP18
		DW      ARP19,ARP20,ARP21,ARP22,ARP23,ARP24,ARP25
		DW      ARP26,ARP27,ARP28,ARP29,ARP30

ARP0::		DB      24,24,12,12,0,0,0,0,0,0,0,0,$80

ARP1::		DB      7,7,4,4,0,0,10,10,$80		;SEVENTH
ARP2::		DB      7,7,4,4,0,0,$80		;MAJOR
ARP3::		DB      7,7,3,3,0,0,$80		;MINOR
		DB      7,7,7,7,7,7,7,7,7,7,$80
ARP4::		DB      5,5,3,3,0,0     ;EDB THANG

		DB      5,5,5,5,5,5,5,5,5,5,$80
ARP5::		DB      7,7,12,12,16,16,$80     ;1ST MAJOR
ARP6::		DB      12,12,6,6,3,3,$80       ;1ST MAJOR DIM
ARP7::		DB      14,14,12,12,7,7,4,4,$80 ;1ST MAJOR SUS2
ARP8::		DB      12,12,7,7,4,4,$80       ;2ND MAJOR

ARP9::		DB      19,19,15,15,12,12,0,0,$80       ;ROOT MINOR + BASS
ARP10::		DB      7,7,12,12,15,15,$80     ;1ST MINOR
ARP11::		DB      12,12,7,7,3,3,$80       ;2ND MINOR

ARP12::		DB      7,7,5,5,3,3,0,0,$80		;FLASH
ARP13::		DB      0,0,5,5,7,7,12,12,19,19,$80     ;FLASH2
ARP14::		DB      12,12,10,10,7,7,5,5,$80 ;1ST MAJOR SUS4 7TH
ARP15::		DB      17,17,12,12,7,7,$80     ;2ND MAJOR SUS4

ARP16::		DB      0,0,7,7,$80     ;FIFTHS
ARP17::		DB      0,0,5,5,$80		;FOURTHS
ARP18::		DB      0,0,4,4,$80		;THIRDS
ARP19::		DB      0,0,0,2,2,2,$80		;HAMMER ON & PULL OFF TONE
ARP20::		DB      9,9,6,6,3,3,0,0,$80     ;DIMINISHED 6TH
ARP21::		DB      0,0,0,3,3,3,$80		;
ARP22::		DB      0,7,$80		;FIFTH2
ARP23::		DB      16,16,12,0,7,7,$80      ;2ND MAJOR
ARP24::		DB      7,7,3,3,0,0,$80		;ROOT MINOR
ARP25::		DB      12,12,7,7,5,5,$80       ;1ST MAJOR SUS4
ARP26::		DB      12,12,7,7,3,3,$80       ;1ST MINOR
ARP27::		DB      15,15,12,12,7,7,$80     ;2ND MINOR
ARP28::		DB      0,0,3,3,5,5,7,7,0,0,3,3,5,5,7,7,12,12,
		DB      15,15,17,17,19,19,24,24,$80     ;SPECIAL
;ARP28::		DB      0,0,7,7,12,12,19,19,22,22,$80   ;SPECIAL
ARP29::		DB      0,0,3,3,7,7,$80		;SIMPLE MINOR
ARP30::		DB      0,0,4,4,7,7,$80		;SIMPLE MAJOR

;
;  FX - FX lists.
;

TblFxList::	DW	0,0,FX01,0		;1
		DW	0,0,FX01,0		;2  fifi - JUMP1
		DW	0,0,FX02,0		;3  fifi - JUMP2
		DW	0,0,FX03,0		;4  fifi - JUMP3
		DW	0,0,FX04,0		;5  fifi - LAST JUMP
		DW	0,0,0,FX07		;6  chopin' wood
		DW	0,0,0,FX08		;7 PILE UP WOOD
		DW	0,0,0,FX08		;8 PILE UP WOOD
		DW	0,0,0,FX08		;9 PILE UP WOOD
		DW	0,0,0,FX08		;10 PILE UP WOOD
		DW	0,0,0,FX08		;11 PILE UP WOOD
		DW	0,0,0,FX10		;12 Duster NOISE
		DW	0,0,0,FX11		;13 Duster NOISE
		DW	0,0,0,FX12		;14 Duster NOISE
		DW	0,0,0,FX13		;15 Duster FUK-UP
		DW	0,0,FX01,0		;16 NOTHING,-OLD Duster FUK-UP
		DW	0,0,FX03,0		;17 belle - JUMPS
		DW	0,0,0,FX16		;18 belle - HIT WOLF
		DW	0,0,0,FX17		;19 belle - HIT OBJECT
		DW	FX19,FX18,0,0		;20 SHOOT - TARGETS CLEARED
		DW	0,0,0,FX20		;21 SHOOTING NOISE
		DW	0,FX21,0,FX20		;22 SHOOTING MISS
		DW	0,FX22,0,FX20		;23 SHOOTING GOOD PICKUP
		DW	0,FX23,0,FX20		;24 SHOOTING BAD PICKUP
		DW	FX19,FX18,0,0		;25 CHIP - STAGE CLEAR
		DW	0,0,0,FX13		;26 CHIP - WRONG CUP
		DW	0,0,FX24,0		;27 CHIP - RIGHT CUP
		DW	0,0,FX01,0		;28 CHIP CHOOSE CUP
		DW	0,0,FX02,0		;29 CHIP CHOOSE CUP
		DW	0,0,FX03,0		;30 CHIP CHOOSE CUP
		DW	0,FX25,0,FX10		;31 duster 1
		DW	0,FX26,0,FX11		;32 duster 2
		DW	0,FX27,0,FX12		;33 duster 3
		DW	0,FX28,0,FX10		;34 duster 4
		DW	0,FX29,0,FX12		;35 duster 5
		DW	0,FX30,0,FX11		;36 duster 6
		DW	0,FX31,0,FX12		;37 duster 7
		DW	0,FX32,0,FX10		;38 duster 8
		DW	0,FX33,0,FX11		;39 duster 9
		DW	0,FX34,0,FX12		;40 duster 10
		DW	0,FX35,0,FX10		;41 duster 11
		DW	0,FX36,0,FX11		;42 duster 12
		DW	0,FX37,0,FX12		;43 duster 13
		DW	0,FX38,0,FX10		;44 duster 14
		DW	0,FX39,0,FX11		;45 duster 15
		DW	0,FX40,0,FX12		;46 duster 16
		DW	0,0,0,FX08		;47 PILE UP WOOD
		DW	0,0,0,FX08		;48 PILE UP WOOD
		DW	0,0,0,FX08		;49 PILE UP WOOD
		DW	0,0,0,FX08		;50 PILE UP WOOD
		DW	0,0,0,FX08		;51 PILE UP WOOD
		DW	0,0,0,FX08		;52 ILE UP WOOD
		DW	0,0,0,FX08		;53 PILE UP WOOD
		DW	0,0,0,FX08		;54 PILE UP WOOD
		DW	0,0,0,FX08		;55 PILE UP WOOD
		DW	0,0,0,FX08		;56 PILE UP WOOD
		DW	0,0,0,FX08		;57 PILE UP WOOD
		DW	FX05,FX05,0,0		;58 STAGE DITTY
		DW	0,0,0,FX58		;59 WOLF RUNS ON THE GROUND
		DW	FX59,0,0,0		;60 SPITTING meter up
		DW	FX60,0,0,0		;61 SPITTING meter down
		DW	0,0,FX61,0		;62 SPITNOISE
		DW	0,0,0,FX62		;63 WATER OUT
		DW	0,FX63,0,0		;64 DROP START
		DW	0,FX65,0,FX64		;65 DROP HITS WATER
		DW	0,FX70,0,0		;66 FILL UP TEAPOT
		DW	0,0,0,FX56		;67 teapot sprays
		DW	0,0,0,FX57		;68 FIRE BACKGROUND
		DW	0,0,0,FX67		;69 teapot quenches fire
		DW	FX71,0,0,0		;70 ROLL 1 DIE
		DW	FX72,0,0,0		;71 ROLL 2 DICE
		DW	0,0,FX69,FX68		;72 FIRE BURNS THRU'
		DW	0,FX73,0,0		;73 MRS POTTS JUMPS
		DW	0,FX74,0,0		;74 TARGET GONE
		DW	0,FX22,0,0		;75 SELECTION
		DW	0,0,FX76,0		;76 ZERO
		DW	0,0,FX77,0		;77 ONE
		DW	0,0,FX78,0		;78 TWO
		DW	0,0,FX79,0		;79 THREE
		DW	0,0,FX80,0		;80 BUTTON BEEP

TblFxListEnd::

FX76::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE		;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	LENGTH,4
		DB	C5,D5,E5,F5
		DB	LENGTH,8,G5
		DB	MANUAL
		DB	ENV,%01000000,G5,1
		DB	ENV,%01100000,G5,1
		DB	END

FX77::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE		;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	LENGTH,4
		DB	D5,E5,F5,G5
		DB	LENGTH,8,A5
		DB	MANUAL
		DB	ENV,%01000000,A5,1
		DB	ENV,%01100000,A5,1
		DB	END

FX78::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE		;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	LENGTH,4
		DB	E5,F5,G5,A5
		DB	LENGTH,8,B5
		DB	MANUAL
		DB	ENV,%01000000,B5,1
		DB	ENV,%01100000,B5,1
		DB	END

FX79::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE		;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	LENGTH,4
		DB	F5,G5,A5,B5
		DB	LENGTH,16,C6
		DB	MANUAL
		DB	ENV,%01000000,C6,1
		DB	ENV,%01100000,C6,1
		DB	END

FX75::		DB	MANUAL,ENV,$84,ARPON,FIFTHS
		DB	G2,4,REST,1,G2,15
		DB	END

FX74::		DB	MANUAL				;FIFI
		DB	ENV,$87,B3,1,C4,8,B3,8,AS3,8,ENV,$85,A3,30
		DB	END

FX73::		DB	MANUAL
		DB	ENV,$A0,LENGTH,1
		DB	D3,DS3,E3,F3,G3,GS3,A3,AS3
		DB	B3,C4,CS4,D4,DS4,E4,F4,FS4,G4
		DB	ENV,$00,C1,1
		DB	END

FX01::		DB	MANUAL,WAVE				;FIFI
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	GLION,-24,16,FS5,18
		DB	END

FX02::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE		;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	GLION,-24,16,G5,18
		DB	END

FX03::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE         ;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	GLION,-24,16,GS5,18
		DB	END

FX04::		DB	MANUAL,WAVE				;FIFI FINAL
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000,LENGTH,1
		DB	D6,CS6,C6,B5,AS5,A5,GS5
		DB	G5,FS5,F5,E5,DS5,D5,CS5,C5,B4,AS4,A4,GS4
		DB	END

FX05::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,SQ2
		DB	G3,G3,REST,G3
		DB	LENGTH,QV2
		DB	A3,AS3,B3,REST,G3
		DB	END

FX06::		DB	ENV,$82					;DUSTER SCALE
		DB	LENGTH,SQ2
		DB	D4,D4,REST,D4
		DB	LENGTH,QV2
		DB	E4,F4,FS4,REST,D4
		DB	END

FX07::		DB	DRUM,8,10,DRUM,8,30			;CHOPIN WOOD
		DB	END

FX08		DB	DRUM,0,10
		DB	END

;FX08::		DB	ENV,$B1                                 ;WOOD STACK
;		DB	MANUAL,A2,2,B2,10
;		DB	END

FX09::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,B2,2,CS3,10
		DB	END

FX10::		DB	REST,30,DRUM,0,20		;SWEEP
		DB	END

FX11::		DB	REST,30,DRUM,2,12		;SWEEP
		DB	END

FX12::		DB	REST,30,DRUM,2,8,DRUM,1,6,DRUM,2,8	;SWEEP
		DB	END

FX13::		DB	DRUM,3,10,REST,1,DRUM,3,15       ;DUSTER MISTAKE
		DB	END

FX14::		DB	ENV,$82                                 ;DUSTER SCALE
		DB	LENGTH,QV2
		DB	E3,A2,E3
		DB	END

FX15::		DB	VIBON,8,1,4,ENV,$A8		;DUSTER MISTAKE
		DB	B3,2,C4,QV2,G3,QV2+2,DS3,QV2+5,C3,CR2+12
		DB	END

FX16::		DB	DRUM,4,60		;BELLE - HIT WOLF
		DB	END

FX17::		DB	DRUM,5,2,REST,2,DRUM,5,40	;BELLE - HIT OBJECT
		DB	END

FX18::		DB	MANUAL,ENV,$A2		;SHOOTING - CLEAR TARGETS
		DB	G3,2,B3,QV2,B3,SQ2,B3,SQ2,A3,SQ2+1,B3,SQ2+2,C4,DQV2
		DB	END

FX19::		DB	ENV,$66,LENGTH,DCR2+5,G2,C3	;SHOOTING - CLEAR TARGETS
		DB	END

FX20::		DB	DRUM,9,60	;SHOOTING NOISE
		DB	END

FX21::		DB	REST,5,LENGTH,3	;SHOOT - MISS
		DB	ENV,$F1,G3,FS3,F3,E3,DS3,D3
		DB	END

FX22::		DB	REST,5,ENV,$B1,LENGTH,3,C3,E3,G3,C4 ;GOOD PICKUP
		DB	END

FX23::		DB	REST,5,ENV,$B1,LENGTH,3,C3,E3,B2,D3,A2,C3 ;BAD PICKUP
		DB	END

FX24::		DB	WAVE
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF ;CHIP RIGHT CUP
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	LENGTH,5,C5,E5,G5,C6,G5,E5
		DB	MANUAL,C5,20
		DB	ENV,%01000000,C5,1
		DB	ENV,%01100000,C5,1
		DB	END

FX25::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	G2
		DB	END

FX26::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	A2
		DB	END

FX27::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	B2
		DB	END

FX28::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	C3
		DB	END

FX29::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	D3
		DB	END

FX30::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	E3
		DB	END

FX31::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	FS3
		DB	END

FX32::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	G3
		DB	END

FX33::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	A3
		DB	END

FX34::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	B3
		DB	END

FX35::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	C4
		DB	END

FX36::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	D4
		DB	END

FX37::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	E4
		DB	END

FX38::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	FS4
		DB	END

FX39::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	G4
		DB	END

FX40::		DB	ENV,$84					;DUSTER SCALE
		DB	LENGTH,CR2
		DB	A4
		DB	END

FX41::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,C3,2,D3,10
		DB	END

FX42::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,CS3,2,DS3,10
		DB	END

FX43::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,D3,2,E3,10
		DB	END

FX44::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,DS3,2,F3,10
		DB	END

FX45::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,E3,2,FS3,10
		DB	END

FX46::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,F3,2,G3,10
		DB	END

FX47::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,FS3,2,GS3,10
		DB	END

FX48::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,G3,2,A3,10
		DB	END

FX49::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,GS3,2,AS3,10
		DB	END

FX50::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,A3,2,B3,10
		DB	END

FX51::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,AS3,2,C4,10
		DB	END

FX52::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,B3,2,CS4,10
		DB	END

FX53::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,C4,2,D4,10
		DB	END

FX54::		DB	ENV,$B1                                 ;WOOD STACK
		DB	MANUAL,CS4,2,DS4,10
		DB	END

FX55::		DB	ENV,$2E
		DB	MANUAL,DRUM,13,15,DRUM,14,30
		DB	END

FX58::		DB	DRUM,2,6,DRUM,2,6,DRUM,0,6,DRUM,2,6
		DB	DRUM,0,6,DRUM,2,6,DRUM,2,6,DRUM,2,6
		DB	END

FX59::		DB	LENGTH,2,ENV,$60
		DB	D2,DS2,E2,F2,FS2,G2,GS2,A2,AS2,B2,C3,CS3
		DB	D3,DS3,E3,F3,FS3,G3,GS3,A3,AS3,B3,C4,CS4
		DB	END

FX60::		DB	LENGTH,2,ENV,$60
		DB	D4,CS4,C4,B3,AS3,A3,GS3,G3,FS3,F3,E3,DS3
		DB	D3,CS3,C3,B2,AS2,A2,GS2,G2,FS2,F2,E2,DS2
		DB	END

FX61::		DB	MANUAL,WAVE
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE         ;FIFI
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	GLION,32,32,B3,38
		DB	END

FX62::		DB	DRUM,21,60
		DB	END

FX63::		DB	MANUAL,ENV,$87
		DB	GLION,24,16,DS3,16
		DB	END

;FX63::		DB	MANUAL,WAVE				;WATERDROPSTART
;		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE
;		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
;		DB	ENV,%00100000
;		DB	GLION,24,16,AS4,16
;		DB	END

FX64::		DB	DRUM,19,10,DRUM,20,50			;DROPHITWATER
		DB	END

FX65::		DB	ENV,$82					;DROPHITWATER
		DB	MANUAL
		DB	F3,10
		DB	ENV,$87
		DB	D3,50
		DB	END

FX66::		DB	ENV,$82					;DROPHITCANDLE
		DB	LENGTH,5
		DB	C3,E3,G3,C4
		DB	END

FX71::		DB	MANUAL,ENV,$B2,C2,20,ENV,$85,C2,3,REST,2,C2,15
		DB	END

FX72::		DB	MANUAL,ENV,$62,C2,3,REST,1,ENV,$C2,C2,15,REST,5
		DB	ENV,$85,C2,3,REST,2,C2,15
		DB	END

FX70::		DB	MANUAL				;FIFI
		DB	ENV,$A5
		DB	LENGTH,5
		DB	G3,A3,B3,C4,D4,ENV,$00,C3
		DB	END

FX69::		DB	MANUAL,WAVE				;FIFI
		DB	$01,$23,$45,$56,$78,$9A,$BC,$DE
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%01000000
		DB	E6,5,REST,2
		DB	E6,5,REST,2
		DB	E6,5,REST,2
		DB	E6,5,REST,2
		DB	E6,5,REST,2
		DB	END

FX68::		DB	MANUAL,DRUM,18,30
		DB	END

FX67::		DB	MANUAL,DRUM,17,48
		DB	END

FX56::		DB	MANUAL,DRUM,15,24
		DB	END

FX57::		DB	MANUAL,DRUM,16,60
		DB	END

FX80::		DB	MANUAL,WAVE			;PASS
		DB	$01,$23,$45,$67,$89,$AB,$CD,$EF
		DB	$FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	D5,5
		DB	END

TblMzTune::	DW	SILENCE,SILENCE,SILENCE,SILENCE
		DW	TITLE1,TITLE2,TITLE3,TITLE4
		DW      ADVANCE1,ADVANCE2,ADVANCE3,ADVANCE4
		DW      COMPLETE1,COMPLETE2,COMPLETE3,COMPLETE4
		DW      GAMEOVER1,GAMEOVER2,GAMEOVER3,GAMEOVER4
		DW      INGAME1,INGAME2,INGAME3,INGAME4
		DW      INTRO1,INTRO2,INTRO3,INTRO4
		DW      FXA1,FXA2,FXA3,FXA4
		DW      FXB1,FXB2,FXB3,FXB4
		DW      WANKER1,WANKER2,WANKER3,WANKER4
		DW      GAYSONG1,GAYSONG2,GAYSONG3,GAYSONG4
		DW      MANU1,MANU2,MANU3,MANU4
		DW      CHAMPIONS1,CHAMPIONS2,CHAMPIONS3,CHAMPIONS4
		DW      TWOONE1,TWOONE2,TWOONE3,TWOONE4
		DW      MUFC1,MUFC2,MUFC3,MUFC4
		DW      GAYJAMES1,GAYJAMES2,GAYJAMES3,GAYJAMES4
		DW	LOVE1,LOVE2,LOVE3,LOVE4
		DW	JERK1,JERK2,JERK3,JERK4
		DW	DAFT1,DAFT2,DAFT3,DAFT4

TblMzTuneEnd::

;
; SEQ - Sequence lists.
;

TblMzSeq::      DW      SEQ0
		DW      SEQ1
		DW      SEQ2
		DW      SEQ3
		DW      SEQ4
		DW      SEQ5
		DW      SEQ6
		DW      SEQ7
		DW      SEQ8
		DW      SEQ9
		DW      SEQ10
		DW      SEQ11
		DW      SEQ12
		DW      SEQ13
		DW      SEQ14
		DW      SEQ15
		DW      SEQ16
		DW      SEQ17
		DW      SEQ18
		DW      SEQ19
		DW      SEQ20
		DW      SEQ21
		DW      SEQ22
		DW      SEQ23
		DW      SEQ24
		DW      SEQ25
		DW      SEQ26
		DW      SEQ27
		DW      SEQ28
		DW      SEQ29
		DW      SEQ30
		DW      SEQ31
		DW      SEQ32
		DW      SEQ33
		DW      SEQ34
		DW      SEQ35
		DW      SEQ36
		DW      SEQ37
		DW      SEQ38
		DW      SEQ39
		DW      SEQ40
		DW      SEQ41
		DW      SEQ42
		DW      SEQ43
		DW      SEQ44
		DW      SEQ45
		DW      SEQ46
		DW      SEQ47
		DW      SEQ48
		DW      SEQ49
		DW      SEQ50
		DW      SEQ51
		DW      SEQ52
		DW      SEQ53
		DW      SEQ54
		DW      SEQ55
		DW      SEQ56
		DW      SEQ57
		DW      SEQ58
		DW      SEQ59
		DW      SEQ60
		DW      SEQ61
		DW      SEQ62
		DW      SEQ63
		DW      SEQ64
		DW      SEQ65
		DW      SEQ66
		DW      SEQ67
		DW      SEQ68
		DW      SEQ69
		DW      SEQ70
		DW      SEQ71
		DW      SEQ72
		DW      SEQ73
		DW      SEQ74
		DW      SEQ75
		DW      SEQ76
		DW      SEQ77
		DW      SEQ78
		DW      SEQ79
		DW      SEQ80
		DW      SEQ81
		DW      SEQ82
		DW      SEQ83
		DW      SEQ84
		DW      SEQ85
		DW      SEQ86
		DW      SEQ87
		DW      SEQ88
		DW      SEQ89
		DW      SEQ90
		DW      SEQ91
		DW      SEQ92
		DW      SEQ93
		DW      SEQ94
		DW      SEQ95
		DW      SEQ96
		DW      SEQ97
		DW      SEQ98
		DW      SEQ99
		DW      SEQ100
		DW      SEQ101
		DW      SEQ102
		DW      SEQ103
		DW      SEQ104
		DW      SEQ105
		DW      SEQ106
		DW      SEQ107
		DW      SEQ108
		DW      SEQ109
		DW      SEQ110
		DW      SEQ111
		DW      SEQ112
		DW      SEQ113
		DW	SEQ114

;-----------------------------------------------------------------------------
;INITIALIZATION
;-----------------------------------------------------------------------------

SEQ42::		DB      POKE,LOW(rNR52),$80
		DB      POKE,LOW(rNR30),$80
		DB      POKE,LOW(rNR10),$00
		DB      POKE,LOW(rNR51),$FF
		DB      POKE,LOW(rNR50),$77
		DB      END

;-----------------------------------------------------------------------------
;SONG DATA
;-----------------------------------------------------------------------------
;SILENCE (DO NOT CHANGE)
;-----------------------------------------------------------------------------

SILENCE::	DB	0
		DW	END

SEQ0::		DB	MANUAL,REST,1,END

;-----------------------------------------------------------------------------
;SONG DATA
;-----------------------------------------------------------------------------
;VICTORY TUNE
;-----------------------------------------------------------------------------

TITLE1::	DB      42
		DB      1
		DW      END

TITLE2::	DB      2
		DW      END

TITLE3::	DB      31
		DW      END

TITLE4::	DB      31
		DW      END

;-----------------------------------------------------------------------------
;

SEQ1::		DB      ENV,$A3
		DB      D4,QV3,E4,QV3,E4,SQ3,E4,SQ3,E4,QV3
		DB      FS4,QV3,E4,QV3,FS4,QV3
		DB      ENV,$A6,VIBON,16,2,4
		DB      G4,MN3
		DB      END

SEQ2::		DB      ENV,$A3,DUTY,%10000000  ;PIZZ. DOUBLE BASS
		DB      B3,QV3,C4,QV3,C4,SQ3,C4,SQ3,C4,QV3
		DB      D4,QV3,C4,QV3,D4,QV3
		DB      ENV,$A6
		DB      D4,MN3
		DB      END

;-----------------------------------------------------------------------------
;LOSING TUNE
;-----------------------------------------------------------------------------

ADVANCE1::      DB      42
		DB      5
		DB      END

ADVANCE2::      DB      TRANS,-12,4
		DB      END

ADVANCE3::      DB      42,3
		DB      END

ADVANCE4::      DB      31
		DB      END

;-----------------------------------------------------------------------------

SEQ3::		DB      MANUAL,WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$CC,$DE,$EF,$DB,$97,$53,$10
		DB	ENV,%01000000
		DB      LENGTH,5
		DB      C5,D5,DS5
		DB      MANUAL
		DB      E5,CR2,DS5,CR2,D5,CR2,CS5,MN2
		DB      ENV,%00000000
		DB      C1,1
		DB      END

SEQ4::		DB      ENV,$85
		DB      MANUAL,REST,15,VIBON,8,1,2
		DB      E3,CR2,DS3,CR2,D3,CR2
		DB      CS3,DMN2
		DB      END

SEQ5::		DB      ENV,$3F
		DB      MANUAL,REST,15,VIBON,2,2,4
		DB      B4,CR2,AS4,CR2,A4,CR2
		DB      ENV,$3F,VIBON,2,2,4
		DB      GS4,CR2,ENV,$55,GS4,MN2
		DB      END

;-----------------------------------------------------------------------------
;BONUS STAR TUNE
;-----------------------------------------------------------------------------

COMPLETE1::     DB      42
		DB      6
		DB      END

COMPLETE2::     DB      7
		DB      END

COMPLETE3::     DB      8
		DB      END

COMPLETE4::     DB      31
		DB      END

;-----------------------------------------------------------------------------

SEQ6::		DB      ENV,$63
		DB      LENGTH,5
		DB      G4,E4,G4
		DB      LENGTH,6,ENV,$91
		DB      A4,F4,A4,B4,G4
		DB      LENGTH,8,ENV,$A1
		DB      B4,C5
		DB      END

SEQ7::		DB      ENV,$85
		DB      MANUAL
		DB      G3,15,A3,18,B3,20,C4,18
		DB      END

SEQ8::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB	ENV,%00100000
		DB      LENGTH,5
		DB      G4,E4,G4
		DB      LENGTH,6
		DB      A4,F4,A4,B4,G4
		DB      LENGTH,8
		DB      B4,C5
		DB      END
;-----------------------------------------------------------------------------
;BELLE'S WILDE RIDE
;-----------------------------------------------------------------------------

GAMEOVER1::     DB      0
		DB      END

GAMEOVER2::     DB      15,15,17,17,0
		DB      JUMP
		DW      GAMEOVER2

GAMEOVER3::     DB      42
		DB      TRANS,24,10,TRANS,24,11,TRANS,24,10,TRANS,24,12
		DB      TRANS,24,10,TRANS,24,11,TRANS,24,10,TRANS,24,13
		DB      TRANS,24,14,TRANS,24,14,0
		DB      JUMP
		DW      GAMEOVER3

GAMEOVER4::     DB      16
		DB      101
		DB      JUMP
		DW      GAMEOVER4

;-----------------------------------------------------------------------------

SEQ9::		DB      LENGTH,SQ3,VIBON,10,1,2
		DB      END

SEQ10::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB      LENGTH,SQ3,VIBON,1,1,2
		DB	ENV,%00100000
		DB      C3,REST,C3,G3,C3,DS3,D3,REST,D3,A2,REST,A2      ;bar1
		DB      END

SEQ11::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB	ENV,%00100000
		DB      LENGTH,SQ3,VIBON,1,1,2
		DB      DS3,REST,DS3,AS2,REST,DS3,D3,REST,D3,A2,F2,DS2  ;BAR2
		DB      END

SEQ12::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB	ENV,%00100000
		DB      LENGTH,SQ3,VIBON,1,1,2
		DB      DS3,REST,DS3,DS3,D3,DS3,F3,REST,F3,C3,A2,F2
		DB      END

SEQ13::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB	ENV,%00100000
		DB      LENGTH,SQ3,VIBON,1,1,2
		DB      DS3,REST,DS3,DS3,D3,DS3,F3,REST,REST,F3,REST,F3
		DB      END

SEQ14::		DB      MANUAL
		DB      WAVE
		DB      $00,$12,$23,$44,$56,$67,$88,$9A
		DB      $AB,$BB,$BB,$BB,$BB,$97,$53,$10
		DB	ENV,%00100000
		DB      VIBON,1,1,2
		DB      MANUAL,G3,DQV3,LENGTH,SQ3,G3,DS3,G3,F3,REST
		DB      F3,MANUAL,C3,QV3,C3,SQ3,AS3,DQV3,LENGTH,SQ3,AS3,F3
		DB      AS3,A3,REST,A3,MANUAL,F3,QV3,F3,SQ3
		DB      G3,DQV3,LENGTH,SQ3,G3,DS3,G3,F3,REST,F3
		DB      MANUAL,C3,QV3,LENGTH,SQ3,F3
		DB      DS3,REST,DS3,D3,C3,AS2,MANUAL,C3,QV3,C3,SQ3,C3,DQV3
		DB      END

SEQ15::		DB      MANUAL,ENV,$47
		DB      C3,SQ3,REST,SQ3,C3,SQ3,G3,QV3,C3,SQ3,D3,SQ3
		DB      REST,SQ3,D3,SQ3,A3,QV3,D3,SQ3
		DB      DS3,SQ3,REST,SQ3,DS3,SQ3,AS3,QV3,DS3,SQ3
		DB      LENGTH,SQ3,D3,REST,D3,A3,F3,D3,MANUAL
		DB      C3,SQ3,REST,SQ3,C3,SQ3,G3,QV3,C3,SQ3,D3,SQ3
		DB      REST,SQ3,D3,SQ3,A3,QV3,D3,SQ3
		DB      DS3,SQ3,REST,SQ3,DS3,SQ3,AS3,QV3,DS3,SQ3,F3,DQV3,A2,DQV3
		DB      END

SEQ16::		DB      LENGTH,SQ3
		DB      END

SEQ17::		DB      MANUAL,ENV,$93,ARPON,FIFTHS
		DB      C3,CR3+SQ3,C3,SQ3,AS2,CR3+SQ3,AS2,SQ3
		DB      DS3,CR3+SQ3,DS3,SQ3,D3,CR3+SQ3,D3,SQ3
		DB      C3,CR3+SQ3,C3,SQ3,AS2,CR3+SQ3,AS2,SQ3
		DB      DS2,DQV3,AS2,DQV3,C3,DCR3,ARPOFF
		DB      END
;----------------------------------------------------------------------------
;SHOOTING GALLERY
;----------------------------------------------------------------------------

INGAME1::       DB      42
		DB      18,20
		DB      JUMP
		DW      INGAME1

INGAME2::       DB      31
		DB      END

INGAME3::       DB      TRANS,12,19,TRANS,12,21
		DB      JUMP
		DW      INGAME3

INGAME4::       DB      LOOP,255,102    ;,102,103,103,104,104
		DB      END

;----------------------------------------------------------------------------

SEQ18::		DB      ENV,$75
		DB      LENGTH,CR4
		DB      C3,A3,A3,E3,B3,B3,F3,C4,C4,B3,G3,E3
		DB      C3,A3,A3,E3,B3,B3,C4,B3,C4,MANUAL,A3,MN4
		DB      LENGTH,CR4,G3
		DB      C3,A3,A3,E3,B3,B3,F3,C4
		DB      LENGTH,QV4,C4,A3,LENGTH,CR4,B3,G3,E3
		DB      C3,A3,A3,E3,B3,B3,C4,B3,C4,MANUAL,D4,DMN4
		DB      END


SEQ19::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      ENV,%00100000
		DB      LENGTH,CR4
		DB      C3,A3,A3,E3,B3,B3,F3,C4,C4,B3,G3,E3
		DB      C3,A3,A3,E3,B3,B3,C4,B3,C4,MANUAL,A3,MN4
		DB      LENGTH,CR4,G3
		DB      C3,A3,A3,E3,B3,B3,F3,C4
		DB      LENGTH,QV4,C4,A3,LENGTH,CR4,B3,G3,E3
		DB      C3,A3,A3,E3,B3,B3,C4,B3,C4,MANUAL,D4,DMN4
		DB      END


SEQ20::		DB      ENV,$82
		DB      MANUAL,E4,MN4,LENGTH,CR4,E4,D4,B3,LENGTH,QV4,G3,C3
		DB      LENGTH,CR4,C4,A3,C4,B3,G3,LENGTH,QV4,E3,C3
		DB      MANUAL,A3,MN4,LENGTH,CR4,A3,G3,E3,LENGTH,QV4,C3,B2
		DB      LENGTH,CR4,D3,E3,D3
		DB      MANUAL,C3,DMN4
		DB      END

SEQ21::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      MANUAL,E4,MN4,LENGTH,CR4,E4,D4,B3,LENGTH,QV4,G3,C3
		DB      LENGTH,CR4,C4,A3,C4,B3,G3,LENGTH,QV4,E3,C3
		DB      MANUAL,A3,MN4,LENGTH,CR4,A3,G3,E3,LENGTH,QV4,C3,B2
		DB      LENGTH,CR4,D3,E3,D3
		DB      MANUAL,C3,DMN4
		DB      END

;-----------------------------------------------------------------------------
;INTRO TUNE
;-----------------------------------------------------------------------------

INTRO1::	DB      42
		DB      LOOP,4,27,26,27,27
		DB      JUMP
		DW      INTRO1
		DB      END

INTRO2::	DB      0
		DB      JUMP
		DW      INTRO2
		DB      END

INTRO3::	DB      42,TRANS,12,24,TRANS,12,25,27,27
		DB      JUMP
		DW      INTRO3
		DB      END

INTRO4::	DB      103
		DB      JUMP
		DW      INTRO4
		DB      END

;;----------------------------------------------------------------------------

SEQ22::		DB      LENGTH,CR4
		DB      ENV,$75
		DB      C2,G1,D2,A1
		DB      END

SEQ23::		DB      ENV,$75,MANUAL
		DB      C4,MN4,D4,MN4
		DB      LENGTH,QV4,C4,C4,B3,A3
		DB      MANUAL,D4,MN4
		DB      END

SEQ24::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      LENGTH,QV4
		DB      C4,REST,G4,REST,G4,REST
		DB      MANUAL,D4,MN4,REST,CR4
		DB      LENGTH,QV4
		DB      DS4,REST,D4,REST,C4,REST
		DB      MANUAL,D4,MN4,A3,CR4
		DB      LENGTH,QV4
		DB      C4,REST,G4,REST,G4,REST
		DB      MANUAL,D4,MN4,C4,QV4,D3,QV4
		DB      LENGTH,QV4
		DB      DS4,REST,D4,REST,C4,REST
		DB      MANUAL,D4,MN4,REST,CR4
		DB      END

SEQ25::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      LENGTH,QV4
		DB      C4,REST,G4,REST,G4,REST
		DB      MANUAL,D4,MN4,REST,CR4
		DB      LENGTH,QV4
		DB      DS4,REST,D4,REST,C4,REST
		DB      MANUAL,D4,MN4,A3,CR4
		DB      LENGTH,QV4
		DB      C4,REST,G4,REST,G4,REST
		DB      MANUAL,D4,MN4,C4,QV4,D3,QV4
		DB      LENGTH,QV4
		DB      DS4,REST,D4,REST,DS4,REST
		DB      MANUAL,F4,MN4,REST,CR4
		DB      END

SEQ26::		DB      LENGTH,DMN4,ENV,$54
		DB      C3,G2
		DB      LENGTH,CR4,DS3,D3,C3
		DB      MANUAL,D3,DMN4
		DB      LENGTH,DMN4,ENV,$54
		DB      C3,G2
		DB      LENGTH,CR4,DS3,D3,DS4
		DB      MANUAL,REST,DMN4
		DB      END

SEQ27::		DB      MANUAL,REST,DSB4
		DB      END

SEQ31::		DB      REST,1
		DB      END

;---------------CHOPPIN' WOOD SONG--------------------------------------

FXA1::		DB      42
		DB      LOOP,2,TRANS,-12,28
		DB      LOOP,2,TRANS,-10,28
		DB      JUMP
		DW      FXA1
		DB      END

FXA2::		DB      LOOP,4,30,TRANS,-24,29
		DB      LOOP,4,30,TRANS,-22,29
		DB      JUMP
		DW      FXA2
		DB      END

FXA3::		DB      42,83
		DB      JUMP
		DW      FXA3
		DB      END

FXA4::		DB      104,105
		DB      JUMP
		DW      FXA4
		DB      END

;----------------------------------------------------------------------------

SEQ28::		DB      ENV,$C1
		DB      LENGTH,QV3
		DB      C4,C4,B3,B3,A3,A3
		DB      LENGTH,SQ3,G3,A3,B3,G3
		DB      LENGTH,QV3
		DB      C4,C4,B3,B3,A3,A3
		DB      MANUAL,G3,DQV3,G3,SQ3
		DB      LENGTH,QV3
		DB      C4,C4,B3,B3,A3,A3
		DB      LENGTH,SQ3,G3,A3,B3,G3
		DB      LENGTH,QV3
		DB      C4,C4,G3,G3,C4,REST,REST
		DB      LENGTH,SQ3,REST,G3
		DB      END

SEQ29::		DB      MANUAL
		DB      VIBON,2,1,2
		DB      ENV,$B7
		DB      C5,CR3,D5,QV3,C5,QV3,E5,QV3,G5,DCR3
		DB      A5,QV3,G5,DCR3,E5,QV3,C5,CR3,REST,QV3
		DB      C5,CR3,D5,QV3,C5,QV3,E5,QV3,G5,DCR3
		DB      A5,QV3,G5,CR3,E5,QV3,C5,QV3,REST,DCR3
		DB      END

SEQ30::		DB      REST,SB3
		DB      END

SEQ83::		DB      MANUAL
		DB	ENV,%00000000
		DB      REST,1
		DB      END







;---------------MAIN THEME----------------------------------------------------------

FXB1::		DB      42
		DB      36,32
		DB      JUMP
		DW      FXB1

FXB2::		DB      37,33
		DB      JUMP
		DW      FXB2

FXB3::		DB      42,34,TRANS,12,35,34,TRANS,12,38
		DB      JUMP
		DW      FXB3

FXB4::		DB      34,34,LOOP,2,106
		DB      JUMP
		DW      FXB4
;-------------------------------------------------------------------------------




SEQ32::		DB      ENV,$D2
		DB      LENGTH,CR4
		DB      C3,G3,G3,G2,G3,G3,C3,G3,G3,G2,G3,G3
		DB      C3,G3,G3,G2,G3,G3,C3,REST,REST
		DB      G2,A2,B2
		DB      END


SEQ33::		DB      ENV,$75
		DB      LENGTH,CR4
		DB      REST,C4,C4
		DB      REST,B3,B3
		DB      REST,C4,C4
		DB      REST,B3,B3
		DB      REST,C4,C4
		DB      REST,B3,B3
		DB      C4,REST,REST
		DB      G3,A3,B3
		DB      END


SEQ34::		DB      LENGTH,SB4,REST,REST,REST,REST,REST,REST
		DB      END

SEQ35::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      ENV,%00100000
		DB      G4,MN4,C5,CR4,B4,MN4,A4,CR4
		DB      G4,MN4,F4,CR4,E4,MN4,D4,QV4,REST,QV4
		DB      G4,MN4,F4,CR4,E4,MN4,D4,CR4
		DB      C4,DMN4,G3,CR4,A3,CR4,B3,CR4
		DB      END

SEQ36::		DB      ENV,$D2
		DB      LENGTH,CR4
		DB      C3,G3,G3,G2,G3,G3,F2,F3,F3,G2,G3,G3
		DB      C3,G3,G3,G2,G3,G3,C3,REST,REST
		DB      G2,A2,B2
		DB      END

SEQ37::		DB      ENV,$75
		DB      LENGTH,CR4
		DB      REST,C4,C4
		DB      REST,B3,B3
		DB      REST,A3,A3
		DB      REST,B3,B3
		DB      REST,C4,C4
		DB      REST,B3,B3
		DB      C4,REST,REST
		DB      G3,A3,B3
		DB      END

SEQ38::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      ENV,%00100000
		DB      G4,MN4,C5,CR4,B4,MN4,A4,CR4
		DB      G4,MN4,C5,CR4,D5,MN4,G4,CR4
		DB      G4,MN4,F4,CR4,E4,MN4,D4,CR4
		DB      C4,DMN4,REST,DMN4
		DB      END
;---------------------------------------------------------------------------

WANKER1::       DB      42
		DB      TRANS,-12,39
		DB      JUMP
		DW      WANKER1

WANKER2::       DB      0
		DB      JUMP
		DW      WANKER2

WANKER3::       DB      43,44			;41
		DB      JUMP
		DW      WANKER3

WANKER4::       DB      107
		DB      JUMP
		DW      WANKER4
;---------------------------------------------------------------------------

SEQ39::		DB      ENV,$A5
		DB      C4,DCR2,C4,QV2,B3,DCR2,B3,QV2
		DB      A3,DCR2,A3,QV2,G3,DCR2,G3,QV2
		DB      F3,DCR2,F3,QV2,E3,DCR2,E3,QV2
		DB      D3,DCR2,D3,QV2,G3,DCR2,G3,QV2
		DB      END

SEQ40::		DB      MANUAL,REST,CR2
		DB      LENGTH,MN2
		DB      ARPON,FIFTHS
		DB      ENV,$77
		DB      C4,B3,A3,G3,F3,E3,D3
		DB      MANUAL,G3,CR2
		DB      END


SEQ41::		DB      LENGTH,SB2
		DB      REST,REST,REST,REST
		DB      END

SEQ43::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      ENV,%00100000
		DB      LENGTH,QV2
		DB      C5,D5,E5,F5,G5,F5,E5,D5
		DB      C5,D5,E5,C5
		DB      LENGTH,CR2
		DB      E5,D5
		DB      LENGTH,QV2
		DB      C5,D5,E5,F5,G5,F5,E5,D5
		DB      C5,D5,E5,C5
		DB      LENGTH,MN2
		DB      D5
		DB      END

SEQ44::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      VIBON,2,1,2
		DB      ENV,%00100000
		DB      LENGTH,QV2
		DB      C5,D5,E5,F5,G5,F5,E5,D5
		DB      A5,B5,C6,G5
		DB      LENGTH,CR2
		DB      B5,A5
		DB      LENGTH,QV2
		DB      C6,B5,A5,G5,B5,A5,G5,F5
		DB      A5,G5,F5,E5
		DB      LENGTH,MN2
		DB      D5
		DB      END

;---------------------------------------------------------------------------

GAYSONG1::      DB      42
		DB      45,45,45,48,49
		DB      JUMP
		DW      GAYSONG1

GAYSONG2::      DB      0
		DB      JUMP
		DW      GAYSONG2

GAYSONG3::      DB      42
		DB      TRANS,12,46,47
		DB      JUMP
		DW      GAYSONG3

GAYSONG4::      DB      108
		DB      JUMP
		DW      GAYSONG4
;---------------------------------------------------------------------------


SEQ45::		DB      LENGTH,QV4,GLIOFF
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,C2,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,C2,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      END

SEQ46::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      ENV,%00100000
		DB      C4,CR4,REST,QV4,C4,QV4,D4,CR4,C4,QV4,REST,QV4
		DB      E4,CR4,G4,QV4,REST,QV4,A4,CR4,G4,QV4,REST,QV4
		DB      C4,CR4,REST,QV4,C4,QV4,D4,CR4,C4,QV4,REST,QV4
		DB      E4,CR4,G4,QV4,REST,QV4,D4,MN4
		DB      C4,CR4,REST,QV4,C4,QV4,D4,CR4,C4,QV4,REST,QV4
		DB      E4,CR4,G4,QV4,REST,QV4,A4,CR4,G4,QV4,REST,QV4
		DB      LENGTH,QV4,C5,REST,REST,A4,G4,REST,F4,REST
		DB      E4,REST,D4,REST
		DB      LENGTH,MN4,C4
		DB      END

SEQ47::		DB      LENGTH,SB4,GLIOFF
		DB      REST,REST
		DB      REST,REST
		DB      END


SEQ48::		DB      LENGTH,QV4,GLIOFF
		DB      ENV,$F1,F1,REST
		DB      ENV,$A1,F1,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$D1,A1,REST
		DB      B1,REST
		DB      C2,REST
		DB      REST,REST
		DB      END

SEQ49::		DB      LENGTH,QV4,GLIOFF
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,C2,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,C2,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,C2,REST
		DB      ENV,$F1,G1,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$F1,C2,REST
		DB      ENV,$A1,G1,REST
		DB      ENV,$F1,A1,REST
		DB      ENV,$A1,B1,REST
		DB      END


SEQ108::	DB      LENGTH,QV4,DRUM,6,REST,DRUM,11,DRUM,10
		DB      DRUM,11,REST,DRUM,10,REST
		DB      END
;--------------------------------------------------------------------------

MANU1::		DB      42,56
		DB      JUMP
		DW      MANU1

MANU2::		DB      56;52,52,55
		DB      JUMP
		DW      MANU2

MANU3::		DB      42
		DB      51,57,51,53,56,56
		DB      JUMP
		DW      MANU3

MANU4::		DB      LOOP,4,109
		DB      JUMP
		DW      MANU4

SEQ109::	DB      LENGTH,QV4,DRUM,6,REST,DRUM,11,DRUM,11,DRUM,11,REST
		DB      END

SEQ50::		DB      LENGTH,CR4,ENV,$A4
		DB      C2,C3,C3
		DB      D2,A2,A2
		DB      G1,B2,B2
		DB      D2,D3,D3
		DB      END

;		DB      ENV,$A4,C2,ENV,$74,E2,G2
;		DB      ENV,$A4,D2,ENV,$74,FS2,A2
;		DB      ENV,$A4,E2,ENV,$74,G2,B2
;		DB      ENV,$A4,D2,ENV,$74,FS2,A2
;		DB      END

SEQ51::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      ENV,%01000000
		DB      VIBON,1,2,4
		DB      C6,DMN4,LENGTH,CR4
		DB      FS5,G5,A5
		DB      LENGTH,DMN4,B5,D5
		DB      C6,LENGTH,CR4
		DB      FS5,G5,A5,B5,A5,LENGTH,QV4,G5,FS5
		DB      LENGTH,CR4,E5,D5,C5
		DB      END

SEQ52::		DB      LENGTH,DMN4
		DB      ARPON,MAJOR
		DB      ENV,$66
		DB      C3,D3,ARPON,MINOR
		DB      E3,ARPON,MAJOR,D3
		DB      END

SEQ53::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      ENV,%01000000
		DB      VIBON,1,2,4
		DB      C6,DMN4,LENGTH,CR4
		DB      C6,D6,A5
		DB      LENGTH,DMN4,B5,D6
		DB      C6,LENGTH,CR4
		DB      FS5,G5,A5,B5,A5,LENGTH,QV4,G5,FS5
		DB      LENGTH,CR4,E5,D5,C5
		DB      END

SEQ54::		DB      LENGTH,CR4
		DB      ENV,$A4,C2,ENV,$74,E2,G2
		DB      ENV,$A4,C3,ENV,$74,G2,E2
		DB      ENV,$A4,G1,ENV,$74,B1,D2
		DB      ENV,$A4,G2,ENV,$74,D2,B1
		DB      ENV,$A4,C2,ENV,$74,E2,G2
		DB      ENV,$A4,C3,ENV,$74,G2,D2
		DB      ENV,$A4,E2,ENV,$74,G2,B2
		DB      ENV,$A4,G1,ENV,$74,B1,D2
		DB      END

SEQ55::		DB      LENGTH,DMN4
		DB      ARPON,MAJOR
		DB      ENV,$66
		DB      C3,C3,G3,G3,C3,C3,ARPON,MINOR,E3
		DB      ARPON,MAJOR,G2
		DB      END

SEQ56::		DB      MANUAL,REST,DMN4
		DB      END

SEQ57::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB      POKE,255&rNR51,$FF
		DB      ENV,%01000000
		DB      VIBON,1,2,4
		DB      C6,DMN4,LENGTH,CR4
		DB      C6,D6,A5
		DB      LENGTH,DMN4,B5,D5
		DB      C6,LENGTH,CR4
		DB      FS5,G5,A5,B5,A5,LENGTH,QV4,G5,FS5
		DB      LENGTH,CR4,E5,D5,C5
		DB      END

;-----------------------------------------------------------------------

CHAMPIONS1::    DB      42,60
		DB      JUMP
		DW      CHAMPIONS1

CHAMPIONS2::    DB      59,59,63
		DB      JUMP
		DW      CHAMPIONS2

CHAMPIONS3::    DB      42,64
		DB      TRANS,12,61,62
		DB      JUMP
		DW      CHAMPIONS3

CHAMPIONS4::    DB      LOOP,4,56
		DB      JUMP
		DW      CHAMPIONS4

SEQ58::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%01000000
		DB      LENGTH,CR4
;		DB      VIBON,0,2,2
		DB      C5,E5,G5,C6,G5,E5
		DB      D5,F5,A5,D6,A5,F5
		DB      E5,G5,B5,E6,B5,G5
		DB      F5,A5,C6,E5,G5,D5
		DB      END

SEQ59::		DB      ARPON,MAJOR
		DB      ENV,$87
		DB      MANUAL
		DB      C3,DSB4
		DB      ARPON,MINOR,D3,SB4+CR4,D3,CR4,E3,DSB4
		DB      ARPON,MAJOR,F3,DMN4
		DB      ARPON,MINOR,E3,MN4,D3,CR4
		DB      END

SEQ60::		DB      ENV,$A7
		DB      LENGTH,CR4
;		DB      VIBON,0,2,2
		DB      C2,E2,G2,C3,G2,E2
		DB      D2,F2,A2,D3,A2,F2
		DB      E2,G2,B2,E3,B2,G2
		DB      F2,A2,C3,E2,G2,D2
		DB      END


SEQ61::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      LENGTH,QV4
		DB      REST,REST
		DB      C5,GLION,2,4,B4
		DB      GLION,-2,4,C5,GLION,2,4,B4
		DB      GLIOFF,LENGTH,CR4,C5,B4,C5
		DB      LENGTH,DMN4-10,D5,LENGTH,DMN4+10
		DB      GLION,10,16,A4,GLIOFF
		DB      LENGTH,QV4
		DB      REST,REST
		DB      E5,GLION,4,4,D5
		DB      GLION,-4,4,E5,GLION,4,4,D5
		DB      GLIOFF,LENGTH,CR4,E5,D5,E5
		DB      LENGTH,DMN4,F5
		DB      LENGTH,CR4,F5,E5,D5
		DB      END

SEQ62::		DB      LENGTH,DSB4,REST,REST,REST,REST
		DB      END

SEQ63::		DB      ARPON,MAJOR
		DB      ENV,$B7
		DB      MANUAL
		DB      C3,DSB4
		DB      ARPON,MINOR,D3,SB4+CR4,D3,CR4,E3,DSB4
		DB      ARPON,MAJOR,F3,DMN4
		DB      ARPON,MINOR,E3,MN4,D3,CR4
		DB      END

SEQ64::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      MANUAL
		DB      REST,MN4
		DB      C5,CR4-10,GLION,-14,16,G5,MN4
		DB      GLION,14,16,C5,CR4+10,GLIOFF
		DB      REST,MN4
		DB      D5,CR4-10,GLION,-14,16,A5,MN4
		DB      GLION,14,16,D5,CR4+10,GLIOFF
		DB      REST,MN4
		DB      E5,CR4-10,GLION,-14,16,B5,MN4
		DB      GLION,14,16,E5,CR4+10,GLIOFF
		DB      F5,DMN4,F5,CR4,E5,CR4,D5,CR4
		DB      END

;--------------------------------------------------------------------

TWOONE1::       DB      42,56
		DB      JUMP
		DW      TWOONE1

TWOONE2::       DB      TRANS,-12,65,68
		DB      TRANS,-10,65,TRANS,2,68
		DB      JUMP
		DW      TWOONE2

TWOONE3::       DB      42,66,67,66,69
		DB      TRANS,2,66,TRANS,2,67
		DB      TRANS,2,66,TRANS,2,69
		DB      JUMP
		DW      TWOONE3

TWOONE4::       DB      110
		DB      JUMP
		DW      TWOONE4

SEQ65::		DB      LENGTH,CR4
		DB      ENV,$B3,C3,ENV,$83,C3
		DB      ENV,$B3,G3,ENV,$83,G3
		DB      ENV,$B3,DS3,ENV,$83,DS3
		DB      ENV,$B3,AS3,ENV,$83,AS3
		DB      ENV,$B3,C3,ENV,$83,C3
		DB      ENV,$B3,G3,ENV,$83,G3
		DB      ENV,$B3,DS3,ENV,$83,DS3
		DB      ENV,$B3,D3,ENV,$83,AS2
		DB      END

SEQ110		DB      LENGTH,QV4,DRUM,11,REST,DRUM,11,DRUM,11
		DB      END

SEQ66::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%01000000
		DB      MANUAL
		DB      LENGTH,QV4,REST,REST
		DB      G5,F5,G5,F5,REST,G5
		DB      REST,F5,G5,F5,G5,F5,DS5,D5
		DB      END

SEQ67::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%01000000
		DB      MANUAL
		DB      LENGTH,QV4,REST,REST
		DB      G5,F5,G5,F5,REST,G5
		DB      REST,G5,AS5,REST
		DB      LENGTH,MN4,DS5
		DB      END

SEQ68::		DB      LENGTH,CR4
		DB      ENV,$B3,C2,ENV,$83,C2
		DB      ENV,$B3,G2,ENV,$83,G2
		DB      ENV,$B3,DS2,ENV,$83,DS2
		DB      ENV,$B3,AS2,ENV,$83,AS2
		DB      LENGTH,MN4
		DB      ENV,$B6
		DB      C2,DS2,F2,D2
		DB      END

SEQ69::		DB      LENGTH,SB4,REST,REST
		DB      END
;----------------------------------------------------------------------------

MUFC1::		DB      42,71
		DB      JUMP
		DW      MUFC1

MUFC2::		DB      56,72
		DB      JUMP
		DW      MUFC2

MUFC3::		DB      42,70
		DB      JUMP
		DW      MUFC3

MUFC4::		DB      73,73,111,111,111,111,111,111,111,112
		DB      JUMP
		DW      MUFC4

SEQ111::	DB      LENGTH,QV4,DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      END

SEQ112::	DB      LENGTH,QV4,DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      DRUM,11,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      END

SEQ70::		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      MANUAL,VIBON,8,1,2
		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,D5,REST
		DB      LENGTH,CR4,D5,FS5,LENGTH,QV4,A5,REST
		DB      LENGTH,DMN4,A5,LENGTH,CR4,REST,REST,REST
		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,D5,REST
		DB      LENGTH,CR4,D5,FS5,LENGTH,QV4,A5,REST
		DB      LENGTH,DMN4,A5,LENGTH,CR4,REST,REST,REST
		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,CS5,REST
		DB      LENGTH,CR4,CS5,E5,LENGTH,QV4,B5,REST
		DB      LENGTH,DMN4,B5,LENGTH,CR4,REST,REST,REST

		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,CS5,REST
		DB      LENGTH,CR4,CS5,E5,LENGTH,QV4,B5,REST
		DB      LENGTH,DMN4,B5,LENGTH,CR4,REST,REST,REST

		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,D5,REST
		DB      LENGTH,CR4,D5,FS5,LENGTH,QV4,A5,REST
		DB      LENGTH,DMN4,D6,LENGTH,CR4,REST,REST,REST
		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,D5,REST
		DB      LENGTH,CR4,D5,FS5,LENGTH,QV4,A5,REST
		DB      LENGTH,DMN4,D6,LENGTH,CR4,REST,REST,REST

		DB      LENGTH,CR4,REST,REST,LENGTH,QV4,E5,REST
		DB      LENGTH,CR4,E5,G5,LENGTH,QV4,B5,REST
		DB      LENGTH,DMN4+CR4,B5,LENGTH,CR4,GS5,A5

		DB      LENGTH,DMN4+CR4,FS6,LENGTH,CR4,D6
		DB      LENGTH,QV4,FS5,REST
		DB      MANUAL,FS5,MN4,E5,CR4,B5,MN4,A5,CR4,D5,DMN4

		DB      END

SEQ71::		DB      ENV,$4D,LENGTH,DSB4
		DB      REST,LENGTH,CR4,REST,REST,A3
		DB      A3,REST,FS3,FS3
		DB      LENGTH,DSB4-CR4
		DB      REST,LENGTH,CR4,REST,REST,A3
		DB      A3,REST,G3,G3
		DB      LENGTH,DSB4-CR4
		DB      REST,LENGTH,CR4,REST,REST,B3
		DB      B3,REST,G3,G3
		DB      LENGTH,DSB4-CR4
		DB      REST,LENGTH,CR4,REST,REST,B3
		DB      B3,REST,FS3,FS3

		DB      LENGTH,DSB4-CR4
		DB      REST,LENGTH,CR4,REST,REST,D4
		DB      D4,REST,A3,A3
		DB      LENGTH,DSB4-CR4
		DB      REST,LENGTH,CR4,REST,REST,D4
		DB      D4,REST,B3,B3

		DB      MANUAL,REST,DSB4,REST,DSB4,REST,DSB4,REST,DSB4-CR4
		DB      REST,DMN4

		DB      END

SEQ72::		DB      ENV,$75,ARPON,MAJOR
		DB      LENGTH,DMN4,REST
		DB      LENGTH,DSB4,D3,REST
		DB      ARPON,SEVENTH,A2,REST
		DB      A2,REST
		DB      ARPON,MAJOR,D3,REST,D3,REST
		DB      ARPON,EDB,B2,REST
		DB      ARPON,SEVENTH,A2
		DB      ARPON,MAJOR,D3
		DB      LENGTH,DMN4,ARPON,EDB,B2
		DB      ARPON,SEVENTH,A2
		DB      ARPON,MAJOR,D3
		DB      END

SEQ73::		DB      MANUAL,REST,DMN4
		DB      END

;--------------------------------------------------------------------

GAYJAMES1::     DB      42
		DB      74,74,74,75,75
		DB      JUMP
		DW      GAYJAMES1

GAYJAMES2::     DB      76,76,76,81,81
		DB      JUMP
		DW      GAYJAMES2

GAYJAMES3::     DB      42,TRANS,-12,79,TRANS,-12,80,TRANS,-12,79,75,75
		DB      JUMP
		DW      GAYJAMES3

GAYJAMES4::     DB      78,82
		DB      JUMP
		DW      GAYJAMES4

SEQ74::		DB      LENGTH,SQ3,ENV,$A1
		DB      C2,REST,C2,REST,C2,REST,C2,C2
		DB      REST,C2,REST,C2,C2,REST,C2,REST
		DB      F2,REST,F2,REST,F2,REST,F2,G2
		DB      REST,G2,REST,G2,G2,REST,G2,REST
		DB      END

SEQ75::		DB      MANUAL,REST,SB3,REST,SB3
		DB      END

SEQ76::		DB      MANUAL,ENV,$A5,ARPON,MAJOR
		DB      C3,SB3,F3,MN3,G3,MN3
		DB      END

SEQ77::		DB      LENGTH,SB3,REST,REST
		DB      END

SEQ78::		DB      LENGTH,CR3
		DB      REST,DRUM,1,REST,DRUM,1
		DB      REST,DRUM,1,REST,LENGTH,QV3,DRUM,1,DRUM,1
		DB      LENGTH,CR3,REST,DRUM,1,REST,DRUM,1
		DB      REST,DRUM,1,REST,LENGTH,QV3,DRUM,1,DRUM,1
		DB      LENGTH,CR3,REST,DRUM,1,REST,DRUM,1
		DB      REST,DRUM,1,REST,LENGTH,QV3,DRUM,1,DRUM,1
		DB      END

SEQ79::		DB      MANUAL,WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$A6
		DB	ENV,%00100000
		DB      REST,CR3,C6,QV3,B5,QV3,C6,CR3,G5,CR3
		DB      LENGTH,QV3,A5,B5,A5,G5,F5,E5,D5,C5
		DB      MANUAL
		DB      END

SEQ80::		DB      MANUAL,WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$A6
		DB	ENV,%00100000
		DB      REST,CR3,C6,QV3,B5,QV3,C6,CR3,G5,CR3
		DB      LENGTH,QV3,A5,B5,A5,REST
		DB      LENGTH,MN3,G5
		DB      MANUAL
		DB      END

SEQ81::		DB      MANUAL,ENV,$85,ARPON,MAJOR
		DB      F3,MN3,G3,MN3,C3,SB3
		DB      END

SEQ82::		DB      LENGTH,QV3
		DB      DRUM,2,DRUM,11,DRUM,1,DRUM,11
		DB      DRUM,2,DRUM,11,DRUM,1,DRUM,11
		DB      DRUM,2,DRUM,11,DRUM,1
		DB      LENGTH,SQ3,DRUM,2,DRUM,11,REST,DRUM,2,REST,DRUM,12
		DB      DRUM,1,DRUM,11,DRUM,11,DRUM,11
		DB      LENGTH,QV3
		DB      DRUM,2,DRUM,11,DRUM,1,DRUM,11
		DB      DRUM,2,DRUM,11,DRUM,1,DRUM,11
		DB      DRUM,2,DRUM,11,DRUM,1
		DB      LENGTH,SQ3,DRUM,2,DRUM,11,REST,DRUM,2,REST,DRUM,12
		DB      DRUM,2,REST,DRUM,2,REST
		DB      END


;----------------------------------------------------------------------------

DAFT1::		DB      42
		DB      84
		DB      JUMP
		DW      DAFT1

DAFT2::		DB      42,89,85,90
		DB      JUMP
		DW      DAFT2

DAFT3::		DB      42,90,88,86
		DB      JUMP
		DW      DAFT3

DAFT4::		DB      42,87
		DB      JUMP
		DW      DAFT4

SEQ84::		DB      ENV,$E2,LENGTH,CR4
		DB	C2,C2,G1,G1,F1,F1,G1,A1
		DB	C2,C2,G1,G1,F1,F1,G1,LENGTH,QV4,A1,B1
		DB      END

SEQ85::		DB      ENV,$95,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		DB	G3,A3,B3,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,D4,C4,LENGTH,CR4,C4,G3
		DB	REST,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		DB	G3,A3,B3,MANUAL
		DB	C4,MN4,G3,MN4,F3,CR4,E3,CR4,C3,MN4
		DB      END


SEQ86::		DB      MANUAL,WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB      LENGTH,QV4
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	G5,C5,A5,REST,G5,G5,REST,REST
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	REST,C5,E5,F5,E5,D5,C5,D5
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	G5,C5,A5,REST,G5,G5,REST,REST
		DB	C6,C6,C6,C6,G5,G5,G5,G5
		DB	F5,F5,E5,E5,C5,C5,C5,C5
		DB      END


SEQ87::		DB      LENGTH,QV4
		DB	DRUM,1,REST,DRUM,2,REST,DRUM,12,REST,DRUM,2,DRUM,2

;		DB	MN3,DRUM,1,DRUM,2,DRUM,3,DRUM,4,DRUM,5
;		DB	DRUM,6,DRUM,7,DRUM,8,DRUM,9,DRUM,10,DRUM,11
;		DB	DRUM,12,DRUM,13,DRUM,14,DRUM,15,DRUM,16,DRUM,17
;		DB	DRUM,18,DRUM,19,DRUM,20,DRUM,21
		DB      END

SEQ88::		DB      MANUAL,WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%01000000
		DB      LENGTH,QV4
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	G5,C5,A5,REST,G5,G5,REST,REST
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	REST,C5,E5,F5,E5,D5,C5,D5
		DB	C5,G5,G5,C5,G5,G5,C5,G5
		DB	G5,C5,A5,REST,G5,G5,REST,REST
		DB	C6,C6,C6,C6,G5,G5,G5,G5
		DB	F5,F5,E5,E5,C5,C5,C5,C5
		DB      END

SEQ89::		DB      ENV,$C5,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		DB	G3,A3,B3,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,D4,C4,LENGTH,CR4,C4,G3
		DB	REST,MANUAL
		DB	C4,DMN4,LENGTH,QV4,D4,C4,REST,B3,REST,C4,REST
		DB	G3,A3,B3,MANUAL
		DB	C4,MN4,G3,MN4,F3,CR4,E3,CR4,C3,MN4
		DB      END

SEQ90::		DB	LENGTH,SB4+SB4,REST,REST,REST,REST
		DB      END

;--------------------------------------------------------------------------

JERK1::		DB      42
		DB      91,91,91,91,96
		DB      JUMP
		DW      JERK1

JERK2::		DB      42,96,92,92,96
		DB      JUMP
		DW      JERK2

JERK3::		DB      42,93,93,96,93
		DB      JUMP
		DW      JERK3

JERK4::		DB      42,LOOP,32,95,96
		DB      JUMP
		DW      JERK4

SEQ91::		DB      ENV,$85
 		DB	LENGTH,QV3
		DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		DB	D2,D2,D2,F2,REST,D2,F2,REST
		DB	AS2,F2,D2,A2,REST,AS1,B1,C2
		DB	C2,C2,C2,DS2,REST,C2,DS2,REST
		DB	GS2,DS2,C2,G2,REST,G1,AS1,B1
		DB      END

SEQ92::		DB      ENV,$A7,MANUAL
		DB	ARPON,MINOR,C3,DMN3
		DB	ARPON,MAJ2,GS2,CR3,GS2,DCR3
		DB	ARPON,MINOR,C3,QV3,REST,MN3
		DB	ARPON,MINOR,C3,DMN3
		DB	ARPON,MAJ2,GS2,CR3,GS2,DCR3
		DB	ARPON,MINOR,C3,QV3,REST,MN3
		DB	ARPON,MINOR,D3,DMN3
		DB	ARPON,MAJ2,AS2,CR3,AS2,DCR3
		DB	ARPON,MINOR,D3,QV3,REST,MN3
		DB	ARPON,MINOR,C3,DMN3
		DB	ARPON,MAJ2,GS2,CR3,GS2,DCR3
		DB	ARPON,MINOR,C3,QV3,REST,MN3
		DB      END

SEQ93::		DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$76,$54,$32,$10
		DB	ENV,%00100000
		DB	VIBON,1,2,2
		DB	C5,DMN3,DS5,QV3,C5,QV3,DS5,DCR3,C5,QV3,REST,MN3
		DB	C5,DMN3,DS5,QV3,C5,QV3,DS5,DCR3,C5,QV3,REST,MN3
		DB	D5,DMN3,F5,QV3,D5,QV3,F5,DCR3,D5,QV3,REST,MN3
		DB	C5,DMN3,DS5,QV3,C5,QV3,DS5,DCR3,C5,QV3,REST,MN3
		DB      END

SEQ94::		DB      MANUAL,ENV,$A0
		DB      REST,1,C6,1,REST,1,C6,1,REST,1,C6,1,REST,1,C6,1
		DB      ENV,$D0
		DB      REST,1,C6,1,REST,1,C6,1,REST,1,C6,1,REST,1,C6,1
		DB      ENV,$F0
		DB      REST,1,C6,1,REST,1,C6,1,REST,1,C6,1,REST,1,C6,1
		DB      REST,1,C6,1,REST,1,C6,1,REST,1,C6,1,REST,1,C6,1
		DB      ENV,$D0
		DB      REST,1,C6,1,REST,1,C6,1,REST,1,C6,1,REST,1,C6,1
		DB      END


SEQ95::		DB      LENGTH,CR3,DRUM,1,DRUM,1,DRUM,2,REST
		DB	LENGTH,QV3,DRUM,1,DRUM,1,REST,DRUM,1
		DB	DRUM,2,REST,DRUM,2,REST
		DB      END

SEQ96::		DB      LENGTH,SB3*2,REST,REST,REST,REST
		DB      END

;-----------------------------------------------------------------------

LOVE1::		DB      42
		DB      97
		DB      JUMP
		DW      LOVE1

LOVE2::		DB      42,98
		DB      JUMP
		DW      LOVE2

LOVE3::		DB      42,114,TRANS,12,100
		DB      JUMP
		DW      LOVE3

LOVE4::		DB      42,99,99,99,113
		DB      JUMP
		DW      LOVE4


SEQ97::		DB	ENV,$B3,LENGTH,CR3
		DB	C2,C2,F2,F2,C2,C2,F2,F2
		DB	C2,C2,F2,F2,C2,C2,G2,G2
		DB	C2,C2,F2,F2,C2,C2,F2,F2
		DB	G2,G2,F2,F2,G2,G2,F2,G2
		DB      END

SEQ98::		DB      ENV,$87,MANUAL
		DB	ARPON,MAJOR,C3,MN3
		DB	ARPON,MAJ1,F2,MN3
		DB	ARPON,MAJOR,REST,QV3,C3,QV3,REST,QV3,C3,QV3
		DB	ARPON,MAJ1,F2,CR3,F2,CR3
		DB	ARPON,MAJOR,C3,MN3
		DB	ARPON,MAJ1,F2,MN3
		DB	ARPON,MAJOR,C3,QV3,C3,QV3,REST,QV3,C3,QV3
		DB	ARPON,MAJ2,G2,MN3
		DB	ARPON,MAJOR,C3,MN3
		DB	ARPON,MAJ1,F2,MN3
		DB	ARPON,MAJOR,REST,QV3,C3,QV3,REST,QV3,C3,QV3
		DB	ARPON,MAJ1,F2,CR3,F2,CR3
		DB	G2,MN3
		DB	F2,MN3
		DB	G2,QV3,G2,QV3,REST,QV3,G2,QV3
		DB	F2,CR3,G2,CR3
		DB      END

SEQ99::		DB      LENGTH,SQ3
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,1,REST,DRUM,1,REST
		DB      END

SEQ113::	DB	LENGTH,SQ3
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,6,REST,DRUM,6,DRUM,6
		DB	DRUM,1,REST,DRUM,6,REST
		DB	DRUM,1,REST,DRUM,6,REST
		DB	LENGTH,CR3
		DB	DRUM,1,DRUM,6,DRUM,1,DRUM,6
		DB      END

SEQ100::	DB      MANUAL
		DB      WAVE
		DB      $01,$23,$45,$67,$89,$AB,$CD,$EF
		DB      $FE,$DC,$BA,$98,$98,$54,$32,$10
		DB	ENV,%01000000
		DB      VIBON,10,2,2
		DB	LENGTH,QV3
		DB	C5,REST,REST,C5,B4,A4,G4,REST
		DB	C5,C5,REST,C5,B4,A4,G4,REST
		DB	C5,REST,REST,C5,B4,A4,G4,REST
		DB	G4,F4,E4,D4,C4,D4,E4,REST
		DB	C5,REST,REST,C5,B4,A4,G4,REST
		DB	C5,C5,REST,C5,D5,REST,G4,REST
		DB	B4,A4,G4,B4,A4,REST,F4,REST
		DB	B4,B4,REST,G4,A4,F4,B4,G4
		DB	END

SEQ114::	DB	LENGTH,SB3*2,REST,REST,REST,REST
		DB	END

;-----------------------------------------------------------------------------
;FX STUFF AS SONGS (SEQ90-99) AND INTRO
;-----------------------------------------------------------------------------
;INTRO TUNE
;-----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;DRUM PATTERNS
;-------------

SEQ101::	DB      DRUM,12,REST,REST,DRUM,12,DRUM,12,DRUM,12
		DB      END

SEQ102::	DB      LENGTH,QV4
		DB      DRUM,10,REST,DRUM,11,DRUM,11,DRUM,11,DRUM,11
		DB      END

SEQ103::	DB      LENGTH,QV4
		DB      DRUM,10,REST,DRUM,11,DRUM,11
		DB      DRUM,11,DRUM,11
		DB      END

SEQ104::	DB      LENGTH,QV3
		DB      REST,DRUM,6,REST,DRUM,6,REST,DRUM,6,REST,DRUM,6
		DB      REST,DRUM,6,REST,DRUM,6,REST,DRUM,6
		DB      LENGTH,SQ3,REST,DRUM,6,DRUM,6,DRUM,6
		DB      LENGTH,QV3
		DB      REST,DRUM,6,REST,DRUM,6,REST,DRUM,6,REST,DRUM,6
		DB      REST,DRUM,6,REST,DRUM,6
		DB      LENGTH,SQ3,REST,DRUM,6,DRUM,6,DRUM,6
		DB      DRUM,7,DRUM,6,DRUM,6,DRUM,6
		DB      END

SEQ105::	DB      LENGTH,CR3
		DB      REST,DRUM,7,REST,DRUM,7,REST,DRUM,7,REST,DRUM,7
		DB      REST,DRUM,7,REST,DRUM,7,REST,DRUM,7,REST,DRUM,7
		DB      END


SEQ106::	DB      LENGTH,QV4
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      REST,DRUM,6,DRUM,6,DRUM,6,DRUM,6,DRUM,6
		DB      LENGTH,DMN4,REST,REST
		DB      END

SEQ107::	DB      LENGTH,CR2
		DB      REST,DRUM,6,REST,DRUM,6,REST,DRUM,6,REST,DRUM,6
		DB      REST,DRUM,6,REST,DRUM,6,REST,DRUM,6,REST,DRUM,6
		DB      END


;-----------------------------------------------------------------------------

END_COD::

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

