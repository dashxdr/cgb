// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERT.H                                                       MODULE **
// **                                                                      **
// ** Convert a bitmap into one of several machine specific formats.       **
// **                                                                      **
// ** Last modified : 12 Jun 1998 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERT_h
#define __XVERT_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// Diagnostic printing macros.

#define	XSPRINTMAP	0
#define	XSPRINTFRM	0

#if XSPRINTMAP
#define	XSPRINTFMAP(s,p) printf(s,p)
#else
#define	XSPRINTFMAP(s,p)
#endif

#if XSPRINTFRM
#define	XSPRINTFFRM(s,p) printf(s,p)
#else
#define	XSPRINTFFRM(s,p)
#endif

// XVERT structure.

typedef	struct	XVERTINFOBLOCK_S
	{
	UI                  uimapPalette;
	UI                  uiblkNumber;
	UI                  uichrNumber;
	UI                  uichrFlip;
	UI                  uichrPriority;
	UI                  uichrPalette;
	UI                  uisort1;
	UI                  uisort2;
	union
		{
		DATACHRSET_T    dciold;
		DATABLKSET_T    dbiold;
		}               o;
	union
		{
		DATACHRSET_T    dcinew;
		DATABLKSET_T    dbinew;
		}               n;
	} XVERTINFOBLOCK;

// XVERT specific error codes.

#define	ERROR_XVERT_PROGRAM		-256L
#define	ERROR_XVERT_ILLEGAL		-257L
#define	ERROR_XVERT_UNKNOWN		-258L
#define	ERROR_XVERT_CHRFULL		-259L
#define	ERROR_XVERT_BLKFULL		-260L
#define	ERROR_XVERT_MAPFULL		-261L
#define	ERROR_XVERT_FRMFULL		-262L

// Codes for the uiMachineType global variable.

#define	MACHINE_GEN         1
#define	MACHINE_SFX         2
#define	MACHINE_3DO         3
#define	MACHINE_SAT         4
#define	MACHINE_PSX         5
#define	MACHINE_IBM         6
#define	MACHINE_N64         7
#define	MACHINE_GMB         8
#define MACHINE_AGB         9

// Codes for the uiOutputOrder global variable.

#define	ORDERHILO           0
#define	ORDERLOHI           1

#if BYTE_ORDER_LO_HI
#define	ORDERSWAP           ORDERHILO
#endif

#if BYTE_ORDER_HI_LO
#define	ORDERSWAP           ORDERLOHI
#endif

// Codes for the uiMapType global variable.

#define	MAP_CHR             1
#define	MAP_SPR             2
#define	MAP_PXL             3
#define	MAP_FNT             4

// Codes for the uiOrderType global variable.

#define	ORDER_LRTB          1
#define	ORDER_TBLR          2

// Codes for the uiSprCoding global variable.

#define	ENCODED_PALETTE     0
#define	ENCODED_RGB         1

// Codes for the uiSprCompression global variable.

#define	ENCODED_UNPACKED    0
#define	ENCODED_PACKED      1

// Codes for the uiSprDirection global variable.

#define	TOPTOBOTTOM         0
#define	BOTTOMTOTOP         1

// Codes for the uiOrderType global variable.

#define	ORDER_LRTB          1
#define	ORDER_TBLR          2

//
// GLOBAL VARIABLES
//

extern	UI                  uiMachineType;
extern	UI                  uiOutputOrder;

extern	UI                  uiMapType;

extern	UI                  uiChrBitSize;
extern	UI                  uiChrXFlShift;
extern	UI                  uiChrYFlShift;
extern	UI                  uiChrPriMask;
extern	UI                  uiChrPriShift;
extern	UI                  uiChrPalMask;
extern	UI                  uiChrPalShift;
extern	UI                  uiChrNumMask;
extern	UI                  uiChrNumShift;

extern	UI                  uiChrMapOrder;
extern	UI                  uiChrMapOffset;

extern	UI                  uiSprBPP;
extern	UL                  ulSprMask;
extern	UI                  uiSprCoding;
extern	UI                  uiSprCompression;
extern	UI                  uiSprDirection;
extern	UI                  uiSprPalette;

extern	FL                  flSprLockYGrid;
extern	FL                  flSprLockXGrid;

extern	UI                  uiMapBoxFactor;

extern	FL                  flReferenceFrame;
extern	FL                  flFindEdges;

extern	FL                  flZeroTransparent;
extern	FL                  flZeroColour0;

