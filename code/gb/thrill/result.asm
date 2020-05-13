; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** RESULT.ASM                                                            **
; **                                                                       **
; ** Created : 20000421 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		section	26

SCORE1		EQUS	"wMessage+64"
SCORE2		EQUS	"wMessage+80"


res_bits	EQUS	"wTemp1024+00"
res_complete	EQUS	"wTemp1024+01"

LINEX		EQU	4
LINEY		EQU	6
SPACEY		EQU	10

funmaplist:
		db	21
		dw	IDX_FUNRESULTRGB
		dw	IDX_FUNRESULTMAP
thrillmaplist:
		db	21
		dw	IDX_THRILLRESULTRGB
		dw	IDX_THRILLRESULTMAP


resultrects:	db	7,5,0,0,1,0
		db	7,5,8,0,12,0
		db	8,5,16,0,6,4
		db	7,5,0,12,1,8
		db	7,5,8,12,12,8
;a=#
resultrect:	ld	hl,resultrects
		jp	RectList


res1flags:	db	1,1,1,0,1,0,0,0,0

res1needs:	db	NEED_FALCON	;fun
		db	NEED_KISS	;fun
		db	NEED_RAPIDS	;fun
		db	NEED_LOOPER	;thrill
		db	NEED_BUILD	;fun
		db	NEED_BEAR	;thrill
		db	NEED_BOAT	;thrill
		db	NEED_RACE	;thrill
		db	NEED_SIDE	;thrill

res1bits:	db	2,16,8,2,4,1,8,4,16

outresult:	ld	a,[any_credit1]
		cp	NEED_OUT
		ld	a,0
		jr	c,.aok
		inc	a
.aok:		ld	[wStartHappy],a
		ld	[wSubCompleted],a
		ret

ResultScreen_b::
		call	SetMachineJcb
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE
		ret	z
		cp	SUBGAME_OUT
		jr	z,outresult
		ld	c,a
		ld	b,0
		ld	hl,res1flags-1
		add	hl,bc
		ld	a,[hl]
		or	a
		jr	z,.thrill

		ld	hl,wFunZone
		push	hl
		ld	hl,funmaplist
		call	NewLoadMap
		ld	hl,IDX_FUNLIGHTSMAP
		call	SecondHalf
		jr	.fun
.thrill:	ld	hl,wThrillZone
		push	hl
		ld	hl,thrillmaplist
		call	NewLoadMap
		ld	hl,IDX_THRILLLIGHTSMAP
		call	SecondHalf
.fun:
		xor	a
		ld	[res_complete],a
		ld	[wSubCompleted],a
		call	part1
		jr	c,.nocomplete
		ld	a,1
		ld	[res_complete],a
		ld	[wSubCompleted],a
		ldh	a,[pin_board]
		ld	c,a
		ld	b,0
		ld	hl,res1bits-1
		add	hl,bc
		ld	a,[hl]
		pop	hl
		push	hl
		or	[hl]
		ld	[hl],a
.nocomplete:
		pop	hl
		ld	a,[hl]
		ld	[res_bits],a
		and	1
		ld	a,0
		call	nz,resultrect
		ld	a,[res_bits]
		and	2
		ld	a,1
		call	nz,resultrect
		ld	a,[res_bits]
		and	4
		ld	a,2
		call	nz,resultrect
		ld	a,[res_bits]
		and	8
		ld	a,3
		call	nz,resultrect
		ld	a,[res_bits]
		and	16
		ld	a,4
		call	nz,resultrect

		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,$30
		ld	[wFontStrideLo],a
		xor	a
		ld	[wFontStrideHi],a

		ld	hl,$c800
		ld	b,$d0
.fill:		ld	a,$00
		ld	[hli],a
		ld	a,$00
		ld	[hli],a
		ld	a,h
		cp	b
		jr	c,.fill

		call	picklite
		call	part2

		ld	a,[res_complete]
		or	a
		jr	z,.nocomplete2
		ld	hl,completestring1
		call	DrawStringLstN
		ld	hl,completestring2
		call	DrawStringLst
		ld	de,score1m
		call	addscore
.nocomplete2:

		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,$c800
		ld	de,$8f80
		call	resrow
		call	DumpChrs
		ld	hl,$c810
		ld	de,$9100
		call	resrow
		ld	hl,$c820
		ld	de,$9280
		call	resrow
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a


		call	FadeIn



		call	InitGroups


.wait:		call	WaitForVBL
		call	ReadJoypad
		call	InitFigures
		call	OutFigures
		ld	a,[wJoy1Hit]
		or	a
		jr	z,.wait
		call	FadeOutBlack
		ret

funclist:	ld	e,a
		ld	d,0
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]


part1:		ldh	a,[pin_board]
		ld	hl,res1needs-1
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[any_credit1]
		sub	[hl]
		ret

part2:		ld	hl,scorestring
		call	DrawStringLstN
		ld	hl,wMessage
		ld	a,160-LINEX
		ld	[hli],a
		ld	a,LINEY
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,2
		ld	[hli],a
		ld	de,wScore
		ld	bc,('0'<<8)+','
		call	res3
		call	rescomma3
		call	rescomma3
		call	rescomma3
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	hl,wMessage+4
		ld	e,14
.lead0:		ld	a,[hl]
		cp	c
		jr	z,.skip
		cp	b
		jr	nz,.done
.skip:		ld	a,' '
		ld	[hli],a
		dec	e
		jr	nz,.lead0
.done:		ld	de,wMessage+4
.cpy:		ld	a,[hli]
		ld	[de],a
		inc	de
		or	a
		jr	nz,.cpy
		ld	[de],a
		ld	hl,wMessage
		jp	DrawStringLst
rescomma3:	ld	a,c
		ld	[hli],a
res3:		REPT	3
		ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ENDR
		ret

resrow:		ld	bc,$1401
.rrlp:		push	bc
		call	DumpChrs
		ld	bc,$20
		add	hl,bc
		pop	bc
		dec	b
		jr	nz,.rrlp
		ret



completestring1:
		db	LINEX
		db	LINEY+SPACEY
		db	0
		db	0
		dw	MSGPASSED
		db	0
completestring2:
		db	160-LINEX
		db	LINEY+SPACEY
		db	0
		db	2
		db	"1,000,000",0
		db	0

scorestring:	db	LINEX
		db	LINEY
		db	0
		db	0
		dw	MSGSCORE
		db	0

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

