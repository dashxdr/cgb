#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <inttypes.h>
#include <unistd.h>
#include <stdarg.h>

/*
converts .spr file into agb sprite format
switches:
-256 = store as 256 color sprite (default is 16)
-nopal = don't output palette (default is to output palette)
-header   = output header file (default is to not output header file)
-nocompress = don't compress output file
-center = makes it so figure can be rotated.
-r = rotate all frame 90 degrees to the right

uword nframes (0x8000 bit = 1 for 256 color)
repeat for nframes
 uword size
 word dx,dy
 long offset to colormap (from start of data), or 0 for no palette
 long offset to character data (from start of data), or 0 for no data
end
palette
character data. Duplicate frames share data

when plotting:
x position of sprite is
xflip  no:x+maindx+dx
xflip yes:x+maindx-dx-width+1
y position of sprite is
yflip  no:y+maindy+dy
yflip yes:y+maindy-dy-height+1

sizes:
 0 =  8 x  8   11    1
 1 = 16 x 16   22    4
 2 = 32 x 32   44   16
 3 = 64 x 64   88   64
 4 = 16 x  8   21    2
 5 = 32 x  8   41    4
 6 = 32 x 16   42    8
 7 = 64 x 32   84   32
 8 =  8 x 16   12    2
 9 =  8 x 32   14    4
10 = 16 x 32   24    8
11 = 32 x 64   48   32

*/

typedef int32_t LONG;
typedef uint32_t ULONG;

int xsizes[12]={1,2,4,8,2,4,4,8,1,1,2,4};
int ysizes[12]={1,2,4,8,1,1,2,4,2,4,4,8};

int rot90=0;

#define MAXWIDTH 256
#define MAXHEIGHT 256
#define MAXFRAMES 2048

#define MAXOUT 0x40000

int infile;
int sprframes;
int sprwidth;
int sprheight;
int osprwidth;
int osprheight;
int minx,miny,maxx,maxy;

int header=0;
int nopal=0;
int c256=0;
int nocompress=0;
int center=0;

unsigned char outblock[MAXOUT],*dataout,*outpoint,compressed[MAXOUT];
int datacount;
int headerlen;

int outfile;

void striptail(char *dest,char *src) {
	char *p;
	strcpy(dest,src);
	p=dest+strlen(src);
	while(p>dest)
		if(*--p=='.')
			break;
	if(*p=='.') *p=0;
}

void bout(int val) {
	*outpoint++=val;
}
void wout(int val) {
	bout(val);
	bout(val>>8);
}
void lout(int val) {
	wout(val);
	wout(val>>16);
}

void owrite(unsigned char *take,int len) {
	while(len--) bout(*take++);
}


unsigned char palette[768],*bm;
unsigned char frame[MAXWIDTH*MAXHEIGHT];

void nomem(int val)
{
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
	if(rot90)
	{
		osprwidth=sprwidth;
		osprheight=sprheight;
		sprheight=osprwidth;
		sprwidth=osprheight;
	}
	bm=malloc(sprwidth*sprheight);
	if(!bm) nomem(1);
	return 0;
}

unsigned char getdot(int x,int y)
{
	return frame[x+y*sprwidth];
}

void getspr(void) {
	unsigned char *p;
	int i,j;
	char toss[2];
	unsigned char line[1024];
	int res;

	res=read(infile,toss,2);res=res; // tic count for this frame
	res=read(infile,palette,768);res=res;
	if(!rot90) {
		res=read(infile,frame,sprwidth*sprheight);res=res;
	} else {
		for(j=0;j<osprheight;++j)
		{
			res=read(infile,line,osprwidth);res=res;
			p=frame+osprheight-1-j;
			for(i=0;i<osprwidth;++i,p+=osprheight)
				*p=line[i];
		}
	}
}

void getextremes() {
	int x,y;

	for(x=0;x<sprwidth;++x)
	{
		for(y=0;y<sprheight;++y)
			if(getdot(x,y)) break;
		if(y<sprheight) break;
	}
	minx=x;

	for(x=sprwidth-1;x>=0;--x)
	{
		for(y=0;y<sprheight;++y)
			if(getdot(x,y)) break;
		if(y<sprheight) break;
	}
	maxx=x;

	for(y=0;y<sprheight;++y)
	{
		for(x=0;x<sprwidth;++x)
			if(getdot(x,y)) break;
		if(x<sprwidth) break;
	}
	miny=y;

	for(y=sprheight-1;y>=0;--y)
	{
		for(x=0;x<sprwidth;++x)
			if(getdot(x,y)) break;
		if(x<sprwidth) break;
	}
	maxy=y;
}

