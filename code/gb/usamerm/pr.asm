;==============================================================================
;   Copyright (C) 1998   NINTENDO
;==============================================================================
;	Main Menu Sequence Macro

		include "equates.equ"


		section 00


pbase		EQU	$de80
HeaderWork	EQUS	"pbase+00" ;14
sseq		EQUS	"pbase+14" ; 1
sseqbak		EQUS	"pbase+15" ; 1
PhaseNo		EQUS	"pbase+16" ; 1
TransCount	EQUS	"pbase+17" ; 2
TransCount1	EQUS	"pbase+19" ; 2
TransCount2	EQUS	"pbase+21" ; 2
PrinterStatus	EQUS	"pbase+23" ; 2
BufPointer_base EQUS	"pbase+25" ; 2
BufPointer_base1 EQUS	"pbase+27" ; 2
BufPointer_base2 EQUS	"pbase+29" ; 2
BufPointer	EQUS	"pbase+31" ; 2
DummySendF	EQUS	"pbase+33" ; 1
SioCheckSum_S	EQUS	"pbase+34" ; 2
CompressF	EQUS	"pbase+36" ; 1
CompressFReal	EQUS	"pbase+37" ; 1
BusyFlag	EQUS	"pbase+38" ; 1
NumofFeed	EQUS	"pbase+39" ; 1
NumofSheet	EQUS	"pbase+40" ; 1
DelayNMI6	EQUS	"pbase+41" ; 1
LastPhaseNo	EQUS	"pbase+42" ; 1
PrnTimer	EQUS	"pbase+43" ; 1
LastBlock	EQUS	"pbase+44" ; 1
ValueofPalette	EQUS	"pbase+45" ; 1
EndofTrans	EQUS	"pbase+46" ; 1
Concentration	EQUS	"pbase+47" ; 1
PrinterStatusLast EQUS	"pbase+48" ; 1
DuringTransPKT	EQUS	"pbase+49" ; 1
SioWatchDogF	EQUS	"pbase+50" ; 1
RequestPhaseNo	EQUS	"pbase+51" ; 1
SioIntOccur	EQUS	"pbase+52" ; 1
Data1SendEndF	EQUS	"pbase+53" ; 1
PreambleSendF	EQUS	"pbase+54" ; 1
PrnDataAddress	EQUS	"pbase+55" ; 2
CompressNum	EQUS	"pbase+57" ;18
HeaderSendF	EQUS	"pbase+75" ; 1
ForceEnd	EQUS	"pbase+76" ; 1
CheckSumSendF	EQUS	"pbase+77" ; 1
CompressFtbl	EQUS	"pbase+78" ; 9
FollowingData	EQUS	"pbase+87" ; 1
PrinterErrorNo	EQUS	"pbase+88" ; 1
SBbak		EQUS	"pbase+89" ; 1
Type		EQUS	"pbase+90" ; 1
LineCount	EQUS	"pbase+91" ; 1
RealError	EQUS	"pbase+92" ; 1

pbase2		EQU	$df00
cmap		EQUS	"pbase2+00" ;4
cmaps		EQUS	"pbase2+04" ;32
pmap		EQUS	"pbase2+36" ;64

SEQ_WK		ESET	$00
seq		macro
		dw	\1
MAIN_\1		equ	SEQ_WK
SEQ_WK		ESET	SEQ_WK+1
		endm


;==============================================================================
;   Copyright (C) 1998   NINTENDO
;==============================================================================
;
;==============================================================================
WAIT270	MACRO
	IF	0
	ld	a,57
.loop:
	NOP		;1
	NOP		;1
	NOP		;1
	NOP		;1
	NOP		;1
	NOP		;1
	DEC	A	;1
	JR	NZ,.loop ;3
	ENDC
	ENDM

;	System Macros
;---
idjp	macro
	ld	a,[\1]
	rst	3
	endm
	
;---
ramset	macro ;	VAL,ADR,NUM
	ld	hl,\2
	ld	bc,\3
	ld	a,\1
	call	rams
	endm

;---
ramclr	macro ;	ADR,NUM
	ld	hl,\1
	ld	bc,\2
	call	ramc
	endm

;---
copy	macro	;SADR,DADR,NUM
	ld	hl,\1
	ld	de,\2
	ld	bc,\3
	call	move
	endm

;---
vblnkwt	macro
	rst	1
	endm

;---
vwait	macro ;	NUM
	ld	bc,\1
	call	vwait_
	endm
;---
swait	macro	;NUM
	ld	bc,\1
	call	swait_
	endm

;---
vrtrset	macro	;LABEL
	ld	a,BANK(\1)
	ld	bc,\1
	call	vrtrbuf_set
	endm

;---
ldm	macro	;op1,op2
	ld	a,\2
	ld	\1,a
	endm

;---
ld_hl_bc	macro
	ld	h,b
	ld	l,c
	endm

;--

ld_hl_de	macro
	ld	h,d
	ld	l,e
	endm
	
;---
nextseq	macro	;op
	ld	hl,\1
	inc	[hl]
	endm

;---
prevseq	macro	; op
	ld	hl,\1
	dec	[hl]
	endm

;---
restseq	macro	; op1
	xor	a
	ld	[\1],a
	endm

;==============================================================================
;	Main Menu Sequence

Main_seq
	idjp	sseq

	seq	Test_init		;0
	seq	Test_main		;1
	seq	Test_connect		;2
	seq	Test_datatrans		;3
	seq	Test_inst		;4
	seq	Test_wait		;5
	seq	Wait100ms		;6

