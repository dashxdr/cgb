; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SOULS.ASM                                                             **
; **                                                                       **
; ** Created : 20000216 by David Ashley                                    **
; **  File included in pin.asm                                             **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	09


soul_hitcounts	EQUS	"wTemp1024+00"	;16 bytes
soul_savecount	EQUS	"wTemp1024+16"
soul_mermx	EQUS	"wTemp1024+17"
soul_mermy	EQUS	"wTemp1024+18"
soul_mermcount	EQUS	"wTemp1024+19"

GROUP_MERMAID	EQU	2

soulinfo:	db	BANK(soulhit)		;wPinJmpHit
		dw	soulhit
		db	BANK(soulprocess)	;wPinJmpProcess
		dw	soulprocess
		db	BANK(soulsprites)	;wPinJmpSprites
		dw	soulsprites
		db	BANK(SubHitFlipper)	;wPinJmpHitFlipper
		dw	SubHitFlipper
		db	BANK(Nothing)		;wPinJmpPerBall
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpHitBumper
		dw	Nothing
		db	BANK(TimeCountStatus)	;wPinJmpScore
		dw	TimeCountStatus
		db	BANK(Nothing)		;wPinJmpLost
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpEject
		dw	Nothing
		db	BANK(Nothing)		;wPinJmpChainRet
		dw	Nothing
		dw	CUTOFFY2	;wPinCutoff
		dw	IDX_SUBDET001CHG	;lsubflippers
		dw	IDX_SUBDET009CHG	;rsubflippers
		db	0			;wPinHitBank
		db	BANK(Char10)		;wPinCharBank

soulmaplist:	db	21
		dw	IDX_SOULBACKRGB
		dw	IDX_SOULBACKMAP

SoulInit::

		ld	hl,soulinfo
		call	SetPinInfo

		ld	a,TIME_CAVE
		call	SetTime
		ld	a,NEED_CAVE
		call	SetCount2

		xor	a
		ld	[soul_mermcount],a
		ld	hl,PAL_FLIPPERS
		call	AddPalette
		ld	hl,PAL_MERMAID
		call	AddPalette

		ld	hl,soul_hitcounts
		ld	c,15
.hcfill:	call	random
		and	7
		or	$10
		ld	[hli],a
		dec	c
		jr	nz,.hcfill
		ld	a,15
		ld	[soul_savecount],a

		ld	hl,IDX_SUBDET000PMP
		call	LoadPinMap

		ld	hl,soulmaplist
		call	NewLoadMap
		ld	hl,IDX_SOULSMAP
		call	SecondHalf

 call	SubAddBall

		call	soulbg

		ld	hl,soulcollisions
		jp	MakeCollisions



soulreptable:	dw	IDX_SUBDET017CHG
		dw	IDX_SUBDET018CHG
		dw	IDX_SUBDET019CHG
		dw	IDX_SUBDET020CHG
		dw	IDX_SUBDET021CHG
		dw	IDX_SUBDET022CHG
		dw	IDX_SUBDET023CHG
		dw	IDX_SUBDET024CHG
		dw	IDX_SUBDET025CHG
		dw	IDX_SUBDET026CHG
		dw	IDX_SUBDET027CHG
		dw	IDX_SUBDET028CHG
		dw	IDX_SUBDET029CHG
		dw	IDX_SUBDET030CHG
		dw	IDX_SUBDET031CHG

soulbg:
		ld	hl,soulreptable
		ld	e,0
.soulbglp:	ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		push	hl
		push	de
		ld	h,a
		ld	l,c
		ld	a,e
		cp	2
		call	nz,MakeChanges
		pop	de
		pop	hl
		inc	e
		ld	a,e
		cp	15
		jr	c,.soulbglp
		ret


soulprocess:
		call	AnyDecTime
		call	SubEnd
		ld	a,[wTime]
		and	15
		ret	z
		dec	a
		ld	e,a
		ld	d,0
		ld	hl,soul_hitcounts
		add	hl,de
		ld	a,[hl]
		ld	b,a
		and	$f0
		ret	z
		ld	c,a
		cp	$10
		jr	z,.soul1
		cp	$20
		jr	z,.soul1a
		cp	$30
		jr	z,.soul2
		cp	$40
		jr	z,.soul2a
		cp	$50
		jr	z,.soul2
		cp	$60
		jr	z,.soul2b
		jr	.soul3

.soul1:		xor	b
		inc	a
		cp	8
		jr	c,.aok1
		xor	a
.aok1:		or	c
		ld	[hl],a
		ld	hl,soul1list
		jr	.reacttab

.soul2:		xor	b
		inc	a
		cp	5
		jr	c,.aok2
		xor	a
.aok2:		or	c
		ld	[hl],a
		ld	hl,soul2list
		jr	.reacttab

