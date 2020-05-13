// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** IFF.C                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Electronic Arts' IFF format.                                      **
// **                                                                      **
// ** The following IFF FORMs are supported ...                            **
// **                                                                      **
// ** FORM ANIM                                                            **
// ** FORM ILBM                                                            **
// ** FORM PBM                                                             **
// **                                                                      **
// ** Complex IFF files containing LIST, PROP and CAT groups are correctly **
// ** supported.                                                           **
// **                                                                      **
// ** Limitations ...                                                      **
// **                                                                      **
// ** Lots.                                                                **
// **                                                                      **
// ** PBMs are working (IBM DPaint/DAnim) but I never bothered to get the  **
// ** ILBM code finished (Amiga DPaint/DAnim).                             **
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
#include	"iff.h"

#include	"pcx.h"

//
// DEFINITIONS
//

#define	IFFPRINT	0

//

#define	WordAlign(size) ((size+1)&(~1L))

//

#define	anhd ((ANHDCHUNK *)(c->data))
#define	bmhd ((BMHDCHUNK *)(c->data))
#define	grab ((GRABCHUNK *)(c->data))
#define	dest ((DESTCHUNK *)(c->data))

// IFF GROUP IDs

#define ID4_FORM MakeID4('F','O','R','M')
#define ID4_PROP MakeID4('P','R','O','P')
#define ID4_LIST MakeID4('L','I','S','T')
#define ID4_CAT  MakeID4('C','A','T',' ')

// IFF FORM IDs

#define ID4_ILBM MakeID4('I','L','B','M')
#define ID4_PBM  MakeID4('P','B','M',' ')
#define ID4_ANIM MakeID4('A','N','I','M')

// IFF FORM.ILBM/FORM.PBM chunk IDs

#define ID4_BMHD MakeID4('B','M','H','D')
#define ID4_DEST MakeID4('D','E','S','T')
#define ID4_CMAP MakeID4('C','M','A','P')
#define ID4_GRAB MakeID4('G','R','A','B')
#define ID4_BODY MakeID4('B','O','D','Y')

// IFF FORM.ANIM chunk IDs

#define ID4_ANHD MakeID4('A','N','H','D')
#define ID4_DLTA MakeID4('D','L','T','A')

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

// IFF 'chunk' structure.

typedef	struct CHUNKHEADER_S
	{
	ID4                 ckID;
	SD                  ckSize;
	} CHUNKHEADER;

// IFF 'group' structure.

typedef	struct GROUPHEADER_S
	{
	ID4                 ckID;
	SD                  ckSize;
	ID4                 groupSubID;
	} GROUPHEADER;

// IFF header for holding chunks in memory.

struct	IFFBLOCK_S;

typedef	struct IFFHEADER_S
	{
	struct IFFBLOCK_S * link;
	UI                  depth;
	CHUNKHEADER         head;
	} IFFHEADER;

typedef	struct IFFBLOCK_S
	{
	IFFHEADER           head;
	UB                  data[1];
	} IFFBLOCK;

// IFF ILBM.BMHD structure.

#define	mskNone                0
#define mskHasMask             1
#define mskHasTransparentColor 2
#define mskLasso               3

#define cmpNone                0
#define cmpByteRun1            1

typedef	struct BMHDCHUNK_S
	{
	UW                 w;					// image width  in pixels
	UW                 h;					// image height in pixels
	SW                 x;					// x position for this image
	SW                 y;					// y position for this image
	UB                 nPlanes;				// # source bitplanes
	UB                 masking;				// masking technique
	UB                 compression;			// compression algorithm
	UB                 pad1;				// UNUSED (set to 0)
	UW                 transparentColor;	// transparent "color number"
	UB                 xAspect;				// x aspect ratio, a rational num xy
	UB                 yAspect;				// y aspect ratio, a rational num xy
	SW                 pageW;				// source "page" size in pixels
	SW                 pageH;
	} BMHDCHUNK;

// IFF ILBM.CMAP chunk.

typedef	struct RGB_S
	{
	UB                 red;
	UB                 green;
	UB                 blue;
	} RGB;

typedef	struct CMAPCHUNK_S
	{
	RGB                 rgbColor[1];
	} CMAPCHUNK;

// IFF ILBM.GRAB chunk.

typedef	struct GRABCHUNK_S
	{
	SW                 xOffset;
	SW                 yOffset;
	} GRABCHUNK;

// IFF ILBM.DEST chunk.

typedef	struct DESTCHUNK_S
	{
	UB                 depth;				// # of bitplanes in the original source
	UB                 pad1;				// UNUSED (set to 0)
	UW                 planePick;			// how to scatter source into destination
	UW                 planeOnOff;			// default bitplane data for planePick
	UW                 planeMask;			// selects which bitplanes to store into
	} DESTCHUNK;

// IFF ILBM.BODY chunk.

typedef	struct BODYCHUNK_S
	{
	UB                 data[1];
	} BODYCHUNK;

// IFF ANIM.ANHD chunk.

#define	ANHD_OP_SET            0
#define ANHD_OP_XOR            1
#define ANHD_OP_SHORT_DELTA    2
#define ANHD_OP_LONG_DELTA     3
#define ANHD_OP_BOTH_DELTA     4
#define ANHD_OP_BYTE_DELTA     5
#define ANHD_OP_ERIC_DELTA     74
#define ANHD_OP_EADA_DELTA     75

#define ANHD_BITS_SHORT_DATA   0x00000000L
#define ANHD_BITS_LONG_DATA    0x00000001L
#define ANHD_BITS_SET          0x00000000L
#define ANHD_BITS_XOR          0x00000002L
#define ANHD_BITS_PLANAR       0x00000000L
#define ANHD_BITS_LINEAR       0x00000004L
#define ANHD_BITS_NORMAL       0x00000000L
#define ANHD_BITS_RLC          0x00000008L
#define ANHD_BITS_HORIZONTAL   0x00000000L
#define ANHD_BITS_VERTICAL     0x00000010L
#define ANHD_BITS_SHORT_OFFSET 0x00000000L
#define ANHD_BITS_LONG_OFFSET  0x00000020L

typedef	struct ANHDCHUNK_S
	{
	UB                 operation;		// compression method
	UB                 mask;			// mask of which planes are used
	UW                 w;				// image width  in pixels
	UW                 h;				// image height in pixels
	SW                 x;				// x position for this image
	SW                 y;				// y position for this image
	UD                 absTime;			// timing w.r.t. 1st  frame in 1/60 sec (unused)
	UD                 relTime;			// timing w.r.t. last frame in 1/60 sec
	UB                 interleave;		// delta w.r.t. n frames back (0 == 2 frames back)
	UB                 pad0;			// UNUSED (set to 0)
	UD                 bits;			// options bits used by operations 4 and 5
	UB                 pad[16];			// UNUSED (set to 0)
	} __attribute__ ((packed)) ANHDCHUNK;

// IFF ANHD.DLTA chunk.

typedef	struct DLTACHUNK_S
	{
	UB                 data[1];
	} DLTACHUNK;

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

struct	IFFCONTEXT_S;

typedef	struct IFFCONTEXT_S
	{
	struct IFFCONTEXT_S *   oldContext;		// Pointer to previous context.
	FILE *                  file;			// File handle for this context.
	UI                      dataType;		// Copy of DataType (see elmer.hpp).
	UI                      groupDepth;		// Current nesting level within file.
	ID4                     groupID;		// Current group ID.
	ID4                     groupSubID;		// Current group sub ID.
	SL                      groupCurPos;	// Current absolute file position.
	SL                      groupEndPos;	// End of group absoulute file position.
	FL                      propFlag;		// YES/NO if a PROP group is allowed.
	struct IFFCONTEXT_S *   animContext;	// Pointer to FORM ANIM context.
	DATABLOCK_T *           animMinus2;		// Pointer to ANIM bitmap 2 frames ago.
	DATABLOCK_T *           animMinus1;		// Pointer to ANIM bitmap 1 frame ago.

	IFFBLOCK *              blkILBMBMHD;	// Pointers to all possible chunks that
	IFFBLOCK *              blkILBMCMAP;	// could be loaded for an ILBM.
	IFFBLOCK *              blkILBMGRAB;
	IFFBLOCK *              blkILBMDEST;
	IFFBLOCK *              blkILBMBODY;
	IFFBLOCK *              blkILBMANHD;
	IFFBLOCK *              blkILBMDLTA;

	IFFBLOCK *              blkPBMBMHD;		// Pointers to all possible chunks that
	IFFBLOCK *              blkPBMCMAP;		// could be loaded for a PBM.
	IFFBLOCK *              blkPBMGRAB;
	IFFBLOCK *              blkPBMDEST;
	IFFBLOCK *              blkPBMBODY;
	IFFBLOCK *              blkPBMANHD;
	IFFBLOCK *              blkPBMDLTA;
	} IFFCONTEXT;