;
;==============================================================================
retryFromStart

	ld	a,0
	ld	[PhaseNo],a

	ld	a,MAIN_Test_init
	ld	[sseqbak],a

	ld	a,MAIN_Wait100ms
	ld	[sseq],a

	ret


equal:		db	23,23,24,24
brighten:	db	23,0,24,47

fillsome:	ld	a,[de]
		inc	de
		or	a
		jr	z,.done
		ld	c,a
		ld	a,b
.lp:		ld	[hli],a
		dec	c
		jr	nz,.lp
.done:		inc	b
		ret


PrintSomething::
		push	af
		call	CgbSingleSpeed
		call	WaitForVBL
		call	WaitForVBL
		call	WaitForVBL
		pop	af
		push	af
		ld	e,a
		ld	d,0
		ld	a,WRKBANK_BM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	a,e
		add	a
		jr	c,.nospecial
		ld	hl,IDX_HIGHSBWRGB
		add	hl,de
		ld	de,pmap
		call	SwdInFileSys
		ld	de,brighten
		jr	.special
.nospecial:
		ld	hl,wBcpArcade
		ld	de,pmap
		ld	bc,64
		call	MemCopy
		ld	de,equal
.special:
		ld	hl,$c800
		ld	b,0
		call	fillsome
		call	fillsome
		call	fillsome
		call	fillsome

		xor	a
		ldh	[hTmp2Hi],a
		ld	hl,HeaderWork
		ld	bc,128
		call	MemClear

		pop	af
		ld	[Type],a

		call	SioInitialize
		di
		SETVBL	SioWatchDog
		ei

.doit:
		call	Main_seq
		call	WaitForVBL

		ldh	a,[hTmp2Hi]
		or	a
		jr	z,.doit

		di
		SETVBL	DoNothing
		ei

;		ld	a,[PrinterErrorNo]
 ld a,[RealError]
		ld	b,4
		cp	2		;no cable
		jr	z,.bok
		ld	b,1
		cp	1		;low battery
		jr	z,.bok
		ld	b,3
		cp	3		;paper jam
		jr	z,.bok
		ld	b,0
		or	a
		jr	z,.bok
		ld	b,4		;no cable
.bok:

		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	a,b
		ld	[wPrinterState],a

		push	af
		call	CgbDoubleSpeed
		call	WaitForVBL
		call	WaitForVBL
		call	WaitForVBL
		pop	af

		ret





;
;==============================================================================
Test_init
	call	makedata
	ld	hl,IDX_DCOPYPKG
	ld	de,$c800+17*20*16
	call	SwdInFileSys

	ld	a,$13
	ld	[NumofFeed],a
	ld	a,1
	ld	[NumofSheet],a
;	ld	a,%11100100
	ld	a,%00011011
	ld	[ValueofPalette],a
	ld	a,$80
	ld	[Concentration],a

	nextseq	sseq

Test_main

	nextseq	sseq
	ret

;
;==============================================================================
Test_connect
	call	ConnectPRN
	cp	$F0
	jr	z,.ret			;wait connect
	cp	$FF			;retry connect
	jr	z,.reterr


	ld	a,[sseq]
	inc	a
	ld	[sseqbak],a

	xor	a
	ld	[DelayNMI6],a
	ld	a,MAIN_Wait100ms
	ld	[sseq],a
.ret	
	ret

.reterr
	ld	a,1
	ldh	[hTmp2Hi],a
	restseq	sseq
	ret

;
;==============================================================================
Test_datatrans
	ld	a,[PrinterStatus]
	cp	$FF
	jp	z,retryFromStart

	ld	a,[DuringTransPKT]
	and	a
	jr	z,.print

	ld	a,[PhaseNo]
	cp	3
	jr	z,.print
	cp	1
	jr	z,.print
	jp	retryFromStart

.print

	ld	a,1
	ld	[LastBlock],a
	ld	hl,PrintWork
	ld	a,9
	call	DataTransPRN
	cp	$ff
	jp	z,retryFromStart
	cp	$f0
	ret	z

	nextseq	sseq
	ret

;
;==============================================================================
Test_inst
	ld	a,[PrinterStatus]
	cp	$FF
	jp	z,retryFromStart

	ld	a,[DuringTransPKT]
	and	a
	jr	z,.inst

	ld	a,[PhaseNo]
	cp	2
	jr	z,.inst
	cp	1
	jr	z,.inst
	jr	.ret

.inst
	ld	a,[PrinterStatus]
	bit	1,a
	jr	nz,.ret

	call	InstructPRN
	cp	$ff
	jp	z,retryFromStart
	cp	$f0
	ret	z
.end
	ld	a,3
	ld	[PrnTimer],a

	xor	a
	ld	[DelayNMI6],a
	ld	a,MAIN_Wait100ms
	ld	[sseq],a
	ld	a,MAIN_Test_wait
	ld	[sseqbak],a

.ret
	ret

;
;==============================================================================
Test_wait
	ld	a,[PrinterStatus]
	cp	$FF
	jp	z,retryFromStart
	bit	3,a
	jp	nz,.skip
	bit	1,a
	jp	nz,.skip


 ld a,1
 ldh	[hTmp2Hi],a

	restseq	sseq

	xor	a
	ld	[PhaseNo],a
.skip
	ret	

;
;==============================================================================
Wait100ms
	ld	hl,DelayNMI6
	inc	[hl]
	ld	a,[hl]
	cp	6
	jr	c,.ret
	xor	a
	ld	[hl],a
