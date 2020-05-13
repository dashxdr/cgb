; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** PINLO.ASM                                                             **
; **                                                                       **
; ** Created : 20000302 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		include "msg.equ"

		section 00

;DE = x
;BC = y
;HL = xy vel
;returns hl=new ball struct or 0 if none available
AddBall::	push	hl
		ld	hl,wBalls	;flags
.balllook:	bit	BALLFLG_USED,[hl]
		jr	z,.ballfound
		ld	a,l
		add	BALLSIZE
		ld	l,a
		cp	LOW(wBalls)+BALLSIZE*MAXBALLS
		jr	c,.balllook
		pop	hl
		ld	hl,0
		ret
.ballfound:	ld	a,1<<BALLFLG_USED
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		ld	a,d
		pop	de
		push	hl
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		add	a
		ld	a,0
		sbc	a
		ld	[hli],a
		ld	a,c
		ld	[hli],a
		ld	a,b
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		add	a
		ld	a,0
		sbc	a
		ld	[hli],a
		xor	a
		ld	[hli],a		;rotations
		ld	[hli],a
		ld	[hli],a		;ballpause
		pop	hl
		dec	hl
		dec	hl
		ret


TimeCountStatus::
		ld	hl,$c800
		ld	a,$80-11
		ld	c,4
.clr:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.clr

		ld	hl,$c804
		ld	a,CHRCLOCK
		ld	[hli],a
		ld	a,[any_time]
		srl	a
		ld	b,CHR0-1
.div10:		inc	b
		sub	10
		jr	nc,.div10
		ld	[hl],b
		inc	hl
		add	CHR0+10
		ld	[hl],a


		ld	hl,$c810-2
		ld	de,any_count2
		ld	b,CHR0
		call	scdigit
		call	scdigit
		ld	hl,$c800
		ld	de,$9c00
		ld	c,1
		jp	DumpChrs
scdigit:	ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ret
AnyDecTime::
		ld	hl,any_time+1
		ld	a,[hl]
		or	a
		jr	z,.carry
.fine:		dec	[hl]
		ret
.carry:		ld	[hl],59
		dec	hl
		ldh	a,[pin_flags]
		set	PINFLG_SCORE,a
		ldh	[pin_flags],a
		ld	a,[hl]
		or	a
		jr	z,.over
		dec	[hl]
		ret	nz
;ran out of time.
.over:		ldh	a,[pin_flags]
		set	PINFLG_EXIT,a
		ldh	[pin_flags],a
		ret


AnyDec2::
		ldh	a,[pin_flags]
		set	PINFLG_SCORE,a
		ldh	[pin_flags],a
		ld	hl,any_count2+1
		ld	a,[hl]
		or	a
		jr	z,.carry
.fine:		dec	[hl]
		ret
.carry:		ld	[hl],9
		dec	hl
		ld	a,[hl]
		or	a
		jr	nz,.fine
;counted down to 0
		inc	hl
		ld	[hl],a
;		ldh	a,[pin_flags]
;		set	PINFLG_EXIT,a
;		ldh	[pin_flags],a
		ret

AnyInc2::
		ldh	a,[pin_flags]
		set	PINFLG_SCORE,a
		ldh	[pin_flags],a
		ld	hl,any_count2+1
		ld	a,[hl]
		cp	9
		jr	z,.carry
.fine:		inc	[hl]
		ret
.carry:		ld	[hl],0
		dec	hl
		ld	a,[hl]
		cp	9
		ret	z
		inc	[hl]
		ret

;hl=IDX of PMP file to load
LoadPinMap::	ld	a,WRKBANK_PINMAP1
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	de,$d000
		call	SwdInFileSys
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

SetPinInfo::	ld	de,wPinInfo
		ld	bc,wPinInfoEnd-wPinInfo
		jp	MemCopy

CountBalls:	ld	bc,1<<BALLFLG_USED
		ld	a,[wBalls+BALL_FLAGS]
		and	c
		jr	z,.noincb1
		inc	b
.noincb1:	ld	a,[wBalls+BALLSIZE+BALL_FLAGS]
		and	c
		jr	z,.noincb2
		inc	b
.noincb2:	ld	a,[wBalls+2*BALLSIZE+BALL_FLAGS]
		and	c
		jr	z,.noincb3
		inc	b
.noincb3:	ld	a,b
		ret

; x range 000-0ff ;d000-d3ff
; y range 000-1ff ;d400-dbff
; function lookup ;dc00-dc7f
;hl=list
BOXSIZE		EQU	3
MakeCollisions::
		push	hl
		ld	a,WRKBANK_COLL
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,$d000
		ld	bc,$1000
		call	MemClear
		pop	hl
		push	hl
		xor	a
