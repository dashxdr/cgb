#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/types.h>
#include <unistd.h>

#include "mgb.h"



char buttonu,buttond,buttonl,buttonr;
char buttonselect,buttonstart,buttona,buttonb;
char hMachine;

unsigned short *grabsave;

void drawprintf(int x,int y,char *p,...);

char backgroundname[256];

int videowidth=320;
int videoheight=200;
int videosize=64000;
char paused=0;
unsigned char fast=0;
unsigned char interact=0;

int framecount;

unsigned char *ramblock,*romblock,*vline,*hstat,*videoblock;
unsigned char *stripblock,**striplookupblock,**striplookup;
unsigned char hmode;
unsigned char bgmap[4],ob0map[4],ob1map[4];


struct acolor
{
	unsigned char red,green,blue;
};
struct acolor thecmap[256];


int oldmode;
char *take;

void colors(void)
{
int i;
	for(i=0;i<256;i+=4)
	{
		set_color(i,255,255,255);
		set_color(i+1,192,192,192);
		set_color(i+2,128,128,128);
		set_color(i+3,64,64,64);
	}
}

/*
int getline(char *p)
{
char ch;
char *p2;
	p2=p;
	while(ch=*take)
	{
		++take;
		if(ch=='\n') break;
		*p2++=ch;
	}
	*p2=0;
	return *p;
}
*/

void nomem(int code)
{
	printf("No memory %d\n",code);
	exit(1);
}


void fixname(char *dest,char *src)
{
char *p,ch;
	p=src+strlen(src);
	while(p>src)
	{
		ch=p[-1];
		if(ch=='/' || ch=='\\' || ch==':') break;
		--p;
	}
	while(*p && *p!='.')
		*dest++=toupper(*p++);
	*dest=0;
}


void drawstring(int x,int y,char *p)
{
int ox;
char ch;
	ox=x;
	while((ch=*p++))
	{
		if(ch=='\n')
		{
			x=ox;
			y+=8;
		} else
		{
			drawcharxy(x,y,ch);
			x+=8;
		}
	}
}
void drawprintf(int x,int y,char *p,...)
{
char buffer[256];
va_list ap;
	va_start(ap, p);
	vsprintf(buffer,p,ap);
	va_end(ap);
	drawstring(x,y,buffer);
}


void initmachine(void)
{
int i,j;
unsigned char *p1,*p2;

	hMachine=CGB;
	ramblock=malloc(RAMSIZE);
	romblock=malloc(ROMSIZE);
	videoblock=malloc(144*160);
	stripblock=malloc(STRIPSIZE);
	striplookupblock=malloc(512*sizeof(char *));
	grabsave=malloc(160*144*sizeof(short));
	vline=malloc(20000);
	hstat=malloc(20000);
	if(!ramblock || !romblock || !vline || !hstat || !videoblock) exit(2);
	if(!stripblock || !striplookupblock || !grabsave) exit(2);

	memset(romblock,0,ROMSIZE);

	for(i=0;i<256;++i)
	{
		striplookupblock[i]=stripblock+(i<<6);
		striplookupblock[i+256]=stripblock+(((i<128) ? i+256 : i) << 6);
	}
	striplookup=striplookupblock;

	memset(hstat,0,20000);
	p1=vline;
	p2=hstat;
	for(i=0;i<154;++i)
	{
		if(i==0)
		{
			j=114;while(j--) {*p1++=i;*p2++=0x11;}
			j= 20;while(j--) {*p1++=i;*p2++=0x22;}
			j= 42;while(j--) {*p1++=i;*p2++=0x83;}
			j= 52;while(j--) {*p1++=i;*p2++=0x08;}
		} else if(i<144)
		{
			j= 20;while(j--) {*p1++=i;*p2++=0x22;}
			j= 42;while(j--) {*p1++=i;*p2++=0x83;}
			j= 52;while(j--) {*p1++=i;*p2++=0x08;}
		} else
		{
			j=114;while(j--) {*p1++=i;*p2++=0x11;}
		}
	}

}
int loadrom(char *name)
{
int file;
char namecopy[128];
	int res;

	file=open(name,O_RDONLY);
	if(file<0)
	{
		sprintf(namecopy,"%s.gb",name);
		file=open(namecopy,O_RDONLY);
		if(file<0)
			return -1;
	}
	res=read(file,romblock,ROMSIZE);
	close(file);
	loadsymbols(name);
	return 0;
}

