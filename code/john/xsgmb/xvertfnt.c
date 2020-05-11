// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTFNT.C                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Font format.                                                    **
// **                                                                      **
// ** Last modified : 15 Oct 1996 by John Brandwood                        **
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

#include	"pcx.h"

//
// DEFINITIONS
//

//
// GLOBAL VARIABLES
//

global	UI                  uiFntChr0  = 32;
global	UI                  uiFntXSpc  = 2;
global	UI                  uiFntYSpc  = 2;
global	FL                  flFntYDbl  = NO;
global	FL                  flFntDebug = NO;

global	char                czFntTest [1024];

//
// STATIC VARIABLES
//

typedef	struct	CHRPOS_S
	{
	UB *                pub__cpB;
	UI                  ui___cpN;
	SI                  si___cpP;
	SI                  si___cpB;
	SI                  si___cpX;
	SI                  si___cpY;
	UI                  ui___cpW;
	UI                  ui___cpH;
	SI                  si___cpL;
	SI                  si___cpR;
	} CHRPOS_T;

static	UB                  aub__sKrnTbl [2048];
static	UB *                pub__sKrnEnd;

//
// STATIC FUNCTION PROTOTYPES
//

static	ERRORCODE           PackKernTable           (
								DATAFNTSET_T *      pcl__Fnt);

static	SI                  TestFont                (
								FNTHDR_T *          pcl__F,
								DATAFNTIDX_T *      pcl__I,
								char *              pcz__Test);

static	SI                  CalcWidth               (
								FNTHDR_T *          pcl__F,
								DATAFNTIDX_T *      pcl__I,
								char *              pcz__Test);

static	SI                  DrawFontChr             (
								DATAFNTIDX_T *      pcl__I,
								UB *                pub__B,
								UI                  ui___N);

static	SI                  FindCols                (
								DATABITMAP_T *      pdbiti,
								SI *                psi__ColX,
								UI *                pui__ColW);

static	SI                  FindRows                (
								DATABITMAP_T *      pdbiti,
								SI *                psi__RowY,
								UI *                pui__RowH);

static	SI                  FindLinY                (
								DATABITMAP_T *      pdbiti,
								SI                  si___X,
								SI *                psi__LinY);

static	void                FindChrPos              (
								CHRPOS_T *          pcl__Chr);

static	SI                  AddPxl08ToFNT           (
								DATAFNTSET_T *      pcl__Fnt,
								CHRPOS_T *          pcl__Chr);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * AddKernPair ()                                                         *
// **************************************************************************
// * Add a kern pair to the kerning table                                   *
// **************************************************************************
// * Inputs  int             1st character                                  *
// *         int             2nd character                                  *
// *         int             delta                                          *
// *                                                                        *
// * Output  FL              YES if OK, NO if an error                      *
// **************************************************************************

global	FL                  AddKernPair             (
								int                 chr0,
								int                 chr1,
								int                 delta)

	{

	// Local variables.

	KERNPAIR_T *        pcl__Pair;

	UI                  i;
	UI                  j;

	// Table full.

	if (FntInfo.ui___fntsKrnCnt == FntInfo.ui___fntsKrnMax)
		{
		return (NO);
		}

	// Add info to table.

	for (i = 0; i < FntInfo.ui___fntsKrnCnt; i++)
		{
		pcl__Pair = &FntInfo.acl__fntsKrnTbl[i];

		if (chr0 < pcl__Pair->ub___chr0) break;
		if (chr0 > pcl__Pair->ub___chr0) continue;

		if (chr1 < pcl__Pair->ub___chr1) break;
		if (chr1 > pcl__Pair->ub___chr1) continue;

		return (NO);
		}

	pcl__Pair = &FntInfo.acl__fntsKrnTbl[FntInfo.ui___fntsKrnCnt] - 1;

	for (j = FntInfo.ui___fntsKrnCnt; j > i; j--)
		{
		((UD *) pcl__Pair)[1] = ((UD *) pcl__Pair)[0];
		pcl__Pair -= 1;
		}

	pcl__Pair = &FntInfo.acl__fntsKrnTbl[i];

	pcl__Pair->ub___chr0    = chr0;
	pcl__Pair->ub___chr1    = chr1;
	pcl__Pair->sb___dX      = delta;
	pcl__Pair->ub___padding = 0;

	FntInfo.ui___fntsKrnCnt += 1;

	return (YES);
	}



// **************************************************************************
// * BitmapToFont ()                                                        *
// **************************************************************************
// * Convert the rectangle within the bitmap into a font                    *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         DATAFNTSET_T *  Ptr to font                                    *
// *                                                                        *
// * Output  SI              # of characters added, or -ve if an error      *
// *                                                                        *
// * N.B.    The conversion rectangle's top-left coordinate (si___bmx,      *
// *         si___bmy) is given relative to the origin point, where the     *
// *         top-left coordinate of the bitmap data has the value           *
// *         (si___bmXTopLeft, si___bmYTopLeft).                            *
// **************************************************************************