.projecttop:	ldh	[hTmpLo],a
		add	a
		ld	c,a
		ld	b,$dc
		ld	a,[hli]
		ld	[bc],a
		ld	e,a
		inc	c
		ld	a,[hli]
		ld	[bc],a
		or	e
		jr	z,.endtop
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		inc	hl
		inc	hl
		ld	b,[hl]
		inc	hl
		inc	hl
		push	hl
		ld	h,d
		ld	l,e
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d0
		ld	h,a
		ldh	a,[hTmpLo]
		ld	c,a
		call	ormask

		pop	hl
		ldh	a,[hTmpLo]
		inc	a
		jr	.projecttop

.endtop:	pop	hl
		xor	a
.projectleft:	ldh	[hTmpLo],a
		ld	a,[hli]
		or	[hl]
		jr	z,.endleft
		inc	hl
		inc	hl
		inc	hl
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		inc	hl
		ld	b,[hl]
		inc	hl
		push	hl
		ld	h,d
		ld	l,e
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d4
		ld	h,a
		ldh	a,[hTmpLo]
		ld	c,a
		call	ormask

		pop	hl
		ldh	a,[hTmpLo]
		inc	a
		jr	.projectleft

.endleft:


		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret

;b=size
;c=bit
ormask:		sla	b
		push	bc
		sla	b
		ld	a,l
		sub	b
		ld	l,a
		ld	a,h
		sbc	0
		ld	h,a
		ld	a,c
		inc	a
		ld	bc,0
		ld	de,0
		stc
.rlp1:		rl	c
		rl	b
		rl	e
		rl	d
		dec	a
		jr	nz,.rlp1
		pop	af
		inc	a
.orlp:		ldh	[hTmpHi],a
		ld	a,[hl]
		or	c
		ld	[hli],a
		ld	a,[hl]
		or	b
		ld	[hli],a
		ld	a,[hl]
		or	e
		ld	[hli],a
		ld	a,[hl]
		or	d
		ld	[hli],a
		ldh	a,[hTmpHi]
		dec	a
		jr	nz,.orlp
		ret

LongVector::	ldh	a,[hRomBank]
		push	af
		ld	de,.longvectret
		push	de
		ld	a,[hli]
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
.longvectret:	pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

SubFlippers::
		ld	a,[wMapYPos+1]
		dec	a
		ld	l,a
		ld	a,[wMapYPos]
		and	$e0
		ld	h,0
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		rlca
		rl	l
		rl	h
		ld	de,B2FLIPPERY>>5
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		jr	nz,.nobottoms2
		ld	a,e
		cp	160
		jr	nc,.nobottoms2
		ld	a,[wMapXPos]
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,LB2FLIPPERX>>5
		sub	h
		ld	d,a
		ldh	a,[pin_lflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(RB2FLIPPERX-LB2FLIPPERX)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS)>>8
		ld	b,a
		ld	a,$80+GROUP_FLIPPERS
		call	AddFigure
.nobottoms2:	ret


Nothing::	ret

statusflash::
		ld	d,h
		ld	e,l
		call	findmessage
		ret	nz
		jp	FetchMessageBC

statusjackvalue:
		call	findmessage
		ret	nz
		ld	h,b
		ld	l,c
		jp	jackval

findmessage:
		ld	hl,any_messagelist
		ld	bc,wMessages
		ld	a,[hli]
		or	a
		jr	z,.takeit
		ld	bc,wMessages+40
		ld	a,[hli]
		or	a
		jr	z,.takeit
		ld	bc,wMessages+80
		ld	a,[hli]
		or	a
		jr	z,.takeit
		ld	bc,wMessages+120
		ld	a,[hli]
		or	a
		ret	nz
.takeit:	dec	hl
		ld	[hl],MESSAGETIME
		ret

AnyMessages::	ld	hl,any_messagelist
		ld	a,[hli]
		or	[hl]
		inc	hl
		or	[hl]
		inc	hl
		or	[hl]
		ret



SubAddBall3::
		ld	a,60+128
		ld	[any_subshoot],a
		ret
SubAddBall2::
		ld	a,60+64
		ld	[any_subshoot],a
		ret
SubAddBall::
		ld	a,60
		ld	[any_subshoot],a
		ret

subball:	dec	[hl]
		ld	a,[hl]
		and	$3f
		ret	nz
		ld	de,22<<5
		ld	bc,90<<5
		ld	hl,$0505
		jp	AddBall

SubEnd::	ld	hl,any_done
		ld	a,[hl]
		or	a
		jr	z,.normal
		dec	[hl]
		ret	nz
		jr	.end
.normal:	ld	hl,any_subshoot]
		ld	a,[hl]
		or	a
		jr	nz,subball
		call	CountBalls
		or	a
		ret	nz
