#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>


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

void nomem(int val)
{
	fprintf(stderr,"No memory %d\n",val);
	exit(20);
}

readsprheader(void)
{
unsigned char header[6];
int len;

	lseek(infile,0L,SEEK_SET);
	len=read(infile,header,3);
	if(len!=3) return -1;
	if(memcmp(header,"SPR",3)) return -2;
	lseek(infile,3L,SEEK_SET);
	read(infile,header,sizeof(header));
	sprframes=header[0] | (header[1]<<8);
	sprwidth=header[2] | (header[3]<<8);
	sprheight=header[4] | (header[5]<<8);
	bm=malloc(sprwidth*sprheight);
	if(!bm) nomem(1);
	return 0;
}


slapspr(int px,int py)
{
unsigned char *p,oneline[1024],*t;
int i,j;

	read(infile,oneline,2); // tic count for this frame
	read(infile,palette,768);
	p=bigbm+(px+py*bigwidth)*3;
	for(j=0;j<sprheight;++j)
	{
		read(infile,oneline,sprwidth);
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



main(int argc,char **argv)
{
int res;
int xpos,ypos;
int i,j;
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
	write(1,temp,strlen(temp));
	write(1,bigbm,bigbmsize);
}