.jump
	ld	a,[sseqbak]
	ld	[sseq],a
.ret
	ret

;
;
;==============================================================================
;

sync:
;__DA__ 20200511 The USA version doesn't have the following lines... (TOP)
.y:		ld	a,[rLY]
		dec	a
		cp	140
		jr	nc,.y
		di
;__DA__ (BOTTOM)
.w1:		ldio	a,[rSTAT]
		and	3
		jr	z,.w1
.w2:		ldio	a,[rSTAT]
		and	3
		jr	nz,.w2
		ret

PrintWork	equ	$c800

makedata

;prints out what is on screen at $9800 with chars at $8800-$97ff

t1:
		call	colorfix

		ld	hl,$9800
		ld	de,PrintWork
		ld	a,18
.y:		ldh	[hTmpHi],a
		ld	a,20
.x:		ldh	[hTmpLo],a
		call	sync
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	c,[hl]
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	a,[hli]
		ei		; __DA__ 20200511 The USA version doesn't have this
		ld	b,a
		rrca
		rrca
		rrca
		and	1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		call	sync
		push	hl
		ld	hl,cmap
		ld	a,b
		and	7
		inc	a
		add	a
		add	a
		ld	l,a
		ld	a,[hli]
		ld	[cmap],a
		ld	a,[hli]
		ld	[cmap+1],a
		ld	a,[hli]
		ld	[cmap+2],a
		ld	a,[hl]
		ei		; __DA__ ditto...
		ld	[cmap+3],a

		ld	a,c
		add	$80
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	bc,$8800
		add	hl,bc
		push	de
		ld	c,4
.copy:		call	sync
		REPT	3
		ld	a,[hli]
		ld	[de],a
		inc	e
		ENDR
		ld	a,[hli]
		ei		; __DA__ ditto...
		ld	[de],a
		inc	de
		dec	c
		jr	nz,.copy
		pop	hl
		call	map1
		ld	d,h
		ld	e,l

		pop	hl
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.x
		ld	bc,12
		add	hl,bc
		ldh	a,[hTmpHi]
		dec	a
		jr	nz,.y
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a

		ld	a,[Type]
		add	a
		ret	z
		ret	c
		ld	hl,$c800
		ld	bc,16*20*3
		ld	a,$ff
		call	MemFill
		ld	hl,$c800+16*20*14
		ld	bc,16*20*4
		ld	a,$ff
		call	MemFill
		ld	hl,$c800+16*20*3
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
		call	.whitelr
.whitelr:	ld	bc,16*4
		ld	a,$ff
		call	MemFill
		ld	bc,16*12
		add	hl,bc
		ld	bc,16*4
		ld	a,$ff
		jp	MemFill

colorfix:
		ld	hl,pmap
		ld	de,cmaps
.cf32:		call	.cf16
.cf16:		call	.cf8
.cf8:		call	.cf4
.cf4:		call	.cf2
.cf2:		call	.cf1
.cf1:		ld	a,[hli]
		ld	b,a
		and	31
		ld	c,a
		ld	a,[hl]
		rlc	b
		adc	a
		rlc	b
		adc	a		
		rlc	b
		adc	a		
		and	31
		add	c
		ld	c,a
		ld	a,[hli]
		rrca
		rrca
		and	31
		add	c
		ld	c,a
		ld	b,$c8
		ld	a,[bc]
		ld	[de],a
		inc	de
		ret

;hl=char
map1:		ld	de,cmap
.map8:		call	.map4
.map4:		call	.map2
.map2:		call	.map1
.map1:		push	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	bc,0
		call	.mapbit8
		pop	hl
		ld	a,c
		ld	[hli],a
		ld	a,b
		ld	[hli],a
		ret		
.mapbit8:	call	.mapbit4
.mapbit4:	call	.mapbit2
.mapbit2:	call	.mapbit1
.mapbit1:	ld	e,0
		sla	h
		rl	e
		sla	l
		rl	e
		ld	a,[de]
		rrca
		rl	c
		rrca
		rl	b
		ret





	IF	0
;prints out a pinmap
t2:

		ldh	a,[hRomBank]
		push	af

		ld	a,WRKBANK_BM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_PRACTICEA1MAP
		ld	de,$d000
		call	SwdInFileSys

		ld	hl,$d000
		ld	de,PrintWork
		ld	a,18
.y:		ldh	[hTmpHi],a
		ld	a,20
.x:		ldh	[hTmpLo],a
		ld	a,WRKBANK_BM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[hli]
		and	$f0
		ld	c,a
		ld	a,[hl]
		rlc	a
		rlc	a
		and	3
		add	BANK(Char30)
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a

		ld	a,[hli]
		push	hl
		and	$3f
		add	$40
		ld	h,a
		ld	l,c
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	bc,16
		call	MemCopy
		pop	hl
		ldh	a,[hTmpLo]
		dec	a
		jr	nz,.x
		ld	bc,8
		add	hl,bc
		ldh	a,[hTmpHi]
		dec	a
		jr	nz,.y

		pop	af
		ldh	[hRomBank],a
		ld	[rMBC_ROM],a

		ret

	ENDC

	IF	0
;prints the b&w choke picture
t3:

		ld	a,WRKBANK_BM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_CHOKECHR
		ld	de,$d000
		call	SwdInFileSys

		ld	a,WRKBANK_BG
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	hl,IDX_CHOKEMAP
		ld	de,$d000
		call	SwdInFileSys

		ld	hl,$d008
		ld	de,PrintWork
