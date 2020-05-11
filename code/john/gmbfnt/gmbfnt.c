// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** GMBFNT.C                                                     PROGRAM **
// **                                                                      **
// ** Convert XsGmb's FNT file into John's GBF Gameboy format.             **
// **                                                                      **
// ** Last modified : 24 Mar 1999 by John Brandwood                        **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#define PC 1

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <time.h>

#include <ctype.h>

#include "io.h"
#include "elmer.h"
//#include "lfptypes.h"

#include "gmbfnt.h"

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

#define	VERSION_STR         "GmbFnt v1.10 (" __DATE__ ")"

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
	UW                  uw___idxOff;
	UB                  ub___idxNul;
	SB                  sb___idxNxt;
	SB                  sb___idxX;
	SB                  sb___idxY;
	UB                  ub___idxW;
	UB                  ub___idxH;
	} FNTIDX_T;

//
// GLOBAL VARIABLES
//

// Fatal error flag.
//
// Used to signal that the error returned by ErrorCode (see below) is fatal
// and that the program should terminate immediately.

global	bool                fl___FatalError     = FALSE;

global	ERRORCODE           ErrorCode           = ERROR_NONE;
global	char                ErrorMessage [256];

global	char                acz__SrcFile [_MAX_PATH + 4];
global	char                acz__DstFile [_MAX_PATH + 4];

global	char                acz__FileDrv [_MAX_DRIVE];
global	char                acz__FileDir [_MAX_DIR];
global	char                acz__FileNam [_MAX_FNAME];
global	char                acz__FileExt [_MAX_EXT];

global	bool                fl___OutputMask     = FALSE;

//
// STATIC VARIABLES
//

//
// STATIC FUNCTION PROTOTYPES
//

extern	void                ErrorReset              (void);
extern	void                ErrorQualify            (void);

//
//
//

extern	int                 ProcessOption           (
								char *              pcz__Option);

extern	int                 ProcessFileSpec         (
								char *              pcz__File);

extern	int                 ProcessFile             (
								char *              pcz__File);

extern	int                 ConvertFont             (
								FNTHDR_T *          pcl__FntHdr,
								FNTHDR_T *          pcl__GbfHdr);

//
//
//

static	FL                  GetValue                (
								SL *                l,
								char *              s);

global	int                 SaveSET                 (
								char *              pcz__File);

global	long                LoadWholeFile           (
								char *              pcz__Name,
								unsigned char **    ppbf_Addr,
								long *              psl__Size);

global	long                SaveWholeFile           (
								char *              pcz__Name,
								unsigned char *     pbf__Addr,
								long                sl___Size);

global	long                GetFileLength           (
								FILE *              file);



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	GLOBAL FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// * main ()                                                                *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  int      argument count                                        *
// *         char **  argument strings                                      *
// *                                                                        *
// * Output  int      Returns an exit code for the whole program.           *
// **************************************************************************

global	int          main                    (
								int                 argc,
								char **             argv)

	{

	// Local variables.

	int                 i;

	// Sign on.

	printf("\n%s by J.C.Brandwood\n\n", VERSION_STR);

	// Check the command line arguments.

	if (argc < 2)
		{
		ProcessOption("-?");
		goto exit;
		}

	// Read through and process the arguments.

	for (i = 1; i < argc; i++)
		{
		if ((*argv[i] == '-') || (*argv[i] == '/'))
			{
			if (ProcessOption(argv[i]) != ERROR_NONE) goto exit;
			}
		else
			{
			if (ProcessFileSpec(argv[i]) != ERROR_NONE) goto exit;
			}
		}

	// Print success message.

	printf("\nGmbFnt - Operation Completed OK !\n\n");

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

	// All done.

	return ((ErrorCode != ERROR_NONE));
	}



// **************************************************************************
// * ProcessOption ()                                                       *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   option                                                *
// *                                                                        *
// * Output  int      Returns an exit code for the whole program.           *
// **************************************************************************

