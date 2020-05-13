; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** RAM.ASM                                                        MODULE **
; **                                                                       **
; ** Variables, Structures and Data Tables.                                **
; **                                                                       **
; ** Last modified : 02 Apr 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



		INCLUDE	"equates.equ"



;############################################################################
;############################################################################
;############################################################################
;
; CARTRIDGE WORK RAM ($A000-$BFFF)
;
;############################################################################
;############################################################################
;############################################################################

		bss	$a000

bKey::		DS	8
bMusicOff	DS	1
bLanguage::	DB
bLocks::	DS	24
bMenus::	DS	16
bHighScores::	DS	8*5*20
bHighPage::	DB
bLanguageHash::	DB
bVariableMax::	DS	0

;############################################################################
;############################################################################
;############################################################################
;
; EXTERNAL WORK RAM ($C000-$DFFF)
;
;############################################################################
;############################################################################
;############################################################################

;
;
;

		section 00
		bss	$c000

wOamShadow::	ds	$a0
		ds	$60
wStackPointer::

wBcpShadow::	DS	8*4*2
wOcpShadow::	DS	8*4*2
wBcpArcade::	DS	8*4*2
wOcpArcade::	DS	8*4*2
wTblColorFade::	DS	32
wBcpArcadeTop::	DS	1*4*2
wBcpArcadeBtm::	DS	1*4*2
wPanelRGB::	DS	8*4*2

		DS	20
wSprDumpStack::	DS	0
;
wStructSmod::
wJmpVblVector::	DS	1
wVblVector::	DS	2
wJmpLycVector::	DS	1
wLycVector::	DS	2
;
wChrFinish::	DS	5
;
wJmpTemporary::	DS	3
wJmpDraw::	DS	3
;
;
wFadeUpCount::	DB
wFadeDnCount::	DB
wFadeOffset::	DB
wFadeWanted::	DB
;
wFileAddr::	DW
wFileBank::	DB
;
wSprPlotSP::	DW
wSprDumpSP::	DW

wTmpSP::	DW
;
wJoy1Dir::	DB;Joypad direction 0-8.
wJoy1Cur::	DB;Joypad current bits.
wJoy1Hit::	DB;Joypad just-pressed bits.
wJoy1Rpt::	DS	4
;
wFontLo::	DB
wFontHi::	DB
wFontPal::	DB
wFontPalXor::	DB
wStringX::	DB
wStringY::	DB
wStringW::	DB
wStringH::	DB
wStringT::	DB
wFontStrideLo::	DB
wFontStrideHi::	DB
;
;
wBoxX::		DB
wBoxY::		DB
wBoxW::		DB
wBoxH::		DB
;
;
wFigCount::	DB
wFigTake::	DB
wFigPhase::	DB
wPalCount::	DB
wPalStart::	DB
;
wTune::		DB
wSndEffect::	DB
;
wWantToPause::	DB
;
wTempSelect::	DB
;

wAvoidIntro::	db

wShellVect::	ds	4
wShellAcc::	db
wRandTake::	db
wRandomBlock::	ds	55

wMapXSize::	db
wMapYSize::	db

wMapXPos::	dw
wMapYPos::	dw

wMapDown::	db
wMapDirty::	ds 6
wVideoBank::	db

wTime::		db

wSelected::	db

wFinished::	db

;
wString::	DS	64
;

;
wPinInfo::
wPinJmpHit::	DS	3	;do not change order
wPinJmpProcess:: DS	3	;
wPinJmpSprites:: DS	3	;
wPinJmpHitFlipper:: DS 3	;
wPinJmpHitBumper:: DS	3	;
wPinJmpScore::	DS	3	;
wPinJmpLost::	DS	3	;
wPinJmpEject::	DS	3	;
wPinJmpChainRet:: DS	3	;
wPinJmpDone::	DS	3	;
wPinCutoff::	DS	2	;
wPinLeftSet::	DS	2	;
wPinRightSet::	DS	2	;
wPinHitBank::	DS	1	;
wPinCharBank::	DS	1	;
wPinInfoEnd::
;

