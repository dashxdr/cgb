; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** out.asm                                                               **
; **                                                                       **
; ** Created : 20000815 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	10

		INTERFACE SubHitFlipper

GROUP_PLATFORM	EQU	2

OUTSCORE1	EQU	100	;in k, for each light
OUTSCORE2	EQU	9999	;in k, for completion

out_second	EQUS	"wTemp1024+00"
out_hit		EQUS	"wTemp1024+01"
out_first	EQUS	"wTemp1024+02"

outinfo:	db	BANK(outhit)		;wPinJmpHit
		dw	outhit
		db	BANK(outprocess)	;wPinJmpProcess
		dw	outprocess
		db	BANK(outsprites)	;wPinJmpSprites
		dw	outsprites
		db	BANK(outflipper)	;wPinJmpHitFlipper
		dw	outflipper
		db	BANK(outbumper)		;wPinJmpHitBumper
		dw	outbumper
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(outlostball)	;wPinJmpLost
		dw	outlostball
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		db	BANK(outdone)		;wPinJmpDone
		dw	outdone
		dw	CUTOFFY2		;wPinCutoff
		dw	IDX_SUB0002CHG		;lsubflippers
		dw	IDX_SUB0010CHG		;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

outmaplist:	db	21
		dw	IDX_OUTBACKRGB
		dw	IDX_OUTBACKMAP

outdone:	ret

OutInit::
		ld	hl,outinfo
		call	SetPinInfo

		ld	a,TIME_OUT
		call	SetTime

		ld	a,NEED_OUT
		ld	[out_hit],a
		call	SetCount2

		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_PLATFORM
		call	AddPalette

		ld	hl,IDX_OUT0001PMP
		call	LoadPinMap
		ld	hl,IDX_SUB0018CHG
		call	UndoChanges

		ld	hl,outmaplist
		call	NewLoadMap
		ld	hl,IDX_OUTLIGHTSMAP
		call	SecondHalf

		call	outsaver.on

		ld	bc,0
.on:		push	bc
		ld	a,c
		add	a
		add	3
		call	outrect
		pop	bc
		push	bc
		ld	hl,IDX_OUT0002CHG
		add	hl,bc
		call	MakeChanges
		pop	bc
		inc	c
		ld	a,c
		cp	34
		jr	c,.on
		ld	a,70
		call	outrect


 call	SubAddBall

		call	subsaver

		ld	hl,outcollisions
		jp	MakeCollisions

FX		EQU	22<<5
FY		EQU	90<<5

outlostball:	ld	a,[any_ballsaver]
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

outflipper:
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
		cp	92
		jp	nc,SubHitFlipper_b

		ld	a,d
		cp	32
		jr	c,.col0
		cp	48
		jr	c,.col1
		cp	64
		jr	c,.col2
		cp	80
		jr	c,.col3
		cp	96
		jr	c,.col4
		cp	112
		jr	c,.col5
		cp	128
		jr	c,.col6
		cp	144
		jr	c,.col7
		jr	.col8
.col0:		ld	bc,(0<<8)+0
		jr	.cols
.col1:		ld	bc,(3<<8)+4
		jr	.cols
.col2:		ld	bc,(7<<8)+8
		jr	.cols
.col3:		ld	bc,(11<<8)+12
		jr	.cols
.col4:		ld	bc,(15<<8)+16
		jr	.cols
.col5:		ld	bc,(19<<8)+12
		jr	.cols
.col6:		ld	bc,(23<<8)+8
		jr	.cols
.col7:		ld	bc,(27<<8)+4
		jr	.cols
.col8:		ld	bc,(31<<8)+0
.cols:		ld	a,e
		add	c
		cp	48
		jr	c,.bp0
		cp	64
		jr	c,.bp1
		cp	80
		jr	c,.bp2
.bp3:		inc	b
.bp2:		inc	b
.bp1:		inc	b
.bp0:		ld	a,b
		push	af
		add	a
		add	2
		call	outrect
		pop	af
		ld	e,a
		ld	d,0
		ld	hl,IDX_OUT0002CHG
		add	hl,de
		call	UndoChanges
		ld	a,FX_OUTBULB
		call	InitSfx
		ld	hl,OUTSCORE1
		call	addthousandshlinform
		call	Credit1
		call	AnyDec2
		ld	a,[out_hit]
		dec	a
		ld	[out_hit],a
		cp	1
		ret	nz
		ld	a,71
		jp	outrect

outprocess:
		ld	a,[out_first]
		or	a
		jr	nz,.nope
		inc	a
		ld	[out_first],a
		ld	a,FX_OUTSTART
		call	InitSfx
.nope:

		call	SubEnd
		call	AnyDecTime
		ld	a,[wTime]
		and	15
		call	z,outsaver

		ld	hl,out_second
		inc	[hl]
		ld	a,[hl]
		cp	60
		jr	c,.nosecond
		ld	[hl],0

.nosecond:

		ret

outsaver:	ld	hl,any_ballsaver
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
		jp	outrect
.off:		ld	a,0
		jp	outrect


;a=#
outrect:	ld	hl,outrects
		jp	RectList


