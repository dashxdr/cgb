// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTPSX.H                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Playstation format.                                             **
// **                                                                      **
// ** Last modified : 12 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERTPSX_h
#define __XVERTPSX_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	BUFFER *            BitmapToPSXSpr          (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max);

extern	ERRORCODE           ReformatSprsForPSX      (
								DATASPRSET_T *      pcl__Spr,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res);

extern	UI                  PxlToPSX8x8x4           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UI                  PxlToPSX8x8x8           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UW *                ReformatMapsForPSX      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount);

//
// End of __XVERTPSX_h
//

#endif


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTPSX.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

