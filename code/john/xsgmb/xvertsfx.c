// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTSFX.C                                                    MODULE **
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
// ** XVERTSFX .H .C                                                       **
// **                                                                      **
// ** Last modified : 31 Oct 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stddef.h>
#include	<stdio.h>

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
//	BitmapToSFXSprALL ()
//
//	Usage
//		global UW * BitmapToSFXSprALL (XVERTINFOBLOCK * pxib,
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


global	UW * BitmapToSFXSprALL (XVERTINFOBLOCK * pxib,
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
			"(XVERT, BitmapToSFXSprLRTB)\n");

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

			pu16end = OptimizeSFXSpr(pu16spr, pu16num);


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
//	BitmapToSFXSprLRTB ()
//
//	Usage
//		global UW * BitmapToSFXSprLRTB (XVERTINFOBLOCK * pxib,
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


global	UW * BitmapToSFXSprLRTB (XVERTINFOBLOCK * pxib,
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
			"(XVERT, BitmapToSFXSprLRTB)\n");

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

				pu16end = OptimizeSFXSpr(pu16spr, pu16num);


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
//	BitmapToSFXSprTBLR ()
//
//	Usage
//		global UW * BitmapToSFXSprTBLR (XVERTINFOBLOCK * pxib,
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


global	UW * BitmapToSFXSprTBLR (XVERTINFOBLOCK * pxib,
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
			"(XVERT, BitmapToSFXSprTBLR)\n");

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

				pu16end = OptimizeSFXSpr(pu16spr, pu16num);


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
//	BitmapToSFXSprRLBT ()
//
//	Usage
//		global UW * BitmapToSFXSprRLBT (XVERTINFOBLOCK * pxib,
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


global	UW * BitmapToSFXSprRLBT (XVERTINFOBLOCK * pxib,
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
			"(XVERT, BitmapToSFXSprRLBT)\n");

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

				pu16end = OptimizeSFXSpr(pu16spr, pu16num);


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
//	BitmapToSFXSprBTRL ()
//
//	Usage
//		global UW * BitmapToSFXSprBTRL (XVERTINFOBLOCK * pxib,
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


global	UW * BitmapToSFXSprBTRL (XVERTINFOBLOCK * pxib,
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
			"(XVERT, BitmapToSFXSprBTRL)\n");

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

				pu16end = OptimizeSFXSpr(pu16spr, pu16num);


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
//	OptimizeSFXSpr ()
//
//	Usage
//		global UW * OptimizeSFXSpr (UW * pu16spr, UW * pu16num)
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


global	UW * OptimizeSFXSpr (UW * pu16spr, UW * pu16num)

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
//	PxlToSFX8x8x8 ()
//
//	Usage
//		global UI PxlToSFX8x8x8 (UB * pu08src, UB * pu08dst,
//			UL ulsrcwidth)
//
//	Description
//		Convert the 256 color bitmap data at psrc (with line width of srcwidth
//		bytes) into a SuperNES character at pdst.  Return palette number.
//
//	Return Value
//		Palette number.
// **************************************************************************