//
// STATIC VARIABLES
//

static	CHUNKHEADER         C;

//
// STATIC FUNCTION PROTOTYPES
//

static	DATABLOCK_T *       ConvertFromILBM         (
								IFFCONTEXT *        context);

static	DATABLOCK_T *       ConvertFromPBM          (
								IFFCONTEXT *        context);

static	ERRORCODE           ConvertFromPBMBODY      (
								UB *               srcptr,
								UB *               srcend,
								UB *               dstptr,
								UD                 dstoff,
								UD                 srcw,
								UD                 srch,
								UD                 srcb,
								UD                 srcc);

static	ERRORCODE           ConvertFromPBMDLTA      (
								UB *               srcptr,
								UB *               srcend,
								UB *               dstptr,
								UD                 dstoff,
								UD                 srcw,
								UD                 srch);

static	ERRORCODE           ReadILBMChunk           (
								IFFCONTEXT *        context);

static	ERRORCODE           ReadPBMChunk            (
								IFFCONTEXT *        context);

static	size_t              ReadChunkHead           (
								IFFCONTEXT *        context);

static	IFFBLOCK *          ReadChunk               (
								IFFCONTEXT *        context);

static	ERRORCODE           SkipChunk               (
								IFFCONTEXT *        context);

static	void                InheritContext          (
								IFFCONTEXT *        curcontext);

static	void                InheritChunks           (
								IFFBLOCK *          blk,
								UI                  depth);

static	void                FreeContext             (
								IFFCONTEXT *        context);

static	void                FreeChunk               (
								IFFBLOCK *          chunk,
								UI                  depth);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * IffIdentify ()                                                         *
// **************************************************************************
// * Test whether the given file is an IFF file                             *
// **************************************************************************
// * Inputs  FILE *        Ptr to file                                      *
// *                                                                        *
// * Output  FILETYPE_T    FILE_IFF or FILE_UNKNOWN                         *
// *                                                                        *
// * N.B.    The file is left at the beginning with its error flag cleared. *
// **************************************************************************

global	FILETYPE_T          IffIdentify             (
								FILE *              pcl__File)

	{

	// Local variables.

	FILETYPE_T          t;
	size_t              l;

	// Assume file is not IFF.

	t = FILE_UNKNOWN;

	// Clear the file's error flag.

	clearerr(pcl__File);

	// Rewind the file.

	if (fseek(pcl__File, 0L, SEEK_SET) == 0)

		{

		// Read the first chunk header.

		l = fread(&C, 1, sizeof(CHUNKHEADER), pcl__File);

		if (ferror(pcl__File) == 0)

			{

			// Did we read a whole CHUNKHEADER ?

			if (l == sizeof(CHUNKHEADER))

				{

				// Convert from MC68000 byte ordering.

				#if BYTE_ORDER_LO_HI
					C.ckSize = SwapD32(C.ckSize);
				#endif

				// Chunk ID of FORM, LIST or CAT ?

				if ((C.ckID == ID4_FORM) || (C.ckID == ID4_LIST) || (C.ckID == ID4_CAT))

					{

					// Chunk size of >= 4 and < 16MB ?  (The check for < 16MB will stop
					// the false recognition of a text file.)

					if ((C.ckSize >= 4) && (C.ckSize < 0x01000000L))

						{

						// Looks like its an IFF file.

						t = FILE_IFF;

						}

					}

				}

			}

		}

	// Leave the file at the beginning.

	fseek(pcl__File, 0L, SEEK_SET);

	// Leave the file's error flag cleared.

	clearerr(pcl__File);

	// Return with code.

	return (t);

	}



// **************************************************************************
// * IffInitRead ()                                                         *
// **************************************************************************
// * Returns to start of file and initializes an IFF reader control block   *
// **************************************************************************
// * Inputs  void **       Ptr to address to use to store input context ptr *
// *         FILE *        Ptr to file                                      *
// *         DATATYPE_T    Mask of data types wanted                        *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    The file is left at the beginning with its error flag cleared. *
// *                                                                        *
// *         Returns to beginning of file and initializes an IFF reader     *
// *         control block. A pointer to this control block is returned.    *
// *         This control block ptr is used by other IFF routines to keep   *
// *         track of what is going on.                                     *
// **************************************************************************

global	ERRORCODE           IffInitRead             (
								void **             ppcl_Context,
								FILE *              pcl__File,
								DATATYPE_T          ui___Wanted)

	{

	// Local variables.

	register	IFFCONTEXT * context;


	// Create a new GroupContext.

	*ppcl_Context = (context = malloc(sizeof(IFFCONTEXT)));


	if (context == NULL)
		{
		return (ErrorCode = ERROR_NO_MEMORY);
		}

	context->oldContext		= NULL;
	context->file			= pcl__File;
	context->dataType		= ui___Wanted;
	context->groupDepth		= 0;
	context->groupID		= 0;
	context->groupSubID		= 0;
	context->groupCurPos	= 0;
	context->groupEndPos	= 0;

	context->propFlag		= NO;

	context->animContext	= NULL;
	context->animMinus2		= NULL;
	context->animMinus1		= NULL;

	context->blkILBMBMHD	= NULL;
	context->blkILBMCMAP	= NULL;
	context->blkILBMGRAB	= NULL;
	context->blkILBMDEST	= NULL;
	context->blkILBMBODY	= NULL;
	context->blkILBMANHD	= NULL;
	context->blkILBMDLTA	= NULL;

	context->blkPBMBMHD		= NULL;
	context->blkPBMCMAP		= NULL;
	context->blkPBMGRAB		= NULL;
	context->blkPBMDEST		= NULL;
	context->blkPBMBODY		= NULL;
	context->blkPBMANHD		= NULL;
	context->blkPBMDLTA		= NULL;

	// Clear the file's error flag.

	clearerr(pcl__File);

	// Rewind the file.

	if (fseek(pcl__File, 0L, SEEK_SET) != 0)
		{
		return (ErrorCode = ERROR_IO_SEEK);
		}

	// Return with the success code.

	return (ERROR_NONE);

	}



// **************************************************************************
// * IffReadData ()                                                         *
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

