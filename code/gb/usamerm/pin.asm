; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** PIN.ASM                                                               **
; **                                                                       **
; ** Last modified : 991223 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"
		INCLUDE "pin.equ"
		INCLUDE "msg.equ"

		SECTION	11

		INTERFACE ProcessDirties
		INTERFACE IceInit
		INTERFACE SoulInit
		INTERFACE ScuttleInit
		INTERFACE ShipInit
		INTERFACE mainboardfirst
		INTERFACE mainboardinit
		INTERFACE board2first
		INTERFACE board2init
		INTERFACE flounderinit
		INTERFACE flotsaminit
		INTERFACE kissinit
		INTERFACE ursulainit
		INTERFACE TresInit
		INTERFACE VolcInit
		INTERFACE TridentInit
		INTERFACE PrisonInit
		INTERFACE DashInit
		INTERFACE MorganaInit
		INTERFACE BearInit
		INTERFACE CloakInit


chainsubgame:	push	af
		call	unlocksub
		ld	hl,wTemp1024
		ld	de,wStore0
		ld	bc,192
		call	MemCopy
		ld	hl,wPinInfo
		ld	bc,wPinInfoEnd-wPinInfo
		call	MemCopy
		ld	hl,hTemp48
		ld	bc,48
		call	MemCopy
		call	pin_shutdown
		pop	af
		call	pintest
		ld	hl,wStore0
		ld	de,wTemp1024
		ld	bc,192
		call	MemCopy
		ld	de,wPinInfo
		ld	bc,wPinInfoEnd-wPinInfo
		call	MemCopy
		ld	de,hTemp48
		ld	bc,48
		call	MemCopy
		ld	hl,wStates
		ld	bc,64
		call	MemClear
		xor	a
		ldh	[pin_chainwant],a
		call	InitBalls
		ld	hl,wPinJmpChainRet
		call	LongVector
		jp	pinouter

DEMOY1		EQU	120<<5
DEMOY2		EQU	294<<5
DEMOX		EQU	87<<5
DEMOX1		EQU	94<<5
DEMOX2		EQU	79<<5

demojs:		ld	hl,any_democlock
		inc	[hl]
		jr	nz,.no2
		inc	hl
		inc	[hl]
		ld	a,[hl]
		cp	5
		jp	z,AnyQuit
.no2:		xor	a
		ldh	[hTmp2Lo],a
		ldh	[hTmp2Hi],a
		ldh	a,[pin_board]
		ld	bc,DEMOX1
		cp	SUBGAME_TABLE1
		jr	z,.bcok2
		ld	bc,DEMOX2
		cp	SUBGAME_TABLE2
		jr	z,.bcok2
		ld	bc,DEMOX
.bcok2:		ld	a,[wBalls+BALL_X]
		sub	c
		ld	a,[wBalls+BALL_X+1]
		sbc	b
		ld	a,0
		adc	a
		ldh	[hTmpHi],a
		ld	bc,DEMOY2
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		jr	z,.bcok
		cp	SUBGAME_TABLE2
		jr	z,.bcok
		ld	bc,DEMOY1
.bcok:		ld	a,[wBalls+BALL_Y]
		sub	c
		ld	a,[wBalls+BALL_Y+1]
		sbc	b
		ld	a,1
		jr	c,.above
		dec	a
.above:		ldh	[hTmpLo],a

		xor	a
		ld	[wJoy1Cur],a
		call	ReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	nz,.demodone
		ld	b,0
		ld	hl,wDemoL
		ld	c,(1<<JOY_L)
		call	randomhit
		ld	hl,wDemoR
		ld	c,(1<<JOY_A)
		ldh	a,[hTmpHi]
		cpl
		ldh	[hTmpHi],a
		call	randomhit
		ld	a,b
		ld	[wJoy1Cur],a
		ldh	a,[hTmp2Hi]
		ld	c,a
		ldh	a,[hTmp2Lo]
		or	a
		jr	z,.aok
		ldh	a,[hTmpHi]
		srl	a
		ld	a,(1<<JOY_R)
		jr	nc,.aok
		ld	a,(1<<JOY_B)
.aok:		or	c
		ld	[wJoy1Hit],a
		ret
.demodone:	call	AnyQuit
		xor	a
		ld	[wJoy1Hit],a
		ld	[wJoy1Cur],a
		ret
randomhit:	ldh	a,[hTmpLo]
		srl	a
		jr	c,.nofix
		bit	7,[hl]
		jr	nz,.nofix
		ldh	a,[hTmpHi]
		srl	a
		jr	nc,.nofix
		ld	a,1
		ld	[hTmp2Lo],a
		ld	[hl],$83
		ldh	a,[hTmp2Hi]
		or	c
		ldh	[hTmp2Hi],a
.nofix:		ld	a,[hl]
		and	$7f
		jr	nz,.wait
		ld	[hl],40
		jr	.set
.wait:		dec	[hl]
.set:		ld	a,[hl]
		add	a
		ret	nc
		ld	a,b
		or	c
		ld	b,a
		ret

chiffReadJoypad:
		ld	a,[wDemoMode]
		or	a
		jp	nz,demojs
		call	ReadJoypad
		ld	a,[any_lockedout]
		or	a
		jr	nz,.zeroout
		ld	a,[any_firing]
		or	a
		jr	z,.normal

		ld	a,[wJoy1Cur]
		and	255-(1<<JOY_L)-(1<<JOY_R)-(1<<JOY_U)-(1<<JOY_D)-(1<<JOY_SELECT)
		ld	b,a
		and	255-(1<<JOY_A)-(1<<JOY_B)
		cp	b
		jr	z,.nosel1
		or	1<<JOY_SELECT
.nosel1:	ld	[wJoy1Cur],a

		ld	a,[wJoy1Hit]
		and	255-(1<<JOY_L)-(1<<JOY_R)-(1<<JOY_U)-(1<<JOY_D)-(1<<JOY_SELECT)
		ld	b,a
		and	255-(1<<JOY_A)-(1<<JOY_B)
		cp	b
		jr	z,.nosel2
		or	1<<JOY_SELECT
.nosel2:	ld	[wJoy1Hit],a

.normal:	ld	a,[any_tvtake]
		or	a
		ret	nz
		ld	a,[wJoy1Hit]
		bit	JOY_L,a
		jr	nz,.chiff
		bit	JOY_A,a
		jr	nz,.chiff
		ret
;		bit	JOY_R,a
;		ret	z
.chiff:		ld	a,FX_FLIPPER
		jp	InitSfx
.zeroout:	xor	a
		ld	[wJoy1Hit],a
		ld	[wJoy1Cur],a
		ret

pintest::
		push	af
		ld	hl,hTemp48
		ld	bc,48
		call	MemClear
		ld	hl,wTemp1024
		ld	bc,1024
		call	MemClear
;		call	BuildMessageList
		call	InitBalls
		call	SetDifficulty

		pop	af

		or	$80	;means first time through, (gets cleared)
		ldh	[pin_board],a
pinouter:	call	pin_setup
		call	SubSong
pinloop:
; db $db,$02
		ld	hl,wTime
		inc	[hl]
		ldh	a,[pin_difficulty]
		or	a
		jr	nz,.force
		ld	a,[hl]
		rrca
		jr	nc,.noincclock
.force:		ld	hl,any_clock-1
.inclp:		inc	hl
		inc	[hl]
		jr	z,.inclp
.noincclock:
		call	WaitForVBL
		ldh	a,[pin_flags2]
		bit	PINFLG2_TV,a
		jr	z,.notv
		res	PINFLG2_TV,a
		ldh	[pin_flags2],a
		ld	a,[any_tv]
		call	TV
		call	ProcessDirties_b
		call	WaitForVBL
.notv:

;		ld	a,[any_samplewant]
;		or	a
;		jr	z,.nosample
;		call	SoundTest
;		xor	a
;		ld	[any_samplewant],a
;.nosample:


;		ld	hl,any_rumble
;		ld	a,[hl]
;		or	a
;		jr	z,.norumble
;		dec	[hl]
;		ld	hl,any_rumbleshift
;		rrc	[hl]
;		ld	a,[hl]
;		and	8
;		ld	[$4000],a
;.norumble:

; db $db,$03
		ld	a,[any_tvtake]
		or	a
		jr	nz,.nochain
		ldh	a,[pin_chainwant]
		or	a
		jp	nz,chainsubgame
.nochain:	call	chiffReadJoypad

		ldh	a,[pin_flags]
		bit	PINFLG_EXIT,a
		jp	nz,pindone

		xor	a
		ldh	[pin_xpush],a
		ldh	[pin_ypush],a
		call	tilts

		call	pushballs

		ld	a,[any_tvtake]
		or	a
		jr	nz,.moviestop
		call	processballs
		ld	a,[any_shutdown]
		or	a
		jr	z,.noshutdown
		dec	a
		ld	[any_shutdown],a
		call	z,AnyEnd
