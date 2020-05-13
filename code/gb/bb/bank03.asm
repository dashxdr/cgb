

		INCLUDE	"equates.equ"

;		SECTION	"gamebank03",DATA[$4000],BANK[3]
		section 3

SHOWCOPYRIGHT	EQU	1	;enable/disable copyright and intro stuff

NUMSTORYBOARDS	EQU	3
NUMMULTIBOARDS	EQU	3

MAXTUNE		EQU	18
MAXSFX		EQU	0 ;80 = actual value, 0 is for nitpicking Nintendo buggers.

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


BANK03_1ST::

		incbin	"res/filesys.b03"


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

LINEDOWN	EQU	24+4
YSPACE		EQU	10
TOPTITLE	EQU	13

SFX_ILLEGAL	EQU	19

NUMGAMES	EQU	10	;# of subgames in practice mode

		INTERFACE Kiss
		INTERFACE Fire
		INTERFACE sultan
		INTERFACE chip
		INTERFACE TargetRange
		INTERFACE BelleRide
		INTERFACE BoardGame
		INTERFACE Whack
		INTERFACE Chopper
		INTERFACE Concentration
		INTERFACE Stove
		INTERFACE Spit
		INTERFACE Cellar
		INTERFACE Dance
		INTERFACE ClrRect18
		INTERFACE DmaBitbox20x18
		INTERFACE Disney
		INTERFACE StoryGame
		INTERFACE TriviaGame

loadbg::
		ld	hl,$c800

		ld	a,[hli]
		ld	b,a
		ld	a,[hli]
		ld	c,a
		push	bc
		ld	a,[hli]
		ld	c,a
		ld	a,[hli]
		ld	b,a
		ld	l,$10
		ld	de,$9800
		ld	a,$80
		sub	c
		ldh	[hTmpLo],a	;add for map later on
		push	hl
		ld	a,c
		swap	a
		ld	l,a
		and	$0f
		ld	h,a
		xor	l
		ld	l,a
		ld	a,e
		sub	l
		ld	e,a
		ld	a,d
		sbc	h
		ld	d,a
		pop	hl	;de=$9800-(# of chars<<4)
.dclp:		ld	a,c
		sub	$80
		ld	a,b
		sbc	0
		jr	c,.dclast
		push	bc
		ld	c,$80
		call	DumpChrs
		pop	bc
		ld	a,c
		sub	$80
		ld	c,a
		ld	a,b
		sbc	0
		ld	b,a
		jr	.dclp
.dclast:	call	DumpChrs

		pop	bc

		ld	de,$cc00
		xor	a
		call	copymap

		LDH	A,[hMachine]
		CP	MACHINE_CGB
		jr	nz,.nocolor
		push	bc
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		push	hl
		ld	hl,$cc00
		ld	de,$9800
		ld	c,$40
		call	DumpChrs
		pop	hl
		ld	de,$c800
		ld	bc,$40
		call	MemCopy
		push	hl

		LD	A,WRKBANK_PAL		;Page in the palettes.
		LDH	[hWrkBank],A		;
		LDIO	[rSVBK],A		;

		ld	hl,$c800
		LD	DE,wBcpArcade		;
		ld	bc,64
		call	MemCopy
		LD	A,WRKBANK_NRM
		LDH	[hWrkBank],A		;bank.
		ldio	[rSVBK],a

		xor	a
		LDH	[hVidBank],A
		LDIO	[rVBK],A

		pop	hl
		pop	bc
		jr	.hadcolor
.nocolor:	ld	de,64
		add	hl,de			;skip palette
.hadcolor:
		ld	de,$c800
		ldh	a,[hTmpLo]
		call	copymap

		ld	hl,$c800
		ld	de,$9800
		ld	c,$40
		call	DumpChrs
		ret

copymap:
		push	af
		ld	a,c
		ldh	[hTmp2Lo],a
		pop	af
		push	bc
		ld	c,a
.cy:		push	bc
		push	de
.cx:		ld	a,[hli]
		add	c
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.cx
		pop	de
		pop	bc
		ld	a,e
		add	$20
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ldh	a,[hTmp2Lo]
		dec	a
		ldh	[hTmp2Lo],a
		jr	nz,.cy
		pop	bc
		ret


NAMECOPY	EQU	$df00

show1:		call	BgInFileSys
		call	FadeIn
		ld	b,90
.wait:		push	bc
		call	WaitForVBL
		call	ReadJoypad
		pop	bc
		ld	a,[wJoy1Cur]
		or	a
		jr	nz,.exit
		dec	b
		jr	nz,.wait
.exit:		jp	FadeOut



;****************************************************************
;****************************************************************
;****************************************************************
;*                                                              *
;*   Shell stuff using John's text & bitmap routines            *
;*                                                              *
;****************************************************************
;****************************************************************
;****************************************************************

STRTEMP		EQUS	"wOamShadow"

SELDIM		EQU	1
SELBRIGHT	EQU	0

SELDIM2		EQU	1
SELBRIGHT2	EQU	0


sel_which	EQUS	"hTemp48+00"
sel_high	EQUS	"hTemp48+01"
sel_count	EQUS	"hTemp48+02"
sel_timelo	EQUS	"hTemp48+03"
sel_timehi	EQUS	"hTemp48+04"
sel_story	EQUS	"hTemp48+05"
sel_multi	EQUS	"hTemp48+06"
sel_boards	EQUS	"hTemp48+07"
sel_type	EQUS	"hTemp48+08"

shutdownbitmap:	call	FadeOutBlack
		di
		SETLYC	LycNormal
		SETVBL	VblNormal
		ld	a,255
		ldio	[rLYC],a
		ei
		ret



redointros:	call	shutdownbitmap
		jp	AbortGame

shell1fade:	call	shutdownbitmap
shell1:		call	SelectSetup
		call	LoadBackup
		ld	a,[wWhichGame]
		or	a
		jr	z,shell1loop
.askagain:	call	ReloadGame
		or	a
		jr	z,.continue
		call	QuitVerify
		or	a
		jr	nz,.killit
		jr	.askagain
.continue:	ld	a,[wWhichGame]
		cp	BACKUP_STORY
		jp	z,restartstory
		cp	BACKUP_BOARD
		jp	z,restartboard
.killit:	xor	a
		ld	[wWhichGame],a
		call	SaveBackup
shell1loop:	call	GameSelect
		cp	255
		jp	z,redointros
		or	a
		jr	z,.story
		dec	a
		jp	z,manyplayers
		dec	a
		jr	z,practice
		dec	a
		jp	z,challenge
		jr	.testmenu
.back:		call	FadeOut
		call	SelectSetup
.story:
		call	StorySelect
		cp	255
		jr	z,shell1loop
		ld	[wSubLevel],a

		xor	a
		call	BoardSelect
		cp	255
		jr	z,.back
		ld	[wBoardMap],a

		call	shutdownbitmap
		call	StoryGame_b
		jr	shell1

.testmenu:	call	OptionsMenu
		jr	shell1loop

practice:
		call	shutdownbitmap
		xor	a
		ld	[wSelected],a
practicelp:
		call	PracticeReSel
		push	af
		push	bc
		push	de
		call	shutdownbitmap
		pop	de
		pop	bc
		pop	af
		jp	nz,shell1
		ld	a,c
		ld	[wSubLevel],a
		xor	a
		ld	[wSubStage],a
		xor	a
		ld	[wSubStars],a
		ld	[wStructGastn+PLYR_STARS],a
		ld	a,PLYR_GASTN
		ld	[wWhichPlyr],a
		ld	a,b
		push	de
		call	LaunchGame
		pop	de
		ld	a,[wSubStage]
		cp	3
		jr	c,nounlock
		ld	hl,wLockState
		add	hl,de
		ld	a,[wSubLevel]
		inc	a
		ld	b,a
		ld	a,$80
.rlp:		rlc	a
		dec	b
		jr	nz,.rlp
		ld	b,a
		or	[hl]
		cp	[hl]
		jr	z,nounlock
		ld	[hl],a
		call	lockmask
		ld	c,a
		and	b
		jr	z,nounlock
		push	bc
		call	Fire_b
		pop	bc
		ld	a,c
		cp	7
		ld	a,0	;don't allow exit until all credits shown
		call	z,Dance_b
		call	UnlockedBoard
nounlock:	jr	practicelp

UnlockedBoard:
		GLOBAL	IntroUnlockMap ; Introhi.asm
		ld	hl,IntroUnlockMap
		call	TalkingHeads
		ret


challenge:
		call	shutdownbitmap
		xor	a
		ld	[wSelected],a
.challenge:
		call	ChallengeReSel
		push	af
		push	bc
		call	shutdownbitmap
		pop	bc
		pop	af
		jp	nz,shell1
		ld	a,c
		ld	[wChallenge],a
		add	3
		ld	[wSubLevel],a
		xor	a
		ld	[wSubStage],a
		ld	[wSubStars],a
		ld	a,b
		call	LaunchGame
		call	tryhighscore
		call	showresults
		jr	.challenge


PADNOISENORMAL	EQU	$ff
PADNOISEUDSSA	EQU	$ff-(MSK_JOY_L+MSK_JOY_R+MSK_JOY_B)
PADNOISEUDSSAB	EQU	$ff-(MSK_JOY_L+MSK_JOY_R)
PADNOISELRSSAB	EQU	$ff-(MSK_JOY_U+MSK_JOY_D)


;Called off of main menu
secretprocess:	ld	a,[wJoy1Hit]
		or	a
		ret	z
		ld	b,a
		ld	hl,wSecretHistory+SECRETLEN-1
		ld	de,wSecretHistory+SECRETLEN-2
		ld	c,SECRETLEN-1
.copyback:	ld	a,[de]
		dec	de
		ld	[hld],a
		dec	c
		jr	nz,.copyback
		ld	[hl],b
		ld	hl,SecretCodes
.codecomp:	ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		or	e
		ret	z
		ld	c,0
.cnt:		ld	a,[de]
		or	a
		jr	z,.cnted
		inc	c
		inc	de
		jr	.cnt
.cnted:		push	hl
		ld	hl,wSecretHistory
.comp:		dec	de
		ld	a,[de]
		cp	[hl]
		jr	nz,.next
		inc	hl
		dec	c
		jr	nz,.comp
		pop	hl	;match
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		jp	[hl]
.next:		pop	hl
		inc	hl
		inc	hl
		jr	.codecomp

;first word is pointer to key sequence (0 marks end of list)
;second word is function to jump to when code matches.
;Only the first matching sequence gets called.

SecretCodes::	dw	secretseq2,secretrout2
		dw	secretseq1,secretrout1
		dw	0

;Each sequence must end in a 0 byte

secretseq1:	db	MSK_JOY_U,MSK_JOY_D,MSK_JOY_U,MSK_JOY_D
		db	MSK_JOY_L,MSK_JOY_R,MSK_JOY_SELECT,0


secretseq2:	db	MSK_JOY_L,MSK_JOY_R,MSK_JOY_L,MSK_JOY_R
		db	MSK_JOY_U,MSK_JOY_D,MSK_JOY_SELECT,0

secretrout2::
		call	UnlockStories
		ld	hl,wLockState
		ld	bc,NUMGAMES
		ld	a,7
		jp	MemFill
secretrout1::
		ld	hl,wLockState
		ld	bc,16
		call	MemClear
		call	LockStories

		ret





manyplayers:
		call	PlayerSelect
		jp	nz,shell1loop
		jr	.nofade
.back:		call	FadeOut
		call	SelectSetup
.nofade:
		call	DifficultySelect
		jr	nz,manyplayers

		ld	a,3
		call	BoardSelect
		cp	255
		jr	z,.back
		ld	[wBoardMap],a

		call	shutdownbitmap
		call	setupplayers
		call	BoardGame_b
		jp	shell1


restartboard:	call	shutdownbitmap
		call	BoardGame_b
		jp	shell1
restartstory:	call	shutdownbitmap
		call	StoryGame_b
		jp	shell1

showresults:	call	PracticeSetup
		ld	a,[wSelected]
		and	$f0
		ldh	[sel_which],a
		call	practicename
		ld	e,2
		call	picklite
		ld	a,[wScoreLo]
		ld	c,a
		ld	a,[wScoreHi]
		ld	b,a
		call	makeinfo
		ld	[hl],0
		ld	a,80
		ld	[STRTEMP],a
		ld	a,1
		ld	[STRTEMP+3],a
		ld	hl,STRTEMP
		call	DrawStringLst
		ldh	a,[sel_high]
		or	a
		jr	z,.nohs
		call	hsname
		call	picklite
		ld	hl,highlst
		call	DrawStringLstN
.nohs:		call	CpyAll
		call	FadeInBlack
showreslp:	ldh	a,[sel_high]
		or	a
		jr	z,.nohs2
		ld	hl,sel_count
		inc	[hl]
		ld	a,[hl]
		and	15
		call	z,hsname
.nohs2:		call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		call	ProcAutoRepeat
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_START,c
		jp	nz,.showresdone
		ldh	a,[sel_high]
		or	a
		jr	nz,.entering
		bit	JOY_A,c
		jp	nz,.showresdone
		bit	JOY_B,c
		jr	nz,.showresdone
		jr	showreslp
.entering:	ld	b,-1
		bit	JOY_L,c
		jr	nz,.switch
		bit	JOY_B,c
		jr	nz,.switch3
		ld	b,1
		bit	JOY_R,c
		jr	nz,.switch
		bit	JOY_A,c
		jr	nz,.switch2
		ld	b,1
		bit	JOY_U,c
		jr	nz,.change
		ld	b,-1
		bit	JOY_D,c
		jr	nz,.change
		jr	showreslp
.switch3:	ldh	a,[sel_which]
		and	3
		jr	z,showreslp
		jr	.switch
.switch2:	ldh	a,[sel_which]
		and	3
		cp	2
		jr	z,.showresdone
.switch:	ldh	a,[sel_which]
		and	$f0
		ld	c,a
		ldh	a,[sel_which]
		xor	c
		add	b
		cp	3
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,2
.aok:		or	c
		ldh	[sel_which],a
		call	hsname
		jr	showreslp
.change:	push	bc
		call	CheckBBRam
		pop	bc
		ldh	a,[sel_which]
		and	3
		ld	c,a
		ld	a,[wSelected]
		and	$f0
		add	HI_INIT1
		add	c
		ld	l,a
		ld	a,[wChallenge]
		add	HIGH(wHighScores1)
		ld	h,a
		ld	a,[hl]
		add	b
		cp	26
		jr	c,.aok2
		ld	a,0
		jr	z,.aok2
		ld	a,25
.aok2:		ld	[hl],a
		call	SumBBRam
		call	hsname
		jp	showreslp



.showresdone:	jp	shutdownbitmap




tryhighscore:
		call	CheckBBRam
		ld	hl,wScoreLo
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a

		xor	a
		ldh	[sel_high],a

		ld	a,[wSelected]
		and	$f0
		add	HI_SCORELO
		ld	l,a
		ld	a,[wChallenge]
		add	HIGH(wHighScores1)
		ld	h,a
		ld	a,[hli]
		sub	e
		ld	a,[hld]
		sbc	d
		ret	nc
		ld	a,1
		ldh	[sel_high],a
		ld	[hl],e
		inc	l
		ld	[hl],d
		jp	SumBBRam


HSENTER		EQU	3

hsname:		ld	a,HSENTER
		call	ClrTop
		xor	a
		call	hsletter
		ld	a,1
		call	hsletter
		ld	a,2
		call	hsletter
		ld	a,HSENTER
		jp	CpyTop
hsletter:	ld	c,a
		dec	a
		add	a
		add	a
		ld	b,a
		add	a
		add	b
		add	80
		ld	hl,STRTEMP
		ld	[hli],a
		ld	a,LINEDOWN+HSENTER*YSPACE	;x9
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ld	a,[wSelected]
		and	$f0
		add	HI_INIT1
		add	c
		ld	e,a
		ld	a,[wChallenge]
		add	HIGH(wHighScores1)
		ld	d,a
		ld	a,[de]
		add	ICON_ALPHABET
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],a
		ldh	a,[sel_count]
		and	16
		jr	z,.onlydark
		ldh	a,[sel_which]
		and	3
		cp	c
		jr	z,.lite
