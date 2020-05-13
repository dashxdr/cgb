; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** ir.asm                                                                **
; **                                                                       **
; ** Created : 20000814 by David Ashley                                    **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		include "equates.equ"
		include "pin.equ"
		section	31


ir_mode		EQUS	"wTemp1024+00"
ir_stat		EQUS	"wTemp1024+01"
ir_sum		EQUS	"wTemp1024+02" ;2
ir_work		EQUS	"wTemp1024+04" ;2
ir_tmp		EQUS	"wTemp1024+06"
ir_bytes	EQUS	"wTemp1024+07"
ir_highs	EQUS	"wTemp1024+08" ;3*5*20

IR::
		ld	hl,wTemp1024
		ld	bc,1024
		call	MemClear

transfer:	call	irInit

		ld	hl,0
		ld	d,6
.www:		ldio	a,[rRP]
		bit	1,a
		jr	z,receive
		inc	l
		jr	nz,.www
		inc	h
		jr	nz,.www
		dec	d
		jr	nz,.www
transmit:
		di
		call	irTransmitConnect
		ld	a,[ir_stat]
		cp	IR_NORMAL
		jp	nz,irerror

		call	sendhighs
		jp	nz,irerror
		call	receivehighs
		jp	nz,irerror
		jr	mergehighs


receive:
		di
		call	irReceiveConnect
		ld	a,[ir_stat]
		cp	IR_NORMAL
		jp	nz,irerror

		call	receivehighs
		jp	nz,irerror
		call	sendhighs
		jp	nz,irerror
mergehighs:
		ei

		ld	de,ir_highs
		ld	hl,bHighScores
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		ld	hl,bHighScores+NUMHIGHS*HIGHSIZE
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		ld	hl,bHighScores+NUMHIGHS*HIGHSIZE*2
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		call	merge1
		xor	a
		ret
merge1:		push	hl
		push	de
		call	mergehigh
		pop	hl
		ld	de,HIGHSIZE
		add	hl,de
		ld	d,h
		ld	e,l
		pop	hl
		ret

sendhighs:	ld	hl,bHighScores
		ld	c,3*5
		ld	b,20
.shlp:		push	bc
		push	hl
		call	irSendPacket
		pop	hl
		pop	bc
		ld	a,[ir_stat]
		cp	IR_NORMAL
		ret	nz
		ld	de,20
		add	hl,de
		dec	c
		jr	nz,.shlp
		ret
receivehighs:	ld	hl,ir_highs
		ld	c,3*5
.rhlp:		push	bc
		push	hl
		call	irRecvPacket
		pop	hl
		pop	bc
		ld	a,[ir_stat]
		cp	IR_NORMAL
		ret	nz
		ld	de,20
		add	hl,de
		dec	c
		jr	nz,.rhlp
		ret

irerror:	ei
		ld	a,1
		ret

;de=high score line to merge
;hl=high score list
mergehigh:	push	hl
		ld	b,NUMHIGHS
.anysame:	call	hscomp
		jr	z,.out
		ld	a,l
		add	20
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		dec	b
		jr	nz,.anysame
		inc	b
.out:		pop	hl
		ret	z

		push	hl
		ld	c,NUMHIGHS
.complp:	push	de
		push	hl
		ld	b,12
.ci:		ld	a,[de]
		cp	[hl]
		jr	c,.next
		jr	nz,.bigger
		inc	de
		inc	hl
		dec	b
		jr	nz,.ci
.next:		pop	hl
		ld	de,HIGHSIZE
		add	hl,de
		pop	de
		dec	c
		jr	nz,.complp
		pop	hl
		ret
.bigger:	pop	bc
		ld	hl,HIGHSIZE-1
		add	hl,bc
		ld	b,h
		ld	c,l
		pop	de
		pop	hl
		push	de
;hl=high score list
;bc=high score to replace
;tos=high score value to put
		ld	de,(NUMHIGHS-1)*HIGHSIZE-1
		add	hl,de
		push	hl
		ld	de,HIGHSIZE
		add	hl,de
		pop	de
.movelp:	ld	a,c
		cp	l
		jr	nz,.doit
		ld	a,b
		cp	h
		jr	z,.done
