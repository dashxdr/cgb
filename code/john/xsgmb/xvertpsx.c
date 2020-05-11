// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTPSX.C                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Playstation format.                                             **
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

static	UD *                Pxl08ToPSX              (
								UB *                pu08src,
								UD *                pu32dst,
								UI                  uiwidth);

static	UB *                Buf32ToPSXNormal        (
								UD *                pu32src,
								UB *                pu08dst,
								UI                  uiwidth);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * BitmapToPSXSpr ()                                                      *
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
// *           CHUNKPSXS_T                                                  *
// *           UD Preamble word 1                                           *
// *           UD Preamble word 2 (if unpacked data)                        *
// *             {                                                          *
// *             UD sprite data in PSX format                               *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	BUFFER *            BitmapToPSXSpr          (
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

	UD *                (*pfuncconv)(UB *, UD *, UI);
	UB *                (*pfuncpack)(UD *, UB *, UI);

	UD                  pu32buf[1024];

	// If its a blank bitmap then we've finished.

	if ((uibmw == 0) || (uibmh == 0)) {
		return (pbf__Cur);
		}

	// Save the sprite's position and size.

	pcl__Chunk = (DATACHUNK_T *) pbf__Cur;

	pcl__Chunk->sl___ckSize = 0;
	pcl__Chunk->ud___ckType = ID4_head;
	pcl__Chunk->ud___ckMach = ID4_PsxS;
	pcl__Chunk->ui___ckFlag = 0;

	cl___Buf.ubp = (UB *) (pcl__Chunk + 1);

	// Now choose our conversion routine depending upon the source data.

	if (uiSprDirection == BOTTOMTOTOP) {
		sibmy = sibmy + uibmh - 1;
		}

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	if (pdbiti->ui___bmB == 8) {
		pfuncconv = Pxl08ToPSX;
		pu08src   = pdbiti->pub__bmBitmap + (ulwsrc * sibmy) + sibmx;
		}
	else
		{
		sprintf(ErrorMessage,
			"(BitmapToPSXSpr)%s Can't convert %dbpp data.\n",
			"(XS, BitmapToPSX)\n",
			pdbiti->ui___bmB);
		goto errorUnknown;
		}

	if (uiSprDirection == BOTTOMTOTOP) {
		ulwsrc = 0 - ulwsrc;
		}

	// Finally, convert the data line-by-line.

	if (uiSprCompression == ENCODED_UNPACKED) {
		pfuncpack = Buf32ToPSXNormal;
		} else {
		// I've left this in just in case we want to add
		// software compression at some stage.
		pfuncpack = Buf32ToPSXNormal;
		}

	while (uibmh-- != 0)
		{
		// Convert the source data into 32 BPP words in the line buffer.

		(*pfuncconv)(pu08src, pu32buf, uibmw);

		// Convert the 32 BPP data into its destination format.

		cl___Buf.ubp = (*pfuncpack)(pu32buf, cl___Buf.ubp, uibmw);

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
// * ReformatSprsForPSX ()                                                  *
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
// *           CHUNKPsxS_T                                                  *
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
// *             {                                                          *
// *             UD sprite data in PSX format                               *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	ERRORCODE           ReformatSprsForPSX      (
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
			"(XVERTPSX) Not enough memory to allocate buffer.\n");
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
				"(XVERTPSX) X overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if ((pcl__Idx->si___spriYOffset >  127) ||
			(pcl__Idx->si___spriYOffset < -128))
			{
			sprintf(ErrorMessage,
				"(XVERTPSX) Y overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if (pcl__Idx->ui___spriWidth  > 255)
			{
			sprintf(ErrorMessage,
				"(XVERTPSX) W overflow in sprite 0x%04X during reformat.\n",
				(pcl__Idx->si___spriNumber));
			}
		if (pcl__Idx->ui___spriHeight > 255)
			{
			sprintf(ErrorMessage,
				"(XVERTPSX) H overflow in sprite 0x%04X during reformat.\n",
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
// * PxlToPSX8x8x4 ()                                                       *
// **************************************************************************
// * Xvert 8bpp bitmap data into an PSX character                           *
// **************************************************************************
// * Inputs  UB *            Ptr to src buffer                              *
// *         UB *            Ptr to dst buffer                              *
// *         UL              Line width of source                           *
// *                                                                        *
// * Output  UI              Palette number of the character                *
// **************************************************************************

global	UI                  PxlToPSX8x8x4           (
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
		// Convert the 256 color data into an X-flipped PSX character.

		pu08lin = pu08src;

		for (uii = 8; uii != 0; uii -= 1)
			{
			*pu08chr++	= (pu08lin[7] << 4) | (pu08lin[6] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[5] << 4) | (pu08lin[4] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[3] << 4) | (pu08lin[2] & ((UB) 0x0F));
			*pu08chr++	= (pu08lin[1] << 4) | (pu08lin[0] & ((UB) 0x0F));

			pu08lin += ulsrcwidth;
			}

		// Convert the normal PSX character into a Y-flipped character.

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

		// Convert the X-flipped PSX character into an X and Y-flipped character.

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



// **************************************************************************
// * PxlToPSX8x8x8 ()                                                       *
// **************************************************************************
// * Xvert 8bpp bitmap data into an PSX character                           *
// **************************************************************************
// * Inputs  UB *            Ptr to src buffer                              *
// *         UB *            Ptr to dst buffer                              *
// *         UL              Line width of source                           *
// *                                                                        *
// * Output  UI              Palette number of the character                *
// **************************************************************************

global	UI                  PxlToPSX8x8x8           (
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

	// Convert the 256 color data into a normal PSX character.

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
		// Convert the 256 color data into an X-flipped PSX character.

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

		// Convert the normal PSX character into a Y-flipped character.

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
// * ReformatMapsForPSX ()                                                  *
// **************************************************************************
// * Reformat the map data for the MAP file                                 *
// **************************************************************************
// * Inputs  UW *            Ptr to map data                                *
// *         UW *            Ptr to map data end                            *
// *         UW *            Ptr to map data buffer end                     *
// *         UD *            Ptr to map data index                          *
// *         UI              # of maps to reformat                          *
// *                                                                        *
// * Output  UW *            Updated ptr to map data end                    *
// *                                                                        *
// *         The old map data has the following format ...                  *
// *           {                                                            *
// *           SW 0 (was X offset from origin to top left of chrmap)        *
// *           SW 0 (was Y offset from origin to top left of chrmap)        *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW map palette                                               *
// *           UW number of map sections                                    *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               UW character data                                        *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// *                                                                        *
// *         The new map data has the following format ...                  *
// *           {                                                            *
// *           SB X offset from origin to top left of chrmap          (1)   *
// *           SB Y offset from origin to top left of chrmap          (1)   *
// *           SB X offset from top left of chrmap to top left of box (2)   *
// *           SB Y offset from top left of chrmap to top left of box (2)   *
// *           UB box width in pixels                                 (2)   *
// *           UB box height in pixels                                (2)   *
// *           UB map palette                                               *
// *           UB number of map sections                                    *
// *             {                                                          *
// *             UB section X offset from top left of chrmap                *
// *             UB section Y offset from top left of chrmap                *
// *             UB section width in characters - 1                   (3)   *
// *             UB section height in characters - 1                  (3)   *
// *             UB section width & height in packed attribute format (4)   *
// *             UB section width*height                              (4)   *
// *               {                                                        *
// *               UW character data                                  (5)   *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// *                                                                        *
// *         (1) Only if flOutputMapPosition == YES                         *
// *         (2) Only if flOutputMapBoxSize == YES                          *
// *         (3) Only if map is a chrmap                                    *
// *         (4) Only if map is a sprmap                                    *
// *         (5) If chrmap then data is stored Top->Bottom[Left->Right]     *
// *             If sprmap then data is stored Left->Right[Top->Bottom]     *
// **************************************************************************

global	UW *                ReformatMapsForPSX      (
								UW *                pu16src,
								UW *                pu16end,
								UW *                pu16max,
								UD *                pu32idx,
								UI                  uimapcount)

	{

	// Local variables.

	UL                  uloffset;

	UW *                pu16tmp;
	UW *                pu16dst;

	UI                  uii;
	UI                  uij;

	UI                  uiw;
	UI                  uih;

	UI                  uimapflags;

	UW                  u16tmp;

	SW                  s16xorigin;
	SW                  s16yorigin;
	UW                  u16xoffset;
	UW                  u16yoffset;

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
						"(XS, ReformatMapsForPSX)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) s16xorigin;

				if ((s16yorigin > 127) || (s16yorigin < -128)) {
					sprintf(ErrorMessage,
						"Y position offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForPSX)\n",
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
					"(XS, ReformatMapsForPSX)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[0] = (UB) u16tmp;

			u16tmp = pu16tmp[3];
			XSPRINTFMAP("BoxY=%02X\n", ((UI) u16tmp));
			if ((((SW) u16tmp) > 127) || (((SW) u16tmp) < -128)) {
				sprintf(ErrorMessage,
					"Y collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForPSX)\n",
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
					"(XS, ReformatMapsForPSX)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			((UB *) pu16dst)[2] = (UB) u16tmp;

			u16tmp = pu16tmp[5];
			XSPRINTFMAP("BoxH=%02X\n", (UI) u16tmp);
			if (u16tmp > ((UW) 0x00FFu)) {
				sprintf(ErrorMessage,
					"Y collision height overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForPSX)\n",
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
				"(XS, ReformatMapsForPSX)\n",
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
						"(XS, ReformatMapsForPSX)\n",
						(uimapcount - uii));
					goto errorOverflow;
					}
				((UB *) pu16dst)[0] = (UB) u16xoffset;

				if (u16yoffset > ((UW) 0x00FFu)) {
					sprintf(ErrorMessage,
						"Y section offset overflow in map 0x%04X.\n"
						"(XS, ReformatMapsForPSX)\n",
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
					"(XS, ReformatMapsForPSX)\n",
					(uimapcount - uii));
				goto errorOverflow;
				}
			if (uih > 0x00FFu) {
				sprintf(ErrorMessage,
					"X collision offset overflow in map 0x%04X.\n"
					"(XS, ReformatMapsForPSX)\n",
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
				if ((uimapflags & 0x8000u) == 0)
					{
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
				((UB *) pu16dst)[0] = ((uiw - 1) << 2) | (uih - 1);
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
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * Pxl08ToPSX ()                                                          *
// **************************************************************************
// * Xvert one line of 8bpp data into PSX format but padded out to 32bpp    *
// **************************************************************************
// * Inputs  UB *            Ptr to bitmap                                  *
// *         UD *            Ptr to destination buffer                      *
// *         UI              # of pixels to convert                         *
// *                                                                        *
// * Output  UD *            Updated ptr to destination, or NULL if failed  *
// **************************************************************************

static	UD *                Pxl08ToPSX              (
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
				"(XVERTPSX) Can't convert 8bpp source data into 16bpp palettized data.\n");
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
			"(XVERTPSX) Don't know how to convert 8bpp data into RGB data.\n");
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
// * Buf32ToPSXNormal ()                                                    *
// **************************************************************************
// * Xvert one line of 32bpp padded data into uncompressed PSX format data  *
// **************************************************************************
// * Inputs  UD *            Ptr to source (padded-data) buffer             *
// *         UD *            Ptr to destination buffer                      *
// *         UI              # of pixels to convert                         *
// *                                                                        *
// * Output  UD *            Updated ptr to destination, or NULL if failed  *
// **************************************************************************

static	UB *                Buf32ToPSXNormal        (
								UD *                pu32src,
								UB *                pu08dst,
								UI                  uiwidth)

	{
	// Local variables.

	UI                  uipad;

	// Find out how much to pad out the end of line. The PSX requires
	// that the data be padded out to 8 pixel boundaries.

	uipad = (8 - (uiwidth & 7)) & 7;

	// Initialize the output buffering.

	BitIOInit(pu08dst);

	// Now write out the line.

	if (uiSprBPP == 4)
		{
		while (uiwidth > 1)
			{
			pu08dst = BitIOWrite(pu08dst, pu32src[1], uiSprBPP);
			pu08dst = BitIOWrite(pu08dst, pu32src[0], uiSprBPP);
			pu32src += 2;
			uiwidth -= 2;
			}
		if (uiwidth == 1)
			{
			pu08dst = BitIOWrite(pu08dst,          0, uiSprBPP);
			pu08dst = BitIOWrite(pu08dst, pu32src[0], uiSprBPP);
			pu32src += 1;
			uipad   -= 1;
			}
		while (uipad--)
			{
			pu08dst = BitIOWrite(pu08dst, 0, uiSprBPP);
			}
		}
	else
		{
		while (uiwidth--)
			{
			pu08dst = BitIOWrite(pu08dst, *pu32src++, uiSprBPP);
			}
		while (uipad--)
			{
			pu08dst = BitIOWrite(pu08dst, 0, uiSprBPP);
			}
		}

	// Flush out the last bits and UD align.

	pu08dst = BitIOFlush(pu08dst, TRUE);

	// Return with success.

	return (pu08dst);
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTPSX.C
// **************************************************************************
// **************************************************************************
// **************************************************************************