global	SI                  BitmapToFont            (
								DATABITMAP_T *      pdbiti,
								DATAFNTSET_T *      pdfnti)

	{

	// Local variables.

	SI *                psi__LinY;

	UI                  ui___CurCol;
	UI                  ui___CurRow;

	UI                  ui___Cols;
	UI                  ui___Rows;

	UI                  ui___Chr;
	CHRPOS_T            cl___Chr;

	SI                  asi__ColX [64];
	UI                  aui__ColW [64];

	SI                  asi__RowY [64];
	UI                  aui__RowH [64];

	SI                  asi__LinY [64];

	// Check that the bitmap is legal.

	if (pdbiti->ui___bmB != 8)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Can't convert %d BPP data into a font.\n"
			"(XS, BitmapToFont)\n",
			pdbiti->ui___bmB);
		return (-1);
		}

	if ((pdbiti->ui___bmW == 0) || (pdbiti->ui___bmH == 0))
		{
		return (0);
		}

	// Scan the bitmap to locate the rows and columns.

	ui___Cols = FindCols(pdbiti, &asi__ColX[0], &aui__ColW[0]);
	ui___Rows = FindRows(pdbiti, &asi__RowY[0], &aui__RowH[0]);

	if (flFntDebug)
		{
		printf("\n");

		printf("Col :  X   W \n");
		printf("-------------\n");

		for (ui___Chr = 0; ui___Chr < ui___Cols; ui___Chr++)
			{
			printf("      %3d %3d\n", asi__ColX[ui___Chr], aui__ColW[ui___Chr]);
			}

		printf("\n");

		printf("Row :  Y   H \n");
		printf("-------------\n");

		for (ui___Chr = 0; ui___Chr < ui___Rows; ui___Chr++)
			{
			printf("      %3d %3d\n", asi__RowY[ui___Chr], aui__RowH[ui___Chr]);
			}

		printf("\n");
		}

	if (ui___Cols < 2)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Need at least 2 columns of data for a font.\n"
			"(XS, BitmapToFont)\n");
		return (-1);
		}

	if (aui__ColW[0] != 1)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"First column is too wide for line position data.\n"
			"(XS, BitmapToFont)\n");
		return (-1);
		}

	// Scan the first column to locate the line positions.

	FindLinY(pdbiti, asi__ColX[0], &asi__LinY[0]);

	// Now convert the bitmap.

	psi__LinY = &asi__LinY[0];

	ui___Chr = 0;

	cl___Chr.pub__cpB = pdbiti->pub__bmBitmap;
	cl___Chr.ui___cpN = pdbiti->si___bmLineSize;

	ui___CurRow = (UI) -1;

	while (++ui___CurRow < ui___Rows)

		{

		// Get the row information.

		cl___Chr.si___cpB = *psi__LinY++;
		cl___Chr.si___cpP = -1;

		if (aui__RowH[ui___CurRow] == 1)
			{
			cl___Chr.si___cpP = asi__RowY[ui___CurRow++];
			if (ui___CurRow == ui___Rows) break;
			}

		// Now process each column in this row.

		ui___CurCol = 0;

		while (++ui___CurCol < ui___Cols)

			{

			// Get the character information.

			cl___Chr.si___cpY = asi__RowY[ui___CurRow];
			cl___Chr.ui___cpH = aui__RowH[ui___CurRow];

			cl___Chr.si___cpX = asi__ColX[ui___CurCol];
			cl___Chr.ui___cpW = aui__ColW[ui___CurCol];

			FindChrPos(&cl___Chr);

			// Was there anything there ?

			if (cl___Chr.ui___cpW == 0) continue;

			#if 0
			printf("x=%03d y=%03d w=%02d h=%02d l=%02d r=%02d b=%03d \n",
				cl___Chr.si___cpX,
				cl___Chr.si___cpY,
				cl___Chr.ui___cpW,
				cl___Chr.ui___cpH,
				cl___Chr.si___cpL,
				cl___Chr.si___cpR,
				cl___Chr.si___cpB);
			#endif

			// Convert the pixel data into a character.

			AddPxl08ToFNT(pdfnti, &cl___Chr);

			ui___Chr++;

			//

			}

		}

	// Report the number of characters converted.

	printf("\nAdded %d characters to the font.\n\n", ui___Chr);

	// All done.

	return (ui___Chr);

	}


// **************************************************************************
// * ReformatFntsForFNT ()                                                  *
// **************************************************************************
// * Reformat the font data for the FNT file                                *
// **************************************************************************
// * Inputs  DATAFNTSET_T *  Ptr to the font data                           *
// *         UB **           Ptr to variable that gets ptr to output data   *
// *         UI *            Ptr to variable that gets len of output data   *
// *         FILE *          Ptr to RES file, or NULL if none               *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           ReformatFntsForFNT      (
								DATAFNTSET_T *      pcl__Fnt,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	ANYPTR_T            pbf__Buf;

	DATAFNTIDX_T *      pcl__Idx;

	FNTHDR_T            cl___FH;
	FNTIDX_T *          pcl__FI;

	UW                  uw___o;

	UI                  ui___i;
	UI                  ui___j;

	UB *                pub__Tmp;
	UD *                pud__Tmp;
	UI                  ui___Tmp;

	SI                  si___xmin;
	SI                  si___xmax;
	SI                  si___ymin;
	SI                  si___ymax;

	SI                  si___t;

	UB                  aub__Xvt [256];

	// Pack the kerning table.

	if (PackKernTable(pcl__Fnt) != ERROR_NONE)
		{
		return (ErrorCode);
		}

	// Initialize the Xvt table.

	if (uiMachineType == MACHINE_N64)
		{
		for (ui___i = 0; ui___i < 256; ui___i++)
			{
			aub__Xvt[ui___i] = 0;
			}

		ui___j = 0x00;

		for (ui___i = 0; ui___i < 16; ui___i++)
			{
			aub__Xvt[ui___i] = ui___j;

			ui___j += 0x11;
			}

//		aub__Xvt[0] = 0x00;
//		aub__Xvt[1] = 0x33;
//		aub__Xvt[2] = 0x66;
//		aub__Xvt[3] = 0x99;
//		aub__Xvt[4] = 0xCC;
//		aub__Xvt[5] = 0xFF;
		}
	else
		{
		for (ui___i = 0; ui___i < 256; ui___i++)
			{
			aub__Xvt[ui___i] = (UB) ui___i;
			}
		}

	// Work out the font stats.

	si___xmin =
	si___xmax =
	si___ymin =
	si___ymax = 0;

	pcl__Idx = pcl__Fnt->acl__fntsBufIndx;
	ui___i   = pcl__Fnt->ui___fntsCount;

	while (ui___i)
		{
		// Find max number of pixels BEFORE character's starting point.

		si___t = pcl__Idx->si___fntiXOffset;

		if (si___t < si___xmin) si___xmin = si___t;

		// Find max number of pixels AFTER character's ending point.

		si___t = (si___t + pcl__Idx->ui___fntiWidth) - pcl__Idx->si___fntiDeltaW;

		if (si___t > si___xmax) si___xmax = si___t;

		// Find max number of pixels ABOVE character's starting point.

		si___t = pcl__Idx->si___fntiYOffset;

		if (si___t < si___ymin) si___ymin = si___t;

		// Find max number of pixels BELOW character's starting point.

		si___t = (si___t + pcl__Idx->ui___fntiHeight);

		if (si___t > si___ymax) si___ymax = si___t;

		// Get the next

		pcl__Idx += 1;
		ui___i   -= 1;
		}

	// Fill in the font header.

	memset(&cl___FH, 0, sizeof(FNTHDR_T));

