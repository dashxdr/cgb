// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** PCX.C                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Zsoft's PCX format.                                               **
// **                                                                      **
// ** Limitations ...                                                      **
// **                                                                      **
// ** Lots.                                                                **
// **                                                                      **
// ** Only the following file contents are currently understood ...        **
// **                                                                      **
// **   1 bits-per-pixel, 4 plane,  16 colour palette.                     **
// **   8 bits-per-pixel, 1 plane, 256 colour palette.                     **
// **                                                                      **
// ** Last modified : 04 Nov 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
//#include	<io.h>
#include	<assert.h>

#include	"elmer.h"
#include	"data.h"
#include	"pcx.h"

//
// DEFINITIONS
//

// Force byte alignment for the following structures.

#if __ZTC__
#pragma ZTC align 1
#endif

#if __WATCOMC__
#pragma pack (1)
#endif

#if _MSC_VER
#pragma pack(1)
#endif

// PCX file header (128 bytes).

typedef	struct	PCX_HEADER_S
	{
	UB                  ub___pcxFlag;
	UB                  ub___pcxVersion;
	UB                  ub___pcxPacked;
	UB                  ub___pcxBPP;
	UW                  uw___pcxXMin;
	UW                  uw___pcxYMin;
	UW                  uw___pcxXMax;
	UW                  uw___pcxYMax;
	UW                  uw___pcxXDPI;
	UW                  uw___pcxYDPI;
	UB                  ub___pcxPalette[48];
	UB                  ub___pcxReserved;
	UB                  ub___pcxPlanes;
	UW                  uw___pcxBytesPerLine;
	UW                  uw___pcxInterp;
	UW                  uw___pcxVideoX;
	UW                  uw___pcxVideoY;
	UB                  ub___pcxBlank[54];
	} PCX_HEADER_T;

typedef	struct RGB_S
	{
	UB                  ub___r;
	UB                  ub___g;
	UB                  ub___b;
	} RGB;

typedef	struct PCX_PALETTE_S
	{
	RGB                 acl__rgb[256];
	} PCX_PALETTE_T;

// Restore default alignment.

#if __ZTC__
#pragma ZTC align
#endif

#if __WATCOMC__
#pragma pack
#endif

#if _MSC_VER
#pragma pack()
#endif

// Context strucure for holding information about the current status of the
// file being read.

struct	PCX_CONTEXT_S;

typedef	struct PCX_CONTEXT_S
	{
	FILE *                  pcl__pcxFile;		// File handle for this context.
	UI                      ui___pcxWanted;		// Copy of DataType (see elmer.h).
	UI                      ui___pcxReadFrames;	// # of frames read.
	UI                      ui___pcxFileFrames;	// # of frames in the file.
	SL                      sl___pcxFileLength;	// Length of the file.
	UB *                    pbf__pcxFileBuffer;	// Header for the next bitmap.
	} PCX_CONTEXT_T;

//
// STATIC VARIABLES
//

//
// STATIC FUNCTION PROTOTYPES
//

static	ERRORCODE           ConvertFromPCX4RLE      (
								PCX_HEADER_T *      pcl__Header,
								UB *                pub__SrcPtr,
								UB *                pub__SrcEnd,
								UB *                pub__DstPtr,
								UD                  ud___DstOff,
								RGBQUAD_T *         pcl__Palette);

static	ERRORCODE           ConvertFromPCX8RLE      (
								PCX_HEADER_T *      pcl__Header,
								UB *                pub__SrcPtr,
								UB *                pub__SrcEnd,
								UB *                pub__DstPtr,
								UD                  ud___DstOff,
								RGBQUAD_T *         pcl__Palette);

static	UB *                EncodePCX8              (
								UB *                pub__src,
								UB *                pub__dst,
								UI                  ui___width);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * PcxIdentify ()                                                         *
// **************************************************************************
// * Test whether the given file is a PCX file                              *
// **************************************************************************
// * Inputs  FILE *        Ptr to file                                      *
// *                                                                        *
// * Output  FILETYPE_T    FILE_PCX or FILE_UNKNOWN                         *
// *                                                                        *
// * N.B.    The file is left at the beginning with its error flag cleared. *
// **************************************************************************