.onlydark:	call	pickdark
		jr	.dark
.lite:		call	picklite
.dark:		ld	hl,STRTEMP
		jp	DrawStringLst


FIX5		EQU	6


ClrTop::	PUSH	AF			;
		ADD	A			;
		LD	B,A
		ADD	A			;
		ADD	A			;
		ADD	B	;x10
		ADD	LINEDOWN-7
		LDH	[hSprYLo],A		;
		LD	A,1*8			;
		LDH	[hSprXLo],A		;
		LD	A,18*8			;
		LD	[wStringW],A		;
		LD	A,YSPACE	;x10
		LD	[wStringH],A		;
		CALL	ClrRect18_b		;
		POP	AF			;
		RET				;
ClrCenter::	PUSH	AF			;
		ADD	A			;
		LD	B,A
		ADD	A			;
		ADD	A			;
		ADD	B	;x10
		ADD	LINEDOWN-7
		LDH	[hSprYLo],A		;
		LD	A,3*8			;
		LDH	[hSprXLo],A		;
		LD	A,14*8			;
		LD	[wStringW],A		;
		LD	A,YSPACE	;x10
		LD	[wStringH],A		;
		CALL	ClrRect18_b		;
		POP	AF			;
		RET				;

ClrAll::
		XOR	A
		LDH	[hSprYLo],A		;
		LD	A,0			;
		LDH	[hSprXLo],A		;
		LD	A,160			;
		LD	[wStringW],A		;
		LD	A,64+8			;take out +8 (TEST MENU)
		LD	[wStringH],A		;
		JP	ClrRect18_b		;



CpyAll:		LD	BC,$0000		;
		LD	DE,$1409		;
		CALL	DmaBitbox20x18_b		;
		LD	DE,$9800
		JP	DumpShadowAtr

;
;
;

CpyTop::	PUSH	AF			;
		ADD	A
		LD	C,A
		ADD	A
		ADD	A
		ADD	C
		ADD	LINEDOWN-7
		SRL	A
		SRL	A
		SRL	A
		LD	C,A
		LD	B,$01		;
		LD	DE,$1202		;
		CALL	DmaBitbox20x18_b		;
		POP	AF			;
		RET				;
CpyCenter::	PUSH	AF			;
		ADD	A
		LD	C,A
		ADD	A
		ADD	A
		ADD	C
		ADD	LINEDOWN-7
		SRL	A
		SRL	A
		SRL	A
		LD	C,A
		LD	B,$03		;
		LD	DE,$0e02		;
		CALL	DmaBitbox20x18_b		;
		POP	AF			;
		RET				;


setupplayers:
		ld	hl,wStructGastn
		ld	bc,8
		call	MemClear
		ld	hl,wStructBelle
		ld	a,[wSelect4+0]
		call	setupplayer
		ld	hl,wStructBeast
		ld	a,[wSelect4+1]
		call	setupplayer
		ld	hl,wStructPotts
		ld	a,[wSelect4+2]
		call	setupplayer
		ld	hl,wStructLumir
		ld	a,[wSelect4+3]
