// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** MAKETEXT.C                                                   PROGRAM **
// **                                                                      **
// ** Purpose       :                                                      **
// **                                                                      **
// ** To concatenate a number of files into a single file.                 **
// **                                                                      **
// ** Last modified : 13 Aug 1999 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define PC 1


//#include <direct.h>
//#include <io.h>
#include <time.h>

#include <ctype.h>

#include "lfptypes.h"
#include "elmer.h"
#include "maketext.h"

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


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL VARIABLES
// **************************************************************************
// **************************************************************************
// **************************************************************************


//
//
//

global	int                 si___Argc;
global	char **             ppcz_Argv;

global	ERRORCODE           ErrorCode           = ERROR_NONE;
global	char                ErrorMessage [256];

global	int                 CommandArg            = 1;
global	int                 CommandLine           = 0;
global	FILE *              CommandFile           = NULL;
global	char *              CommandString         = NULL;

global	char                CommandBuffer         [516];

global static UB hilo=0;

#define MAXCOMMANDSIZE      512

//
//
//

#define HELPMESSAGE0        0
#define HELPMESSAGE1        1
#define REMAPFROM           2
#define REMAPFILE           3
#define OUTPUTORDER         4
#define BANK                5
#define SKIP                6
#define LANGUAGES           7
#define JAPANESE            8

#define NUMBER_OF_OPTIONS   9

global	char *              OptionList[] =
			{
			"?",
			"H",
			"REMAPFROM",
			"REMAPFILE",
			"OUTPUTORDER",
			"BANK",
			"SKIP",
			"LANGUAGES",
			"JAPANESE"
			};

//
//
//

global	char *              StringYes           = "YES";
global	char *              StringNo            = "NO";


//
//
//

global	char *              StringHILO          = "HILO";
global	char *              StringLOHI          = "LOHI";

#define ORDERHILO 0
#define ORDERLOHI 1

//
//
//

global	char *              StringBIN           = "BIN";
global	char *              StringC             = "C";

#define OUTPUTBIN 0
#define OUTPUTC   1

//
//
//

global	UI                  uiFileCount         = 0;

global	UI                  uiOutputOrder       = ORDERHILO;
global	Boolean             flOutputHeader      = NO;
global	UI                  uiOutputFormat      = OUTPUTBIN;
global	Boolean             flSplitOutput       = NO;

#define MAXLABELSIZE 64

global	char                czOutputLabel       [MAXLABELSIZE];
global	char *              czOutputLabelEnd;

global	SL                  slWantLength        = -1;
global	SL                  slDropFirst         = -1;
global	SL                  slKeepFirst         = -1;
global	SL                  slDropLast          = -1;
global	SL                  slKeepLast          = -1;

global	SI                  siLine;

//
//
//

global	FILE *              ResultsFile;
global	char                ResultsName[128];
global	char *              ResultsExt;

global	char                acz__FileOut [500];

global	char                acz__FileDrv [500];
global	char                acz__FileDir [500];
global	char                acz__FileNam [500];
global	char                acz__FileExt [500];

//
//
//

typedef struct FileListS
	{
	struct FileListS *      pcl__flLink;
	char *                  cz___flFileName;
	SL                      sl___flFileOffset;
	SL                      sl___flFileLength;
	} FileListT;

global	FileListT *         pcl__gFiles         = NULL;
global	FileListT *         pcl__gFilesEnd      = NULL;

//
//
//

typedef struct BankListS
	{
	struct FileListS *      pcl__bkLink;
	SI                      sl___bkNum;
	UB *                    pub__bk1st;
	UB *                    pub__bkCur;
	UB                      aub__bkData [0x4000];
	} BankListT;

//
//
//

typedef struct FileInfoS
	{
	SL                      sl___fiFileOffset;
	SL                      sl___fiFileLength;
	} FileInfoT;

//
//
//

static char StringHex [512]	=

	{
	"000102030405060708090A0B0C0D0E0F"
	"101112131415161718191A1B1C1D1E1F"
	"202122232425262728292A2B2C2D2E2F"
	"303132333435363738393A3B3C3D3E3F"
	"404142434445464748494A4B4C4D4E4F"
	"505152535455565758595A5B5C5D5E5F"
	"606162636465666768696A6B6C6D6E6F"
	"707172737475767778797A7B7C7D7E7F"
	"808182838485868788898A8B8C8D8E8F"
	"909192939495969798999A9B9C9D9E9F"
	"A0A1A2A3A4A5A6A7A8A9AAABACADAEAF"
	"B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF"
	"C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF"
	"D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF"
	"E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF"
	"F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF"
	};

//
//
//