.doit:		push	bc
		ld	c,HIGHSIZE
.m2:		ld	a,[de]
		dec	de
		ld	[hld],a
		dec	c
		jr	nz,.m2
		pop	bc
		jr	.movelp
.done:		ld	hl,-(HIGHSIZE-1)
		add	hl,bc
		ld	d,h
		ld	e,l
		pop	hl
		ld	bc,15
		jp	MemCopy

hscomp:		push	de
		push	hl
		ld	c,15
.complp:	ld	a,[de]
		cp	[hl]
		jr	nz,.out
		inc	de
		inc	hl
		dec	c
		jr	nz,.complp
.out:		pop	hl
		pop	de
		ret


;*********************************************************************
;*								     *
;*		     Infrared Communications Library		     *
;*								     *
;*********************************************************************
;*	Function		Summary			    	     *
;*-------------------------------------------------------------------*
;*	irInit			Communications standards	     *
;*								     *
;*	irCountHi		Count during HI cycle		     *
;*	irCountLo		Count during LO cycle		     *
;*								     *
;*	irHi			Light				     *
;*	irLo			Turn off light			     *
;*								     *
;*	irConnect		Confirm connection & determine	     * 
;*				send/recv relationship		     *
;*	irDisconnect		Disconnect                           *
;*								     *
;*	irSendPacket		Send packet & receive status	     *
;*	irSend			Send byte units			     *
;*								     *
;*	irRecvPacket		Receive packet & send status	     *
;*	irRecv			Receive byte units		     *
;*								     *
;*	dmy			10cycle Wait			     *
;*	dmy5			15cycle Wait			     *
;*							    	     *
;*********************************************************************
;========= Infrared Communications Mode ==========
IR_RECEIVE	EQU	%00000001
IR_TRANSMIT	EQU	%00000010
;========= Infrared Communications Status ==========
IR_NORMAL	EQU	%00000000
IR_ERR_SUM	EQU	%00000001
IR_ERR_PULSE	EQU	%00000010
IR_ERR_OTHER	EQU	%00000100
IR_DISCONNECT   EQU	%11111111
;=========================================
;=====================================================================
;	Set Various Signal Pulse Lengths for Communications Protcol
;---------------------------------------------------------------------
;	Constant	Setting	Function Used	Details
;---------------------------------------------------------------------
IRP_CONNECTION	    EQU	$1A	; irConnect	Confirm connection, HI/LO cycle
IRP_PACKET	    EQU	$16	; irSend	Start - stop signal, HI/LO cycle
;- - - - - - - - - - - - - - - -
IRP_RAW		    EQU	$5A	; irSendPacket	Raw data identification code
;- - - - - - - - - - - - - - - -
IRP_C1_HI	    EQU	14	; irSend	1 signal, HI cycle
IRP_C1_LO	    EQU	18	; irSend	1 signal, LO cycle
IRP_C0_HI	    EQU	 8	; irSend	0 signal, HI cycle
IRP_C0_LO	    EQU	12	; irSend	0 signal, LO cycle
IRP_CDIV	    EQU	12	; irRecv	0/1 discrimination count number
;=====================================================================


;===========================================================
;	irInit	Infrared Communications   Receive Preparation
;-----------------------------------------------------------
;	enter		(KEY1)
;	work		A, B, (RP)
;===========================================================
irInit:
	ld	a,%11000000
	ldio	[rRP],a		; Infrared Communications Receive possible
	ld	a,IR_DISCONNECT
	ld	[ir_stat],a
	ret

;===========================================================
;	irCountHi		HI cycle counter
;	irCountLo		LO cycle counter
;-----------------------------------------------------------
;	enter		c	RP instruction ($56)
;			d	Set to 0
;	work		a
;	return		d	Count number
;				Return timeout to 0
;===========================================================
;	irHi			Light   d countdown loop
;	irLo			Turn off light	d countdown loop
;-----------------------------------------------------------
;	enter		c	RP instruction ($56)
;			d	Count number
;	work		a
;	return		-
;===========================================================
irCountHi:
.Hray01
	inc	d			; Count lit cycles
	ret	z			; Time over
	ld	a,[c]
	bit	1,a
	jr	z,.Hray01
	ret