outrects:
		db	2,2,0,9,10,12		;  0 Saver 0
		db	2,2,0,6,10,12		;  1 Saver 1
		db	2,2,0,3,2,4		;  2 Bulb01 0
		db	2,2,0,0,2,4		;  3 Bulb01 1
		db	2,2,18,3,2,6		;  4 Bulb02 0
		db	2,2,18,0,2,6		;  5 Bulb02 1
		db	2,2,18,3,2,8		;  6 Bulb03 0
		db	2,2,18,0,2,8		;  7 Bulb03 1
		db	2,2,3,3,4,4		;  8 Bulb04 0
		db	2,2,3,0,4,4		;  9 Bulb04 1
		db	2,2,3,3,4,6		; 10 Bulb05 0
		db	2,2,3,0,4,6		; 11 Bulb05 1
		db	2,2,3,3,4,8		; 12 Bulb06 0
		db	2,2,3,0,4,8		; 13 Bulb06 1
		db	2,2,3,3,4,10		; 14 Bulb07 0
		db	2,2,3,0,4,10		; 15 Bulb07 1
		db	2,2,6,3,6,3		; 16 Bulb08 0
		db	2,2,6,0,6,3		; 17 Bulb08 1
		db	2,2,9,3,6,5		; 18 Bulb09 0
		db	2,2,9,0,6,5		; 19 Bulb09 1
		db	2,2,9,3,6,7		; 20 Bulb10 0
		db	2,2,9,0,6,7		; 21 Bulb10 1
		db	2,2,9,3,6,9		; 22 Bulb11 0
		db	2,2,9,0,6,9		; 23 Bulb11 1
		db	2,2,3,3,8,3		; 24 Bulb12 0
		db	2,2,3,0,8,3		; 25 Bulb12 1
		db	2,2,3,3,8,5		; 26 Bulb13 0
		db	2,2,3,0,8,5		; 27 Bulb13 1
		db	2,2,3,3,8,7		; 28 Bulb14 0
		db	2,2,3,0,8,7		; 29 Bulb14 1
		db	2,2,3,3,8,9		; 30 Bulb15 0
		db	2,2,3,0,8,9		; 31 Bulb15 1
		db	2,2,9,3,10,2		; 32 Bulb16 0
		db	2,2,9,0,10,2		; 33 Bulb16 1
		db	2,2,9,3,10,4		; 34 Bulb17 0
		db	2,2,9,0,10,4		; 35 Bulb17 1
		db	2,2,9,3,10,6		; 36 Bulb18 0
		db	2,2,9,0,10,6		; 37 Bulb18 1
		db	2,2,9,3,10,8		; 38 Bulb19 0
		db	2,2,9,0,10,8		; 39 Bulb19 1
		db	2,2,3,3,12,3		; 40 Bulb20 0
		db	2,2,3,0,12,3		; 41 Bulb20 1
		db	2,2,3,3,12,5		; 42 Bulb21 0
		db	2,2,3,0,12,5		; 43 Bulb21 1
		db	2,2,3,3,12,7		; 44 Bulb22 0
		db	2,2,3,0,12,7		; 45 Bulb22 1
		db	2,2,3,3,12,9		; 46 Bulb23 0
		db	2,2,3,0,12,9		; 47 Bulb23 1
		db	2,2,12,3,14,3		; 48 Bulb24 0
		db	2,2,12,0,14,3		; 49 Bulb24 1
		db	2,2,9,3,14,5		; 50 Bulb25 0
		db	2,2,9,0,14,5		; 51 Bulb25 1
		db	2,2,9,3,14,7		; 52 Bulb26 0
		db	2,2,9,0,14,7		; 53 Bulb26 1
		db	2,2,9,3,14,9		; 54 Bulb27 0
		db	2,2,9,0,14,9		; 55 Bulb27 1
		db	2,2,3,3,16,4		; 56 Bulb28 0
		db	2,2,3,0,16,4		; 57 Bulb28 1
		db	2,2,3,3,16,6		; 58 Bulb29 0
		db	2,2,3,0,16,6		; 59 Bulb29 1
		db	2,2,3,3,16,8		; 60 Bulb30 0
		db	2,2,3,0,16,8		; 61 Bulb30 1
		db	2,2,3,3,16,10		; 62 Bulb31 0
		db	2,2,3,0,16,10		; 63 Bulb31 1
		db	2,2,15,3,18,4		; 64 Bulb32 0
		db	2,2,15,0,18,4		; 65 Bulb32 1
		db	2,2,21,3,18,6		; 66 Bulb33 0
		db	2,2,21,0,18,6		; 67 Bulb33 1
		db	2,2,21,3,18,8		; 68 Bulb34 0
		db	2,2,21,0,18,8		; 69 Bulb34 1
		db	4,2,3,6,9,0		; 70 Switch 1
		db	4,2,3,9,9,0		; 71 Switch 0
		db	4,2,3,12,9,0		; 72 Switch 2



outbumper:
		ld	a,[out_hit]
		cp	1
		ld	a,FX_OUTSWITCH
		jp	nz,InitSfx
		ld	a,72
		call	outrect

		ld	a,FX_OUTWON
		call	InitSfx

		ld	a,[out_hit]
		dec	a
		ld	[out_hit],a
		ld	hl,OUTSCORE2
		call	addthousandshl
		call	Credit1
		call	AnyDec2

		call	AnyEnd


;		ldh	a,[pin_x]
;		ld	l,a
;		ldh	a,[pin_x+1]
;		ld	h,a
;		add	hl,hl
;		add	hl,hl
;		add	hl,hl
;		ld	d,h
;
;		ldh	a,[pin_y]
;		ld	l,a
;		ldh	a,[pin_y+1]
;		ld	h,a
;		add	hl,hl
;		add	hl,hl
;		add	hl,hl
;		ld	e,h

.soft:		ld	hl,pin_flags2
		res	PINFLG2_HARD,[hl]
		ret


outcollisions:
		dw	0

outhit:	ret

outsprites:

		jp	SubFlippers

