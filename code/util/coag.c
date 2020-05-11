#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define BUFFERSIZE 65536
#define MAXSIZE 0x800000

#define OUTPUTNAME "filesys"
#define BASE ("_binary_" OUTPUTNAME "_start")


#define INFONAME ( OUTPUTNAME ".h")


char buffer1[BUFFERSIZE];
char buffer2[BUFFERSIZE];
char *take;


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
	while(ch=*p++)
		if(ch!='.') *dest++=toupper(ch);
	*dest=0;
}

void uc(char *s)
{
	while(*s) *s=toupper(*s),++s;
}


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

main(int argc,char **argv)
{
int file;
int i,j;
int len;
char name[128];
char fixed[128];
char *info;
int offset;
char *store;

	if(argc<2)
	{
		printf("Use: %s <name>\n",argv[0]);
		printf("Where <name> is a file containing a list of resources\n");
		exit(0);
	}
	file=open(argv[1],O_RDONLY);
	if(file<0)
	{
		printf("Cannot open '%s' list file for read\n",argv[1]);
		exit(3);
	}
	i=read(file,buffer1,BUFFERSIZE-1);
	close(file);
	buffer1[i]=0;
	store=malloc(MAXSIZE);
	if(!store)
	{
		printf("No memory\n");
		exit(-1);
	}

	take=buffer1;
	info=buffer2;
	offset=0;
	sprintf(info,"extern unsigned char %s[];\n",BASE);
	info+=strlen(info);
	for(;;)
	{
		if(!getname(name)) break;
		file=open(name,O_RDONLY|O_BINARY);
		if(file<0)
		{
			printf("Could not open %s file in list\n",name);
			continue;
		}
		
		len=lseek(file,0L,SEEK_END);
		lseek(file,0L,SEEK_SET);
		read(file,store+offset,len);
		close(file);
		tossdir(fixed,name);
		uc(fixed);
		sprintf(info,"#define DATA_%s (%s+0x%x)\n",
			fixed,BASE,offset);
		offset+=len;
		while(offset&3) store[offset++]=0;
		info+=strlen(info);
		sprintf(info,"#define SIZE_%s 0x%x\n",fixed,len);
		info+=strlen(info);
	}
	file=open(INFONAME,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,0644);
	if(file<0)
		printf("Couldn't open '%s' for output\n",INFONAME);
	else
	{
		write(file,buffer2,info-buffer2);
		close(file);
	}
	file=open(OUTPUTNAME,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,0644);
	if(file<0)
		printf("Couldn't open '%s' for output\n",OUTPUTNAME);
	else
	{
		write(file,store,offset);
		close(file);
	}

}
