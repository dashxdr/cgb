; ***************************************************************************
; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; ** DANCE.ASM                                                             **
; **                                                                       **
; ** Last modified : 990327 by David Ashley                                **
; **                                                                       **
; ***************************************************************************
; ***************************************************************************
; ***************************************************************************


		INCLUDE	"equates.equ"

;		SECTION	"dance",CODE,BANK[3]
		section 3

; ***************************************************************************
; ***************************************************************************
; ***************************************************************************

dance_top::


SONG_DANCE	EQU	14


DANCEFLG_FIRST	EQU	0

dance_phase	EQUS	"hTemp48+00"
dance_flags	EQUS	"hTemp48+01"
dance_count	EQUS	"hTemp48+02"
dance_num	EQUS	"hTemp48+03"
dance_maplo	EQUS	"hTemp48+04"
dance_maphi	EQUS	"hTemp48+05"
dance_chrlo	EQUS	"hTemp48+06"
dance_chrhi	EQUS	"hTemp48+07"
dance_pallo	EQUS	"hTemp48+08"
dance_palhi	EQUS	"hTemp48+09"
dance_type	EQUS	"hTemp48+10"
dance_wait	EQUS	"hTemp48+11"
dance_credit	EQUS	"hTemp48+12"
dance_exitok	EQUS	"hTemp48+13"

MAPSIZE		EQU	$20*18
MAP		EQU	$e000-MAPSIZE*2
ATTR		EQU	$e000-MAPSIZE*1


swdanimtbl:	dw	IDX_FD000MAP
		dw	IDX_FD000CHR
		dw	IDX_BWD000MAP
		dw	IDX_BWD000CHR
		dw	IDX_DISNEY00MAP
		dw	IDX_DISNEY00CHR


Disney::	ld	hl,hTemp48
		ld	bc,48
		call	MemClear
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jp	nz,gmbdisney
		ld	a,LOW(disneypal)
		ldh	[dance_pallo],a
		ld	a,HIGH(disneypal)
		ldh	[dance_palhi],a
		ld	a,60
		ldh	[dance_num],a
		ld	a,48
		ldh	[dance_wait],a
		ld	a,8
		ldh	[dance_type],a
		ld	hl,swdanimtbl
		call	addahl
		ld	a,[hli]
		ldh	[dance_maplo],a
		ld	a,[hli]
		ldh	[dance_maphi],a
		ld	a,[hli]
		ldh	[dance_chrlo],a
		ld	a,[hl]
		ldh	[dance_chrhi],a

		call	dance_setup
disneyloop::
		ld	a,[wAvoidIntro]
		or	a
		jr	z,.noskipout
		ld	a,$ff
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jp	nz,disneydone
.noskipout:
		ldh	a,[dance_count]
		call	disneyrender
		call	disneycopy
		call	disneyflip
		ld	hl,dance_flags
		bit	DANCEFLG_FIRST,[hl]
		jr	z,.notfirst
		res	DANCEFLG_FIRST,[hl]
		call	FadeIn
		xor	a
		ldh	[hVbl8],a
.notfirst:
		ldh	a,[dance_num]
		ld	b,a
		ldh	a,[dance_count]
		inc	a
		cp	b
		jr	c,.aok
		ldh	a,[dance_type]
		cp	8
		jr	z,disneydone
		xor	a
.aok:		ldh	[dance_count],a

		ldh	a,[dance_wait]
		call	AccurateWait
		jr	disneyloop

disneydone:	call	dance_shutdown
		ret
gmbdisney:	ld	de,MAP
		ld	hl,IDX_DISNEYBWMAP	;disneybwmap
		ld	bc,0
		call	dancemapfix
		ld	hl,IDX_DISNEYBWCHR	;disneybwchr
		ld	de,$c800
		call	SwdInFileSys
		ld	hl,$c800
		ld	de,$9000
		ld	c,$80
		call	DumpChrs
		ld	de,$8800
		ld	c,$5f
		call	DumpChrs
		call	disneycopy
		call	disneyflip
		call	FadeIn
		ld	a,120
		ldh	[dance_count],a
.gmbwait:	call	WaitForVBL
		ld	a,[wAvoidIntro]
		or	a
		jr	z,.noskipout
		ld	a,$ff
		call	noisyReadJoypad
		ld	a,[wJoy1Hit]
		or	a
		jr	nz,.out
.noskipout:	ld	hl,dance_count
		dec	[hl]
		jr	nz,.gmbwait
.out:		jp	FadeOut