int numpalettes=0;
int paletteoffs[MAXFRAMES];

void addpalette() {
	int i;
	int numcolors;
	unsigned char tp[512];
	int r,g,b,c;

	if(nopal)
	{
		lout(0);
		return;
	}
	numcolors=c256 ? 256 : 16;
	for(i=0;i<numcolors;++i)
	{
		r=(palette[i+i+i]>>3)&0x1f;
		g=(palette[i+i+i+1]>>3)&0x1f;
		b=(palette[i+i+i+2]>>3)&0x1f;
		c=r | (g<<5) | (b<<10);
		tp[i+i]=c;
		tp[i+i+1]=c>>8;
	}
	for(i=0;i<numpalettes;++i)
	{
		if(paletteoffs[i]<0) continue;
		if(!memcmp(tp,dataout+paletteoffs[i],numcolors<<1))
			break;
	}
	if(i<numpalettes)
	{
		paletteoffs[numpalettes++]=-1;
		lout(paletteoffs[i]+headerlen);
		return;
	}
	paletteoffs[numpalettes++]=datacount;
	lout(datacount+headerlen);
	memcpy(dataout+datacount,tp,numcolors<<1);
	datacount+=numcolors<<1;
}

int numframes=0;
int frameoffs[MAXFRAMES];

void addframe(int tx,int ty,int sizex,int sizey) {
	int i,j,x,y;
	int x2,y2;
	unsigned char tf[64*64],*p,*p2,*p3;

	p=tf;
	for(y=ty;y<ty+sizey;y+=8)
		for(x=tx;x<tx+sizex;x+=8)
			for(j=0;j<8;++j)
				for(i=0;i<8;++i)
				{
					x2=x+i;
					y2=y+j;
					if(x2<sprwidth && y2<sprheight && x2>=0 && y2>=0)
						*p++=getdot(x+i,y+j);
					else
						*p++=0;
				}

	if(!c256)
	{
		p2=p3=tf;
		while(p3<p)
		{
			*p2++=(*p3&15) | ((p3[1]&15)<<4);
			p3+=2;
		}
		p=p2;
	}
	j=p-tf;
	for(i=0;i<numframes;++i)
	{
		if(frameoffs[i]<0) continue;
		if(!memcmp(tf,dataout+frameoffs[i],j))
			break;
	}
	if(i<numframes)
	{
		frameoffs[numframes++]=-1;
		lout(frameoffs[i]+headerlen);
		return;
	}
	frameoffs[numframes++]=datacount;
	lout(datacount+headerlen);
	memcpy(dataout+datacount,tf,j);
	datacount+=j;

}

void hprintf(int f,char *str, ...) {
	char buff[1024];

	va_list ap;
	va_start(ap, str);
	vsprintf(buff,str, ap);
	va_end(ap);
	int res=write(f,buff,strlen(buff));res=res;
}

#define MAXOVERALL 2048

unsigned char costsize[MAXOVERALL];
unsigned char costdist[MAXOVERALL];

int maxdist,maxsize;
int bestoff,bestlen;
int totalcost;

int ocount;
int ofile;
ULONG *obuff;

void co(ULONG value)
{
	obuff[ocount++]=value;
}

int bitsin;
ULONG workinglong;
void bitsout(int numbits,int val)
{
//printf("Writing %d bits:%x\n",numbits,val);
	if(bitsin+numbits<=32)
	{
		workinglong|=val<<bitsin;
		bitsin+=numbits;
	} else
	{
	int t1,t2,t3;
		t1=32-bitsin;
		t3=numbits-t1;
		if(t1)
		{
			t2=val&((1<<t1)-1);
			val>>=t1;
			workinglong|=t2<<bitsin;
		}
		co(workinglong);
		workinglong=val;
		bitsin=t3;
	}
}

int complook(unsigned char *at,int before,int after) {
	int i,k;
	int ratio,bestratio,cost;

	if(!before) return -1;
	if(!after) return -2;
	bestratio=bestoff=bestlen=0;
	i=1;
	if(before>maxdist) before=maxdist;
	if(after>maxsize) after=maxsize;
	while(i<=before)
	{
		k=0;
		while(k<after)
			if(at[-i+k]!=at[k]) break;
			else k++;
		if(k>1)
		{
			cost=costdist[i-1]+costsize[k];
			if(cost<9*k && (ratio=(k<<16)/cost) > bestratio)
			{
				bestlen=k;
				bestoff=i;
				bestratio=ratio;
			}
		}
		i++;
	}
	if(bestlen>1) return 1;
	return 0;
}

