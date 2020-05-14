#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>


int main(int argc,char **argv) {
	int infile;
	int len,i,j,k;
	char block[256];

	if(argc<2)
		return -1;
	infile=open(argv[1],O_RDONLY);
	if(infile<0) return -2;
	len=lseek(infile,0,SEEK_END);
	lseek(infile,0,SEEK_SET);
	putchar((len+255)>>8);
	putchar((len+255)>>16);
	i=len;
	while(i)
	{
		j=i>sizeof(block) ? sizeof(block) : i;
		int res=read(infile,block,j);res=res;
		for(k=0;k<j;++k)
			putchar(block[k]-0x80);
		i-=j;
		if(j==sizeof(block)) continue;
		while(j++<sizeof(block)) putchar(0);
		break;
	}
	close(infile);
	return 0;
}
