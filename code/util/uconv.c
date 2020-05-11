#include <stdio.h>
#include <stdlib.h>

#define DUMMY 0x888888

int *map;

int main(int argc, char **argv) {
	int i,j;
	char line[256],*p;
	char ch;

	map=malloc(65536*sizeof(int));
	if(!map) exit(2);
	for(i=0;i<65536;++i)
		map[i]=DUMMY;
	for(;;)
	{
		p=line;
		while((ch=getchar()) !=EOF)
		{
			if(p<line+256)
				*p++=ch;
			if(ch=='\n') break;
		}
		if(sscanf(line,"0x%x 0x%x",&i,&j)==2)
		{
			map[j&65535]=i;
		}
		if(ch==EOF) break;
	}
	for(i=0;i<65536;++i)
	{
		j=map[i];
		if(j==DUMMY) j=0;
		printf("0x%x,",j);
		if((i%10)==9) printf("\n");
	}
	return 0;
}
