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
lHL = xy vel
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
		ld	b,$80-10
		ld	de,any_time
		call	scdigit
		ld	a,$80-12
		ld	[hli],a
		call	scdigit
		call	scdigit
		ld	hl,$c810-2
		ld	de,any_count2
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
;		ldh	a,[pin_difficulty]
;		or	a
;		jr	nz,.force
;		ld	a,[wTime]
;		srl	a
;		ret	nc
;.force:
		ld	hl,any_time+3
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
		jr	nz,.fine
		ld	[hl],9
		dec	hl
		ld	a,[hl]
		or	a
		jr	nz,.fine
		ld	[hl],5
		dec	hl
		ld	a,[hl]
		or	a
		jr	nz,.fine
;ran out of time.
		inc	hl
		ld	[hli],a
		ld	[hli],a
		ldh	a,[pin_flags]
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
		add	255&(IDX_FLIPPERS+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS+18)>>8
		ld	b,a
		ld	a,GROUP_FLIPPERS
		push	de
		call	AddFigure
		pop	de
		ld	a,d
		add	(RB2FLIPPERX-LB2FLIPPERX)>>5
		ld	d,a
		ldh	a,[pin_rflipper]
		add	255&(IDX_FLIPPERS+18)
		ld	c,a
		ld	a,0
		adc	(IDX_FLIPPERS+18)>>8
		ld	b,a
		ld	a,$80+GROUP_FLIPPERS
		call	AddFigure
.nobottoms2:	ret


Nothing::	ret

statusflash::	ld	b,MAXMESSAGES
		ld	de,any_messagelist
		ld	c,-1
.comp:		ld	a,[de]
		or	a
		jr	z,.next3
		inc	e
		ld	a,[de]
		cp	l
		jr	nz,.next2
		inc	e
		ld	a,[de]
		cp	h
		jr	nz,.next1
		dec	e
		dec	e
		ld	a,l
		cp	MSGJACKVALUE
		ld	a,MESSAGETIME
		jr	z,.aok
		ld	a,MESSAGETIME*2
.aok:		ld	[de],a
		ret
.next3:		ld	c,e
		inc	e
.next2:		inc	e
.next1:		inc	e
		dec	b
		jr	nz,.comp
.nosearch:	ld	a,c
		inc	a
		ret	z	;already full
		ld	b,d
		ld	a,MESSAGETIME
		ld	[bc],a
		inc	c
		ld	a,l
		ld	[bc],a
		inc	c
		ld	a,h
		ld	[bc],a
		ret

AnyMessages::	ld	hl,any_messagelist
		ld	de,3
		ld	bc,MAXMESSAGES
.cnt:		ld	a,[hl]
		or	a
		jr	z,.noincb
		inc	b
.noincb:	add	hl,de
		dec	c
		jr	nz,.cnt
		ld	a,b
		or	a
		ret



SubAddBall::
		ld	a,60
		ld	[any_subshoot],a
		ret

subball:	dec	[hl]
		ret	nz
		ld	de,22<<5
		ld	bc,90<<5
;		ld	hl,$1010
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
		set	PINFLG_EXIT,a
		ldh	[pin_flags],a
		ret

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


;**************************
;Temporary

;BuildMessageList:
;		ldh	a,[hRomBank]
;		push	af
;		ld	a,BANK(MessageData)
;		ldh	[hRomBank],a
;		ld	[rMBC_ROM],a
;
;		ld	de,MessageData
;		xor	a
;		ld	hl,wMessageList
;		ld	[hli],a
;		ld	[hli],a
;.find:		ld	[hl],e
;		inc	hl
;		ld	[hl],d
;		inc	hl
;		ld	a,[de]
;		or	a
;		jr	z,.done
;.skip0:		ld	a,[de]
;		inc	de
;		or	a
;		jr	nz,.skip0
;		jr	.find
;
;.done:		pop	af
;		ldh	[hRomBank],a
;		ld	[rMBC_ROM],a
;		ret


;de=message #
FetchMessage::
		ld	a,e
		cp	MSGJACKVALUE
		jr	z,jackval
		ld	a,e
		ld	[wLastMsg],a
		ld	a,d
		ld	[wLastMsg+1],a
		call	GetString

		ld	de,wString
		ld	hl,wMessage
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