;a=0 means cannot exit until looped through credits once
; !=0 means exit anytime
Dance::

		push	af
		ld	hl,hTemp48
		ld	bc,48
		call	MemClear
		pop	af
		ldh	[dance_exitok],a
		ld	a,LOW(dancepal)
		ldh	[dance_pallo],a
		ld	a,HIGH(dancepal)
		ldh	[dance_palhi],a
		ld	a,22
		ldh	[dance_num],a
		ld	a,64
		ldh	[dance_wait],a

		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ld	a,0
		jr	z,.aok
		ld	a,4
.aok:
		ldh	[dance_type],a
		ld	hl,swdanimtbl
		call	addahl
		ld	a,[hli]
		ldh	[dance_maplo],a
		ld	a,[hli]
		ldh	[dance_maphi],a
		ld	a,[hli]
		ldh	[dance_chrlo],a
		ld	a,[hl]
		ldh	[dance_chrhi],a

		xor	a
		ldh	[dance_count],a

		call	dance_setup
		call	creditsetup
danceloop::
		call	ReadJoypad
		ldh	a,[dance_exitok]
		or	a
		jr	z,.noexit
		ld	a,[wJoy1Hit]
		or	a
		jp	nz,dancedone
.noexit:
		ldh	a,[dance_count]
		or	a
		call	z,drawcredit

		ldh	a,[dance_count]
		call	dancerender
		call	dancecopy
		call	danceflip
		ld	hl,dance_flags
		bit	DANCEFLG_FIRST,[hl]
		jr	z,.notfirst
		res	DANCEFLG_FIRST,[hl]
		LD	A,%10010011		;Initialize screen fade.
		LD	[wFadeVblBGP],A
		LD	[wFadeOBP0],A
		LD	[wFadeLycBGP],A
		LD	A,[wGmbPal2]
		LD	[wFadeOBP1],A

		call	FadeInBlack
		xor	a
		ldh	[hVbl8],a
.notfirst:
		ldh	a,[dance_num]
		ld	b,a
		ldh	a,[dance_count]
		inc	a
		cp	b
		jr	c,.aok
		ldh	a,[dance_type]
		cp	8
		jr	z,dancedone
		xor	a
.aok:		ldh	[dance_count],a

		ldh	a,[dance_wait]
		call	AccurateWait
		jr	danceloop

dancedone:	call	dance_shutdown
		ret


dance_setup:	ldh	a,[dance_type]
		cp	8
		jr	nc,.notune
		ld	a,SONG_DANCE
		call	InitTunePref
.notune:	ldh	a,[dance_pallo]
		ld	l,a
		ldh	a,[dance_palhi]
		ld	h,a
		call	LoadPalHL

		ld	hl,dance_flags
		set	DANCEFLG_FIRST,[hl]
		ret

dance_shutdown:	call	FadeOutBlack
		ret



dancecopy:	ld	hl,MAP+6*$20
		ldh	a,[dance_phase]
		srl	a
		ld	de,$9800+6*$20
		jr	nc,.deok
		ld	de,$9c00+6*$20
.deok:		ld	c,2*12
		push	de
		call	DumpChrs
		pop	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,ATTR+6*$20
		ld	c,2*12
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret

disneycopy:	ld	hl,MAP
		ldh	a,[dance_phase]
		srl	a
		ld	de,$9800
		jr	nc,.deok
		ld	de,$9c00
.deok:		ld	c,2*18
		push	de
		call	DumpChrs
		pop	de
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		ret	nz
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,ATTR
		ld	c,2*18
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ret



dancerender:
		ld	l,a
		push	hl
		ldh	a,[dance_maplo]
		add	l
		ld	l,a
		ldh	a,[dance_maphi]
		adc	0
		ld	h,a

		ld	de,MAP
		ld	c,0
		ld	b,$00
		call	dancemapfix
		ld	hl,MAP
		ld	de,32-20
		ld	b,$80
.y:		ld	c,20
		ld	a,b
.x:		ld	[hli],a
		add	6
		dec	c
		jr	nz,.x
		add	hl,de
		inc	b
		ld	a,b
		cp	$86
		jr	nz,.y

		pop	hl
		ldh	a,[dance_chrlo]
		add	l
		ld	l,a
		ldh	a,[dance_chrhi]
		adc	0
		ld	h,a
		ld	de,$d000
		call	SwdInFileSys
		ld	hl,$d000
		ld	de,$8000
		ldh	a,[dance_phase]
		srl	a
		jr	c,.deok
		ld	de,$9000
.deok:		ld	c,$80
		jp	DumpChrs




disneyrender::
		ld	l,a
		cp	40
		jr	c,.lok
		ld	l,39
