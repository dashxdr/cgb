#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <inttypes.h>
#include <unistd.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif
struct instance {
	int x,y;
	int px,py;
	int sx,sy;
	int which;
} instances[2048*4];
int numinstances;

unsigned char flipbits[256];
unsigned char temparray[65536];
int xsize,ysize,xsize2,ysize2;
int bganimchrs;
#define OBSIZE 4096
unsigned char oblock[OBSIZE*4];


/*
 .DM# structure
 2 bytes width
 2 bytes height
 x*y words in CGB format (first byte is tile #, second byte is attributes)
 Resultant file is broken into 4096 byte blocks for SWD

 .CHR is normal GMB char format. First char is always 0's.

 .RGB is normal CGB format for color map.

 .HIT is for the tile collision masks
 1 byte # of masks
 #*64 bytes of masks, top to bottom, high bits on left
 1 byte index for each tile # in .CHR file, selecting which mask to use

 .CAN is for background animation
 1 (n) byte # of alternate frames for this set, or 0 for end of list
 1 (c) byte # of characters per frame
 <repeat (c) times>
   2 bytes character offset
   2*n offsets to each character, on 16 byte alignment, (n) = # of frames
 <end repeat>
 ...

*/


#define MAXTILES 2048
#define MAXMASKS 64

#define FORM 0x464f524dL
#define TUME 0x74554d45L
#define ROOM 0x524f4f4dL
#define TSET 0x54534554L
#define DATA 0x44415441L
#define TMGC 0x544d4743L
#define CMAP 0x434d4150L


unsigned char *tumeblock,*tumetake;
int tumelen;
unsigned char *cmap,*room,*tmgc[20];
int numtmgc;
int collisionmap[MAXTILES];
int bganimcollisions[MAXTILES];
unsigned char collisionmasks[MAXMASKS*64];
int nummasks;


unsigned char tiles[MAXTILES*16];
int numtiles=0;

int32_t getlong()
{
	int32_t val;
	val=(*tumetake<<24) | (tumetake[1]<<16) | (tumetake[2]<<8) | tumetake[3];
	tumetake+=4;
	return val;
}

void gettile(int whichset,unsigned char *put,int tnum) {
	int j;
	unsigned char b1,b2,*p;
	int x,y;

	p=tmgc[whichset]+10+(tnum<<6);
	for(y=0;y<8;++y)
	{
		b1=b2=0;
		for(x=0;x<8;++x)
		{
			j=*p++;
			b1<<=1;
			b2<<=1;
			if(j&1) b1|=0x01;
			if(j&2) b2|=0x01;
		}
		*put++=b1;
		*put++=b2;
	}
}


void flushob(unsigned char *p,int n,char *name,int cnt) {
	char nametemp[256];
	int ofile;
	int res;
	sprintf(nametemp,"%s.dm%d",name,cnt);
	ofile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(ofile<0)
	{
		printf("Could not open %s for write\n",nametemp);
		return;
	}
	res=write(ofile,p,n);res=res;
	close(ofile);
}

void domask(int ref,int num) {
	int i;
	unsigned char tempmask[64];

	memcpy(tempmask,tmgc[1]+10+(ref<<6),64);
	for(i=0;i<64;++i) tempmask[i]&=63;
	for(i=0;i<nummasks;++i)
	{
		if(!memcmp(tempmask,collisionmasks+(i<<6),64))
			break;
	}
	if(i==nummasks)
	{
		if(nummasks<MAXMASKS)
		{
			memcpy(collisionmasks+(i<<6),tempmask,64);
			++nummasks;
		} else
		{
			printf("Erro:Too many unique masks in the mask plane! (%d)\n",nummasks);
			--i;
		}
	}
	collisionmap[num]=i;
}

void doremap(int *remaptab,int docollision) {
	int i,j,k;
	unsigned char *p;
	k=xsize*ysize;
	p=temparray+16;
	while(k--)
	{
		if(*p==255 && (p[1]&8)) {p+=2;continue;}
		i=*p | ((p[1]&8) ? 256 : 0);
		i=remaptab[i];
		*p++=i;
		*p=(*p&~8) | (i>=256 ? 8 : 0);
		++p;
	}
	if(docollision)
		for(i=0;i<numtiles+docollision;++i)
		{
			j=remaptab[i];
			if(j<0 || i==j) continue;
			collisionmap[j]=collisionmap[i];
		}
}

