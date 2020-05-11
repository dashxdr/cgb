// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** XS.C                                                         PROGRAM **
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
// **   N64                                                                **
// **   AGB                                                                **
// **                                                                      **
// ** Last modified : 16 Aug 1999 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include <ctype.h>
#include	"io.h"

#include	"elmer.h"
#include	"data.h"
#include	"bmp.h"
#include	"iff.h"
#include	"pcx.h"
#include	"spr.h"
#include	"tga.h"
#include	"xvert.h"
#include	"xs.h"

void _splitpath(char *in,char *drive,char *dir,char *name,char *ext)
{
	char *p;
	int extsize,filesize,dirsize,len;
	*drive=*dir=*name=*ext=0;

	len=strlen(in);
	p=in+len;
	extsize=filesize=dirsize=0;
	while(--p >= in)
	{
		if(*p=='/') break;
		++extsize;
		if(*p=='.') break;
	}
	if(p<in)
	{
		strcpy(name,in);
		return;
	}
	if(*p=='/')
	{
		filesize=extsize;
		extsize=0;
	} else
	{
		while(--p >= in)
		{
			if(*p=='/') break;
			++filesize;
		}
	}
	dirsize=len-filesize-extsize;
	memcpy(ext,in+len-extsize,extsize);
	ext[extsize]=0;
	memcpy(name,in+len-extsize-filesize,filesize);
	name[filesize]=0;
	memcpy(dir,in,dirsize);
	dir[dirsize]=0;
}
void strupr(char *s)
{
	while(*s)
	{
		*s=toupper(*s);
		++s;
	}
}
int strcmpi(char *s1,char *s2)
{
	while(*s1 && tolower(*s1)==tolower(*s2)) ++s1,++s2;
	return tolower(*s1)-tolower(*s2);
}

//
// DEFINITIONS
//

#define	VERSION_STR "XS v7.50 (" __DATE__ ")"

#ifdef __ZTC__
 #define strcmpi(xx,yy) strcmpl(xx,yy)
#endif

typedef	struct LABEL_S
	{
	struct LABEL_S * pcl__NxtLabel;
	int              si___LabelVal;
	char             acz__LabelStr [258];
	} LABEL_T;

//
// GLOBAL VARIABLES
//

#define HELPMSG0            0
#define HELPMSG1            1
#define MACHINE             2
#define OUTPUTORDER         3
#define OUTPUTMAPINDEX      4
#define OUTPUTMAPSTART      5
#define OUTPUTMAPPOSITION   6
#define OUTPUTMAPBOXSIZE    7
#define OUTPUTBYTEMAP       8
#define	OUTPUTWORDOFFSETS   9
#define	MAPTYPE             10
#define REFERENCEFRAME      11
#define FINDEDGES           12
#define REMOVECHRREPEATS    13
#define REMOVEBLKREPEATS    14
#define REMOVEMAPREPEATS    15
#define REMOVESPRREPEATS    16
#define REMOVEIDXREPEATS    17
#define REMOVEBLANKMAPS     18
#define REMOVEBLANKSPRS     19
#define	CHRWIDTH            20
#define	CHRHEIGHT           21
#define	CHRBITSPERPIXEL     22
#define ALLOWCHRXFLIP       23
#define ALLOWCHRYFLIP       24
#define STORECHRNUMBER      25
#define STORECHRPRIORITY    26
#define STORECHRFLIP        27
#define STORECHRPALETTE     28
#define	BLKWIDTH            29
#define	BLKHEIGHT           30
#define	CHRMAPORDER         31
#define	CHRMAPOFFSET        32
#define	CHRMAPTOBLKMAP      33
#define ALLOWMAPXFLIP       34
#define ALLOWMAPYFLIP       35
#define STOREMAPPOSITION    36
#define STOREMAPPALETTE     37
#define BOX                 38
#define CLRPRIORITY         39
#define SETPRIORITY         40
#define INFORM              41
#define CLEARCHRS           42
#define CLEARBLKS           43
#define CLEARMAPS           44
#define CLEARSPRS           45
#define OVERRIDE            46
#define CHRSTOSTRIP         47
#define WRITERGB            48
#define WRITECHR            49
#define WRITEBLK            50
#define WRITEMAP            51
#define WRITESPR            52
#define WRITEIDX            53
#define WRITEFNT            54
#define WRITERES            55
#define	PADTOCHR            56
#define	USENEWPALETTE       57
#define	PALETTEALPHARGB     58
#define	PALETTEALPHABGR     59
#define	SPRBITSPERPIXEL     60
#define	SPRCODING           61
#define	SPRCOMPRESSION      62
#define	SPRDIRECTION        63
#define	SHRINKINPUT         64
#define	LOADREMAPTABLE      65
#define	REMAPINPUT          66
#define	FILTERINPUT         67
#define	FILTERBELOW         68
#define	FILTERABOVE         69
#define	FILTERCHRS          70
#define	ZEROTRANSPARENT     71
#define	ZEROCOLOURZERO      72
#define	USEPROCESSEDNAME    73
#define	DUMPFRAMES          74
#define	WRITEPROCESSED      75
#define	PROCESSONLY         76
#define	HISTOGRAM           77
#define	OUTPUTDIR           78
#define	CHRBITSIZE          79
#define	CHRXFLIPSHIFT       80
#define	CHRYFLIPSHIFT       81
#define	CHRPRIORITYMASK     82
#define	CHRPRIORITYSHIFT    83
#define	CHRPALETTEMASK      84
#define	CHRPALETTESHIFT     85
#define	CHRNUMBERMASK       86
#define	CHRNUMBERSHIFT      87
#define	FNTCHR0             88
#define	FNTXSPC             89
#define	FNTYSPC             90
#define	FNTYDBL             91
#define	FNTTEST             92
#define	FNTDEBUG            93
#define	KERNPAIR            94
#define	PALETTESPL          95
#define	ZEROPOSITION        96
#define	SPRONLYLRTB         97
#define	SPRLOCKYGRID        98
#define	SPRLOCKXGRID        99
#define	RMVPERMANENTCHR     100
#define	STATICMAPFRAME      101
#define	CLEARNAME           102
#define   WRITEEQU			103
#define   EMPTYCHRZERO        104
#define   BRIGHTERCOLORS      105
#define NUMBER_OF_OPTIONS   106

global	char *              OptionList[] =
								{
								"?",
								"H",
								"MACHINE",
								"OUTPUTORDER",
								"OUTPUTMAPINDEX",
								"OUTPUTMAPSTART",
								"OUTPUTMAPPOSITION",
								"OUTPUTMAPBOXSIZE",
								"OUTPUTBYTEMAP",
								"OUTPUTWORDOFFSETS",
								"MAPTYPE",
								"REFERENCEFRAME",
								"FINDEDGES",
								"REMOVECHRREPEATS",
								"REMOVEBLKREPEATS",
								"REMOVEMAPREPEATS",
								"REMOVESPRREPEATS",
								"REMOVEIDXREPEATS",
								"REMOVEBLANKMAPS",
								"REMOVEBLANKSPRS",
								"CHRWIDTH",
								"CHRHEIGHT",
								"CHRBITSPERPIXEL",
								"ALLOWCHRXFLIP",
								"ALLOWCHRYFLIP",
								"STORECHRNUMBER",
								"STORECHRPRIORITY",
								"STORECHRFLIP",
								"STORECHRPALETTE",
								"BLKWIDTH",
								"BLKHEIGHT",
								"CHRMAPORDER",
								"CHRMAPOFFSET",
								"CHRMAPTOBLKMAP",
								"ALLOWMAPXFLIP",
								"ALLOWMAPYFLIP",
								"STOREMAPPOSITION",
								"STOREMAPPALETTE",
								"BOX",
								"CLRPRIORITY",
								"SETPRIORITY",
								"INFORM",
								"CLEARCHRS",
								"CLEARBLKS",
								"CLEARMAPS",
								"CLEARSPRS",
								"OVERRIDE",
								"CHRSTOSTRIP",
								"WRITERGB",
								"WRITECHR",
								"WRITEBLK",
								"WRITEMAP",
								"WRITESPR",
								"WRITEIDX",
								"WRITEFNT",
								"WRITERES",
								"PADTOCHR",
								"USENEWPALETTE",
								"PALETTEALPHARGB",
								"PALETTEALPHABGR",
								"SPRBITSPERPIXEL",
								"SPRCODING",
								"SPRCOMPRESSION",
								"SPRDIRECTION",
								"SHRINKINPUT",
								"LOADREMAPTABLE",
								"REMAPINPUT",
								"FILTERINPUT",
								"FILTERBELOW",
								"FILTERABOVE",
								"FILTERCHRS",
								"ZEROTRANSPARENT",
								"ZEROCOLOURZERO",
								"USEPROCESSEDNAME",
								"DUMPFRAMES",
								"WRITEPROCESSED",
								"PROCESSONLY",
								"HISTOGRAM",
								"OUTPUTDIR",
								"CHRBITSIZE",
								"CHRXFLIPSHIFT",
								"CHRYFLIPSHIFT",
								"CHRPRIORITYMASK",
								"CHRPRIORITYSHIFT",
								"CHRPALETTEMASK",
								"CHRPALETTESHIFT",
								"CHRNUMBERMASK",
								"CHRNUMBERSHIFT",
								"FNTCHR0",
								"FNTXSPC",
								"FNTYSPC",
								"FNTYDBL",
								"FNTTEST",
								"FNTDEBUG",
								"KERNPAIR",
								"PALETTESPL",
								"ZEROPOSITION",
								"SPRONLYLRTB",
								"SPRLOCKYGRID",
								"SPRLOCKXGRID",
								"RMVPERMANENTCHR",
								"STATICMAPFRAME",
								"CLEARNAME",
								"WRITEEQU",
								"EMPTYCHRZERO",
								"BRIGHTERCOLORS",
								};

global	char *              StringYes	  		= "YES";
global	char *              StringNo	  		= "NO";

global    char *              StringAGB           = "AGB";
global	char *              StringGenesis 		= "GENESIS";
global	char *              StringSuperNES		= "SUPERNES";
global	char *              String3DO			= "3DO";
global	char *              StringSaturn		= "SATURN";
global	char *              StringPSX			= "PSX";
global	char *              StringIBM			= "PC";
global	char *              StringN64			= "N64";
global	char *              StringGMB			= "GAMEBOY";

global	char *              StringHILO			= "HILO";
global	char *              StringLOHI			= "LOHI";

global	char *              StringCHR			= "CHR";
global	char *              StringSPR			= "SPR";
global	char *              StringPXL			= "PXL";
global	char *              StringFNT			= "FNT";

global	char *              StringLRTB			= "LRTB";
global	char *              StringTBLR			= "TBLR";

global	char *              StringRGB			= "RGB";
global	char *              StringPALETTE		= "PALETTE";

global	char *              StringUNPACKED		= "UNPACKED";
global	char *              StringPACKED		= "PACKED";

global	char *              StringTOPTOBOTTOM	= "TOPTOBOTTOM";
global	char *              StringBOTTOMTOTOP	= "BOTTOMTOTOP";

global	FL                  flShrinkInput		= NO;
global	FL                  flRemapInput		= NO;
global	FL                  flFilterInput		= NO;
global	FL                  flFilterChrs		= NO;
global	UI                  uiFilterBelow		= 0;
global	UI                  uiFilterAbove		= 0;
global	FL                  flHistogram			= NO;
global	FL                  flUseProcessedName	= NO;
global	FL                  flWriteProcessed	= NO;
global	FL                  flProcessOnly		= NO;

global	FL                  flOutputMapIndex	= NO;
global	SL                  slOutputMapStart	= 0;

global	FL                  flOutputMapPosition	= NO;
global	FL                  flOutputMapBoxSize	= YES;

global	FL                  flOutputWordIdx		= NO;
global	FL                  flOutputByteMap		= NO;

global	FL                  flOutputWordOffsets	= NO;

global	FL                  flUseNewPalette		= NO;
global	FL                  flPaletteAlphaRGB	= NO;
global	FL                  flPaletteAlphaBGR	= NO;
global	FL                  flPaletteSPL		= YES;

global	FL                  flZeroPosition		= NO;

global	UI                  uiChrsToStrip		= 0;

global	FL                  flWriteRGB			= NO;
global	FL                  flWriteCHR			= NO;
global	FL                  flWriteBLK			= NO;
global	FL                  flWriteMAP			= NO;
global	FL                  flWriteSPR			= YES;
global	FL                  flWriteIDX			= YES;
global	FL                  flWriteFNT			= NO;

global	FL                  flWriteRES			= NO;
global	FL                  flWriteEQU			= NO;

global	FL                  flEmptyChrZero			= YES;
global    FL                  flBrighterColors         = NO;
//

global	int                 si___Argc;
global	char **             ppcz_Argv;

global	int                 si___CommandArg     = 1;
global	int                 si___CommandLine    = 0;
global	FILE *              pcl__CommandFile    = NULL;
global	char *              pcz__CommandString  = NULL;

global	char                acz__CommandBuffer [516];

global	char                acz__FileInp [_MAX_PATH + 4];
global	char                acz__FileOut [_MAX_PATH + 4];

global	char                acz__FileDrv [_MAX_DRIVE];
global	char                acz__FileDir [_MAX_DIR];
global	char                acz__FileNam [_MAX_FNAME];
global	char                acz__FileExt [_MAX_EXT];

global	LABEL_T *           pcl__Label = NULL;

//

global	FILE *              pcl__OutputFil;
global	char *              pcz__OutputNam;
global	char *              pcz__OutputExt;
global	char                pcz__OutputStr [512];

global	char                pcz__DebugName [_MAX_PATH + 4];
global	char *              pcz__DebugNamePtr = &pcz__DebugName[0];
global	char *              pcz__DebugNameExt;

global	UI                  uiFileCount;
global	UI                  uiFileFrame;
global	UI                  uiFilePalette;

global	char                Label[128];
global	char *              LabelNum;
global	char *              LabelVal;

global	DATABLOCK_T *       FrameBitmap;

global	UI                  uiOverrideCode		= 0;

global	RGBQUAD_T           Palette[256];

//
// STATIC VARIABLES
//

static	UW *                pu16FrmBufTmp;
static	UW                  au16FrmBufTmp [8];

//
// STATIC FUNCTION PROTOTYPES
//

global	int                 main (int argc, char * argv[]);

global	ERRORCODE           GlobalAlloc (void);
global	void                GlobalFree  (void);

global	ERRORCODE           SetDiagnosticName (char *);
global	void                IncDiagnosticName ();

//
// STATIC FUNCTION PROTOTYPES
//

static	char *              GetToken                (char * filter);

static	int                 ProcessToken            (char * string);

static	ERRORCODE           ProcessOption           (char * string);
static	ERRORCODE           ProcessFile             (char * string);

static	void           	    InitCHRSet              (void);
static	void           	    InitBLKSet              (void);

static	void                SetGEN                  (void);
static	void                SetSFX                  (void);
static	void                Set3DO                  (void);
static	void                SetSAT                  (void);
static	void                SetPSX                  (void);
static	void                SetIBM                  (void);
static	void                SetN64                  (void);
static	void                SetGMB                  (void);
static	void                SetAGB                  (void);

static	FL                  GetValue                (
								SL *                l,
								char *              s);