.lok:		push	hl
		ldh	a,[dance_maplo]
		add	l
		ld	l,a
		ldh	a,[dance_maphi]
		adc	0
		ld	h,a

		ld	de,MAP
		ld	b,$08
		ldh	a,[dance_phase]
		srl	a
		jr	c,.cok
		ld	b,$00
.cok:		ld	c,0
		call	dancemapfix
		pop	hl
		ldh	a,[dance_chrlo]
		add	l
		ld	l,a
		ldh	a,[dance_chrhi]
		adc	0
		ld	h,a
		ld	de,$c800
		call	SwdInFileSys
		ld	a,[dance_phase]
		and	1
		LDH	[hVidBank],A
		LDIO	[rVBK],A


		ld	hl,$c800
		ld	de,$9000
		ld	c,$80
		call	DumpChrs
		ld	de,$8800
		ld	c,$5f
		call	DumpChrs
		xor	a
		ldh	[hVidBank],a
		LDIO	[rVBK],A
		ret



		

danceflip:	ldh	a,[dance_phase]
		inc	a
		ldh	[dance_phase],a
		srl	a
		ld	a,%10011111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret

disneyflip:	ldh	a,[dance_phase]
		inc	a
		ldh	[dance_phase],a
		srl	a
		ld	a,%10001111
		jr	nc,.aok
		ld	a,%10000111
.aok:		ldh	[hVblLCDC],a
		ret



;hl=id #
;de=dest
;c=add value for map
;b=add value for attr
dancemapfix:	push	de
		push	bc
		ld	de,$c800
		call	SwdInFileSys
		pop	bc
		ld	a,c
		ldh	[hTmpLo],a
		ld	a,b
		ldh	[hTmpHi],a
		pop	de
		ld	hl,$c800+8
		ld	c,18
.y1:		ld	b,20
.x1:		ldh	a,[hTmpLo]
		add	[hl]
		inc	hl
		inc	hl
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.x1
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.y1

		ld	hl,$c800+8
		ld	c,18
.y2:		ld	b,20
.x2:		inc	hl
		ldh	a,[hTmpHi]
		add	[hl]
		inc	hl
		ld	[de],a
		inc	e
		dec	b
		jr	nz,.x2
		ld	a,e
		add	12
		ld	e,a
		ld	a,d
		adc	0
		ld	d,a
		dec	c
		jr	nz,.y2
		ret

creditsetup:

		ld	hl,$c800
		ld	de,32-20
		ld	b,$80
.y:		ld	c,20
		ld	a,b
.x:		ld	[hli],a
		add	6
		dec	c
		jr	nz,.x
		add	hl,de
		inc	b
		ld	a,b
		cp	$86
		jr	nz,.y

		ld	hl,$c800
		ld	de,$9800
		ld	c,2*6
		call	DumpChrs
		ld	hl,$c800
		ld	de,$9c00
		ld	c,2*6
		call	DumpChrs
		ldh	a,[hMachine]
		cp	MACHINE_CGB
		jr	nz,.noattr
		ld	hl,$c800
		ld	bc,6*$20
		ld	a,6
		call	MemFill
		LD	A,1
		LDH	[hVidBank],A
		LDIO	[rVBK],A
		ld	hl,$c800
		ld	de,$9800
		ld	c,2*6
		call	DumpChrs
		ld	hl,$c800
		ld	de,$9c00
		ld	c,2*6
		call	DumpChrs
		XOR	A
		LDH	[hVidBank],A
		LDIO	[rVBK],A

.noattr:

		ret





drawcredit:
		ld	hl,$c800
		ld	bc,$10*6*20
		call	MemClear

		ld	a,1
		ld	[wFontFlg],a

		call	pickend

.back:		ldh	a,[dance_credit]
		add	a
		ld	hl,credits
		call	addahl
		ld	a,[hli]
		ld	h,[hl]
		ld	l,a
		or	h
		jr	nz,.inccredits
		xor	a
		ldh	[dance_credit],a
		dec	a
		ldh	[dance_exitok],a
		jr	.back
.inccredits:	ldh	a,[dance_credit]
		inc	a
		ldh	[dance_credit],a

		ld	b,h
		ld	c,l
		call	NextICmd

		ld	hl,$c800
		ld	de,$8800
		ld	c,120
		jp	DumpChrs

		IF	VERSION_JAPAN
SPECIALFONTEND	EQUS	"FontLarge"
SPECIALFONTDARK	EQUS	"FontSmall"
		ELSE
