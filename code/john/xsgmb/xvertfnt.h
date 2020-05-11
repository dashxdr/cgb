// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XVERTFNT.H                                                    MODULE **
// **                                                                      **
// ** Functions here are called from XVERT.C to perform data conversions   **
// ** into Font format.                                                    **
// **                                                                      **
// ** Last modified : 14 Oct 1996 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#ifndef __XVERTFNT_h
#define __XVERTFNT_h

//
// GLOBAL DATA STRUCTURES AND DEFINITIONS
//

typedef	struct FNTHDR_S
	{
	UD                  ud___fntNull;
	UB                  ub___fntFlgs;
	UB                  ub___fntKrnN;
	UB                  ub___fntChr0;
	UB                  ub___fntChrN;
	SB                  sb___fntXSpc;
	SB                  sb___fntYSpc;
	SB                  sb___fntXLft;
	SB                  sb___fntXRgt;
	SB                  sb___fntYTop;
	SB                  sb___fntYBtm;
	SB                  sb___fntYCap;
	SB                  sb___fntYOvr;
	} FNTHDR_T;

typedef	struct FNTIDX_S
	{
	UW                  uw___chrOff;
	UB                  ub___chrNul;
	SB                  sb___chrNxt;
	SB                  sb___chrX;
	SB                  sb___fntY;
	UB                  ub___fntW;
	UB                  ub___fntH;
	} FNTIDX_T;

//
// GLOBAL VARIABLES
//

extern	UI                  uiFntChr0;
extern	UI                  uiFntXSpc;
extern	UI                  uiFntYSpc;
extern	FL                  flFntYDbl;
extern	FL                  flFntDebug;
extern	char                czFntTest [1024];

//
// GLOBAL FUNCTION PROTOTYPES
//

extern	FL                  AddKernPair             (
								int                 chr0,
								int                 chr1,
								int                 delta);

extern	SI                  BitmapToFont            (
								DATABITMAP_T *      pdbiti,
								DATAFNTSET_T *      pdfnti);

/*
extern	void                ReformatFntsForFNT      (
								UI                  ui___sprcnt,
								BUFFER *            pbf__idxbuf,
								BUFFER **           ppbf_idxend,
								BUFFER *            pbf__sprbuf,
								BUFFER **           ppbf_sprend);
*/

extern	ERRORCODE           ReformatFntsForFNT      (
								DATAFNTSET_T *      pcl__Fnt,
								UB **               ppub_Buf,
								UI *                pui__Buf,
								FILE *              pcl__Res);

//
// End of __XVERTFNT_h
//

#endif



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XVERTFNT.H
// **************************************************************************
// **************************************************************************
// **************************************************************************