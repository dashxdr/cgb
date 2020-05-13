; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** side.asm                                                              **
; **                                                                       **
; ** Created : 20000802 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	23

GROUP_PLATFORM	EQU	2

side_second	EQUS	"wTemp1024+00"
side_ping	EQUS	"wTemp1024+01"
side_hit	EQUS	"wTemp1024+02" ;9
side_raise	EQUS	"wTemp1024+11"
side_side	EQUS	"wTemp1024+12"


SIDESCORE1	EQU	100	;in 1000's, going through ramp
SIDESCORE2	EQU	5	;in 1000's, hitting regular drop
SIDESCORE3	EQU	10	;in 1000's, hitting ramp blocker


sideinfo:	db	BANK(sidehit)		;wPinJmpHit
		dw	sidehit
		db	BANK(sideprocess)	;wPinJmpProcess
		dw	sideprocess
		db	BANK(sidesprites)	;wPinJmpSprites
		dw	sidesprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(sidebumper)	;wPinJmpHitBumper
		dw	sidebumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(sidelostball)	;wPinJmpLost
		dw	sidelostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(sidedone)		;wPinJmpDone
		dw	sidedone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	BANK(SideInit)		;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

sidemaplist:	db	21
		dw	IDX_SIDEBACKRGB
		dw	IDX_SIDEBACKMAP

;raise times are in 4/15ths of a second
raisetimes:	db	20*15/4,16*15/4,12*15/4


sidedone:	ret

SideInit::
		ld	hl,sideinfo
		call	SetPinInfo

		ld	a,TIME_SIDE
		call	SetTime

		ld	a,NEED_SIDE
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_PLATFORM
		call	AddPalette

		ld	hl,IDX_SIDE0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,sidemaplist
		call	NewLoadMap
		ld	hl,IDX_SIDELIGHTSMAP
		call	SecondHalf

		call	sidesaver.on

 call	SubAddBall

		call	subsaver

		call	sideraise

		ld	hl,sidecollisions
		jp	MakeCollisions

FX		EQU	50<<5
FY		EQU	80<<5

sidelostball:	ld	a,[any_ballsaver]
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

sideprocess:


		call	SubEnd
		call	AnyDecTime
		ld	a,[side_ping]
		or	a
		call	nz,dosideping
		ld	a,[wTime]
		and	15
		call	z,sidesaver

		ld	a,[wTime]
		and	15
		jr	nz,.noraise
		ld	a,[side_raise]
		or	a
		jr	z,.noraise
		dec	a
		jr	z,.tryraise
		ld	[side_raise],a
		jr	.noraise
.tryraise:	ld	a,[wBalls+BALL_Y+1]
		cp	10
		jr	c,.noraise
		call	sideraise
.noraise:

		ret

sideraise:
		xor	a
		ld	[side_raise],a
		ld	a,26
		call	siderect
		ld	a,28
		call	siderect
		ld	a,30
		call	siderect
		ld	a,32
		call	siderect
		ld	a,34
		call	siderect
		ld	a,36
		call	siderect
		ld	a,38
		call	siderect
		ld	hl,side_hit
		ld	bc,7
		call	MemClear
sidebothup:	call	sideleftup
		jp	siderightup

sideopen:	call	sideleftdown
		call	siderightdown
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,raisetimes
		add	hl,bc
		ld	a,[hl]
		ld	[side_raise],a
		ret




sidesaver:	ld	hl,any_ballsaver
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
		jp	siderect
.off:		ld	a,0
		jp	siderect


;a=#
siderect:	ld	hl,siderects
		jp	RectList