global	DATABLOCK_T *       IffReadData             (
								void **             ppcl_Context)

	{

	// Local variables.

	IFFCONTEXT *        oldcontext;
	IFFCONTEXT *        curcontext;
	size_t              l;
//	IFFBLOCK *          c;
	DATABLOCK_T *       d;

	//

	d = NULL;

	// Use an infinite while loop to read in successive chunks until there is
	// either an error, the end of the file, or a valid data object.

	while (1)

		{

		// Get the current context.

		curcontext = (IFFCONTEXT *) *ppcl_Context;

		// If we are at the start of the file, or if we are not at the end of a
		// group, then read in the next chunk/group header.
		// This check is needed in case two nested groups end at the same point.

		if ((curcontext->groupCurPos == 0) ||
				(curcontext->groupCurPos != curcontext->groupEndPos))

			{

			// Read the next chunk header.

			if (ReadChunkHead(curcontext) == 0)
				{
				if ((ErrorCode == ERROR_NONE) &&
						(curcontext->groupCurPos != curcontext->groupEndPos))
					{
					ErrorCode = ERROR_IFF_TRUNCATED;
					sprintf(ErrorMessage,
						"(IFF) File truncated at 0x%08.8lX : incomplete chunk header.\n",
						(UL) curcontext->groupCurPos);
					}
				goto errorExit;
				}

			// Is it a new group ?

			if ((C.ckID == ID4_FORM) || (C.ckID == ID4_LIST) ||
					(C.ckID == ID4_PROP) || (C.ckID == ID4_CAT))

				{

				// Is this group allowed here ?

				if ((C.ckID == ID4_PROP) && (curcontext->propFlag == NO))
					{
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
						"(IFF) File malformed at 0x%08.8lX : illegally positioned PROP group.\n",
						(UL) curcontext->groupCurPos - sizeof(CHUNKHEADER));
					goto errorExit;
					}

				if ((C.ckID != ID4_FORM) && (curcontext->animContext != NULL))
					{
					*(ID4 *)ID4String = C.ckID;
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
						"(IFF) File malformed at 0x%08.8lX : illegal group %s within ANIM.\n",
						(UL) curcontext->groupCurPos - sizeof(CHUNKHEADER),
						ID4String);
					goto errorExit;
				}

				// Allocate new context.

				oldcontext = curcontext;

				curcontext = malloc(sizeof(IFFCONTEXT));

				if (curcontext == NULL)
					{
					ErrorCode = ERROR_NO_MEMORY;
					goto errorExit;
					}

				memcpy(curcontext, oldcontext, sizeof(IFFCONTEXT));

				curcontext->oldContext	= oldcontext;
				curcontext->groupDepth	= curcontext->groupDepth + 1;
				curcontext->groupID			= C.ckID;
				curcontext->groupEndPos	= curcontext->groupCurPos + WordAlign(C.ckSize);

				*ppcl_Context = curcontext;

				// Read group sub ID.

				l = fread(&(curcontext->groupSubID), 1, sizeof(ID4), curcontext->file);

				if (ferror(curcontext->file))
					{
					ErrorCode = ERROR_IO_READ;
					goto errorExit;
					}

				if (l < sizeof(ID4))
					{
					ErrorCode = ERROR_IFF_TRUNCATED;
					sprintf(ErrorMessage,
						"(IFF) File truncated at 0x%08.8lX : incomplete group header.\n",
						(UL) curcontext->groupCurPos);
					goto errorExit;
					}

				curcontext->groupCurPos = curcontext->groupCurPos + l;

				// Print out the group header.

				#if IFFPRINT > 0
					for (i = curcontext->groupDepth - 1; i > 0; i--)
						{
						if (fputc(' ',ferr) == EOF)
							{
							goto errorDiagnostic;
							}
						}
					*(ID4 *)ID4String = C.ckID;
					if (fprintf(ferr,"%s 0x%08.8lX ", ID4String, (UL) C.ckSize) < 0)
						{
						goto errorDiagnostic;
						}
					*(ID4 *)ID4String = curcontext->groupSubID;
					if (fprintf(ferr,"%s\n", ID4String) < 0)
						{
						goto errorDiagnostic;
						}
				#endif

				// PROP ANIM group ?

				if ((curcontext->groupID == ID4_PROP) && (curcontext->groupSubID == ID4_ANIM))
					{
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
						"(IFF) File malformed at 0x%08.8lX : PROP ANIM is not a legal group type.\n",
						(UL) curcontext->groupCurPos - sizeof(GROUPHEADER));
					goto errorExit;
					}

				// Determine whether subsequent PROP groups should be allowed.

				if (curcontext->groupID == ID4_LIST)
					{
					oldcontext->propFlag = NO;
					curcontext->propFlag = YES;
					}
				else if (curcontext->groupID == ID4_CAT)
					{
					oldcontext->propFlag = NO;
					curcontext->propFlag = NO;
					}
				else if (curcontext->groupID == ID4_FORM)
					{
					oldcontext->propFlag = NO;
					curcontext->propFlag = NO;
					if (curcontext->groupSubID == ID4_ANIM)
						{
						curcontext->animContext = curcontext;
						curcontext->animMinus2 = NULL;
						curcontext->animMinus1 = NULL;
						}
					}

				// Seek to the end of an unknown FORM or PROP.

				if ((curcontext->groupID == ID4_FORM) || (curcontext->groupID == ID4_PROP))
					{
					if ((curcontext->groupSubID != ID4_ANIM) &&
							(curcontext->groupSubID != ID4_ILBM) &&
							(curcontext->groupSubID != ID4_PBM))
						{
						if (fseek(curcontext->file,curcontext->groupEndPos,SEEK_SET) != 0)
							{
							ErrorCode = ERROR_IFF_TRUNCATED;
							sprintf(ErrorMessage,
								"(IFF) File truncated at 0x%08.8lX : unable to seek to end of group.\n",
								(UL) curcontext->groupCurPos);
							goto errorExit;
							}
						curcontext->groupCurPos = curcontext->groupEndPos;
						}
					}
				}

			// If it isn't a new group then it must be an ordinary chunk.

			else

				{
				// Print out chunk header.

				#if IFFPRINT > 0
					for (i = curcontext->groupDepth; i > 0; i--)
						{
						if (fputc(' ',ferr) == EOF)
							{
							goto errorDiagnostic;
							}
						}
					*(ID4 *)ID4String = C.ckID;
					if (fprintf(ferr,"%s 0x%08.8lX ", ID4String, (UL) C.ckSize) < 0)
						{
						goto errorDiagnostic;
						}
				#endif

				// Beginning of the file ?

				if (curcontext->groupEndPos == 0)
					{
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
						"(IFF) File malformed at 0x%08.8lX : not a valid group header.\n",
						(UL) 0);
					goto errorExit;
					}

				// Data chunk within a LIST or CAT ?

				if ((curcontext->groupID == ID4_LIST) || (curcontext->groupID == ID4_CAT))
					{
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
  					"(IFF) File malformed at 0x%08.8lX : LIST and CAT groups cannot contain "
						"data chunks.\n",
						(UL) curcontext->groupCurPos - sizeof(CHUNKHEADER));
					goto errorExit;
					}

				// Read or skip the next data chunk depending upon the group type and
				// the type of data wanted.

				if (curcontext->groupSubID == ID4_ANIM)
					{
					// FORM ANIM.
					ErrorCode = ERROR_IFF_MALFORMED;
					sprintf(ErrorMessage,
  					"(IFF) File malformed at 0x%08.8lX : FORM ANIM cannot contain data "
						"chunks.\n",
						(UL) curcontext->groupCurPos - sizeof(CHUNKHEADER));
					}

				else if (curcontext->groupSubID == ID4_ILBM)
					{
					// FORM/PROP ILBM.
					if (ReadILBMChunk(curcontext) != ERROR_NONE)
						{
						goto errorExit;
						}
					}

				else if (curcontext->groupSubID == ID4_PBM)
					{
					// FORM/PROP PBM.
					if (ReadPBMChunk(curcontext) != ERROR_NONE)
						{
						goto errorExit;
						}
					}
				else
					{
					// Unknown FORM/PROP.
					if (SkipChunk(curcontext) != ERROR_NONE)
						{
						goto errorExit;
						}
					}

				// Finish printing chunk header.

				#if IFFPRINT > 0
					if (fputs("\n", ferr) < 0)
						{
						goto errorDiagnostic;
						}
				#endif

				}

			}

		// Are we at the end of a group yet ?

		if (curcontext->groupCurPos >= curcontext->groupEndPos)

			{

			// Head of context list (and therefore the logical end-of-file) ?

			if ((curcontext->groupDepth == 0))
				{
				break;
				}

			// Check for overrun passed the end of the group.

			if (curcontext->groupCurPos > curcontext->groupEndPos)
				{
				ErrorCode = ERROR_IFF_MALFORMED;
				*(ID4 *)ID4String = curcontext->groupID;
				sprintf(ErrorMessage,
 					"(IFF) File malformed at 0x%08.8lX : %s group should end at 0x%08.8lX.\n",
					(UL) curcontext->groupCurPos,
					ID4String,
					(UL) curcontext->groupEndPos);
				goto errorExit;
				}

			// Are we leaving a PROP group ?

			if (curcontext->groupID == ID4_PROP)
				{
				InheritContext(curcontext);
				}

			// Or perhaps a FORM group ?

			else if (curcontext->groupID == ID4_FORM)
				{

				// Is it a FORM.ILBM ?

				if (curcontext->groupSubID == ID4_ILBM)
					{
					d = ConvertFromILBM(curcontext);
					if ((d == NULL) && (ErrorCode != ERROR_NONE))
						{
						goto errorExit;
						}
					}

				// Is it a FORM.PBM ?

				else if (curcontext->groupSubID == ID4_PBM)
					{
					d = ConvertFromPBM(curcontext);
					if ((d == NULL) && (ErrorCode != ERROR_NONE))
						{
						goto errorExit;
						}
					}

				}

			// Now unlink the current context and restore the previous context.

			oldcontext = curcontext->oldContext;
			oldcontext->groupCurPos = curcontext->groupCurPos;
			if (oldcontext->groupEndPos == 0)
				{
				// Logical end of file so force groupEndPos=groupCurPos to ensure
				// that subsequent calls will return with d=NULL without trying to
				// read anything.
				oldcontext->groupEndPos = oldcontext->groupCurPos;
				}
			*ppcl_Context = oldcontext;

			// Free up all the memory blocks allocated within the current context.

			FreeContext(curcontext);

			}

		// If there was an error, or if we actually have got an object, then
		// break out of the infinite while () loop, else go back to the top
		// and get the next chunk.

		if ((ErrorCode != ERROR_NONE) || (d != NULL))
			{
			break;
			}

		} // End of infinite while () loop.

	return (d);

	// Error handlers (reached via the dreaded goto).

	#if IFFPRINT > 0
		errorDiagnostic:
			ErrorCode  = ERROR_DIAGNOSTIC;
			FatalError = YES;
	#endif

	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * IffQuitRead ()                                                         *
