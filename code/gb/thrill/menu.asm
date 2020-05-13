; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** menu.asm                                                              **
; **                                                                       **
; ** Created : 20000502 by David Ashley                                    **
; **  # of players                                                         **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section 27

menu_row	EQUS	"wTemp1024+00"
menu_cx		EQUS	"wTemp1024+01"
menu_cy		EQUS	"wTemp1024+02"
menu_cp		EQUS	"wTemp1024+03"
menu_first	EQUS	"wTemp1024+04"

menu_list	EQUS	"bMenus+OPT_NUMPLAYERS"

GROUP_CURSOR	EQU	0

menumaplist:
		db	21
		dw	IDX_PLAYERSRGB
		dw	IDX_PLAYERSMAP
;		db	21
;		dw	IDX_PLAYERSRGB
;		dw	IDX_GPLAYERSMAP
;		db	21
;		dw	IDX_PLAYERSRGB
;		dw	IDX_FPLAYERSMAP
;		db	21
;		dw	IDX_PLAYERSRGB
;		dw	IDX_IPLAYERSMAP
;		db	21
;		dw	IDX_PLAYERSRGB
;		dw	IDX_SPLAYERSMAP

Menu::
		call	menu1maxes

		ld	hl,wTemp1024
		ld	bc,256
		call	MemClear

		call	InitGroups
		ld	hl,PAL_ARROW
		call	AddPalette

		ld	a,BANK(Char00)
		ld	[wPinCharBank],a
		ld	hl,menumaplist
		ld	a,[bLanguage]
		ld	e,a
		add	a
		add	a
		add	e
		ld	e,a
		ld	d,0
		add	hl,de
		call	NewLoadMap
		ld	hl,IDX_PLAYERBITSMAP
		call	SecondHalf
		ld	de,0
		ld	hl,0
		call	NewInitScroll

		call	showrows

		ld	a,[menu_list]
		or	a
		jr	z,.p1
		dec	a
		jr	z,.p2
		dec	a
		jr	z,.p3
.p4:		ld	a,7
		call	menuon
.p3:		ld	a,6
		call	menuon
.p2:		ld	a,5
		call	menuon
.p1:		ld	a,4
		call	menuon

		ld	a,1
		ld	[menu_first],a

menuouter:	call	movecursor
menuloop:
		call	WaitForVBL

		call	InitFigures
		call	cursor
		call	OutFigures

		ld	a,[menu_first]
		or	a
		jr	z,.nofade
		xor	a
		ld	[menu_first],a
		call	FadeInBlack
.nofade:

		call	ReadJoypad

		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,menuforward
		bit	JOY_A,a
		jp	nz,menuforward
		ld	c,-1
		bit	JOY_L,a
		jr	nz,.leftright
		bit	JOY_U,a
		jr	nz,.updown
		bit	JOY_B,a
		jp	nz,menuback
		ld	c,1
		bit	JOY_R,a
		jr	nz,.leftright
		bit	JOY_D,a
		jr	nz,.updown
		jr	menuloop

.updown:	jr	menuouter
;		ld	a,[menu_row]
;		add	c
;		cp	2
;		jr	c,.menuok
;		ld	a,0
;		jr	z,.menuok
;		ld	a,1
;.menuok:	ld	[menu_row],a
;		call	fxmove
;		jr	menuouter

.leftright:
		ld	a,[menu_row]
		ld	e,a
		ld	d,0
		ld	hl,rowlengths
		add	hl,de
		ld	b,[hl]
		ld	hl,menu_list
		add	hl,de
		ld	a,[hl]
		cp	b
		jr	c,.fine
		xor	a
		ld	[hl],a
.fine:		push	af
		add	c
		cp	b
		jr	c,.fine2
		ld	a,0
		jr	nz,.fine2
		ld	a,b
		dec	a
.fine2:		ld	[hl],a
		pop	bc
		cp	b
		jr	z,menuloop
		ld	c,a
		push	bc
		ld	hl,rowstarts
		add	hl,de
		add	[hl]
		push	af
		ld	a,b
		add	[hl]
		call	menuoff
		pop	af
		call	menuon
		call	WaitForVBL