setupplayer:	push	af
		push	hl
		ld	bc,8
		call	MemClear
		pop	hl
		pop	bc
		ld	a,b
		and	3
		jr	z,.outofgame
		set	PFLG_PLAY,[hl]
		dec	a
		jr	z,.outofgame
		set	PFLG_CPU,[hl]
.outofgame:	ld	a,b
		srl	a
		srl	a
		and	3
		inc	hl
		ld	[hl],a
		ret


checkselect4:	ld	hl,wSelect4
		call	.check1
		call	.check1
		call	.check1
.check1:	ld	a,[hl]
		and	$03
		cp	3
		jr	nz,.ok1
		ld	a,1
.ok1:		ld	b,a
		ld	a,[hl]
		and	$0c
		cp	$0c
		jr	nz,.ok2
		xor	a
.ok2:		or	b
		ld	[hli],a
		ret


;0=none
;1=user
;2=cpu
initsel1tab:	db	1,2,2,2
;fills out hTemp48 4 bytes
;returns A=00 means advance, all is well
;        A=FF means B button pressed, back up


ChallengeSetup:
PracticeSetup:	ld	hl,IDX_BCOGGSPKG
		ld	de,IDX_CCOGGSPKG
		jr	AllSetup

SelectSetup:
		ld	hl,IDX_BDSCROLLPKG
		ld	de,IDX_CDSCROLLPKG ;cdscrollpkg

MenuSetup:

		call	AllSetup
		jp	FadeInBlack
AllSetup:
		push	de
		push	hl
		xor	a
		call	InitTune
		call	SetBitmap20x18
		pop	hl
		pop	de

AllSetup2:
		call	XferBitmap

		call	DmaBitmap20x18
		ld	de,$9800
		jp	DumpShadowAtr

LegalScreen::	push	de
		push	hl
		call	SetBitmap20x18
		pop	hl
		pop	de
		call	XferBitmap
		call	pickdark

		ld	a,%11000011		;Override GMB palettes for
		LD	[wFadeVblBGP],A		;a black background.
		LD	[wFadeLycBGP],A		;

		ld	hl,legallst1
		call	DrawStringLstN

		ld	a,144
		ld	[wStringL1Width],a
		ld	[wStringL2Width],a
		ld	[wStringL3Width],a
		ld	[wStringL4Width],a

		IF	VERSION_JAPAN
		call	pickolde
		ENDC

		ld	de,195
		call	GetString
		call	SplitString
		ld	hl,legallst2
		call	DrawStringLstP

		IF	VERSION_JAPAN
		call	pickdark
		ENDC

		ld	de,196
		call	GetString
		call	SplitString
		ld	hl,legallst3
		call	DrawStringLstP

		ld	hl,legallst4
		call	DrawStringLstN

		ld	de,198
		call	GetString
		call	SplitString
		ld	hl,legallst5
		call	DrawStringLstP

		ld	de,199
		call	GetString
		call	SplitString
		ld	hl,legallst6
		call	DrawStringLstP

		ld	de,200
		call	GetString
		call	SplitString
		ld	hl,legallst7
		call	DrawStringLstP

		jr	SSenter


SingleScreen:	push	de
		push	hl
		call	SetBitmap20x18
		pop	hl
		pop	de
		call	XferBitmap
SSenter:	call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
		call	FadeInBlack
		ld	a,60*3
		ldh	[sel_count],a
.wait:		call	WaitForVBL
		ld	a,[wAvoidIntro]
		or	a
		jr	z,.noskipout
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	nz,.exit
.noskipout:	ld	hl,sel_count
		dec	[hl]
		jr	nz,.wait
.exit:		jp	shutdownbitmap



PlayerSelect::
		call	checkselect4
		call	pickolde

		call	ClrAll
		xor	a
		ldh	[sel_which],a
		ld	hl,sel1title
		call	DrawStringLstN
		call	Sel14
		call	CpyAll

sel1loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		ldh	a,[sel_which]
		ld	hl,wSelect4
		call	addahl
		bit	JOY_L,c
		jr	z,.nolf
		ld	a,[hl]
		and	3
		jr	nz,.mok
		xor	[hl]
		or	3
		ld	[hl],a
.mok:		dec	[hl]
		jr	.ref
.nolf:		bit	JOY_R,c
		jr	z,.nort
		inc	[hl]
		ld	a,[hl]
		and	3
		cp	3
		jr	c,.mok2
		xor	[hl]
		ld	[hl],a
.mok2:		jr	.ref
.nort:		bit	JOY_A,c
		jr	nz,.go
		bit	JOY_SELECT,c
		jr	nz,.go
		bit	JOY_START,c
		jr	z,.nostart
.go:		ld	hl,wSelect4
		ld	c,4
		ld	de,0
.count:		ld	a,[hli]
		and	3
		jr	z,.next
		dec	a
		jr	nz,.noincd
		inc	d
.noincd:	inc	e
.next:		dec	c
		jr	nz,.count
		ld	a,d
		or	a
		jr	z,.invalid
		ld	a,e
		cp	2
		ld	a,0
		jr	nc,sel1done
.invalid:	ld	a,SFX_ILLEGAL
		call	InitSfx
		jr	sel1loop
.nostart:	bit	JOY_B,c
		jr	z,.nob
		ld	a,255
		jr	sel1done
.nob:		jr	sel1loop

.ref:		ldh	a,[sel_which]
		call	sel1disp
		call	CpyAll
		jp	sel1loop
.switch:	ldh	a,[sel_which]
		push	af
		add	b
		and	3
		ldh	[sel_which],a
		call	sel1disp
		pop	af
		call	sel1disp
		call	CpyAll
		jp	sel1loop

sel1done:	or	a
		ret


Sel14:		xor	a
		call	sel1disp
		ld	a,1
		call	sel1disp
		ld	a,2
		call	sel1disp
		ld	a,3
sel1disp:	push	af
		call	ClrTop
		pop	af
		push	af
		ld	c,a
		call	pickfont
		ld	hl,STRTEMP
		ld	a,8
		ld	[hli],a
		ld	a,c
		add	a
		add	a
		add	a
		add	c	;x10
		add	c
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,c
		add	a
		add	LOW(sel1names)
		ld	e,a
		ld	a,0
		adc	HIGH(sel1names)
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	e,b
		ld	d,a
		push	hl
		call	GetString
		pop	hl
		ld	de,wString
		call	copyz
PLAYERTYPEX	EQU	118
		ld	a,PLAYERTYPEX
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		ld	a,[STRTEMP+2]
		ld	[hli],a
		ld	a,1	;2
		ld	[hli],a
		ld	a,c
		add	LOW(wSelect4)
		ld	e,a
		ld	d,HIGH(wSelect4)
		ld	a,[de]
		and	3
		add	a
		add	LOW(sel1types)
		ld	e,a
		ld	a,0
		adc	HIGH(sel1types)
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	e,b
		ld	d,a
;		push	hl
;		call	GetString
;		pop	hl
;		ld	de,wString
		call	copyz
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		ret


copyz:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,copyz
		ret


pickgmblite:	ldh	a,[hMachine]
		cp	MACHINE_CGB
		jp	z,picklite
		jp	pickdark
;c=current line #
pickfont:	ldh	a,[sel_which]
		and	15
		cp	c
		jp	nz,pickdark
		jp	picklite
pickfont2:	ld	a,[wTempSelect]
		cp	c
		jp	nz,pickdark
		jp	picklite

sel1title:	db	80,TOPTITLE,0,1
		dw	127	;PLAYER SELECT
		db	0

sel1names:	dw	129	;BELLE
		dw	128	;BEAST
		dw	130	;MRS. POTTS
		dw	131	;LUMIERE

sel1types:	dw	.none	;134	;NONE
		dw	.user	;132	;USER
		dw	.cpu	;133	;CPU
.none:		db	ICON_NOBODY,0
.user:		db	ICON_HUMAN,0
.cpu:		db	ICON_CPU,0


sel2diffs:
sel2diffs2:	dw	.weak
		dw	.average
		dw	.strong
.weak:		db	ICON_DIFFICULTY,0
.average:	db	ICON_DIFFICULTY,ICON_DIFFICULTY,0
.strong:	db	ICON_DIFFICULTY,ICON_DIFFICULTY,ICON_DIFFICULTY,0

sel2title:	db	80,TOPTITLE,0,1
		dw	204	;DIFFICULTY SELECT
		db	0
sel3title:	db	80,TOPTITLE,0,1
		dw	87	;GAME SELECT
		db	0

sel9title:	db	80,TOPTITLE,0,1
		dw	92	;OPTIONS
		db	0

sel9tab:	dw	96	;MUSIC
		dw	99	;CLEAR MEMORY
		dw	94	;SONG ;95 = SFX
		IF	VERSION_EUROPE
		dw	202	;LANGUAGE
		ENDC
		dw	103	;CREDITS


pausetitle:	db	80,76,0,1
		dw	193
		db	0

sel10title:	db	80,20,0,1
		dw	wStringLine1	;CLEAR HIGH SCORES?
		db	80,38,0,1
		dw	wStringLine2
		db	0

sel10tab:	dw	101
		dw	102

sel11title:	db	80,20,0,1
		dw	205	;DELETE GAME?
		db	0

selarrows:	db	8-4,48,0,0
		db	ICON_LEFT,0
		db	152+4,48,0,2
		db	ICON_RIGHT,0
		db	0

sel8title:	db	80,TOPTITLE,0,1
		dw	189	;SAVED GAME
		db	0

