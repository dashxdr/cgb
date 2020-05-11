#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#define BUFFERSIZE 65536L
#define MAXBANKS 32
#define MAXITEMS 2048
#define BANKSIZE 16384
#define MAXFILES 1024

#define MASK 31

int bank,offset;
char *take;
int errorcode=0;
int firstbank;

#ifndef O_BINARY
#define O_BINARY 0
#endif

unsigned char *buffer1,*buffer2;

char *banks[MAXBANKS];
int ins[MAXBANKS];
int ins2[MAXBANKS];
long starts[MAXBANKS];
int allocated=0;
long index[MAXITEMS];
long lens[MAXITEMS];
char *filenames[MAXFILES];
int bases[MAXFILES];
char *nameput;
int numinputfiles;
int czcount,cnzcount;

unsigned char *mapfile,*charfile;
int mapsize,charsize;

int numsprites;

long getlong(int i)
{
unsigned char *p;
	p=mapfile+(i<<2);
	return *p | (p[1]<<8) | (p[2]<<16L) | (p[3]<<24L);
}

int getname(char *put)
{
char ch;
char *p;
	p=put;
top:
	for(;;)
	{
		ch=*take;
		if(!ch) break;
		++take;
		if(ch=='\n') break;
		if(ch==' ' || ch=='\t' || ch==';')
		{
			while(*take && *take!='\n') ++take;
			break;
		}
		*p++=ch;
	}
	*p=0;
	if(p==put && *take) goto top;
	return *put;
}