void dumpliteral(unsigned char *from,int len)
{
	if(!len) return;
	while(len)
	{
		bitsout(1,0);
		bitsout(8,from[-len]);
		len--;
	}
}
dumpcopy()
{
int t;
//printf("bestlen=%d\n",bestlen);
	if(bestlen==2)
		bitsout(2,1);
	else if(bestlen>=3 && bestlen<=5)
		{bitsout(2,3);bitsout(2,bestlen-2);}
	else if(bestlen>=6 && bestlen<=20)
		{bitsout(4,3);bitsout(4,bestlen-5);}
	else
		{bitsout(8,3);bitsout(8,bestlen-20);}

	if(bestoff<=0x20)
		{bitsout(2,0);bitsout(5,bestoff-1);}
	else if(bestoff<=0xa0)
		{bitsout(2,1);bitsout(7,bestoff-0x21);}
	else if(bestoff<=0x2a0)
		{bitsout(2,2);bitsout(9,bestoff-0xa1);}
	else
		{bitsout(2,3);bitsout(10,bestoff-0x2a1);}
}
int docompress(char *to,char *from,int len)
{
int offset;
int i,j,k;
int literal;
int val;
int out;
	ocount=0;
	obuff=(unsigned long *)to;
	out=offset=literal=0;
	totalcost=0;
	bitsin=0;
	while(offset<len)
	{
		val=complook(from+offset,offset,len-offset);
		switch(val)
		{
		case 0: /* couldn't find anything */
		case -1: /* nothing before */
			++offset;
			++literal;
			totalcost+=9;
			break;
		case -2: /* nothing after */
			break;
		default:
			dumpliteral(from+offset,literal);
			literal=0;
			i=costdist[bestoff-1]+costsize[bestlen];
			totalcost+=i;
//if(verbose) printf("%5d bits:Copy:(%d) %d bytes\n",i,-bestoff,bestlen);
			offset+=bestlen;
			dumpcopy();
			break;
		}
	}
	dumpliteral(from+offset,literal);
	bitsout(16,3);
	bitsout(32,0);
	return ocount<<2;
}
initswd()
{
int i;
	for(i=0;i<MAXOVERALL;++i)
	{
		if(i==2) costsize[i]=2;
		else if(i>=3 && i<=5) costsize[i]=4;
		else	if(i>=6 && i<=20) costsize[i]=8;
		else costsize[i]=16;
		if(i<0x20) costdist[i]=7;
		else if(i<0xa0) costdist[i]=9;
		else if(i<0x2a0) costdist[i]=11;
		else costdist[i]=12;
	}
	maxdist=0x6a0;
	maxsize=256;
}

