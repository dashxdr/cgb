// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTAGB.C                                                    MODULE **
// **                                                                      **
// ** Purpose       :                                                      **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Nintendo SNES format.                                           **
// **                                                                      **
// ** Dependencies  :                                                      **
// **                                                                      **
// ** ELMER    .H                                                          **
// ** MEM      .H                                                          **
// ** DATA     .H                                                          **
// ** XVERT    .H                                                          **
// ** XVERTSAGB .H .C                                                       **
// **                                                                      **
// ** Last modified : 31 Oct 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stddef.h>
#include	<stdio.h>
#include <stdlib.h>

#include	"elmer.h"
#include	"data.h"
#include	"xvert.h"
#include	"xs.h"



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL VARIABLES
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC VARIABLES
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTION PROTOTYPES
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
//	BitmapToAGBSprALL ()
//
//	Usage
//		global UW * BitmapToAGBSprALL (XVERTINFOBLOCK * pxib,
//			DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI sibmw, UI sibmh,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Turn the 256 colour bitmap data into a Super NES sprite map at pu16dst.
//		Scan the bitmap data LRTB, but do not do any optimization.
//		The conversion rectangle's top-left coordinate (sibmx,sibmy) is given
//		relative to the origin point, where the top-left coordinate of the
//		bitmap data has the value (bdXTopLeft,bdYTopLeft).
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The map data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			SW X offset from top left of chrmap to top left of data
//			SW Y offset from top left of chrmap to top left of data
//			UW data width in pixels
//			UW data height in pixels
//			UW palette number and flags
//			UW number of map sections
//				{
//				UW section X offset from top left of chrmap
//				UW section Y offset from top left of chrmap
//				UW section width in characters
//				UW section height in characters
//					{
//					UW chr number
//					}
//				}
//			}
// **************************************************************************


global	UW * BitmapToAGBSprALL (XVERTINFOBLOCK * pxib,
					DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI uibmw, UI uibmh,
					UW * pu16dst, UW * pu16max)

	{

	//
	// Local variables.
	//

	UW *							pu16num;
	UW *							pu16spr;
	UW *							pu16end;

	UB *							pu08src;
	size_t							ulwsrc;

	SI								sipxlx;
	SI								sipxly;
	UI								uipxlw;
	UI								uipxlh;
	UI								uisprw;
	UI								uisprh;
	UI								uiwchr;
	UI								uihchr;

	//
	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).
	//

	pxib->uimapPalette = 0;

	//
	// Calculate bitmap's approx size in sprs.
	//

	uiwchr = ((uibmw + 15) & (~15)) >> 3;

	uihchr = ((uibmh + 15) & (~15)) >> 3;


	//
	// Check that there is enough room to save this map given worst case
	// conversion.
	//

	if ((int) ((uiwchr * uihchr * 10) + 8) > (pu16max - pu16dst))

		{

		ErrorCode = ERROR_XVERT_MAPFULL;

		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToAGBSprLRTB)\n");

		goto errorExit;

		}


	//
	// Save the map's size and position, and get the map data pointer.
	//
	// N.B. Allow for 8 pxls around the edge for overrun during RLBT and
	// BTRL scans.
	//

	pu16dst[0] = sibmx - 16;
	pu16dst[1] = sibmy - 16;
	pu16dst[2] = 16;
	pu16dst[3] = 16;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;
	pu16dst[6] = 0;
	pu16dst[7] = 0;

	pu16num = pu16dst + 7;

	pu16end = pu16dst + 8;


	//
	// Set the initial source Y position and height.
	//

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	sipxly = sibmy;
	uipxlh = uibmh;


	//
	// Scan across each row, from the top row to the bottom row.
	//

	while (uipxlh != 0)

		{

		//
		// Calculate the spr height at this point.
		//

		uisprh = 16;

		if (uipxlh < 16)
			{
			uisprh = uipxlh;
			}

		uihchr = 2;


		//
		// Set the initial source X position and width.
		//

		sipxlx = sibmx;
		uipxlw = uibmw;


		//
		// Scan from left to right across this row.
		//

		while (uipxlw != 0)

			{

			//
			// Calculate the spr width at this point.
			//

			uisprw = 16;

			if (uipxlw < 16)
				{
				uisprw = uipxlw;
				}

			uiwchr = 2;


			//
			// Calculate the pxl data address.
			//

			pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;


			//
			// Save the spr position, size and data.
			//

			pu16spr = pu16end;

			pu16end[0] = sipxlx - (sibmx - 16);
			pu16end[1] = sipxly - (sibmy - 16);
			pu16end[2] = uiwchr;
			pu16end[3] = uihchr;

			pu16end = pu16end + 4;

			if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, ORDER_LRTB,
				pu16end)) == NULL)
				{
				goto errorExit;
				}

			*pu16num = *pu16num + 1;


			//
			// Run the spr through the optimizer.
			//

			pu16end = OptimizeAGBSpr(pu16spr, pu16num);


			//
			// Update the source position and width.
			//

			sipxlx = sipxlx + uisprw;
			uipxlw = uipxlw - uisprw;


			//
			// End of while (uipxlw != 0)
			//

			}


		//
		// Update the source position and width.
		//

		sipxly = sipxly + uisprh;
		uipxlh = uipxlh - uisprh;


		//
		// End of while (uipxlh != 0)
		//

		}


	//
	// Fill in the map palette (and set the SPR flag).
	//

	pu16dst[6] = ((pxib->uimapPalette & 0x00FFu) | 0x8000u);


	//
	// Select sorting keys.
	//

	pxib->uisort1 = *pu16num;
	pxib->uisort2 = pxib->n.dcinew.ui___chrCount;


	//
	// Return with success code.
	//

	return (pu16end);


	//
	// Error handlers (reached via the dreaded goto).
	//

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	BitmapToAGBSprLRTB ()
//
//	Usage
//		global UW * BitmapToAGBSprLRTB (XVERTINFOBLOCK * pxib,
//			DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI sibmw, UI sibmh,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Turn the 256 colour bitmap data into a Super NES sprite map at pu16dst.
//		Scan the bitmap data LRTB.
//		The conversion rectangle's top-left coordinate (sibmx,sibmy) is given
//		relative to the origin point, where the top-left coordinate of the
//		bitmap data has the value (bdXTopLeft,bdYTopLeft).
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The map data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			SW X offset from top left of chrmap to top left of data
//			SW Y offset from top left of chrmap to top left of data
//			UW data width in pixels
//			UW data height in pixels
//			UW palette number and flags
//			UW number of map sections
//				{
//				UW section X offset from top left of chrmap
//				UW section Y offset from top left of chrmap
//				UW section width in characters
//				UW section height in characters
//					{
//					UW chr number
//					}
//				}
//			}
// **************************************************************************