dump(int n,char *rootname)
{
char name[64];
int file;
	sprintf(name,"%s.b%02x",rootname,n+firstbank);
	file=open(name,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(file<0)
	{
		printf("Could not open %s file for writing\n",name);
		errorcode|=16;
		return;
	}
	write(file,banks[n],ins[n]+ins2[n]);
	close(file);
}

void tossdir(char *dest,char *src)
{
char *p,ch;
	p=src+strlen(src);
	while(p>src)
	{
		ch=*--p;
		if(ch=='/' || ch=='\\' || ch==':') {++p;break;}
	}
	while(ch=*p++)
		if(ch!='.') *dest++=toupper(ch);
		else break;
	*dest=0;
}

void allocbank(void)
{
	banks[allocated]=malloc(BANKSIZE);
	if(!banks[allocated])
	{
		printf("no memory to allocate %d byte bank\n",BANKSIZE);
		exit(4);
	}
	starts[allocated]=0;
	ins[allocated]=0;
	ins2[allocated]=0;
	++allocated;
}

char *getfile(char *name,int *size)
{
int file;
long len;
char *p;

	file=open(name,O_RDONLY|O_BINARY);
	if(file<0) return 0;
	*size=len=lseek(file,0L,SEEK_END);
	p=malloc(len+1);
	if(!p) {printf("panic, no memory %d\n",len);exit(22);}
	lseek(file,0L,SEEK_SET);
	read(file,p,len);
	close(file);
	p[len]=0;
	return p;
}

// return # of bytes this sprite will need in bits 0-15 (total),
// # of bytes just for pointers in bits 16-31
int spritelen(char *in)
{
int n;
int height;
int total;
int charsize;

	n=in[3]>>1;
	height=1+(in[3]&1);
	charsize=height*n*16;
	total=2+n*4+charsize;
	return (charsize<<16) | total;
}

addsprite(int which,unsigned char *header,unsigned char *chardata,int charbase)
{
unsigned char *in,*take;
int globalx,globaly;
int info0,info1;
int numpieces;
int height;
int thisx,thisy;
int i,j,k;

	in=mapfile+getlong(which);
	globalx=*in++;
	globaly=*in++;
	info0=*in++;
	info1=*in++;
	numpieces=info1>>1;
	height=1+(info1&1) << 4;
	*header++=info0;
	*header++=info1;
	while(numpieces--)
	{
		thisx=*in++;
		thisy=*in++;

		*header++=thisy+globaly;
		*header++=thisx+globalx;
		*header++=charbase;
		*header++=charbase>>8;
		charbase+=height;
		for(i=0;i<height;i+=16)
		{
			j=*in++;
			j+=*in++ << 8;
			if(j) ++cnzcount; else ++czcount;
			if(j<<4 < charsize)
				memcpy(chardata,charfile+(j<<4),16);
			else
			{
				for(k=0;k<numinputfiles;++k)
					if(which<bases[k]) break;
				--k;
				printf("Illegal map value %d for sprite # %d, file %s\n",
					j,which-bases[k],filenames[k]);
			}
			chardata+=16;
		}
	}
}

makeroot(char *dest,char *src)
{
char *p;

	strcpy(dest,src);
	dest[strlen(dest)]=0;
	p=dest+strlen(dest);
	while(p>dest)
		if(*--p=='.')
		{
			*p=0;
			break;
		}
}

// open the map file, find out # of sprites and size and fix up where it will
// be loaded
pass1(char *name,int base)
{
int i,j,k;
int reuse;
int len,len2;
unsigned char *p;
char tempname[256];

	sprintf(tempname,"%s.map",name);
	mapfile=getfile(tempname,&mapsize);
	if(!mapfile)
	{
		printf("Cannot open %s map file for read\n",tempname);
		exit(3);
	}
	numsprites=getlong(0)>>2;
	reuse=0;
	for(i=1;i<numsprites;++i)
	{
		k=getlong(i);
		if(k>reuse)
		{
cant:
			lens[i+base-1]=spritelen(mapfile+k);
			reuse=k;
			len=lens[i+base-1] & 0xffff;
			len2=lens[i+base-1]>>16L;
			for(j=0;j<allocated;j++)
			{
				if((starts[j]+ins[j]+len-len2+MASK & ~MASK ) +
						ins2[j]+len2<=BANKSIZE)
					break;
			}
			if(j==allocated)
				allocbank();
			index[i+base-1]=(j<<16) | starts[j]+ins[j];
			ins[j]+=len-len2; // header portion
			ins2[j]+=len2; // character portion
		} else
		{
			lens[i+base-1]=0;
			for(j=1;j<i;j++)
				if(k==getlong(j))
					break;
			if(j==i) goto cant;
			index[i+base-1]=index[j+base-1];
		}

	}

	p=banks[0]+(base<<2);
	for(i=1;i<numsprites;i++)
	{
		j=index[i+base-1];
		*p++=j;
		*p++=(j>>8) | 0x40;
		*p++=(j>>16) + firstbank;
		*p++=0;
	}
	free(mapfile);
}

process(char *name,int base)
{
char *p;
char tempname[256];
int i,j,k;
int len,len2;


	sprintf(tempname,"%s.map",name);
	mapfile=getfile(tempname,&mapsize);
	if(!mapfile)
	{
		printf("Cannot open %s map file for read\n",name);
		exit(3);
	}
	sprintf(tempname,"%s.chr",name);

	charfile=getfile(tempname,&charsize);
	if(!charfile)
	{
		printf("Cannot open %s char file for read\n",tempname);
		exit(3);
	}

	numsprites=getlong(0)>>2;
	for(i=1;i<numsprites;++i)
	{
		if(!lens[i+base-1]) continue;
		j=index[i+base-1];
		k=j>>16;
		p=banks[k]+(j&0xffff)-starts[k]; // pointer to headers
		j=lens[i+base-1]>>16;
		addsprite(i,p,banks[k]+ins[k],starts[k]+ins[k]|0x4000);
		ins[k]+=j;
		ins2[k]-=j;
	}

	free(mapfile);mapfile=0;
	free(charfile);charfile=0;

}
cutext(char *p)
{
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
//printf("Cut name '%s'\n",p);
}
addfiles(char *in)
{
char *p,ch,*b;

int i;
b=in;
	while(*in)
	{
		p=nameput;
		for(;;)
		{
			ch=*in;
			if(ch==' ' || ch=='\t' || ch==';' || ch==EOF ||
				ch=='#' || ch=='\n' || !ch)
			{
				while((ch=*in) && ch!='\n') ++in;
				if(ch) ++in;
				else break;
				if(nameput>p)
				{
					*nameput++=0;
					cutext(p);
					filenames[numinputfiles++]=p;
					break;
				}
			} else
			{
				*nameput++=ch;
				++in;
			}
		}
	}
}

int howmany(char *name)
{
int file;
unsigned char buff4[4];
char tempname[256];

	sprintf(tempname,"%s.map",name);
	file=open(tempname,O_RDONLY|O_BINARY);
	if(file<0) return 0;
	read(file,buff4,4);
	close(file);
	return (*buff4 | (buff4[1]<<8) | (buff4[2]<<16L) | (buff4[3]<<24L)) >> 2;
}
int tailcomp(char *s1,char *s2)
{
char t1[256],*p,ch;

	p=t1;
	while((ch=tolower(*s1++)) && ch!=0x1a) *p++=ch;
	*p=0;
	if(strlen(s2)>strlen(t1)) return 1;
	return strcmp(t1+strlen(t1)-strlen(s2),s2);
}





main(int argc,char **argv)
{
int file;
long i,j,k;
char *p;
char rootname[256];
int totalnum;
int size;
char tempname[256];
char temp[256];
char item[256];


	rootname[0]=0;
	if(argc<2)
	{
		printf("GMBSPR2 utility version 2 (%s) by Dave Ashley\n",__DATE__);
		printf("   USE: gmbspr2 [name] [filelist] [<file.map>] [-aBANK:OFFSET]\n");
		printf("   outputs file.b?? files\n");
		printf("   at start of data is index BB:HHLL stored as LLHHBB00 longwords\n");
		exit(1);
	}

	buffer1=malloc(BUFFERSIZE);
	buffer2=malloc(BUFFERSIZE);
	if(!buffer1 || !buffer2)
	{
		printf("no memory!\n");
		exit(10);
	}
	numinputfiles=0;
	nameput=buffer1;
	firstbank=offset=0;
	for(i=1;i<argc;i++)
	{
		strcpy(item,argv[i]);
		p=item;
		while(*p && *p!=0x1a) ++p;
		*p=0;
		if(!item[0]) continue;
		if(!strncmp(item,"-a",2))
		{
			sscanf(item+2,"%x:%x",&firstbank,&offset);
			offset&=0x3fff;
		} else if(item[0]=='@')
		{
			p=getfile(item+1,&size);
			if(!p)
				printf("Cannot open list file %s\n",item+1);
			else
			{
				makeroot(rootname,item+1);
				addfiles(p);

				free(p);
			}
		} else
		{
			if(!tailcomp(item,".map") || !tailcomp(item,".spr") ||
							!tailcomp(item,".abm"))
			{
				if(!rootname[0])
					makeroot(rootname,item);
				addfiles(item);
			}
			else
			{
				strcpy(rootname,item);
			}
		}
	}

	totalnum=1;
	for(i=0;i<numinputfiles;++i)
	{
		bases[i]=totalnum;
		totalnum+=howmany(filenames[i])-1;
	}
	bases[i]=totalnum;
	printf("%d total sprites, %d separate files\n",totalnum,numinputfiles);


	czcount=cnzcount=0;

	sprintf(tempname,"%s.asm",rootname);
	file=open(tempname,O_WRONLY|O_CREAT|O_TRUNC,0644);
	if(file<0)
		printf("Cannot open ASM file %s for write\n",tempname);
	else
	{
		for(i=0;i<numinputfiles;++i)
		{
			tossdir(tempname,filenames[i]);
			sprintf(temp,"IDX_%s EQU %d\n",tempname,bases[i]);
			write(file,temp,strlen(temp));
		}
		close(file);
	}

	allocated=0;
	allocbank();
	starts[0]=offset;
	ins[0]=(totalnum<<2)+2;
	ins2[0]=0;
	i=totalnum<<2;;
	j=(i+offset) | 0x4000;
	banks[0][0]=j;
	banks[0][1]=j>>8;
	banks[0][2]=firstbank;
	banks[0][3]=0;
	banks[0][i]=0;
	banks[0][i+1]=0;

	for(i=0;i<numinputfiles;++i)
	{
		pass1(filenames[i],bases[i]);
	}
	for(i=0;i<allocated;i++)
		while(starts[i]+ins[i] & MASK) banks[i][ins[i]++]=0;
	for(i=0;i<numinputfiles;++i)
	{
		process(filenames[i],bases[i]);
	}
	for(i=0;i<allocated;i++)
		dump(i,rootname);
	printf("Zero tiles: %d, Nonzero tiles: %d\n",czcount,cnzcount);
	exit(0);
}