;		ldh	a,[hRomBank]
;		push	af
;		ld	a,BANK(MessageData)
;		ldh	[hRomBank],a
;		ld	[rMBC_ROM],a
;		ld	hl,wMessageList
;		add	hl,de
;		add	hl,de
;		ld	e,[hl]
;		inc	hl
;		ld	d,[hl]
;
;		ld	hl,wMessage
;		ld	a,80
;		ld	[hli],a
;		ld	a,5
;		ld	[hli],a
;		xor	a
;		ld	[hli],a
;		inc	a
;		ld	[hli],a
;.zcpy:		ld	a,[de]
;		inc	de
;		ld	[hli],a
;		or	a
;		jr	nz,.zcpy
;		ld	[hl],a
;		pop	af
;		ldh	[hRomBank],a
;		ld	[rMBC_ROM],a
;		ret

jackval:
		ld	hl,wMessage
		ld	a,80
		ld	[hli],a
		ld	a,5
		ld	[hli],a
		xor	a
		ld	[hli],a
		inc	a
		ld	[hli],a
		ld	b,"0"
		ld	c,","
		ld	de,wLastJack
		call	jack3
		ld	a,c
		ld	[hli],a
		call	jack3
		ld	a,c
		ld	[hli],a
		call	jack3
		ld	a,c
		ld	[hli],a
		call	jack3
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	hl,wMessage+4
		ld	e,14
.lead0:		ld	a,[hl]
		cp	b
		jr	z,.clear
		cp	c
		jr	nz,.done
.clear:		inc	hl
		dec	e
		jr	nz,.lead0
.done:		ld	de,wMessage+4
.c0:		ld	a,[hli]
		ld	[de],a
		inc	de
		or	a
		jr	nz,.c0
		ld	[de],a

		ret
jack3:		ld	a,[de]
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



;hl=0-511
addmillionshl::
		call	hltolastjack
		ld	de,wLastJack
		jp	addscoreh2

hltolastjack::
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	c,11
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
		ld	[hli],a		
		ld	[hli],a		
		ld	[hli],a		
		ld	[hl],a		
		ret

addscore::
;		xor	a
;		ld	[any_combo1],a
;		ld	[any_combo2],a
;		ld	[any_combo3],a
;		ld	[any_loopcount],a
addscoreh::	ld	a,[wHappyMode]
		or	a
		jr	z,.deok
		ld	de,score5m
.deok:
addscoreh2::
		ld	a,[any_pearlball]
		or	a
		jr	z,.normal
		push	de
		call	.normal
		pop	de
.normal:	ld	hl,wScore+11
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
;		ld	a,[pin_difficulty]
;		or	a
;		jr	z,saver30
;		ld	a,[any_ballsaver]
;		cp	5
;		jr	nc,.more5
;		ld	a,5
;		ld	[any_ballsaver],a
;.more5:		ret
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

;Sets Z flag if within time limit
timelimit::	push	hl
		ld	b,a
		ld	de,any_clock
		ld	a,[de]
		sub	[hl]
		ld	c,a
		inc	de
		inc	hl
		ld	a,[de]
		sbc	[hl]
		jr	nz,.overflow
		inc	de
		inc	hl
		ld	a,[de]
		sbc	[hl]
		jr	nz,.overflow
		inc	de
		inc	hl
		ld	a,[de]
		sbc	[hl]
		jr	nz,.overflow
		ld	a,c
		cp	b
		jr	nc,.overflow
		pop	hl
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
		ret
.overflow:	pop	hl
		xor	a
		inc	a
		ret


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

;de=list of frames
;a=bank #
;c=bank # for char set
AnyVideo::	ld	[any_tvtake],a
		ld	a,l
		ld	[any_tvtake+1],a
		ld	a,h
		ld	[any_tvtake+2],a
		ld	a,c
		ld	[wVideoBank],a
		ret

StepVideo::
		ld	hl,any_tvdelay
		inc	[hl]
		ld	a,[hl]
		cp	5
		ret	c
		ld	[hl],0

		ld	a,[any_tvtake+1]
		ld	l,a
		ld	a,[any_tvtake+2]
		ld	h,a
		ld	a,[hli]
		ld	c,a
		ld	a,l
		ld	[any_tvtake+1],a
		ld	a,h
		ld	[any_tvtake+2],a
		ld	a,c
		or	a
		jr	nz,.notend
		ld	[any_tvtake],a
		jr	.end
.notend:
		ld	a,[wPinCharBank]
		push	af
		ld	a,[wVideoBank]
		ld	[wPinCharBank],a
		ld	a,c
		dec	a
		call	TV
		pop	af
		ld	[wPinCharBank],a
