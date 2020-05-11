// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** DATA.H                                                        MODULE **
// **                                                                      **
// ** Modules defining structures and code for handling various types of   **
// ** data in a consistent fashion.                                        **
// **                                                                      **
// ** Last modified : 14 Aug 1997 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __DATATYPE_h
#define __DATATYPE_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// DATA specific error codes.

#define ERROR_DATA_UNKNOWN		-0x0100L
#define ERROR_DATA_ILLEGAL		-0x0101L

// Global file type variable.

typedef	UD                  FILETYPE_T;

#define FILE_UNKNOWN        0
#define FILE_DIB            1
#define FILE_IFF            2
#define FILE_PCX            3
#define FILE_TGA            4
#define FILE_SPR            5

// Global data type variable.
//
// On reading, the code used should be the sum of all the different types
// of information that should be returned, i.e. use ...
//
// TYPE_BITMAP+TYPE_PCM_SAMPLE to return either kind of information.

typedef	UD                  DATATYPE_T;

#define DATA_ANYTHING       (~0)

#define	DATA_NOTHING        0
#define DATA_BITMAP         1
#define DATA_PCM_SAMPLE     2

// Data header structure.
//
// Heads up each different type of data structure in order to provide a
// standard interface to the different data types.

typedef	struct DATABLOCK_S
	{
	struct DATABLOCK_S * next;
	struct DATABLOCK_S * prev;
	SI                   size;
	DATATYPE_T           type;
	} DATABLOCK_T;

// Force byte alignment.

#if __ZTC__
#pragma ZTC align 1
#endif

#if __WATCOMC__
#pragma pack (1)
#endif

#if _MSC_VER
#pragma pack(1)
#endif

// Definition of the DATABITMAP_T structure for the DATA_BITMAP type.
//
// This structure is based on the MicroSoft Windows 3.x device-independant
// bitmap file structure, and whilst the header itself is different, the
// actual data is stored in a Windows-compatible format.

typedef	struct RGBQUAD_S
	{
	UB                  ub___rgbB;
	UB                  ub___rgbG;
	UB                  ub___rgbR;
	UB                  ub___rgbA;
	} RGBQUAD_T;

typedef	struct RGBTRPL_S
	{
	UB                  ub___rgbB;
	UB                  ub___rgbG;
	UB                  ub___rgbR;
	} RGBTRPL_T;

typedef	struct DATABITMAP_S
	{
	DATABLOCK_T         head;
	UB *                pub__bmBitmap;			// Pointer to bitmap data.
	SI                  si___bmLineSize;		// Size of a (padded) line in bytes.
	SI                  si___bmXTopLeft;		// X coord of top left corner.
	SI                  si___bmYTopLeft;		// Y coord of top left corner.
	UI                  ui___bmW;				// Width  of bitmap in pixels.
	UI                  ui___bmH;				// Height of bitmap in pixels.
	UI                  ui___bmB;				// Bits-per-pixel (1/4/8/24).
	UI                  ui___bmF;				// YES = TopToBottom, NO = BottomToTop.
	RGBQUAD_T           acl__bmC [256];			// Windows DIB color palette.
	} DATABITMAP_T;

#define BM_TOP2BTM          1

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

//

typedef	struct DATACHRSET_S
	{
	DATABLOCK_T         head;
	UD *                pud__chrBufKeys;
	UD *                pud__chrBufData;
	UD *                pud__chrBufEnd;
	UI                  ui___chrCount;
	UI                  ui___chrMaximum;
	UI                  ui___chrXPxlSize;
	UI                  ui___chrXPxlShift;
	UI                  ui___chrYPxlSize;
	UI                  ui___chrYPxlShift;
	UI                  ui___chrPxlBits;
	UI                  ui___chrU32Size;
	UI                  ui___chrU32Shift;
	UI                  ui___chrBytSize;
	UI                  ui___chrBytShift;
	} DATACHRSET_T;