global	UI PxlToSFX8x8x8 (UB * pu08src, UB * pu08dst, UL ulsrcwidth)

	{

	// Local variables.

	UB *							pu08lin;
	UB *							pu08chr;

	UW *							pu16lin;
	UW *							pu16chr;

	UI								uii;
	SI								sij;

	UB								u08plane0;
	UB								u08plane1;
	UB								u08plane2;
	UB								u08plane3;
	UB								u08plane4;
	UB								u08plane5;
	UB								u08plane6;
	UB								u08plane7;
	UB								u08pixel;

	// Convert the 256 color data into a normal Super NES character.

	pu08chr = pu08dst;

	pu08lin = pu08src;

	for (uii = 8; uii != 0; uii -= 1)
		{
		u08plane0 = 0;
		u08plane1 = 0;
		u08plane2 = 0;
		u08plane3 = 0;
		u08plane4 = 0;
		u08plane5 = 0;
		u08plane6 = 0;
		u08plane7 = 0;

		for (sij = 0; sij != 8; sij += 1)
			{
			u08pixel  = pu08lin[sij];
			u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
			u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
			u08plane2 = (u08plane2 << 1) | (((UB) 1) & (u08pixel >> 2));
			u08plane3 = (u08plane3 << 1) | (((UB) 1) & (u08pixel >> 3));
			u08plane4 = (u08plane4 << 1) | (((UB) 1) & (u08pixel >> 4));
			u08plane5 = (u08plane5 << 1) | (((UB) 1) & (u08pixel >> 5));
			u08plane6 = (u08plane6 << 1) | (((UB) 1) & (u08pixel >> 6));
			u08plane7 = (u08plane7 << 1) | (((UB) 1) & (u08pixel >> 7));
			}

		pu08chr[0]  = u08plane0;
		pu08chr[1]  = u08plane1;
		pu08chr[16] = u08plane2;
		pu08chr[17] = u08plane3;
		pu08chr[32] = u08plane4;
		pu08chr[33] = u08plane5;
		pu08chr[48] = u08plane6;
		pu08chr[49] = u08plane7;

		pu08chr += 2;
		pu08lin += ulsrcwidth;
		}

	pu08chr += (64-16);

	// Produce flipped versions if flipped characters are allowed.

	if ((flChrXFlipAllowed == YES) || (flChrYFlipAllowed == YES))

		{

		// Convert the 256 color data into an X-flipped Super NES character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			u08plane0 = 0;
			u08plane1 = 0;
			u08plane2 = 0;
			u08plane3 = 0;
			u08plane4 = 0;
			u08plane5 = 0;
			u08plane6 = 0;
			u08plane7 = 0;

			for (sij = 7; sij >= 0; sij -= 1)
				{
				u08pixel  = pu08lin[sij];
				u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
				u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
				u08plane2 = (u08plane2 << 1) | (((UB) 1) & (u08pixel >> 2));
				u08plane3 = (u08plane3 << 1) | (((UB) 1) & (u08pixel >> 3));
				u08plane4 = (u08plane4 << 1) | (((UB) 1) & (u08pixel >> 4));
				u08plane5 = (u08plane5 << 1) | (((UB) 1) & (u08pixel >> 5));
				u08plane6 = (u08plane6 << 1) | (((UB) 1) & (u08pixel >> 6));
				u08plane7 = (u08plane7 << 1) | (((UB) 1) & (u08pixel >> 7));
				}

			pu08chr[0]  = u08plane0;
			pu08chr[1]  = u08plane1;
			pu08chr[16] = u08plane2;
			pu08chr[17] = u08plane3;
			pu08chr[32] = u08plane4;
			pu08chr[33] = u08plane5;
			pu08chr[48] = u08plane6;
			pu08chr[49] = u08plane7;

			pu08chr += 2;
			pu08lin += ulsrcwidth;
			}

		pu08chr += (64-16);

		// Convert the normal Super NES character into a Y-flipped character.

		pu16chr = (UW *) pu08chr;
		pu16lin = (UW *) pu08dst;

		*pu16chr++ = pu16lin[ 7];
		*pu16chr++ = pu16lin[ 6];
		*pu16chr++ = pu16lin[ 5];
		*pu16chr++ = pu16lin[ 4];
		*pu16chr++ = pu16lin[ 3];
		*pu16chr++ = pu16lin[ 2];
		*pu16chr++ = pu16lin[ 1];
		*pu16chr++ = pu16lin[ 0];

		*pu16chr++ = pu16lin[15];
		*pu16chr++ = pu16lin[14];
		*pu16chr++ = pu16lin[13];
		*pu16chr++ = pu16lin[12];
		*pu16chr++ = pu16lin[11];
		*pu16chr++ = pu16lin[10];
		*pu16chr++ = pu16lin[ 9];
		*pu16chr++ = pu16lin[ 8];

		*pu16chr++ = pu16lin[23];
		*pu16chr++ = pu16lin[22];
		*pu16chr++ = pu16lin[21];
		*pu16chr++ = pu16lin[20];
		*pu16chr++ = pu16lin[19];
		*pu16chr++ = pu16lin[18];
		*pu16chr++ = pu16lin[17];
		*pu16chr++ = pu16lin[16];

		*pu16chr++ = pu16lin[31];
		*pu16chr++ = pu16lin[30];
		*pu16chr++ = pu16lin[29];
		*pu16chr++ = pu16lin[28];
		*pu16chr++ = pu16lin[27];
		*pu16chr++ = pu16lin[26];
		*pu16chr++ = pu16lin[25];
		*pu16chr++ = pu16lin[24];

		// Convert the X-flipped Super NES character into an X and Y-flipped character.

		pu16lin = (UW *) (pu08dst + 64);

		*pu16chr++ = pu16lin[ 7];
		*pu16chr++ = pu16lin[ 6];
		*pu16chr++ = pu16lin[ 5];
		*pu16chr++ = pu16lin[ 4];
		*pu16chr++ = pu16lin[ 3];
		*pu16chr++ = pu16lin[ 2];
		*pu16chr++ = pu16lin[ 1];
		*pu16chr++ = pu16lin[ 0];

		*pu16chr++ = pu16lin[15];
		*pu16chr++ = pu16lin[14];
		*pu16chr++ = pu16lin[13];
		*pu16chr++ = pu16lin[12];
		*pu16chr++ = pu16lin[11];
		*pu16chr++ = pu16lin[10];
		*pu16chr++ = pu16lin[ 9];
		*pu16chr++ = pu16lin[ 8];

		*pu16chr++ = pu16lin[23];
		*pu16chr++ = pu16lin[22];
		*pu16chr++ = pu16lin[21];
		*pu16chr++ = pu16lin[20];
		*pu16chr++ = pu16lin[19];
		*pu16chr++ = pu16lin[18];
		*pu16chr++ = pu16lin[17];
		*pu16chr++ = pu16lin[16];

		*pu16chr++ = pu16lin[31];
		*pu16chr++ = pu16lin[30];
		*pu16chr++ = pu16lin[29];
		*pu16chr++ = pu16lin[28];
		*pu16chr++ = pu16lin[27];
		*pu16chr++ = pu16lin[26];
		*pu16chr++ = pu16lin[25];
		*pu16chr++ = pu16lin[24];
		}

	// Return with the palette number.

	return ((UI) 0);

	}



