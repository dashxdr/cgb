; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** INTROHI.ASM                                                    MODULE **
; **                                                                       **
; ** Subgame introductions.                                                **
; **                                                                       **
; ** Last modified : 31 Mar 1999 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

		INCLUDE	"equates.equ"

;		SECTION	"introhi",CODE,BANK[3]
		section 3


; ***************************************************************************
; * IntroBoom -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroBoom::	DB	ICMD_ABORTOFF		;

		DB	ICMD_KILLSOUND		;
		DB	ICMD_PLAYMUSIC		;
		DB	SONG_LOST		;

		DB	ICMD_NEWPKG		;Initialize picture.
;		IF	VERSION_USA		;
;		DW	IDX_BBOOMPKG		;
;		DW	IDX_CBOOMPKG		;
;		ELSE				;
		DW	IDX_BJBOOMPKG		;
		DW	IDX_CJBOOMPKG		;
;		ENDC				;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,65		;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Fade up the screen.

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSTLOSEPKG		;
		DW	IDX_CSTLOSEPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,65		;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.
		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroCellar -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroCellar::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BLUMCEL0PKG		;
		DW	IDX_CLUMCEL0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	50,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Come quick, everyone!",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"There's water leaking",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"in the cellar!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,31	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BLUMCEL1PKG		;
		DW	IDX_CLUMCEL1PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	55,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Hah!  Water is no",0
		DB	80, 30+1*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"match for Lumiere.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,32	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesCellar::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Use your flames to",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"stop the water drips.",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Too many drips will",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"put your fire out.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,33	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroChip -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroChip::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCHIP1PKG		;
		DW	IDX_CCHIP1PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	98,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Oh, Chip, are you",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"hiding again?",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,34	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCHIP2PKG		;
		DW	IDX_CCHIP2PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	100,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Try and find me,",0
		DB	80, 30+1*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Mama!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,35	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesChip::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Watch Chip closely.",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"When the cups stop,",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"pick out the one",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"that's Chip.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,36	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroChopper -                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroChopper::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BBELPOP0PKG		;
		DW	IDX_CBELPOP0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80,30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Papa, is your",0
		DB	80,30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"invention ready yet?",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,37	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	96,70			;
		DW	DoBubbleRhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80,21+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"You're just in time,",0
		DB	80,21+1*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Belle. I'm going to",0
		DB	80,21+2*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"test it out.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,38	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80,21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Be careful, Papa.",0
		DB	80,21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Remember what",0
		DB	80,21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"happened last time.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,39	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesChopper::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Use the spring cart",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to bounce the logs",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to the log pile.",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Don't let any drop.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,40	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroRide -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroRide::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BBELPHL0PKG		;
		DW	IDX_CBELPHL0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Philippe, I don't",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"like the looks of",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"this forest.  We'd",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"better hurry home.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,41	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BWLFPAK0PKG		;
		DW	IDX_CWLFPAK0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 38+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Grrrr!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,42	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesRide::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Wolves, bats and",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"traps block Belle's",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"path.  Jump and duck",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to reach safety.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,43	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStove -                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroStove::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCHEF1PKG		;
		DW	IDX_CCHEF1PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Ha-ha!  This meal",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"will be my greatest",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"masterpiece!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,44	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCHEF2PKG		;
		DW	IDX_CCHEF2PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Look at me, Mama!",0
		DB	80, 21+1*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"I'm way up high!",0
		DB	80, 21+2*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Oops.  Sorry!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,45	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCHEF3PKG		;
		DW	IDX_CCHEF3PKG	;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Oh, Chip, I told you",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"not to play",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"up there.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,46	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesStove::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Mrs. Potts must put",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"out all the fires.",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Use the pumps to",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"get more water.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,47	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroSultan -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroSultan::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSULTANPKG		;
		DW	IDX_CSULTANPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	72,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Oooh! Look at the",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"mess you made!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,48	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	76,70			;
		DW	DoBubbleRhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	88, 38+0*17,GMB_PALF+CGB_PALF+CGB_PAL0,1
		DB	"Woof! Woof!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,49	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	72,70			;
		DW	DoBubbleLhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"You naughty",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"poochy, now I will",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"have to clean it up!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,50	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesSultan::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"To clean up,",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"dust the paw prints",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"in the same order",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"as they are left.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,51	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroTarget -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroTarget::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BLEFOU0PKG		;
		DW	IDX_CLEFOU0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	68,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"There's no greater",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"shooter than Gaston.",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"So step up and try",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to prove me wrong.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,52	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesTarget::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Each stage has good",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"targets and bad.",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Shoot the good but",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"avoid the bad.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,53	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite1		;

		DB	ICMD_WIPE		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"If you run out of",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"time or lives, the",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"game is over.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,54	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroWhack -                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroWhack::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BWLFPAK0PKG		;
		DW	IDX_CWLFPAK0PKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Vicious wolves",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"lurk everywhere",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"in the forest.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,55	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BWLFBST0PKG		;
		DW	IDX_CWLFBST0PKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"The Beast must",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"battle them",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to save Belle.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,56	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