.lp:		ld	a,WRKBANK_BG
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[hli]
		push	hl
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	bc,$d000
		add	hl,bc
		ld	c,16
.copy:
		ld	a,WRKBANK_BM
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,[hli]
		ld	b,a
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,b
		ld	[de],a
		inc	de
		dec	c
		jr	nz,.copy

		ld	hl,PrintWork+20*18*16
		ld	a,l
		cp	e
		jr	nz,.diff
		ld	a,h
		cp	d
.diff:		pop	hl
		jr	nz,.lp
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ret
	ENDC


;
;=====<<< End of File >>>=====
;

;
SioHibernate
	xor	a
	ldio	[rSC],a
	ldio	[rSB],a


;››››››››››››››››››››››››››››
; Initialization when power is turned on
SioInitialize
	xor	a
	ldio	[rSB],a
	ldio	[rSC],a
	ld	[PhaseNo],a
	ld	[SioWatchDogF],a
	dec	a
	ld	[PrinterStatus],a
	ld	[PrinterStatus+1],a
	ld	a,$80
	ld	[Concentration],a	;Concentration

	call	SioFlagInit
	ret

;››››››››››››››››››››››››››››
; Prepare for packet sending 
SioFlagInit
	xor	a
	ld	[EndofTrans],a
	ld	[SioIntOccur],a
	ld	[DuringTransPKT],a

;››››››››››››››››››››››››››››
; When packet transmission is finished 
ClearFlags
	xor	a
	ld	[PreambleSendF],a	; Preamble send end Flag
	ld	[HeaderSendF],a		; Header send end Flag
	ld	[Data1SendEndF],a
	ld	[CheckSumSendF],a
	ld	[DummySendF],a
	ld	[SioCheckSum_S],a
	ld	[SioCheckSum_S+1],a
        ld	[BufPointer],a
        ld	[BufPointer+1],a
	ld	[ForceEnd],a
	ld	[BusyFlag],a
	ret


;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Checking the printer connection 
;
;››››››››››››››››››››››››››››››››
ConnectPRN
	ld	a,[DuringTransPKT]
	and	a
	jr	z,.trans0

	call	CheckEndofTrans
	ret	nc
.trans0
	ld	a,[LastPhaseNo]
	cp	1
	jr	nz,.trans1
	call	CheckEndofTrans
	ret	nc
.trans1
	call	PreparePacket1
	jp	StartStringTrans


;››››››››››››››››››››››››››››››››
; Check at end of transmission of packet
CheckEndofTrans
	ld	a,[EndofTrans]
	cp	2
	jr	c,.TransContinue

	call	WaitNextCall		;Wait for the next frame
	jr	nz,.TransContinue

; Packet transmission is finished and printer status is valid 
	xor	a

	ld	[PrnTimer],a
	ld	[LastPhaseNo],a
	inc	a
	ld	[PhaseNo],a

	ld	a,[PrinterStatus]
	cp	$ff
	jr	z,.fatal

	bit	0,a			;CheckSum
	jr	nz,.retry	

	bit	1,a			;Busy
	jr	nz,.retry

	and	$f0			;Error?
	jr	z,.ret			;No Error

	xor	a
	ld	[PhaseNo],a
	ld	[LastPhaseNo],a
	ld	a,[PrinterStatus]
	call	SetPrinterErrorNo
	jr	.ret
.retry
	scf				; Re-send
	ret

.Hibernate
	xor	a
	ld	[LastPhaseNo],a		
	dec	a
.fatal
	inc	a
	ld	[PhaseNo],a		;PhaseNo=0
	dec	a
	call	SetPrinterErrorNo
.ret
	and	a
	ret

.TransContinue
	xor	a
	ld	a,$f0			; Printer status invalid / undetermined 
	ret


; Wait for next frame
WaitNextCall
	ld	hl,EndofTrans
	ld	a,[hl]
	cp	3
	ret	z			;return flag=z
	inc	a			;       flag=nz
	ld	[hl],a
	ret				;return flag=nz

;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Send print instruction to printer 
;
;››››››››››››››››››››››››››››››››
InstructPRN
	ld	a,[PhaseNo]
	cp	1
	jr	z,.ok
	cp	2
	jr	z,.ok
	and	a
	ld	a,$ff
	ret	z
.forced_return
	ld	a,$f0			; Printer status invalid / undetermined 
	ret
.ok
	ld	a,[BusyFlag]
	and	a
	jr	nz,.forced_return
	ld	a,[DuringTransPKT]
	and	a
	jr	z,.trans0
	call	CheckEndofTrans
	ret	nc
.trans0
	ld	a,[LastPhaseNo]
	cp	2
	jr	nz,.trans1
	call	CheckEndofTrans
	ret	nc
.trans1

	ld	a,[PrinterStatus]
	cp	$ff
	jp	z,SetPrinterErrorNo	; Error

.prepare
	call	PreparePacket2
	jp	StartStringTrans

;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
; Sending data packet
;	hl <- Data Address
;	a  <- Line Counter
;››››››››››››››››››››››››››››››››
DataTransPRN
	ld	c,a

	ld	a,[PhaseNo]
	and	a
	ld	a,[PrinterStatus]
	jp	z,SetPrinterErrorNo
.send
	ld	a,[PhaseNo]
	cp	1
	jr	z,.ok
	cp	3
	jr	z,.ok
	ld	a,$f0			; Printer status invalid / undetermined 
	ret
