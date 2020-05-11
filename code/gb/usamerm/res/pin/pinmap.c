#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif

char outputname[64];


typedef struct surface
{
	unsigned char format;
	unsigned char colormap[768];
	unsigned char *pic;
	int xsize;
	int ysize;
} surface;
#define FORMAT8 1
#define FORMAT16 2
#define FORMAT32 4

#define WIDTH 24
#define HEIGHT 64

surface pic;

char lastpic[64];

void nomem(int code)
{
	printf("Out of memory, code %d\n",code);
	exit(-1);
}


#define IBUFFLEN 1024
int pcxileft=0,pcxihand=0;
unsigned char *pcxibuff=0,*pcxitake;

int pcxci()
{
	if(!pcxileft)
	{
		pcxileft=read(pcxihand,pcxibuff,IBUFFLEN);

		if(!pcxileft) return -1;
		pcxitake=pcxibuff;
	}
	pcxileft--;
	return *pcxitake++;
}
void pcxciinit(void)
{
	if(!pcxibuff)
		pcxibuff=malloc(IBUFFLEN);
	if(!pcxibuff) nomem(1);
	pcxileft=0;
}

int readpcx(char *name,surface *gs)
{
int xs,ys;
int i,j,k,n,t;
int totalsize;
int width,height;
int x,y;
unsigned char *bm,*lp;
char tname[256];
int r,g,b;
int numbpp;
unsigned char map48[48];
unsigned char arow[2048];
int perrow;
int pcxbyteswide;
	pcxciinit();
	memset(gs,0,sizeof(surface));
	gs->format=FORMAT8;
	pcxihand=open(name,O_RDONLY);
	if(pcxihand<0)
		return 1;
	if(pcxci()!=10) {close(pcxihand);return 2;} // 10=zsoft .pcx
	if(pcxci()!=5) {close(pcxihand);return 3;} // version 3.0
	if(pcxci()!=1) {close(pcxihand);return 4;} //encoding method
	numbpp=pcxci();
//	if(numbpp!=8) {close(pcxihand);return 5;} //bpp
	if(numbpp!=8 && numbpp!=1) {close(pcxihand);return 5;} //bpp
	xs=pcxci();
	xs|=pcxci()<<8;
	ys=pcxci();
	ys|=pcxci()<<8;
	width=pcxci();
	width|=pcxci()<<8;
	height=pcxci();
	height|=pcxci()<<8;
	width=width+1-xs;
	height=height+1-ys;
	for(i=0;i<4;++i) pcxci();
	for(i=0;i<48;++i) map48[i]=pcxci();
	pcxci();
	n=pcxci();
//	if(n!=1) {close(pcxihand);return 6;} // # of planes
	if(numbpp==8 && n!=1) {close(pcxihand);return 6;} // # of planes
	pcxbyteswide=pcxci();
	pcxbyteswide|=pcxci()<<8;
	perrow=pcxbyteswide*n;
	i=pcxci();
	i|=pcxci()<<8;
//	if(i!=1) {close(ihand);return 7;} // 1=color/bw,2=grey
	for(i=0;i<58;++i) pcxci();
	totalsize=height*width;
	bm=malloc(totalsize);
	if(!bm) {close(pcxihand);return 8;} // no memory
	memset(bm,0,totalsize);
	gs->pic=bm;
	gs->xsize=width;
	gs->ysize=height;

	lp=bm;
	for(y=0;y<height;++y)
	{
		i=0;
		while(i<perrow)
		{
			j=pcxci();
			if(j<0xc0)
			{
				arow[i++]=j;
			} else
			{
				j&=0x3f;
				k=pcxci();
				while(j-- && i<perrow)
				{
					arow[i++]=k;
				}
			}
		}
		if(numbpp==8)
			memcpy(lp,arow,width);
		else
		{
			for(t=0;t<n;++t)
			{
				i=t*pcxbyteswide;
				j=0;
				while(j<width)
				{
					k=arow[i++] | 256;
					while(!(k&0x10000) && j<width)
					{
						if(k&0x80) lp[j]|=1<<t;
						k<<=1;
						++j;
					}
				}
			}
		}
		lp+=width;
	}
	if(numbpp==8)
	{
		lseek(pcxihand,-0x300,SEEK_END);
		pcxileft=0;
		for(i=0;i<256;++i)
		{
			r=pcxci();
			g=pcxci();
			b=pcxci();
			gs->colormap[i+i+i]=r;
			gs->colormap[i+i+i+1]=g;
			gs->colormap[i+i+i+2]=b;
		}
	} else
	{
		for(i=0,j=0;i<16;++i)
		{
			r=map48[j++];
			g=map48[j++];
			b=map48[j++];
			gs->colormap[i+i+i]=r;
			gs->colormap[i+i+i+1]=g;
			gs->colormap[i+i+i+2]=b;
		}
	}
	close(pcxihand);
	return 0;
}
void striptail(char *s)
{
char *p;
	p=s+strlen(s);
	while(--p>s)
		if(*p=='.')
		{
			*p=0;
			break;
		}
}

