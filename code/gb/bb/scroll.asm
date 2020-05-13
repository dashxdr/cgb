; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** SCROLL.ASM                                                     MODULE **
; **                                                                       **
; ** Court scrolling and camera logic.                                     **
; **                                                                       **
; ** Last modified : 09 Nov 1998 by John Brandwood                         **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"scroll",HOME
		section 0

		IF	0


; ***************************************************************************
; * ScrollCourt ()                                                          *
; ***************************************************************************
; * Scroll the screen and reposition the sprites                            *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollCourt::	CALL	ScrollCourtLR		;
		CALL	ScrollCourtUD		;

		LDH	A,[hScxBlk]		;Changed current X block
		LD	D,A			;position ?
		LDH	A,[hScrXLo]		;
		AND	$F0			;
		LD	B,A			;
		LDH	A,[hScrXHi]		;
		AND	$0F			;
		OR	B			;
		SWAP	A			;
		LDH	[hScxBlk],A		;
		SUB	D			;
		JR	Z,.Skip0		;
		LDH	[hScxChg],A		;
.Skip0:		LD	B,A			;

		LDH	A,[hScyBlk]		;Changed current Y block
		LD	E,A			;position ?
		LDH	A,[hScrYLo]		;
		AND	$F0			;
		LD	C,A			;
		LDH	A,[hScrYHi]		;
		AND	$0F			;
		OR	C			;
		SWAP	A			;
		LDH	[hScyBlk],A		;
		SUB	E			;
		JR	Z,.Skip1		;
		LDH	[hScyChg],A		;
.Skip1:		LD	C,A			;

		LDH	A,[hScxChg]		;
		OR	A			;
		CALL	NZ,IntroCourtLR		;

		LDH	A,[hScyChg]		;
		OR	A			;
		CALL	NZ,IntroCourtUD		;

CalcScr2Offset::LD	HL,hScrXLo		;
		LD	A,[HLI]			;
		LD	C,A			;
		LD	A,[HLI]			;
		LD	B,A			;
		LD	A,[HLI]			;
		LD	E,A			;
		LD	A,[HLI]			;
		LD	D,A			;

		LD	A,[wMapXOrgLo]		;Convert camera ISO_Y
		SUB	C			;to MAP_Y.
;		LDH	[hIso2ScrXLo],A		;
		LD	A,[wMapXOrgHi]		;
		SBC	B			;
;		LDH	[hIso2ScrXHi],A		;

		LD	A,[wMapYOrgLo]		;Convert camera ISO_Y
		SUB	E			;to MAP_Y.
;		LDH	[hIso2ScrYLo],A		;
		LD	A,[wMapYOrgHi]		;
		SBC	D			;
;		LDH	[hIso2ScrYHi],A		;

		RET



; ***************************************************************************
; * ScrollCourtLR ()                                                        *
; ***************************************************************************
; * Determine if the screen needs to be scrolled horizontally               *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollCourtLR::	LDH	A,[hScrXLo]		;Get ScrX.
		LD	L,A
		LDH	A,[hScrXHi]
		LD	H,A

ScrGetXChg::	LD	A,[wCamScrXLo]		;Calc BC = CamX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wCamScrXHi]
		SBC	H
		LD	B,A

		BIT	7,B
		JR	NZ,ScrNegXChg

ScrPosXChg::	OR	A
		JR	NZ,ScrMaxXChg
		LD	A,C
		SUB	MAX_XSCROLL
		JR	C,ScrAddXChg
ScrMaxXChg::	LD	BC,0+MAX_XSCROLL
		JR	ScrAddXChg

ScrNegXChg::	INC	A
		JR	NZ,ScrMinXChg
		LD	A,C
		ADD	MAX_XSCROLL
		JR	C,ScrAddXChg
ScrMinXChg::	LD	BC,0-MAX_XSCROLL

ScrAddXChg::	ADD	HL,BC			;Calc HL = new ScrX.