.end:		ldh	a,[pin_flags]
		bit	PINFLG_EXIT,a
		ret	nz
		set	PINFLG_EXIT,a
		ldh	[pin_flags],a
		ld	a,FX_SUBLOST
		jp	InitSfx

;de=routine in bank #8
;a = # of ticks later to do it
addtimed:
		ld	hl,any_timed
		add	a
		ld	l,a
		ld	a,[any_timedpnt]
		add	l
		ld	l,a
.look0:		ld	a,[hli]
		or	[hl]
		jr	z,.take
		inc	l
		jr	.look0
.take:		ld	[hl],d
		dec	l
		ld	[hl],e
		ret

processtimed::
		ld	hl,any_timed
		ld	a,[any_timedpnt]
		ld	l,a
		inc	a
		inc	a
		ld	[any_timedpnt],a
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		or	d
		ret	z
		xor	a
		ld	[hld],a
		ld	[hl],a
		ld	h,d
		ld	l,e
		jp	[hl]


;bc=message text
FetchMessage::
		ld	bc,wMessage
FetchMessageBC::
		push	bc
		call	GetString

		ld	de,wString
		pop	hl
		ld	a,80
		ld	[hli],a
		ld	a,6
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
.zcpy:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,.zcpy
		ld	[hl],a
		ret


bonusmul:	push	af
		call	findmessage
		ld	h,b
		ld	l,c
		pop	bc
		ret	nz
		push	bc
		ld	a,80
		ld	[hli],a
		ld	a,5
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		push	hl
		ld	de,MSGBONUS
		call	GetString
		pop	hl
		ld	de,wString
		jr	.c
.t:		ld	[hli],a
.c:		ld	a,[de]
		inc	de
		or	a
		jr	nz,.t
		ld	a,' '
		ld	[hli],a
		pop	af
		cp	10
		jr	c,.dig1
		cp	100
		jr	c,.dig2
		cp	200
		jr	c,.dig1xx
		sub	200
		ld	[hl],"2"
		jr	.dig2xx
.dig1xx:	sub	100
		ld	[hl],"1"
.dig2xx:	inc	hl
.dig2:		ld	[hl],"0"-1
.div10:		inc	[hl]
		sub	10
		jr	nc,.div10
		inc	hl
		add	10		
.dig1:		add	"0"
		ld	[hli],a
		ld	a,"X"
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],a
		ret

jackval:	ld	a,80
		ld	[hli],a
		ld	a,5
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		push	hl
		ld	de,MSGJACKPOT
		call	GetString
		pop	hl
		ld	de,wString
		jr	.c
.t:		ld	[hli],a
.c:		ld	a,[de]
		inc	de
		or	a
		jr	nz,.t
		ld	a,' '
		ld	[hli],a
		ld	de,wLastJack
descoretohl::	push	hl
		ld	b,"0"
		ld	c,","
		call	.jack3
		ld	a,c
		ld	[hli],a
		call	.jack3
		ld	a,c
		ld	[hli],a
		call	.jack3
		ld	a,c
		ld	[hli],a
		call	.jack3
		xor	a
		ld	[hli],a
		ld	[hl],a
		pop	hl
		push	hl
		ld	e,14
.lead0:		ld	a,[hl]
		cp	b
		jr	z,.clear
		cp	c
		jr	nz,.done
.clear:		inc	hl
		dec	e
		jr	nz,.lead0
.done:		ld	d,h
		ld	e,l
		pop	hl
.c0:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,.c0
		ld	[hl],a
		ret
.jack3:		ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ld	a,[de]
		inc	de
		add	b
		ld	[hli],a
		ret


;**************************



;hl=0-9999
addthousandshl::
		call	hltolastjack
		ld	de,wLastJack
		jp	addscore

hltolastjack::
		add	hl,hl
		add	hl,hl
		ld	c,14
		ld	de,0
.lp:		add	hl,hl
		ld	a,e
		jr	nc,.noinc
		inc	a
.noinc:		add	e
		daa
		ld	e,a
		ld	a,d
		adc	a
		daa
		ld	d,a
		dec	c
		jr	nz,.lp
		xor	a
		ld	hl,wLastJack
		ld	c,15
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	a,d
		swap	a
		and	c
		ld	[hli],a
		ld	a,d
		and	c
		ld	[hli],a
		ld	a,e
		swap	a
		and	c
		ld	[hli],a
		ld	a,e
		and	c
		ld	[hli],a
		xor	a
		ld	[hli],a		
		ld	[hli],a		
		ld	[hl],a		
		ret

addscore::	ld	hl,wScore+11
		ld	bc,12
		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		dec	de