static UB AnsiToByte [256]	=

	{
	0x00u,	// $00 ' '
	0x00u,	// $01 ' '
	0x00u,	// $02 ' '
	0x00u,	// $03 ' '
	0x00u,	// $04 ' '
	0x00u,	// $05 ' '
	0x00u,	// $06 ' '
	0x00u,	// $07 ' '
	0x00u,	// $08 ' '
	0x00u,	// $09 ' '
	0x00u,	// $0A ' '
	0x00u,	// $0B ' '
	0x00u,	// $0C ' '
	0x00u,	// $0D ' '
	0x00u,	// $0E ' '
	0x00u,	// $0F ' '
	0x00u,	// $10 ' '
	0x00u,	// $11 ' '
	0x00u,	// $12 ' '
	0x00u,	// $13 ' '
	0x00u,	// $14 ' '
	0x00u,	// $15 ' '
	0x00u,	// $16 ' '
	0x00u,	// $17 ' '
	0x00u,	// $18 ' '
	0x00u,	// $19 ' '
	0x00u,	// $1A ' '
	0x00u,	// $1B ' '
	0x00u,	// $1C ' '
	0x00u,	// $1D ' '
	0x00u,	// $1E ' '
	0x00u,	// $1F ' '
	0x20u,	// $20 ' '
	0x21u,	// $21 '!'
	0x22u,	// $22 '"'
	0x23u,	// $23 '#'
	0x24u,	// $24 '$'
	0x25u,	// $25 '%'
	0x26u,	// $26 '&'
	0x27u,	// $27 '''
	0x28u,	// $28 '('
	0x29u,	// $29 ')'
	0x2Au,	// $2A '*'
	0x2Bu,	// $2B '+'
	0x2Cu,	// $2C ','
	0x2Du,	// $2D '-'
	0x2Eu,	// $2E '.'
	0x2Fu,	// $2F '/'
	0x30u,	// $30 '0'
	0x31u,	// $31 '1'
	0x32u,	// $32 '2'
	0x33u,	// $33 '3'
	0x34u,	// $34 '4'
	0x35u,	// $35 '5'
	0x36u,	// $36 '6'
	0x37u,	// $37 '7'
	0x38u,	// $38 '8'
	0x39u,	// $39 '9'
	0x3Au,	// $3A ':'
	0x3Bu,	// $3B ';'
	0x3Cu,	// $3C '<'
	0x3Du,	// $3D '='
	0x3Eu,	// $3E '>'
	0x3Fu,	// $3F '?'
	0x40u,	// $40 '@'
	0x41u,	// $41 'A'
	0x42u,	// $42 'B'
	0x43u,	// $43 'C'
	0x44u,	// $44 'D'
	0x45u,	// $45 'E'
	0x46u,	// $46 'F'
	0x47u,	// $47 'G'
	0x48u,	// $48 'H'
	0x49u,	// $49 'I'
	0x4Au,	// $4A 'J'
	0x4Bu,	// $4B 'K'
	0x4Cu,	// $4C 'L'
	0x4Du,	// $4D 'M'
	0x4Eu,	// $4E 'N'
	0x4Fu,	// $4F 'O'
	0x50u,	// $50 'P'
	0x51u,	// $51 'Q'
	0x52u,	// $52 'R'
	0x53u,	// $53 'S'
	0x54u,	// $54 'T'
	0x55u,	// $55 'U'
	0x56u,	// $56 'V'
	0x57u,	// $57 'W'
	0x58u,	// $58 'X'
	0x59u,	// $59 'Y'
	0x5Au,	// $5A 'Z'
	0x5Bu,	// $5B '['
	0x5Cu,	// $5C '\'
	0x5Du,	// $5D ']'
	0x5Eu,	// $5E '^'
	0x5Fu,	// $5F '_'
	0x60u,	// $60 '`'
	0x61u,	// $61 'a'
	0x62u,	// $62 'b'
	0x63u,	// $63 'c'
	0x64u,	// $64 'd'
	0x65u,	// $65 'e'
	0x66u,	// $66 'f'
	0x67u,	// $67 'g'
	0x68u,	// $68 'h'
	0x69u,	// $69 'i'
	0x6Au,	// $6A 'j'
	0x6Bu,	// $6B 'k'
	0x6Cu,	// $6C 'l'
	0x6Du,	// $6D 'm'
	0x6Eu,	// $6E 'n'
	0x6Fu,	// $6F 'o'
	0x70u,	// $70 'p'
	0x71u,	// $71 'q'
	0x72u,	// $72 'r'
	0x73u,	// $73 's'
	0x74u,	// $74 't'
	0x75u,	// $75 'u'
	0x76u,	// $76 'v'
	0x77u,	// $77 'w'
	0x78u,	// $78 'x'
	0x79u,	// $79 'y'
	0x7Au,	// $7A 'z'
	0x00u,	// $7B '{'
	0x00u,	// $7C '|'
	0x00u,	// $7D '}'
	0x00u,	// $7E '~'
	0x00u,	// $7F ' '
	0x00u,	// $80 ' '
	0x00u,	// $81 ' '
	0x00u,	// $82 ' '
	0x00u,	// $83 ' '
	0x00u,	// $84 ' '
	0x00u,	// $85 ' '
	0x00u,	// $86 ' '
	0x00u,	// $87 ' '
	0x00u,	// $88 ' '
	0x00u,	// $89 ' '
	0x00u,	// $8A ' '
	0x00u,	// $8B ' '
	0x00u,	// $8C ANSI_OE
	0x00u,	// $8D ' '
	0x00u,	// $8E ' '
	0x00u,	// $8F ' '
	0x00u,	// $90 ' '
	0x00u,	// $91 ' '
	0x00u,	// $92 ' '
	0x00u,	// $93 ' '
	0x00u,	// $94 ' '
	0x00u,	// $95 ' '
	0x00u,	// $96 ' '
	0x00u,	// $97 ' '
	0x00u,	// $98 ' '
	0x00u,	// $99 ' '
	0x00u,	// $9A ' '
	0x00u,	// $9B ' '
	0xA1u,	// $9C ANSI_oe
	0x00u,	// $9D ' '
	0x00u,	// $9E ' '
	0x00u,	// $9F ' '
	0x00u,	// $A0 ' '
	0x7Bu,	// $A1 ANSI_invpoint
	0x00u,	// $A2 ' '
	0x00u,	// $A3 ' '
	0x00u,	// $A4 ' '
	0x00u,	// $A5 ' '
	0x00u,	// $A6 ' '
	0x00u,	// $A7 ' '
	0x00u,	// $A8 ' '
	0xA9u,	// $A9 ANSI_copyright
	0x00u,	// $AA ' '
	0x00u,	// $AB ' '
	0x00u,	// $AC ' '
	0x00u,	// $AD ' '
	0x00u,	// $AE ' '
	0x00u,	// $AF ' '
	0x00u,	// $B0 ' '
	0x00u,	// $B1 ' '
	0x00u,	// $B2 ' '
	0x00u,	// $B3 ' '
	0x00u,	// $B4 ' '
	0x00u,	// $B5 ' '
	0x00u,	// $B6 ' '
	0x00u,	// $B7 ' '
	0x00u,	// $B8 ' '
	0x00u,	// $B9 ' '
	0x00u,	// $BA ' '
	0x00u,	// $BB ' '
	0x00u,	// $BC ' '
	0x00u,	// $BD ' '
	0x00u,	// $BE ' '
	0x7Cu,	// $BF ANSI_invqmark
	0x7Du,	// $C0 ANSI_Abak
	0x7Eu,	// $C1 ANSI_Afwd
	0x93u,	// $C2 ANSI_Ahat DAVE
	0x00u,	// $C3 ANSI_Atilde
	0x80u,	// $C4 ANSI_Aumlaut
	0x00u,	// $C5 ANSI_Ablob
	0x00u,	// $C6 ANSI_AE
	0x81u,	// $C7 ANSI_Ccedila
	0x82u,	// $C8 ANSI_Ebak
	0x83u,	// $C9 ANSI_Efwd
	0x98u,	// $CA ANSI_Ehat DAVE
	0x00u,	// $CB ANSI_Eumlaut
	0x85u,	// $CC ANSI_Ibak
	0x86u,	// $CD ANSI_Ifwd
	0x9Bu,	// $CE ANSI_Ihat DAVE
	0x00u,	// $CF ANSI_Iumlaut
	0x00u,	// $D0 ' '
	0x88u,	// $D1 ANSI_Ntilde
	0x89u,	// $D2 ANSI_Obak
	0x8Au,	// $D3 ANSI_Ofwd
	0x00u,	// $D4 ANSI_Ohat
	0x00u,	// $D5 ANSI_Otilde
	0x8Cu,	// $D6 ANSI_Oumlaut
	0x00u,	// $D7 ' '
	0x00u,	// $D8 ' '
	0x8Eu,	// $D9 ANSI_Ubak
	0x8Fu,	// $DA ANSI_Ufwd
	0x8Du,	// $DB ANSI_Uhat DAVE
	0x90u,	// $DC ANSI_Uumlaut
	0x00u,	// $DD ANSI_Yfwd
	0x00u,	// $DE ' '
	0xA5u,	// $DF ANSI_BS
	0x91u,	// $E0 ANSI_abak
	0x92u,	// $E1 ANSI_afwd
	0x93u,	// $E2 ANSI_ahat
	0x00u,	// $E3 ANSI_atilde
	0x94u,	// $E4 ANSI_aumlaut
	0x00u,	// $E5 ANSI_ablob
	0x00u,	// $E6 ANSI_ae
	0x95u,	// $E7 ANSI_ccedila
	0x96u,	// $E8 ANSI_ebak
	0x97u,	// $E9 ANSI_efwd
	0x98u,	// $EA ANSI_ehat
	0x00u,	// $EB ANSI_eumlaut
	0x99u,	// $EC ANSI_ibak
	0x9Au,	// $ED ANSI_ifwd
	0x9Bu,	// $EE ANSI_ihat
	0x00u,	// $EF ANSI_iumlaut
	0x00u,	// $F0 ' '
	0x9Cu,	// $F1 ANSI_ntilde
	0x9Du,	// $F2 ANSI_obak
	0x9Eu,	// $F3 ANSI_ofwd
	0x9Fu,	// $F4 ANSI_ohat
	0x00u,	// $F5 ANSI_otilde
	0xA0u,	// $F6 ANSI_oumlaut
	0x00u,	// $F7 ' '
	0x00u,	// $F8 ' '
	0xA2u,	// $F9 ANSI_ubak
	0xA3u,	// $FA ANSI_ufwd
	0x00u,	// $FB ANSI_uhat
	0xA4u,	// $FC ANSI_uumlaut
	0x00u,	// $FD ANSI_yfwd
	0x00u,	// $FE ' '
	0x00u	// $FF ANSI_yumlaut
	};

//
//
//

#define	MAX_LANG			5

global	char                acz__FileDir [500];

global	SL                  sl___Bank;

global	int                 si___SkipLang = 0;
global	int                 si___ReadLang = 5;
global	int                 si___Japanese = 0;

global	int                 si___Xlate = 0x20;

global	int                 si___StrNum;
global	int                 si___StrMax;
global	int                 asi__StrIdx [MAX_LANG] [ 2048];
global	int                 asi__StrNxt [MAX_LANG];
global	UB                  acz__StrBuf [MAX_LANG] [65536];
global  UB                  aub__OutBuf [256*1024];

global	UB                  aub__Found [256][256];
global	UB                  aub__Xlate [256][256];

global	char *              LanguageName[] =
			{
			"english",
			"german",
			"french",
			"italian",
			"spanish"
			};

