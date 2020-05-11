// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** BMP.H                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Microsoft's BMP (aka DIB) format.                                 **
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

#ifndef __BMP_h
#define __BMP_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// BMP specific error codes.

#define	ERROR_BMP_NOT_HANDLED   -256L
#define ERROR_BMP_TRUNCATED     -257L
#define ERROR_BMP_MALFORMED     -258L
#define ERROR_BMP_MISSING       -259L

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	FILETYPE_T          BmpIdentify             (
								FILE *              pcl__File);

extern	ERRORCODE           BmpInitRead             (
								void **             ppcl_Context,
								FILE *              pcl__File,
								DATATYPE_T          ui___Wanted);

extern	DATABLOCK_T *       BmpReadData             (
								void **             ppcl_Context);

extern	FILE *              BmpQuitRead             (
								void **             ppcl_Context);

extern	ERRORCODE           BmpDumpFrame            (
								DATABLOCK_T *       d,
								char *              filename);

//
// End of __BMP_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF BMP.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