irCountLo:
.Lray01
	inc	d			; Count "light off" cycles
	ret	z			; Time over
	ld	a,[c]
	bit	1,a
	jr	nz,.Lray01
	ret
;-----------------------------
irHi:
	ld	a,%11000001
	ld	[c],a			; Light LED
.Hret01:
	dec	d
	jr	nz,.Hret01
	ret
irLo:
	ld	a,%11000000
	ld	[c],a			; Turn off LED
.Hret01:
	dec	d
	jr	nz,.Hret01
	ret


irReceiveConnect:
	ld	b,IRP_CONNECTION	; Pulse HI/LO cycle
	ld	c,$56
	ld	d,0
	ld	e,d

	call	irCountLo		; Count LO cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	ld	d,e
	call	irCountHi		; Count HI cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	call	irCountLo		; Count LO cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	call	irCountHi		; Count HI cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	cp	$08
	jp	c,irErrPulse		; NG if count value is less than 08
	cp	$2A
	jp	nc,irErrPulse		; NG if count value is greater than 2A

	ld	a,IR_NORMAL		; Communication status OK
	ld	[ir_stat],a

	ld	d,b
	call	irLo			; Light off for set cycle
	ld	d,b
	call	irHi			; Light for set cycle
	ld	d,b
	call	irLo			; Light off for set cycle
	ld	d,b
	call	irHi			; Light for set cycle
	ld	d,b
	call	irLo			; Light off for set cycle

	ret
;---------------------------------------
irTransmitConnect:
	ld	a,IR_TRANSMIT
	ld	[ir_mode],a
	ld	b,IRP_CONNECTION
	ld	c,$56
	ld	d,b
	ld	e,0

	call	irLo			; Light off for set cycle
	ld	d,b
	call	irHi			; Light for set cycle
	ld	d,b
	call	irLo			; Light off for set cycle
	ld	d,b
	call	irHi			; Light for set cycle
	ld	d,b
	call	irLo			; Light off for set cycle

	ld	d,e
	call	irCountLo		; Count LO cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	ld	d,e
	call	irCountHi		; Count HI cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	ld	d,e
	call	irCountLo		; Count LO cycles
	ld	a,d
	and	a
	jp	z,irErrPulse
	ld	d,e
	call	irCountHi		; Count HI cycles
	ld	a,d
	and	a
	jp	z,irErrPulse

	ld	d,IRP_CONNECTION	; Time sync with receive side
	call	irLo			; Turn off light for set cycle

	ld	a,IR_NORMAL
	ld	[ir_stat],a
	ret


;==========================================================================
;	irDisconnect		Disconnect Communications & Disable Communications
;--------------------------------------------------------------------------
; Shift both CGB units which were in communication enabled status to disconnect 
; status & communication disabled status
;--------------------------------------------------------------------------
;	entry		-
;	work		A
;	return		[ir_stat]
;	child call	-
;==========================================================================
irDisconnect:
	xor	a
	ldio	[rRP],a
	ld	a,IR_DISCONNECT
	ld	[ir_stat],a
	ret


;==========================================================================
;	irSendPacket	Communicate as send side (Send and sum receive)
;--------------------------------------------------------------------------
;	Send	:  Header (Send code $00 + Send byte count 1byte)
;			+ Data (Maximum 256 bytes) + Check sum (2 bytes)
;	Receive:  Receive side sum
;--------------------------------------------------------------------------
;	entry		HL			Send start address
;			B			Send byte count
;	work		A,B,C,D,E,HL
;	return		[ir_sum],[ir_sum+1]		Send side sum
;			[ir_stat]		Communication result status
;	child call	irSend, irRecv
;==========================================================================
irSendPacket:
	xor	a
	ld	[ir_sum],a
	ld	[ir_sum+1],a

	push	hl
	push	bc
	ld	hl,ir_work		; Create header
	ld	a,IRP_RAW		; Indicate raw data
	ld	[hli],a			; Header data code
	ld	[hl],b			; Data send byte count
	dec	hl
	ld	b,2

	ld	d,30
	call	irLo			; LO

	call	irSend			; Send header
	pop	bc		; 3
	pop	hl		; 3
	call	dmy			; Adjust timing

	call	irSend			; Send data

	ld	a,[ir_sum]		; 4	; Clear checksum
	ld	[ir_work],a	; 4
	ld	a,[ir_sum+1]	; 4
	ld	[ir_work+1],a	; 4

	ld	hl,ir_work	; 3
	ld	b,2		; 2
	call	irSend			; Send checksum

	ld	hl,ir_stat
	ld	b,1
	call	irRecv			; Receive status

	ld	a,[ir_work]		; Return checksum
	ld	[ir_sum],a		; 4
	ld	a,[ir_work+1]	; 1
	ld	[ir_sum+1],a	; 4

	ret
