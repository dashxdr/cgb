; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SOUND2.ASM                                                            **
; **                                                                       **
; ** Sound second bank                                                     **
; **                                                                       **
; ** Created 20000412 by David Ashley                                      **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		section	02

SOUND1		EQU	0
SOUND2		EQU	1

KillAllSoundB2::
		jp	KillAllSoundB
KillTuneB2::
		jp	KillTuneB
KillSfxB2::
		jp	KillSfxB
InitTuneB2::
		jp	InitTuneB
InitSfxB2::
		jp	InitSfxB
MzRefresh2::
		jp	MzRefresh



		include	"gensound.asm"
