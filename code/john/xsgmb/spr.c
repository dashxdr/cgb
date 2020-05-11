// **************************************************************************
// **************************************************************************
// **************************************************************************
// **                                                                      **
// ** SPR.C                                                         MODULE **
// **                                                                      **
// ** Simple interface for reading data objects (see DATA.H) from a file   **
// ** in Promotion's SPR Format.                                           **
// **                                                                      **
// ** Last modified : 990219 by David Ashley                               **
// **                                                                      **
// **************************************************************************
// **************************************************************************
// **************************************************************************

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	"io.h"
#include	<assert.h>

#include	"elmer.h"
#include	"data.h"
#include	"spr.h"

struct sprcontext
{
	FILE *infile;
	UI wanted;
	UI totalframes;
	UI width,height;
	UI framesread;
};


FILETYPE_T SprIdentify(FILE *infile)
{
int len;
unsigned char header[9];
int val;

	fseek(infile,0L,SEEK_SET);
	len=fread(header,1,9,infile);
//printf("read %d bytes\n",len);
	fseek(infile,0L,SEEK_SET);
	if(len==9 && !memcmp(header,"SPR",3)) val=FILE_SPR;
	else val=FILE_UNKNOWN;
//printf("SprIdentify returning %d\n",val);
	return val;
}

ERRORCODE SprInitRead(void **contextptr,FILE *infile,DATATYPE_T wanted)
{
struct sprcontext *context;
unsigned char header[6];
int len;

	context=*contextptr=malloc(sizeof(struct sprcontext));
	if(!context) return ErrorCode=ERROR_NO_MEMORY;
	context->infile=infile;
	context->wanted=wanted;
	if(!(wanted&DATA_BITMAP)) return ERROR_NONE;
	fseek(infile,3L,SEEK_SET);
	len=fread(header,1,6,infile);
	context->totalframes=*header | (header[1]<<8);
	context->width=header[2] | (header[3]<<8);
	context->height=header[4] | (header[5]<<8);
	context->framesread=0;
	return ERROR_NONE;
}
FILE *SprQuitRead(void **contextptr)
{
struct sprcontext *context=*contextptr;
FILE *infile;
	infile=context->infile;
	free(context);
	return infile;
}

DATABLOCK_T *SprReadData(void **contextptr)
{
struct sprcontext *context=*contextptr;
DATABITMAP_T *bm;
FILE *infile;
RGBQUAD_T *color;
int i,j,k,len;
unsigned char *p;


	if(!context) return 0;
	if(context->framesread==context->totalframes) return 0;
	bm=(void *)DataBitmapAlloc(context->width,context->height,8,NO);
	if(!bm) return 0;
	++context->framesread;
	infile=context->infile;
	fseek(infile,2L,SEEK_CUR);// skip frame delay value in msec
	color=bm->acl__bmC;
	i=256;
	while(i--)
	{
		unsigned char c3[3];
		len=fread(c3,1,3,infile);
		if(len!=3)
		{
			free(bm);
			return 0;
		}
		color->ub___rgbR=*c3;
		color->ub___rgbG=c3[1];
		color->ub___rgbB=c3[2];
		color->ub___rgbA=255;
		++color;
	}
	i=context->width;
	j=context->height;
	k=bm->si___bmLineSize;
	p=bm->pub__bmBitmap;
	while(j--)
	{
		len=fread(p,1,i,infile);
		if(len!=i)
		{
			free(bm);
			return 0;
		}
		p+=k;
	}
	return (DATABLOCK_T *)bm;
}