#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif

char outputname[64];
int use16;
int rot90=0;

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

#define MAXTILES 0x10000

#define WIDTH 256
#define HEIGHT 256

surface pic;

char lastpic[64];

void nomem(int code)
{
	printf("Out of memory, code %d\n",code);
	exit(-1);
}

#define MAXHASHES 0x10000
struct hashentry {
	unsigned long next;
	unsigned long tile;
} hashes[MAXTILES+MAXHASHES];

int nexthash;

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

int hashtile(unsigned char *tile)
{
unsigned long hashval;
int i,j;
	hashval=0;
	for(i=0;i<32;++i)
	{
		hashval=((hashval&1)<<31) | (hashval>>1);
		hashval^=*tile++;
		hashval^=*tile++<<8;
		++hashval;
	}
	hashval=(hashval&0xffff) ^ (hashval>>16);
	if(use16) hashval&=0x0f0f;
	return hashval;
}

int gettile(unsigned char *put,int px,int py)
{
int i,j,k,x,y;
unsigned char b1,b2,*p,c,c0,c1;
int err;

	c0=0;
	c1=0xff;
	memset(put,0,64);
	if(pic.xsize<(px+1<<3) || pic.ysize<(py+1<<3)) return 0;
	p=pic.pic+(py*pic.xsize+px<<3);
	err=0;
	for(y=0;y<8;++y)
	{
		b1=b2=0;
		for(x=0;x<8;++x)
		{
			c=*put++=p[rot90 ? (y+(x^7)*pic.xsize) : (x+y*pic.xsize)];
			c0|=c;
			c1&=c;
		}
//		p+=pic.xsize-8;
	}
	if(use16 && ((c0^c1)&0xf0))
		printf("Palette problem at %d,%d\n",px<<3,py<<3);
	return use16 ? ((c0&0xf0)<<8) : 0;
}

unsigned char *tiles;
int amap[WIDTH*HEIGHT];
int numtiles;

processmap(char *name,int w,int h)
{
unsigned char temp[WIDTH*HEIGHT*2],*p;
char tname[128];
int i,j,k;
char t2[4];

	if(!rot90)
	{
		p=temp;
		for(j=0;j<h;++j)
			for(i=0;i<w;++i)
			{
				k=amap[j*WIDTH+i];
				*p++=k;
				*p++=k>>8;
			}
		t2[0]=w;
		t2[1]=w>>8;
		t2[2]=h;
		t2[3]=h>>8;
	} else
	{
		p=temp;
		for(j=0;j<w;++j)
			for(i=h-1;i>=0;--i)
			{
				k=amap[i*WIDTH+j];
				*p++=k;
				*p++=k>>8;
			}
		t2[0]=h;
		t2[1]=h>>8;
		t2[2]=w;
		t2[3]=w>>8;
	}
	sprintf(tname,"%s.map",name);
	i=open(tname,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	write(i,t2,4);
	write(i,temp,p-temp);
	close(i);
}

int compare(unsigned char *p1,unsigned char *p2)
{
unsigned char mask;
int i;
	mask=use16 ? 0x0f : 0xff;
	for(i=0;i<64;++i)
		if((*p1++ ^ *p2++)&mask) break;
	return i<64;
}

processpicture()
{
int i,j,k,x,y;
int mapnum;
unsigned char *p,*p2;
int *mp;
unsigned char araw[64];
int hashval,tilenum,hsave;
	for(y=0;y<pic.ysize+7>>3;++y)
	{
		for(x=0;x<pic.xsize+7>>3;++x)
		{
			p=tiles+(numtiles<<6);
			mapnum=gettile(p,x,y);
			hsave=hashval=hashtile(p)+1;
			while(hashval)
			{
				tilenum=hashes[hashval-1].tile;
				if(!tilenum) break;
				if(!compare(tiles+(tilenum-1<<6),p)) break;
				tilenum=0;
				hashval=hashes[hashval-1].next;
			}
			mp=amap+WIDTH*y+x;
			if(!tilenum)
			{
				if(hashes[hsave-1].tile)
				{
					hashes[nexthash]=hashes[hsave-1];
					hashes[hsave-1].next=nexthash+1;

					++nexthash;
				}
				hashes[hsave-1].tile=numtiles+1;

				*mp=numtiles;
				++numtiles;
			} else
				*mp=tilenum-1;
		}
	}
}

unsigned char colormap[768];

void writetiles(int f)
{
int i,j,k;
unsigned char t[32],*p;

	if(!use16)
	{
		write(f,tiles,numtiles<<6);
		return;
	}
	for(i=0;i<numtiles;++i)
	{
		p=tiles+(i<<6);
		for(j=0;j<64;j+=2)
		{
			t[j>>1]=(p[j]&15) | ((p[j+1]&15)<<4);
		}
		write(f,t,32);
	}
}

processcmap(char *name)
{
int ofile;
int i,j;
int r,g,b;
char nametemp[256];
unsigned short pal[256];

	sprintf(nametemp,"%s.rgb",name);
	ofile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(ofile<0) {printf("Cannot open %s for write\n",nametemp);return;}
	for(i=0;i<256;++i)
	{
		r=pic.colormap[i+i+i]>>3;
		g=pic.colormap[i+i+i+1]>>3;
		b=pic.colormap[i+i+i+2]>>3;
		j=r | (g<<5) | (b<<10);
		pal[i]=j;
	}
	write(ofile,pal,sizeof(pal));
	close(ofile);

}

main(int argc,char **argv)
{
struct surface s;
int i,j,k,t;
char strippedname[128];
char temp[256];
unsigned char *p;
char setoutputname;

	nexthash=MAXHASHES;
	memset(hashes,0,sizeof(hashes));
	if(!strcmp(argv[0],"pinmap216"))
		use16=1;
	else
		use16=0;
	tiles=malloc(0x100000);
	if(!tiles) nomem(1);
	memset(tiles,0,64);
	numtiles=1;
	i=hashtile(tiles);
	hashes[i].tile=1;
	memset(amap,0,sizeof(amap));

	if(argc<2)
	{
		printf("Specify pcx file(s)...\n");
		exit(0);
	}
	i=1;
	if(!use16)
		strcpy(outputname,"allchr");
	else
		strcpy(outputname,"allchr16");
	memset(amap,0,sizeof(amap));
	setoutputname=0;
	for(i=1;i<argc;++i)
	{
		if(argv[i][0]=='-')
		{
			switch(argv[i][1])
			{
			case 'r': // rotate 90
				rot90=1;
				break;
			}
			continue;
		}
		if(setoutputname)
		{
			strcpy(outputname,argv[i]);
			setoutputname=0;
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

			processpicture();
			processmap(strippedname,pic.xsize>>3,pic.ysize>>3);
			processcmap(strippedname);
			memset(amap,0,sizeof(amap));
		}
	}

	printf("numtiles=%d\n",numtiles);

	sprintf(temp,"%s.chr",outputname);
	i=open(temp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(i<0)
		printf("Could not open file %s\n",temp);
	else
	{
		writetiles(i);
		close(i);
	}
}
