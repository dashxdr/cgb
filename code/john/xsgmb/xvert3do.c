// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERT3DO.C                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into 3DO format.                                                     **
// **                                                                      **
// ** Last modified : 12 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stddef.h>
#include	<stdio.h>
#include	<string.h>
#include <stdlib.h>

#include	"elmer.h"
#include	"data.h"
#include	"xvert.h"
#include	"xs.h"
#include	"bitio.h"

//
// DEFINITIONS
//

typedef	struct FILESPRIDX_S
	{
	UD                  ud___fsiO;
	SB                  sb___fsiX;
	SB                  sb___fsiY;
	UB                  ub___fsiW;
	UB                  ub___fsiH;
	} FILESPRIDX_T;

//
// GLOBAL VARIABLES
//

//
// STATIC VARIABLES
//

//
// STATIC FUNCTION PROTOTYPES
//

static	UD *                Pxl08To3DO              (
								UB *                pu08src,
								UD *                pu32dst,
								UI                  uiwidth);

static	UD *                Buf32To3DONormal        (
								UD *                pu32src,
								UD *                pu32dst,
								UI                  uiwidth);

static	UD *                Buf32To3DOPacked        (
								UD *                pu32src,
								UD *                pu32dst,
								UI                  uiwidth);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * BitmapTo3DOSpr ()                                                      *
// **************************************************************************
// * Convert the rectangle within the bitmap into a sprite                  *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         BUFFER *        Ptr to buffer that will receive new spr data   *
// *         BUFFER *        End of buffer that will receive new spr data   *
// *                                                                        *
// * Output  BUFFER *        Updated ptr to spr buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// *                                                                        *
// *         The spr data has the following format ...                      *
// *           {                                                            *
// *           CHUNK3doS_T                                                  *
// *           UD Preamble word 1                                           *
// *           UD Preamble word 2 (if unpacked data)                        *
// *             {                                                          *
// *             UD sprite data in 3DO format                               *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	BUFFER *            BitmapTo3DOSpr          (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__Cur,
								BUFFER *            pbf__Max)

	{
	// Local variables.

	DATACHUNK_T *       pcl__Chunk;
	ANYPTR_T            cl___Buf;

	UB *                pu08src;
	UL                  ulwsrc;

	UD                  u32tmp;

	UD *                (*pfuncconv)(UB *, UD *, UI);
	UD *                (*pfuncpack)(UD *, UD *, UI);

	UD                  pu32buf[1024];

	// If its a blank bitmap then we've finished.

	if ((uibmw == 0) || (uibmh == 0)) {
		return (pbf__Cur);
		}

	// Save the sprite's position and size.

	pcl__Chunk = (DATACHUNK_T *) pbf__Cur;

	pcl__Chunk->sl___ckSize = 0;
	pcl__Chunk->ud___ckType = ID4_head;
	pcl__Chunk->ud___ckMach = ID4_3doS;
	pcl__Chunk->ui___ckFlag = 0;

	cl___Buf.ubp = (UB *) (pcl__Chunk + 1);

	// Save the 1ST preamble word.

	u32tmp = ((uibmh - 1) & 0x00003FFL) << 6;

	switch (uiSprBPP)
		{
		case 1:
			u32tmp |= 0x00000001L;
			break;
		case 2:
			u32tmp |= 0x00000002L;
			break;
		case 4:
			u32tmp |= 0x00000003L;
			break;
		case 6:
			u32tmp |= 0x00000004L;
			break;
		case 8:
			u32tmp |= 0x00000005L;
			break;
		case 16:
			u32tmp |= 0x00000006L;
			break;
		default:
			sprintf(ErrorMessage,
				"(BitmapTo3DOSpr) Can't create %dbpp sprites.\n",
				uiSprBPP);
			goto errorUnknown;
		}

	if (uiSprCoding == ENCODED_RGB) {
		u32tmp |= 0x00000010L;
		}

	if (uiSprCompression == ENCODED_PACKED) {
		u32tmp |= 0x80000000L;
		}

	if (uiOutputOrder == ORDERSWAP) {
		u32tmp = SwapD32(u32tmp);
		}

	*cl___Buf.udp++ = u32tmp;

	// Save the 2ND preamble word (if required).

	if (uiSprCompression == ENCODED_UNPACKED)
		{
		u32tmp = (uibmw - 1) & 0x00003FFL;

		if (uiOutputOrder == ORDERSWAP) {
			u32tmp = SwapD32(u32tmp);
			}

		*cl___Buf.udp++ = u32tmp;
		}

	// Now choose our conversion routine depending upon the source data.

	if (uiSprDirection == BOTTOMTOTOP) {
		sibmy = sibmy + uibmh - 1;
		}

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	if (pdbiti->ui___bmB == 8) {
		pfuncconv = Pxl08To3DO;
		pu08src   = pdbiti->pub__bmBitmap + (ulwsrc * sibmy) + sibmx;
		}
	else
		{
		sprintf(ErrorMessage,
			"(BitmapTo3DOSpr) Can't convert %dbpp data.\n",
			pdbiti->ui___bmB);
		goto errorUnknown;
		}

	if (uiSprDirection == BOTTOMTOTOP) {
		ulwsrc = 0 - ulwsrc;
		}

	// Finally, convert the data line-by-line.

	if (uiSprCompression == ENCODED_UNPACKED) {
		pfuncpack = Buf32To3DONormal;
		} else {
		pfuncpack = Buf32To3DOPacked;
		}

	while (uibmh-- != 0)
		{
		// Convert the source data into 32 BPP words in the line buffer.

		(*pfuncconv)(pu08src, pu32buf, uibmw);

		// Convert the 32 BPP data into its destination format.

		cl___Buf.udp = (*pfuncpack)(pu32buf, cl___Buf.udp, uibmw);

		// Move onto the next line.

		pu08src += ulwsrc;
		}

	// 32bit align the end of the sprite data.

	while ((((UL) cl___Buf.ubp) & 3) != 0)
		{
		*cl___Buf.ubp++ = 0;
		}

	// Save the size of this chunk.

	pcl__Chunk->sl___ckSize = cl___Buf.ubp - ((UB *) pcl__Chunk);

	// Return with success.

	return (cl___Buf.bfp);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_XVERT_UNKNOWN;

		return (NULL);

	}