global	UW * BitmapToAGBSprLRTB (XVERTINFOBLOCK * pxib,
					DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI uibmw, UI uibmh,
					UW * pu16dst, UW * pu16max)

	{

	//
	// Local variables.
	//

	UW *							pu16num;
	UW *							pu16spr;
	UW *							pu16end;

	UB *							pu08src;
	size_t						ulwsrc;

	SI								sipxlx;
	SI								sipxly;
	UI								uipxlw;
	UI								uipxlh;
	UI								uisprw;
	UI								uisprh;
	UI								uiwchr;
	UI								uihchr;

	UI								uii;


	//
	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).
	//

	pxib->uimapPalette = 0;


	//
	// Calculate bitmap's approx size in sprs.
	//

	uiwchr = ((uibmw + 15) & (~15)) >> 3;

	uihchr = ((uibmh + 15) & (~15)) >> 3;


	//
	// Check that there is enough room to save this map given worst case
	// conversion.
	//

	if ((int) ((uiwchr * uihchr * 10) + 8) > (pu16max - pu16dst))

		{

		ErrorCode = ERROR_XVERT_MAPFULL;

		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToAGBSprLRTB)\n");

		goto errorExit;

		}


	//
	// Save the map's size and position, and get the map data pointer.
	//
	// N.B. Allow for 8 pxls around the edge for overrun during RLBT and
	// BTRL scans.
	//

	pu16dst[0] = sibmx - 16;
	pu16dst[1] = sibmy - 16;
	pu16dst[2] = 16;
	pu16dst[3] = 16;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;
	pu16dst[6] = 0;
	pu16dst[7] = 0;

	pu16num = pu16dst + 7;

	pu16end = pu16dst + 8;


	//
	// Set the initial source Y position and height.
	//

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	sipxly = sibmy;
	uipxlh = uibmh;


	//
	// Scan across each row, from the top row to the bottom row.
	//

	while (uipxlh != 0)

		{

		//
		// Calculate the spr height at this point.
		//

		uisprh = 16;

		if (uipxlh < 16)
			{
			uisprh = uipxlh;
			}

		uihchr = 2;


		//
		// Set the initial source X position and width.
		//

		sipxlx = sibmx;
		uipxlw = uibmw;


		//
		// Scan from left to right across this row.
		//

		while (uipxlw != 0)

			{

			//
			// Scan downwards looking for a non-zero pixel.
			//

			pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;

			for (uii = uisprh; uii != 0; uii = uii - 1)
				{
				if (*pu08src != 0) break;
				pu08src = pu08src + ulwsrc;
				}


			//
			// If non-zero data was found, then convert a sprite's worth of
			// data, else move onto the next line.
			//

			if (uii != 0)

				//
				// Data found, convert sprite.
				//

				{

				//
				// Calculate the spr width at this point.
				//

				uisprw = 16;

				if (uipxlw < 16)
					{
					uisprw = uipxlw;
					}

				uiwchr = 2;


				//
				// Calculate the pxl data address.
				//

				pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;


				//
				// Save the spr position, size and data.
				//

				pu16spr = pu16end;

				pu16end[0] = sipxlx - (sibmx - 16);
				pu16end[1] = sipxly - (sibmy - 16);
				pu16end[2] = uiwchr;
				pu16end[3] = uihchr;

				pu16end = pu16end + 4;

				if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, ORDER_LRTB,
					pu16end)) == NULL)
					{
					goto errorExit;
					}

				*pu16num = *pu16num + 1;


				//
				// Run the spr through the optimizer.
				//

				pu16end = OptimizeAGBSpr(pu16spr, pu16num);


				//
				// Update the source position and width.
				//

				sipxlx = sipxlx + uisprw;
				uipxlw = uipxlw - uisprw;

				}


			else

				//
				// Empty line, move onto the next.
				//

				{

				//
				// Update the source position and width.
				//

				sipxlx = sipxlx + 1;
				uipxlw = uipxlw - 1;

				}


			//
			// End of while (uipxlw != 0)
			//

			}


		//
		// Update the source position and width.
		//

		sipxly = sipxly + uisprh;
		uipxlh = uipxlh - uisprh;


		//
		// End of while (uipxlh != 0)
		//

		}


	//
	// Fill in the map palette (and set the SPR flag).
	//

	pu16dst[6] = ((pxib->uimapPalette & 0x00FFu) | 0x8000u);


	//
	// Select sorting keys.
	//

	pxib->uisort1 = *pu16num;
	pxib->uisort2 = pxib->n.dcinew.ui___chrCount;


	//
	// Return with success code.
	//

	return (pu16end);


	//
	// Error handlers (reached via the dreaded goto).
	//

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	BitmapToAGBSprTBLR ()
//
//	Usage
//		global UW * BitmapToAGBSprTBLR (XVERTINFOBLOCK * pxib,
//			DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI sibmw, UI sibmh,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Turn the 256 colour bitmap data into a Super NES sprite map at pu16dst.
//		Scan the bitmap data TBLR.
//		The conversion rectangle's top-left coordinate (sibmx,sibmy) is given
//		relative to the origin point, where the top-left coordinate of the
//		bitmap data has the value (bdXTopLeft,bdYTopLeft).
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The map data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			SW X offset from top left of chrmap to top left of data
//			SW Y offset from top left of chrmap to top left of data
//			UW data width in pixels
//			UW data height in pixels
//			UW palette number and flags
//			UW number of map sections
//				{
//				UW section X offset from top left of chrmap
//				UW section Y offset from top left of chrmap
//				UW section width in characters
//				UW section height in characters
//					{
//					UW chr number
//					}
//				}
//			}
// **************************************************************************


global	UW * BitmapToAGBSprTBLR (XVERTINFOBLOCK * pxib,
					DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI uibmw, UI uibmh,
					UW * pu16dst, UW * pu16max)

	{

	//
	// Local variables.
	//

	UW *							pu16num;
	UW *							pu16spr;
	UW *							pu16end;

	UB *							pu08src;
	size_t						ulwsrc;

	SI								sipxlx;
	SI								sipxly;
	UI								uipxlw;
	UI								uipxlh;
	UI								uisprw;
	UI								uisprh;
	UI								uiwchr;
	UI								uihchr;

	UI								uii;


	//
	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).
	//

	pxib->uimapPalette = 0;


	//
	// Calculate bitmap's approx size in sprs.
	//

	uiwchr = ((uibmw + 15) & (~15)) >> 3;

	uihchr = ((uibmh + 15) & (~15)) >> 3;


	//
	// Check that there is enough room to save this map given worst case
	// conversion.
	//

	if ((int) ((uiwchr * uihchr * 10) + 8) > (pu16max - pu16dst))

		{

		ErrorCode = ERROR_XVERT_MAPFULL;

		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToAGBSprTBLR)\n");

		goto errorExit;

		}


	//
	// Save the map's size and position, and get the map data pointer.
	//
	// N.B. Allow for 16 pxls around the edge for overrun during RLBT and
	// BTRL scans.
	//

	pu16dst[0] = sibmx - 16;
	pu16dst[1] = sibmy - 16;
	pu16dst[2] = 16;
	pu16dst[3] = 16;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;
	pu16dst[6] = 0;
	pu16dst[7] = 0;

	pu16num = pu16dst + 7;

	pu16end = pu16dst + 8;


	//
	// Set the initial source Y position and height.
	//

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	sipxlx = sibmx;
	uipxlw = uibmw;


	//
	// Scan down each column, from the left column to the right column.
	//

	while (uipxlw != 0)

		{

		//
		// Calculate the spr height at this point.
		//

		uisprw = 16;

		if (uipxlw < 16)
			{
			uisprw = uipxlw;
			}

		uiwchr = 2;


		//
		// Set the initial source Y position and height.
		//

		sipxly = sibmy;
		uipxlh = uibmh;


		//
		// Scan from top to bottom down this column.
		//

		while (uipxlh != 0)

			{

			//
			// Scan rightwards looking for a non-zero pixel.
			//

			pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;

			for (uii = uisprw; uii != 0; uii = uii - 1)
				{
				if (*pu08src != 0) break;
				pu08src = pu08src + 1;
				}


			//
			// If non-zero data was found, then convert a sprite's worth of
			// data, else move onto the next line.
			//

			if (uii != 0)

				//
				// Data found, convert sprite.
				//

				{

				//
				// Calculate the spr height at this point.
				//

				uisprh = 16;

				if (uipxlh < 16)
					{
					uisprh = uipxlh;
					}

				uihchr = 2;


				//
				// Calculate the pxl data address.
				//

				pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;


				//
				// Save the spr position, size and data.
				//

				pu16spr = pu16end;

				pu16end[0] = sipxlx - (sibmx - 16);
				pu16end[1] = sipxly - (sibmy - 16);
				pu16end[2] = uiwchr;
				pu16end[3] = uihchr;

				pu16end = pu16end + 4;

				if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, ORDER_LRTB,
					pu16end)) == NULL)
					{
					goto errorExit;
					}

				*pu16num = *pu16num + 1;


				//
				// Run the spr through the optimizer.
				//

				pu16end = OptimizeAGBSpr(pu16spr, pu16num);


				//
				// Update the source position and width.
				//

				sipxly = sipxly + uisprh;
				uipxlh = uipxlh - uisprh;

				}


			else

				//
				// Empty line, move onto the next.
				//

				{

				//
				// Update the source position and width.
				//

				sipxly = sipxly + 1;
				uipxlh = uipxlh - 1;

				}


			//
			// End of while (uipxlh != 0)
			//

			}


		//
		// Update the source position and width.
		//

		sipxlx = sipxlx + uisprw;
		uipxlw = uipxlw - uisprw;


		//
		// End of while (uipxlw != 0)
		//

		}


	//
	// Fill in the map palette (and set the SPR flag).
	//

	pu16dst[6] = ((pxib->uimapPalette & 0x00FFu) | 0x8000u);


	//
	// Select sorting keys.
	//

	pxib->uisort1 = *pu16num;
	pxib->uisort2 = pxib->n.dcinew.ui___chrCount;


	//
	// Return with success code.
	//

	return (pu16end);


	//
	// Error handlers (reached via the dreaded goto).
	//

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	BitmapToAGBSprRLBT ()
//
//	Usage
//		global UW * BitmapToAGBSprRLBT (XVERTINFOBLOCK * pxib,
//			DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI sibmw, UI sibmh,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Turn the 256 colour bitmap data into a Super NES sprite map at pu16dst.
//		Scan the bitmap data RLBT.
//		The conversion rectangle's top-left coordinate (sibmx,sibmy) is given
//		relative to the origin point, where the top-left coordinate of the
//		bitmap data has the value (bdXTopLeft,bdYTopLeft).
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The map data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			SW X offset from top left of chrmap to top left of data
//			SW Y offset from top left of chrmap to top left of data
//			UW data width in pixels
//			UW data height in pixels
//			UW palette number and flags
//			UW number of map sections
//				{
//				UW section X offset from top left of chrmap
//				UW section Y offset from top left of chrmap
//				UW section width in characters
//				UW section height in characters
//					{
//					UW chr number
//					}
//				}
//			}
// **************************************************************************