static UB AnsiAndSjis []	=
	{
	0x00u,0x41u,0x00u,0x61u,26,		// Make lower and upper case the same if unset.
	0x82u,0x60u,0x82u,0x81u,26,		// Make lower and upper case the same if unset.
	0x00u,0x41u,0x82u,0x60u,26,		// Uppercase
	0x00u,0x61u,0x82u,0x81u,26,		// Lowercase
	0x00u,0x30u,0x82u,0x4Fu,10,     // Numerals
	0x00u,0x20u,0x81u,0x40u,1,      // Space
	0x00u,0x21u,0x81u,0x49u,1,      // !
	0x00u,0x22u,0x81u,0x4Eu,1,      // "
	0x00u,0x23u,0x81u,0x94u,1,      // #
	0x00u,0x24u,0x81u,0x90u,1,      // $
	0x00u,0x25u,0x81u,0x93u,1,      // %
	0x00u,0x26u,0x81u,0x95u,1,      // &
	0x00u,0x27u,0x81u,0x66u,1,      // '
	0x00u,0x28u,0x81u,0x69u,1,      // (
	0x00u,0x29u,0x81u,0x6Au,1,      // )
	0x00u,0x2Au,0x81u,0x96u,1,      // *
	0x00u,0x2Bu,0x81u,0x7Bu,1,      // +
	0x00u,0x2Cu,0x81u,0x43u,1,      // ,
	0x00u,0x2Du,0x81u,0x7Cu,1,      // -
	0x00u,0x2Eu,0x81u,0x44u,1,      // .
	0x00u,0x2Fu,0x81u,0x5Eu,1,      // /
	0x00u,0x3Au,0x81u,0x46u,1,      // :
	0x00u,0x3Bu,0x81u,0x47u,1,      // ;
	0x00u,0x3Du,0x81u,0x81u,1,      // =
	0x00u,0x3Fu,0x81u,0x48u,1,      // ?
	0,0,0,0,0
	};


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTION PROTOTYPES
// **************************************************************************
// **************************************************************************
// **************************************************************************



global	int                 main (int argc, char * argv[]);

extern	void                ErrorReset              (void);
extern	void                ErrorQualify            (void);

static	ERRORCODE           ParseRemapFile          (void);
static	ERRORCODE           CreateRemapping         (char * pcz__File);
static	ERRORCODE           procline                (char * pcz__line);
static	ERRORCODE           proclanguage            (int si___language, char * pcz__language);
static	ERRORCODE           procjapanese            (int si___language, char * pcz__language, char **line);


// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTION PROTOTYPES
// **************************************************************************
// **************************************************************************
// **************************************************************************


static	ERRORCODE           ProcessToken       (char * string);
static	char *              GetToken           (void);

static	ERRORCODE           ParseFlag          (Boolean  * flag);
static	ERRORCODE           ParseValue         (SL * value, char * option);
static	ERRORCODE           ParseLabel         (char * czlabel,
												UI     uispace,
												char * option);

static	ERRORCODE           ParseOutputOrder   (UI * order);
static	ERRORCODE           ParseOutputFormat  (UI * format);

static	ERRORCODE           LinkFile           (char * cz___filename);
static	ERRORCODE           FreeFiles          (void);

static	ERRORCODE           CreatePackage      (FileListT * pcl__filelist);

static	ERRORCODE           DumpBIN            (void * fileaddr,
												size_t filesize);

static	ERRORCODE           DumpC              (void * fileaddr,
												size_t filesize);

static	long                GetFileLength      (char * FileName);

static	void                splitcpy           (UB * dstptr, UB * srcptr, SL length);

static	long                LoadWholeFile           (
								char *              pcz__Name,
								unsigned char **    ppbf_Addr,
								long *              psl__Size);

static	long                SaveWholeFile           (
								char *              pcz__Name,
								unsigned char *     pbf__Addr,
								long                sl___Size);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************
#define MAXBAD 2048
int badvals[MAXBAD];
int numbad=0;
void addbad(int val)
{
int i;
	for(i=0;i<numbad;++i)
		if(badvals[i]==val) return;
	if(numbad<MAXBAD) badvals[numbad++]=val;
}
void addbad2(int v1,int v2)
{
	addbad((v1<<8)|v2);
}
int intcomp(const void *s1,const void *s2)
{
	return *(int *)s1-*(int *)s2;
}

