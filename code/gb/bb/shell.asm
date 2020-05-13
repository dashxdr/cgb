; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SHELL                                                                 **
; **                                                                       **
; ** Last modified : 15 Jun 1998                                           **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"gamebank00",HOME
		section 0


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


SHELL_START::

initstuff:

		XOR	A
		ldio	[rWX],a
		ldio	[rWY],a

		LDH	[hPosFlag],A
		ldh	[hVblSCX],a
		ldh	[hVblSCY],a

		XOR	A
		LDIO	[rSCX],A		;Reset scroll position.
		LDIO	[rSCY],A
		DEC	A
		LD	[wJoy1Cur],A
		LDIO	[rLYC],A		;disable interrupt

		LD	A,LOW(LycDoNothing)	;Vector LYC and VBL interrupts to
		LD	[wLycVector],A		;harmless code.
		LD	A,LOW(VblDoNothing)
		LD	[wVblVector],A

		LD	A,$40			;Set LCDC interrupt to LYC
		LDIO	[rSTAT],A		;detection, and then clear
		XOR	A			;out pending interrupts.
		LDIO	[rIF],A			;

		LD	A,%10000111
		LDH	[hLycLCDC],A
		LD	A,%10000111
		LDH	[hVblLCDC],A

		LD	A,LOW(LycNormal)
		LD	[wLycVector],A
		LD	A,LOW(VblNormal)
		LD	[wVblVector],A

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,0
		jr	z,.aok
		inc	a
.aok:

		LD	A,HIGH(wOamShadow)	;Initialize OAM shadow
		LDH	[hOamPointer],A		;buffer.

		CALL	SprBlank		;Blank out the OAM_BUFFER.

		LD	A,HIGH(wOamShadow)	;And copy it to the OAM RAM.
		LDH	[hOamFlag],A

		LD	A,$FF			;Enable pause mode.
		LD	[wJoy1Cur],A

		LD	A,HIGH(wOamShadow)	;Signal VBL to update OAM RAM and
		LDH	[hOamFlag],A		;character sprites.
		LDH	[hPosFlag],A

		LD	A,%11010010
		LD	[wGmbPal2],A

		call	InitAutoRepeat

		ret

ShellCode::

		call	initstuff

		call	normalgmbfade

		ld	a,BANK(doshell)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		jp	doshell


normalgmbfade::
		LD	A,%11100100		;Initialize screen fade.
		LD	[wFadeVblBGP],A
		LD	[wFadeOBP0],A
		LD	[wFadeLycBGP],A
		LD	A,[wGmbPal2]
		LD	[wFadeOBP1],A
		ret


sprblank::	ld	hl,wOamShadow
		ld	c,160/8
		xor	a
.blp:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.blp
		LD	A,HIGH(wOamShadow)	;And copy it to the OAM RAM.
		LDH	[hOamFlag],A
		ret

;returns a=random # 00-ff
;preserves everything else
random::	push	hl
		push	de
		ld	hl,wRandTake
		inc	[hl]
		ld	a,[hl]
		cp	55
		jr	c,.mok
		xor	a
		ld	[hl],a
.mok:		ld	hl,wRandomBlock
		ld	d,h
		ld	e,l
		add	l
		ld	l,a
		ld	a,[wRandTake]
		sub	31
		jr	nc,.aok
		add	55
.aok:		add	e
		ld	e,a
		ld	a,[de]
		xor	[hl]
		ld	[hl],a
		pop	de
		pop	hl
		ret





addahl::	add	l
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		ret


bank_link::	ldh	a,[hRomBank]
		push	af
		ld	a,[wShellVect+3]
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,[wShellAcc]
		call	wShellVect
		ld	[wShellVect+3],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,[wShellVect+3]
		ret



SHELL_END::

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SHELL.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
