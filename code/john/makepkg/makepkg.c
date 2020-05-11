// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** MAKEPKG.C                                                    PROGRAM **
// **                                                                      **
// ** Purpose       :                                                      **
// **                                                                      **
// ** To concatenate a number of files into a single file.                 **
// **                                                                      **
// ** Last modified : 14 May 1999 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <time.h>

#include <ctype.h>

#include "lfptypes.h"
#include "makepkg.h"


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

typedef int ERRORCODE;

#define ERROR_NONE 0
#define ERROR_DIAGNOSTIC 1
#define ERROR_NO_MEMORY 2
#define ERROR_NO_FILE 3
#define ERROR_IO_READ 4
#define ERROR_IO_WRITE 5
#define ERROR_PROGRAM 6
#define ERROR_ILLEGAL 7
#define ERROR_IO_EOF 8
#define ERROR_IO_SEEK 9
#define _MAX_PATH 256
#define _MAX_DRIVE 256
#define _MAX_DIR 256
#define _MAX_FNAME 256
#define _MAX_EXT 256



global	int                 si___Argc;
global	char **             ppcz_Argv;

global	ERRORCODE           ErrorCode           = ERROR_NONE;
global	char                ErrorMessage [256];

global	int                 CommandArg            = 1;
global	int                 CommandLine           = 0;
global	FILE *              CommandFile           = NULL;
global	char *              CommandString         = NULL;

global	char                CommandBuffer         [516];

#define MAXCOMMANDSIZE      512

//
//
//

#define HELPMESSAGE0        0
#define HELPMESSAGE1        1
#define OUTPUTORDER         2
#define OUTPUTHEADER        3
#define OUTPUTFORMAT        4
#define OUTPUTLABEL         5
#define SPLIT               6
#define OFFSET              7
#define LENGTH              8
#define DROPFIRST           9
#define KEEPFIRST           10
#define DROPLAST            11
#define KEEPLAST            12
#define RECTANGLE           13

#define NUMBER_OF_OPTIONS   14

global	char *              OptionList[] =
			{
			"?",
			"H",
			"OUTPUTORDER",
			"OUTPUTHEADER",
			"OUTPUTFORMAT",
			"OUTPUTLABEL",
			"SPLIT",
			"OFFSET",
			"LENGTH",
			"DROPFIRST",
			"KEEPFIRST",
			"DROPLAST",
			"KEEPLAST",
			"RECTANGLE"
			};

//
//
//

global	char *              StringYes           = "YES";
global	char *              StringNo            = "NO";

#define NO  FALSE
#define YES TRUE

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

global	SL                  slBoxX              =  0;
global	SL                  slBoxY              =  0;
global	SL                  slBoxW              =  0;
global	SL                  slBoxH              =  0;
global	SL                  slMapW              =  0;

//
//
//

global	FILE *              ResultsFile;
global	char                ResultsName[128];
global	char *              ResultsExt;

global	char                acz__FileOut [_MAX_PATH + 4];

global	char                acz__FileDrv [_MAX_DRIVE];
global	char                acz__FileDir [_MAX_DIR];
global	char                acz__FileNam [_MAX_FNAME];
global	char                acz__FileExt [_MAX_EXT + 8];

//
//
//