void showbad()
{
int i;
	if(!numbad) return;
	qsort(badvals,numbad,sizeof(int),intcomp);
	printf("Bad characters\n");
	for(i=0;i<numbad;++i)
		printf("%04x\n",badvals[i]);
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

	char *		p;

	// Sign on.

	si___Argc = argc;
	ppcz_Argv = argv;

	puts("\nMAKETEXT v0.06 " __DATE__ " by J.C.Brandwood\n");

	// Initialize global data.

	czOutputLabel[0] = '\0';

	pcl__gFiles    = NULL;
	pcl__gFilesEnd = (FileListT *) (&pcl__gFiles);

	// Initialize remapping.

	memset(aub__Xlate, 0, sizeof(aub__Xlate));

	memcpy(&aub__Xlate[0][0], AnsiToByte, 256);

	// Read through program arguments.

	while ((p = GetToken()) != NULL)
		{
		if (ProcessToken(p) != ERROR_NONE) goto exit;
		}

	if (ErrorCode != ERROR_NONE) goto exit;

	// Print up help message if there were no files to package.

	if (pcl__gFiles == NULL)
		{
		ProcessToken("-?");
		goto exit;
		}

	// Now create the package file.

	printf("\n");

	_splitpath(acz__FileOut, acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

	if (CreatePackage(pcl__gFiles) != ERROR_NONE)
		{
		goto exit;
		}

	// Print success message.

	printf("\nMAKETEXT process completed without error.\n");

	// Program exit.
	//
	// This will either be dropped through to if everything is OK, or 'goto'ed
	// if there was an error.

	exit:

		ErrorQualify();

		if (ErrorCode != ERROR_NONE)
			{
			puts(ErrorMessage);
			}

		if (ResultsFile != NULL) fclose(ResultsFile);

		if (CommandFile != NULL) fclose(CommandFile);

		FreeFiles();

showbad();
		return ((ErrorCode != ERROR_NONE));

	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



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

static	ERRORCODE	ProcessToken (char * string)

	{
	// Local variables.

	UI				i;
	SL				l;

	// Is the token a command file ?

	if (*string == '@')
		{
		// Skip the leading '@'.

		string++;

		// Is there already an open command file ?

		if (CommandFile != NULL)
			{
			ErrorCode = ERROR_ILLEGAL;
			sprintf(ErrorMessage,
				"MAKETEXT error : Unable to open nested command file %s at line %d.\n",
				string, CommandLine);
			goto errorExit;
			}

		// Open the command file.

		CommandString = NULL;
		CommandLine   = 0;

		if ((CommandFile = fopen(string,"rt")) == NULL)
			{
			ErrorCode = ERROR_NO_FILE;
			sprintf(ErrorMessage,
				"MAKETEXT error : Unable to open command file %s.\n",
				string);
			goto errorExit;
			}

		strcpy(acz__FileOut, string);

		printf("CommandFile = %s\n\n", string);
		}

	// Is the token an option ?

	else

	if (*string == '-')

		// Token is an option.

		{
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
			// Request for help ?

			case HELPMESSAGE0:
			case HELPMESSAGE1:
				{
				puts(
					"Usage : MAKETEXT [@<commandfile>] [<option>] [<datafile>]\n"
					"\n"
					"This utility converts EXCEL .CSV file(s) of strings into usable data.\n"
					"\n"
					"The list of files, together with any options for each file are\n"
					"given in a command file or specified on the command line.\n"
					"\n"
					"The command file is an ASCII text file consisting of a list of\n"
					"the files to package together, with each filename on a seperate\n"
					"line. Blank lines are ignored, as are lines that start with a\n"
					"semicolon.\n"
					"\n"
					"The following options are available ...\n"
					"\n"
					"-Bank         n\n"
					"\n"
					"The output is controlled by the following options ...\n"
					"\n"
					"-OutputOrder  HILO | LOHI\n"
					);
				break;
				}

			// New REMAPFROM value ?

			case REMAPFROM:
				{
				if (ParseValue(&l, "REMAPFROM") != ERROR_NONE)
					{
					goto errorExit;
					}
				si___Xlate = (int) l;
				if ((si___Xlate < 1) || (si___Xlate > 255))
					{
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal number in RemapFrom option at line %d.\n"
						"(MAKETEXT, ProcessLine)\n",
						(UI) CommandLine);
					goto errorExit;
					}
				break;
				}

			// New REMAPFILE value ?

			case REMAPFILE:
				{
				if (ParseRemapFile() != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New uiOutputOrder ?

			case OUTPUTORDER:
				{
				if (ParseOutputOrder(&uiOutputOrder) != ERROR_NONE) goto errorExit;
				break;
				}

			// New BANK value ?

			case BANK:
				{
				if (ParseValue(&sl___Bank, "BANK") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New SKIP value ?

			case SKIP:
				{
				if (ParseValue(&l, "SKIP") != ERROR_NONE)
					{
					goto errorExit;
					}
				si___SkipLang = (int) l;
				if ((si___SkipLang < 0) || (si___SkipLang > 32))
					{
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal number in skip option at line %d.\n"
						"(MAKETEXT, ProcessLine)\n",
						(UI) CommandLine);
					goto errorExit;
					}
				break;
				}

			// New LANGUAGES value ?

			case LANGUAGES:
				{
				if (ParseValue(&l, "LANGUAGES") != ERROR_NONE)
					{
					goto errorExit;
					}
				si___ReadLang = (int) l;
				if ((si___ReadLang < 1) || (si___ReadLang > MAX_LANG))
					{
					ErrorCode = ERROR_ILLEGAL;
					sprintf(ErrorMessage,
						"Illegal number of languages option at line %d.\n"
						"(MAKETEXT, ProcessLine)\n",
						(UI) CommandLine);
					goto errorExit;
					}
				break;
				}

			// New JAPANESE value ?

			case JAPANESE:
				{
				si___Japanese = 1;
				break;
				}

			// Unidentified option.

			default:
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unidentified option at line %d.\n"
					"(MAKETEXT, ProcessLine)\n",
					(UI) CommandLine);
				goto errorExit;
				}

			}

		}

	// If neither of the above, then it must be a data file.

	else

		{
		// If we don't already have an output file, use this file as the basis.

		if (*acz__FileOut == 0)
			{
			strcpy(acz__FileOut, string);
			}

		// Add the file onto the list of files.

		uiFileCount += 1;

//		strupr(string);

		if (LinkFile(string) != ERROR_NONE) goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



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

static	char *		GetToken (void)

	{
	// Local variables.

	// Are we reading a command file or the program arguments ?

	if (CommandFile != NULL)
		{
		if (CommandString != NULL)
			{
			CommandString = strtok(NULL, " \t\n");
			}

		if (CommandString == NULL)
			{
			do	{
				CommandLine += 1;

				if (fgets(CommandBuffer, 512, CommandFile) == NULL)
					{
					fclose(CommandFile);

					CommandString = NULL;
					CommandFile   = NULL;
					CommandLine   = 0;

					break;
					}

				CommandString = strtok(CommandBuffer, " \t\n");

				} while ((CommandString == NULL) || (*CommandString == ';'));
			}
		}

	if (CommandString != NULL)
		{
		return (CommandString);
		}
	else
		{
		// Get next token from the command line.

		if (CommandArg != si___Argc)
			{
			return (ppcz_Argv[CommandArg++]);
			}
		}

	// All tokens read, return end of commands marker.

	return (NULL);
	}







// **************************************************************************
//	ParseFlag ()
//
//	Usage
//		static ERRORCODE ParseFlag (Boolean &flag)
//
//	Description
//		Read the new token and use it to set the flag to YES or NO.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseFlag (Boolean * flag)

	{
	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"MAKETEXT error : Flag value missing after option at line %d.\n",
			(UI) CommandLine);
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
			"MAKETEXT error : Illegal flag value %s after option at line %d.\n",
			(char *) string,
			(UI) CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ParseValue ()
//
//	Usage
//		static ERRORCODE ParseValue (SL &value, char * option)
//
//	Description
//		Read the next token as a numeric value.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseValue (SL * value, char * option)

	{
	// Local variables.

	char *		string;
	char *		p;
	SL				l;

	// Get the value's new token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Value missing after %s option at line %d.\n"
			"(MAKETEXT, SetValue)\n",
			option,
			(UI) CommandLine);
		goto errorExit;
		}

	l = strtol(string, &p, 0);

	if (*p != '\0')
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Illegal characters in %s value at line %d.\n"
			"(MAKETEXT, SetValue)\n",
			option,
			(UI) CommandLine);
		goto errorExit;
		}

	*value = l;

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ParseLabel ()
//
//	Usage
//		static ERRORCODE ParseLabel (char * czlabel, UI uispace, char * option)
//
//	Description
//		Read the next token as a string.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseLabel (char * czlabel, UI uispace, char * option)

	{
	// Local variables.

	char *		string;

	// Get the value's new token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Label missing after %s option at line %d.\n"
			"(MAKETEXT, ParseLabel)\n",
			option,
			(UI) CommandLine);
		goto errorExit;
		}

	if (strlen(string) >= uispace)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Label too long after %s option at line %d.\n"
			"(MAKETEXT, ParseLabel)\n",
			option,
			(UI) CommandLine);
		goto errorExit;
		}

	strcpy(czlabel, string);

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ParseOutputOrder ()
//
//	Usage
//		static ERRORCODE ParseOutputOrder (UI &order)
//
//	Description
//		Read the new token and use it to set the order to HILO or LOHI.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseOutputOrder (UI * order)

	{
	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"MAKETEXT error : OutputOrder value missing at line %d.\n",
			(UI) CommandLine);
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
			"MAKETEXT error : Illegal OutputOrder value %s at line %d.\n",
			(char *) string,
			(UI) CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ParseOutputFormat ()
//
//	Usage
//		static ERRORCODE ParseOutputFormat (UI &format)
//
//	Description
//		Read the new token and use it to set the order to HILO or LOHI.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseOutputFormat (UI * format)

	{
 	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"MAKETEXT error : OutputFormat value missing at line %d.\n",
			(UI) CommandLine);
		goto errorExit;
		}

	if (strcmpi(string, StringBIN) == 0)
		{
		*format = OUTPUTBIN;
		}
	else if (strcmpi(string, StringC) == 0)
		{
		*format = OUTPUTC;
		}
	else
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"MAKETEXT error : Illegal OutputFormat value %s at line %d.\n",
			(char *) string,
			(UI) CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	ParseRemapFile ()
//
//	Usage
//		static ERRORCODE ParseFlag (Boolean &flag)
//
//	Description
//		Read the new token and use it to set the flag to YES or NO.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE ParseRemapFile (void)

	{
	// Local variables.

	char *		string;

	// Get the flag's new value token.

	string = GetToken();

	if (string == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"MAKETEXT error : Filename missing after REMAPFILE option at line %d.\n",
			(UI) CommandLine);
		goto errorExit;
		}

	// Return with success code.

	return (CreateRemapping(string));

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	LinkFile ()
//
//	Usage
//		static ERRORCODE LinkFile (char * cz___filename)
//
//	Description
//		Add this file into the list of files to be packaged together.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE LinkFile (char * cz___filename)

	{
	// Static variables.

	static char *       cz___fileblank = "            ";

	// Local variables.

	char                cz___filespace[16];
	FileListT *         pcl__file;
	SL                  sl___fileoffset;
	SL                  sl___filelength;

	// Allocate a new FileList block.

	pcl__file = calloc(sizeof(FileListT), 1);

	if (pcl__file == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Out of memory.\n"
			"(MAKETEXT, LinkFile)\n");
		goto errorExit;
		}

	// Create a copy of the filename, and put it in the FileList block.

	pcl__file->cz___flFileName = strdup(cz___filename);

	if (pcl__file->cz___flFileName == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Out of memory.\n"
			"(MAKETEXT, LinkFile)\n");
		goto errorFree1;
		}

	// Find out which region of the file we want.

	sl___fileoffset = 0;
	sl___filelength = GetFileLength(cz___filename);

	if (sl___filelength < 0)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Can't get size of file %s.\n"
			"(MAKETEXT, LinkFile)\n",
			pcl__file->cz___flFileName);
		goto errorFree2;
		}

	pcl__file->sl___flFileOffset = sl___fileoffset;
	pcl__file->sl___flFileLength = sl___filelength;

	// Print out details of this file.

	strcpy(cz___filespace, cz___fileblank);

	cz___filename = strrchr(pcl__file->cz___flFileName, '\\');

	if (cz___filename == NULL)
		{
		cz___filename = pcl__file->cz___flFileName;
		}
	else
		{
		cz___filename += 1;
		}

	if (strlen(cz___filename) < 13)
		{
		strncpy(cz___filespace, cz___filename, strlen(cz___filename));
		}

	printf(
		"%s  offset 0x%08lX  length 0x%08lX\n",
		cz___filespace,
		pcl__file->sl___flFileOffset,
		pcl__file->sl___flFileLength
		);

	// Link the new file into the list of files.

	pcl__file->pcl__flLink      = NULL;
	pcl__gFilesEnd->pcl__flLink = pcl__file;
	pcl__gFilesEnd              = pcl__file;

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorFree2:

		free (pcl__file->cz___flFileName);

	errorFree1:

		free (pcl__file);

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	FreeFiles ()
//
//	Usage
//		static ERRORCODE FreeFiles (void)
//
//	Description
//		Free up all the memory used by the FileListT blocks.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE FreeFiles (void)

	{
	// Local variables.

	FileListT *         pcl__file;
	FileListT *         pcl__next;

	// Free up all the FileList blocks and their associated file names.

	pcl__file = pcl__gFiles;

	while (pcl__file != NULL)
		{
		pcl__next = pcl__file->pcl__flLink;
		    free(pcl__file->cz___flFileName);
		free(pcl__file);
		pcl__file = pcl__next;
		}

	return (ERROR_NONE);

	}