;
;
wActivePlayer::	DB
wNumPlayers::	DB
wStartHappy::	DB

wMainSelected::	DB

wLastMsg::	DW

wDemoMode::	DB
wDemoL::	DB
wDemoR::	DB

wFunZone::	DB
wThrillZone::	DB

wSpeed::	DB

wSubCompleted::	DB

wTiltCount::	DB
wTiltTimes::	DS	32

wGotHigh::	DB

wShellLastVariable::


;
;
; $C600-$C9FF
;


		BSS	$c600


SprDumpLoop::	DS	256	;$c1 bytes	;* Self-modifying code.

wOamBuffer::	DS	256			;* Ring-buffer for attributes.

wTemp512::	DS	512			;*


		bss	$d000		;this is in work bank 7

;  WorkRam Bank 8 of 8

wAtrShadow::	DS	32*32			;$D000
wAtrDecode::	DS	32*32			;$D400

		bss	$d000		;this is in work bank 0

wTemp1024::	DS	1024
wBalls::	DS	58	;Align on page boundary!!!
wBallCount::	DB
wWarps::	DS	4
wWarp::		DB
wScore::	DS	12
wLastJack::	DS	12
wScoreBackup::	DS	12
wSubScore::	DS	12
wStates::	DS	128

wStore1::	DS	384
wStore2::	DS	384
wStore3::	DS	384
wStore4::	DS	384
wStore0::	DS	384

wMessage::	DS	128
wMessages::	DS	40*4
wChances::	DS	256

;
;
;



;############################################################################
;############################################################################
;############################################################################
;
; INTERNAL WORK RAM ($FF80-$FFFE)
;
;############################################################################
;############################################################################
;############################################################################

		bss	$ff80
;
; Temporary workspace for SubGames.
;

hTemp48::	DS	48

;
; Interrupt control variables.
;

hRomBank::	DB;Currently selected ROM bank.
hRamBank::	DB;Currently selected RAM bank.
hWrkBank::	DB;Currently selected WRK bank (CGB only).
hVidBank::	DB;Currently selected VID bank (CGB only).

hOamFlag::	DB;Set flag to dump OAM ram during VBL.
hPalFlag::	DB;Set flag to dump colours during VBL.
hPosFlag::	DB;Set flag

hOamPointer::	DB;High-byte of address of OAM shadow buffer.

hVblBank::	DB;ROM bank preserved during VBL.
hVblFlag::	DB;VBL sets flag to mark VBL.
hVblCount::	DB;VBL counter.
hVblLCDC::	DB;LCDC value to set during VBL.
hVblSCX::	DB;SCX value to set during VBL.
hVblSCY::	DB;SCY value to set during VBL.
hVbl8::		DB;Vbl counter, increments by 8 for accuracy...

hLycLCDC::	DB;LCDC value to set during LYC.

hWndY::		DB;

hCycleCount::	DB;Counter for synchronizing stuff.

;
; Joypad status variables.
;

hPadDir::	DB;Joypad direction 0-8.
hPadCur::	DB;Joypad current bits.
hPadHit::	DB;Joypad just-pressed bits.

;
; Temporary variables.
;

hTmpLo::	DB
hTmpHi::	DB
hTmp2Lo::	DB
hTmp2Hi::	DB
hTmp3Lo::	DB
hTmp3Hi::	DB
hTmp4Lo::	DB
hTmp4Hi::	DB

;
; Sprite plotting variables.
;

hSprXLo::	DB;
hSprXHi::	DB;
hSprYLo::	DB;
hSprYHi::	DB;
hSprPal::	DB;
hSprNxt::	DB;
hSprMax::	DB;
hSprCnt::	DB;

hOamBufLo::	DB;
hOamBufHi::	DB;

;

hCutoff::	DB	;don't do XFERs if LYC below this line (DumpSmod)


		bss	$fff6
hOamXfer::	DS	8			;$08 bytes self-modifying code.
hMachine::	DB


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF RAM.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

