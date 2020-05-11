/*
	Remap written 990616 by David Ashley

	Takes pcx file in, writes to same filename, remaps colors based on
	fixed settings...

	Defined in main() remaptab


*/


#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>


typedef unsigned char uchar;

typedef struct gfxset {
	uchar gs_colormap[768];
	uchar gs_inout[256];
	uchar *gs_pic;
	int gs_xsize;
	int gs_ysize;
} gfxset;



void freegfxset(gfxset *gs) {
	if(gs->gs_pic) free(gs->gs_pic);
	gs->gs_pic=0;
}


#define IBUFFLEN 1024
int ileft=0,ihand=0,byteswide;
unsigned char ibuff[IBUFFLEN],*itake;

int myci() {
	if(!ileft)
	{
		ileft=read(ihand,ibuff,IBUFFLEN);

		if(!ileft) return -1;
		itake=ibuff;
	}
	ileft--;
	return *itake++;
}

int readpcx(char *name,gfxset *gs) {
	int xs,ys;
	int i,j,k;
	int totalsize;
	int width,height;
	unsigned char *bm,*lp;
	int res;

	memset(gs,0,sizeof(gfxset));
	ileft=0;
	ihand=open(name,O_RDONLY);
	if(ihand<0)
		return 1;
	if(myci()!=10) {close(ihand);return 2;} // 10=zsoft .pcx
	if(myci()!=5) {close(ihand);return 3;} // version 3.0
	if(myci()!=1) {close(ihand);return 4;} //encoding method
	if(myci()!=8) {close(ihand);return 5;} //bpp
	xs=myci();
	xs|=myci()<<8;
	ys=myci();
	ys|=myci()<<8;
	width=myci();
	width|=myci()<<8;
	height=myci();
	height|=myci()<<8;
	width=width+1-xs;
	height=height+1-ys;
	for(i=0;i<48+4;++i) myci();
	myci();
	if(myci()!=1) {close(ihand);return 6;} // # of planes
	byteswide=myci();
	byteswide|=myci()<<8;
	i=myci();
	i|=myci()<<8;
//	if(i!=1) {close(ihand);return 7;} // 1=color/bw,2=grey
	for(i=0;i<58;++i) myci();
	totalsize=height*byteswide;
	bm=malloc(totalsize+1);
	if(!bm) {close(ihand);return 8;} // no memory
	gs->gs_pic=bm;
	gs->gs_xsize=width;
	gs->gs_ysize=height;
	while(height--)
	{
		lp=bm;
		i=byteswide;
		while(i>0)
		{
			j=myci();
			if(j<0xc0)
			{
				*lp++=j;
				--i;
			} else
			{
				j&=0x3f;
				k=myci();
				while(j-- && i)
				{
					*lp++=k;
					--i;
				}
			}
		}
		bm+=width;
	}
	lseek(ihand,-0x300,SEEK_END);
	res=read(ihand,gs->gs_colormap,0x300);res=res;
	close(ihand);
	return 0;
	
}

int writepcxlow(char *name, int width, int height, void (*fetch)(), unsigned char *colors) {
	int file;
	unsigned char temp[2048],*p,temp2[2048],*p2;
	int i,j,k;
	int res;

	file=open(name,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return 1;
	p=temp;
	*p++=10;
	*p++=5;
	*p++=1;
	*p++=8;
	*p++=0;
	*p++=0;
	*p++=0;
	*p++=0;
	i=width-1;
	*p++=i;
	*p++=i>>8;
	i=height-1;
	*p++=i;
	*p++=i>>8;
	*p++=width;
	*p++=width>>8;
	*p++=height;
	*p++=height>>8;
	for(i=0;i<49;++i) *p++=0;
	*p++=1; //NPlanes
	i=(width+1) & 0xfffe;
	*p++=width;	//bytes per line
	*p++=width>>8;
	*p++=1;		//palette info
	*p++=0;
	for(i=0;i<58;++i) *p++=0;
	res=write(file,temp,p-temp);res=res;
	for(j=0;j<height;++j)
	{
		fetch(temp,j);
		p=temp;
		p2=temp2;
		i=(width+1) & 0xfffe;
		temp[width]=0;
		k=0;
		while(i)
		{
			while(k<i && k<63 && p[++k]==*p);
			if(k>1)
			{
				*p2++=k | 0xc0;
				*p2++=*p;
				p+=k;
			} else
			{
				if(*p>=0xc0)
					*p2++=0xc1;
				*p2++=*p++;
			}
			i-=k;
			k=0;
		}
		res=write(file,temp2,p2-temp2);res=res;
	}
	res=write(file,"\014",1);res=res;
	res=write(file,colors,0x300);res=res;
	close(file);
	return 0;
}
gfxset *tmpgfxset;

void lfetch(unsigned char *buff,int line)
{
int xsize;
	xsize=tmpgfxset->gs_xsize;
	memmove(buff,tmpgfxset->gs_pic+xsize*line,xsize);
}

int writepcx(char *name,gfxset *gs) {
	int val;
	tmpgfxset=gs;
	val=writepcxlow(name,gs->gs_xsize,gs->gs_ysize,lfetch,gs->gs_colormap);
	return val;
}

void remap(gfxset *gs,uchar *rtab) {
int num;
unsigned char *p,ctemp[768];
int i,j;

	p=gs->gs_pic;
	num=gs->gs_xsize*gs->gs_ysize;

	memcpy(ctemp,gs->gs_colormap,768);
	for(i=0;i<256;++i)
	{
		j=rtab[i];
		memcpy(gs->gs_colormap+j+j+j,ctemp+i+i+i,3);
	}


	while(num)
	{
		*p=rtab[*p];
		++p;
		--num;
	}

}
int makemap(char *name,unsigned char *maptab) {
	int i;
	int file;
	char buffer[16384],*p;
	int from,to;

	for(i=0;i<256;++i) maptab[i]=i;

	file=open(name,O_RDONLY);
	if(file<0)
	{
		printf("Cannot open %s remap list for input\n",name);
		return 1;
	}
	i=read(file,buffer,sizeof(buffer)-1);
	if(i>=0) buffer[i]=0;
	p=buffer;
	while(*p)
	{
		if(sscanf(p,"%d,%d",&from,&to)==2)
				maptab[from]=to;
		while(*p && *p++!='\n');
	}
	return 0;

}
int main(int argc,char **argv)
{
	int i;
	gfxset ags;
	unsigned char remaptab[256];

	if(argc<3)
	{
		printf("Remap <filename.pcx> <ramaptable>\n");
		printf("<remaptable> has the form\n");
		printf("[from #],[to #]\n");
		printf("[from #],[to #]\n");
		printf("[from #],[to #]\n");
		printf("...\n");
		exit(1);
	}
	i=readpcx(argv[1],&ags);
	if(i)
	{
		printf("readpcx error %d\n",i);
		exit(2);
	}

	i=makemap(argv[2],remaptab);
	if(i)
	{
		printf("makemap error %d\n",i);
		exit(3);
	}

	remap(&ags,remaptab);
	i=writepcx(argv[1],&ags);
	if(i)
	{
		printf("writepcx error %d\n",i);
		exit(4);
	}
	return 0;
}