global	UW * BitmapToAGBSprRLBT (XVERTINFOBLOCK * pxib,
					DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI uibmw, UI uibmh,
					UW * pu16dst, UW * pu16max)

	{

	//
	// Local variables.
	//

	UW *							pu16num;
	UW *							pu16spr;
	UW *							pu16end;

	UB *							pu08src;
	size_t						ulwsrc;

	SI								sipxlx;
	SI								sipxly;
	UI								uipxlw;
	UI								uipxlh;
	UI								uisprw;
	UI								uisprh;
	UI								uiwchr;
	UI								uihchr;

	UI								uii;


	//
	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).
	//

	pxib->uimapPalette = 0;


	//
	// Calculate bitmap's approx size in sprs.
	//

	uiwchr = ((uibmw + 15) & (~15)) >> 3;

	uihchr = ((uibmh + 15) & (~15)) >> 3;


	//
	// Check that there is enough room to save this map given worst case
	// conversion.
	//

	if ((int) ((uiwchr * uihchr * 10) + 8) > (pu16max - pu16dst))

		{

		ErrorCode = ERROR_XVERT_MAPFULL;

		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToAGBSprRLBT)\n");

		goto errorExit;

		}


	//
	// Save the map's size and position, and get the map data pointer.
	//
	// N.B. Allow for 16 pxls around the edge for overrun during RLBT and
	// BTRL scans.
	//

	pu16dst[0] = sibmx - 16;
	pu16dst[1] = sibmy - 16;
	pu16dst[2] = 16;
	pu16dst[3] = 16;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;
	pu16dst[6] = 0;
	pu16dst[7] = 0;

	pu16num = pu16dst + 7;

	pu16end = pu16dst + 8;


	//
	// Set the initial source Y position and height.
	//

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	uipxlh = uibmh;
	sipxly = sibmy + uibmh;


	//
	// Scan across each row, from the bottom row to the top row.
	//

	while (uipxlh != 0)

		{

		//
		// Calculate the spr height at this point.
		//

		uisprh = 16;

		if (uipxlh < 16)
			{
			uisprh = uipxlh;
			}

		uipxlh = uipxlh - uisprh;

		uisprh = (uisprh + 15) & (~15);

		uihchr = uisprh >> 3;

		sipxly = sipxly - uisprh;


		//
		// Set the initial source X position and width.
		//

		uipxlw = uibmw;
		sipxlx = sibmx + uibmw;


		//
		// Scan from right to left across this row.
		//

		while (uipxlw != 0)

			{

			//
			// Scan downwards looking for a non-zero pixel.
			//

			pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + (sipxlx - 1);

			for (uii = uisprh; uii != 0; uii = uii - 1)
				{
				if (*pu08src != 0) break;
				pu08src = pu08src + ulwsrc;
				}


			//
			// If non-zero data was found, then convert a sprite's worth of
			// data, else move onto the next line.
			//

			if (uii != 0)

				//
				// Data found, convert sprite.
				//

				{

				//
				// Calculate the spr width at this point.
				//

				uisprw = 16;

				if (uipxlw < 16)
					{
					uisprw = uipxlw;
					}

				uipxlw = uipxlw - uisprw;

				uisprw = (uisprw + 15) & (~15);

				uiwchr = uisprw >> 3;

				sipxlx = sipxlx - uisprw;


				//
				// Calculate the pxl data address.
				//

				pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;


				//
				// Save the spr position, size and data.
				//

				pu16spr = pu16end;

				pu16end[0] = sipxlx - (sibmx - 16);
				pu16end[1] = sipxly - (sibmy - 16);
				pu16end[2] = uiwchr;
				pu16end[3] = uihchr;

				pu16end = pu16end + 4;

				if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, ORDER_LRTB,
					pu16end)) == NULL)
					{
					goto errorExit;
					}

				*pu16num = *pu16num + 1;


				//
				// Run the spr through the optimizer.
				//

				pu16end = OptimizeAGBSpr(pu16spr, pu16num);


				}


			else

				//
				// Empty line, move onto the next.
				//

				{

				//
				// Update the source position and width.
				//

				sipxlx = sipxlx - 1;
				uipxlw = uipxlw - 1;

				}


			//
			// End of while (uipxlw != 0)
			//

			}


		//
		// End of while (uipxlh != 0)
		//

		}


	//
	// Fill in the map palette (and set the SPR flag).
	//

	pu16dst[6] = ((pxib->uimapPalette & 0x00FFu) | 0x8000u);


	//
	// Select sorting keys.
	//

	pxib->uisort1 = *pu16num;
	pxib->uisort2 = pxib->n.dcinew.ui___chrCount;


	//
	// Return with success code.
	//

	return (pu16end);


	//
	// Error handlers (reached via the dreaded goto).
	//

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	BitmapToAGBSprBTRL ()
//
//	Usage
//		global UW * BitmapToAGBSprBTRL (XVERTINFOBLOCK * pxib,
//			DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI sibmw, UI sibmh,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Turn the 256 colour bitmap data into a Super NES sprite map at pu16dst.
//		Scan the bitmap data BTRL.
//		The conversion rectangle's top-left coordinate (sibmx,sibmy) is given
//		relative to the origin point, where the top-left coordinate of the
//		bitmap data has the value (bdXTopLeft,bdYTopLeft).
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The map data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			SW X offset from top left of chrmap to top left of data
//			SW Y offset from top left of chrmap to top left of data
//			UW data width in pixels
//			UW data height in pixels
//			UW palette number and flags
//			UW number of map sections
//				{
//				UW section X offset from top left of chrmap
//				UW section Y offset from top left of chrmap
//				UW section width in characters
//				UW section height in characters
//					{
//					UW chr number
//					}
//				}
//			}
// **************************************************************************