// **************************************************************************
//	CreateRemapping ()
//
//	Usage
//		static ERRORCODE CreateRemapping (char * pcz__File)
//
//	Description
//		Create a package file from a list of files.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE CreateRemapping (char * pcz__File)

	{
	// Local variables.

	UB *                pub__Code;
	UB                  ub___1st;
	UB                  ub___2nd;

	UB *                pub__File;
	long                sl___File;

	// Clear remapping table.

	memset(aub__Xlate, 0, sizeof(aub__Xlate));

	// Read the file into the buffer.

	pub__File = NULL;
	sl___File = 0;

	if (LoadWholeFile(pcz__File, &pub__File, &sl___File) < 0)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Unable to read remapping file %s.\n"
			"(MAKETEXT, CreatePackage)\n",
			pcz__File);
		goto errorExit;
		}

	//

	pub__Code = pub__File;

	while (sl___File >= 0)
		{
		// Read a character.

		ub___2nd = *pub__Code++; sl___File -= 1;

/*
		// Strip CR/LF bytes.

		if ((ub___2nd == 0x0D) || (ub___2nd == 0x0A))
			{
			continue;
			}
*/

		//

		ub___1st = 0;

		if ((si___Japanese != 0))
			{
			ub___1st = *pub__Code++; sl___File -= 1;
			}

		// Save as next code.

		aub__Xlate[ub___1st][ub___2nd] = (UB) si___Xlate++;
		}

	if(aub__Xlate[0][0x61] == 0 && aub__Xlate[0][0x41] != 0) // a-z
		memcpy(&aub__Xlate[0][0x61],&aub__Xlate[0][0x41],26);
	if(aub__Xlate[0][0x41] == 0 && aub__Xlate[0][0x61] != 0) // A-Z
		memcpy(&aub__Xlate[0][0x41],&aub__Xlate[0][0x61],26);
	if(aub__Xlate[0xff][0x41] == 0 && aub__Xlate[0][0x61] != 0) // A-Z
		memcpy(&aub__Xlate[0xff][0x41],&aub__Xlate[0][0x61],26);
	if(aub__Xlate[0xff][0x21] == 0 && aub__Xlate[0][0x41] != 0) // a-z
		memcpy(&aub__Xlate[0xff][0x21],&aub__Xlate[0][0x41],26);

	if(aub__Xlate[0xff][0x10]==0) // 0-9
		memcpy(&aub__Xlate[0xff][0x10],&aub__Xlate[0x00][0x30],10);
	if(aub__Xlate[0x30][0x00]==0) // ' '
		aub__Xlate[0x30][0x00]=aub__Xlate[0x00][0x20];
	if(aub__Xlate[0xff][0x01]==0) // '!'
		aub__Xlate[0xff][0x01]=aub__Xlate[0x00][0x21];
	if(aub__Xlate[0xff][0x1f]==0) // '?'
		aub__Xlate[0xff][0x1f]=aub__Xlate[0x00][0x3f];
	if(aub__Xlate[0xff][0x03]==0) // '#'
		aub__Xlate[0xff][0x03]=aub__Xlate[0x00][0x23];
	if(aub__Xlate[0xff][0x06]==0) // '&'
		aub__Xlate[0xff][0x06]=aub__Xlate[0x00][0x26];


#if 0  // Leftover shift gis stuff
	// ANSI A-Z set ?

	if (aub__Xlate[0x00][0x41] == 0)
		{
		if (aub__Xlate[0x82][0x60] != 0)
			{
			memcpy(&aub__Xlate[0x00][0x41], &aub__Xlate[0x82][0x60], 26);
			}
		else
		if (aub__Xlate[0x82][0x81] != 0)
			{
			memcpy(&aub__Xlate[0x00][0x41], &aub__Xlate[0x82][0x81], 26);
			}
		}

	// ANSI a-z set ?

	if (aub__Xlate[0x00][0x61] == 0)
		{
		if (aub__Xlate[0x82][0x81] != 0)
			{
			memcpy(&aub__Xlate[0x00][0x61], &aub__Xlate[0x82][0x81], 26);
			}
		else
		if (aub__Xlate[0x82][0x60] != 0)
			{
			memcpy(&aub__Xlate[0x00][0x61], &aub__Xlate[0x82][0x60], 26);
			}
		}

	// SJIS A-Z set ?

	if (aub__Xlate[0x82][0x60] == 0)
		{
		if (aub__Xlate[0x00][0x41] != 0)
			{
			memcpy(&aub__Xlate[0x82][0x60], &aub__Xlate[0x00][0x41], 26);
			}
		else
		if (aub__Xlate[0x00][0x61] != 0)
			{
			memcpy(&aub__Xlate[0x82][0x60], &aub__Xlate[0x00][0x61], 26);
			}
		}

	// SJIS a-z set ?

	if (aub__Xlate[0x82][0x81] == 0)
		{
		if (aub__Xlate[0x00][0x61] != 0)
			{
			memcpy(&aub__Xlate[0x82][0x81], &aub__Xlate[0x00][0x61], 26);
			}
		else
		if (aub__Xlate[0x00][0x41] != 0)
			{
			memcpy(&aub__Xlate[0x82][0x81], &aub__Xlate[0x00][0x41], 26);
			}
		}

	// ANSI 0-9 set ?

	if (aub__Xlate[0x00][0x30] == 0)
		{
		if (aub__Xlate[0x82][0x4F] != 0)
			{
			memcpy(&aub__Xlate[0x00][0x30], &aub__Xlate[0x82][0x4F], 10);
			}
		}

	// SJIS 0-9 set ?

	if (aub__Xlate[0x82][0x4F] == 0)
		{
		if (aub__Xlate[0x00][0x30] != 0)
			{
			memcpy(&aub__Xlate[0x82][0x4F], &aub__Xlate[0x00][0x30], 10);
			}
		}

	// ANSI space set ?

	if (aub__Xlate[0x00][0x20] == 0)
		{
		if (aub__Xlate[0x81][0x40] != 0)
			{
			aub__Xlate[0x00][0x20] = aub__Xlate[0x81][0x40];
			}
		}

	// SJIS space set ?

	if (aub__Xlate[0x81][0x40] == 0)
		{
		if (aub__Xlate[0x00][0x20] != 0)
			{
			aub__Xlate[0x81][0x40] = aub__Xlate[0x00][0x20];
			}
		}

	//
#endif

	{
	UB ub___1st,ub___2nd,ub___3rd,ub___4th,ub___5th;
	UB * pub__Equivalent;

	pub__Equivalent = AnsiAndSjis;

	do	{
		ub___1st = *pub__Equivalent++;
		ub___2nd = *pub__Equivalent++;
		ub___3rd = *pub__Equivalent++;
		ub___4th = *pub__Equivalent++;
		ub___5th = *pub__Equivalent++;

		if ((aub__Xlate[ub___1st][ub___2nd] == 0) && (aub__Xlate[ub___3rd][ub___4th] != 0))
			{
			memcpy(&aub__Xlate[ub___1st][ub___2nd], &aub__Xlate[ub___3rd][ub___4th], ub___5th);
			}
		else
		if ((aub__Xlate[ub___3rd][ub___4th] == 0) && (aub__Xlate[ub___1st][ub___2nd] != 0))
			{
			memcpy(&aub__Xlate[ub___3rd][ub___4th], &aub__Xlate[ub___1st][ub___2nd], ub___5th);
			}
		} while ((ub___1st | ub___2nd) != 0);
	}

	// Return with success code.

	ErrorCode = ERROR_NONE;

	// Error handlers (reached via the dreaded goto).

	errorExit:

		if (pub__File != NULL)
			{
			free(pub__File);
			}

		return (ErrorCode);

	}

