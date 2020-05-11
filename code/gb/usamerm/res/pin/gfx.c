#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <SDL.h>
#include <math.h>
#include "gfx.h"

#define REPT_DELAY 250
#define REPT_RATE 33

#define MAXBACKBUFFERS 8
#define KEYMAX 32
int numdown;
int downcodes[KEYMAX];
int displayopen=0;

#define MAXCODES 64
int codelist[MAXCODES];
int codeput,codetake;
int lastcode;
int vxsize,vysize;

SDL_Surface *thescreen;
int stride;
unsigned char *videomem;
unsigned char locked=0;
unsigned short *darker,*lighter;
int downtime;
unsigned char stilldown=0;

unsigned char *backbuffers[MAXBACKBUFFERS]={0};

unsigned char exitflag=0;
extern void nomem();

int sdlinout[]={
SDLK_0,'0',')',
SDLK_1,'1','!',
SDLK_2,'2','@',
SDLK_3,'3','#',
SDLK_4,'4','$',
SDLK_5,'5','%',
SDLK_6,'6','^',
SDLK_7,'7','&',
SDLK_8,'8','*',
SDLK_9,'9','(',
SDLK_a,'a','A',
SDLK_b,'b','B',
SDLK_c,'c','C',
SDLK_d,'d','D',
SDLK_e,'e','E',
SDLK_f,'f','F',
SDLK_g,'g','G',
SDLK_h,'h','H',
SDLK_i,'i','I',
SDLK_j,'j','J',
SDLK_k,'k','K',
SDLK_l,'l','L',
SDLK_m,'m','M',
SDLK_n,'n','N',
SDLK_o,'o','O',
SDLK_p,'p','P',
SDLK_q,'q','Q',
SDLK_r,'r','R',
SDLK_s,'s','S',
SDLK_t,'t','T',
SDLK_u,'u','U',
SDLK_v,'v','V',
SDLK_w,'w','W',
SDLK_x,'x','X',
SDLK_y,'y','Y',
SDLK_z,'z','Z',
SDLK_MINUS,'-','_',
SDLK_EQUALS,'=','+',
SDLK_LEFTBRACKET,'[','{',
SDLK_RIGHTBRACKET,']','}',
SDLK_SEMICOLON,';',':',
SDLK_QUOTE,'\'','"',
SDLK_BACKSLASH,'\\','|',
SDLK_SLASH,'/','?',
SDLK_PERIOD,'.','>',
SDLK_COMMA,',','<',
SDLK_BACKQUOTE,'`','~',
SDLK_BACKSPACE,8,8,
SDLK_TAB,9,9,
SDLK_DELETE,MYDELETE,MYDELETE,
SDLK_RETURN,13,13,
SDLK_F1,MYF1,MYF1,
SDLK_F2,MYF2,MYF2,
SDLK_F3,MYF3,MYF3,
SDLK_F4,MYF4,MYF4,
SDLK_F5,MYF5,MYF5,
SDLK_F6,MYF6,MYF6,
SDLK_F7,MYF7,MYF7,
SDLK_F8,MYF8,MYF8,
SDLK_F9,MYF9,MYF9,
SDLK_F10,MYF10,MYF10,
SDLK_ESCAPE,0x1b,0x1b,
SDLK_LEFT,MYLEFT,MYLEFT,
SDLK_RIGHT,MYRIGHT,MYRIGHT,
SDLK_UP,MYUP,MYUP,
SDLK_DOWN,MYDOWN,MYDOWN,
SDLK_PAGEUP,MYPAGEUP,MYPAGEUP|MYSHIFTED,
SDLK_PAGEDOWN,MYPAGEDOWN,MYPAGEDOWN|MYSHIFTED,
SDLK_SPACE,' ',' ',
SDLK_HOME,MYHOME,MYHOME,
SDLK_END,MYEND,MYEND,
SDLK_LALT,MYALTL,MYALTL,
SDLK_RALT,MYALTR,MYALTR,
SDLK_LCTRL,MYCTRLL,MYCTRLL,
SDLK_RCTRL,MYCTRLR,MYCTRLR,
SDLK_LSHIFT,MYSHIFTL,MYSHIFTL,
SDLK_RSHIFT,MYSHIFTR,MYSHIFTR,
ENDMARK
};