global	int                 ProcessOption           (
								char *              pcz__Option)

	{
	// Local variables.

//	int                 i;
//	long                l;
//	char *              p;

	// Process option string.

	strupr(pcz__Option);

	switch(pcz__Option[1])
		{
		// Display help.

		case '?':
		case 'H':
			{
			printf
				(
				"Purpose    : Convert XsGmb's FNT file into John's GBF Gameboy format.\n"
				"\n"
				"Usage      : GmbFnt [<option>] <filename>\n"
				"\n"
				"<filename> : Long filenames and wildcards OK\n"
				"\n"
				"<option>   : Option........Description....................................\n"
				"\n"
				"             -h            Show this help message\n"
				"             -m            Output font with mask\n"
				"\n"
				);

			ErrorCode = ERROR_NONE;

			return (ERROR_DIAGNOSTIC);
			}

		// Select masked font.

		case 'M':
			{
			fl___OutputMask = TRUE;

			break;
			}

		// Select adpcm block size.

		/*
		case 'B':
			{
			if ((GetValue(&l, &pcz__Option[2]) == FALSE) || (l < 16) || (l > 1024))
				{
				sprintf(ErrorMessage,
					"Acr32 - Illegal ADPCM block size (must be 16 <= n <= 1024) !\n");
				return (ErrorCode = ERROR_ILLEGAL);
				}

			ui___BlockSize = l;

			break;
			}
		*/

		// Unknown option.

		default:
			{
			sprintf(ErrorMessage,
				"GmbFnt - Unknown option !\n");
			return (ErrorCode = ERROR_ILLEGAL);
			}
		}

	// All done.

	return (ERROR_NONE);
	}



// **************************************************************************
// * GetValue ()                                                            *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  -                                                              *
// *                                                                        *
// * Output  -                                                              *
// **************************************************************************

static	FL                  GetValue                (
								SL *                l,
								char *              s)

	{
	char * string;
	char * p;

	string = strtok(s, " \t\n");

	if (string == NULL) return (FALSE);

	*l = strtol(string, &p, 0);

	if (*p != '\0') return (FALSE);

	return (TRUE);
	}



// **************************************************************************
// * ProcessFileSpec ()                                                     *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   option                                                *
// *                                                                        *
// * Output  int      Returns an exit code for the whole program.           *
// **************************************************************************

global	int                 ProcessFileSpec         (
								char *              pcz__File)

	{
	// Local variables.


	ProcessFile(pcz__File);

#if 0

	int                 i;

    long                h____FileSpec;
    struct _finddata_t  cl___FileSpec;

	char                acz__All [_MAX_PATH];
	char                acz__Drv [_MAX_DRIVE];
	char                acz__Dir [_MAX_DIR];
	char                acz__Nam [_MAX_FNAME];
	char                acz__Ext [_MAX_EXT];

	// File name too long ?



	if (strlen(pcz__File) > _MAX_PATH)
		{
		sprintf(ErrorMessage,
			"GmbFnt - File name too long !\n");
		return (ErrorCode = ERROR_ILLEGAL);
		}

	// Copy the filespec to our buffer.

	#if 0
		if (_fullpath(acz__All, pcz__File, _MAX_PATH) == NULL)
			{
			sprintf(ErrorMessage,
				"GmbFnt - Illegal filename argument !\n");
			return (ErrorCode = ERROR_NO_FILE);
			}
	#else
		strcpy(acz__All, pcz__File);
	#endif

	// Split the filespec into its components.

	_splitpath(acz__All, acz__Drv, acz__Dir, acz__Nam, acz__Ext);

	// Now search the given path for files matching the filespec.

	if ((h____FileSpec = _findfirst(acz__All, &cl___FileSpec)) == -1L)
		{
		sprintf(ErrorMessage,
			"GmbFnt - File not found !\n");
		return (ErrorCode = ERROR_NO_FILE);
		}
	else
		{
		do	{
			// Have we found a directory or a file ?

			if ((cl___FileSpec.attrib & (_A_SUBDIR)) != 0)
				{
				// Process subdirectory.

				}
			else
			if ((cl___FileSpec.attrib & (_A_HIDDEN | _A_SYSTEM)) == 0)
				{
				// Process normal file.

				strcpy(acz__All, acz__Drv);
				strcat(acz__All, acz__Dir);
				strcat(acz__All, cl___FileSpec.name);

				// Process the file.

				if ((i = ProcessFile(acz__All)) != ERROR_NONE)
					{
					_findclose(h____FileSpec);

					return (i);
					}
				}

			} while (_findnext(h____FileSpec, &cl___FileSpec) == 0);

		_findclose(h____FileSpec);
		}

	// All done, return success.
#endif

	return (ERROR_NONE);
	}