//	cl___FH.cz___fntName [7];
	cl___FH.ub___fntFlgs = 0;
	cl___FH.ub___fntKrnN = pcl__Fnt->ui___fntsKrnCnt;
	cl___FH.ub___fntChr0 = uiFntChr0;
	cl___FH.ub___fntChrN = pcl__Fnt->ui___fntsCount;
	cl___FH.sb___fntXSpc = uiFntXSpc;
	cl___FH.sb___fntYSpc = uiFntYSpc;
	cl___FH.sb___fntXLft = 0-si___xmin;
	cl___FH.sb___fntXRgt = 0+si___xmax;
	cl___FH.sb___fntYTop = 1-si___ymin;
	cl___FH.sb___fntYBtm = si___ymax-1;

	ui___i = 'X' - cl___FH.ub___fntChr0;

	if (ui___i >= cl___FH.ub___fntChrN)
		{
		ui___i = cl___FH.sb___fntYTop;
		}
	else
		{
		ui___i = 1 - pcl__Fnt->acl__fntsBufIndx[ui___i].si___fntiYOffset;
		}

	cl___FH.sb___fntYCap = ui___i;

	cl___FH.sb___fntYOvr =
		(cl___FH.sb___fntYTop + cl___FH.sb___fntYBtm) - cl___FH.sb___fntYCap;

	// Create a test string if one hasn't already been set.

	ui___i = 0;

	if (czFntTest[0] == 0)
		{
		ui___j = cl___FH.ub___fntChr0;
		while (ui___j <= '/')
			{
			czFntTest[ui___i++] = ui___j;
			ui___j++;
			}
		ui___j = '/';
		while (ui___j < (UI) (cl___FH.ub___fntChr0 + cl___FH.ub___fntChrN))
			{
			czFntTest[ui___i++] = ui___j;
			ui___j++;
			}
		}

	// Now write out a test string bitmap using this font.

	TestFont(&cl___FH, pcl__Fnt->acl__fntsBufIndx, czFntTest);

	// Initialize output buffer.

	ui___Buf =
		sizeof(FNTHDR_T) +
		sizeof(FNTIDX_T) * pcl__Fnt->ui___fntsCount +
		(pub__sKrnEnd - aub__sKrnTbl) +
		(((UB *)pcl__Fnt->pbf__fntsBufCur)-((UB *)pcl__Fnt->pbf__fntsBuf1st));

	pub__Buf = (UB *) malloc(ui___Buf);

	if (pub__Buf == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		sprintf(ErrorMessage,
			"(ReformatFNT) Not enough memory to allocate buffer.\n");
		return (ErrorCode);
		}

	pbf__Buf.ubp = pub__Buf;

	// Write out the header.

	if (pcl__Res != NULL)
		{
		*pcz__OutputExt = '\0';
		fprintf(pcl__Res, "resource \"FNT-%s\" public\n\n", pcz__OutputNam);
		fprintf(pcl__Res, "bytes\n\n");

		fprintf(pcl__Res, "0!d  # Data Pointer\n");

		fprintf(pcl__Res, "%3d  # Flags\n", cl___FH.ub___fntFlgs);
		fprintf(pcl__Res, "%3d  # KrnN\n",  cl___FH.ub___fntKrnN);
		fprintf(pcl__Res, "%3d  # Chr0\n",  cl___FH.ub___fntChr0);
		fprintf(pcl__Res, "%3d  # ChrN\n",  cl___FH.ub___fntChrN);
		fprintf(pcl__Res, "%3d  # XSpc\n",  cl___FH.sb___fntXSpc);
		fprintf(pcl__Res, "%3d  # YSpc\n",  cl___FH.sb___fntYSpc);
		fprintf(pcl__Res, "%3d  # XLft\n",  cl___FH.sb___fntXLft);
		fprintf(pcl__Res, "%3d  # XRgt\n",  cl___FH.sb___fntXRgt);
		fprintf(pcl__Res, "%3d  # YTop\n",  cl___FH.sb___fntYTop);
		fprintf(pcl__Res, "%3d  # YBtm\n",  cl___FH.sb___fntYBtm);
		fprintf(pcl__Res, "%3d  # YCap\n",  cl___FH.sb___fntYCap);
		fprintf(pcl__Res, "%3d  # YOvr\n",  cl___FH.sb___fntYOvr);
		fprintf(pcl__Res, "\n");

		fprintf(pcl__Res, "# data   X   Y   W   H  dX   -\n");
		fprintf(pcl__Res, "\n");
		}

	memcpy(pbf__Buf.ubp, &cl___FH, sizeof(FNTHDR_T));

	pbf__Buf.ubp += sizeof(FNTHDR_T);

	// Construct the font index table.

	pcl__Idx = pcl__Fnt->acl__fntsBufIndx;
	pcl__FI  = (FNTIDX_T *) (pbf__Buf.ubp);

	for (ui___i = 0; ui___i < pcl__Fnt->ui___fntsCount; ui___i += 1)
		{
		uw___o = ((pcl__Fnt->ui___fntsCount - ui___i) * sizeof(FNTIDX_T))
			+ (pub__sKrnEnd - aub__sKrnTbl)
			+ (pcl__Idx->pbf__fntiBufPtr - pcl__Fnt->pbf__fntsBuf1st);

		if (uiOutputOrder == ORDERSWAP) {
			pcl__FI->uw___chrOff = SwapD16(uw___o);
			} else {
			pcl__FI->uw___chrOff = uw___o;
			}

		pcl__FI->ub___chrNul = 0;
		pcl__FI->sb___chrX   = pcl__Idx->si___fntiXOffset;
		pcl__FI->sb___fntY   = pcl__Idx->si___fntiYOffset;
		pcl__FI->ub___fntW   = pcl__Idx->ui___fntiWidth;
		pcl__FI->ub___fntH   = pcl__Idx->ui___fntiHeight;
		pcl__FI->sb___chrNxt = pcl__Idx->si___fntiDeltaW;

		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "$%04X!w $%02X $%02X $%02X $%02X $%02X $00\n",
				(int) uw___o,
				(int) pcl__Idx->si___fntiXOffset & 255,
				(int) pcl__Idx->si___fntiYOffset & 255,
				(int) pcl__Idx->ui___fntiWidth   & 255,
				(int) pcl__Idx->ui___fntiHeight  & 255,
				(int) pcl__Idx->si___fntiDeltaW  & 255);
			}

		pcl__Idx += 1;
		pcl__FI  += 1;
		}

	pbf__Buf.ubp = (UB *) pcl__FI;

	if (pcl__Res != NULL)
		{
		fprintf(pcl__Res, "\n");
		}

	// Copy the font kerning table.

	if (pub__sKrnEnd != aub__sKrnTbl)
		{
		// Copy the kern pair index table.

		pub__Tmp = aub__sKrnTbl;

		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "# Kerning Index Table\n\n");
			}

		ui___i = (pcl__Fnt->ui___fntsCount + 1) & ~1;

		while (ui___i--)
			{
			*pbf__Buf.ubp++ = *pub__Tmp;

			if (pcl__Res != NULL)
				{
				fprintf(pcl__Res, "$%02X\n", *pub__Tmp);
				}

			pub__Tmp += 1;
			}

		// Copy the kern pair data table.

		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "\n");
			fprintf(pcl__Res, "# Kerning Data Table\n\n");
			}

		while (pub__Tmp < pub__sKrnEnd)
			{
			*pbf__Buf.ubp++ = pub__Tmp[0];
			*pbf__Buf.ubp++ = pub__Tmp[1];

			if (pcl__Res != NULL)
				{
				fprintf(pcl__Res, "$%02X $%02X\n", (int) pub__Tmp[0], (int) pub__Tmp[1]);
				}

			pub__Tmp += 2;
			}

		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "\n");
			}
		}

	// Construct the font data table.

	pcl__Idx = pcl__Fnt->acl__fntsBufIndx;

	for (ui___i = 0; ui___i < pcl__Fnt->ui___fntsCount; ui___i += 1)
		{
		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "# Character %d\n\n", ui___i);

			pub__Tmp = (UB *) pcl__Idx->pbf__fntiBufPtr;
			ui___Tmp =        pcl__Idx->ul___fntiBufLen;

			while (ui___Tmp)
				{
				ui___j    = (ui___Tmp < 32) ? ui___Tmp : 32;
				ui___Tmp -= ui___j;
				fprintf(pcl__Res, "[");
				while (ui___j--) fprintf(pcl__Res, "%02X", aub__Xvt[*pub__Tmp++]);
				fprintf(pcl__Res, "]\n");
				}

			fprintf(pcl__Res, "\n");
			}

		pud__Tmp = (UD *) pcl__Idx->pbf__fntiBufPtr;
		ui___Tmp =        pcl__Idx->ul___fntiBufLen >> 2;

		while (ui___Tmp--)
			{
			*pbf__Buf.udp++ = *pud__Tmp++;
			}

		pcl__Idx += 1;
		}

	//

	if (pcl__Res != NULL)
		{
		fprintf(pcl__Res, "endresource\n\n");
		}

	// All done.

	*ppub_Buf = pub__Buf;
	*pui__Buf = (pbf__Buf.ubp - pub__Buf);

	return (ERROR_NONE);

	}



