// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERT.C                                                       MODULE **
// **                                                                      **
// ** Convert a bitmap into one of several machine specific formats.       **
// **                                                                      **
// ** Last modified : 27 Jul 1998 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stddef.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"io.h"

#include	"elmer.h"
#include	"data.h"
#include	"xvert.h"
#include	"xs.h"

//
// DEFINITIONS
//

//
// GLOBAL VARIABLES
//

// Conversion flags.

global	UI                  uiMachineType			= MACHINE_3DO;
global	UI                  uiOutputOrder			= ORDERHILO;

global	UI                  uiMapType				= MAP_PXL;

global	UI                  uiChrBitSize			= 16;
global	UI                  uiChrXFlShift			= 2;
global	UI                  uiChrYFlShift			= 2;
global	UI                  uiChrPriMask			= 2;
global	UI                  uiChrPriShift			= 2;
global	UI                  uiChrPalMask			= 2;
global	UI                  uiChrPalShift			= 2;
global	UI                  uiChrNumMask			= 2;
global	UI                  uiChrNumShift			= 2;

global	UI                  uiChrMapOrder			= ORDER_LRTB;
global	UI                  uiChrMapOffset			= 0;

global	UI                  uiSprBPP				= 6;
global	UL                  ulSprMask				= 0x0000003Fl;
global	UI                  uiSprCoding				= ENCODED_PALETTE;
global	UI                  uiSprCompression		= ENCODED_PACKED;
global	UI                  uiSprDirection			= TOPTOBOTTOM;
global	UI                  uiSprPalette			= 0;

global	FL                  flSprLockYGrid          = NO;
global	FL                  flSprLockXGrid          = NO;

global	UI                  uiMapBoxFactor			= 100;

global	FL                  flReferenceFrame		= NO;
global	FL                  flFindEdges				= NO;

global	FL                  flZeroTransparent		= YES;
global	FL                  flZeroColour0			= YES;

global	FL                  flRemovePalRepeats		= YES;
global	FL                  flRemoveChrRepeats		= YES;
global	FL                  flRemoveBlkRepeats		= YES;
global	FL                  flRemoveMapRepeats		= NO;
global	FL                  flRemoveSprRepeats		= YES;
global	FL                  flRemoveFrmRepeats		= NO;
global	FL                  flRemoveIdxRepeats		= NO;

global	FL                  flRemoveBlankMaps		= YES;
global	FL                  flRemoveBlankSprs		= NO;

global	FL                  flChrXFlipAllowed		= YES;
global	FL                  flChrYFlipAllowed		= YES;

global	FL                  flStoreChrNumber		= YES;
global	FL                  flStoreChrPriority		= YES;
global	FL                  flStoreChrFlip			= YES;
global	FL                  flStoreChrPalette		= YES;

global	FL                  flChrMapToBlkMap		= NO;

global	FL                  flMapXFlipAllowed		= NO;
global	FL                  flMapYFlipAllowed		= NO;

global	FL                  flStoreMapPosition		= YES;
global	FL                  flStoreMapPalette		= NO;

global	FL                  flClrPriority			= NO;
global	FL                  flSetPriority			= NO;

global	FL                  flRmvPermanentChr		= NO;
global	UI                  uiNumPermanentChr		= 0;

global	SI                  siStaticMapFrame        = 0;

global	DATACHRSET_T        ChrInfo;
global	DATABLKSET_T        BlkInfo;
global	DATAMAPSET_T        MapInfo;
global	DATASPRSET_T        SprInfo;
global	DATAFNTSET_T        FntInfo;
global	DATAPALSET_T        PalInfo;

// Conversion data pointers.

global	UD                  TotalChrExpected = 0;

//
// STATIC VARIABLES
//

//
// STATIC FUNCTION PROTOTYPES
//

static	UW *                BitmapToChrmap          (
								XVERTINFOBLOCK *    pxib,
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								UW *                pu16dst,
								UW *                pu16max);

static	UW *                BitmapToSprmap          (
								XVERTINFOBLOCK *    pxib,
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								UW *                pu16dst,
								UW *                pu16max);

static	UI                  PxlToChr8x8x8           (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth);

static	UI                  PxlToChr8x8x4           (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth);

static	UI                  PxlToChr8x8x2           (
								XVERTINFOBLOCK *    pxib,
				  				UB *                pu08src,
								UL                  ulsrcwidth);

static	FL                  CompareChr8x8x8         (
								UD *                p,
								UD *                q);

static	FL                  CompareChr8x8x4         (
								UD *                p,
								UD *                q);

static	FL                  CompareChr8x8x2         (
								UD *                p,
								UD *                q);

static	UI                  ChrToBlk                (
								XVERTINFOBLOCK *    pxib,
								UW *                pu16src,
								UL                  ulsrcwidth);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * XvertStorePalette ()                                                   *