void remaparray(void) {
	int tilehist[1024];
	int tilemap[1024];
	int i,j,k,n;
	unsigned char *p;

	for(i=0;i<numtiles;++i) tilemap[i]=i;
	n=0;
	for(i=0;i<numtiles-1;++i)
	{
		if(tilemap[i]!=i) continue;
		for(j=i+1;j<numtiles;++j)
		{
			if(tilemap[j]!=j) continue;
			if(memcmp(tiles+(i<<4),tiles+(j<<4),16)) continue;
			tilemap[j]=tilemap[i];
			++n;
		}
	}
	if(n)
		doremap(tilemap,0);

	memset(tilehist,0,sizeof(tilehist));
	tilehist[0]=1;
	k=xsize*ysize;
	p=temparray+16;
	while(k--)
	{
		i=*p++;
		j=*p++;
		if(i==255 && (j&8)) continue;
		if(j&8) i+=256;
		++tilehist[i];
	}
	n=0;
	for(i=0;i<numtiles;++i) tilemap[i]=i;
	for(i=0;i<numtiles;++i)
	{
		if(tilehist[i]) continue;
		tilehist[i]=-1;
		j=numtiles;
		while(--j>i)
		{
			if(tilehist[j])
			{
				tilemap[j]=i;
				memcpy(tiles+(i<<4),tiles+(j<<4),16);
				break;
			}
		}
		--numtiles;
		++n;
	}
	if(n)
	{
		doremap(tilemap,n);
		printf("Removed %d unused or redundant tiles.\n",n);
	}
}

void writecan(char *name, unsigned char *from, int len) {
	char nametemp[128];
	int canfile;
	int res;

	sprintf(nametemp,"%s.can",name);
	canfile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC,0644);
	if(canfile<0)
	{
		printf("Could not open CAN file %s\n",nametemp);
		return;
	}
	res=write(canfile,from,len);res=res;
	close(canfile);
}

int findtile2(unsigned char *tile) {
	int i;
	i=0;
	while(i<numtiles)
		if(!memcmp(tile,tiles+(i<<4),16)) return i;
		else ++i;
	return -1;
}

int findtile(unsigned char *tile) {
	int i;
	unsigned char temp[16];

	for(i=0;i<16;++i)
		temp[i]=tile[i];
	i=findtile2(temp);
	if(i>=0) return i;

	for(i=0;i<16;++i)
		temp[i]=flipbits[tile[i]];
	i=findtile2(temp);
	if(i>=0) return i;

	for(i=0;i<16;++i)
		temp[i]=tile[15-i];
	i=findtile2(temp);
	if(i>=0) return i;

	for(i=0;i<16;++i)
		temp[i]=flipbits[tile[15-i]];
	return findtile2(temp);
}

int locateinstances(int px,int py,int sx,int sy,int which) {
	int x,y,i,j,k;
	int instancemap[16][16];
	unsigned char temptile[16],*p;
	int used;
	char first=1;
	int t;

	for(y=0;y<sy;++y)
		for(x=0;x<sx;++x)
		{
			gettile(0,temptile,(px+x)+(py+y)*xsize2);
			i=findtile(temptile);
			if(i<0)
			{
				printf("Failed to find instance of bganim chr at (%d,%d)\n",px+x,py+y);
				return 0;
			}
			instancemap[x][y]=i;
		}
	used=0;
	for(j=0;j<=ysize-sy;++j)
		for(i=0;i<=xsize-sx;++i)
		{
			for(y=0;y<sy;++y)
			{
				for(x=0;x<sx;++x)
				{
					p=temparray+16+((i+x+(j+y)*xsize)<<1);
					k=*p | ((p[1]&8) ? 256 : 0);
					if(k!=instancemap[x][y]) break;
				}
				if(x<sx) break;
			}
			if(y<sy) continue;
//printf("Located instance at (%d,%d)\n",i,j);
			instances[numinstances].x=i;
			instances[numinstances].y=j;
			instances[numinstances].px=px;
			instances[numinstances].py=py;
			instances[numinstances].sx=sx;
			instances[numinstances].sy=sy;
			instances[numinstances].which=which;
			++numinstances;
			++used;
			t=0;
			for(y=0;y<sy;++y)
				for(x=0;x<sx;++x) {
					p=temparray+16+((i+x+(j+y)*xsize)<<1);
					if(first) {
						k=*p | ((p[1]&8) ? 256 : 0);
						bganimcollisions[which+t++]=collisionmap[k];
					}
					*p=255;
					p[1]|=8;
				}
			first=0;
		}
	return used;
}