ScrCmpMinX::	LD	A,[wMapXMinLo]		;Calc DE = MinX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wMapXMinHi]
		SBC	H
		LD	B,A

		BIT	7,A			;Overflow ?
		JR	NZ,ScrCmpMaxX

		ADD	HL,BC			;Calc HL = MinX.

ScrCmpMaxX::	LD	A,[wMapXMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wMapXMaxHi]
		SBC	H
		LD	B,A

		BIT	7,A			;Overflow ?
		JR	Z,ScrSavScrX

		ADD	HL,BC			;Calc HL = MaxX.

ScrSavScrX::	LD	A,H			;Save new scroll position.
		LDH	[hScrXHi],A
		LD	A,L
		LDH	[hScrXLo],A

		RET



; ***************************************************************************
; * ScrollCourtUD ()                                                        *
; ***************************************************************************
; * Determine if the screen needs to be scrolled vertically                 *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

ScrollCourtUD::	LDH	A,[hScrYLo]		;Get ScrX.
		LD	L,A
		LDH	A,[hScrYHi]
		LD	H,A

ScrGetYChg::	LD	A,[wCamScrYLo]		;Calc BC = CamX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wCamScrYHi]
		SBC	H
		LD	B,A

		BIT	7,B
		JR	NZ,ScrNegYChg

ScrPosYChg::	OR	A
		JR	NZ,ScrMaxYChg
		LD	A,C
		SUB	MAX_YSCROLL
		JR	C,ScrAddYChg
ScrMaxYChg::	LD	BC,0+MAX_YSCROLL
		JR	ScrAddYChg

ScrNegYChg::	INC	A
		JR	NZ,ScrMinYChg
		LD	A,C
		ADD	MAX_YSCROLL
		JR	C,ScrAddYChg
ScrMinYChg::	LD	BC,0-MAX_YSCROLL

ScrAddYChg::	ADD	HL,BC			;Calc HL = new ScrX.

ScrCmpMinY::	LD	A,[wMapYMinLo]		;Calc DE = MinX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wMapYMinHi]
		SBC	H
		LD	B,A

		BIT	7,A			;Overflow ?
		JR	NZ,ScrCmpMaxY

		ADD	HL,BC			;Calc HL = MinX.

ScrCmpMaxY::	LD	A,[wMapYMaxLo]		;Calc DE = MaxX - ScrX.
		SUB	L
		LD	C,A
		LD	A,[wMapYMaxHi]
		SBC	H
		LD	B,A

		BIT	7,A			;Overflow ?
		JR	Z,ScrSavScrY

		ADD	HL,BC			;Calc HL = MaxX.

ScrSavScrY::	LD	A,H			;Save new scroll position.
		LDH	[hScrYHi],A
		LD	A,L
		LDH	[hScrYLo],A

		RET



; ***************************************************************************
; * IntroCourtLR ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroCourtLR::	ADD	A
		JR	NC,IntroCourtRhs

;

IntroCourtLhs::
;		LD	BC,(0*8*256)+(0*8)	;Set intro coordinates.
;		CALL	CalcScrBlk		;Calculate scr intro addr.
		CALL	GetScrBlk1L1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScxScrLo],A
		LD	A,H
		LDH	[hScxScrHi],A

;		CALL	CalcMapBlk_80		;Calculate map intro addr.
		CALL	GetMapBlk1L1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScxMapLo],A
		LD	A,H
		LDH	[hScxMapHi],A

		RET

;

IntroCourtRhs::
;		LD	BC,(20*8*256)+(0*8)	;Set intro coordinates.
;		CALL	CalcScrBlk		;Calculate scr intro addr.
		CALL	GetScrBlk11R1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScxScrLo],A
		LD	A,H
		LDH	[hScxScrHi],A

;		CALL	CalcMapBlk_80		;Calculate map intro addr.
		CALL	GetMapBlk11R1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScxMapLo],A
		LD	A,H
		LDH	[hScxMapHi],A

		RET



; ***************************************************************************
; * IntroCourtUD ()                                                         *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

IntroCourtUD::	ADD	A
		JR	NC,IntroCourtBtm

;