typedef struct FileListS
	{
	struct FileListS *      pcl__flLink;
	char *                  cz___flFileName;
	SL                      sl___flFileOffset;
	SL                      sl___flFileLength;
	SL                      sl___flFileBoxX;
	SL                      sl___flFileBoxY;
	SL                      sl___flFileBoxW;
	SL                      sl___flFileBoxH;
	SL                      sl___flFileMapW;
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
	SI                      sl___fiFileOffset;
	SI                      sl___fiFileLength;
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

	puts("\nMakePKG v2.10 " __DATE__ " by J.C.Brandwood\n");

	// Initialize global data.

	czOutputLabel[0] = '\0';

	pcl__gFiles    = NULL;
	pcl__gFilesEnd = (FileListT *) (&pcl__gFiles);

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

	printf("\nMakePKG process completed without error.\n");

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

static	ERRORCODE	ProcessToken (char * tok)

	{
	// Local variables.

	UI				i;
	char dummytoken[128],*string;

	strcpy(dummytoken,tok);
	string=dummytoken;

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
				"MakePKG error : Unable to open nested command file %s at line %d.\n",
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
				"MakePKG error : Unable to open command file %s.\n",
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
					"Usage : MakePKG [@<commandfile>] [<option>] [<datafile>]\n"
					"\n"
					"This utility packs a list of files into a single output file.\n"
					"\n"
					"The list of files, together with any options for each file are\n"
					"given in a command file or specified on the command line.\n"
					"\n"
					"The command file is an ASCII text file consisting of a list of\n"
					"the files to package together, with each filename on a seperate\n"
					"line. Blank lines are ignored, as are lines that start with a\n"
					"semicolon.\n"
					"\n"
					"The filename can be preceeded by a list of options that uniquely\n"
					"specify which subsection of a file to include. The following\n"
					"options are available ...\n"
					"\n"
					"-Offset       n\n"
					"-Length       n\n"
					"-DropFirst    n\n"
					"-KeepFirst    n\n"
					"-DropLast     n\n"
					"-KeepLast     n\n"
					"-Rectangle    boxx boxy boxw boxh mapw\n"
					"\n"
					"The output is controlled by the following options ...\n"
					"\n"
					"-OutputFormat BIN  | C\n"
					"-OutputHeader YES  | NO\n"
					"-OutputOrder  HILO | LOHI\n"
					"-OutputLabel  x\n"
					"-Split\n"
					);
				break;
				}

			// New uiOutputOrder ?

			case OUTPUTORDER:
				{
				if (ParseOutputOrder(&uiOutputOrder) != ERROR_NONE) goto errorExit;
				break;
				}

			// New flOutputHeader ?

			case OUTPUTHEADER:
				{
				if (ParseFlag(&flOutputHeader) != ERROR_NONE) goto errorExit;
				break;
				}

			// New uiOutputFormat ?

			case OUTPUTFORMAT:
				{
				if (ParseOutputFormat(&uiOutputFormat) != ERROR_NONE) goto errorExit;
				break;
				}

			// New uiOutputFormat ?

			case OUTPUTLABEL:
				{
				if (ParseLabel(czOutputLabel, MAXLABELSIZE, "OutputLabel")
					!= ERROR_NONE) goto errorExit;
				break;
				}

			// New OFFSET value ?

			case OFFSET:
				{
				if (ParseValue(&slDropFirst, "OFFSET") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New LENGTH value ?

			case LENGTH:
				{
				if (ParseValue(&slWantLength, "LENGTH") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New DROPFIRST value ?

			case DROPFIRST:
				{
				if (ParseValue(&slDropFirst, "DROPFIRST") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New KEEPFIRST value ?

			case KEEPFIRST:
				{
				if (ParseValue(&slKeepFirst, "KEEPFIRST") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New DROPLAST value ?

			case DROPLAST:
				{
				if (ParseValue(&slDropLast, "DROPLAST") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New KEEPLAST value ?

			case KEEPLAST:
				{
				if (ParseValue(&slKeepLast, "KEEPLAST") != ERROR_NONE)
					{
					goto errorExit;
					}
				break;
				}

			// New SPLIT value ?

			case SPLIT:
				{
				flSplitOutput = YES;
				break;
				}

			// New RECTANGLE value ?

			case RECTANGLE:
				{
				if (ParseValue(&slBoxX, "RECTANGLE") != ERROR_NONE) { goto errorExit; }
				if (ParseValue(&slBoxY, "RECTANGLE") != ERROR_NONE) { goto errorExit; }
				if (ParseValue(&slBoxW, "RECTANGLE") != ERROR_NONE) { goto errorExit; }
				if (ParseValue(&slBoxH, "RECTANGLE") != ERROR_NONE) { goto errorExit; }
				if (ParseValue(&slMapW, "RECTANGLE") != ERROR_NONE) { goto errorExit; }
				break;
				}

			// Unidentified option.

			default:
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unidentified option at line %d.\n"
					"(MakePKG, ProcessLine)\n",
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
			"MakePKG error : Flag value missing after option at line %d.\n",
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
			"MakePKG error : Illegal flag value %s after option at line %d.\n",
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
			"(MakePKG, SetValue)\n",
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
			"(MakePKG, SetValue)\n",
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
			"(MakePKG, ParseLabel)\n",
			option,
			(UI) CommandLine);
		goto errorExit;
		}

	if (strlen(string) >= uispace)
		{
		ErrorCode = ERROR_ILLEGAL;
		sprintf(ErrorMessage,
			"Label too long after %s option at line %d.\n"
			"(MakePKG, ParseLabel)\n",
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
			"MakePKG error : OutputOrder value missing at line %d.\n",
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
			"MakePKG error : Illegal OutputOrder value %s at line %d.\n",
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
			"MakePKG error : OutputFormat value missing at line %d.\n",
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
			"MakePKG error : Illegal OutputFormat value %s at line %d.\n",
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

	// Local variables.

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
			"(MakePKG, LinkFile)\n");
		goto errorExit;
		}

	// Create a copy of the filename, and put it in the FileList block.

	pcl__file->cz___flFileName = strdup(cz___filename);

	if (pcl__file->cz___flFileName == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Out of memory.\n"
			"(MakePKG, LinkFile)\n");
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
			"(MakePKG, LinkFile)\n",
			pcl__file->cz___flFileName);
		goto errorFree2;
		}

	// Work out how much of the file we want.

	if (slKeepFirst >= 0)
		{
		if (slKeepFirst <= sl___filelength)
			{
			sl___filelength = slKeepFirst;
			}
		}

	if (slKeepLast >= 0)
		{
		if (slKeepLast <= sl___filelength)
			{
			sl___fileoffset = sl___filelength - slKeepLast;
			sl___filelength = slKeepLast;
			}
		}

	if (slDropFirst >= 0)
		{
		if (slDropFirst <= sl___filelength)
			{
			sl___fileoffset += slDropFirst;
			sl___filelength -= slDropFirst;
			}
		}

	if (slDropLast >= 0)
		{
		if (slDropLast <= sl___filelength)
			{
			sl___filelength -= slDropLast;
			}
		}

	if (slWantLength >= 0)
		{
		if (slWantLength <= sl___filelength)
			{
			sl___filelength = slWantLength;
			}
		}

	if ((slBoxW > 0) && (slBoxH > 0))
		{
		if (sl___filelength > (slBoxW * slBoxH * sizeof(UW)))
			{
			sl___filelength = (slBoxW * slBoxH * sizeof(UW));
			}
		}

	pcl__file->sl___flFileOffset = sl___fileoffset;
	pcl__file->sl___flFileLength = sl___filelength;

	pcl__file->sl___flFileBoxX = slBoxX;
	pcl__file->sl___flFileBoxY = slBoxY;
	pcl__file->sl___flFileBoxW = slBoxW;
	pcl__file->sl___flFileBoxH = slBoxH;
	pcl__file->sl___flFileMapW = slMapW;

	// Print out details of this file.

	cz___filename = strrchr(pcl__file->cz___flFileName, '\\');

	if (cz___filename == NULL)
		{
		cz___filename = pcl__file->cz___flFileName;
		}
	else
		{
		cz___filename += 1;
		}

	if ((slBoxW == 0) || (slBoxH == 0))
		{
		printf(
			"%-20s  offset 0x%08lX  length 0x%08lX\n",
			cz___filename,
			pcl__file->sl___flFileOffset,
			pcl__file->sl___flFileLength
			);
		}
	else
		{
		printf(
			"%20s  offset 0x%08lX  box 0x%02lX 0x%02lX 0x%02lX 0x%02lX 0x%04lX \n",
			cz___filename,
			pcl__file->sl___flFileOffset,
			pcl__file->sl___flFileBoxX,
			pcl__file->sl___flFileBoxY,
			pcl__file->sl___flFileBoxW,
			pcl__file->sl___flFileBoxH,
			pcl__file->sl___flFileMapW
			);
		}

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
	FileInfoT *         pcl__packbuffer;
	SL                  sl___packlength;

	FileListT *         pcl__thisfile;
	FileInfoT *         pcl__fileptr;
	UB *                pub__fileptr;
	SL                  sl___filelen;
	SL                  sl___temp;

	UB *                pub__split;
	SL                  sl___split;

	// Locate end of czOutputLabel.

	czOutputLabelEnd = czOutputLabel + strlen(czOutputLabel);

	// Calculate the size of the package.

	sl___packlength = (uiFileCount + 1) * sizeof(FileInfoT);

	pcl__thisfile = pcl__filelist;

	while (pcl__thisfile != NULL)
		{
		sl___packlength += (pcl__thisfile->sl___flFileLength + 3) & (~3ul);
		pcl__thisfile    = (pcl__thisfile->pcl__flLink);
		}

	// Allocate a RAM buffer to hold the entire package.
	// Tacky but quick.

	pcl__packbuffer = malloc(sl___packlength);

	if (pcl__packbuffer == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Can't allocate enough room for the entire package.\n"
			"(MakePKG, CreatePackage)\n");
		goto errorExit;
		}

	pub__split = NULL;

	// Now fill out the overall package information.

	pub__fileptr = (UB *)       pcl__packbuffer
		+ ((uiFileCount + 1) * sizeof(FileInfoT));
	pcl__fileptr = (FileInfoT *) pcl__packbuffer;

	sl___temp = uiFileCount;
	#ifdef	BYTE_ORDER_LO_HI
		if (uiOutputOrder == ORDERHILO)
	#endif
	#ifdef	BYTE_ORDER_HI_LO
		if (uiOutputOrder == ORDERLOHI)
	#endif
		{
		sl___temp = SwapD32(sl___temp);
		}

	pcl__fileptr->sl___fiFileOffset = MakeID4('P','K','G','0');
	pcl__fileptr->sl___fiFileLength = sl___temp;
	pcl__fileptr += 1;

	// Now read in each file into the buffer.

	while (pcl__filelist != NULL)

		{

		// Fill out the file information.

		sl___temp = pub__fileptr - ((UB *) pcl__packbuffer);
		#ifdef	BYTE_ORDER_LO_HI
			if (uiOutputOrder == ORDERHILO)
		#endif
		#ifdef	BYTE_ORDER_HI_LO
			if (uiOutputOrder == ORDERLOHI)
		#endif
			{
			sl___temp = SwapD32(sl___temp);
			}
		pcl__fileptr->sl___fiFileOffset = sl___temp;

		sl___temp = pcl__filelist->sl___flFileLength;
		#ifdef	BYTE_ORDER_LO_HI
			if (uiOutputOrder == ORDERHILO)
		#endif
		#ifdef	BYTE_ORDER_HI_LO
			if (uiOutputOrder == ORDERLOHI)
		#endif
			{
			sl___temp = SwapD32(sl___temp);
			}
		pcl__fileptr->sl___fiFileLength = sl___temp;

		// Read the file into the buffer.

		if ((pcl__filelist->sl___flFileBoxW == 0) || (pcl__filelist->sl___flFileBoxH == 0))

			{

			// Read the file into the buffer.

			if ((f = fopen(pcl__filelist->cz___flFileName, "rb")) == NULL)
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unable to open %s for reading.\n"
					"(MakePKG, CreatePackage)\n",
					pcl__filelist->cz___flFileName);
				goto errorFree;
				}

			if (fseek(f, pcl__filelist->sl___flFileOffset, SEEK_SET) != 0)
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unable to seek to position in %s.\n"
					"(MakePKG, CreatePackage)\n",
					pcl__filelist->cz___flFileName);
				goto errorClose;
				}

			if (fread(pub__fileptr, 1, pcl__filelist->sl___flFileLength, f) !=
				(size_t) pcl__filelist->sl___flFileLength)
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unable to read at position in %s.\n"
					"(MakePKG, CreatePackage)\n",
					pcl__filelist->cz___flFileName);
				goto errorClose;
				}

			fclose(f);

			}

		else

			{

			// Very local variables.

			UW *                puw__map;
			UW *                puw__src;
			UW *                puw__dst;
			SL					i;
			SL					j;

			// Read the file into a buffer.

			pub__split = NULL;
			sl___split = 0;

			if (LoadWholeFile(pcl__filelist->cz___flFileName, &pub__split, &sl___split) < 0)
				{
				ErrorCode = ERROR_PROGRAM;
				sprintf(ErrorMessage,
					"Unable to read whole file %s.\n"
					"(MakePKG, CreatePackage)\n",
					pcl__filelist->cz___flFileName);
				goto errorClose;
				}

			// Locate the top-left of the map data.

			puw__map = (UW *) (pub__split + pcl__filelist->sl___flFileOffset);

			puw__map += pcl__filelist->sl___flFileBoxX;
			puw__map += pcl__filelist->sl___flFileBoxY * pcl__filelist->sl___flFileMapW;

			// Copy the map rectangle to the destination buffer.

			puw__dst = (UW *) pub__fileptr;

			i = pcl__filelist->sl___flFileBoxH;

			while (i--)
				{
				puw__src = puw__map;
				puw__map = puw__map + pcl__filelist->sl___flFileMapW;

				j = pcl__filelist->sl___flFileBoxW;

				while (j--)
					{
					*puw__dst++ = *puw__src++;
					}
				}

			// Free up the file.

			free(pub__split); pub__split = NULL;

			}

		// Update buffer pointer, and pad out to the next 32 bit boundary.

		pub__fileptr += pcl__filelist->sl___flFileLength;

		while (((UL) pub__fileptr) & 3)
			{
			*pub__fileptr++ = 0;
			}

		// Now repeat for the next file.

		pcl__fileptr += 1;
		pcl__filelist = pcl__filelist->pcl__flLink;
		}

	// Finally, write out the file.

	if (flSplitOutput)
		{
		pub__split = malloc((sl___packlength + 1) / 2);

		if (pub__split == NULL)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Can't allocate enough room for the split package.\n"
				"(MakePKG, CreatePackage)\n");
			goto errorExit;
			}
		}

	pcl__fileptr = pcl__packbuffer;
	sl___filelen = sl___packlength;

	if (flOutputHeader == NO)
		{
		pcl__fileptr += (uiFileCount + 1);
		sl___filelen -= (uiFileCount + 1) * sizeof(FileInfoT);
		}

	switch (uiOutputFormat)
		{
		case OUTPUTBIN:
			{
			if (!flSplitOutput)
				{
				strcpy(acz__FileExt, ".pkg");

				if (DumpBIN(pcl__fileptr, sl___filelen) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			else
				{
				sl___split = (sl___filelen + 1) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 0, sl___split);

				strcpy(acz__FileExt, ".lo");

				if (DumpBIN(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}

				sl___split = (sl___filelen + 0) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 1, sl___split);

				strcpy(acz__FileExt, ".hi");

				if (DumpBIN(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			break;
			}
		case OUTPUTC:
			{
			if (!flSplitOutput)
				{
				strcpy(acz__FileExt, ".c");

				if (DumpC(pcl__fileptr, sl___filelen) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			else
				{
				sl___split = (sl___filelen + 1) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 0, sl___split);

				strcpy(acz__FileExt, "LO.C"); strcpy(czOutputLabelEnd, "Lo");

				if (DumpC(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}

				sl___split = (sl___filelen + 0) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 1, sl___split);

				strcpy(acz__FileExt, "HI.C"); strcpy(czOutputLabelEnd, "Hi");

				if (DumpC(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			break;
			}
		}

	// Free up the buffer.

	if (pub__split != NULL) free(pub__split);

	free(pcl__packbuffer);

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorClose:

		fclose(f);

	errorFree:

		if (pub__split != NULL) free(pub__split);

		free(pcl__packbuffer);

	errorExit:

		return (ErrorCode);

	}



// **************************************************************************
//	CreateBanks ()
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

static	ERRORCODE CreateBanks (FileListT * pcl__filelist)

	{
	// Local variables.

	FILE *              f;
	FileInfoT *         pcl__packbuffer;
	SL                  sl___packlength;

	FileListT *         pcl__thisfile;
	FileInfoT *         pcl__fileptr;
	UB *                pub__fileptr;
	SL                  sl___filelen;
	SL                  sl___temp;

	UB *                pub__split;
	SL                  sl___split;

	// Locate end of czOutputLabel.

	czOutputLabelEnd = czOutputLabel + strlen(czOutputLabel);

	// Calculate the size of the package.

	sl___packlength = (uiFileCount + 1) * sizeof(FileInfoT);

	pcl__thisfile = pcl__filelist;

	while (pcl__thisfile != NULL)
		{
		sl___packlength += (pcl__thisfile->sl___flFileLength + 3) & (~3ul);
		pcl__thisfile    = (pcl__thisfile->pcl__flLink);
		}

	// Allocate a RAM buffer to hold the entire package.
	// Tacky but quick.

	pcl__packbuffer = malloc(sl___packlength);

	if (pcl__packbuffer == NULL)
		{
		ErrorCode = ERROR_PROGRAM;
		sprintf(ErrorMessage,
			"Can't allocate enough room for the entire package.\n"
			"(MakePKG, CreatePackage)\n");
		goto errorExit;
		}

	pub__split = NULL;

	if (flSplitOutput)
		{
		pub__split = malloc((sl___packlength + 1) / 2);

		if (pub__split == NULL)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Can't allocate enough room for the split package.\n"
				"(MakePKG, CreatePackage)\n");
			goto errorExit;
			}
		}

	// Now fill out the overall package information.

	pub__fileptr = (UB *)       pcl__packbuffer
		+ ((uiFileCount + 1) * sizeof(FileInfoT));
	pcl__fileptr = (FileInfoT *) pcl__packbuffer;

	sl___temp = uiFileCount;
	#ifdef	BYTE_ORDER_LO_HI
		if (uiOutputOrder == ORDERHILO)
	#endif
	#ifdef	BYTE_ORDER_HI_LO
		if (uiOutputOrder == ORDERLOHI)
	#endif
		{
		sl___temp = SwapD32(sl___temp);
		}

	pcl__fileptr->sl___fiFileOffset = MakeID4('P','K','G','0');
	pcl__fileptr->sl___fiFileLength = sl___temp;
	pcl__fileptr += 1;

	// Now read in each file into the buffer.

	while (pcl__filelist != NULL)

		{

		// Fill out the file information.

		sl___temp = pub__fileptr - ((UB *) pcl__packbuffer);
		#ifdef	BYTE_ORDER_LO_HI
			if (uiOutputOrder == ORDERHILO)
		#endif
		#ifdef	BYTE_ORDER_HI_LO
			if (uiOutputOrder == ORDERLOHI)
		#endif
			{
			sl___temp = SwapD32(sl___temp);
			}
		pcl__fileptr->sl___fiFileOffset = sl___temp;

		sl___temp = pcl__filelist->sl___flFileLength;
		#ifdef	BYTE_ORDER_LO_HI
			if (uiOutputOrder == ORDERHILO)
		#endif
		#ifdef	BYTE_ORDER_HI_LO
			if (uiOutputOrder == ORDERLOHI)
		#endif
			{
			sl___temp = SwapD32(sl___temp);
			}
		pcl__fileptr->sl___fiFileLength = sl___temp;

		// Read the file into the buffer.

		if ((f = fopen(pcl__filelist->cz___flFileName, "rb")) == NULL)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to open %s for reading.\n"
				"(MakePKG, CreatePackage)\n",
				pcl__filelist->cz___flFileName);
			goto errorFree;
			}

		if (fseek(f, pcl__filelist->sl___flFileOffset, SEEK_SET) != 0)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to seek to position in %s.\n"
				"(MakePKG, CreatePackage)\n",
				pcl__filelist->cz___flFileName);
			goto errorClose;
			}

		if (fread(pub__fileptr, 1, pcl__filelist->sl___flFileLength, f) !=
			(size_t) pcl__filelist->sl___flFileLength)
			{
			ErrorCode = ERROR_PROGRAM;
			sprintf(ErrorMessage,
				"Unable to read at position in %s.\n"
				"(MakePKG, CreatePackage)\n",
				pcl__filelist->cz___flFileName);
			goto errorClose;
			}

		fclose(f);

		// Update buffer pointer, and pad out to the next 32 bit boundary.

		pub__fileptr += pcl__filelist->sl___flFileLength;

		while (((UL) pub__fileptr) & 3)
			{
			*pub__fileptr++ = 0;
			}

		// Now repeat for the next file.

		pcl__fileptr += 1;
		pcl__filelist = pcl__filelist->pcl__flLink;
		}

	// Finally, write out the file.

	pcl__fileptr = pcl__packbuffer;
	sl___filelen = sl___packlength;

	if (flOutputHeader == NO)
		{
		pcl__fileptr += (uiFileCount + 1);
		sl___filelen -= (uiFileCount + 1) * sizeof(FileInfoT);
		}

	switch (uiOutputFormat)
		{
		case OUTPUTBIN:
			{
			if (!flSplitOutput)
				{
				strcpy(acz__FileExt, ".pkg");

				if (DumpBIN(pcl__fileptr, sl___filelen) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			else
				{
				sl___split = (sl___filelen + 1) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 0, sl___split);

				strcpy(acz__FileExt, ".lo");

				if (DumpBIN(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}

				sl___split = (sl___filelen + 0) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 1, sl___split);

				strcpy(acz__FileExt, ".hi");

				if (DumpBIN(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			break;
			}
		case OUTPUTC:
			{
			if (!flSplitOutput)
				{
				strcpy(acz__FileExt, ".c");

				if (DumpC(pcl__fileptr, sl___filelen) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			else
				{
				sl___split = (sl___filelen + 1) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 0, sl___split);

				strcpy(acz__FileExt, "lo.c"); strcpy(czOutputLabelEnd, "lo");

				if (DumpC(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}

				sl___split = (sl___filelen + 0) / 2;

				splitcpy(pub__split, ((UB *) pcl__fileptr) + 1, sl___split);

				strcpy(acz__FileExt, "hi.c"); strcpy(czOutputLabelEnd, "hi");

				if (DumpC(pub__split, sl___split) != ERROR_NONE)
					{
					goto errorFree;
					}
				}
			break;
			}
		}

	// Free up the buffer.

	if (pub__split != NULL) free(pub__split);

	free(pcl__packbuffer);

	// Return with success code.

	return (ERROR_NONE);

	// Error handlers (reached via the dreaded goto).

	errorClose:

		fclose(f);

	errorFree:

		if (pub__split != NULL) free(pub__split);

		free(pcl__packbuffer);

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
			"MakePKG error : Unable to open %s for writing. (Write protected ?)\n",
			acz__FileOut);
		goto errorExit;
		}

	if (fileaddr != NULL)
		{
		if (fwrite(fileaddr, 1, filesize, f) != filesize)
			{
			ErrorCode = ERROR_IO_WRITE;
			sprintf(ErrorMessage,
				"MakePKG error : Error writing to %s. (Disk full ?)\n",
				acz__FileOut);
			goto errorExit;
			}
		}

	if (fclose(f) != 0)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"MakePKG error : Unable to close %s after writing.\n",
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
			"(MakePKG, DumpC)\n");
		goto errorExit;
		}

	printf("Writing %s\n", acz__FileOut);

	if ((f = fopen(acz__FileOut, "wt")) == NULL)
		{
		ErrorCode = ERROR_IO_WRITE;
		sprintf(ErrorMessage,
			"Unable to open %s for writing. (Write protected ?)\n"
			"(MakePKG, DumpC)\n",
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
			"(MakePKG, DumpC)\n",
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
			"(MakePKG, DumpC)\n",
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
//	END OF MAKEPKG.C
// **************************************************************************
// **************************************************************************
// **************************************************************************
