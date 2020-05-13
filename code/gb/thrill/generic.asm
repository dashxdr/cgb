; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** generic.asm                                                            **
; **                                                                       **
; ** Created : 20000801 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

GROUP_PLATFORM	EQU	2

generic_second	EQUS	"wTemp1024+00"

genericinfo:	db	BANK(generichit)		;wPinJmpHit
		dw	generichit
		db	BANK(genericprocess)	;wPinJmpProcess
		dw	genericprocess
		db	BANK(genericsprites)	;wPinJmpSprites
		dw	genericsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(genericbumper)	;wPinJmpHitBumper
		dw	genericbumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(genericlostball)	;wPinJmpLost
		dw	genericlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(genericdone)		;wPinJmpDone
		dw	genericdone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

genericmaplist:	db	21
		dw	IDX_genericBACKRGB
		dw	IDX_genericBACKMAP

genericdone:	ret

genericInit::
		ld	hl,genericinfo
		call	SetPinInfo

		ld	a,TIME_generic
		call	SetTime

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_PLATFORM
		call	AddPalette

		ld	hl,IDX_generic0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,genericmaplist
		call	NewLoadMap
		ld	hl,IDX_genericLIGHTSMAP
		call	SecondHalf

		call	genericsaver.on

 call	SubAddBall

		call	subsaver

		ld	hl,genericcollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	50<<5

genericlostball:	ld	a,[any_ballsaver]
		or	a
		ret	z
		ld	hl,pin_ballflags
		set	BALLFLG_USED,[hl]
		ld	a,FX&255
		ldh	[pin_x],a
		ld	a,FX>>8
		ld	[pin_x+1],a
		ld	a,FY&255
		ldh	[pin_y],a
		ld	a,FY>>8
		ld	[pin_y+1],a
		xor	a
		ldh	[pin_vx],a
		ldh	[pin_vx+1],a
		ldh	[pin_vy],a
		ldh	[pin_vy+1],a
		ret

genericprocess:
		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,genericsaver

		ld	hl,generic_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:

		ret

genericsaver:	ld	hl,any_ballsaver
		ld	a,[hl]
		or	a
		ret	z
		dec	[hl]
		jr	z,.off
		cp	8
		jr	nc,.on
		cp	3
		jr	c,.off
		srl	a
		jr	c,.off
.on:		ld	a,1
		jp	genericrect
.off:		ld	a,0
		jp	genericrect


;a=#
genericrect:	ld	hl,genericrects
		jp	RectList


genericrects:



genericbumper:
		ldh	a,[pin_x]
		ld	l,a
		ldh	a,[pin_x+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	d,h

		ldh	a,[pin_y]
		ld	l,a
		ldh	a,[pin_y+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	e,h

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret


genericcollisions:
		dw	0

generichit:	ret

genericsprites:

		jp	SubFlippers

