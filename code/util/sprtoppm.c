#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#define WIDEWANT 480

int infile;
int sprframes;
int sprwidth;
int sprheight;

int bigwidth;

int numx,spacex;
int numy,spacey;

unsigned char palette[768],*bm;

unsigned char *bigbm;

void nomem(int val) {
	fprintf(stderr,"No memory %d\n",val);
	exit(20);
}

int readsprheader(void) {
	unsigned char header[6];
	int len;
	int res;

	lseek(infile,0L,SEEK_SET);
	len=read(infile,header,3);
	if(len!=3) return -1;
	if(memcmp(header,"SPR",3)) return -2;
	lseek(infile,3L,SEEK_SET);
	res=read(infile,header,sizeof(header));res=res;
	sprframes=header[0] | (header[1]<<8);
	sprwidth=header[2] | (header[3]<<8);
	sprheight=header[4] | (header[5]<<8);
	bm=malloc(sprwidth*sprheight);
	if(!bm) nomem(1);
	return 0;
}


void slapspr(int px,int py) {
	unsigned char *p,oneline[1024],*t;
	int i,j;
	int res;

	res=read(infile,oneline,2);res=res; // tic count for this frame
	res=read(infile,palette,768);res=res;
	p=bigbm+(px+py*bigwidth)*3;
	for(j=0;j<sprheight;++j)
	{
		res=read(infile,oneline,sprwidth);res=res;
		for(i=0;i<sprwidth;++i)
		{
			t=palette+3*oneline[i];
			*p++=*t++;
			*p++=*t++;
			*p++=*t++;
		}
		p+=(bigwidth-sprwidth)*3;
	}
}



int main(int argc,char **argv) {
	int res;
	int xpos,ypos;
	char temp[64];
	int bigbmsize;

	if(argc<2) infile=0;
	else
	{
		infile=open(argv[1],O_RDONLY);
		if(infile<0)
		{
			fprintf(stderr,"Couldn't open %s for read.\n",argv[1]);
			exit(1);
		}
	}
	res=readsprheader();
	if(res<0)
	{
		fprintf(stderr,"Error reading SPR header %d\n",res);
		exit(2);
	}
	numx=WIDEWANT/sprwidth;
	numy=(sprframes+numx-1)/numx;
	if(sprframes>numx)
		bigwidth=numx*sprwidth;
	else
		bigwidth=sprframes*sprwidth;
	spacex=sprwidth;
	spacey=sprheight;

	xpos=ypos=0;
	bigbmsize=bigwidth*spacey*numy*3;
	bigbm=malloc(bigbmsize);
	if(!bigbm) nomem(3);
	memset(bigbm,0,bigbmsize);

	while(sprframes>0)
	{
		slapspr(xpos,ypos);
		xpos+=spacex;
		if(xpos>=bigwidth)
		{
			xpos=0;
			ypos+=spacey;
		}
		--sprframes;
	}
	sprintf(temp,"P6\n%d %d\n255\n",bigwidth,spacey*numy);
	res=write(1,temp,strlen(temp));res=res;
	res=write(1,bigbm,bigbmsize);res=res;
	return 0;
}