static	FL                  GetKernChr              (
								SL *                l,
								char *              s);

static	ERRORCODE           SetMachineType          (
								UI *                machine);
static	ERRORCODE           SetOrderValue           (
								UI *                machine);
static	ERRORCODE           SetOrderType            (
								UI *                order);
static	ERRORCODE           SetMapType              (
								UI *                maptype);
static	ERRORCODE           SetCodingType           (
								UI *                coding);
static	ERRORCODE           SetCompressionType      (
								UI *                compression);
static	ERRORCODE           SetDirection            (
								UI *                direction);
static	ERRORCODE           SetFlagValue            (
								FL      *           flag);
static	ERRORCODE           SetLabelName            (
								char *              label);
static	void                IncLabelName            (
								void                );
static	ERRORCODE           SetOutputDir            (
								char *              directory);

static	UW *                ConvertFile             (
								char *              pcfilename,
								UW *                pu16dst,
								UW *                pu16max);

static	ERRORCODE           ConvertRefFrm           (
								UI                  uifileframe,
								DATABLOCK_T **      ppdbh,
								SI *                psibmxtl,
								SI *                psibmytl);

static	UW *                ConvertDatFrm           (
								UI                  uifileframe,
								DATABLOCK_T **      ppdbh,
								SI                  sibmxtl,
								SI                  sibmytl,
								UW *                pu16dst,
								UW *                pu16max);

static	ERRORCODE           LoadRemapTbl            (
								char *              filename);

static	ERRORCODE           DumpCHR                 (
								char *              filename);
static	ERRORCODE           DumpBLK                 (
								char *              filename);
static	ERRORCODE           DumpMAP                 (
								char *              filename);
static	ERRORCODE           DumpSPR                 (
								FILE *              pcl__Res);
static	ERRORCODE           DumpFNT                 (
								FILE *              pcl__Res);
static	ERRORCODE           DumpRGB                 (
								FILE *              pcl__Res);
	static	ERRORCODE           DumpMemory              (
								char *              filename,
								void *              fileaddr0,
								size_t              filesize0,
								void *              fileaddr1,
								size_t              filesize1);

static	ERRORCODE           FrameDump (DATABITMAP_T * pbmh, UW * pu16frm);

static	void                PlotChr (UB * pu08dst, size_t ulwidth,
								UI uichrnum, UB u08palette);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************

static void OutputEqu (FILE * pcl__File, LABEL_T * pcl__Label)
	{
	if (pcl__Label->pcl__NxtLabel != NULL)
		{
		OutputEqu(pcl__File, pcl__Label->pcl__NxtLabel);
		}
	fprintf(pcl__File, "IDX_%s EQU %d\n",
		pcl__Label->acz__LabelStr,
		pcl__Label->si___LabelVal);
	}



// **************************************************************************
//	main ()
//
//	Usage
//		int main (int argc, char * argv[])
//
//	Description
//
//	Return Value
//		Returns an exit code for the whole program, 0 if OK, !0 if failed.
// **************************************************************************