.noshutdown:	ld	hl,wPinJmpProcess
		call	LongVector
		call	ProcessDirties_b
		jr	.nomoviestop

.moviestop:
		ld	de,$0200
		ld	a,[wMapYSize]
		sub	21
		ld	h,a
		ld	l,e
		push	hl
		call	NewScroll
		pop	hl
		ld	a,[wMapYPos+1]
		sub	h
		jr	nc,.pos
		cpl
		inc	a
.pos:		cp	3
		jr	nc,.nomove
		call	StepVideo
		call	ProcessDirties_b
.nomove:	jr	.forcebottom
.nomoviestop:
		call	pinview
		ldh	a,[pin_xpush]
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok1
		dec	b
.bok1:		ld	a,e
		add	c
		ld	e,a
		ld	a,d
		adc	b
		ld	d,a
		ldh	a,[pin_ypush]
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok2
		dec	b
.bok2:		add	hl,bc
		call	NewScroll
.forcebottom:
		call	InitFigures64
		call	showpinballs

		ld	hl,wPinJmpSprites
		call	LongVector

		call	OutFigures
		call	unpushballs

		ld	a,1
		ldh	[hPosFlag],a

		call	panel

		ld	hl,pin_flags
		bit	PINFLG_FIRST,[hl]
		jr	nz,.nofade
		set	PINFLG_FIRST,[hl]
		call	FadeIn
.nofade:
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	z,pinloop

;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
	IF	0
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
pinpause:	xor	a
		ld	[any_rumble],a
		xor	a
		ld	[any_selected],a
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		ld	a,PAUSE1MAX
		jr	z,.aok
		ld	a,PAUSE2MAX
.aok:		ld	[any_maxsel],a
.pauseouter:	ld	a,[any_selected]
		add	a
		ld	e,a
		ld	d,0
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		ld	hl,pause1list
		jr	z,.hlok
		ld	hl,pause2list
.hlok:		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	statusmsg
		call	pinmsg
.pplp:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[any_maxsel]
		ld	b,a
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jp	nz,.pausedone
		bit	JOY_L,a
		jr	nz,.left
		bit	JOY_R,a
		jr	z,.pplp
.right:		ld	a,[any_selected]
		inc	a
		cp	b
		jr	nz,.gotnew
		xor	a
.gotnew:	ld	[any_selected],a
		jr	.pauseouter
.left:		ld	a,[any_selected]
		or	a
		jr	z,.carry
		dec	a
		jr	.gotnew
.carry:		ld	a,b
		dec	a
		jr	.gotnew


.pausedone:
		ld	hl,pin_flags
		set	PINFLG_SCORE,[hl]
		ld	a,[any_selected]
		ld	e,a
		ld	d,0
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		ld	hl,pause1chains
		jr	z,.hlok2
		ld	hl,pause2chains
.hlok2:		add	hl,de
		ld	a,[hl]
		or	a
		jr	z,.nochain
		call	ChainSub
		xor	a
		ld	[any_firing],a
.nochain:	jp	pinloop
pause1list:	dw	MSGPAUSE
		dw	MSGKISSNAME
		dw	MSGSCUTTLENAME
		dw	MSGSHIPNAME
		dw	MSGTREASURENAME
		dw	MSGSOULSNAME
		dw	MSGFLOUNDERNAME
		dw	MSGFLOTSAMNAME
		dw	MSGURSULANAME
pause1chains:	db	0
		db	SUBGAME_KISS
		db	SUBGAME_SCUTTLE
		db	SUBGAME_SHIP
		db	SUBGAME_TREASURE
		db	SUBGAME_CAVE
		db	SUBGAME_FLOUNDER
		db	SUBGAME_FLOTSAM
		db	SUBGAME_URSULA
PAUSE1MAX	EQU	@-pause1chains
pause2list:	dw	MSGPAUSE
		dw	MSGICECAVENAME
		dw	MSGVOLCANONAME
		dw	MSGCLOAKNAME
		dw	MSGPRISONNAME
		dw	MSGMORGANANAME
		dw	MSGTRIDENTNAME
		dw	MSGDASHNAME
		dw	MSGBEARNAME
pause2chains:	db	0
		db	SUBGAME_ICECAVE
		db	SUBGAME_VOLCANO
		db	SUBGAME_CLOAK
		db	SUBGAME_PRISON
		db	SUBGAME_MORGANA
		db	SUBGAME_TRIDENT
		db	SUBGAME_DASH
		db	SUBGAME_BEAR
PAUSE2MAX	EQU	@-pause2chains
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
	ELSE
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
pinpause:	xor	a
		ld	[any_rumble],a

		xor	a
		ld	[any_selected],a
		ld	a,3
		ld	[any_maxsel],a

.pauseouter:	ld	a,[any_selected]
		or	a
		ld	de,MSGPAUSE
		jr	z,.deok
		cp	2
		ld	de,MSGQUIT
		jr	z,.deok
		ld	a,[bMenus+OPT_OPTIONS+2]
		or	a
		ld	de,MSGRUMBLEON
		jr	z,.deok
		ld	de,MSGRUMBLEOFF
.deok:		call	statusde
.pplp:		call	WaitForVBL
		call	ReadJoypad
		ld	a,[any_maxsel]
		ld	b,a
		ld	a,[wJoy1Hit]
		bit	JOY_A,a
		jr	nz,.doit
		bit	JOY_B,a
		jp	nz,.trypausedone
		bit	JOY_START,a
		jp	nz,.pausedone
		bit	JOY_L,a
		jr	nz,.left
; bit	JOY_D,a	;DEBUG
; jr	nz,.msgs
		bit	JOY_R,a
		jr	z,.pplp
.right:		ld	a,[any_selected]
		cp	b
		jr	nc,.yesno
		xor	2
;		inc	a
;		cp	b
;		jr	nz,.gotnew
;		xor	a
.gotnew:	ld	[any_selected],a
		jr	.pauseouter
.left:		ld	a,[any_selected]
		cp	b
		jr	nc,.yesno
;		or	a
;		jr	z,.carry
;		dec	a
;		jr	.gotnew
;.carry:		ld	a,b
;		dec	a
		xor	2
		jr	.gotnew
.yesno:		xor	1
.toyesno:	ld	[any_selected],a
		and	1
		ld	de,MSGNO
		jr	z,.deok
		ld	de,MSGYES
		jr	.deok
.trypausedone:	ld	a,[any_selected]
		cp	8
		jr	c,.pausedone
.nope:		ld	a,2
		ld	[any_selected],a
		jp	.pauseouter
.doit:		ld	a,[any_selected]
		cp	8
		jr	z,.nope
		cp	9
		jr	z,.quit
		or	a
		jr	z,.pplp
		cp	2
		jr	z,.tryquit
		ld	a,[bMenus+OPT_OPTIONS+2]
		and	1
		xor	1
		ld	[bMenus+OPT_OPTIONS+2],a
		jp	.pauseouter
.tryquit:	ld	de,MSGSURE
		call	statusde
		call	Wait60
		ld	a,8
		jr	.toyesno
.quit:		call	AnyQuit
		jr	.pausedone
.msgs:		ld	hl,any_rumble
		inc	[hl]
		ld	a,[hl]
		cp	254
		jr	c,.ok
		ld	[hl],1
.ok:		ld	l,[hl]
		ld	h,0
		call	statusmsg
		jp	.pplp

.pausedone:
		xor	a
		ld	[any_rumble],a
		ld	hl,wPinJmpScore
		call	LongVector
		jp	pinloop

;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
	ENDC
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************




pindone:	call	pin_shutdown
		jp	ResultScreen

FLASHTIME	equ	120

panel:
 ld	a,[wTime]
 and $1f
 cp $19
 ret nz
 jp	statusprocess

		ldh	a,[pin_flash]
		or	a
		jr	z,.noflash
		inc	a
		cp	FLASHTIME
		jr	nc,.toscore
		ldh	[pin_flash],a
 ret
		ld	b,a
		and	7
		ret	nz
		bit	3,b
		jp	z,pinclear
		jp	pinmsg
.noflash:
		ldh	a,[pin_flags]
		bit	PINFLG_SCORE,a
		jr	z,.noscore
		res	PINFLG_SCORE,a
		ldh	[pin_flags],a
.toscore:	xor	a
		ldh	[pin_flash],a
		ld	hl,wPinJmpScore
		call	LongVector
.noscore:	ret



doflippers:	call	dolflipper
dorflipper:	ld	hl,pin_rflipperdlt
		ld	[hl],0
		ld	a,[wJoy1Cur]
;		bit	JOY_R,a
;		jr	nz,.upright
		bit	JOY_A,a
		jr	z,.downright
.upright:	ldh	a,[pin_rflipper]
		cp	MAXFLIPPER
		ret	z
		ld	[hl],1
		inc	a
		jp	newright
.downright:	ldh	a,[pin_rflipper]
		cp	MINFLIPPER
		ret	z
		ld	[hl],-1
		dec	a
		jp	newright