// **************************************************************************
// * ReformatSprsFor3DO ()                                                  *
// **************************************************************************
// * Reformat the spr data for the SPR file                                 *
// **************************************************************************
// * Inputs  DATASPRSET_T *  Ptr to the sprite data                         *
// *         UB **           Ptr to variable that gets ptr to output data   *
// *         UI *            Ptr to variable that gets len of output data   *
// *         FILE *          Ptr to RES file, or NULL if none               *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    The old data has the following format ...                      *
// *           {                                                            *
// *           CHUNK3doS_T                                                  *
// *           UD Preamble word 1                                           *
// *           UD Preamble word 2 (if unpacked data)                        *
// *             {                                                          *
// *             UD sprite data in PSX format                               *
// *             }                                                          *
// *           }                                                            *
// *                                                                        *
// *         The new index has the following format ...                     *
// *           {                                                            *
// *           UD Offset from here to data                                  *
// *           SB Sprite X offset from origin                               *
// *           SB Sprite Y offset from origin                               *
// *           UB Sprite width                                              *
// *           UB Sprite height                                             *
// *           }                                                            *
// *                                                                        *
// *         The new data has the following format ...                      *
// *           {                                                            *
// *           UD Preamble word 1                                           *
// *           UD Preamble word 2 (if unpacked data)                        *
// *             {                                                          *
// *             UD sprite data in PSX format                               *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	ERRORCODE           ReformatSprsFor3DO      (
								DATASPRSET_T *      pcl__Spr,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	ANYPTR_T            pbf__Buf;

	DATASPRIDX_T *      pcl__Idx;

	FILESPRIDX_T *      pcl__FH;
	FILESPRIDX_T *      pcl__FI;

	DATACHUNK_T *       pcl__Chunk;

	UI                  ui___i;
	UI                  ui___j;

	UB *                pub__Tmp;
	UI                  ui___Tmp;

	// Initialize output buffer.

	ui___Buf  =
		sizeof(FILESPRIDX_T) * pcl__Spr->ui___sprsCount +
		(((UB *)pcl__Spr->pbf__sprsBufCur)-((UB *)pcl__Spr->pbf__sprsBuf1st));

	pub__Buf  = (UB *) malloc(ui___Buf);

	if (pub__Buf == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		sprintf(ErrorMessage,
			"(XVERT3DO) Not enough memory to allocate buffer.\n");
		return (ErrorCode);
		}

	pbf__Buf.ubp = pub__Buf;

	// Construct the sprite index table (for a RES file).

	if (pcl__Res != NULL)
		{
		*pcz__OutputExt = '\0';
		fprintf(pcl__Res, "resource \"IDX-%s\" public\n", pcz__OutputNam);
		fprintf(pcl__Res, "bytes\n");
		fprintf(pcl__Res, "$%08X!d $%08X!d\n",
			pcl__Spr->ui___sprsCount,
			0);

		pcl__Idx = pcl__Spr->acl__sprsBufIndx;

		for (ui___i = 0; ui___i < pcl__Spr->ui___sprsCount; ui___i += 1)
			{
			if (pcl__Idx->si___spriNumber < 0)
				{
				// Blank sprite.
				fprintf(pcl__Res, "$00000000!d 0 0 0 0\n");
				}
			else
				{
				// Normal sprite.

				*pcz__OutputExt = '\0';

				if (pcl__Spr->ui___sprsCount > 1)
					{
					sprintf(pcz__OutputExt, "_%03d", pcl__Idx->si___spriNumber);
					}

				fprintf(pcl__Res, "@SPR-%s %4d %4d %4d %4d\n",
					pcz__OutputNam,
					pcl__Idx->si___spriXOffset,
					pcl__Idx->si___spriYOffset,
					0,
					0);
				}
			pcl__Idx += 1;
			}
		fprintf(pcl__Res, "endresource\n\n");
		}

	// Construct the sprite data table.

	pcl__FH      =
	pcl__FI      = (FILESPRIDX_T *) (pbf__Buf.ubp);
	pbf__Buf.ubp = (UB *) (pcl__FI + pcl__Spr->ui___sprsCount);

	pcl__Idx = pcl__Spr->acl__sprsBufIndx;

	for (ui___i = 0; ui___i < pcl__Spr->ui___sprsCount; ui___i += 1)
		{
		// Blank sprite ???

		if (pcl__Idx->si___spriNumber < 0)
			{
			XSPRINTFMAP("SprN=FFFF (Blank)\n", (0));

			pcl__FI->ud___fsiO = 0;
			pcl__FI->sb___fsiX = 0;
			pcl__FI->sb___fsiY = 0;
			pcl__FI->ub___fsiW = 0;
			pcl__FI->ub___fsiH = 0;

			continue;
			}

		// Get X and Y origin, width and height.

		XSPRINTFMAP("SprN=%04X\n", (pcl__Idx.ui___spriNumber));
		XSPRINTFMAP("SprX=%02X\n", (pcl__Idx.si___spriXOffset & 0xFFu));
		XSPRINTFMAP("SprY=%02X\n", (pcl__Idx.si___spriYOffset & 0xFFu));
		XSPRINTFMAP("SprW=%02X\n", (pcl__Idx.ui___spriWidth   & 0xFFu));
		XSPRINTFMAP("SprH=%02X\n", (pcl__Idx.ui___spriHeight  & 0xFFu));

		pcl__FI->sb___fsiX = pcl__Idx->si___spriXOffset;
		pcl__FI->sb___fsiY = pcl__Idx->si___spriYOffset;
//		pcl__FI->ub___fsiW = pcl__Idx->ui___spriWidth  - 1;
//		pcl__FI->ub___fsiH = pcl__Idx->ui___spriHeight - 1;
		pcl__FI->ub___fsiW = pcl__Idx->ui___spriWidth;
		pcl__FI->ub___fsiH = pcl__Idx->ui___spriHeight;

		if ((pcl__Idx->si___spriXOffset >  127) ||
			(pcl__Idx->si___spriXOffset < -128))
			{
			sprintf(ErrorMessage,
				"(XVERT3DO) X overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if ((pcl__Idx->si___spriYOffset >  127) ||
			(pcl__Idx->si___spriYOffset < -128))
			{
			sprintf(ErrorMessage,
				"(XVERT3DO) Y overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if (pcl__Idx->ui___spriWidth  > 255)
			{
			sprintf(ErrorMessage,
				"(XVERT3DO) W overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if (pcl__Idx->ui___spriHeight > 255)
			{
			sprintf(ErrorMessage,
				"(XVERT3DO) H overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}

		// Get the offset to the packed sprite data.

		if (pcl__Idx->ul___spriBufLen == 0)
			{
			// Repeated sprite, get the offset from the original index.

			pcl__FI->ud___fsiO = pcl__FH[pcl__Idx->si___spriNumber].ud___fsiO;
			}
		else
			{
			// New sprite, calculate the offset.

			pcl__FI->ud___fsiO = pbf__Buf.ubp - ((UB *) pcl__FI);

			if (uiOutputOrder == ORDERSWAP)
				{
				pcl__FI->ud___fsiO = SwapD32(pcl__FI->ud___fsiO);
				}

			// Now copy the rest of the data chunk as is.

			pcl__Chunk = (DATACHUNK_T *) pcl__Idx->pbf__spriBufPtr;

			if (pcl__Res != NULL)
				{
				*pcz__OutputExt = '\0';

				if (pcl__Spr->ui___sprsCount > 1)
					{
					sprintf(pcz__OutputExt, "_%03d", ui___i);
					}

				fprintf(pcl__Res, "resource \"SPR-%s\"\n", pcz__OutputNam);
				/*
				fprintf(pcl__Res, "%3d!w %3d!w\n",
					0,
					0);
				*/
				fprintf(pcl__Res, "%3d!w %3d!w\n",
					pcl__Idx->ui___spriWidth,
					pcl__Idx->ui___spriHeight);
				fprintf(pcl__Res, "$00000000!d\n");

				if (flWriteRGB == NO)
					{
					fprintf(pcl__Res, "$00000000!d\n");
					}
				else
					{
					*pcz__OutputExt = '\0';
					fprintf(pcl__Res, "@SPL-%s\n", pcz__OutputNam);
					}

				pub__Tmp = (UB *) (pcl__Chunk + 1);
				ui___Tmp =        pcl__Chunk->sl___ckSize - sizeof(DATACHUNK_T);
				while (ui___Tmp)
					{
					ui___j    = (ui___Tmp < 32) ? ui___Tmp : 32;
					ui___Tmp -= ui___j;
					fprintf(pcl__Res, "[");
					while (ui___j--) fprintf(pcl__Res, "%02X", *pub__Tmp++);
					fprintf(pcl__Res, "]\n");
					}
				fprintf(pcl__Res, "endresource\n\n");
				}

			pub__Tmp = (UB *) (pcl__Chunk + 1);
			ui___Tmp =        pcl__Chunk->sl___ckSize - sizeof(DATACHUNK_T);

			memcpy(pbf__Buf.ubp, pub__Tmp, ui___Tmp);

			pbf__Buf.ubp += ui___Tmp;
			}

		// Now do the next sprite.

		pcl__FI  += 1;
		pcl__Idx += 1;
		}

	// All done.

	*ppub_Buf = pub__Buf;
	*pui__Buf = (pbf__Buf.ubp - pub__Buf);

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
// * Pxl08To3DO ()                                                          *
// **************************************************************************
// * Xvert one line of 8bpp data into 3DO format but padded out to 32bpp    *
// **************************************************************************
// * Inputs  UB *            Ptr to bitmap                                  *
// *         UD *            Ptr to destination buffer                      *
// *         UI              # of pixels to convert                         *
// *                                                                        *
// * Output  UD *            Updated ptr to destination, or NULL if failed  *
// **************************************************************************

static	UD *                Pxl08To3DO              (
								UB *                pu08src,
								UD *                pu32dst,
								UI                  uiwidth)

	{
	// Select how to output the data.

	if (uiSprCoding == ENCODED_PALETTE)
		{
		// Output pixel data as palettized.

		if (uiSprBPP == 16)
			{
			sprintf(ErrorMessage,
				"(XVERT3DO) Can't convert 8bpp source data into 16bpp palettized data.\n");
			goto errorIllegal;
			}

		while (uiwidth-- != 0)
			{
			 *pu32dst++ = ((UL) (*pu08src++)) & ulSprMask;
			}
		}
	else
		{
		// Output pixel data as RGB.

		sprintf(ErrorMessage,
			"(XVERT3DO) Don't know how to convert 8bpp data into RGB data.\n");
		goto errorUnknown;
		}

	// Return with success.

	return (pu32dst);

	// Error handlers (reached via the dreaded goto).

	errorIllegal:

		ErrorCode = ERROR_XVERT_ILLEGAL;
		goto errorExit;

	errorUnknown:

		ErrorCode = ERROR_XVERT_UNKNOWN;

	errorExit:

		return (NULL);
	}



// **************************************************************************
// * Buf32To3DONormal ()                                                    *
// **************************************************************************
// * Xvert one line of 32bpp padded data into uncompressed 3DO format data  *
// **************************************************************************
// * Inputs  UD *            Ptr to source (padded-data) buffer             *
// *         UD *            Ptr to destination buffer                      *
// *         UI              # of pixels to convert                         *
// *                                                                        *
// * Output  UD *            Updated ptr to destination, or NULL if failed  *
// **************************************************************************

static	UD *                Buf32To3DONormal        (
								UD *                pu32src,
								UD *                pu32dst,
								UI                  uiwidth)

	{
	// Local variables.

	UD *                pu32lin;
	UB *                pu08dst;

	// Initialize the output buffering.

	pu32lin = pu32dst;
	pu08dst = (UB *) pu32dst;

	BitIOInit(pu08dst);

	// Now write out the line.

	while (uiwidth--)
		{
		pu08dst = BitIOWrite(pu08dst, *pu32src++, uiSprBPP);
		}

	// Flush out the last bits, UD align, and then force to a minimum length
	// of U64.

	pu08dst = BitIOFlush(pu08dst, TRUE);

	pu32dst = (UD *) pu08dst;

	if ((pu32dst - pu32lin) == 1)
		{
		*pu32dst++ = 0;
		}

	// Return with success.

	return (pu32dst);
	}



// **************************************************************************
// * Buf32To3DOPacked ()                                                    *
// **************************************************************************
// * Xvert one line of 32bpp padded data to RLE bit-packed 3DO format data  *
// **************************************************************************
// * Inputs  UD *            Ptr to source (padded-data) buffer             *
// *         UD *            Ptr to destination buffer                      *
// *         UI              # of pixels to convert                         *
// *                                                                        *
// * Output  UD *            Updated ptr to destination, or NULL if failed  *
// **************************************************************************

static	UD *                Buf32To3DOPacked        (
								UD *                pu32src,
								UD *                pu32dst,
								UI                  uiwidth)

	{
	// Local variables.

	UD *                pu32lin;
	UD *                pu32cur;
	UD *                pu32tmp;
	UB *                pu08dst;

	UI                  uioffset;
	UI                  uiliteral;

	// Initialize the output buffering.

	pu32lin = pu32dst;
	pu08dst = (UB *) pu32dst;

	BitIOInit(pu08dst);

	// Write out enough space for the line offset.

	if (uiSprBPP < 8)
		{
		pu08dst = BitIOWrite(pu08dst, 0, 8);
		}
	else
		{
		pu08dst = BitIOWrite(pu08dst, 0, 16);
		}

	// Remove the trailing space from the line.

	if (flZeroTransparent == YES)
		{
		pu32tmp = pu32src + uiwidth - 1;

		while (*pu32tmp == 0)
			{
			pu32tmp -= 1;
			uiwidth -= 1;
			if (uiwidth == 0) break;
			}
		}

	// Now write out the line.

	uiliteral = 0;

	pu32cur = pu32src;

	while (uiwidth)
		{

		UD u32value;
		UI uirepeat;
		UI uilenliteral;
		UI uilenrepeat;

		// Find out how many repeats there are of the current pixel.

		pu32tmp = pu32cur;

		u32value = *pu32tmp++;
		uirepeat = uiwidth - 1;

		while (uirepeat)
			{
			if (*pu32tmp++ != u32value) break;
			uirepeat -= 1;
			}

		uirepeat = uiwidth - uirepeat;

		if (uirepeat > 64) uirepeat = 64;

		// Find out whether there is a repeat worth coding up.

		if (uirepeat == 1)
			{
			// Don't bother with a repeat of 1.
			uirepeat = 0;
			}
		else
			{
			// Calculate the number of bits used to code this as a literal or as
			// a repeat.

			uilenrepeat = 8;

			if ((u32value != 0) || (flZeroTransparent == NO)) {
				uilenrepeat  += uiSprBPP;
				}

			uilenliteral = uiSprBPP * uirepeat;

			if (uiliteral == 0) {
				uilenliteral += 8;
				} else {
				if (uirepeat != uiwidth) {
					uilenrepeat += 8;
					}
				}

			if ((uiliteral + uirepeat) > 64) {
				uilenliteral += 8;
				}

			// Is it worth coding up a repeat ?

			if (uilenrepeat > uilenliteral) {
				uirepeat = 0;
				}
			}

		// Do we need to output anything yet ?

		if ((uirepeat != 0) || (uiliteral == 64))
			{
			// Write out any literals.

			if (uiliteral)
				{
				pu08dst = BitIOWrite(pu08dst, uiliteral + 0x003FU, 8);

				while (uiliteral) {
					pu08dst = BitIOWrite(pu08dst, *pu32src++, uiSprBPP);
					uiliteral -= 1;
					}
				}

			// Write out any repeats.

			if (uirepeat)
				{
				if ((u32value != 0) || (flZeroTransparent == NO))
					{
					pu08dst = BitIOWrite(pu08dst, uirepeat + 0x00BFU, 8);
					pu08dst = BitIOWrite(pu08dst, *pu32src, uiSprBPP);
					} else {
					pu08dst = BitIOWrite(pu08dst, uirepeat + 0x007FU, 8);
					}
				pu32src += uirepeat;
				uiwidth -= uirepeat;
				}

			pu32cur = pu32src;

			}
		else
			{
			pu32cur   += 1;
			uiliteral += 1;
			uiwidth   -= 1;
			}
		}

	// Write out any remaining literal pixels.

	if (uiliteral)
		{
		pu08dst = BitIOWrite(pu08dst, uiliteral + 0x3F, 8);

		while (uiliteral) {
			pu08dst = BitIOWrite(pu08dst, *pu32src++, uiSprBPP);
			uiliteral -= 1;
			}
		}

	// Write the EOL, flush out the last bits, UD align, force to a minimum
	// length of U64, and finally write in the line offset.

	pu08dst = BitIOWrite(pu08dst, 0, 2);

	pu08dst = BitIOFlush(pu08dst, TRUE);

	pu32dst = (UD *) pu08dst;

	if ((pu32dst - pu32lin) == 1) {
		*pu32dst++ = 0;
		}

	uioffset = pu32dst - pu32lin - 2;

	if (uiSprBPP < 8)
		{
		BitIOInit ((UB *) pu32lin);
		BitIOWrite((UB *) pu32lin, uioffset, 8);
		}
	else
		{
		BitIOInit ((UB *) pu32lin);
		BitIOWrite((UB *) pu32lin, uioffset, 16);
		}

	// Return with success.

	return (pu32dst);
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERT3DO.C
// **************************************************************************
// **************************************************************************
// **************************************************************************