.ok
	ld	a,[DuringTransPKT]
	and	a
	jp	nz,.CheckEndofTrans

; The first time only
	ld	a,c
	inc	a
	ld	[LineCount],a		; +1 for END OF DATA 

	ld	a,l
	ld	[PrnDataAddress],a
	ld	a,h
	ld	[PrnDataAddress+1],a

	ld	a,[PrinterStatus]
	cp	$ff
	jp	z,SetPrinterErrorNo	; Error


.send01
; Only comes from above the first time

	ld	a,[CompressF]
	ld	[CompressFReal],a
	and	a
	jr	z,.normal0

	ld	a,[LineCount]
	dec	a
	dec	a

	push	af
	ld	c,a
	ld	b,0
	push	hl
	ld	hl,CompressFtbl
	add	hl,bc
	ld	a,[hl]
	pop	hl
	ld	[CompressFReal],a

	pop	af
	add	a,a
	ld	c,a
	ld	b,0
	push	hl
	ld	hl,CompressNum
	add	hl,bc
	ld	a,[hli]
	ld	b,[hl]
	pop	hl
	ld	c,a
	
	jp	.nextData

.normal0
	ld	bc,$0280		; Fixed for the time being 
					; The address is HL
.nextData
	call	PreparePacket3
	jp	StartStringTrans

.CheckEndofTrans
	ld	a,[EndofTrans]
	cp	2
	ld	a,$f0			; Printer status invalid / undetermined 
	jp	c,.ret

	call	WaitNextCall		; Wait for next frame
	ld	a,$f0			; Printer status invalid / undetermined 
	jp	nz,.ret

	ld	hl,LineCount

	ld	a,[PrinterStatus]
	ld	c,a
	and	$f0
	ld	a,c
	jp	nz,.erPacketEnd

	bit	1,a
	jp	nz,.saisou0			; Resend (BUSY)
	bit	0,a
	jp	nz,.saisou0			; Resend (CHECKSUM-ERR)

	ld	a,[hl]			; Has 'end of data transmission' been sent?
	and	a
	ld	a,[PrinterStatus]
	jp	z,.end			; yes

	ld	a,[hl]			; Send 'end of data transfer' 
	cp	1
	jp	z,.endofRecord

	dec	[hl]			; Counter Over
	ld	a,[PrinterStatus]
	jp	z,.end
.saisou0
	ld	a,[hl]
	cp	1			; Next frame is 'end of data transmission' packet  
	ld	a,$f0			; Printer status invalid / undetermined
	jp	z,.ret		; wait 1-frame 

	ld	bc,$0280

	ld	a,[CompressF]
	ld	[CompressFReal],a
	and	a
	jr	z,.normal

	ld	a,[LineCount]
	dec	a
	dec	a

	push	af
	ld	c,a
	ld	b,0
	push	hl
	ld	hl,CompressFtbl
	add	hl,bc
	ld	a,[hl]
	pop	hl
	ld	[CompressFReal],a

	pop	af

	add	a,a
	ld	c,a
	ld	b,0
	push	hl
	ld	hl,CompressNum
	add	hl,bc
	ld	a,[hli]
	ld	b,[hl]
	pop	hl
	ld	c,a
	

.normal
;nextdata
; Compression is not a consideration at the present time

	ld	a,[PrinterStatus]
	bit	1,a
	jp	nz,.saisou1			; Resend
.send02
	ld	a,[BufPointer_base2]
	add	a,$80
	ld	[BufPointer_base2],a
	ld	a,[BufPointer_base2+1]
	adc	a,$02
	ld	[BufPointer_base2+1],a
.saisou1
	ld	a,[BufPointer_base2]
	ld	l,a
	ld	a,[BufPointer_base2+1]
	ld	h,a

	jp	.nextData
;end
.erPacketEnd
	push	af
	ld	a,1
	ld	[ForceEnd],a
	pop	af	
	call	SetPrinterErrorNo
.end
	push	af
	xor	a
	ld	[FollowingData],a
	ld	[DuringTransPKT],a
	pop	af
.ret
	ret

.endofRecord
	ld	a,[LastBlock]
	and	a
	ld	a,[PrinterStatus]
	jr	z,.end
	dec	[hl]			;Counter<-0
	call	PreparePacket6
	jp	StartStringTrans
	
;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Send print break 
;
;››››››››››››››››››››››››››››››››
BreakPRN
	ld	a,[PhaseNo]
	cp	1
	jr	z,.ok
	cp	3
	jr	z,.ok
	and	a
	ld	a,$ff
	ret	z
	ld	a,$f0			; Printer status invalid / undetermined 
	ret
.ok
	ld	a,[DuringTransPKT]
	and	a
	jr	z,.trans0
	call	CheckEndofTrans
	ret	nc
.trans0
	ld	a,[LastPhaseNo]
	cp	4
	jr	nz,.trans1
	call	CheckEndofTrans
	ret	nc
.trans1
	ld	a,[PrinterStatus]
	cp	$ff
	jp	z,SetPrinterErrorNo	; Error

.send03
	call	PreparePacket4
	jp	StartStringTrans


;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Send NUL packet 
;
;››››››››››››››››››››››››››››››››
NULTransPRN
	ld	a,[PhaseNo]
	cp	1
	jr	z,.ok
	cp	3
	jr	z,.ok
	and	a
	ld	a,$ff
	ret	z
	ld	a,$f0			; Printer status invalid / undetermined 
	ret
.ok
	ld	a,[DuringTransPKT]
	and	a
	jr	z,.trans0
	call	CheckEndofTrans
	ret	nc