.end:
		ret

IncBonusVal::	ld	hl,any_bonusval+4
		ld	b,10
		ld	a,3
.inc:		add	[hl]
		ld	[hl],a
		sub	b
		ret	c
		ld	[hld],a
		ld	a,1
		jr	.inc

ClearBonusVal::	ld	hl,any_bonusval
		xor	a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a
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
.div60:		inc	[hl]
		sub	60
		jr	nc,.div60
		add	60
		inc	hl
		ld	[hl],CHRCOLON
		inc	hl
		ld	[hl],CHR0-1
.div10:		inc	[hl]
		sub	10
		jr	nc,.div10
		inc	hl
		add	CHR0+10
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
		ld	a,CHRBLANK
		ld	[hl],a
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
		add	b
		ld	[hli],a

		ld	a,b
		ld	[hli],a
		ld	a,CHRCOMMA
		ld	[hli],a
		ld	a,b
		ld	[hli],a
		ld	[hli],a
		ld	[hl],a

		ld	hl,$c809
		ld	b,CHR0
		ld	c,CHRCOMMA
		ld	d,CHRBLANK
		ld	e,11
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

statusmsg::	ld	d,h
		ld	e,l
statusde::
		call	FetchMessage

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
		ld	hl,wMessage

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
spinnerscore::
dropscore::	db	0,0,0,0,0,0,0,1,0,0,0,0
popperscore::	db	0,0,0,0,0,0,0,0,3,3,3,3
popper99score::	db	0,0,0,0,0,1,0,0,0,0,0,0
bumperscore::	db	0,0,0,0,0,0,0,0,2,2,2,2
loopscore::	db	0,0,0,0,0,0,0,3,0,0,0,0
rampscore::	db	0,0,0,0,0,0,0,5,0,0,0,0

scorestandupunlit: db	0,0,0,0,0,0,0,0,5,0,0,0
scorerolloverunlit: db	0,0,0,0,0,0,0,2,0,0,0,0

score100k::	db	0,0,0,0,0,0,1,0,0,0,0,0
score200k::	db	0,0,0,0,0,0,2,0,0,0,0,0
score300k::	db	0,0,0,0,0,0,3,0,0,0,0,0
score400k::	db	0,0,0,0,0,0,4,0,0,0,0,0
score500k::	db	0,0,0,0,0,0,5,0,0,0,0,0
score600k::	db	0,0,0,0,0,0,6,0,0,0,0,0
score700k::	db	0,0,0,0,0,0,7,0,0,0,0,0
score800k::	db	0,0,0,0,0,0,8,0,0,0,0,0
score900k::	db	0,0,0,0,0,0,9,0,0,0,0,0
score1m::	db	0,0,0,0,0,1,0,0,0,0,0,0
score2m::	db	0,0,0,0,0,2,0,0,0,0,0,0
megapopperscore::
score3m::	db	0,0,0,0,0,3,0,0,0,0,0,0
score4m::	db	0,0,0,0,0,4,0,0,0,0,0,0
score5m::	db	0,0,0,0,0,5,0,0,0,0,0,0
score6m::	db	0,0,0,0,0,6,0,0,0,0,0,0
score7m::	db	0,0,0,0,0,7,0,0,0,0,0,0
score8m::	db	0,0,0,0,0,8,0,0,0,0,0,0
score9m::	db	0,0,0,0,0,9,0,0,0,0,0,0
score10m::	db	0,0,0,0,1,0,0,0,0,0,0,0
score25m::	db	0,0,0,0,2,5,0,0,0,0,0,0
score50m::	db	0,0,0,0,5,0,0,0,0,0,0,0
score100m::	db	0,0,0,1,0,0,0,0,0,0,0,0
score1000m::	db	0,0,1,0,0,0,0,0,0,0,0,0

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
		jr	.notyet
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
.first:		call	AnyMessages
		jr	nz,.notyet
		ld	a,30
		jr	.next
.second:	ld	hl,MSGBONUS
		call	statusmsg
		ld	a,60
		jr	.next
.third:		call	BonusScore
		ld	a,120
		jr	.next
.fourth:	call	PinScore
		ld	a,BONUSCOUNTTIME
		jr	.next