// **************************************************************************
// * Aborts reading from the context, and frees up all memory used          *
// **************************************************************************
// * Inputs  void **       Ptr to address of input context                  *
// *                                                                        *
// * Output  FILE *        Returns the FILE * for this context              *
// *                                                                        *
// * N.B.    This function MUST be called when you are finished with an     *
// *         IFF file or else the memory blocks will not be freed.          *
// *                                                                        *
// *         Note that this function does NOT close the file itself, it     *
// *         returns the FILE * so that you can do that.                    *
// **************************************************************************

global	FILE *              IffQuitRead             (
								void **             ppcl_Context)

	{

	// Local variables.

	IFFCONTEXT *        oldcontext;
	IFFCONTEXT *        curcontext;
	FILE *              file;

	// Local code.

	curcontext = (IFFCONTEXT *) *ppcl_Context;

	file = curcontext->file;

	while (curcontext != NULL)
		{
		oldcontext = curcontext->oldContext;
		FreeContext(curcontext);
		curcontext = oldcontext;
		}

	*ppcl_Context = NULL;

	return (file);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * ConvertFromILBM ()                                                     *
// **************************************************************************
// * Called after reading a FORM.ILBM to xvert the data into a DATA_BITMAP  *
// **************************************************************************
// * Inputs  IFFCONTEXT *  Ptr to context                                   *
// *                                                                        *
// * Output  DATABLOCK_T * Ptr to bitmap, or NULL if an error               *
// **************************************************************************

static	DATABLOCK_T *       ConvertFromILBM         (
								IFFCONTEXT *        context)

	{

	// Local variables.

//	IFFBLOCK *          c;
//	size_t              l;
//	DATABLOCK_T *   	d;

	BMHDCHUNK *         pbmhd;
	CMAPCHUNK *         pcmap;
	GRABCHUNK *         pgrab;
	DESTCHUNK *         pdest;
	BODYCHUNK *         pbody;
	ANHDCHUNK *         panhd;
	DLTACHUNK *         pdlta;

	// Get the chunk pointers.

	pbmhd = (BMHDCHUNK *) context->blkILBMBMHD;
	if (pbmhd != NULL) pbmhd =  (BMHDCHUNK *) ((IFFBLOCK *)pbmhd)->data;
	pcmap = (CMAPCHUNK *) context->blkILBMCMAP;
	if (pcmap != NULL) pcmap =  (CMAPCHUNK *) ((IFFBLOCK *)pcmap)->data;
	pgrab = (GRABCHUNK *) context->blkILBMGRAB;
	if (pgrab != NULL) pgrab =  (GRABCHUNK *) ((IFFBLOCK *)pgrab)->data;
	pdest = (DESTCHUNK *) context->blkILBMDEST;
	if (pdest != NULL) pdest =  (DESTCHUNK *) ((IFFBLOCK *)pdest)->data;
	pbody = (BODYCHUNK *) context->blkILBMBODY;
	if (pbody != NULL) pbody =  (BODYCHUNK *) ((IFFBLOCK *)pbody)->data;
	panhd = (ANHDCHUNK *) context->blkILBMANHD;
	if (panhd != NULL) panhd =  (ANHDCHUNK *) ((IFFBLOCK *)panhd)->data;
	pdlta = (DLTACHUNK *) context->blkILBMDLTA;
	if (pdlta != NULL) pdlta =  (DLTACHUNK *) ((IFFBLOCK *)pdlta)->data;

	// Determine whether we need to decode a normal bitmap or an ANIM delta.

	if ((context->animContext == NULL) || (context->animMinus1 == NULL))

		// Decode a normal bitmap.

		{

		// Check that the required chunks exist.

		if (pbmhd == NULL)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ILBM malformed : missing a BMHD chunk.\n");
			goto errorMalformed;
			}

		if ((pbmhd->nPlanes != 0) && (pbody == NULL))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ILBM malformed : missing a BODY chunk.\n");
			goto errorMalformed;
			}

		if (pdest != NULL)
			{
			ErrorCode = ERROR_IFF_NOT_HANDLED;
			sprintf(ErrorMessage,
				"(IFF) FORM ILBM too complex : I can't handle DEST chunks.\n");
			goto errorExit;
			}

		}

	else

		// Decode an ANIM delta.

		{

		// Check that the required chunks exist.

		if (panhd == NULL) {
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a ANHD chunk.\n");
			goto errorMalformed;
			}

		if ((panhd->operation < 2) && (pbody == NULL)) {
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a BODY chunk.\n");
			goto errorMalformed;
			}

		if ((panhd->operation > 1) && (pdlta == NULL)) {
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a DLTA chunk.\n");
			goto errorMalformed;
			}

		}

	// Sorry folks ...

	sprintf(ErrorMessage,
		"(IFF) FORM ILBM not currently implemented.\n");
	goto errorUnknown;

	// Return the bitmap.

	//	return (d);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

		ErrorCode = ERROR_IFF_NOT_HANDLED;
		goto errorExit;

	errorMalformed:

		ErrorCode = ERROR_IFF_MALFORMED;

	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * ConvertFromPBM ()                                                      *
// **************************************************************************
// * Called after reading a FORM.PBM to xvert the data into a DATA_BITMAP   *
// **************************************************************************
// * Inputs  IFFCONTEXT *  Ptr to context                                   *
// *                                                                        *
// * Output  DATABLOCK_T * Ptr to bitmap, or NULL if an error               *
// **************************************************************************