// **************************************************************************
// * Add this bitmap's palette(s) to the palette set                        *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         DATAPALSET_T *  Ptr to palette set                             *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK, else -ve if failed           *
// *                                                                        *
// * N.B.    The palette data has the following format ...                  *
// *           {                                                            *
// *           CHUNKpalD_T                                                  *
// *             {                                                          *
// *             RGBQUAD_T palette data                                     *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	ERRORCODE           XvertStorePalette       (
								DATABITMAP_T *      pcl__Bmp,
								DATAPALSET_T *      pcl__Pal)

	{

	// Local variables.

	FL                  fl___blank;
	FL                  fl___repeat;

	DATACHUNK_T *       pcl__Chk;
	ANYPTR_T            cl___Buf;
	ANYPTR_T            cl___End;

	RGBQUAD_T *         pcl__SrcPal;
	RGBQUAD_T *         pcl__DstPal;

	DATAPALIDX_T *      pcl__PalIdx;

	UD *                pud__KeyPtr;
	UI                  ui___KeyLen;
	UD                  ud___KeyVal;

	DATAPALIDX_T *      pcl__TmpIdx;
	UD *                pud__TmpPtr;

	UI                  ui___NumPal;
	UI                  ui___LenPal;

	UI                  ui___i;
	UI                  ui___j;

	// Check for a palette-format bitmap.

	if (pcl__Bmp->ui___bmB > 8)
		{
		sprintf(ErrorMessage,
			"(XVERT) Can't store palette, data is in RGB format.\n");
		return (ErrorCode = ERROR_XVERT_ILLEGAL);
		}

	// Convert the bitmap into a sprite.

	fl___blank  = NO;
	fl___repeat = NO;

	pcl__SrcPal = pcl__Bmp->acl__bmC;

	ui___NumPal = 1;
	ui___LenPal = (1 << pcl__Bmp->ui___bmB);

	// Save a section of the palette.

	while (ui___NumPal--)

		{
		// Save the palette head.

		cl___Buf.bfp = pcl__Pal->pbf__palsBufCur;
		cl___End.bfp = pcl__Pal->pbf__palsBufEnd;

		pcl__Chk = (DATACHUNK_T *) cl___Buf.bfp;

		pcl__Chk->sl___ckSize = 0;
		pcl__Chk->ud___ckType = ID4_palD;
		pcl__Chk->ud___ckMach = ID4_Mxxx;
		pcl__Chk->ui___ckFlag = 0;

		// Save the palette data.

		pcl__DstPal = (RGBQUAD_T *) (pcl__Chk + 1);

		if (flZeroColour0 == YES)
			{
			pcl__SrcPal->ub___rgbR = 0;
			pcl__SrcPal->ub___rgbG = 0;
			pcl__SrcPal->ub___rgbB = 0;
			pcl__SrcPal->ub___rgbA = 4;
			}

		ui___i = ui___LenPal;

		do	{
			*pcl__DstPal++ = *pcl__SrcPal++;
			} while (--ui___i);

		cl___Buf.bfp = (BUFFER *) pcl__DstPal;

		// Scan the palette data for alpha-channel transparency codes.

		if (flPaletteAlphaRGB == YES)
			{
			RGBQUAD_T * pcl__TmpPal;

			pcl__TmpPal =
			pcl__DstPal = (RGBQUAD_T *) (pcl__Chk + 1);

			ui___i = ui___LenPal;

			do	{
				if ((pcl__DstPal->ub___rgbR >= 0xFCu) &&
					(pcl__DstPal->ub___rgbG == 0x00u) &&
					(pcl__DstPal->ub___rgbB == 0x00u))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 1;
					pcl__DstPal++;
					}
				else
				if ((pcl__DstPal->ub___rgbR == 0x00u) &&
					(pcl__DstPal->ub___rgbG >= 0xFCu) &&
					(pcl__DstPal->ub___rgbB == 0x00u))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 2;
					pcl__DstPal++;
					}
				else
				if ((pcl__DstPal->ub___rgbR == 0x00u) &&
					(pcl__DstPal->ub___rgbG == 0x00u) &&
					(pcl__DstPal->ub___rgbB >= 0xFCu))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 3;
					pcl__DstPal++;
					}
				else
					{
					pcl__TmpPal = pcl__DstPal++;
					}
				} while (--ui___i);
			}

		if (flPaletteAlphaBGR == YES)
			{
			RGBQUAD_T * pcl__TmpPal;

			pcl__TmpPal =
			pcl__DstPal = (RGBQUAD_T *) (pcl__Chk + 1);

			ui___i = ui___LenPal;

			do	{
				if ((pcl__DstPal->ub___rgbR >= 0xFCu) &&
					(pcl__DstPal->ub___rgbG == 0x00u) &&
					(pcl__DstPal->ub___rgbB == 0x00u))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 3;
					pcl__DstPal++;
					}
				else
				if ((pcl__DstPal->ub___rgbR == 0x00u) &&
					(pcl__DstPal->ub___rgbG >= 0xFCu) &&
					(pcl__DstPal->ub___rgbB == 0x00u))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 2;
					pcl__DstPal++;
					}
				else
				if ((pcl__DstPal->ub___rgbR == 0x00u) &&
					(pcl__DstPal->ub___rgbG == 0x00u) &&
					(pcl__DstPal->ub___rgbB >= 0xFCu))
					{
					pcl__DstPal->ub___rgbR = pcl__TmpPal->ub___rgbR;
					pcl__DstPal->ub___rgbG = pcl__TmpPal->ub___rgbG;
					pcl__DstPal->ub___rgbB = pcl__TmpPal->ub___rgbB;
					pcl__DstPal->ub___rgbA = 1;
					pcl__DstPal++;
					}
				else
					{
					pcl__TmpPal = pcl__DstPal++;
					}
				} while (--ui___i);
			}

		// Save the size of this chunk.

		pcl__Chk->sl___ckSize = cl___Buf.ubp - ((UB *) pcl__Chk);

		// Initialize the new palette's index entry.

		pcl__PalIdx = &(pcl__Pal->acl__palsBufIndx[pcl__Pal->ui___palsCount]);

		pcl__PalIdx->pbf__paliBufPtr = (BUFFER *) pcl__Chk;
		pcl__PalIdx->ul___paliBufLen =            pcl__Chk->sl___ckSize;

		pcl__PalIdx->si___paliNumber = pcl__Pal->ui___palsCount;

		pcl__PalIdx->ui___paliMaxVal = 0;

		// Calculate the new palette's key value.

		pud__KeyPtr = (UD *) pcl__PalIdx->pbf__paliBufPtr;
		ui___KeyLen =        pcl__PalIdx->ul___paliBufLen;
		ud___KeyVal = 0;

		for (ui___i = (ui___KeyLen >> 2); ui___i != 0; ui___i -= 1)
			{
			ud___KeyVal ^= *pud__KeyPtr++;
			ud___KeyVal += 1;
			}

		pcl__PalIdx->ud___paliKeyVal = ud___KeyVal;

		// Check for a repeated palette definition ?

		if (flRemovePalRepeats == YES)
			{
			// Check if the palette already exists in the sprite set.

			pcl__TmpIdx = pcl__Pal->acl__palsBufIndx;

			for (ui___i = pcl__Pal->ui___palsCount; ui___i != 0; ui___i -= 1)
				{
				if (ud___KeyVal == pcl__TmpIdx->ud___paliKeyVal)
					{
					if (ui___KeyLen == pcl__TmpIdx->ul___paliBufLen)
						{
						pud__KeyPtr = (UD *) pcl__PalIdx->pbf__paliBufPtr;
						pud__TmpPtr = (UD *) pcl__TmpIdx->pbf__paliBufPtr;
						for (ui___j = (ui___KeyLen >> 2); ui___j != 0; ui___j -= 1)
							{
							if (*pud__KeyPtr++ != *pud__TmpPtr++) break;
							}
						if (ui___j == 0)
							{
							pcl__PalIdx->pbf__paliBufPtr = pcl__TmpIdx->pbf__paliBufPtr;
							pcl__PalIdx->ul___paliBufLen = 0;
							pcl__PalIdx->si___paliNumber = pcl__Pal->ui___palsCount - ui___i;
							if (pcl__TmpIdx->ui___paliMaxVal < pcl__PalIdx->ui___paliMaxVal)
								{
								pcl__TmpIdx->ui___paliMaxVal = pcl__PalIdx->ui___paliMaxVal;
								}
							cl___Buf.bfp = pcl__Pal->pbf__palsBufCur;
							fl___repeat  = YES;
							break;
							}
						}
					}
				pcl__TmpIdx += 1;
				}
			}

		// Save out the palette number to store in sprite data.

		uiSprPalette  =
		uiFilePalette =	pcl__PalIdx->si___paliNumber + 1;

		// Update the palette data buffer pointer.

		pcl__Pal->pbf__palsBufCur = cl___Buf.bfp;
		pcl__Pal->ui___palsCount += 1;
		}

	// Save the resulting index in the frame data, and display it.

	#if 0
	if (fl___blank == YES) {
		printf("palnumber=0x%04X (blank)\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	else if (fl___repeat == YES) {
		printf("palnumber=0x%04X (repeat of 0x%04X)\n\n",
			(UI) (si___idx & 0xFFFFu),
			(UI) pcl__PalIdx->si___paliNumber);
		}
	else {
		printf("palnumber=0x%04X\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	#endif

	#if 1
	printf("palnumber=0x%04X\n\n",
		(UI) (uiFilePalette));
	#endif

	// All Done.

	return (ERROR_NONE);

	}



// **************************************************************************
// * XvertBitmapBorder16 ()                                                 *
// **************************************************************************
// * Expand the bitmap 32 pixels in W & H to produce a 16 pixel border      *
// **************************************************************************
// * Inputs  DATABLOCK_T *   Ptr to old bitmap                              *
// *                                                                        *
// * Output  DATABLOCK_T *   Ptr to new bitmap or NULL if failed            *
// *                                                                        *
// * N.B.    Original bitmap is freed.                                      *
// **************************************************************************

global	DATABLOCK_T *       XvertBitmapBorder16     (
								DATABLOCK_T *       d)

	{

	// Local variables.

	DATABLOCK_T *       e;

	DATABITMAP_T *      bd;
	DATABITMAP_T *      be;

	UB *                p;
	UB *                q;

	UD                  sp;
	UD                  sq;

	UD                  w;
	UD                  h;

	//

	e  = NULL;

	bd = (DATABITMAP_T *) d;

	if (bd->ui___bmB != 8)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"(XVERT) Can't expand %u bpp bitmap.\n",
			(UI) bd->ui___bmB);
		goto errorFree;
		}

	w = ((bd->ui___bmW + 3) & (~3L));
	h = bd->ui___bmH;

	// Allocate the large bitmap.

	e = DataBitmapAlloc(w + 32, h + 32, 8, YES);

	if (e == NULL) {
		goto errorFree;
		}

	be = (DATABITMAP_T *) e;

	// Update the new bitmap header.

	be->si___bmXTopLeft = bd->si___bmXTopLeft - 16;
	be->si___bmYTopLeft = bd->si___bmYTopLeft - 16;
	be->ui___bmF        = bd->ui___bmF;

	// Copy the color palette.

	memcpy(be->acl__bmC, bd->acl__bmC, (256 * sizeof(RGBQUAD_T)));

	// Copy the bitmap data.

	p = bd->pub__bmBitmap;
	q = be->pub__bmBitmap + (be->si___bmLineSize * 16) + 16;

	sp = bd->si___bmLineSize;
	sq = be->si___bmLineSize;

	while (h-- != 0)
		{
		memcpy(q, p, sp);
		p = p + sp;
		q = q + sq;
		}

	// Return with success.

	DataFree(d);

	return (e);

	// Error handlers (reached via the dreaded goto).

	errorFree:

		DataFree(d);
		DataFree(e);

//	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * XvertBitmapToMapFrm ()                                                 *
// **************************************************************************
// * Convert the bitmap into a sprite frame                                 *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         DATACHRSET_T *  Ptr to chrset that will receive new chr data   *
// *         DATABLKSET_T *  Ptr to blkset that will receive new blk data   *
// *         DATAMAPSET_T *  Ptr to mapset that will receive new map data   *
// *         UW *            Ptr to buffer that will receive new frm data   *
// *         UW *            End of buffer that will receive new frm data   *
// *                                                                        *
// * Output  UW *            Updated ptr to frm buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// *                                                                        *
// *         The space at the end of the chrset/blkset/mapset is used as    *
// *         buffer space during the conversion.                            *
// *                                                                        *
// *         The frm data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           UW map's palette number                                      *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW map number                                                *
// *           }                                                            *
// *                                                                        *
// *         The map data has the following format ...                      *
// *           {                                                            *
// *           SW 0 (was X offset from origin to top left of chrmap)        *
// *           SW 0 (was Y offset from origin to top left of chrmap)        *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW flag bits (palette number removed)                        *
// *           UW number of map sections                                    *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               either UW character data                                 *
// *               or     UD character data                                 *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	UW *                XvertBitmapToMapFrm    (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATACHRSET_T *      pdchri,
								DATABLKSET_T *      pdblki,
								DATAMAPSET_T *      pdmapi,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	FL                  fl___blank;
	FL                  fl___repeat;

	DATAMAPIDX_T *      pcl__mapidx;

	UW *                pu16mapdst;
	UW *                pu16mapend;
	UW *                pu16blkdst;
	UW *                pu16blkend;

	UD *                pud__keyptr;
	UD                  ud___keyval;
	UI                  ui___buflen;

	DATAMAPIDX_T *      pcl__idxptr;
	UD *                pud__bufptr;

	SI                  si___idx;

	UI                  ui___i;
	UI                  ui___j;

	// Enough room for the frm data ?

	if ((pu16max - pu16dst) < 8)
		{
		ErrorCode = ERROR_XVERT_FRMFULL;
		sprintf(ErrorMessage,
			"(XVERT) Frm buffer full during XvertBitmapToMapFrm.\n");
		goto errorExit;
		}

	pu16max = pu16dst + 8;

	// Find out where to put the new map data.

	pu16mapdst = pdmapi->puw__mapsBufCur;
	pu16blkend =
	pu16mapend = pdmapi->puw__mapsBufEnd;

	// Initialize the map's index entry.

	pcl__mapidx = &(pdmapi->acl__mapsBufIndx[pdmapi->ui___mapsCount]);

	pcl__mapidx->ud___mapiKeyVal = 0;

	// Is it a blank map ?

	fl___blank  = NO;
	fl___repeat = NO;

	if ((uibmw == 0) || (uibmh == 0))

		{
		// Initialize blank map frame.

//		pcl__mapidx->puw__mapiBufPtr  = pdmapi->acl__mapsBufIndx[0].puw__mapiBufPtr;
		pcl__mapidx->puw__mapiBufPtr  = NULL;

		pcl__mapidx->ul___mapiBufLen  = 0;
		pcl__mapidx->si___mapiXOffset = 0;
		pcl__mapidx->si___mapiYOffset = 0;
		pcl__mapidx->si___mapiNumber  = 0;

		pu16dst[0] = 0;
		pu16dst[1] = 0;
		pu16dst[2] = 0;
		pu16dst[3] = 0;
		pu16dst[4] = 0;
		pu16dst[5] = 0;
		pu16dst[6] = 0;
		pu16dst[7] = 0;

		pu16mapend = pu16mapdst;

		fl___blank = YES;
		}

	else

		{
		// Now convert the bitmap into a chrmap.

		pu16mapend = XvertBitmapToChrmap
			(pdbiti, sibmx, sibmy, uibmw, uibmh, pdchri, pu16mapdst, pu16mapend);

		if (pu16mapend == NULL) {
			goto errorExit;
			}

		// Do we want to convert the chrmap to a blkmap ?

		if (flChrMapToBlkMap == YES)
			{
			// Convert the chrmap data to blkmap data.

			pu16blkdst = pu16mapend;
			pu16blkend = XvertChrmapToBlkmap
				(pu16mapdst, pdblki, pu16blkdst, pu16blkend);

			if (pu16blkend == NULL) {
				goto errorExit;
				}

			// Copy the blkmap data on top of the chrmap data.

			memcpy(pu16mapdst, pu16blkdst, ((pu16blkend - pu16blkdst) * sizeof(UW)));

			pu16mapend = pu16mapdst + (pu16blkend - pu16blkdst);
			}

		// Pad map out if required to keep the maps aligned on UD boundaries.

		if (((pu16mapend - pu16mapdst) & 1) != 0) {
			*pu16mapend++ = 0;
			}

		// Remove the position and palette data from the map header (but leave
		// the flag settings).

		if (flStoreMapPosition == NO)
			{
			pu16mapdst[0] = 0;
			pu16mapdst[1] = 0;
			}

		if (flStoreMapPalette == NO)
			{
			pu16mapdst[6] = pu16mapdst[6] & ((UW) 0xFF00u);
			}

		// Set up the frm header and index.

		pcl__mapidx->puw__mapiBufPtr  = pu16mapdst;
		pcl__mapidx->ul___mapiBufLen  = (pu16mapend - pu16mapdst) * sizeof(UW);
		pcl__mapidx->si___mapiXOffset = 0;
		pcl__mapidx->si___mapiYOffset = 0;
		pcl__mapidx->si___mapiNumber  = pdmapi->ui___mapsCount;

		pu16dst[0] = pu16mapdst[0];
		pu16dst[1] = pu16mapdst[1];
		pu16dst[2] = pu16mapdst[6] & ((UW) 0x00FFu);
		pu16dst[3] = 0;
		pu16dst[4] = 0;
		pu16dst[5] = 0;
		pu16dst[6] = 0;

		// Calculate the new map's key value.

		pud__keyptr = (UD *) pcl__mapidx->puw__mapiBufPtr;
		ui___buflen =        pcl__mapidx->ul___mapiBufLen;
		ud___keyval = 0;

		for (ui___i = (ui___buflen >> 2); ui___i != 0; ui___i -= 1)
			{
			ud___keyval ^= *pud__keyptr++;
			ud___keyval += 1;
			}
		pcl__mapidx->ud___mapiKeyVal = ud___keyval;

		// Check for a repeated map definition ?

		if (flRemoveMapRepeats == YES)
			{
			// Check if the map already exists in the map set.

			pcl__idxptr = pdmapi->acl__mapsBufIndx;

			for (ui___i = pdmapi->ui___mapsCount; ui___i != 0; ui___i -= 1)
				{
				if (ud___keyval == pcl__idxptr->ud___mapiKeyVal)
					{
					if (ui___buflen == pcl__idxptr->ul___mapiBufLen)
						{
						pud__keyptr = (UD *) pcl__mapidx->puw__mapiBufPtr;
						pud__bufptr = (UD *) pcl__idxptr->puw__mapiBufPtr;
						for (ui___j = (ui___buflen >> 2); ui___j != 0; ui___j -= 1)
							{
							if (*pud__keyptr++ != *pud__bufptr++) break;
							}
						if (ui___j == 0)
							{
							pcl__mapidx->puw__mapiBufPtr = pcl__idxptr->puw__mapiBufPtr;
							pcl__mapidx->ul___mapiBufLen = 0;
							pcl__mapidx->si___mapiNumber = pdmapi->ui___mapsCount - ui___i;
							pu16mapend = pu16mapdst;
							fl___repeat = YES;
							break;
							}
						}
					}
				pcl__idxptr += 1;
				}
			}
		}

	// Update the map data buffer pointer.

	pdmapi->puw__mapsBufCur = pu16mapend;

	// Is this a duplicate or blank index that should be removed ?

	if ((flRemoveBlankMaps == YES) &&
		(pcl__mapidx->puw__mapiBufPtr == NULL))
		{
		si___idx = 0;
		}
	else
		{
		// Check for a repeated sprite index ?

		si___idx = pdmapi->ui___mapsCount++;

		if (flRemoveIdxRepeats == YES)
			{
			// Check if the map index already exists in the map set.

			pcl__idxptr = pdmapi->acl__mapsBufIndx;

			for (ui___i = si___idx; ui___i != 0; ui___i -= 1)
				{
				if (memcmp(pcl__idxptr, pcl__mapidx, sizeof(DATAMAPIDX_T)) == 0)
					{
					pdmapi->ui___mapsCount -= 1;
					si___idx               -= ui___i;
					fl___repeat = YES;
					break;
					}
				pcl__idxptr += 1;
				}
			}
		}

	// Save the resulting index in the frame data, and display it.

	pu16dst[7] = si___idx;

	#if 1
	if (fl___blank == YES) {
		printf("mapnumber=0x%04X (blank)\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	else if (fl___repeat == YES) {
		printf("mapnumber=0x%04X (repeat of 0x%04X)\n\n",
			(UI) (si___idx & 0xFFFFu),
			(UI) pcl__mapidx->si___mapiNumber);
		}
	else {
		printf("mapnumber=0x%04X\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	#endif

	// Print out map position and number.

	#if 0
		printf("frmxoff=0x%04hX frmyoff=0x%04hX mappalette=0x%04hX mapnumber=0x%04hX\n\n",
			(US) pu16dst[0], (US) pu16dst[1], (US) pu16dst[2], (US) pu16dst[7]);
	#endif

	// Return with address of next free frm buffer space.

	return (pu16max);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * XvertBitmapToSprFrm ()                                                 *
// **************************************************************************
// * Convert the bitmap into a sprite frame                                 *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         DATACHRSET_T *  Ptr to chrset that will receive new chr data   *
// *         DATABLKSET_T *  Ptr to blkset that will receive new blk data   *
// *         DATAMAPSET_T *  Ptr to mapset that will receive new map data   *
// *         UW *            Ptr to buffer that will receive new frm data   *
// *         UW *            End of buffer that will receive new frm data   *
// *                                                                        *
// * Output  UW *            Updated ptr to frm buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// *                                                                        *
// *         The space at the end of the chrset/blkset/mapset is used as    *
// *         buffer space during the conversion.                            *
// *                                                                        *
// *         The frm data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           UW map's palette number                                      *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW map number                                                *
// *           }                                                            *
// *                                                                        *
// *         The map data has the following format ...                      *
// *           {                                                            *
// *           SW 0 (was X offset from origin to top left of chrmap)        *
// *           SW 0 (was Y offset from origin to top left of chrmap)        *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW flag bits (palette number removed)                        *
// *           UW number of map sections                                    *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               either UW character data                                 *
// *               or     UD character data                                 *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	UW *                XvertBitmapToSprFrm     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATASPRSET_T *      pdspri,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	FL                  fl___blank;
	FL                  fl___repeat;

	DATASPRIDX_T *      pcl__spridx;

	BUFFER *            pbf__sprdst;
	BUFFER *            pbf__sprend;

	UD *                pud__keyptr;
	UD                  ud___keyval;
	UI                  ui___buflen;

	DATASPRIDX_T *      pcl__idxptr;
	UD *                pud__bufptr;

	SI                  si___idx;

	UI                  ui___i;
	UI                  ui___j;

	// Enough room for the frm data ?

	if ((pu16max - pu16dst) < 8)
		{
		ErrorCode = ERROR_XVERT_FRMFULL;
		sprintf(ErrorMessage,
			"(XVERT) Frm buffer full during XvertBitmapToSprFrm.\n");
		goto errorExit;
		}

	pu16max = pu16dst + 8;

	// Convert the bitmap into a sprite.

	fl___blank  = NO;
	fl___repeat = NO;

	pbf__sprdst = pdspri->pbf__sprsBufCur;
	pbf__sprend = pdspri->pbf__sprsBufEnd;

	pbf__sprend = XvertBitmapToSprite(
		pdbiti, sibmx, sibmy, uibmw, uibmh, pbf__sprdst, pbf__sprend);

	if (pbf__sprend == NULL)
		{
		goto errorExit;
		}

	// Initialize the sprite's index entry.

	pcl__spridx = &(pdspri->acl__sprsBufIndx[pdspri->ui___sprsCount]);

	pcl__spridx->ud___spriKeyVal = 0;

	// Is it a blank sprite ?

	if (pbf__sprend == pbf__sprdst)

		{
		// Initialize blank sprite frame.

		pcl__spridx->pbf__spriBufPtr  =  NULL;
		pcl__spridx->ul___spriBufLen  =  0;
		pcl__spridx->si___spriXOffset =  0;
		pcl__spridx->si___spriYOffset =  0;
		pcl__spridx->ui___spriWidth   =  0;
		pcl__spridx->ui___spriHeight  =  0;
		pcl__spridx->ui___spriPalette =  0;
		pcl__spridx->si___spriNumber  = -1;

		pu16dst[0] = 0;
		pu16dst[1] = 0;
		pu16dst[2] = 0;
		pu16dst[3] = 0;
		pu16dst[4] = 0;
		pu16dst[5] = 0;
		pu16dst[6] = 0;
		pu16dst[7] = 0;

		fl___blank = YES;
		}

	else

		{
		// Initialize non-blank sprite frame.

		pcl__spridx->pbf__spriBufPtr = pbf__sprdst;
		pcl__spridx->ul___spriBufLen = pbf__sprend - pbf__sprdst;

		if (uiSprDirection == BOTTOMTOTOP) sibmy = sibmy + uibmh - 1;

		pcl__spridx->si___spriXOffset = sibmx;
		pcl__spridx->si___spriYOffset = sibmy;
		pcl__spridx->ui___spriWidth   = uibmw;
		pcl__spridx->ui___spriHeight  = uibmh;
		pcl__spridx->si___spriNumber  = pdspri->ui___sprsCount;
		pcl__spridx->ui___spriPalette = uiSprPalette;

		pu16dst[0] = 0;
		pu16dst[1] = 0;
		pu16dst[2] = 0;
		pu16dst[3] = 0;
		pu16dst[4] = 0;
		pu16dst[5] = 0;
		pu16dst[6] = 0;

		// Calculate the new sprite's key value.

		pud__keyptr = (UD *) pcl__spridx->pbf__spriBufPtr;
		ui___buflen =        pcl__spridx->ul___spriBufLen;
		ud___keyval = 0;
		for (ui___i = (ui___buflen >> 2); ui___i != 0; ui___i -= 1)
			{
			ud___keyval ^= *pud__keyptr++;
			ud___keyval += 1;
			}
		pcl__spridx->ud___spriKeyVal = ud___keyval;

		// Check for a repeated sprite definition ?

		if (flRemoveSprRepeats == YES)
			{
			// Check if the sprite already exists in the sprite set.

			pcl__idxptr = pdspri->acl__sprsBufIndx;

			for (ui___i = pdspri->ui___sprsCount; ui___i != 0; ui___i -= 1)
				{
				if (ud___keyval == pcl__idxptr->ud___spriKeyVal)
					{
					if (ui___buflen == pcl__idxptr->ul___spriBufLen)
						{
						pud__keyptr = (UD *) pcl__spridx->pbf__spriBufPtr;
						pud__bufptr = (UD *) pcl__idxptr->pbf__spriBufPtr;
						for (ui___j = (ui___buflen >> 2); ui___j != 0; ui___j -= 1)
							{
							if (*pud__keyptr++ != *pud__bufptr++) break;
							}
						if (ui___j == 0)
							{
							pcl__spridx->pbf__spriBufPtr = pcl__idxptr->pbf__spriBufPtr;
							pcl__spridx->ul___spriBufLen = 0;
							pcl__spridx->si___spriNumber = pdspri->ui___sprsCount - ui___i;
							pbf__sprend = pbf__sprdst;
							fl___repeat = YES;
							break;
							}
						}
					}
				pcl__idxptr += 1;
				}
			}
		}

	// Update the sprite data buffer pointer.

	pdspri->pbf__sprsBufCur = pbf__sprend;

	// Is this a duplicate or blank index that should be removed ?

	if ((flRemoveBlankSprs == YES) &&
		(pcl__spridx->pbf__spriBufPtr == NULL))
		{
		si___idx = -1;
		}
	else
		{
		// Check for a repeated sprite index ?

		si___idx = pdspri->ui___sprsCount++;

		if (flRemoveIdxRepeats == YES)
			{
			// Check if the sprite already exists in the sprite set.

			pcl__idxptr = pdspri->acl__sprsBufIndx;

			for (ui___i = si___idx; ui___i != 0; ui___i -= 1)
				{
				if (memcmp(pcl__idxptr, pcl__spridx, sizeof(DATASPRIDX_T)) == 0)
					{
					pdspri->ui___sprsCount -= 1;
					si___idx               -= ui___i;
					fl___repeat = YES;
					break;
					}
				pcl__idxptr += 1;
				}
			}
		}

	// Save the resulting index in the frame data, and display it.

	pu16dst[7] = si___idx;

	#if 1
	if (fl___blank == YES) {
		printf("sprnumber=0x%04X (blank)\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	else if (fl___repeat == YES) {
		printf("sprnumber=0x%04X (repeat of 0x%04X)\n\n",
			(UI) (si___idx & 0xFFFFu),
			(UI) pcl__spridx->si___spriNumber);
		}
	else {
		printf("sprnumber=0x%04X\n\n",
			(UI) (si___idx & 0xFFFFu));
		}
	#endif

	// Print out the frame position and number.

	#if 0
		printf("frmxoff=0x%04hX frmyoff=0x%04hX sprpalette=0x%04hX sprnumber=0x%04hX\n\n",
			(US) pu16dst[0], (US) pu16dst[1], (US) pu16dst[2], (US) pu16dst[7]);
	#endif

	// Return with address of next free frm buffer space.

	return (pu16max);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * XvertBitmapToFntFrm ()                                                 *
// **************************************************************************
// * Convert the bitmap into a font                                         *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         DATAFNTSET_T *  Ptr to fntset that will receive new fnt data   *
// *         UW *            Ptr to buffer that will receive new frm data   *
// *         UW *            End of buffer that will receive new frm data   *
// *                                                                        *
// * Output  UW *            Updated ptr to frm buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The frm data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           UW map's palette number                                      *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW reserved (0)                                              *
// *           UW map number                                                *
// *           }                                                            *
// **************************************************************************

global	UW *                XvertBitmapToFntFrm     (
								DATABITMAP_T *      pdbiti,
								DATAFNTSET_T *      pdfnti,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	// Enough room for the frm data ?

	if ((pu16max - pu16dst) < 8)
		{
		ErrorCode = ERROR_XVERT_FRMFULL;
		sprintf(ErrorMessage,
			"(XVERT) Frm buffer full during XvertBitmapToFntFrm.\n");
		goto errorExit;
		}

	// Save a blank (dummy) frm.

	pu16dst[0] = 0;
	pu16dst[1] = 0;
	pu16dst[2] = 0;
	pu16dst[3] = 0;
	pu16dst[4] = 0;
	pu16dst[5] = 0;
	pu16dst[6] = 0;
	pu16dst[7] = 0;
	pu16max    = pu16dst + 8;

	// Convert the bitmap into a sprite.

	if (BitmapToFont(pdbiti, pdfnti) < 0) {
		goto errorExit;
		}

	// Return with address of next free frm buffer space.

	return (pu16max);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * XvertBitmapToChrmap ()                                                 *
// **************************************************************************
// * Convert the box within the bitmap into a character or sprite map       *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         DATACHRSET_T *  Ptr to chrset that will receive new chr data   *
// *         UW *            Ptr to buffer that will receive new map data   *
// *         UW *            End of buffer that will receive new map data   *
// *                                                                        *
// * Output  UW *            Updated ptr to map buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    It is assumed that the bitmap will have at least one chr worth *
// *         of blank space around the conversion rectangle.                *
// *                                                                        *
// *         The space at the end of the chrset is used as buffer space for *
// *         the conversion.                                                *
// *                                                                        *
// *         The map data has the following format ...                      *
// *         	{                                                           *
// *         	SW X offset from origin to top left of chrmap               *
// *         	SW Y offset from origin to top left of chrmap               *
// *         	SW X offset from top left of chrmap to top left of data     *
// *         	SW Y offset from top left of chrmap to top left of data     *
// *         	UW data width in pixels                                     *
// *         	UW data height in pixels                                    *
// *         	UW palette number and flags                                 *
// *         	UW number of map sections                                   *
// *         		{                                                       *
// *         		UW section X offset from top left of chrmap             *
// *         		UW section Y offset from top left of chrmap             *
// *         		UW section width in characters                          *
// *         		UW section height in characters                         *
// *         			{                                                   *
// *         			UW chr number or UD chr number                      *
// *         			}                                                   *
// *         		}                                                       *
// *         	}                                                           *
// *                                                                        *
// *         The data position and size stored are enlarged/shrunk to the   *
// *         percentage of their original size given by ui___MapBoxFactor.  *
// **************************************************************************

global	UW *                XvertBitmapToChrmap     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATACHRSET_T *      pdchri,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	XVERTINFOBLOCK		xib;

	UW *                pu16end;

	UI                  uii;
	SI                  sij;

	SI                  six;
	SI                  siy;
	UI                  uiw;
	UI                  uih;

	// Print out destination and limit.

	#if 0
	printf("pu16dst=%08lX pu16max=%08lX\n",
		(UL) pu16dst, (UL) pu16max);
	#endif

	// Conversion rectangle legal ?

	if (((sibmx - pdbiti->si___bmXTopLeft) < 0) ||
			((sibmx - pdbiti->si___bmXTopLeft + uibmw) > pdbiti->ui___bmW) ||
			((sibmy - pdbiti->si___bmYTopLeft) < 0) ||
			((sibmy - pdbiti->si___bmYTopLeft + uibmh) > pdbiti->ui___bmH))
		{
		ErrorCode = ERROR_XVERT_ILLEGAL;
		sprintf(ErrorMessage,
			"(XVERT) Conversion box overruns bitmap in XvertBitmapToChrmap.\n");
		goto errorExit;
		}

	// Initialize the XVERTINFOBLOCK to put the new chr data after the end
	// of the current chr data.

	xib.o.dciold = *pdchri;
	xib.n.dcinew = *pdchri;

	xib.n.dcinew.ui___chrCount = 0;

	xib.n.dcinew.ui___chrMaximum = xib.o.dciold.ui___chrMaximum -
		xib.o.dciold.ui___chrCount;

	xib.n.dcinew.pud__chrBufKeys = xib.o.dciold.pud__chrBufKeys +
		xib.o.dciold.ui___chrCount;

	xib.n.dcinew.pud__chrBufData = xib.o.dciold.pud__chrBufData +
		(xib.o.dciold.ui___chrCount << xib.o.dciold.ui___chrU32Shift);

	uii = (xib.n.dcinew.pud__chrBufEnd - xib.n.dcinew.pud__chrBufData) >>
		xib.n.dcinew.ui___chrU32Shift;

	if (xib.n.dcinew.ui___chrMaximum > uii) {
		xib.n.dcinew.ui___chrMaximum = uii;
		}

	// Only convert the bitmap if it has width and height.

	if ((uibmw != 0) && (uibmh != 0))

		// Bitmap has width and height, so continue with the conversion.

		{

		// Now decide whether to do a simple map conversion or a complex spr
		// conversion.

		if (uiMapType == MAP_SPR)
			{
			// If converting the bitmap to SPR data.
			if ((pu16end = BitmapToSprmap(&xib, pdbiti, sibmx, sibmy, uibmw, uibmh,
				pu16dst, pu16max)) == NULL) {
				goto errorExit;
				}
			}
		else
			{
			// If converting the bitmap to CHR or BLK data (note that we only convert
			// as far as chr data in this routine).
			if ((pu16end = BitmapToChrmap(&xib, pdbiti, sibmx, sibmy, uibmw, uibmh,
				pu16dst, pu16max)) == NULL) {
				goto errorExit;
				}
			}

		// Update the global character set.

		pdchri->ui___chrCount = pdchri->ui___chrCount + xib.n.dcinew.ui___chrCount;

		// Enlarge/Shrink the stored collision box size.

		uiw = (((UI) pu16dst[4]) * uiMapBoxFactor) / 100;
		uih = (((UI) pu16dst[5]) * uiMapBoxFactor) / 100;

		sij = ((SI) (((UI) pu16dst[4]) - uiw)) >> 1;
		six = ((SI) ((SW *) pu16dst)[2]) + sij;

		sij = ((SI) (((UI) pu16dst[5]) - uih)) >> 1;
		siy = ((SI) ((SW *) pu16dst)[3]) + sij;

		pu16dst[2] = six;
		pu16dst[3] = siy;
		pu16dst[4] = uiw;
		pu16dst[5] = uih;

		// Conversion complete.
		}

	else

		// Bitmap has no width or height, so return with a dummy map.

		{
		// Enough room for a dummy map ?

		if ((pu16max - pu16dst) < 8)
			{
			ErrorCode = ERROR_XVERT_MAPFULL;
			sprintf(ErrorMessage,
				"(XVERT) Map buffer full during XvertBitmapToChrmap.\n");
			goto errorExit;
			}

		// Create a blank map header giving a map with zero width, height, and
		// sections.

		memset(pu16dst, 0, (8 * sizeof(UW)));

		pu16end = pu16dst + 8;
		}

	// Print out the chr map.

	#if 0
		UW *                pu16tmp;
		UI                  uisprw,uisprh;
		UI                  uij,uik;

		pu16tmp = pu16dst;

		printf("%08lX  ", (UL) pu16tmp);

		printf("chrmap hotX=0x%04X hotY=0x%04X\n",
			(SI) (pu16tmp[0]),
			(SI) (pu16tmp[1]));

		printf("%08lX  ", (UL) pu16tmp);

		printf("chrmap boxX=0x%04X boxY=0x%04X boxW=0x%04X boxH=0x%04X\n",
			(SI) (pu16tmp[2]),
			(SI) (pu16tmp[3]),
			(UI) (pu16tmp[4]),
			(UI) (pu16tmp[5]));

		printf("%08lX  ", (UL) pu16tmp);

		printf("chrmap mapP=0x%04X mapN=0x%04X\n",
			(UI) (pu16tmp[6]),
			(UI) (pu16tmp[7]));

		uii = pu16tmp[7];

		pu16tmp = pu16tmp + 8;

		while (uii-- != 0)
			{
			printf("%08lX  ", (UL) pu16tmp);

			printf(" chrmap sprX=0x%04X sprY=0x%04X sprW=0x%04X sprH=0x%04X\n",
				(UI) (pu16tmp[0]),
				(UI) (pu16tmp[1]),
				(UI) (pu16tmp[2]),
				(UI) (pu16tmp[3]));
			uisprw = pu16tmp[2];
			uisprh = pu16tmp[3];

			pu16tmp += 4;

			for (uij = uisprh; uij != 0; uij -= 1)
				{
				printf("%08lX  ", (UL) pu16tmp);
				printf(" ");
				for (uik = uisprw; uik != 0; uik -= 1)
					{
					printf(" 0x%04X",
						(UI) (*(pu16tmp++)));
					}
				printf("\n");
				}
			}

		printf("\n");

		fflush(stdout);
	#endif

	// Return with success.

	return (pu16end);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * XvertChrmapToBlkmap ()                                                 *
// **************************************************************************
// * Convert the chrmap into a blkmap of equivalent size                    *
// **************************************************************************
// * Inputs  UW *            Ptr to src map to convert                      *
// *         DATABLKSET_T *  Ptr to blkset that will receive new blk data   *
// *         UW *            Ptr to buffer that will receive new map data   *
// *         UW *            End of buffer that will receive new map data   *
// *                                                                        *
// * Output  UW *            Updated ptr to map buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The src and dst map buffers must not overlap.                  *
// *                                                                        *
// *         The space at the end of the blkset is used as buffer space for *
// *         the conversion.                                                *
// *                                                                        *
// *         The map data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW palette number and flags                                  *
// *           UW number of map sections                                    *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               either UW character/block data                           *
// *               or     UD character/block data                           *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

global	UW *                XvertChrmapToBlkmap    (
								UW *                pu16src,
								DATABLKSET_T *      pdblki,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	XVERTINFOBLOCK		xib;

	UW *                pu16end;
	UW *                pu16row;
	UW *                pu16col;

	UI                  uiwchr;
	UI                  uihchr;
	UI                  uiwblk;
	UI                  uihblk;
	UI                  uixovr;
	UI                  uiyovr;

	UI                  uisections;

	UI                  uii;
	UI                  uij;

	// Print out destination and limit.

	#if 0
	printf("pu16dst=%08lX pu16max=%08lX\n",
		(UL) pu16dst, (UL) pu16max);
	#endif

	// Initialize the XVERTINFOBLOCK to put the new blk data after the end
	// of the current blk data.

	xib.o.dbiold = *pdblki;
	xib.n.dbinew = *pdblki;

	xib.n.dbinew.ui___blkCount = 0;

	xib.n.dbinew.ui___blkMaximum = xib.o.dbiold.ui___blkMaximum -
		xib.o.dbiold.ui___blkCount;

	xib.n.dbinew.puw__blkBufKeys = xib.o.dbiold.puw__blkBufKeys +
		xib.o.dbiold.ui___blkCount;

	xib.n.dbinew.puw__blkBufData = xib.o.dbiold.puw__blkBufData +
		(xib.o.dbiold.ui___blkCount * xib.o.dbiold.ui___blkChrSize);

	uii = (xib.n.dbinew.puw__blkBufEnd - xib.n.dbinew.puw__blkBufData) /
		xib.n.dbinew.ui___blkChrSize;

	if (xib.n.dbinew.ui___blkMaximum > uii) {
		xib.n.dbinew.ui___blkMaximum = uii;
		}

	// Copy the map header to the destination buffer.

	pu16end = pu16dst;

	pu16end[0] = pu16src[0];
	pu16end[1] = pu16src[1];
	pu16end[2] = pu16src[2];
	pu16end[3] = pu16src[3];
	pu16end[4] = pu16src[4];
	pu16end[5] = pu16src[5];
	pu16end[6] = pu16src[6];

	pu16end[7] = pu16src[7];
	uisections = pu16src[7];

	pu16src += 8;
	pu16end += 8;

	// Convert each chrmap section into a blkmap.

	while (uisections-- != 0)

		{

		// Copy the section header to the destination buffer, changing the chr
		// width and height to blk width and height.

		pu16end[0] = pu16src[0];
		pu16end[1] = pu16src[1];

		uiwchr     = pu16src[2];
		uiwblk     = (uiwchr + xib.n.dbinew.ui___blkXChrSize - 1) /
									xib.n.dbinew.ui___blkXChrSize;
		uixovr     = (uiwblk * xib.n.dbinew.ui___blkXChrSize) - uiwchr;
		pu16end[2] = uiwblk;

		uihchr     = pu16src[3];
		uihblk     = (uihchr + xib.n.dbinew.ui___blkYChrSize - 1) /
									xib.n.dbinew.ui___blkYChrSize;
		uiyovr     = (uihblk * xib.n.dbinew.ui___blkYChrSize) - uihchr;
		pu16end[3] = uihblk;

		// Does this section have data ?

		if ((uiwchr == 0) || (uihchr == 0))

			// This chrmap section is blank.

			{
			// Ensure that the blk width and height are zero.

			pu16end[2] = 0;
			pu16end[3] = 0;

			pu16src += 4;
			pu16end += 4;
			}

		else

			// This chrmap section is not blank, continue with the conversion.

			{
			// Detect arithmetic overflow when calculating blkmap size.

			if ((uiwblk == 0) || (uihblk == 0))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"(XVERT) Arithmetic overflow calculating blkmap size.\n");
				goto errorExit;
				}

			// Is there enough room in the destination buffer for the chr map ?

			if ((((ptrdiff_t) (uiwchr + uixovr)) *
				   ((ptrdiff_t) (uihchr + uiyovr)) ) > (pu16max - pu16end))
				{
				ErrorCode = ERROR_XVERT_MAPFULL;
				sprintf(ErrorMessage,
					"(XVERT) Not enough room in map buffer to create blkmap.\n");
				goto errorExit;
				}

			// Copy the map to the destination buffer, expanding it to an integer
			// blk width and height.

			pu16src += 4;
			pu16end += 4;

			pu16col = pu16end;

			for (uii = uihchr; uii != 0; uii = uii - 1)
				{
				for (uij = uiwchr; uij != 0; uij = uij - 1)
					{
					*pu16col++ = *pu16src++;
					}
				for (uij = uixovr; uij != 0; uij = uij - 1)
					{
					*pu16col++ = 0;
					}
				}

			for (uii = (uiyovr * (uiwchr + uixovr)); uii != 0; uii = uii - 1)
				{
				*pu16col++ = 0;
				}

			// Now convert the chrmap to a blkmap.

			uiwchr = uiwchr + uixovr;
			uihchr = uihchr + uiyovr;

			uixovr = pdblki->ui___blkXChrSize;
			uiyovr = pdblki->ui___blkYChrSize * uiwchr;

			pu16row = pu16end;

			for (uii = uihblk; uii != 0; uii = uii - 1)
				{
				pu16col = pu16row;

				for (uij = uiwblk; uij != 0; uij = uij - 1)
					{
					// Is there room for a new blk ?

					if ((xib.n.dbinew.ui___blkCount + 1) > xib.n.dbinew.ui___blkMaximum)
						{
						ErrorCode = ERROR_XVERT_BLKFULL;
						sprintf(ErrorMessage,
							"(XVERT) Blk buffer full during XvertChrmapToBlkmap.\n");
						goto errorExit;
						}

					// Convert this blk.

					*pu16end++ = ChrToBlk(&xib, pu16col, uiwchr);

					// Update ptr to next blk in this row.

					pu16col += uixovr;
					}

				// Update ptr to next row of blks.

				pu16row += uiyovr;
				}

			// End of non-blank map section conversion.
			}

		// End of this map section.
		}

	// Update the global block set.

	pdblki->ui___blkCount = pdblki->ui___blkCount + xib.n.dbinew.ui___blkCount;

	// Print out the blk map.

	#if 0

		UW *							pu16tmp;
		UI								uisprw,uisprh;
		UI								uik;

		pu16tmp = pu16dst;

		printf("%08lX  ", (UL) pu16tmp);

		printf("blkmap hotX=0x%04X hotY=0x%04X\n",
			(SI) (pu16tmp[0]),
			(SI) (pu16tmp[1]));

		printf("%08lX  ", (UL) pu16tmp);

		printf("blkmap boxX=0x%04X boxY=0x%04X boxW=0x%04X boxH=0x%04X\n",
			(SI) (pu16tmp[2]),
			(SI) (pu16tmp[3]),
			(UI) (pu16tmp[4]),
			(UI) (pu16tmp[5]));

		printf("%08lX  ", (UL) pu16tmp);

		printf("blkmap mapP=0x%04X mapN=0x%04X\n",
			(UI) (pu16tmp[6]),
			(UI) (pu16tmp[7]));

		uii = pu16tmp[7];

		pu16tmp = pu16tmp + 8;

		while (uii-- != 0)
			{
			printf("%08lX  ", (UL) pu16tmp);

			printf(" blkmap sprX=0x%04X sprY=0x%04X sprW=0x%04X sprH=0x%04X\n",
				(UI) (pu16tmp[0]),
				(UI) (pu16tmp[1]),
				(UI) (pu16tmp[2]),
				(UI) (pu16tmp[3]));

			uisprw = pu16tmp[2];
			uisprh = pu16tmp[3];

			pu16tmp += 4;

			for (uij = uisprh; uij != 0; uij -= 1)
				{
				printf("%08lX  ", (UL) pu16tmp);
				printf(" ");
				for (uik = uisprw; uik != 0; uik -= 1)
					{
					printf(" 0x%04X",
						(UI) (*pu16tmp++));
					}
				printf("\n");
				}
			}
		printf("\n");

		fflush(stdout);
	#endif

	// Return with ptr to next free space.

	return (pu16end);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);
	}



// **************************************************************************
// * XvertBitmapToSprite ()                                                 *
// **************************************************************************
// * Convert the box within the bitmap into a sprite                        *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         UW *            Ptr to buffer that will receive new spr data   *
// *         UW *            End of buffer that will receive new spr data   *
// *                                                                        *
// * Output  UW *            Updated ptr to spr buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// **************************************************************************

global	BUFFER *            XvertBitmapToSprite     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max)

	{

	// Local variables.

	BUFFER *            pbf__end;

	// Print out destination and limit.

	#if 0
	printf("pu32dst=%08lX pu32max=%08lX\n",
		(UL) pu32dst, (UL) pu32max);
	#endif

	// Conversion rectangle legal ?

	if (((sibmx - pdbiti->si___bmXTopLeft) < 0) ||
		((sibmx - pdbiti->si___bmXTopLeft + uibmw) > pdbiti->ui___bmW) ||
		((sibmy - pdbiti->si___bmYTopLeft) < 0) ||
		((sibmy - pdbiti->si___bmYTopLeft + uibmh) > pdbiti->ui___bmH))
		{
		ErrorCode = ERROR_XVERT_ILLEGAL;
		sprintf(ErrorMessage,
			"Conversion rectangle exceeds bitmap's boundaries.\n"
			"(XVERT, XvertBitmapToSprite)\n");
		goto errorExit;
		}

	// Now choose our conversion routine depending upon the machine.
	// conversion.

	switch (uiMachineType)
		{
		case MACHINE_3DO:
			{
			if ((pbf__end = BitmapTo3DOSpr(
				pdbiti,
				sibmx,
				sibmy,
				uibmw,
				uibmh,
				pbf__dst,
				pbf__max)) == NULL) goto errorExit;
			break;
			}
		case MACHINE_SAT:
			{
			if ((pbf__end = BitmapToSATSpr(
				pdbiti,
				sibmx,
				sibmy,
				uibmw,
				uibmh,
				pbf__dst,
				pbf__max)) == NULL) goto errorExit;
			break;
			}
		case MACHINE_PSX:
			{
			if ((pbf__end = BitmapToPSXSpr(
				pdbiti,
				sibmx,
				sibmy,
				uibmw,
				uibmh,
				pbf__dst,
				pbf__max)) == NULL) goto errorExit;
			break;
			}
		case MACHINE_IBM:
			{
			if ((pbf__end = BitmapToIBMSpr(
				pdbiti,
				sibmx,
				sibmy,
				uibmw,
				uibmh,
				pbf__dst,
				pbf__max)) == NULL) goto errorExit;
			break;
			}
		case MACHINE_N64:
			{
			if ((pbf__end = BitmapToN64Spr(
				pdbiti,
				sibmx,
				sibmy,
				uibmw,
				uibmh,
				pbf__dst,
				pbf__max)) == NULL) goto errorExit;
			break;
			}
		default: {
			ErrorCode = ERROR_XVERT_UNKNOWN;
			sprintf(ErrorMessage,
				"Don't know how to create bitmapped sprites for this machine type.\n"
				"(XVERT, XvertBitmapToSprite)\n");
			goto errorExit;
			}
		}

	// Return with success.

	return (pbf__end);

	// Error handlers (reached via the dreaded goto).

	errorExit:

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
// * BitmapToChrmap ()                                                      *
// **************************************************************************
// * Turn the bitmap into a single large character map                      *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         UW *            Ptr to buffer that will receive new map data   *
// *         UW *            End of buffer that will receive new map data   *
// *                                                                        *
// * Output  UW *            Updated ptr to map buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// *                                                                        *
// *         The map data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW flag bits (palette number removed)                        *
// *           UW number of map sections (1 in this case)                   *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               either UW character/block data                           *
// *               or     UD character/block data                           *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

static	UW *                BitmapToChrmap          (
								XVERTINFOBLOCK *    pxib,
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	UW *                pu16end;

	UB *                pu08src;
	size_t              ulwsrc;

	UI                  uiwpxl;
	UI                  uiwchr;
	UI                  uihpxl;
	UI                  uihchr;

	// Bomb out if not 256 colour data.

	if (pdbiti->ui___bmB != 8) {
		ErrorCode = ERROR_XVERT_UNKNOWN;
		sprintf(ErrorMessage,
			"Don't know how to convert %u bit per pixel bitmap data.\n"
			"(XVERT, BitmapToChrmap)\n",
			(UI) pdbiti->ui___bmB);
		goto errorExit;
		}

	// Clear the overall map palette (needed as a default since BitmapNToChrmap
	// assumes an initial zero value).

	pxib->uimapPalette = 0;

	// Calculate bitmap's size in chrs.

	uiwchr = (uibmw + (pxib->n.dcinew.ui___chrXPxlSize - 1)) >>
		pxib->n.dcinew.ui___chrXPxlShift;

	uiwpxl = uiwchr << pxib->n.dcinew.ui___chrXPxlShift;

	uihchr = (uibmh + (pxib->n.dcinew.ui___chrYPxlSize - 1)) >>
		pxib->n.dcinew.ui___chrYPxlShift;

	uihpxl = uihchr << pxib->n.dcinew.ui___chrYPxlShift;

	// Check that there is enough room to save this map.

	if ((int) ((uiwchr * uihchr) + 12) > (pu16max - pu16dst)) {
		ErrorCode = ERROR_XVERT_MAPFULL;
		sprintf(ErrorMessage,
			"Not enough room, map buffer full.\n"
			"(XVERT, BitmapToChrmap)\n");
		goto errorExit;
		}

	// Save the map's size and position, and get the map data pointer.

	pu16dst[0] = sibmx;
	pu16dst[1] = sibmy;
	pu16dst[2] = 0;
	pu16dst[3] = 0;
	pu16dst[4] = uibmw;
	pu16dst[5] = uibmh;

	pu16end = pu16dst + 8;

	// Get the source line width and data pointer.

	sibmx  -= pdbiti->si___bmXTopLeft;
	sibmy  -= pdbiti->si___bmYTopLeft;
	ulwsrc  = pdbiti->si___bmLineSize;

	pu08src = pdbiti->pub__bmBitmap + (ulwsrc * sibmy) + sibmx;

	// Save the map size followed by the map data.

	pu16end[0] = 0;
	pu16end[1] = 0;
	pu16end[2] = uiwchr;
	pu16end[3] = uihchr;

	pu16end = pu16end + 4;

	if ((pu16end = PxlToChrmap(pxib, pu08src, ulwsrc, uiwchr, uihchr, uiChrMapOrder, pu16end)) == NULL) {
		goto errorExit;
		}

	// Fill in the map palette and number of sections.

	pu16dst[6] = (pxib->uimapPalette & 0x00FFu);
	pu16dst[7] = 1;

	// Display number of new characters.

	#if 1
		printf("0x%04X new chrs defined in 1 section, ",
			(UI) pxib->n.dcinew.ui___chrCount);
	#else
		printf("0x%04X new chrs defined in 1 section\n",
			(UI) pxib->n.dcinew.ui___chrCount);
	#endif

	// Return with success code.

	return (pu16end);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * BitmapToSprmap ()                                                      *
// **************************************************************************
// * Turn the bitmap into a number of small chracter maps                   *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X of box to convert                            *
// *         SI              Y of box to convert                            *
// *         UI              W of box to convert                            *
// *         UI              H of box to convert                            *
// *         UW *            Ptr to buffer that will receive new map data   *
// *         UW *            End of buffer that will receive new map data   *
// *                                                                        *
// * Output  UW *            Updated ptr to map buffer, or NULL if failed   *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// *                                                                        *
// *         If MACHINE_GEN then sprites are any size up to 4x4.            *
// *         If MACHINE_SFX then sprites are sizes 1x1 and 2x2.             *
// *                                                                        *
// *         The map data has the following format ...                      *
// *           {                                                            *
// *           SW X offset from origin to top left of chrmap                *
// *           SW Y offset from origin to top left of chrmap                *
// *           SW X offset from top left of chrmap to top left of data      *
// *           SW Y offset from top left of chrmap to top left of data      *
// *           UW data width in pixels                                      *
// *           UW data height in pixels                                     *
// *           UW flag bits (palette number removed)                        *
// *           UW number of map sections                                    *
// *             {                                                          *
// *             UW section X offset from top left of chrmap                *
// *             UW section Y offset from top left of chrmap                *
// *             UW section width in characters                             *
// *             UW section height in characters                            *
// *               {                                                        *
// *               either UW character/block data                           *
// *               or     UD character/block data                           *
// *               }                                                        *
// *             }                                                          *
// *           }                                                            *
// **************************************************************************

static	UW   auw__sTmpSprMaps [2][8192];
static	UD   aud__sTmpSprKeys [2][2048];
static	UD   aud__sTmpSprData [2][2048*16];

static	UW * (*apFuncSprGEN[])(XVERTINFOBLOCK *, DATABITMAP_T *, SI, SI, UI, UI, UW *, UW *) =
	{
	BitmapToGENSprLRTB,
	BitmapToGENSprTBLR,
	BitmapToGENSprRLBT,
	BitmapToGENSprBTRL,
	NULL
	};

static	UW * (*apFuncSprSFX[])(XVERTINFOBLOCK *, DATABITMAP_T *, SI, SI, UI, UI, UW *, UW *) =
	{
	BitmapToSFXSprLRTB,
	BitmapToSFXSprTBLR,
	BitmapToSFXSprRLBT,
	BitmapToSFXSprBTRL,
	NULL
	};

static	UW * (*apFuncSprGMB[])(XVERTINFOBLOCK *, DATABITMAP_T *, SI, SI, UI, UI, UW *, UW *) =
	{
	BitmapToGMBSprLRTB,
	BitmapToGMBSprTBLR,
	BitmapToGMBSprRLBT,
	BitmapToGMBSprBTRL,
	NULL
	};

static	UW *                BitmapToSprmap          (
								XVERTINFOBLOCK *    pxib,
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								UW *                pu16dst,
								UW *                pu16max)

	{

	// Local variables.

	UI                  uisprcount;

	UI                  uii;
	UI                  uij;
	UI                  uik;

	UW *                pu16sprdst;
	UW *                pu16sprend;
	UW *                pu16sprtmp;

	UW *                pu16mapdst;
	UW *                pu16mapend;

	UW *                (**ppfuncspr)(XVERTINFOBLOCK *, DATABITMAP_T *, SI, SI, UI, UI, UW *, UW *);

	UW *                apu16dst[2];
	UW *                apu16end[2];

	XVERTINFOBLOCK      axib[2];

	// Bomb out if not 256 colour data.

	if (pdbiti->ui___bmB != 8)
		{
		ErrorCode = ERROR_XVERT_UNKNOWN;
		sprintf(ErrorMessage,
			"Don't know how to convert %u bit per pixel bitmap data.\n"
			"(XVERT, BitmapToSprmap)\n",
			(UI) pdbiti->ui___bmB);
		goto errorExit;
		}

	// Select conversion algorithms based on the destination machine.

	switch (uiMachineType)
		{
		case MACHINE_GEN:
			{
			ppfuncspr = apFuncSprGEN;

			break;
			}
		case MACHINE_SFX:
			{
			ppfuncspr = apFuncSprSFX;

			break;
			}
		case MACHINE_GMB:
			{
			ppfuncspr = apFuncSprGMB;

			break;
			}
		default:
			{
			ErrorCode = ERROR_XVERT_UNKNOWN;
			sprintf(ErrorMessage,
				"(XVERT) Target machine doesn't support sprmap conversions.\n");
			goto errorExit;
			}
		}

	// Initialize temporary workspace.

	for (uii = 0; uii != 2; uii += 1)
		{
		axib[uii] = *pxib;
		axib[uii].n.dcinew                 = axib[uii].o.dciold;
		axib[uii].n.dcinew.ui___chrCount   = 0;
		axib[uii].n.dcinew.ui___chrMaximum = 2048;
		axib[uii].n.dcinew.pud__chrBufKeys = &aud__sTmpSprKeys[uii][0];
		axib[uii].n.dcinew.pud__chrBufData = &aud__sTmpSprData[uii][0];
		axib[uii].n.dcinew.pud__chrBufEnd  = axib[uii].n.dcinew.pud__chrBufData +
			(axib[uii].n.dcinew.ui___chrMaximum << axib[uii].n.dcinew.ui___chrU32Shift);

		apu16dst[uii] = &auw__sTmpSprMaps[uii][0];
		}

	// Try first conversion algorithm.

	uii = 0;
	uij = 1;

	if ((apu16end[uii] = (*(*ppfuncspr++))(
		&axib[uii], pdbiti, sibmx, sibmy, uibmw, uibmh, apu16dst[uii], apu16dst[uii]+8192)) == NULL) {
		goto errorExit;
		}

	// Try subsequent conversion algorithms.

	if (flSprLockYGrid == NO)
		{
		while (*ppfuncspr != NULL)
			{
			// Initialize conversion buffer in case previously altered.

			axib[uij] = *pxib;
			axib[uij].n.dcinew                 = axib[uij].o.dciold;
			axib[uij].n.dcinew.ui___chrCount   = 0;
			axib[uij].n.dcinew.ui___chrMaximum = 1024;
			axib[uij].n.dcinew.pud__chrBufKeys = &aud__sTmpSprKeys[uij][0];
			axib[uij].n.dcinew.pud__chrBufData = &aud__sTmpSprData[uij][0];
			axib[uij].n.dcinew.pud__chrBufEnd  = axib[uii].n.dcinew.pud__chrBufData +
				(axib[uij].n.dcinew.ui___chrMaximum << axib[uij].n.dcinew.ui___chrU32Shift);

			apu16dst[uij] = &auw__sTmpSprMaps[uij][0];

			// Perform the actual conversion.

			if ((apu16end[uij] = (*(*ppfuncspr++))(
				&axib[uij], pdbiti, sibmx, sibmy, uibmw, uibmh, apu16dst[uij], apu16dst[uij]+8192)) == NULL) {
				goto errorExit;
				}

			// Check if this conversion was better than the previous best.

			if (((axib[uij].uisort1  < axib[uii].uisort1)) ||
				((axib[uij].uisort1 == axib[uii].uisort1) && (axib[uij].uisort2 < axib[uii].uisort2)))
				{
				uii ^= 1;
				uij ^= 1;
				}
			}
		}

	// Copy the winning chrs to the global chrset.

	memcpy(pxib->n.dcinew.pud__chrBufKeys,
		axib[uii].n.dcinew.pud__chrBufKeys,
		axib[uii].n.dcinew.ui___chrCount * sizeof(UD));

	memcpy(pxib->n.dcinew.pud__chrBufData,
		axib[uii].n.dcinew.pud__chrBufData,
		axib[uii].n.dcinew.ui___chrCount << axib[uii].n.dcinew.ui___chrBytShift);

	pxib->n.dcinew.ui___chrCount += axib[uii].n.dcinew.ui___chrCount;

	// Copy the winning maps to the global mapset.

	uij = apu16end[uii] - apu16dst[uii];

	memcpy(pu16dst, apu16dst[uii], uij * sizeof(UW));

	pu16sprdst = pu16dst;
	pu16sprend = pu16dst + uij;

	// Sort the sprite map into size order, with the largest sprites
	// first.

	pu16mapdst = pu16sprend;

	if (pu16max < (pu16mapdst + (pu16sprend - pu16sprdst)))
			{
			ErrorCode = ERROR_XVERT_MAPFULL;
			sprintf(ErrorMessage,
				"Ran out of space in the map buffer.\n"
				"(XVERT, BitmapToSprmap)\n");
			goto errorExit;
			}

	uisprcount = pu16sprdst[7];

	pu16mapdst[0] = pu16sprdst[0];
	pu16mapdst[1] = pu16sprdst[1];
	pu16mapdst[2] = pu16sprdst[2];
	pu16mapdst[3] = pu16sprdst[3];
	pu16mapdst[4] = pu16sprdst[4];
	pu16mapdst[5] = pu16sprdst[5];
	pu16mapdst[6] = pu16sprdst[6];
	pu16mapdst[7] = pu16sprdst[7];
	pu16mapdst += 8;
	pu16sprdst += 8;

	uii = 4;

	uij = uisprcount;
	pu16sprtmp  = pu16sprdst;

	while (uij != 0)
		{
		uik = pu16sprtmp[2] * pu16sprtmp[3];
		if (pu16sprtmp[2] >= 4)
			{
			pu16mapdst[0] = pu16sprtmp[0];
			pu16mapdst[1] = pu16sprtmp[1];
			pu16mapdst[2] = pu16sprtmp[2];
			pu16mapdst[3] = pu16sprtmp[3];
			pu16sprtmp += 4;
			pu16mapdst += 4;
			while (uik != 0)
				{
				*pu16mapdst++ = *pu16sprtmp++;
				uik -= 1;
				}
			}
		else
			{
			pu16sprtmp += 4 + uik;
			}
		uij -= 1;
		}

	uii = 3;

	while (uii != 0)
		{
		uij = uisprcount;
		pu16sprtmp  = pu16sprdst;

		while (uij != 0)
			{
			uik = pu16sprtmp[2] * pu16sprtmp[3];
			if (pu16sprtmp[2] == uii)
				{
				pu16mapdst[0] = pu16sprtmp[0];
				pu16mapdst[1] = pu16sprtmp[1];
				pu16mapdst[2] = pu16sprtmp[2];
				pu16mapdst[3] = pu16sprtmp[3];
				pu16sprtmp += 4;
				pu16mapdst += 4;
				while (uik != 0)
					{
					*pu16mapdst++ = *pu16sprtmp++;
					uik -= 1;
					}
				}
			else
				{
				pu16sprtmp += 4 + uik;
				}
			uij -= 1;
			}

		uii -= 1;
		}

	pu16mapend = pu16mapdst;
	pu16mapdst = pu16sprend;

	pu16max = pu16dst + (pu16mapend - pu16mapdst);
	memcpy(pu16dst, pu16mapdst, (pu16mapend - pu16mapdst) * sizeof(UW));

	// pu16max = pu16dst + (pu16sprend - pu16sprdst);
	// memcpy(pu16dst, pu16sprdst, (pu16sprend - pu16sprdst) * sizeof(UW));

	// Display number of new characters.

	#if 1

		printf("0x%04X new chrs defined in %d sections, ",
			(UI) pxib->n.dcinew.ui___chrCount,
			(UI) pu16dst[7]);

	#endif

	// Return with success code.

	return (pu16max);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * PxlToChrmap ()                                                         *
// **************************************************************************
// * Convert the 256 color bitmap data into a character map                 *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         UB *            Ptr to 8bpp bitmap data                        *
// *         UL              Line width offset of bitmap                    *
// *         UI              W of box to convert in chrs                    *
// *         UI              H of box to convert in chrs                    *
// *         UI              ???                                            *
// *         UW *            Ptr to buffer that will receive new map data   *
// *                                                                        *
// * Output  UW *            Updated ptr to map buffer, or NULL if failed   *
// **************************************************************************

global	UW *                PxlToChrmap             (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth,
								UI                  uiwchr,
								UI                  uihchr,
								UI                  uiorder,
								UW *                pu16dst)

	{

	// Local variables.

	UI                  (*pfunc)(XVERTINFOBLOCK *, UB *, UL);

	UB *                pu08tmp;

	UL                  ulcoloffset;
	UL                  ulrowoffset;

	UI                  uicharacter;
	UI                  uipalette;

	UI                  uii;
	UI                  uij;

	// Select the chr conversion routine.

	uii = 0;

	if (pxib->n.dcinew.ui___chrXPxlSize == 8)					// X=8
		{
		if (pxib->n.dcinew.ui___chrYPxlSize == 8)				// X=8 Y=8
			{
			if (pxib->n.dcinew.ui___chrPxlBits == 8)			// X=8 Y=8 B=8
				{
				// Select routine PxlToChr8x8x8, but check that it supports this
				// machine type.

				pfunc = PxlToChr8x8x8;

				if ((uiMachineType == MACHINE_SFX) || (uiMachineType == MACHINE_AGB) ||
					(uiMachineType == MACHINE_SAT)) {
					uii = 1;
					}
				}

			else if (pxib->n.dcinew.ui___chrPxlBits == 4)		// X=8 Y=8 B=4
				{
				// Select routine PxlToChr8x8x4, but check that it supports this
				// machine type.

				pfunc = PxlToChr8x8x4;

				if ((uiMachineType == MACHINE_GEN) || (uiMachineType == MACHINE_SFX) ||
					(uiMachineType == MACHINE_SFX) ||
					(uiMachineType == MACHINE_SAT)) {
					uii = 1;
					}
				}

			else if (pxib->n.dcinew.ui___chrPxlBits == 2)		// X=8 Y=8 B=2
				{
				// Select routine PxlToChr8x8x2, but check that it supports this
				// machine type.

				pfunc = PxlToChr8x8x2;

				if ((uiMachineType == MACHINE_SFX) ||
					(uiMachineType == MACHINE_GMB)) {
					uii = 1;
					}
				}

			}	// End of X=8 Y=8

		}	// End of X=8

	// Abort if we don't know how to convert this data.

	if (uii == 0)
		{
		ErrorCode = ERROR_XVERT_UNKNOWN;

		sprintf(ErrorMessage,
			"Can't convert 256 colour bitmap into %ux%ux%u chr size.\n"
			"(XVERT, PxlToChrmap)\n",
			(UI) pxib->n.dcinew.ui___chrXPxlSize,
			(UI) pxib->n.dcinew.ui___chrYPxlSize,
			(UI) pxib->n.dcinew.ui___chrPxlBits);

		goto errorExit;
		}

	// Calculate next_chr and next_row offsets.

	ulcoloffset =         1L << pxib->n.dcinew.ui___chrXPxlShift;
	ulrowoffset = ulsrcwidth << pxib->n.dcinew.ui___chrYPxlShift;

	// Do we want LRTB or TBLR conversion ?
	//
	// If TBLR then swap horizontal and vertical values.

	if (uiorder == ORDER_TBLR)
		{
		uihchr      ^= uiwchr;
		uiwchr      ^= uihchr;
		uihchr      ^= uiwchr;
		ulcoloffset ^= ulrowoffset;
		ulrowoffset ^= ulcoloffset;
		ulcoloffset ^= ulrowoffset;
		}

	// Do the conversion.

	uipalette = 0;

	for (uii = uihchr; uii != 0; uii = uii - 1)

		{
		// Convert a row of characters.

		pu08tmp = pu08src;

		for (uij = uiwchr; uij != 0; uij = uij - 1)
			{
			// Is there room for a new character ?

			if ((pxib->n.dcinew.ui___chrCount + 4) > pxib->n.dcinew.ui___chrMaximum)
				{
				ErrorCode = ERROR_XVERT_CHRFULL;

				sprintf(ErrorMessage,
					"Not enough room, chr buffer full.\n"
					"(XVERT, PxlToChrmap)\n");

				goto errorExit;
				}

			// Convert the bitmap data into a character.

			uicharacter = (*pfunc)(pxib, pu08tmp, ulsrcwidth);

			// Is this one of the permanent characters ?

			if ((flRmvPermanentChr) && (uicharacter < uiNumPermanentChr))
				{
				uicharacter = 0;
				}
			else
				{
				// Blank character ?

				if (uicharacter != 0)
					{
					// Save this character's palette as the map's palette.

					uipalette = pxib->uichrPalette;
					}

				// Compensate for the permanent characters ?

				if (uiNumPermanentChr != 0)
					{
					uicharacter -= (uiNumPermanentChr - 1);
					}

				// Compensate for the map offset ?

				uicharacter += uiChrMapOffset;

				// Really store the character ?

				if (flStoreChrNumber == NO)
					{
					uicharacter = 0;
					}

				// Convert from simple character number to screen data representation,
				// i.e. include the flip and colour palette bits ?

				if ((flStoreChrPriority == YES) ||
					(flStoreChrFlip     == YES) ||
					(flStoreChrPalette  == YES))
					{
					// Screen data is machine dependant.

					if (uiMachineType == MACHINE_SFX)			// Convert for the Super NES.
						{
						if (uicharacter > 0x03FF)
							{
							ErrorCode = ERROR_XVERT_ILLEGAL;
							sprintf(ErrorMessage,
								"Too many chrs defined to store flip/palette bits.\n"
								"(XVERT, PxlToChrmap, Sfx)\n");
							goto errorExit;
							}

						if (flStoreChrPriority == YES)	uicharacter |= (pxib->uichrPriority << 13);
						if (flStoreChrFlip     == YES)	uicharacter |= (pxib->uichrFlip     << 14);
						if (flStoreChrPalette  == YES)	uicharacter |= (pxib->uichrPalette  << 10);
						}
					else if (uiMachineType == MACHINE_AGB)			// Convert for the Advanced Gameboy.
						{
						if (uicharacter > 0x03FF)
							{
							ErrorCode = ERROR_XVERT_ILLEGAL;
							sprintf(ErrorMessage,
								"Too many chrs defined to store flip/palette bits.\n"
								"(XVERT, PxlToChrmap, Sfx)\n");
							goto errorExit;
							}

						if (flStoreChrFlip     == YES)	uicharacter |= (pxib->uichrFlip     << 10);
						if (flStoreChrPalette  == YES)	uicharacter |= (pxib->uichrPalette  << 12);
						}

					else if (uiMachineType == MACHINE_GEN)		// Convert for the Genesis.
						{
						if (uicharacter > 0x07FF)
							{
							ErrorCode = ERROR_XVERT_ILLEGAL;
							sprintf(ErrorMessage,
								"Too many chrs defined to store flip/palette bits.\n"
								"(XVERT, PxlToChrmap, Gen)\n");
							goto errorExit;
							}

						if (flStoreChrPriority == YES)	uicharacter |= (pxib->uichrPriority << 15);
						if (flStoreChrFlip     == YES)	uicharacter |= (pxib->uichrFlip     << 11);
						if (flStoreChrPalette  == YES)	uicharacter |= (pxib->uichrPalette  << 13);
						}

					else if (uiMachineType == MACHINE_SAT)		// Convert for the Saturn.
						{
						if (uicharacter > uiChrNumMask)
							{
							ErrorCode = ERROR_XVERT_ILLEGAL;
							sprintf(ErrorMessage,
								"Too many chrs defined to store flip/palette bits.\n"
								"(XVERT, PxlToChrmap, Sat)\n");
							goto errorExit;
							}

						uicharacter <<= uiChrNumShift;

						if (flStoreChrPriority == YES) {
							uicharacter |= ((pxib->uichrPriority & uiChrPriMask) << uiChrPriShift);
							}
						if (flStoreChrFlip     == YES) {
							uicharacter |= ((pxib->uichrFlip & 1) << (uiChrXFlShift - 0));
							uicharacter |= ((pxib->uichrFlip & 2) << (uiChrYFlShift - 1));
							}
						if (flStoreChrPalette  == YES) {
							uicharacter |= ((pxib->uichrPalette & uiChrPalMask) << uiChrPalShift);
							}
						}

					else if (uiMachineType == MACHINE_GMB)		// Convert for the Gameboy.
						{
						if (((uicharacter > 0x1FFF)) ||
						    ((uicharacter > 0x0FFF) && (flStoreChrPriority == YES)) ||
							((uicharacter > 0x03FF) && (flStoreChrFlip     == YES)))
							{
							ErrorCode = ERROR_XVERT_ILLEGAL;
							sprintf(ErrorMessage,
								"Too many chrs defined to store flip/palette bits.\n"
								"(XVERT, PxlToChrmap, Gmb)\n");
							goto errorExit;
							}

						uicharacter = (uicharacter & 0x00FFu) + ((uicharacter & 0x1F00u) << (11-8));

						if (flStoreChrPriority == YES)	uicharacter |= ((pxib->uichrPriority & 1) << 15);
						if (flStoreChrFlip     == YES)	uicharacter |= ((pxib->uichrFlip     & 3) << 13);
						if (flStoreChrPalette  == YES)	uicharacter |= ((pxib->uichrPalette  & 7) <<  8);
						}
					}

				else

					{
					// Screen data is machine dependant.

					if (uiMapType == MAP_CHR)
						{
						// Only screw around with the character number if this is going to
						// be used in a character map and not a sprite map.

						if (uiMachineType == MACHINE_GMB)			// Convert for the Gameboy.
							{
							uicharacter = (uicharacter & 0x00FFu) + ((uicharacter & 0x0100u) << (11-8));
							}
						}
					}
				}

			// Save the character number in the map.

			if (uiChrBitSize == 16) {
				*(UW *) pu16dst = ((UW) uicharacter);
				pu16dst++;
				} else {
				*(UD *) pu16dst = ((UD) uicharacter);
				pu16dst += 2;
				}

			// Move onto the next character in this row.

			pu08tmp = pu08tmp + ulcoloffset;
			}

		// Move onto the next row of characters.

		pu08src = pu08src + ulrowoffset;
		}

	// If non-zero then set up the overall map palette.

	if (uipalette != 0) {
		pxib->uimapPalette = uipalette;
		}

	// Return with updated map buffer pointer.

	return (pu16dst);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
// * PxlToChr8x8x8 ()                                                       *
// **************************************************************************
// * Convert the 8bpp bitmap data into an 8x8x8 character                   *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         UB *            Ptr to 8bpp bitmap data                        *
// *         UL              Line width offset of bitmap                    *
// *                                                                        *
// * Output  UI              Character number, or -ve if failed             *
// **************************************************************************

static	UI                  PxlToChr8x8x8           (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth)

	{

	// Local variables.

	UD *                pu32chr;
	UD *                pu32buf;
	UD *                pu32key;

	UD                  u32keyx0y0;
	UD                  u32keyx1y0;
	UD                  u32keyx0y1;
	UD                  u32keyx1y1;

	UI                  uii;

	// Initialize character flip flag to NONE.

	pxib->uichrFlip = 0;

	// Calculate where we are going to put the new character data.

	pu32chr = pxib->n.dcinew.pud__chrBufData + (pxib->n.dcinew.ui___chrCount << 4);

	// Convert the bitmap data into character data (with flipped versions).

	if (uiMachineType == MACHINE_SFX)			// Convert to SuperNES format.
		{
		uii = PxlToSFX8x8x8(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = 0;
		pxib->uichrPriority = 0;
		}
	else	if (uiMachineType == MACHINE_AGB)			// Convert to AGB format.
		{
		uii = PxlToAGB8x8x8(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = 0;
		pxib->uichrPriority = 0;
		}

	else if (uiMachineType == MACHINE_SAT) 		// Convert to Saturn format.
		{
		uii = PxlToSAT8x8x8(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 3);
		pxib->uichrPriority = (uii & 8) >> 3;
		}

	else										// Unknown format.
		{
		// This error condition should already have been caught in PxlToChrmap
		// so lets just return chr number 0.

		uii = 0;

		goto foundCharacter;
		}

	// Override priority ?

	if (flClrPriority == YES) {
		pxib->uichrPriority = 0;
		}

	if (flSetPriority == YES) {
		pxib->uichrPriority = 1;
		}

	// Calculate the key value of the unflipped character.

	u32keyx0y0  = *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;

	pu32chr -= 16;

	// Check for a repeat ?

	if (flRemoveChrRepeats == YES)

		{
		// Do a search to see if the normal version of the character has already
		// been defined.

		pu32key = pxib->o.dciold.pud__chrBufKeys;
		pu32buf = pxib->o.dciold.pud__chrBufData;

		for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 16;
			}

		pu32key = pxib->n.dcinew.pud__chrBufKeys;
		pu32buf = pxib->n.dcinew.pud__chrBufData;

		for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 16;
			}

		// Do a search to see if the X-flipped version of the character has already
		// been defined.

		pu32chr += 16;

		if (flChrXFlipAllowed == YES)

			{
			pxib->uichrFlip = 1;

			u32keyx1y0  = *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;

			pu32chr -= 16;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}
			}

		// Do a search to see if the Y-flipped version of the character has already
		// been defined.

		pu32chr += 16;

		if (flChrYFlipAllowed == YES)

			{
			pxib->uichrFlip = 2;

			u32keyx0y1  = *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;

			pu32chr -= 16;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}
			}

		// Do a search to see if the X and Y-flipped version of the character has
		// already been defined.

		pu32chr += 16;

		if ((flChrXFlipAllowed == YES) && (flChrYFlipAllowed == YES))

			{
			pxib->uichrFlip = 3;

			u32keyx1y1  = *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;

			pu32chr -= 16;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x8(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 16;
				}
			}

		}

	// If we drop through to here then the character is undefined ...

	pxib->uichrFlip = 0;

	uii = pxib->n.dcinew.ui___chrCount++;

	pxib->n.dcinew.pud__chrBufKeys[uii] = u32keyx0y0;

	uii = uii + pxib->o.dciold.ui___chrCount;

	// Return with the character code.

	foundCharacter:

		pxib->uichrNumber = uii;

		return (uii);

	}



// **************************************************************************
// * PxlToChr8x8x4 ()                                                       *
// **************************************************************************
// * Convert the 8bpp bitmap data into an 8x8x4 character                   *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         UB *            Ptr to 8bpp bitmap data                        *
// *         UL              Line width offset of bitmap                    *
// *                                                                        *
// * Output  UI              Character number, or -ve if failed             *
// **************************************************************************

static	UI                  PxlToChr8x8x4           (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth)

	{

	// Local variables.

	UD *                pu32chr;
	UD *                pu32buf;
	UD *                pu32key;

	UD                  u32keyx0y0;
	UD                  u32keyx1y0;
	UD                  u32keyx0y1;
	UD                  u32keyx1y1;

	UI                  uii;

	// Initialize character flip flag to NONE.

	pxib->uichrFlip = 0;

	// Calculate where we are going to put the new character data.

	pu32chr = pxib->n.dcinew.pud__chrBufData + (pxib->n.dcinew.ui___chrCount << 3);

	// Convert the bitmap data into character data (with flipped versions).

	if (uiMachineType == MACHINE_SFX)			// Convert to SuperNES format.
		{
		uii = PxlToSFX8x8x4(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 7);
		pxib->uichrPriority = (uii & 8) >> 3;
		}
	else	if (uiMachineType == MACHINE_AGB)			// Convert to AGB format.
		{
		uii = PxlToAGB8x8x4(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 15);
		pxib->uichrPriority = 0;
		}

	else if (uiMachineType == MACHINE_GEN) 		// Convert to Genesis format.
		{
		uii = PxlToGEN8x8x4(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 3);
		pxib->uichrPriority = (uii & 8) >> 3;
		}

	else if (uiMachineType == MACHINE_SAT) 		// Convert to Saturn format.
		{
		uii = PxlToSAT8x8x4(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 15);
		pxib->uichrPriority = (uii &  8) >> 3;
		}

	else										// Unknown format.
		{
		// This error condition should already have been caught in PxlToChrmap
		// so lets just return chr number 0.
		uii = 0;

		goto foundCharacter;
		}

	// Override priority ?

	if (flClrPriority == YES) {
		pxib->uichrPriority = 0;
		}

	if (flSetPriority == YES) {
		pxib->uichrPriority = 1;
		}

	// Calculate the key value of the unflipped character.

	u32keyx0y0  = *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;

	pu32chr -= 8;

	// Check for a repeat ?

	if (flRemoveChrRepeats == YES)

		{
		// Do a search to see if the normal version of the character has already
		// been defined.

		pu32key = pxib->o.dciold.pud__chrBufKeys;
		pu32buf = pxib->o.dciold.pud__chrBufData;

		for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 8;
			}

		pu32key = pxib->n.dcinew.pud__chrBufKeys;
		pu32buf = pxib->n.dcinew.pud__chrBufData;

		for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 8;
			}

		// Do a search to see if the X-flipped version of the character has already
		// been defined.

		pu32chr += 8;

		if (flChrXFlipAllowed == YES)

			{
			pxib->uichrFlip = 1;

			u32keyx1y0  = *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;

			pu32chr -= 8;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}
			}

		// Do a search to see if the Y-flipped version of the character has already
		// been defined.

		pu32chr += 8;

		if (flChrYFlipAllowed == YES)

			{
			pxib->uichrFlip = 2;

			u32keyx0y1  = *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;

			pu32chr -= 8;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}
			}

		// Do a search to see if the X and Y-flipped version of the character has
		// already been defined.

		pu32chr += 8;

		if ((flChrXFlipAllowed == YES) && (flChrYFlipAllowed == YES))

			{
			pxib->uichrFlip = 3;

			u32keyx1y1  = *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;

			pu32chr -= 8;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x4(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 8;
				}
			}

		}

	// If we drop through to here then the character is undefined ...

	pxib->uichrFlip = 0;

	uii = pxib->n.dcinew.ui___chrCount++;

	pxib->n.dcinew.pud__chrBufKeys[uii] = u32keyx0y0;

	uii = uii + pxib->o.dciold.ui___chrCount;

	// Return with the character code.

	foundCharacter:

		pxib->uichrNumber = uii;

		return (uii);

	}