void processbganim(char *name) {
	unsigned char *p,*base;
	int numchr;
	int width,height;
	unsigned char borderchr[64];
	int px,py,sx,sy,numframes;
	unsigned char *o1,*o2;
	int i,j,k;
	unsigned char oblock1[8192*4];
	unsigned char oblock2[8192*4];
	unsigned char keytile[16];
	int n,c;
	int numcantiles;
	int which;

	bganimchrs=0;
	numinstances=0;
	o1=oblock1;
	o2=oblock2;

	p=tmgc[0];
	numchr=p[0]*256+p[1];
	p+=10;
	base=p;
	memset(borderchr,255,64);
	i=0;
	while(i<numchr)
		if(!memcmp(p,borderchr,64)) break;
		else i++,p+=64;
	if(i==numchr)
	{
		writecan(name,(unsigned char *)"",1);
		return;
	}
	i=(p-base)/64;
	width=1;
	while(!memcmp(p,borderchr,64))
	{
		p+=64;
		++width;
	}
	height=numchr/width;
	px=i%width+1;
	py=i/width+1;
	
	xsize2=width;
	ysize2=height;
	numcantiles=0;
	which=0;
	while(py<height)
	{
		p=base+((px+py*width)<<6);
		if(!memcmp(p,borderchr,64))
			break;
		sy=0;
		while(py+sy<height)
		{
			p=base+((px+(py+sy)*width)<<6);
			if(!memcmp(p,borderchr,64)) break;
			++sy;
		}
		sx=0;
		while(px+sx<width)
		{
			p=base+((px+sx+py*width)<<6);
			if(!memcmp(p,borderchr,64)) break;
			++sx;
		}
		numframes=0;
		while(px+(sx+1)*numframes<width)
		{
			p=base+((px+(sx+1)*numframes+py*width)<<6);
			if(!memcmp(p,borderchr,64)) break;
			++numframes;
		}
		printf("At (%d,%d), size (%d,%d),  %d frames\n",px,py,sx,sy,numframes);
		if(!locateinstances(px,py,sx,sy,which)) goto skip;
		remaparray();
		*o1++=numframes;
		*o1++=sx*sy;
		for(j=0;j<sy;++j)
		{
			for(i=0;i<sx;++i)
			{
				n=which++;
				*o1++=n;
				*o1++=n>>8;
				for(k=0;k<numframes;++k)
				{
					gettile(0,keytile,k*(sx+1)+(px+i)+(py+j)*width);
					for(n=0;n<numcantiles;++n)
						if(!memcmp(oblock2+(n<<4),keytile,16)) break;
					if(n==numcantiles)
					{
						++numcantiles;
						memcpy(o2,keytile,16);
						o2+=16;
					}
					n<<=4;
					*o1++=n;
					*o1++=n>>8;
				}
			}
		}
skip:
		py+=sy+1;
	}
	bganimchrs=which;
	for(k=0;k<numinstances;++k)
	{
		px=instances[k].x;
		py=instances[k].y;
		sx=instances[k].sx;
		sy=instances[k].sy;
		which=numtiles+instances[k].which;
		for(j=0;j<sy;++j)
			for(i=0;i<sx;++i)
			{
				p=temparray+16+((px+i+(py+j)*xsize)<<1);
				*p=which;
				p[1]=(p[1]&~8) | (which>=256 ? 8 : 0);
				++which;
			}
	}

	*o1++=0;
	while((o1-oblock1)&15) *o1++=0;
	k=o1-oblock1;
	p=oblock1;
	while((n=*p++))
	{
		c=*p++;
		while(c--)
		{
			i=*p | (p[1]<<8);
			i=(numtiles+i)<<4;
			*p++=i;
			*p++=i>>8;
			i=n;
			while(i--)
			{
				j=p[0] | (p[1]<<8);
				j+=k;
				*p++=j;
				*p++=j>>8;
			}
		}
	}
	memcpy(o1,oblock2,o2-oblock2);
	o1+=o2-oblock2;
	writecan(name,oblock1,o1-oblock1);
}

