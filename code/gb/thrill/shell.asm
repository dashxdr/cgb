
		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"

		section	26

SHOWCOPYRIGHT	EQU	01	;enable/disable copyright and intro stuff


MAXTUNE		EQU	10
MAXSFX		EQU	$58

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INTERFACE DmaBitbox20x18
		INTERFACE pintest
		INTERFACE Menu
		INTERFACE Menu2
		INTERFACE Menu3
		INTERFACE EnterHigh
		INTERFACE ShowHigh
		INTERFACE CheckHighs
		INTERFACE Menu6

; ***************************************************************************
; * ClrRect18 ()                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      HL   = Ptr to chr data                                      *
; *                                                                         *
; *             also ...                                                    *
; *                                                                         *
; *             hSprXLo       = X coordinate                                *
; *             hSprYLo       = Y coordinate                                *
; *             hSprCnt       = # of 8-pixel wide strips                    *
; *             wJmpTemporary = ptr to function to dump a column            *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ClrRect18::
		LD	A,WRKBANK_BG		;point to bg work area.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		LD	DE,CodeClrColumn	;Calc address of the dump
		LD	A,[wStringH]		;code for a single column.
		SUB	80+1			;
		JR	NC,.Error		;
		CPL				;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;
		ADD	HL,DE			;
		LD	A,L			;
		LD	[wJmpTemporary+1],A	;
		LD	A,H			;
		LD	[wJmpTemporary+2],A	;

		LD	HL,TblOffset0120	;Calc X chr offset.
		LDH	A,[hSprXLo]		;
		CP	160			;
		JR	NC,.Error		;
		AND	$F8			;
		RRCA				;
		RRCA				;
		ADD	L			;
		LD	L,A			;
		JR	NC,.Skip0		;
		INC	H			;
.Skip0:		LD	A,[HLI]			;
		LD	D,[HL]			;
		LD	E,A			;

		LDH	A,[hSprYLo]		;Calc Y pxl offset.
		CP	144			;
		JR	NC,.Error		;
		LD	L,A			;
		LD	H,0			;
		ADD	HL,HL			;

		ADD	HL,DE			;Sum offsets.

		LD	DE,$0120		;Set delta to next dst column.

		LD	A,[wStringW]		;Calc number of columns
		ADD	$07			;to clear.
		AND	$F8			;
		RRCA				;
		RRCA				;
		RRCA				;
		LD	B,A			;

.Loop0:		PUSH	HL			;Preserve dst ptr.

		XOR	A			;

		CALL	wJmpTemporary		;Write a column of data.

		POP	HL			;Restore dst ptr.

		ADD	HL,DE			;Goto next dst column.

		DEC	B			;Do another column ?
		JR	NZ,.Loop0		;

		LD	A,WRKBANK_NRM		;Restore normal
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		RET				;All Done.

.Error:		JR	.Error			;

CodeClrColumn:	REPT	80			;2 bytes per line repeat.

		LD	[HLI],A			;
		LD	[HLI],A			;

		ENDR				;

		RET				;All Done.

