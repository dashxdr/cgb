// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** DATA.C                                                        MODULE **
// **                                                                      **
// ** Modules defining structures and code for handling various types of   **
// ** data in a consistent fashion.                                        **
// **                                                                      **
// ** Last modified : 08 Oct 1998 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
//#include	<io.h>

#include	"elmer.h"
#include	"data.h"

ERRORCODE ErrorCode;
char ErrorMessage[256];

//
// DEFINITIONS
//

// Pixels per meter for Windows DIB header.
//
// Printer has a resolution of 300 dpi.
// Monitor has a resolution of 100 dpi @ a .25mm dot pitch.

#define	PRINTER_PPM         11811
#define	MONITOR_PPM          3937

//
// GLOBAL VARIABLES
//

// Global file type variable.
// Used to signal what type of file to use for reading/writing.
// The different codes used are defined in DATA.HPP

global	FILETYPE_T          FileType;

// Global data type variable.
// Used to signal what type of data is to be read/written.
// On reading, the code used should be the sum of all the different types
// of information that should be returned, i.e. use ...
//
// TYPE_BITMAP+TYPE_PCM_SAMPLE to return either kind of information.
//
// The different codes used are defined in DATA.H

global	DATATYPE_T          DataType;

//
// STATIC VARIABLES
//

// Remapping table for Gameboy Basketball ...

global	UB                  RemappingTable [256] =
				{
				0x00,0x01,0x02,0x03,0x00,0x21,0x22,0x23,
				0x00,0x41,0x42,0x43,0x00,0x61,0x62,0x63,
				0x00,0x11,0x12,0x13,0x00,0x31,0x32,0x33,
				0x00,0x51,0x52,0x53,0x00,0x71,0x72,0x73,
				0x00,0x41,0x42,0x43,0x00,0x51,0x52,0x53,
				0x00,0x41,0x42,0x43,0x00,0x51,0x52,0x53,
				0x00,0x61,0x62,0x63,0x00,0x71,0x72,0x73,
				0x00,0x61,0x62,0x63,0x00,0x71,0x72,0x73,

				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,

				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,

				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
				0x00,0x00,0x00,0x00,0x00,0x00,0xFE,0xFF
				};

// Ptr to histogram table. This is not allocated unless needed.

global	UL *                    paul_Histogram = NULL;

//
// STATIC FUNCTION PROTOTYPES
//

static	ERRORCODE           CheckBitmapSize     (UI width, UI height, UI bits);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * DataBitmapAlloc ()                                                     *
// **************************************************************************
// * Allocate a bitmap of the desired size                                  *
// **************************************************************************
// * Inputs  UD            Width                                            *
// *         UD            Height                                           *
// *         UW            Bits-per-pixel                                   *
// *         FL            Clear the bitmap ?                               *
// *                                                                        *
// * Output  DATABLOCK_T * Ptr to data or NULL if failed                    *
// **************************************************************************