;===========================================================
;	irSend		Send module used by irSendPacket
;	Send signal of specified number of bytes sandwiched 
;	by packet pulses
;===========================================================
irSend:					; Send byte units (From HL to B byte)
	ld	c,$56

	ld	d,IRP_PACKET		; Send start sign
	call	irHi
	ld	d,IRP_PACKET
	call	irLo

	ld	a,b
	cpl				; Invert to count number of bytes sent
	ld	b,a
.next_byte:
	inc	b
	jr	z,.s_finished

	ld	a,8		; 2
	ld	[ir_tmp],a		; 4
	ld	a,[hli]		; 2
	ld	e,a		; 1

	ld	a,[ir_sum]	; 4
	add	e		; 1
	ld	[ir_sum],a	; 4
	jr	nc,.summed
	ld	a,[ir_sum+1]	; 4
	inc	a		; 1
	ld	[ir_sum+1],a	; 4
	jr	.wsummed
.summed:
	call	dmy
.wsummed:
.next_bit:
	ld	a,e
	rlca
	ld	e,a
	jr	nc,.send_0
.send_1:
	ld	d,IRP_C1_HI		; 1 HI cycle
	nop
	nop
	nop
	call	irHi
	ld	d,IRP_C1_LO		; 1 LO cycle
	nop
	nop
	nop
	call	irLo
	jr	.sended
.send_0:
	ld	d,IRP_C0_HI		; 0 HI cycles
	nop
	nop
	nop
	call	irHi
	ld	d,IRP_C0_LO		; 0 LO cycles
	nop
	nop
	nop
	call	irLo
.sended:
	ld	a,[ir_tmp]		; 4
	dec	a		; 1
	ld	[ir_tmp],a		; 4
	jr	z,.byte_end
	call	dmy5
	call	dmy5
	jr	.next_bit
.byte_end:
	jr	.next_byte
.s_finished:
	call	dmy
	call	dmy
	call	dmy5
	ld	d,IRP_PACKET		; END pulse
	call	irHi
	ld	d,IRP_PACKET
	call	irLo

	ret

;==========================================================================
;	irErrPulse		Error processing on improper pulse width 
;	irErrSum		Error processing on checksum mismatch
;	irErrOther		Error processing when communication is 
;				impossible for other reasons
;--------------------------------------------------------------------------
;	work	a
;	return	[ir_stat]	Infrared communications status
;==========================================================================
irErrPulse:
	ld	a,IR_ERR_PULSE
	ld	[ir_stat],a
	ret
irErrSum:				; Sum check error
	ld	a,[ir_stat]
	or	IR_ERR_SUM
	ld	[ir_stat],a
	ret
irErrOther:
	ld	a,[ir_stat]
	or	IR_ERR_OTHER
	ld	[ir_stat],a
	ret
;=======================================