.addscorelp:	ld	a,[de]
		add	[hl]
		add	b
		ld	b,0
		cp	10
		jr	c,.noover10
		sub	10
		inc	b
.noover10:	ld	[hld],a
		dec	de
		dec	c
		jr	nz,.addscorelp
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
		ret	

saver5::
		jr	saver30

subsaver:	ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,subsavertimes
		add	hl,bc
		ld	a,[hl]
		ld	[any_ballsaver],a
		ret
subsavertimes:	db	SUBSAVERTIME*6,SUBSAVERTIME*3,SUBSAVERTIME


saver20::	ld	a,[any_ballsaver]
		cp	20
		jr	nc,.more20
		ld	a,20
		ld	[any_ballsaver],a
.more20:	ret
saver30::	ld	a,[any_ballsaver]
		cp	30
		jr	nc,.more30
		ld	a,30
		ld	[any_ballsaver],a
.more30:	ret
saver60::	ld	a,[any_ballsaver]
		cp	60
		jr	nc,.more60
		ld	a,60
		ld	[any_ballsaver],a
.more60:	ret




saveclock::	ld	hl,any_clock
		ld	bc,4
		jp	MemCopy



;hl=variable
;e=max value
incmax1::	ld	a,[hl]
		cp	e
		ret	z
		inc	[hl]
		ret

;hl=variable (2 bytes)
;de=max value
incmax2::	ld	a,[hli]
		cp	e
		ld	a,[hld]
		jr	nz,.inc
		cp	d
		ret	z
.inc:		inc	[hl]
		ret	nz
		inc	hl
		inc	[hl]
		ret

InitBalls::	ld	hl,wBalls
		ld	bc,MAXBALLS*BALLSIZE
		jp	MemClear


passedby::
		push	hl
		ldh	a,[pin_vx]
		ld	c,a
		ldh	a,[pin_vx+1]
		ld	b,a
		ld	a,h
		ld	e,l
		call	bcmula
		ldh	a,[pin_vy]
		ld	c,a
		ldh	a,[pin_vy+1]
		ld	b,a
		ld	a,e
		ld	d,h
		ld	e,l
		call	bcmula
		add	hl,de
		ld	d,h
		ld	e,l
		ld	a,h
		pop	hl
		add	a
		ld	a,1
		ret	nc
		dec	a
		ret

bcmula::	ld	h,0
		cp	$80
		jr	c,.apos
		inc	h
		cpl
		inc	a
.apos:		ld	l,a
		ld	a,b
		add	a
		jr	nc,.bcpos
		inc	h
		ld	a,c
		cpl
		ld	c,a
		ld	a,b
		cpl
		ld	b,a
		inc	bc
.bcpos:		ld	a,h
		push	af
		ld	a,l
		ld	hl,0
.mullp:		srl	a
		jr	nc,.noadd
		add	hl,bc
.noadd:		sla	c
		rl	b
		or	a
		jr	nz,.mullp
		pop	af
		srl	a
		ret	nc
		ld	a,l
		cpl
		ld	l,a
		ld	a,h
		cpl
		ld	h,a
		inc	hl
		ret



;A = bank for routines
dohits::	ld	b,a

		ldh	a,[hRomBank]
		push	af
		ld	a,b
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a

		ld	a,WRKBANK_COLL
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ldh	a,[pin_x+1]
		ld	l,a
		ld	h,0
		ldh	a,[pin_x]
		add	a
		rl	l
		rl	h
		add	a
		rl	l
		rl	h
		add	a
		rl	l
		rl	h
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d0
		ld	h,a
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	e,a
		ld	d,[hl]

		ldh	a,[pin_y+1]
		ld	l,a
		ld	h,0
		ldh	a,[pin_y]
		add	a
		rl	l
		rl	h
		add	a
		rl	l
		rl	h
		add	a
		rl	l
		rl	h
		add	hl,hl
		add	hl,hl
		ld	a,h
		add	$d4
		ld	h,a
		ld	a,[hli]
		and	c
		push	af
		ld	a,[hli]
		and	b
		push	af
		ld	a,[hli]
		and	e
		push	af
		ld	a,[hl]
		and	d
		ld	hl,$dc00+16*3
		call	nz,coll8
		pop	af
		ld	hl,$dc00+16*2
		call	nz,coll8
		pop	af
		ld	hl,$dc00+16*1
		call	nz,coll8
		pop	af
		ld	hl,$dc00+16*0
		call	nz,coll8

		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

coll8:		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		call	c,coll1
		inc	l
		inc	l
		rrca
		ret	nc
coll1:		push	hl
		push	af
		ld	bc,.nextcoll
		push	bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		jp	[hl]
.nextcoll:	ld	a,WRKBANK_COLL
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		pop	af
		pop	hl
		ret