// **************************************************************************
// * ProcessFile ()                                                         *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   option                                                *
// *                                                                        *
// * Output  int      Returns an exit code for the whole program.           *
// **************************************************************************

global	int                 ProcessFile             (
								char *              pcz__File)

	{
	// Local variables.

	unsigned char *     pub__FntFile;
	long                sl___FntFile;

	unsigned char *     pub__GbfFile;
	long                sl___GbfFile;

	//

	ErrorCode = 0;

	pub__FntFile = NULL;
	sl___FntFile = 0;

	pub__GbfFile = NULL;
	sl___GbfFile = 0;

	// Split the filename into its components.

	_splitpath(pcz__File, acz__FileDrv, acz__FileDir, acz__FileNam, acz__FileExt);

	// Load the FNT file.

	strcpy(acz__SrcFile, acz__FileDrv);
	strcat(acz__SrcFile, acz__FileDir);
	strcat(acz__SrcFile, acz__FileNam);
	strcat(acz__SrcFile, acz__FileExt);

	printf("Load \"%s\"\n", acz__SrcFile);

	if (LoadWholeFile(acz__SrcFile, &pub__FntFile, &sl___FntFile) < 0)
		{
		sprintf(ErrorMessage,
			"GmbFnt - Unable to read input file \"%s\" !\n",
			acz__SrcFile);
		ErrorCode = ERROR_NO_FILE;
		goto errorExit;
		}

	// Allocate space for the GBF file.

	pub__GbfFile = (unsigned char *) malloc((sl___FntFile * 3));

	if (pub__GbfFile == NULL)
		{
		sprintf(ErrorMessage,
			"GmbFnt - Unable to allocate workspace !\n");
		ErrorCode = ERROR_NO_MEMORY;
		goto errorExit;
		}

	// Convert the font from a FNT to a GBF.

	sl___GbfFile = ConvertFont((FNTHDR_T *) pub__FntFile, (FNTHDR_T *) pub__GbfFile);

	if (sl___GbfFile < 0)
		{
		sprintf(ErrorMessage,
			"GmbFnt - Unable to convert font \"%s\" !\n",
			acz__SrcFile);
		ErrorCode = ERROR_ILLEGAL;
		goto errorExit;
		}

	// Save the GBF file.

	strcpy(acz__DstFile, acz__FileDrv);
	strcat(acz__DstFile, acz__FileDir);
	strcat(acz__DstFile, acz__FileNam);
	strcat(acz__DstFile, ".gbf");

	printf("Save \"%s\"\n", acz__DstFile);

	if (SaveWholeFile(acz__DstFile, pub__GbfFile, sl___GbfFile) < 0)
		{
		sprintf(ErrorMessage,
			"GmbFnt - Unable to write output file \"%s\" !\n",
			acz__DstFile);
		ErrorCode = ERROR_NO_FILE;
		goto errorExit;
		}

	// Free up resources and return error code.

	ErrorCode = 0;

	errorExit:

		if (pub__FntFile != NULL) free(pub__FntFile);
		if (pub__GbfFile != NULL) free(pub__GbfFile);

		return (ErrorCode);
	}



// **************************************************************************
// * ConvertFont ()                                                         *
// **************************************************************************
// *                                                                        *
// **************************************************************************
// * Inputs  char *   option                                                *
// *                                                                        *
// * Output  int      Returns an exit code for the whole program.           *
// **************************************************************************