.fifth:		ld	a,[any_bonusmul]
		or	a
		jr	z,.last
		dec	a
		ld	[any_bonusmul],a
		ld	a,FX_BONUS
		call	InitSfx
		ld	hl,$c800
		ld	bc,12
		call	MemClear
		ld	hl,any_bonusval
		ld	de,$c800+3
		ld	bc,5
		call	MemCopy
		ld	de,$c800
		call	addscore
		call	PinScore
		ld	a,BONUSCOUNTTIME
		ld	[any_bonusinfo2],a
		jr	.notyet
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
		add	a
		ld	c,a
		ld	b,0
		xor	a
		ld	[any_credit1],a
		ld	[any_credit2],a
		ld	[any_credit3],a
		ld	hl,subvideos
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		ret	z
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	c,a
		push	de
		ld	a,1
		call	AnyVideo
		pop	hl
		call	OtherPage
		ldh	a,[pin_chainwant]
		jp	subsonga
subvideos::	dw	0
		dw	soulsvideo
		dw	scuttlevideo
		dw	shipvideo
		dw	floundervideo
		dw	flotsamvideo
		dw	kissvideo
		dw	ursulavideo
		dw	treasurevideo
		dw	0
		dw	icevideo
		dw	volcanovideo
		dw	tridentvideo
		dw	prisonvideo
		dw	dashvideo
		dw	morganavideo
		dw	bearvideo
		dw	cloakvideo

cloakvideo:	dw	IDX_CLOAKVIDMAP
		db	BANK(Char40)
		db	1,1,1,1,1,1,1
		db	2,2,2,2,2,2,2,2,2,2,2,2
		db	3,3,3,3,3,3,3,3,3,3,3,3
		db	4,4,4,4
		db	5,5,6,6,7,7,8,8,9,9,2,2,2,2
		db	10,10,11,12,13,14,15,16,17,18,19,20
		db	0
morganavideo:
		dw	IDX_MORGVIDMAP
		db	BANK(Char40)
		db	1,1,1,1,1,1,1
		db	2,2,3,4,5,6,7,8,8,9,9,10,10,11,11
		db	12,12,13,13,14,14,15,15,16,16,17,17
		db	18,18,18,18,18,18
		db	19,19,19,19,20,20,19,19,19,19,20,20,19,19,19,19
		db	0
tridentvideo:
		dw	IDX_TRIDENTVIDMAP
		db	BANK(Char40)
		db	1,1,1,1,1,1
		db	2,3,4,5,6,2,3,4,5,6,2,3,4,5,6,2,3,4,5,6
		db	7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16
		db	17,17
		db	0
prisonvideo:	dw	IDX_TRAPVIDMAP
		db	BANK(Char10)
		db	1,2,3,4,5,6,7
		db	8,9,10,11,12,13,14,14,14,14,14,14,14,14
		db	15,15,15,15,15,15
		db	16,17,18,19
		db	20,20,20,20,20,20,20,20,20,20,20,20,20
		db	0

bearvideo:	dw	IDX_BEARVIDMAP
		db	BANK(Char10)
		db	1,2,3,4,5,6,7
		db	8,8,9,9,10,10,11,11
		db	8,8,9,9,10,10,11,11
		db	8,8,9,9,10,10,11,11
		db	8,8,9,9,10,10,11,11

;		db	8,9,10,11,8,9,10,11
;		db	8,9,10,11,8,9,10,11
;		db	8,9,10,11
		db	12,12,13,13,14,14,15,15,16,16,17,17,18,18
		db	19,19,19,19,19,19
		db	20,20,20,20,20,20,20,20,20,20,20,20
		db	0

icevideo:	dw	IDX_TIPVIDEOMAP
		db	BANK(Char20)
		db	1,1,1,1,1,1,1,1,1,1,1,1
		db	2,2,3,3,2,2,3,3,2,2,3,3,2,2,3,3
		db	2,2,3,3,2,2,3,3
		db	4,4,4,4,4,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
		db	20,20,20,20,20,20,20,20,20,20,20,20
		db	0

dashvideo:	dw	IDX_DASHVIDEOMAP
		db	BANK(Char20)
		db	1,1,1,1,1,1,1,1,2,3,4,5,6,7,8,9,10
		db	11,1,1,1,1,12,12,12,12
		db	13,13,13,13,12,12,12,12
		db	13,13,13,13,14,15,16,17
		db	18,19,20,21,21,21,21,21
		db	22,22,22,22,22,22,22,22,22,22,22,22
		db	0