SetCount2::	ld	b,-1
.div10:		inc	b
		sub	10
		jr	nc,.div10
		add	10
		ld	[any_count2+1],a
		ld	a,b
		ld	[any_count2],a
		ret

AnyQuit:	ldh	a,[pin_flags2]
		set	PINFLG2_QUIT,a
		ldh	[pin_flags2],a
AnyEnd::	ldh	a,[pin_flags]
		set	PINFLG_EXIT,a
		ldh	[pin_flags],a
		ret

BONUSVALSIZE	EQU	5

;b=10's digit, C = 1's digit, to add to bonus value
IncBonusVal::
		ld	a,[any_bonusmaxed]
		or	a
		ret	nz
		ld	hl,any_bonusval+BONUSVALSIZE-1
		ld	d,10
		ld	e,BONUSVALSIZE
		ld	a,c
.add:		add	[hl]
		ld	[hl],a
		sub	d
		jr	c,.ok
		inc	b
		ld	[hl],a
.ok:		dec	hl
		ld	c,b
		ld	b,0
		ld	a,c
		or	a
		ret	z
		dec	e
		jr	nz,.add
		ld	a,1
		ld	[any_bonusmaxed],a
		ld	hl,any_bonusval
		ld	bc,BONUSVALSIZE
		ld	a,9
		jp	MemFill

ClearBonusVal::	ld	hl,any_bonusval
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ld	[any_bonusmaxed],a
		ret

CHR0		EQU	$80-10
CHRBLANK	EQU	$80-11
CHRCOLON	EQU	$80-12
CHRCOMMA	EQU	$80-13
CHRX		EQU	$80-14
CHRBALL		EQU	$80-15
CHRCLOCK	EQU	$80-16
CHRPERIOD	EQU	$80-17
PinScore::	ld	de,wScore
		ld	hl,$c800

		ld	a,[any_tabletime]
		or	a
		jr	z,.ballsleft
		ld	c,a
		ld	a,CHRCLOCK
		ld	[hli],a
		ld	[hl],CHR0-1
		ld	a,c
		srl	a
.div10:		inc	[hl]
		sub	10
		jr	nc,.div10
		inc	hl
		add	CHR0+10
		ld	[hli],a
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hli],a
		jr	.timeleft

.ballsleft:
		ld	a,CHRBALL
		ld	[hli],a
		ld	a,[any_ballsleft]
		cp	9
		jr	c,.aok
		ld	a,9
.aok:		add	CHR0
		ld	[hli],a
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
.timeleft:
		ld	c,12/3
		ld	b,CHR0
		jr	.copyenter
.copy:		ld	a,CHRCOMMA
		ld	[hli],a
.copyenter:	ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		dec	c
		jr	nz,.copy
		ld	hl,$c805
		ld	b,CHR0
		ld	c,CHRCOMMA
		ld	d,CHRBLANK
		ld	e,15
		jr	.kill0
.kill1:		ld	a,d
		ld	[hli],a
.kill0:		dec	e
		jr	z,.donekill0
		ld	a,[hl]
		cp	b
		jr	z,.kill1
		cp	c
		jr	z,.kill1
.donekill0:	ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		jp	DumpChrs

BonusScore::
		ld	hl,$c800
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	a,[any_bonusmul]
		ld	b,-1
.div10:		inc	b
		sub	10
		jr	nc,.div10
		add	CHR0+10
		ld	c,a
		ld	a,b
		or	a
		ld	a,CHRBLANK
		jr	z,.aok
		ld	a,b
		add	CHR0
.aok:		ld	[hli],a
		ld	a,c
		ld	[hli],a
		ld	a,CHRBLANK
		ld	[hli],a
		ld	a,CHRX
		ld	[hli],a
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a

		ld	b,CHR0
		ld	de,any_bonusval

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,CHRCOMMA
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		add	b
		ld	[hli],a

		ld	a,CHRCOMMA
		ld	[hli],a

		ld	a,b
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a

		ld	hl,$c80a
		ld	b,CHR0
		ld	c,CHRCOMMA
		ld	d,CHRBLANK
		ld	e,10
		jr	.kill0
.kill1:		ld	a,d
		ld	[hli],a
.kill0:		dec	e
		jr	z,.donekill0
		ld	a,[hl]
		cp	b
		jr	z,.kill1
		cp	c
		jr	z,.kill1
.donekill0:

		ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		jp	DumpChrs

BonusTotal:
		ld	de,wScore
		ld	hl,$c800
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	c,12/3
		ld	b,CHR0
		jr	.copyenter
.copy:		ld	a,CHRCOMMA
		ld	[hli],a
