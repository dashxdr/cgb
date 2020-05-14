#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#define BUFFERSIZE 2048

#ifndef O_BINARY
#define O_BINARY 0
#endif

int main(int argc,char **argv) {
	int sum,len;
	int i;
	int file;
	unsigned char buffer[BUFFERSIZE];

	if(argc<2)
	{
		printf("Use: %s <filename>\n",argv[0]);
		printf("Generates 16 bit sum of all bytes in file.\n");
		exit(1);
	}
	file=open(argv[1],O_RDONLY|O_BINARY);
	if(file<0)
	{
		printf("Could not open %s for input.\n",argv[1]);
		exit(2);
	}
	sum=0;
	for(;;)
	{
		len=read(file,buffer,BUFFERSIZE);
		if(!len) break;
		if(len<0)
		{
			printf("Read error\n");
			exit(3);
		}
		for(i=0;i<len;++i)
			sum+=buffer[i];
	}
	close(file);
	printf("Nintendo sum is %04X\n",sum&0xffff);
	return 0;
}