// **************************************************************************
// * PxlToChr8x8x2 ()                                                       *
// **************************************************************************
// * Convert the 8bpp bitmap data into an 8x8x2 character                   *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         UB *            Ptr to 8bpp bitmap data                        *
// *         UL              Line width offset of bitmap                    *
// *                                                                        *
// * Output  UI              Character number, or -ve if failed             *
// **************************************************************************

static	UI                  PxlToChr8x8x2           (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth)

	{

	// Local variables.

	UD *                pu32chr;
	UD *                pu32buf;
	UD *                pu32key;

	UD                  u32keyx0y0;
	UD                  u32keyx1y0;
	UD                  u32keyx0y1;
	UD                  u32keyx1y1;

	UI                  uii;

	// Initialize character flip flag to NONE.

	pxib->uichrFlip = 0;

	// Calculate where we are going to put the new character data.

	pu32chr = pxib->n.dcinew.pud__chrBufData + (pxib->n.dcinew.ui___chrCount << 2);

	// Convert the bitmap data into character data (with flipped versions).

	if (uiMachineType == MACHINE_SFX)		// Convert to SuperNES format.
		{
		uii = PxlToSFX8x8x2(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 7);
		pxib->uichrPriority = (uii & 0x20) >> 5;
		}

	else if (uiMachineType == MACHINE_GMB)	// Convert to Gameboy format.
		{
		uii = PxlToGMB8x8x2(pu08src, (UB *) pu32chr, ulsrcwidth);

		pxib->uichrPalette  = (uii & 7);
		pxib->uichrPriority = (uii & 8) >> 3;
		}

	else									// Unknown format.
		{
		// This error condition should already have been caught in PxlToChrmap
		// so lets just return chr number 0.

		uii = 0;

		goto foundCharacter;
		}

	// Override priority ?

	if (flClrPriority == YES) {
		pxib->uichrPriority = 0;
		}

	if (flSetPriority == YES) {
		pxib->uichrPriority = 1;
		}

	// Calculate the key value of the unflipped character.

	u32keyx0y0  = *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;
	u32keyx0y0 ^= *pu32chr++;

	pu32chr -= 4;

	// Check for a repeat ?

	if (flRemoveChrRepeats == YES)

		{
		// Do a search to see if the normal version of the character has already
		// been defined.

		pu32key = pxib->o.dciold.pud__chrBufKeys;
		pu32buf = pxib->o.dciold.pud__chrBufData;

		for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 4;
			}

		pu32key = pxib->n.dcinew.pud__chrBufKeys;
		pu32buf = pxib->n.dcinew.pud__chrBufData;

		for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
			{
			if (u32keyx0y0 == *pu32key++)
				{
				if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
					{
					uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
					goto foundCharacter;
					}
				}
			pu32buf += 4;
			}

		// Do a search to see if the X-flipped version of the character has already
		// been defined.

		pu32chr += 4;

		if (flChrXFlipAllowed == YES)

			{
			pxib->uichrFlip = 1;

			u32keyx1y0  = *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;
			u32keyx1y0 ^= *pu32chr++;

			pu32chr -= 4;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y0 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}
			}

		// Do a search to see if the Y-flipped version of the character has already
		// been defined.

		pu32chr += 4;

		if (flChrYFlipAllowed == YES)

			{
			pxib->uichrFlip = 2;

			u32keyx0y1  = *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;
			u32keyx0y1 ^= *pu32chr++;

			pu32chr -= 4;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx0y1 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}
			}

		// Do a search to see if the X and Y-flipped version of the character has
		// already been defined.

		pu32chr += 4;

		if ((flChrXFlipAllowed == YES) && (flChrYFlipAllowed == YES))

			{
			pxib->uichrFlip = 3;

			u32keyx1y1  = *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;
			u32keyx1y1 ^= *pu32chr++;

			pu32chr = pu32chr - 4;

			pu32key = pxib->o.dciold.pud__chrBufKeys;
			pu32buf = pxib->o.dciold.pud__chrBufData;

			for (uii = pxib->o.dciold.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}

			pu32key = pxib->n.dcinew.pud__chrBufKeys;
			pu32buf = pxib->n.dcinew.pud__chrBufData;

			for (uii = pxib->n.dcinew.ui___chrCount; uii != 0; uii -= 1)
				{
				if (u32keyx1y1 == *pu32key++)
					{
					if (CompareChr8x8x2(pu32buf, pu32chr) == YES)
						{
						uii = pxib->o.dciold.ui___chrCount + pxib->n.dcinew.ui___chrCount - uii;
						goto foundCharacter;
						}
					}
				pu32buf += 4;
				}
			}

		} // End of "if (flRemoveChrRepeats == YES)"

	// If we drop through to here then the character is undefined ...

	pxib->uichrFlip = 0;

	uii = pxib->n.dcinew.ui___chrCount++;

	pxib->n.dcinew.pud__chrBufKeys[uii] = u32keyx0y0;

	uii = uii + pxib->o.dciold.ui___chrCount;

	// Return with the character code.

	foundCharacter:

		pxib->uichrNumber = uii;

		return (uii);

	}