void mapkey(int code,int qual,int *mapped)
{
int *list;
	list=sdlinout;
	while(*list!=ENDMARK)
	{
		if(*list==code) break;
		list+=3;
	}
	if(*list==ENDMARK)
	{
		*mapped=mapped[1]=-1;
		return;
	}
	*mapped=(qual&KMOD_SHIFT) ? list[2] : list[1];
	if(qual & KMOD_ALT)
		*mapped|=MYALTED;
	if(qual & KMOD_CTRL)
		*mapped&=0x1f;
	mapped[1]=list[1];
}
int nextcode(void)
{
int code;
	if(codeput==codetake) return -1;
	code=codelist[codetake];
	codetake=codetake+1&MAXCODES-1;
	return code;
}
int peekcode(void)
{
	if(codeput==codetake) return -1;
	return codelist[codetake];
}
void addcode(int code)
{
int new;
	new=codeput+1&MAXCODES-1;
	if(new==codetake) return;
	lastcode=code;
	codelist[codeput]=code;
	codeput=new;
}
void markkey(int code,int mod,int status)
{
int i,j;
int *ip;
int mapped[2];

	mapkey(code,mod,mapped);
	code=mapped[1];
	if(code<0) return;
	if(status)
	{
		addcode(*mapped);
		stilldown=1;
		downtime=SDL_GetTicks()+REPT_DELAY;
		ip=downcodes;
		i=numdown;
		while(i)
			if(*ip++==code) break;
			else i--;
		if(!i && numdown<KEYMAX)
			downcodes[numdown++]=code;
	} else
	{
		i=numdown;
		ip=downcodes;
		while(i)
			if(*ip++==code)
			{
				*--ip=downcodes[--numdown];
				break;
			} else i--;
	}

}

int checkdown(int code)
{
int *p,i;
	i=numdown;
	p=downcodes;
	while(i--)
		if(*p++==code) return 1;
	return 0;
}

void scaninput(void)
{
SDL_Event event;
int key,mod;
static int bs=0;
int newtime;

//	mousedown=0;
	while(SDL_PollEvent(&event))
	{
		switch(event.type)
		{
		case SDL_KEYDOWN:
			key=event.key.keysym.sym;
			mod=event.key.keysym.mod;
			markkey(key,mod,1);
			break;
		case SDL_KEYUP:
			key=event.key.keysym.sym;
			mod=event.key.keysym.mod;
			markkey(key,mod,0);
			stilldown=0;
			break;
		case SDL_MOUSEBUTTONUP:
			bs=event.button.button;
			if(bs>=1 && bs<=3)
			{
				addcode(MYMOUSE1UP+bs-1);
				addcode(event.button.x);
				addcode(event.button.y);
			}
			break;
		case SDL_MOUSEBUTTONDOWN:
			bs=event.button.button;
			if(bs>=1 && bs<=3)
			{
				addcode(MYMOUSE1DOWN+bs-1);
				addcode(event.button.x);
				addcode(event.button.y);
			}
			break;
		case SDL_MOUSEMOTION:
			addcode(MYMOUSEMOVE);
			addcode(event.motion.x);
			addcode(event.motion.y);
			break;
		}
	}
	if(stilldown)
	{
		newtime=SDL_GetTicks();
		if(newtime>downtime)
		{
			downtime+=REPT_RATE;
			addcode(lastcode);
		}
	}
}
unsigned char crossdata[]=
{
0x03,0x80,
0x02,0x80,
0x02,0x80,
0x02,0x80,
0x03,0x80,
0x00,0x00,
0xf8,0x3e,
0x88,0x22,
0xf8,0x3e,
0x00,0x00,
0x03,0x80,
0x02,0x80,
0x02,0x80,
0x02,0x80,
0x03,0x80
};

unsigned char crossmask[]=
{
0x03,0x80,
0x03,0x80,
0x03,0x80,
0x03,0x80,
0x03,0x80,
0x00,0x00,
0xf8,0x3e,
0xf8,0x3e,
0xf8,0x3e,
0x00,0x00,
0x03,0x80,
0x03,0x80,
0x03,0x80,
0x03,0x80,
0x03,0x80
};

SDL_Cursor *crosscursor;
void getcursors()
{
	crosscursor=SDL_CreateCursor(crossdata,crossmask,15,15,7,7);
	SDL_SetCursor(crosscursor);
}

void opendisplay(int sx,int sy)
{
unsigned long videoflags;
int i;
unsigned char r,g,b;

	vxsize=sx;
	vysize=sy;
	codeput=codetake=0;
	darker=malloc(65536*sizeof(unsigned short));
	lighter=malloc(65536*sizeof(unsigned short));
	if(!darker || !lighter) nomem(5);
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 )
	{
		fprintf(stderr, "Couldn't initialize SDL: %s\n",SDL_GetError());
		exit(1);
	}
	videoflags = SDL_SWSURFACE;

	thescreen = SDL_SetVideoMode(vxsize, vysize, 16, videoflags);
	if ( thescreen == NULL )
	{
		fprintf(stderr, "Couldn't set display mode: %s\n",
							SDL_GetError());
		SDL_Quit();
		exit(5);
	}
	stride=thescreen->pitch;
	videomem=(void *)thescreen->pixels;