volcanovideo:	dw	IDX_VOLCVIDEOMAP
		db	BANK(Char20)
		db	1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
		db	1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
		db	10,10,10,10,10,10,10,10,10,10,10,10
		db	10,10,10,10,10,10,10,10,10,10,10,10
		db	5,5,5,5,5,5,5,5,5,5,5,5
		db	5,5,5,5,5,5,5,5,5,5,5,5
		db	6,7,8,9,6,7,8,9,6,7,8,9,6,7,8,9,6,7,8,9
		db	10,11,12,13,14,15,16,17,18,19,20
		db	10,10,10,10,10,10
		db	0

treasurevideo:	dw	IDX_TREASVIDEOMAP
		db	BANK(Char20)
		db	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
		db	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
		db	5,5,5,5,5,6,7,8,9,10,11,12,13,14,15
		db	16,5,5,5,5,0

shipvideo:	dw	IDX_STORMVIDEOMAP
		db	BANK(Char20)
		db	1,1,2,2,2,2,2,2,2,2,3,4,5,2,2,2,2,2,2,2,2
		db	3,4,5,6,6,6,6,6,6,6,6
		db	7,8,9,6,6,6,6,6,6,6,6
		db	10,11,12,13,14,15,16,17,18
		db	14,15,16,17,18,19,20,21
		db	13,22,22,22,22,22,22,22,22,0
kissvideo:
		dw	IDX_KISSVIDEOMAP
		db	BANK(Char20)
		db	1,1,1,1,1,1,1,1,2,3,3,3,3
		db	1,1,1,1,1,1,1,1,4,5,6,7,8,9
		db	10,11,12,13,13,13,13,13,13,13,13
		db	14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15
		db	0
soulsvideo:
		dw	IDX_SOULVIDEOMAP
		db	BANK(Char20)
		db	1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
		db	3,4,5,6,7,8,9,10,11,12
		db	9,10,11,12
		db	13,13,13,13,13,13,13,13
		db	14,15,16,17,18,19,20,21,22,23
		db	24,24,24,24,24,24,24,24
		db	0
scuttlevideo:
		dw	IDX_SCUTTLEVIDEOMAP
		db	BANK(Char20)
		db	1,2,3,4,5,6,6,6,6,6,6,6,6
		db	7,7,7,7,7,7,7,7,8,9,10,11,12
		db	13,14,15,16,17
		db	0
floundervideo:
		dw	IDX_FLOUNDVIDEOMAP
		db	BANK(Char20)
		db	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
		db	17,18,19,17,17,17,17,20,20,20,20,20
		db	20,20,20,20
		db	0

flotsamvideo:
		dw	IDX_EELVIDEOMAP
		db	BANK(Char20)
		db	1,1,1,1,1,1,1,1
		db	2,3,4,5,6,7,8,9
		db	10,11,12
		db	13,13,13,13,13,13,13,13
		db	14,14,14,14,14,14,14,14
		db	0
ursulavideo:
		dw	IDX_URSULAVIDEOMAP
		db	BANK(Char20)
		db	1,2,3,4,5,6,7,8,9
		db	10,10,10,10,10,10,10,10
		db	11,12,13,14,15,14,13,13,14,15
		db	0


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

RandomVel::
		call	random
		and	63
		ld	e,a
		ld	d,0
		ld	hl,TblSin
		add	hl,de
		ld	l,[hl]
		ld	h,0
		ld	a,l
		add	a
		ld	a,h
		sbc	h
		ld	h,a
		add	hl,hl
		ld	a,l
		ldh	[pin_vy],a
		ld	a,h
		ldh	[pin_vy+1],a

		ld	hl,TblCos
		add	hl,de
		ld	l,[hl]
		ld	h,0
		ld	a,l
		add	a
		ld	a,h
		sbc	h
		ld	h,a
		add	hl,hl
		ld	a,l
		ldh	[pin_vx],a
		ld	a,h
		ldh	[pin_vx+1],a
		ld	a,FX_BALLZAP
		jp	InitSfx

PlayerReport::
		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		ld	hl,MSGPLAYER1
		add	hl,bc
		jp	statusflash


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
		jp	MemCopy

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
		jr	nz,.hard
		ld	a,[wActivePlayer]
		ld	c,a
		ld	b,0
		ld	hl,bMenus+OPT_SPEEDS
		add	hl,bc
		ld	a,[hl]
.hard:		ldh	[pin_difficulty],a
		or	a
		ld	a,$55
		jr	z,.aok
		ld	a,$ee
.aok:		ld	[any_speed],a
		ret



Credit1::
		push	hl
		ld	hl,any_credit1
		inc	[hl]
		pop	hl
		ret