dolflipper:	ld	hl,pin_lflipperdlt
		ld	[hl],0
		ldh	a,[pin_flags]
		bit	PINFLG_FORCEL,a
		jr	nz,.upleft
		ld	a,[wJoy1Cur]
		bit	JOY_L,a
		jr	z,.downleft
.upleft:
		ldh	a,[pin_flags]
		res	PINFLG_FORCEL,a
		ldh	[pin_flags],a
		ldh	a,[pin_lflipper]
		cp	MAXFLIPPER
		ret	z
		ld	[hl],1
		inc	a
		jp	newleft
.downleft:	ldh	a,[pin_lflipper]
		cp	MINFLIPPER
		ret	z
		ld	[hl],-1
		dec	a
		jp	newleft

newleft:	push	af
		ld	hl,wPinLeftSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ldh	a,[pin_lflipper]
		call	offflipper
		pop	hl
		pop	af
		ldh	[pin_lflipper],a
		jp	onflipper

newright:	push	af
		ld	hl,wPinRightSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ldh	a,[pin_rflipper]
		call	offflipper
		pop	hl
		pop	af
		ldh	[pin_rflipper],a
		jp	onflipper


offflipper:	and	15
		ret	z
		dec	a
		add	l
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		jp	UndoChanges

onflipper:	and	15
		ret	z
		dec	a
		add	l
		ld	l,a
		ld	a,h
		adc	0
		ld	h,a
		jp	MakeChanges

OffFlippers::	ld	hl,wPinLeftSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[pin_lflipper]
		call	offflipper
		ld	hl,wPinRightSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[pin_rflipper]
		jp	offflipper
OnFlippers::	ld	hl,wPinLeftSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[pin_lflipper]
		call	onflipper
		ld	hl,wPinRightSet
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[pin_rflipper]
		jp	onflipper



showpinballs:
		xor	a
.showlp:	ld	[wBallCount],a
		ld	l,a
		ld	h,HIGH(wBalls)
		bit	BALLFLG_USED,[hl]
		jr	z,.notused
		ld	de,pin_ballflags
		ld	bc,BALLSIZE
		call	MemCopy
		call	showpinball
.notused:	ld	a,[wBallCount]
		add	BALLSIZE
		cp	MAXBALLS*BALLSIZE
		jr	c,.showlp
		ret
showpinball:	ld	a,[wMapXPos]
		and	$e0
		ld	l,a
		ld	a,[wMapXPos+1]
		dec	a
		ld	h,a
		ldh	a,[pin_x]
		and	$e0
		sub	l
		ld	l,a
		ldh	a,[pin_x+1]
		sbc	h
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	d,h

		ld	a,[wMapYPos]
		and	$e0
		ld	l,a
		ld	a,[wMapYPos+1]
		dec	a
		ld	h,a
		ldh	a,[pin_y]
		and	$e0
		sub	l
		ld	l,a
		ldh	a,[pin_y+1]
		sbc	h
		inc	a
		ld	h,a

		add	hl,hl
		ret	c
		add	hl,hl
		ret	c
		add	hl,hl
		ret	c
		ld	a,h
		sub	8
		ld	e,a


		ld	a,[any_pearlball]
		or	a
		jr	nz,pearlball

		ldh	a,[pin_ballpause]
		or	a
		jr	z,.nopause
		cp	SHRINKTIME*1
		jr	c,.size16
		cp	SHRINKTIME*2
		jr	c,.size17
		cp	SHRINKTIME*3
		jr	c,.size18
		cp	HOLDTIME-SHRINKTIME*3
		ret	c
		cp	HOLDTIME-SHRINKTIME*2
		jr	c,.size18
		cp	HOLDTIME-SHRINKTIME*1
		jr	c,.size17
.size16:	ld	bc,IDX_BALL+16
		jr	.gotbc
.size17:	ld	bc,IDX_BALL+17
		jr	.gotbc
.size18:	ld	bc,IDX_BALL+18
		jr	.gotbc
.nopause:
		ldh	a,[pin_theta]
		swap	a
		and	15
		add	255&IDX_BALL
		ld	c,a
		ld	a,0
		adc	IDX_BALL>>8
		ld	b,a
.gotbc:		ld	a,GROUP_BALL
		jp	AddFigure

pearlball:
		ldh	a,[pin_ballpause]
		or	a
		jr	z,.nopause
		cp	SHRINKTIME*1
		jr	c,.size16
		cp	SHRINKTIME*2
		jr	c,.size17
		cp	SHRINKTIME*3
		jr	c,.size18
		cp	HOLDTIME-SHRINKTIME*3
		ret	c
		cp	HOLDTIME-SHRINKTIME*2
		jr	c,.size18
		cp	HOLDTIME-SHRINKTIME*1
		jr	c,.size17
.size16:	ld	bc,IDX_WHITEPEARL+16
		jr	.gotbc
.size17:	ld	bc,IDX_WHITEPEARL+17
		jr	.gotbc
.size18:	ld	bc,IDX_WHITEPEARL+18
		jr	.gotbc
.nopause:
		ldh	a,[pin_theta]
		swap	a
		and	15
		add	255&IDX_WHITEPEARL
		ld	c,a
		ld	a,0
		adc	IDX_WHITEPEARL>>8
		ld	b,a
.gotbc:		ld	a,GROUP_PEARL
		jp	AddFigure

processballs:
;;DEBUG		call	doflippers
		ld	a,1
		ldh	[pin_doperball],a
		call	pinmoves
		xor	a
		ldh	[pin_doperball],a
		call	pinmoves
		ldh	a,[pin_difficulty]
		or	a
		call	nz,pinmoves
		ld	a,[any_speed]
		rrc	a
		ld	[any_speed],a
		ret	nc
pinmoves:
		call	doflippers
		call	ballcollisions
		ld	hl,pin_grcount
		inc	[hl]
		ld	a,[hl]
		cp	GRAVITYDIV
		jr	c,.noresetgravity
		ld	[hl],0
.noresetgravity:
		ld	hl,pin_spcount
		inc	[hl]
		ld	a,[hl]
		cp	SPINDIV
		jr	c,.noresetspin
		ld	[hl],0
.noresetspin:

		xor	a
.movelp:	ld	[wBallCount],a
		ld	l,a
		ld	h,HIGH(wBalls)
		bit	BALLFLG_USED,[hl]
		jr	z,.notused
		ld	de,pin_ballflags
		push	de
		push	hl
		ld	bc,BALLSIZE
		call	MemCopy
		call	pinmove
		ldh	a,[pin_doperball]
		or	a
		ld	hl,wPinJmpPerBall
		call	nz,LongVector
		pop	de
		pop	hl
		ld	bc,BALLSIZE
		call	MemCopy
.notused:	ld	a,[wBallCount]
		add	BALLSIZE
		cp	MAXBALLS*BALLSIZE
		jr	c,.movelp
		ret


pinmove:	ldh	a,[pin_ballpause]
		or	a
		jr	z,.nopause
		ld	a,[wTime]
		and	3
		ret	nz
		ldh	a,[pin_ballpause]
		dec	a
		ldh	[pin_ballpause],a
		jr	z,.scoopout
		cp	HOLDTIME/2
		ret	nz
		ld	hl,wPinJmpEject
		jp	LongVector
.scoopout:	ld	a,FX_SCOOPOUT
		jp	InitSfx
.nopause:	ldh	a,[pin_grcount]
		or	a
		jr	nz,.nogravity
		ldh	a,[pin_vy]
		add	GRAVITY
		ldh	[pin_vy],a
		jr	nc,.nocarry
		ldh	a,[pin_vy+1]
		inc	a
		ldh	[pin_vy+1],a
.nocarry:
.nogravity:

		ldh	a,[pin_spcount]
		or	a
		jr	nz,.nospin
		ldh	a,[pin_dtheta]
		ld	b,a
		ldh	a,[pin_theta]
		add	b
		ldh	[pin_theta],a
.nospin:

		ld	hl,wPinCutoff
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ldh	a,[pin_y]
		sub	l
		ldh	a,[pin_y+1]
		sbc	h
		jr	c,.noresetball

		xor	a
		ldh	[pin_ballflags],a

		ld	hl,wPinJmpLost
		jp	LongVector