// **************************************************************************
// * PackKernTable ()                                                       *
// **************************************************************************
// * Pack the kern pair list into output format                             *
// **************************************************************************
// * Inputs  DATAFNTSET_T *  Ptr to the font data                           *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

static	ERRORCODE           PackKernTable           (
								DATAFNTSET_T *      pcl__Fnt)

	{

	// Local variables.

	UI                  i;
	UI                  j;

	KERNPAIR_T *        pcl__KrnLst;

	UB *                pub__KrnIdx;
	UB *                pub__KrnTbl;
	UB *                pub__KrnEnd;

	UB *                pub__KrnMrk;
	UB                  ub___KrnMrk;

	// Initialize the kern table.

	pub__sKrnEnd = aub__sKrnTbl;

	memset(aub__sKrnTbl, 0, 1024);

	i = pcl__Fnt->ui___fntsKrnCnt;

	if (i == 0)
		{
		return (ERROR_NONE);
		}

	pcl__KrnLst = pcl__Fnt->acl__fntsKrnTbl;

	// Construct the kern table from the kern pairs list.

	pub__KrnIdx = &aub__sKrnTbl[0];

 	pub__KrnTbl =
	pub__KrnEnd = pub__KrnIdx + ((pcl__Fnt->ui___fntsCount + 1) & ~1);

	ub___KrnMrk = 0;

	while (i--)
		{
		// Start of new section ?

		if (pcl__KrnLst->ub___chr0 != ub___KrnMrk)
			{
			if (((UI) pcl__KrnLst->ub___chr0 <  uiFntChr0) ||
				((UI) pcl__KrnLst->ub___chr0 >= uiFntChr0 + pcl__Fnt->ui___fntsCount))
				{
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"(PackKernTable) Kern pair character \'%c\' not stored in font !\n",
					pcl__KrnLst->ub___chr0);
				return (ErrorCode);
				}

			ub___KrnMrk = pcl__KrnLst->ub___chr0;
			pub__KrnMrk = pub__KrnEnd;

			*pub__KrnEnd++ = 0;
			*pub__KrnEnd++ = 0;

			j = (pub__KrnEnd - pub__KrnIdx) >> 1;

			if (j > 255)
				{
				ErrorCode = ERROR_NO_MEMORY;
				sprintf(ErrorMessage,
					"(PackKernTable) Kern pair table full !\n");
				return (ErrorCode);
				}

			pub__KrnIdx[pcl__KrnLst->ub___chr0 - uiFntChr0] = (UB) j;
			}

		// Add pair to current section.

		pub__KrnMrk[1] += 1;

		*pub__KrnEnd++ = (UB) pcl__KrnLst->ub___chr1;
		*pub__KrnEnd++ = (UB) pcl__KrnLst->sb___dX;

		pcl__KrnLst += 1;
		}

	// Finish off the last section.

	*pub__KrnEnd++ = 0;
	*pub__KrnEnd++ = 0;

	// Pad out table to an 4-byte boundary.

	j = ((pub__KrnEnd - pub__KrnIdx) + 3) & ~3;

	pub__sKrnEnd = aub__sKrnTbl + j;

	// All done.

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
// * TestFont ()                                                            *
// **************************************************************************
// * Write out a font test bitmap                                           *
// **************************************************************************
// * Inputs  FNTHDR_T *      Ptr to the font summary info                   *
// *         DATAFNTIDX_T *  Ptr to the font data index                     *
// *         char *          Ptr to string to print                         *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