int nextletterboth(unsigned char **p)
{
int v;

	v=*(*p)++;
	if(si___Japanese)
	{
		if(hilo)
			v=(v<<8) | *(*p)++;
		else
			v=v | (*(*p)++ << 8);
		if(v==0xfffe) {hilo=!hilo;v=0xfeff;}
	}
	return v;
}
int nextletter(unsigned char **p)
{
int v;

top:
	v=*(*p)++;
	if(si___Japanese)
		v=v | (*(*p)++ << 8);
	return v;
}

char *myfgets(unsigned char *s,int size,FILE *f)
{
unsigned char t[2],*p,*put;
int l,v;
	if(!si___Japanese) return fgets(s,size,f);
	put=s;
	while(put<s+size-2)
	{
		l=fread(t,1,2,f);
		if(l<2) return 0;
		p=t;
		v=nextletterboth(&p);
		if(v==0xfeff) continue;
		if(v==0x0d) continue;
		if(v==0x0a) break;
		*put++=v;
		*put++=v>>8;
	}
	*put++=0;
	*put++=0;
	return s;

}

// **************************************************************************
//	CreatePackage ()
//
//	Usage
//		static ERRORCODE CreatePackage (FileListT * pcl__file)
//
//	Description
//		Create a package file from a list of files.
//
//	Return Value
//		ERROR_NONE if OK, else error.
// **************************************************************************

static	ERRORCODE CreatePackage (FileListT * pcl__filelist)

	{
	// Local variables.

	FILE *              f;

	int                 i;
	int                 j;
	int                 k;

	int                 si___OutIdx;
	int                 si___OutBuf;
	UB *                pub__Src;

	char                acz__Bank [16];

	char                acz__line [2048];

	// Clear strings.

	memset(asi__StrIdx, 0, sizeof(asi__StrIdx));
	memset(acz__StrBuf, 0, sizeof(acz__StrBuf));

	si___StrMax = 1;

	for (i = 0; i < si___ReadLang; i++)
		{
		asi__StrNxt[i] = 1;
		}

	// Clear usage flags.

	memset(aub__Found, 0, sizeof(aub__Found));

	// Now read in each file into the buffer.

	while (pcl__filelist != NULL)

		{
		// Read the file into the buffer.

		if ((f = fopen(pcl__filelist->cz___flFileName, "rt")) == NULL)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to open %s for reading.\n"
				"(MAKETEXT, CreatePackage)\n",
				pcl__filelist->cz___flFileName);
			goto errorExit;
			}

		// Now read through the input one line at a time.

		siLine = 1;

		while (myfgets(acz__line, 2048, f) != NULL)
					{

					if (procline(acz__line) < 0) goto errorClose;
					siLine += 1;
					}

		// Was there an error ?

		if (ferror(f))
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to read input file %s.\n"
				"(MAKETEXT, CreatePackage)\n",
				pcl__filelist->cz___flFileName);
			goto errorClose;
			}

		fclose(f);

		// Now repeat for the next file.

		pcl__filelist = pcl__filelist->pcl__flLink;
		}

	// Initialize the language.

	si___StrNum = si___StrMax + 1;

	for (i = 0; i < si___ReadLang; i++)
		{
		aub__OutBuf[(2*i)+0] = (255 & (((si___ReadLang*2) + (i*3*si___StrNum)) >> 0));
		aub__OutBuf[(2*i)+1] = (255 & (((si___ReadLang*2) + (i*3*si___StrNum)) >> 8)) + 0x40;
		}

	si___OutIdx = si___ReadLang * (2);
	si___OutBuf = si___ReadLang * (2 + (3*si___StrNum));

	// Process each language.

	for (i = 0; i < si___ReadLang; i += 1)
		{
		// Process each string in the language.

		for (j = 0; j <= si___StrMax; j += 1)
			{
			// Empty string ?

			if (asi__StrIdx[i][j] == 0)
				{
				aub__OutBuf[si___OutIdx + 0] = 0;
				aub__OutBuf[si___OutIdx + 1] = 0;
				aub__OutBuf[si___OutIdx + 2] = 0;
				si___OutIdx += 3;
				continue;
				}

			// Locate the src string.

			pub__Src = &acz__StrBuf[i][(asi__StrIdx[i][j])];

			// Pad out to the next bank if it would overflow.

			k = strlen((char *) pub__Src) + 1;

			if ((si___OutBuf & ~0x3FFF) != ((si___OutBuf + k) & ~0x3FFF))
				{
				while (si___OutBuf & 0x3FFF)
					{
					aub__OutBuf[si___OutBuf] = 0;
					si___OutBuf += 1;
					}
				}

			// Write the header.

			aub__OutBuf[si___OutIdx + 0] = 255 & (((si___OutBuf & 0x3FFF) + 0x4000) >> 0);
			aub__OutBuf[si___OutIdx + 1] = 255 & (((si___OutBuf & 0x3FFF) + 0x4000) >> 8);
			aub__OutBuf[si___OutIdx + 2] = ((si___OutBuf & ~0x3FFF) >> 14) + (int) sl___Bank;
			si___OutIdx += 3;

			// Copy the string.

			do	{
				aub__OutBuf[si___OutBuf++] = *pub__Src;
				} while (*pub__Src++ != 0);

			// Now process the next string.
			}

		// Now process the next language.
		}

	// Pad out the output to a 16-byte boundary.

	while (si___OutBuf & 15)
		{
		aub__OutBuf[si___OutBuf] = 0;
		si___OutBuf += 1;
		}

	// Print out usage flags.

	{
	int i,j;
	for (i = 128; i < 256; i++)
		{
		if (aub__Found[0][i] != 0)
			{
			printf("Found ANSI 0x%02X.\n", i);
			}
		}

/*
	for (i = 128; i < 256; i++)
		{
		for (j = 64; j < 256; j++)
			{
			if (aub__Found[i][j] != 0)
				{
				printf("Found SJIS 0x%02X,0x%02X.\n", i, j);
				}
			}
		}
*/
	}

	// Write out the banks of strings.

	pub__Src = aub__OutBuf;

	while (si___OutBuf)
		{
		// Create the output filename.

		sprintf(acz__Bank, ".b%02lx", sl___Bank++);

//		strcpy(acz__FileOut, acz__FileDrv);
//		strcat(acz__FileOut, acz__FileDir);
//		strcat(acz__FileOut, acz__FileNam);
//		strcat(acz__FileOut, acz__Bank);

		strcpy(acz__FileOut, acz__FileNam);
		strcat(acz__FileOut, acz__Bank);

		printf("Writing %s\n", acz__FileOut);

		//

		si___OutIdx = (si___OutBuf < 0x4000) ? si___OutBuf : 0x4000;

		if (SaveWholeFile(acz__FileOut, pub__Src, si___OutIdx) < 0)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to write output bank %s.\n"
				"(MAKETEXT, CreatePackage)\n",
				acz__FileOut);
			goto errorExit;
			}

		//

		pub__Src    += si___OutIdx;
		si___OutBuf -= si___OutIdx;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorClose:

		fclose(f);

	errorExit:

		return (ErrorCode);

	}

char *mystrtok(char **s,char *delim)
{
static unsigned char *p=0;
char *put,*t;
static char save[2048],**mys;
int c;

	if(s) {p=*s;mys=s;}
	if(!p) return 0;
	put=save;
	while(c=nextletter(&p))
	{
		t=delim;
		while(*t && *t!=c) ++t;
		if(*t) break;
		if(put<save+sizeof(save)-1)
			*put++=c;
	}
	*put=0;
	if(!c) p=0;
	*mys=p;
	return save;
}



// **************************************************************************
//	procline ()
//
//	Usage
//		static void splitcpy (UB * dstptr, UB * srcptr, SL length)
//
//	Description
//		Do an even/odd byte copy.
//
//	Return Value
//		None.
// **************************************************************************