// **************************************************************************
//	PxlToSFX8x8x4 ()
//
//	Usage
//		global UI PxlToSFX8x8x4 (UB * pu08src, UB * pu08dst,
//			UL ulsrcwidth)
//
//	Description
//		Convert the 256 color bitmap data at psrc (with line width of srcwidth
//		bytes) into a SuperNES character at pdst.  Return palette number.
//
//	Return Value
//		Palette number.
// **************************************************************************


global	UI PxlToSFX8x8x4 (UB * pu08src, UB * pu08dst, UL ulsrcwidth)

	{

	// Local variables.

	UB *							pu08lin;
	UB *							pu08chr;

	UW *							pu16lin;
	UW *							pu16chr;

	UD 								u32palette;

	UI								uii;
	SI								sij;

	UB								u08plane0;
	UB								u08plane1;
	UB								u08plane2;
	UB								u08plane3;
	UB								u08pixel;

	// Convert the 256 color data into a normal Super NES character.

	u32palette = 0;

	pu08chr = pu08dst;

	pu08lin = pu08src;

	for (uii = 8; uii != 0; uii -= 1)
		{
		u32palette |= ((UD *) pu08lin)[0] | ((UD *) pu08lin)[1];

		u08plane0 = 0;
		u08plane1 = 0;
		u08plane2 = 0;
		u08plane3 = 0;

		for (sij = 0; sij != 8; sij += 1)
			{
			u08pixel  = pu08lin[sij];
			u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
			u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
			u08plane2 = (u08plane2 << 1) | (((UB) 1) & (u08pixel >> 2));
			u08plane3 = (u08plane3 << 1) | (((UB) 1) & (u08pixel >> 3));
			}

		pu08chr[0]  = u08plane0;
		pu08chr[1]  = u08plane1;
		pu08chr[16] = u08plane2;
		pu08chr[17] = u08plane3;

		pu08chr += 2;
		pu08lin += ulsrcwidth;
		}

	pu08chr += (32-16);

	// Produce flipped versions if flipped characters are allowed.

	if ((flChrXFlipAllowed == YES) || (flChrYFlipAllowed == YES))

		{

		// Convert the 256 color data into an X-flipped Super NES character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			u08plane0 = 0;
			u08plane1 = 0;
			u08plane2 = 0;
			u08plane3 = 0;

			for (sij = 7; sij >= 0; sij -= 1)
				{
				u08pixel  = pu08lin[sij];
				u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
				u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
				u08plane2 = (u08plane2 << 1) | (((UB) 1) & (u08pixel >> 2));
				u08plane3 = (u08plane3 << 1) | (((UB) 1) & (u08pixel >> 3));
				}

			pu08chr[0]  = u08plane0;
			pu08chr[1]  = u08plane1;
			pu08chr[16] = u08plane2;
			pu08chr[17] = u08plane3;

			pu08chr += 2;
			pu08lin += ulsrcwidth;
			}

		pu08chr += 16;

		// Convert the normal Super NES character into a Y-flipped character.

		pu16chr = (UW *) pu08chr;
		pu16lin = (UW *) pu08dst;

		*pu16chr++ = pu16lin[ 7];
		*pu16chr++ = pu16lin[ 6];
		*pu16chr++ = pu16lin[ 5];
		*pu16chr++ = pu16lin[ 4];
		*pu16chr++ = pu16lin[ 3];
		*pu16chr++ = pu16lin[ 2];
		*pu16chr++ = pu16lin[ 1];
		*pu16chr++ = pu16lin[ 0];

		*pu16chr++ = pu16lin[15];
		*pu16chr++ = pu16lin[14];
		*pu16chr++ = pu16lin[13];
		*pu16chr++ = pu16lin[12];
		*pu16chr++ = pu16lin[11];
		*pu16chr++ = pu16lin[10];
		*pu16chr++ = pu16lin[ 9];
		*pu16chr++ = pu16lin[ 8];

		// Convert the X-flipped Super NES character into an X and Y-flipped character.

		pu16lin = (UW *) (pu08dst + 32);

		*pu16chr++ = pu16lin[ 7];
		*pu16chr++ = pu16lin[ 6];
		*pu16chr++ = pu16lin[ 5];
		*pu16chr++ = pu16lin[ 4];
		*pu16chr++ = pu16lin[ 3];
		*pu16chr++ = pu16lin[ 2];
		*pu16chr++ = pu16lin[ 1];
		*pu16chr++ = pu16lin[ 0];

		*pu16chr++ = pu16lin[15];
		*pu16chr++ = pu16lin[14];
		*pu16chr++ = pu16lin[13];
		*pu16chr++ = pu16lin[12];
		*pu16chr++ = pu16lin[11];
		*pu16chr++ = pu16lin[10];
		*pu16chr++ = pu16lin[ 9];
		*pu16chr++ = pu16lin[ 8];
		}

	// Get the palette number.

	u32palette = (u32palette >> 04) | (u32palette >> 12) |
							 (u32palette >> 20) | (u32palette >> 28);

	u32palette = u32palette & 0x0F;

	// Return with the palette number.

	return ((UI) u32palette);

	}