static	SI                  TestFont                (
								FNTHDR_T *          pcl__F,
								DATAFNTIDX_T *      pcl__I,
								char *              pcz__S)

	{

	// Local Variables.

	DATABLOCK_T *       pcl__D;
	DATABITMAP_T *      pcl__B;

	UB *                pub__B;
	UB *                pub__K;

	SI                  si___X;
	SI                  si___Y;

	UI                  ui___W;
	UI                  ui___H;

	SI                  si___C;


	// Calculate the string's width and height.

	ui___H  = pcl__F->sb___fntYTop + pcl__F->sb___fntYBtm;
	ui___W  = pcl__F->sb___fntXLft + pcl__F->sb___fntXRgt;
	ui___W += CalcWidth(pcl__F, pcl__I, pcz__S);

	if (flFntYDbl) ui___H <<= 1;

	// Allocate a bitmap and set its palette.

	pcl__D = DataBitmapAlloc(640, 480, 8, YES);

	if (pcl__D == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		sprintf(ErrorMessage,
			"(XVERTFNT) Not enough memory for font test bitmap.\n");
		return (-1);
		}

	pcl__B = (DATABITMAP_T *) pcl__D;

	memcpy(pcl__B->acl__bmC, Palette,
		(1 << pcl__B->ui___bmB) * sizeof(RGBQUAD_T));

	// Now draw the test string into the bitmap.

	si___X = pcl__F->sb___fntXLft;
	si___Y = pcl__F->sb___fntYTop - 1;

	while ((si___C = *(UB *) pcz__S) != 0)
		{
		++pcz__S;
		if (si___C == 255)
			{
			si___X  = pcl__F->sb___fntXLft;
			si___Y += pcl__F->sb___fntYTop + pcl__F->sb___fntYBtm + pcl__F->sb___fntYSpc;
			continue;
			}

		if (si___C == '/')
			{
			if ((si___C = *(UB *) pcz__S) == 0) break;
			++pcz__S;
			if (si___C != '/') si___C += 64;
			}

		si___C -= pcl__F->ub___fntChr0;

		if ((si___C < 0) || (si___C >= pcl__F->ub___fntChrN)) break;

		ui___W = pcl__I[si___C].si___fntiDeltaW + pcl__F->sb___fntXSpc;

		if (pcl__F->ub___fntKrnN)
			{
			if (aub__sKrnTbl[si___C] != 0)
				{
				pub__K = aub__sKrnTbl + (((int) aub__sKrnTbl[si___C]) << 1);

				while (pub__K[0] != 0)
					{
					if (pub__K[0] == *((UB *) pcz__S))
						{
						ui___W += ((SB *) pub__K)[1];
						break;
						}
					pub__K += 2;
					}
				}
			}

		if ((si___X + ui___W) > 640)
			{
			si___X  = pcl__F->sb___fntXLft;
			si___Y += pcl__F->sb___fntYTop + pcl__F->sb___fntYBtm + pcl__F->sb___fntYSpc;
			}

		if (si___Y > 400) break;

		pub__B = pcl__B->pub__bmBitmap + ((si___X + pcl__I[si___C].si___fntiXOffset));

		if (flFntYDbl) {
			pub__B += 2 *
				((si___Y + pcl__I[si___C].si___fntiYOffset) * pcl__B->si___bmLineSize);
			} else {
			pub__B +=
				((si___Y + pcl__I[si___C].si___fntiYOffset) * pcl__B->si___bmLineSize);
			}

		DrawFontChr(&pcl__I[si___C], pub__B, pcl__B->si___bmLineSize);

		si___X += ui___W;
		}


	// Write out the finished bitmap.

	if (PcxDumpBitmap(pcl__D, "FONTTEST.PCX") != ERROR_NONE)
		{
		DataFree(pcl__D);
		return (-1);
		}

	// All done.

	DataFree(pcl__D);


	return (ERROR_NONE);

	}



// **************************************************************************
// * CalcWidth ()                                                           *
// **************************************************************************
// * Calculate the width of a string bitmap                                 *
// **************************************************************************
// * Inputs  FNTHDR_T *      Ptr to the font summary info                   *
// *         DATAFNTIDX_T *  Ptr to the font data index                     *
// *         char *          Ptr to string to print                         *
// *                                                                        *
// * Output  SI              Width of string in pixels, or -ve if error     *
// **************************************************************************

static	SI                  CalcWidth               (
								FNTHDR_T *          pcl__F,
								DATAFNTIDX_T *      pcl__I,
								char *              pcz__S)

	{

	// Local Variables.

	UI                  ui___W;
	SI                  si___C;

	UB *                pub__T;

	// Now calculate the length of the string.

	ui___W = 0;

	while ((si___C = *(UB *) pcz__S) != 0)
		{
		++pcz__S;
		si___C -= pcl__F->ub___fntChr0;

		if ((si___C < 0) || (si___C >= pcl__F->ub___fntChrN)) break;

		ui___W += pcl__I[si___C].si___fntiDeltaW + pcl__F->sb___fntXSpc;

		if (pcl__F->ub___fntKrnN)
			{
			if (aub__sKrnTbl[si___C] != 0)
				{
				pub__T = aub__sKrnTbl + (((int) aub__sKrnTbl[si___C]) << 1);
				si___C = *((UB *) pcz__S);

				while (*pub__T != 0)
					{
					if (*pub__T == si___C)
						{
						ui___W += ((SB *) pub__T)[1];
						break;
						}
					pub__T += 2;
					}
				}
			}
		}

	// All done.

	return (ui___W);

	}



// **************************************************************************
// * FindChrPos ()                                                          *
// **************************************************************************
// * Scan for the bitmap character's edges                                  *
// **************************************************************************
// * Inputs  CHRPOS_T *      Ptr to position structure to fill in           *
// *                                                                        *
// * Output  -                                                              *
// **************************************************************************