loadbg::
		ld	hl,$c800

		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		push	bc
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	l,$10
		ld	de,$9800
		ld	a,$80
		sub	c
		ldh	[hTmpLo],a	;add for map later on
		push	hl
		ld	a,c
		swap	a
		ld	l,a
		and	$0f
		ld	h,a
		xor	l
		ld	l,a
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		pop	hl	;de=$9800-(# of chars<<4)
.dclp:		ld	a,c
		sub	$80
		ld	a,b
		sbc	0
		jr	c,.dclast
		push	bc
		ld	c,$80
		call	DumpChrs
		pop	bc
		ld	a,c
		sub	$80
		ld	c,a
		ld	a,b
		sbc	0
		ld	b,a
		jr	.dclp
.dclast:	call	DumpChrs

		pop	bc

		ld	de,$dc00
		xor	a
		call	copymap

		push	bc
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		push	hl
		ld	hl,$dc00
		ld	de,$9800
		ld	c,$40
		call	DumpChrs
		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A

		pop	hl
		ld	de,wBcpArcade
		ld	bc,$40
		call	MemCopy

		pop	bc

		ld	de,$dc00
		ldh	a,[hTmpLo]
		call	copymap

		ld	hl,$dc00
		ld	de,$9800
		ld	c,$40
		call	DumpChrs
		ret

copymap:
		push	af
		ld	a,c
		ldh	[hTmp2Lo],a
		pop	af
		push	bc
		ld	c,a
.cy:		push	bc
		push	de
.cx:		ld	a,[hli]
		add	c
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.cx
		pop	de
		pop	bc
		ld	a,e
		add	$20
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ldh	a,[hTmp2Lo]
		dec	a
		ldh	[hTmp2Lo],a
		jr	nz,.cy
		pop	bc
		ret


;****************************************************************
;****************************************************************
;****************************************************************
;*                                                              *
;*   Shell stuff using John's text & bitmap routines            *
;*                                                              *
;****************************************************************
;****************************************************************
;****************************************************************


SELDIM		EQU	1
SELBRIGHT	EQU	0

SELDIM2		EQU	1
SELBRIGHT2	EQU	0


sel_which	EQUS	"hTemp48+00"
sel_high	EQUS	"hTemp48+01"
sel_count	EQUS	"hTemp48+02"
sel_timelo	EQUS	"hTemp48+03"
sel_timehi	EQUS	"hTemp48+04"

shutdownbitmap:	call	FadeOutBlack
		di
		SETLYC	LycNormal
		SETVBL	VblNormal
		ld	a,255
		ldio	[rLYC],a
		ei
		ret


FIX5		EQU	6


ClrHigh::	PUSH	AF			;
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LDH	[hSprYLo],A		;
		LD	A,1*8			;
		LDH	[hSprXLo],A		;
		LD	A,18*8			;
		LD	[wStringW],A		;
		LD	A,8			;
		LD	[wStringH],A		;
		CALL	ClrRect18		;
		POP	AF			;
		RET				;
ClrTop::	PUSH	AF			;
		ADD	3
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LDH	[hSprYLo],A		;
		LD	A,1*8			;
		LDH	[hSprXLo],A		;
		LD	A,18*8			;
		LD	[wStringW],A		;
		LD	A,8			;
		LD	[wStringH],A		;
		CALL	ClrRect18		;
		POP	AF			;
		RET				;
ClrCenter::	PUSH	AF			;
		ADD	3
		ADD	A			;
		ADD	A			;
		ADD	A			;
		LDH	[hSprYLo],A		;
		LD	A,3*8			;
		LDH	[hSprXLo],A		;
		LD	A,14*8			;
		LD	[wStringW],A		;
		LD	A,8			;
		LD	[wStringH],A		;
		CALL	ClrRect18		;
		POP	AF			;
		RET				;

ClrAll::
		XOR	A
		LDH	[hSprYLo],A		;
		LD	A,8			;
		LDH	[hSprXLo],A		;
		LD	A,144			;
		LD	[wStringW],A		;
		LD	A,56+8			;take out +8 (TEST MENU)
		LD	[wStringH],A		;
		JP	ClrRect18		;



CpyAll:		LD	BC,$0000		;
		LD	DE,$1409		;
		CALL	DmaBitbox20x18_b	;
		LD	DE,$9800
		JP	DumpShadowAtr

CpyHigh::	PUSH	AF			;
		LD	B,$01			;
		LD	DE,$1201		;
		LD	C,A			;
		CALL	DmaBitbox20x18_b	;
		POP	AF			;
		RET				;

CpyTop::	PUSH	AF			;
		LD	BC,$0103		;
		LD	DE,$1201		;
		ADD	C			;
		LD	C,A			;
		CALL	DmaBitbox20x18_b	;
		POP	AF			;
		RET				;
CpyCenter::	PUSH	AF			;
		LD	BC,$0303		;
		LD	DE,$0e01		;
		ADD	C			;
		LD	C,A			;
		CALL	DmaBitbox20x18_b	;
		POP	AF			;
		RET				;



;c=current line #
pickfont:	jp	picklite

copyz:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,copyz
		ret

SelectSetup:
		ld	de,IDX_CDSCROLLPKG	;cdscrollpkg

MenuSetup:
		push	de
		call	SetBitmap20x18
		pop	de

		call	XferBitmap

		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		jp	FadeInBlack

GameSelectClr::
		xor	a
		ld	[sel_which],a

GameSelect::

; xor a
; call InitTune
		xor	a
		ld	[sel_timelo],a
		ld	[sel_timehi],a

		call	Sel34
		call	CpyAll

sel3loop:	call	WaitForVBL
		call	ReadJoypad
		call	ProcAutoRepeat
		ld	a,[wJoy1Hit]
		ld	c,a
		or	a
		jr	z,.nozerotime
		xor	a
		ldh	[sel_timelo],a
		ldh	[sel_timehi],a
.nozerotime:	ld	hl,sel_timelo
		inc	[hl]
		jr	nz,.no16
		inc	l
		inc	[hl]
.no16:
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		bit	JOY_L,c
		jr	nz,.leftright
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_R,c
		jr	nz,.leftright
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_B,c
		jr	nz,.back
		bit	JOY_SELECT,c
		jr	z,sel3loop
.back:		ld	a,-1
		jr	sel3done
.done:		ldh	a,[sel_which]
		jr	sel3done
.ref:		ldh	a,[sel_which]
		call	sel3disp
		jr	sel3loop

.switch:	ldh	a,[sel_which]
		push	af
		add	b
		cp	SEL3MAX
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,SEL3MAX-1
.aok:		ldh	[sel_which],a
		call	sel3disp
		pop	af
		call	sel3disp
		jp	sel3loop
.leftright:	ldh	a,[sel_which]
		cp	1
		jr	nz,.notdiff
		ld	a,[bMenus+OPT_DIFFICULTY]
		add	b
		cp	3
		jr	c,.bok
		ld	a,0
		jr	z,.bok
		ld	a,2
.bok:		ld	[bMenus+OPT_DIFFICULTY],a
		jr	.redisp
.notdiff:	or	a
		jp	nz,sel3loop
		ld	a,[wSndEffect]
		add	b
		cp	-1
		jp	z,sel3loop
		cp	MAXSFX+MAXTUNE+1
		jp	z,sel3loop
		ld	[wSndEffect],a
.redisp:		ldh	a,[sel_which]
		call	sel3disp
		jp	sel3loop

sel3done:	ret



Sel34:
		xor	a
.sel34lp:	push	af
		call	sel3disp
		pop	af
		inc	a
		cp	SEL3MAX
		jr	c,.sel34lp
		ret
sel3disp:	push	af
		call	ClrHigh
		pop	af
		ld	c,a
		ld	b,0

.normal:
		ld	hl,sel3tab
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		ld	a,c
		cp	1
		jr	nz,.gotde
		ld	a,[bMenus+OPT_DIFFICULTY]
		or	a
		jr	z,.gotde
		ld	de,msgmedium
		dec	a
		jr	z,.gotde
		ld	de,msghard
.gotde:		ld	a,c
		push	af
		call	pickfont
		ld	hl,wOamShadow
		ld	a,80
		ld	[hli],a
		ld	a,c
		add	a
		add	a
		add	a
		add	5
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		pop	af
		push	af
		or	a
		jr	nz,.notsfx
		dec	hl
		ld	a," "
		ld	[hli],a
		ld	a,[wSndEffect]
		ld	[hl],"0"-1
.d10:		inc	[hl]
		sub	10
		jr	nc,.d10
		add	"0"+10
		inc	hl
		ld	[hli],a
		xor	a
		ld	[hli],a
.notsfx:	ld	[hl],0
		ld	hl,wOamShadow
		call	DrawStringLst
		pop	af
		call	CpyHigh
;a=line #
selfixattrhigh:	ld	l,a
		ld	h,a
		ld	a,h
		LD	BC,$0100		;
		LD	DE,$1201		;
		ADD	C			;
		LD	C,A			;
		ldh	a,[sel_which]
		and	15
		cp	l
		ld	a,SELDIM
		jr	nz,.aok
		ld	a,SELBRIGHT
.aok:

		CALL	FillShadowAtr
		ld	de,$9800
		call	DumpShadowAtr
		ret

;a=line #
selfixattr:	ld	l,a
selfixattr2:	ld	h,a
		ld	a,h
		LD	BC,$0103		;
		LD	DE,$1201		;
		ADD	C			;
		LD	C,A			;
		ldh	a,[sel_which]
		and	15
		cp	l
		ld	a,SELDIM
		jr	nz,.aok
		ld	a,SELBRIGHT
.aok:

		CALL	FillShadowAtr
		ld	de,$9800
		call	DumpShadowAtr
		ret

selcenterattr:	ld	l,a
selcenterattr2:	ld	h,a
		ld	a,h
		LD	BC,$0303		;
		LD	DE,$0e01		;
		ADD	C			;
		LD	C,A			;
		ldh	a,[sel_which]
		and	15
		cp	l
		ld	a,SELDIM
		jr	nz,.aok
		ld	a,SELBRIGHT
.aok:

		CALL	FillShadowAtr
		ld	de,$9800
		call	DumpShadowAtr
		ret

;sel3title:	db	80,16,0,1
;		db	"Test Menu",0
;		db	0


sel3tab:	dw	msgsfx
		dw	msgeasy
		dw	msgsub1
		dw	msgsub2
		dw	msgsub3
		dw	msgsub4
		dw	msgsub5
		dw	msgsub6
		dw	msgsub7
		dw	msgsub8
		dw	msgsub9
		dw	msgsub10
SEL3MAX		EQU	(@-sel3tab)/2

msgsfx:		db	"SOUND",0
msgeasy:	db	"EASY",0
msgmedium:	db	"MEDIUM",0
msghard:	db	"HARD",0
msgsub1:	db	"FALCON",0
msgsub2:	db	"KISS",0
msgsub3:	db	"RAPIDS",0
msgsub4:	db	"LOOPER",0
msgsub5:	db	"RACE I",0
msgsub6:	db	"GREAT BEAR",0
msgsub7:	db	"TIDAL FORCE",0
msgsub8:	db	"RACE II",0
msgsub9:	db	"SIDEWINDER",0
msgsub10:	db	"LIGHTS OUT",0

shell1:
		CALL	SetMachineJcb		;Reset machine to known state.

	jp	domenu
testmenu:
 ld a,0
		ld	[wSelected],a
		xor	a
		ld	[bMenus+OPT_DIFFICULTY],a

shell1outer:	call	SelectSetup
shell1loop:	ld	a,[wSelected]
		ldh	[sel_which],a
		call	GameSelect
		cp	-1
		jr	z,domenu2
		ldh	a,[sel_which]
		ld	[wSelected],a
		push	af
		ld	hl,hTemp48
		ld	bc,48
		call	MemClear
		pop	af
		or	a
		jr	z,dosfx
		cp	1
		jr	z,shell1loop
		push	af
		call	shutdownbitmap
		ld	hl,wScore
		ld	bc,12
		call	MemClear
		pop	af
		sub	1
		call	pintest_b
		call	menutune
		jr	shell1outer
pintests:	call	shutdownbitmap
		ld	a,1
		ld	[bMenus+OPT_DIFFICULTY],a
		ld	a,16	;DEBUG
		call	pintest_b
		jr	shell1outer
dosfx:		ld	a,[wSndEffect]
		cp	MAXTUNE+1
		jr	c,.tune
		sub	MAXTUNE
		call	InitSfx
		jr	shell1loop
.tune:		call	InitTune
		jr	shell1loop
		GLOBAL	SoundTest
st:;		call	SoundTest
		jr	shell1loop
domenu2:
		call	shutdownbitmap
domenu:
		call	menutune
		CALL	SetMachineJcb		;Reset machine to known state.
		call	Menu3_b
		cp	-1
		jp	z,testmenu
		or	a
		jr	z,.top
		cp	1
		jr	z,.records
		call	Menu6_b
		jr	domenu
.records:	call	ShowHigh_b
		jr	domenu
.top:		call	Menu_b
		or	a
		jr	nz,domenu

;.middle:
		call	Menu2_b
		or	a
		jr	nz,.top
;		call	Menu4_b
;		or	a
;		jr	nz,.middle
		call	shutdownbitmap
		ld	a,[bMenus+OPT_NUMPLAYERS]
		inc	a
		ld	[wNumPlayers],a
		xor	a
		ld	[wActivePlayer],a
		ld	a,SUBGAME_TABLE
		call	pintest_b
		xor	a
		call	InitTune
		call	CheckHighs_b
		ld	a,[wGotHigh]
		or	a
		jp	z,domenu
		xor	a
		ld	[wGotHigh],a
		jp	domenu.records

enterhigh:	call	shutdownbitmap
		xor	a
		call	EnterHigh_b
;		call	ShowHigh_b
;		call	Menu5_b
		jp	shell1outer

	if	0
FREQ		EQU	2048-256
		di
		ld	a,$ff
		ld	[$ff24],a
		ld	[$ff25],a
		ld	[$ff26],a
		ld	a,$80
		ld	[$ff1a],a
		ld	a,$0
		ld	[$ff1b],a
		ld	a,$20
		ld	[$ff1c],a
		ld	a,FREQ
		ld	[$ff1d],a
		ld	a,$80|(FREQ>>8)
		ld	[$ff1e],a
zzz:
.lpo:		ld	de,sample
.lp:
		xor	a
		ld	[$ff1a],a
		ld	hl,$ff30
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,[de]
		inc	de
		ld	[hli],a
		ld	a,$80
		ld	[$ff1a],a
		ld	a,FREQ
		ld	[$ff1d],a
		ld	a,$80|(FREQ>>8)
		ld	[$ff1e],a

		ld	b,$6b
.w:		ld	c,8
.w2:		dec	c
		jr	nz,.w2
		dec	b
		jr	nz,.w

		ld	a,2
.w3:		dec	a
		jr	nz,.w3
;		nop
;		nop

		ld	a,d
		cp	$80
		jr	c,.lp
		jr	.lpo


		ei

	endc

		jp	shell1loop

;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************


SingleScreenNo:
		xor	a
		ld	[wAvoidIntro],a
		jr	SingleScreen
SingleScreenYes:
		ld	a,1
		ld	[wAvoidIntro],a
SingleScreen::
		push	de
		push	hl
		call	SetBitmap20x18
		pop	hl
		pop	de
		call	XferBitmap
		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	FadeInBlack
		ld	c,60*3
.wait:		call	WaitForVBL
		ld	a,[wAvoidIntro]
		or	a
		jr	z,.noskipout
		call	ReadJoypadNoReset
		ld	a,[wJoy1Hit]
		or	a
		jr	nz,.exit
.noskipout:	dec	c
		jr	nz,.wait
.exit:		jp	shutdownbitmap


doshell::
		xor	a
		ld	[wTune],a
		ld	[wSndEffect],a
;		call	InitTune
		xor	a
		ld	[wTempSelect],a

		call	checklanguage

		if	SHOWCOPYRIGHT	;COPYRIGHT + TITLE STUFF

 		call	menutune

;		ld	de,IDX_CNINPKG	;cninpkg
;		call	SingleScreenNo

		ld	de,IDX_SIERRALOGOPKG
		call	SingleScreenNo

		ld	de,IDX_CLEFTPKG	;cleftpkg
		call	SingleScreenYes

;		ld	de,IDX_DYNAMIXLOGOPKG
;		call	SingleScreenYes

		ld	de,IDX_CLEGALPKG
		call	SingleScreenNo

		endc

		jp	shell1



; ***************************************************************************
; ***************************************************************************

checklanguage:
		ld	a,[bLanguage]
		cp	5
		jr	nc,.force
		xor	$DA
		ld	c,a
		ld	a,[bLanguageHash]
		cp	c
		ret	z
.force:		xor	a
		ld	[bLanguage],a
		xor	$DA
		ld	[bLanguageHash],a
;		call	Language_b
		ret