.trans0
	ld	a,[PrinterStatus]
	cp	$ff
	jp	z,SetPrinterErrorNo	; Error

.prepare
	call	PreparePacket5
	jp	StartStringTrans


;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Initializing character data transmission
;	a  <-- RequestedPhaseNo
;	d  <-- Exist Value data
;	hl <-- Start Address
;	bc <-- Transfer Count
;
;››››››››››››››››››››››››››››››››

InitDataTrans
	ld	[RequestPhaseNo],a	; Requested Phase No
	ld	a,d
	ld	[FollowingData],a	; Print instruction, data packet 

	ld	a,l			; Header/AfterPreamble address
	ld	[BufPointer_base],a
	ld	[BufPointer_base1],a
	ld	a,h
	ld	[BufPointer_base+1],a
	ld	[BufPointer_base1+1],a

	ld	a,c			; Header/AfterPreamble Count
	ld	[TransCount],a
	ld	[TransCount1],a
	ld	a,b
	ld	[TransCount+1],a
	ld	[TransCount1+1],a

	xor	a
	ld	[EndofTrans],a
	call	ClearFlags
	ret


; # Preamble data 
PreambleData
	db	$88,$33
	      ; Code            C-sum   Dummy
Packet1	db	$01,$00,$00,$00,$01,$00,$00,$00	; Connection check packet 
Packet2	db	$02,$00,$04,$00			; Print instruction packet 
Packet3						; Data packet
Packet6	db	$04,$00,$00,$00,$04,$00,$00,$00	; Data end packet 
Packet4	db	$08,$00,$00,$00,$08,$00,$00,$00	; Break packet 
Packet5	db	$0f,$00,$00,$00,$0f,$00,$00,$00	; NUL packet 
;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the connection check packet 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket1
	ld	a,1			; RequestPhaseNo
	ld	d,0			; Only Fixed Data
	ld	hl,Packet1
	ld	bc,8
	jp	InitDataTrans

;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the print instruction packet 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket2
	ld	a,2
	ld	d,0			; Only This Data
	ld	hl,HeaderWork
	ld	bc,12
	call	InitDataTrans

	ld	hl,Packet2
	ld	de,HeaderWork
	ld	bc,4
	call	MemCopy

;	Creating the print instruction data 
	ld	de,$0006		;Packettype:2 + Length:4
	ld	a,[NumofSheet]		;Number of sheets 
	ld	[HeaderWork+4],a
	call	.sumadd
	ld	a,[NumofFeed]		;Feed
	ld	[HeaderWork+5],a
	call	.sumadd
	ld	a,[ValueofPalette]		;Palette
	ld	[HeaderWork+6],a
	call	.sumadd

	ld	a,[Concentration]		;Concentration
	ld	[HeaderWork+7],a
	call	.sumadd
	ld	a,e			; Send check sum 
	ld	[HeaderWork+8],a
	ld	a,d			; Send check sum 
	ld	[HeaderWork+9],a
	xor	a
	ld	[HeaderWork+10],a	;Dummy1
	ld	[HeaderWork+11],a	;Dummy2
	ret

.sumadd
	add	a,e
	ld	e,a
	ld	a,d
	adc	a,0
	ld	d,a
	ret

;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the data packet 
;	hl <-- Data Address
;	bc <-- Data Count
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket3
	ld	a,l			; Data Address
	ld	[BufPointer_base2],a
	ld	a,h
	ld	[BufPointer_base2+1],a

	ld	a,c			; Data Count
	ld	[TransCount2],a
	ld	a,b
	ld	[TransCount2+1],a
	push	bc

	ld	a,3
	ld	d,1			; Not Only following Data
	ld	hl,HeaderWork
	ld	bc,4			; Only Header
	call	InitDataTrans

	ld	a,[Packet3]
	ld	[HeaderWork],a
; Creating the header data 
; Creating the actual data 
; Note: Determine beforehand whether data compressed or not compressed, then set the buffer address to Work

	ld	a,[CompressFReal]
	ld	[HeaderWork+1],a	; Compressed or not compressed 
	pop	bc

	ld	a,c
	ld	[HeaderWork+2],a	; Data length Low
	ld	a,b
	ld	[HeaderWork+3],a	; Data length High

	ret

;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the break packet 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket4
	ld	a,4			; RequestPhaseNo
	ld	d,0			; Only Fixed Data
	ld	hl,Packet4
	ld	bc,8
	jp	InitDataTrans
;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the NUL packet 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket5
	ld	a,5			; RequestPhaseNo
	ld	d,0			; Only Fixed Data
	ld	hl,Packet5
	ld	bc,8
	jp	InitDataTrans

;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Creating the data end packet 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
PreparePacket6
	ld	a,6			; RequestPhaseNo
	ld	d,1			; Only Fixed Data[but for DATA]
	ld	hl,Packet6
	ld	bc,8
	jp	InitDataTrans
	ret

;________________________________________________________________
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
;
;	Kick data send/receive 
;
;œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ
StartStringTrans
	ld	a,[PhaseNo]		; Is the present Phase 1?
	cp	1
	jr	z,.ok			; yes
	and	a
	jr	nz,.ng			; Error is 2 or above 

					; Phase0
	ld	a,[RequestPhaseNo]
	cp	1
	jr	z,.ok_connect
					; Requests other than connection check when disconnected
.ng					; Some Phases are not completed
	scf
	ret