RulesWhack::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Use the arrows as a",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"guide to fight the",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"wolves with jumps,",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ducks and punches.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,57	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroTrivia -                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroTrivia::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Answer the question",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"before time runs out.",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Answer fast for",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"better rewards.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroBonus -                                                            *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroBonus::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_CBONUSPKG		;
		DW	IDX_CBONUSPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 50+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Congratulations,",0
		DB	80, 50+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"you have collected",0
		DB	80, 50+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"enough stars for a",0
		DB	80, 50+4*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"bonus game.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	135,118			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_STRBOUNDS,124,124,124,124,0
		DB	ICMD_SPLITSTR,58
		DB	ICMD_SLOWSTRP
		DB	80, 50+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine1
		DB	80, 50+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine2
		DB	80, 50+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine3
		DB	80, 50+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	wStringLine4
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	135,118			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroSpit -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroSpit::
RulesSpit::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 18+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Use the meter below",0
		DB	80, 18+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston to aim for the",0
		DB	80, 18+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"spittoon with the star.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	154,59			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,59	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroMind -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroMind::
RulesMind::	DB	ICMD_KILLSOUND

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Find the matching pairs",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"behind the doors.  The",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"better you do, the",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"greater the rewards.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	154,59			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,60	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStory1 -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroStory1::	DB	ICMD_KILLSOUND		;
		DB	ICMD_PREFMUSIC		;
		DB	SONG_TITLE		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"In the Story Game,",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"you must find the",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast before Gaston.",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Good luck!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	154,59			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,61	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSGASTONPKG		;
		DW	IDX_CSGASTONPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston speaks to a",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"gathering mob.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	154,59			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,62	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	95,70			;
		DW	DoBubbleLhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"He'll harm your",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"children...  We",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"are not safe until",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"the Beast is dead.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,63	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSCELLARPKG		;
		DW	IDX_CSCELLARPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Belle is locked in",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"the cellar while",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"the angry mob heads",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"for the castle.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,64	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	67,70			;
		DW	DoBubbleRhs		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"I must get out of",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"here and warn the",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast before it's",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"too late!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,65	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSMOBPKG		;
		DW	IDX_CSMOBPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston's mob",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"sets off for the",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast's castle.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,66	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSMOBPKG		;
		DW	IDX_CSMOBPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	78,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Kill the Beast!",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Kill the Beast!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
;		DB	ICMD_INTROSTR,67	;Display string.
		DB	ICMD_SLOWSTRN
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	67
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	67
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSSTOKEPKG		;
		DW	IDX_CSSTOKEPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Chip desperately",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"tries to start",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"the woodchopping",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"contraption.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,68	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSSTOKEPKG		;
		DW	IDX_CSSTOKEPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	103,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"I must help Belle",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"escape to warn the",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,69	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSCHOPPRPKG		;
		DW	IDX_CSCHOPPRPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Chip starts the",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"woodchopper and",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"heads toward the",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"locked door.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,70	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSCHOPPRPKG		;
		DW	IDX_CSCHOPPRPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	118,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Here I come, Belle!",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Stay away from the",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"door!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,71	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSBOOMPKG		;
		DW	IDX_CSBOOMPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"The woodchopper",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"breaks the locked",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"door!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,72	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSFREEPKG		;
		DW	IDX_CSFREEPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"With Chip's help,",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Belle and Maurice",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"escape the locked",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"cellar.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,73	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSFREEPKG		;
		DW	IDX_CSFREEPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	148,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 31+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"We must hurry,",0
		DB	80, 31+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Father!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,74	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroFinish1 -                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroFinish1::	DB	ICMD_KILLSOUND		;
		DB	ICMD_PREFMUSIC		;
		DB	SONG_TITLE		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Well done! You",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"have beaten Gaston",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to the forest.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,224	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Don't stop now;",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"there is still a",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"long way to go!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,226	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		IF	VERSION_USA
		DW	IDX_BSFORESTPKG		;
		DW	IDX_CSFORESTPKG		;
		ELSE
		DW	IDX_BJFORESTPKG		;
		DW	IDX_CJFORESTPKG		;
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStory2 -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroStory2::	DB	ICMD_KILLSOUND		;
		DB	ICMD_PREFMUSIC		;
		DB	SONG_TITLE		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