static	void                FindChrPos              (
								CHRPOS_T *          pcl__Chr)

	{

	// Local Variables.

	SI                  si___X;
	SI                  si___Y;
	UI                  ui___W;
	UI                  ui___H;

	UB *                pub__T;
	SI                  si___T;

	// Look for the left and right edge position override.

	pcl__Chr->si___cpL =
	pcl__Chr->si___cpR = -1;

	if (pcl__Chr->si___cpP >= 0)
		{
		si___X = pcl__Chr->si___cpX;
		pub__T = pcl__Chr->pub__cpB +
			(pcl__Chr->si___cpP * pcl__Chr->ui___cpN) + pcl__Chr->si___cpX;
		si___Y = pcl__Chr->ui___cpW + si___X;

		while (si___X < si___Y)
			{
			if (*pub__T != 0) break;
			pub__T += 1;
			si___X += 1;
			}

		if (si___X < si___Y)
			{
			pcl__Chr->si___cpL = si___X;
			while (si___X < si___Y)
				{
				if (*pub__T != 0) si___T = si___X;
				pub__T += 1;
				si___X += 1;
				}
			pcl__Chr->si___cpR = si___T + 1;
			}

		if (pcl__Chr->si___cpR == pcl__Chr->si___cpL)
			{
			pcl__Chr->si___cpR = -1;
			}
		}

	// Find the top edge.

	si___X = pcl__Chr->si___cpX;

	ui___H = pcl__Chr->ui___cpH;
	si___Y = pcl__Chr->si___cpY;

	while (ui___H)
		{
		ui___W = pcl__Chr->ui___cpW;
		pub__T = pcl__Chr->pub__cpB + (si___Y * pcl__Chr->ui___cpN) + si___X;
		while (ui___W)
			{
			if (*pub__T != 0) goto foundTop;
			pub__T += 1;
			ui___W -= 1;
			}
		si___Y += 1;
		ui___H -= 1;
		}

	foundTop:

	if (ui___H == 0)
		{
		pcl__Chr->si___cpL = 0;
		pcl__Chr->si___cpR = 0;
		pcl__Chr->si___cpX = 0;
		pcl__Chr->si___cpY = 0;
		pcl__Chr->ui___cpW = 0;
		pcl__Chr->ui___cpH = 0;
		return;
		}

	pcl__Chr->si___cpY += (pcl__Chr->ui___cpH - ui___H);
	pcl__Chr->ui___cpH  = ui___H;

	// Find the btm edge.

	ui___H = pcl__Chr->ui___cpH;
	si___Y = pcl__Chr->si___cpY + ui___H - 1;

	while (ui___H)
		{
		ui___W = pcl__Chr->ui___cpW;
		pub__T = pcl__Chr->pub__cpB + (si___Y * pcl__Chr->ui___cpN) + si___X;
		while (ui___W)
			{
			if (*pub__T != 0) goto foundBtm;
			pub__T += 1;
			ui___W -= 1;
			}
		si___Y -= 1;
		ui___H -= 1;
		}

	foundBtm:

	pcl__Chr->ui___cpH = ui___H;

	// Find the lhs edge.

	si___Y = pcl__Chr->si___cpY;

	ui___W = pcl__Chr->ui___cpW;
	si___X = pcl__Chr->si___cpX;

	while (ui___W)
		{
		ui___H = pcl__Chr->ui___cpH;
		pub__T = pcl__Chr->pub__cpB + (si___Y * pcl__Chr->ui___cpN) + si___X;
		while (ui___H)
			{
			if (*pub__T != 0) goto foundLhs;
			pub__T += pcl__Chr->ui___cpN;
			ui___H -= 1;
			}
		si___X += 1;
		ui___W -= 1;
		}

	foundLhs:

	pcl__Chr->si___cpX += (pcl__Chr->ui___cpW - ui___W);
	pcl__Chr->ui___cpW  = ui___W;

	// Find the rhs edge.

	ui___W = pcl__Chr->ui___cpW;
	si___X = pcl__Chr->si___cpX + ui___W - 1;

	while (ui___W)
		{
		ui___H = pcl__Chr->ui___cpH;
		pub__T = pcl__Chr->pub__cpB + (si___Y * pcl__Chr->ui___cpN) + si___X;
		while (ui___H)
			{
			if (*pub__T != 0) goto foundRhs;
			pub__T += pcl__Chr->ui___cpN;
			ui___H -= 1;
			}
		si___X -= 1;
		ui___W -= 1;
		}

	foundRhs:

	pcl__Chr->ui___cpW = ui___W;

	// Set the left and right edge positions if not done before.

	if (pcl__Chr->si___cpL == -1) {
		pcl__Chr->si___cpL = pcl__Chr->si___cpX;
		}

	if (pcl__Chr->si___cpR == -1) {
		pcl__Chr->si___cpR = pcl__Chr->si___cpX + pcl__Chr->ui___cpW;
		}

	// Change lhs & rhs coordinate into offset & width from the base.

	pcl__Chr->si___cpR = pcl__Chr->si___cpR - pcl__Chr->si___cpL;
	pcl__Chr->si___cpL = pcl__Chr->si___cpX - pcl__Chr->si___cpL;

	// All done.

	return;

	}



// **************************************************************************
// * FindCols ()                                                            *
// **************************************************************************
// * Scan the bitmap to divide it into columns                              *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI *            Ptr to buffer to store column coordinates      *
// *         UI *            Ptr to buffer to store column widths           *
// *                                                                        *
// * Output  SI              # of columns, or -ve if an error               *
// **************************************************************************

static	SI                  FindCols                (
								DATABITMAP_T *      pdbiti,
								SI *                psi__ColX,
								UI *                pui__ColW)

	{

	// Local Variables.

	UB *                pub__Pxl;
	UB *                pub__Tmp;

	UI                  ui___Pxl;
	UI                  ui___Tmp;

	SI                  si___BmX;
	UI                  ui___BmW;
	UI                  ui___BmH;
	UI                  ui___Len;

	UI                  ui___Col;

	// Scan the bitmap to locate the columns.

	ui___BmW = pdbiti->ui___bmW;
	ui___BmH = pdbiti->ui___bmH;
	ui___Len = pdbiti->si___bmLineSize;

	pub__Pxl = pdbiti->pub__bmBitmap;
	ui___Pxl = 0;
	si___BmX = 0;
	ui___Col = 0;

	while (si___BmX < (SI) ui___BmW)
		{
		// Search for a non-zero pixel.
		pub__Tmp = pub__Pxl;
		ui___Tmp = ui___BmH;
		while (ui___Tmp) {
			if (*pub__Tmp != 0) break;
			pub__Tmp += ui___Len;
			ui___Tmp -= 1;
			}
		if (ui___Tmp != 0)
			{
			// Start of a column ?
			if (ui___Pxl == 0) {
				ui___Pxl  = 1;
				*psi__ColX = si___BmX;
				}
			} else {
			// End of a column ?
			if (ui___Pxl == 1) {
				ui___Pxl  = 0;
				*pui__ColW++ = si___BmX - *psi__ColX++;
				ui___Col += 1;
				}
			}
		pub__Pxl += 1;
		si___BmX += 1;
		}

	if (ui___Pxl == 1) {
		*pui__ColW++ = si___BmX - *psi__ColX++;
		ui___Col += 1;
		}

	// All done.

	return (ui___Col);

	}



// **************************************************************************
// * FindRows ()                                                            *
// **************************************************************************
// * Scan the bitmap to divide it into rows                                 *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI *            Ptr to buffer to store row coordinates         *
// *         UI *            Ptr to buffer to store row widths              *
// *                                                                        *
// * Output  SI              # of rows, or -ve if an error                  *
// **************************************************************************

static	SI                  FindRows                (
								DATABITMAP_T *      pdbiti,
								SI *                psi__RowY,
								UI *                pui__RowH)

	{

	// Local Variables.

	UB *                pub__Pxl;
	UB *                pub__Tmp;

	UI                  ui___Pxl;
	UI                  ui___Tmp;

	SI                  si___BmY;
	UI                  ui___BmW;
	UI                  ui___BmH;
	UI                  ui___Len;

	UI                  ui___Row;

	// Scan the bitmap to locate the rows.

	ui___BmW = pdbiti->ui___bmW;
	ui___BmH = pdbiti->ui___bmH;
	ui___Len = pdbiti->si___bmLineSize;

	pub__Pxl = pdbiti->pub__bmBitmap;
	ui___Pxl = 0;
	si___BmY = 0;
	ui___Row = 0;

	while (si___BmY < (SI) ui___BmH)
		{
		// Search for a non-zero pixel.
		pub__Tmp = pub__Pxl;
		ui___Tmp = ui___BmW;
		while (ui___Tmp) {
			if (*pub__Tmp != 0) break;
			pub__Tmp += 1;
			ui___Tmp -= 1;
			}
		if (ui___Tmp != 0)
			{
			// Start of a row ?
			if (ui___Pxl == 0) {
				ui___Pxl = 1;
				*psi__RowY = si___BmY;
				}
			} else {
			// End of a row ?
			if (ui___Pxl == 1) {
				ui___Pxl = 0;
				*pui__RowH++ = si___BmY - *psi__RowY++;
				ui___Row++;
				}
			}
		pub__Pxl += ui___Len;
		si___BmY += 1;
		}

	if (ui___Pxl == 1) {
		*pui__RowH++ = si___BmY - *psi__RowY++;
		ui___Row++;
		}

	// All done.

	return (ui___Row);

	}