// **************************************************************************
//	PxlToSFX8x8x2 ()
//
//	Usage
//		global UI PxlToSFX8x8x2 (UB * pu08src, UB * pu08dst,
//			UL ulsrcwidth)
//
//	Description
//		Convert the 256 color bitmap data at psrc (with line width of srcwidth
//		bytes) into a SuperNES character at pdst.  Return palette number.
//
//	Return Value
//		Palette number.
// **************************************************************************


global	UI PxlToSFX8x8x2 (UB * pu08src, UB * pu08dst, UL ulsrcwidth)

	{

	// Local variables.

	UB *							pu08lin;
	UB *							pu08chr;

	UW *							pu16lin;
	UW *							pu16chr;

	UD 								u32palette;

	UI								uii;
	SI								sij;

	UB								u08plane0;
	UB								u08plane1;
	UB								u08pixel;

	// Convert the 256 color data into a normal Super NES character.

	u32palette = 0;

	pu08chr = pu08dst;

	pu08lin = pu08src;

	for (uii = 8; uii != 0; uii -= 1)
		{
		u32palette |= ((UD *) pu08lin)[0] | ((UD *) pu08lin)[1];

		u08plane0 = 0;
		u08plane1 = 0;

		for (sij = 0; sij != 8; sij += 1)
			{
			u08pixel  = pu08lin[sij];
			u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
			u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
			}

		pu08chr[0]  = u08plane0;
		pu08chr[1]  = u08plane1;

		pu08chr += 2;
		pu08lin += ulsrcwidth;
		}

	// pu08chr += (16-16);

	// Produce flipped versions if flipped characters are allowed.

	if ((flChrXFlipAllowed == YES) || (flChrYFlipAllowed == YES))

		{

		// Convert the 256 color data into an X-flipped Super NES character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			u08plane0 = 0;
			u08plane1 = 0;

			for (sij = 7; sij >= 0; sij -= 1)
				{
				u08pixel  = pu08lin[sij];
				u08plane0 = (u08plane0 << 1) | (((UB) 1) & u08pixel);
				u08plane1 = (u08plane1 << 1) | (((UB) 1) & (u08pixel >> 1));
				}

			pu08chr[0]  = u08plane0;
			pu08chr[1]  = u08plane1;

			pu08chr += 2;
			pu08lin += ulsrcwidth;
			}

		// pu08chr += (16-16);

		// Convert the normal Super NES character into a Y-flipped character.

		pu16chr = (UW *) pu08chr;
		pu16lin = (UW *) pu08dst;

		*pu16chr++ = pu16lin[7];
		*pu16chr++ = pu16lin[6];
		*pu16chr++ = pu16lin[5];
		*pu16chr++ = pu16lin[4];
		*pu16chr++ = pu16lin[3];
		*pu16chr++ = pu16lin[2];
		*pu16chr++ = pu16lin[1];
		*pu16chr++ = pu16lin[0];

		// Convert the X-flipped Super NES character into an X and Y-flipped character.

		pu16lin = (UW *) (pu08dst + 16);

		*pu16chr++ = pu16lin[7];
		*pu16chr++ = pu16lin[6];
		*pu16chr++ = pu16lin[5];
		*pu16chr++ = pu16lin[4];
		*pu16chr++ = pu16lin[3];
		*pu16chr++ = pu16lin[2];
		*pu16chr++ = pu16lin[1];
		*pu16chr++ = pu16lin[0];
		}

	// Get the palette number.

	u32palette = (u32palette >> 02) | (u32palette >> 10) |
							 (u32palette >> 18) | (u32palette >> 26);

	u32palette = u32palette & 0x3F;

	// Return with the palette number.

	return ((UI) u32palette);

	}