SPECIALFONTEND	EQUS	"FontEnd"
SPECIALFONTDARK	EQUS	"FontDark"
		ENDC



;credit1:	db	ICMD_FONT
;		dw	SPECIALFONTEND
;		db	ICMD_FASTSTR
;		db	80,24,0,1
;		db	"Beauty and the Beast",0
;		db	0
;		db	ICMD_END
credit1:	db	ICMD_FONT
		dw	SPECIALFONTDARK
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"LEFT FIELD PRODUCTIONS",0
		db	0
		db	ICMD_FASTSTR
		db	80,28,0,1
		db	"TEAM MEMBERS...",0
		db	0
		db	ICMD_END

credit2:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Programming",0
		db	80,36,0,1
		db	"David Ashley",0
		db	0
		db	ICMD_END
credit3:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Programming",0
		db	80,36,0,1
		db	"John Brandwood",0
		db	0
		db	ICMD_END
credit4:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Lead Artist",0
		db	80,36,0,1
		db	"Robert Hemphill",0
		db	0
		db	ICMD_END
credit5:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Lead Animator",0
		db	80,36,0,1
		db	"Roger Hardy Jr.",0
		db	0
		db	ICMD_END
credit6:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Producer and Designer",0
		db	80,36,0,1
		db	"James Maxwell",0
		db	0
		db	ICMD_END
credit7:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Additional Design",0
		db	80,36,0,1
		db	"Robert Hemphill",0
		db	0
		db	ICMD_END
credit8:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Additional Design",0
		db	80,36,0,1
		db	"Roger Hardy Jr.",0
		db	0
		db	ICMD_END
credit9:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Sound FX and Music",0
		db	80,36,0,1
		db	"Chris Lamb",0
		db	0
		db	ICMD_END
credit10:	db	ICMD_FONT
		dw	SPECIALFONTDARK
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"DISNEY INTERACTIVE",0
		db	0
		db	ICMD_FASTSTR
		db	80,28,0,1
		db	"TEAM MEMBERS...",0
		db	0
		db	ICMD_END

credit11:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Senior Producer",0
		db	80,36,0,1
		db	"Dan Winters",0
		db	0
		db	ICMD_END
credit12:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Assistant Producer",0
		db	80,36,0,1
		db	"Renee Johnson",0
		db	0
		db	ICMD_END
credit13:	db	ICMD_FONT
		dw	SPECIALFONTDARK
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"NINTENDO OF AMERICA",0
		db	0
		db	ICMD_FASTSTR
		db	80,28,0,1
		db	"TEAM MEMBERS...",0
		db	0
		db	ICMD_END
credit15:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Producer",0
		db	80,36,0,1
		db	"Erich Waas",0
		db	0
		db	ICMD_END
credit16:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Testing",0
		db	80,36,0,1
		db	"Teresa Lillygren",0
		db	0
		db	ICMD_END
credit17:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Testing",0
		db	80,36,0,1
		db	"Brent Clearman",0
		db	0
		db	ICMD_END
credit18:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Testing",0
		db	80,36,0,1
		db	"Dougall Campbell",0
		db	0
		db	ICMD_END
credit19:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Special thanks",0
		db	80,36,0,1
		db	"Mr. Arakawa",0
		db	0
		db	ICMD_END
credit20:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Special thanks",0
		db	80,36,0,1
		db	"Howard Lincoln",0
		db	0
		db	ICMD_END
credit21:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Special thanks",0
		db	80,36,0,1
		db	"Mr. Fukuda",0
		db	0
		db	ICMD_END
credit22:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Special thanks",0
		db	80,36,0,1
		db	"Ms. Gail Tilden",0
		db	0
		db	ICMD_END
credit23:	db	ICMD_FONT
		dw	SPECIALFONTEND
		db	ICMD_FASTSTR
		db	80,18,0,1
		db	"Special thanks",0
		db	80,36,0,1
		db	"Ken Lobb",0
		db	0
		db	ICMD_END




credits:	dw	credit1
;		dw	credit1b
		dw	credit2
		dw	credit3
		dw	credit4
		dw	credit5
		dw	credit6
		dw	credit7
		dw	credit8
		dw	credit9
		dw	credit10
		dw	credit11
		dw	credit12
		dw	credit13
		dw	credit15
		dw	credit16
		dw	credit17
		dw	credit18
		dw	credit19
		dw	credit20
		dw	credit21
		dw	credit22
		dw	credit23
		dw	0





dancepal:	incbin	"res/dave/dance/fd000.rgb"
disneypal:	incbin	"res/dave/logo/disney00.rgb"

dance_end::
