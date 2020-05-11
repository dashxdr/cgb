#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define BUFFERLEN 65536L
char *take,*buffer;



int _getline(char *p)
{
char ch;
char *p2;
	p2=p;
	while(ch=*take)
	{
		++take;
		if(ch=='\n') break;
		*p2++=ch;
	}
	*p2=0;
	return *p;
}

void outsome(char *varname,int j)
{
int i;
	for(i=0;i<j;i++)
		printf("\tdw\tIDX_X%s+%d\n",varname,i);
}


main(int argc,char **argv)
{
int file,len,val;
char line[80];
char varname[64],ch,lastvarname[64];
int i,j,k;
int count,last;

	if(argc<2)
	{
		printf("Use: bmap <filename>\n");
		printf("   <filename> is usually whtspr.asm. Generates remap table\n");
		exit(1);
	}
	buffer=malloc(BUFFERLEN);
	if(!buffer)
	{
		printf("no memory\n");
		exit(2);
	}
	file=open(argv[1],O_RDONLY);
	if(file<0)
	{
		printf("Could not open %s for input\n",argv[1]);
		exit(3);
	}
	len=read(file,buffer,BUFFERLEN-1);
	buffer[len]=0;
	close(file);
	printf("\tdw\t0\n");
	take=buffer;
	count=0;
	while(_getline(line))
	{
		if(strncmp(line,"IDX_",4))
		{
			printf("input file malformed, expecting lines like IDX_* EQU #\n");
			printf("got %s\n",line);
			exit(4);
		}
		i=4;j=0;
		while((ch=line[i++])!=' ') varname[j++]=ch;
		varname[j]=0;
		i+=4;
		val=atoi(line+i);
		if(count)
			outsome(lastvarname,val-last);
		strcpy(lastvarname,varname);
		last=val;
		++count;
	}
	outsome(lastvarname,10);
}
