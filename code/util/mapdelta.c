/* This program reads in a sequence of PCX files and creates a handy
format for the map to be written by the gameboy. The format is
word offset for map # 0
word offset for map # 1
...
Offsets are deltas from the location of the offset+1.
so
;hl=index into table
 ld a,[hli]
 ld d,[hl]
 ld e,a
 add hl,de
will work.
The map is stored as follows:
# of bytes to copy (0 = endmark)
WORD delta from current location (starting in UL of the map)
BYTES to copy

Two such sequences are stored, the first updates the map, the second the
attributes for color gameboy. The attribute sequence follows right after the
map one.

DELTAS are based on a 32 byte line.
Input maps are assumed to be 20x18

The 00 map value is assumed to be transparent, and is skipped.

outputs to binary file specified on command line

Processes 2 files, the second being the black and white version.


*/


#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

int nframes;

unsigned char output[65536];
unsigned char *opnt;

unsigned char amap[2048];

#ifndef O_BINARY
#define O_BINARY 0
#endif

int lastpos;

int readmap(int x,int y) {
	int index;
	int val;

	index=8+((y*20+x)<<1);
	val=amap[index] | (amap[index+1]<<8);
	return val;
}


void dump(int num,int x,int y,int lohi) {
	int startpos;
	int val;

	x-=num;
	if(!num) return;
	*opnt++=num;
	startpos=y*32+x;
	*opnt++=startpos-lastpos;
	*opnt++=(startpos-lastpos)>>8;
	lastpos=startpos+num;
	while(num--)
	{
		val=readmap(x++,y);
		if(lohi) val>>=8;
		else --val;
		*opnt++=val;
	}
}

void packmap(int lohi) {
	int i,j,k;
	int val;

	lastpos=0;

	k=0;
	for(j=0;j<18;++j)
	{
		for(i=0;i<20;++i)
		{
			val=readmap(i,j);
			if(!(val&255))
			{
				if(k)
				{
					dump(k,i,j,lohi);
					k=0;
				}
			} else
				++k;
		}
		if(k)
		{
			dump(k,i,j,lohi);
			k=0;
		}
	}
	*opnt++=0;
}

void packset(char *nameroot,int start) {
	int file;
	int i,j,k;
	char name[256];
	int res;

	for(i=0;i<nframes;++i)
	{
		sprintf(name,"%s%03d.map",nameroot,i+1);
		file=open(name,O_RDONLY|O_BINARY);
		if(file<0) {printf("Couldn't open %s\n",name);continue;}
		res=read(file,amap,20*18*2+8);res=res;
		close(file);
		j=i+i+start+start;
		k=(opnt-output)-j-1;
		output[j]=k;
		output[j+1]=k>>8;
		packmap(0);
		packmap(1);
	}
}

int main(int argc,char **argv) {
	int file;
	int res;

	if(argc<5 || sscanf(argv[3],"%d",&nframes)<1)
	{
		printf("Use: MAPDELTA <CGBBASENAME> <GMBBASENAME> <#FRAMES> <OUTPUTNAME>\n");
		exit(1);
	}

	opnt=output+nframes*4;
	memset(output,0,nframes*4);
	packset(argv[1],0);
	packset(argv[2],nframes);
	file=open(argv[4],O_CREAT|O_BINARY|O_WRONLY|O_TRUNC,0644);
	if(file<0)
	{
		printf("Couldn't open output file %s\n",argv[4]);
		return 1;
	}
	res=write(file,output,opnt-output);res=res;
	close(file);
	return 0;
}