void gettileraw(unsigned char *put,int px,int py)
{
unsigned char *p;
int x,y,i,j;

	memset(put,0,64);
	if(pic.xsize<(px+1<<3) || pic.ysize<(py+1<<3)) return;
	p=pic.pic+(py*pic.xsize+px<<3);
	for(y=0;y<8;++y)
	{
		for(x=0;x<8;++x)
		{
			*put++=*p++;
		}
		p+=pic.xsize-8;
	}
}
int gettile(unsigned char *put,int px,int py)
{
int i,j,k,x,y;
unsigned char b1,b2,*p;
int err;

	memset(put,0,16);
	if(pic.xsize<(px+1<<3) || pic.ysize<(py+1<<3)) return 0;
	p=pic.pic+(py*pic.xsize+px<<3);
	k=*p;
	err=0;
	for(y=0;y<8;++y)
	{
		b1=b2=0;
		for(x=0;x<8;++x)
		{
			j=*p++;
			if((j^k)&0xf0) ++err;
			b1<<=1;
			b2<<=1;
			if(j&1) b1|=0x01;
			if(j&2) b2|=0x01;
		}
		*put++=b1;
		*put++=b2;
		p+=pic.xsize-8;
	}
	if(err) printf("Palette problem in %s at %d,%d\n",lastpic,px<<3,py<<3);
	return (k>>4)&7;
}

unsigned char *tiles;
int amap[WIDTH*HEIGHT];
int numtiles;

void processmap(char *name,int h)
{
	unsigned char temp[32*64*2],*p;
	char tname[128];
	int i,j,k;
	int res;

	p=temp;
	j=WIDTH*h;
	for(i=0;i<j;++i)
	{
		k=amap[i];
		*p++=k;
		*p++=k>>8;
	}
	sprintf(tname,"%s.map",name);
	i=open(tname,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	res=write(i,temp,p-temp);res=res;
	close(i);
}

void processpicture(int mask)
{
int i,j,k,x,y;
int mapnum;
unsigned char *p,*p2;
int *mp;
unsigned char araw[64];

	for(y=0;y<HEIGHT;++y)
	{
		for(x=0;x<WIDTH;++x)
		{
			if(!mask)
			{
				p=tiles+(numtiles<<4);
				mapnum=gettile(p,x,y);
				p2=tiles;
				while(p2<p)
					if(!memcmp(p2,p,16)) break;
					else p2+=16;
				if(p2==p) ++numtiles;
				mp=amap+WIDTH*y+x;
				j=*mp;
				if(j==2)
					*mp=~0;
				else if(j==1)
					*mp=mapnum | (p2-tiles&0xfff0) | 8;
				else
					*mp=mapnum | (p2-tiles&0xfff0);

			} else
			{
				gettileraw(araw,x,y);
				j=0;
				for(i=0;i<64;++i) j|=araw[i];
				amap[WIDTH*y+x]=j;
			}
		}
	}
}

unsigned char colormap[768];

void processcmap(char *name)
{
	int ofile;
	int i,j;
	int r,g,b;
	char nametemp[256];
	int res;

	sprintf(nametemp,"%s.rgb",name);
	ofile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(ofile<0) {printf("Cannot open %s for write\n",nametemp);return;}
	for(i=0;i<32;++i)
	{
		j=(i&3) | ((i&0x1c)<<2);
		r=pic.colormap[j+j+j]>>3;
		g=pic.colormap[j+j+j+1]>>3;
		b=pic.colormap[j+j+j+2]>>3;
		j=r | (g<<5) | (b<<10);
		nametemp[i+i]=j;
		nametemp[i+i+1]=j>>8;
	}
	res=write(ofile,nametemp,64);res=res;
	close(ofile);

}

int main(int argc,char **argv)
{
struct surface s;
int i,j,k,t;
char strippedname[128];
char temp[256];
char mask;
unsigned char *p;
char setoutputname;

	tiles=malloc(65536);
	if(!tiles) nomem(1);
	memset(tiles,0,16);
	numtiles=1;
	memset(amap,0,sizeof(amap));

	if(argc<2)
	{
		printf("Specify pcx file(s)...\n");
		exit(0);
	}
	i=1;
	mask=0;
	strcpy(outputname,"allchr");
	memset(amap,0,sizeof(amap));
	setoutputname=0;
	for(i=1;i<argc;++i)
	{
		if(setoutputname)
		{
			strcpy(outputname,argv[i]);
			setoutputname=0;
			continue;
		}
		if(!strcmp(argv[i],"-mask"))
		{
			mask=1;
			continue;
		}
		if(!strcmp(argv[i],"-o"))
		{
			setoutputname=1;
			continue;
		}
		strcpy(lastpic,argv[i]);
		j=readpcx(lastpic,&pic);
		if(j)
			printf("Error %d reading pcx file, %s\n",j,lastpic);
		else
		{
			printf("Processing file %s\n",lastpic);
			strcpy(strippedname,lastpic);
			striptail(strippedname);

			processpicture(mask);
			if(!mask)
			{
				processmap(strippedname,pic.ysize>>3);
				processcmap(strippedname);
				memset(amap,0,sizeof(amap));
			}
			mask=0;
		}
	}

	printf("numtiles=%d\n",numtiles);

	p=tiles;
	j=numtiles<<4;
	k=0;
	while(j)
	{
		sprintf(temp,"%s.ch%d",outputname,k);
		i=open(temp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
		if(i<0)
		{
			printf("Could not open file %s\n",temp);
			break;
		}
		t=j>16384 ? 16384 : j;
		int res=write(i,p,t);res=res;
		close(i);
		p+=t;
		j-=t;
		++k;
	}
}