// **************************************************************************
// * CompareChr8x8x8 ()                                                     *
// **************************************************************************
// * Compares 2 64-byte characters                                          *
// **************************************************************************
// * Inputs  UD *            Ptr to 1st character                           *
// *         UD *            Ptr to 2nd character                           *
// *                                                                        *
// * Output  FL              YES if they are the same, NO if not            *
// **************************************************************************

static	FL                  CompareChr8x8x8         (
								UD *                p,
								UD *                q)

	{
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;

	return (YES);

	exitNo:

		return (NO);
	}



// **************************************************************************
// * CompareChr8x8x4 ()                                                     *
// **************************************************************************
// * Compares 2 32-byte characters                                          *
// **************************************************************************
// * Inputs  UD *            Ptr to 1st character                           *
// *         UD *            Ptr to 2nd character                           *
// *                                                                        *
// * Output  FL              YES if they are the same, NO if not            *
// **************************************************************************

static	FL                  CompareChr8x8x4         (
								UD *                p,
								UD *                q)

	{
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;

	return (YES);

	exitNo:

		return (NO);
	}



// **************************************************************************
// * CompareChr8x8x2 ()                                                     *
// **************************************************************************
// * Compares 2 16-byte characters                                          *
// **************************************************************************
// * Inputs  UD *            Ptr to 1st character                           *
// *         UD *            Ptr to 2nd character                           *
// *                                                                        *
// * Output  FL              YES if they are the same, NO if not            *
// **************************************************************************