.wy:		ldio	a,[rLY]
		cp	80
		jr	nz,.wy
		pop	bc
		ld	a,b
		cp	c
		jr	c,.bigger
		add	4
		call	menuoffwipe
		jr	.smaller
.bigger:	add	5
		call	menuonwipe
.smaller:

		call	fxmove
		jp	menuouter

showrows:
		ld	hl,menu_list
		ld	de,rowstarts
		call	showrow
		ret
showrow:	ld	a,[de]
		inc	de
		add	[hl]
		inc	hl
		push	de
		push	hl
		call	menuon
		pop	hl
		pop	de
		ret

menuforward:	call	fxsel
		call	menushutdown
		xor	a
		ret
menuback:	call	fxback
		call	menushutdown
		ld	a,1
		ret

menushutdown:
		call	FadeOutBlack
		jp	sprblank

menuon:		ld	hl,menuons
		jr	menuonoff
menuoff:	ld	hl,menuoffs
menuonoff:
		push	af
		push	hl
		ld	a,[menu_row]
		ld	c,a
		ld	b,0
		ld	hl,.positions
		add	hl,bc
.wait:		ldio	a,[rLY]
		cp	[hl]
		jr	nz,.wait
		pop	hl
		pop	af
		add	a
		ld	c,a
		add	a
		add	c
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
		call	BGRect
		jp	ProcessDirties
.positions:	db	64
		db	5
		db	110

menuonwipe:	ld	hl,menuons
		jr	menuonoffwipe
menuoffwipe:	ld	hl,menuoffs
menuonoffwipe:
		add	a
		ld	c,a
		add	a
		add	c
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
.y:		push	bc
		push	de
		push	hl
		ld	a,c
		cp	2
		jr	c,.cok
		ld	c,2
.cok:		call	BGRect
		call	ProcessDirties
		call	WaitForVBL
		pop	hl
		pop	de
		pop	bc
		inc	l
		inc	l
		inc	e
		inc	e
		dec	c
		ret	z
		dec	c
		jr	nz,.y
		ret

menuons:	db	3,5,0,0,2,3
		db	4,5,0,5,6,3
		db	3,5,0,10,11,3
		db	3,5,0,15,15,3

		db	5,7,10,0,0,10
		db	6,7,10,8,4,8
		db	6,8,10,16,9,9
		db	6,8,10,25,14,8

menuoffs:	db	3,5,5,0,2,3
		db	4,5,5,5,6,3
		db	3,5,5,10,11,3
		db	3,5,5,15,15,3

		db	5,7,16,0,0,10
		db	6,7,17,8,4,8
		db	6,8,17,16,9,9
		db	6,8,17,25,14,8

rowlengths:	db	4
		db	2

rowstarts:	db	0
		db	4

movecursor:	ld	a,[menu_row]
		ld	c,a
		ld	b,0
		ld	hl,rowstarts
		add	hl,bc
		ld	a,[hl]
		ld	hl,menu_list
		add	hl,bc
		add	[hl]
		add	a
		ld	c,a
		ld	hl,curslist
		add	hl,bc
		ld	a,[hli]
		ld	[menu_cx],a
		ld	a,[hl]
		ld	[menu_cy],a
		ret

curslist:	db	12,50
		db	46,50
		db	82,50
		db	115,50
cursor:		ld	a,[menu_cp]
		inc	a
		cp	ARROWMAX*4
		jr	c,.aok
		xor	a
.aok:		ld	[menu_cp],a
		srl	a
		srl	a
		add	IDX_ARROW&255
		ld	c,a
		ld	a,0
		adc	IDX_ARROW>>8
		ld	b,a
		ld	a,[menu_cx]
		ld	d,a
		ld	a,[menu_cy]
		ld	e,a
		ld	a,GROUP_CURSOR
		jp	AddFigure

menu1maxes:	ld	hl,menu_list
		ld	de,rowlengths
.max1:		ld	a,[de]
		dec	a
		cp	[hl]
		jr	nc,.good
.bad:		ld	[hl],a
.good:		inc	de
		inc	hl
		ret





;***********************************************************************
;***********************************************************************