int online;
unsigned char spritelinebuff[176];
unsigned char spritepriority[176];

void buildspriteline(int x3,int line,int pripick)
{
unsigned char *p,*strip,*map,pri;
int i,j,k;
int t;
int ysize;
int xflip;

	if(!(ramblock[0xff40]&2)) return;

	pripick=pripick ? 0x80 : 0;
	ysize=(ramblock[0xff40]&4) ? 16 : 8;
	for(p=ramblock+0xfe00;p<ramblock+0xfea0 && online<10;p+=4)
	{
		if(hMachine==GMB)
		{
			if((pripick^p[3])&0x80) continue;
			if((p[1]^x3)&7) continue;
		}
		j=line-(*p-16);

		if(j<0 || j>=ysize) continue;
		t=p[2];
		if(ysize==16) t&=~1;
		if(p[3]&0x40) j^=ysize-1;
		strip=stripblock+(((t<<3)+j)<<3);
		if(hMachine==CGB && (p[3]&8)) strip+=0x180<<6;
		xflip=(p[3]&0x20) ? 7 : 0;
		map=(p[3]&0x10) ? ob1map : ob0map;

		i=p[1];
		if(i>=168) continue;
		++online;
		pri=(p[3]&0x80) ? 1 : 2;
		if(hMachine==GMB)
		{
			for(j=0;j<8;++j,++i)
			{
				if((k=strip[j^xflip]) && pri>spritepriority[i])
				{
					spritepriority[i]=pri;
					spritelinebuff[i]=map[k];
				}
			}
		}
		else
		{
			t=32|((p[3]&7)<<2);
			for(j=0;j<8;++j,++i)
			{
				if((k=strip[j^xflip]) && pri>spritepriority[i])
				{
					spritepriority[i]=pri;
					spritelinebuff[i]=t|k;
				}
			}
		}
	}
}