IntroCourtTop::
;		LD	BC,(0*8*256)+(0*8)	;Set intro coordinates.
;		CALL	CalcScrBlk		;Calculate scr intro addr.
		CALL	GetScrBlk1L1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScyScrLo],A
		LD	A,H
		LDH	[hScyScrHi],A

;		CALL	CalcMapBlk_80		;Calculate map intro addr.
		CALL	GetMapBlk1L1U		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScyMapLo],A
		LD	A,H
		LDH	[hScyMapHi],A

		RET

;

IntroCourtBtm::
;		LD	BC,(0*8*256)+(18*8)	;Set intro coordinates.
;		CALL	CalcScrBlk		;Calculate scr intro addr.
		CALL	GetScrBlk1L10D		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScyScrLo],A
		LD	A,H
		LDH	[hScyScrHi],A

;		CALL	CalcMapBlk_80		;Calculate map intro addr.
		CALL	GetMapBlk1L10D		;Calculate scr intro addr.
		LD	A,L
		LDH	[hScyMapLo],A
		LD	A,H
		LDH	[hScyMapHi],A

		RET



; ***************************************************************************
; * CalcScrBlk ()                                                           *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      B    X-offset from hScx                                     *
; *             C    Y-offset from hScy                                     *
; *                                                                         *
; * Outputs     HL   Screen address ($9800-$9BFF)                           *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; ***************************************************************************

CalcScrBlk::	LDH	A,[hScrYLo]		;3   Calculate screen intro position.
		ADD	C			;1
		RLCA				;1
		RLCA				;1
		LD	H,A			;1
		AND	$C0			;2
		LD	L,A			;1
		LD	A,H			;1
		AND	$03			;2
		OR	$98			;2
		LD	H,A			;1

		LDH	A,[hScrXLo]		;3
		ADD	B			;1
		RRCA				;1
		RRCA				;1
		RRCA                            ;1
		AND	$1E			;2
		OR	L			;1
		LD	L,A			;1

		RET				;4



; ***************************************************************************
; * CalcMapBlk_80 ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

CalcMapBlk_80::	LD	A,[hScrXHi]		;3
		LD	D,A			;1
		LD	A,[hScrXLo]		;3
		ADD	B			;1
		JR	NC,.Skip0		;3/2
		INC	D			;1
.Skip0:		AND	$F0			;2
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		LD	E,A			;1

		LD	A,[hScrYHi]		;3
		LD	H,A			;1
		LD	A,[hScrYLo]		;3
		ADD	C			;1
		JR	NC,.Skip1		;3/2
		INC	H			;1
.Skip1:		AND	$F0			;2
		LD	L,A
		ADD	HL,HL			;2
		LD	C,L			;1
		LD	B,H			;1
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,BC			;2

		ADD	HL,DE			;2

		LD	BC,wMapData		;3
		ADD	HL,BC			;2

		RET				;4



; ***************************************************************************
; * GetScrBlk1L1U ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Screen address ($9800-$9BFF)                           *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; ***************************************************************************

GetScrBlk1L1U::	LDH	A,[hScrYLo]		;3   Calculate screen intro
		SUB	$10			;2   position.
		RLCA				;1
		RLCA				;1
		LD	H,A			;1
		AND	$C0			;2
		LD	L,A			;1
		LD	A,H			;1
		AND	$03			;2
		OR	$98			;2
		LD	H,A			;1

		LDH	A,[hScrXLo]		;3
		SUB	$10			;1
		RRCA				;1
		RRCA				;1
		RRCA                            ;1
		AND	$1E			;2
		OR	L			;1
		LD	L,A			;1

		RET				;4



; ***************************************************************************
; * GetMapBlk1L1U ()                                                        *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Map address ($D000-$DFFF)                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetMapBlk1L1U::	LD	A,[hScrXHi]		;3
		LD	D,A			;1
		LD	A,[hScrXLo]		;3
		SUB	$10			;1
		JR	NC,.Skip0		;3/2
		DEC	D			;1