typedef	struct DATABLKSET_S
	{
	DATABLOCK_T         head;
	UD *                pud__blkBufKeys;
	UW *                puw__blkBufData;
	UW *                puw__blkBufEnd;
	UI                  ui___blkCount;
	UI                  ui___blkMaximum;
	UI                  ui___blkXChrSize;
	UI                  ui___blkXChrShift;
	UI                  ui___blkYChrSize;
	UI                  ui___blkYChrShift;
	UI                  ui___blkChrSize;
	UI                  ui___blkChrShift;
	UI                  ui___blkBytSize;
	UI                  ui___blkBytShift;
	} DATABLKSET_T;

typedef	struct DATAMAPSET_S
	{
	DATABLOCK_T         head;
	UD **               ppud_mapBufIndx;
	UD *                pud__mapBufKeys;
	UW *                puw__mapBufData;
	UW *                puw__mapBufEnd;
	UI                  ui___mapCount;
	UI                  ui___mapMaximum;
	} DATAMAPSET_T;

typedef	struct DATASPRIDX_S
	{
	BUFFER *            pbf__spriBufPtr;	// NULL if blank sprite.
	UL                  ul___spriBufLen;	// ==0 if sprite is blank/repeated.
	SI                  si___spriXOffset;
	SI                  si___spriYOffset;
	UI                  ui___spriWidth;
	UI                  ui___spriHeight;
	UI                  ui___spriPalette;
	SI                  si___spriNumber;
	UD                  ud___spriKeyVal;
	} DATASPRIDX_T;

typedef	struct DATASPRSET_S
	{
	DATABLOCK_T         head;
	DATASPRIDX_T *      acl__sprsBufIndx;
	BUFFER *            pbf__sprsBuf1st;
	BUFFER *            pbf__sprsBufCur;
	BUFFER *            pbf__sprsBufEnd;
	UI                  ui___sprsCount;
	UI                  ui___sprsMaximum;
	} DATASPRSET_T;

typedef	struct DATAFNTIDX_S
	{
	BUFFER *            pbf__fntiBufPtr;	// NULL if blank sprite.
	UL                  ul___fntiBufLen;	// ==0 if sprite is blank/repeated.
	SI                  si___fntiXOffset;
	SI                  si___fntiYOffset;
	UI                  ui___fntiWidth;
	UI                  ui___fntiHeight;
	SI                  si___fntiDeltaW;
	UD                  ud___fntiPadding;
	} DATAFNTIDX_T;

typedef struct KERNPAIR_S
    {
    char                ub___chr0;
    char                ub___chr1;
    SB                  sb___dX;
    UB                  ub___padding;
    } KERNPAIR_T;

typedef	struct DATAFNTSET_S
	{
	DATABLOCK_T         head;
	DATAFNTIDX_T *      acl__fntsBufIndx;
	BUFFER *            pbf__fntsBuf1st;
	BUFFER *            pbf__fntsBufCur;
	BUFFER *            pbf__fntsBufEnd;
	UI                  ui___fntsCount;
	UI                  ui___fntsMaximum;
	KERNPAIR_T *        acl__fntsKrnTbl;
	UI                  ui___fntsKrnCnt;
	UI                  ui___fntsKrnMax;
	} DATAFNTSET_T;

typedef	struct DATAPALIDX_S
	{
	BUFFER *            pbf__paliBufPtr;	// NULL if blank sprite.
	UL                  ul___paliBufLen;	// ==0 if sprite is blank/repeated.
	UI                  ui___paliMaxVal;
	SI                  si___paliNumber;
	UD                  ud___paliKeyVal;
	} DATAPALIDX_T;

typedef	struct DATAPALSET_S
	{
	DATABLOCK_T         head;
	DATAPALIDX_T *      acl__palsBufIndx;
	BUFFER *            pbf__palsBuf1st;
	BUFFER *            pbf__palsBufCur;
	BUFFER *            pbf__palsBufEnd;
	UI                  ui___palsCount;
	UI                  ui___palsMaximum;
	} DATAPALSET_T;

//

#define ID4_GenS MakeID4('G','e','n','S')
#define ID4_SfxS MakeID4('S','f','x','S')
#define ID4_3doS MakeID4('3','d','o','S')
#define ID4_SatS MakeID4('S','a','t','S')
#define ID4_PsxS MakeID4('P','s','x','S')
#define ID4_IbmS MakeID4('I','b','m','S')
#define ID4_N64S MakeID4('N','6','4','S')