sel8title2:	db	80,28,0,1
		dw	wStringLine1
		db	80,36,0,1
		dw	wStringLine2
		db	0

sel8tab:	dw	191	;CONTINUE
		dw	192	;QUIT

sel3tab:	dw	88	;STORY GAME
		dw	89	;BOARD GAME
		dw	90	;PRACTICE GAME
		dw	91	;CHALLENGE MODE
		dw	92	;OPTIONS

legallst1:	db	80,8,0,1
		dw	194
		db	0

		IF	VERSION_JAPAN
legallst2:	db	80,24,0,1
		dw	wStringLine1
		db	0
legallst3:	db	80,37,0,1
		dw	wStringLine1
		db	80,46,0,1
		dw	wStringLine2
		db	0
		ELSE
legallst2:	db	80,19,0,1
		dw	wStringLine1
		db	80,28,0,1
		dw	wStringLine2
		db	0
legallst3:	db	80,39,0,1
		dw	wStringLine1
		db	80,48,0,1
		dw	wStringLine2
		db	0
		ENDC

legallst4:	db	80,59,0,1
		dw	197
		db	0
legallst5:	db	80,70,0,1
		dw	wStringLine1
		db	80,79,0,1
		dw	wStringLine2
		db	0
legallst6:	db	80,90,0,1
		dw	wStringLine1
		db	80,99,0,1
		dw	wStringLine2
		db	80,108,0,1
		dw	wStringLine3
		db	80,117,0,1
		dw	wStringLine4
		db	0

		IF	VERSION_JAPAN
legallst7:	db	80,137,0,1
		dw	wStringLine1
		db	0
		ELSE
legallst7:	db	80,128,0,1
		dw	wStringLine1
		db	80,137,0,1
		dw	wStringLine2
		db	0
		ENDC

highlst:	db	80,LINEDOWN,0,1
		dw	178	;HIGH SCORE!!!
		db	0

sel7tab:
sel4tab:	dw	163	;EASY
		dw	164	;MEDIUM
		dw	165	;HARD

sel6tab:	dw	166	;CHALLENGE EASY
		dw	167	;CHALLENGE HARD

sel7title:	db	80,TOPTITLE,0,1
		dw	88	;STORY GAME
		db	0



DifficultySelect::
		call	checkselect4

		ldh	a,[sel_which]
		ld	c,a
		dec	c
.skips2:	inc	c
		ld	a,c
		and	3
		ld	c,a
		ld	hl,wSelect4
		call	addahl
		ld	a,[hl]
		and	3
		jr	z,.skips2
		ld	a,c
		ldh	[sel_which],a


		call	pickolde

		call	ClrAll
		ld	hl,sel2title
		call	DrawStringLstN
		call	Sel24
		call	CpyAll

sel2loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_B,c
		ld	a,255
		jp	nz,sel2done
		ldh	a,[sel_which]
		ld	hl,wSelect4
		call	addahl
		ld	a,[hl]
		and	3
		ld	b,a
		xor	[hl]
		bit	JOY_L,c
		jr	z,.nolf
		or	a
		jr	nz,.aok
		ld	a,4*3
.aok:		sub	4
		or	b
		ld	[hl],a
		jr	.ref
.nolf:		bit	JOY_R,c
		jr	z,.nort
		add	4
		cp	4*3
		jr	c,.aok2
		xor	a
.aok2:		or	b
		ld	[hl],a
		jr	.ref
.nort:		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel2loop
.done:		xor	a
		jr	sel2done
.ref:		ldh	a,[sel_which]
		call	sel2disp
		call	CpyAll
		jr	sel2loop

.switch:	ldh	a,[sel_which]
		push	af
		ld	c,a
.skips:		ld	a,c
		add	b
		and	3
		ld	c,a
		ld	hl,wSelect4
		call	addahl
		ld	a,[hl]
		and	3
		jr	z,.skips
		ld	a,c
		ldh	[sel_which],a
		call	sel2disp
		pop	af
		call	sel2disp
		call	CpyAll
		jp	sel2loop

sel2done:	ret



Sel24:		xor	a
		call	sel2disp
		ld	a,1
		call	sel2disp
		ld	a,2
		call	sel2disp
		ld	a,3
sel2disp:	push	af
		call	ClrTop
		pop	af
		ld	c,a
		ld	hl,wSelect4
		and	3
		call	addahl
		ld	a,[hl]
		and	3
		ld	a,c
		jp	z,CpyTop
		push	af
		call	pickfont
		ld	hl,STRTEMP
		ld	a,8
		ld	[hli],a
		ld	a,c
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,c
		add	a
		ld	de,sel1names
		add	e
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	e,b
		ld	d,a
		push	hl
		call	GetString
		pop	hl
		ld	de,wString
		call	copyz

		ld	a,152-12
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		ld	a,[STRTEMP+2]
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ld	a,c
		add	LOW(wSelect4)
		ld	e,a
		ld	d,HIGH(wSelect4)
		ld	a,[de]
		ld	b,a
		srl	a
		and	6
		ld	e,a
		ld	a,b
		and	3
		cp	2	;CPU controlled
		ld	a,e
		ld	de,sel2diffs
		jr	nz,.deok
		ld	de,sel2diffs2
.deok:		add	e
		ld	e,a
		ld	a,0
		adc	d
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	e,b
		ld	d,a
		call	copyz

		ld	a,PLAYERTYPEX
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		xor	a		;;;;
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ld	a,c
		add	LOW(wSelect4)
		ld	e,a
		ld	d,HIGH(wSelect4)
		ld	a,[de]
		and	3
		add	a
		add	LOW(sel1types)
		ld	e,a
		ld	a,0
		adc	HIGH(sel1types)
		ld	d,a
		ld	a,[de]
		inc	de
		ld	b,a
		ld	a,[de]
		ld	e,b
		ld	d,a
;		push	hl
;		call	GetString
;		pop	hl
;		ld	de,wString
		call	copyz

		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		ret
;		jp	CpyTop

GameSelect::
		xor	a
		ld	[sel_which],a
		ld	[sel_timelo],a
		ld	[sel_timehi],a
		ld	[sel_story],a
		ld	[sel_multi],a

		call	pickolde

		call	ClrAll
		ld	hl,sel3title
		call	DrawStringLstN
		call	Sel34
		call	CpyAll

sel3loop:	call	WaitForVBL
		ld	a,PADNOISEUDSSA
		call	noisyReadJoypad
		call	secretprocess
		ld	a,[wJoy1Hit]
		ld	c,a
		or	a
		jr	z,.nozerotime
		xor	a
		ldh	[sel_timelo],a
		ldh	[sel_timehi],a
.nozerotime:	ld	hl,sel_timelo
		inc	[hl]
		jr	nz,.no16
		inc	l
		inc	[hl]
.no16:		ldh	a,[sel_timehi]
		cp	6	;6*256 = about 26 seconds
		ld	a,255
		jr	z,sel3done

		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		bit	JOY_L,c
		jr	nz,.switch2
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_R,c
		jr	nz,.switch2
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel3loop
.done:		ldh	a,[sel_which]
		jr	sel3done
.ref:		ldh	a,[sel_which]
		call	sel3disp
		ldh	a,[sel_which]
		call	CpyTop
		jr	sel3loop
.switch2:	ldh	a,[sel_which]
		cp	2
		jr	nc,sel3loop
		ld	hl,sel_story
		ld	c,NUMSTORYBOARDS
		or	a
		jr	z,.hlbok
		ld	hl,sel_multi
		ld	c,NUMMULTIBOARDS
.hlbok:		ld	a,[hl]
		add	b
		cp	c
		jr	c,.aok
		ld	a,0
		jr	nz,.aok
		ld	a,c
		dec	a
.aok:		ld	[hl],a
		jr	.ref

.switch:	ldh	a,[sel_which]
		push	af
		add	b
		cp	5
		jr	c,.aok2
		ld	a,0
		jr	z,.aok2
		ld	a,4
.aok2:		ldh	[sel_which],a
		call	sel3disp
		pop	af
		call	sel3disp
		call	CpyAll
		jp	sel3loop

sel3done:	ret



Sel34:		xor	a
		call	sel3disp
		ld	a,1
		call	sel3disp
		ld	a,2
		call	sel3disp
		ld	a,3
		call	sel3disp
		ld	a,4
sel3disp:	push	af
		call	ClrTop
		pop	af
		ld	c,a
		ld	hl,sel3tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		call	GetString
		ld	de,wString
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		pop	af
;		cp	2
;		jr	nc,.notstory
;		or	a
;		ldh	a,[sel_story]
;		jr	z,.aok
;		ldh	a,[sel_multi]
;.aok:		ld	b,a
;		dec	hl
;		ld	a,ICON_REALSPACE
;		ld	[hli],a
;		ld	[hli],a
;		ld	a,b
;		add	"1"
;		ld	[hli],a
;		xor	a
;		ld	[hli],a
;.notstory:

		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		ret

PickLanguage:
		call	CheckLanguage
		ret	z

		ld	hl,wLockState
		ld	bc,16
		call	MemClear

		call	SelectSetup

		xor	a
		ld	[sel_which],a
		ld	[sel_timelo],a
		ld	[sel_timehi],a

		call	ClrAll
		call	selpick4
		call	CpyAll

selpickloop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a

		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,selpickloop
.done:		ldh	a,[sel_which]
		jr	selpickdone
.ref:		ldh	a,[sel_which]
		call	selpickdisp
		jr	selpickloop

.switch:	ldh	a,[sel_which]
		push	af
		add	b
		cp	5
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,4
.aok:		ldh	[sel_which],a
		call	selpickdisp
		pop	af
		call	selpickdisp
		call	CpyAll
		jp	selpickloop