.Skip0:		AND	$F0			;2
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		LD	E,A			;1

		LD	A,[hScrYHi]		;3
		LD	H,A			;1
		LD	A,[hScrYLo]		;3
		SUB	$10			;1
		JR	NC,.Skip1		;3/2
		DEC	H			;1
.Skip1:		AND	$F0			;2
		LD	L,A
		ADD	HL,HL			;2
		LD	C,L			;1
		LD	B,H			;1
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,BC			;2

		ADD	HL,DE			;2

		LD	BC,wMapData		;3
		ADD	HL,BC			;2

		RET				;4



; ***************************************************************************
; * GetScrBlk1L10D ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Screen address ($9800-$9BFF)                           *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; ***************************************************************************

GetScrBlk1L10D::LDH	A,[hScrYLo]		;3   Calculate screen intro
		ADD	$A0			;2   position.
		RLCA				;1
		RLCA				;1
		LD	H,A			;1
		AND	$C0			;2
		LD	L,A			;1
		LD	A,H			;1
		AND	$03			;2
		OR	$98			;2
		LD	H,A			;1

		LDH	A,[hScrXLo]		;3
		SUB	$10			;1
		RRCA				;1
		RRCA				;1
		RRCA                            ;1
		AND	$1E			;2
		OR	L			;1
		LD	L,A			;1

		RET				;4



; ***************************************************************************
; * GetMapBlk1L10D ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Map address ($D000-$DFFF)                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetMapBlk1L10D::LD	A,[hScrXHi]		;3
		LD	D,A			;1
		LD	A,[hScrXLo]		;3
		SUB	$10			;1
		JR	NC,.Skip0		;3/2
		DEC	D			;1
.Skip0:		AND	$F0			;2
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		LD	E,A			;1

		LD	A,[hScrYHi]		;3
		LD	H,A			;1
		LD	A,[hScrYLo]		;3
		ADD	$A0			;1
		JR	NC,.Skip1		;3/2
		INC	H			;1
.Skip1:		AND	$F0			;2
		LD	L,A
		ADD	HL,HL			;2
		LD	C,L			;1
		LD	B,H			;1
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,BC			;2

		ADD	HL,DE			;2

		LD	BC,wMapData		;3
		ADD	HL,BC			;2

		RET				;4



; ***************************************************************************
; * GetScrBlk11R1U ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Screen address ($9800-$9BFF)                           *
; *                                                                         *
; * Preserved   BC,DE                                                       *
; ***************************************************************************

GetScrBlk11R1U::LDH	A,[hScrYLo]		;3   Calculate screen intro
		SUB	$10			;2   position.
		RLCA				;1
		RLCA				;1
		LD	H,A			;1
		AND	$C0			;2
		LD	L,A			;1
		LD	A,H			;1
		AND	$03			;2
		OR	$98			;2
		LD	H,A			;1

		LDH	A,[hScrXLo]		;3
		ADD	$B0			;1
		RRCA				;1
		RRCA				;1
		RRCA                            ;1
		AND	$1E			;2
		OR	L			;1
		LD	L,A			;1

		RET				;4



; ***************************************************************************
; * GetMapBlk11R1U ()                                                       *
; ***************************************************************************
; *                                                                         *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     HL   Map address ($D000-$DFFF)                              *
; *                                                                         *
; * Preserved   None                                                        *
; ***************************************************************************

GetMapBlk11R1U::LD	A,[hScrXHi]		;3
		LD	D,A			;1
		LD	A,[hScrXLo]		;3
		ADD	$B0			;1
		JR	NC,.Skip0		;3/2
		INC	D			;1
.Skip0:		AND	$F0			;2
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		SRA	D			;2
		RRA				;1
		LD	E,A			;1

		LD	A,[hScrYHi]		;3
		LD	H,A			;1
		LD	A,[hScrYLo]		;3
		SUB	$10			;1
		JR	NC,.Skip1		;3/2
		DEC	H			;1
