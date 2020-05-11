// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** ELMER.H                                                       MODULE **
// **                                                                      **
// ** Purpose       :                                                      **
// **                                                                      **
// ** Standard definitions, data types, and variables used in all of my    **
// ** code.                                                                **
// **                                                                      **
// ** Dependencies  :                                                      **
// **                                                                      **
// ** ELMER    .H                                                          **
// **                                                                      **
// ** Last modified : 31 Oct 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __ELMER_h
#define __ELMER_h

#ifndef __LFPTYPES_H
#include "lfptypes.h"
#endif

// ** WARNING ***************************************************************
// ** WARNING ***************************************************************
// ** WARNING ***************************************************************
//
// The following assumptions are made throughout my code about
// the size of various types, and things will break down badly
// if the assumptions are incorrect ...
//
// type int    MUST be at least 16 bits,
// type long   MUST be at least 32 bits,
// type size_t MUST be at least 32 bits.
//
// The requirement that size_t be at least 32 bits will not be
// fulfilled by most MSDOS compilers except when compiling for
// a DOS extender.
//
// ** WARNING ***************************************************************
// ** WARNING ***************************************************************
// ** WARNING ***************************************************************


// #define STR	char *

#define BUFFER unsigned char

/*
#define UB    unsigned char
#define SB      signed char
#define UW    unsigned short
#define SW      signed short
#define UD   unsigned int
#define SD      signed int
#define UV     unsigned int
#define SV       signed int
*/

// Typedef a structure to hold any type of pointer.

typedef union ANYPTR_U
	{
	UC *     ucp;
	US *     usp;
	UI *     uip;
	UL *     ulp;
	SC *     scp;
	SS *     ssp;
	SI *     sip;
	SL *     slp;
	UB *     ubp;
	UW *     uwp;
	UD *     udp;
	SB *     sbp;
	SW *     swp;
	UD *     sdp;
	BUFFER * bfp;
	} ANYPTR_T;

// Determine where to send error messages since stderr can't be redirected
// with MS-DOS.

#if MSDOS
	#define ferr	stdout
#else
	#define ferr	stdout
#endif

// Fatal error flag.
//
// Used to signal that the error returned by ErrorCode (see below) is fatal
// and that the program should terminate immediately.

#define	NO                  (0)
#define	YES                 (~0)

extern	FL                  FatalError;

// Global error reporting variables.
//
// Used by all functions to indicate what error has occurred if they signal
// that something has gone wrong.
//
// The string ErrorMessage will be printed out to tell the user what error
// has occurred.
//
// Values of -1 to -255 are reserved to indicate standard OS errors.
// Values <= -256 should be used to indicate code specific errors.

typedef	SL                  ERRORCODE;

extern	ERRORCODE           ErrorCode;
extern	char                ErrorMessage[256];

#define ERROR_NONE           0L
#define ERROR_DIAGNOSTIC    -1L
#define	ERROR_NO_MEMORY     -2L
#define	ERROR_NO_FILE       -3L
#define	ERROR_IO_EOF        -4L
#define	ERROR_IO_READ       -5L
#define	ERROR_IO_WRITE      -6L
#define	ERROR_IO_SEEK       -7L
#define	ERROR_PROGRAM       -8L
#define	ERROR_UNKNOWN       -9L
#define	ERROR_ILLEGAL      -10L

// FlipTable[] - Index into this table to get bit reversed value of a byte.

extern	UB                  FlipTable[256];

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

// When a routine returns an error code to indicate that something has
// gone wrong, it will usually set up the string ErrorMessage to indicate
// what the error was.  Some errors are so generic that the routine will
// just return an error code and not set up ErrorMessage.
//
// If you are going to print out the ErrorMessage string to tell the user
// that something has gone wrong, then you should call ErrorQualify() first
// so that if the routine itself did not supply a message then it can set
// up a default one.

extern	void						ErrorQualify (void);

// Once you have acknowledged that an error has occurred, then you should
// call ErrorReset() to reset the error code and the error message before
// using any of my library functions again.

extern	void						ErrorReset (void);

//
// End of __ELMER_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF ELMER.H
// **************************************************************************
// **************************************************************************
// **************************************************************************