selpickdone:	ldh	a,[sel_which]
		ld	[wLanguage],a
		call	HashLanguage

		jp	shutdownbitmap

selpick4:	xor	a
		call	selpickdisp
		ld	a,1
		call	selpickdisp
		ld	a,2
		call	selpickdisp
		ld	a,3
		call	selpickdisp
		ld	a,4
selpickdisp:	push	af
 dec a
		call	ClrTop
		pop	af
		ld	c,a
		ld	a,[wLanguage]
		push	af
		ld	a,c
		ld	[wLanguage],a
		ld	de,203
		push	bc
		call	GetString
		pop	bc
		pop	af
		ld	[wLanguage],a
		ld	de,wString

		push	af
		call	pickfont
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
 dec a
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
 dec a
 dec a
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
 dec a
		ret
;		jp	CpyTop




StorySelect::
		xor	a
		ld	[sel_which],a

		call	pickolde

		call	ClrAll
		ld	hl,sel7title
		call	DrawStringLstN
		call	Sel74
		call	CpyAll

sel7loop:	call	WaitForVBL
		ld	a,PADNOISEUDSSAB
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_B,c
		ld	a,255
		jp	nz,sel7done
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel7loop
.done:		ldh	a,[sel_which]
		jr	sel7done
.ref:		ldh	a,[sel_which]
		call	sel7disp
		jr	sel7loop

.switch:	ldh	a,[sel_which]
		push	af
		add	b
		cp	3
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,2
.aok:		ldh	[sel_which],a
		call	sel7disp
		pop	af
		call	sel7disp
		call	CpyAll
		jp	sel7loop

sel7done:	ret



Sel74:		xor	a
		call	sel7disp
		ld	a,1
		call	sel7disp
		ld	a,2
sel7disp:	push	af
		inc	a
		call	ClrTop
		pop	af
		ld	c,a
		ld	hl,sel7tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		call	GetString
		ld	de,wString
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
		inc	a
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN+2
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		inc	a
		ret
;		jp	CpyTop


challengename:
practicename:	call	pickolde

		call	ClrAll
		ldh	a,[sel_which]
		swap	a
		and	15
		add	a
		ld	hl,subnames
		call	addahl
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		call	GetString
		ld	de,wString
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,TOPTITLE
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		ld	[hl],0

		ld	hl,STRTEMP
		jp	DrawStringLst


putarrows:	call	pickolde
		ld	hl,selarrows
		jp	DrawStringLst

bstab:		dw	IDX_CSNGL1TPKG	;csngl1tpkg
		dw	IDX_CSNGL1TPKG	;csngl1tpkg
		dw	IDX_CSNGL2TPKG	;csngl2tpkg
		dw	IDX_CSNGL2TPKG	;csngl2tpkg
		dw	IDX_CSNGL3TPKG	;csngl3tpkg
		dw	IDX_CSNGL3TPKG	;csngl3tpkg
		dw	IDX_CMULTI1TPKG	;cmulti1tpkg
		dw	IDX_CMULTI1TPKG	;cmulti1tpkg
		dw	IDX_CMULTI2TPKG	;cmulti2tpkg
		dw	IDX_CMULTI2TPKG	;cmulti2tpkg
		dw	IDX_CMULTI3TPKG	;cmulti3tpkg
		dw	IDX_CMULTI3TPKG	;cmulti3tpkg
		dw	IDX_CMULTI4TPKG	;cmulti4tpkg
		dw	IDX_CMULTI4TPKG	;cmulti4tpkg
		dw	IDX_CMARKTPKG	;cmarktpkg
		dw	IDX_CMARKTPKG	;cmarktpkg


lockmask:	ld	hl,wLockState
		ld	a,7
		ld	c,NUMGAMES
.ll:		and	[hl]
		inc	hl
		dec	c
		jr	nz,.ll
		ret

bits:		db	1,2,4,8,16,32,64,128

boardnext:	ldh	a,[sel_type]
		ld	l,a
		ldh	a,[sel_which]
		cp	l
		jr	c,.aok
		ld	a,-1
.aok:		inc	a
		ldh	[sel_which],a
		ret
boardprev:	ldh	a,[sel_type]
		ld	l,a
		ldh	a,[sel_which]
		or	a
		jr	nz,.aok
		ld	a,l
		inc	a
.aok:		dec	a
		ldh	[sel_which],a
		ret

disabledstrlst2:
		db	80,117,0,1
		dw	wStringLine1
		db	80,127,0,1
		dw	wStringLine2
		db	0
disabledstrlst3:
		db	80,112,0,1
		dw	wStringLine1
		db	80,122,0,1
		dw	wStringLine2
		db	80,132,0,1
		dw	wStringLine3
		db	0


disabledstrings:
		db	218,219,220
		db	221,221,222,223

;a=0 for single mode
;a=1 for multi mode
BoardSelect:	ld	d,a
		or	a
		ld	a,2
		jr	z,.aok
		ld	a,6
.aok:		ldh	[sel_type],a
		ld	a,d
		or	a
		jr	z,.aok2
		ld	a,3
.aok2:		ldh	[sel_which],a
		ld	a,[wStoryUnlocked]
		and	3
		add	a
		inc	a
		ld	e,a	;John's single mask | 1
		ld	a,d
		or	a
		ld	a,e
		jr	z,.nomultis
		ld	a,[wStoryUnlocked]
		ld	e,a	;John's single mask
		call	lockmask
		add	a
		inc	a
		add	a
		add	a
		add	a
		or	e
.nomultis:	ldh	[sel_boards],a
		call	FadeOutBlack
boardselectouter:
		ldh	a,[sel_which]
		ld	c,a
		ld	b,0
		ld	hl,bits
		add	hl,bc
		ldh	a,[sel_boards]
		and	[hl]
		ld	a,c
		jr	nz,.aok
		ld	a,7
.aok:		push	af
		add	a
		add	a
		ld	hl,bstab
		call	addahl
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		inc	hl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		call	XferBitmap

		pop	af
		cp	7
		jr	z,.disabled
		call	pickolde
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,124
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ldh	a,[sel_which]
		add	210
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	hl,STRTEMP
		call	DrawStringLstN
		jr	.enabled
.disabled:
		call	picklite
		ld	a,128
		ld	[wStringL1Width],a
		ld	[wStringL2Width],a
		ld	[wStringL3Width],a

		ld	hl,disabledstrings
		ldh	a,[sel_type]
		cp	3
		jr	nc,.nodec
		dec	hl
.nodec:		ldh	a,[sel_which]
		call	addahl
		ld	e,[hl]
		ld	d,0
		call	GetString
		call	SplitString
		ld	hl,disabledstrlst2
		ld	a,[wStringLine3]
		or	a
		jr	z,.hlok
		ld	hl,disabledstrlst3
.hlok:		call	DrawStringLstP
.enabled:

		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr
;		CALL	SloBitmap20x18		;Copy the bitmap to vram.

		call	FadeInBlack
boardselectinner:
		call	WaitForVBL
		ld	a,PADNOISELRSSAB
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		bit	JOY_START,a
		jr	nz,.tryselect
		bit	JOY_A,a
		jr	nz,.tryselect
		bit	JOY_B,a
		jr	nz,.back
		bit	JOY_L,a
		jr	nz,.goprev
		bit	JOY_R,a
		jr	nz,.gonext
		jr	boardselectinner
.goprev:	call	boardprev
		jr	.switch
.gonext:	call	boardnext
		jr	.switch
.switch:	ldh	a,[sel_which]
		jp	boardselectouter
.back:		ld	a,255
		ret
.tryselect:	ldh	a,[sel_which]
		ld	hl,bits
		call	addahl
		ldh	a,[sel_boards]
		and	[hl]
		jr	nz,.done
		ld	a,SFX_ILLEGAL
		call	InitSfx
		jr	boardselectinner
.done:		ldh	a,[sel_which]
		ret








;returns a=255 for B button (back)
;otherwise a=0
;e=game # in list of games (unmapped, for use by wLockState)
;b=subgame # (for use by LaunchGame)
;c=skill level to play at
PracticeReSel:	ld	a,[wSelected]
		jr	PracticeAny
PracticeSelect:
		xor	a
PracticeAny:
		ldh	[sel_which],a

		call	CheckBBRam
		call	PracticeSetup
practiceouter:
		call	practicename
		call	Sel44
		call	putarrows
		call	CpyAll
		call	FadeInBlack

sel4loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,-16
		bit	JOY_L,c
		jr	nz,.bigswitch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		ld	b,16
		bit	JOY_R,c
		jr	nz,.bigswitch
		bit	JOY_B,c
		ld	a,255
		jp	nz,sel4done
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel4loop
.done:		ldh	a,[sel_which]
		ld	[wSelected],a
		swap	a
		and	15
		ld	e,a
		ld	d,0
		ld	hl,subgamemap
		add	hl,de
		ld	b,[hl]
		ldh	a,[sel_which]
		and	3
		ld	c,a
		xor	a
		jr	sel4done
.ref:		ldh	a,[sel_which]
		ld	[wSelected],a
		call	sel4disp
		call	CpyAll
		jr	sel4loop

.switch:	ldh	a,[sel_which]
		push	af
		ld	c,a
		and	3
		add	b
		cp	3
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,2
.aok:		ld	b,a
		ld	a,c
		and	$f0
		or	b
		ldh	[sel_which],a
		ld	[wSelected],a
		call	sel4disp
		pop	af
		call	sel4disp
		call	CpyAll
		jp	sel4loop