// **************************************************************************
// * FindLinY ()                                                            *
// **************************************************************************
// * Scan the Y origin marker column to locate the row origin positions     *
// **************************************************************************
// * Inputs  DATABITMAP_T *  Ptr to bitmap                                  *
// *         SI              X coordinate of the marker column              *
// *         SI *            Ptr to buffer to store row origins             *
// *                                                                        *
// * Output  SI              # of rows, or -ve if an error                  *
// **************************************************************************

static	SI                  FindLinY                (
								DATABITMAP_T *      pdbiti,
								SI                  si___X,
								SI *                psi__LinY)

	{

	// Local Variables.

	UB *                pub__Pxl;
	UI                  ui___Pxl;

	SI                  si___BmY;
	UI                  ui___BmW;
	UI                  ui___BmH;
	UI                  ui___Len;

	UI                  ui___Lin;

	// Scan the bitmap to locate the rows.

	ui___BmW = pdbiti->ui___bmW;
	ui___BmH = pdbiti->ui___bmH;
	ui___Len = pdbiti->si___bmLineSize;

	pub__Pxl = pdbiti->pub__bmBitmap + si___X;
	ui___Pxl = 0;
	si___BmY = 0;
	ui___Lin = 0;

	while (si___BmY < (SI) ui___BmH)
		{
		// Search for a non-zero pixel.
		if (*pub__Pxl != 0)
			{
			ui___Pxl = 1;
			}
		else
			{
			if (ui___Pxl == 1)
				{
				ui___Pxl = 0;
				*psi__LinY++ = si___BmY - 1;
				ui___Lin++;
				}
			}
		pub__Pxl += ui___Len;
		si___BmY += 1;
		}

	if (ui___Pxl == 1)
		{
		*psi__LinY++ = si___BmY - 1;
		ui___Lin++;
		}

	*psi__LinY++ = -1;

	// All done.

	return (ui___Lin);

	}



// **************************************************************************
// * AddPxl08ToFNT ()                                                       *
// **************************************************************************
// * Xvert a rectangle within the 8bpp bitmap into a font character         *
// **************************************************************************
// * Inputs  DATAFNTSET_T *  Ptr to font                                    *
// *         CHRPOS_T *      Ptr to source data rectangle information       *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

static	SI                  AddPxl08ToFNT           (
								DATAFNTSET_T *      pcl__Fnt,
								CHRPOS_T *          pcl__Chr)

	{

	//

	DATAFNTIDX_T *      pcl__Idx;

	UB *                pub__B;

	//

	pcl__Idx = pcl__Fnt->acl__fntsBufIndx + pcl__Fnt->ui___fntsCount;
	pub__B   = pcl__Fnt->pbf__fntsBufCur;

	pcl__Idx->pbf__fntiBufPtr  = pub__B;
	pcl__Idx->si___fntiXOffset = pcl__Chr->si___cpL;
	pcl__Idx->si___fntiYOffset = pcl__Chr->si___cpY - pcl__Chr->si___cpB;
	pcl__Idx->ui___fntiWidth   = pcl__Chr->ui___cpW;
	pcl__Idx->ui___fntiHeight  = pcl__Chr->ui___cpH;
	pcl__Idx->si___fntiDeltaW  = pcl__Chr->si___cpR;

	// First convert the character into an intermediate byte-per-nibble
	// format.

	{
	UB *                pub__R;
	UB *                pub__C;
	UB *                pub__N;

	UI                  ui___H;
	UI                  ui___N;

	ui___N = pcl__Chr->ui___cpN;
	pub__R = pcl__Chr->pub__cpB +
		(pcl__Chr->si___cpY * ui___N) + pcl__Chr->si___cpX;

	ui___H = pcl__Chr->ui___cpH;

	while (ui___H)
		{
		// Convert this row (no compression, byte-per-pixel).

		pub__C = pub__R;
		pub__N = pub__C + pcl__Chr->ui___cpW;

		while (pub__C < pub__N)
			{
			if (*pub__C != 255)
				{
				*pub__B++ = *pub__C++;
				}
			else
				{
				*pub__B++ = 0;
				pub__C   += 1;
				}
			}

		// Next row.

		pub__R += ui___N;
		ui___H -= 1;
		}
	}

	// Now align the data end-point.

	while ((((UL) pub__B) & 3) != 0)
		{
		*pub__B++ = 0;
		}

	// Update the font header info.

	pcl__Idx->ul___fntiBufLen = pub__B - pcl__Idx->pbf__fntiBufPtr;
	pcl__Fnt->pbf__fntsBufCur = pub__B;
	pcl__Fnt->ui___fntsCount += 1;

	// All done.

	return (ERROR_NONE);

	}



// **************************************************************************
// * DrawFontChr ()                                                         *
// **************************************************************************
// * Draw a font character into a bitmap                                    *
// **************************************************************************
// * Inputs  DATAFNTIDX_T *  Ptr to font index                              *
// *         UB *            Ptr to destination bitmap                      *
// *         UI              Character number to print                      *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

static	SI                  DrawFontChr             (
								DATAFNTIDX_T *      pcl__I,
								UB *                pub__B,
								UI                  ui___N)

	{

	// Local Variables.

	UB *                pub__S;

	UI                  ui___W;
	UI                  ui___H;

	UB *                pub__P;
	UB                  ub___P;

	//

	pub__S = (UB *) pcl__I->pbf__fntiBufPtr;

	ui___H = pcl__I->ui___fntiHeight;

	while (ui___H--)
		{
		pub__P  = pub__B;
		ui___W  = pcl__I->ui___fntiWidth;

		if (flFntYDbl)
			{
			while (ui___W--)
				{
				ub___P = *pub__S++;
				if (ub___P != 0)
					{
					*(pub__P)          = ub___P;
					*(pub__P + ui___N) = ub___P;
					}
				pub__P += 1;
				}
			pub__B += ui___N << 1;
			}
		else
			{
			while (ui___W--)
				{
				ub___P = *pub__S++;
				if (ub___P != 0)
					{
					*pub__P = ub___P;
					}
				pub__P += 1;
				}
			pub__B += ui___N;
			}
		}

	// All done.

	return (ERROR_NONE);
	}



// **************************************************************************
// * AddPxl08ToFNT ()                                                       *
// **************************************************************************
// * Xvert a rectangle within the 8bpp bitmap into a font character         *
// **************************************************************************
// * Inputs  DATAFNTSET_T *  Ptr to font                                    *
// *         CHRPOS_T *      Ptr to source data rectangle information       *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