;		DB	ICMD_NEWPKG		;Initialize picture.
;		IF	VERSION_USA
;		DW	IDX_BSFORESTPKG		;
;		DW	IDX_CSFORESTPKG		;
;		ELSE
;		DW	IDX_BJFORESTPKG		;
;		DW	IDX_CJFORESTPKG		;
;		ENDC
;
;		DB	ICMD_FADEUP		;Fade up the screen.
;
;		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.
;
;		DB	ICMD_HALT		;Pause for the user.
;
;		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BBELPHL0PKG		;
		DW	IDX_CBELPHL0PKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	15,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"I wonder how",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"far Gaston is",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"ahead of us?",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,75	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroFinish2 -                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroFinish2::	DB	ICMD_KILLSOUND		;
		DB	ICMD_PREFMUSIC		;
		DB	SONG_TITLE		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Well done! You",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"have beaten Gaston",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to the forest.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,225	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Don't stop now;",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"there is still a",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"long way to go!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,226	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSCASTLEPKG		;
		DW	IDX_CSCASTLEPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStory3 -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroStory3::	DB	ICMD_KILLSOUND		;
		DB	ICMD_PREFMUSIC		;
		DB	SONG_TITLE		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

;		DB	ICMD_NEWPKG		;Initialize picture.
;		DW	IDX_BSCASTLEPKG		;
;		DW	IDX_CSCASTLEPKG		;
;
;		DB	ICMD_FADEUP		;Fade up the screen.
;
;		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.
;
;		DB	ICMD_HALT		;Pause for the user.
;
;		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSLOGPKG		;
		DW	IDX_CSLOGPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston's mob arrives",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"at the castle. A",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"great door bars",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"their way.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,76	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech
		DB	ICMD_SPROFF		;area.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;
		DB	ICMD_WIPE		;

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"They construct a",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"battering ram to",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"break the door",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"down.",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,77	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSBATTERPKG		;
		DW	IDX_CSBATTERPKG		;

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	78,70			;
		DW	DoBubbleLhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Kill the Beast!",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Kill the Beast!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