// **************************************************************************
//	ReformatMapsForSFX ()
//
//	Usage
//		static UW * ReformatMapsForSFX (UW * pu16src, UW * pu16end,
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


global	UW *                ReformatMapsForSFX      (
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
						"(XS, ReformatMapsForSFX)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) s16xorigin;

				if ((s16yorigin > 127) || (s16yorigin < -128)) {
					sprintf(ErrorMessage,
						"Y position offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForSFX)\n",
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
					"(XS, ReformatMapsForSFX)\n",
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
					"(XS, ReformatMapsForSFX)\n",
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
					"(XS, ReformatMapsForSFX)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[2] = (UB) u16tmp;

			u16tmp = pu16tmp[5];
			XSPRINTFMAP("BoxH=%02X\n", ((UI) u16tmp));
			if (u16tmp > ((UW) 0x00FFu)) {
				sprintf(ErrorMessage,
					"Y collision height overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForSFX)\n",
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
				"(XS, ReformatMapsForSFX)\n",
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
						"(XS, ReformatMapsForSFX)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) u16xoffset;

				if (u16yoffset > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"Y section offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForSFX)\n",
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
					"(XS, ReformatMapsForSFX)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			if (uih > 0x00FFu) {
				sprintf(ErrorMessage,
					"X collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForSFX)\n",
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



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTSFX.C
// **************************************************************************
// **************************************************************************
// **************************************************************************