global	int main (int argc, char * argv[])

	{

	// Local variables.

	char *              p;

	FILE *              pcl__Res = NULL;
	FILE *              pcl__Equ = NULL;

	// Initialize the memory package.

	{
	UL * pul__Mem;
	UL   ul___Mem;

	pul__Mem = (UL *) malloc(ul___Mem = (8 * 1024 * 1024));

	if (pul__Mem == NULL)
		{
		ErrorCode = ERROR_NO_MEMORY;
		sprintf(ErrorMessage,
			"XS error : Not enough memory.\n");
		goto exit;
		}

	}

	// Sign on.

	si___Argc = argc;
	ppcz_Argv = argv;

	printf("%s by J.C.Brandwood (linux port by David Ashley)\n", VERSION_STR);

	// Initialize global data.

	FrameBitmap = NULL;
	pcl__OutputFil = NULL;

	SetDiagnosticName("DUMP0000.PCX");

	if (GlobalAlloc() != ERROR_NONE) goto exit;

	// Set up the 1st map as a blank.

	MapInfo.acl__mapsBufIndx[0].puw__mapiBufPtr  =  MapInfo.puw__mapsBufCur;
	MapInfo.acl__mapsBufIndx[0].ul___mapiBufLen  =  16;
	MapInfo.acl__mapsBufIndx[0].si___mapiXOffset =  0;
	MapInfo.acl__mapsBufIndx[0].si___mapiYOffset =  0;
	MapInfo.acl__mapsBufIndx[0].si___mapiNumber  =  0;
	MapInfo.acl__mapsBufIndx[0].ud___mapiKeyVal  =  0;

	memset(MapInfo.puw__mapsBufCur, 0, (8 * sizeof(UW)));

	MapInfo.puw__mapsBufCur += 8;
	MapInfo.ui___mapsCount   = 1;

	//

	uiFileCount = 0;

	SetLabelName("LABEL");

	FrameBitmap = DataBitmapAlloc(320, 200, 8, NO);

	// Use the program name to initialize certain defaults.

	_splitpath(argv[0], acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

	if (strcmpi(acz__FileNam, "xs3do") == 0) Set3DO();
	if (strcmpi(acz__FileNam, "xssat") == 0) SetSAT();
	if (strcmpi(acz__FileNam, "xspsx") == 0) SetPSX();
	if (strcmpi(acz__FileNam, "xsibm") == 0) SetIBM();
	if (strcmpi(acz__FileNam, "xspc" ) == 0) SetIBM();
	if (strcmpi(acz__FileNam, "xsn64") == 0) SetN64();
	if (strcmpi(acz__FileNam, "xsgmb") == 0) SetGMB();
	if (strcmpi(acz__FileNam, "xsagb") == 0) SetAGB();


	// Read through program arguments.

	while ((p = GetToken(" \t\n")) != NULL)
		{
		if (ProcessToken(p) != ERROR_NONE) goto exit;
		}

	if (ErrorCode != ERROR_NONE) goto exit;

	// Print up help message if there were no files processed.

	if (*acz__FileOut == '\0')
		{
		ProcessToken("-?");
		goto exit;
		}

	// Use the first filename as the basis for the output filenames.

	_splitpath(acz__FileOut, acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

	strcpy(pcz__OutputStr, acz__FileDrv);
	strcat(pcz__OutputStr, acz__FileDir);

	pcz__OutputNam = pcz__OutputStr + strlen(pcz__OutputStr);

	strcpy(pcz__OutputNam, acz__FileNam);

	pcz__OutputExt = pcz__OutputNam + strlen(pcz__OutputNam);

	strcpy(pcz__OutputExt, acz__FileExt);

	// Print out the total character/block/map usage.

	if (flWriteCHR == YES) printf("0x%04lX total chrs used\n", (UL) ChrInfo.ui___chrCount);
	if (flWriteBLK == YES) printf("0x%04lX total blks used\n", (UL) BlkInfo.ui___blkCount);
	if (flWriteMAP == YES) printf("0x%04lX total maps used\n", (UL) MapInfo.ui___mapsCount);
	if (flWriteSPR == YES) printf("0x%04lX total sprs used\n", (UL) SprInfo.ui___sprsCount);
	if (flWriteFNT == YES) printf("0x%04lX total fnts used\n", (UL) FntInfo.ui___fntsCount);

	// Output the desired results.

	if (flWriteRES == YES)
		{
		strcpy(pcz__OutputExt, ".res");
		if ((pcl__Res = fopen(pcz__OutputStr,"wt")) == NULL)
			{
			ErrorCode = ERROR_NO_FILE;
			sprintf(ErrorMessage,
				"(XS) Unable to open RES file %s.\n",
				pcz__OutputStr);
			goto exit;
			}
		*pcz__OutputExt = '\0';
		fprintf(pcl__Res, "# Generated by %s from the command file %s\n",
			VERSION_STR,
			pcz__OutputNam);
		strcpy(pcz__OutputExt, ".bin");
		fprintf(pcl__Res, "file \"%s\"\n", pcz__OutputNam);
		}

	if (flWriteFNT == YES)
		{
		if (DumpFNT(pcl__Res) != ERROR_NONE) goto exit;
		}

	if (flWriteSPR == YES)
		{
		if (DumpSPR(pcl__Res) != ERROR_NONE) goto exit;
		}

	if (flWriteRGB == YES)
		{
		if (DumpRGB(pcl__Res) != ERROR_NONE) goto exit;
		}

	if (flWriteCHR == YES)
		{
		if (DumpCHR(pcz__OutputStr) != ERROR_NONE) goto exit;
		}

	if ((flWriteBLK == YES) && (BlkInfo.ui___blkCount != 0))
		{
		if (DumpBLK(pcz__OutputStr) != ERROR_NONE) goto exit;
		}

	if (flWriteMAP == YES)
		{
		if (DumpMAP(pcz__OutputStr) != ERROR_NONE) goto exit;
		}

	if (flWriteRES == YES)
		{
		fprintf(pcl__Res, "endfile\n");
		fclose(pcl__Res);
		pcl__Res = NULL;
		}

	// Output the equates file.

	if (flWriteEQU == YES)
		{
		LABEL_T * pcl__tmp = pcl__Label;

		strcpy(pcz__OutputExt, ".equ");

		if ((pcl__Res = fopen(pcz__OutputStr,"wt")) == NULL)
			{
			ErrorCode = ERROR_NO_FILE;
			sprintf(ErrorMessage,
				"(XS) Unable to open EQU file %s.\n",
				pcz__OutputStr);
			goto exit;
			}

		OutputEqu(pcl__Res, pcl__Label);

		fclose(pcl__Res);
		pcl__Res=NULL;
		}

	// Print out the colour histogram ?

	if (paul_Histogram != NULL)
		{
		DataBitmapShowHist();
		free(paul_Histogram);
		}

	// Print success message.

	printf("All files written.\nXS process completed without error.\n");

	// Program exit.
	//
	// This will either be dropped through to if everything is OK, or 'goto'ed
	// if there was an error.

	exit:

	ErrorQualify();

	if (ErrorCode != ERROR_NONE) {
		puts(ErrorMessage);
		}

	if (pcl__Res != NULL)       fclose(pcl__Res);
	if (pcl__OutputFil != NULL) fclose(pcl__OutputFil);

	DataFree(FrameBitmap);

	{
	LABEL_T * pcl__tmp;

	while (pcl__Label != NULL)
		{
		pcl__tmp   = pcl__Label;
		pcl__Label = pcl__Label->pcl__NxtLabel;
		free(pcl__tmp);
		}
	}

	GlobalFree();

	return ((ErrorCode != ERROR_NONE));

	}



// **************************************************************************
//	SetGEN ()
//
//	Usage
//		static void SetGEN()
//
//	Description
//		Set up the defaults for GENESIS conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetGEN (void)

	{
	uiMachineType        = MACHINE_GEN;
	uiOutputOrder        = ORDERHILO;
	uiMapType            = MAP_CHR;
	flUseNewPalette      = YES;

	uiChrBitSize         =     16;
	uiChrXFlShift        =     11;
	uiChrYFlShift        =     12;
	uiChrPriMask         =      1;
	uiChrPriShift        =     15;
	uiChrPalMask         =      3;
	uiChrPalShift        =     13;
	uiChrNumMask         = 0x07FF;
	uiChrNumShift        =      0;

	return;
	}



// **************************************************************************
//	SetSFX ()
//
//	Usage
//		static void SetSFX()
//
//	Description
//		Set up the defaults for SNES conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetSFX (void)

	{
	uiMachineType        = MACHINE_SFX;
	uiOutputOrder        = ORDERLOHI;
	uiMapType            = MAP_CHR;
	flUseNewPalette      = YES;

	uiChrBitSize         =     16;
	uiChrXFlShift        =     14;
	uiChrYFlShift        =     15;
	uiChrPriMask         =      1;
	uiChrPriShift        =     13;
	uiChrPalMask         =      7;
	uiChrPalShift        =     10;
	uiChrNumMask         = 0x03FF;
	uiChrNumShift        =      0;

	return;
	}

// **************************************************************************
//	SetAGB ()
//
//	Usage
//		static void SetAGB()
//
//	Description
//		Set up the defaults for AGB conversions.
// (DA) This isn't correct...
//	Return Value
//		None.
// **************************************************************************

static	void SetAGB (void)

	{
	uiMachineType        = MACHINE_AGB;
	uiOutputOrder        = ORDERLOHI;
	uiMapType            = MAP_CHR;
	flUseNewPalette      = YES;

	uiChrBitSize         =     16;
	uiChrXFlShift        =     10;
	uiChrYFlShift        =     11;
	uiChrPriMask         =      0;
	uiChrPriShift        =      0;
	uiChrPalMask         =     15;
	uiChrPalShift        =     12;
	uiChrNumMask         = 0x03FF;
	uiChrNumShift        =      0;

	return;
	}



// **************************************************************************
//	Set3DO ()
//
//	Usage
//		static void Set3DO()
//
//	Description
//		Set up the defaults for 3DO conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void Set3DO (void)

	{
	uiMachineType        = MACHINE_3DO;
	uiOutputOrder        = ORDERHILO;
	uiMapType            = MAP_PXL;
	uiSprBPP             = 6;
	ulSprMask            = 0x0000003Fl;
	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_PACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = YES;
	flRemoveBlankSprs    = YES;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;
	flUseNewPalette      = NO;

	return;
	}



// **************************************************************************
//	SetSAT ()
//
//	Usage
//		static void SetSAT()
//
//	Description
//		Set up the defaults for SATURN conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetSAT (void)

	{
	uiMachineType        = MACHINE_SAT;
	uiOutputOrder        = ORDERHILO;
	uiMapType            = MAP_PXL;
	uiSprBPP             = 4;
	ulSprMask            = 0x0000000Fl;
	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_UNPACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = YES;
	flRemoveBlankSprs    = NO;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;
	flUseNewPalette      = NO;

	uiChrBitSize         =     16;
	uiChrXFlShift        =     16;
	uiChrYFlShift        =     16;
	uiChrPriMask         =      1;
	uiChrPriShift        =     16;
	uiChrPalMask         =     15;
	uiChrPalShift        =     12;
	uiChrNumMask         = 0x0FFF;
	uiChrNumShift        =      0;

	return;
	}



// **************************************************************************
//	SetPSX ()
//
//	Usage
//		static void SetPSX()
//
//	Description
//		Set up the defaults for PSX conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetPSX (void)

	{
	uiMachineType        = MACHINE_PSX;
	uiOutputOrder        = ORDERLOHI;
	uiMapType            = MAP_PXL;
	uiSprBPP             = 4;
	ulSprMask            = 0x0000000Fl;
	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_UNPACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = YES;
	flRemoveBlankSprs    = NO;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;
	flUseNewPalette      = NO;

	return;
	}



// **************************************************************************
//	SetIBM ()
//
//	Usage
//		static void SetIBM()
//
//	Description
//		Set up the defaults for IBM conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetIBM (void)

	{
	uiMachineType        = MACHINE_IBM;
	uiOutputOrder        = ORDERLOHI;
	uiMapType            = MAP_PXL;
	uiSprBPP             = 8;
	ulSprMask            = 0x000000FFl;
	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_UNPACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = YES;
	flRemoveBlankSprs    = NO;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;
	flUseNewPalette      = NO;
	flWriteRES           = YES;
	flPaletteSPL         = YES;

	return;
	}



// **************************************************************************
//	SetN64 ()
//
//	Usage
//		static void SetN64()
//
//	Description
//		Set up the defaults for N64 conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetN64 (void)

	{
	uiMachineType        = MACHINE_N64;
	uiOutputOrder        = ORDERHILO;
	uiMapType            = MAP_PXL;
	uiSprBPP             = 8;
	ulSprMask            = 0x000000FFl;
	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_UNPACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = YES;
	flRemoveBlankSprs    = NO;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;
	flUseNewPalette      = NO;
	flWriteRES           = YES;
	flPaletteSPL         = NO;

	flZeroPosition       = YES;

	return;
	}



// **************************************************************************
//	SetGMB ()
//
//	Usage
//		static void SetGMB()
//
//	Description
//		Set up the defaults for Gameboy conversions.
//
//	Return Value
//		None.
// **************************************************************************

static	void SetGMB (void)

	{
	uiMachineType        = MACHINE_GMB;
	uiOutputOrder        = ORDERLOHI;
	uiMapType            = MAP_CHR;
	flUseNewPalette      = YES;

	uiSprCoding          = ENCODED_PALETTE;
	uiSprCompression     = ENCODED_UNPACKED;
	uiSprDirection       = TOPTOBOTTOM;
	flRemoveBlankMaps    = NO;
	flRemoveBlankSprs    = NO;
	flRemoveSprRepeats   = YES;
	flRemoveIdxRepeats   = NO;

	flWriteEQU           = YES;

	uiChrBitSize         =     16;
	uiChrXFlShift        =     13;
	uiChrYFlShift        =     14;
	uiChrPriMask         =      1;
	uiChrPriShift        =     15;
	uiChrPalMask         =      7;
	uiChrPalShift        =      8;
	uiChrNumMask         = 0x01FF;
	uiChrNumShift        =      0;

	ChrInfo.ui___chrPxlBits = 2;

	flOutputWordIdx = NO;

	return;
	}



// **************************************************************************
//	GlobalAlloc ()
//
//	Usage
//		global ERRORCODE GlobalAlloc ()
//
//	Description
//		Allocate the global memory buffers.
//
//	Return Value
//		ERROR_NONE if OK, ERROR_NO_MEMORY if failed.
// **************************************************************************


global	ERRORCODE GlobalAlloc (void)

	{

	// Initialize the pointers to NULL so that we don't try to free any
	// unallocated ptrs if something goes wrong.

	ChrInfo.pud__chrBufKeys  = NULL;
	ChrInfo.pud__chrBufData  = NULL;

	BlkInfo.puw__blkBufKeys  = NULL;
	BlkInfo.puw__blkBufData  = NULL;

	MapInfo.ppud_mapBufIndx  = NULL;
	MapInfo.pud__mapBufKeys  = NULL;
	MapInfo.puw__mapBufData  = NULL;

	MapInfo.acl__mapsBufIndx = NULL;
	MapInfo.puw__mapsBuf1st  = NULL;

	SprInfo.acl__sprsBufIndx = NULL;
	SprInfo.pbf__sprsBuf1st  = NULL;

	FntInfo.acl__fntsBufIndx = NULL;
	FntInfo.pbf__fntsBuf1st  = NULL;

	PalInfo.acl__palsBufIndx = NULL;
	PalInfo.pbf__palsBuf1st  = NULL;

	// Allocate the chr buffers.

	ChrInfo.ui___chrXPxlSize   = 8;
	ChrInfo.ui___chrXPxlShift  = 3;
	ChrInfo.ui___chrYPxlSize   = 8;
	ChrInfo.ui___chrYPxlShift  = 3;
	ChrInfo.ui___chrPxlBits    = 4;
	ChrInfo.ui___chrU32Size    = 8;
	ChrInfo.ui___chrU32Shift   = 3;
	ChrInfo.ui___chrBytSize    = 32;
	ChrInfo.ui___chrBytShift   = 5;

	ChrInfo.ui___chrCount      = 0;
	ChrInfo.ui___chrMaximum    = XS_MAX_CHR;

	if ((ChrInfo.pud__chrBufKeys	=
		malloc(XS_MAX_CHR * sizeof(UD ))) == NULL) goto errorExit;
	if ((ChrInfo.pud__chrBufData	=
		malloc(XS_BUF_CHR)) == NULL) goto errorExit;

	ChrInfo.pud__chrBufEnd = ChrInfo.pud__chrBufData + (XS_BUF_CHR / sizeof(UD ));

	// Allocate the blk buffers.

	BlkInfo.ui___blkXChrSize   = 2;
	BlkInfo.ui___blkYChrSize   = 2;
	BlkInfo.ui___blkChrSize    = 4;
	BlkInfo.ui___blkBytSize    = 8;

	BlkInfo.ui___blkCount      = 0;
	BlkInfo.ui___blkMaximum    = XS_MAX_BLK;

	if ((BlkInfo.puw__blkBufKeys	=
		malloc(XS_MAX_BLK * sizeof(UW ))) == NULL) goto errorExit;
	if ((BlkInfo.puw__blkBufData	=
		malloc(XS_BUF_BLK)) == NULL) goto errorExit;

	BlkInfo.puw__blkBufEnd = BlkInfo.puw__blkBufData + (XS_BUF_BLK / sizeof(UW));

	// Allocate the map buffers.

	MapInfo.ui___mapsCount   = 0;
	MapInfo.ui___mapsMaximum = XS_MAX_MAP;

//	if ((MapInfo.ppud_mapBufIndx =
//		malloc(XS_MAX_MAP * sizeof(UW *))) == NULL) goto errorExit;
//	if ((MapInfo.pud__mapBufKeys =
//		malloc(XS_MAX_MAP * sizeof(UD ))) == NULL) goto errorExit;
//	if ((MapInfo.puw__mapBufData =
//		malloc(XS_BUF_MAP)) == NULL) goto errorExit;
//
//	MapInfo.puw__mapBufEnd = MapInfo.puw__mapBufData + (XS_BUF_MAP / sizeof(UW));
//	MapInfo.ppud_mapBufIndx[0] = (UD *) (&(MapInfo.puw__mapBufData[0]));

	if ((MapInfo.acl__mapsBufIndx =
		malloc(XS_MAX_MAP * sizeof(DATAMAPIDX_T))) == NULL) goto errorExit;
	if ((MapInfo.puw__mapsBuf1st  = (UW *)
		malloc(XS_BUF_MAP)) == NULL) goto errorExit;

	MapInfo.puw__mapsBufCur = MapInfo.puw__mapsBuf1st;
	MapInfo.puw__mapsBufEnd = MapInfo.puw__mapsBuf1st + (XS_BUF_MAP / sizeof(UW));

	// Allocate the spr buffers.

	SprInfo.ui___sprsCount      = 0;
	SprInfo.ui___sprsMaximum    = XS_MAX_SPR;

	if ((SprInfo.acl__sprsBufIndx =
		malloc(XS_MAX_SPR * sizeof(DATASPRIDX_T))) == NULL) goto errorExit;
	if ((SprInfo.pbf__sprsBuf1st  =
		malloc(XS_BUF_SPR)) == NULL) goto errorExit;

	SprInfo.pbf__sprsBufCur = SprInfo.pbf__sprsBuf1st;
	SprInfo.pbf__sprsBufEnd = SprInfo.pbf__sprsBuf1st + XS_BUF_SPR;

	// Allocate the fnt buffers.

	FntInfo.ui___fntsCount      = 0;
	FntInfo.ui___fntsMaximum    = XS_MAX_FNT;

	if ((FntInfo.acl__fntsBufIndx =
		malloc(XS_MAX_FNT * sizeof(DATAFNTIDX_T))) == NULL) goto errorExit;
	if ((FntInfo.pbf__fntsBuf1st  =
		malloc(XS_BUF_FNT)) == NULL) goto errorExit;

	FntInfo.pbf__fntsBufCur = FntInfo.pbf__fntsBuf1st;
	FntInfo.pbf__fntsBufEnd = FntInfo.pbf__fntsBuf1st + XS_BUF_FNT;

	FntInfo.ui___fntsKrnCnt = 0;
	FntInfo.ui___fntsKrnMax = XS_MAX_KRN;

	if ((FntInfo.acl__fntsKrnTbl =
		malloc(XS_MAX_KRN * sizeof(KERNPAIR_T))) == NULL) goto errorExit;

	// Allocate the pal buffers.

	PalInfo.ui___palsCount      = 0;
	PalInfo.ui___palsMaximum    = XS_MAX_PAL;

	if ((PalInfo.acl__palsBufIndx =
		malloc(XS_MAX_PAL * sizeof(DATAPALIDX_T))) == NULL) goto errorExit;
	if ((PalInfo.pbf__palsBuf1st  =
		malloc(XS_BUF_PAL)) == NULL) goto errorExit;

	PalInfo.pbf__palsBufCur = PalInfo.pbf__palsBuf1st;
	PalInfo.pbf__palsBufEnd = PalInfo.pbf__palsBuf1st + XS_BUF_PAL;

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		ErrorCode = ERROR_NO_MEMORY;

		sprintf(ErrorMessage,
			"Not enough memory to allocate global buffers.\n"
			"XS, GlobalAlloc.\n");

		return (ErrorCode);

	}



// **************************************************************************
//	GlobalFree ()
//
//	Usage
//		global void GlobalFree ()
//
//	Description
//		Free up the global memory buffers.
//
//	Return Value
//		None.
// **************************************************************************

global	void GlobalFree (void)

	{

	// Free only the buffers that were allocated (some may not have been if
	// we ran out of memory during GlobalAlloc()).

	if (ChrInfo.pud__chrBufKeys  != NULL) free(ChrInfo.pud__chrBufKeys);
	if (ChrInfo.pud__chrBufData  != NULL) free(ChrInfo.pud__chrBufData);

	if (BlkInfo.puw__blkBufKeys  != NULL) free(BlkInfo.puw__blkBufKeys);
	if (BlkInfo.puw__blkBufData  != NULL) free(BlkInfo.puw__blkBufData);

	if (MapInfo.ppud_mapBufIndx  != NULL) free(MapInfo.ppud_mapBufIndx);
	if (MapInfo.pud__mapBufKeys  != NULL) free(MapInfo.pud__mapBufKeys);
	if (MapInfo.puw__mapBufData  != NULL) free(MapInfo.puw__mapBufData);

	if (MapInfo.acl__mapsBufIndx != NULL) free(MapInfo.acl__mapsBufIndx);
	if (MapInfo.puw__mapsBuf1st  != NULL) free(MapInfo.puw__mapsBuf1st);

	if (SprInfo.acl__sprsBufIndx != NULL) free(SprInfo.acl__sprsBufIndx);
	if (SprInfo.pbf__sprsBuf1st  != NULL) free(SprInfo.pbf__sprsBuf1st);

	if (FntInfo.acl__fntsBufIndx != NULL) free(FntInfo.acl__fntsBufIndx);
	if (FntInfo.pbf__fntsBuf1st  != NULL) free(FntInfo.pbf__fntsBuf1st);

	if (PalInfo.acl__palsBufIndx != NULL) free(PalInfo.acl__palsBufIndx);
	if (PalInfo.pbf__palsBuf1st  != NULL) free(PalInfo.pbf__palsBuf1st);

	return;

	}



// **************************************************************************
//	SetDiagnosticName ()
//
//	Usage
//		global ERRORCODE SetDiagnosticName (char * string)
//
//	Description
//		Set the diagnostic output filename.
//
//	Return Value
//		None.
// **************************************************************************

global	ERRORCODE SetDiagnosticName (char * string)

	{

	// Local variables.

	char *      p;

	//

	while ((p = strchr(string, '\\')) != NULL) {
		string = p + 1;
		}

	strcpy(pcz__DebugNamePtr, string);

	if ((p = strchr(pcz__DebugNamePtr, '.')) != NULL) {
		pcz__DebugNameExt = p;
		} else {
		pcz__DebugNameExt = strchr(pcz__DebugNamePtr, '\0');
		}

	string = pcz__DebugNamePtr + 5;

	while (pcz__DebugNameExt < string) *pcz__DebugNameExt++ = '0';

	strcpy(pcz__DebugNamePtr+5, "000.pcx");

	pcz__DebugNameExt = pcz__DebugNamePtr + 9;

	// Return with success code.

	return (ERROR_NONE);

	}



// **************************************************************************
//	IncDiagnosticName ()
//
//	Usage
//		global void IncDiagnosticName ()
//
//	Description
//		Increment the diagnostic output filename.
//
//	Return Value
//		None.
// **************************************************************************

global	void IncDiagnosticName ()

	{
	char * string;
	UI     i;

	string = pcz__DebugNameExt - 2;

	i = 4;

	while (i-- != 0)
		{
		if (*string != '9') {
			*string += 1;
			break;
			} else {
			*string = '0';
			string -= 1;
			}
		}
	return;
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
//	GetToken ()
//
//	Usage
//		static char * GetToken (void)
//
//	Description
//		Process the command line passed in 'string'.
//
//	Return Value
//		ERROR_NONE if OK, ERROR_NO_MEMORY if failed.
// **************************************************************************

static	char *		GetToken (char * filter)

	{
	// Local variables.

	// Are we reading a command file or the program arguments ?

	if (pcl__CommandFile != NULL)
		{
		if (pcz__CommandString != NULL)
			{
			pcz__CommandString = strtok(NULL, filter);
			}

		if (pcz__CommandString == NULL)
			{
			do	{
				si___CommandLine += 1;

				if (fgets(acz__CommandBuffer, 512, pcl__CommandFile) == NULL)
					{
					fclose(pcl__CommandFile);

					pcz__CommandString = NULL;
					pcl__CommandFile   = NULL;
					si___CommandLine   = 0;

					break;
					}

				pcz__CommandString = strtok(acz__CommandBuffer, filter);

				} while ((pcz__CommandString == NULL) || (*pcz__CommandString == ';'));
			}
		}

	if (pcz__CommandString != NULL)
		{
		return (pcz__CommandString);
		}
	else
		{
		// Get next token from the command line.

		if (si___CommandArg != si___Argc)
			{
			return (ppcz_Argv[si___CommandArg++]);
			}
		}

	// All tokens read, return end of commands marker.

	return (NULL);
	}



// **************************************************************************
//	ProcessToken ()
//
//	Usage
//		static ERRORCODE ProcessLine (char * string)
//
//	Description
//		Process the command line passed in 'string'.
//
//	Return Value
//		ERROR_NONE if OK, ERROR_NO_MEMORY if failed.
// **************************************************************************

global	int                 ProcessToken            (
								char *              pcz__Token)

	{
	// Is the token a command file ?

	if (*pcz__Token == '@')
		{
		// Skip the leading '@'.

		pcz__Token++;

		// Is there already an open command file ?

		openCMD:

		if (pcl__CommandFile != NULL)
			{
			ErrorCode = ERROR_ILLEGAL;
			sprintf(ErrorMessage,
				"GmbSpr error : Unable to open nested command file %s at line %d.\n",
				pcz__Token, si___CommandLine);
			goto errorExit;
			}

		// Open the command file.

		pcz__CommandString = NULL;
		si___CommandLine   = 0;

		if ((pcl__CommandFile = fopen(pcz__Token,"rt")) == NULL)
			{
			ErrorCode = ERROR_NO_FILE;
			sprintf(ErrorMessage,
				"GmbSpr error : Unable to open command file %s.\n",
				pcz__Token);
			goto errorExit;
			}

		printf("CommandFile = %s\n", pcz__Token);
		}

	// Is the token an option ?

	else

	if (*pcz__Token == '-')
		{
		if (ProcessOption(pcz__Token) != ERROR_NONE) goto errorExit;
		}

	// If neither of the above, then it must be a filename.

	else
		{
		// If this is the first filename, then preserve it.

		if (*acz__FileOut == '\0')
			{
			strcpy(acz__FileOut, pcz__Token);
			}

		// Is this actually a command file ?

		_splitpath(pcz__Token, acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

		if (strcmpi(acz__FileExt, ".cmd") == 0) goto openCMD;

		// Process graphics file.

		if (ProcessFile(pcz__Token) != ERROR_NONE) goto errorExit;
//		if (ProcessFileSpec(pcz__Token) != ERROR_NONE) goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ProcessFile ()
//
//	Usage
//		static ERRORCODE ProcessFile (char * string)
//
//	Description
//		Process the command line passed in 'string'.
//
//	Return Value
//		ERROR_NONE if OK, ERROR_NO_MEMORY if failed.
// **************************************************************************

static	ERRORCODE	ProcessFile (char * string)

	{

	// Has the machine type been set ?

	if (uiMachineType == 0)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Machine type be selected before line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Make sure that the characters and blocks are initialized.

	InitCHRSet();
	InitBLKSet();

	// Convert the file.

	uiFileCount += 1;

	pu16FrmBufTmp = &au16FrmBufTmp[0];
	pu16FrmBufTmp = ConvertFile(string, pu16FrmBufTmp, pu16FrmBufTmp+8);

	if (pu16FrmBufTmp == NULL)
		{
		goto errorExit;
		}

	#if 0
	if (uiFrameCount == 0)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"No 1st body part, file is empty.\n"
			"(XS, ProcessLine)\n");
		goto errorExit;
		}
	#endif

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ProcessOption ()
//
//	Usage
//		static ERRORCODE ProcessOption (char * string)
//
//	Description
//		Process the command line passed in 'string'.
//
//	Return Value
//		ERROR_NONE if OK, ERROR_NO_MEMORY if failed.
// **************************************************************************

static	ERRORCODE	ProcessOption (char * op)

	{

	// Local variables.

	UI				i;
	SL				l;
	SL				m;
	SL				n;
	char *string,optcopy[256];

	strcpy(optcopy,op);
	string=optcopy;

	// Skip the leading '-' and uppercase the rest of the token.

	string++;

	strupr(string);

	// Identify which option.

	for (i = 0; i < NUMBER_OF_OPTIONS; i = i + 1)
		{
		if (strcmp(string, OptionList[i]) == 0) break;
		}

	// Act upon the option.

	switch (i)

		{
		// Print help message ?

		case HELPMSG0:
		case HELPMSG1:
			{
			puts(
				"\n"
				"This utility converts bitmap data into character maps,\n"
				"sprites and fonts suitable for a variety of platforms.\n"
				"\n"
				"Input files    - LBM (PC-DeluxePaint 8bpp PBM)\n"
				"               - ABM (PC-DeluxeAnim  8bpp ABM)\n"
				"               - SPR (ProMotion 8bpp Sprite)\n"
				"               - PCX (4bpp & 8bpp)\n"
//				"               - TGA (8bpp)\n"
				"\n"
				"Output formats - Genesis, SNES, 3DO, Saturn, PlayStation, PC, N64, Gameboy,\n"
				"                 Advanced Gameboy.\n"
				"\n"
				"Usage : XS <commandfile>\n");
			break;
			}

		// New uiMachineType ?

		case MACHINE: {
			if (SetMachineType(&uiMachineType) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiOutputOrder ?

		case OUTPUTORDER: {
			if (SetOrderValue(&uiOutputOrder) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flOutputMapIndex ?

		case OUTPUTMAPINDEX: {
			if (SetFlagValue(&flOutputMapIndex) != ERROR_NONE) goto errorExit;
			break;
			}

		// New slOutputMapStart ?

		case OUTPUTMAPSTART:
			{
			if (!GetValue(&l, "OUTPUTMAPSTART")) goto errorExit;
			slOutputMapStart = l;
			break;
			}

		// New flOutputMapPosition ?

		case OUTPUTMAPPOSITION: {
			if (SetFlagValue(&flOutputMapPosition) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flOutputMapBoxSize ?

		case OUTPUTMAPBOXSIZE: {
			if (SetFlagValue(&flOutputMapBoxSize) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flOutputByteMap ?

		case OUTPUTBYTEMAP: {
			if (SetFlagValue(&flOutputByteMap) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flOutputWordOffsets ?

		case OUTPUTWORDOFFSETS: {
			if (SetFlagValue(&flOutputWordOffsets) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiMapType ?

		case MAPTYPE: {
			if (SetMapType(&uiMapType) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flReferenceFrame ?

		case REFERENCEFRAME: {
			if (SetFlagValue(&flReferenceFrame) != ERROR_NONE) goto errorExit;

			if (uiMapType == MAP_FNT) flReferenceFrame = NO;

			if (flReferenceFrame == YES) flZeroPosition = NO;

			break;
			}

		// New flFindEdges ?

		case FINDEDGES: {
			if (SetFlagValue(&flFindEdges) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flRemoveXXXRepeats ?

		case REMOVECHRREPEATS: {
			if (SetFlagValue(&flRemoveChrRepeats) != ERROR_NONE) goto errorExit;
			break;
			}

		case REMOVEBLKREPEATS: {
			if (SetFlagValue(&flRemoveBlkRepeats) != ERROR_NONE) goto errorExit;
			break;
			}

		case REMOVEMAPREPEATS: {
			if (SetFlagValue(&flRemoveMapRepeats) != ERROR_NONE) goto errorExit;
			break;
			}

		case REMOVESPRREPEATS: {
			if (SetFlagValue(&flRemoveSprRepeats) != ERROR_NONE) goto errorExit;
			break;
			}

		case REMOVEIDXREPEATS: {
			if (SetFlagValue(&flRemoveIdxRepeats) != ERROR_NONE) goto errorExit;
			break;
			}

		// New FlagRemoveBlankXXX ?

		case REMOVEBLANKMAPS: {
			if (SetFlagValue(&flRemoveBlankMaps) != ERROR_NONE) goto errorExit;
			break;
			}

		case REMOVEBLANKSPRS: {
			if (SetFlagValue(&flRemoveBlankSprs) != ERROR_NONE) goto errorExit;
			break;
			}

		// New character width value ?

		case CHRWIDTH:
			{
			if (ChrInfo.ui___chrCount != 0) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Characters already defined before CHRWIDTH at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			if (!GetValue(&l, "CHRWIDTH")) goto errorExit;
			if (l == 8) {
				ChrInfo.ui___chrXPxlSize  = 8;
				ChrInfo.ui___chrXPxlShift = 3;
				}
			else if (l == 16) {
				ChrInfo.ui___chrXPxlSize  = 16;
				ChrInfo.ui___chrXPxlShift = 4;
				}
			else
				{
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Illegal CHRWIDTH value at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			break;
			}

		// New character height value ?

		case CHRHEIGHT:
			{
			if (ChrInfo.ui___chrCount != 0) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Characters already defined before CHRHEIGHT at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			if (!GetValue(&l, "CHRHEIGHT")) goto errorExit;
			if (l == 8) {
				ChrInfo.ui___chrYPxlSize  = 8;
				ChrInfo.ui___chrYPxlShift = 3;
				}
			else if (l == 16) {
				ChrInfo.ui___chrYPxlSize  = 16;
				ChrInfo.ui___chrYPxlShift = 4;
				}
			else
				{
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Illegal CHRHEIGHT value at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			break;
			}

		// New characters bits per pixel ?

		case CHRBITSPERPIXEL:
			{
			if (ChrInfo.ui___chrCount != 0) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Characters already defined before CHRBITSPERPIXEL at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			if (!GetValue(&l, "CHRBITSPERPIXEL")) goto errorExit;
			switch (l) {
				case 2 :
					ChrInfo.ui___chrPxlBits = 2;
					break;
				case 4 :
					ChrInfo.ui___chrPxlBits = 4;
					break;
				case 8 :
					ChrInfo.ui___chrPxlBits = 8;
					break;
				default :
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal CHRBITSPERPIXEL value at line %d.\n"
						"(XS, ProcessLine)\n",
						(UI) si___CommandLine);
					goto errorExit;
				}
			break;
			}

		// New flChrXFlipAllowed ?

		case ALLOWCHRXFLIP:
			{
			if (SetFlagValue(&flChrXFlipAllowed) != ERROR_NONE) goto errorExit;
			if (flChrXFlipAllowed == YES) {
				flStoreChrFlip = YES;
				} else {
				if (flChrYFlipAllowed == NO) {
					flStoreChrFlip = NO;
					}
				}
			break;
			}

		// New flChrYFlipAllowed ?

		case ALLOWCHRYFLIP:
			{
			if (SetFlagValue(&flChrYFlipAllowed) != ERROR_NONE) goto errorExit;
			if (flChrYFlipAllowed == YES) {
				flStoreChrFlip = YES;
				} else {
				if (flChrXFlipAllowed == NO) {
					flStoreChrFlip = NO;
					}
				}
			break;
			}

		// New flStoreChrNumber ?

		case STORECHRNUMBER: {
			if (SetFlagValue(&flStoreChrNumber) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flStoreChrPriority ?

		case STORECHRPRIORITY: {
			if (SetFlagValue(&flStoreChrPriority) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flStoreChrFlip ?

		case STORECHRFLIP: {
			if (SetFlagValue(&flStoreChrFlip) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flStoreChrPalette ?

		case STORECHRPALETTE: {
			if (SetFlagValue(&flStoreChrPalette) != ERROR_NONE) goto errorExit;
			break;
			}

		// New block width value ?

		case BLKWIDTH:
			{
			if (BlkInfo.ui___blkCount != 0) {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : BLKWIDTH defined after CHRMAPTOBLKMAP at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			if (!GetValue(&l, "BLKWIDTH")) goto errorExit;

			if ((l < 1) || (l > 7))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Illegal BLKWIDTH value at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			BlkInfo.ui___blkXChrSize = (UI) l;

			break;
			}

		// New block height value ?

		case BLKHEIGHT:
			{
			if (BlkInfo.ui___blkCount != 0) {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : BLKHEIGHT defined after CHRMAPTOBLKMAP at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			if (!GetValue(&l, "BLKHEIGHT")) goto errorExit;

			if ((l < 1) || (l > 7))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Illegal BLKHEIGHT value at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			BlkInfo.ui___blkYChrSize = (UI) l;

			break;
			}

		// New ChrMapOrder setting ?

		case CHRMAPORDER: {
			if (SetOrderType(&uiChrMapOrder) != ERROR_NONE) goto errorExit;
			break;
			}

		// New ChrMapOffset value ?

		case CHRMAPOFFSET:
			{
			if (!GetValue(&l, "CHRMAPOFFSET")) goto errorExit;
			uiChrMapOffset = (UI) l;
			break;
			}

		// New flChrMapToBlkMap ?

		case CHRMAPTOBLKMAP: {
			if (SetFlagValue(&flChrMapToBlkMap) != ERROR_NONE) goto errorExit;
			break;
			}

		#if 0
			// New flMapXFlipAllowed ?

			case ALLOWMAPXFLIP: {
				if (SetFlagValue(&flMapXFlipAllowed) != ERROR_NONE) goto errorExit;
				break;
				}

			// New flMapYFlipAllowed ?

			case ALLOWMAPYFLIP: {
				if (SetFlagValue(&flMapYFlipAllowed) != ERROR_NONE) goto errorExit;
				break;
				}
		#endif

		// New flStoreMapPosition ?

		case STOREMAPPOSITION: {
			if (SetFlagValue(&flStoreMapPosition) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flStoreMapPalette ?

		case STOREMAPPALETTE: {
			if (SetFlagValue(&flStoreMapPalette) != ERROR_NONE) goto errorExit;
			break;
			}

		// New MapBoxFactor ?

		case BOX: {
			if (!GetValue(&l, "BOX")) goto errorExit;

			if ((l < 0) || (l > 200)) {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : BOX value out of range at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			uiMapBoxFactor = l;
			break;
			}

		// New flClrPriority ?

		case CLRPRIORITY: {
			if (SetFlagValue(&flClrPriority) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flSetPriority ?

		case SETPRIORITY: {
			if (SetFlagValue(&flSetPriority) != ERROR_NONE) goto errorExit;
			break;
			}

		// Inform user of something ?

		case INFORM: {
			string = GetToken("\n");
			while ((*string == ' ') || (*string == '\t')) {
				string += 1;
				}
			fputs(string, stderr);
			fputs("\n",stderr);
			break;
			}

		// Clear chrs ?

		case CLEARCHRS: {
			ChrInfo.ui___chrCount = 0;
			break;
			}

		// Clear blks ?

		case CLEARBLKS: {
			BlkInfo.ui___blkCount = 0;
			break;
			}

		// Clear maps ?

		case CLEARMAPS: {
			MapInfo.ui___mapsCount = 1;
			break;
			}

		// Clear sprites ?

		case CLEARSPRS: {
			SprInfo.ui___sprsCount = 0;
			break;
			}

		// New palette override code value ?

		case OVERRIDE: {
			if (!GetValue(&l, "OVERRIDE")) goto errorExit;

			if ((l < 0) || (l > 255)) {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : OVERRIDE value out of range at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			uiOverrideCode = l;
			break;
			}

		// New ChrsToStrip value ?

		case CHRSTOSTRIP: {
			if (!GetValue(&l, "CHRSTOSTRIP")) goto errorExit;
			uiChrsToStrip = (UI) l;
			break;
			}

		// New flWriteRGB ?

		case WRITERGB: {
			if (SetFlagValue(&flWriteRGB) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteCHR ?

		case WRITECHR: {
			if (SetFlagValue(&flWriteCHR) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteBLK ?

		case WRITEBLK: {
			if (SetFlagValue(&flWriteBLK) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteMAP ?

		case WRITEMAP: {
			if (SetFlagValue(&flWriteMAP) != ERROR_NONE) goto errorExit;
			break;
			}

		case WRITEEQU: {
			if ( SetFlagValue(&flWriteEQU) != ERROR_NONE) goto errorExit;
			break;
			}

		case EMPTYCHRZERO:
			if ( SetFlagValue(&flEmptyChrZero) != ERROR_NONE) goto errorExit;
			break;
		case BRIGHTERCOLORS:
			if ( SetFlagValue(&flBrighterColors) != ERROR_NONE) goto errorExit;
			break;

		// New flWriteSPR ?

		case WRITESPR: {
			if (SetFlagValue(&flWriteSPR) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteIDX ?

		case WRITEIDX: {
			if (SetFlagValue(&flWriteIDX) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteFNT ?

		case WRITEFNT: {
			if (SetFlagValue(&flWriteFNT) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteFNT ?

		case WRITERES: {
			if (SetFlagValue(&flWriteRES) != ERROR_NONE) goto errorExit;
			break;
			}

		// Pad out the character set.

		case PADTOCHR:
			{
			InitCHRSet();

			if (!GetValue(&l, "PADTOCHR")) goto errorExit;

			if (l >= XS_MAX_CHR) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Illegal PADTOCHR value at line %d, only room for %d characters.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine,
					(UI) XS_MAX_CHR);
				goto errorExit;
				}

			i = (UI) l;

			if (i < ChrInfo.ui___chrCount) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Illegal PADTOCHR value at line %d, already at character %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine,
					(UI) ChrInfo.ui___chrCount);
				goto errorExit;
				}

			if (i > ChrInfo.ui___chrCount)
				{
				memset(
					((UB *) ChrInfo.pud__chrBufData) + (((size_t) ChrInfo.ui___chrCount) << ChrInfo.ui___chrBytShift),
					0,
					ChrInfo.ui___chrBytSize * (i - ChrInfo.ui___chrCount)
					);
				while (i > ChrInfo.ui___chrCount)
					{
					ChrInfo.pud__chrBufKeys[ChrInfo.ui___chrCount++] = 0;
					}
				}

			break;
			}

		// New flUseNewPalette ?

		case USENEWPALETTE: {
			if (SetFlagValue(&flUseNewPalette) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flPaletteAlphaRGB ?

		case PALETTEALPHARGB: {
			flPaletteAlphaBGR = NO;
			if (SetFlagValue(&flPaletteAlphaRGB) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flPaletteAlphaBGR ?

		case PALETTEALPHABGR: {
			flPaletteAlphaRGB = NO;
			if (SetFlagValue(&flPaletteAlphaBGR) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiSprBPP ?

		case SPRBITSPERPIXEL:
			{
			if (!GetValue(&l, "SPRBITSPERPIXEL")) goto errorExit;

			switch (l)
				{
				case 1:
					uiSprBPP  = 1;
					ulSprMask = 0x00000001L;
					break;
				case 2:
					uiSprBPP  = 2;
					ulSprMask = 0x00000003L;
					break;
				case 4:
					uiSprBPP  = 4;
					ulSprMask = 0x0000000FL;
					break;
				case 6:
					uiSprBPP  = 6;
					ulSprMask = 0x0000003FL;
					break;
				case 8:
					uiSprBPP  = 8;
					ulSprMask = 0x000000FFL;
					break;
				case 16:
					uiSprBPP  = 16;
					ulSprMask = 0x00007FFFL;
					break;
				default:
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal SPRBITSPERPIXEL value at line %d.\n"
						"(XS, ProcessLine)\n",
						(UI) si___CommandLine);
					goto errorExit;
				}
			break;
			}

		// New uiSprCoding ?

		case SPRCODING: {
			if (SetCodingType(&uiSprCoding) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiSprCompression ?

		case SPRCOMPRESSION: {
			if (SetCompressionType(&uiSprCompression) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiSprDirection ?

		case SPRDIRECTION: {
			if (SetDirection(&uiSprDirection) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flShrinkInput ?

		case SHRINKINPUT: {
			if (SetFlagValue(&flShrinkInput) != ERROR_NONE) goto errorExit;
			break;
			}

		// New RemappingTable ?

		case LOADREMAPTABLE: {
			string = GetToken(" \t\n");
			if (string == NULL) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Filename missing after LOADREMAPTABLE option at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			if (LoadRemapTbl(string) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flRemapInput ?

		case REMAPINPUT: {
			if (SetFlagValue(&flRemapInput) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flFilterInput ?

		case FILTERINPUT: {
			if (SetFlagValue(&flFilterInput) != ERROR_NONE) goto errorExit;
			break;
			}

		// New uiFilterBelow ?

		case FILTERBELOW: {
			if (!GetValue(&l, "FILTERBELOW")) goto errorExit;
			uiFilterBelow = l;
			break;
			}

		// New uiFilterAbbove ?

		case FILTERABOVE: {
			if (!GetValue(&l, "FILTERABOVE")) goto errorExit;
			uiFilterAbove = l;
			break;
			}

		// New flFilterChrs ?

		case FILTERCHRS: {
			if (SetFlagValue(&flFilterChrs) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flZeroTransparent ?

		case ZEROTRANSPARENT: {
			if (SetFlagValue(&flZeroTransparent) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flZeroColour0 ?

		case ZEROCOLOURZERO: {
			if (SetFlagValue(&flZeroColour0) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flUseProcessedName ?

		case USEPROCESSEDNAME: {
			if (SetFlagValue(&flUseProcessedName) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flWriteProcessed ?

		case DUMPFRAMES:
		case WRITEPROCESSED: {
			if (SetFlagValue(&flWriteProcessed) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flProcessOnly ?

		case PROCESSONLY: {
			if (SetFlagValue(&flProcessOnly) != ERROR_NONE) goto errorExit;
			if (flProcessOnly == YES) {
				flWriteRGB = NO;
				flWriteCHR = NO;
				flWriteBLK = NO;
				flWriteMAP = NO;
				flWriteSPR = NO;
				}
			break;
			}

		// New flHistogram ?

		case HISTOGRAM: {
			if (SetFlagValue(&flHistogram) != ERROR_NONE) goto errorExit;
			break;
			}

		// New output directory ?

		case OUTPUTDIR: {
			string = GetToken(" \t\n");
			if (string == NULL) {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Directory name missing after OUTPUTDIR option at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			SetOutputDir(string);
			break;
			}

		// New character map bit size ?

		case CHRBITSIZE: {
			if (MapInfo.ui___mapsCount > 1) {
				ErrorCode = ERROR_ILLEGAL;
				sprintf(ErrorMessage,
					"Maps defined before CHRBITSIZE at line %d.\n"
					"(XS, ProcessLine)\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			if (!GetValue(&l, "CHRBITSIZE")) goto errorExit;
			switch (l) {
				case 16 : uiChrBitSize = 16;
					break;
				case 32 : uiChrBitSize = 32;
					break;
				default :
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal CHRHEIGHT value at line %d.\n"
						"(XS, ProcessLine)\n", (UI) si___CommandLine);
					goto errorExit;
				}
			break;
			}

		// New character map X-flip shift ?

		case CHRXFLIPSHIFT: {
			if (!GetValue(&l, "CHRXFLIPSHIFT")) goto errorExit;
			uiChrXFlShift = l;
			break;
			}

		// New character map Y-flip shift ?

		case CHRYFLIPSHIFT: {
			if (!GetValue(&l, "CHRYFLIPSHIFT")) goto errorExit;
			uiChrYFlShift = l;
			break;
			}

		// New character map priority mask ?

		case CHRPRIORITYMASK: {
			if (!GetValue(&l, "CHRPRIORITYMASK")) goto errorExit;
			uiChrPriMask = l;
			break;
			}

		// New character map priority shift ?

		case CHRPRIORITYSHIFT: {
			if (!GetValue(&l, "CHRPRIORITYSHIFT")) goto errorExit;
			uiChrPriShift = l;
			break;
			}

		// New character map palette mask ?

		case CHRPALETTEMASK: {
			if (!GetValue(&l, "CHRPALETTEMASK")) goto errorExit;
			uiChrPalMask = l;
			break;
			}

		// New character map palette shift ?

		case CHRPALETTESHIFT: {
			if (!GetValue(&l, "CHRPALETTESHIFT")) goto errorExit;
			uiChrPalShift = l;
			break;
			}

		// New character map number mask ?

		case CHRNUMBERMASK: {
			if (!GetValue(&l, "CHRNUMBERMASK")) goto errorExit;
			uiChrNumMask = l;
			break;
			}

		// New character map number shift ?

		case CHRNUMBERSHIFT: {
			if (!GetValue(&l, "CHRNUMBERSHIFT")) goto errorExit;
			uiChrNumShift = l;
			break;
			}

		// New font starting character ?

		case FNTCHR0: {
			if (!GetValue(&l, "FNTCHR0")) goto errorExit;
			uiFntChr0 = l;
			break;
			}

		// New default font X space ?

		case FNTXSPC: {
			if (!GetValue(&l, "FNTXSPC")) goto errorExit;
			uiFntXSpc = l;
			break;
			}

		// New default font Y space ?

		case FNTYSPC: {
			if (!GetValue(&l, "FNTYSPC")) goto errorExit;
			uiFntYSpc = l;
			break;
			}

		// New flFntYDbl ?

		case FNTYDBL: {
			if (SetFlagValue(&flFntYDbl) != ERROR_NONE) goto errorExit;
			break;
			}

		// New string to add to czFntTest ?

		case FNTTEST: {
			if ((string = GetToken("\n")) != NULL)
				{
				if (czFntTest[0] != '\0')
					{
					strcat(czFntTest, "\377");
					}
				while ((*string == ' ') || (*string == '\t'))
					{
					string++;
					}
				if ((strlen(czFntTest) + strlen(string)) < 1022)
					{
					strcat(czFntTest, string);
					}
				}
			break;
			}

		// New font kern pair ?

		case KERNPAIR: {
			if (!GetValue(&l, "KERNPAIR")) goto errorExit;
			if (!GetValue(&m, "KERNPAIR")) goto errorExit;
			if (!GetValue(&n, "KERNPAIR")) goto errorExit;

			if ((l < 1) || (l > 255) || (m < 1) || (m > 255))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Illegal kern pair character at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			if ((n < -128) || (n > 127))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Illegal kern pair delta at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}

			if (!AddKernPair(l, m, n))
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Kern pair already define at line %d.\n",
					(UI) si___CommandLine);
				goto errorExit;
				}
			break;
			}

		// New flFntDebug ?

		case FNTDEBUG: {
			if (SetFlagValue(&flFntDebug) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flPaletteSPL ?

		case PALETTESPL: {
			if (SetFlagValue(&flPaletteSPL) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flZeroPosition ?

		case ZEROPOSITION: {
			if (SetFlagValue(&flZeroPosition) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flSprOnlyLRTB ?

		case SPRONLYLRTB: {
			if (SetFlagValue(&flSprLockYGrid) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flSprLockYGrid ?

		case SPRLOCKYGRID: {
			if (SetFlagValue(&flSprLockYGrid) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flSprLockXGrid ?

		case SPRLOCKXGRID: {
			if (SetFlagValue(&flSprLockXGrid) != ERROR_NONE) goto errorExit;
			break;
			}

		// New flRmvPermanentChr ?

		case RMVPERMANENTCHR: {
			flRmvPermanentChr = YES;
			uiNumPermanentChr = ChrInfo.ui___chrCount;
			*acz__FileOut  = '\0';
			break;
			}

		// New siStaticMapFrame ?

		case STATICMAPFRAME: {
			if (!GetValue(&l, "STATICMAPFRAME")) goto errorExit;
			siStaticMapFrame = l;
			break;
			}

		// Clear Output Name ?

		case CLEARNAME: {
			*acz__FileOut = '\0';
			break;
			}

  		// Unidentified option.

		default: {
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"XS error : Unidentified option at line %d.\n",
				(UI) si___CommandLine);
			goto errorExit;
			}

		}	// End of "switch (i)"

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	GetValue ()
//
//	Usage
//		static FL GetValue (SL * l, char * s)
//
//	Description
//		Get an integer value from the command line.
//
//	Return Value
//		TRUE if OK, FALSE if an error occurred.
// **************************************************************************

static	FL GetValue (SL * l, char * s)

	{
	char * string;
	char * p;

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
		"Value missing after %s option at line %d.\n"
		"(XS, ProcessLine)\n", s, (UI) si___CommandLine);
		return (NO);
		}

	if (string[0] == '\'' || string[0] == '\"')
		{
		if (string[2] == '\'' || string[2] == '\"')
			{
			*l = string[1] & 0xFFu;
			}
		else
			{
			ErrorCode = ERROR_ILLEGAL;
			sprintf(ErrorMessage,
			"Illegal character constant in %s value at line %d.\n"
			"(XS, ProcessLine)\n", s, (UI) si___CommandLine);
			return (NO);
			}
		}
	else
		{
		*l = strtol(string, &p, 0);

		if (*p != '\0')
			{
			ErrorCode = ERROR_ILLEGAL;
			sprintf(ErrorMessage,
			"Illegal characters in %s value at line %d.\n"
			"(XS, ProcessLine)\n", s, (UI) si___CommandLine);
			return (NO);
			}
		}

	return (YES);
	}



// **************************************************************************
//	GetKernChr ()
//
//	Usage
//		static FL GetKernChr (SL * l, char * s)
//
//	Description
//		Get an integer value from the command line.
//
//	Return Value
//		TRUE if OK, FALSE if an error occurred.
// **************************************************************************

static	FL GetKernChr (SL * l, char * s)

	{
	char * string;

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
		"Value missing after %s option at line %d.\n"
		"(XS, ProcessLine)\n", s, (UI) si___CommandLine);
		return (NO);
		}

	if (string[1] == '\0')
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
		"Illegal kern character constant in %s value at line %d.\n"
		"(XS, ProcessLine)\n", s, (UI) si___CommandLine);
		return (NO);
		}

	*l = string[0] & 0xFFu;

	return (YES);
	}



// **************************************************************************
//	InitCHRSet ()
//
//	Usage
//		static VOID InitCHRSet (VOID)
//
//	Description
//		Make sure that there is at least 1 blank CHR defined.
//
//	Return Value
//		None.
// **************************************************************************

static	void InitCHRSet (void)

	{

	UI	i;

	//
	// Have we defined any characters yet ?
	//


	if (ChrInfo.ui___chrCount == 0)

		{

		//
		// Initialize the chr buffer with a blank chr.
		//

		ChrInfo.ui___chrBytSize = (ChrInfo.ui___chrXPxlSize *
			ChrInfo.ui___chrYPxlSize *	ChrInfo.ui___chrPxlBits) >> 3;
		ChrInfo.ui___chrU32Size = ChrInfo.ui___chrBytSize >> 2;

		ChrInfo.ui___chrBytShift = 0;
		i = ChrInfo.ui___chrBytSize;
		while ((i = i >> 1) != 0)
			{
			ChrInfo.ui___chrBytShift += 1;
			}
		ChrInfo.ui___chrU32Shift = ChrInfo.ui___chrBytShift - 2;

		ChrInfo.pud__chrBufKeys[0] = 0;

		if(flEmptyChrZero)
		{
			ChrInfo.ui___chrCount = 1;
			memset(ChrInfo.pud__chrBufData, 0, ChrInfo.ui___chrBytSize);
		} else
		{
			ChrInfo.ui___chrCount = 0;
		}

		#if 0
		if (uiMapType != MAP_PXL) {
			printf("ui___chrXPxlSize  %d\n", ChrInfo.ui___chrXPxlSize);
			printf("ui___chrYPxlSize  %d\n", ChrInfo.ui___chrYPxlSize);
			printf("ui___chrPxlBits   %d\n", ChrInfo.ui___chrPxlBits);
			}
		#endif
		}
	return;
	}



// **************************************************************************
//	InitBLKSet ()
//
//	Usage
//		static VOID InitBLKSet (VOID)
//
//	Description
//		Make sure that there is at least 1 blank BLK defined.
//
//	Return Value
//		None.
// **************************************************************************

static	void InitBLKSet (void)

	{

	//
	// Have we defined any blocks yet ?
	//

	if (BlkInfo.ui___blkCount == 0)

		{

		//
		// Initialize the block buffer with a blank block.
		//

		BlkInfo.ui___blkChrSize =
				BlkInfo.ui___blkXChrSize * BlkInfo.ui___blkYChrSize;
		BlkInfo.ui___blkBytSize = BlkInfo.ui___blkChrSize * sizeof(UW);

		BlkInfo.puw__blkBufKeys[0] = 0;

		memset(BlkInfo.puw__blkBufData, 0, BlkInfo.ui___blkBytSize);

		}

	}



// **************************************************************************
//	SetMachineType ()
//
//	Usage
//		static ERRORCODE SetMachineType (UI * order)
//
//	Description
//		Read the new token and use it to set the order to HILO or LOHI.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetMachineType (UI * machine)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"(XS) Machine type missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	     if (strcmpi(string, StringGenesis)  == 0) SetGEN();
	else if (strcmpi(string, StringSuperNES) == 0) SetSFX();
	else if (strcmpi(string, String3DO)      == 0) Set3DO();
	else if (strcmpi(string, StringSaturn)   == 0) SetSAT();
	else if (strcmpi(string, StringPSX)      == 0) SetPSX();
	else if (strcmpi(string, StringIBM)      == 0) SetIBM();
	else if (strcmpi(string, StringN64)      == 0) SetN64();
	else if (strcmpi(string, StringGMB)      == 0) SetGMB();
	else if (strcmpi(string, StringAGB)      == 0) SetAGB();
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"(XS) Illegal machine type %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	SetOrderValue ()
//
//	Usage
//		static ERRORCODE SetOrderValue (UI * order)
//
//	Description
//		Read the new token and use it to set the order to HILO or LOHI.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetOrderValue (UI * order)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Order value missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringHILO) == 0)
		{
		*order = ORDERHILO;
		}
	else if (strcmpi(string, StringLOHI) == 0)
		{
		*order = ORDERLOHI;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal order value %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}


// **************************************************************************
//	SetOrderType ()
//
//	Usage
//		static ERRORCODE SetOrderType (UI * order)
//
//	Description
//		Read the new token and use it to set the order to LRTB or TBLR.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetOrderType (UI * order)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Order type missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringLRTB) == 0)
		{
		*order = ORDER_LRTB;
		}
	else if (strcmpi(string, StringTBLR) == 0)
		{
		*order = ORDER_TBLR;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal order type %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}


// **************************************************************************
//	SetMapType ()
//
//	Usage
//		static ERRORCODE SetMapType (UI * maptype)
//
//	Description
//		Read the new token and use it to set the map type to CHR or SPR.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetMapType (UI * maptype)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Map type missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringCHR) == 0)
		{
		*maptype = MAP_CHR;
		}
	else if (strcmpi(string, StringSPR) == 0)
		{
		*maptype = MAP_SPR;
		}
	else if (strcmpi(string, StringPXL) == 0)
		{
		*maptype = MAP_PXL;
		}
	else if (strcmpi(string, StringFNT) == 0)
		{
		*maptype = MAP_FNT;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal map type %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	SetCodingType ()
//
//	Usage
//		static ERRORCODE SetCodingType (UI * coding)
//
//	Description
//		Read the new token and use it to set the coding to RGB or PALETTE.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetCodingType (UI * coding)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Coding type missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringRGB) == 0)
		{
		*coding = ENCODED_RGB;
		}
	else if (strcmpi(string, StringPALETTE) == 0)
		{
		*coding = ENCODED_PALETTE;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal coding type %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	SetCompressionType ()
//
//	Usage
//		static ERRORCODE SetCompressionType (UI * compression)
//
//	Description
//		Read the new token and use it to set the compression type.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetCompressionType (UI * compression)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Compression type missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringUNPACKED) == 0)
		{
		*compression = ENCODED_UNPACKED;
		}
	else if (strcmpi(string, StringPACKED) == 0)
		{
		*compression = ENCODED_PACKED;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal compression type %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}


// **************************************************************************
//	SetDirection ()
//
//	Usage
//		static ERRORCODE SetDirection (UI * direction)
//
//	Description
//		Read the new token and use it to set the direction.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetDirection (UI * direction)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Direction missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringTOPTOBOTTOM) == 0)
		{
		*direction = TOPTOBOTTOM;
		}
	else if (strcmpi(string, StringBOTTOMTOTOP) == 0)
		{
		*direction = BOTTOMTOTOP;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal direction %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	SetFlagValue ()
//
//	Usage
//		static ERRORCODE SetFlagValue (FL      &flag)
//
//	Description
//		Read the new token and use it to set the flag to YES or NO.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE SetFlagValue (FL      * flag)

	{

	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken(" \t\n");

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Flag value missing after option at line %d.\n",
			(UI) si___CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringYes) == 0)
		{
		*flag = YES;
		}
	else if (strcmpi(string, StringNo) == 0)
		{
		*flag = NO;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Illegal flag value %s after option at line %d.\n",
			(char *) string,
			(UI) si___CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	SetLabelName ()
//
//	Usage
//		static ERRORCODE SetLabelName (char * label)
//
//	Description
//		Set up the output label name.
//
//	Return Value
//		None.
// **************************************************************************

static	ERRORCODE SetLabelName (char * label)

	{

	// Local variables.

	size_t		i;

	char *		labelptr;

	//

	i = strlen(label);

	if ((i == 0) || (i > 13))
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Invalid label name (%s).\n",
			label);
		goto errorExit;
		}

	strcpy(Label, label);

	LabelNum = Label + i;

	labelptr = LabelNum;

	*labelptr++ = '0';
	*labelptr++ = '0';

	i = i + 2;

	if (i < 8)
		{
		*labelptr++ = '\t';
		}

	*labelptr++ = '\t';

	strcpy(labelptr, "EQU\t$0000\n");

	LabelVal = labelptr + 5;

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	IncLabelName ()
//
//	Usage
//		global void IncLabelName (void)
//
//	Description
//		Increment the output label name.
//
//	Return Value
//		None.
// **************************************************************************

/*
static	void IncLabelName ()

	{

	if (LabelNum[1] == '9')
		{
		LabelNum[0] = LabelNum[0] + 1;
		LabelNum[1] = '0';
		}
	else
		{
		LabelNum[1] = LabelNum[1] + 1;
		}

	}
*/



// **************************************************************************
//	SetOutputDir ()
//
//	Usage
//		static ERRORCODE SetOutputDir (char * string)
//
//	Description
//		Set up the output directory name.
//
//	Return Value
//		None.
// **************************************************************************

static	ERRORCODE SetOutputDir (char * string)

	{

	// Local variables.

	size_t		i;

	char        tmp [256];

	// Keep a copy of the filename.

	i = strlen(pcz__DebugNamePtr);

	if (i > 255) {
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Filename too long to keep.\n");
		goto errorExit;
		}

	strcpy(tmp, pcz__DebugNamePtr);

	// Set up the new directory.

	i = strlen(string);

	if (i == 0) {
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Directory name too short.\n");
		goto errorExit;
		}

	if (i > (256 - 16)) {
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"XS error : Directory name too long.\n");
		goto errorExit;
		}

	strcpy(pcz__DebugName, string);

	string = pcz__DebugName + i;

	if (pcz__DebugName[i - 1] != '\\') {
		*string++ = '\\';
		*string   = '\0';
		}

	pcz__DebugNamePtr = string;

	// Restore the copy of the filename.

	strcpy(pcz__DebugNamePtr, tmp);

	pcz__DebugNameExt = pcz__DebugNamePtr + 9;

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ConvertFile ()
//
//	Usage
//		static UW * ConvertFile (char * pcfilename,
//			UW * pu16dst, UW * pu16max)
//
//	Description
//		Convert a file containing 1 or more bitmaps into frm data.
//		The information about the sprites is set up in the frame buffer
//		'frmbuf'.
//
//	Return Value
//		NULL if an error occurred, or updated value of pu16dst.
//
//	N.B.
//		The frm data has the following format ...
//			{
//			SW X offset from origin to top left of chrmap
//			SW Y offset from origin to top left of chrmap
//			UW frm's palette number
//			UW frm's depth
//			UW frm's code number
//			UW frm's priority flag
//			UW reserved (0)
//			UW map number
//			}
// **************************************************************************

static	UW * ConvertFile (char * str, UW * pu16dst, UW * pu16max)

	{

	// Local variables.

	FILE *              pfile;

	void *              pvoid;
	DATABLOCK_T *       pdbh;
	DATABITMAP_T *      pbmh;

	ERRORCODE           (*pfinitread)(void **, FILE *, DATATYPE_T);
	DATABLOCK_T *       (*pfreaddata)(void **);
	FILE *              (*pfquitread)(void **);

	UW *                pu16end;

	SI                  sibmxtl;
	SI                  sibmytl;
	char namecopy[256],*pcfilename;

	strcpy(namecopy,str);
	pcfilename=namecopy;
	// Print out the filename.

//	strupr(pcfilename);

	printf("\n%s\n", pcfilename);

	if (flUseProcessedName)
		{
		SetDiagnosticName(pcfilename);
		}

	uiFileFrame = 0;

	// Add the file to the label list.

	{
	LABEL_T * pcl__new;

	_splitpath(pcfilename, acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

	if ((pcl__new = malloc(sizeof(LABEL_T))) == NULL) goto errorExit;

	pcl__new->pcl__NxtLabel = pcl__Label;
	pcl__new->si___LabelVal = MapInfo.ui___mapsCount;

	strcpy(pcl__new->acz__LabelStr, acz__FileNam);

	pcl__Label = pcl__new;
	}

	// Open the file for input.

	if ((pfile = fopen(pcfilename, "rb")) == NULL)
		{
		ErrorCode = ERROR_NO_FILE;
		sprintf(ErrorMessage,
			"%s file not found.\n"
			"(XS, ConvertFile)\n",
			pcfilename);
		goto errorExit;
		}

	// Select the file read routines to use depending upon the file type.

	if (IffIdentify(pfile) == FILE_IFF) {
		pfinitread = IffInitRead;
		pfreaddata = IffReadData;
		pfquitread = IffQuitRead;
		}
//	else
//	if (BmpIdentify(pfile) == FILE_DIB) {
//		pfinitread = BmpInitRead;
//		pfreaddata = BmpReadData;
//		pfquitread = BmpQuitRead;
//		}
	else
	if (PcxIdentify(pfile) == FILE_PCX) {
		pfinitread = PcxInitRead;
		pfreaddata = PcxReadData;
		pfquitread = PcxQuitRead;
		}
	else
	if (SprIdentify(pfile) == FILE_SPR) {
		pfinitread = SprInitRead;
		pfreaddata = SprReadData;
		pfquitread = SprQuitRead;
		}
//	else
//	if (TgaIdentify(pfile) == FILE_TGA) {
//		pfinitread = TgaInitRead;
//		pfreaddata = TgaReadData;
//		pfquitread = TgaQuitRead;
//		}
	else
		{
		ErrorCode = ERROR_NO_FILE;
		sprintf(ErrorMessage,
			"(XS) File %s is not in a known file format.\n",
			pcfilename);
		goto errorClose;
		}

	// Initialize the file for reading.

	if ((*pfinitread)(&pvoid, pfile, DATA_BITMAP) != ERROR_NONE) {
		goto errorClose;
		}

	// Now loop around, reading each data object from the file.

	while ((pdbh = (*pfreaddata)(&pvoid)) != NULL)

		{

		// Process a frame.

		uiFileFrame += 1;

		// If its the 1st frame in an file, then grab a copy of the
		// colour palette.

		pbmh = (DATABITMAP_T *) pdbh;

		if ((uiFileFrame == 1) && (uiFileCount == 1))
			{
			if (pbmh->ui___bmB <= 8)
				{
				memcpy(Palette, pbmh->acl__bmC,
					(1 << pbmh->ui___bmB) * sizeof(RGBQUAD_T));
				if (flZeroColour0 == YES) {
					memset(Palette, 0, sizeof(RGBQUAD_T));
					}
				}
			}

		if (uiFileFrame == 1)
			{
			if (pbmh->ui___bmB <= 8)
				{
				if (XvertStorePalette(pbmh, &PalInfo) != ERROR_NONE) goto errorFree;
				}
			}

		// First frame in file and flReferenceFrame flag set ?

		if ((uiFileFrame == 1) && (flReferenceFrame == YES))
			// Convert origin frame.
			{
			if (ConvertRefFrm(uiFileFrame, &pdbh, &sibmxtl, &sibmytl) != ERROR_NONE) goto errorFree;
			}
		else
			// Convert data frame.
			{
			pu16end = ConvertDatFrm(uiFileFrame, &pdbh, sibmxtl, sibmytl, pu16dst, pu16max);

			if (pu16end == NULL) goto errorFree;

//			pu16dst = pu16end;
			}

		// Free up the bitmap.

		DataFree(pdbh);
		}

	// Error occurred ?

	if (ErrorCode != 0) goto errorQuit;

	// End of input file.

	pfile = (*pfquitread)(&pvoid);

	fclose(pfile);

	// Return with success code.

	return (pu16dst);

	// Error handlers (reached via the dreaded goto).

	errorFree:

		if (pdbh != NULL) {
			DataFree(pdbh);
			}

	errorQuit:

		pfile = (*pfquitread)(&pvoid);

	errorClose:

		fclose(pfile);

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	ConvertRefFrm ()
//
//	Usage
//		static ERRORCODE ConvertRefFrm (UI uifileframe, DATABLOCK ** ppdb,
//			SI * psibmxtl, SI * psibmytl)
//
//	Description
//		Convert a bitmap data block into origin coordinates.
//
//	Return Value
//		ERROR_NONE if OK, or an error number.
// **************************************************************************

static	ERRORCODE ConvertRefFrm (UI uifileframe, DATABLOCK_T ** ppdbh, SI * psibmxtl, SI * psibmytl)

	{

	// Local variables.

	DATABITMAP_T *      pbmh;

	SI                  sibmx;
	SI                  sibmy;
	UI                  uibmw;
	UI                  uibmh;

	// Locate the bitmap data.

	pbmh = (DATABITMAP_T *) *ppdbh;

	// Shrink the input pixel data to 1/2 size ?
	// This can be used when developing to produce smaller files
	// that will fit into VRAM.

	if (flShrinkInput)
		{
		if (DataBitmapQuarter(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH) != ERROR_NONE) goto errorExit;
		}

	// Remap the input palette ?

	if (flRemapInput)
		{
		if (DataBitmapRemap(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH) != ERROR_NONE) goto errorExit;
		}

	// Filter the input pixel data ?

	if (flFilterInput)
		{
		if (DataBitmapFilter(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH,
			uiFilterBelow,
			uiFilterAbove) != ERROR_NONE) goto errorExit;
		}

	// Filter the input pixel data ?

	if (flFilterChrs)
		{
		sibmx = pbmh->si___bmXTopLeft;
		sibmy = pbmh->si___bmYTopLeft;
		uibmw = pbmh->ui___bmW;
		uibmh = pbmh->ui___bmH;

		if (flFindEdges == YES) {
			DataBitmapBoundingBox(pbmh, &sibmx, &sibmy, &uibmw, &uibmh);
			}

		if (DataBitmapPalettize(pbmh, sibmx, sibmy, uibmw, uibmh) != ERROR_NONE) {
			goto errorExit;
			}
		}

	// Dump the frame back to disk as a diagnostic reference or maybe
	// even for further processing.

	if (flWriteProcessed)
		{
		if (PcxDumpBitmap(*ppdbh, pcz__DebugName) != ERROR_NONE) {
			goto errorExit;
			}
		IncDiagnosticName();
		}

	// Skip the conversion ?

	if (!flProcessOnly)

		{
		// This is an origin frame, so find the bitmap data's origin.

		sibmx = pbmh->si___bmXTopLeft = 0;
		sibmy = pbmh->si___bmYTopLeft = 0;
		uibmw = pbmh->ui___bmW;
		uibmh = pbmh->ui___bmH;

		DataBitmapBoundingBox(pbmh, &sibmx, &sibmy, &uibmw, &uibmh);

		printf("frame=%03u x=%-+4d y=%-+4d w=%-4u h=%-4u origin\n",
			uifileframe, sibmx, sibmy, uibmw, uibmh);

		// Origin reference frame.

		if ((uibmw == 1) && (uibmh == 1))
			{
			sibmx = 0 - sibmx;
			sibmy = 0 - sibmy;
			if (flShrinkInput) {
				sibmx = sibmx / 2;
				sibmy = sibmy / 2;
				}
			*psibmxtl = sibmx;
			*psibmytl = sibmy;
			}
		else
			{
			ErrorCode = ERROR_PROGRAM;
			if ((uibmw | uibmh) == 0) {
				sprintf(ErrorMessage,
					"Origin reference frame has no points set.\n"
					"(XS, ConvertRefFrm)\n");
				} else {
				sprintf(ErrorMessage,
					"Origin reference frame has more than 1 point set.\n"
					"(XS, ConvertRefFrm)\n");
				}
			goto errorExit;
			}
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ConvertDatFrm ()
//
//	Usage
//		static UW * ConvertDatFrm (UI uifileframe, DATABLOCK ** ppdb,
//			SI sibmxtl, SI sibmytl, UW * pu16dst, UW * pu16max)
//
//	Description
//		Convert a bitmap data block into a sprite/map frame.
//
//	Return Value
//		NULL if an error occurred, or updated value of pu16dst.
// **************************************************************************

static	UW * ConvertDatFrm (UI uifileframe, DATABLOCK_T ** ppdbh, SI sibmxtl, SI sibmytl, UW * pu16dst, UW * pu16max)

	{

	// Local variables.

	DATABITMAP_T *      pbmh;

	SI                  sibmx;
	SI                  sibmy;
	UI                  uibmw;
	UI                  uibmh;

	UW *                pu16end;

	// Locate the bitmap data.

	pbmh = (DATABITMAP_T *) *ppdbh;

	// Shrink the input pixel data to 1/2 size ?
	// This can be used when developing to produce smaller files
	// that will fit into VRAM.

	if (flShrinkInput)
		{
		if (DataBitmapQuarter(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH) != ERROR_NONE) goto errorExit;
		}

	// Remap the input palette ?

	if (flRemapInput)
		{
		if (DataBitmapRemap(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH) != ERROR_NONE) goto errorExit;
		}

	// Filter the input pixel data ?

	if (flFilterInput)
		{
		if (DataBitmapFilter(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH,
			uiFilterBelow,
			uiFilterAbove) != ERROR_NONE) goto errorExit;
		}

	// Filter the input pixel data ?

	if (flFilterChrs)
		{
		sibmx = pbmh->si___bmXTopLeft;
		sibmy = pbmh->si___bmYTopLeft;
		uibmw = pbmh->ui___bmW;
		uibmh = pbmh->ui___bmH;

		if (flFindEdges == YES) {
			DataBitmapBoundingBox(pbmh, &sibmx, &sibmy, &uibmw, &uibmh);
			}

		if (DataBitmapPalettize(pbmh, sibmx, sibmy, uibmw, uibmh) != ERROR_NONE) {
			goto errorExit;
			}
		}

	// Count up the input pixel data and add it to the global
	// histogram.

	if (flHistogram)
		{
		if (DataBitmapHistogram(pbmh,
			pbmh->si___bmXTopLeft,
			pbmh->si___bmYTopLeft,
			pbmh->ui___bmW,
			pbmh->ui___bmH) != ERROR_NONE) goto errorExit;
		}

	// Dump the frame back to disk as a diagnostic reference or maybe
	// even for further processing.

	if (flWriteProcessed)
		{
		if (PcxDumpBitmap(*ppdbh, pcz__DebugName) != ERROR_NONE) {
			goto errorExit;
			}
		IncDiagnosticName();
		}

	// Skip the conversion ?

	if (flProcessOnly)
		{
		pu16end = pu16dst;
		}
	else
		{
		// If there was a reference frame, then use that as the basis for
		// the coordinates.

		if (flReferenceFrame == YES)
			{
			// If there is a reference frame then override the top left
			// coordinates.
			pbmh->si___bmXTopLeft = sibmxtl;
			pbmh->si___bmYTopLeft = sibmytl;
			} else {
			// If there isn't a reference frame then still override the top
			// left coordinates.
			pbmh->si___bmXTopLeft = 0;
			pbmh->si___bmYTopLeft = 0;
			}

		// Find the smallest box that fits around the bitmap.

		sibmx = pbmh->si___bmXTopLeft;
		sibmy = pbmh->si___bmYTopLeft;
		uibmw = pbmh->ui___bmW;
		uibmh = pbmh->ui___bmH;

		if (uiMapType != MAP_FNT)
			{
			if (flFindEdges == YES) {
				DataBitmapBoundingBox(pbmh, &sibmx, &sibmy, &uibmw, &uibmh);
				}
			}

		printf("frame=%03u x=%-+4d y=%-+4d w=%-4u h=%-4u data\n",
			uifileframe, sibmx, sibmy, uibmw, uibmh);

		// Blank offset position information ?

		if (flZeroPosition)
			{
			pbmh->si___bmXTopLeft -= sibmx;
			pbmh->si___bmYTopLeft -= sibmy;

			sibmx = 0;
			sibmy = 0;
			}

		// Create a version with a 16 pixel border around each edge.

		if (uiMapType != MAP_FNT)
			{
			*ppdbh = XvertBitmapBorder16(*ppdbh);
			}

		if (*ppdbh == NULL) goto errorExit;

		pbmh = (DATABITMAP_T *) *ppdbh;

		// Convert the bitmap into a sprite.

		switch (uiMapType)
			{
			case MAP_CHR:
			case MAP_SPR: {
				pu16end = XvertBitmapToMapFrm(pbmh, sibmx, sibmy, uibmw, uibmh,
					&ChrInfo, &BlkInfo, &MapInfo, pu16dst, pu16max);
				break;
				}
			case MAP_PXL: {
				pu16end = XvertBitmapToSprFrm(pbmh, sibmx, sibmy, uibmw, uibmh,
					&SprInfo, pu16dst, pu16max);
				break;
					}
			case MAP_FNT: {
				pu16end = XvertBitmapToFntFrm(pbmh,
					&FntInfo, pu16dst, pu16max);
				break;
					}
			default: {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Don't know how to convert data to map type %d.\n"
					"(XS, ConvertFile)\n",
					(UI) uiMapType);
				pu16end = NULL;
				}
			}

		if (pu16end == NULL) goto errorExit;

		} // End of "if (flProcessOnly)"

	// Return with success code.

	return (pu16end);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (NULL);

	}



// **************************************************************************
//	LoadRemapTbl ()
//
//	Usage
//		static ERRORCODE LoadRemapTbl (char * filename)
//
//	Description
//		Load up a new 256-colour palette remapping table.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE LoadRemapTbl (char * filename)

	{

	// Local variables.

	FILE *              f;

	UI                  ui___Lin;
	UI                  ui___Pxl;

	SL                  sl___Val;

	UB *                pub__Tbl;
	char *              pcz__Str;
	char *              pcz__End;

	UB                  aub__Tbl [256];
	char                cz___Inp [256];

	// Clear out the temporary table.

	memset(aub__Tbl, 0, 256*sizeof(UB));

	// Now read in 256 numbers from the input file.

	f = NULL;

	if ((f = fopen(filename, "r")) == NULL) {
		ErrorCode = ERROR_IO_READ;
		sprintf(ErrorMessage,
			"XS error : Unable to open %s for reading.\n", filename);
		goto errorExit;
		}

	ui___Lin = 1;
	ui___Pxl = 0;

	while (fgets(cz___Inp, 256, f) != NULL)
		{
		pcz__Str = cz___Inp;

		while ((pcz__Str = strtok(pcz__Str, ", \t\n")) != NULL)
			{
			sl___Val = strtol(pcz__Str, &pcz__End, 0);

			if (*pcz__End != '\0') {
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"XS error : Illegal characters in new RemappingTable at line %d.\n",
					ui___Lin);
				goto errorExit;
				}

			aub__Tbl[ui___Pxl++] = (UB) sl___Val;

			if (ui___Pxl == 256) break;

			pcz__Str = NULL;
			}

		if (ui___Pxl == 256) break;

		ui___Lin += 1;
		}

	fclose(f);

	// Print out the resulting table.

	printf("\nRemappingTable =\n");

	pub__Tbl = aub__Tbl;

	for (ui___Lin = 16; ui___Lin != 0; ui___Lin -= 1) {
		for (ui___Pxl = 16; ui___Pxl != 0; ui___Pxl -= 1) {
			printf("  %02X", *pub__Tbl++);
			}
		printf("\n");
		}

	printf("\n");

	// Copy the temporary table over the permanent table.

	memcpy(RemappingTable, aub__Tbl, 256*sizeof(UB));

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		if (f != NULL) fclose(f);

		return (ErrorCode);

	}



// **************************************************************************
//	DumpCHR ()
//
//	Usage
//		static ERRORCODE DumpCHR (char * filename)
//
//	Description
//		Write out the character set to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpCHR (char * filename)

	{

	// Set up the file extension.

	strcpy(pcz__OutputExt, ".chr");

	// Write the character set out to disk (if there are any that we want).

	if (uiChrsToStrip < uiNumPermanentChr) uiChrsToStrip = uiNumPermanentChr;

	if (ChrInfo.ui___chrCount > uiChrsToStrip) {
		DumpMemory (
			filename,
			ChrInfo.pud__chrBufData + (uiChrsToStrip << ChrInfo.ui___chrU32Shift),
			(ChrInfo.ui___chrCount - uiChrsToStrip) << ChrInfo.ui___chrBytShift,
			0,
			0);
		}

	// Return with code.

	return (ErrorCode);

	}



// **************************************************************************
//	DumpBLK ()
//
//	Usage
//		static ERRORCODE DumpBLK (char * filename)
//
//	Description
//		Write out the blocks to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpBLK (char * filename)

	{

	// Local variables.

	size_t              uli;

	UW *               pu16dst;
	UW *               pu16end;

	// Set up the file extension.

	strcpy(pcz__OutputExt, ".blk");

	// Only do this if there are really any blocks to save.

	if (BlkInfo.ui___blkCount != 0)
		{
		// Reorder data ?

		if (uiOutputOrder == ORDERSWAP)
			{
			pu16end = (pu16dst = BlkInfo.puw__blkBufData);
			for (
				uli  = (BlkInfo.ui___blkCount * BlkInfo.ui___blkChrSize);
				uli != 0;
				uli -= 1)
				{
				*pu16end++ = SwapD16(*pu16end);
				}
			}

		// Write the blocks out to disk.

		DumpMemory(filename,
			BlkInfo.puw__blkBufData, (BlkInfo.ui___blkCount * BlkInfo.ui___blkBytSize),
			0,0);
		}

	// Return with code.

	return (ErrorCode);

	}



// **************************************************************************
//	DumpMAP ()
//
//	Usage
//		static ERRORCODE DumpMAP (char * filename)
//
//	Description
//		Write out the maps to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpMAP (char * filename)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	UW *                pu16src;
	UW *                pu16dst;
	UW *                pu16end;
	UW *                pu16max;

	UI                  uimapcount;

	UD *                pu32idx;
	UL                  ulidxsize;

//	UD                  u32tmp;
//	UI                  uii;

//	UW                  u16tmp;
	UW *                pu16idx;

	// Set up the file extension.

	strcpy(pcz__OutputExt, ".map");

	// Remove map repeats.

	if (siStaticMapFrame != 0)
		{
		if (RemoveStaticMapData(
			&MapInfo, siStaticMapFrame) != ERROR_NONE)
			{
			goto errorExit;
			}
		}

	// Get the addresses of the map data.

	uimapcount = MapInfo.ui___mapsCount;

	pu16src = MapInfo.puw__mapsBuf1st;
	pu16dst = MapInfo.puw__mapsBuf1st;
	pu16end = MapInfo.puw__mapsBufCur;
	pu16max = MapInfo.puw__mapsBufEnd;

	pu16idx = NULL;
	pu32idx = NULL;
	ulidxsize = 0;

	// Reformat the map data.

	switch (uiMachineType)
		{
/*
		case MACHINE_SFX: {
			pu16end = ReformatMapsForSFX(
				pu16src,
				pu16end,
				pu16max,
				((UD *) MapInfo.ppud_mapBufIndx),
				uimapcount);
			break;
			}
		case MACHINE_GEN: {
			pu16end = ReformatMapsForGEN(
				pu16src,
				pu16end,
				pu16max,
				((UD *) MapInfo.ppud_mapBufIndx),
				uimapcount);
			break;
			}
		case MACHINE_SAT: {
			pu16end = ReformatMapsForSAT(
				pu16src,
				pu16end,
				pu16max,
				((UD *) MapInfo.ppud_mapBufIndx),
				uimapcount);
			break;
			}
		case MACHINE_PSX: {
			pu16end = ReformatMapsForPSX(
				pu16src,
				pu16end,
				pu16max,
				((UD *) MapInfo.ppud_mapBufIndx),
				uimapcount);
			break;
			}
*/
		case MACHINE_AGB: {
			if (ReformatMapsForAGB(
				&MapInfo, &pub__Buf, &ui___Buf) != ERROR_NONE)
				{
				goto errorExit;
				}
//			pu16end = ReformatMapsForGMB(
//				pu16src,
//				pu16end,
//				pu16max,
//				((UD *) MapInfo.ppud_mapBufIndx),
//				uimapcount);
			break;
			}
		case MACHINE_GMB: {
			if (ReformatMapsForGMB(
				&MapInfo, &pub__Buf, &ui___Buf) != ERROR_NONE)
				{
				goto errorExit;
				}
//			pu16end = ReformatMapsForGMB(
//				pu16src,
//				pu16end,
//				pu16max,
//				((UD *) MapInfo.ppud_mapBufIndx),
//				uimapcount);
			break;
			}

		default: {
			ErrorCode = ERROR_ILLEGAL;
			sprintf(ErrorMessage,
				"(XS) Unable to output MAP data for this machine !\n");
			goto errorExit;
			}
		}

/*
	if (pu16end == NULL) {
		goto errorExit;
		}

	// Determine whether to save the index information.

	if (flOutputMapIndex == YES)
		{
		if (flOutputWordIdx)
			{
			// Output index as 16-bit words.

			pu16src = (UW *) malloc(uimapcount * 2);
			pu16idx = (UW *) pu16src;
			pu32idx = (UD *) MapInfo.ppud_mapBufIndx;
			for (uii = uimapcount; uii != 0; uii = uii - 1) {
				u16tmp = (UW) *pu32idx++;
				if (uiOutputOrder == ORDERSWAP) {
					u16tmp = SwapD16(u16tmp);
					}
				*pu16idx++ = u16tmp;
				}
			pu16idx   = (UW *) pu16src;
			pu32idx   = (UD *) pu16src;
			ulidxsize = ((UL) uimapcount) * sizeof(UW);
			}
		else
			{
			// Output index as 32-bit longs.

			if (uiOutputOrder == ORDERSWAP) {
				pu32idx = (UD *) MapInfo.ppud_mapBufIndx;
				for (uii = uimapcount; uii != 0; uii = uii - 1) {
					u32tmp = *pu32idx;
					*pu32idx++ = SwapD32(u32tmp);
					}
				}
			pu32idx   = (UD *) MapInfo.ppud_mapBufIndx;
			ulidxsize = ((UL) uimapcount) * sizeof(UD);
			}
		}

	// Write the maps out to disk.

	DumpMemory(filename,
		pu32idx, ulidxsize,
		pu16dst, (((UB *) pu16end) - ((UB *) pu16dst)));

	// Free up 16-bit index table ?

	if (pu16idx != NULL) free(pu16idx);
*/

	// Write the maps out to disk.

	if (pub__Buf != NULL)
		{
//		strcpy(pcz__OutputExt, ".map");
		DumpMemory(filename, pub__Buf, ui___Buf, 0, 0);
		free(pub__Buf);
		}

	// Return with code.

	return (ErrorCode);

	// Error handlers (reached via the dreaded goto).

	errorExit:

	return (ErrorCode);
	}



// **************************************************************************
//	DumpSPR ()
//
//	Usage
//		static ERRORCODE DumpSPR (char * filename)
//
//	Description
//		Write out the sprites to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpSPR (FILE * pcl__Res)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	// Reformat the sprite data.

	switch (uiMachineType)
		{
		case MACHINE_N64:
			{
			if (ReformatSprsForN64(
				&SprInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
				{
				goto errorExit;
				}
			break;
			}

		case MACHINE_IBM:
			{
			if (ReformatSprsForIBM(
				&SprInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
				{
				goto errorExit;
				}
			break;
			}
		case MACHINE_PSX:
			{
			if (ReformatSprsForPSX(
				&SprInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
				{
				goto errorExit;
				}
			break;
			}
		case MACHINE_SAT:
			{
			if (ReformatSprsForSAT(
				&SprInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
				{
				goto errorExit;
				}
			break;
			}
		case MACHINE_3DO:
			{
			if (ReformatSprsFor3DO(
				&SprInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
				{
				goto errorExit;
				}
			break;
			}
		}

	// Write the sprs out to disk.

	if (pub__Buf != NULL)
		{
		if (pcl__Res == NULL)
			{
			strcpy(pcz__OutputExt, ".spr");
			DumpMemory(pcz__OutputStr, pub__Buf, ui___Buf, 0, 0);
			}
		free(pub__Buf);
		}

	// Return with code.

	return (ErrorCode);

	// Error handlers (reached via the dreaded goto).

	errorExit:

	return (ErrorCode);
	}



// **************************************************************************
//	DumpFNT ()
//
//	Usage
//		static ERRORCODE DumpFNT (char * filename)
//
//	Description
//		Write out the font data to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpFNT (FILE * pcl__Res)

	{

	// Local variables.

	UB *                pub__Buf;
	UI                  ui___Buf;

	// Reformat the font data.

	if (ReformatFntsForFNT(&FntInfo, &pub__Buf, &ui___Buf, pcl__Res) != ERROR_NONE)
		{
		goto errorExit;
		}

	// Write the font out to disk.

	if (pub__Buf != NULL)
		{
		if (pcl__Res == NULL)
			{
			strcpy(pcz__OutputExt, ".fnt");
			DumpMemory(pcz__OutputStr, pub__Buf, ui___Buf, 0, 0);
			}
		free(pub__Buf);
		}

	// Return with code.

	return (ErrorCode);

	// Error handlers (reached via the dreaded goto).

	errorExit:

	return (ErrorCode);
	}



// **************************************************************************
//	DumpRGB ()
//
//	Usage
//		static ERRORCODE DumpRGB (char * filename)
//
//	Description
//		Write out the color palette to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpRGB (FILE * pcl__Res)

	{

	// Local variables.

	RGBQUAD_T *         pcl__P;
	UW *                puw__Q;
	UD *                pud__Q;

	UI                  ui___A;
	UI                  ui___R;
	UI                  ui___G;
	UI                  ui___B;

	UI                  ui___P;
	UI                  ui___Q;

	UI                  i;
	UI                  j;

	UD					aud__P [256];

	DATAPALIDX_T *      pcl__PalIdx;
	DATACHUNK_T *       pcl__PalChk;
	UI                  ui___NumPal;
	UI                  ui___i;

	// Make colour 0 transparent.
	//
	//  ub___rgbA = 0 (solid)
	//            = 1 ( 25%-transparent)
	//            = 2 ( 50%-transparent)
	//            = 3 ( 75%-transparent)
	//            = 4 (100%-transparent)

	Palette[0].ub___rgbA = 4;

	// Find out how many palettes to dump.

	pcl__PalIdx = PalInfo.acl__palsBufIndx;
	ui___NumPal = PalInfo.ui___palsCount;

	if ((uiMachineType != MACHINE_IBM) ||
		(uiMachineType != MACHINE_N64))
		{
		ui___NumPal = 1;
		}

	// Now loop around writing out each palette.

	pcl__PalIdx -= 1;

	for (ui___i = 0; ui___i < ui___NumPal; ui___i += 1)

		{
		// Is this a repeat ?

		pcl__PalIdx += 1;

		if (pcl__PalIdx->ul___paliBufLen == 0) continue;

		pcl__PalChk = (DATACHUNK_T *) pcl__PalIdx->pbf__paliBufPtr;

		pcl__P = (RGBQUAD_T *) (pcl__PalChk + 1);

		// Write out the resource head.

		if (pcl__Res != NULL)
			{
			*pcz__OutputExt = '\0';

			if (ui___NumPal > 1)
				{
				sprintf(pcz__OutputExt, "_%03d", ui___i);
				}

			if (flPaletteSPL)
				{
				fprintf(pcl__Res, "resource \"SPL-%s\" public\n", pcz__OutputNam);
				fprintf(pcl__Res, "dwords\n");
				}
			else
				{
				fprintf(pcl__Res, "resource \"PAL-%s\" public\n", pcz__OutputNam);
				fprintf(pcl__Res, "words\n");
				}
			}

		// Convert palette to GEN format.

		if (uiMachineType == MACHINE_GEN)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "32\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 16) <= 255) ? (ui___R + 16) : 255;
				ui___G = ((ui___G + 16) <= 255) ? (ui___G + 16) : 255;
				ui___B = ((ui___B + 16) <= 255) ? (ui___B + 16) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 5;
					ui___G = ui___G >> 5;
					ui___B = ui___B >> 5;
					}
				else
					{
					ui___R = ui___R >= 46 ? (ui___R - 46) / 28 : 0;
					ui___G = ui___G >= 46 ? (ui___G - 46) / 28 : 0;
					ui___B = ui___B >= 46 ? (ui___B - 46) / 28 : 0;
					}
				ui___P = (ui___B << 9) + (ui___G << 5) + (ui___R << 1);
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to SFX format.

		else
		if (uiMachineType == MACHINE_SFX)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}
				ui___P = (ui___B << 10) + (ui___G << 5) + ui___R;
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}
		else
		if (uiMachineType == MACHINE_AGB)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
/*				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
*/
//				if (flUseNewPalette == NO)
				if(1)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}
				ui___P = (ui___B << 10) + (ui___G << 5) + ui___R;
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to 3DO format.

		else
		if (uiMachineType == MACHINE_3DO)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "32\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 32; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}
				ui___P = (ui___R << 10) + (ui___G << 5) + ui___B;
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to SAT format.

		else
		if (uiMachineType == MACHINE_SAT)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___R + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___R + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}
				ui___P = (ui___B << 10) + (ui___G << 5) + ui___R;
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to PSX format.

		else
		if (uiMachineType == MACHINE_PSX)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}
				ui___P = (ui___B << 10) + (ui___G << 5) + ui___R;
				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + 0x00000400u;
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to IBM format.

		else
		if (uiMachineType == MACHINE_IBM)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			pud__Q = (UD *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___A = pcl__P->ub___rgbA;
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}

				ui___P = (ui___A << 16) + (ui___R << 10) + (ui___G << 5) + ui___B;
//				ui___P = (ui___A << 16) + (ui___R << 11) + (ui___G << 6) + ui___B;

				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + ((4 - ui___A) << 8);
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD32(ui___P);
					}
				*pud__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			puw__Q = (UW *) pud__Q;
			}

		// Convert palette to N64 format.

		else
		if (uiMachineType == MACHINE_N64)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "256\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];
			for (i = 0; i < 256; i = i + 1)
				{
				ui___A = pcl__P->ub___rgbA;
				ui___R = pcl__P->ub___rgbR;
				ui___G = pcl__P->ub___rgbG;
				ui___B = pcl__P->ub___rgbB;
				ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
				ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
				ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
				if (flUseNewPalette == NO)
					{
					ui___R = ui___R >> 3;
					ui___G = ui___G >> 3;
					ui___B = ui___B >> 3;
					}
				else
					{
					ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
					ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
					ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
					}

				ui___P = (ui___R << 10) + (ui___G << 5) + ui___B;

				if (pcl__Res != NULL)
					{
					if (flPaletteSPL)
						{
						ui___Q = (ui___P << 16) + ((4 - ui___A) << 8);
						if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
						else              fprintf(pcl__Res, "$%08X\n", ui___Q);
						}
					else
						{
						ui___P <<= 1;

						if (i != 0) ui___P |= 0x0001u;

						if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
						else              fprintf(pcl__Res, "$%04X\n", ui___P);
						}
					}
				if (uiOutputOrder == ORDERSWAP)
					{
					ui___P = SwapD16(ui___P);
					}
				*puw__Q++ = (UW) ui___P;
				pcl__P = pcl__P + 1;
				}
			}

		// Convert palette to GMB format.

		else
		if (uiMachineType == MACHINE_GMB)
			{
			if ((pcl__Res != NULL) && flPaletteSPL)
				{
				fprintf(pcl__Res, "32\n");
				fprintf(pcl__Res, "$00000000\n");
				}
			puw__Q = (UW *) &aud__P[0];

			i = 0;

			for (i = 0; i < 8; i = i + 1)
				{
				for (j = 0; j < 4; j = j + 1)
					{
					ui___R = pcl__P->ub___rgbR;
					ui___G = pcl__P->ub___rgbG;
					ui___B = pcl__P->ub___rgbB;
// _DA__ 20200510
// The artists wanted some artwork brighter but not other
					if(flBrighterColors) {
						ui___R = ((ui___R + 4) <= 255) ? (ui___R + 4) : 255;
						ui___G = ((ui___G + 4) <= 255) ? (ui___G + 4) : 255;
						ui___B = ((ui___B + 4) <= 255) ? (ui___B + 4) : 255;
					}

					if (flUseNewPalette == NO)
						{
						ui___R = ui___R >> 3;
						ui___G = ui___G >> 3;
						ui___B = ui___B >> 3;
						}
					else
						{
						ui___R = ui___R >= 34 ? (ui___R - 34) / 7 : 0;
						ui___G = ui___G >= 34 ? (ui___G - 34) / 7 : 0;
						ui___B = ui___B >= 34 ? (ui___B - 34) / 7 : 0;
						}
					ui___P = (ui___B << 10) + (ui___G << 5) + ui___R;
					if (pcl__Res != NULL)
						{
						if (flPaletteSPL)
							{
							ui___Q = (ui___P << 16) + 0x00000400u;
							if ((i & 3) != 3) fprintf(pcl__Res, "$%08X ",  ui___Q);
							else              fprintf(pcl__Res, "$%08X\n", ui___Q);
							}
						else
							{
							if ((i & 3) != 3) fprintf(pcl__Res, "$%04X ",  ui___P);
							else              fprintf(pcl__Res, "$%04X\n", ui___P);
							}
						}
					if (uiOutputOrder == ORDERSWAP)
						{
						ui___P = SwapD16(ui___P);
						}
					*puw__Q++ = (UW) ui___P;
					pcl__P = pcl__P + 1;
					}

				if (!flRemapInput)
					{
					pcl__P = pcl__P + (16 - 4);
					}
				else
					{
					if ((i & 1) == 0)
						{
						pcl__P = pcl__P + 12;
						}
					else
						{
						pcl__P = pcl__P - 16;
						}
					}
				}
			}

		// Write out the resource tail.

		if (pcl__Res != NULL)
			{
			fprintf(pcl__Res, "endresource\n");
			}

		// Now loop around and dump out the next palette.
		}

	// Write the color pcl__Palette out to disk.

	if (pcl__Res == NULL)
		{
		strcpy(pcz__OutputExt, ".rgb");
		DumpMemory(pcz__OutputStr,
			&aud__P[0], (((UB *) puw__Q) - ((UB *) aud__P)), 0, 0);
		}

	// Return with code.

	return (ErrorCode);

	}



// **************************************************************************
//	DumpMemory ()
//
//	Usage
//		static ERRORCODE DumpFile (char * filename,
//			void * fileaddr0, size_t filesize0,
//			void * fileaddr1, size_t filesize1)
//
//	Description
//		Write out a block of memory to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpMemory (char * filename,
					void * fileaddr0, size_t filesize0,
					void * fileaddr1, size_t filesize1)

	{

	// Local variables.

	FILE *			f;

	//

	printf("Writing %s\n", filename);

	f = NULL;

	if ((f = fopen(filename, "wb")) == NULL) {
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"XS error : Unable to open %s for writing. (Write protected ?)\n", filename);
		goto errorExit;
		}

	if ((fileaddr0 != NULL) && (filesize0 != 0)) {
		if (fwrite(fileaddr0, 1, filesize0, f) != filesize0) {
			ErrorCode = ERROR_IO_WRITE;
			sprintf(ErrorMessage,
				"XS error : Error writing to %s. (Disk full ?)\n", filename);
			goto errorExit;
			}
		}

	if ((fileaddr1 != NULL) && (filesize1 != 0)) {
		if (fwrite(fileaddr1, 1, filesize1, f) != filesize1) {
			ErrorCode = ERROR_IO_WRITE;
			sprintf(ErrorMessage,
				"XS error : Error writing to %s. (Disk full ?)\n", filename);
			goto errorExit;
			}
		}

	if (fclose(f) != 0) {
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"XS error : Unable to close %s after writing.\n", filename);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		if (f != NULL) fclose(f);

		return (ErrorCode);

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF XS.CPP
// **************************************************************************
// **************************************************************************
// **************************************************************************