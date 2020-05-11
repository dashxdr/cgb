// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** MAKEPKG.H                                                    PROGRAM **
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

#ifndef __MAKEPKG_h
#define __MAKEPKG_h

#ifndef __LFPTYPES_h
 #include "lfptypes.h"
#endif

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

typedef SW		ID2;
typedef SD		ID4;

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

extern	int          main                    (
								int                 argc,
								char **             argv);

//
// End of __MAKEPKG_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF MAKEPKG.H
// **************************************************************************
// **************************************************************************
// **************************************************************************