.copyenter:	ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		ld	a,[de]
		inc	e
		add	b
		ld	[hli],a

		dec	c
		jr	nz,.copy
		ld	a,CHRBLANK
		ld	[hli],a
		ld	[hl],a
		ld	hl,$c803
		ld	b,CHR0
		ld	c,CHRCOMMA
		ld	d,CHRBLANK
		ld	e,15
		jr	.kill0
.kill1:		ld	a,d
		ld	[hli],a
.kill0:		dec	e
		jr	z,.donekill0
		ld	a,[hl]
		cp	b
		jr	z,.kill1
		cp	c
		jr	z,.kill1
.donekill0:	ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		jp	DumpChrs

statusde::
		call	FetchMessage
		ld	de,wMessage
statusstring:
		ld	hl,$c800
		ld	c,20
		ld	a,$ff
.fill:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.fill
		call	picklite
		ld	a,$10
		ld	[wFontStrideLo],a
		xor	a
		ld	[wFontStrideHi],a
		ld	h,d
		ld	l,e

		call	DrawStringLst

		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,$c800
		ld	de,$9580
		ld	c,20
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		jp	pinmsg

pinclear:	ld	hl,$c800
		ld	a,$80-11
		ld	c,5
.fill:		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		dec	c
		jr	nz,.fill
		ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		jp	DumpChrs
pinmsg:		ld	hl,$c800
		ld	a,$80-40
		ld	c,5
.fill:		ld	[hli],a
		inc	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		inc	a
		dec	c
		jr	nz,.fill
		ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		jp	DumpChrs


scoopscore::	db	0,0,0,0,0,0,0,0,1,1,1,1
spinnerscore::	db	0,0,0,0,0,0,0,0,0,3,3,3
dropscore::	db	0,0,0,0,0,0,0,0,1,0,0,0
bumperscore::	db	0,0,0,0,0,0,0,0,2,0,0,0
loopscore::	db	0,0,0,0,0,0,0,0,2,0,0,0
rampscore::	db	0,0,0,0,0,0,0,0,2,0,0,0
scorerolloverunlit: db	0,0,0,0,0,0,0,0,0,7,0,0

score1m::	db	0,0,0,0,0,1,0,0,0,0,0,0

Eject::		ld	a,HOLDTIME
		ldh	[pin_ballpause],a
		ld	a,e
		ldh	[pin_x],a
		ld	a,d
		ldh	[pin_x+1],a
		ld	a,c
		ldh	[pin_y],a
		ld	a,b
		ldh	[pin_y+1],a
		ld	a,FX_SCOOPIN
		call	InitSfx
		call	RumbleLow
		ld	de,scoopscore
		jp	addscore

BonusProcess::
		ld	a,[any_bonusinfo1]
		or	a
		ret	z
		ld	c,a
		ld	hl,any_bonusinfo2
		ld	a,[hl]
		or	a
		jr	z,.nopause
		dec	[hl]
		jp	.notyet
.nopause:	dec	c
		jr	z,.first
		dec	c
		jr	z,.second
		dec	c
		jr	z,.third
		dec	c
		jr	z,.fourth
		dec	c
		jr	z,.fifth
		jr	.last
.first:		call	AnyMessages
		jr	nz,.notyet
		ld	a,30
		jr	.next
.second:	ld	de,MSGBONUS
		call	statusde
		ld	a,30
		jr	.next
.third:		call	BonusScore
		ld	a,60
		jr	.next
.fourth:
		ld	de,wScoreBackup
		ld	hl,wScore
		ld	bc,12
		call	MemCopy
		ld	hl,wScore
		ld	bc,12
		call	MemClear
		ld	hl,$c800
		ld	bc,12
		call	MemClear
		ld	hl,any_bonusval
		ld	de,$c800+4
		ld	bc,5
		call	MemCopy
		ld	a,[any_bonusmul]
		or	a
		jr	z,.none
.addlp:		ld	de,$c800
		call	addscore
		ld	hl,any_bonusmul
		dec	[hl]
		jr	nz,.addlp
.none:		ld	hl,pin_flags
		res	PINFLG_SCORE,[hl]
		call	BonusTotal
		ld	a,60
		jr	.next
.fifth:		ld	de,wScoreBackup
		call	addscore
		call	PinScore
		ld	a,30
;		jr	.next
.last:		xor	a
		ld	[any_bonusinfo1],a
		jr	.done
.next:		ld	[any_bonusinfo2],a
		ld	hl,any_bonusinfo1
		inc	[hl]
.notyet:	xor	a
		ret
.done:		ld	a,1
		or	a
		ret

BONUSCOUNTTIME	EQU	20


flashlist::	add	a
		add	l
		ld	l,a
		ld	a,0
		adc	h
		ld	h,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	statusflash