void buildline(int line)
{
unsigned char *strip,pri;
unsigned register char *p,*pp;
int i,j,k;
int scx,scy,lcdc;
int t;
unsigned short *p2,*p3;
unsigned char linebuff[176],priority[176];
unsigned short *gs;

	memset(priority,0,sizeof(priority));
	scx=ramblock[0xff43];
	scy=ramblock[0xff42];
	p=linebuff+8-(scx&7);
	pp=priority+8-(scx&7);
	lcdc=ramblock[0xff40];
	if(!(lcdc&0x80) || (hMachine==GMB && !(lcdc&0x01)))
	{
		memset(linebuff,0,sizeof(linebuff));
		goto skip;
	}
	t=(lcdc&8) ? 0x9c00 : 0x9800;
	t+=(((line+scy)&255)>>3)<<5;
	scy=((line+scy)&7)<<3;
	for(i=0;i<168;i+=8)
	{
		j=t+(((i+scx)&255)>>3);
		if(hMachine==GMB)
		{
			strip=striplookup[ramblock[j]]+scy;
			*p=bgmap[*strip];
			p[1]=bgmap[strip[1]];
			p[2]=bgmap[strip[2]];
			p[3]=bgmap[strip[3]];
			p[4]=bgmap[strip[4]];
			p[5]=bgmap[strip[5]];
			p[6]=bgmap[strip[6]];
			p[7]=bgmap[strip[7]];
		} else
		{
			strip=striplookup[ramblock[j]];
			j=ramblock[j+0x8000];
			pri=(j&0x80) ? 2 : 0;
			if(j&8) strip+=0x180<<6;
			k=(j&7)<<2;
			if(j&0x40)
				strip+=scy^(7<<3);
			else
				strip+=scy;
			if(j&0x20)
			{
				p[7]=k|*strip;
				p[6]=k|strip[1];
				p[5]=k|strip[2];
				p[4]=k|strip[3];
				p[3]=k|strip[4];
				p[2]=k|strip[5];
				p[1]=k|strip[6];
				*p=k|strip[7];
				if(*strip) pp[7]=pri;
				if(strip[1]) pp[6]=pri;
				if(strip[2]) pp[5]=pri;
				if(strip[3]) pp[4]=pri;
				if(strip[4]) pp[3]=pri;
				if(strip[5]) pp[2]=pri;
				if(strip[6]) pp[1]=pri;
				if(strip[7]) *pp=pri;

			} else
			{
				*p=k|*strip;
				p[1]=k|strip[1];
				p[2]=k|strip[2];
				p[3]=k|strip[3];
				p[4]=k|strip[4];
				p[5]=k|strip[5];
				p[6]=k|strip[6];
				p[7]=k|strip[7];
				if(*strip) *pp=pri;
				if(strip[1]) pp[1]=pri;
				if(strip[2]) pp[2]=pri;
				if(strip[3]) pp[3]=pri;
				if(strip[4]) pp[4]=pri;
				if(strip[5]) pp[5]=pri;
				if(strip[6]) pp[6]=pri;
				if(strip[7]) pp[7]=pri;
			}
			pp+=8;
		}
		p+=8;
	}
	scx=ramblock[0xff4b];
	scy=ramblock[0xff4a];
	if(lcdc&0x20 && line>=scy && scx>=7 && scx<=166)
	{
		scx-=7;
		p=linebuff+8+scx;
		pp=priority+8+scx;
		t=(lcdc&0x40) ? 0x9c00 : 0x9800;
		scy=line-scy;
		t+=(scy>>3)<<5;
		scy=(scy&7)<<3;
		for(i=scx;i<160;i+=8)
		{
			if(hMachine==GMB)
			{
				strip=striplookup[ramblock[t++]]+scy;
				*p=bgmap[*strip];
				p[1]=bgmap[strip[1]];
				p[2]=bgmap[strip[2]];
				p[3]=bgmap[strip[3]];
				p[4]=bgmap[strip[4]];
				p[5]=bgmap[strip[5]];
				p[6]=bgmap[strip[6]];
				p[7]=bgmap[strip[7]];
			} else
			{
				strip=striplookup[ramblock[t]];
				j=ramblock[t++ +0x8000];
				pri=(j&0x80) ? 2 : 0;
				if(j&8) strip+=0x180<<6;
				k=(j&7)<<2;
				if(j&0x40)
					strip+=scy^(7<<3);
				else
					strip+=scy;
				if(j&0x20)
				{
					p[7]=k|*strip;
					p[6]=k|strip[1];
					p[5]=k|strip[2];
					p[4]=k|strip[3];
					p[3]=k|strip[4];
					p[2]=k|strip[5];
					p[1]=k|strip[6];
					*p=k|strip[7];
					if(*strip) pp[7]=pri;
					if(strip[1]) pp[6]=pri;
					if(strip[2]) pp[5]=pri;
					if(strip[3]) pp[4]=pri;
					if(strip[4]) pp[3]=pri;
					if(strip[5]) pp[2]=pri;
					if(strip[6]) pp[1]=pri;
					if(strip[7]) *pp=pri;
				} else
				{
					*p=k|*strip;
					p[1]=k|strip[1];
					p[2]=k|strip[2];
					p[3]=k|strip[3];
					p[4]=k|strip[4];
					p[5]=k|strip[5];
					p[6]=k|strip[6];
					p[7]=k|strip[7];
					if(*strip) *pp=pri;
					if(strip[1]) pp[1]=pri;
					if(strip[2]) pp[2]=pri;
					if(strip[3]) pp[3]=pri;
					if(strip[4]) pp[4]=pri;
					if(strip[5]) pp[5]=pri;
					if(strip[6]) pp[6]=pri;
					if(strip[7]) pp[7]=pri;
				}
				pp+=8;
			}
			p+=8;
		}
	}
	if(lcdc&2)
	{
		online=0;
		memset(spritelinebuff,0,sizeof(spritelinebuff));
		memset(spritepriority,0,sizeof(spritepriority));
		if(hMachine==GMB)
		{
			for(i=7;i>=0;--i)
				buildspriteline(i,line,0);
			for(i=7;i>=0;--i)
				buildspriteline(i,line,1);
		} else
			buildspriteline(0,line,0);
		p=linebuff;
		for(i=8;i<168;++i)
			if(spritepriority[i]>priority[i])
				p[i]=spritelinebuff[i];
	}
skip:

	p=linebuff+8;
	gs=grabsave+line*160;
	line<<=1;
	p2=(void *)(videomem+line*stride+((IXSIZE-320)>>1)*2);
	p3=(void *)(videomem+line*stride+stride+((IXSIZE-320)>>1)*2);
	i=160;
	while(i--)
	{
		*gs++=myrgbmap[*p];
		j=rgbmap[*p++];
		*p2++=j;
		*p2++=j;
		*p3++=j;
		*p3++=j;
	}

}