.bigswitch:	ldh	a,[sel_which]
		ld	c,a
		add	b
		and	$f0
		cp	NUMGAMES<<4
		jr	c,.aok2
		ld	a,0
		jr	z,.aok2
		ld	a,(NUMGAMES-1)<<4
.aok2:		ld	b,a
		ld	a,c
		and	15
		or	b
		ldh	[sel_which],a
		ld	[wSelected],a
		jp	practiceouter

sel4done:	or	a
		ret



Sel44:		xor	a
		call	sel4disp
		ld	a,1
		call	sel4disp
		ld	a,2
sel4disp:	and	15
		push	af
		inc	a
		call	ClrCenter
		pop	af
		ld	c,a
		ld	hl,sel4tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		call	GetString
		ld	hl,STRTEMP
		ld	a,32
		ld	[hli],a
		ld	a,c
		inc	a
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN+2
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,0
		ld	[hli],a
		ld	de,wString
		call	copyz

		ldh	a,[sel_which]
		swap	a
		and	15
		add	LOW(wLockState)
		ld	e,a
		ld	a,0
		adc	HIGH(wLockState)
		ld	d,a
		ld	a,[de]
		ld	d,c
		inc	d
.rlp:		srl	a
		dec	d
		jr	nz,.rlp
		jr	nc,.nocheck
		ld	a,128
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,2
		ld	[hli],a
		ld	a,ICON_CHECK
		ld	[hli],a
		xor	a
		ld	[hli],a
.nocheck:	ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		inc	a
		ret


;returns a=255 for B button (back)
;otherwise a=0
;b=subgame #
;c=skill level to play at
ChallengeReSel:	ld	a,[wSelected]
		jr	ChallengeAny
ChallengeSelect:
		xor	a
ChallengeAny:
		ldh	[sel_which],a

		call	CheckBBRam
		call	ChallengeSetup
challengeouter:
		call	challengename
		call	Sel64
		call	putarrows
		call	CpyAll
		call	FadeInBlack

sel6loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jr	nz,.switch
		ld	b,-16
		bit	JOY_L,c
		jr	nz,.bigswitch
		ld	b,1
		bit	JOY_D,c
		jr	nz,.switch
		ld	b,16
		bit	JOY_R,c
		jr	nz,.bigswitch
		bit	JOY_B,c
		ld	a,255
		jp	nz,sel6done
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel6loop
.done:		ldh	a,[sel_which]
		ld	[wSelected],a
		swap	a
		and	15
		ld	hl,subgamemap
		call	addahl
		ld	b,[hl]
		ldh	a,[sel_which]
		and	3
		ld	c,a
		xor	a
		jr	sel6done
.ref:		ldh	a,[sel_which]
		ld	[wSelected],a
		call	sel6disp
		jr	sel6loop

.switch:	ldh	a,[sel_which]
		push	af
		ld	c,a
		add	b
		and	$01
		ld	b,a
		ld	a,c
		and	$f0
		or	b
		ldh	[sel_which],a
		ld	[wSelected],a
		call	sel6disp
		pop	af
		call	sel6disp
		call	CpyAll
		jp	sel6loop

.bigswitch:	ldh	a,[sel_which]
		ld	c,a
		add	b
		and	$70
		ld	b,a
		ld	a,c
		and	15
		or	b
		ldh	[sel_which],a
		ld	[wSelected],a
		jp	challengeouter

sel6done:	or	a
		ret

SPACE6		EQU	3

Sel64:		xor	a
		call	sel6disp
		ld	a,1
		call	sel6disp
		xor	a
		call	showhigh
		ld	a,1
		jp	showhigh
sel6disp:	and	15
		push	af
		jr	z,.aok1
		ld	a,SPACE6
.aok1:		call	ClrCenter
		pop	af
		ld	c,a
		ld	hl,sel6tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
		or	a
		jr	z,.aok2
		ld	a,SPACE6
.aok2:		ld	b,a
		add	a
		add	a
		add	a
		add	b
		add	b	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
;		call	copyz
		ld	[hl],e
		inc	hl
		ld	[hl],d
		inc	hl
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLstN
		pop	af
		ld	l,a
		or	a
		jr	z,.aok3
		ld	a,SPACE6
.aok3:		ret




;high score struct
;16 bytes
;Stored in wHighScores
;00 = status on easy
;01 = status on medium
;02 = status on hard
;03 = Initial 0
;04 = Initial 1
;05 = Initial 2
;06 = High score lo
;07 = High score hi


HIGHLINE	EQU	1
showhigh:	push	af
		or	a
		jr	z,.aok1
		ld	a,SPACE6
.aok1:		add	HIGHLINE
		call	ClrCenter
		ld	e,a
		pop	bc
		push	af
		call	pickgmblite
		ld	a,[wSelected]
		and	$f0
		add	HI_SCORELO
		ld	c,a
		ld	a,b
		add	HIGH(wHighScores1)
		ld	b,a
		push	bc
		ld	a,[bc]
		ld	d,a
		inc	c
		ld	a,[bc]
		ld	b,a
		ld	c,d
		call	makeinfo
		ld	a,128+4+7+4	;3 letter initials X position
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,2
		ld	[hli],a

		pop	bc
		ldh	a,[sel_which]
		and	$f0
		add	HI_INIT1
		ld	c,a
		ld	a,[bc]
		inc	c
		add	ICON_ALPHABET
		ld	[hli],a
		ld	a,[bc]
		inc	c
		add	ICON_ALPHABET
		ld	[hli],a
		ld	a,[bc]
		inc	c
		add	ICON_ALPHABET
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	[hl],a
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		jp	CpyCenter

;bc=value to display
;e=line to display it on
makeinfo:	ld	hl,STRTEMP
		ld	a,24-2-4	;# and units x position
		ld	[hli],a
		ld	a,e
		add	a
		add	a
		add	a
		add	e
		add	e	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		xor	a
		ld	[hli],a
		push	bc
		call	decbcde
		push	hl
		ld	a,d
		swap	a
		and	15
		add	ICON_ZERO
		ld	[hli],a
		ld	a,d
		and	15
		add	ICON_ZERO
		ld	[hli],a
		ld	a,e
		swap	a
		and	15
		add	ICON_ZERO
		ld	[hli],a
		ld	a,e
		and	15
		add	ICON_ZERO
		ld	[hli],a
		ld	[hl],0
		pop	de
		ld	h,d
		ld	l,e
		ld	c,3
.kill0:		ld	a,[de]
		cp	ICON_ZERO
		jr	nz,.out
		inc	de
		dec	c
		jr	nz,.kill0
.out:		ld	a,[de]
		inc	de
		ld	[hli],a
		or	a
		jr	nz,.out
		dec	hl
		ld	a,ICON_REALSPACE
		ld	[hli],a
		pop	bc
		dec	bc
		ld	a,b
		or	c
		ld	bc,selunitsp
		jr	nz,.bcok
		ld	bc,selunits
.bcok:		ldh	a,[sel_which]
		swap	a
		and	15
		add	a
		add	c
		ld	c,a
		ld	a,0
		adc	b
		ld	b,a
		ld	a,[bc]
		inc	bc
		ld	e,a
		ld	a,[bc]
		ld	d,a
		push	bc
		push	hl
		call	GetString
		pop	hl
		pop	bc
		ld	de,wString
		call	copyz
		ret


decbcde:	ld	de,0
.todec:		sla	b
		sla	b
		push	bc
		ld	c,6
		call	.todecsome
		pop	bc
		ld	b,c
		ld	c,8
.todecsome:	ld	a,e
		sla	b
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
		jr	nz,.todecsome
		ret



ReloadGame::
		xor	a
		ld	[sel_which],a


		call	ClrAll
		call	pickolde
		ld	hl,sel8title
		call	DrawStringLstN
		call	picklite
		ld	a,128
		ld	[wStringL1Width],a
		ld	[wStringL2Width],a
		ld	[wStringL3Width],a

		ld	de,190
		call	GetString
		call	SplitString

		ld	hl,sel8title2
		call	DrawStringLstP
		call	Sel84
		call	CpyAll

sel8loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_U,c
		jr	nz,.switch
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel8loop
.done:		ldh	a,[sel_which]
		jr	sel8done
.ref:		ldh	a,[sel_which]
		call	sel8disp
		jr	sel8loop

.switch:	ldh	a,[sel_which]
		push	af
		xor	1
		ldh	[sel_which],a
		call	sel8disp
		pop	af
		call	sel8disp
		jp	sel8loop

sel8done:	ret



Sel84:		xor	a
		call	sel8disp
		ld	a,1
sel8disp:	add	2
		call	ClrTop
		sub	2
		ld	c,a
		ld	hl,sel8tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		call	GetString
		ld	de,wString
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
		add	2
		ld	c,a
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		call	copyz
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLst
		pop	af
		add	2
		jp	CpyTop


OptionsMenu::
		xor	a
		ldh	[sel_which],a

optionsrestart:

		call	lockmask
		ldh	[sel_type],a
		call	pickolde
		call	ClrAll
		ld	hl,sel9title
		call	DrawStringLstN
		call	Sel94
		call	CpyAll

sel9loop:	call	WaitForVBL
		ldh	a,[sel_which]
		cp	2
		jr	z,.quiet
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		jr	.noisy
.quiet:		call	ReadJoypad
.noisy:		call	ProcAutoRepeat
		ld	a,[wJoy1Cur]
		bit	JOY_START,a
		jr	z,.nocredits
		bit	JOY_SELECT,a
		jr	z,.nocredits
		bit	JOY_L,a
		jr	z,.nocredits
		ldh	a,[sel_which]
		dec	a
		jr	nz,.nocredits
		jr	.credits