siderects:	db	2,2,18,3,10,12	; 0 saver 0
		db	2,2,18,0,10,12	; 1 saver 1
		db	2,1,6,3,6,6	; 2 left drop a 0
		db	2,1,6,0,6,6	; 3 left drop a 1
		db	2,2,3,3,5,4	; 4 left drop b 0
		db	2,2,3,0,5,4	; 5 left drop b 1
		db	2,2,0,3,5,2	; 6 left drop c 0
		db	2,2,0,0,5,2	; 7 left drop c 1
		db	2,1,15,3,14,6	; 8 right drop a 0
		db	2,1,15,0,14,6	; 9 right drop a 1
		db	2,2,12,3,15,4	;10 right drop b 0
		db	2,2,12,0,15,4	;11 right drop b 1
		db	2,2,9,3,15,2	;12 right drop c 0
		db	2,2,9,0,15,2	;13 right drop c 1
		db	2,2,0,9,6,8	;14 left arrow a 0
		db	2,2,0,6,6,8	;15 left arrow a 1
		db	3,2,3,9,6,10	;16 left arrow b 0
		db	3,2,3,6,6,10	;17 left arrow b 1
		db	2,2,7,9,7,12	;18 left arrow c 0
		db	2,2,7,6,7,12	;19 left arrow c 1
		db	2,2,10,9,14,8	;20 right arrow a 0
		db	2,2,10,6,14,8	;21 right arrow a 1
		db	3,2,13,9,13,10	;22 right arrow b 0
		db	3,2,13,6,13,10	;23 right arrow b 1
		db	2,2,17,9,13,12	;24 right arrow c 0
		db	2,2,17,6,13,12	;25 right arrow c 1
		db	1,1,0,15,3,9	;26 light a 0
		db	1,1,0,12,3,9	;27 light a 1
		db	1,1,0,15,5,8	;28 light b 0
		db	1,1,0,12,5,8	;29 light b 1
		db	1,1,0,15,8,8	;30 light c 0
		db	1,1,0,12,8,8	;31 light c 1
		db	2,2,2,15,10,8	;32 light d 0
		db	2,2,2,12,10,8	;33 light d 1
		db	1,1,0,15,13,8	;34 light e 0
		db	1,1,0,12,13,8	;35 light e 1
		db	1,1,0,15,16,8	;36 light f 0
		db	1,1,0,12,16,8	;37 light f 1
		db	1,1,0,15,18,9	;38 light g 0
		db	1,1,0,12,18,9	;39 light g 1



sidebumper:
		ld	a,[side_ping]
		or	a
		jp	nz,.soft
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

		ld	a,e
		sub	31
		cp	d
		jr	nc,.p0
		ld	a,200
		sub	d
		ld	b,a
		ld	a,e
		sub	6
		cp	b
		jr	nc,.p6
		ld	a,d
		cp	61
		jr	c,.lefts
		cp	115
		jr	nc,.rights
		cp	78
		jr	c,.p2
		cp	98
		jr	c,.p3
.p4:		ld	c,4
		jr	.handle
.p0:		ld	c,0
		jr	.handle
.p6:		ld	c,6
		jr	.handle
.p2:		ld	c,2
		jr	.handle
.p3:		ld	c,3
		jr	.handle
.lefts:		ld	a,e
		cp	47
		jr	c,.p7
		ld	a,[side_hit+7]
		or	a
		jr	nz,.p1
		ld	a,d
		cp	45
		jr	nc,.p7
.p1:		ld	c,1
		jr	.handle
.p7:		ld	c,7
		jr	.handle
.rights:	ld	a,e
		cp	47
		jr	c,.p8
		ld	a,[side_hit+8]
		or	a
		jr	nz,.p5
		ld	a,d
		cp	133
		jr	c,.p8
.p5:		ld	c,5
		jr	.handle
.p8:		ld	c,8
.handle:	call	handlesidehit

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret
sideleftdown:	ld	a,3
		call	setsideleft
		ld	a,15
		call	siderect
		ld	a,17
		call	siderect
		ld	a,19
		call	siderect
sideleftdowntemp:
		ld	a,2
		call	siderect
		ld	a,4
		call	siderect
		ld	a,6
		jp	siderect
siderightdown:	ld	a,3
		call	setsideright
		ld	a,21
		call	siderect
		ld	a,23
		call	siderect
		ld	a,25
		call	siderect
siderightdowntemp:
		ld	a,8
		call	siderect
		ld	a,10
		call	siderect
		ld	a,12
		jp	siderect

sideleftup:
		xor	a
		call	setsideleft
		ld	a,14
		call	siderect
		ld	a,16
		call	siderect
		ld	a,18
		call	siderect
		ld	a,3
		call	siderect
		ld	a,5
		call	siderect
		ld	a,7
		jp	siderect

siderightup:
		xor	a
		call	setsideright
		ld	a,20
		call	siderect
		ld	a,22
		call	siderect
		ld	a,24
		call	siderect
		ld	a,9
		call	siderect
		ld	a,11
		call	siderect
		ld	a,13
		jp	siderect

sideleftrestore:
		ld	a,[side_hit+7]
		ld	c,7
		jp	siderestore
siderightrestore:
		ld	a,[side_hit+8]
		ld	c,13
siderestore:	or	a
		ld	b,a
		ld	a,c
		jr	z,.s0
		dec	b
		jr	z,.s1
		dec	b
		jr	z,.s2
		ret	
.s0:		push	af
		call	siderect
		pop	af
		dec	a
		dec	a
.s1:		push	af
		call	siderect
		pop	af
		dec	a
		dec	a
.s2:		jp	siderect




