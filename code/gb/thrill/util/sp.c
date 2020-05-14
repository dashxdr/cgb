#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SIZE 0x100000

int main(int argc,char **argv) {
	int i,j,f;
	unsigned char *p,*s;
	int av;
	int s2;

	if(argc<2)
	{
		printf("Use: %s <name>\n",argv[0]);
		exit(0);
	}
	f=open(argv[1],O_RDONLY);
	if(f<0)
	{
		printf("Couldn't open %s\n",argv[1]);
		exit(-1);
	}
	av=0;
	p=malloc(SIZE);
	if(!p)
	{
		printf("No memory\n");
		exit(-2);
	}
	memset(p,0,SIZE);
	s2=read(f,p,SIZE);
	close(f);
	for(i=0;i<(s2>>14);++i)
	{
		s=p+(i<<14);
		j=16384;
		while(j>0)
		{
			if(s[j-1]!=0xff) break;
			--j;
		}
		printf("%02d:%04x\n",i,16384-j);
		av+=16384-j;
	}
	printf("Total space $%x,%d\n",av,av);
	return 0;
}