#define ID4_Mxxx MakeID4('M','x','x','x')
#define ID4_Mgen MakeID4('M','g','e','n')
#define ID4_Msfx MakeID4('M','s','f','x')
#define ID4_M3do MakeID4('M','3','d','o')
#define ID4_Msat MakeID4('M','s','a','t')
#define ID4_Mpsx MakeID4('M','p','s','x')
#define ID4_Mibm MakeID4('M','i','b','m')
#define ID4_Mn64 MakeID4('M','n','6','4')

#define ID4_palI MakeID4('p','a','l','I')
#define ID4_palD MakeID4('p','a','l','D')
#define ID4_chrI MakeID4('c','h','r','I')
#define ID4_chrD MakeID4('c','h','r','D')
#define ID4_blkI MakeID4('b','l','k','I')
#define ID4_blkD MakeID4('b','l','k','D')
#define ID4_mapI MakeID4('m','a','p','I')
#define ID4_mapD MakeID4('m','a','p','D')
#define ID4_sprI MakeID4('s','p','r','I')
#define ID4_sprD MakeID4('s','p','r','D')
#define ID4_fntI MakeID4('f','n','t','I')
#define ID4_fntD MakeID4('f','n','t','D')

#define ID4_head MakeID4('h','e','a','d')
#define ID4_sect MakeID4('s','e','c','t')

typedef	struct DATACHUNK_S
	{
	SL                  sl___ckSize;
	ID4                 ud___ckType;
	ID4                 ud___ckMach;
	UI                  ui___ckFlag;
	} DATACHUNK_T;

//
// GLOBAL VARIABLES
//

extern	FILETYPE_T          FileType;
extern	DATATYPE_T          DataType;

extern	UB                  RemappingTable [256];
extern	UL *                paul_Histogram;

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	DATABLOCK_T *       DataBitmapAlloc         (
								UI                  width,
								UI                  height,
								UI                  bits,
								FL                  clear);

extern	ERRORCODE           DataBitmapQuarter       (
								DATABITMAP_T *      pdbiti,
								SI                  siboxx,
								SI                  siboxy,
								UI                  uiboxw,
								UI                  uiboxh);

extern	ERRORCODE           DataBitmapRemap         (
								DATABITMAP_T *      pdbiti,
								SI                  siboxx,
								SI                  siboxy,
								UI                  uiboxw,
								UI                  uiboxh);

extern	ERRORCODE           DataBitmapFilter        (
								DATABITMAP_T *      pdbiti,
								SI                  siboxx,
								SI                  siboxy,
								UI                  uiboxw,
								UI                  uiboxh,
								UI                  uirangelo,
								UI                  uirangehi);

extern	ERRORCODE           DataBitmapHistogram     (
								DATABITMAP_T *      pdbiti,
								SI                  siboxx,
								SI                  siboxy,
								UI                  uiboxw,
								UI                  uiboxh);

extern	ERRORCODE           DataBitmapBoundingBox   (
								DATABITMAP_T *      pdbiti,
								SI *                psiboxx,
								SI *                psiboxy,
								UI *                puiboxw,
								UI *                puiboxh);

extern	ERRORCODE           DataBitmapPalettize     (
								DATABITMAP_T *      pdbiti,
								SI                  siboxx,
								SI                  siboxy,
								UI                  uiboxw,
								UI                  uiboxh);

extern	ERRORCODE           DataBitmapInvert        (
								DATABLOCK_T *       d);

extern	ERRORCODE           DataBitmapSaveBMP       (
								DATABLOCK_T *       d,
								char *              filename);

extern	ERRORCODE           DataBitmapShowHist      (
								void);

extern	DATABLOCK_T *       DataDuplicate           (
								DATABLOCK_T *       d);

extern	ERRORCODE           DataFree                (
								DATABLOCK_T *       d);

//
// End of __DATATYPE_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF DATA.H
// **************************************************************************
// **************************************************************************
// **************************************************************************