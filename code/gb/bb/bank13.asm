; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** ROM BANK 0x13 ($4000-$7FFF) -                                         **
; **                                                                       **
; ** Last modified : 990218 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"


;		SECTION	"gamebank13",DATA[$4000],BANK[19]
		section 19


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

BANK13_1ST::

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		incbin	"res/sprites.b13"

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

BANK13_END::

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF BANK13.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