extern	FL                  flRemovePalRepeats;
extern	FL                  flRemoveChrRepeats;
extern	FL                  flRemoveBlkRepeats;
extern	FL                  flRemoveMapRepeats;
extern	FL                  flRemoveSprRepeats;
extern	FL                  flRemoveFrmRepeats;
extern	FL                  flRemoveIdxRepeats;

extern	FL                  flRemoveBlankMaps;
extern	FL                  flRemoveBlankSprs;

extern	FL                  flChrXFlipAllowed;
extern	FL                  flChrYFlipAllowed;

extern	FL                  flStoreChrNumber;
extern	FL                  flStoreChrPriority;
extern	FL                  flStoreChrFlip;
extern	FL                  flStoreChrPalette;

extern	FL                  flChrMapToBlkMap;

extern	FL                  flMapXFlipAllowed;
extern	FL                  flMapYFlipAllowed;

extern	FL                  flStoreMapPosition;
extern	FL                  flStoreMapPalette;

extern	FL                  flClrPriority;
extern	FL                  flSetPriority;

extern	FL                  flRmvPermanentChr;
extern	UI                  uiNumPermanentChr;

extern	SI                  siStaticMapFrame;

extern	DATACHRSET_T        ChrInfo;
extern	DATABLKSET_T        BlkInfo;
extern	DATAMAPSET_T        MapInfo;
extern	DATASPRSET_T        SprInfo;
extern	DATAFNTSET_T        FntInfo;
extern	DATAPALSET_T        PalInfo;

extern	UD                  TotalChrExpected;

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	ERRORCODE           XvertStorePalette       (
								DATABITMAP_T *      pcl__Bmp,
								DATAPALSET_T *      pcl__Pal);

extern	DATABLOCK_T *       XvertBitmapBorder16     (
								DATABLOCK_T *       d);

extern	UW *                XvertBitmapToMapFrm     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATACHRSET_T *      pdchri,
								DATABLKSET_T *      pdblki,
								DATAMAPSET_T *      pdmapi,
								UW *                pu16dst,
								UW *                pu16max);

global	UW *                XvertBitmapToSprFrm     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATASPRSET_T *      pdspri,
								UW *                pu16dst,
								UW *                pu16max);

global	UW *                XvertBitmapToFntFrm     (
								DATABITMAP_T *      pdbiti,
								DATAFNTSET_T *      pdfnti,
								UW *                pu16dst,
								UW *                pu16max);

extern	UW *                XvertBitmapToChrmap    (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								DATACHRSET_T *      pdchri,
								UW *                pu16dst,
								UW *                pu16max);

extern	UW *                XvertChrmapToBlkmap     (
								UW *                pu16src,
								DATABLKSET_T *      pdblki,
								UW *                pu16dst,
								UW *                pu16max);

extern	BUFFER *            XvertBitmapToSprite     (
								DATABITMAP_T *      pdbiti,
								SI                  sibmx,
								SI                  sibmy,
								UI                  uibmw,
								UI                  uibmh,
								BUFFER *            pbf__dst,
								BUFFER *            pbf__max);

extern	UW *                PxlToChrmap             (
								XVERTINFOBLOCK *    pxib,
								UB *                pu08src,
								UL                  ulsrcwidth,
								UI                  uiwchr,
								UI                  uihchr,
								UI                  uiorder,
								UW *                pu16dst);

extern	ERRORCODE           RemoveStaticMapData     (
								DATAMAPSET_T *      pcl__Map,
								SI                  si___Frm);

// Include all of the machine specific header files.

#ifndef __XVERTGEN_h
 #include "xvertgen.h"
#endif

#ifndef __XVERTSFX_h
 #include "xvertsfx.h"
#endif

#ifndef __XVERTAGB_h
 #include "xvertagb.h"
#endif

#ifndef __XVERT3DO_h
 #include "xvert3do.h"
#endif

#ifndef __XVERTSAT_h
 #include "xvertsat.h"
#endif

#ifndef __XVERTPSX_h
 #include "xvertpsx.h"
#endif

#ifndef __XVERTIBM_h
 #include "xvertibm.h"
#endif

#ifndef __XVERTN64_h
 #include "xvertn64.h"
#endif

#ifndef __XVERTGMB_h
 #include "xvertgmb.h"
#endif

#ifndef __XVERTFNT_h
 #include "xvertfnt.h"
#endif

//
// End of __XVERT_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERT.H
// **************************************************************************
// **************************************************************************
// **************************************************************************