// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTN64.H                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Nintendo 64 format.                                             **
// **                                                                      **
// ** Last modified : 14 Aug 1997 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERTN64_h
#define __XVERTN64_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	BUFFER *            BitmapToN64Spr          (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max);

extern	ERRORCODE           ReformatSprsForN64      (
								DATASPRSET_T *      pcl__Spr,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res);

extern	UI                  PxlToN648x8x4           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UI                  PxlToN648x8x8           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UW *                ReformatMapsForN64      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount);

//
// End of __XVERTN64_h
//

#endif


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTN64.H
// **************************************************************************
// **************************************************************************
// **************************************************************************
