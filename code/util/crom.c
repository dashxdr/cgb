#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>


unsigned long rrr=0xaabacada;
int myrand()
{
	rrr=rrr ^ (rrr>>3);
	rrr=(rrr>>8) | (rrr<<24);
	return rrr&255;
}

int process(char *name)
{
int f;
int len;
unsigned char *data;
int datalen;
int i,j;

	f=open(name,O_RDONLY);
	if(f<0) return -1;
	len=lseek(f,0,SEEK_END);
	lseek(f,0,SEEK_SET);
	data=malloc(len);
	if(!data) {close(f);return -2;}
	datalen=read(f,data,len);
	close(f);
	printf("int romdatalen=%d;\n",datalen);
	printf("unsigned char romdata[%d]={\n",datalen);
	while(datalen)
	{
		i=(datalen>16) ? 16 : datalen;
		for(j=0;j<i;++j)
			printf("%d,",*data++ ^ myrand());
		printf("\n");
		datalen-=i;
	}
	printf("};\n");
	return 0;
}

int main(int argc,char **argv) {
	process(argv[1]);
	return 0;
}