Credit2::
		push	hl
		ld	hl,any_credit2
		inc	[hl]
		pop	hl
		ret
Credit3::
		push	hl
		ld	hl,any_credit3
		inc	[hl]
		pop	hl
		ret

SetTime::
		ld	c,a
		ldh	a,[pin_difficulty]
		or	a
		ld	a,c
		jr	nz,.aok
		add	a
.aok:		ld	hl,any_time
		ld	[hl],-1
.minutes:	inc	[hl]
		sub	60
		jr	nc,.minutes
		add	60
		inc	hl
		ld	[hl],-1
.tens:		inc	[hl]
		sub	10
		jr	nc,.tens
		add	10
		inc	hl
		ld	[hl],a
		ret


songmap:	db	SONG_TABLE1
		db	SONG_CAVE
		db	SONG_SCUTTLE
		db	SONG_SHIP
		db	SONG_FLOUNDER
		db	SONG_FLOTSAM
		db	SONG_KISS
		db	SONG_URSULA
		db	SONG_TREASURE
		db	SONG_TABLE2
		db	SONG_ICECAVE
		db	SONG_VOLCANO
		db	SONG_TRIDENT
		db	SONG_PRISON
		db	SONG_DASH
		db	SONG_MORGANA
		db	SONG_BEAR
		db	SONG_CLOAK

SubSong::	ld	a,[pin_board]
subsonga:	ld	c,a
		ld	b,0
		ld	hl,songmap
		add	hl,bc
		ld	a,c
		cp	SUBGAME_TABLE1
		jr	z,.to1
		cp	SUBGAME_TABLE2
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

unlocksub::
		ld	c,a
		ld	b,0
		ld	hl,bLocks
		add	hl,bc
		ld	[hl],1
		ret

dorelit::	ld	de,score5m
		call	addscore
		ld	hl,MSG5M
		jp	statusflash


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
;		ret
; __DA__ 20200510 I think the Japanese version didn't have a rumble unit
;                 so the following was commented out...
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
menutune::	xor	a
		ld	[wMzShift],a
		ld	a,[bMenus+OPT_OPTIONS]
		or	a
		ld	a,SONG_MENUS
		jr	z,.aok
		xor	a
.aok:		jp	InitTune
TVSet::		ld	[any_tv],a
		ld	hl,pin_flags2
		set	PINFLG2_TV,[hl]
		ret

GROUP_PRINTER	EQU	7
PXY		EQU	$5048

PrinterProcess::
		ld	a,[wPrinterPossible]
		or	a
		ret	z
	IF	!PRINTER
		ret
	ENDC
		ldh	a,[hVblCount]
		and	7
		jr	nz,.same
		ld	a,[wPrinterState]
		add	8
		jr	nc,.diff
		xor	a
.diff:		ld	[wPrinterState],a
.same:
		ld	a,[wPrinterState]
		and	7
		add	a
		ld	c,a
		ld	b,0
		ld	hl,.pstates
		add	hl,bc
		ld	a,[wPrinterState]
		ld	c,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[wJoy1Hit]
		ld	de,PXY
		jp	[hl]
.pstates:	dw	.p0
		dw	.p1
		dw	.p2
		dw	.p3
		dw	.p4
.p0:		bit	JOY_SELECT,a
		jr	nz,.to2
		ld	bc,IDX_PRNTICON+0	;tiny
		ld	a,[wWave]
		ld	e,a
		ld	d,$99
		ld	a,GROUP_PRINTER
		jp	AddFigure
.p1:		bit	4,c
		jr	z,.p2
		ld	bc,IDX_PRNTICON+2	;battery
		jr	.lang
.to2:		ld	a,2
		ld	[wPrinterState],a
.p2:		ld	bc,IDX_PRNTICON+1	;fine
		jr	.nolang
.p3:		bit	4,c
		jr	z,.p2
		ld	bc,IDX_PRNTICON+4	;jam
		jr	.lang
.p4:		bit	4,c
		jr	z,.p2
		ld	bc,IDX_PRNTICON+3	;no cable
.lang:		ld	a,[bLanguage]
		ld	l,a
		add	a
		add	l
		add	c
		ld	c,a
		jr	nc,.noincb
		inc	b
.noincb:
.nolang:	ld	a,GROUP_PRINTER
		jp	AddFigure
.done:		ret



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
		ld	a,1
		ld	[wNumBalls],a
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


;********************************************************************
;********************************************************************
