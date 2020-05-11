// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** TGA.H                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in TrueVision's TGA format.                                          **
// **                                                                      **
// ** Limitations ...                                                      **
// **                                                                      **
// ** Lots.                                                                **
// **                                                                      **
// ** Only the following file contents are currently understood ...        **
// **                                                                      **
// **   Colour-mapped 8 bits-per-pixel.                                    **
// **                                                                      **
// ** Last modified : 03 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __TGA_h
#define __TGA_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// TGA specific error codes.

#define	ERROR_TGA_NOT_HANDLED   -256L
#define ERROR_TGA_TRUNCATED     -257L
#define ERROR_TGA_MALFORMED     -258L
#define ERROR_TGA_MISSING       -259L

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	FILETYPE_T          tga_Identify            (
								FILE *              pcl__File);

extern	ERRORCODE           tga_InitRead            (
								void **             ppcl_Context,
								FILE *              pcl__File,
								DATATYPE_T          ui___Wanted);

extern	DATABLOCK_T *       tga_ReadData            (
								void **             ppcl_Context);

extern	FILE *              tga_QuitRead            (
								void **             ppcl_Context);

//
// End of __TGA_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF TGA.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