.Skip1:		AND	$F0			;2
		LD	L,A
		ADD	HL,HL			;2
		LD	C,L			;1
		LD	B,H			;1
		ADD	HL,HL			;2
		ADD	HL,HL			;2
		ADD	HL,BC			;2

		ADD	HL,DE			;2

		LD	BC,wMapData		;3
		ADD	HL,BC			;2

		RET				;4



; ***************************************************************************
; * NewScrGmb ()                                                            *
; ***************************************************************************
; * Update the complete background screen (at $9800) during HBL time        *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Time taken is 20*6 horizontal blanks.                       *
; ***************************************************************************

NewScrCgb::	LD	A,2			;Dump hi-byte (attrs).
		LDH	[hWrkBank],A
		LDIO	[rSVBK],A
		DEC	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A

		CALL	NewScrGmb

		LD	A,1			;Dump lo-byte (chars).
		LDH	[hWrkBank],A
		LDIO	[rSVBK],A
		DEC	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A

NewScrGmb::	LD	BC,(0*8*256)+(0*8)	;Set intro coordinates.

;		CALL	CalcScrBlk		;Calculate scr intro addr.
		CALL	GetScrBlk1L1U		;Calculate scr intro addr.

		PUSH	HL

;		CALL	CalcMapBlk_80		;Calculate map intro addr.
		CALL	GetMapBlk1L1U		;Calculate map intro addr.

		POP	DE

;		LD	A,20			;2   Set row count.
		LD	A,24			;2   Set row count.

.Loop:		PUSH	AF			;4
		PUSH	DE			;4   Save DE=hSCX_SCR.
		PUSH	HL			;4   Save HL=hSCX_MAP.

		LD	A,E			;1
		AND	$E0			;2
		LD	B,A			;1

;		LD	C,24/4			;2   Set col count.
		LD	C,28/4			;2   Set col count.

		DI				;1

.Sync:		LDIO	A,[rSTAT]		;3   Synchronize with HBL.
		AND	%11			;1
		JR	Z,.Sync			;3/2
.Wait:		LDIO	A,[rSTAT]		;3
		AND	%11			;1
		JR	NZ,.Wait		;3/2 = 15 cycles total.

		LD	A,[HLI]			;2   Copy lhs chr of pair.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2   Copy rhs chr of pair.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,$1F			;1
		AND	E			;2
		OR	B			;1
		LD	E,A			;1   = 15 cycles total.

		LD	A,[HLI]			;2   Copy lhs chr of pair.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2   Copy rhs chr of pair.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,$1F			;1
		AND	E			;2
		OR	B			;1
		LD	E,A			;1   = 15 cycles total.

		DEC	C			;1
		JR	NZ,.Sync		;3/2

		EI				;1

		POP	HL			;3
		POP	DE			;3

		LD	BC,80			;3   Update map addr.
		ADD	HL,BC			;2
		LD	A,32			;2   Update scr addr.
		ADD	E			;1
		LD	E,A			;1
		JR	NC,.Skip		;3/2
		INC	D			;1
.Skip:		RES	2,D			;2   = 15 cycles total.

		POP	AF			;3
		DEC	A			;1
		JR	NZ,.Loop		;3/2

		RET				;4



; ***************************************************************************
; * NewRowVbl ()                                                            *
; ***************************************************************************
; * Update the top or bottom edge of the background screen (at $9800)       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Designed to be called during vblank only.                   *
; *                                                                         *
; *             Time taken is 413 cycles for 24 wide.                       *
; *             Time taken is 477 cycles for 28 wide.                       *
; ***************************************************************************

NewRowVbl::	LD	HL,hScyScrLo		;3   Get HL=hSCX_MAP.
		LD	A,[HLI]			;2   Get DE=hSCX_SCR.
		LD	E,A			;1
		LD	A,[HLI]			;2
		LD	D,A			;1
		LD	A,[HLI]			;2
		LD	H,[HL]			;2
		LD	L,A			;1   (14 cycles total)

		LD	B,E			;1

;		LD	C,24/4			;2
		LD	C,28/4			;2
.TopLoop:	LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2
		DEC	C			;1
		JR	NZ,.TopLoop		;3/2 (193 cycles total)

		LD	E,B			;1
		SET	5,E			;2