global	FILETYPE_T          PcxIdentify             (
								FILE *              pcl__File)

	{

	// Local variables.

	FILETYPE_T          t;
	size_t              l;
	PCX_HEADER_T        h;
	int                 i;

	// Assume file is not PCX.

	t = FILE_UNKNOWN;

	// Clear the file's error flag.

	clearerr(pcl__File);

	// Rewind the file.

	if (fseek(pcl__File, 0L, SEEK_SET) == 0)
		{
		// Read the PCX file header.

		l = fread(&h, 1, sizeof(PCX_HEADER_T), pcl__File);

		if (ferror(pcl__File) == 0)
			{

			// Did we read a whole PCX_HEADER_T ?

			if (l == sizeof(PCX_HEADER_T))
				{

				// Check for a version 5 PCX file with RLE compression.

				if ((h.ub___pcxFlag    == 0x0A) &&
					(h.ub___pcxPacked  == 0x01))
					{

					// Check that the last 54 bytes of the header are blank.

					for (i = 0; i < 54; i += 1) {
						if (h.ub___pcxBlank[i] != 0) break;
						}

					if (i == 54) {
						t = FILE_PCX;
						}
					}
				}
			}
		}

	// Leave the file at the beginning.

	fseek(pcl__File, 0, SEEK_SET);

	// Leave the file's error flag cleared.

	clearerr(pcl__File);

	// Return with code.

	return (t);

	}



// **************************************************************************
// * PcxInitRead ()                                                         *
// **************************************************************************
// * Returns to start of file and initializes an PCX reader control block   *
// **************************************************************************
// * Inputs  void **       Ptr to address to use to store input context ptr *
// *         FILE *        Ptr to file                                      *
// *         DATATYPE_T    Mask of data types wanted                        *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    The file is left at the beginning with its error flag cleared. *
// *                                                                        *
// *         Returns to beginning of file and initializes an PCX reader     *
// *         control block. A pointer to this control block is returned.    *
// *         This control block ptr is used by other PCX routines to keep   *
// *         track of what is going on.                                     *
// **************************************************************************

global	ERRORCODE           PcxInitRead             (
								void **             ppcl_Context,
								FILE *              pcl__File,
								DATATYPE_T          ui___Wanted)

	{

	// Local variables.

	PCX_CONTEXT_T *     pcl__Context;

	// Create a new context for this file.

	*ppcl_Context =
	pcl__Context  = (PCX_CONTEXT_T *) malloc(sizeof(PCX_CONTEXT_T));

	if (pcl__Context == NULL)
		{
		return (ErrorCode = ERROR_NO_MEMORY);
		}

	pcl__Context->pcl__pcxFile       = pcl__File;
	pcl__Context->ui___pcxWanted     = ui___Wanted;
	pcl__Context->ui___pcxFileFrames = 0;
	pcl__Context->ui___pcxReadFrames = 0;
	pcl__Context->sl___pcxFileLength = 0;
	pcl__Context->pbf__pcxFileBuffer = NULL;

	// PCX files only hold bitmap data, so we don't need to read the file
	// if the user isn't interested in bitmaps.

	if ((ui___Wanted & DATA_BITMAP) == 0)
		{
		return (ERROR_NONE);
		}

	// Find out the size of the file.

	if (fseek(pcl__File, 0, SEEK_END) != 0) {
		return (ErrorCode = ERROR_IO_SEEK);
		}

	if ((pcl__Context->sl___pcxFileLength = ftell(pcl__File)) < 0) {
		return (ErrorCode = ERROR_IO_SEEK);
		}

	if (fseek(pcl__File, 0, SEEK_SET) != 0) {
		return (ErrorCode = ERROR_IO_SEEK);
		}

	// Allocate space for the file and read it in.

	pcl__Context->pbf__pcxFileBuffer =
		(UB *) malloc(pcl__Context->sl___pcxFileLength);

	if (pcl__Context->pbf__pcxFileBuffer == NULL) {
		return (ErrorCode = ERROR_NO_MEMORY);
		}

	if (fread(pcl__Context->pbf__pcxFileBuffer, 1,
		pcl__Context->sl___pcxFileLength, pcl__File) != (size_t)
		pcl__Context->sl___pcxFileLength) {
		return (ErrorCode = ERROR_IO_READ);
		}

	pcl__Context->ui___pcxFileFrames = 1;

	// Convert the header into the native format.

	#if BYTE_ORDER_HILO
	pcl__Header->uw___pcxXMin =
		XvertD16LOHI(pcl__Header->uw___pcxXMin);
	pcl__Header->uw___pcxYMin =
		XvertD16LOHI(pcl__Header->uw___pcxYMin);
	pcl__Header->uw___pcxXMax =
		XvertD16LOHI(pcl__Header->uw___pcxXMax);
	pcl__Header->uw___pcxYMax =
		XvertD16LOHI(pcl__Header->uw___pcxYMax);
	pcl__Header->uw___pcxBytesPerLine =
		XvertD16LOHI(pcl__Header->uw___pcxBytesPerLine);
	#endif

	// Clear the file's error flag.

	clearerr(pcl__File);

	// Return with the success code.

	return (ERROR_NONE);

	}



