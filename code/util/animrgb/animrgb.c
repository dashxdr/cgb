/*

	Reads a <name>.lst file (given as argument) and generates
	<name.pal> which is ASM source with data statements for the palettes
	<name.equ> which is ASM source for GLOBALS
*/



#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/types.h>
#include <ctype.h>
#include <unistd.h>
#include "elmer.h"
#include "data.h"
#include "iff.h"
#include "pcx.h"
#include "spr.h"

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define BLOCKSIZE 8000000L
#define BUFFERSIZE 65536
char *take;
char *buffer1,*buffer2,*buffer3;
char *palput,*equput;



int tailcomp(char *s1,char *s2)
{
char t1[256],*p,ch;

	p=t1;
	while((ch=tolower(*s1++)) && ch!=0x1a) *p++=ch;
	*p=0;
	if(strlen(s2)>strlen(t1)) return 1;
	return strcmp(t1+strlen(t1)-strlen(s2),s2);
}
void cutext(char *p) {
	int i=0;
	char ch;
	i=strlen(p);
	while(i>0)
	{
		ch=p[--i];
		if(ch=='.') {p[i]=0;break;}
		if(ch=='/' || ch=='\\' || ch==':')
			break;
	}
}

int _getline(char *p)
{
	int ch;
	char *p2;
	p2=p;
	while((ch=*take))
	{
		++take;
		if(ch=='\n') break;
		*p2++=ch;
	}
	*p2=0;
	return *p;
}

void fixname(char *dest,char *src)
{
char *p,ch;
	p=src+strlen(src);
	while(p>src)
	{
		ch=p[-1];
		if(ch=='/' || ch=='\\' || ch==':') break;
		--p;
	}
	while(*p && *p!='.')
		*dest++=toupper(*p++);
	*dest=0;
}


int convert(char *name)
{
FILE *              pfile;
ERRORCODE           (*pfinitread)(void **, FILE *, DATATYPE_T);
DATABLOCK_T *       (*pfreaddata)(void **);
FILE *              (*pfquitread)(void **);
DATABLOCK_T *       pdbh;
DATABITMAP_T *      pbmh;
void *pvoid;
int i,j,width,height,perrow;
unsigned char *p1,*p2;
int numpics;
int hist[256];
char namebuff[256];
char rgb[64];
int file;

	strcpy(namebuff,name);
	if(!tailcomp(namebuff,".map"))
	{
		cutext(namebuff);
		strcat(namebuff,".abm");
	}

	pfile=fopen(namebuff, "rb");
	if(!pfile)
	{
		return -1;
	}
	if (IffIdentify(pfile) == FILE_IFF)
	{
		pfinitread = IffInitRead;
		pfreaddata = IffReadData;
		pfquitread = IffQuitRead;
	} else
	if (PcxIdentify(pfile) == FILE_PCX)
	{
		pfinitread = PcxInitRead;
		pfreaddata = PcxReadData;
		pfquitread = PcxQuitRead;
	} else
	if (SprIdentify(pfile) == FILE_SPR)
	{
		pfinitread = SprInitRead;
		pfreaddata = SprReadData;
		pfquitread = SprQuitRead;
	} else return -2;


	if ((*pfinitread)(&pvoid, pfile, DATA_BITMAP) != ERROR_NONE)
		return -3;
	for(i=0;i<64;i++) hist[i]=0;
	while((pdbh= (*pfreaddata)(&pvoid)))
	{
		numpics++;
		pbmh=(DATABITMAP_T *)pdbh;
		perrow=pbmh->si___bmLineSize;
		width=pbmh->ui___bmW;
		height=pbmh->ui___bmH;
		p1=pbmh->pub__bmBitmap;
		for(j=0;j<height;j++)
		{
			p2=p1;
			for(i=0;i<width;i++)
			{
				if(*p2)
					++hist[*p2>>2];
				++p2;
			}
			p1+=perrow;
		}
		DataFree(pdbh);
	}
	pfile = (*pfquitread)(&pvoid);
	fclose(pfile);
	j=0;
	for(i=0;i<64;i++)
		if(hist[i]>hist[j]) j=i;
	j>>=2;
	j&=7;
	strcpy(namebuff,name);
	cutext(namebuff);
	strcat(namebuff,".rgb");
	file=open(namebuff,O_RDONLY|O_BINARY);
	if(file<0) return -1;
	read(file,rgb,64);
	close(file);
	fixname(namebuff,name);
	sprintf(palput,"PAL_%s::\tdb\t",namebuff);
	palput+=strlen(palput);
	p1=(void *)rgb+(j<<3);
	for(i=0;i<7;i++)
	{
		sprintf(palput,"$%02x,",*p1++);
		palput+=strlen(palput);
	}
	sprintf(palput,"$%02x\n",*p1);
	palput+=strlen(palput);
	sprintf(equput,"\t\tGLOBAL PAL_%s\n",namebuff);
	equput+=strlen(equput);
	return 0;
}



int main(int argc,char **argv)
{
	int i;
	int file;
	UL * pul__Mem;
	UL   ul___Mem;
	char name[256];
	char fixed[256];

	if(argc<2)
	{
		printf("ANIMRGB version 2\n");
		printf("Use: animrgb <file.lst>\n");
		printf("     file.lst contains list of sprites (file1.map,file2.map,etc)\n");
		printf("     reads in <name>.abm or <name.spr> for each file,\n");
		printf("     writes <name>.pal = palettes as ASM source\n");
		printf("     writes <name>.equ = list of GLOBAL asm source statements\n");
		exit(1);
	}

	pul__Mem = (UL *) malloc(ul___Mem = BLOCKSIZE);

	if (pul__Mem == NULL)
	{
		printf("No memory(2)\n");
		exit(20);
	}
	memset(pul__Mem,0,BLOCKSIZE);

	buffer1=malloc(BUFFERSIZE);
	buffer2=malloc(BUFFERSIZE);
	buffer3=malloc(BUFFERSIZE);
	if(!buffer1 || !buffer2 || !buffer3)
	{
		printf("no memory\n");
		exit(1);
	}
	file=open(argv[1],O_RDONLY);
	if(file<0)
	{
		printf("Cannot open %s for read\n",argv[1]);
		exit(2);
	}
	i=read(file,buffer1,BUFFERSIZE);
	close(file);
	buffer1[i]=0;
	snprintf(fixed, sizeof(fixed), "%s", argv[1]);
	cutext(fixed);
	take=buffer1;
	palput=buffer2;
	equput=buffer3;
	while(_getline(name))
	{
		convert(name);
	}
	sprintf(name,"%s.pal",fixed);
	file=open(name,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0)
	{
		printf("Cannot open %s for write\n",name);
	} else
	{
		write(file,buffer2,palput-buffer2);
		close(file);
	}
	sprintf(name,"%s.equ",fixed);
	file=open(name,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0)
	{
		printf("Cannot open %s for write\n",name);
	} else
	{
		write(file,buffer3,equput-buffer3);
		close(file);
	}
	return 0;

}
