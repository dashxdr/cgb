:; ***************************************************************************
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
		DS	12			;N.B. Must allow >=2 for stack.
wMzChannel1::	DS	42+12			;CHANNEL_LENGTH
wMzChannel2::	DS	42+12			;CHANNEL_LENGTH
wMzChannel3::	DS	42+12			;CHANNEL_LENGTH
wMzChannel4::	DS	42+12			;CHANNEL_LENGTH
wFxChannel1::	DS	42+12			;CHANNEL_LENGTH
wFxChannel2::	DS	42+12			;CHANNEL_LENGTH
wFxChannel3::	DS	42+12			;CHANNEL_LENGTH
wFxChannel4::	DS	42			;CHANNEL_LENGTH
wMzSP::		DW
wMzNumber::	DB				;Number of tune playing.
wFxNumber::	DB				;Number of FX playing.
wMzPlaying::	DB				;Default to OFF.
wMzWavePtr::	DW
wMzBank::	DB
wMzRefresh::	DS	3
wMzShift::	DB

;
wFadeUpCount::	DB
wFadeDnCount::	DB
wFadeVblBGP::	DB
wFadeLycBGP::	DB
wFadeOBP0::	DB
wFadeOBP1::	DB
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
wCelsPerFrame::	DB
wPalCount::	DB
wPalStart::	DB
wGroupCount::	DB
;wGroups::	DS	8*4	;MAX of 4 groups
wGroup1::	DB
wGroup2::	DB
wGroup3::	DB
wGroup4::	DB
wGroup5::	DB
wGroup6::	DB
wGroup7::	DB
wGroup8::	DB
;
wTune::		DB
wSndEffect::	DB
;
wWantToPause::	DB
;
wTempSelect::	DB
;
wChrUsedLo::	DB
wChrUsedHi::	DB
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

;
wString::	DS	64
;

;
wPinInfo::
wPinJmpHit::	DS	3	;do not change order
wPinJmpProcess:: DS	3	;
wPinJmpSprites:: DS	3	;
wPinJmpHitFlipper:: DS 3	;
wPinJmpPerBall:: DS	3	;
wPinJmpHitBumper:: DS	3	;
wPinJmpScore::	DS	3	;
wPinJmpLost::	DS	3	;
wPinJmpEject::	DS	3	;
wPinJmpChainRet:: DS	3	;
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
wNumBalls::	DB
wHappyMode::	DB
wStartHappy::	DB

wMainSelected::	DB

wLastMsg::	DW

wWave::		DB

wPrinterState::	DB
wPrinterPossible:: DB

wDemoMode::	DB
wDemoL::	DB
wDemoR::	DB

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
wMessageList::	DS	512
wBalls::	DS	63	;Align on page boundary!!!
wBallCount::	DB
wScore::	DS	12
wLastJack::	DS	12
wStates::	DS	64

wStore1::	DS	384
wStore2::	DS	384
wStore3::	DS	384
wStore4::	DS	384
wStore0::	DS	384
wMessage::	DS	128

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
hVblBGP::	DB;BGP value to set during VBL.
hVblOBP0::	DB;OBP0 value to set during VBL.
hVblOBP1::	DB;OBP1 value to set during VBL.
hVblSCX::	DB;SCX value to set during VBL.
hVblSCY::	DB;SCY value to set during VBL.
hVbl8::		DB;Vbl counter, increments by 8 for accuracy...

hLycLCDC::	DB;LCDC value to set during LYC.
hLycBGP::	DB;BGP value to set during LYC.

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
x
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
;
;

hIntroSeqLo::	DB
hIntroSeqHi::	DB
hIntroPkgLo::	DB
hIntroPkgHi::	DB
hIntroRtsLo::	DB
hIntroRtsHi::	DB
hIntroDone::	DB
hIntroDelay::	DB
hIntroFlags::	DB
hIntroBlit::	DS	4

;
;
;


hChannelVol::	DB
hShadowNR12::	DB
hShadowNR22::	DB
hShadowNR32::	DB
hShadowNR42::	DB
hActualNR32::	DB


;
;
;

hCutoff::	DB	;don't do XFERs if LYC below this line (DumpSmod)

;
;
;

EZERO::		DB

;
;
;

		bss	$fff5

hOamXfer::	DS	8			;$08 bytes self-modifying code.
hSgb::		DB
hMachine::	DB


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF RAM.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
