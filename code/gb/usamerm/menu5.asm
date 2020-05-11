; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu5.asm                                                             **
; **                                                                       **
; ** Created : 20000517 by David Ashley                                    **
; **   Practice game screen                                                **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 11

LOCKED		EQU	1

		INTERFACE ProcessDirties

menu5_row	EQUS	"wTemp1024+00"
menu5_cx	EQUS	"wTemp1024+01"
menu5_cy	EQUS	"wTemp1024+02"
menu5_cp	EQUS	"wTemp1024+03"
menu5_first	EQUS	"wTemp1024+04"

menu5_list	EQUS	"bMenus+OPT_PRACTICEGAME"

GROUP_CURSOR	EQU	1
GROUP_SNAIL	EQU	2
GROUP_DOLPHIN	EQU	3

menu5maplists:
		db	21
		dw	IDX_PRACTICEA0RGB
		dw	IDX_PRACTICEA0MAP
		db	21
		dw	IDX_PRACTICEA1RGB
		dw	IDX_PRACTICEA1MAP

		db	21
		dw	IDX_PRACTICEB0RGB
		dw	IDX_PRACTICEB0MAP
		db	21
		dw	IDX_PRACTICEB1RGB
		dw	IDX_PRACTICEB1MAP

		db	21
		dw	IDX_PRACTICEC0RGB
		dw	IDX_PRACTICEC0MAP
		db	21
		dw	IDX_PRACTICEC1RGB
		dw	IDX_PRACTICEC1MAP

		db	21
		dw	IDX_PRACTICED0RGB
		dw	IDX_PRACTICED0MAP
		db	21
		dw	IDX_PRACTICED1RGB
		dw	IDX_PRACTICED1MAP

		db	21
		dw	IDX_PRACTICEE0RGB
		dw	IDX_PRACTICEE0MAP
		db	21
		dw	IDX_PRACTICEE1RGB
		dw	IDX_PRACTICEE1MAP

		db	21
		dw	IDX_PRACTICEF0RGB
		dw	IDX_PRACTICEF0MAP
		db	21
		dw	IDX_PRACTICEF1RGB
		dw	IDX_PRACTICEF1MAP

		db	21
		dw	IDX_PRACTICEG0RGB
		dw	IDX_PRACTICEG0MAP
		db	21
		dw	IDX_PRACTICEG1RGB
		dw	IDX_PRACTICEG1MAP

		db	21
		dw	IDX_PRACTICEH0RGB
		dw	IDX_PRACTICEH0MAP
		db	21
		dw	IDX_PRACTICEH1RGB
		dw	IDX_PRACTICEH1MAP

		db	21
		dw	IDX_PRACTICEI0RGB
		dw	IDX_PRACTICEI0MAP
		db	21
		dw	IDX_PRACTICEI1RGB
		dw	IDX_PRACTICEI1MAP

		db	21
		dw	IDX_PRACTICEJ0RGB
		dw	IDX_PRACTICEJ0MAP
		db	21
		dw	IDX_PRACTICEJ1RGB
		dw	IDX_PRACTICEJ1MAP

		db	21
		dw	IDX_PRACTICEK0RGB
		dw	IDX_PRACTICEK0MAP
		db	21
		dw	IDX_PRACTICEK1RGB
		dw	IDX_PRACTICEK1MAP

		db	21
		dw	IDX_PRACTICEL0RGB
		dw	IDX_PRACTICEL0MAP
		db	21
		dw	IDX_PRACTICEL1RGB
		dw	IDX_PRACTICEL1MAP

		db	21
		dw	IDX_PRACTICEM0RGB
		dw	IDX_PRACTICEM0MAP
		db	21
		dw	IDX_PRACTICEM1RGB
		dw	IDX_PRACTICEM1MAP

		db	21
		dw	IDX_PRACTICEN0RGB
		dw	IDX_PRACTICEN0MAP
		db	21
		dw	IDX_PRACTICEN1RGB
		dw	IDX_PRACTICEN1MAP

		db	21
		dw	IDX_PRACTICEO0RGB
		dw	IDX_PRACTICEO0MAP
		db	21
		dw	IDX_PRACTICEO1RGB
		dw	IDX_PRACTICEO1MAP

		db	21
		dw	IDX_PRACTICEP0RGB
		dw	IDX_PRACTICEP0MAP
		db	21
		dw	IDX_PRACTICEP1RGB
		dw	IDX_PRACTICEP1MAP


Menu5::
		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		call	InitGroups
		call	BubbleInit
		ld	hl,PAL_ARROW
		call	AddPalette
		ld	hl,PAL_SNAIL
		call	AddPalette
		ld	hl,PAL_DOLPHIN
		call	AddPalette
		ld	hl,PAL_PRNTICON
		call	Palette7
		xor	a
		ld	[wPrinterState],a
		ld	a,32
		ld	[wWave],a

		ld	a,[menu5_list]
		and	15
		ld	[menu5_list],a
		ld	a,[menu5_list+1]
		and	1
		ld	[menu5_list+1],a


		ld	a,BANK(Char30)
		ld	[wPinCharBank],a

		ld	hl,IDX_PRACTICEBITSMAP
		call	SecondHalf

		call	menu5showgame
		ld	a,1
		ld	[menu5_first],a
		call	setpp

menu5outer:	call	menu5movecursor
menu5loop:
		call	WaitForVBL
		call	ReadJoypad
		call	WaveFX

		call	InitFigures64
		call	menu5cursor
		call	menu5snaildolphin
		call	PrinterProcess
		call	Bubbles
		call	OutFigures

		ld	a,[menu5_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu5_first],a
		call	WaveOn
		call	FadeInBlack
