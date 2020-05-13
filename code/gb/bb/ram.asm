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

;		SECTION	"lram0",BSS[$C000]
		section 0
		bss	$c000

		DS	64
		DS	32
wStackPointer::	DS	0
		DS	20
wSprDumpStack::	DS	0
;
wStructSmod::	DB
wJmpVblVector::	DS	1
wVblVector::	DS	2
wJmpLycVector::	DS	1
wLycVector::	DS	2
wJmpFadeColor::	DS	3
wJmpXferColor::	DS	3
wJmpSprLRTB::	DS	3
wJmpSprRLTB::	DS	3
wJmpSprDumpMod::DS	3
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
wFontFlg::	DB
wFontLo::	DB
wFontHi::	DB
wFontPal::	DB
wFontPalXor::	DB
wStringX::	DB
wStringY::	DB
wStringW::	DB
wStringH::	DB
wStringT::	DB
;
wBoxX::		DB
wBoxY::		DB
wBoxW::		DB
wBoxH::		DB
;
wFocusPlyr::	DB
wPlyrMoves::	DB
wFrontPlyr::	DB
wFrontLoop::	DB
;
wSubChoose::	DB
wSubGaston::	DB
wSubLevel::	DB
wSubStage::	DB
wSubAward::	DB
wSubStars::	DB
wSubPhrase::	DB
wSubCount::	DB
;
wTriviaSpeed::	DB
wTriviaRight::	DB
;
wFigCount::	DB
wFigTake::	DB
wFigPhase::	DB
wCelsPerFrame::	DB
wPalCount::	DB
wPalStart::	DB
wGroupCount::	DB
wGroups::	DS	8*4	;MAX of 4 groups
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
wParallax0::	DB
wParallax1::	DB
wParallax2::	DB
;
wWantToPause::	DB
;
wTempSelect::	DB
;
wChrUsedLo::	DB
wChrUsedHi::	DB
;
wShellBank::	db

wAvoidIntro::	db

wShellVect::	ds	4
wShellAcc::	db
wRandTake::	db
wRandomBlock::	ds	55
wShellSound::	db

wGmbPal2::	db

wScoreLo::	db
wScoreHi::	db
wChallenge::	db

wSelected::	db

wBoardMz::	db

wRowCnt::	DB
wColCnt::	DB
wRowTmp::	DB
wColTmp::	DB

;
;
;
wShellLastVariable::

;
;
; $C300-$C7FF
;

;		SECTION	"lram_c300",BSS[$C300]
		bss $c300

wOamShadow::	DS	$A0			;* Buffer for OAM DMA.
wChrXfer::	DS	$60			;  Self-modifying code.

SprDumpLoop::	DS	256			;* Self-modifying code.

wOamBuffer::	DS	256			;* Ring-buffer for attributes.

wTemp512::	DS	512			;*

;
; $C800-$CFFF
;

;		SECTION "lram_c800",BSS[$C800]
		bss	$c800

;
; $D000-$DFFF
;
;  WorkRam Bank 1 of 8 - map data
;  WorkRam Bank 2 of 8 - map attr
;  WorkRam Bank 3 of 8 - palettes

;		SECTION	"lram_d000",BSS[$D000]
		bss	$d000

;wMapData::	DS	0			;^ Arcade map data (80*50).

;  WorkRam Bank 3 of 8

wAtrShadow::	DS	32*32			;$D000
wAtrDecode::	DS	32*32			;$D400

wBcpShadow::	DS	8*4*2			;$D800
wOcpShadow::	DS	8*4*2			;$D840
wBcpArcade::	DS	8*4*2			;$D880
wOcpArcade::	DS	8*4*2			;$D8C0
wTblColorFade::	DS	32			;$D900
wBcpArcadeTop::	DS	1*4*2			;$D920
wBcpArcadeBtm::	DS	1*4*2			;$D928

wCmapSwap::	DS	8*4*2			;$D230 used in bank07 (DA)

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

;		SECTION	"hramlo",HRAM[$FF80]
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

;		SECTION	"hramhi",HRAM[$FFF5]
		bss	$fff5

hOamXfer::	DS	8			;$08 bytes self-modifying code.
hSgb::		DB
hMachine::	DB

