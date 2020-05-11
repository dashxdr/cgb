#include "mgb.h"

#define KEYMAX 32

SDL_Surface *thescreen;
unsigned char *videomem;
int stride;
SDL_Color themap[256];
unsigned char mustlock=0,locked=0;
int pressedcodes[KEYMAX],downcodes[KEYMAX],numpressed,numdown;
int mousex,mousey,mouseb,buttondown;
#define KEYHISTSIZE 16
int keytake=0,keyput=0,keysin;
int keyhist[KEYHISTSIZE];
unsigned char mapsave[768];

#define RREAL 128
#define GREAL 128
#define BREAL 128
#define GOOD 24
#define BAD 0


#define ENDMARK 0xaabacada

unsigned short rgbmap[256],myrgbmap[256];

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
void markkey(int code,int mod,int status)
{
int i;
int *ip;
int mapped[2];

	mapkey(code,mod,mapped);
	code=mapped[1];
	if(code<0) return;
	if(status)
	{
		if(numdown<KEYMAX)
			downcodes[numdown++]=code;
		ip=pressedcodes;
		i=numpressed;
		while(i)
			if(*ip++==code) break;
			else i--;
		if(!i && numpressed<KEYMAX)
			pressedcodes[numpressed++]=code;
		if(*mapped==(MYALTED | 'q')) exitflag = 1;
		if(keysin<KEYHISTSIZE)
		{
			keyhist[keyput++ & (KEYHISTSIZE-1)]=*mapped;
			++keysin;
		}
	} else
	{
		i=numpressed;
		ip=pressedcodes;
		while(i)
			if(*ip++==code)
			{
				*--ip=pressedcodes[--numpressed];
				break;
			} else i--;
	}

}
int ignorable(int code)
{
	return code==MYALTL || code==MYALTR || 
		code==MYCTRLL || code==MYCTRLR ||
		code==MYSHIFTL || code==MYSHIFTR;
}

#define REPEATDELAY 200
#define REPEATRATE 20
int takedown()
{
static int nexttime=0;
static int lastcode=-1;
int time;
int i,j;

	if(keysin)
	{
		--keysin;
		lastcode=keyhist[keytake++ & (KEYHISTSIZE-1)];
		nexttime=SDL_GetTicks()+REPEATDELAY;
		return lastcode;
	}
	time=SDL_GetTicks();
	j=0;
	for(i=0;i<numpressed;++i)
		if(!ignorable(pressedcodes[i]))
			++j;

	if(j)
	{
		if(time>=nexttime)
		{
			nexttime+=REPEATRATE;
			return lastcode;
		}
	} else
		lastcode=-1;
	return -1;
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

int checkpressed(int code)
{
int *p,i;
	i=numpressed;
	p=pressedcodes;
	while(i--)
		if(*p++==code) return 1;
	return 0;
}

int maprgb(int red,int green,int blue)
{
	return SDL_MapRGB(thescreen->format,red,green,blue);
}
int mymaprgb(int red,int green,int blue)
{
	return ((blue&0xf8)<<7) | ((green&0xf8)<<2) |((red&0xf8)>>3);
}

void set_color(int color, int red, int green, int blue)
{
unsigned char *p;
	red=(BREAL*BAD+red*GOOD)/(GOOD+BAD);
	green=(BREAL*BAD+green*GOOD)/(GOOD+BAD);
	blue=(BREAL*BAD+blue*GOOD)/(GOOD+BAD);
	rgbmap[color]=maprgb(red,green,blue);
	myrgbmap[color]=mymaprgb(red,green,blue);
	p=mapsave+color*3;
	*p++=red;
	*p++=green;
	*p++=blue;
}

void opengfx(void)
{
unsigned long videoflags;

	themap[0].r=0;
	themap[0].g=0;
	themap[0].b=0;

	if ( SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER/*|SDL_INIT_AUDIO*/) < 0 )
	{
		fprintf(stderr, "Couldn't initialize SDL: %s\n",SDL_GetError());
		exit(1);
	}
	videoflags = SDL_SWSURFACE;

	thescreen = SDL_SetVideoMode(IXSIZE, IYSIZE, 16, videoflags);
	if ( thescreen == NULL )
	{
		fprintf(stderr, "Couldn't set display mode: %s\n",
							SDL_GetError());
		SDL_Quit();
		exit(5);
	}
	stride=thescreen->pitch;
	videomem=thescreen->pixels;
	mustlock=SDL_MUSTLOCK(thescreen);
	locked=0;
//	SDL_ShowCursor(0);
}
void closegfx()
{
	SDL_Quit();
}
void clear(void)
{
int i;
unsigned char *p;
	p=videomem;
	i=IYSIZE;
	while(i--)
	{
		memset(p,0,IXSIZE<<1);
		p+=stride;
	}
}
void gfxlock(void)
{
	if(locked || !mustlock) return;
	if ( SDL_LockSurface(thescreen) < 0 )
	{
		fprintf(stderr, "Couldn't lock display surface: %s\n",
							SDL_GetError());
	}
	locked=1;
}
void gfxunlock(void)
{
	if(!locked || !mustlock) return;
	SDL_UnlockSurface(thescreen);
	locked=0;
}

void copyup()
{
	gfxunlock();
	SDL_UpdateRect(thescreen, 0,0,0,0);
}
void updategb(void)
{
	gfxunlock();
	SDL_UpdateRect(thescreen, (IXSIZE-320)>>1, 0, 320, 288);
}
extern unsigned char tainted;
void updatef()
{
static int lastupdate=0;
int new;

	if(!tainted) return;
	new=SDL_GetTicks();
	if(new-lastupdate<20) return;
	lastupdate=new;
	tainted=0;
	gfxunlock();
	SDL_UpdateRect(thescreen, 0, 288 , IXSIZE, IYSIZE-288);
}

void scaninput(void)
{
SDL_Event event;
int key,mod;
static int bs=0;

	updatef();
	numdown=0;
	buttondown=0;
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
			break;
		case SDL_MOUSEBUTTONUP:
			bs&=~(1<<(event.button.button-1));
			mousex=event.button.x>>1;
			mousey=event.button.y>>1;
			mouseb=bs;
			break;
		case SDL_MOUSEBUTTONDOWN:
			bs|=1<<(event.button.button-1);
			mousex=event.button.x>>1;
			mousey=event.button.y>>1;
			mouseb=bs;
			break;
		case SDL_MOUSEMOTION:
			mousex=event.motion.x>>1;
			mousey=event.motion.y>>1;
			break;
		}
	}
}

int gticks(void)
{
	return SDL_GetTicks();
}
void wait1(void)
{
	SDL_Delay(1);
}