.soul3:		ld	a,b
		cp	$c0
		jr	nz,.removed
		push	hl
		push	de
		ld	hl,soul_savecount
		dec	[hl]
		ld	hl,soulreptable
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	UndoChanges
		ld	a,[soul_savecount]
		dec	a
		ld	hl,IDX_SUBDET019CHG
		call	z,MakeChanges
		pop	de
		pop	hl
.removed:	ld	a,[hl]
		inc	[hl]
		cp	$c0+7
		jr	c,.transforming
; xor a
; ld [hl],a
; ret
		ld	a,$c0+3
		ld	[hl],a
.transforming:
		and	$3f
		ld	hl,soul3list
		jr	.reacttab

.soul1a:	ld	a,[hl]
		xor	c
		inc	a
		cp	2
		jr	c,.aok1a
		ld	c,$30
		xor	a
.aok1a:		or	c
		ld	[hl],a
		ld	a,3
		jr	.react

.soul2a:	ld	a,[hl]
		xor	c
		inc	a
		cp	2
		jr	c,.aok2a
		ld	c,$c0
		xor	a
.aok2a:		or	c
		ld	[hl],a
		ld	a,9
		jr	.react

.soul2b:	ld	a,[hl]
		xor	c
		inc	a
		cp	2
		jr	c,.aok2b
		ld	c,$c0
		xor	a
.aok2b:		or	c
		ld	[hl],a
		ld	a,9
		jr	.react

.reacttab:	and	15
		add	l
		ld	l,a
		ld	a,0
		adc	h
		ld	h,a
		ld	a,[hl]
.react:		ld	hl,soultable
		add	hl,de
		add	hl,de
		add	hl,de
		add	hl,de
		ld	e,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		push	bc	;where to put
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a	;bc = size
		add	hl,de
		add	hl,de
		ld	a,[hli]
		ld	e,[hl]
		ld	d,a	;de = where from
		pop	hl
		jp	BGRect

soul1list:	db	0,0,0,0,0,1,1,2
soul2list:	db	4,5,6,7,8
soul3list:	db	10,11,12,13,14,15,16

soultable:	db	3,0
		dw	soultype1
		db	6,0
		dw	soultype1
		db	9,0
		dw	soultype3
		db	14,0
		dw	soultype1
		db	17,0
		dw	soultype1
		db	2,4
		dw	soultype2
		db	5,4
		dw	soultype2
		db	8,4
		dw	soultype2
		db	11,4
		dw	soultype2
		db	14,4
		dw	soultype2
		db	17,4
		dw	soultype2
		db	5,8
		dw	soultype2
		db	8,8
		dw	soultype2
		db	11,8
		dw	soultype2
		db	14,8
		dw	soultype2

soultype1:	db	2,4	;size
		db	0,0
		db	3,0
		db	6,0
		db	9,0
		db	12,0
		db	15,0
		db	18,0
		db	21,0
		db	0,4
		db	3,4
		db	6,4
		db	9,4
		db	12,4
		db	15,4
		db	18,4
		db	21,4
		db	17,26

soultype2:	db	3,4
		db	0,8
		db	3,8
		db	6,8
		db	9,8
		db	12,8
		db	15,8
		db	18,8
		db	21,8
		db	0,12
		db	3,12
		db	6,12
		db	9,12
		db	12,12
		db	15,12
		db	18,12
		db	21,12
		db	20,26
soultype3:	db	4,4
		db	0,16
		db	4,16
		db	8,16
		db	12,16
		db	16,16
		db	20,16
		db	0,21
		db	4,21
		db	8,21
		db	12,21
		db	16,21
		db	20,21
		db	0,26
		db	4,26
		db	8,26
		db	12,26
		db	20,26


B2ROW1MIN	EQU	(41-21)<<4
B2ROW1MAX	EQU	(41+21)<<4
B2ROW2MIN	EQU	(105-21)<<4
B2ROW2MAX	EQU	(105+21)<<4
B2ROW3MIN	EQU	(169-21)<<4
B2ROW3MAX	EQU	(169+21)<<4
B2X1		EQU	(62-19)<<4	;2 upper left
B2X2		EQU	(174-19)<<4	;1 triton
B2X3		EQU	(238-19)<<4	;2 upper right
B2X4		EQU	(54-19)<<4	;6 middle
B2X5		EQU	(102-19)<<4	;4 bottom
B2SPACEX	EQU	48<<4
B2SIZEX		EQU	38<<4


soulhit:	ldh	a,[pin_x]
		ld	e,a
		ldh	a,[pin_x+1]
		ld	d,a
		ldh	a,[pin_y]
		ld	c,a
		sub	255&B2ROW1MIN
		ldh	a,[pin_y+1]
		ld	b,a
		sbc	B2ROW1MIN>>8
		ret	c
		ld	a,c
		sub	255&B2ROW1MAX
		ld	a,b
		sbc	B2ROW1MAX>>8
		jr	nc,.notrow1
		ld	a,e
		sub	255&B2X2
		ld	a,d
		sbc	B2X2>>8
		jr	c,.b2row1a
		ld	a,e
		sub	255&(B2X2+B2SIZEX)
		ld	a,d
		sbc	(B2X2+B2SIZEX)>>8
		jr	nc,.b2row1b
		ld	l,2
		jr	.b2hit