setsideleft:	push	af
		ld	a,[side_hit+7]
		ld	c,a
		ld	b,0
		ld	hl,IDX_SIDE0002CHG
		add	hl,bc
		cp	3
		call	c,UndoChanges
		pop	af
		ld	[side_hit+7],a
		ld	c,a
		ld	b,0
		ld	hl,IDX_SIDE0002CHG
		add	hl,bc
		cp	3
		ret	nc
		jp	MakeChanges

setsideright:	push	af
		ld	a,[side_hit+8]
		ld	c,a
		ld	b,0
		ld	hl,IDX_SIDE0005CHG
		add	hl,bc
		cp	3
		call	c,UndoChanges
		pop	af
		ld	[side_hit+8],a
		ld	c,a
		ld	b,0
		ld	hl,IDX_SIDE0005CHG
		add	hl,bc
		cp	3
		ret	nc
		jp	MakeChanges

handlesidehit:
		ld	a,c
		cp	7
		jr	z,.left
		cp	8
		jr	z,.right
		ld	b,0
		ld	hl,side_hit
		add	hl,bc
		ld	a,[hl]
		or	a
		ret	nz
		ld	[hl],1
		ld	a,c
		add	a
		add	27
		call	siderect
		ld	hl,SIDESCORE2
		call	addthousandshl
		ld	a,FX_SIDEHIT
		call	InitSfx
		ld	hl,side_hit
		ld	a,[hli]
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		inc	hl
		add	[hl]
		cp	7
		jp	z,sideopen
		ret
.left:		ld	a,[side_hit+7]
		add	a
		push	af
		add	2
		call	siderect
		pop	af
		add	15
		call	siderect
		ld	hl,SIDESCORE3
		call	addthousandshl
		ld	a,FX_SIDEBARRIER
		call	InitSfx
		ld	a,[side_hit+7]
		inc	a
		jp	setsideleft
.right:		ld	a,[side_hit+8]
		add	a
		push	af
		add	8
		call	siderect
		pop	af
		add	21
		call	siderect
		ld	hl,SIDESCORE3
		call	addthousandshl
		ld	a,FX_SIDEBARRIER
		call	InitSfx
		ld	a,[side_hit+8]
		inc	a
		jp	setsideright

sideenterleft:	ld	a,[side_ping]
		or	a
		ret	nz
		ld	a,1
		ld	[side_side],a
		call	siderightdowntemp
		ld	a,FX_SIDERAMP
		call	InitSfx
		ld	a,WITHIN
		ld	[side_ping],a
		ret
sideenterright:	ld	a,[side_ping]
		or	a
		ret	nz
		xor	a
		ld	[side_side],a
		call	sideleftdowntemp
		ld	a,FX_SIDERAMP
		call	InitSfx
		ld	a,WITHIN
		ld	[side_ping],a
		ret

WITHIN		EQU	18

sidecollisions:
		dw	sideenterleft,39,16
		db	4,4
		dw	sideenterright,137,16
		db	4,4
		dw	0

sidehit:	ret

sidesprites:

		jp	SubFlippers

