// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XS.H                                                         PROGRAM **
// **                                                                      **
// ** To convert LBM/ABM/PCX bitmaps into a machine dependant format.      **
// **                                                                      **
// ** Currently supported are ...                                          **
// **                                                                      **
// **   Genesis                                                            **
// **   Super NES                                                          **
// **   3DO                                                                **
// **   Saturn                                                             **
// **   Playstation                                                        **
// **   IBM PC                                                             **
// **                                                                      **
// ** Last modified : 06 Aug 1998 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XS_h
#define __XS_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

// Space to allocate for each type of data.

#define	XS_MAX_CHR		((UI)          8192)
#define	XS_BUF_CHR		((size_t) 0x040000L)

#define	XS_MAX_BLK		((UI)          2048)
#define	XS_BUF_BLK		((size_t) 0x008000L)

#define	XS_MAX_MAP		((UI)          1024)
#define	XS_BUF_MAP		((size_t) 0x080000L)

#define	XS_MAX_SPR		((UI)          2048)
#define	XS_BUF_SPR		((size_t) 0x100000L)

#define	XS_MAX_FRM		((UI)          1024)
#define	XS_BUF_FRM		((size_t) 0x010000L)

#define	XS_MAX_FNT		((UI)           256)
#define	XS_BUF_FNT		((size_t) 0x020000L)
#define	XS_MAX_KRN		((UI)          1024)

#define	XS_MAX_PAL		((UI)           256)
#define	XS_BUF_PAL		((size_t) 0x020000L)

//
// GLOBAL VARIABLES
//

extern	FL                  fl___gZeroColour0;

extern	FL                  fl___gShrinkInput;
extern	FL                  flRemapInput;
extern	FL                  flFilterInput;
extern	FL                  flFilterChrs;
extern	UI                  uiFilterBelow;
extern	UI                  uiFilterAbove;
extern	FL                  flHistogram;
extern	FL                  flUseProcessedName;
extern	FL                  flWriteProcessed;
extern	FL                  flProcessOnly;

extern	FL                  flOutputMapIndex;
extern	SL                  slOutputMapStart;

extern	FL                  flOutputMapPosition;
extern	FL                  flOutputMapBoxSize;

extern	FL                  flOutputWordIdx;
extern	FL                  flOutputByteMap;

extern	FL                  flOutputWordOffsets;

extern	FL                  flUseNewPalette;
extern	FL                  flPaletteAlphaRGB;
extern	FL                  flPaletteAlphaBGR;
extern	FL                  flPaletteSPL;

extern	UI                  uiChrsToStrip;

extern	FL                  flWriteRGB;
extern	FL                  flWriteCHR;
extern	FL                  flWriteBLK;
extern	FL                  flWriteMAP;
extern	FL                  flWriteSPR;
extern	FL                  flWriteIDX;
extern	FL                  flWriteFNT;

extern	FL                  flWriteRES;

extern	RGBQUAD_T           Palette[256];

extern	UI                  uiFileCount;
extern	UI                  uiFileFrame;
extern	UI                  uiFilePalette;

extern	FILE *              pcl__OutputFil;
extern	char *              pcz__OutputNam;
extern	char *              pcz__OutputExt;
extern	char                pcz__OutputStr[512];

//
// GLOBAL FUNCTION PROTOTYPES
//

//
// End of __XS_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XS.H
// **************************************************************************
// **************************************************************************
// **************************************************************************