static	DATABLOCK_T *       ConvertFromPBM          (
								IFFCONTEXT *        context)

	{

	// Local variables.

	IFFCONTEXT *        c;

	BMHDCHUNK *         pbmhd;
	CMAPCHUNK *         pcmap;
	GRABCHUNK *         pgrab;
	DESTCHUNK *         pdest;
	BODYCHUNK *         pbody;
	ANHDCHUNK *         panhd;
	DLTACHUNK *         pdlta;

	DATABLOCK_T *       d;
	DATABITMAP_T *      b;

	UD                  srcw;
	UD                  srch;
	UW                  srcb;
	UB                  srcc;
	UB *                srcp;

	UB *                dstp;

	UD                  n;

	// Get the chunk pointers.

	pbmhd = (BMHDCHUNK *) context->blkPBMBMHD;
	pcmap = (CMAPCHUNK *) context->blkPBMCMAP;
	pgrab = (GRABCHUNK *) context->blkPBMGRAB;
	pdest = (DESTCHUNK *) context->blkPBMDEST;
	pbody = (BODYCHUNK *) context->blkPBMBODY;
	panhd = (ANHDCHUNK *) context->blkPBMANHD;
	pdlta = (DLTACHUNK *) context->blkPBMDLTA;

	if (pbmhd != NULL) pbmhd =  (BMHDCHUNK *) ((IFFBLOCK *)pbmhd)->data;
	if (pgrab != NULL) pgrab =  (GRABCHUNK *) ((IFFBLOCK *)pgrab)->data;
	if (pdest != NULL) pdest =  (DESTCHUNK *) ((IFFBLOCK *)pdest)->data;
	if (panhd != NULL) panhd =  (ANHDCHUNK *) ((IFFBLOCK *)panhd)->data;

	// Determine whether we need to decode a normal FORM PBM bitmap or a
	// FORM ANIM PBM bitmap delta.

	if ((context->animContext == NULL) || (context->animMinus1 == NULL))

		// Decode a FORM PBM bitmap.

		{

		// Check that the required chunks exist.

		if (pbmhd == NULL)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM malformed : missing a BMHD chunk.\n");
			goto errorMalformed;
			}

		if ((pbmhd->nPlanes != 0) && (pbody == NULL))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM malformed : missing a BODY chunk.\n");
			goto errorMalformed;
			}

		if (pdest != NULL)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM malformed : should not contain a DEST chunk.\n");
			goto errorMalformed;
			}

		// Check that we can handle this bitmap.

		if ((pbmhd->nPlanes != 0) && (pbmhd->nPlanes != 8))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM not handled : number of planes must be 8 not %hu.\n",
				(US) pbmhd->nPlanes);
			goto errorUnknown;
			}

		if ((pbmhd->masking != mskNone) &&
				(pbmhd->masking != mskHasTransparentColor))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM not handled : don't understand masked PBM.\n");
			goto errorUnknown;
			}

		if (pbmhd->compression > 1)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM PBM not handled : don't understand compression methods > 1.\n");
			goto errorUnknown;
			}

		// Get the bitmap's important parameters.

		srcw = pbmhd->w;
		srch = pbmhd->h;
		srcb = pbmhd->nPlanes;
		srcc = pbmhd->compression;

		// If nPlanes == 0 then we have a color map only, so override the width
		// and height.

		if (srcb == 0)
			{
			srcw = 0;
			srch = 0;
			}

		// Create a native bitmap of the required size.

		d = DataBitmapAlloc(srcw, srch, srcb, NO);

		if (d == NULL) goto errorExit;

		b = (DATABITMAP_T *) d;

		// GRAB chunk present (and not within an ANIM because EA screwed up) ?

		if ((pgrab != NULL) && (context->animContext == NULL))
			{
			b->si___bmXTopLeft = 0 - pgrab->xOffset;
			b->si___bmYTopLeft = 0 - pgrab->yOffset;
			}

		// CMAP chunk present ?

		if (pcmap != NULL)

			{

			n = ((UD ) ((IFFBLOCK *) pcmap)->head.head.ckSize) / 3;

			if (n > (1UL << srcb))
				{
				n = (1UL << srcb);
				}

			pcmap = (CMAPCHUNK *) ((IFFBLOCK *)pcmap)->data;

			srcp = (UB *) pcmap->rgbColor;
			dstp = (UB *) b->acl__bmC;

			while (n != 0)
				{
				dstp[2] = srcp[0];
				dstp[1] = srcp[1];
				dstp[0] = srcp[2];
				srcp		= srcp + 3;
				dstp		= dstp + 4;
				n				= n - 1;
				}

			}

		// If we have both width and height, then lets try to actually convert
		// the BODY chunk.

		if ((srcw != 0) && (srch != 0))

			{

			// Get BODY size and pointer.

			n = ((IFFBLOCK *) pbody)->head.head.ckSize;
			pbody = (BODYCHUNK *) ((IFFBLOCK *) pbody)->data;

			// Call ConvertFromPBMBODY() to do the actual conversion, this routine
			// could do with being written in assembler for greater speed.

			if (ConvertFromPBMBODY(
				((UB *) pbody),
				((UB *) pbody) + n,
				b->pub__bmBitmap,
				b->si___bmLineSize,
				srcw, srch, srcb, srcc) != ERROR_NONE)
				{
				DataFree(d);
				sprintf(ErrorMessage,
					"(IFF) FORM PBM malformed : error in BODY chunk data.\n");
				goto errorMalformed;
				}

			// End of conversion of FORM PBM BODY chunk.

			}

		// End of conversion of FORM PBM bitmap.

		}

	else

		// Decode a FORM ANIM PBM bitmap delta.

		{

		// Check that the required chunks exist.

		if (panhd == NULL)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a ANHD chunk.\n");
			goto errorMalformed;
			}

		if ((panhd->operation < 2) && (pbody == NULL))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a BODY chunk.\n");
			goto errorMalformed;
			}

		if ((panhd->operation > 1) && (pdlta == NULL))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : missing a DLTA chunk.\n");
			goto errorMalformed;
			}

		if (pdest != NULL)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM malformed : should not contain a DEST chunk.\n");
			goto errorMalformed;
			}

		// Is the compression method implemented ?

		if (panhd->operation != ANHD_OP_EADA_DELTA)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM ANHD too wierd : only operation <K> implemented.\n");
			goto errorUnknown;
			}

		// Get the reference frame.

		if (panhd->interleave > 2)
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM ANHD too wierd : interleave must be < 3.\n");
			goto errorUnknown;
			}

		if ((panhd->interleave == 1) || (context->animMinus2 == NULL))
			{
			d = context->animMinus1;
			}
		else
			{
			d = context->animMinus2;
			}

		// Get the DLTA width and height from ANHD.

		srcw = panhd->w;
		srch = panhd->h;

		if ((srcw != ((DATABITMAP_T *) d)->ui___bmW) ||
			(srch != ((DATABITMAP_T *) d)->ui___bmH))
			{
			sprintf(ErrorMessage,
				"(IFF) FORM ANIM PBM ANHD too wierd : bitmap size changed.\n");
			goto errorMalformed;
			}

		// Make a copy of the reference bitmap for us to work on.

		d = DataDuplicate(d);

		if (d == NULL) goto errorExit;

		b = (DATABITMAP_T *) d;

		// If we have both width and height, then lets try to actually convert
		// the DLTA chunk.

		if ((srcw != 0) && (srch != 0))

			{

			// Get DLTA size and pointer.

			n = ((IFFBLOCK *) pdlta)->head.head.ckSize;
			pdlta = (DLTACHUNK *) (((IFFBLOCK *) pdlta)->data);

			// Call ConvertFromPBMDLTA() to do the actual conversion, this routine
			// could do with being written in assembler for greater speed.

			if (ConvertFromPBMDLTA(
				((UB *) pdlta),
				((UB *) pdlta) + n,
				b->pub__bmBitmap,
				b->si___bmLineSize,
				srcw, srch) != ERROR_NONE)
				{
				DataFree(d);
				sprintf(ErrorMessage,
					"(IFF) FORM ANIM PBM malformed : error in DLTA chunk data.\n");
				goto errorMalformed;
				}

			}

		// End of conversion of FORM ANIM PBM bitmap delta.

		}


	// If within a FORM ANIM then preserve a copy of the bitmap.

	if (context->animContext != NULL)

		{

		// Free up the copy of the bitmap for two frames ago.

		if (context->animMinus2 != NULL)
			{
			DataFree(context->animMinus2);
			}

		// Go back up to the parent FORM ANIM updating the bitmap pointers.

		c = context;

		while (c != c->animContext)
			{
			c = c->oldContext;
			c->animMinus2 = c->animMinus1;
			c->animMinus1 = d;
			}

		// Make a copy of the bitmap to be returned.

		d = DataDuplicate(d);

		if (d == NULL)
			{
			goto errorExit;
			}

		}

	// Return the bitmap.

	return (d);

	// Error handlers (reached via the dreaded goto).

	errorUnknown:

			ErrorCode = ERROR_IFF_NOT_HANDLED;

			goto errorExit;

	errorMalformed:

			ErrorCode = ERROR_IFF_MALFORMED;

	errorExit:

		return ((DATABLOCK_T *) NULL);

	}