global	UW * BitmapToAGBSprBTRL (XVERTINFOBLOCK * pxib,
					DATABITMAP_T * pdbiti, SI sibmx, SI sibmy, UI uibmw, UI uibmh,
					UW * pu16dst, UW * pu16max)

	{

	//
	// Local variables.
	//

	UW *							pu16num;
	UW *							pu16spr;
	UW *							pu16end;

	UB *							pu08src;
	size_t						ulwsrc;

	SI								sipxlx;
	SI								sipxly;
	UI								uipxlw;
	UI								uipxlh;
	UI								uisprw;
	UI								uisprh;
	UI								uiwchr;
	UI								uihchr;

	UI								uii;


	//
	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).
	//

	pxib->uimapPalette = 0;


	//
	// Calculate bitmap's approx size in sprs.
	//

	uiwchr = ((uibmw + 15) & (~15)) >> 3;

	uihchr = ((uibmh + 15) & (~15)) >> 3;


	//
	// Check that there is enough room to save this map given worst case
	// conversion.
	//

	if ((int) ((uiwchr * uihchr * 10) + 8) > (pu16max - pu16dst))

		{

		ErrorCode = ERROR_XVERT_MAPFULL;

		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToAGBSprBTRL)\n");

		goto errorExit;

		}


	//
	// Save the map's size and position, and get the map data pointer.
	//
	// N.B. Allow for 8 pxls around the edge for overrun during RLBT and
	// BTRL scans.
	//

	pu16dst[0] = sibmx - 16;
	pu16dst[1] = sibmy - 16;
	pu16dst[2] = 16;
	pu16dst[3] = 16;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;
	pu16dst[6] = 0;
	pu16dst[7] = 0;

	pu16num = pu16dst + 7;

	pu16end = pu16dst + 8;


	//
	// Set the initial source X position and width.
	//

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	uipxlw = uibmw;
	sipxlx = sibmx + uibmw;


	//
	// Scan up each column, from the right column to the left column.
	//

	while (uipxlw != 0)

		{

		//
		// Calculate the spr width at this point.
		//

		uisprw = 16;

		if (uipxlw < 16)
			{
			uisprw = uipxlw;
			}

		uipxlw = uipxlw - uisprw;

		uisprw = (uisprw + 15) & (~15);

		uiwchr = uisprw >> 3;

		sipxlx = sipxlx - uisprw;


		//
		// Set the initial source Y position and height.
		//

		uipxlh = uibmh;
		sipxly = sibmy + uibmh;


		//
		// Scan from bottom to top up this column.
		//

		while (uipxlh != 0)

			{

			//
			// Scan across looking for a non-zero pixel.
			//

			pu08src = pdbiti->pub__bmBitmap + (ulwsrc * (sipxly - 1)) + sipxlx;

			for (uii = uisprw; uii != 0; uii = uii - 1)
				{
				if (*pu08src != 0) break;
				pu08src = pu08src + 1;
				}


			//
			// If non-zero data was found, then convert a sprite's worth of
			// data, else move onto the next line.
			//

			if (uii != 0)

				//
				// Data found, convert sprite.
				//

				{

				//
				// Calculate the spr height at this point.
				//

				uisprh = 16;

				if (uipxlh < 16)
					{
					uisprh = uipxlh;
					}

				uipxlh = uipxlh - uisprh;

				uisprh = (uisprh + 15) & (~15);

				uihchr = uisprh >> 3;

				sipxly = sipxly - uisprh;


				//
				// Calculate the pxl data address.
				//

				pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sipxly) + sipxlx;


				//
				// Save the spr position, size and data.
				//

				pu16spr = pu16end;

				pu16end[0] = sipxlx - (sibmx - 16);
				pu16end[1] = sipxly - (sibmy - 16);
				pu16end[2] = uiwchr;
				pu16end[3] = uihchr;

				pu16end = pu16end + 4;

				if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, ORDER_LRTB,
					pu16end)) == NULL)
					{
					goto errorExit;
					}

				*pu16num = *pu16num + 1;


				//
				// Run the spr through the optimizer.
				//

				pu16end = OptimizeAGBSpr(pu16spr, pu16num);


				}


			else

				//
				// Empty line, move onto the next.
				//

				{

				//
				// Update the source position and height.
				//

				sipxly = sipxly - 1;
				uipxlh = uipxlh - 1;

				}


			//
			// End of while (uipxlh != 0)
			//

			}


		//
		// End of while (uipxlw != 0)
		//

		}


	//
	// Fill in the map palette (and set the SPR flag).
	//

	pu16dst[6] = ((pxib->uimapPalette & 0x00FFu) | 0x8000u);


	//
	// Select sorting keys.
	//

	pxib->uisort1 = *pu16num;
	pxib->uisort2 = pxib->n.dcinew.ui___chrCount;


	//
	// Return with success code.
	//

	return (pu16end);


	//
	// Error handlers (reached via the dreaded goto).
	//

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	OptimizeAGBSpr ()
//
//	Usage
//		global UW * OptimizeAGBSpr (UW * pu16spr, UW * pu16num)
//
//	Description
//		Optimize the spr map by turning a 2x2 sprite with 2 or less characters
//		into 2 1x1 sprites.
//
//	Return Value
//		If NULL then failed, else return pointer to next free data after new
//		map.
//
//	N.B.
//		The spr data has the following format ...
//			{
//			UW	section X offset from top left of chrmap
//			UW	section Y offset from top left of chrmap
//			UW	section width in characters
//			UW	section height in characters
//				{
//				UW chr number
//				}
//			}
// **************************************************************************


global	UW * OptimizeAGBSpr (UW * pu16spr, UW * pu16num)

	{

	//
	// Local variables.
	//

	UW *							pu16tmp;

	UW								u16chr0;
	UW								u16chr1;
	UW								u16chr2;
	UW								u16chr3;

	UI								uisprx;
	UI								uispry;

	UI								uii;
	UI								uij;

	//
	// Get spr size, position and address.
	//

	(*pu16num)--;

	uisprx  = pu16spr[0];
	uispry  = pu16spr[1];

	//
	// Count number of non-zero characters in the sprite.
	//

	pu16tmp = pu16spr + 4;

	uii = 0;

	for (uij = 4; uij != 0; uij -= 1)
		{
		if ((*pu16tmp++) != 0) uii += 1;
		}

	//
	// Optimize out ?
	//

	if (uii == 0)
		{
		return (pu16spr);
		}

	//
	// Leave as is ?
	//

	if (uii >= 3)
		{
		(*pu16num)++;
		return (pu16tmp);
		}

	//
	// Change to 1x1 sprites.
	//

	u16chr0 = pu16spr[4];
	u16chr1 = pu16spr[5];
	u16chr2 = pu16spr[6];
	u16chr3 = pu16spr[7];

	if (u16chr0 != 0)
		{
		(*pu16num)++;
		*pu16spr++ = uisprx + 0;
		*pu16spr++ = uispry + 0;
		*pu16spr++ = 1;
		*pu16spr++ = 1;
		*pu16spr++ = u16chr0;
		}

	if (u16chr1 != 0)
		{
		(*pu16num)++;
		*pu16spr++ = uisprx + 8;
		*pu16spr++ = uispry + 0;
		*pu16spr++ = 1;
		*pu16spr++ = 1;
		*pu16spr++ = u16chr1;
		}

	if (u16chr2 != 0)
		{
		(*pu16num)++;
		*pu16spr++ = uisprx + 0;
		*pu16spr++ = uispry + 8;
		*pu16spr++ = 1;
		*pu16spr++ = 1;
		*pu16spr++ = u16chr2;
		}

	if (u16chr3 != 0)
		{
		(*pu16num)++;
		*pu16spr++ = uisprx + 8;
		*pu16spr++ = uispry + 8;
		*pu16spr++ = 1;
		*pu16spr++ = 1;
		*pu16spr++ = u16chr3;
		}

	//
	// Return with pointer to next free space.
	//

	return (pu16spr);

	}





// **************************************************************************
// * PxlToAGB8x8x8 ()                                                       *
// **************************************************************************
// * Xvert 8bpp bitmap data into an AGB character                           *
// **************************************************************************
// * Inputs  UB *            Ptr to src buffer                              *
// *         UB *            Ptr to dst buffer                              *
// *         UL              Line width of source                           *
// *                                                                        *
// * Output  UI              Palette number of the character                *
// **************************************************************************

global	UI                  PxlToAGB8x8x8           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth)

	{
	// Local variables.

	UB *                pu08lin;
	UB *                pu08chr;
	UD *                pu32lin;
	UD *                pu32chr;
	UI                  uii;

	// Convert the 256 color data into a normal AGB character.

	pu08lin = pu08src;
	pu08chr = pu08dst;

	for (uii = 8; uii != 0; uii -= 1)
		{
		*pu08chr++	= pu08lin[0];
		*pu08chr++	= pu08lin[1];
		*pu08chr++	= pu08lin[2];
		*pu08chr++	= pu08lin[3];
		*pu08chr++	= pu08lin[4];
		*pu08chr++	= pu08lin[5];
		*pu08chr++	= pu08lin[6];
		*pu08chr++	= pu08lin[7];

		pu08lin += ulsrcwidth;
		}

	// Produce flipped versions if flipped characters are allowed.

	if ((flChrXFlipAllowed == YES) || (flChrYFlipAllowed == YES))
		{
		// Convert the 256 color data into an X-flipped AGB character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			*pu08chr++	= pu08lin[7];
			*pu08chr++	= pu08lin[6];
			*pu08chr++	= pu08lin[5];
			*pu08chr++	= pu08lin[4];
			*pu08chr++	= pu08lin[3];
			*pu08chr++	= pu08lin[2];
			*pu08chr++	= pu08lin[1];
			*pu08chr++	= pu08lin[0];

			pu08lin += ulsrcwidth;
			}

		// Convert the normal AGB character into a Y-flipped character.

		pu32chr = (UD *) pu08chr;
		pu32lin = (UD *) pu08dst;

		*pu32chr++ = pu32lin[14];
		*pu32chr++ = pu32lin[15];
		*pu32chr++ = pu32lin[12];
		*pu32chr++ = pu32lin[13];
		*pu32chr++ = pu32lin[10];
		*pu32chr++ = pu32lin[11];
		*pu32chr++ = pu32lin[8];
		*pu32chr++ = pu32lin[9];
		*pu32chr++ = pu32lin[6];
		*pu32chr++ = pu32lin[7];
		*pu32chr++ = pu32lin[4];
		*pu32chr++ = pu32lin[5];
		*pu32chr++ = pu32lin[2];
		*pu32chr++ = pu32lin[3];
		*pu32chr++ = pu32lin[0];
		*pu32chr++ = pu32lin[1];

		// Convert the X-flipped Genesis character into an X and Y-flipped character.

		pu32lin = (UD *) (pu08dst + 64);

		*pu32chr++ = pu32lin[14];
		*pu32chr++ = pu32lin[15];
		*pu32chr++ = pu32lin[12];
		*pu32chr++ = pu32lin[13];
		*pu32chr++ = pu32lin[10];
		*pu32chr++ = pu32lin[11];
		*pu32chr++ = pu32lin[8];
		*pu32chr++ = pu32lin[9];
		*pu32chr++ = pu32lin[6];
		*pu32chr++ = pu32lin[7];
		*pu32chr++ = pu32lin[4];
		*pu32chr++ = pu32lin[5];
		*pu32chr++ = pu32lin[2];
		*pu32chr++ = pu32lin[3];
		*pu32chr++ = pu32lin[0];
		*pu32chr++ = pu32lin[1];
		}

	// Return with the palette number.

	return (0);
	}