static	FL                  CompareChr8x8x2         (
								UD *                p,
								UD *                q)

	{
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;
	if (*p++ != *q++) goto exitNo;

	return (YES);

	exitNo:

		return (NO);
	}



// **************************************************************************
// * ChrToBlk ()                                                            *
// **************************************************************************
// * Convert chrmap data into a blk                                         *
// **************************************************************************
// * Inputs  XVERTINFOBLOCK *  Ptr to ???                                   *
// *         UW *            Ptr to character data                          *
// *         UL              Width of character data                        *
// *                                                                        *
// * Output  UI              Block number, or -ve if failed                 *
// **************************************************************************

static	UI                  ChrToBlk                (
								XVERTINFOBLOCK *    pxib,
								UW *                pu16src,
								UL                  ulsrcwidth)

	{

	// Local variables.

	UW *                pu16dst;
	UW *                pu16blk;
	UW *                pu16tmp;
	UW *                pu16key;

	UI                  uii;
	UI                  uij;

	UI                  uikeysize;
	UW                  u16blkkey;

	// Calculate where we are going to put the new block data.

	pu16blk = pxib->n.dbinew.puw__blkBufData +
		(pxib->n.dbinew.ui___blkCount * pxib->n.dbinew.ui___blkChrSize);

	// Extract the block data from the character map.

	pu16dst = pu16blk;

	for (uii = pxib->n.dbinew.ui___blkYChrSize; uii != 0; uii -= 1)
		{
		pu16tmp = pu16src;

		for (uij = pxib->n.dbinew.ui___blkXChrSize; uij != 0; uij -= 1)
			{
			*pu16dst++ = *pu16tmp++;
			}

		pu16src += ulsrcwidth;
		}

	// Calculate the new blk's key value.

	uikeysize = pxib->n.dbinew.ui___blkBytSize / sizeof(UW);

	u16blkkey = 0;

	pu16tmp = pu16blk;

	for (uii = uikeysize; uii != 0; uii -= 1)
		{
		u16blkkey ^= *pu16tmp++;
		}

	// Check for a repeated block ?

	if (flRemoveBlkRepeats == YES)

		{
		// Check if the block already exists in the old blkset.

		pu16key = pxib->o.dbiold.puw__blkBufKeys;
		pu16src = pxib->o.dbiold.puw__blkBufData;

		for (uii = pxib->o.dbiold.ui___blkCount; uii != 0; uii -= 1)
			{
			if (u16blkkey == *pu16key++)
				{
				pu16dst = pu16blk;
				pu16tmp = pu16src;

				for (uij = uikeysize; uij != 0; uij -= 1)
					{
					if (*pu16dst++ != *pu16tmp++) break;
					}

				if (uij == 0)
					{
					uii = pxib->o.dbiold.ui___blkCount - uii;
					goto foundBlk;
					}
				}

			pu16src += pxib->o.dbiold.ui___blkChrSize;
			}

		// Check if the block already exists in the new blkset.

		pu16key = pxib->n.dbinew.puw__blkBufKeys;
		pu16src = pxib->n.dbinew.puw__blkBufData;

		for (uii = pxib->n.dbinew.ui___blkCount; uii != 0; uii -= 1)
			{
			if (u16blkkey == *pu16key++)
				{
				pu16dst = pu16blk;
				pu16tmp = pu16src;

				for (uij = uikeysize; uij != 0; uij -= 1)
					{
					if (*pu16dst++ != *pu16tmp++) break;
					}

				if (uij == 0)
					{
					uii = pxib->o.dbiold.ui___blkCount + pxib->n.dbinew.ui___blkCount - uii;
					goto foundBlk;
					}
				}
			pu16src += pxib->n.dbinew.ui___blkChrSize;
			}
		}

	// If we get to here then the block is unique ...

	uii = pxib->n.dbinew.ui___blkCount++;

	pxib->n.dbinew.puw__blkBufKeys[uii] = u16blkkey;

	uii = uii + pxib->o.dbiold.ui___blkCount;

	// Block number found.

	foundBlk:

	// Print out block number.

	#if 0
		printf("blknumber=0x%04X\n",
			(UI) uii);
	#endif

	// Return with the block number.

	return (uii);

	}