/*
static	SI                  AddPxl08ToFNT           (
								DATAFNTSET_T *      pcl__Fnt,
								CHRPOS_T *          pcl__Chr)

	{

	//

	DATAFNTIDX_T *      pcl__Idx;

	UB *                pub__B;

	//

	pcl__Idx = pcl__Fnt->acl__fntsBufIndx + pcl__Fnt->ui___fntsCount;
	pub__B   = pcl__Fnt->pbf__fntsBufCur;

	pcl__Idx->pbf__fntiBufPtr  = pub__B;
	pcl__Idx->si___fntiXOffset = pcl__Chr->si___cpL;
	pcl__Idx->si___fntiYOffset = pcl__Chr->si___cpY - pcl__Chr->si___cpB;
	pcl__Idx->ui___fntiWidth   = pcl__Chr->ui___cpW;
	pcl__Idx->ui___fntiHeight  = pcl__Chr->ui___cpH;
	pcl__Idx->si___fntiDeltaW  = pcl__Chr->si___cpR;

	// First convert the character into an intermediate byte-per-nibble
	// format.

	{
	UB *                pub__R;
	UB *                pub__C;
	UB *                pub__N;

	UI                  ui___H;
	UI                  ui___N;

	UI                  ui___P;

	ui___N = pcl__Chr->ui___cpN;
	pub__R = pcl__Chr->pub__cpB +
		(pcl__Chr->si___cpY * ui___N) + pcl__Chr->si___cpX;

	ui___H = pcl__Chr->ui___cpH;

	while (ui___H)

		{

		// Convert this row.

		pub__C = pub__R;
		pub__N = pub__C + pcl__Chr->ui___cpW;

		// Find out how much blank space is at the start of the row.

		while (pub__C < pub__N)
			{
			if ((*pub__C & 15) != 0) break;
			pub__C++;
			}

		if (pub__C == pub__N)
			{
			// Line is empty, write out a pair of zeroes.

			*pub__B++ = -1;
			*pub__B++ = -1;
			}
		else
			{
			// Write out the line.

			pub__C = pub__R;

			while (pub__C < pub__N)
				{

				// Run of zeros ?

				if ((ui___P = (*pub__C++ & 15)) != 0)
					{
					*pub__B++ = ui___P;
					}
				else
					{
					ui___P = 1;
					while (pub__C < pub__N)
						{
						if ((*pub__C & 15) != 0) break;
						ui___P++;
						pub__C++;
						}
					if (pub__C == pub__N)
						{
						if (ui___P == 1) {
							*pub__B++ = 0;
							} else {
							*pub__B++ = -1;
							*pub__B++ = -1;
							}
						}
					else
						{
						while (ui___P > 17)
							{
							*pub__B++ = -1;
							*pub__B++ = 14;
							ui___P -= 17;
							}
						if (ui___P == 1)
							{
							*pub__B++ = 0;
							}
						else
						if (ui___P == 2)
							{
							*pub__B++ = 0;
							*pub__B++ = 0;
							}
						else
							{
							*pub__B++ = -1;
							*pub__B++ = ui___P-3;
							}
						}
					}
				}
			}

		// Next row.

		pub__R += ui___N;
		ui___H -= 1;

		}
	}

	// Now compress the byte-per-nibble format.

	{
	SB *                psb__N;
	SB *                psb__B;
	UD *                pud__B;
	UI                  ui___D;

	psb__N = (SB *) pub__B;

	psb__N[0] = -1;
	psb__N[1] = -1;
	psb__N[2] = -1;
	psb__N[3] = -1;
	psb__N[4] = -1;
	psb__N[5] = -1;
	psb__N[6] = -1;
	psb__N[7] = -1;

	psb__B = (SB *) pcl__Idx->pbf__fntiBufPtr;
	pud__B = (UD *) psb__B;

	do	{
		ui___D =
			((psb__B[0] + 1) <<  0) |
			((psb__B[1] + 1) <<  4) |
			((psb__B[2] + 1) <<  8) |
			((psb__B[3] + 1) << 12) |
			((psb__B[4] + 1) << 16) |
			((psb__B[5] + 1) << 20) |
			((psb__B[6] + 1) << 24) |
			((psb__B[7] + 1) << 28);
		*pud__B++ = ui___D;

		psb__B += 8;
		} while (psb__B < psb__N);

	pub__B = (UB *) pud__B;
	}

	// Update the font header info.

	pcl__Idx->ul___fntiBufLen = pub__B - pcl__Idx->pbf__fntiBufPtr;
	pcl__Fnt->pbf__fntsBufCur = pub__B;
	pcl__Fnt->ui___fntsCount += 1;

	// All done.

	return (ERROR_NONE);
	}
*/



// **************************************************************************
// * DrawFontChr ()                                                         *
// **************************************************************************
// * Draw a font character into a bitmap                                    *
// **************************************************************************
// * Inputs  DATAFNTIDX_T *  Ptr to font index                              *
// *         UB *            Ptr to destination bitmap                      *
// *         UI              Character number to print                      *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

/*
static	SI                  DrawFontChr             (
								DATAFNTIDX_T *      pcl__I,
								UB *                pub__B,
								UI                  ui___N)

	{

	// Local Variables.

	UI *                pui__D;
	UI                  ui___D;
	UI                  ui___S;

	UI                  ui___W;
	UI                  ui___H;

	UB *                pub__P;
	UI                  ui___P;

	//

	pui__D = (UI *) pcl__I->pbf__fntiBufPtr;

	ui___D = *pui__D++;
	ui___S = 8;

	ui___H = pcl__I->ui___fntiHeight;

	while (ui___H--)
		{
		pub__P  = pub__B;
		ui___W  = pcl__I->ui___fntiWidth;

		while (ui___W--)
			{
			ui___P = ui___D & 15;

			ui___D >>= 4;
			if (--ui___S == 0)
				{
				ui___D = *pui__D++;
				ui___S = 8;
				}

			if (ui___P != 0)
				{
				if (flFntYDbl)
					{
					*(pub__P + ui___N) = ui___P - 1;
					*pub__P++          = ui___P - 1;
					}
					else
					{
					*pub__P++ = ui___P - 1;
					}
				}
			else
				{
				ui___P = ui___D & 15;

				ui___D >>= 4;
				if (--ui___S == 0)
					{
					ui___D = *pui__D++;
					ui___S = 8;
					}

				if (ui___P == 0) break;

				pub__P += ui___P + 2;
				ui___W -= ui___P + 1;
				}
			}

		if (flFntYDbl) {
			pub__B += ui___N << 1;
			} else {
			pub__B += ui___N;
			}
		}

	// All done.

	return (ERROR_NONE);
	}
*/



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTFNT.C
// **************************************************************************
// **************************************************************************
// **************************************************************************