;		LD	BC,80-24		;3
		LD	BC,80-28		;3
		ADD	HL,BC			;2

;		LD	C,24/4			;2
		LD	C,28/4			;2
.BtmLoop:	LD	A,[HLI]			;2   Copy btm pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2
		LD	A,[HLI]			;2   Copy btm pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2
		DEC	C			;1
		JR	NZ,.BtmLoop		;3/2 (193 cycles total)

		RET				;4   (413 cycles total)



; ***************************************************************************
; * NewColVbl ()                                                            *
; ***************************************************************************
; * Update the left or right edge of the background screen (at $9800)       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; * N.B.        Designed to be called during vblank only.                   *
; *                                                                         *
; *             Time taken is 452 cycles for 20 high.                       *
; *             Time taken is 538 cycles for 24 high.                       *
; ***************************************************************************

NewColVbl::	LD	HL,hScxScrLo		;3   Get HL=hSCX_MAP.
		LD	A,[HLI]			;2   Get DE=hSCX_SCR.
		LD	E,A			;1
		LD	A,[HLI]			;2
		LD	D,A			;1
		LD	A,[HLI]			;2
		LD	H,[HL]			;2
		LD	L,A			;1   (14 cycles total)

		LD	BC,80			;3

;		LD	A,20/2			;2
		LD	A,24/2			;2
.Loop:		LDH	[hTmpLo],A		;3
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HL]			;2
		LD	[DE],A			;2
		ADD	HL,BC			;2   Update src ptr.
		SET	5,E			;2   Update dst ptr.
		LD	A,[HLD]			;2   Copy btm pair of block.
		LD	[DE],A			;2
		DEC	E			;1
		LD	A,[HL]			;2
		LD	[DE],A			;2
		ADD	HL,BC			;2   Update src ptr.
		LD	A,32			;2   Update dst ptr.
		ADD	E			;1
		LD	E,A			;1
		JR	NC,.Skip		;3/2
		INC	D			;1
.Skip:		RES	2,D			;2
		LDH	A,[hTmpLo]		;3
		DEC	A			;1
		JR	NZ,.Loop		;3/2 (431 cycles total)

		RET				;4   (452 cycles total)



; ***************************************************************************
; * NewRowHbl ()                                                            *
; ***************************************************************************
; * Update the top or bottom edge of the background screen (at $9800)       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; *             Time taken is 10 scanlines.                                 *
; ***************************************************************************

NewRowHbl::	LD	HL,hScyScrLo		;3   Get HL=hSCX_MAP.
		LD	A,[HLI]			;2   Get DE=hSCX_SCR.
		LD	E,A			;1
		LD	A,[HLI]			;2
		LD	D,A			;1
		LD	A,[HLI]			;2
		LD	H,[HL]			;2
		LD	L,A			;1   (14 cycles total)

		PUSH	DE			;4

		LD	BC,$0341		;3   Copy top row of blk in
		CALL	NewRowHblTopA		;x   5 scanlines (6,6,6,6,4).
		CALL	NewRowHblTopA		;x
		CALL	NewRowHblTopA		;x
		CALL	NewRowHblTopA		;x
		CALL	NewRowHblTopB		;x   Copy extra.

		POP	DE			;3
		SET	5,E			;2

		LD	BC,80-28		;3
		ADD	HL,BC			;2

		LD	BC,$0341		;3   Copy btm row of blk in
		CALL	NewRowHblBtmA		;x   5 scanlines (6,6,6,6,4).
		CALL	NewRowHblBtmA		;x
		CALL	NewRowHblBtmA		;x
		CALL	NewRowHblBtmA		;x
		CALL	NewRowHblBtmB		;x

		RET				;4

;
;
;

NewRowHblTopA::	DI				;1

.Sync:		LD	A,[C]			;2   Wait until the current
		AND	B			;1   HBL is finished.
		JR	Z,.Sync			;3/2