// **************************************************************************
// * RemoveStaticMapData ()                                                 *
// **************************************************************************
// * Reformat the map data for the MAP file                                 *
// **************************************************************************
// * Inputs  DATAMAPSET_T *  Ptr to the map data                            *
// *         SI              Number of the static map frame                 *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B. Reorder map data from ...                                         *
// *                                                                        *
// * The map data has the following format ...                              *
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
// **************************************************************************

global	ERRORCODE           RemoveStaticMapData     (
								DATAMAPSET_T *      pcl__Map,
								SI                  si___Frm)

	{

	// Local variables.

	DATAMAPIDX_T *      pcl__SrcIdx;
	DATAMAPIDX_T *      pcl__DstIdx;

	SI                  si___i;
	SI                  si___j;

	UI                  ui___w;
	UI                  ui___h;

	UW *                pu16src;
	UW *                pu16dst;

	// Construct the map data table.

	for (si___i = (pcl__Map->ui___mapsCount - 1); si___i > 0; si___i -= 1)
		{
		// Locate the source and destination map indices.

		if (si___Frm >= 0)
			{
			if (si___i == si___Frm) continue;

			pcl__SrcIdx = &pcl__Map->acl__mapsBufIndx[si___Frm];
			}
		else
			{
			if ((si___j = (si___i + si___Frm)) < 0) continue;

			pcl__SrcIdx = &pcl__Map->acl__mapsBufIndx[si___j];
			}

		pcl__DstIdx = &pcl__Map->acl__mapsBufIndx[si___i];

		// Blank map ???

		if ((pcl__SrcIdx->puw__mapiBufPtr == NULL) ||
		    (pcl__DstIdx->puw__mapiBufPtr == NULL))
			{
			continue;
			}

		// Repeat map ???

		if ((pcl__SrcIdx->ul___mapiBufLen == 0) ||
		    (pcl__DstIdx->ul___mapiBufLen == 0))
			{
			continue;
			}

		// Now process the map itself.

		pu16src = pcl__SrcIdx->puw__mapiBufPtr;
		pu16dst = pcl__DstIdx->puw__mapiBufPtr;

		// Set up number of sections (including sprite section height flag).

		si___j = pu16src[7];

		if (si___j != pu16dst[7])
			{
			continue;
			}

		// Now reorder each section.

		pu16src += 8;
		pu16dst += 8;

		while (si___j-- != 0)
			{
			// Get section width and height.

			if ((ui___w = pu16src[2]) != pu16dst[2]) break;
			if ((ui___h = pu16src[3]) != pu16dst[3]) break;

			// Move onto the section data.

			pu16src += 4;
			pu16dst += 4;

			// Blank out identical map data.

			ui___w = ui___w * ui___h;

			while (ui___w-- != 0)
				{
				if (*pu16dst == *pu16src)
					{
					*pu16dst = 0;
					}
				pu16src += 1;
				pu16dst += 1;
				}

			// End of this map section.

			}

		// Now do the next map.

		}

	// All done.

	return (ERROR_NONE);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERT.C
// **************************************************************************
// **************************************************************************
// **************************************************************************