static	ERRORCODE procline (char * pcz__line)

	{
	// Local variables.

	char *              pcz__token;
	int                 i;

	SL                  slString;

	// Empty line.

	if ((*pcz__line == '\n') || (*pcz__line == '\t'))
		{
		return (ERROR_NONE);
		}

	// Read the string number.

	pcz__token = mystrtok(&pcz__line, "\t\n");

	slString = strtol(pcz__token, &pcz__token, 0);
	if (*pcz__token != '\0')
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Unable to read string number at line %d.\n"
			"(MAKETEXT, CreatePackage)\n",
			siLine);
		goto errorExit;
		}

	if ((slString < 1) || (slString > 255))
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Illegal string number at line %d.\n"
			"(MAKETEXT, CreatePackage)\n",
			siLine);
		goto errorExit;
		}

	si___StrNum = slString;

	if (asi__StrIdx[0][si___StrNum] != 0)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"String %d already defined at line %d.\n"
			"(MAKETEXT, CreatePackage)\n",
			si___StrNum,
			siLine);
		goto errorExit;
		}

	if (si___StrMax < si___StrNum)
		{
		si___StrMax = si___StrNum;
		}

	// Skip language text.

	for (i = 0; i < si___SkipLang; i += 1)
		{
		if ((pcz__token = mystrtok(NULL, "\t\n")) == NULL)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Missing skipped text at line %d.\n"
				"(MAKETEXT, CreatePackage)\n",
				siLine);
			goto errorExit;
			}
		}
	// Read language text.
	for (i = 0; i < si___ReadLang; i += 1)
		{
		if (si___Japanese)
			{
			if (procjapanese(i, LanguageName[i],&pcz__line) != ERROR_NONE)
				{
				goto errorExit;
				}
			}
		else
			{

			if (proclanguage(i, LanguageName[i]) != ERROR_NONE)
				{
				goto errorExit;
				}
			}
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	proclanguage ()
//
//	Usage
//		static void splitcpy (UB * dstptr, UB * srcptr, SL length)
//
//	Description
//		Do an even/odd byte copy.
//
//	Return Value
//		None.
// **************************************************************************

static	ERRORCODE proclanguage (int si___Language, char * pcz__Language)

	{
	// Local variables.

	char *              pcz__token;

	UB *                pub__Dst;
	UB                  ub___Dst;

	// Locate english text.

	if ((pcz__token = mystrtok(NULL, "\t\n")) == NULL)
		{

/*
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Missing %s text at line %d.\n"
			"(MAKETEXT, CreatePackage)\n",
			pcz__Language,
			siLine);
		goto errorExit;
*/
//(DA)
pcz__token=" ";
		}

	//

	pub__Dst = &acz__StrBuf[si___Language][asi__StrNxt[si___Language]];

	while (*pcz__token != 0)
		{
		// Track usage.

		if (*((UB *) pcz__token) > 0x7Fu)
			{
			aub__Found[0][*((UB *) pcz__token)] = 1;
//			printf("Found 0x%02X in %s text at line %d\n", *((UB *) pcz__token), pcz__language, siLine);
			}

		// Convert chr.

		ub___Dst = aub__Xlate[0][(UB) *pcz__token];

		//
/*
		if (ub___Dst == 0)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Untranslatable chr 0x%02X in language %d text at line %d.\n"
				"(MAKETEXT, CreatePackage)\n",
				(int) *pcz__token,
				si___Language + 1,
				siLine);
			goto errorExit;
			}
*/

		//

		if (ub___Dst == 0)
			{
			printf(
				"Untranslatable chr 0x%02X in language %d text at line %d.\n",
				(int) *pcz__token,
				si___Language + 1,
				siLine);
			addbad(*pcz__token);
			ub___Dst = aub__Xlate[0x00][0x20];
			}

		//

		*pub__Dst++ = ub___Dst;

		pcz__token += 1;
		}

	// Terminate the string and update the pointers.

	*pub__Dst++ = 0;

	asi__StrIdx[si___Language][si___StrNum] = asi__StrNxt[si___Language];

	asi__StrNxt[si___Language] = pub__Dst - &acz__StrBuf[si___Language][0];

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	procjapanese ()
//
//	Usage
//		static void splitcpy (UB * dstptr, UB * srcptr, SL length)
//
//	Description
//		Do an even/odd byte copy.
//
//	Return Value
//		None.
// **************************************************************************

static	ERRORCODE procjapanese (int si___Language, char * pcz__Language,char **pcz__line)

	{
	// Local variables.

	char *              pcz__token;

	UB *                pub__Dst;
	UB                  ub___Dst;

	UB                  ub___1st;
	UB                  ub___2nd;
	int t;
	// Locate english text.

/*
	if ((pcz__token = mystrtok(NULL, "\t\n")) == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Missing %s text at line %d.\n"
			"(MAKETEXT, CreatePackage)\n",
			pcz__Language,
			siLine);
		goto errorExit;
		}
*/

	//

	pub__Dst = &acz__StrBuf[si___Language][asi__StrNxt[si___Language]];

	while ((t=nextletter((unsigned char **)pcz__line)) && t!=9 && t!='\n')
		{
		// Read the next character.
		ub___1st=t>>8;
		ub___2nd=t;

//printf("%02x%02x\n",ub___1st,ub___2nd);

		// Track usage.

		if ((ub___1st != 0x00u) || (ub___2nd > 0x7Fu))
			{
			aub__Found[ub___1st][ub___2nd] = 1;
//			printf("Found 0x%02X in %s text at line %d\n", *((UB *) pcz__token), pcz__language, siLine);
			}

		// Convert chr.

		ub___Dst = aub__Xlate[ub___1st][ub___2nd];

		//
/*
		if (ub___Dst == 0)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Untranslatable chr 0x%02X,0x%02X in language %d text at line %d.\n"
				"(MAKETEXT, CreatePackage)\n",
				(int) ub___1st,
				(int) ub___2nd,
				si___Language + 1,
				siLine);
			goto errorExit;
			}
*/
		//

		if (ub___Dst == 0)
			{
			printf(
				"Untranslatable chr 0x%02X,0x%02X in language %d text at line %d.\n",
				(int) ub___1st,
				(int) ub___2nd,
				si___Language + 1,
				siLine);
			addbad2(ub___1st,ub___2nd);
			ub___Dst = aub__Xlate[0x00][0x20];
			}

		//

		*pub__Dst++ = ub___Dst;
		}

	// Terminate the string and update the pointers.

	*pub__Dst++ = 0;

	asi__StrIdx[si___Language][si___StrNum] = asi__StrNxt[si___Language];

	asi__StrNxt[si___Language] = pub__Dst - &acz__StrBuf[si___Language][0];

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	splitcpy ()
//
//	Usage
//		static void splitcpy (UB * dstptr, UB * srcptr, SL length)
//
//	Description
//		Do an even/odd byte copy.
//
//	Return Value
//		None.
// **************************************************************************

static	void splitcpy (UB * dstptr, UB * srcptr, SL length)

	{
	while (length--)
		{
		dstptr[0] = srcptr[0];
		dstptr += 1;
		srcptr += 2;
		}

	return;
	}



// **************************************************************************
//	DumpBIN ()
//
//	Usage
//		static ERRORCODE DumpBIN (char * filename,
//			void * fileaddr, size_t filesize)
//
//	Description
//		Write out a block of memory to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpBIN (void * fileaddr, size_t filesize)

	{
	// Local variables.

	FILE *			f;

	//

	strcpy(acz__FileOut, acz__FileDrv);
	strcat(acz__FileOut, acz__FileDir);
	strcat(acz__FileOut, acz__FileNam);
	strcat(acz__FileOut, acz__FileExt);

	//

	printf("Writing %s\n", acz__FileOut);

	f = NULL;

	if ((f = fopen(acz__FileOut, "wb")) == NULL)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"MAKETEXT error : Unable to open %s for writing. (Write protected ?)\n",
			acz__FileOut);
		goto errorExit;
		}

	if (fileaddr != NULL)
		{
		if (fwrite(fileaddr, 1, filesize, f) != filesize)
			{
			ErrorCode = ERROR_IO_WRITE;
			sprintf(ErrorMessage,
				"MAKETEXT error : Error writing to %s. (Disk full ?)\n",
				acz__FileOut);
			goto errorExit;
			}
		}

	if (fclose(f) != 0)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"MAKETEXT error : Unable to close %s after writing.\n",
			acz__FileOut);
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
//	DumpC ()
//
//	Usage
//		static ERRORCODE DumpC (char * filename,
//			void * fileaddr, size_t filesize)
//
//	Description
//		Write out a block of memory to disk.
//
//	Return Value
//		ERROR_NONE if OK, else failed.
// **************************************************************************

static	ERRORCODE DumpC (void * fileaddr, size_t filesize)

	{
	// Local variables.

	FILE *      f = NULL;
	UI          i;
	UI          j;

	UB *        pub__buf;
	UB *        pub__str;

	//

	strcpy(acz__FileOut, acz__FileDrv);
	strcat(acz__FileOut, acz__FileDir);
	strcat(acz__FileOut, acz__FileNam);
	strcat(acz__FileOut, acz__FileExt);

	//

	if (!czOutputLabel[0])
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"You MUST specify a label to output to the source file.\n"
			"(MAKETEXT, DumpC)\n");
		goto errorExit;
		}

	printf("Writing %s\n", acz__FileOut);

	if ((f = fopen(acz__FileOut, "wt")) == NULL)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"Unable to open %s for writing. (Write protected ?)\n"
			"(MAKETEXT, DumpC)\n",
			acz__FileOut);
		goto errorExit;
		}

	if (fprintf(f, "unsigned char %s [] =\n\t{\n", czOutputLabel) < 0)
		{
		goto errorWrite;
		}

	pub__buf = (UB *) fileaddr;

	while (filesize)
		{
		pub__str = (UB *) CommandString;

		if (filesize >= 16)
			{
			i = 16;
			filesize -= 16;
			}
		else
			{
			i = filesize;
			filesize  = 0;
			}

		while (i)
			{
			pub__str[0] = '0';
			pub__str[1] = 'x';
			j           = *pub__buf++;
			pub__str[2] = StringHex [(j << 1) + 0];
			pub__str[3] = StringHex [(j << 1) + 1];
			pub__str[4] = ',';
			pub__str += 5;
			i        -= 1;
			}

		if (filesize)
			{
			pub__str[0] = '\0';
			}
		else
			{
			pub__str[-1] = '\0';
			}

		if (fprintf(f, "\t%s\n", CommandString) < 0)
			{
			goto errorWrite;
			}
		}

	if (fprintf(f, "\t};\n") < 0)
		{
		goto errorWrite;
		}

	if (fclose(f) != 0)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"Unable to close %s after writing.\n"
			"(MAKETEXT, DumpC)\n",
			acz__FileOut);
		goto errorExit;
		}

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorWrite:

		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"Unable to write to %s. (Disk Full ?)\n"
			"(MAKETEXT, DumpC)\n",
			acz__FileOut);

	errorExit:

		if (f != NULL) fclose(f);

		return (ErrorCode);

	}