char basefname[256];

void striptail(char *d,char *s,char *t)
{
int j,k;

	strcpy(d,s);
	j=strlen(d);
	k=strlen(t);
	if(k>=j) return;
	d+=j-k;
	j=0;
	while(k>j)
	{
		if(tolower(d[j])!=tolower(t[j])) return;
		++j;
	}
	*d=0;
}

int writepcx(char *name, int width, int height, void (*fetch)(), unsigned char *colors)
{
int file;
unsigned char temp[2048], *p,temp2[2048],*p2;
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
	res=write(file,temp,p-temp);
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
		res=write(file,temp2,p2-temp2);
	}
	res=write(file,"\014",1);
	res=write(file,colors,0x300);
	close(file);
	return 0;
}

unsigned char *grab2=0;
void lfetch(unsigned char *buff,int line)
{
	memmove(buff,grab2+line*160,160);
}
void grab(void)
{
char name[64];
static int num=0;
unsigned char *grabunmap,*p;
unsigned char grabcolors[768];
int i,j,k;
int r,g,b;

	grabunmap=malloc(65536);
	if(!grab2)
		grab2=malloc(160*144);

	if(!grabunmap || !grab2) return;
	memset(grabunmap,255,65536);
	k=0;
	p=grab2;
	for(i=0;i<160*144;++i)
	{
		j=grabsave[i];
		if(grabunmap[j]==255)
		{
			grabunmap[j]=k;
			r=(j&0x1f)<<3;
			g=(j&0x3e0)>>2;
			b=(j&0x7c00)>>7;
			grabcolors[k+k+k]=r;
			grabcolors[k+k+k+1]=g;
			grabcolors[k+k+k+2]=b;
			k=(k+1)&255;
		}
		*p++=grabunmap[j];
	}

	sprintf(name,"grab%04d.pcx",num++);
	writepcx(name,160,144,lfetch,grabcolors);

	free(grabunmap);

}

int exitflag = 0;

int main(int argc,char **argv)
{
int code;
int time=0;
int inputtime=0;
int resettime;


	if(argc<2)
	{
		printf("Must specify ROM file\n");
		exit(20);
	}

//	if(fork()) return 0;
	exitflag = 0;
	initmachine();
	initdebug();

	if(loadrom(argv[1]))
	{
		printf("Error loading %s ROM file\n",argv[1]);
		exit(21);
	}
	striptail(basefname,argv[1],".gb");

	opengfx();
	initfont();

	clear();

	initcpu();
	soundopen();

	quiet=0;
	resettime=1;
	interact=1;
	fast=0;
	while(!exitflag)
	{
		if(interact)
		{
			interaction();
			interact=0;
			resettime=1;
		}
		if(resettime)
		{
			framecount=0;
			time=gticks();
			inputtime=time+10;
			resettime=0;
		}
		if(!paused)
			interact=cpu(114);
		while(!fast && (framecount*1000)/60>gticks()-time) wait1();

		if(gticks()>inputtime)
		{
			inputtime+=10;
			scaninput();
			buttonu=checkpressed(MYUP)|checkpressed(' ');
			buttond=checkpressed(MYDOWN)|checkpressed('z');
			buttonl=checkpressed(MYLEFT)|checkpressed(MYSHIFTL);
			buttonr=checkpressed(MYRIGHT);
			buttonstart=checkpressed('s');
			buttonselect=checkpressed('d');
			buttona=checkpressed('a')|checkpressed(MYSHIFTR);
			buttonb=checkpressed('b')|checkpressed('/');
			code=takedown();
			if(checkpressed(0x7f)) {fast=1;resettime=1;}
			else fast=0;
			if(code==('q' | MYALTED)) break;
			if(code=='t') trace=!trace;
			if(code=='q') invertaudio();
			if(code=='p') {paused=!paused;if(!paused) resettime=1;}
			if(code=='m')
			{
				hMachine=(hMachine==GMB) ? CGB : GMB;
				initcpu();
			}
			if(code==13 || code==0x1b) interact=1;
		}
	}
	writebbram();
	time=gticks()-time;
//	soundclose();
	closegfx();
	if(!time) time=1;
	printf("frames=%d,time=%d, fps=%d\n",framecount,time,1000*framecount/time);
	return 0;
}
