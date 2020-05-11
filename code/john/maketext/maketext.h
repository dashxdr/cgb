// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** MAKETEXT.H                                                   PROGRAM **
// **                                                                      **
// ** Purpose       :                                                      **
// **                                                                      **
// ** To concatenate a number of files into a single file.                 **
// **                                                                      **
// ** Last modified : 29 Jul 1998 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __MAKETEXT_h
#define __MAKETEXT_h

#ifndef __LFPTYPES_h
 #include "lfptypes.h"
#endif

//
//
//

#define	ANSI_OE			0x8C
#define	ANSI_oe			0x9C

#define	ANSI_invpoint	0xA1
#define	ANSI_invqmark	0xBF

#define	ANSI_Abak		0xC0
#define	ANSI_Afwd		0xC1
#define	ANSI_Ahat		0xC2
#define	ANSI_Atilde		0xC3
#define	ANSI_Aumlaut	0xC4
#define	ANSI_Ablob		0xC5
#define	ANSI_AE			0xC6
#define	ANSI_Ccedila	0xC7
#define	ANSI_Ebak		0xC8
#define	ANSI_Efwd		0xC9
#define	ANSI_Ehat		0xCA
#define	ANSI_Eumlaut	0xCB
#define	ANSI_Ibak		0xCC
#define	ANSI_Ifwd		0xCD
#define	ANSI_Ihat		0xCE
#define	ANSI_Iumlaut	0xCF
#define	ANSI_Ntilde		0xD1
#define	ANSI_Obak		0xD2
#define	ANSI_Ofwd		0xD3
#define	ANSI_Ohat		0xD4
#define	ANSI_Otilde		0xD5
#define	ANSI_Oumlaut	0xD6
#define	ANSI_Ubak		0xD9
#define	ANSI_Ufwd		0xDA
#define	ANSI_Uhat		0xDB
#define	ANSI_Uumlaut	0xDC
#define	ANSI_Yfwd		0xDD
#define	ANSI_BS			0xDF

#define	ANSI_abak		0xE0
#define	ANSI_afwd		0xE1
#define	ANSI_ahat		0xE2
#define	ANSI_atilde		0xE3
#define	ANSI_aumlaut	0xE4
#define	ANSI_ablob		0xE5
#define	ANSI_ae			0xE6
#define	ANSI_ccedila	0xE7
#define	ANSI_ebak		0xE8
#define	ANSI_efwd		0xE9
#define	ANSI_ehat		0xEA
#define	ANSI_eumlaut	0xEB
#define	ANSI_ibak		0xEC
#define	ANSI_ifwd		0xED
#define	ANSI_ihat		0xEE
#define	ANSI_iumlaut	0xEF
#define	ANSI_ntilde		0xF1
#define	ANSI_obak		0xF2
#define	ANSI_ofwd		0xF3
#define	ANSI_ohat		0xF4
#define	ANSI_otilde		0xF5
#define	ANSI_oumlaut	0xF6
#define	ANSI_ubak		0xF9
#define	ANSI_ufwd		0xFA
#define	ANSI_uhat		0xFB
#define	ANSI_uumlaut	0xFC
#define	ANSI_yfwd		0xFD
#define	ANSI_yumlaut	0xFF

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// Macros for converting to/from different byte-ordering.
//
// These should be used whenever reading from a file, to convert the data
// into the correct format for the processor.

#define	SwapD16(x) \
	((((x)>>8) & 0x00FFu) | (((x)<<8) & 0xFF00u))

#define	SwapD32(x) \
	( (((x)>>24) & 0x000000FFul) | (((x)>>8)  & 0x0000FF00ul) \
	| (((x)<<8)  & 0x00FF0000ul) | (((x)<<24) & 0xFF000000ul))

#ifdef BYTE_ORDER_LO_HI
	#define XvertD16LOHI(x)	x
	#define XvertD32LOHI(x)	x
	#define	XvertD16HILO(x) \
		((((x)>>8) & 0x00FFu) | (((x)<<8) & 0xFF00u))
	#define	XvertD32HILO(x) \
		( (((x)>>24) & 0x000000FFul) | (((x)>>8)  & 0x0000FF00ul) \
		| (((x)<<8)  & 0x00FF0000ul) | (((x)<<24) & 0xFF000000ul))
#endif

#ifdef BYTE_ORDER_HI_LO
	#define	XvertD16HILO(x) \
		((((x)>>8) & 0x00FFu) | (((x)<<8) & 0xFF00u))
	#define	XvertD32HILO(x) \
		( (((x)>>24) & 0x000000FFul) | (((x)>>8)  & 0x0000FF00ul) \
		| (((x)<<8)  & 0x00FF0000ul) | (((x)<<24) & 0xFF000000ul))
	#define XvertD16LOHI(x)	x
	#define XvertD32LOHI(x)	x
#endif

// Macros for creating 2 and 4 byte ASCII identifiers used by IFF, RIFF,
// etc.

//typedef SW		ID2;
//typedef SD		ID4;

extern	char	ID2String[4];
extern	char	ID4String[8];

#define	ID_NONE	0L

#if BYTE_ORDER_HI_LO
	#define	MakeID2(a,b)		\
		(((ID2)(a)<<8) | ((ID2)(b)))
	#define	MakeID4(a,b,c,d)	\
		(((ID4)(a)<<24) | ((ID4)(b)<<16) | ((ID4)(c)<<8) | ((ID4)(d)))
#endif

#if BYTE_ORDER_LO_HI
	#define	MakeID2(a,b)		\
		(((ID2)(b)<<8) | ((ID2)(a)))
	#define	MakeID4(a,b,c,d)	\
		(((ID4)(d)<<24) | ((ID4)(c)<<16) | ((ID4)(b)<<8) | ((ID4)(a)))
#endif

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	int         main                    (
								int                 argc,
								char **             argv);

//
// End of __MAKETEXT_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF MAKETEXT.H
// **************************************************************************
// **************************************************************************
// **************************************************************************