.b2row1a:	ld	a,e
		sub	255&B2X1
		ld	e,a
		ld	a,d
		sbc	B2X1>>8
		ld	d,a
		ld	l,0
		ld	h,2
		jr	.b2mods
.b2row1b:	ld	a,e
		sub	255&B2X3
		ld	e,a
		ld	a,d
		sbc	B2X3>>8
		ld	d,a
		ld	l,3
		ld	h,2
		jr	.b2mods
.notrow1:	ld	a,c
		sub	255&B2ROW2MIN
		ld	a,b
		sbc	B2ROW2MIN>>8
		ret	c
		ld	a,c
		sub	255&B2ROW2MAX
		ld	a,b
		sbc	B2ROW2MAX>>8
		jr	nc,.notrow2
		ld	a,e
		sub	255&B2X4
		ld	e,a
		ld	a,d
		sbc	B2X4>>8
		ld	d,a
		ret	c
		ld	l,5
		ld	h,6
		jr	.b2mods
.notrow2:	ld	a,c
		sub	255&B2ROW3MIN
		ld	a,b
		sbc	B2ROW3MIN>>8
		ret	c
		ld	a,c
		sub	255&B2ROW3MAX
		ld	a,b
		sbc	B2ROW3MAX>>8
		ret	nc
		ld	a,e
		sub	255&B2X5
		ld	e,a
		ld	a,d
		sbc	B2X5>>8
		ld	d,a
		ret	c
		ld	l,11
		ld	h,4
		jr	.b2mods
.b2mods:	ld	a,e
		sub	255&B2SIZEX
		ld	a,d
		sbc	B2SIZEX>>8
		jr	c,.b2hit
		ld	a,e
		sub	255&B2SPACEX
		ld	e,a
		ld	a,d
		sbc	B2SPACEX>>8
		ld	d,a
		ret	c
		inc	l
		dec	h
		jr	nz,.b2mods
		ret
.b2hit:		ld	d,0
		ld	e,l
		ld	a,e
		cp	2
		jr	nz,.nottriton
		ld	a,[soul_savecount]
		dec	a
		ret	nz
.nottriton:	ld	hl,soul_hitcounts
		add	hl,de
		ld	a,[hl]
		bit	4,a
		ret	z
		and	$f0
		add	$10
		ld	[hl],a
		call	Credit2
		ld	a,FX_SOULHIT
		jp	InitSfx

soulsprites:
		ld	a,[soul_mermcount]
		or	a
		jr	z,.nomerm
		ld	c,a
		and	$c0
		ld	b,a
		ld	a,c
		inc	a
		and	$3f
		or	b
		ld	[soul_mermcount],a
		srl	a
		srl	a
		and	3
		ld	c,a
		ld	hl,IDX_MERMAID
		bit	6,b
		jr	z,.hlok
		ld	hl,IDX_MERMAN
.hlok:		ld	b,0
		add	hl,bc
		ld	b,h
		ld	c,l
		ld	a,[soul_mermx]
		ld	d,a
		ld	a,[soul_mermy]
		dec	a
		dec	a
		ld	e,a
		ld	[soul_mermy],a
		cp	$90
		jr	c,.noreset
		cp	$e0
		jr	nc,.noreset
		xor	a
		ld	[soul_mermcount],a
.noreset:	ld	a,GROUP_MERMAID
		call	AddFigure
		jr	.wasmerm
.nomerm:	call	anytransforming
		
.wasmerm:
		jp	SubFlippers


anytransforming:
		ld	hl,soul_hitcounts
		ld	c,15
		ld	b,$c7
.looklp:	ld	a,[hli]
		cp	b
		jr	z,.found
		dec	c
		jr	nz,.looklp
		ret
.found:		dec	hl
		ld	[hl],0
		ld	a,15
		sub	c
		add	a
		ld	c,a
		ld	b,0
		ld	hl,mermpositions
		add	hl,bc
		ld	a,[hli]
		sub	8
		ld	[soul_mermx],a
		ld	a,[hl]
		sub	8
		ld	[soul_mermy],a
		call	random
		or	$80
		ld	[soul_mermcount],a
		call	Credit1
		ld	a,FX_SOULSAVE
		call	InitSfx
		call	AnyDec2
		ld	hl,any_count2
		ld	a,[hli]
		or	[hl]
		jr	nz,.notdone
		ld	a,HOLDTIME
		ld	[any_done],a
.notdone:	ret
mermpositions:	db	31,20
		db	55,20
		db	87,20
		db	119,20
		db	142,20
		db	27,52
		db	51,52
		db	75,52
		db	99,52
		db	123,52
		db	147,52
		db	51,84
		db	75,84
		db	99,84
		db	123,84



soulcollisions:
		dw	0

;***********************************************************************
;***********************************************************************