// **************************************************************************
// * PcxReadData ()                                                         *
// **************************************************************************
// * Read the next data item from the file                                  *
// **************************************************************************
// * Inputs  void **       Ptr to address of input context                  *
// *                                                                        *
// * Output  DATABLOCK_T * Ptr to data item, or NULL if an error or no data *
// *                                                                        *
// * N.B.    The end of the file is signalled by a return of NULL with an   *
// *         ErrorCode of ERROR_NONE                                        *
// **************************************************************************

global	DATABLOCK_T *       PcxReadData             (
								void **             ppcl_Context)

	{

	// Local variables.

	ERRORCODE           (*pfread)(PCX_HEADER_T *, UB *, UB *, UB *, UI, RGBQUAD_T *);

	PCX_CONTEXT_T *     pcl__Context;
	PCX_HEADER_T *      pcl__Header;
	DATABLOCK_T *       pcl__Data;
	DATABITMAP_T *      pcl__Bitmap;

	UD                  ud___SrcW;
	UD                  ud___SrcH;
	UI                  ui___SrcB;

	UI                  ui___i;

	// Locate the context.

	if (ppcl_Context == NULL) {
		return (NULL);
		}

	pcl__Context = (PCX_CONTEXT_T *) *ppcl_Context;

	if (pcl__Context == NULL) {
		return (NULL);
		}

	// Have we already read the frame ?

	if (pcl__Context->ui___pcxReadFrames == pcl__Context->ui___pcxFileFrames) {
		return (NULL);
		}

	pcl__Context->ui___pcxReadFrames += 1;

	// Check that we can handle this bitmap.

	pcl__Header = (PCX_HEADER_T *) pcl__Context->pbf__pcxFileBuffer;

	ui___i = (pcl__Header->ub___pcxPlanes << 8) + pcl__Header->ub___pcxBPP;

	if ((ui___i != 0x0108) && (ui___i != 0x0401))
		{
		ErrorCode = ERROR_PCX_NOT_HANDLED;
		sprintf(ErrorMessage,
			"(PCX) Unknown variant : cannot read %d planes with %d bpp.\n",
			(UI) pcl__Header->ub___pcxPlanes,
			(UI) pcl__Header->ub___pcxBPP);
		goto errorExit;
		}

	// Get the bitmap's important parameters.

	ud___SrcW = 1 + pcl__Header->uw___pcxXMax - pcl__Header->uw___pcxXMin;
	ud___SrcH = 1 + pcl__Header->uw___pcxYMax - pcl__Header->uw___pcxYMin;
	ui___SrcB = pcl__Header->ub___pcxBPP * pcl__Header->ub___pcxPlanes;

	// Create a native bitmap of the required size.

	pcl__Data = DataBitmapAlloc(ud___SrcW, ud___SrcH, ui___SrcB, NO);

	if (pcl__Data == NULL) {
		goto errorExit;
		}

	pcl__Bitmap = (DATABITMAP_T *) pcl__Data;

	// If we have both width and height, then lets try to actually convert
	// the bitmap data.

	if ((ud___SrcW != 0) && (ud___SrcH != 0))
		{
		// Call ConvertFromPCXRLE() to do the actual conversion, this routine
		// could do with being written in assembler for greater speed.

		if      (ui___i == 0x0401) pfread = ConvertFromPCX4RLE;
		else if (ui___i == 0x0108) pfread = ConvertFromPCX8RLE;

		if ((*pfread)(
			pcl__Header,
			pcl__Context->pbf__pcxFileBuffer + 128,
			pcl__Context->pbf__pcxFileBuffer + pcl__Context->sl___pcxFileLength,
			pcl__Bitmap->pub__bmBitmap,
			pcl__Bitmap->si___bmLineSize,
			pcl__Bitmap->acl__bmC) != ERROR_NONE)
			{
			DataFree(pcl__Data);
			ErrorCode = ERROR_PCX_MALFORMED;
			sprintf(ErrorMessage,
				"(PCX) File malformed : error in RLE bitmap data.\n");
			goto errorExit;
			}
		}

	// Return the bitmap.

	return (pcl__Data);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * PcxQuitRead ()                                                         *
// **************************************************************************
// * Aborts reading from the context, and frees up all memory used          *
// **************************************************************************
// * Inputs  void **       Ptr to address of input context                  *
// *                                                                        *
// * Output  FILE *        Returns the FILE * for this context              *
// *                                                                        *
// * N.B.    This function MUST be called when you are finished with an     *
// *         PCX file or else the memory blocks will not be freed.          *
// *                                                                        *
// *         Note that this function does NOT close the file itself, it     *
// *         returns the FILE * so that you can do that.                    *
// **************************************************************************

global	FILE *              PcxQuitRead             (
								void **             ppcl_Context)

	{

	// Local variables.

	PCX_CONTEXT_T *     pcl__Context;
	FILE *				pcl__File;

	// Locate the context.

	if (ppcl_Context == NULL) {
		return (NULL);
		}

	pcl__Context  = (PCX_CONTEXT_T *) *ppcl_Context;
	*ppcl_Context = NULL;

	if (pcl__Context == NULL) {
		return (NULL);
		}

	// Extract the file pointer, and destroy the context.

	pcl__File = pcl__Context->pcl__pcxFile;

	if (pcl__Context->pbf__pcxFileBuffer != NULL) {
		free(pcl__Context->pbf__pcxFileBuffer);
		}

	free(pcl__Context);

	return (pcl__File);

	}



// **************************************************************************
// * PcxDumpBitmap ()                                                       *
// **************************************************************************
// * Writes out the bitmap (in PCX format) with the given filename          *
// **************************************************************************
// * Inputs  DATABLOCK_T *   Ptr to bitmap datablock                        *
// *         char *          Ptr to filename                                *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// **************************************************************************

global	ERRORCODE           PcxDumpBitmap           (
								DATABLOCK_T *       d,
								char *              filename)

	{

	// Local variables.

	FILE *              f;
	DATABITMAP_T *      b;

	UI                  o;
	UI                  i;

	UI                  ui___W;
	UI                  ui___H;
	UI                  ui___L;

	UB *                pub__Bitmap;
	UB *                pub__PlaneBuf;
	UB *                pub__PlanePtr;

	PCX_HEADER_T        cl___Header;

	UB *                pub__Palette;
	UB                  aub__Palette[769];

	// Is it really a bitmap ?

	if (d->type != DATA_BITMAP)
		{
		ErrorCode = ERROR_DATA_UNKNOWN;
		goto errorExit;
		}

	b = (DATABITMAP_T *) d;

	// Make sure that its an 8 BPP bitmap.

	if (b->ui___bmB != 8)
		{
		ErrorCode = ERROR_PCX_NOT_HANDLED;
		sprintf(ErrorMessage,
			"(PCX) Variant not handled : cannot dump %d bpp data.\n",
			(UI) b->ui___bmB);
		goto errorExit;
		}

	// If the bitmap is stored bottom to top then invert it.

	o = b->ui___bmF;

	if ((o & BM_TOP2BTM) == 0)
		{
		if (DataBitmapInvert(d) != ERROR_NONE) goto errorExit;
		}

	// Fill in the PCX file header.

	ui___W = b->ui___bmW  - 1;
	ui___H = b->ui___bmH - 1;
	ui___L = (b->ui___bmW + 1) & ~1;

	memset(&cl___Header, 0, sizeof(PCX_HEADER_T));

	cl___Header.ub___pcxFlag         = 0x0A;
	cl___Header.ub___pcxVersion      = 5;
	cl___Header.ub___pcxPacked       = 1;
	cl___Header.ub___pcxBPP          = 8;
	cl___Header.uw___pcxXMin         = 0;
	cl___Header.uw___pcxYMin         = 0;
	cl___Header.uw___pcxXMax         = XvertD16LOHI(ui___W);
	cl___Header.uw___pcxYMax         = XvertD16LOHI(ui___H);
	cl___Header.uw___pcxXDPI         = XvertD16LOHI(72);
	cl___Header.uw___pcxYDPI         = XvertD16LOHI(72);
	cl___Header.ub___pcxPlanes       = 1;
	cl___Header.uw___pcxBytesPerLine = XvertD16LOHI(ui___L);
	cl___Header.uw___pcxInterp       = 0;
	cl___Header.uw___pcxVideoX       = 0;
	cl___Header.uw___pcxVideoY       = 0;

	ui___W += 1;
	ui___H += 1;

	// Fill in the palette data.

	pub__Palette = &aub__Palette[0];

	*pub__Palette++ = 0x0Cu;

	for (i = 0; i != 256; i += 1)
		{
		pub__Palette[0] = b->acl__bmC[i].ub___rgbR;
		pub__Palette[1] = b->acl__bmC[i].ub___rgbG;
		pub__Palette[2] = b->acl__bmC[i].ub___rgbB;
		pub__Palette   += 3;
		}

	// Allocate a buffer for encoding a plane.

	pub__PlaneBuf = malloc(ui___W * 2);

	if (pub__PlaneBuf == NULL) {
		ErrorCode = ERROR_NO_MEMORY;
		goto errorExit;
		}

	// Write it out.

	f = fopen(filename, "wb");

	if (f == NULL) {
		goto errorWrite;
		}

	if (fwrite(&cl___Header, 1, sizeof(PCX_HEADER_T), f) != sizeof(PCX_HEADER_T)) {
		ErrorCode = ERROR_IO_WRITE;
		goto errorClose;
		}

	pub__Bitmap = b->pub__bmBitmap;

	while (ui___H)
		{
		pub__PlanePtr = EncodePCX8(pub__Bitmap, pub__PlaneBuf, ui___L);

		i = pub__PlanePtr - pub__PlaneBuf;

		if (fwrite(pub__PlaneBuf, 1, i, f) != i) {
			ErrorCode = ERROR_IO_WRITE;
			goto errorClose;
			}

		pub__Bitmap += b->si___bmLineSize;
		ui___H      -= 1;
		}

	if (fwrite(aub__Palette, 1, 769, f) != 769) {
		ErrorCode = ERROR_IO_WRITE;
		goto errorClose;
		}

	if (fclose(f) != 0) {
		goto errorWrite;
		}

	// Free up the plane buffer.

	free(pub__PlaneBuf);

	// If the bitmap was originally stored bottom to top then restore it to
	// that orientation.

	if ((o & BM_TOP2BTM) == 0)
		{
		if (DataBitmapInvert(d) != ERROR_NONE) goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorClose:

		fclose(f);

	errorWrite:

		ErrorCode = ERROR_IO_WRITE;

		free(pub__PlaneBuf);

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * ConvertFromPCX4RLE ()                                                  *
// **************************************************************************
// * Convert the PCX RLE data into DIB data                                 *
// **************************************************************************
// * Inputs  PCX_HEADER_T *  Ptr to PCX header                              *
// *         UB *            Ptr to start of RLE src                        *
// *         UB *            Ptr to end   of RLE src                        *
// *         UB *            Destination buffer                             *
// *         UI              Destination buffer width                       *
// *         RGBQUAD_T *     Ptr to colour palette                          *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    ErrorCode and ErrorMessage are NOT set on failure.             *
// **************************************************************************

static	ERRORCODE           ConvertFromPCX4RLE      (
								PCX_HEADER_T *      pcl__Header,
								UB *                pub__SrcPtr,
								UB *                pub__SrcEnd,
								UB *                pub__DstPtr,
								UI                  ui___DstOff,
								RGBQUAD_T *         pcl__Palette)

	{

	// Local variables.

	UB *                pub__DstCol;
	UI                  ui___SrcOff;
	UI                  ui___DstRhs;
	SI                  si___SrcW;
	SI                  si___SrcH;
	UB                  ub___Byte;
	UB                  ub___Rept;

	UI                  ui___i;

	// Calculate source line width and destination RHS edge size.

	ui___SrcOff = pcl__Header->uw___pcxBytesPerLine;
	ui___DstRhs = ui___DstOff - ui___SrcOff;

	// Now read in the frame.

	si___SrcH = 1 + pcl__Header->uw___pcxYMax - pcl__Header->uw___pcxYMin;

	do	{
		pub__DstCol  = pub__DstPtr;
		pub__DstPtr += ui___DstOff;
		si___SrcW    = ui___SrcOff;

		do	{
			ub___Byte = *pub__SrcPtr++;
			if ((ub___Byte & 0xC0u) != 0xC0u) {
				*pub__DstCol++ = ub___Byte;
				si___SrcW     -= 1;
				}
			else {
				ub___Rept = (ub___Byte & 0x3Fu);
				ub___Byte = *pub__SrcPtr++;
				if ((si___SrcW -= ub___Rept) < 0) goto errorExit;
				do	{
					*pub__DstCol++ = ub___Byte;
					} while (--ub___Rept);
				}
			} while (si___SrcW >= 0);

		if (ui___DstRhs != 0) {
			memset(pub__DstCol, 0, ui___DstRhs);
			}
		si___SrcH -= 1;
		} while (si___SrcH != 0);

	// Colour palette present ?

	if (pcl__Header->ub___pcxVersion != 3)
		{
		pub__SrcPtr = pcl__Header->ub___pcxPalette;
		for (ui___i = 16; ui___i != 0; ui___i -= 1)
			{
			pcl__Palette->ub___rgbA = 0;
			pcl__Palette->ub___rgbR = pub__SrcPtr[0];
			pcl__Palette->ub___rgbG = pub__SrcPtr[1];
			pcl__Palette->ub___rgbB = pub__SrcPtr[2];
			pub__SrcPtr  += 3;
			pcl__Palette += 1;
			}
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (~ERROR_NONE);

	}



// **************************************************************************
// * ConvertFromPCX8RLE ()                                                  *
// **************************************************************************
// * Convert the PCX RLE data into DIB data                                 *
// **************************************************************************
// * Inputs  PCX_HEADER_T *  Ptr to PCX header                              *
// *         UB *            Ptr to start of RLE src                        *
// *         UB *            Ptr to end   of RLE src                        *
// *         UB *            Destination buffer                             *
// *         UI              Destination buffer width                       *
// *         RGBQUAD_T *     Ptr to colour palette                          *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    ErrorCode and ErrorMessage are NOT set on failure.             *
// **************************************************************************

static	ERRORCODE           ConvertFromPCX8RLE      (
								PCX_HEADER_T *      pcl__Header,
								UB *                pub__SrcPtr,
								UB *                pub__SrcEnd,
								UB *                pub__DstPtr,
								UI                  ui___DstOff,
								RGBQUAD_T *         pcl__Palette)

	{

	// Local variables.

	UB *                pub__DstCol;
	UI                  ui___SrcOff;
	UI                  ui___DstRhs;
	SI                  si___SrcW;
	SI                  si___SrcH;
	UB                  ub___Byte;
	UB                  ub___Rept;

	UI                  ui___i;

	// Calculate source line width and destination RHS edge size.

	ui___SrcOff = pcl__Header->uw___pcxBytesPerLine;
	ui___DstRhs = ui___DstOff - ui___SrcOff;

	// Now read in the frame.

	si___SrcH = 1 + pcl__Header->uw___pcxYMax - pcl__Header->uw___pcxYMin;

	do	{
		pub__DstCol  = pub__DstPtr;
		pub__DstPtr += ui___DstOff;
		si___SrcW    = ui___SrcOff;

		do	{
			ub___Byte = *pub__SrcPtr++;
			if ((ub___Byte & 0xC0u) != 0xC0u) {
				*pub__DstCol++ = ub___Byte;
				si___SrcW     -= 1;
				}
			else {
				ub___Rept = (ub___Byte & 0x3Fu);
				ub___Byte = *pub__SrcPtr++;
				if ((si___SrcW -= ub___Rept) < 0) goto errorExit;
				do	{
					*pub__DstCol++ = ub___Byte;
					} while (--ub___Rept);
				}
//			} while (si___SrcW >= 0);
			} while (si___SrcW > 0);

		if (ui___DstRhs != 0) {
			memset(pub__DstCol, 0, ui___DstRhs);
			}
		si___SrcH -= 1;
		} while (si___SrcH != 0);

	// Colour palette present ?

	if (pub__SrcPtr == (pub__SrcEnd - 769))
		{
		if (*pub__SrcPtr++ == 0x0Cu)
			{
			for (ui___i = 256; ui___i != 0; ui___i -= 1)
				{
				pcl__Palette->ub___rgbA = 0;
				pcl__Palette->ub___rgbR = pub__SrcPtr[0];
				pcl__Palette->ub___rgbG = pub__SrcPtr[1];
				pcl__Palette->ub___rgbB = pub__SrcPtr[2];
				pub__SrcPtr  += 3;
				pcl__Palette += 1;
				}
			}
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (~ERROR_NONE);

	}



// **************************************************************************
// * EncodePCX8 ()                                                          *
// **************************************************************************
// * RLE compress a bitplane                                                *
// **************************************************************************
// * Inputs  UB *            Ptr to src                                     *
// *         UB *            Ptr to dst                                     *
// *         UI              Width                                          *
// *                                                                        *
// * Output  UB *            Updated ptr to dst, or NULL if an error        *
// **************************************************************************

static	UB *                EncodePCX8              (
								UB *                pub__src,
								UB *                pub__dst,
								UI                  ui___width)

	{

	UB *                pub__tmp;
	UB                  ub___value;
	UI                  ui___count;
	UI                  ui___limit;

	// Now encode and write out the line.

	while (ui___width)

		{
		// Find out how many repeats there are of the current pixel.

		pub__tmp   = pub__src;
		ub___value = *pub__tmp++;
		ui___count = 1;
		ui___limit = ui___width;

		if (ui___limit > 63) ui___limit = 63;

		while (ui___count < ui___limit) {
			if (*pub__tmp++ != ub___value) break;
			ui___count += 1;
			}

		// Write out the value byte or repeat/value pair.

		if ((ui___count > 1) || (ub___value > 191)) {
			*pub__dst++ = ui___count | 0xC0u;
			}

		*pub__dst++ = ub___value;

		// Advance the source pointers.

		pub__src   += ui___count;
		ui___width -= ui___count;
		}

	// Return with success.

	return (pub__dst);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF PCX.C
// **************************************************************************
// **************************************************************************
// **************************************************************************