// **************************************************************************
// * LoadWholeFile ()                                                       *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   File name                                             *
// *         UB **    Ptr to variable holding file address                  *
// *         long *   Ptr to variable holding file size                     *
// *                                                                        *
// * Output  long     Bytes read, or -ve if an error                        *
// **************************************************************************

static	long                LoadWholeFile           (
								char *              pcz__Name,
								unsigned char **    ppbf_Addr,
								long *              psl__Size)

	{
	// Local Variables.

	FILE *              file;
	unsigned char *     addr;
	long                size;

	//

	if ((pcz__Name == NULL) || (ppbf_Addr == NULL) || (psl__Size == NULL))
		{
		return (-1);
		}

	if ((file = fopen(pcz__Name, "rb")) == NULL)
		{
		return (-1);
		}

	fseek(file, 0, SEEK_END);

	size = ftell(file);

	fseek(file, 0, SEEK_SET);

	if ((*psl__Size != 0) && (*psl__Size < size))
		{
		size = *psl__Size;
		}

	addr = *ppbf_Addr;

	if (addr == NULL)
		{
		addr = (unsigned char *) malloc(size);
		}

	if (addr == NULL)
		{
		size = -1;
		}
	else
		{
		if (fread(addr, 1, size, file) != (size_t) size)
			{
			size = -1;
			}
		}

	fclose(file);

	*psl__Size = size;

	if (*ppbf_Addr == NULL)
		{
		if (size < 0)
			{
			free(addr);
			}
		else
			{
			*ppbf_Addr = addr;
			}
		}

	// All done, return size or -ve if error.

	return (size);
	}



// **************************************************************************
// * SaveWholeFile ()                                                       *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   File name                                             *
// *         UB *     File address                                          *
// *         long     File size                                             *
// *                                                                        *
// * Output  long     Bytes written, or -ve if an error                     *
// **************************************************************************

static	long                SaveWholeFile           (
								char *              pcz__Name,
								unsigned char *     pbf__Addr,
								long                sl___Size)

	{
	// Local Variables.

	FILE *              file;

	//

	if ((pcz__Name == NULL) || (pbf__Addr == NULL) || (sl___Size < 0))
		{
		return (-1);
		}

	if ((file = fopen(pcz__Name, "wb")) == NULL)
		{
		return (-1);
		}

	if (sl___Size != 0)
		{
		if (fwrite(pbf__Addr, 1, sl___Size, file) != (size_t) sl___Size)
			{
			sl___Size = -1;
			}
		}

	fclose(file);

	// All done, return size or -ve if error.

	return (sl___Size);
	}



// **************************************************************************
// * GetFileLength ()                                                       *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  FILE *                                                         *
// *                                                                        *
// * Output  long                                                           *
// **************************************************************************

static	long                GetFileLength           (
								char *              FileName)

	{
	// Local Variables.

	long                CurrentPos;
	long                FileLength;

	FILE *              File;

	//

	if ((File = fopen(FileName, "rb")) == NULL)
		{
		return (-1);
		}

	CurrentPos = ftell(File);

	fseek(File, 0, SEEK_END);

	FileLength = ftell(File);

	fseek(File, CurrentPos, SEEK_SET);

	fclose(File);

	return (FileLength);
	}



// **************************************************************************
// * ErrorReset ()                                                          *
// **************************************************************************
// * Reset the error condition flags                                        *
// **************************************************************************
// * Inputs  -                                                              *
// *                                                                        *
// * Output  -                                                              *
// **************************************************************************

global	void                ErrorReset              (void)

	{
	ErrorCode = ERROR_NONE;

	ErrorMessage[0] = '\0';
	}



// **************************************************************************
// * ErrorQualify ()                                                        *
// **************************************************************************
// * If ErrorMessage is blank, then fill it with a generic message          *
// **************************************************************************
// * Inputs  -                                                              *
// *                                                                        *
// * Output  -                                                              *
// **************************************************************************

global	void                ErrorQualify            (void)

	{
	if (*ErrorMessage == '\0')

		{
		if (ErrorCode == ERROR_NONE)
			{
			}

		else if (ErrorCode == ERROR_DIAGNOSTIC)
			{
			sprintf(ErrorMessage,
				"Error : Error during diagnostic printout.\n");
			}

		else if (ErrorCode == ERROR_NO_MEMORY)
			{
			sprintf(ErrorMessage,
				"Error : Not enough memory to complete this operation.\n");
			}

		else if (ErrorCode == ERROR_NO_FILE)
			{
			sprintf(ErrorMessage,
				"Error : File not found.\n");
			}

		else if (ErrorCode == ERROR_IO_EOF)
			{
			sprintf(ErrorMessage,
				"Error : Unexpected end-of-file.\n");
			}

		else if (ErrorCode == ERROR_IO_READ)
			{
			sprintf(ErrorMessage,
				"Error : I/O read failure (file corrupted ?).\n");
			}

		else if (ErrorCode == ERROR_IO_WRITE)
			{
			sprintf(ErrorMessage,
				"Error : I/O write failure (disk full ?).\n");
			}

		else if (ErrorCode == ERROR_IO_SEEK)
			{
			sprintf(ErrorMessage,
				"Error : I/O seek failure (file corrupted ?).\n");
			}

		else if (ErrorCode == ERROR_PROGRAM)
			{
			sprintf(ErrorMessage,
				"Error : A program error has occurred.\n");
			}

		else
			{
			sprintf(ErrorMessage,
				"Error : Unknown error number.\n");
			}
		}
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF MAKETEXT.C
// **************************************************************************
// **************************************************************************
// **************************************************************************