.ok
	ld	a,[RequestPhaseNo]
	cp	1
	jr	z,.ng			; Already Phase1

	ld	[PhaseNo],a	
.ok_connect

;Send the first byte of the Preamble: Trigger packet sending
.FirstByte
	xor	a
	ld	[EndofTrans],a
	ld	[LastPhaseNo],a
	ld	a,1
	ld	[BufPointer],a
	ld	[DuringTransPKT],a

	ld	a,[PreambleData]
	ldio	[rSB],a
	ld	a,$01
	ldio	[rSC],a
	ld	a,$81
	ldio	[rSC],a
;
	ld	a,$f0			;Printer status invalid / undetermined 
	ret
;
;
;
;________________________________________________________________
;››››››››››››››››››››››››››››››››
;
;	Set Printer Error number
;
;››››››››››››››››››››››››››››››››
SetPrinterErrorNo
	push	af
	ld	a,1
	ldh	[hTmp2Hi],a
	ld	a,[PrinterStatus]
	cp	$ff
	jr	z,.next150
	bit	7,a
	jr	z,.next100
	ld	a,1	;0+1
	jr	.next700
.next100
	bit	6,a
	jr	z,.next130
	ld	a,4	;3+1
	jr	.next700
.next130
	bit	5,a
	jr	z,.next150
	ld	a,3	;2+1
	jr	.next700
.next150
	ld	a,[PrinterStatus+1]
	cp	$81
	jr	z,.next170
	ld	a,2	;1+1
	jr	.next700
.next170
	ld	a,2	;1+1
.next700
	ld	[PrinterErrorNo],a
	pop	af
	ret
;
;=====<<< End of File >>>=====
;


;==============================================================================
;   Copyright (C) 1998   NINTENDO
;==============================================================================

;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;
;	SIO send/receive interrupt
;
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
SioInt::
	push	af
	ldio	a,[rSC]
	bit	7,a
	jr	nz,.NoSioInt		; Really? 
;
	push	bc
	push	de
	push	hl

	ld	a,1
	ld	[SioIntOccur],a
	call	SioProc

	pop	hl
	pop	de
	pop	bc
.NoSioInt
        pop	af
	reti

;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;
;	SIO WatchDog
;
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
SioWatchDog
	ld	a,[PhaseNo]			; Printer connected? 
	cp	1
	ret	nz

	ld	a,[PrinterStatus]		; Printer error? 
	cp	$FF
	ret	z

	ld	a,[DuringTransPKT]	; During data transfer? 
	and	a
	ret	nz				; Yes

	ld	hl,PrnTimer
	inc	[hl]
	ld	a,[hl]		
	cp	6				;16.6msec x 6=99.6msec < 100msec
	ret	c
	xor	a
	ld	[hl],a
	ld	[BusyFlag],a
	call	NULTransPRN
	ret


;==============================================================================
;   Copyright (C) 1998   NINTENDO
;==============================================================================
;
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
;
;  SIO interrupt processing 
;
;¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
SioProc
	ld	a,[ForceEnd]
	and	a
	jp	nz,SIOForceEnd

	ld	a,[PhaseNo]
	cp	7
	jp	z,GetPrinterStatus

	ld	a,[PreambleSendF]
	and	a
	jr	nz,.afterHeader
	call	PreambleTrans		; Sends Preamble 
	ret
;-----	jp	SioIntRet

.afterHeader
	ld	a,[HeaderSendF]		; Is header finished being sent ? 
	and	a
	jr	z,.trans

; Only data packets come here.  For all else, PhaseNo = 7 when HeaderSendF becomes 1. 
	ld	a,[Data1SendEndF]
	and	a
	jr	z,.trans

	ld	a,[CheckSumSendF]
	cp	2
	jr	z,.sendDummy

	call	TransCheckSum		; Sends 2 bytes of Checksum 
	ret
;-----	jr	.ret
.sendDummy
	call	TransDummy		; Sends 2 bytes of Dummy data 
	ret
;-----	jr	.ret	

; All phases come 
.trans
	call	Transmit
.ret
	ret
;-----	jp	SioIntRet

;========================================================
PreambleTrans
	ld	hl,BufPointer
	ld	c,[hl]
	inc	[hl]
	ld	b,0
	ld	hl,PreambleData
	add	hl,bc

;****
;	call	Wait270us
	WAIT270

	ld	a,[hl]
	ldio	[rSB],a
	ld	a,%00000001		; Internal clock 
	ldio	[rSC],a
	ld	a,%10000001		; Request transmission of 1 byte
	ldio	[rSC],a

	ld	a,[BufPointer]
	cp	2
	ret	nz
	xor	a
	ld	[BufPointer],a
	inc	a
	ld	[PreambleSendF],a
	ret
	

;========================================================
Transmit
	ld	a,[BufPointer]
	ld	c,a
	ld	a,[BufPointer+1]
	ld	b,a

	ld	a,[BufPointer_base]
	ld	l,a
	ld	a,[BufPointer_base+1]
	ld	h,a

	add	hl,bc

	ldio	a,[rSB]
	ld	[SBbak],a

	ld	a,[hl]
	ldio	[rSB],a
	ld	l,a
	ld	a,[SioCheckSum_S]
	add	a,l
	ld	[SioCheckSum_S],a
	ld	a,[SioCheckSum_S+1]
	adc	a,0
	ld	[SioCheckSum_S+1],a