;==========================================================================
;	irRecvPacket	Communicate as receive side (Receive + send sum)
;--------------------------------------------------------------------------
;	entry		HL			Receive data storage start address
;	work		A,B,C,D,E,HL
;	return		(BYTES)			Received byte count
;			[ir_sum],[ir_sum+1]		Receive side sum
;			[ir_work],[ir_work+1]	Send side sum
;			[ir_stat]		Communication result status
;	child call	irRecv, irSend
;==========================================================================
irRecvPacket:
	xor	a
	ld	[ir_sum],a
	ld	[ir_sum+1],a

	push	hl
	ld	hl,ir_work
	ld	b,2
	call	irRecv			; Receive header
	ld	a,[ir_work+1]	; 4
	ld	[ir_bytes],a	; 4
	ld	b,a		; 2
	pop	hl		; 3
	ld	a,[ir_work]
	cp	IRP_RAW			; Compare raw data identification code
	jp	nz,irErrOther

	call	irRecv			; Receive data

	ld	a,[ir_sum]		; 4
	ld	d,a		; 1
	ld	a,[ir_sum+1]	; 4
	ld	e,a		; 1
	push	de		; 4	; Clear comparison sum
	ld	hl,ir_work
	ld	b,2
	call	irRecv			; Receive checksum
	pop	de		; 3

	ld	hl,ir_work	; 3
	ld	a,[hli]		; 2	; Compare sums
	xor	d		; 1
	ld	b,a		; 1
	ld	a,[hl]		; 2
	xor	e		; 1
	or	b		; 1
	jr	z,.irNormal	; 3/2

.irErrSum:				; Checksum error
	ld	a,[ir_stat]	; 4
	or	IR_ERR_SUM	; 1
	ld	[ir_stat],a	; 4
.irNormal:				; Sum check pass
	push	de		; 4 <22>

	ld	hl,ir_stat
	ld	b,1
	call	irSend			; Send status
	pop	de

	ld	a,d
	ld	[ir_sum],a
	ld	a,e
	ld	[ir_sum+1],a

	ret
;===========================================================
;	irRecv		Receive module used by irRecvPacket
;	Receive signal of specified number of bytes sandwiched 
;	by packet pulses
;===========================================================
irRecv:
	ld	c,$56

	ld	d,0
	call	irCountLo
	ld	a,d
	or	a
	jp	z,irErrPulse

	ld	d,0
	call	irCountHi
	ld	a,d
	or	a
	jp	z,irErrPulse

	ld	d,0
	call	irCountLo
	ld	a,d
	or	a
	jp	z,irErrPulse

	call	dmy5
	call	dmy5
	push	af
	pop	af

	ld	a,b
	cpl
	ld	b,a
.next_byte:
	inc	b
	jr	z,.r_finished

	ld	a,8		; 2
	ld	[ir_tmp],a		; 4
.next_bit:
	ld	d,0
	call	irCountHi
	call	irCountLo

	ld	a,IRP_CDIV
	nop
	nop
	cp	d			; Lo/Hi count threshold value
	jr	nc,.recv_0

.recv_1:
	ld	a,e
	set	0,a
	ld	e,a
	jr	.received
.recv_0:
	ld	a,e
	res	0,a
	ld	e,a
.received:
	ld	a,[ir_tmp]
	dec	a
	ld	[ir_tmp],a

	jr	z,.byte_end
	ld	a,e		; 1
	rlca			; 1
	ld	e,a		; 1
	call	dmy5
	call	dmy5
	jr	.next_bit	; 3
.byte_end:
	ld	a,e		; 1
	ld	[hli],a		; 2

	ld	a,[ir_sum]		; 4
	add	e		; 1
	ld	[ir_sum],a		; 4
	jr	nc,.summed
	ld	a,[ir_sum+1]	; 4
	inc	a		; 1
	ld	[ir_sum+1],a	; 4
	jr	.wsummed
.summed:
	call	dmy
.wsummed:
	jr	.next_byte
.r_finished:
	ld	d,0			; END pulse
	call	irCountHi
	ld	a,d
	and	a
	jp	z,irErrPulse
	ld	d,IRP_PACKET-5
	call	irLo			; Adjust timing
	ret

;================================================================
;	irSendEOF	Send end communication signal to receiving unit
;	irRecvEOF	Receive end communication signal, return status
;================================================================
irSendEOF:
	ld	b,$00
	jp	irSendPacket
irRecvEOF:
	ld	b,$00
	jp	irRecvPacket


dmy:	ret
dmy5:	jr	z,.a
.a	jr	nz,.b
.b	ret