.nocredits:	ld	a,[wJoy1Hit]
		ld	c,a
		ld	b,-1
		bit	JOY_U,c
		jp	nz,.switch
		bit	JOY_L,c
		jr	nz,.change
		ld	b,1
		bit	JOY_D,c
		jp	nz,.switch
		bit	JOY_R,c
		jr	nz,.change
		bit	JOY_B,c
		ld	a,255
		jp	nz,sel9done
		bit	JOY_A,c
		jr	nz,.doit
		bit	JOY_START,c
		jr	nz,.doit
		jr	sel9loop
.done:		ldh	a,[sel_which]
		jp	sel9done

.doit:		ldh	a,[sel_which]
		cp	1
		jr	z,.bbram
		cp	2
		jr	z,.songsfx
		IF	VERSION_EUROPE
		cp	4
		ELSE
		cp	3
		ENDC
		jr	z,.credits
		jr	sel9loop
.credits:	call	shutdownbitmap
		ld	a,1	;allow exit at any time
		call	Dance_b
		call	SelectSetup
		jp	OptionsMenu

.bbram:		call	ClearMenu
		jp	OptionsMenu

.songsfx:	xor	a
		call	InitTune
		ld	a,[wSndEffect]
		cp	MAXTUNE+1
		jr	nc,.soundfx
.song:		ld	a,[wSndEffect]
		call	InitTune
		jp	sel9loop
.soundfx:	ld	a,[wSndEffect]
		sub	MAXTUNE
		call	InitSfx
		jp	sel9loop

.change:	ldh	a,[sel_which]
		IF	VERSION_EUROPE
		cp	3
		ld	d,5
		ld	hl,wLanguage
		jr	z,.add2
		ENDC
		cp	2
		ld	d,MAXSFX+MAXTUNE+1
		ld	hl,wSndEffect
		jr	z,.add
		or	a
		jp	nz,sel9loop
		ld	a,[wMusicOff]
		or	a
		ld	a,0
		jr	nz,.aok2
		dec	a
.aok2:		ld	[wMusicOff],a
		jr	.ref
.add2:		call	.doadd
		call	HashLanguage
		jp	optionsrestart
.add:		call	.doadd
		cp	255
		call	nz,CpyTop
		jp	sel9loop
.doadd:		ld	a,b
		add	[hl]
		cp	255
		ret	z
		cp	d
		ld	a,255
		ret	z
		ld	a,b
		add	[hl]
		ld	[hl],a
		ldh	a,[sel_which]
		jp	sel9disp
.ref:		ldh	a,[sel_which]
		call	sel9disp
		call	CpyTop
		jp	sel9loop

.switch:	ldh	a,[sel_type]
		cp	7
		IF	VERSION_EUROPE
		ld	c,4
		ELSE
		ld	c,3
		ENDC
		jr	nz,.cok
		inc	c
.cok:		ldh	a,[sel_which]
		push	af
		add	b
		cp	c
		jr	c,.aok
		ld	a,0
		jr	z,.aok
		ld	a,c
		dec	a
.aok:		ldh	[sel_which],a
		call	sel9disp
		pop	af
		call	sel9disp
		call	CpyAll
		jp	sel9loop

sel9done:	ret



Sel94:		xor	a
		call	sel9disp
		ld	a,1
		call	sel9disp
		ld	a,2
		call	sel9disp
		IF	VERSION_EUROPE
		ld	a,3
		call	sel9disp
		ldh	a,[sel_type]
		cp	7
		ret	nz
		ld	a,4
		ELSE
		ldh	a,[sel_type]
		cp	7
		ret	nz
		ld	a,3
		ENDC
sel9disp:	push	af
		call	ClrTop
		pop	af
		ld	c,a
		ld	hl,sel9tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		cp	2
		jr	nz,.notsongsfx
		ld	a,[wSndEffect]
		cp	MAXTUNE+1
		jr	c,.notsongsfx
		inc	de
.notsongsfx:	call	pickfont
		ld	hl,STRTEMP
		ld	a,16
		ld	[hli],a
		ld	a,c
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,0
		ld	[hli],a
		ld	[hl],e
		inc	hl
		ld	[hl],d
		inc	hl
		ld	[hl],0
		ld	hl,STRTEMP
		push	bc
		call	DrawStringLstN
		pop	bc
		ld	hl,STRTEMP
		call	special9
		ld	[hl],0
		ld	hl,STRTEMP
		ld	a,[hl]
		or	a
		call	nz,DrawStringLst
		pop	af
		ret
;		jp	CpyTop

special9:	ld	a,c
		or	a
		jr	z,.musiconoff
		cp	2
		jr	z,.songsfxnum
		IF	VERSION_EUROPE
		cp	3
		jr	z,.language
		ENDC
		ret
.language:	call	.rjust
		push	bc
		push	hl
		ld	de,203
		call	GetString
		pop	hl
		pop	bc
		ld	de,wString
		jp	copyz

.songsfxnum:	call	.rjust
		ld	a,[wSndEffect]
		jr	.num
.num:		call	dec30
		xor	a
		ld	[hli],a
		ret
.musiconoff:	call	.rjust
		ld	a,[wMusicOff]
		or	a
		ld	de,97	;ON
		jr	z,.deok
		ld	de,98	;OFF
.deok:		push	hl
		call	GetString
		pop	hl
		ld	de,wString
		jp	copyz

.rjust:		ld	a,144
		ld	[hli],a
		ld	a,[STRTEMP+1]
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,2
		ld	[hli],a
		ret
;hl=where to put ascii dec out with leading zeros
;a=dec #
dec30::		cp	100
		jr	c,.less100
		cp	200
		jr	c,.less200
		ld	[hl],"2"
		sub	200
		jr	.dec20
.less200:	ld	[hl],"1"
		sub	100
		jr	.dec20
.less100:	ld	[hl],ICON_ZERO
.dec20:		inc	hl
		ld	[hl],ICON_ZERO-1
.dig1:		inc	[hl]
		sub	10
		jr	nc,.dig1
		add	ICON_ZERO+10
		inc	hl
		ld	[hli],a
		ret


ClearMenu::
		xor	a
		ld	[sel_which],a

		call	pickolde

		call	ClrAll

		ld	a,144
		ld	[wStringL1Width],a
		ld	[wStringL2Width],a
		ld	[wStringL3Width],a
		ld	de,100
		call	GetString
		call	SplitString
		ld	hl,sel10title
		call	DrawStringLstP
		call	Sel104
		call	CpyAll

sel10loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_U,c
		jp	nz,.switch
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_B,c
		ret	nz
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	nz,.switch
		jr	sel10loop
.done:		ldh	a,[sel_which]
		or	a
		ret	z
		jp	ReInitBBRam

.switch:	ldh	a,[sel_which]
		push	af
		xor	1
		ldh	[sel_which],a
		call	sel10disp
		pop	af
		call	sel10disp
		jp	sel10loop



Sel104:		xor	a
		call	sel10disp
		ld	a,1
sel10disp:	push	af
		add	2
		call	ClrTop
		pop	af
		ld	c,a
		ld	hl,sel10tab
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	e,[hl]
		inc	hl
		ld	d,[hl]
		push	af
		call	pickfont
		ld	hl,STRTEMP
		ld	a,80
		ld	[hli],a
		ld	a,c
		add	2
		add	a
		add	a
		add	a
		add	c
		add	c	;x10
		add	LINEDOWN+4
		ld	[hli],a
		xor	a
		ld	[hli],a
		ld	a,1
		ld	[hli],a
		ld	a,e
		ld	[hli],a
		ld	a,d
		ld	[hli],a
		ld	[hl],0
		ld	hl,STRTEMP
		call	DrawStringLstN
		pop	af
		add	2
		jp	CpyTop



QuitVerify::
		xor	a
		ld	[sel_which],a

		call	pickolde

		call	ClrAll
		ld	hl,sel11title
		call	DrawStringLstN
		call	Sel104
		call	CpyAll

sel11loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_U,c
		jp	nz,.switch
		bit	JOY_D,c
		jr	nz,.switch
		bit	JOY_B,c
		jp	nz,.ret0
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	nz,.switch
		jr	sel11loop
.done:		ldh	a,[sel_which]
		ret
.ret0:		xor	a
		ret

.switch:	ldh	a,[sel_which]
		push	af
		xor	1
		ldh	[sel_which],a
		call	sel10disp
		pop	af
		call	sel10disp
		jp	sel11loop



PauseMenu::
		call	SetBitmap20x18
		ld	hl,IDX_BPAUSEDPKG	;bpausedpkg
		ld	de,IDX_CPAUSEDPKG	;cpausedpkg
		call	XferBitmap

		call	pickolde
		ld	hl,pausetitle
		call	DrawStringLstN

		call	DmaBitmap20x18
		ld	de,$9800
		call	DumpShadowAtr

		call	FadeInBlack

		xor	a
		ld	[wTempSelect],a

sel5loop:	call	WaitForVBL
		ld	a,PADNOISENORMAL
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		ld	c,a
		bit	JOY_A,c
		jr	nz,.done
		bit	JOY_START,c
		jr	nz,.done
		bit	JOY_SELECT,c
		jr	z,sel5loop
.done:		ld	a,[wTempSelect]
		jr	sel5done


sel5done:	push	af
		call	shutdownbitmap
		pop	af
		ret


PresetHighs::
		ld	de,hightab1
		ld	hl,wHighScores1
		call	preset1
		ld	de,hightab2
		ld	hl,wHighScores2