;
;
;

;
; Scrolling variables that aren't used, but I don't want to
; lose track of them.
;
;wMapXOrgLo:	DB
;wMapXOrgHi:	DB
;wMapYOrgLo:	DB
;wMapYOrgHi:	DB
;wMapXMinLo:	DB;Minimum ScrX value.
;wMapXMinHi:	DB
;wMapYMinLo:	DB;Minimum ScrY value.
;wMapYMinHi:	DB
;wMapXMaxLo:	DB;Maximum ScrX value.
;wMapXMaxHi:	DB
;wMapYMaxLo:	DB;Maximum ScrY value.
;wMapYMaxHi:	DB
;wCamScrXLo:	DB
;wCamScrXHi:	DB
;wCamScrYLo:	DB
;wCamScrYHi:	DB
;
;hScrXLo::	DB
;hScrXHi::	DB
;hScrYLo::	DB
;hScrYHi::	DB
;hScxBlk::	DB
;hScyBlk::	DB
;hScxChg::	DB
;hScyChg::	DB
;hScxScrLo::	DB
;hScxScrHi::	DB
;hScxMapLo::	DB
;hScxMapHi::	DB
;hScyScrLo::	DB
;hScyScrHi::	DB
;hScyMapLo::	DB
;hScyMapHi::	DB



		BSS	$A000
wSramSignature	ds	8
wStructRamLo	ds	1
wStructRamHi	ds	1
wWhichGame	ds	1
wWhichPlyr	ds	1
wStoryUnlocked	ds	3
wStructBeast	ds	8
wStructBelle	ds	8
wStructPotts	ds	8
wStructLumir:	ds	8
wStructGastn	ds	8
wBoardMap	ds	1
wPadding	ds	2
wBackupWhich	ds	1
wBackupSave0	ds	48
wBackupSave1	ds	48

wMapXMinLo	ds	1
wMapXMinHi	ds	1
wMapYMinLo	ds	1
wMapYMinHi	ds	1
wMapXMaxLo	ds	1
wMapXMaxHi	ds	1
wMapYMaxLo	ds	1
wMapYMaxHi	ds	1

wSelect4	ds	4	;Used for None/CPU/Human Easy/Med/Hard
wMusicOff	ds	1

wLockState	ds	16

wLanguage	ds	1	;0=english, 1=german, 2=french, 3=italian, 4=spanish
wStringBad	ds	1	;
wStringL1Width	ds	1	;
wStringL2Width	ds	1	;
wStringL3Width	ds	1	;
wStringL4Width	ds	1	;
wStringL5Width	ds	1	;

wLanguageH1	ds	1
wLanguageH2	ds	1
wLanguageH3	ds	1

wBoardSqrLo	ds	1
wBoardSqrHi	ds	1
wBoardGrdLo	ds	1
wBoardGrdHi	ds	1
wBoardMapLo	ds	1
wBoardMapHi	ds	1
wBoardDieLo	ds	1
wBoardDieHi	ds	1
wBoardSmlX	ds	1
wBoardSmlY	ds	1
wBoardBtnX	ds	1
wBoardBtnY	ds	1

wGuardPosnLo	ds	1
wGuardPosnHi	ds	1
wGuard1Sqr	ds	5
wGuard2Sqr	ds	5
wGuard3Sqr	ds	5
wGuard4Sqr	ds	5
wGuard5Sqr	ds	5
wGuard6Sqr	ds	5
wGuard7Sqr	ds	5
wGuard8Sqr	ds	5
wGuard9Sqr	ds	5

		BSS	$A100
wHighScores1	ds	$0100	;Initials and high score for each game
wHighScores2	ds	$0100	;Initials and high score for each game

wTblDivide3	ds	256
wTblMapLine	ds	256

wSaveTemp48	ds	48

wSecretHistory	ds	SECRETLEN

wStringLine1	ds	32
wStringLine2	ds	32
wStringLine3	ds	32
wStringLine4	ds	32
wStringLine5	ds	32
wStringOverflow	ds	32
wString:		ds	256

		BSS	$B000

wMapData:	ds	$1000





; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF RAM.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