sidepostab:
	db	31+88,-6+72
	db	31+88,-9+72
	db	32+88,-12+72
	db	33+88,-15+72
	db	34+88,-18+72
	db	35+88,-21+72
	db	36+88,-24+72
	db	37+88,-27+72
	db	38+88,-30+72
	db	39+88,-33+72
	db	40+88,-36+72
	db	41+88,-39+72
	db	41+88,-42+72
	db	42+88,-45+72
	db	43+88,-48+72
	db	44+88,-51+72
	db	45+88,-54+72
	db	47+88,-57+72
	db	50+88,-58+72
	db	53+88,-59+72
	db	56+88,-59+72
	db	59+88,-59+72
	db	62+88,-58+72
	db	65+88,-56+72
	db	67+88,-53+72
	db	69+88,-50+72
	db	70+88,-47+72
	db	70+88,-44+72
	db	70+88,-41+72
	db	69+88,-38+72
	db	67+88,-35+72
	db	65+88,-33+72
	db	62+88,-31+72
	db	59+88,-30+72
	db	56+88,-30+72
	db	53+88,-30+72
	db	50+88,-30+72
	db	47+88,-30+72
	db	44+88,-30+72
	db	41+88,-30+72
	db	38+88,-30+72
	db	35+88,-30+72
	db	32+88,-30+72
	db	29+88,-30+72
	db	26+88,-30+72
	db	23+88,-30+72
	db	20+88,-30+72
	db	17+88,-30+72
	db	14+88,-30+72
	db	11+88,-30+72
	db	8+88,-30+72
	db	5+88,-30+72
	db	2+88,-30+72
	db	-1+88,-30+72
	db	-4+88,-30+72
	db	-7+88,-31+72
	db	-10+88,-32+72
	db	-12+88,-34+72
	db	-15+88,-37+72
	db	-17+88,-40+72
	db	-18+88,-43+72
	db	-19+88,-46+72
	db	-19+88,-49+72
	db	-19+88,-52+72
	db	-18+88,-55+72
	db	-17+88,-58+72
	db	-15+88,-61+72
	db	-13+88,-63+72
	db	-10+88,-65+72
	db	-7+88,-66+72
	db	-4+88,-67+72
	db	-1+88,-67+72
	db	2+88,-67+72
	db	5+88,-66+72
	db	8+88,-65+72
	db	11+88,-63+72
	db	13+88,-61+72
	db	15+88,-58+72
	db	17+88,-55+72
	db	18+88,-52+72
	db	18+88,-49+72
	db	18+88,-46+72
	db	18+88,-43+72
	db	17+88,-40+72
	db	15+88,-38+72
	db	13+88,-35+72
	db	10+88,-33+72
	db	7+88,-31+72
	db	4+88,-30+72
	db	1+88,-30+72
	db	-2+88,-30+72
	db	-5+88,-30+72
	db	-8+88,-30+72
	db	-11+88,-30+72
	db	-14+88,-30+72
	db	-17+88,-30+72
	db	-20+88,-30+72
	db	-23+88,-30+72
	db	-26+88,-30+72
	db	-29+88,-30+72
	db	-32+88,-30+72
	db	-35+88,-30+72
	db	-38+88,-30+72
	db	-41+88,-30+72
	db	-44+88,-30+72
	db	-47+88,-30+72
	db	-50+88,-30+72
	db	-53+88,-30+72
	db	-56+88,-30+72
	db	-59+88,-30+72
	db	-62+88,-30+72
	db	-65+88,-32+72
	db	-67+88,-34+72
	db	-69+88,-37+72
	db	-71+88,-40+72
	db	-71+88,-43+72
	db	-71+88,-46+72
	db	-71+88,-49+72
	db	-70+88,-52+72
	db	-68+88,-55+72
	db	-65+88,-57+72
	db	-62+88,-58+72
	db	-59+88,-59+72
	db	-56+88,-59+72
	db	-53+88,-59+72
	db	-50+88,-58+72
	db	-47+88,-56+72
	db	-46+88,-53+72
	db	-45+88,-50+72
	db	-44+88,-47+72
	db	-43+88,-44+72
	db	-42+88,-41+72
	db	-41+88,-38+72
	db	-40+88,-35+72
	db	-39+88,-32+72
	db	-39+88,-29+72
	db	-38+88,-26+72
	db	-37+88,-23+72
	db	-36+88,-20+72
	db	-35+88,-17+72
	db	-34+88,-14+72
	db	-33+88,-11+72
	db	-32+88,-8+72
	db	-31+88,-5+72

PINGNUM		EQU	(@-sidepostab)/2

EJECTY		EQU	30

dosideping:
		ld	hl,side_ping
		ld	a,[hl]
		cp	PINGNUM+1
		jr	c,.cont
		ld	[hl],0
		ld	a,EJECTY&255
		ld	[wBalls+BALL_VY],a
		ld	a,EJECTY>>8
		ld	[wBalls+BALL_VY+1],a
		call	AnyDec2
		call	Credit1
		ld	hl,SIDESCORE1
		call	addthousandshlinform
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.noend
		call	AnyEnd
		ld	a,FX_SIDEWON
		call	InitSfx
.noend:		ld	a,[side_raise]
		or	a
		ret	nz
		ld	a,[side_side]
		or	a
		jr	nz,.left
.right:		call	sideleftrestore
		jp	siderightup
.left:		call	siderightrestore
		jp	sideleftup
.cont:		ld	a,[side_side]
		or	a
		ld	a,[hl]
		jr	z,.aok
		cpl
		add	PINGNUM+2
.aok:		dec	a
		inc	[hl]
		ld	c,a
		ld	b,0
		ld	hl,sidepostab
		add	hl,bc
		add	hl,bc
		ld	a,[hli]
;		add	80+8
		ld	d,a
		ld	a,[hl]
;		add	72
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,l
		ld	[wBalls+BALL_Y],a
		ld	a,h
		ld	[wBalls+BALL_Y+1],a
		ld	l,d
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,l
		ld	[wBalls+BALL_X],a
		ld	a,h
		ld	[wBalls+BALL_X+1],a
		xor	a
		ld	[wBalls+BALL_VX],a
		ld	[wBalls+BALL_VX+1],a
		ld	[wBalls+BALL_VY],a
		ld	[wBalls+BALL_VY+1],a
		ret
