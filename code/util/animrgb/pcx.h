// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** PCX.H                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Zsoft's PCX format.                                               **
// **                                                                      **
// ** Limitations ...                                                      **
// **                                                                      **
// ** Lots.                                                                **
// **                                                                      **
// ** Only the following file contents are currently understood ...        **
// **                                                                      **
// **   1 bits-per-pixel, 4 plane,  16 colour palette.                     **
// **   8 bits-per-pixel, 1 plane, 256 colour palette.                     **
// **                                                                      **
// ** Last modified : 04 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __PCX_h
#define __PCX_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// PCX specific error codes.

#define	ERROR_PCX_NOT_HANDLED   -256L
#define ERROR_PCX_TRUNCATED     -257L
#define ERROR_PCX_MALFORMED     -258L
#define ERROR_PCX_MISSING       -259L

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	FILETYPE_T          PcxIdentify             (
								FILE *              pcl__File);

extern	ERRORCODE           PcxInitRead             (
								void **             ppcl_Context,
								FILE *              pcl__File,
								DATATYPE_T          ui___Wanted);

extern	DATABLOCK_T *       PcxReadData             (
								void **             ppcl_Context);

extern	FILE *              PcxQuitRead             (
								void **             ppcl_Context);

extern	ERRORCODE           PcxDumpBitmap           (
								DATABLOCK_T *       d,
								char *              filename);

//
// End of __PCX_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF PCX.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