// **************************************************************************
// * PxlToAGB8x8x4 ()                                                       *
// **************************************************************************
// * Xvert 8bpp bitmap data into an AGB character                           *
// **************************************************************************
// * Inputs  UB *            Ptr to src buffer                              *
// *         UB *            Ptr to dst buffer                              *
// *         UL              Line width of source                           *
// *                                                                        *
// * Output  UI              Palette number of the character                *
// **************************************************************************

global	UI                  PxlToAGB8x8x4           (
								UB *                pu08src,
								UB *                pu08dst,
								UL                  ulsrcwidth)

	{
	// Local variables.

	UB *                pu08lin;
	UB *                pu08chr;
	UD *                pu32lin;
	UD *                pu32chr;
	UD                  u32palette;
	UI                  uii;

	// Convert the 256 color data into a normal Genesis character.

	u32palette = 0;

	pu08lin = pu08src;
	pu08chr = pu08dst;

	for (uii = 8; uii != 0; uii -= 1)
		{
		u32palette |= ((UD *) pu08lin)[0] | ((UD *) pu08lin)[1];

		*pu08chr++	= (pu08lin[0] << 4) | (pu08lin[1] & ((UB) 0x0F));
		*pu08chr++	= (pu08lin[2] << 4) | (pu08lin[3] & ((UB) 0x0F));
		*pu08chr++	= (pu08lin[4] << 4) | (pu08lin[5] & ((UB) 0x0F));
		*pu08chr++	= (pu08lin[6] << 4) | (pu08lin[7] & ((UB) 0x0F));

		pu08lin += ulsrcwidth;
		}

	// Produce flipped versions if flipped characters are allowed.

	if ((flChrXFlipAllowed == YES) || (flChrYFlipAllowed == YES))
		{
		// Convert the 256 color data into an X-flipped AGB character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			*pu08chr++	= (pu08lin[7] << 4) | (pu08lin[6] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[5] << 4) | (pu08lin[4] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[3] << 4) | (pu08lin[2] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[1] << 4) | (pu08lin[0] & ((UB) 0x0F));

			pu08lin += ulsrcwidth;
			}

		// Convert the normal AGB character into a Y-flipped character.

		pu32chr = (UD *) pu08chr;
		pu32lin = (UD *) pu08dst;

		*pu32chr++ = pu32lin[7];
		*pu32chr++ = pu32lin[6];
		*pu32chr++ = pu32lin[5];
		*pu32chr++ = pu32lin[4];
		*pu32chr++ = pu32lin[3];
		*pu32chr++ = pu32lin[2];
		*pu32chr++ = pu32lin[1];
		*pu32chr++ = pu32lin[0];

		// Convert the X-flipped AGB character into an X and Y-flipped character.

		pu32lin = (UD *) (pu08dst + 32);

		*pu32chr++ = pu32lin[7];
		*pu32chr++ = pu32lin[6];
		*pu32chr++ = pu32lin[5];
		*pu32chr++ = pu32lin[4];
		*pu32chr++ = pu32lin[3];
		*pu32chr++ = pu32lin[2];
		*pu32chr++ = pu32lin[1];
		*pu32chr++ = pu32lin[0];
		}

	// Get the palette number.

	u32palette =
		(u32palette>>04) | (u32palette>>12) | (u32palette>>20) | (u32palette>>28);

	u32palette = u32palette & 0x0F;

	// Return with the palette number.

	return ((UI) u32palette);
	}


#if 0

// **************************************************************************
//	ReformatMapsForAGB ()
//
//	Usage
//		static UW * ReformatMapsForAGB (UW * pu16src, UW * pu16end,
//			UW * pu16max, UD *  pu32idx, UI uimapcount)
//
//	Description
//		Reformat the map data for the Super NES.
//
//	Return Value
//		Ptr to the next free after the reorganized map data or NULL if an error
//		occurred.
//
//  N.B.
//		Reorder map data from ...
//
//	The old map data has the following format ...
//	  {
//	  SW 0 (was X offset from origin to top left of chrmap)
//	  SW 0 (was Y offset from origin to top left of chrmap)
//	  SW X offset from top left of chrmap to top left of data
//	  SW Y offset from top left of chrmap to top left of data
//	  UW data width in pixels
//	  UW data height in pixels
//	  UW map palette
//	  UW number of map sections
//	    {
//	    UW section X offset from top left of chrmap
//	    UW section Y offset from top left of chrmap
//	    UW section width in characters
//	    UW section height in characters
//	      {
//	      UW character data
//	      }
//	    }
//	  }
//
//	The new map data has the following format ...
//	  {
//	  SB X offset from origin to top left of chrmap          (1)
//	  SB Y offset from origin to top left of chrmap          (1)
//	  SB X offset from top left of chrmap to top left of box (2)
//	  SB Y offset from top left of chrmap to top left of box (2)
//	  UB box width in pixels                                 (2)
//	  UB box height in pixels                                (2)
//	  UB map palette
//	  UB number of map sections
//	    {
//	    UB section X offset from top left of chrmap
//	    UB section Y offset from top left of chrmap
//	    UB section width in characters - 1                   (3)
//	    UB section height in characters - 1                  (3)
//	    UB 0 if 1x1, 1 if 2x2                                (4)
//	    UB section width*height                              (4)
//	      {
//	      UW character data                                  (5)
//	      }
//	    }
//	  }
//
// (1) Only if flOutputMapPosition == YES
// (2) Only if flOutputMapBoxSize == YES
// (3) Only if map is a chrmap
// (4) Only if map is a sprmap
// (5) If chrmap then data is stored Top->Bottom[Left->Right]
//     If sprmap then data is stored Left->Right[Top->Bottom]
// **************************************************************************


