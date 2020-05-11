#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#define MAXBUFFER 1000000

char buffer[MAXBUFFER];
char *take;
#define MAXBANKS 64

int _getline(char *put) {
	char ch;
	char *p;

	p=put;
	for(;;)
	{
		ch=*take;
		if(!ch) break;
		++take;
		if(ch=='\n') break;
		*p++=ch;
	}
	*p=0;
	return *put || *take;
}


int main(int argc,char **argv) {
	int f,len,i;
	char line[128];
	int max[MAXBANKS];
	unsigned int bank,val;
	int space;

	if(argc<2)
	{
		printf("Use: %s <file>.sym\n",argv[0]);
		printf("   Prints out space left in each bank.\n");
		exit(1);
	}
	f=open(argv[1],O_RDONLY);
	if(f<0)
	{
		printf("Could not open %s for read\n",argv[1]);
		exit(2);
	}
	len=read(f,buffer,MAXBUFFER-1);
	if(len>=0) buffer[len]=0;
	else
	{
		printf("Some error reading...\n");
		exit(3);
	}
	memset(max,0,sizeof(max));
	take=buffer;
	while(_getline(line))
	{
		if(sscanf(line,"%x:%x",&bank,&val)!=2) continue;
		if(!bank && val>0x4000) continue;
		if(bank && val>=0x4000) val-=0x4000;
		if(bank>=MAXBANKS) continue;
		if(max[bank]<val)
			max[bank]=val;
	}
	space=0;
	for(i=0;i<MAXBANKS;++i)
	{
		printf("%02X:%04X  %4X free\n",i,max[i],0x4000-max[i]);
		space+=0x4000-max[i];
	}
	printf("Space:%6X\n",space);
	printf("%02X banks, %04X bytes\n",space>>14,space&0x3fff);
	return 0;
}
