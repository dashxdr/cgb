#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <inttypes.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

#define BUFFERSIZE 65536L
#define MAXBANKS 64
#define MAXRESOURCES 1024
#define BANKSIZE 16384
char *buffer1;
char *buffer2;
char *buffer3;
int bank,offset;
char *take;
int errorcode=0;
int firstbank;

#ifndef O_BINARY
#define O_BINARY 0
#endif

char eqnames[MAXRESOURCES][64];
char rnames[MAXRESOURCES][128];
int lens[MAXRESOURCES];
int indexes[MAXRESOURCES];

char *banks[MAXBANKS];
int ins[MAXBANKS];
int starts[MAXBANKS];
int allocated=0;

int sizes[MAXBANKS];

int getname(char *put)
{
char ch;
char *p;
char directive;

	directive=(*take=='#');
	p=put;
top:
	for(;;)
	{
		ch=*take;
		if(!ch) break;
		++take;
		if(ch=='\n') break;
		if(!directive && (ch==' ' || ch=='\t' || ch==';'))
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

void dump(int n,char *rootname) {
	char name[64];
	int file;
	int res;
	sprintf(name,"%s.b%02x",rootname,n);
	file=open(name,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(file<0)
	{
		printf("Could not open %s file for writing\n",name);
		errorcode|=16;
		return;
	}
	res=write(file,banks[n],ins[n]);res=res;
	close(file);
}

void tossdir(char *dest,char *src)
{
char *p,ch;
	p=src+strlen(src);
	while(p>src)
	{
		ch=*--p;
		if(ch=='/' || ch=='\\' || ch==':') break;
	}
	++p;
	while((ch=*p++))
		if(ch!='.') *dest++=toupper(ch);
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
	memset(banks[allocated],0,BANKSIZE);
	starts[allocated]=0;
	ins[allocated]=0;
	++allocated;
}

#ifdef __STDC__
int comp(const void *a, const void *b) {
    return indexes[*(int *)a] - indexes[*(int *)b];
}
#endif

int main(int argc,char **argv) {
	int file;
	int i,j,k;
	char name[256];
	int len;
	char *p;
	char rootname[256];
	int filenum;
	int res;

	memset(sizes,0,sizeof(sizes));
	if(argc<3)
	{
		printf("GATHER utility version 2:%s\n",__DATE__);
		printf("   USE: gather <file> BANK:OFFSET\n");
		printf("   <file> contains list of files to be included\n");
		printf("   outputs file.b?? files\n");
		printf("   at start of data is index BB:HHLL stored as LLHHBB00 32-bit words\n");
		printf("   Lines beginning with #SPACE BB:SSSS indicate how much\n");
		printf("   space to fill in a specific bank.\n");
		exit(1);
	}
	strcpy(rootname,argv[1]);
	p=rootname;
	while(*p && *p!='.') ++p;
	*p=0;
	buffer1=malloc(BUFFERSIZE);
	buffer2=malloc(BUFFERSIZE);
	buffer3=malloc(BUFFERSIZE);
	if(!buffer1 || !buffer2 || !buffer3)
	{
		printf("no memory\n");
		exit(2);
	}
	memset(buffer1,0,BUFFERSIZE);
	memset(buffer2,0,BUFFERSIZE);
	memset(buffer3,0,BUFFERSIZE);
	sscanf(argv[2],"%x:%x",&firstbank,&offset);
	offset&=0x3fff;
	file=open(argv[1],O_RDONLY);
	if(file<0)
	{
		printf("Cannot open %s list file for read\n",argv[1]);
		exit(3);
	}
	i=read(file,buffer1,BUFFERSIZE-1);i=i;
	close(file);
	buffer1[i]=0;
	take=buffer1;
	filenum=0;
	for(;;)
	{
		if(!getname(name)) break;
		if(*name=='#')
		{
			if(strncmp(name,"#SPACE ",7))
				continue;
			if(sscanf(name+7,"%x,%x",&i,&j)==2)
			{
				if(i>=0 && i<MAXBANKS)
					sizes[i]=j;
			}
			continue;
		}
		file=open(name,O_RDONLY|O_BINARY);
		if(file<0)
		{
			printf("Could not open %s file in list\n",name);
			continue;
		}
		
		lens[filenum]=lseek(file,0L,SEEK_END);
		strcpy(rnames[filenum],name);
		tossdir(eqnames[filenum],name);
		close(file);
		++filenum;
	}
	p=buffer3;
	i=0;
	while(i<filenum)
	{
		sprintf(p,"IDX_%s\tequ\t%d\n",eqnames[i],i);
		p+=strlen(p);
		++i;
	}
	i=0;
	while(i<filenum)
	{
		sprintf(p,"FSSIZE_%s\tequ\t%d\n",eqnames[i],lens[i]);
		p+=strlen(p);
		++i;
	}
	sprintf(name,"%s.asm",rootname);
	file=open(name,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0)
	{
		printf("Could not open %s map file\n",name);
		exit(6);
	}
	res=write(file,buffer3,p-buffer3);res=res;
	close(file);

	allocated=0;
	for(i=0;i<MAXBANKS;++i)
		allocbank();
	starts[firstbank]=offset;
	ins[firstbank]=filenum<<2;
	while((starts[firstbank]+ins[firstbank])&15) ++ins[firstbank];

	i=0;
	while(i<filenum)
	{
		len=(lens[i]+15) & ~15;
		for(j=0;j<MAXBANKS;j++)
		{
			if(starts[j]+ins[j]+len<sizes[j])
				break;
		}
		if(j==MAXBANKS)
		{
			for(j=firstbank;j<MAXBANKS;++j)
			{
				if(!sizes[j] && starts[j]+ins[j]+len<BANKSIZE)
					break;
			}
		}
		if(j==MAXBANKS)
		{
			printf("No banks left! Move your filesystem down.\n");
			exit(20);
		}
		indexes[i]=(j<<16) | (starts[j]+ins[j]);
		ins[j]+=len;
		++i;
	}

	p=banks[firstbank];
	for(i=0;i<filenum;i++)
	{
		j=indexes[i];
		*p++=j;
		*p++=(j>>8) | 0x40;
		*p++=(j>>16);
		*p++=0;
	}
	for(i=0;i<filenum;++i)
	{
		len=lens[i];
		file=open(rnames[i],O_RDONLY|O_BINARY);
		if(file<0)
		{
			printf("Serious error, couldn't reopen same file %s\n",rnames[i]);
			continue;
		}
		j=indexes[i];
		k=j>>16;
		p=banks[k]+(j&0xffff)-starts[k];
		res=read(file,p,len);res=res;
		close(file);

	}
	for(i=0;i<MAXBANKS;i++)
		if(ins[i])
			dump(i,rootname);
	int sorted[MAXRESOURCES];
	#ifndef __STDC__
        int comp(const void *a, const void *b) {
		return indexes[*(int *)a] - indexes[*(int *)b];
	}
	#endif
	for(i=0;i<filenum;++i) sorted[i]=i;
	qsort(sorted, filenum, sizeof(*sorted), comp);
	for(i=0;i<filenum;++i) {
		int t = sorted[i];
		int actual = (indexes[t]>>16)*0x4000 + (indexes[t]&0xffff);
		printf("%02x:%04x [%06x] %s\n", indexes[t]>>16, (indexes[t]&0xffff)|0x4000, actual, rnames[t]);
	}
	return 0;
}