int main(int argc,char **argv) {
	int res;
	int i,j;
	int needx,needy;
	int bestsize,bestnum;
	int dx,dy;
	char basename[256];
	char tempname[256];
	int extralen;
	int headerfile;
	unsigned char t4[4];

	i=1;
	while(i<argc && argv[i][0]=='-')
	{
		if(!strcmp(argv[i]+1,"256"))
			c256=1;
		else if(!strcmp(argv[i]+1,"nopal"))
			nopal=1;
		else if(!strcmp(argv[i]+1,"header"))
			header=1;
		else if(!strcmp(argv[i]+1,"nocompress"))
			nocompress=1;
		else if(!strcmp(argv[i]+1,"center"))
			center=1;
		else if(!strcmp(argv[i]+1,"r"))
			rot90=1;
		else
		{
			printf("Unknown switch %s\n",argv[i]);
			exit(-1);
		}
		++i;
	}
	if(i==argc)
	{
		printf("Use: %s [-256] [-nopal] [-header] <sprfile>\n",argv[0]);
		printf("-256         = 256 color (default 16)\n");
		printf("-nopal       = Don't include palette (default is to do so)\n");
		printf("-header      = Output .h file (default is to not do so)\n");
		printf("-nocompress  = Don't compress output file (default is to compress)\n");
		printf("-center      = move reference point to center of frame\n");
		exit(0);
	}
	infile=open(argv[i],O_RDONLY);
	if(infile<0)
	{
		fprintf(stderr,"Couldn't open %s for read.\n",argv[i]);
		exit(1);
	}
	res=readsprheader();
	if(res<0)
	{
		fprintf(stderr,"Error reading SPR header %d\n",res);
		exit(2);
	}
	striptail(basename,argv[i]);
	sprintf(tempname,"%s.bin",basename);
	if(header)
	{
		sprintf(tempname,"%s.h",basename);
		headerfile=open(tempname,O_WRONLY|O_CREAT|O_TRUNC,0644);
		if(headerfile<0)
		{
			fprintf(stderr,"Could not open %s for write.\n",tempname);
			exit(-10);
		}
		hprintf(headerfile,"extern unsigned char _binary_%s_bin_start[];\n",
			basename);
		close(headerfile);
	}
	printf("agbspr: %s\n",basename);

	headerlen=(1+7*(sprframes-1))<<1;
	extralen=((headerlen+15)&~15)-headerlen;
	headerlen+=extralen;
	outpoint=outblock;
	dataout=outblock+headerlen;
	datacount=0;

	wout(sprframes + (c256 ? 0x8000 : 0));

	for(i=0;i<sprframes;++i)
	{
		getspr();
		getextremes();
		if(!i)
		{
			if(minx!=maxx || miny!=maxy)
			{
				printf("First frame should have only 1 non-zero pixel\n");
				exit(-1);
			}
			dx=minx;
			dy=miny;
/*
			wout(-dx);
			wout(-dy);
*/
		} else if(minx>maxx)
		{
			printf("Frame %d  empty\n",i);
			wout(0);
			wout(0);
			wout(0);
			lout(0);
			lout(0);
		} else
		{
			if(center)
			{
//printf("(%d,%d) center, (%d,%d) to (%d,%d)\n",dx,dy,minx,miny,maxx,maxy);
				int xs,ys;
				xs=ys=8;
				while(xs<32 && (dx-minx>xs || maxx-dx>=xs)) xs<<=1;
				while(ys<32 && (dy-miny>ys || maxy-dy>=ys)) ys<<=1;

				if(xs>ys) ys=xs;
				else if(ys>xs) xs=ys;

				j=0;
				if(dx-minx>xs || maxx-dx>=xs) j=1;
				if(dy-miny>ys || maxy-dy>=ys) j=1;
				minx=dx-xs;
				miny=dy-xs;
				maxx=dx+xs-1;
				maxy=dy+ys-1;

				if(j) printf("Warning, frame was too big, clipped.\n");
//printf("(%d,%d) center, (%d,%d) to (%d,%d)\n",dx,dy,minx,miny,maxx,maxy);
			}
			needx=(maxx-minx+8)>>3;
			needy=(maxy-miny+8)>>3;
			bestnum=-1;
			bestsize=256;
			for(j=0;j<12;++j)
			{
				if(xsizes[j]<needx || ysizes[j]<needy) continue;
				if(xsizes[j]*ysizes[j]>=bestsize) continue;
				bestsize=xsizes[j]*ysizes[j];
				bestnum=j;
			}
			if(bestnum<0)
			{
				printf("This sprite is bigger than 64x64.\n");
				exit(-4);
			}
			needx=xsizes[bestnum]<<3;
			needy=ysizes[bestnum]<<3;

			printf("Frame %d  (%d,%d) to (%d,%d)  %dx%x at (%d,%d)\n",i,
				minx,miny,maxx,maxy,xsizes[bestnum],ysizes[bestnum],
				minx-dx,miny-dy);
			wout(bestnum);
			wout(minx-dx);
			wout(miny-dy);
			addpalette();
			addframe(minx,miny,needx,needy);
		}
	}
	while(extralen--) bout(0);

	sprintf(tempname,"%s.bin",basename);
	outfile=open(tempname,O_WRONLY|O_CREAT|O_TRUNC,0644);
	if(outfile<0)
	{
		printf("Could not open output file %s\n",tempname);
		exit(-2);
	}
	datacount+=headerlen;

	if(nocompress) {
		res=write(outfile,outblock,datacount);res=res;
	} else
	{
		initswd();
		t4[0]=datacount;
		t4[1]=datacount>>8;
		t4[2]=datacount>>16;
		t4[3]=datacount>>24;
		res=write(outfile,t4,4);res=res;

		res=write(outfile,compressed,
			docompress(compressed,outblock,datacount));
		res=res;
	}
	close(outfile);
	return 0;
}