global	int                 ConvertFont             (
								FNTHDR_T *          pcl__FntHdr,
								FNTHDR_T *          pcl__GbfHdr)

	{
	// Local Variables.

	FNTIDX_T *          pcl__FntIdx;
	FNTIDX_T *          pcl__GbfIdx;

	UB *                pub__FntGfx;
	UB *                pub__GbfGfx;

	int                 i;
	int                 j;
	int                 k;
	int                 l;
	int                 m;

	int                 si___ChrW;
	int                 si___ChrH;

	UB *                pub__Col;
	UB *                pub__Row;
	UB *                pub__Pxl;

	UB                  ub___lo;
	UB                  ub___hi;
	UB                  ub___mk;
	UB                  ub___bm;

	//

	ErrorCode = 0;

	// Locate FNT index table.

	pcl__FntIdx = (FNTIDX_T *) (pcl__FntHdr + 1);
	pcl__GbfIdx = (FNTIDX_T *) (pcl__GbfHdr + 1);

	// Copy header and index info from FNT to GBF.

	j = sizeof(FNTHDR_T) + pcl__FntIdx->uw___idxOff;

	memcpy(pcl__GbfHdr, pcl__FntHdr, j);

	// Save offset to kerning data.

	i = 0;

	if (pcl__GbfHdr->ub___fntKrnN != 0)
		{
		i = sizeof(FNTHDR_T) + (sizeof(FNTIDX_T) * pcl__GbfHdr->ub___fntChrN);
		}

	pcl__GbfHdr->ud___fntNull = i;

	// Calc ptr to GBF graphics.

	pub__GbfGfx = ((UB *) pcl__GbfHdr) + sizeof(FNTHDR_T) + pcl__GbfIdx->uw___idxOff;

	// Now convert each individual character glyph.

	i = pcl__GbfHdr->ub___fntChrN;

	while (i--)

		{
		// Update GBF index.

		pcl__GbfIdx->uw___idxOff = pub__GbfGfx - ((UB *) pcl__GbfIdx);

		// Update GBF delta.

		pcl__GbfIdx->sb___idxNxt += pcl__GbfHdr->sb___fntXSpc;

		// Locate FNT data.

		pub__FntGfx = ((UB *) pcl__FntIdx) + pcl__FntIdx->uw___idxOff;

		// Locate this glyph's width and height.

		si___ChrW = pcl__FntIdx->ub___idxW;
		si___ChrH = pcl__FntIdx->ub___idxH;

		// Grab a number of 8-pixel strips.

		pub__Col = pub__FntGfx;

		j = si___ChrW;

		while (j)

			{
			// Calc the width (1-8) of this strip.

			k = j;

			if (k > 8) k = 8;

			j = j - k;

			// Make up an 8 pixel wide column.

			pub__Row = pub__Col;

			l = si___ChrH;

			while (l--)

				{
				// Make up an 8 pixel wide byte.

				pub__Pxl = pub__Row;

				ub___lo = 0x00;
				ub___hi = 0x00;
				ub___mk = 0x00;
				ub___bm = 0x80;

				m = k;

				while (m--)
					{
					if (*pub__Pxl != 0) ub___mk |= ub___bm;
					if (*pub__Pxl  & 1) ub___lo |= ub___bm;
					if (*pub__Pxl  & 2) ub___hi |= ub___bm;
					pub__Pxl += 1;
					ub___bm >>= 1;
					}

				if (fl___OutputMask)
					{
					*pub__GbfGfx++ = ub___mk;
					}

				*pub__GbfGfx++ = ub___lo;
				*pub__GbfGfx++ = ub___hi;

				pub__Row = pub__Row + si___ChrW;
				}

			// Next strip.

			pub__Col += k;
			}

		// Move onto next glyph.

		pcl__FntIdx += 1;
		pcl__GbfIdx += 1;
		}

	// Return with size of new GBF data.

	ErrorCode = pub__GbfGfx - ((UB *) pcl__GbfHdr);

	// Free up resources and return error code.

//	errorExit:

		return (ErrorCode);
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	STATIC FUNCTIONS
// **************************************************************************
// **************************************************************************
// **************************************************************************



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

global	long                LoadWholeFile           (
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

	size = GetFileLength(file);

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

global	long                SaveWholeFile           (
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

global	long                GetFileLength           (
								FILE *              file)

	{
	// Local Variables.

	long                CurrentPos;
	long                FileLength;

	//

	CurrentPos = ftell(file);

	fseek(file, 0, SEEK_END);

	FileLength = ftell(file);

	fseek(file, CurrentPos, SEEK_SET);

	return (FileLength);
	}



// **************************************************************************
// **************************************************************************
// **************************************************************************
// **************************************************************************



// **************************************************************************
// **************************************************************************
// **************************************************************************
//	END OF GMBFNT.C
// **************************************************************************
// **************************************************************************
// **************************************************************************