.nofade:
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menu5forward
		bit	JOY_A,a
		jp	nz,menu5forward
		bit	JOY_B,a
		jp	nz,menu5back
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		bit	JOY_SELECT,a
		jr	nz,.print
		jr	menu5loop
.print:
	IF	PRINTER
		call	checklocked
		jr	z,menu5loop
		call	fxsel
		ld	a,[menu5_list]
		and	15
		inc	a
		call	PrintSomething
	ENDC
		jr	menu5loop
.nope:		xor	a
		ld	[wPrinterState],a
		call	fxillegal
		jr	menu5loop

.updown:	ld	a,[menu5_row]
		add	c
		cp	2
		jp	c,.menuok
		ld	a,0
		jr	z,.menuok
		ld	a,1
.menuok:	ld	[menu5_row],a
		call	fxmove
		jp	menu5outer
.leftright:
		ld	a,[menu5_row]
		or	a
		jr	z,.changegame
		ld	a,[menu5_list+1]
		xor	1
		and	1
		ld	[menu5_list+1],a
		call	fxmove
		jp	menu5outer
.changegame:
		xor	a
		ld	[wPrinterState],a
		ld	a,[menu5_list]
		add	c
		and	15
		ld	[menu5_list],a
		call	fxmove
		call	FadeOutBlack
		call	menu5showgame
		call	setpp
		ld	a,1
		ld	[menu5_first],a
		jp	menu5outer
checklocked:
		ld	a,[menu5_list]
		and	15
		add	a
		ld	c,a
		ld	b,0
		ld	hl,menu5list+1
		add	hl,bc
		ld	c,[hl]
		ld	hl,bLocks
		add	hl,bc
		ld	a,[hl]
		or	a
		ret

setpp:		call	checklocked
		ld	[wPrinterPossible],a
		ret


menu5forward:
		call	checklocked
	IF	LOCKED
		jp	z,.nope
	ENDC
		push	bc
		call	fxsel
		call	menu5shutdown
		pop	bc
		ld	a,c
		push	bc
		call	playvideo
		pop	bc
		ld	a,c
		ret
.nope:		call	fxillegal
		jp	menu5loop
menu5back:	call	fxback
		call	menu5shutdown
		xor	a
		ret

menu5shutdown:
		call	FadeOutBlack
		call	WaveOff
		jp	sprblank


menu5movecursor:
		ld	a,[menu5_row]
		or	a
		jr	z,.aok
		ld	a,[menu5_list+1]
		and	1
		inc	a
.aok:		add	a
		ld	c,a
		ld	b,0
		ld	hl,menu5curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu5_cx],a
		ld	a,[hl]
		ld	[menu5_cy],a
		ret


menu5curslist:
		db	60,110
		db	38,140
		db	100,140
menu5cursor:	ld	a,[menu5_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu5_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu5_cx]
		ld	d,a
		ld	a,[menu5_cy]
		ld	e,a
		ld	a,GROUP_CURSOR
		jp	AddFigure

menu5snaildolphin:
		ld	a,[menu5_list+1]
		and	1
		jr	z,.snail
		ld	de,$6481
		ld	bc,IDX_DOLPHIN
		ld	a,GROUP_DOLPHIN
		jp	AddFigure
.snail:		ld	de,$3281
		ld	bc,IDX_SNAIL
		ld	a,GROUP_SNAIL
		jp	AddFigure


menu5showgame:

		ld	a,[menu5_list]
		and	15
		add	a
		ld	c,a
		ld	b,0
		ld	hl,menu5list
		add	hl,bc
		ld	c,[hl]
		inc	hl
		ld	e,[hl]
		ld	d,b
		ld	hl,bLocks
		add	hl,de
		ld	a,[hl]
		or	a
		ld	de,0
	IF	LOCKED
		jr	z,.deok
	ENDC
		ld	de,5
.deok:		ld	h,b
		ld	l,c
		add	hl,hl
		add	hl,hl
		add	hl,bc
		add	hl,hl
		ld	bc,menu5maplists
		add	hl,bc
		add	hl,de
		call	NewLoadMap
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,[bLanguage]
		or	a
		jr	z,.fine
		dec	a
		ld	e,a
		add	a
		add	e
		ld	e,a
		ld	d,0
		ld	bc,$1403
		ld	hl,0
		call	BGRect
		call	ProcessDirties_b
.fine:
		ret

menu5list:	db	0,SUBGAME_URSULA
		db	1,SUBGAME_MORGANA
		db	2,SUBGAME_PRISON
		db	3,SUBGAME_KISS
		db	4,SUBGAME_SHIP
		db	5,SUBGAME_TREASURE
		db	6,SUBGAME_DASH
		db	7,SUBGAME_FLOUNDER
		db	8,SUBGAME_SCUTTLE
		db	9,SUBGAME_CLOAK
		db	10,SUBGAME_BEAR
		db	11,SUBGAME_ICECAVE
		db	12,SUBGAME_CAVE
		db	13,SUBGAME_FLOTSAM
		db	14,SUBGAME_TRIDENT
		db	15,SUBGAME_VOLCANO


tvback:		db	21
		dw	IDX_BOARD1RGB
		dw	IDX_TVBACKMAP

playvideo:	call	ChainSub
		ld	a,BANK(Char40)
		ld	[wPinCharBank],a
		ld	hl,tvback
		call	NewLoadMap
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		ld	a,-1
		ldh	[pin_board],a
		call	FadeInBlack
.lp:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	nz,.exit
		call	StepVideo
		call	ProcessDirties_b
		ld	a,[any_tvtake]
		or	a
		jr	nz,.lp
.exit:		jp	FadeOutBlack

;***********************************************************************
;***********************************************************************