//	SDL_ShowCursor(0);
	getcursors();

	for(i=0;i<65536;++i)
	{
		SDL_GetRGB(i,thescreen->format,&r,&g,&b);
		darker[i]=SDL_MapRGB(thescreen->format,r*3>>2,g*3>>2,b*3>>2);
		if(r>128 && g>128 && b>128)
			lighter[i]=SDL_MapRGB(thescreen->format,r+255>>1,g+255>>1,b+255>>1);
		else
			lighter[i]=i;
	}
	displayopen=1;
}

void closedisplay(void)
{
	SDL_Quit();
	displayopen=0;
}
void scrlock(void)
{
	if(!locked && SDL_MUSTLOCK(thescreen))
	{
		if ( SDL_LockSurface(thescreen) < 0 )
		{
			fprintf(stderr, "Couldn't lock display surface: %s\n",
								SDL_GetError());
		}
	}
	locked=1;
}

void scrunlock(void)
{
	if(locked && SDL_MUSTLOCK(thescreen))
		SDL_UnlockSurface(thescreen);
	locked=0;
}
void clear(void)
{
int i;
char *p;
	scrlock();
	p=videomem;
	i=vysize;
	while(i--)
	{
		memset(p,0,vxsize);
		p+=stride;
	}
}
void copyup(void)
{
	scrunlock();
	SDL_UpdateRect(thescreen, 0, 0, 0, 0);
}
void copyupany(int mx,int my,int sx,int sy)
{
	scrunlock();
	SDL_UpdateRect(thescreen,mx,my,sx,sy);
}
void delay(int ticks)
{
	SDL_Delay(ticks);
}
int gticks(void)
{
	return SDL_GetTicks();
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
			if(displayopen)
				gs->rgb[i]=SDL_MapRGB(thescreen->format,r,g,b);
			j=i*3;
			gs->colormap[j]=r;
			gs->colormap[j+1]=g;
			gs->colormap[j+2]=b;

		}
	} else
	{
		for(i=0,j=0;i<16;++i)
		{
			r=map48[j++];
			g=map48[j++];
			b=map48[j++];
			if(displayopen)
				gs->rgb[i]=SDL_MapRGB(thescreen->format,r,g,b);
		}
	}
	close(pcxihand);
	return 0;
}
void gstoback(int destx,int desty,surface *gs,int sourcex,int sourcey,int sizex,int sizey)
{
unsigned short *ps;
unsigned char *p;
int i,j;

	if(destx>=vxsize || desty>=vysize) return;
	if(destx<0)
	{
		sourcex-=destx;
		sizex+=destx;
		destx=0;
	}
	if(desty<0)
	{
		sourcey-=desty;
		sizey+=desty;
		desty=0;
	}
	if(destx+sizex>vxsize)
		sizex=vxsize-destx;
	if(desty+sizey>vysize)
		sizey=vysize-desty;
	p=gs->pic+sourcex+sourcey*gs->xsize;
	ps=(void *)(videomem+stride*desty+(destx<<1));
	while(sizey--)
	{
		i=sizex;
		while(i--)
			*ps++=gs->rgb[*p++];
		ps+=(stride-sizex-sizex)>>1;
		p+=gs->xsize-sizex;
	}
}
void rgbdot(unsigned int x,unsigned int y,unsigned char r,unsigned char g,unsigned char b)
{
	if(x<vxsize && y<vysize)
		*(unsigned short *)(videomem+y*stride+x+x)=
			SDL_MapRGB(thescreen->format,r,g,b);
}
void eraserect(int x,int y,int sizex,int sizey)
{
unsigned char *p;
	if(y<0)
	{
		sizey+=y;
		y=0;
	}
	if(x<0)
	{
		sizex+=x;
		x=0;
	}
	if(x+sizex>vxsize)
		sizex=vxsize-x;
	if(y+sizey>vysize)
		sizey=vysize-y;
	p=videomem+stride*y+(x<<1);
	sizex<<=1;
	while(sizey-->0)
	{
		memset(p,0,sizex);
		p+=stride;
	}

}
void transformrect(int x,int y,int sizex,int sizey,unsigned short *trans)
{
unsigned short *p;
int i;
	if(y<0)
	{
		sizey+=y;
		y=0;
	}
	if(x<0)
	{
		sizex+=x;
		x=0;
	}
	if(x+sizex>vxsize)
		sizex=vxsize-x;
	if(y+sizey>vysize)
		sizey=vysize-y;
	p=(void *)(videomem+stride*y+(x<<1));
	while(sizey-->0)
	{
		i=sizex;
		while(i-->0)
			p[i]=trans[p[i]];
		p+=stride>>1;
	}
}
void darkenrect(int x,int y,int sizex,int sizey)
{
	transformrect(x,y,sizex,sizey,darker);
}
void lightenrect(int x,int y,int sizex,int sizey)
{
	transformrect(x,y,sizex,sizey,lighter);
}
void solidrect(int x,int y,int sizex,int sizey,unsigned char r,unsigned char g,unsigned char b)
{
unsigned short *p;
int i;
int c;
	c=SDL_MapRGB(thescreen->format,r,g,b);
	if(y<0)
	{
		sizey+=y;
		y=0;
	}
	if(x<0)
	{
		sizex+=x;
		x=0;
	}
	if(x+sizex>vxsize)
		sizex=vxsize-x;
	if(y+sizey>vysize)
		sizey=vysize-y;
	p=(void *)(videomem+stride*y+(x<<1));
	while(sizey-->0)
	{
		i=sizex;
		while(i-->0)
			p[i]=c;
		p+=stride>>1;
	}
}
/* This is specific to shanghai... */
void applyshadowplane(unsigned char *plane)
{
unsigned short *p,*p2;
int i,j,k;
unsigned char c;

	p=(void *)videomem;
	for(j=0;j<vysize;++j)
	{
		i=vxsize;
		p2=p;
		p+=stride>>1;
		while(i>0)
		{
			i-=8;
			c=*plane++;
			k=0;
			while(c)
			{
				if(c&1) p2[k]=darker[p2[k]];
				c>>=1;
				++k;
			}
			p2+=8;
		}
	}
}
void copytoback(unsigned int n)
{
int i;
unsigned char *p1,*p2;

	if(n>=MAXBACKBUFFERS) return;
	if(!backbuffers[n])
	{
		backbuffers[n]=malloc(vxsize*vysize*sizeof(unsigned short));
		if(!backbuffers[n]) nomem(25);
	}
	p1=backbuffers[n];
	p2=videomem;
	i=vysize;
	while(i--)
	{
		memcpy(p1,p2,vxsize<<1);
		p1+=vxsize<<1;
		p2+=stride;
	}
}
void copyfromback(unsigned int n)
{
int i;
unsigned char *p1,*p2;
	if(n>=MAXBACKBUFFERS || !backbuffers[n]) return;
	p1=backbuffers[n];
	p2=videomem;
	i=vysize;
	while(i--)
	{
		memcpy(p2,p1,vxsize<<1);
		p1+=vxsize<<1;
		p2+=stride;
	}
}
void freegs(surface *gs)
{
	if(gs->pic)
	{
		free(gs->pic);
		gs->pic=0;
	}
}
int maprgb(int r,int g,int b)
{
	if(!displayopen) return 0;
	return SDL_MapRGB(thescreen->format,r,g,b);
}
int writeppm(char *name)
{
	int ofile;
	unsigned char text[256],*p;
	unsigned short *take;
	int i,j;
	unsigned char r,g,b;
	int res;

	ofile=open(name,O_WRONLY|O_CREAT|O_TRUNC,0644);
	if(ofile<0) return -1;
	sprintf(text,"P6\n");
	res=write(ofile,text,strlen(text));res=res;
	sprintf(text,"%d %d\n",vxsize,vysize);
	res=write(ofile,text,strlen(text));res=res;
	sprintf(text,"255\n");
	res=write(ofile,text,strlen(text));res=res;
	take=(unsigned short *) videomem;
	p=text;
	j=vysize;
	while(j--)
	{
		for(i=0;i<vxsize;++i)
		{
			SDL_GetRGB(take[i],thescreen->format,p,p+1,p+2);
			p+=3;
			if(p>=text+sizeof(text)-3)
			{
				res=write(ofile,text,p-text);res=res;
				p=text;
			}
		}
		take+=stride>>1;
	}
	if(p>text) {
		res=write(ofile,text,p-text);res=res;
	}
}

void setcolor(struct surface *gs,int num,int r,int g,int b)
{
	gs->rgb[num]=maprgb(r,g,b);
	num+=num<<1;
	gs->colormap[num++]=r;
	gs->colormap[num++]=g;
	gs->colormap[num]=b;
}

int allocgs(struct surface *gs,int width,int height,int format)
{
int r,g,b,rt,gt,bt;
int i,j,k;
unsigned char *p;
	memset(gs,0,sizeof(struct surface));
	p=gs->colormap;
	i=0;
	for(b=0;b<6;++b)
	{
		bt=255*b/5;
		for(g=0;g<7;++g)
		{
			gt=255*g/6;
			for(r=0;r<6;++r)
			{
				rt=255*r/5;
				*p++=rt;
				*p++=gt;
				*p++=bt;
				gs->rgb[i++]=maprgb(rt,gt,bt);
			}
		}
	}
	gs->xsize=width;
	gs->ysize=height;
	gs->format=format;
	i=width*height*format;
	gs->pic=malloc(i);
	if(!gs->pic) nomem(54);
	memset(gs->pic,0,i);
	return 0;
}