// **************************************************************************
// * ConvertFromPBMBODY ()                                                  *
// **************************************************************************
// * Convert a PBM.BODY data chunk into DIB data                            *
// **************************************************************************
// * Inputs  UB *            Ptr to src (IFF) data                          *
// *         UB *            Ptr to src (IFF) data end                      *
// *         UB *            Ptr to dst (DIB) data                          *
// *         UD              Line offset of dst buffer                      *
// *         UD              Src width                                      *
// *         UD              Src height                                     *
// *         UD              Src bpp                                        *
// *         UD              Src compression type                           *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    ErrorCode and ErrorMessage are NOT set on failure.             *
// **************************************************************************

static	ERRORCODE           ConvertFromPBMBODY      (
								UB *                srcptr,
								UB *                srcend,
								UB *                dstptr,
								UD                  dstoff,
								UD                  srcw,
								UD                  srch,
								UD                  srcb,
								UD                  srcc)

	{

	// Local variables.

	UD                  srcoff;
	SD                  dstadd;
	UD                  dstrhs;
	UD                  dstcnt;

	UB                  f;
	UB                  n;

	// Calculate source line width and destination RHS edge size.

	srcoff = ((srcw * srcb) + 7) >> 3;

	dstrhs = dstoff - srcoff;

	dstadd = 0;

	if (srcoff & 1)
		{
		dstadd = -1L;
		srcoff = WordAlign(srcoff);
		}

	// Select which conversion routine to use depending upon the compression
	// method used.

	if (srcc == 0)

		// Convert uncompressed bitmap.

		{

		// Copy each line from the source to the destination.

		while (srch-- != 0)

			{

			memcpy(dstptr, srcptr, srcoff);
			memset(dstptr + srcoff + dstadd, 0, dstrhs);
			srcptr = srcptr + srcoff;
			dstptr = dstptr + dstoff;

			}

		}

	else

		// Convert RLE compressed bitmap.

		{

		// Copy each line from the source to the destination.

		while (srch-- != 0)

			{

			dstcnt = srcoff;

			while (dstcnt != 0)

				{

				if (srcptr == srcend) goto errorExit;
				n = *srcptr++;

				if (n < 0x80)
					{
					n = n + 1;
					if ((srcptr + n) > srcend) goto errorExit;
					if (dstcnt < n) goto errorExit;
					dstcnt = dstcnt - n;
					do
						{
						*dstptr++ = *srcptr++;
						n = n - 1;
						} while (n != 0);
					}

				else if (n != 0x80)
					{
					n = 1 - n;
					if (srcptr == srcend) goto errorExit;
					f = *srcptr++;
					if (dstcnt < n) goto errorExit;
					dstcnt = dstcnt - n;
					do
						{
						*dstptr++ = f;
						n = n - 1;
						} while (n != 0);
					}

				}

			if (dstrhs != 0)
				{
				dstptr = dstptr + dstadd;
				memset(dstptr, 0, dstrhs);
				dstptr = dstptr + dstrhs;
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
// * ConvertFromPBMDLTA ()                                                  *
// **************************************************************************
// * Convert a PBM.DLTA data chunk into DIB data                            *
// **************************************************************************
// * Inputs  UB *            Ptr to src (IFF) data                          *
// *         UB *            Ptr to src (IFF) data end                      *
// *         UB *            Ptr to dst (DIB) data                          *
// *         UD              Line offset of dst buffer                      *
// *         UD              Src width                                      *
// *         UD              Src height                                     *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    ErrorCode and ErrorMessage are NOT set on failure.             *
// **************************************************************************

static	ERRORCODE           ConvertFromPBMDLTA      (
								UB *                srcptr,
								UB *                srcend,
								UB *                dstptr,
								UD                  dstoff,
								UD                  srcw,
								UD                  srch)

	{

	// Local variables.

	UD                  srcoff;
	UD                  dstcnt;
	UD                  dstrhs;
	UB *                dsttmp;

	UB                  c;
	UB                  f;
	UW                  r;
//HERE0
	// Calculate source line width.

	dstrhs = 0;

	srcoff = srcw;

	if (srcoff & 1)
		{
		dstrhs = srcoff;
		srcoff = WordAlign(srcoff);
		}

	// Skip the DLTA plane pointers.

	#if BYTE_ORDER_LO_HI
		srcptr = srcptr + SwapD32(*((UD *) srcptr));
	#endif

	#if BYTE_ORDER_HI_LO
		srcptr = srcptr + *((UD *) srcptr);
	#endif

	// Convert method 'K' delta.

	while (srch-- != 0)

		{

		dsttmp = dstptr;
		dstcnt = srcoff;

		// Get the number of commands in the line.

		if (srcptr >= srcend) goto errorExit;
		c = *srcptr++;

		// Repeat while there are commands ...

		while (c != 0)

			{

			if (srcptr == srcend) goto errorExit;
			r = *srcptr++;

			if (r == ((UW) 0x00))

				{
				// Fill 1-255 pixels.

				if (srcptr == srcend) goto errorExit;
				r = *srcptr++;
				if (srcptr == srcend) goto errorExit;
				f = *srcptr++;
				if (dstcnt < r) goto errorExit;
				dstcnt = dstcnt - r;
				do
					{
					*dsttmp++ = f;
					r = r - 1;
					} while (r != 0);
				}

			else if (r <= ((UW) 0x7F))

				{
				// Copy 1-127 pixels.

				if ((srcptr + r) > srcend) goto errorExit;
				if (dstcnt < r) goto errorExit;
				dstcnt = dstcnt - r;
				do
					{
					*dsttmp++ = *srcptr++;
					r = r - 1;
					} while (r != 0);
				}

			else if (r >= ((UW) 0x81))

				{
				// Skip 1-127 pixels.

				r = r - ((UW) 0x0080);
				if (dstcnt < r) goto errorExit;
				dstcnt = dstcnt - r;
				dsttmp = dsttmp + r;
				}

			else

				{
				// Extended operation.

				if (srcptr == srcend) goto errorExit;
				r = *srcptr++;
				if (srcptr == srcend) goto errorExit;
				r = r + (*srcptr++ << 8);

				if ((r == ((UW) 0x0000)) || (r == ((UW) 0x8000)) || (r == ((UW) 0xC000)))

					{
					// Unknown.

					goto errorExit;
					}

				else if (r <= ((UW) 0x7FFF))

					{
					// Skip 1-32767 pixels.

					if (dstcnt < r) goto errorExit;
					dstcnt = dstcnt - r;
					dsttmp = dsttmp + r;
					}

				else if (r <= ((UW) 0xBFFF))

					{
					// Copy 1-16383 pixels.

					r = r - ((UW) 0x8000);
					if ((srcptr + r) > srcend) goto errorExit;
					if (dstcnt < r) goto errorExit;
					dstcnt = dstcnt - r;
					do
						{
						*dsttmp++ = *srcptr++;
						r = r - 1;
						} while (r != 0);
					}

				else

					{
					// Fill 1-16383 pixels.

					r = r - ((UW) 0xC000);
					if (srcptr == srcend) goto errorExit;
					f = *srcptr++;
					if (dstcnt < r) goto errorExit;
					dstcnt = dstcnt - r;
					do
						{
						*dsttmp++ = f;
						r = r - 1;
						} while (r != 0);
					}

				}

			c = c - 1;

			}

		if (dstrhs != 0)
			{
			*(dstptr + dstrhs) = 0;
			}

		dstptr = dstptr + dstoff;

		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (~ERROR_NONE);

	}



// **************************************************************************
// * ReadILBMChunk ()                                                       *
// **************************************************************************
// * Read the next ILBM chunk and update the context                        *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    Also updates context->groupCurPos if OK.                       *
// **************************************************************************

static	ERRORCODE           ReadILBMChunk           (
								IFFCONTEXT *        context)

	{

	// Local variables.

	IFFBLOCK *	c;

	// TYPE_BITMAP wanted ?

	if (context->dataType & DATA_BITMAP)

		{
		// Read in the chunk.

		c = ReadChunk(context);
		if (c == NULL)
			{
			goto errorExit;
			}

		// Is it an important chunk ?

		if (C.ckID == ID4_BMHD)
			{
			c->head.link = context->blkILBMBMHD;
			context->blkILBMBMHD = c;
			#if BYTE_ORDER_LO_HI
				bmhd->w					= SwapD16(bmhd->w);
				bmhd->h					= SwapD16(bmhd->h);
				bmhd->x					= SwapD16(bmhd->x);
				bmhd->y					= SwapD16(bmhd->y);
				bmhd->transparentColor	= SwapD16(bmhd->transparentColor);
				bmhd->pageW				= SwapD16(bmhd->pageW);
				bmhd->pageH				= SwapD16(bmhd->pageH);
			#endif
			}

		else if (C.ckID == ID4_DEST)
			{
			c->head.link = context->blkILBMDEST;
			context->blkILBMDEST = c;
			#if BYTE_ORDER_LO_HI
				dest->planePick			= SwapD16(dest->planePick);
				dest->planeOnOff		= SwapD16(dest->planeOnOff);
				dest->planeMask			= SwapD16(dest->planeMask);
			#endif
			}

		else if (C.ckID == ID4_CMAP)
			{
			c->head.link = context->blkILBMCMAP;
			context->blkILBMCMAP = c;
			}

		else if (C.ckID == ID4_GRAB)
			{
			c->head.link = context->blkILBMGRAB;
			context->blkILBMGRAB = c;
			#if BYTE_ORDER_LO_HI
				grab->xOffset			= SwapD16(grab->xOffset);
				grab->yOffset			= SwapD16(grab->yOffset);
			#endif
			}

		else if (C.ckID == ID4_BODY)
			{
			c->head.link = context->blkILBMBODY;
			context->blkILBMBODY = c;
			}

		else if (C.ckID == ID4_ANHD)
			{
			c->head.link = context->blkILBMANHD;
			context->blkILBMANHD = c;
			#if BYTE_ORDER_LO_HI
				anhd->w					= SwapD16(anhd->w);
				anhd->h					= SwapD16(anhd->h);
				anhd->x					= SwapD16(anhd->x);
				anhd->y					= SwapD16(anhd->y);
				anhd->absTime			= SwapD32(anhd->absTime);
				anhd->relTime			= SwapD32(anhd->relTime);
				anhd->bits				= SwapD32(anhd->bits);
			#endif
			}

		else if (C.ckID == ID4_DLTA)
			{
			c->head.link = context->blkILBMDLTA;
			context->blkILBMDLTA = c;
			}

		else
			{
			free(c);
			#if IFFPRINT > 1
				if (fputs("discarded", ferr) < 0) goto errorDiagnostic;
			#endif
			}
		}

	// TYPE_BITMAP unwanted.

	else
		{
		if (SkipChunk(context) != ERROR_NONE)
			{
			goto errorExit;
			}

		// Print out "skipped" message.

		#if IFFPRINT > 1
			if (fputs("skipped", ferr) < 0) goto errorDiagnostic;
		#endif
		}

	// Error handlers (reached via the dreaded goto).

	#if IFFPRINT > 0
		return (ErrorCode);

		errorDiagnostic:
			ErrorCode  = ERROR_DIAGNOSTIC;
			FatalError = YES;
	#endif

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * ReadPBMChunk ()                                                        *
// **************************************************************************
// * Read the next PBM chunk and update the context                         *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    Also updates context->groupCurPos if OK.                       *
// **************************************************************************

static	ERRORCODE           ReadPBMChunk            (
								IFFCONTEXT *        context)

	{

	// Local variables.

	IFFBLOCK *	c;

	// TYPE_BITMAP wanted ?

	if (context->dataType & DATA_BITMAP)

		{
		// Read in the chunk.

		c = ReadChunk(context);
		if (c == NULL)
			{
			goto errorExit;
			}

		// Is it an important chunk ?

		if (C.ckID == ID4_BMHD)
			{
			c->head.link = context->blkPBMBMHD;
			context->blkPBMBMHD = c;
			#if BYTE_ORDER_LO_HI
				bmhd->w					= SwapD16(bmhd->w);
				bmhd->h					= SwapD16(bmhd->h);
				bmhd->x					= SwapD16(bmhd->x);
				bmhd->y					= SwapD16(bmhd->y);
				bmhd->transparentColor	= SwapD16(bmhd->transparentColor);
				bmhd->pageW				= SwapD16(bmhd->pageW);
				bmhd->pageH				= SwapD16(bmhd->pageH);
			#endif
			}

		else if (C.ckID == ID4_DEST)
			{
			c->head.link = context->blkPBMDEST;
			context->blkPBMDEST = c;
			#if BYTE_ORDER_LO_HI
				dest->planePick			= SwapD16(dest->planePick);
				dest->planeOnOff		= SwapD16(dest->planeOnOff);
				dest->planeMask			= SwapD16(dest->planeMask);
			#endif
			}

		else if (C.ckID == ID4_CMAP)
			{
			c->head.link = context->blkPBMCMAP;
			context->blkPBMCMAP = c;
			}

		else if (C.ckID == ID4_GRAB)
			{
			c->head.link = context->blkPBMGRAB;
			context->blkPBMGRAB = c;
			#if BYTE_ORDER_LO_HI
				grab->xOffset			= SwapD16(grab->xOffset);
				grab->yOffset			= SwapD16(grab->yOffset);
			#endif
			}

		else if (C.ckID == ID4_BODY)
			{
			c->head.link = context->blkPBMBODY;
			context->blkPBMBODY = c;
			}

		else if (C.ckID == ID4_ANHD)
			{
			c->head.link = context->blkPBMANHD;
			context->blkPBMANHD = c;
			#if BYTE_ORDER_LO_HI
				anhd->w					= SwapD16(anhd->w);
				anhd->h					= SwapD16(anhd->h);
				anhd->x					= SwapD16(anhd->x);
				anhd->y					= SwapD16(anhd->y);
				anhd->absTime			= SwapD32(anhd->absTime);
				anhd->relTime			= SwapD32(anhd->relTime);
				anhd->bits				= SwapD32(anhd->bits);
			#endif
			}

		else if (C.ckID == ID4_DLTA)
			{
			c->head.link = context->blkPBMDLTA;
			context->blkPBMDLTA = c;
			}

		else
			{
			free(c);
			#if IFFPRINT > 1
				if (fputs("discarded", ferr) < 0) goto errorDiagnostic;
			#endif
			}

		}

	// TYPE_BITMAP unwanted.

	else
		{
		if (SkipChunk(context) != ERROR_NONE)
			{
			goto errorExit;
			}

		// Print out "skipped" message.

		#if IFFPRINT > 1
			if (fputs("skipped", ferr) < 0) goto errorDiagnostic;
		#endif
		}

	// Error handlers (reached via the dreaded goto).

	#if IFFPRINT > 0
		return (ErrorCode);

		errorDiagnostic:
			ErrorCode  = ERROR_DIAGNOSTIC;
			FatalError = YES;
	#endif

	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// * ReadChunkHead ()                                                       *
// **************************************************************************
// * Reads the next chunk header into structure C and update the context    *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  size_t          sizeof(CHUNKHEADER) if OK, 0 if an error       *
// *                                                                        *
// * N.B.    Also updates context->groupCurPos if OK.                       *
// **************************************************************************

static	size_t              ReadChunkHead           (
								IFFCONTEXT *        context)

	{
	// Local variables.

	size_t              l;

	// Read the next chunk header.

	l = fread(&C, 1, sizeof(CHUNKHEADER), context->file);

	if (ferror(context->file))
		{
		ErrorCode = ERROR_IO_READ;
		goto errorExit;
		}

	if (l == 0)
		{
		ErrorCode = ERROR_NONE;
		goto errorExit;
		}

	if (l < sizeof(CHUNKHEADER))
		{
		ErrorCode = ERROR_IFF_TRUNCATED;
		sprintf(ErrorMessage,
			"(IFF) File truncated at 0x%08.8lX : incomplete chunk header.\n");
		goto errorExit;
		}

	context->groupCurPos = context->groupCurPos + l;

	// Convert from MC68000 byte ordering.

	#if BYTE_ORDER_LO_HI
		C.ckSize = SwapD32(C.ckSize);
	#endif

	// Check for dubious chunk size.

	if ((C.ckSize < 0) || (C.ckSize > 0x00100000L))
		{
		ErrorCode = ERROR_IFF_MALFORMED;
		sprintf(ErrorMessage,
			"(IFF) File malformed at 0x%08.8lX : chunk size either -ve or > 1MB.\n");
		goto errorExit;
		}

	// Return with success code.

	return (l);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (0);
	}



// **************************************************************************
// * ReadChunk ()                                                           *
// **************************************************************************
// * Read the next chunk and update the context                             *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  IFFBLOCK *      Ptr to chunk, or NULL if an error              *
// *                                                                        *
// * N.B.    Also updates context->groupCurPos if OK.                       *
// **************************************************************************

static	IFFBLOCK *          ReadChunk               (
								IFFCONTEXT *        context)

	{
	// Local variables.

	IFFBLOCK *          c;
	size_t              l;
	size_t              s;

	// Allocate memory for the chunk.

	s = WordAlign(C.ckSize);

	c = malloc(sizeof(IFFHEADER) + s);

	if (c == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		goto errorExit;
		}

	// Initialize the chunk header.

	c->head.link = NULL;
	c->head.depth = context->groupDepth;
	c->head.head.ckID = C.ckID;
	c->head.head.ckSize = C.ckSize;

	// Read the chunk into memory (if there is one).

	if (s != 0)
		{
		l = fread(c->data, 1, s, context->file);

		if (ferror(context->file))
			{
			ErrorCode = ERROR_IO_READ;
			goto errorFree;
			}

		if (l < s)
			{
			ErrorCode = ERROR_IFF_TRUNCATED;
			sprintf(ErrorMessage,
				"(IFF) File truncated at 0x%08.8lX : incomplete chunk header.\n",
				(UL) context->groupCurPos);
			goto errorFree;
			}

		context->groupCurPos = context->groupCurPos + s;
		}

	// Return with success code.

	return (c);

	// Error handlers (reached via the dreaded goto).

	errorFree:

		free(c);

	errorExit:

		return ((IFFBLOCK *) NULL);
	}



// **************************************************************************
// * SkipChunk ()                                                           *
// **************************************************************************
// * Skip the next chunk and update the context                             *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  ERRORCODE       ERROR_NONE if OK                               *
// *                                                                        *
// * N.B.    Also updates context->groupCurPos if OK.                       *
// **************************************************************************

static	ERRORCODE           SkipChunk               (
								IFFCONTEXT *        context)

	{
	// Local variables.

	size_t              s;

	// Skip the chunk.

	s = WordAlign(C.ckSize);

	if (s != 0)
		{
		if (fseek(context->file, s, SEEK_CUR) != 0)
			{
			sprintf(ErrorMessage,
				"(IFF) File truncated at 0x%08.8lX : incomplete chunk data.\n",
				(UL) context->groupCurPos);
			return (ErrorCode = ERROR_IFF_TRUNCATED);
			}

		context->groupCurPos = context->groupCurPos + s;
		}

	// Return with success code.

	return (ERROR_NONE);
	}



// **************************************************************************
// * InheritContext ()                                                      *
// **************************************************************************
// * Inherit the current context up to the previous context                 *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  -                                                              *
// *                                                                        *
// * N.B.    This is used to process PROP groups.                           *
// **************************************************************************

static	void                InheritContext          (
								IFFCONTEXT *        curcontext)

	{
	// Local variables.

	IFFCONTEXT *        oldcontext;

	UI                  depth;

	// Now inherit the current context up to the previous context.

	oldcontext = curcontext->oldContext;

	depth = curcontext->groupDepth;

	InheritChunks((oldcontext->blkILBMBMHD = curcontext->blkILBMBMHD), depth);
	InheritChunks((oldcontext->blkILBMCMAP = curcontext->blkILBMCMAP), depth);
	InheritChunks((oldcontext->blkILBMGRAB = curcontext->blkILBMGRAB), depth);
	InheritChunks((oldcontext->blkILBMDEST = curcontext->blkILBMDEST), depth);
	InheritChunks((oldcontext->blkILBMBODY = curcontext->blkILBMBODY), depth);
	InheritChunks((oldcontext->blkILBMANHD = curcontext->blkILBMANHD), depth);
	InheritChunks((oldcontext->blkILBMDLTA = curcontext->blkILBMDLTA), depth);

	InheritChunks((oldcontext->blkPBMBMHD = curcontext->blkPBMBMHD), depth);
	InheritChunks((oldcontext->blkPBMCMAP = curcontext->blkPBMCMAP), depth);
	InheritChunks((oldcontext->blkPBMGRAB = curcontext->blkPBMGRAB), depth);
	InheritChunks((oldcontext->blkPBMDEST = curcontext->blkPBMDEST), depth);
	InheritChunks((oldcontext->blkPBMBODY = curcontext->blkPBMBODY), depth);
	InheritChunks((oldcontext->blkPBMANHD = curcontext->blkPBMANHD), depth);
	InheritChunks((oldcontext->blkPBMDLTA = curcontext->blkPBMDLTA), depth);
	}



// **************************************************************************
// * InheritChunks ()                                                       *
// **************************************************************************
// * Decrement the depth of all the chunks at the current depth             *
// **************************************************************************
// * Inputs  IFFBLOCK *      Ptr to chunk                                   *
// *         UI              Depth                                          *
// *                                                                        *
// * Output  -                                                              *
// *                                                                        *
// * N.B.    This is used to transfer ownership of all the chunks at the    *
// *         current depth up to the previous context depth.                *
// **************************************************************************

static	void                InheritChunks           (
								IFFBLOCK *          blk,
								UI                  depth)

	{
	while (blk != NULL)
		{
		if (blk->head.depth == depth)
			{
			blk->head.depth = blk->head.depth - 1;
			}
		else
			{
			break;
			}
		blk = blk->head.link;
		}
	}



// **************************************************************************
// * FreeContext ()                                                         *
// **************************************************************************
// * Frees up all the memory used by the context (including itself)         *
// **************************************************************************
// * Inputs  IFFCONTEXT *    Ptr to context                                 *
// *                                                                        *
// * Output  -                                                              *
// **************************************************************************

static	void                FreeContext             (
								IFFCONTEXT *        context)

	{
	// If we are freeing a FORM ANIM context then we must free up the 2 bitmaps
	// that it keeps for processing the deltas.

	if ((context->groupID == ID4_FORM) && (context->groupSubID == ID4_ANIM))
		{
		if (context->animMinus2 != NULL) DataFree(context->animMinus2);
		if (context->animMinus1 != NULL) DataFree(context->animMinus1);
		}

	// Free up the individual chunks allocated within this context.

	FreeChunk(context->blkILBMBMHD, context->groupDepth);
	FreeChunk(context->blkILBMCMAP, context->groupDepth);
	FreeChunk(context->blkILBMGRAB, context->groupDepth);
	FreeChunk(context->blkILBMDEST, context->groupDepth);
	FreeChunk(context->blkILBMBODY, context->groupDepth);
	FreeChunk(context->blkILBMANHD, context->groupDepth);
	FreeChunk(context->blkILBMDLTA, context->groupDepth);

	FreeChunk(context->blkPBMBMHD, context->groupDepth);
	FreeChunk(context->blkPBMCMAP, context->groupDepth);
	FreeChunk(context->blkPBMGRAB, context->groupDepth);
	FreeChunk(context->blkPBMDEST, context->groupDepth);
	FreeChunk(context->blkPBMBODY, context->groupDepth);
	FreeChunk(context->blkPBMANHD, context->groupDepth);
	FreeChunk(context->blkPBMDLTA, context->groupDepth);

	// Finally, free up the context itself.

	free(context);
	}



// **************************************************************************
// * FreeChunk ()                                                           *
// **************************************************************************
// * Run thru the list of chunks freeing up all those at the current depth  *
// **************************************************************************
// * Inputs  IFFBLOCK *      Ptr to chunk                                   *
// *         UI              Depth                                          *
// *                                                                        *
// * Output  -                                                              *
// *                                                                        *
// * N.B.    Stops at the first chunk with a different depth value.         *
// **************************************************************************

static	void                FreeChunk               (
								IFFBLOCK *          chunk,
								UI                  depth)

	{

	// Local variables.

	IFFBLOCK *		p;

	// Free up all the IFFBLOCKs belonging to the current context.

	while (chunk != NULL)
		{
		if (chunk->head.depth != depth) break;

		p = chunk->head.link;

		free(chunk);

		chunk = p;
		}
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF IFF.C
// **************************************************************************
// **************************************************************************
// **************************************************************************