;		DB	ICMD_INTROSTR,67	;Display string.
		DB	ICMD_SLOWSTRN
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	67
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	67
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current
		DB	ICMD_SPROFF		;display.
		DW	wSprite0		;
		DB	ICMD_SPROFF		;
		DW	wSprite1		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSBRKINPKG		;
		DW	IDX_CSBRKINPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Gaston breaks the",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"castle door down!",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"There's not much time",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"to warn the Beast!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,78	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * StoryWin -                                                             *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroStoryWin::	DB	ICMD_ABORTOFF		;

		DB	ICMD_KILLSOUND
		DB	ICMD_PLAYMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSXFORMPKG		;
		DW	IDX_CSXFORMPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
    		DB	"Belle warns the",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast and Gaston",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"is defeated.",0
		DB	0
		ELSE
		DB	ICMD_INTROSTR,80	;Display string.
		ENDC

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHUMANPKG		;
		DW	IDX_CSHUMANPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 13+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"True love is found",0
		DB	80, 13+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"and the Beast",0
		DB	80, 13+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"returns to his",0
		DB	80, 13+3*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"former self.",0
		DB	0
		ELSE
		DB	ICMD_INTROSTR,81	;Display string.
		ENDC

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGBELLE1PKG		;
		DW	IDX_CGBELLE1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"And they lived ...",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	82
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSWINPKG		;
		DW	IDX_CSWINPKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"... happily ever after.",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	83
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,30		;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	84
		DB	0
		ENDC

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON

		IF	DUMP_TEXT		;
		ELSE				;
		DB	ICMD_JUMP		;
		DW	.Loop			;
		ENDC				;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStoryLose -                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroStoryLose::DB	ICMD_ABORTOFF		;

		DB	ICMD_KILLSOUND
		DB	ICMD_PLAYMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BBELPHL0PKG		;
		DW	IDX_CBELPHL0PKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
    		DB	"Belle does not",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"reach the Beast in",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"time.",0
		DB	0
		ELSE
		DB	ICMD_INTROSTR,85	;Display string.
		ENDC

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSPETALPKG		;
		DW	IDX_CSPETALPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSXPETALPKG		;
		DW	IDX_CSXPETALPKG		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 21+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
    		DB	"The last petal has",0
		DB	80, 21+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"fallen from the",0
		DB	80, 21+2*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"enchanted rose.",0
		DB	0
		ELSE
		DB	ICMD_INTROSTR,86	;Display string.
		ENDC

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;

		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSLOSEPKG		;
		DW	IDX_CSLOSEPKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80, 140+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	84
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON

		IF	DUMP_TEXT		;
		ELSE				;
		DB	ICMD_JUMP		;
		DW	.Loop			;
		ENDC				;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroStarSqr -                                                          *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroStarSqr::	DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		IF	0
		DB	ICMD_SLOWSTR
		DB	80, 30+0*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"You receive a",0
		DB	80, 30+1*17,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"bonus star!",0
		DB	0
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	154,80			;
		DW	DoButtonIcon		;
		ELSE
		DB	ICMD_INTROSTR,207	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;
		ENDC

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroKnight -                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

; 1 linesDB	80, 38+0*17,
; 2 linesDB	80, 30+0*17,
; 3 linesDB	80, 21+0*17,
; 4 linesDB	80, 13+0*17,

IntroKnight::	DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BKNIGHTPKG		;
		DW	IDX_CKNIGHTPKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Challenge",0
		DB	0
		DB	ICMD_FONT		;Setup font.
		DW	FontLite		;
		DB	ICMD_FASTSTR
		DB	80,110+0*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"DEFEAT MY",0
		DB	80,110+1*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"CHALLENGE AND",0
		DB	80,110+2*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"I WILL REWARD",0
		DB	80,110+3*9,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"YOU",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	96, 95,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	208
		DB	0
		DB	ICMD_LUCKYSTR,209
		ENDC

		DB	ICMD_SPRON
		DW	wSprite1
		DB	148,66
		DW	DoButtonIcon

		DB	ICMD_FADEUP		;Fade up the screen.

;		IF	DUMP_TEXT		;
;		ELSE				;
;		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.
;		ENDC				;

 		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * MultiWinBeast -                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MultiWinBeast::	DB	ICMD_ABORTOFF

		DB	ICMD_KILLSOUND
		DB	ICMD_PREFMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGBEAST1PKG		;
		DW	IDX_CGBEAST1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Congratulations!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	146
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Beast Wins!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	147
		DB	0
		ENDC

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGBEAST2PKG		;
		DW	IDX_CGBEAST2PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	151
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON		;

		DB	ICMD_JUMP		;
		DW	.Loop			;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * MultiWinBelle -                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MultiWinBelle::	DB	ICMD_ABORTOFF

		DB	ICMD_KILLSOUND
		DB	ICMD_PREFMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGBELLE1PKG		;
		DW	IDX_CGBELLE1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Congratulations!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	146
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Belle Wins!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	148
		DB	0
		ENDC

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGBELLE2PKG		;
		DW	IDX_CGBELLE2PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	151
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON

		DB	ICMD_JUMP		;
		DW	.Loop			;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * MultiWinPotts -                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MultiWinPotts::	DB	ICMD_ABORTOFF

		DB	ICMD_KILLSOUND
		DB	ICMD_PREFMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGPOTTS1PKG		;
		DW	IDX_CGPOTTS1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Congratulations!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	146
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Mrs. Potts Wins!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	149
		DB	0
		ENDC

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGPOTTS2PKG		;
		DW	IDX_CGPOTTS2PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	151
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON

		DB	ICMD_JUMP		;
		DW	.Loop			;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * MultiWinLumir -                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