.noresetball:


		ldh	a,[pin_x]
		ld	e,a
		ldh	a,[pin_x+1]
		ld	d,a
		ldh	a,[pin_vx]
		add	e
		ld	e,a
		ldh	[pin_x],a
		ldh	a,[pin_vx+1]
		adc	d
		ld	d,a
		ldh	[pin_x+1],a

		ldh	a,[pin_y]
		ld	c,a
		ldh	a,[pin_y+1]
		ld	b,a
		ldh	a,[pin_vy]
		add	c
		ld	c,a
		ldh	[pin_y],a
		ldh	a,[pin_vy+1]
		adc	b
		ld	b,a
		ldh	[pin_y+1],a

		call	pinbyte
		ld	l,a
		and	$c0
		or	a
		jp	z,.nohit

		ldh	[pin_hittype],a	;type of hit
		xor	l
		ld	c,a
		ld	b,0
		ld	hl,TblSin
		add	hl,bc
		ld	a,[hl]
		ldh	[pin_sin],a	;sin
		ld	hl,TblCos
		add	hl,bc
		ld	a,[hl]
		ldh	[pin_cos],a	;cos

		call	fixpush
		ld	hl,pin_flags
		res	PINFLG_FLIPPED,[hl]
		ldh	a,[pin_hittype]	;type of hit
		cp	2<<6
		ld	hl,wPinJmpHitFlipper
		call	z,LongVector

		ldh	a,[pin_vy]
		ld	c,a
		ldh	a,[pin_vy+1]
		ld	b,a
		ldh	a,[pin_sin]	;sin
		call	bcmula
		ld	d,h
		ld	e,l
		ldh	a,[pin_vx]
		ld	c,a
		ldh	a,[pin_vx+1]
		ld	b,a
		ldh	a,[pin_cos]	;cos
		call	bcmula
		add	hl,de		;hl=v
		ld	a,h
		add	a
		jp	nc,.nocollision

		push	hl

		call	hlshr2
		call	hlshr2

		ld	b,h
		ld	c,l
		push	bc
		ldh	a,[pin_cos]	;cos
		call	bcmula
		call	hlshr3

		ld	d,h
		ld	e,l
		ldh	a,[pin_vx]
		ld	l,a
		ldh	a,[pin_vx+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,l
		sub	e
		ld	l,a
		ld	a,h
		sbc	d
		ld	h,a

 call	deshr1
 ld	a,l
 sub	e
 ld	l,a
 ld	a,h
 sbc	d
 ld	h,a
 ldh	a,[pin_hittype]	 ;type of hit
 cp	2<<6
 jr	z,.flipper1
 call	deshr2
 add	hl,de
.flipper1:

		call	hlshr3
		ld	a,l
		ldh	[pin_vx],a
		ld	a,h
		ldh	[pin_vx+1],a

		pop	bc

		ldh	a,[pin_sin]	;sin
		call	bcmula
		call	hlshr3

		ld	d,h
		ld	e,l
		ldh	a,[pin_vy]
		ld	l,a
		ldh	a,[pin_vy+1]
		ld	h,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	a,l
		sub	e
		ld	l,a
		ld	a,h
		sbc	d
		ld	h,a

 call	deshr1
 ld	a,l
 sub	e
 ld	l,a
 ld	a,h
 sbc	d
 ld	h,a
 ldh	a,[pin_hittype]	 ;type of hit
 cp	2<<6
 jr	z,.flipper2
 call	deshr2
 add	hl,de
.flipper2:

		call	hlshr3
		ld	a,l
		ldh	[pin_vy],a
		ld	a,h
		ldh	[pin_vy+1],a

		ld	hl,wPinJmpHit
		call	LongVector

		pop	hl	;hl=v

		ldh	a,[pin_hittype]
		cp	1<<6
		call	z,hitbumper


		ldh	a,[pin_vy]
		ld	c,a
		ldh	a,[pin_vy+1]
		ld	b,a
		ldh	a,[pin_cos]	;cos
		call	bcmula
		ld	d,h
		ld	e,l
		ldh	a,[pin_vx]
		ld	c,a
		ldh	a,[pin_vx+1]
		ld	b,a
		ldh	a,[pin_sin]	;sin
		call	bcmula
		ld	a,e
		sub	l
		ld	l,a
		ld	a,d
		sbc	h
		ld	h,a		;hl=y for rotation
		call	hlshr5
		ldh	a,[pin_dtheta]
		ld	c,a
		ld	a,l
		ldh	[pin_dtheta],a
		sub	c
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok
		dec	b
.bok:
 if 0
		push	bc
		ldh	a,[pin_sin]	;sin
		call	bcmula
		call	hlshr5
		call	hlshr5
		ldh	a,[pin_vx]
		add	l
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		adc	h
		ldh	[pin_vx+1],a
		pop	bc
		ldh	a,[pin_cos]	;cos
		cpl
		inc	a
		call	bcmula
		call	hlshr5
		call	hlshr5
		ldh	a,[pin_vy]
		add	l
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		adc	h
		ldh	[pin_vy+1],a
 endc
		jr	.noflipped

.nocollision
		ldh	a,[pin_flags]
		bit	PINFLG_FLIPPED,a
		jr	z,.noflipped
		ldh	a,[pin_xfliplo]	;flipper xvel low
		ld	c,a
		ldh	a,[pin_xfliphi]	;flipper xvel high
		ld	b,a
		ldh	a,[pin_vx]
		add	c
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		adc	b
		ldh	[pin_vx+1],a

		ldh	a,[pin_yfliplo]	;flipper yvel low
		ld	c,a
		ldh	a,[pin_yfliphi]	;flipper yvel high
		ld	b,a
		ldh	a,[pin_vy]
		add	c
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		adc	b
		ldh	[pin_vy+1],a

.noflipped:
		call	unfixpush

		ld	a,7
		ldh	[hTmp2Hi],a	;eventual escape...
.pushout:
		ldh	a,[pin_cos]	;cos
		ld	e,a
		ld	d,0
		add	a
		jr	nc,.posc
		dec	d
.posc:
		call	deshr2
		ldh	a,[pin_x]
		add	e
		ldh	[pin_x],a
		ld	e,a
		ldh	a,[pin_x+1]
		adc	d
		ldh	[pin_x+1],a
		ld	d,a

		ldh	a,[pin_sin]	;sin
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.poss
		dec	b
.poss:
		call	bcshr2
		ldh	a,[pin_y]
		add	c
		ldh	[pin_y],a
		ld	c,a
		ldh	a,[pin_y+1]
		adc	b
		ldh	[pin_y+1],a
		ld	b,a
		call	pinbyte
		ld	c,a
		and	$c0
		jr	z,.nohit
		xor	c
		ld	c,a
		ld	b,0
		ld	hl,TblSin
		add	hl,bc
		ld	a,[hl]
		ldh	[pin_sin],a	;sin
		ld	hl,TblCos
		add	hl,bc
		ld	a,[hl]
		ldh	[pin_cos],a	;cos
		ld	hl,hTmp2Hi
		dec	[hl]
		jr	nz,.pushout
		ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		jr	nz,.noforcel
		ldh	a,[pin_flags]
		set	PINFLG_FORCEL,a
		ldh	[pin_flags],a
.noforcel:

.nohit:

		ld	a,[wPinHitBank]
		or	a
		call	nz,dohits

		ret



NEARLIMIT	EQU	4<<5
nearbox:	ldh	a,[pin_x]
		sub	e
		ld	e,a
		ldh	a,[pin_x+1]
		sbc	d
		ld	d,a
		call	c,negde
		ld	a,e
		sub	NEARLIMIT&255
		ld	a,d
		sbc	NEARLIMIT>>8
		ret	nc
		ldh	a,[pin_y]
		sub	c
		ld	c,a
		ldh	a,[pin_y+1]
		sbc	b
		ld	b,a
		call	c,negbc
		ld	a,c
		sub	NEARLIMIT&255
		ld	a,b
		sbc	NEARLIMIT>>8
		ret




unpushballs:	call	getpushposes
		ld	a,b
		or	c
		jr	nz,.doit
		ld	a,d
		or	e
		ret	z
.doit:		ld	hl,wBalls+BALL_FLAGS
.lp:		ld	a,l
		add	BALL_BALLPAUSE
		ld	l,a
		ld	a,[hl]
		or	a
		ld	a,BALLSIZE-BALL_BALLPAUSE
		jr	nz,.notused
		ld	a,l
		sub	BALL_BALLPAUSE
		ld	l,a
		ld	a,BALLSIZE
		bit	BALLFLG_USED,[hl]
		jr	z,.notused
		inc	l
		ld	a,[hl]
		sub	e
		ld	[hli],a
		ld	a,[hl]
		sbc	d
		ld	[hli],a
		inc	l
		inc	l
		ld	a,[hl]
		sub	c
		ld	[hli],a
		ld	a,[hl]
		sbc	b
		ld	[hl],a
		ld	a,BALLSIZE-(BALL_Y+1)
.notused:	add	l
		ld	l,a
		cp	LOW(wBalls)+MAXBALLS*BALLSIZE
		jr	c,.lp
		ret
pushballs:	call	getpushposes
		ld	a,b
		or	c
		jr	nz,.doit
		ld	a,d
		or	e
		ret	z
.doit:		ld	hl,wBalls+BALL_FLAGS
.lp:		ld	a,l
		add	BALL_BALLPAUSE
		ld	l,a
		ld	a,[hl]
		or	a
		ld	a,BALLSIZE-BALL_BALLPAUSE
		jr	nz,.notused
		ld	a,l
		sub	BALL_BALLPAUSE
		ld	l,a
		ld	a,BALLSIZE
		bit	BALLFLG_USED,[hl]
		jr	z,.notused
		inc	l
		ld	a,[hl]
		add	e
		ld	[hli],a
		ld	a,[hl]
		adc	d
		ld	[hli],a
		inc	l
		inc	l
		ld	a,[hl]
		add	c
		ld	[hli],a
		ld	a,[hl]
		adc	b
		ld	[hl],a
		ld	a,BALLSIZE-(BALL_Y+1)
.notused:	add	l
		ld	l,a
		cp	LOW(wBalls)+MAXBALLS*BALLSIZE
		jr	c,.lp
		ret


getpushposes:	ldh	a,[pin_xpush]
		ld	e,a
		ld	d,0
		add	a
		jr	nc,.dok
		dec	d
.dok:		ldh	a,[pin_ypush]
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok
		dec	b
.bok:		ret



fixpush:	call	getpushes
		ldh	a,[pin_vx]
		add	c
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		adc	b
		ldh	[pin_vx+1],a
		ldh	a,[pin_vy]
		add	e
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		adc	d
		ldh	[pin_vy+1],a
		ret
unfixpush:	call	getpushes
		ldh	a,[pin_vx]
		sub	c
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		sbc	b
		ldh	[pin_vx+1],a
		ldh	a,[pin_vy]
		sub	e
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		sbc	d
		ldh	[pin_vy+1],a
		ret

getpushes:	ld	bc,0
		ldh	a,[pin_xpush]
		or	a
		jr	z,.gotbc
		ld	bc,PUSHVAL
		add	a
		jr	nc,.gotbc
		ld	bc,-PUSHVAL
.gotbc:		ld	de,0
		ldh	a,[pin_ypush]
		or	a
		jr	z,.gotde
		ld	de,PUSHVAL
		add	a
		jr	nc,.gotde
		ld	de,-PUSHVAL
.gotde:		ret


neghl:		ld	a,l
		cpl
		ld	l,a
		ld	a,h
		cpl
		ld	h,a
		inc	hl
		ret

hlshr3:		bit	7,h
		jr	z,poshlshr3
		jr	neghlshr3
hlshr5:		bit	7,h
		jr	z,poshlshr5
		sra	h
		rr	l
		jr	nc,.noinc1
		inc	hl
.noinc1:	sra	h
		rr	l
		jr	nc,.noinc2
		inc	hl
.noinc2:
neghlshr3:	sra	h
		rr	l
		jr	nc,.noinc3
		inc	hl
.noinc3:	sra	h
		rr	l
		jr	nc,.noinc4
		inc	hl
.noinc4:	sra	h
		rr	l
		ret	nc
		inc	hl
		ret
poshlshr5:	sra	h
		rr	l
		sra	h
		rr	l
poshlshr3:	sra	h
		rr	l
		sra	h
		rr	l
		sra	h
		rr	l
		ret

bcshr1:		bit	7,b
		jr	z,posbcshr1
		jr	negbcshr1
bcshr2:		bit	7,b
		jr	z,posbcshr2
		jr	negbcshr2
bcshr5:		bit	7,b
		jr	z,posbcshr5
		sra	b
		rr	c
		jr	nc,.noinc1
		inc	bc
.noinc1:	sra	b
		rr	c
		jr	nc,.noinc2
		inc	bc
.noinc2:	sra	b
		rr	c
		jr	nc,.noinc3
		inc	bc
.noinc3:
negbcshr2:	sra	b
		rr	c
		jr	nc,.noinc4
		inc	bc
.noinc4:
negbcshr1:	sra	b
		rr	c
		ret	nc
		inc	bc
		ret
posbcshr5:	sra	b
		rr	c
		sra	b
		rr	c
		sra	b
		rr	c
posbcshr2:	sra	b
		rr	c
posbcshr1:	sra	b
		rr	c
		ret

deshr1:		bit	7,d
		jr	z,posdeshr1
		jr	negdeshr1
deshr2:		bit	7,d
		jr	z,posdeshr2
		sra	d
		rr	e
		jr	nc,.noinc1
		inc	de
.noinc1:
negdeshr1:	sra	d
		rr	e
		ret	nc
		inc	de
		ret
posdeshr2:	sra	d
		rr	e
posdeshr1:	sra	d
		rr	e
		ret

hlshr2:		bit	7,h
		jr	z,poshlshr2
		sra	h
		rr	l
		jr	nc,.noinc1
		inc	hl
.noinc1:	sra	h
		rr	l
		ret	nc
		inc	hl
		ret

poshlshr2:	sra	h
		rr	l
		sra	h
		rr	l
		ret

board1hitflipper::
		ld	hl,pin_flags
		ldh	a,[pin_x]
		sub	255&CFLIPPERX12
		ldh	a,[pin_x+1]
		sbc	CFLIPPERX12>>8
		jr	c,.lefts
		ldh	a,[pin_rflipperdlt]
		dec	a
		ret	nz
		set	PINFLG_RIGHT,[hl]
		ldh	a,[pin_rflipper]
		ld	hl,rflipperdeltas
		ld	bc,RFLIPPERX
		ld	de,FLIPPERY
		jp	dohitflipper

.lefts:		ldh	a,[pin_lflipperdlt]
		dec	a
		ret	nz
		res	PINFLG_RIGHT,[hl]
		ldh	a,[pin_y]
		sub	255&CFLIPPERY34
		ldh	a,[pin_y+1]
		sbc	CFLIPPERY34>>8
		jr	c,.left3
		ldh	a,[pin_y]
		sub	255&CFLIPPERY14
		ldh	a,[pin_y+1]
		sbc	CFLIPPERY14>>8
		jr	c,.left4
		ldh	a,[pin_lflipper]
		ld	hl,lflipperdeltas
		ld	bc,LFLIPPERX
		ld	de,FLIPPERY
		jp	dohitflipper
.left3:		ldh	a,[pin_lflipper]
		ld	hl,lflipper3deltas
		ld	bc,FLIPPERX3
		ld	de,FLIPPERY3
		jp	dohitflipper
.left4:		ldh	a,[pin_lflipper]
		ld	hl,lflipper4deltas
		ld	bc,FLIPPERX4
		ld	de,FLIPPERY4
		jp	dohitflipper


board2hitflipper::
		ld	hl,pin_flags
		ldh	a,[pin_x]
		sub	255&FLIPPERCX12B2
		ldh	a,[pin_x+1]
		sbc	FLIPPERCX12B2>>8
		jr	nc,.rights
		ldh	a,[pin_lflipperdlt]
		dec	a
		ret	nz
		res	PINFLG_RIGHT,[hl]
		ldh	a,[pin_lflipper]
		ld	hl,flipper1b2deltas
		ld	bc,FLIPPERX1B2
		ld	de,FLIPPERYB2
		jp	dohitflipper
.rights:	ldh	a,[pin_rflipperdlt]
		dec	a
		ret	nz
		set	PINFLG_RIGHT,[hl]
		ldh	a,[pin_y]
		sub	255&FLIPPERCY23B2
		ldh	a,[pin_y+1]
		sbc	FLIPPERCY23B2>>8
		jr	c,.right3
		ldh	a,[pin_rflipper]
		ld	hl,flipper2b2deltas
		ld	bc,FLIPPERX2B2
		ld	de,FLIPPERYB2
		jp	dohitflipper
.right3:	ldh	a,[pin_lflipper]
		ld	hl,flipper3b2deltas
		ld	bc,FLIPPERX3B2
		ld	de,FLIPPERY3B2
		jp	dohitflipperstrong

dohitflipperstrong:
		ldh	[hTmp3Lo],a	;flipper position
		add	a
		add	l
		ld	l,a
		jr	nc,.noinch
		inc	h
.noinch:
		ld	a,3
		jr	dohitflipperboth

dohitflipper::
		ldh	[hTmp3Lo],a	;flipper position
		add	a
		add	l
		ld	l,a
		jr	nc,.noinch
		inc	h
.noinch:
		ld	a,-2
dohitflipperboth:
		ldh	[hTmpLo],a	;weaken amount
		ldh	a,[pin_x]
		sub	c
		ld	c,a
		ldh	a,[pin_x+1]
		sbc	b
		ld	b,a
		ldh	a,[pin_y]
		sub	e
		ld	e,a
		ldh	a,[pin_y+1]
		sbc	d
		ld	d,a
		push	bc
		push	de
		push	hl

		ld	a,[hli]
		ld	l,[hl]
		ld	h,a
		call	bcshr5
		ld	a,l
		push	hl
		call	bcmula
		ld	b,d
		ld	c,e
		ld	d,h
		ld	e,l
		call	bcshr5
		pop	af
		call	bcmula
		ld	a,l
		sub	e
		ld	l,a
		ld	a,h
		sbc	d
		ld	h,a
		ldh	a,[pin_flags]
		bit	PINFLG_RIGHT,a
		call	z,neghl
		ld	a,l
		sub	255&FLIPPERWIDTH
		ld	a,h
		sbc	FLIPPERWIDTH>>8

		pop	hl
		pop	de
		pop	bc
		ret	nc


		ld	a,[hli]
		ld	h,[hl]
		push	hl
		call	bcmula
		pop	af
		ld	b,d
		ld	c,e
		ld	d,h
		ld	e,l
		call	bcmula
		add	hl,de
		call	hlshr5
		call	hlshr3
		ld	a,h
		add	a
		ret	c
		ld	a,l
		sra	a
		sra	a
		add	9
		ld	d,22
		cp	d
		jr	nc,.dok
		ld	d,a
.dok:
		ldh	a,[hTmpLo]	;weaken amount
		add	d
		ld	d,a

		ldh	a,[pin_cos]	;cos
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok1
		dec	b
.bok1:		ld	a,d
		call	bcmula
		call	hlshr2
		ld	a,l
		ldh	[pin_xfliplo],a	;flipper xvel low
		ld	a,h
		ldh	[pin_xfliphi],a	;flipper xvel high
		ldh	a,[pin_vx]
		sub	l
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		sbc	h
		ldh	[pin_vx+1],a

		ldh	a,[pin_sin]	;sin
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok2
		dec	b
.bok2:
		ld	a,d
		call	bcmula
		call	hlshr2
		ld	a,l
		ldh	[pin_yfliplo],a	;flipper yvel low
		ld	a,h
		ldh	[pin_yfliphi],a	;flipper yvel high
		ldh	a,[pin_vy]
		sub	l
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		sbc	h
		ldh	[pin_vy+1],a
		ld	hl,pin_flags
		set	PINFLG_FLIPPED,[hl]
		ret

hitbumper:
		ld	a,l
		sub	255&(-BUMPERACTIVATE)
		ld	a,h
		sbc	(-BUMPERACTIVATE)>>8
		ld	hl,pin_flags2
		jr	nc,.weak
		set	PINFLG2_HARD,[hl]
		jr	.hard
.weak:		res	PINFLG2_HARD,[hl]
.hard:		ld	hl,wPinJmpHitBumper
		call	LongVector

		ldh	a,[pin_flags2]
		bit	PINFLG2_HARD,a
		ret	z
;		ld	a,FX_BUMPER
;		call	InitSfx
.bad1:		call	random
		and	7
		jr	z,.bad1
		sub	4
		ld	l,a
		ldh	a,[pin_cos]	;cos
		add	l
		ld	l,a
		ld	h,0
		add	a
		jr	nc,.hok1
		dec	h
.hok1:
		ld	d,h
		ld	e,l
		add	hl,hl
		add	hl,de
		add	hl,hl
		add	hl,de
		call	hlshr3
		ldh	a,[pin_vx]
		add	l
		ldh	[pin_vx],a
		ldh	a,[pin_vx+1]
		adc	h
		ldh	[pin_vx+1],a

.bad2:		call	random
		and	7
		jr	z,.bad2
		sub	4
		ld	l,a
		ldh	a,[pin_sin]	;sin
		add	l
		ld	l,a
		ld	h,0
		add	a
		jr	nc,.hok2
		dec	h
.hok2:
		ld	d,h
		ld	e,l
		add	hl,hl
		add	hl,de
		add	hl,hl
		add	hl,de
		call	hlshr3
		ldh	a,[pin_vy]
		add	l
		ldh	[pin_vy],a
		ldh	a,[pin_vy+1]
		adc	h
		ldh	[pin_vy+1],a

		ret


pinview:
		ld	bc,0
		ld	hl,wBalls+BALL_FLAGS
.findmaxy:	bit	BALLFLG_USED,[hl]
		jr	z,.notusedy
		ld	d,l
		ld	a,l
		add	BALL_Y-BALL_FLAGS
		ld	l,a
		ld	a,[hli]
		ld	e,a
		ld	a,c
		sub	e
		ld	a,[hl]
		ld	l,d
		ld	d,a
		ld	a,b
		sbc	d
		jr	nc,.smallery
		ld	b,d
		ld	c,e
.smallery:
.notusedy:	ld	a,l
		add	BALLSIZE
		ld	l,a
		cp	LOW(wBalls)+BALLSIZE*MAXBALLS
		jr	c,.findmaxy

		push	bc

		ld	bc,0
		ld	hl,wBalls+BALL_FLAGS
.findmaxx:	bit	BALLFLG_USED,[hl]
		jr	z,.notusedx
		ld	d,l
		ld	a,l
		add	BALL_X-BALL_FLAGS
		ld	l,a
		ld	a,[hli]
		ld	e,a
		ld	a,c
		sub	e
		ld	a,[hl]
		ld	l,d
		ld	d,a
		ld	a,b
		sbc	d
		jr	nc,.smallerx
		ld	b,d
		ld	c,e
.smallerx:
.notusedx:	ld	a,l
		add	BALLSIZE
		ld	l,a
		cp	LOW(wBalls)+BALLSIZE*MAXBALLS
		jr	c,.findmaxx

		pop	hl
		ld	d,b
		ld	e,c
		ld	a,d
		sub	20
		ld	d,a
		jr	nc,.deok
		ld	de,0
.deok:
		ld	a,h
		or	l
		jr	nz,.hlok3
		ld	h,50
		jr	.hlok
.hlok3:
		call	CountBalls
		cp	2
		ld	b,4
		jr	c,.bok
;		ld	b,12	;MARIO CLUB doesn't want this.
.bok:		ld	a,h
		sub	b
		ld	h,a
		jr	nc,.hlok
		ld	hl,0
.hlok:

		inc	d

		ld	a,[wMapYSize]
		sub	21
		ld	b,a
		ld	c,0
		ld	a,c
		sub	l
		ld	a,b
		sbc	h
		jr	nc,.hlok2
		ld	h,b
		ld	l,c
.hlok2:

		ret



pin_setup:

		ld	a,255
		ldio	[rLYC],a
		di
		SETVBL	VblNormal
		ei

		call	InitGroups
		ld	hl,PAL_BALL
		call	AddPalette
		ld	hl,PAL_WHITEPEARL
		call	Palette7

		xor	a
		ldh	[pin_textpal],a

		call	setupboard

		ld	a,%11100111
		ldh	[hVblLCDC],a
		ld	a,7
		ldio	[rWX],a
		ld	a,PANELSTART
		ldio	[rWY],a
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,IDX_DIGITSCHR
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c810
		ld	de,$9580
		ld	c,40
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a

		ld	de,$c800
		ld	c,20
		ldh	a,[pin_textpal]
		or	$88
		ld	h,a
		ld	l,$58
.panel:		ld	a,l
		res	5,e
		ld	[de],a
		ld	a,h
		set	5,e
		ld	[de],a
		inc	e
		inc	l
		dec	c
		jr	nz,.panel
		ld	hl,$c800
		ld	de,$9c00
		ld	c,2
		call	DumpChrs
		ld	a,1
		ldh	[hVidBank],a
		ldio	[rVBK],a
		ld	hl,$c820
		ld	de,$9c00
		ld	c,2
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		ldio	[rVBK],a


		call	pinview
		call	NewInitScroll
		ld	hl,pin_flags
		res	PINFLG_FIRST,[hl]

		ld	hl,wPinJmpScore
		call	LongVector

		ret


setupboard:
		ldh	a,[pin_board]
		bit	7,a
		jr	z,.notfirst
		res	7,a
		ldh	[pin_board],a
		call	firstsetup
.notfirst:	ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		jp	z,mainboardinit_b
		cp	SUBGAME_CAVE
		jp	z,SoulInit_b
		cp	SUBGAME_ICECAVE
		jp	z,IceInit_b
		cp	SUBGAME_SCUTTLE
		jp	z,ScuttleInit_b
		cp	SUBGAME_SHIP
		jp	z,ShipInit_b
		cp	SUBGAME_TABLE2
		jp	z,board2init_b
		cp	SUBGAME_FLOUNDER
		jp	z,flounderinit_b
		cp	SUBGAME_FLOTSAM
		jp	z,flotsaminit_b
		cp	SUBGAME_KISS
		jp	z,kissinit_b
		cp	SUBGAME_URSULA
		jp	z,ursulainit_b
		cp	SUBGAME_TREASURE
		jp	z,TresInit_b
		cp	SUBGAME_VOLCANO
		jp	z,VolcInit_b
		cp	SUBGAME_TRIDENT
		jp	z,TridentInit_b
		cp	SUBGAME_PRISON
		jp	z,PrisonInit_b
		cp	SUBGAME_DASH
		jp	z,DashInit_b
		cp	SUBGAME_MORGANA
		jp	z,MorganaInit_b
		cp	SUBGAME_BEAR
		jp	z,BearInit_b
		cp	SUBGAME_CLOAK
		jp	z,CloakInit_b
		ret
firstsetup:	ldh	a,[pin_board]
		cp	SUBGAME_TABLE1
		jr	nz,.notfirstmain
		call	mainboardfirst_b
		jr	.dup
.notfirstmain:	cp	SUBGAME_TABLE2
		jr	nz,.notsecondmain
		call	board2first_b
		jr	.dup
.notsecondmain:	ret
.dup:		call	SetDifficulty
		ld	a,1
		call	SavePlayer
		ld	a,2
		call	SavePlayer
		ld	a,3
		call	SavePlayer
		ld	hl,any_ballsleft
		dec	[hl]
		ld	a,1
		ld	[any_wantfire],a
		ret


pin_shutdown:
		call	FadeOut
		jp	SprOff

tilts:		ld	hl,pin_rtilt
		ld	de,rtilts
		ld	a,[wJoy1Hit]
		bit	JOY_R,a
		jr	nz,.right
		bit	JOY_D,a
.right:		call	dotilt
		ld	hl,pin_ltilt
		ld	de,ltilts
		ld	a,[wJoy1Hit]
		bit	JOY_B,a
		call	dotilt
		ld	hl,pin_utilt
		ld	de,utilts
		ld	a,[wJoy1Hit]
		bit	JOY_U,a
dotilt:		jr	z,.nochange
		ld	a,[hl]
		or	a
		jr	nz,.nochange
		inc	[hl]
.nochange:	ld	a,[hl]
		or	a
		ret	z
		inc	[hl]
		dec	a
		add	a
		add	e
		ld	e,a
		jr	nc,.noincd
		inc	d
.noincd:	ld	a,[de]
		ld	b,a
		inc	de
		ld	a,[de]
		ld	c,a
		or	b
		jr	nz,.noend
		ld	[hl],0
		ret
.noend:		ldh	a,[pin_xpush]
		add	b
		ldh	[pin_xpush],a
		ldh	a,[pin_ypush]
		add	c
		ldh	[pin_ypush],a
		ret
rtilts:		db	-32,0
		db	-64,0
		db	-96,0
		db	-64,0
		db	-32,0
		db	0,0
ltilts:		db	32,0
		db	64,0
		db	96,0
		db	64,0
		db	32,0
		db	0,0
utilts:		db	0,32
		db	0,64
		db	0,96
		db	0,64
		db	0,32
		db	0,0


negbc:		ld	a,c
		cpl
		ld	c,a
		ld	a,b
		cpl
		ld	b,a
		inc	bc
		ret
negde:		ld	a,e
		cpl
		ld	e,a
		ld	a,d
		cpl
		ld	d,a
		inc	de
		ret


sqrtab:		dw	0,1,4,9,16,25,36,49,64,81,100
		dw	121,144,169,196,225,256,289,324,361,400
		dw	441,484,529,576,625,676,729,784,841,900
		dw	961,1024


ballcollisions:

		ld	de,wBalls
		ld	a,[de]
		bit	BALLFLG_USED,a
		jr	z,.no1213
		ld	a,[wBalls+BALL_BALLPAUSE]
		or	a
		jr	nz,.no1213
		ld	a,[wBalls+BALLSIZE+BALL_BALLPAUSE]
		or	a
		jr	nz,.no12
		ld	hl,wBalls+BALLSIZE
		bit	BALLFLG_USED,[hl]
		call	nz,ballcollision
.no12:
		ld	a,[wBalls+BALLSIZE*2+BALL_BALLPAUSE]
		or	a
		jr	nz,.no13
		ld	de,wBalls
		ld	hl,wBalls+BALLSIZE*2
		bit	BALLFLG_USED,[hl]
		call	nz,ballcollision
.no13:
.no1213:	ld	hl,wBalls+BALLSIZE
		bit	BALLFLG_USED,[hl]
		ret	z
		ld	a,[wBalls+BALLSIZE+BALL_BALLPAUSE]
		or	a
		ret	nz
		ld	de,wBalls+BALLSIZE*2
		ld	a,[de]
		bit	BALLFLG_USED,a
		ret	z
		ld	a,[wBalls+BALLSIZE*2+BALL_BALLPAUSE]
		or	a
		ret	nz
		jp	ballcollision


DIAMETER	EQU	11<<5
ballpushvals:
		dw	(DIAMETER-$20)*(DIAMETER-$20)/4
		dw	(DIAMETER-$40)*(DIAMETER-$40)/4
		dw	(DIAMETER-$60)*(DIAMETER-$60)/4
		dw	(DIAMETER-$80)*(DIAMETER-$80)/4
		dw	(DIAMETER-$a0)*(DIAMETER-$a0)/4
		dw	(DIAMETER-$c0)*(DIAMETER-$c0)/4
		dw	(DIAMETER-$e0)*(DIAMETER-$e0)/4
		dw	0


;de=ball struct
;hl=ball struct
;see if they collide
ballcollision:
		ld	a,[de]
		xor	[hl]
		bit	BALLFLG_LAYER,a
		ret	nz
		inc	e
		inc	l
		ld	a,[de]
		ld	c,a
		inc	e
		ld	a,[de]
		ld	b,a
		inc	e
		push	de
		inc	e
		inc	e
		ld	a,[hli]
		sub	c
		ld	c,a
		ld	a,[hli]
		sbc	b
		ld	b,a
		push	hl
		inc	l
		inc	l
		push	bc	;dx
		add	a
		call	c,negbc
		ld	a,c
		sub	255&DIAMETER
		ld	a,b
		sbc	DIAMETER>>8
		jr	c,.insidexbox
		pop	bc
		pop	bc
		pop	bc
		ret
.insidexbox:
		ld	a,c
		ldh	[hTmp2Lo],a
		ld	a,b
		ldh	[hTmp2Hi],a
		ld	a,[de]
		ld	c,a
		inc	e
		ld	a,[de]
		ld	b,a
		dec	e
		ld	a,[hli]
		sub	c
		ld	c,a
		ld	a,[hld]
		sbc	b
		ld	b,a
		push	bc	;dy
		add	a
		call	c,negbc
		ld	a,c
		sub	255&DIAMETER
		ld	a,b
		sbc	DIAMETER>>8
		jr	c,.insideybox
.outsidecircle:	pop	bc
		pop	bc
		pop	bc
		pop	bc
		ret
.insideybox:	
		srl	b
		rr	c
		ld	d,b
		ld	e,c
		call	mulbcdetohl
		push	hl
		ldh	a,[hTmp2Lo]
		ld	c,a
		ldh	a,[hTmp2Hi]
		ld	b,a
		srl	b
		rr	c
		ld	d,b
		ld	e,c
		call	mulbcdetohl
		pop	de
		add	hl,de
		jr	c,.outsidecircle
		ld	a,l
		ldh	[hTmp2Lo],a
		sub	255&(DIAMETER*DIAMETER/4)
		ld	a,h
		ldh	[hTmp2Hi],a
;hTmp2 contains d^2 / 4
		sbc	(DIAMETER*DIAMETER/4)>>8
		jr	nc,.outsidecircle
		pop	bc	;dy
		pop	de	;dx
		call	normalize
		ld	a,d
		ldh	[pin_cos],a	;cos
		ld	a,e
		ldh	[pin_sin],a	;sin

		pop	hl
		pop	de

		push	de
		push	hl

		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	a,[de]
		inc	e
		sub	c
		ld	c,a
		ld	a,[de]
		sbc	b
		ld	b,a	;bc=v2x-v1x
		inc	e
		inc	e
		inc	e
		inc	l
		inc	l
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		ld	a,[de]
		inc	e
		sub	l
		ld	l,a
		ld	a,[de]
		sbc	h
		ld	e,l
		ld	d,a	;de=v2y-v1y;
		ldh	a,[pin_cos]	;cos
		call	bcmula
		ld	b,d
		ld	c,e
		ld	d,h
		ld	e,l
		ldh	a,[pin_sin]	;sin
		call	bcmula
		add	hl,de
		call	hlshr5
		ld	b,h
		ld	c,l
		pop	hl
		pop	de
		ld	a,b
		add	a
		jr	c,.departing
		ldh	a,[pin_cos]	;cos
		push	bc
		push	hl
		call	bcmula
		call	hlshr5
		ld	b,h
		ld	c,l
		pop	hl
		ld	a,[de]
		sub	c
		ld	[de],a
		inc	e
		ld	a,[de]
		sbc	b
		ld	[de],a
		inc	e
		inc	e
		inc	e
		ld	a,[hl]
		add	c
		ld	[hli],a
		ld	a,[hl]
		adc	b
		ld	[hli],a
		inc	l
		inc	l
		pop	bc
		ldh	a,[pin_sin]	;sin
		push	hl
		call	bcmula
		call	hlshr5
		ld	b,h
		ld	c,l
		pop	hl

		ld	a,[de]
		sub	c
		ld	[de],a
		inc	e
		ld	a,[de]
		sbc	b
		ld	[de],a
		dec	e
		ld	a,[hl]
		add	c
		ld	[hli],a
		ld	a,[hl]
		adc	b
		ld	[hld],a
		dec	e
		dec	e
		dec	e
		dec	e
		dec	l
		dec	l
		dec	l
		dec	l
.departing:	dec	e
		dec	e
		dec	l
		dec	l
		push	de
		push	hl
		ld	hl,ballpushvals
		ldh	a,[hTmp2Lo]
		ld	e,a
		ldh	a,[hTmp2Hi]
		ld	d,a
		ld	c,0
.pushcount:	inc	c
		ld	a,e
		sub	[hl]
		inc	l
		ld	a,d
		sbc	[hl]
		inc	l
		jr	c,.pushcount
		pop	hl
		pop	de
		ld	a,c
		ldh	[hTmp2Lo],a
		ldh	[hTmp2Hi],a
		ldh	a,[pin_cos],a	;cos
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok1
		dec	b
.bok1:		call	bcshr1
.pushlpx:	ld	a,[de]
		sub	c
		ld	[de],a
		inc	e
		ld	a,[de]
		sbc	b
		ld	[de],a
		dec	e
		ld	a,[hl]
		add	c
		ld	[hli],a
		ld	a,[hl]
		adc	b
		ld	[hld],a
		ldh	a,[hTmp2Lo]
		dec	a
		ldh	[hTmp2Lo],a
		jr	nz,.pushlpx
		inc	e
		inc	e
		inc	e
		inc	e
		inc	l
		inc	l
		inc	l
		inc	l
		ldh	a,[pin_sin]	;sin
		ld	c,a
		ld	b,0
		add	a
		jr	nc,.bok2
		dec	b
.bok2:		call	bcshr1
.pushlpy:	ld	a,[de]
		sub	c
		ld	[de],a
		inc	e
		ld	a,[de]
		sbc	b
		ld	[de],a
		dec	e
		ld	a,[hl]
		add	c
		ld	[hli],a
		ld	a,[hl]
		adc	b
		ld	[hld],a
		ldh	a,[hTmp2Hi]
		dec	a
		ldh	[hTmp2Hi],a
		jr	nz,.pushlpy

		ret


mulbcdetohl:	ld	hl,0
.mullp:		srl	b
		rr	c
		jr	nc,.noadd
		add	hl,de
.noadd:		sla	e
		rl	d
		ld	a,b
		or	c
		jr	nz,.mullp
		ret



;de=dx (signed)
;bc=dy (signed)
;return de=dx,dy normalized so that vector magnitude is 32.
normalize:	ld	hl,hTmpLo
		ld	[hl],0
		bit	7,d
		jr	z,.dxpos
		set	0,[hl]
		call	negde
.dxpos:		bit	7,b
		jr	z,.dypos
		set	1,[hl]
		call	negbc
.dypos:		jr	.shiftenter
.shiftlp:	sra	b
		rr	c
		sra	d
		rr	e
.shiftenter:	ld	a,b
		or	d
		jr	nz,.shiftlp
		ld	a,c
		or	e
		add	a
		jr	c,.shiftlp
		ld	b,e	;bc=xy of outside point
		ld	h,d	;hl=xy of inside point
		ld	l,d
.loop:		ld	a,b
		add	h
		sra	a
		ld	d,a
		ld	a,c
		add	l
		sra	a
		ld	e,a
		cp	c
		jr	nz,.diff1
		ld	a,d
		cp	b
		jr	z,.signs
.diff1:		ld	a,e
		cp	l
		jr	nz,.diff2
		ld	a,d
		cp	h
		jr	z,.signs
.diff2:		ld	a,d
		cp	$21
		jr	nc,.outside
		ld	a,e
		cp	$21
		jr	nc,.outside
		push	hl
		push	de
		ld	a,e
		add	a
		add	LOW(sqrtab)
		ld	l,a
		ld	a,0
		adc	HIGH(sqrtab)
		ld	h,a
		ld	a,[hli]
		ld	e,a
		ld	a,d
		ld	d,[hl]
		add	a
		add	LOW(sqrtab)
		ld	l,a
		ld	a,0
		adc	HIGH(sqrtab)
		ld	h,a
		ld	a,[hli]
		add	e
		ld	e,a
		ld	a,[hl]
		adc	d
		ld	d,a
		sub	4
		pop	de
		pop	hl
		jr	c,.inside
.outside:	ld	b,d
		ld	c,e
		jr	.loop
.inside:	ld	h,d
		ld	l,e
		jr	.loop
.signs:		ld	hl,hTmpLo
		bit	0,[hl]
		jr	z,.xpos
		ld	a,d
		cpl
		inc	a
		ld	d,a
.xpos:		bit	1,[hl]
		jr	z,.ypos
		ld	a,e
		cpl
		inc	a
		ld	e,a
.ypos:		ret


;de=x
;bc=y
;find tile byte

pinbyte:	ldh	a,[pin_ballflags]
		bit	BALLFLG_LAYER,a
		ld	a,WRKBANK_PINMAP1
		jr	z,.layerok
		inc	a
.layerok:	ldh	[hWrkBank],a
		ldio	[rSVBK],a

		ld	l,b
		ld	h,0
		ld	b,e
		ld	a,d
		ld	e,l
		ld	d,h
		add	hl,hl
		add	hl,de
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	e,a
		add	hl,de
		add	hl,hl
		ld	de,$d000
		add	hl,de
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		xor	a
		ldh	[hWrkBank],a
		ldio	[rSVBK],a
		ld	a,b
		rlca
		rlca
		rlca
		and	7
		ld	e,a
		ld	a,c
		rrca
		rrca
		and	$38
		or	e
		ld	e,a
		jp	FetchPinInfo


;337,344,350,356,3,10,16,23,29
flipper1b2deltas:
sublflipperdeltas:
lflipperdeltas:
		db	29,12
		db	30,8
		db	31,5
		db	31,2
		db	31,-1
		db	31,-5
		db	30,-8
		db	29,-12
		db	27,-15

;200,195,189,181,175,169,163,156,151
flipper2b2deltas:
subrflipperdeltas:
rflipperdeltas:
		db	-30,10
		db	-30,8
		db	-31,5
		db	-31,0
		db	-31,-2
		db	-31,-6
		db	-30,-9
		db	-29,-13
		db	-27,-15

;300,306,312,318,324,331,336,342,349
lflipper3deltas:
		db	15,27
		db	18,25
		db	21,23
		db	23,21
		db	25,18
		db	27,15
		db	29,13
		db	30,9
		db	31,6

flipper3b2deltas:
;		db	-15,27
		db	-18,25
		db	-21,23
		db	-23,21
		db	-25,18
		db	-27,15
		db	-29,13
		db	-30,9
		db	-31,6
		db	-32,0

;280,286,294,299,306,311,317,323,331
lflipper4deltas:
		db	5,31
		db	8,30
		db	13,29
		db	15,27
		db	18,25
		db	20,24
		db	23,21
		db	25,19
		db	27,15


statusprocess:
		ld	bc,MAXMESSAGES
		ld	hl,any_messagelist
		ld	de,3
.declp:		ld	a,[hl]
		or	a
		jr	z,.notactive
		set	7,b
		inc	b
		dec	[hl]
		jr	nz,.notactive
		dec	b
.notactive:	add	hl,de
		dec	c
		jr	nz,.declp
		ld	a,b
		cp	$80
		jr	z,.forcescore
		ld	a,[any_messagecnt]
		ld	e,a
		ld	d,0
		ld	c,MAXMESSAGES
.next:		ld	a,e
		add	3
		cp	MAXMESSAGES*3
		jr	c,.aok
		xor	a
.aok:		ld	e,a
		ld	hl,any_messagelist
		add	hl,de
		ld	a,[hl]
		or	a
		jr	nz,.found
		dec	c
		jr	nz,.next
		jr	.checkscore
.found:		ld	a,e
		ld	[any_messagecnt],a
		inc	l
		ld	e,[hl]
		inc	l
		ld	d,[hl]
		jp	statusde
.checkscore:	ldh	a,[pin_flags]
		bit	PINFLG_SCORE,a
		ret	z
.forcescore:	ldh	a,[pin_flags]
		res	PINFLG_SCORE,a
		ldh	[pin_flags],a
		ld	hl,wPinJmpScore
		jp	LongVector

SubHitFlipper::
		ld	hl,pin_flags
		ldh	a,[pin_x]
		sub	255&B2CENTERX
		ldh	a,[pin_x+1]
		sbc	B2CENTERX>>8
		jr	c,.left2
.right2:	ldh	a,[pin_rflipperdlt]
		dec	a
		ret	nz
		set	PINFLG_RIGHT,[hl]
		ldh	a,[pin_rflipper]
		ld	hl,subrflipperdeltas
		ld	bc,RB2FLIPPERX
		ld	de,B2FLIPPERY
		jp	dohitflipper
.left2:		ldh	a,[pin_lflipperdlt]
		dec	a
		ret	nz
		res	PINFLG_RIGHT,[hl]
		ldh	a,[pin_lflipper]
		ld	hl,sublflipperdeltas
		ld	bc,LB2FLIPPERX
		ld	de,B2FLIPPERY
		jp	dohitflipper

pin_end::