void processtriggers(char *name) {
	int i,j,n,n2;
	unsigned char *p,*op;
	char tname[128];
	int res;

	op=oblock;


	p=room+0x10+xsize*ysize*4;
	for(j=0;j<ysize;++j)
	{
		for(i=0;i<xsize;++i)
		{
			n=((p[2]<<8) | p[3]) & 0x3ff;
			p+=4;
			if(!n) continue;
			if(i<xsize-1)
				n2=((p[2]<<8) | p[3]) & 0x3ff;
			else
				n2=0;
//printf("Trigger %d at (%d,%d)\n",n,i,j);
			*op++=n;
			*op++=n2;
			*op++=i;
			*op++=i>>8;
			*op++=j;
			*op++=j>>8;
			if(n2)
			{
				++i;
				p+=4;
			}
		}
	}
	*op++=0;
	*op++=0;
	sprintf(tname,"%s.trg",name);
	i=open(tname,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(i<0)
	{
		printf("Failed to create trigger file %s\n",tname);
		return;
	}
	res=write(i,oblock,op-oblock);res=res;
	close(i);
}

void processroom(char *name) {
	unsigned char *p;
	int i,j,k;
	int *map;
	int xflip,yflip,pri;
	int palette;
	unsigned char temptile[16];
	int oin;
	int ocnt;
	unsigned char v1;
	char nametemp[256];
	int res;

	map=malloc(65536*sizeof(int));
	if(!map) {printf("No memory for map\n");return;}
	memset(map,0,65536*sizeof(int));
	p=room;
	xsize=(p[4]<<8) | p[5];
	ysize=(p[6]<<8) | p[7];
	p+=16;
	k=xsize*ysize;
	ocnt=0;
	memset(temparray,0,16);
	temparray[0]=xsize;
	temparray[1]=xsize>>8;
	temparray[2]=ysize;
	temparray[3]=ysize>>8;
	oin=16;
	numtiles=1;
	memset(tiles,0,16); // tile 0 is all 0's
	nummasks=1;
	collisionmap[0]=0;
	memset(collisionmasks,0,64); // collision mask 0 is all 0's
	while(k--)
	{
		v1=*p++;
		p++;
		xflip=v1&0x40 ? ~0 : 0;
		yflip=v1&0x20 ? ~0 : 0;
		pri  =v1&0x10 ? ~0 : 0;
		j=((*p<<8) | p[1]);
		p+=2;
		if(j && !map[j])
		{
			gettile(0,temptile,j-1);
			for(i=0;i<numtiles;++i)
				if(!memcmp(tiles+(i<<4),temptile,16)) break;
			if(i==numtiles)
			{
				memcpy(tiles+(i<<4),temptile,16);
				if(numtmgc>1)
					domask(j-1,i);
				++numtiles;
			}
			map[j]=i;
		}
		if(!(v1&0x80))
			palette=j ? ((tmgc[0][((j-1)<<6)+10])>>4)&7 : 0;
		else
			palette=v1&7;

		temparray[oin++]=map[j];
		temparray[oin++]=(pri&0x80) | (xflip&0x20) | (yflip&0x40) | (map[j]>=256 ? 8 : 0) | palette;

	}


/*

	k=0;
	for(j=0;j<ysize;j+=2)
	{
		for(i=0;i<xsize;i+=2)
		{
			tap=temparray+16+(j*xsize+i<<1);
			p=oblock+(k<<3);
			*p++=*tap;
			*p++=tap[1];
			*p++=tap[2];
			*p++=tap[3];
			tap+=xsize<<1;
			*p++=*tap;
			*p++=tap[1];
			*p++=tap[2];
			*p++=tap[3];
			p-=8;
			for(t=0;t<k;++t)
			{
				if(!memcmp(p,oblock+(t<<3),8)) break;
			}
			if(t==k && k<(sizeof(oblock)>>3)) ++k;
		}
	}
	printf("%d unique 2x2 sets\n",k);
*/


	remaparray();
	processbganim(name);
	printf("%d unique tiles, %d bg anim chrs, %d total\n",numtiles,bganimchrs,
		numtiles+bganimchrs);

	if(numtmgc>1)
	{
		p=oblock;
		*p++=nummasks;
		for(i=0;i<nummasks;++i)
		{
			memcpy(p,collisionmasks+(i<<6),64);
			p+=64;
		}
		for(i=0;i<numtiles;++i)
			*p++=collisionmap[i];
		for(i=0;i<bganimchrs;++i)
			*p++=bganimcollisions[i];
		sprintf(nametemp,"%s.hit",name);
		i=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
		if(i<0)
			printf("Could not open %s for write\n",nametemp);
		else
		{
			res=write(i,oblock,p-oblock);res=res;
			close(i);
		}
	}
	ocnt=0;
	j=0;
	while(oin>0)
	{
		i=oin>OBSIZE ? OBSIZE : oin;
		flushob(temparray+j,i,name,ocnt++);
		oin-=i;
		j+=i;
	}
	if(room[13]>1)
		processtriggers(name);

}

void processcmap(char *name) {
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
		r=cmap[j+j+j]>>3;
		g=cmap[j+j+j+1]>>3;
		b=cmap[j+j+j+2]>>3;
		j=r | (g<<5) | (b<<10);
		nametemp[i+i]=j;
		nametemp[i+i+1]=j>>8;
	}
	res=write(ofile,nametemp,64);res=res;
	close(ofile);

}
void processtmgc(char *name) {
	int ofile;
	int i,j;
	char nametemp[256];
	int res;
	if((numtiles<<4)<=4096)
	{
		sprintf(nametemp,"%s.chr",name);
		ofile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
		if(ofile<0) {printf("Cannot open %s for write\n",nametemp);return;}
		res=write(ofile,tiles,numtiles<<4);res=res;
		close(ofile);
	} else
	{
		i=0;
		j=numtiles<<4;
		while(j)
		{
			sprintf(nametemp,"%s.ch%c",name,!i ? 'r' : i+'0');
			ofile=open(nametemp,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
			if(ofile<0) {printf("Cannot open %s for write\n",nametemp);return;}
			j-=write(ofile,tiles+i*0x1800,(j>0x1800) ? 0x1800 : j);
			close(ofile);
			++i;
		}
	}

}



int dumptume(char *name)
{
	int file;
	int len;
	int type1,type2,size;
	char basename[256],*p;
	int res;

	strcpy(basename,name);
	p=basename+strlen(basename)-1;
	while(p>basename)
	{
		if(*p=='.')
		{
			*p=0;
			break;
		}
		--p;
	}

	file=open(name,O_RDONLY|O_BINARY);
	if(file<0) return 1;
	len=lseek(file,0L,SEEK_END);
	if(len<0) {close(file);return 2;}
	tumeblock=malloc(len);
	if(!tumeblock) {close(file);return 3;}
	tumelen=len;
	lseek(file,0L,SEEK_SET);
	res=read(file,tumeblock,len);res=res;
	close(file);
	room=cmap=0;
	tumetake=tumeblock;
	numtmgc=0;
	while((!room || numtmgc<3 || !cmap) && tumetake-tumeblock<len)
	{
		type1=getlong();
		if(type1==FORM)
		{
			getlong();
back:
			type1=getlong();
			type2=getlong();
		} else
			type2=0;
		size=getlong();
		if(type1==TUME && type2==FORM) goto back;
		if(type1==ROOM && type2==DATA)
		{
			room=tumetake;
		}
		if(type1==TMGC && numtmgc<4)
		{
//printf("tmgc %d:%x\n",numtmgc,tumetake-tumeblock);
			tmgc[numtmgc]=tumetake;
			++numtmgc;
		}
		if(type1==CMAP)
		{
			cmap=tumetake;
		}
		tumetake+=(size+1) & ~1;
	}
	if(!room || !numtmgc || !cmap)
	{
		printf("I can't read this TUME file, stuff is missing.\n");
		if(!room) printf("No room block\n");
		if(!numtmgc) printf("No tmgc block(s)\n");
		if(!cmap) printf("No cmap block\n");
		return 4;
	}
	printf("Everything in order\n");
	processroom(basename);
	processcmap(basename);
	processtmgc(basename);

	return 0;
}

int main(int argc,char **argv) {
	int i,j,k;
	if(argc<2)
	{
		printf("Use: tumerd <file.prj> ...\n");
		exit(1);
	}
	for(i=0;i<256;++i)
	{
		k=0;
		for(j=0;j<8;++j)
		{
			if(i&(0x01<<j))
				k|=0x80>>j;
		}
		flipbits[i]=k;
	}


	i=1;
	while(i<argc)
		dumptume(argv[i++]);
	return 0;
}