MultiWinLumir::	DB	ICMD_ABORTOFF

		DB	ICMD_KILLSOUND
		DB	ICMD_PREFMUSIC
		DB	SONG_VICTORY

.Loop:		DB	ICMD_FONT		;Setup font.
		DW	FontEnd			;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGLUMIR1PKG		;
		DW	IDX_CGLUMIR1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Congratulations!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	146
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_USEPKG		;Blank out the speech

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Lumiere Wins!",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	150
		DB	0
		ENDC

		DB	ICMD_WIPE		;

		DB	ICMD_DELAY,TEXT_DELAY0	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BGLUMIR2PKG		;
		DW	IDX_CGLUMIR2PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Game Over",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	80,140,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	151
		DB	0
		ENDC

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_DELAY,TEXT_DELAY1	;Allow timeout.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_FADEDN		;Remove the current

		DB	ICMD_ABORTON

		DB	ICMD_JUMP		;
		DW	.Loop			;

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * TargetStg1ICmd -                                                        *
; * TargetStg2ICmd -                                                        *
; * TargetStg3ICmd -                                                        *
; * TargetStg4ICmd -                                                        *
; * TargetStg5ICmd -                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

TargetStg1ICmd::DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHOOT1PKG		;
		DW	IDX_CSHOOT1PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Stage 1",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	179
		DB	0
		ENDC

		DB	ICMD_JUMP
		DW	TargetBtnICmd

TargetStg2ICmd::DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHOOT2PKG		;
		DW	IDX_CSHOOT2PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Stage 2",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	180
		DB	0
		ENDC

		DB	ICMD_JUMP
		DW	TargetBtnICmd

TargetStg3ICmd::DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHOOT3PKG		;
		DW	IDX_CSHOOT3PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Stage 3",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	181
		DB	0
		ENDC

		DB	ICMD_JUMP
		DW	TargetBtnICmd

TargetStg4ICmd::DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHOOT4PKG		;
		DW	IDX_CSHOOT4PKG		;

		IF	0
		DB	ICMD_FASTSTR
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DB	"Challenge",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	 80, 24,GMB_PALN+CGB_PALN+CGB_PAL0,1
		DW	91
		DB	0
		ENDC

		DB	ICMD_JUMP
		DW	TargetBtnICmd

TargetStg5ICmd::DB	ICMD_KILLSOUND		;

		DB	ICMD_FONT		;Setup font.
		DW	FontOlde		;

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BSHOOT5PKG		;
		DW	IDX_CSHOOT5PKG		;

		DB	ICMD_JUMP
		DW	TargetBtnICmd

TargetBtnICmd::	IF	0
		DB	ICMD_FASTSTR
		DB	 44, 48,GMB_PALF+CGB_PALN+CGB_PAL0,1
		DB	"Shoot",0
		DB	116, 48,GMB_PALF+CGB_PALN+CGB_PAL0,1
		DB	"Avoid",0
		DB	0
		ELSE
		DB	ICMD_FASTSTRN
		DB	 44, 48,GMB_PALF+CGB_PALN+CGB_PAL0,1
		DW	185
		DB	116, 48,GMB_PALF+CGB_PALN+CGB_PAL0,1
		DW	186
		DB	0
		ENDC

		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite0		;
		DB	140,123			;
		DW	DoButtonIcon		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; * IntroUnlockMap -                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroUnlockMap::DB	ICMD_KILLSOUND
		DB	ICMD_PREFMUSIC
		DB	SONG_WON

		DB	ICMD_FONT
		DW	FontOlde

		DB	ICMD_NEWPKG		;Initialize picture.
		DW	IDX_BCOGGSPKG
		DW	IDX_CCOGGSPKG

		DB	ICMD_SPRON		;Initialize speech bubble.
		DW	wSprite0		;
		DB	60,70			;
		DW	DoBubbleRhs		;

		DB	ICMD_FADEUP		;Fade up the screen.

		DB	ICMD_INTROSTR,217	;Display string.
		DB	ICMD_SPRON		;Initialize button icon.
		DW	wSprite1		;
		DB	152,80			;
		DW	DoButtonIcon		;

		DB	ICMD_HALT		;Pause for the user.

		DB	ICMD_END		;All Done.



; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF INTROHI.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