.Wait:		LD	A,[C]			;2   Wait for the next HBL.
		AND	B			;1
		JR	NZ,.Wait		;3/2 (11 cycles total)

		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2   (14 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2   (28 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2   (42 cycles total)

		EI				;1

		RET				;4

;
;
;

NewRowHblTopB::	DI				;1

.Sync:		LD	A,[C]			;2   Wait until the current
		AND	B			;1   HBL is finished.
		JR	Z,.Sync			;3/2

.Wait:		LD	A,[C]			;2   Wait for the next HBL.
		AND	B			;1
		JR	NZ,.Wait		;3/2 (11 cycles total)

		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2   (14 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		RES	5,E			;2   (28 cycles total)

		EI				;1

		RET				;4

;
;
;

NewRowHblBtmA::	DI				;1

.Sync:		LD	A,[C]			;2   Wait until the current
		AND	B			;1   HBL is finished.
		JR	Z,.Sync			;3/2

.Wait:		LD	A,[C]			;2   Wait for the next HBL.
		AND	B			;1
		JR	NZ,.Wait		;3/2 (11 cycles total)

		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2   (14 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2   (28 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2   (42 cycles total)

		EI				;1

		RET				;4

;
;
;

NewRowHblBtmB::	DI				;1

.Sync:		LD	A,[C]			;2   Wait until the current
		AND	B			;1   HBL is finished.
		JR	Z,.Sync			;3/2

.Wait:		LD	A,[C]			;2   Wait for the next HBL.
		AND	B			;1
		JR	NZ,.Wait		;3/2 (11 cycles total)

		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2   (14 cycles total)
		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HLI]			;2
		LD	[DE],A			;2
		RES	5,E			;2
		INC	E			;1
		SET	5,E			;2   (28 cycles total)

		EI				;1

		RET				;4



; ***************************************************************************
; * NewColHbl ()                                                            *
; ***************************************************************************
; * Update the left or right edge of the background screen (at $9800)       *
; ***************************************************************************
; * Inputs      None                                                        *
; *                                                                         *
; * Outputs     None                                                        *
; *                                                                         *
; * Preserved   None                                                        *
; *                                                                         *
; *             Time taken is 12 scanlines.                                 *
; ***************************************************************************

NewColHbl::	LD	HL,hScxScrLo		;3   Get HL=hSCX_MAP.
		LD	A,[HLI]			;2   Get DE=hSCX_SCR.
		LD	E,A			;1
		LD	A,[HLI]			;2
		LD	D,A			;1
		LD	A,[HLI]			;2
		LD	H,[HL]			;2
		LD	L,A			;1   (14 cycles total)

		LD	BC,80			;3

		DI

;		LD	A,20/2			;2
		LD	A,24/2			;2
.Loop:		LDH	[hTmpLo],A		;3

.Sync:		LDIO	A,[rSTAT]		;3   Wait until the current
		AND	%11			;1   HBL is finished.
		JR	Z,.Sync			;3/2
.Wait:		LDIO	A,[rSTAT]		;3   Wait for the next HBL.
		AND	%11			;1
		JR	NZ,.Wait		;3/2 (13 cycles total)

		LD	A,[HLI]			;2   Copy top pair of block.
		LD	[DE],A			;2
		INC	E			;1
		LD	A,[HL]			;2
		LD	[DE],A			;2
		ADD	HL,BC			;2   Update src ptr.
		SET	5,E			;2   Update dst ptr.

		LD	A,[HLD]			;2   Copy btm pair of block.
		LD	[DE],A			;2
		DEC	E			;1
		LD	A,[HL]			;2
		LD	[DE],A			;2
		ADD	HL,BC			;2   Update src ptr.
		LD	A,32			;2   Update dst ptr.
		ADD	E			;1
		LD	E,A			;1
		JR	NC,.Skip		;3/2
		INC	D			;1
.Skip:		RES	2,D			;2

		LDH	A,[hTmpLo]		;3
		DEC	A			;1
		JR	NZ,.Loop		;3/2 (431 cycles total)

		EI

		RET				;4   (452 cycles total)


		ENDC


; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
;  END OF SCROLL.ASM
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

