; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** rollup.asm                                                            **
; **                                                                       **
; ** Created : 20000505 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 09

roll_first	EQUS	"wTemp1024+64"
roll_ypos	EQUS	"wTemp1024+65"
roll_delay	EQUS	"wTemp1024+66"

rollmaplist:
		db	21
		dw	IDX_TITLECHARSRGB
		dw	IDX_TITLE2MAP
DELAYTIME	EQU	60+60

Rollup::

		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		ld	de,wPanelRGB
		ld	bc,64
		ld	hl,IDX_TITLELOGORGB
		call	MemCopyInFileSys

;		call	InitGroups
;		ld	hl,PAL_BALL
;		call	AddPalette
;		ld	hl,PAL_ARROW
;		call	AddPalette

		ld	a,BANK(Char40)
		ld	[wPinCharBank],a
		ld	hl,rollmaplist
		call	NewLoadMap
		ld	de,0
		ld	hl,0
		call	NewInitScroll

;		ld	a,1
;		ld	[roll_first],a

		call	FadeInBlack
		ld	a,1
		ld	[roll_delay],a

rolluploop:
		call	WaitForVBL

;		call	InitFigures
;		call	OutFigures

;		ld	a,[roll_first]
;		or	a
;		jr	z,.nofade
;		xor	a
;		ld	[roll_first],a
;		call	FadeInBlack
;.nofade:

		ld	hl,roll_delay
		ld	a,[hl]
		or	a
		jr	z,.yep
		ld	a,255
		ldio	[rLYC],a
		inc	[hl]
		ld	a,[hl]
		cp	DELAYTIME
		jr	c,.nope
		ld	[hl],0
		ld	a,[roll_ypos]
		cp	144
		jr	z,.done
		di
		SETLYC	LycStatus
		ei

.yep:		ld	hl,roll_ypos
		inc	[hl]
		ld	a,[hl]
		cp	144
		jr	c,.nope2
		ld	a,1
		ld	[roll_delay],a
		ld	hl,wPanelRGB
		ld	de,wBcpShadow
		ld	bc,64
		call	MemCopy
		ld	hl,wPanelRGB
		ld	de,wBcpArcade
		ld	bc,64
		call	MemCopy
		
.nope2:		ld	hl,roll_ypos
		ld	l,[hl]
		ld	a,140
		sub	l
		jr	nc,.fine
		xor	a
.fine:		ldio	[rLYC],a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	b,h
		ld	c,l
		ld	de,0
		call	NewScroll		
		ld	a,1
		ldh	[hPosFlag],a
.nope:
		ld	a,1
		ldh	[hPalFlag],a

;		jr	rolluploop

		call	ReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	z,rolluploop
.done:		call	FadeOutBlack
		ld	a,255
		ldio	[rLYC],a
		di
		SETLYC	LycDoNothing
		ei
		ret





;***********************************************************************
;***********************************************************************