global	DATABLOCK_T *       DataBitmapAlloc         (
								UI                  width,
								UI                  height,
								UI                  bits,
								FL                  clear)

	{
	// Local variables.

	UL                  l;
	UL                  m;
	UL                  s;
	DATABLOCK_T *       d;
	DATABITMAP_T *      b;

	// Check for illegal parameters.

	if (CheckBitmapSize(width, height, bits) != ERROR_NONE) {
		goto errorExit;
		}

	// Get size of line in bytes padded out to the next 4 byte boundary.
	// Given that ...

	l = ((((size_t) width * bits) + 31L) >> 3) & (~3L);

	// Now calculate the amount of memory needed for the whole block.

	m = l * height;
	s = m + sizeof(DATABITMAP_T);

	// Allocate the memory.

	d = (DATABLOCK_T *) malloc(s);

	if (d == NULL) {
		ErrorCode = ERROR_NO_MEMORY;
		goto errorExit;
		}

	// Initialize the data headers.

	b = (DATABITMAP_T *) d;

	memset(b, 0, sizeof(DATABITMAP_T));

	b->head.next       = NULL;
	b->head.prev       = NULL;
	b->head.size       = s;
	b->head.type       = DATA_BITMAP;

	b->pub__bmBitmap   = (UB *) (b+1);
	b->si___bmLineSize = l;
	b->si___bmXTopLeft = 0;
	b->si___bmYTopLeft = 0;
	b->ui___bmW        = width;
	b->ui___bmH        = height;
	b->ui___bmB        = bits;
	b->ui___bmF        = BM_TOP2BTM;

	// Clear the bitmap ?

	if ((clear == YES) && (m != 0))
		{
		memset(b->pub__bmBitmap, 0, m);
		}

	// Return with success.

	return (d);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * DataBitmapQuarter ()                                                   *
// **************************************************************************
// * Shrink the bitmap to 1/4 size                                          *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of box to shrink                  *
// *         SI              Y coordinate of box to shrink                  *
// *         UI              W of box to shrink                             *
// *         UI              H of box to shrink                             *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapQuarter       (
								DATABITMAP_T *      pcl__bm,
								SI                  si___boxx,
								SI                  si___boxy,
								UI                  ui___boxw,
								UI                  ui___boxh)

	{
	// Local variables.

	UB *                pub__srclin;
	UB *                pub__dstlin;
	UB *                pub__src;
	UB *                pub__dst;

	UI                  ui___halfw;
	UI                  ui___halfh;

	size_t              si___linesize;

	UI                  ui___i;

	// Get the shrink box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___boxx -= pcl__bm->si___bmXTopLeft;
	si___boxy -= pcl__bm->si___bmYTopLeft;

	if ((ui___boxw == 0) || (ui___boxh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't shrink a zero size box.\n");
		goto errorExit;
		}

	// Is the shrink rectangle within the bitmap ?

	if ((si___boxx < 0) || ((si___boxx + ui___boxw) > pcl__bm->ui___bmW) ||
		(si___boxy < 0) || ((si___boxy + ui___boxh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Shrink rectangle overruns bitmap.\n");
		goto errorExit;
		}

	// Select the shrink routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	if (pcl__bm->ui___bmB == 8)

		{
		// Shrink an 8 bits-per-pixel bitmap.
		pub__srclin =
		pub__dstlin =
			pcl__bm->pub__bmBitmap + (si___boxy * si___linesize) + si___boxx;

		ui___halfw = ui___boxw / 2;
		ui___halfh = ui___boxh / 2;
		ui___boxw -= ui___halfw;
		ui___boxh -= ui___halfh;

		while (ui___halfh--)
			{
			pub__src = pub__srclin;
			pub__dst = pub__dstlin;
			ui___i = ui___halfw;
			while (ui___i--)
				{
				*pub__dst = *pub__src;
				pub__src += 2;
				pub__dst += 1;
				}
			ui___i = ui___boxw;
			while (ui___i--)
				{
				*pub__dst++ = 0;
				}
			pub__dstlin += si___linesize;
			pub__srclin += si___linesize*2;
			}

		ui___boxw += ui___halfw;

		while (ui___boxh--)
			{
			memset(pub__dstlin, 0, ui___boxw);
			pub__dstlin += si___linesize;
			}
		// End of 8 bits-per-pixel shrink.
		}

	else

		{
		// Can't handle this number of bits-per-pixel.
		sprintf(ErrorMessage,
			"(DATA) Can't shrink a %u bpp bitmap.\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * DataBitmapRemap ()                                                     *
// **************************************************************************
// * Remap the pixel data using a lookup table                              *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of box to remap                   *
// *         SI              Y coordinate of box to remap                   *
// *         UI              W of box to remap                              *
// *         UI              H of box to remap                              *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapRemap         (
								DATABITMAP_T *      pcl__bm,
								SI                  si___boxx,
								SI                  si___boxy,
								UI                  ui___boxw,
								UI                  ui___boxh)

	{
	// Local variables.

	UB *                pub__lin;
	UB *                pub__pxl;

	SI                  si___linesize;

	UI                  ui___i;
	UI                  ui___j;

	// Get the remap box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___boxx -= pcl__bm->si___bmXTopLeft;
	si___boxy -= pcl__bm->si___bmYTopLeft;

	if ((ui___boxw == 0) || (ui___boxh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't remap a zero size box.\n");
		goto errorExit;
		}

	// Is the search rectangle within the bitmap ?

	if ((si___boxx < 0) || ((si___boxx + ui___boxw) > pcl__bm->ui___bmW) ||
		(si___boxy < 0) || ((si___boxy + ui___boxh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Remapping rectangle overruns bitmap.\n");
		goto errorExit;
		}

	// Select the search routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	if (pcl__bm->ui___bmB == 8)

		{
		// Remap an 8 bits-per-pixel bitmap.
		pub__lin = pcl__bm->pub__bmBitmap + (si___boxy * si___linesize) + si___boxx;

		for (ui___i = ui___boxh; ui___i != 0; ui___i -= 1)
			{
			pub__pxl = pub__lin;
			for (ui___j = ui___boxw; ui___j != 0; ui___j -= 1)
				{
				*pub__pxl = RemappingTable[*pub__pxl];
				++pub__pxl;
				}
			si___boxy   += 1;
			ui___boxh   -= 1;
			pub__lin += si___linesize;
			}
		// End of 8 bits-per-pixel filter.
		}
	else
		{
		// Can't handle this number of bits-per-pixel.

		sprintf(ErrorMessage,
			"Can't remap a bitmap that has %u bits-per-pixel.\n"
			"(DATA, DataBitmapRemap)\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * DataBitmapFilter ()                                                    *
// **************************************************************************
// * Filter a bitmap of pixels that are above or below a specified range    *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of box to filter                  *
// *         SI              Y coordinate of box to filter                  *
// *         UI              W of box to filter                             *
// *         UI              H of box to filter                             *
// *         UI              Lowest pixel value to keep                     *
// *         UI              Highest pixel value to keep                    *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapFilter        (
								DATABITMAP_T *      pcl__bm,
								SI                  si___boxx,
								SI                  si___boxy,
								UI                  ui___boxw,
								UI                  ui___boxh,
								UI                  ui___rangelo,
								UI                  ui___rangehi)

	{
	// Local variables.

	UB *                pub__lin;
	UB *                pub__pxl;

	UB                  ub___lo;
	UB                  ub___hi;

	SI                  si___linesize;

	UI                  ui___i;
	UI                  ui___j;

	// Is the bitmap in a known format ?

	if (ui___rangelo > ui___rangehi)
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Lo-filter limit is > Hi-filter limit.\n");
		goto errorExit;
		}

	// Get the filter box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___boxx -= pcl__bm->si___bmXTopLeft;
	si___boxy -= pcl__bm->si___bmYTopLeft;

	if ((ui___boxw == 0) || (ui___boxh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't filter a zero size box.\n");
		goto errorExit;
		}

	// Is the search rectangle within the bitmap ?

	if ((si___boxx < 0) || ((si___boxx + ui___boxw) > pcl__bm->ui___bmW) ||
		(si___boxy < 0) || ((si___boxy + ui___boxh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Filter rectangle overruns bitmap.\n");
		goto errorExit;
		}

	// Select the search routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	if (pcl__bm->ui___bmB == 8)

		{
		// Filter an 8 bits-per-pixel bitmap.

		if (ui___rangelo > 255)
			{
			ErrorCode = ERROR_DATA_ILLEGAL;
			sprintf(ErrorMessage,
				"(DATA) Lo-filter limit is too large for an 8-bpp bitmap.\n");
			goto errorExit;
			}

		if (ui___rangehi > 255)
			{
			ErrorCode = ERROR_DATA_ILLEGAL;
			sprintf(ErrorMessage,
				"(DATA) Hi-filter limit is too large for an 8-bpp bitmap.\n");
			goto errorExit;
			}

		ub___lo = ui___rangelo;
		ub___hi = ui___rangehi;

		pub__lin = pcl__bm->pub__bmBitmap + (si___boxy * si___linesize) + si___boxx;

		for (ui___i = ui___boxh; ui___i != 0; ui___i -= 1)
			{
			pub__pxl = pub__lin;
			for (ui___j = ui___boxw; ui___j != 0; ui___j -= 1)
				{
				if ((*pub__pxl < ub___lo) || (*pub__pxl > ub___hi)) {
					*pub__pxl = 0;
					}
				pub__pxl += 1;
				}
			si___boxy += 1;
			ui___boxh -= 1;
			pub__lin  += si___linesize;
			}
		// End of 8 bits-per-pixel filter.
		}

	else

		{
		// Can't handle this number of bits-per-pixel.

		sprintf(ErrorMessage,
			"(DATA) Can't filter a %u bpp bitmap.\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * DataBitmapHistogram ()                                                 *
// **************************************************************************
// * Count up the occurrences of each pixel within a bitmap                 *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of box to count                   *
// *         SI              Y coordinate of box to count                   *
// *         UI              W of box to count                              *
// *         UI              H of box to count                              *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapHistogram     (
								DATABITMAP_T *      pcl__bm,
								SI                  si___boxx,
								SI                  si___boxy,
								UI                  ui___boxw,
								UI                  ui___boxh)

	{

	// Local variables.

	UB *                pub__lin;
	UB *                pub__pxl;

	SI                  si___linesize;

	UI                  ui___i;
	UI                  ui___j;

	// Make sure that the histogram table exists.

	if (paul_Histogram == NULL)
		{
		paul_Histogram = (UL *) malloc(256*sizeof(UL));

		if (paul_Histogram == NULL)
			{
			ErrorCode = ERROR_NO_MEMORY;
			sprintf(ErrorMessage,
				"(DATA) Can't allocate memory for histogram table.\n");
			goto errorExit;
			}

		memset(paul_Histogram, 0, 256*sizeof(UL));
		}

	// Get the bounding box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___boxx -= pcl__bm->si___bmXTopLeft;
	si___boxy -= pcl__bm->si___bmYTopLeft;

	if ((ui___boxw == 0) || (ui___boxh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't make a histogram within a zero size box.\n");
		goto errorExit;
		}

	// Is the search rectangle within the bitmap ?

	if ((si___boxx < 0) || ((si___boxx + ui___boxw) > pcl__bm->ui___bmW) ||
		(si___boxy < 0) || ((si___boxy + ui___boxh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Histogram rectangle exceeds bitmap's boundaries.\n");
		goto errorExit;
		}

	// Select the search routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	if (pcl__bm->ui___bmB == 8)

		{
		// Remap an 8 bits-per-pixel bitmap.
		pub__lin = pcl__bm->pub__bmBitmap + (si___boxy * si___linesize) + si___boxx;

		for (ui___i = ui___boxh; ui___i != 0; ui___i -= 1)
			{
			pub__pxl = pub__lin;
			for (ui___j = ui___boxw; ui___j != 0; ui___j -= 1)
				{
				paul_Histogram[*pub__pxl++] += 1;
				}
			si___boxy  += 1;
			ui___boxh  -= 1;
			pub__lin += si___linesize;
			}
		// End of 8 bits-per-pixel filter.
		}
	else
		{
		// Can't handle this number of bits-per-pixel.

		sprintf(ErrorMessage,
			"(DATA) Can't make a histogram of a %u bpp bitmap.\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * DataBitmapBoundingBox ()                                               *
// **************************************************************************
// * Find the smallest box that contains all the non-zero pixel data        *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI *            Ptr to X coordinate of box                     *
// *         SI *            Ptr to Y coordinate of box                     *
// *         UI *            Ptr to W of box                                *
// *         UI *            Ptr to H of box                                *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapBoundingBox   (
								DATABITMAP_T *      pcl__bm,
								SI *                psi__boxx,
								SI *                psi__boxy,
								UI *                pui__boxw,
								UI *                pui__boxh)

	{

	// Local variables.

	UB *                pub__lin;
	UB *                pub__pxl;

	SI                  si___bmx;
	SI                  si___bmy;
	UI                  ui___bmw;
	UI                  ui___bmh;

	SI                  si___linesize;

	UI                  ui___i;
	UI                  ui___j;

	// Get the search box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___bmx = *psi__boxx - pcl__bm->si___bmXTopLeft;
	si___bmy = *psi__boxy - pcl__bm->si___bmYTopLeft;
	ui___bmw = *pui__boxw;
	ui___bmh = *pui__boxh;

	if ((ui___bmw == 0) || (ui___bmh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't find boundaries in a zero size box.\n");
		goto errorExit;
		}

	// Is the search rectangle within the bitmap ?

	if ((si___bmx < 0) || ((si___bmx + ui___bmw) > pcl__bm->ui___bmW) ||
		(si___bmy < 0) || ((si___bmy + ui___bmh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Boundary rectangle overruns bitmap.\n");
		goto errorExit;
		}

	// Select the search routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	// Is it an 8-bpp bitmap ?

	if (pcl__bm->ui___bmB == 8)

		// Search an 8 bits-per-pixel bitmap.

		{
		// Find the top edge.

		pub__lin = pcl__bm->pub__bmBitmap + (si___bmy * si___linesize) + si___bmx;

		for (ui___i = ui___bmh; ui___i != 0; ui___i -= 1)
			{
			pub__pxl = pub__lin;
			for (ui___j = ui___bmw; ui___j != 0; ui___j -= 1)
				{
				if (*pub__pxl != 0) goto foundTop;
				pub__pxl += 1;
				}
			si___bmy   += 1;
			ui___bmh   -= 1;
			pub__lin += si___linesize;
			}

		foundTop:

		// If ui___i == 0 then the box was blank, else we have found the top edge
		// and can continue on with the search for the other edges.

		if (ui___i == 0)
			{
			// Box is blank.
			//
			// Return with zero sized box.

			*pui__boxw = 0;
			*pui__boxh = 0;
			}
		else
			{
			// Box is not blank.
			//
			// Find the bottom edge.

			pub__lin = pcl__bm->pub__bmBitmap + ((si___bmy + ui___bmh - 1) * si___linesize) + si___bmx;

			for (ui___i = ui___bmh; ui___i != 0; ui___i -= 1)
				{
				pub__pxl = pub__lin;
				for (ui___j = ui___bmw; ui___j != 0; ui___j -= 1)
					{
					if (*pub__pxl != 0) goto foundBottom;
					pub__pxl += 1;
					}
				ui___bmh   -= 1;
				pub__lin -= si___linesize;
				}

			foundBottom:

			// Find the left edge.

			pub__lin = pcl__bm->pub__bmBitmap + (si___bmy * si___linesize) + si___bmx;

			for (ui___i = ui___bmw; ui___i != 0; ui___i -= 1)
				{
				pub__pxl = pub__lin;
				for (ui___j = ui___bmh; ui___j != 0; ui___j -= 1)
					{
					if (*pub__pxl != 0) goto foundLeft;
					pub__pxl += si___linesize;
					}
				si___bmx   += 1;
				ui___bmw   -= 1;
				pub__lin += 1;
				}

			foundLeft:

			// Find the right edge.

			pub__lin = pcl__bm->pub__bmBitmap + (si___bmy * si___linesize) + (si___bmx + ui___bmw - 1);

			for (ui___i = ui___bmw; ui___i != 0; ui___i -= 1)
				{
				pub__pxl = pub__lin;
				for (ui___j = ui___bmh; ui___j != 0; ui___j -= 1)
					{
					if (*pub__pxl != 0) goto foundRight;
					pub__pxl += si___linesize;
					}
				ui___bmw -= 1;
				pub__lin -= 1;
				}

			foundRight:

			// Return logical coordinates relative to the origin.

			*psi__boxx = si___bmx + pcl__bm->si___bmXTopLeft;
			*psi__boxy = si___bmy + pcl__bm->si___bmYTopLeft;
			*pui__boxw = ui___bmw;
			*pui__boxh = ui___bmh;
			}

		// End of 8 bits-per-pixel search.

		}

	// Wierd size bitmap.

	else

		// Can't handle this number of bits-per-pixel.

		{
		sprintf(ErrorMessage,
			"(DATA) Can't find boundaries of a %u bpp bitmap.\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
// * DataBitmapInvert ()                                                    *
// **************************************************************************
// * Flip the bitmap from top-to-btm to btm-to-top or vice-versa            *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapInvert        (
								DATABLOCK_T *       d)

	{

	// Local variables.

	DATABITMAP_T *      b;
	UB *                t;

	UB *                src;
	UB *                dst;
	size_t              s;
	size_t              w;
	UD                  h;

	// Does it exist ?

	if (d == NULL)
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		sprintf(ErrorMessage,
			"(DATA) Unable to invert NULL bitmap.\n");
		goto errorExit;
		}

	// Is it really a bitmap ?

	if (d->type != DATA_BITMAP)
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		sprintf(ErrorMessage,
			"(DATA) Unable to invert unknown data object.\n");
		goto errorExit;
		}

	// Then go ahead and invert it ...

	b = (DATABITMAP_T *) d;

	s = b->ui___bmH * b->si___bmLineSize;

	if (s != 0)

		{

		t = malloc(s);

		if (t == NULL)
			{
			ErrorCode = ERROR_NO_MEMORY;
			goto errorExit;
			}

		w = b->si___bmLineSize;
		h = b->ui___bmH;

		src = t + s - w;
		dst = b->pub__bmBitmap;

		memcpy(t, dst, s);

		while (h-- != 0)
			{
			memcpy(dst, src, w);
			src = src - w;
			dst = dst + w;
			}

		free(t);

		}

	// Return with success code.

	b->ui___bmF ^= BM_TOP2BTM;

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
// * DataBitmapShowHist ()                                                  *
// **************************************************************************
// * Prints out the pixel histogram                                         *
// **************************************************************************
// * Inputs  -                                                              *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

static	void Show1Val (UI ui___Num, UL ul___Val);

global	ERRORCODE           DataBitmapShowHist      (
								void                )

	{

	// Local variables.

	UL *                pul__Tmp;
	UL                  ul___Tmp;
	UL                  ul___Max;

	UI                  ui___i;
	UI                  ui___j;

	// Make sure that the histogram table exists.

	if (paul_Histogram == NULL)
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		sprintf(ErrorMessage,
			"(DATA) Can't find histogram table.\n");
		goto errorExit;
		}

	// First find out the maximum entry (ignoring blank pixels).

	paul_Histogram[0] = 0;

	ul___Max = 0;

	pul__Tmp = paul_Histogram;
	for (ui___i = 256; ui___i != 0; ui___i -= 1)
		{
		ul___Tmp = *pul__Tmp++;
		if (ul___Tmp > ul___Max) ul___Max = ul___Tmp;
		}

	// Find out a scaling factor to reduce each entry to 16 bits.

	ui___j = 0;

	while (ul___Max > 65536ul)
		{
		ul___Max >>= 1;
		ui___j    += 1;
		}

	// Apply the scaling factor to every entry, making sure that
	// we don't scale anything down to zero.

	if (ui___j != 0)
		{
		pul__Tmp = paul_Histogram;
		for (ui___i = 256; ui___i != 0; ui___i -= 1)
			{
			ul___Tmp = *pul__Tmp;
			if (ul___Tmp != 0) {
				ul___Tmp >>= ui___j;
				if (ul___Tmp == 0) ul___Tmp = 1;
				}
			*pul__Tmp++ = ul___Tmp;
			}
		}

	// Now calculate the total of the entries left.

	ul___Max = 0;

	pul__Tmp = paul_Histogram;
	for (ui___i = 256; ui___i != 0; ui___i -= 1)
		{
		ul___Max += *pul__Tmp++;
		}

	// Convert the entries to percentages (to 2dp).

	pul__Tmp = paul_Histogram;
	for (ui___i = 256; ui___i != 0; ui___i -= 1)
		{
		ul___Tmp = *pul__Tmp;
		if (ul___Tmp != 0) {
			ul___Tmp = (ul___Tmp * 10000) / ul___Max;
			if (ul___Tmp == 0) ul___Tmp = 1;
			}
		*pul__Tmp++ = ul___Tmp;
		}

	// Now print out the results.

	printf("\nHistogram of Colours Used (as a percentage, minimum 0.01%%)\n\n");

	ui___i = 0;

	do	{
		do	{
			Show1Val(ui___i+0x00, paul_Histogram[ui___i+0x00]);
			Show1Val(ui___i+0x10, paul_Histogram[ui___i+0x10]);
			Show1Val(ui___i+0x20, paul_Histogram[ui___i+0x20]);
			Show1Val(ui___i+0x30, paul_Histogram[ui___i+0x30]);
			printf("\n");
			ui___i += 1;
			} while ((ui___i & 15) != 0);
		printf("\n");
		ui___i += (64 - 16);
		} while (ui___i != 256);

	printf("\n");

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}

//

static	void Show1Val (UI ui___Num, UL ul___Val)
	{
	//
	UI ui___X;
	UI ui___Y;
	//
	if (ul___Val == 0)
		{
		printf("%3d   0       ", ui___Num);
		}
	else
		{
		ui___X = ul___Val / 100;
		ui___Y = ul___Val % 100;
		printf("%3d %3d.%02d    ", ui___Num, ui___X, ui___Y);
		}
	}




// **************************************************************************
// * DataBitmapPalettize ()                                                 *
// **************************************************************************
// * Flag characters that use more than one palette                         *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of box to remap                   *
// *         SI              Y coordinate of box to remap                   *
// *         UI              W of box to remap                              *
// *         UI              H of box to remap                              *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataBitmapPalettize     (
								DATABITMAP_T *      pcl__bm,
								SI                  si___boxx,
								SI                  si___boxy,
								UI                  ui___boxw,
								UI                  ui___boxh)

	{
	// Local variables.

	UB *                pub__lin;

	SI                  si___linesize;

	SI                  si___i;
	SI                  si___j;

	SI                  si___x;
	SI                  si___y;

	UB                  ub___pal;

	UB                  aub__palette [16];

	// Round width and height to character multiples.

	ui___boxw = (ui___boxw + 7) & ~7;
	ui___boxh = (ui___boxh + 7) & ~7;

	// Get the remap box position and size (relative to the bitmap's physical
	// coordinates, rather than its logical coordinates).

	si___boxx -= pcl__bm->si___bmXTopLeft;
	si___boxy -= pcl__bm->si___bmYTopLeft;

	if ((ui___boxw == 0) || (ui___boxh == 0))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Can't filter characters in a zero size box.\n");
		goto errorExit;
		}

	// Is the search rectangle within the bitmap ?

	if ((si___boxx < 0) || ((si___boxx + ui___boxw) > pcl__bm->ui___bmW) ||
		(si___boxy < 0) || ((si___boxy + ui___boxh) > pcl__bm->ui___bmH))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Filter characters rectangle overruns bitmap.\n");
		goto errorExit;
		}

	// Select the search routine depending upon the number of bits-per-pixel.

	si___linesize = pcl__bm->si___bmLineSize;

	if (pcl__bm->ui___bmB == 8)

		{
		// Remap an 8 bits-per-pixel bitmap.

		pub__lin = pcl__bm->pub__bmBitmap + (si___boxy * si___linesize) + si___boxx;

		for (si___x = 0; si___x != (SI) ui___boxw; si___x += 8)
			{
			for (si___y = 0; si___y != (SI) ui___boxh; si___y += 8)
				{
				// Clear palette used flags.

				for (si___i = 0; si___i < 16; si___i += 1) aub__palette[si___i] = 0;

				// Find out which palettes are used within this character.

				pub__lin = pcl__bm->pub__bmBitmap +
					((si___boxy + si___y) * si___linesize) + (si___boxx + si___x);

				for (si___i = 0; si___i != 8; si___i += 1)
					{
					for (si___j = 0; si___j != 8; si___j += 1)
						{
						ub___pal = 0x0Fu & (*pub__lin >> 4);

						aub__palette[ub___pal] += 1;

						pub__lin += 1;
						}
					pub__lin += si___linesize - 8;
					}

				// Select the palette to use.

				ub___pal = 0x00;

				for (si___i = 0; si___i < 16; si___i += 1)
					{
					if ((aub__palette[si___i] != 0) && (aub__palette[si___i] != 64))
						{
//						ub___pal = (UB) (si___i << 4);
						ub___pal = (UB) 0x80u;
						break;
						}
					}

				// Remap the character to use the selected palette.

				if (ub___pal != 0)
					{
					pub__lin = pcl__bm->pub__bmBitmap +
						((si___boxy + si___y) * si___linesize) + (si___boxx + si___x);

					for (si___i = 0; si___i != 8; si___i += 1)
						{
						for (si___j = 0; si___j != 8; si___j += 1)
							{
							*pub__lin = (0x0Fu & (*pub__lin)) | ub___pal;

							pub__lin += 1;
							}
						pub__lin += si___linesize - 8;
						}
					}
				}
			}

		// End of 8 bits-per-pixel filter.
		}
	else
		{
		// Can't handle this number of bits-per-pixel.

		sprintf(ErrorMessage,
			"Can't filter characters in a bitmap that has %u bits-per-pixel.\n"
			"(DATA, DataBitmapPalettize)\n",
			(UI) pcl__bm->ui___bmB);
		goto errorUnknown;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_DATA_UNKNOWN;

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * DataDuplicate ()                                                       *
// **************************************************************************
// * Makes a copy of a data block                                           *
// **************************************************************************
// * Inputs  DATABLOCK_T *   Ptr to block to copy                           *
// *                                                                        *
// * Output  DATABLOCK_T *   Ptr to new block, or NULL if an error          *
// **************************************************************************

global	DATABLOCK_T *       DataDuplicate           (
								DATABLOCK_T *       pdbold)

	{

	// Local variables.

	DATABLOCK_T *       pdbnew;
	DATABITMAP_T *      pbmh;

	// Does it exist ?

	if (pdbold == NULL)
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		sprintf(ErrorMessage,
			"(DATA) Unable to duplicate NULL data object.\n");
		goto errorExit;
		}

	// Is it a DATA_BITMAP ?

	if (pdbold->type == DATA_BITMAP)
		{
		pdbnew = (DATABLOCK_T *) malloc(pdbold->size);
		if (pdbnew == NULL)
			{
			ErrorCode = ERROR_NO_MEMORY;
			goto errorExit;
			}
		memcpy(pdbnew, pdbold, pdbold->size);
		pbmh                = (DATABITMAP_T *) pdbnew;
		pbmh->pub__bmBitmap = (UB *) (pbmh + 1);
		}

	// Then God knows what it is.

	else
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		sprintf(ErrorMessage,
			"(DATA) Unable to duplicate unknown data object.\n");
		goto errorExit;
		}

	// Return with success.

	return (pdbnew);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return ((DATABLOCK_T *) NULL);
	}



// **************************************************************************
// * DataFree ()                                                            *
// **************************************************************************
// * Frees up the memory belonging to the data block                        *
// **************************************************************************
// * Inputs  DATABLOCK_T *   Ptr to block to free                           *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           DataFree                (
								DATABLOCK_T *       d)

	{
	if (d != NULL)
		{
		// Is it a DATA_BITMAP ?

		if (d->type == DATA_BITMAP)
			{
			free(d);
			}

		// Then God knows what it is.

		else
			{
			ErrorCode = ERROR_DATA_UNKNOWN;
			sprintf(ErrorMessage,
				"(DATA) Unable to free unknown data object.\n");
			return (ERROR_DATA_UNKNOWN);
			}
		}

	return (ERROR_NONE);
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * CheckBitmapSize ()                                                     *
// **************************************************************************
// * Check whether the bitmap parameters are legal and understood           *
// **************************************************************************
// * Inputs  UI              Width                                          *
// *         UI              Height                                         *
// *         UI              Bits-per-pixel                                 *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    The restrictions are :                                         *
// *                                                                        *
// *         width   <= 65536                                               *
// *         height  <= 65536                                               *
// *         bits    == 1/4/8/24                                            *
// *         size    <= 2MB (this is arbitrary and can easily be increased) *
// **************************************************************************

static	ERRORCODE           CheckBitmapSize         (
								UI                  width,
								UI                  height,
								UI                  bits)

	{

	// Local variables.

	UI                  s;

	// Start the checks ...

	if ((bits != 1) && (bits != 4) && (bits != 8) && (bits != 24))
		{
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (number of bits must be 1/4/8/24).\n");
		goto errorExit;
		}

	if (bits != 8)
		{
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (only 256 color implemented).\n");
		goto errorExit;
		}

	if (width > 32768L)
		{
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (max width is 32768).\n");
		goto errorExit;
		}

	if (height > 32768L)
		{
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (max height is 32768).\n");
		goto errorExit;
		}

	s = width * height;

	switch (bits)
		{
		case  1: s = s/8; break;
		case  4: s = s/2; break;
		case  8: break;
		case 16: s = s*2; break;
		case 24: s = s*3; break;
		case 32: s = s*4; break;
		}

	if (s > (2048*1024))
		{
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (bitmap > 2MB is far too big).\n");
		goto errorExit;
		}

	// Somewhat arbitrary check for width without height or vice versa.

	if (((width == 0) && (height != 0)) || ((width != 0) && (height == 0)))
		{
		ErrorCode = ERROR_DATA_ILLEGAL;
		sprintf(ErrorMessage,
			"(DATA) Illegal bitmap size (width without height or vice versa).\n");
		goto errorExit;
		}

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode = ERROR_DATA_ILLEGAL);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF DATA.C
// **************************************************************************
// **************************************************************************
// **************************************************************************