// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTSAT.H                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Saturn format.                                                  **
// **                                                                      **
// ** Last modified : 12 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERTSAT_h
#define __XVERTSAT_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	BUFFER *            BitmapToSATSpr          (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max);

extern	ERRORCODE           ReformatSprsForSAT      (
								DATASPRSET_T *      pcl__Spr,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res);

extern	UI                  PxlToSAT8x8x4           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UI                  PxlToSAT8x8x8           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UW *                ReformatMapsForSAT      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount);

//
// End of __XVERTSAT_h
//

#endif


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTSAT.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