ComboSound::	or	a
		ret	z
		ld	b,a
		ld	a,FX_COMBO1
		dec	b
		jr	z,.aok
		ld	a,FX_COMBO2
		dec	b
		jr	z,.aok
		ld	a,FX_COMBO3
		dec	b
		jr	z,.aok
		ld	a,FX_COMBO4
.aok:		jp	InitSfx


ResultScreen::
		ld	a,[wDemoMode]
		or	a
		ret	nz
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(ResultScreen_b)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		call	ResultScreen_b
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret



;********************************************************************
;********************************************************************

ChainSub::	ldh	[pin_chainwant],a
		xor	a
		ld	[any_credit1],a
		ld	a,FX_CHAINSUB
		call	InitSfx
		ldh	a,[pin_chainwant]
		jp	subsonga


TblSin::
		db	0
		db	3
		db	6
		db	9
		db	12
		db	15
		db	17
		db	20
		db	22
		db	24
		db	26
		db	28
		db	29
		db	30
		db	31
		db	31
TblCos::
		db	32
		db	31
		db	31
		db	30
		db	29
		db	28
		db	26
		db	24
		db	22
		db	20
		db	17
		db	15
		db	12
		db	9
		db	6
		db	3
		db	0
		db	-3
		db	-6
		db	-9
		db	-12
		db	-15
		db	-17
		db	-20
		db	-22
		db	-24
		db	-26
		db	-28
		db	-29
		db	-30
		db	-31
		db	-31
		db	-32
		db	-31
		db	-31
		db	-30
		db	-29
		db	-28
		db	-26
		db	-24
		db	-22
		db	-20
		db	-17
		db	-15
		db	-12
		db	-9
		db	-6
		db	-3
		db	0
		db	3
		db	6
		db	9
		db	12
		db	15
		db	17
		db	20
		db	22
		db	24
		db	26
		db	28
		db	29
		db	30
		db	31
		db	31

playerstores:	dw	wStore1
		dw	wStore2
		dw	wStore3
		dw	wStore4

;a=player # 0,1,2,3
SavePlayer::	add	a
		ld	c,a
		ld	b,0
		ld	hl,playerstores
		add	hl,bc
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		ld	hl,wScore
		ld	bc,12
		call	MemCopy
		ld	hl,wTemp1024
		ld	bc,192
		call	MemCopy
		ld	hl,hTemp48
		ld	bc,48
		jp	MemCopy

;a=player # 0,1,2,3
RestorePlayer::	add	a
		ld	c,a
		ld	b,0
		ld	hl,playerstores
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	de,wScore
		ld	bc,12
		call	MemCopy
		ld	de,wTemp1024
		ld	bc,192
		call	MemCopy
		ld	de,hTemp48
		ld	bc,48
		call	MemCopy
		ld	hl,wTiltTimes
		ld	bc,32
		jp	MemClear

SwitchPlayers::
		ldh	a,[hRomBank]
		push	af
		ld	a,BANK(OffFlippers)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		call	OffFlippers
		ld	a,[wActivePlayer]
		ldh	[hTmpLo],a
		call	SavePlayer
		ld	hl,wTemp1024
		ld	bc,1024-128
		call	MemClear
.switchlp:	ld	a,[wNumPlayers]
		ld	b,a
		ld	a,[wActivePlayer]
		inc	a
		cp	b
		jr	nz,.fine
		xor	a
.fine:		ld	[wActivePlayer],a
		call	RestorePlayer
		ldh	a,[hTmpLo]
		ld	b,a
		ld	a,[any_ballsleft]
		or	a
		jr	nz,.fine2
		ld	a,[wActivePlayer]
		cp	b
		jr	nz,.switchlp
		ld	a,SHUTDOWNTIME
		ld	[any_shutdown],a
.fine2:		call	OnFlippers
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		jr	SetDifficulty

SetDifficulty::
		ld	a,[wDemoMode]
		or	a
		ld	a,2
		jr	nz,.hard
		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		ld	hl,bMenus+OPT_DIFFICULTY
		add	hl,bc
		ld	a,[hl]
.hard:		ldh	[pin_difficulty],a
		ld	c,a
		ld	b,0
		ld	hl,difficultyspeeds
		add	hl,bc
		ld	a,[hl]
		ld	[wSpeed],a
		ret
difficultyspeeds:
		db	$11,$aa,$ee


Credit1::
		push	hl
		ld	hl,any_credit1
		inc	[hl]
		pop	hl
		ret

SetTime::
		ldh	a,[pin_difficulty]
		ld	c,a
		ld	b,0
		ld	hl,subtimes
		add	hl,bc
		ld	a,[hl]
		ld	[any_time],a
		ret