global	UW *                ReformatMapsForAGB      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount)

	{

	// Local variables.

	UL                  uloffset;

	UW *               pu16tmp;
	UW *               pu16dst;

	UI                  uii;
	UI                  uij;

	UI                  uiw;
	UI                  uih;

	UI                  uimapflags;

	UW                 u16tmp;

	SW                 s16xorigin;
	SW                 s16yorigin;
	UW                 u16xoffset;
	UW                 u16yoffset;

	// Now reorder each map in turn.

	pu16dst = (pu16tmp = pu16src);

	uloffset = ((UL) ((UB *) pu16dst)) -
		(slOutputMapStart + (uimapcount * sizeof(UD )));

	for (uii = uimapcount; uii != 0; uii -= 1)

		{
		// Print out map number.

		XSPRINTFMAP("MapN=%04X\n", ((UI) (uimapcount - uii)));

		// Save index address.

		*pu32idx++ = (UD ) (((UL) ((UB *) pu16dst)) - uloffset);

		// Get X and Y origin.

		s16xorigin = ((SW *) pu16tmp)[0];
		s16yorigin = ((SW *) pu16tmp)[1];

		// Only save origin if flOutputMapPosition is YES.

		if (flOutputMapPosition == YES)
			{
			if (flOutputWordOffsets == NO)
				{
				// Set up byte X and Y origin offsets.

				XSPRINTFMAP("MapX=%02X\n", (((UI) s16xorigin) & 0xFFu));
				XSPRINTFMAP("MapY=%02X\n", (((UI) s16yorigin) & 0xFFu));

				if ((s16xorigin > 127) || (s16xorigin < -128)) {
					sprintf(ErrorMessage,
						"X position offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) s16xorigin;

				if ((s16yorigin > 127) || (s16yorigin < -128)) {
					sprintf(ErrorMessage,
						"Y position offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[1] = (UB) s16yorigin;

				pu16dst += 1;
				}
			else
				{
				// Set up word X and Y origin offsets.

				XSPRINTFMAP("MapX=%04X\n", (((UI) s16xorigin) & 0xFFFFu));
				XSPRINTFMAP("MapY=%04X\n", (((UI) s16yorigin) & 0xFFFFu));

				if (uiOutputOrder == ORDERSWAP) {
					pu16dst[0] = SwapD16(s16xorigin);
					pu16dst[1] = SwapD16(s16yorigin);
					} else {
					pu16dst[0] = s16xorigin;
					pu16dst[1] = s16yorigin;
					}

				pu16dst += 2;
				}
			}	// End of "if (flOutputMapPosition == YES)"

		// Only save box size if flOutputMapBoxSize is YES.

		if (flOutputMapBoxSize == YES)
			{
			// Set up collision box X and Y offsets.

			u16tmp = pu16tmp[2];
			XSPRINTFMAP("BoxX=%02X\n", ((UI) u16tmp));
			if ((((SW) u16tmp) > 127) || (((SW) u16tmp) < -128)) {
				sprintf(ErrorMessage,
					"X collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[0] = (UB) u16tmp;

			u16tmp = pu16tmp[3];
			XSPRINTFMAP("BoxY=%02X\n", ((UI) u16tmp));
			if ((((SW) u16tmp) > 127) || (((SW) u16tmp) < -128))
				{
				sprintf(ErrorMessage,
					"Y collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[1] = (UB) u16tmp;

			// Set up collision box width and height.

			u16tmp = pu16tmp[4];
			XSPRINTFMAP("BoxW=%02X\n", ((UI) u16tmp));
			if (u16tmp > ((UW) 0x00FFu)) {
				sprintf(ErrorMessage,
					"X collision width overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[2] = (UB) u16tmp;

			u16tmp = pu16tmp[5];
			XSPRINTFMAP("BoxH=%02X\n", ((UI) u16tmp));
			if (u16tmp > ((UW) 0x00FFu)) {
				sprintf(ErrorMessage,
					"Y collision height overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[3] = (UB) u16tmp;

			pu16dst += 2;
			}	// End of "if (flOutputMapBoxSize == YES)"

		// Get the map's flag bits.

		uimapflags = pu16tmp[6] & 0xFF00u;

		// Set up map palette.

		u16tmp = pu16tmp[6] & ((UW) 0x00FFu);

		XSPRINTFMAP("MapP=%02X\n", ((UI) u16tmp));

		((UB *) pu16dst)[0] = (UB) u16tmp;

		// Set up number of sections.

		u16tmp = pu16tmp[7];

		XSPRINTFMAP("MapS=%02X\n", ((UI) u16tmp));
		if (u16tmp > ((UW) 0x00FFu)) {
			sprintf(ErrorMessage,
				"Too many sections in map 0x%04X.\n"
				"(XS, ReformatMapsForAGB)\n",
				(uimapcount - uii));
			goto errorOverflow;
			}
		((UB *) pu16dst)[1] = (UB) u16tmp;

		pu16dst += 1;

		// Now reorder each section.

		pu16tmp += 8;

		uij = u16tmp;

		while (uij-- != 0)
			{
			// Get section offsets.

			u16xoffset = pu16tmp[0];
			u16yoffset = pu16tmp[1];

			if (flOutputMapPosition == NO) {
				u16xoffset += s16xorigin;
				u16yoffset += s16yorigin;
				}

			// Set up byte or word X and Y section offsets.

			if (flOutputWordOffsets == NO)
				{
				// Set up byte X and Y section offsets.

				XSPRINTFMAP(" SprX=%02X\n", ((UI) u16xoffset));
				XSPRINTFMAP(" SprY=%02X\n", ((UI) u16yoffset));

				if (u16xoffset > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"X section offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) u16xoffset;

				if (u16yoffset > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"Y section offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[1] = (UB) u16yoffset;

				pu16dst += 1;
				}
			else
				{
				// Set up word X and Y section offsets.

				XSPRINTFMAP(" SprX=%04X\n", ((UI) u16xoffset));
				XSPRINTFMAP(" SprY=%04X\n", ((UI) u16yoffset));

				if (uiOutputOrder == ORDERSWAP) {
					pu16dst[0] = SwapD16(u16xoffset);
					pu16dst[1] = SwapD16(u16yoffset);
					} else {
					pu16dst[0] = u16xoffset;
					pu16dst[1] = u16yoffset;
					}
				pu16dst += 2;
				}

			// Get section width and height.

			uiw = pu16tmp[2];
			uih = pu16tmp[3];

			XSPRINTFMAP(" SprW=%02X\n", uiw);
			XSPRINTFMAP(" SprH=%02X\n", uih);

			if (uiw > 0x00FFu) {
				sprintf(ErrorMessage,
					"X section width overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			if (uih > 0x00FFu) {
				sprintf(ErrorMessage,
					"X collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}

			// Move onto the section data.

			pu16tmp += 4;

			// Print out the spr map ?

			#if XSPRINTMAP
				{
				UW *               pu16row;
				UW *               pu16col;
				UI                  uik;
				UI                  uiwloop;
				UI                  uihloop;
				pu16row = pu16tmp;
				if ((uimapflags & 0x8000u) == 0) {
					for (uihloop = uih; uihloop != 0; uihloop -= 1) {
						printf(" ");
						for (uiwloop = uiw; uiwloop != 0; uiwloop -= 1) {
							printf(" %04X", (UI) *pu16row++);
							}
						printf("\n");
						}
					} else {
					for (uiwloop = uiw; uiwloop != 0; uiwloop -= 1) {
						printf(" ");
						for (uihloop = uih; uihloop != 0; uihloop -= 1) {
							printf(" %04X", (UI) *pu16row++);
							}
						printf("\n");
						}
					}
				}
			#endif

			// Output the map data.

			if ((uimapflags & 0x8000u) == 0) {
				// Save CHRMAP width and height.
				((UB *) pu16dst)[0] = (uiw - 1);
				((UB *) pu16dst)[1] = (uih - 1);
				} else {
				// Save SPRMAP width and height.
				((UB *) pu16dst)[0] = uiw - 1;
				((UB *) pu16dst)[1] = uiw * uih;
				}

			pu16dst += 1;

			uiw = uiw * uih;

			if (uiOutputOrder == ORDERSWAP) {
				while (uiw-- != 0) {
					u16tmp = *pu16tmp++;
					*pu16dst++ = SwapD16(u16tmp);
					}
				} else {
				while (uiw-- != 0) {
					*pu16dst++ = *pu16tmp++;
					}
				}

			// End of this map section.

			}

		// If the pu16tmp is on an odd UW boundary, then increment it onto the
		// next UD boundary.

		if (((pu16tmp - pu16src) & 1) != 0) {
			pu16tmp += 1;
			}

		#if XSPRINTMAP
			printf("\n");
			fflush(stdout);
		#endif

		// End of this map.
		}

	// Return with ptr to next free.

	return (pu16dst);

	// Error handlers (reached via the dreaded goto).

	errorOverflow:

		ErrorCode = ERROR_ILLEGAL;

		return (NULL);
	}

#endif


// **************************************************************************
// * ReformatMapsForAGB ()                                                  *
// **************************************************************************
// * Reformat the map data for the MAP file                                 *
// **************************************************************************
// * Inputs  DATAMAPSET_T *  Ptr to the map data                            *
// *         UB **           Ptr to variable that gets ptr to output data   *
// *         UI *            Ptr to variable that gets len of output data   *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B. Reorder map data from ...                                         *
// *                                                                        *
// * The old map data has the following format ...                          *
// *  {                                                                     *
// *  SW 0 (was X offset from origin to top left of chrmap)                 *
// *  SW 0 (was Y offset from origin to top left of chrmap)                 *
// *  SW X offset from top left of chrmap to top left of data               *
// *  SW Y offset from top left of chrmap to top left of data               *
// *  UW data width in pixels                                               *
// *  UW data height in pixels                                              *
// *  UW map palette                                                        *
// *  UW number of map sections                                             *
// *    {                                                                   *
// *    UW section X offset from top left of chrmap                         *
// *    UW section Y offset from top left of chrmap                         *
// *    UW section width in characters                                      *
// *    UW section height in characters                                     *
// *      {                                                                 *
// *      UW character data                                                 *
// *      }                                                                 *
// *    }                                                                   *
// *  }                                                                     *
// *                                                                        *
// * The new map data has the following format ...                          *
// *  {                                                                     *
// *  SB X offset from origin to top left of chrmap          (1)            *
// *  SB Y offset from origin to top left of chrmap          (1)            *
// *  SB X offset from top left of chrmap to top left of box (2)            *
// *  SB Y offset from top left of chrmap to top left of box (2)            *
// *  UB box width in pixels                                 (2)            *
// *  UB box height in pixels                                (2)            *
// *  UB map palette                                                        *
// *  UB number of map sections                                             *
// *    {                                                                   *
// *    UB section X offset from top left of chrmap                         *
// *    UB section Y offset from top left of chrmap                         *
// *    UB section width in characters - 1                   (3)            *
// *    UB section height in characters - 1                  (3)            *
// *      {                                                                 *
// *      UW character data                                                 *
// *      }                                                                 *
// *    }                                                                   *
// *  }                                                                     *
// *                                                                        *
// * (1) Only if flOutputMapPosition == YES                                 *
// * (2) Only if flOutputMapBoxSize == YES                                  *
// * (3) Only if map is a chrmap                                            *
// **************************************************************************

typedef	struct FILEMAPIDX_S
	{
	UD                  ud___fsiO;
//	SB                  sb___fsiX;
//	SB                  sb___fsiY;
	} FILEMAPIDX_T;

global	ERRORCODE           ReformatMapsForAGB      (
								DATAMAPSET_T *      pcl__Map,
								UB **               ppub_Buf,
								UI *                pui__Buf)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	ANYPTR_T            pbf__Buf;

	DATAMAPIDX_T *      pcl__Idx;

	FILEMAPIDX_T *      pcl__FH;
	FILEMAPIDX_T *      pcl__FI;

	UI                  ui___i;
	UI                  ui___j;

	UI                  ui___w;
	UI                  ui___h;

	UW *                pu16tmp;
	UW *                pu16dst;

	UI                  uimapflags;

	UW                  u16tmp;

	SW                  s16xorigin;
	SW                  s16yorigin;
	UW                  u16xoffset;
	UW                  u16yoffset;

	// Initialize output buffer.

	ui___Buf  =
		sizeof(FILEMAPIDX_T) * pcl__Map->ui___mapsCount +
		(((UB *)pcl__Map->puw__mapsBufCur)-((UB *)pcl__Map->puw__mapsBuf1st));

	pub__Buf  = (UB *) malloc(ui___Buf);

	if (pub__Buf == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		sprintf(ErrorMessage,
			"(ReformatMapsForAgb) Not enough memory to allocate buffer.\n");
		return (ErrorCode);
		}

	pbf__Buf.ubp = pub__Buf;

	// Construct the map data table.

	pcl__FH      =
	pcl__FI      = (FILEMAPIDX_T *) (pbf__Buf.ubp);

	if (flOutputMapIndex == YES)
		{
		pbf__Buf.ubp = (UB *) (pcl__FI + pcl__Map->ui___mapsCount);
		}

	pcl__Idx = pcl__Map->acl__mapsBufIndx;

	for (ui___i = 0; ui___i < pcl__Map->ui___mapsCount; ui___i += 1)
		{
		// Blank sprite ???

		if (pcl__Idx->puw__mapiBufPtr == NULL)
			{
			XSPRINTFMAP("MapN=0000 (Blank)\n", (0));

			if (flOutputMapIndex == YES)
				{
				pcl__FI->ud___fsiO = pcl__FH->ud___fsiO;
//				pcl__FI->ud___fsiO = 0;
//				pcl__FI->sb___fsiX = 0;
//				pcl__FI->sb___fsiY = 0;

				pcl__FI  += 1;
				}

			pcl__Idx += 1;

			continue;
			}

		// Get X and Y origin, width and height.

		XSPRINTFMAP("MapN=%04X\n", (pcl__Idx.ui___mapiNumber));
		XSPRINTFMAP("MapX=%02X\n", (pcl__Idx.si___mapiXOffset & 0xFFu));
		XSPRINTFMAP("MapY=%02X\n", (pcl__Idx.si___mapiYOffset & 0xFFu));

//		pcl__FI->sb___fsiX = pcl__Idx->si___spriXOffset;
//		pcl__FI->sb___fsiY = pcl__Idx->si___spriYOffset;

		if ((pcl__Idx->si___mapiXOffset >  127) ||
			(pcl__Idx->si___mapiXOffset < -128))
			{
			sprintf(ErrorMessage,
				"(ReformatMapsForAgb) X overflow in map 0x%04X during reformat.\n",
				(pcl__Idx->si___mapiNumber));
			}
		if ((pcl__Idx->si___mapiYOffset >  127) ||
			(pcl__Idx->si___mapiYOffset < -128))
			{
			sprintf(ErrorMessage,
				"(ReformatMapsForAgb) Y overflow in map 0x%04X during reformat.\n",
				(pcl__Idx->si___mapiNumber));
			}

		// Get the offset to the packed sprite data.

		if ((pcl__Idx->ul___mapiBufLen == 0) && (flOutputMapIndex == YES))
			{
			// Repeated sprite, get the offset from the original index.

			pcl__FI->ud___fsiO = pcl__FH[pcl__Idx->si___mapiNumber].ud___fsiO;
			}
		else
			{
			// New map, calculate the offset.

			if (flOutputMapIndex == YES)
				{
				pcl__FI->ud___fsiO = (pbf__Buf.ubp - ((UB *) pcl__FH)) + slOutputMapStart;

				if (uiOutputOrder == ORDERSWAP)
					{
					pcl__FI->ud___fsiO = SwapD32(pcl__FI->ud___fsiO);
					}
				}

			// Now process the map itself.

			pu16tmp = pcl__Idx->puw__mapiBufPtr;

			pu16dst = pbf__Buf.uwp;

			// Get X and Y origin.

			s16xorigin = ((SW *) pu16tmp)[0];
			s16yorigin = ((SW *) pu16tmp)[1];

			// Only save origin if flOutputMapPosition is YES.

			if (flOutputMapPosition == YES)
				{
				if (flOutputWordOffsets == NO)
					{
					// Set up byte X and Y origin offsets.

					XSPRINTFMAP("MapX=%02X\n", (((UI) s16xorigin) & 0xFFu));
					XSPRINTFMAP("MapY=%02X\n", (((UI) s16yorigin) & 0xFFu));

					if ((s16xorigin > 127) || (s16xorigin < -128)) {
						sprintf(ErrorMessage,
							"X position offset overflow in map 0x%04X.\n"
							"(XS, ReformatMapsForAGB)\n",
							(ui___i));
						goto errorOverflow;
						}
					((UB *) pu16dst)[0] = (UB) s16xorigin;

					if ((s16yorigin > 127) || (s16yorigin < -128)) {
						sprintf(ErrorMessage,
							"Y position offset overflow in map 0x%04X.\n"
							"(XS, ReformatMapsForAGB)\n",
							(ui___i));
						goto errorOverflow;
						}
					((UB *) pu16dst)[1] = (UB) s16yorigin;

					pu16dst += 1;
					}
				else
					{
					// Set up word X and Y origin offsets.

					XSPRINTFMAP("MapX=%04X\n", (((UI) s16xorigin) & 0xFFFFu));
					XSPRINTFMAP("MapY=%04X\n", (((UI) s16yorigin) & 0xFFFFu));

					if (uiOutputOrder == ORDERSWAP) {
						pu16dst[0] = SwapD16(s16xorigin);
						pu16dst[1] = SwapD16(s16yorigin);
						} else {
						pu16dst[0] = s16xorigin;
						pu16dst[1] = s16yorigin;
						}

					pu16dst += 2;
					}
				}	// End of "if (flOutputMapPosition == YES)"

			// Only save box size if flOutputMapBoxSize is YES.

			if (flOutputMapBoxSize == YES)
				{
				// Set up collision box X and Y offsets.

				u16tmp = pu16tmp[2];
				XSPRINTFMAP("BoxX=%02X\n", ((UI) u16tmp));
				if ((((SW) u16tmp) > 127) || (((SW) u16tmp) < -128)) {
					sprintf(ErrorMessage,
						"X collision offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) u16tmp;

				u16tmp = pu16tmp[3];
				XSPRINTFMAP("BoxY=%02X\n", ((UI) u16tmp));
				if ((((SW) u16tmp) > 127) || (((SW) u16tmp) < -128))
					{
					sprintf(ErrorMessage,
						"Y collision offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}
				((UB *) pu16dst)[1] = (UB) u16tmp;

				// Set up collision box width and height.

				u16tmp = pu16tmp[4];
				XSPRINTFMAP("BoxW=%02X\n", ((UI) u16tmp));
				if (u16tmp > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"X collision width overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}
				((UB *) pu16dst)[2] = (UB) u16tmp;

				u16tmp = pu16tmp[5];
				XSPRINTFMAP("BoxH=%02X\n", ((UI) u16tmp));
				if (u16tmp > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"Y collision height overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}
				((UB *) pu16dst)[3] = (UB) u16tmp;

				pu16dst += 2;
				}	// End of "if (flOutputMapBoxSize == YES)"

			// Get the map's flag bits.

			uimapflags = pu16tmp[6] & 0xFF00u;

			// Set up map palette.

			u16tmp = pu16tmp[6] & ((UW) 0x00FFu);

			XSPRINTFMAP("MapP=%02X\n", ((UI) u16tmp));

			((UB *) pu16dst)[0] = (UB) u16tmp;

			// Set up number of sections (including sprite section height flag).

			u16tmp = pu16tmp[7];

			if ((uimapflags & 0x8000u) == 0)
				{
				((UB *) pu16dst)[1] = (UB) u16tmp;
				}
			else
				{
				u16tmp = u16tmp << 1;

				if (pu16tmp[11] != 1)
					{
					u16tmp = u16tmp | 1;
					}

				((UB *) pu16dst)[1] = (UB) u16tmp;

				u16tmp = u16tmp >> 1;
				}

			XSPRINTFMAP("MapS=%02X\n", ((UI) u16tmp));
			if (u16tmp > ((UW) 0x00FFu)) {
				sprintf(ErrorMessage,
					"Too many sections in map 0x%04X.\n"
					"(XS, ReformatMapsForAGB)\n",
					(ui___i));
				goto errorOverflow;
				}

			pu16dst += 1;

			// Now reorder each section.

			pu16tmp += 8;

			ui___j = u16tmp;

			while (ui___j-- != 0)
				{
				// Get section offsets.

				u16xoffset = pu16tmp[0];
				u16yoffset = pu16tmp[1];

				if (flOutputMapPosition == NO) {
					u16xoffset += s16xorigin;
					u16yoffset += s16yorigin;
					}

				// Set up byte or word X and Y section offsets.

				if (flOutputWordOffsets == NO)
					{
					// Set up byte X and Y section offsets.

					XSPRINTFMAP(" SprX=%02X\n", ((UI) u16xoffset));
					XSPRINTFMAP(" SprY=%02X\n", ((UI) u16yoffset));

					if (u16xoffset > ((UW) 0x00FFu)) {
						sprintf(ErrorMessage,
							"X section offset overflow in map 0x%04X.\n"
							"(XS, ReformatMapsForAGB)\n",
							(ui___i));
						goto errorOverflow;
						}
					((UB *) pu16dst)[0] = (UB) u16xoffset;

					if (u16yoffset > ((UW) 0x00FFu)) {
						sprintf(ErrorMessage,
							"Y section offset overflow in map 0x%04X.\n"
							"(XS, ReformatMapsForAGB)\n",
							(ui___i));
						goto errorOverflow;
						}
					((UB *) pu16dst)[1] = (UB) u16yoffset;

					pu16dst += 1;
					}
				else
					{
					// Set up word X and Y section offsets.

					XSPRINTFMAP(" SprX=%04X\n", ((UI) u16xoffset));
					XSPRINTFMAP(" SprY=%04X\n", ((UI) u16yoffset));

					if (uiOutputOrder == ORDERSWAP) {
						pu16dst[0] = SwapD16(u16xoffset);
						pu16dst[1] = SwapD16(u16yoffset);
						} else {
						pu16dst[0] = u16xoffset;
						pu16dst[1] = u16yoffset;
						}
					pu16dst += 2;
					}

				// Get section width and height.

				ui___w = pu16tmp[2];
				ui___h = pu16tmp[3];

				XSPRINTFMAP(" SprW=%02X\n", ui___w);
				XSPRINTFMAP(" SprH=%02X\n", ui___h);

				if (ui___w > 0x00FFu) {
					sprintf(ErrorMessage,
						"X section width overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}
				if (ui___h > 0x00FFu) {
					sprintf(ErrorMessage,
						"X collision offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForAGB)\n",
						(ui___i));
					goto errorOverflow;
					}

				// Move onto the section data.

				pu16tmp += 4;

				// Print out the spr map ?

				#if XSPRINTMAP
					{
					UW *               pu16row;
					UW *               pu16col;
					UI                  uik;
					UI                  uiwloop;
					UI                  uihloop;
					pu16row = pu16tmp;
					if ((uimapflags & 0x8000u) == 0) {
						for (uihloop = ui___h; uihloop != 0; uihloop -= 1) {
							printf(" ");
							for (uiwloop = uiw; uiwloop != 0; uiwloop -= 1) {
								printf(" %04X", (UI) *pu16row++);
								}
							printf("\n");
							}
						} else {
						for (uiwloop = ui___w; uiwloop != 0; uiwloop -= 1) {
							printf(" ");
							for (uihloop = uih; uihloop != 0; uihloop -= 1) {
								printf(" %04X", (UI) *pu16row++);
								}
							printf("\n");
							}
						}
					}
				#endif

				// Output the map data.

				if ((uimapflags & 0x8000u) == 0) {
					// Save CHRMAP width and height.
					((UB *) pu16dst)[0] = (ui___w - 1);
					((UB *) pu16dst)[1] = (ui___h - 1);
					pu16dst += 1;
					} else {
					// Save SPRMAP width and height.
//					((UB *) pu16dst)[0] = (uiw - 1);
//					((UB *) pu16dst)[1] = (uih - 1);
//					pu16dst += 1;
					}

				ui___w = ui___w * ui___h;

				if (flOutputByteMap == NO)
					{
					if (uiOutputOrder == ORDERSWAP) {
						while (ui___w-- != 0) {
							u16tmp = *pu16tmp++;
							*pu16dst++ = SwapD16(u16tmp);
							}
						} else {
						while (ui___w-- != 0) {
							*pu16dst++ = *pu16tmp++;
							}
						}
					}
				else
					{
					UB * pu08dst = (UB *) pu16dst;

					while (ui___w-- != 0) {
						*pu08dst++ = (UB) (*pu16tmp++);
						}

//					if (((pu08dst - ((UB *) pu16dst)) & 1) != 0) {
//						*pu08dst++ = 0;
//						}

					pu16dst = (UW *) pu08dst;
					}

				// End of this map section.

				}

			// If the pu16dst is on an odd UB boundary, then increment it onto the
			// next UW boundary.

			{
			UB * pu08dst = (UB *) pu16dst;

			if ((((UL) pu08dst) & 1) != 0) {
				*pu08dst++ = 0;
				}

			pu16dst = (UW *) pu08dst;
			}

//			if ((((UL) pu16dst) & 2) != 0) {
//				*pu16dst++ = 0;
//				}

			#if XSPRINTMAP
				printf("\n");
				fflush(stdout);
			#endif

			// End of this map.

			pbf__Buf.uwp = pu16dst;
			}

		// Now do the next map.

		if (flOutputMapIndex == YES)
			{
			pcl__FI  += 1;
			}

		pcl__Idx += 1;
		}

	// All done.

	*ppub_Buf = pub__Buf;
	*pui__Buf = (pbf__Buf.ubp - pub__Buf);

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorOverflow:

		return (ErrorCode = ERROR_ILLEGAL);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTAGB.C
// **************************************************************************
// **************************************************************************
// **************************************************************************