// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTIBM.H                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into PC format.                                                      **
// **                                                                      **
// ** Last modified : 12 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERTIBM_h
#define __XVERTIBM_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

//
// GLOBAL VARIABLES
//

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	BUFFER *            BitmapToIBMSpr          (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max);

extern	ERRORCODE           ReformatSprsForIBM      (
								DATASPRSET_T *      pcl__Spr,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res);

extern	UI                  PxlToIBM8x8x4           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UI                  PxlToIBM8x8x8           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth);

extern	UW *                ReformatMapsForIBM      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount);

//
// End of __XVERTIBM_h
//

#endif


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTIBM.H
// **************************************************************************
// **************************************************************************
// **************************************************************************

