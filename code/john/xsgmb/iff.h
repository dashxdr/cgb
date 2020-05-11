// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** IFF.H                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Electronic Arts' IFF format.                                      **
// **                                                                      **
// ** The following IFF FORMs are supported ...                            **
// **                                                                      **
// ** FORM ANIM                                                            **
// ** FORM ILBM                                                            **
// ** FORM PBM                                                             **
// **                                                                      **
// ** Complex IFF files containing LIST, PROP and CAT groups are correctly **
// ** supported.                                                           **
// **                                                                      **
// ** Limitations ...                                                      **
// **                                                                      **
// ** Lots.                                                                **
// **                                                                      **
// ** PBMs are working (IBM DPaint/DAnim) but I never bothered to get the  **
// ** ILBM code finished (Amiga DPaint/DAnim).                             **
// **                                                                      **
// ** Last modified : 04 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __IFF_h
#define __IFF_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// IFF specific error codes.

#define	ERROR_IFF_NOT_HANDLED   -256L
#define ERROR_IFF_TRUNCATED     -257L
#define ERROR_IFF_MALFORMED     -258L
#define ERROR_IFF_MISSING       -259L

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	FILETYPE_T          IffIdentify             (
								FILE *              file);

extern	ERRORCODE           IffInitRead             (
								void **             cp,
								FILE *              file,
								DATATYPE_T          dt);

extern	DATABLOCK_T *       IffReadData             (
								void **             cp);

extern	FILE *              IffQuitRead             (
								void **             cp);

//
// End of __IFF_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF IFF.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