subtimes:	db	100,80,60
;
;		add	a
;		ld	c,a
;		ldh	a,[pin_difficulty]
;		or	a
;		jr	z,.cok
;		ld	b,c
;		srl	c
;		dec	a
;		jr	nz,.cok
;		srl	c
;		ld	a,b
;		sub	c
;		ld	c,a
;.cok:		ld	a,c
;		ld	[any_time],a
;		ret


songmap:	db	SONG_TABLE
		db	SONG_FALCON
		db	SONG_KISS
		db	SONG_RAPIDS
		db	SONG_LOOPER
		db	SONG_BUILD
		db	SONG_BEAR
		db	SONG_BOAT
		db	SONG_RACE
		db	SONG_SIDE
		db	SONG_OUT
		db	0
		db	0
		db	0
		db	0
		db	0
		db	0
		db	0

SubSong::	ld	a,[pin_board]
subsonga:	ld	c,a
		ld	b,0
		ld	hl,songmap
		add	hl,bc
		ld	a,c
		cp	SUBGAME_TABLE
		jr	z,.to1
		ld	a,[hl]
		jr	PrefTune2
.to1:		ld	a,[hl]
		jr	PrefTune1
PrefTune1::	ld	c,a
		ld	a,[bMenus+OPT_OPTIONS+0]
		or	a
		ld	a,c
		jr	z,.aok
		xor	a
.aok:		jp	InitTune

PrefTune2::	ld	c,a
		ld	a,[bMenus+OPT_OPTIONS+1]
		or	a
		ld	a,c
		jr	z,.aok
		xor	a
.aok:		jp	InitTune

;low
;  Drop target
;  Sea target
;  Ariel/melody letter (not complete)
;medium
;  Any pop bumper
;high
;  Firing the ball
;  Kickback
;  Kicked out of scoop

RumbleLow::
		ld	b,$c9
		jr	rumbles
RumbleMedium::
		ld	b,$d5
		jr	rumbles
RumbleHigh::
		ld	b,$ff
rumbles:
		ld	a,[wDemoMode]
		or	a
		ret	nz
		ld	a,[any_rumble]
		or	a
		ret	nz
		ld	a,[bMenus+OPT_OPTIONS+2]
		or	a
		ret	nz
		ld	a,b
		ld	[any_rumbleshift],a
		ld	a,RUMBLETIME
		ld	[any_rumble],a
		ret		

;de = # of pkg file
loadpic::	push	de
		call	SetBitmap20x18
		pop	de
		jp	XferBitmap

copyshow::
		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		jp	FadeInBlack

fxmove::	ld	a,FX_MOVEBEEP
		jp	InitSfx
fxsel::		ld	a,FX_SELBEEP
		jp	InitSfx
fxback::	ld	a,FX_BACKBEEP
		jp	InitSfx
fxillegal::	ld	a,FX_ILLEGAL
		jp	InitSfx
menutune::	ld	a,[bMenus+OPT_OPTIONS]
		or	a
		ld	a,SONG_MENUS
		jr	z,.aok
		xor	a
.aok:		jp	InitTune
TVSet::		ld	[any_tv],a
		ld	hl,pin_flags2
		set	PINFLG2_TV,[hl]
		ret

DemoMode::
		ld	a,[hRomBank]
		push	af
		ld	a,BANK(pintest)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		xor	a
		ld	[wDemoL],a
		ld	[wDemoR],a
		inc	a
		ld	[wDemoMode],a
		ld	[wNumPlayers],a
		xor	a
		ld	[wActivePlayer],a

.r18:		call	random
		and	31
		cp	18
		jr	nc,.r18
		call	pintest
		xor	a
		ld	[wDemoMode],a
		call	SetMachineJcb
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret
settabletime:
		ld	[any_tabletime],a
		ret

RectList::	add	a
		ld	c,a
		ld	b,0
		add	hl,bc
		add	hl,bc
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
ProcessDirties::
		ld	a,[hRomBank]
		push	af
		ld	a,BANK(ProcessDirties_real)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		call	ProcessDirties_real
		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a
		ret

SubSaver::
		ld	a,[any_ballsaver]
		or	a
		ret	z
		ld	a,[any_subshoot]
		ld	b,1
		or	a
		jr	z,.bok
		ld	b,64
.bok:		add	b
		ld	[any_subshoot],a
		ret

dorelit::	ld	hl,100
		jr	addthousandshlinform

;hl = # of 1000's to add
;add the value to score, then show "# points!" message.
addthousandshlinform::
		call	addthousandshl
		call	findmessage
		ret	nz
		ld	h,b
		ld	l,c
		ld	a,80
		ld	[hli],a
		ld	a,6
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		ld	de,wLastJack
		jp	descoretohl



;********************************************************************
;********************************************************************