preset1:	ld	c,8
preset1lp:	ld	a,l
		add	HI_SCORELO
		ld	l,a
		ld	a,[de]
		inc	de
		ld	[hl],a
		ld	a,l
		and	$f0
		add	HI_INIT1
		ld	l,a
		ld	a,[de]
		inc	de
		sub	"a"
		ld	[hli],a
		ld	a,[de]
		inc	de
		sub	"a"
		ld	[hli],a
		ld	a,[de]
		inc	de
		sub	"a"
		ld	[hli],a
		ld	a,l
		add	15
		and	$f0
		ld	l,a
		dec	c
		jr	nz,preset1lp
		ret



;easy challenge
hightab1:	db	2,"dav"	;must be in lower case
		db	2,"rob"
		db	2,"rog"
		db	2,"jam"
		db	2,"jcb"
		db	2,"crs"
		db	2,"ren"
		db	2,"dan"

;hard challenge
hightab2:	db	2,"ash"
		db	2,"hem"
		db	2,"har"
		db	2,"max"
		db	2,"reg"
		db	2,"lam"
		db	2,"joh"
		db	2,"win"


;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************


doshell::
		xor	a
		ld	[wTune],a
		ld	[wSndEffect],a
		call	InitTune
		xor	a
		ld	[wTempSelect],a

		call	PickLanguage

		if	SHOWCOPYRIGHT	;COPYRIGHT + TITLE STUFF

		ld	hl,IDX_BNINPKG	;bninpkg
		ld	de,IDX_CNINPKG	;cninpkg
		call	SingleScreen

		call	testabort

		call	Disney_b

		call	testabort

		ld	hl,IDX_BLEFTPKG	;bleftpkg
		ld	de,IDX_CLEFTPKG	;cleftpkg
		call	SingleScreen

		call	testabort

		ld	hl,IDX_BLEGALPKG	;blegalpkg
		ld	de,IDX_CLEGALPKG	;clegalpkg
		call	LegalScreen

		call	testabort

		ld	hl,titlescreens
		ld	a,[wLanguage]
		add	a
		add	a
		call	addahl
		ld	a,[hli]
		ld	e,a
		ld	a,[hli]
		ld	d,a
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
;		ld	hl,IDX_BDTITLEPKG	;bdtitlepkg
;		ld	de,IDX_CDTITLEPKG	;cdtitlepkg
		call	SingleScreen

		endc

;		call	Kiss_b
;		call	Fire_b

;		ld	a,GAME_SPIT
;		call	LaunchGame

		jp	shell1

testabort:	ld	a,[wAvoidIntro]
		or	a
		ret	z
		ld	a,[wJoy1Hit]
		and	$f0
		jr	nz,.abort
		call	WaitForVBL
		call	ReadJoypad
		ld	a,[wJoy1Cur]
		and	$f0
		jr	nz,.abort
		ret
.abort:		add	sp,2
		jp	shell1

titlescreens:
		IF	VERSION_USA
		dw	IDX_CDTITLEPKG	;cdtitlepkg
		dw	IDX_BDTITLEPKG	;bdtitlepkg
		ENDC
		IF	VERSION_JAPAN
		dw	IDX_CJAPANPKG	;cjapanpkg
		dw	IDX_BJAPANPKG	;bjapanpkg
		ENDC
		IF	VERSION_EUROPE
		dw	IDX_CDTITLEPKG	;cdtitlepkg
		dw	IDX_BDTITLEPKG	;bdtitlepkg
		dw	IDX_CGERMANPKG	;cgermanpkg
		dw	IDX_BGERMANPKG	;bgermanpkg
		dw	IDX_CFRENCHPKG	;cfrenchpkg
		dw	IDX_BFRENCHPKG	;bfrenchpkg
		dw	IDX_CITALIANPKG	;citalianpkg
		dw	IDX_BITALIANPKG	;bitalianpkg
		dw	IDX_CSPANISHPKG	;cspanishpkg
		dw	IDX_BSPANISHPKG	;bspanishpkg
		ENDC

;a=game # as defined in equates.equ
LaunchGame::
		add	a
		ld	c,a
		ld	b,0
		di
		SETLYC	LycNormal
		SETVBL	VblNormal
		ld	a,255
		ldio	[rLYC],a
		ei
		push	bc
		srl	c
		ld	hl,gameflags
		add	hl,bc
		ld	a,[hl]
		bit	0,a
		call	nz,LevelSelect
		pop	bc
		push	bc

		ld	a,[wSubLevel]
		cp	3
		jr	nc,shellret2
		ld	hl,gameintros
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		IF	TRACE_BOARD
		ELSE
		call	nz,TalkingHeads
		ENDC

shellret2:	pop	bc
		push	bc
		ld	hl,shellret
		push	hl
		ld	hl,gamelist
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		IF	TRACE_BOARD
		ELSE
		push	hl
		ENDC
		xor	a
		ld	[wSubStage],a
		ld	[wSubGaston],a
		xor	a
		ld	[wScoreLo],a
		ld	[wScoreHi],a
		ld	hl,hTemp48
		ld	bc,48
		jp	MemClear

shellret:	pop	bc

ShowGameResult::ld	hl,gamenames
		add	hl,bc
		ld	a,[hli]
		ld	d,[hl]
		ld	e,a
		call	GetString
		ld	hl,wString
		ld	de,NAMECOPY
.strcpy:	ld	a,[hli]
		ld	[de],a
		inc	e
		or	a
		jr	nz,.strcpy
		ld	a,[wSubLevel]
		cp	3
		ret	nc
		srl	c
		ld	hl,gameflags
		add	hl,bc
		ld	a,[hl]
		ld	hl,NAMECOPY
		bit	1,a
		jp	nz,LevelResult
		bit	2,a
		jp	nz,LevelResultT
		bit	3,a
		jp	nz,LevelResultM
		bit	4,a
		jp	nz,LevelResultS
		ret


;a=game # as defined in equates.equ

LaunchGaston::	add	a
		ld	c,a
		ld	b,0
		di
		SETLYC	LycNormal
		SETVBL	VblNormal
		ld	a,255
		ldio	[rLYC],a
		ei

		IF	1	;INTRO
		push	bc
		ld	hl,miniintros
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		call	nz,TalkingHeads
		pop	bc
		ENDC

		ld	hl,gamelist
		add	hl,bc
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		push	hl
		ld	a,2
		ld	[wSubGaston],a
		ld	[wSubStage],a
		xor	a
		ld	[wScoreLo],a
		ld	[wScoreHi],a
		ld	hl,hTemp48
		ld	bc,48
		jp	MemClear


nothing:	ret



gamelist:	dw	nothing
		dw	sultan_b
		dw	chip_b
		dw	TargetRange_b
		dw	BelleRide_b
		dw	Whack_b
		dw	Chopper_b
		dw	Concentration_b
		dw	Stove_b
		dw	TriviaGame_b
		dw	Spit_b
		dw	Cellar_b

gameflags:	db	0	;nothing
		db	3	;Sultan
		db	3	;Chip
		db	3	;Targetrange
		db	3	;Belleride
		db	3	;Whack
		db	3	;Chopper
		db	0+$08	;Concentration
		db	3	;Stove
		db	0+$04	;Trivia
		db	0+$10	;Spit
		db	3	;Cellar

gameintros:	dw	0
		dw	IntroSultan
		dw	IntroChip
		dw	IntroTarget
		dw	IntroRide
		dw	IntroWhack
		dw	IntroChopper
		dw	IntroMind
		dw	IntroStove
		dw	IntroTrivia
		dw	IntroSpit
		dw	IntroCellar

miniintros:	dw	0
		dw	RulesSultan
		dw	RulesChip
		dw	RulesTarget
		dw	RulesRide
		dw	RulesWhack
		dw	RulesChopper
		dw	0
		dw	RulesStove
		dw	0
		dw	0
		dw	RulesCellar

gamenames::	dw	0
		dw	157	;POOCHY PAW PRINTS
		dw	158	;WHERE'S CHIP?
		dw	156	;LE FOU'S GALLERY
		dw	152	;BELLE'S RIDE
		dw	153	;BEAST'S BATTLE
		dw	154	;CRAZY CHOPPER
		dw	161	;MATCHING SQUARES
		dw	155	;MRS. POTTS' PERIL
		dw	160	;COGSWORTH'S TRIVIA
		dw	162	;GASTON'S SPITTOONS
		dw	159	;LUMIERE'S LEAKS

subnames::	dw	152	;BELLE'S RIDE
		dw	153	;BEAST'S BATTLE
		dw	154	;CRAZY CHOPPER
		dw	155	;MRS. POTTS' PERIL
		dw	156	;LE FOU'S GALLERY
		dw	157	;POOCHY PAW PRINTS
		dw	158	;WHERE'S CHIP?
		dw	159	;LUMIERE'S LEAKS
		dw	161	;MATCHING SQUARES
		dw	162	;GASTON'S SPITTOONS

subgamemap:	db	GAME_RIDE
		db	GAME_BEAST
		db	GAME_CHOPPER
		db	GAME_STOVE
		db	GAME_SHOOTING
		db	GAME_SULTAN
		db	GAME_CHIP
		db	GAME_CELLAR
		db	GAME_MIND
		db	GAME_SPIT

selunits:	dw	168	;PACES
		dw	170	;WOLF
		dw	227	;LOGS ***
		dw	228	;FLAMES ***
		dw	229	;TARGETS ***
		dw	230	;STEPS ***
		dw	176	;SHUFFLE
		dw	177	;DRIPS

selunitsp:	dw	168	;PACES
		dw	169	;WOLVES
		dw	171	;LOGS
		dw	172	;FLAMES
		dw	173	;TARGETS
		dw	174	;STEPS
		dw	175	;SHUFFLES
		dw	177	;DRIPS



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

BANK03_END::

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BANK03.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



