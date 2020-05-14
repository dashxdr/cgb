/* This program accepts two or more files for input and compares them. If
   all of the bytes are different the line is displayed. If they are all
   either ascending or descending, an asterisk is displayed to highlight the
   line. This is useful for figuring out what a game's variables are. */
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

#define MAXIN 50
#define BUFFSIZE 16384

int files[MAXIN],numf;
unsigned char *buffers[MAXIN],*takes[MAXIN];
int lefts[MAXIN];


int get(int num)
{
	if(lefts[num]==-1) return -1;
	if(!lefts[num])
	{
		lefts[num]=read(files[num],buffers[num],BUFFSIZE);
		takes[num]=buffers[num];
		if(!lefts[num])
		{
			lefts[num]=-1;
			return -1;
		}
	}
	--lefts[num];
	return *takes[num]++;
}

void closeall(void) {
	int i;
	for(i=0;i<numf;i++)
	{
		if(files[i]>=0) {close(files[i]);files[i]=0;}
		if(buffers[i]) {free(buffers[i]);buffers[i]=0;}
	}
}
int main(int argc,char **argv) {
	int i,j;
	int ch[MAXIN];
	long addr;
	char a,b;
	char difflengths=0;

	if(argc<3)
	{
		puts("Use: comp <file1> <file2> <file3>...\n");
		return -1;
	}

	numf=argc-1;
	for(i=0;i<numf;i++)
	{
		files[i]=open(argv[i+1],O_RDONLY);
		lefts[i]=0;
		buffers[i]=malloc(BUFFSIZE);
	}
	for(i=0;i<numf;i++)
		if(files[i]<0)
		{
			printf("Cannot open %s.\n",argv[i+1]);
			closeall();
			return -2;
		} else if(buffers[i]==0)
		{
			printf("Could not allocate memory for buffer.\n");
			closeall();
			return -3;
		}
	addr=0;
	for(;;++addr)
	{
		j=0;
		for(i=0;i<numf;i++)
		{
			ch[i]=get(i);
			if(ch[i]>=0) ++j;
		}
		if(!j) break;
		if(j!=i) difflengths=1;
		for(j=0;j<numf-1;j++)
		{
			if(ch[j]==-1) continue;
			for(i=j+1;i<numf;i++)
			{
				if(ch[i]==-1) continue;
				if(ch[i]!=ch[j]) goto exit;
			}
		}
		continue;
exit:
		printf("%06lx ",addr);
		for(j=0;j<numf;j++)
		{
			if(ch[j]>=0)
				printf(" %02x",ch[j]&0xff);
			else
				printf("   ");
		}
		a=1;b=1;
		for(i=0;i<numf-1;i++)
		{
			if(ch[i]<ch[i+1]) a=0;
			if(ch[i]>ch[i+1]) b=0;
		}
		if(a || b) printf(" *");
		putchar('\n');
	}
	closeall();
	if(difflengths) printf("Files were not all the same length.\n");
	return 0;
}