;*****
;	call	Wait270us
	WAIT270

	ld	a,%00000001		; Internal clock 
	ldio	[rSC],a
	ld	a,%10000001		; Request transmission of 1 byte 
	ldio	[rSC],a

	ld	hl,BufPointer
	inc	[hl]
	jr	nz,.skiphi
	inc	hl
	inc	[hl]
.skiphi
	ld	hl,BufPointer
	ld	a,[TransCount]
	cp	[hl]
	jr	nz,.continue	
	inc	hl
	ld	a,[TransCount+1]
	cp	[hl]	
	jr	z,.EndofTrans		; end of Trans
.continue
	ret

.EndofTrans
	ld	hl,HeaderSendF
	ld	a,[hl]
	and	a
	jr	z,.setflag

	ld	hl,Data1SendEndF
.setflag
	inc	[hl]
	ld	a,[FollowingData]
	and	a
	jr	z,SetEndofTrans

	ld	a,[PhaseNo]
	cp	6			; Data End Packet
	jr	z,SetEndofTrans

	ld	hl,Data1SendEndF
	ld	a,[hl]
	and	a
	jr	nz,.datatransend
	xor	a
	ld	[BufPointer],a
	ld	[BufPointer+1],a

	ld	a,[BufPointer_base2]
	ld	[BufPointer_base],a
	ld	a,[BufPointer_base2+1]
	ld	[BufPointer_base+1],a
	ld	a,[TransCount2]
	ld	[TransCount],a
	ld	a,[TransCount2+1]
	ld	[TransCount+1],a
	ret

.datatransend
	call	ForRetry_DataTrans
	ret

SetEndofTrans
	ld	a,[SBbak]
	ld	[PrinterStatus+1],a

SetEndofTrans_data
	ld	a,7			; Get Printer Status
	ld	[PhaseNo],a
	ld	a,1
	ld	[EndofTrans],a
	call	ClearFlags
ForRetry_DataTrans
	ld	a,[TransCount1]
	ld	[TransCount],a
	ld	a,[TransCount1+1]
	ld	[TransCount+1],a
	ld	a,[BufPointer_base1]
	ld	[BufPointer_base],a
	ld	a,[BufPointer_base1+1]
	ld	[BufPointer_base+1],a

	ret

;========================================================
TransCheckSum
	ld	c,a
	ld	b,0
	ld	hl,SioCheckSum_S
	add	hl,bc

;****
;	call	Wait270us
	WAIT270

	ld	a,[hl]
	ldio	[rSB],a
	ld	a,%00000001		; Internal clock 
	ldio	[rSC],a
	ld	a,%10000001		; Request transmission of 1 byte 
	ldio	[rSC],a

	ld	hl,CheckSumSendF
	inc	[hl]
	ret
;========================================================
TransDummy
	ldio	a,[rSB]
	ld	[PrinterStatus+1],a	;B is machine number? 

;****
;	call	Wait270us
	WAIT270

	xor	a
	ldio	[rSB],a
	ld	a,%00000001		; Internal clock 
	ldio	[rSC],a
	ld	a,%10000001		; Request transmission of 1 byte 
	ldio	[rSC],a

	ld	hl,DummySendF
	inc	[hl]
	ld	a,[hl]
	cp	2
	jr	z,SetEndofTrans_data
	ret




;››››››››››››››››››››››››››››
;
;	Getting the printer status 
;
;››››››››››››››››››››››››››››
GetPrinterStatus
	ld	a,[RequestPhaseNo]
	ld	[LastPhaseNo],a

	ld	a,[PrinterStatus]
	ld	[PrinterStatusLast],a
	ldio	a,[rSB]
	ld	[PrinterStatus],a
	cp	$FF
	jr	z,.fail2
	bit	7,a
	jr	nz,.fail1
	bit	5,a
	jr	nz,.fail3
	ld	a,[PrinterStatus+1]
	cp	$81
	jr	nz,.fail2
	ld	a,[PrinterStatus]
	jr	.ok
.fail1:
	ld	a,1
	jr	.fail
.fail2:
	ld	a,2
	jr	.fail
.fail3:
	ld	a,3
.fail:
	ld	[RealError],a
	ld	a,1
	ldh	[hTmp2Hi],a
	ld	a,0
	ld	[DuringTransPKT],a		; Clear 
	ld	[PhaseNo],a
;_forceOK
	ld	a,2
	jr	.ng
.ok
	bit	1,a
	jr	z,.ok10
	ld	a,1
	ld	[BusyFlag],a
.ok10
	bit	4,a
	ld	a,0
	ld	[PhaseNo],a
	ld	a,1
	jr	nz,.skip
	ld	[PhaseNo],a
.skip
	inc	a			; a is 2
.ng
	ld	[EndofTrans],a		; EndofTrans is 2 then over.

	ld	a,[FollowingData]	; During DataTrnasPRN
	and	a
	jr	nz,.skipifDataTrans

	xor	a
	ld	[DuringTransPKT],a
.skipifDataTrans	

SIOForceEnd				; NodataSetting
	ret


;The following code causes a crash after printing for some reason.
;Wait270us
;    PUSH    DE
;    LD      A,[rKEY1] 
;    BIT     7,A
;    JR      Z,_SINGLE
;_DOUBLE
;    LD      DE,57
;    JR      _LOOP
;_SINGLE
;    LD      DE,29   
;
;_LOOP
;    NOP                 ;1
;    NOP                 ;1
;    NOP                 ;1
;    DEC     DE          ;2
;    LD      A,D         ;1
;    OR      E           ;1
;    JR      NZ,_LOOP    ;3  A total of 10 cycles
;
;    POP     DE
;    RET
