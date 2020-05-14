#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <inttypes.h>
#include "elmer.h"
#include "data.h"
#include "iff.h"
#include "pcx.h"
#include "spr.h"
#include "SDL.h"

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define MYF1 0x180
#define MYF2 0x181
#define MYF3 0x182
#define MYF4 0x183
#define MYF5 0x184
#define MYF6 0x185
#define MYF7 0x186
#define MYF8 0x187
#define MYF9 0x188
#define MYF10 0x189
#define MYLEFT 0x190
#define MYRIGHT 0x191
#define MYUP 0x192
#define MYDOWN 0x193
#define MYPAGEUP 0x194
#define MYPAGEDOWN 0x195
#define MYHOME 0x196
#define MYEND 0x197
#define MYDELETE 0x7f

#define MYSHIFTED 0x40
#define MYALTED 0x200

#define IXSIZE 800
#define IYSIZE 600


#define IDX 240
#define IDY 160

#define DX 240
#define DY 160

int speeddelays[]={1000/4,1000/5,1000/8,1000/10,1000/12,1000/20,1000/30,1000/60};
int speedrates[]={4,5,8,10,12,20,30,60};

//#define DOJOHN
char letterbox=0; // SET TO 1 for Robert's crazy letterbox mode
char blackandwhite=0;
char realsprites=0;
int mousex,mousey,mouseb,mousebold=0;
int mousedownx,mousedowny,mouseupx,mouseupy,mousedown=0,mouseup=0;
int mouseat;
int mouseoldx,mouseoldy;
int mousedx,mousedy;
int mousepixelid;
int mousedownpos,mouseuppos;
int mouseupordown=0;
char drawmouse=1;
char newdrawmouse=1;

int locklow=0;
int locklen=0;

int bgcolor;
int zerocolor;

#define MOUSE_MASK 0xff00
#define MOUSE_COMAREA 0x100
#define MOUSE_LIST 0x200
#define MOUSE_SCREEN 0x300

#define CODE_CHANGEFILE 0x8000
#define CODE_NEWCEL 0x8001
#define CODE_DUPFRAME 0x8002
#define CODE_CELTOBOTTOM 0x8003
#define CODE_PLAY 0x8004
#define CODE_NEXT 0x8005
#define CODE_PREV 0x8006
#define CODE_TOGGLE 0x8007
#define CODE_MOVECEL 0x8008
#define CODE_LEFTCLICK 0x8009
#define CODE_HELP 0x800a
#define CODE_CHANGECEL 0x800b

#define DISPLAY_CELS (-1)


SDL_Surface *thescreen;
SDL_Color themap[256];
int stride;
unsigned char *videomem;

int filewant=0;

#define COMMANDLINE 10
/* Mouse position numbers
*/


#define CMD_ENDFRAME    0
#define CMD_BGMASK      1
#define CMD_COLORMASK   2
#define CMD_LOADCHARS   3
#define CMD_SCROLL      4
#define CMD_SPRITEBLOCK 5
#define CMD_ENDANIM     7
#define CMD_LOADBG      8
#define CMD_LOADCOLOR   9


void drawprintf(int x,int y,char *p,...);
void putcel(int num,int xpos,int ypos,int flags);
#define BLOCKSIZE 8000000L

char backgroundname[256];
#define SPEEDFACTOR 50

int playspeed=1;
char locked=0;
char *message=0;
char errormsg[128];
char errstr[256];

unsigned char spritepalettes[8];


int perlines[256];
int spritesused;
int videowidth=(IXSIZE>>1);
int videoheight=(IYSIZE>>1);
int videosize=(IXSIZE*IYSIZE>>1);
int overs2=0;
unsigned char *spritez;
unsigned char *pixelid,pixelidval;

struct animfile {
unsigned char *map;
int mapsize;
unsigned char *chr;
int chrsize;
unsigned char *rgb;
int rgbsize;
int colorbase;
} animfiles[100];

char rootname[128];
int selected=0;
int currentframe;

#define NO_DRAW_BG 1
#define NO_DRAW_CELS 2
char mask=0;

unsigned char picks[64];

char commands[]="\
new cel        F2\n\
dup frame      F3\n\
cel to bottom  F4\n\
play          ret\n\
next            2\n\
prev            1\n\
help            H\n\
";

#define MAXKEYS 16
struct keyhit
{
	int code;
	int qual;
} keylist[MAXKEYS];
int keyput,keytake;


char helptext[]="\
delete frame S-F1\n\
insert frame   F1\n\
delete cel   S-F2\n\
new cel        F2\n\
dup frame      F3\n\
cel to bottom  F4\n\
obj -1         F5\n\
obj +1         F6\n\
fig -1         F7\n\
fig +1         F8\n\
invert all      l\n\
invert this   spc\n\
save        alt-s\n\
exit        alt-q\n\
play          ret\n\
next            2\n\
prev            1\n\
copy        alt-c\n\
paste       alt-v\n\
invert x        x\n\
";
char helptext2[]="\
escape commands: \n\
rm  #[-#]        \n\
dup #[-#][,#]    \n\
goto #           \n\
lock #-#         \n\
move #-#,#       \n\
";

struct acolor
{
	unsigned char red,green,blue;
};
struct acolor thecmap[256];

#define DIFF_BG 1
#define DIFF_COLOR 2
unsigned char diffs[18][20];
int tilemap[32][32];
unsigned char colormap[32][32];

#define BUFFERSIZE 0x200000L
#define MAXFRAMES 2048
int oldmode;
unsigned char *buffer1,*buffer2;
unsigned short *buffer2w;
int overallchars=0;
unsigned short *video;
unsigned char *backbuffer;
char *take;
unsigned char *currentfont;
char filenames[100][128];
char fixednames[100][128];
int numframes,numfiles;
int freecolor;

unsigned short *compressed[256];
struct spritegroup
{
	unsigned char *firstchar;
	int numchars;
	unsigned char *firstsprite;
	int numsprites;
	int remapbase;
} spritegroups[256];

int numgfx;
struct group
{
	int start;
	int length;
	int sizex,sizey;
	int offsetx,offsety;
	char type;//0=bg, 1=sprite
} groups[256];
int convert(char *name,struct group *grp,int usetransp);

struct boundary
{
	int xmin,ymin;
	int xmax,ymax;
};


#define CEL_FLIPX 0x20


typedef struct cel
{
	struct cel *next;
	int filenumber;
	int spritenumber;
	int deltax,deltay;
	int flags;
} cel;
struct frame
{
	cel *cellist;
	int bgdx,bgdy;
} frames[MAXFRAMES];

int pasteselected=0;
int pastebgdx,pastebgdy;
cel paste[32];
int inpaste=0;

int numframes;

void dot(unsigned int x,unsigned int y,int c) {
	if(x<(IXSIZE>>1) && y<(IYSIZE>>1))
		video[y*(IXSIZE>>1)+x]=c;
}
unsigned getdot(unsigned int x,unsigned int y) {
	if(x<(IXSIZE>>1) && y<(IYSIZE>>1))
		return video[y*(IXSIZE>>1)+x];
	else return 0;
}

void clear(int color) {
	int i,j;
	unsigned short *p;
	p=video;
	i=videowidth*videoheight;
	while(i--) *p++=color;
}
#define ENDMARK 0xaabacada

int sdlinoutnormal[]={
SDLK_0,'0',
SDLK_1,'1',
SDLK_2,'2',
SDLK_3,'3',
SDLK_4,'4',
SDLK_5,'5',
SDLK_6,'6',
SDLK_7,'7',
SDLK_8,'8',
SDLK_9,'9',
SDLK_a,'a',
SDLK_b,'b',
SDLK_c,'c',
SDLK_d,'d',
SDLK_e,'e',
SDLK_f,'f',
SDLK_g,'g',
SDLK_h,'h',
SDLK_i,'i',
SDLK_j,'j',
SDLK_k,'k',
SDLK_l,'l',
SDLK_m,'m',
SDLK_n,'n',
SDLK_o,'o',
SDLK_p,'p',
SDLK_q,'q',
SDLK_r,'r',
SDLK_s,'s',
SDLK_t,'t',
SDLK_u,'u',
SDLK_v,'v',
SDLK_w,'w',
SDLK_x,'x',
SDLK_y,'y',
SDLK_z,'z',
SDLK_EQUALS,'=',
SDLK_MINUS,'-',
SDLK_PLUS,'=',
SDLK_LEFTBRACKET,'[',
SDLK_RIGHTBRACKET,']',
SDLK_SEMICOLON,';',
SDLK_QUOTE,'\'',
SDLK_SLASH,'/',
SDLK_PERIOD,'.',
SDLK_COMMA,',',
SDLK_BACKQUOTE,'`',
SDLK_BACKSPACE,8,
SDLK_TAB,9,
SDLK_DELETE,MYDELETE,
SDLK_RETURN,13,
SDLK_F1,MYF1,
SDLK_F2,MYF2,
SDLK_F3,MYF3,
SDLK_F4,MYF4,
SDLK_F5,MYF5,
SDLK_F6,MYF6,
SDLK_F7,MYF7,
SDLK_F8,MYF8,
SDLK_F9,MYF9,
SDLK_F10,MYF10,
SDLK_ESCAPE,0x1b,
SDLK_LEFT,MYLEFT,
SDLK_RIGHT,MYRIGHT,
SDLK_UP,MYUP,
SDLK_DOWN,MYDOWN,
SDLK_PAGEUP,MYPAGEUP,
SDLK_PAGEDOWN,MYPAGEDOWN,
SDLK_SPACE,' ',
SDLK_HOME,MYHOME,
SDLK_END,MYEND,
ENDMARK
};
int sdlinoutshifted[]={
SDLK_0,')',
SDLK_1,'!',
SDLK_2,'@',
SDLK_3,'#',
SDLK_4,'$',
SDLK_5,'%',
SDLK_6,'^',
SDLK_7,'&',
SDLK_8,'*',
SDLK_9,'(',
SDLK_a,'A',
SDLK_b,'B',
SDLK_c,'C',
SDLK_d,'D',
SDLK_e,'E',
SDLK_f,'F',
SDLK_g,'G',
SDLK_h,'H',
SDLK_i,'I',
SDLK_j,'J',
SDLK_k,'K',
SDLK_l,'L',
SDLK_m,'M',
SDLK_n,'N',
SDLK_o,'O',
SDLK_p,'P',
SDLK_q,'Q',
SDLK_r,'R',
SDLK_s,'S',
SDLK_t,'T',
SDLK_u,'U',
SDLK_v,'V',
SDLK_w,'W',
SDLK_x,'X',
SDLK_y,'Y',
SDLK_z,'Z',
SDLK_EQUALS,'+',
SDLK_MINUS,'_',
SDLK_PLUS,'+',
SDLK_LEFTBRACKET,'{',
SDLK_RIGHTBRACKET,'}',
SDLK_SEMICOLON,':',
SDLK_QUOTE,'"',
SDLK_SLASH,'?',
SDLK_PERIOD,'>',
SDLK_COMMA,'<',
SDLK_BACKQUOTE,'~',
SDLK_BACKSPACE,8,
SDLK_TAB,9,
SDLK_DELETE,MYDELETE,
SDLK_RETURN,13,
SDLK_F1,MYF1+MYSHIFTED,
SDLK_F2,MYF2+MYSHIFTED,
SDLK_F3,MYF3+MYSHIFTED,
SDLK_F4,MYF4+MYSHIFTED,
SDLK_F5,MYF5+MYSHIFTED,
SDLK_F6,MYF6+MYSHIFTED,
SDLK_F7,MYF7+MYSHIFTED,
SDLK_F8,MYF8+MYSHIFTED,
SDLK_F9,MYF9+MYSHIFTED,
SDLK_F10,MYF10+MYSHIFTED,
SDLK_ESCAPE,0x1b,
SDLK_LEFT,MYLEFT+MYSHIFTED,
SDLK_RIGHT,MYRIGHT+MYSHIFTED,
SDLK_UP,MYUP+MYSHIFTED,
SDLK_DOWN,MYDOWN+MYSHIFTED,
SDLK_PAGEUP,MYPAGEUP,
SDLK_PAGEDOWN,MYPAGEDOWN,
SDLK_SPACE,' ',
SDLK_HOME,MYHOME,
SDLK_END,MYEND,
ENDMARK
};

int maprgb(int r,int g,int b)
{
	return SDL_MapRGB(thescreen->format,r,g,b);
}

int fontmap[4];

int looklist(int code,int *list)
{
	while(*list!=ENDMARK)
	{
		if(*list==code)
			return list[1];
		list+=2;
	}
	return -1;
}
unsigned stilldown=0;
int downtime;
int lastcode,lastqual;
void addkey(int code,int qual) {
	lastcode=code;
	lastqual=qual;
	keylist[keyput].code=code;
	keylist[keyput].qual=qual;
	keyput=keyput+1&MAXKEYS-1;
}

void processkey(int code,int qual) {

	if(qual & KMOD_SHIFT)
		code=looklist(code,sdlinoutshifted);
	else
		code=looklist(code,sdlinoutnormal);
	if(code<0) return;

	if(qual & KMOD_ALT)
		code|=MYALTED;

	addkey(code,qual);
	stilldown=1;
	downtime=SDL_GetTicks()+250;
}
void scaninput() {
	SDL_Event event;
	int key,mod;
	static int bs=0;
	int newtime;

	SDL_Delay(1);
	while(SDL_PollEvent(&event))
	{
		switch(event.type)
		{
		case SDL_ACTIVEEVENT:
			newdrawmouse=event.active.gain;
			if(!newdrawmouse) drawmouse=0;
			break;
		case SDL_KEYDOWN:
			key=event.key.keysym.sym;
			mod=event.key.keysym.mod;
			processkey(key,mod);
			break;
		case SDL_KEYUP:
			stilldown=0;
			break;
		case SDL_MOUSEBUTTONUP:
			bs&=~(1<<event.button.button-1);
			drawmouse=newdrawmouse;
			mousex=event.button.x>>1;
			mousey=event.button.y>>1;
			mouseb=bs;
			break;
		case SDL_MOUSEBUTTONDOWN:
			bs|=1<<event.button.button-1;
			drawmouse=newdrawmouse;
			mousex=event.button.x>>1;
			mousey=event.button.y>>1;
			mouseb=bs;
			break;
		case SDL_MOUSEMOTION:
			drawmouse=newdrawmouse;
			mousex=event.motion.x>>1;
			mousey=event.motion.y>>1;
			break;
		}
	}
	if(stilldown)
	{
		newtime=SDL_GetTicks();
		if(newtime>downtime)
		{
			downtime+=33;
			addkey(lastcode,lastqual);
		}
	}
}

int scrlock()
{
	if(SDL_MUSTLOCK(thescreen))
	{
		if ( SDL_LockSurface(thescreen) < 0 )
		{
			fprintf(stderr, "Couldn't lock display surface: %s\n",
								SDL_GetError());
			return -1;
		}
	}
	return 0;
}
void scrunlock() {
	if(SDL_MUSTLOCK(thescreen))
		SDL_UnlockSurface(thescreen);
	SDL_UpdateRect(thescreen, 0, 0, 0, 0);
}

void doublex(unsigned short **dest,unsigned short *src) {
	int i;
	unsigned short c,*p;
	i=IXSIZE>>1;
	p=*dest;
	while(i--)
	{
		c=*src++;
		*p++=c;
		*p++=c;
	}
	(*(unsigned char **)dest)+=stride;
}
void copyup(void) {
	int i,j;
	unsigned short *p1,*p2;

	scrlock();
	p1=(void *)videomem;
	p2=video;
	for(i=0;i<IYSIZE>>1;++i)
	{
		doublex(&p1,p2);
		doublex(&p1,p2);
		p2+=(IXSIZE>>1);
	}
	scrunlock();
}
void copyback(void) {
	memmove(backbuffer,video,videosize);
}

unsigned char font2[]={
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,0,0,0,
0,2,2,1,0,0,0,0,
0,2,2,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,2,2,0,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,2,2,0,0,
0,2,2,1,2,2,1,0,
0,0,1,1,0,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,0,2,0,0,
0,2,2,2,2,2,2,0,
0,0,2,1,2,1,1,1,
2,2,2,2,2,2,0,0,
0,2,1,2,1,1,1,0,
0,0,1,0,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,2,0,0,0,0,
0,2,2,2,2,2,0,0,
0,2,1,2,1,1,1,0,
0,2,2,2,2,2,0,0,
0,0,1,2,1,2,1,0,
0,2,2,2,2,2,1,0,
0,0,1,2,1,1,1,0,
0,0,0,0,1,0,0,0,

0,0,0,0,0,0,0,0,
2,2,0,2,2,1,0,0,
2,2,1,2,2,1,0,0,
0,1,2,2,1,1,0,0,
0,1,2,2,1,2,2,0,
0,2,2,1,1,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,1,2,1,0,0,0,
0,0,2,0,2,0,0,0,
0,1,2,2,2,1,2,0,
0,2,2,1,2,2,0,1,
0,1,2,2,2,1,2,0,
0,0,0,1,1,1,0,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,0,0,0,
0,2,2,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,1,2,2,0,
0,0,0,0,2,2,1,1,
0,0,0,0,2,2,1,0,
0,0,0,0,2,2,1,0,
0,0,0,0,2,2,1,0,
0,0,0,0,2,2,1,0,
0,0,0,0,1,2,2,0,
0,0,0,0,0,0,1,1,

0,2,2,1,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,2,2,1,0,0,0,
0,0,2,2,1,0,0,0,
0,0,2,2,1,0,0,0,
0,0,2,2,1,0,0,0,
0,2,2,1,1,0,0,0,
0,0,1,1,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,0,0,0,0,
0,0,1,2,1,0,0,0,
2,2,2,2,2,2,2,0,
0,1,2,2,2,1,1,1,
0,2,1,1,1,2,0,0,
0,0,1,0,0,0,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,0,0,0,0,
0,0,0,2,1,0,0,0,
0,2,2,2,2,2,0,0,
0,0,1,2,1,1,1,0,
0,0,0,2,1,0,0,0,
0,0,0,0,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,2,2,0,0,0,0,0,
0,2,1,1,0,0,0,0,
0,0,1,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,2,2,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,2,2,0,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,2,1,0,0,
0,0,1,2,2,1,0,0,
0,0,2,2,1,1,0,0,
0,1,2,2,1,0,0,0,
0,2,2,1,1,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,2,0,0,0,
0,0,2,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,0,1,1,1,2,2,0,
0,1,2,2,2,2,1,1,
0,2,2,1,1,1,1,0,
0,2,2,2,2,2,2,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,0,1,1,1,2,2,0,
0,0,2,2,2,2,1,1,
0,0,0,1,1,2,2,0,
0,2,2,2,2,2,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,2,2,2,0,
0,0,2,2,1,2,2,1,
0,2,2,1,1,2,2,1,
0,2,2,2,2,2,2,2,
0,0,1,1,1,2,2,1,
0,0,0,0,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,2,2,1,1,1,1,1,
0,2,2,2,2,2,1,0,
0,0,1,1,1,2,2,0,
1,2,2,2,2,2,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,0,0,
0,2,2,1,1,1,1,0,
0,2,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,0,1,1,1,2,2,1,
0,0,0,0,2,2,1,1,
0,0,0,2,2,1,1,0,
0,0,0,2,2,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,1,2,2,2,2,1,1,
0,2,2,1,1,2,2,0,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,1,2,2,2,2,2,1,
0,0,0,1,1,2,2,1,
0,0,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,2,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,2,2,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,2,2,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,2,2,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,2,2,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,1,0,0,
0,0,0,0,2,2,0,0,
0,0,2,2,2,1,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,2,2,2,2,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,2,2,2,2,1,
0,2,2,1,1,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,2,2,2,1,1,
0,2,2,1,1,2,2,0,
0,2,2,2,2,2,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,0,1,1,
0,2,2,1,0,2,2,0,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,2,2,2,2,2,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,2,2,1,1,1,1,1,
0,2,2,2,2,2,0,0,
0,2,2,1,1,1,1,0,
0,2,2,2,2,2,2,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,2,2,1,1,1,1,1,
0,2,2,2,2,2,0,0,
0,2,2,1,1,1,1,0,
0,2,2,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,2,0,
0,2,2,1,1,1,1,1,
0,2,2,1,2,2,2,0,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,2,1,
0,0,0,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,2,2,2,2,1,
0,2,2,1,1,2,2,1,
0,2,2,1,0,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,2,2,2,2,0,0,
0,0,0,2,2,1,1,0,
0,0,0,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,2,2,2,2,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,2,2,0,
0,0,0,0,0,2,2,1,
0,0,0,0,0,2,2,1,
0,2,2,0,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,2,2,1,1,
0,2,2,2,2,1,1,0,
0,2,2,1,2,2,0,0,
0,2,2,1,0,2,2,0,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,0,0,0,
0,2,2,1,0,0,0,0,
0,2,2,1,0,0,0,0,
0,2,2,1,0,0,0,0,
0,2,2,2,2,2,2,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,2,2,2,2,1,
0,2,2,1,1,2,2,1,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,2,0,2,2,1,
0,2,2,2,2,2,2,1,
0,2,2,1,2,2,2,1,
0,2,2,1,0,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,2,2,2,1,1,
0,2,2,1,1,1,1,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,1,1,2,2,0,
0,0,0,0,0,0,1,1,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,1,0,
0,2,2,1,1,2,2,0,
0,2,2,2,2,2,1,1,
0,2,2,1,1,2,2,0,
0,2,2,1,0,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,2,2,2,0,
0,2,2,1,1,1,1,1,
0,1,2,2,2,2,1,0,
0,0,0,1,1,2,2,0,
0,2,2,2,2,2,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,0,1,2,2,1,1,1,
0,0,0,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,0,2,2,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,2,2,1,2,2,1,1,
0,2,2,2,2,1,1,0,
0,0,1,1,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,0,2,2,1,
0,2,2,1,0,2,2,1,
0,2,2,2,2,2,2,1,
0,2,2,1,1,2,2,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
2,2,0,0,0,2,2,0,
0,2,2,0,2,2,1,1,
0,0,2,2,2,1,1,0,
0,2,2,1,2,2,0,0,
2,2,1,1,0,2,2,0,
0,1,1,0,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,0,0,2,2,0,
0,2,2,1,0,2,2,1,
0,1,2,2,2,2,1,1,
0,0,0,2,2,1,1,0,
0,0,0,2,2,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,2,2,0,
0,0,1,1,2,2,1,1,
0,0,0,2,2,1,1,0,
0,0,2,2,1,1,0,0,
0,2,2,2,2,2,2,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,2,2,2,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,2,2,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,2,2,0,0,0,0,
0,0,2,2,1,0,0,0,
0,0,1,2,2,0,0,0,
0,0,0,2,2,1,0,0,
0,0,0,1,2,2,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,2,2,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,0,0,2,2,0,0,0,
0,2,2,2,2,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,0,0,0,0,
0,0,2,2,2,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
2,2,2,2,2,2,2,2,

};
unsigned char font[]={
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,0,0,0,
0,3,3,1,0,0,0,0,
0,3,3,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,3,3,0,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,3,3,0,0,
0,3,3,1,3,3,1,0,
0,0,1,1,0,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,0,3,0,0,
0,3,3,3,3,3,3,0,
0,0,3,1,3,1,1,1,
3,3,3,3,3,3,0,0,
0,3,1,3,1,1,1,0,
0,0,1,0,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,3,0,0,0,0,
0,2,3,3,3,3,0,0,
0,3,1,3,1,1,1,0,
0,2,3,3,3,2,0,0,
0,0,1,3,1,3,1,0,
0,3,3,3,3,2,1,0,
0,0,1,3,1,1,1,0,
0,0,0,0,1,0,0,0,

0,0,0,0,0,0,0,0,
3,3,0,2,3,1,0,0,
3,3,1,3,2,1,0,0,
0,1,2,3,1,1,0,0,
0,1,3,2,1,3,3,0,
0,2,3,1,1,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,1,3,1,0,0,0,
0,0,3,0,3,0,0,0,
0,1,3,3,3,1,3,0,
0,3,3,1,3,3,0,1,
0,1,3,3,3,1,3,0,
0,0,0,1,1,1,0,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,0,0,0,
0,3,3,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,1,3,3,0,
0,0,0,0,3,3,1,1,
0,0,0,0,3,3,1,0,
0,0,0,0,3,3,1,0,
0,0,0,0,3,3,1,0,
0,0,0,0,3,3,1,0,
0,0,0,0,1,3,3,0,
0,0,0,0,0,0,1,1,

0,3,3,1,0,0,0,0,
0,0,3,3,0,0,0,0,
0,0,3,3,1,0,0,0,
0,0,3,3,1,0,0,0,
0,0,3,3,1,0,0,0,
0,0,3,3,1,0,0,0,
0,3,3,1,1,0,0,0,
0,0,1,1,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,0,0,0,0,
0,0,1,3,1,0,0,0,
2,3,3,3,3,3,2,0,
0,1,3,2,3,1,1,1,
0,2,1,1,1,2,0,0,
0,0,1,0,0,0,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,0,0,0,0,
0,0,0,3,1,0,0,0,
0,3,3,3,3,3,0,0,
0,0,1,3,1,1,1,0,
0,0,0,3,1,0,0,0,
0,0,0,0,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,3,3,0,0,0,0,0,
0,3,1,1,0,0,0,0,
0,0,1,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,3,3,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,3,3,0,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,2,3,1,0,0,
0,0,1,3,2,1,0,0,
0,0,2,3,1,1,0,0,
0,1,3,2,1,0,0,0,
0,2,3,1,1,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,3,0,0,0,
0,0,3,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,0,1,1,1,3,3,0,
0,1,3,3,3,3,1,1,
0,3,3,1,1,1,1,0,
0,3,3,3,3,3,3,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,0,1,1,1,3,3,0,
0,0,3,3,3,3,1,1,
0,0,0,1,1,3,3,0,
0,3,3,3,3,3,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,3,3,3,0,
0,0,3,3,1,3,3,1,
0,3,3,1,1,3,3,1,
0,3,3,3,3,3,3,3,
0,0,1,1,1,3,3,1,
0,0,0,0,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,3,3,1,1,1,1,1,
0,3,3,3,3,3,1,0,
0,0,1,1,1,3,3,0,
1,3,3,3,3,3,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,0,0,
0,3,3,1,1,1,1,0,
0,3,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,0,1,1,1,3,3,1,
0,0,0,0,3,3,1,1,
0,0,0,3,3,1,1,0,
0,0,0,3,3,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,1,3,3,3,3,1,1,
0,3,3,1,1,3,3,0,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,1,3,3,3,3,3,1,
0,0,0,1,1,3,3,1,
0,0,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,0,0,0,0,
0,0,0,1,1,0,0,0,
0,0,3,3,0,0,0,0,
0,0,0,1,1,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,0,0,0,0,
0,0,0,1,1,0,0,0,
0,0,3,3,0,0,0,0,
0,0,3,1,1,0,0,0,
0,0,0,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,3,3,0,0,0,
0,0,3,3,1,1,0,0,
0,0,0,3,3,0,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,3,3,0,0,
0,0,0,1,1,1,1,0,
0,0,3,3,3,3,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,0,0,0,0,
0,0,0,3,3,0,0,0,
0,0,3,3,1,1,0,0,
0,0,0,1,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,1,0,0,
0,0,1,1,3,3,0,0,
0,0,3,3,3,1,1,0,
0,0,0,1,1,1,0,0,
0,0,3,3,0,0,0,0,
0,0,0,1,1,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,3,3,3,3,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,3,3,3,3,1,
0,3,3,1,1,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,3,3,3,1,1,
0,3,3,1,1,3,3,0,
0,3,3,3,3,3,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,0,1,1,
0,3,3,1,0,3,3,0,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,3,3,3,3,3,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,3,3,1,1,1,1,1,
0,3,3,3,3,3,0,0,
0,3,3,1,1,1,1,0,
0,3,3,3,3,3,3,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,3,3,1,1,1,1,1,
0,3,3,3,3,3,0,0,
0,3,3,1,1,1,1,0,
0,3,3,1,0,0,0,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,3,0,
0,3,3,1,1,1,1,1,
0,3,3,1,3,3,3,0,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,3,1,
0,0,0,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,3,3,3,3,1,
0,3,3,1,1,3,3,1,
0,3,3,1,0,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,3,3,3,3,0,0,
0,0,0,3,3,1,1,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,3,3,3,3,0,0,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,3,3,0,
0,0,0,0,0,3,3,1,
0,0,0,0,0,3,3,1,
0,3,3,0,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,3,3,1,1,
0,3,3,3,3,1,1,0,
0,3,3,1,3,3,0,0,
0,3,3,1,0,3,3,0,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,0,0,0,
0,3,3,1,0,0,0,0,
0,3,3,1,0,0,0,0,
0,3,3,1,0,0,0,0,
0,3,3,3,3,3,3,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,3,3,3,3,1,
0,3,3,1,1,3,3,1,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,3,0,3,3,1,
0,3,3,3,3,3,3,1,
0,3,3,1,3,3,3,1,
0,3,3,1,0,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,3,3,3,1,1,
0,3,3,1,1,1,1,0,
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,1,1,3,3,0,
0,0,0,0,0,0,1,1,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,1,0,
0,3,3,1,1,3,3,0,
0,3,3,3,3,3,1,1,
0,3,3,1,1,3,3,0,
0,3,3,1,0,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,1,3,3,3,3,3,0,
0,3,3,1,1,1,1,1,
0,1,3,3,3,3,1,0,
0,0,0,1,1,3,3,0,
0,3,3,3,3,3,1,1,
0,0,1,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,0,1,3,3,1,1,1,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,1,1,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,3,3,1,3,3,1,1,
0,3,3,3,3,1,1,0,
0,0,1,1,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,0,3,3,1,
0,3,3,1,0,3,3,1,
0,3,3,3,3,3,3,1,
0,3,3,1,1,3,3,1,
0,0,1,1,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
3,3,0,0,0,3,3,0,
0,3,3,0,3,3,1,1,
0,0,3,3,3,1,1,0,
0,3,3,1,3,3,0,0,
3,3,1,1,0,3,3,0,
0,1,1,0,0,0,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,0,0,3,3,0,
0,3,3,1,0,3,3,1,
0,1,3,3,3,3,1,1,
0,0,0,3,3,1,1,0,
0,0,0,3,3,1,0,0,
0,0,0,0,1,1,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,3,3,0,
0,0,1,1,3,3,1,1,
0,0,0,3,3,1,1,0,
0,0,3,3,1,1,0,0,
0,3,3,3,3,3,3,0,
0,0,1,1,1,1,1,1,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,3,3,3,0,
0,0,0,3,3,1,1,1,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,3,3,0,
0,0,0,0,1,1,1,1,

0,0,0,0,0,0,0,0,
0,1,3,2,0,0,0,0,
0,0,2,3,1,0,0,0,
0,0,1,3,2,0,0,0,
0,0,0,2,3,1,0,0,
0,0,0,1,3,2,0,0,
0,0,0,0,0,1,1,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,3,3,3,3,0,0,0,
0,0,1,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,0,0,3,3,1,0,0,
0,3,3,3,3,1,0,0,
0,0,1,1,1,1,0,0,

0,0,0,0,0,0,0,0,
0,0,0,3,0,0,0,0,
0,0,3,3,3,0,0,0,
0,0,0,1,1,1,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
3,3,3,3,3,3,3,3,

};



void colors(void)
{
int i;

	zerocolor=bgcolor=fontmap[0]=maprgb(255,255,255);
	fontmap[1]=maprgb(192,192,192);
	fontmap[2]=maprgb(128,128,128);
	fontmap[3]=maprgb(64,64,64);

}

int celmax(int f) {
	cel *acel;
	int i;
	acel=frames[f].cellist;
	i=1;
	while(acel) {++i;acel=acel->next;}
	return i;
}

int where()
{
	if(mousex>=DX+20 && mousey<DY)
		return (mousey>>3) | MOUSE_COMAREA;
	if(mousex<DX && mousey>=DY)
		return (mousey-DY>>3) | MOUSE_LIST;
	if(mousex<DX && mousey<DY)
		return MOUSE_SCREEN;
}
int readmouse() {
	mousedown=mouseb & ~mousebold;
	mouseup=~mouseb & mousebold;
	mousebold=mouseb;
	mouseat=where();
	if(mouseat==MOUSE_SCREEN)
	{
		mousedx=mousex-mouseoldx;
		mousedy=mousey-mouseoldy;
		mouseoldx=mousex;
		mouseoldy=mousey;
	} else
		mousedx=mousedy=0;
	if(mouseupordown) // mouse is down
	{
		if(mouseup)
		{
			mouseupx=mousex;
			mouseupy=mousey;
			mouseupordown=0;
			mouseuppos=mouseat;
		}
	} else		// mouse is up
	{
		if(mousedown)
		{
			mousedownx=mousex;
			mousedowny=mousey;
			mouseupordown=1;
			mousedownpos=mouseat;
			if(mousedownpos==MOUSE_SCREEN)
				mousepixelid=pixelid[mousedowny*IDX+mousedownx];
		}
	}
	return mouseb;
}

int commandmap[]={
CODE_NEWCEL,
CODE_DUPFRAME,
CODE_CELTOBOTTOM,
CODE_PLAY,
CODE_NEXT,
CODE_PREV,
CODE_HELP
};
int processmouse(int framenum)
{
int which,where;

	readmouse();
	where=mousedownpos&MOUSE_MASK;
	which=mousedownpos&~MOUSE_MASK;
	if(framenum==DISPLAY_CELS)
	{
		if(mousedown&1) return CODE_LEFTCLICK;
		return 0;
	}
	if(mousedown&1)
	{
		if(where==MOUSE_COMAREA)
		{
			if(which<numfiles)
				return CODE_CHANGEFILE;
			if(which>=COMMANDLINE &&
				 which-COMMANDLINE<sizeof(commandmap)/sizeof(int))
				return commandmap[which-COMMANDLINE];
		} else if(where==MOUSE_LIST)
		{
			if(which>0 && which<=celmax(framenum))
				return CODE_TOGGLE;
		}
	}
	if((mouseb&1) && where==MOUSE_SCREEN && mouseat==MOUSE_SCREEN)
		return CODE_MOVECEL;
	if((mousedown&2) && where==MOUSE_SCREEN)
		return CODE_CHANGECEL;
	return 0;
}

void mousedot(int x,int y,unsigned short **p,unsigned char c2,int on)
{
	if(on)
	{
		*(*p)++=getdot(x,y);
		if(drawmouse)
			dot(x,y,fontmap[c2]);
	} else
	{
		dot(x,y,*(*p)++);
	}
}
unsigned char mousepoints[]=
{
1,1,0,
1,2,0,
1,3,0,
1,4,0,
1,5,0,
2,1,0,
3,1,0,
4,1,0,
5,1,0,
2,2,0,
3,3,0,
4,4,0,
5,5,0,
6,6,0,
7,7,0,
8,8,0,
9,9,0,
0,0,3,
1,0,3,
2,0,3,
3,0,3,
4,0,3,
5,0,3,
6,0,3,
6,1,3,
6,2,3,
5,2,3,
4,2,3,
3,2,3,
4,3,3,
5,4,3,
6,5,3,
7,6,3,
8,7,3,
9,8,3,
10,9,3,
9,10,3,
8,9,3,
7,8,3,
6,7,3,
5,6,3,
4,5,3,
3,4,3,
2,3,3,
2,4,3,
2,5,3,
2,6,3,
1,6,3,
0,6,3,
0,5,3,
0,4,3,
0,3,3,
0,2,3,
0,1,3,
128
};


void domouse(int on)
{
int i;
int j;
static unsigned short save[64],*p;
unsigned char c,*pnts;
int x,y;
	j=255;
	p=save;
	pnts=mousepoints;
	for(;;)
	{
		x=*pnts++;
		if(x==128) break;
		y=*pnts++;
		c=*pnts++;
		mousedot(mousex+x,mousey+y,&p,c,on);
	}	
}


int kr(void)
{
	return keyput!=keytake;
}

int wci(void)
{
	int ch,q;

	while(!kr())
		scaninput();
	ch=keylist[keytake].code;
	q=keylist[keytake].qual;
	keytake=keytake+1&MAXKEYS-1;

	return ch;

	if(!(ch & 0xff)) ch=(ch>>8)+0x100;
	else ch&=0xff;
	if((q&3) && ch>=0x100) ch+=0x200; /* shift keys */
	return ch;
}

int _getline(char *p)
{
char ch;
char *p2;
	p2=p;
	while(ch=*take)
	{
		++take;
		if(ch=='\r') continue;
		if(ch=='\n') break;
		*p2++=ch;
	}
	*p2=0;
	return *p;
}
cel *newcel(void)
{
cel *acel;
	acel=malloc(sizeof(cel));
	if(acel)
		memset(acel,0,sizeof(cel));
	return acel;
}
void freecel(cel *acel)
{
	if(acel) free(acel);
}

int getnum(char **p)
{
int sign;
char ch;
int val;

	if(**p=='-') {sign=-1;++*p;}
	else sign=1;
	val=0;
	while(ch=**p)
	{
		++*p;
		if(ch>='0' && ch<='9')
			val=val*10+ch-'0';
		else
			break;
	}
	return val*sign;
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

void die(char *p,int val)
{
	printf("Dead, error code %d\n",val);
	printf("%s", p);
	exit(val);
}

char *getfile(char *name,int *size)
{
	int file;
	int len;
	char *p;
	int res;

	file=open(name,O_RDONLY|O_BINARY);
	if(file<0)
	{
		sprintf(errstr,"Could not get file %s\n",name);
		die(errstr,25);
	}
	*size=len=lseek(file,0L,SEEK_END);
	p=malloc(len+1);
	if(!p) {sprintf(errstr,"panic, no memory %d\n",len);die(errstr,22);}
	lseek(file,0L,SEEK_SET);
	res=read(file,p,len);res=res;
	close(file);
	p[len]=0;
	return p;
}
void getanimfile(struct animfile *af,char *name,int colorbase)
{
unsigned char root[256];
char temp[256];
unsigned char *p1;
int i,r,g,b,in;


	strcpy(root,name);
	p1=root+strlen(root);
	while(p1>root)
	{
		if(*p1=='.') {*p1=0;break;}
		--p1;
	}
	sprintf(temp,"%s.map",root);
	af->map=getfile(temp,&af->mapsize);
	sprintf(temp,"%s.chr",root);
	af->chr=getfile(temp,&af->chrsize);
	sprintf(temp,"%s.rgb",root);
	af->rgb=getfile(temp,&af->rgbsize);
	p1=af->rgb;
	af->colorbase=colorbase;
	for(i=colorbase;i<colorbase+32;i++)
	{
		in=*p1 | (p1[1]<<8);
		p1+=2;
		r=in&0x1f;
		g=(in>>5) & 0x1f;
		b=(in>>10) & 0x1f;
		thecmap[i].red=r<<3;
		thecmap[i].green=g<<3;
		thecmap[i].blue=b<<3;
	}
}
int parseinput(char *input)
{
char *p1,*p2;
char linebuff[256];
int spritenum=0,whichanim=0,deltax=0,deltay=0;
cel *acel,*lastcel;
int i,j;

	take=input;
	numframes=0;
	numfiles=0;
	if(_getline(backgroundname))
		convert(backgroundname,groups,0);
	while(_getline(filenames[numfiles]))
	{
		if(realsprites)
			getanimfile(animfiles+numfiles,filenames[numfiles],32+(numfiles<<5));
		fixname(fixednames[numfiles],filenames[numfiles]);
		groups[numfiles].start=numgfx;
		i=convert(filenames[numfiles],groups+numfiles,1);
		if(i<0) {printf("Serious error, %d, exiting\n",i);exit(50);}
		++numfiles;
	}
	while(*take)
	{
		lastcel=0;
		frames[numframes].bgdx=0;
		frames[numframes].bgdy=0;
		while(_getline(linebuff))
		{
			p1=linebuff;

			whichanim=getnum(&p1);
			spritenum=getnum(&p1);
			if(p1[-1]!=',')
			{
				frames[numframes].bgdx=whichanim;
				frames[numframes].bgdy=spritenum;
				continue;
			}
			deltax=getnum(&p1);
			deltay=getnum(&p1);
/*
if(whichanim==3)
{
	frames[numframes].bgdx=deltax+80;
	frames[numframes].bgdy=deltay+100-28;
	continue;
}
*/

			acel=newcel();
			if(!acel) return 16;
			acel->next=0;
			acel->filenumber=whichanim&0x7f;
			acel->spritenumber=spritenum;
			if(whichanim&0x80) acel->flags|=CEL_FLIPX;
			acel->deltax=deltax; //+64+18;
			acel->deltay=deltay; //+95+32;
			if(lastcel)
				lastcel->next=acel;
			else
				frames[numframes].cellist=acel;
			lastcel=acel;
		}
		++numframes;
	}
	frames[numframes].cellist=0;
	++numframes;
/*
	for(i=0;i<numfiles;i++)
		printf("File %02d:%s\n",i,filenames[i]);
	for(i=0;i<numframes;i++)
	{
		printf("--- Frame %d ---\n",i);
		acel=frames[i].cellist;
		while(acel)
		{
			printf("filenumber=%3d ",acel->filenumber);
			printf("spritenumber=%3d ",acel->spritenumber);
			printf("deltax=%3d ",acel->deltax);
			printf("deltay=%3d\n",acel->deltay);
			acel=acel->next;
		}
	}
*/
	return 0;
}


void selectfont(int f)
{
	if(f) currentfont=font;
	else currentfont=font2;
}

void drawchar(int x,int y,int ch)
{
int i,j;
unsigned char *p1;
unsigned short *p2;

	ch=toupper(ch);
	if(ch<0x20 || ch>=0x60) return;
	ch-=0x20;
	p1=currentfont+(ch<<6);
	p2=video+y*videowidth+x;
	if(x<0 || y<0 || x>videowidth-8 || y>videoheight-8) return;
	for(j=0;j<8;j++)
	{
		*p2=fontmap[*p1++];
		p2[1]=fontmap[*p1++];
		p2[2]=fontmap[*p1++];
		p2[3]=fontmap[*p1++];
		p2[4]=fontmap[*p1++];
		p2[5]=fontmap[*p1++];
		p2[6]=fontmap[*p1++];
		p2[7]=fontmap[*p1++];
		p2+=videowidth;
	}
}
void drawstring(int x,int y,char *p)
{
int ox;
char ch;
	ox=x;
	while(ch=*p++)
	{
		if(ch=='\n')
		{
			x=ox;
			y+=8;
		} else
		{
			drawchar(x,y,ch);
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

void frameinfo(int f,int sel1,int sel2,int flag)
{
cel *acel;
int x,y;
int i;
cel testcel;


	x=0;
	y=DY;
	if(flag)
	{
		selectfont(1);
		if(f<numframes-1)
			drawprintf(x,y,"FRAME %3d/%3d ",f+1,numframes-1);
		else
			drawprintf(x,y," --END-- /%3d ",numframes-1);
		if(f<numframes-1)
		{
			y+=8;
			selectfont(sel1==0);
			drawprintf(x,y,"%cBACKGROUND  DX%03d DY%03d",
					(selected&1) ? '*' : ' ',
					frames[f].bgdx,frames[f].bgdy);
			y+=8;
			i=1;
			acel=frames[f].cellist;
			while(acel && i<8)
			{
				selectfont(i==sel1);
				drawprintf(x,y,"%cOBJ%02d FIG%02d DX%03d DY%03d %c %s",
					((2<<acel->filenumber)&selected) ? '*' : ' ',
					acel->filenumber,acel->spritenumber,acel->deltax,acel->deltay,
					(acel->flags&CEL_FLIPX) ? 'X':' ',
					fixednames[acel->filenumber]);
				acel=acel->next;
				y+=8;
				++i;
			}
		}
	} else
	{
		selectfont(1);
		drawprintf(x,y,"FRAME %3d/%3d  %2dFPS",f+1,numframes-1,
			speedrates[playspeed]);
	}
}
void drawhelp()
{
	clear(fontmap[0]);
	selectfont(1);
	drawstring(0,0,helptext);
	drawstring(DX,0,helptext2);
}
int32_t getlong(unsigned char *p)
{
	return *p | (p[1]<<8) | (p[2]<<16) | (p[3]<<24);
}

void putchr(unsigned char *p1,int x,int y,int color)
{
int i,j;
int a,b,c;
int xt,yt;
unsigned char *sz;

	for(j=0;j<8;++j)
	{
		a=*p1++;
		b=*p1++;
		yt=y+j;
		if(yt<16 || yt>=128) continue;
		++perlines[yt];
		if(perlines[yt]>10) continue;
		sz=spritez+yt*DX;
		for(i=0;i<8;i++)
		{
			xt=x+i;
			c=(a&0x80) ? 1 : 0;
			c|=(b&0x80) ? 2 : 0;
			a<<=1;
			b<<=1;
			if(c && xt>=0 && xt<DX && !sz[xt])
			{
				dot(xt,yt,c+color);
				sz[xt]=1;
			}
		}
	}
}

void putsprite(struct animfile *af,int x,int y,int which)
{
unsigned char *p1;
char gx,gy,tx,ty;
unsigned char info1,info2;
int h,n;
int i,j,k;
int color,colorbase;

	if(getlong(af->map)>>2 <= which+1) return; // invalid sprite #
	p1=af->map+getlong(af->map + (which+1<<2));
	gx=*p1++;
	gy=*p1++;
	info1=*p1++;
	info2=*p1++;
	h=1+(info2&1);
	n=info2>>1;
	colorbase=af->colorbase;
	while(n--)
	{
		tx=*p1++;
		ty=*p1++;
		++spritesused;
		for(i=0;i<h;i++)
		{
			k=*p1 | (p1[1]<<8);
			color=(k>>8) & 7;
			color=colorbase + (color<<2);
			k&=255;
			p1+=2;
//			if(spritesused<=40)
				putchr(af->chr + (k<<4),x+gx+tx,y+gy+ty+(i<<3),color);

		}
	}
}
void forcpy(unsigned short *dest,unsigned short *src,int len)
{
	while(len--)
		*dest++=*src++;
}
void putcelnoclip(int num,int xpos,int ypos) {
	int i,j,k;
	unsigned short *p1,*p2;
	int offset;
	int xt;
	int dx,dy,cx,cy;

	p1=compressed[num];
	if(!p1) return;
	for(;;)
	{
		dx=*p1++;
		if(dx==0x8000) break;
		dy=*p1++;
		if(dx>0x7fff) dx-=0x10000L;
		if(dy>0x7fff) dy-=0x10000L;
		j=*p1++;
		p2=p1;
		p1+=j;
		cx=xpos+dx;
		cy=ypos+dy;
		if(cy<0 || cy>=DY) continue;
		if(cx+j<=0 || cx>=DX) continue;
		if(cx<0)
		{
			j+=cx;
			p2-=cx;
			cx=0;
		}
		if(cx+j>DX)
			j=DX-cx;
		if(j>0)
			forcpy(video+cy*videowidth+cx,p2,j);
	}
}

void paint(int f,int sel1,int sel2,int flag)
{
cel *acel;
struct group *grp;
cel *celstack[256];
int i,j,k,l,u,v,t1,t2,t3,t4;
unsigned char used[256],needs[256];
unsigned char *p1;
int overs,goods;

	memset(spritez,0,DX*DY);
	memset(pixelid,0,IDY*IDX);
	pixelidval=0;
	for(i=0;i<256;++i) perlines[i]=0;
	spritesused=0;
	frameinfo(f,sel1,sel2,flag);
	if(flag)
	{
		selectfont(1);
		drawstring(DX+20,COMMANDLINE<<3,commands);
		for(i=0;i<numfiles;++i)
		{
			selectfont((i==filewant) ? 1 : 0);
			drawstring(DX+20,i<<3,fixednames[i]);
		}
	}

	if(f==numframes-1) return;
	if(!(mask & NO_DRAW_BG))
		if(mask)
			putcelnoclip(0,0,0);
		else
			putcel(0,frames[f].bgdx,frames[f].bgdy,0);
	acel=frames[f].cellist;
	i=0;
	if(realsprites)
	{
		while(acel)
		{
			putsprite(animfiles+acel->filenumber,
				acel->deltax+80,acel->deltay+72,acel->spritenumber);
			acel=acel->next;
		}
	} else
	{
		while(acel)
		{
			celstack[i++]=acel;
			acel=acel->next;
		}
		while(i--)
		{
			acel=celstack[i];
			pixelidval=i+1;
			grp=groups+acel->filenumber;
			if(acel->spritenumber < grp->length)
			{
				if((mask&NO_DRAW_CELS) && grp->type) continue;
				putcel(grp->start+acel->spritenumber,
					acel->deltax+80,
					acel->deltay+72,acel->flags);
			}
		}
	}
}

cel *getcel(int f,int which) {
	cel *acel;
	if(which<0) return 0;
	acel=frames[f].cellist;
	while(acel && which--) acel=acel->next;
	return acel;
}

void revcpy(unsigned short *dest,unsigned short *src,int len) {
	while(len--)
		*dest++=*--src;
}

void putcel(int num,int xpos,int ypos,int flags) {
	int i,j,k,len;
	unsigned short *p1,*p2;
	int offset;
	int clipymax;
	int clipymin;
	int xt;
	int dx,dy,cx,cy;
	int pixelidset;

	p1=compressed[num];
	if(!p1) return;
	if(letterbox)
	{
		clipymin=16;
		clipymax=128;
	} else
	{
		clipymin=0;
		clipymax=DY;
	}
	for(;;)
	{
		dx=*p1++;
		if(dx==0x8000) break;
		dy=*p1++;
		if(dx>0x7fff) dx-=0x10000L;
		if(dy>0x7fff) dy-=0x10000L;
		j=*p1++;
		len=j;
		p2=p1;
		p1+=j;
		if(flags&CEL_FLIPX) dx=-dx-j;
		cx=xpos+dx;
		cy=ypos+dy;
		if(cy<clipymin || cy>=clipymax) continue;
		if(cx+j<=0 || cx>=DX) continue;
		k=0;
		if(cx<0)
		{
			j+=cx;
			k-=cx;
			cx=0;
		}
		if(cx+j>DX)
			j=DX-cx;
		if(j<=0) continue;
		if(flags&CEL_FLIPX)
			revcpy(video+videowidth*cy+cx,p2+len-k,j);
		else
			forcpy(video+videowidth*cy+cx,p2+k,j);
		pixelidset=cy*IDX+cx;
		if(pixelidset+j<IDY*IDX)
			memset(pixelid+pixelidset,pixelidval,j);
	}
}
void putsimplecel(int num,int xpos,int ypos) {
	int i,j,k;
	unsigned short *p1,*p2;
	int offset;
	int xt;
	int dx,dy,cx,cy;

	p1=compressed[num];
	if(!p1) return;
	for(;;)
	{
		dx=*p1++;
		if(dx==0x8000) break;
		dy=*p1++;
		if(dx>0x7fff) dx-=0x10000L;
		if(dy>0x7fff) dy-=0x10000L;
		j=*p1++;
		p2=p1;
		p1+=j;
		cx=xpos+dx;
		cy=ypos+dy;
		if(cy<0 || cy>=200) continue;
		if(cx+j<=0 || cx>=320) continue;
		if(cx<0)
		{
			j+=cx;
			p2-=cx;
			cx=0;
		}
		if(cx+j>320)
			j=320-cx;
		if(j>0);
			forcpy(video+cy*videowidth+cx,p2,j);
	}
}


unsigned short *compress(char *image,int width,int height,int perrow,int usetransp,
		int offsetx,int offsety,struct acolor *tmap)
{
unsigned short *p1;
unsigned char *p2;
int i,j,k,l;
int offset;
struct acolor *ac;

	p1=buffer2w;
	p2=image;
	if(!usetransp)
	{
		for(j=0;j<height;j++)
		{
			*p1++=-offsetx;
			*p1++=j-offsety;
			*p1++=width;
			for(l=0;l<width;++l)
			{
				ac=tmap+p2[l];
				*p1++=maprgb(ac->red,ac->green,ac->blue);
			}
//			memcpy(p1,p2,width);
//			p1+=width;
			p2+=perrow;
		}
	} else
	{
		k=0;
		for(j=0;j<height;j++)
		{
			for(i=0;i<width;i++)
			{
				if(p2[i])
				{
					++k;
				} else
				{
					if(k)
					{
						*p1++=i-k-offsetx;
						*p1++=j-offsety;
						*p1++=k;
						for(l=0;l<k;++l)
						{
							ac=tmap+p2[i-k+l];
							*p1++=maprgb(ac->red,ac->green,ac->blue);
						}
//						memcpy(p1,p2+i-k,k);
//						p1+=k;
						k=0;
					}
				}
			}
			if(k)
			{
				*p1++=i-k-offsetx;
				*p1++=j-offsety;
				*p1++=k;
				for(l=0;l<k;++l)
				{
					ac=tmap+p2[i-k+l];
					*p1++=maprgb(ac->red,ac->green,ac->blue);
				}
//				memcpy(p1,p2+i-k,k);
//				p1+=k;
				k=0;
			}
			offset+=videowidth;
			p2+=perrow;
		}
	}

	*p1++=0x8000;
	i=(p1-buffer2w)<<1;
	p1=malloc(i);
	if(p1)
		memcpy(p1,buffer2w,i);
	return p1;
}

int same(int c1,int c2)
{
	c1-=c2;
	if(c1<0) c1=-c1;
	return c1<40;
}


int convert(char *name,struct group *grp,int havetransp)
{
FILE *              pfile;
ERRORCODE           (*pfinitread)(void **, FILE *, DATATYPE_T);
DATABLOCK_T *       (*pfreaddata)(void **);
FILE *              (*pfquitread)(void **);
DATABLOCK_T *       pdbh;
DATABITMAP_T *      pbmh;
void *pvoid;
int i,j,k,width,height,perrow,cc;
unsigned char *p1,*p2;
int numpics;
int remap[256];
int red,green,blue;
int tempdx,tempdy;
int nontransp;
struct acolor tempmap[256];
int coloradd;
int newcolor;
int coloraddavg;
int spritefix=-1;
unsigned char colortrans[256];

	pfile=fopen(name, "rb");
	if(!pfile)
	{
		printf("Failed to open file %s\n", name);
		return -1;
	}
	if (IffIdentify(pfile) == FILE_IFF)
	{
		pfinitread = IffInitRead;
		pfreaddata = IffReadData;
		pfquitread = IffQuitRead;
	} else
	if(SprIdentify(pfile) == FILE_SPR)
	{
		pfinitread = SprInitRead;
		pfreaddata = SprReadData;
		pfquitread = SprQuitRead;
	} else
	if (PcxIdentify(pfile) == FILE_PCX)
	{
		pfinitread = PcxInitRead;
		pfreaddata = PcxReadData;
		pfquitread = PcxQuitRead;
	} else {
		printf("Unknown graphics file type %s\n", name);
		return -2;
	}

	if ((*pfinitread)(&pvoid, pfile, DATA_BITMAP) != ERROR_NONE)
		return -3;
	numpics=0;
	for(i=0;i<256;i++) remap[i]=-1;
	grp->offsetx=0;
	grp->offsety=0;
	coloraddavg=0;
	while(pdbh= (*pfreaddata)(&pvoid))
	{
		pbmh=(DATABITMAP_T *)pdbh;
		perrow=pbmh->si___bmLineSize;
		width=pbmh->ui___bmW;
		height=pbmh->ui___bmH;
		if(!numpics)
		{
			grp->sizex=width;
			grp->sizey=height;
		}
		numpics++;

		coloradd=0;
		if(havetransp  && (width<DX || height<112))
			coloradd=128;
		else
			havetransp=0;
		coloraddavg+=coloradd;

		for(i=0;i<256;++i)
			colortrans[i]=i;
#if 0
		for(i=0;i<128;i+=16)
		{
		int bright[4];
		int order[4];
		int max,maxnum;

			for(j=0;j<4;++j)
			{
				bright[j]=pbmh->acl__bmC[i+j].ub___rgbR*6;
				bright[j]+=pbmh->acl__bmC[i+j].ub___rgbG*8;
				bright[j]+=pbmh->acl__bmC[i+j].ub___rgbB*3;
			}
			for(j=0;j<4;++j)
			{
				max=-1;
				for(k=0;k<4;++k)
				{
					if(bright[k]>max)
					{
						max=bright[k];
						maxnum=k;
					}
				}
				bright[maxnum]=-1;
				order[j]=maxnum;
			}
			for(j=0;j<4;++j)
				colortrans[i+j]=i+order[j];
		}
#endif


		p1=pbmh->pub__bmBitmap;
		nontransp=0;
		for(j=0;j<height;j++)
		{
			p2=p1;
			for(i=0;i<width;i++)
			{
				k=*p2++;
				if(k || !havetransp || !coloradd)
				{
					if(!nontransp)
					{
						tempdx=i;
						tempdy=j;
					}
					++nontransp;
				}
			}
			p1+=perrow;
		}
		if(nontransp==1 && numpics==1)
		{
			grp->offsetx=tempdx;
			grp->offsety=tempdy;
			--numpics;
		}


	for(i=0;i<256;++i)
	{
		tempmap[i].red=pbmh->acl__bmC[i].ub___rgbR;
		tempmap[i].green=pbmh->acl__bmC[i].ub___rgbG;
		tempmap[i].blue=pbmh->acl__bmC[i].ub___rgbB;
	}

		compressed[numgfx]=compress(pbmh->pub__bmBitmap,width,height,
						perrow,havetransp,grp->offsetx,grp->offsety,tempmap);
		++numgfx;
		DataFree(pdbh);
	}
	grp->length=numpics;
	grp->start=numgfx-numpics;

	pfile = (*pfquitread)(&pvoid);
	fclose(pfile);
	if(numpics)
		coloraddavg/=numpics;
	grp->type=(coloraddavg<64) ? 0 : 1;
	return numpics;

}


void addline(int file,char *str)
{
	int res;
	res=write(file,str,strlen(str));res=res;
	res=write(file,"\n",1);res=res;
}

int save(char *name)
{
char temp[256];
int file;
int i,j,k;
cel *acel;
int x1,y1,z1,x2,y2,z2,xo,yo,zo,x,y,z,xd,yd,zd,v1,v2,v3;

	sprintf(temp,"%s.pos",name);
	file=open(temp,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return -1;
	addline(file,backgroundname);
	for(i=0;i<numfiles;i++)
		addline(file,filenames[i]);
	for(i=0;i<numframes-1;i++)
	{
		addline(file,"");
		acel=frames[i].cellist;
		sprintf(temp,"%d,%d",frames[i].bgdx,frames[i].bgdy);
		addline(file,temp);
		while(acel)
		{
			sprintf(temp,"%d,%d,%d,%d",acel->filenumber |
					((acel->flags&CEL_FLIPX) ? 0x80 : 0),
				acel->spritenumber,
				acel->deltax,acel->deltay);
			addline(file,temp);
			acel=acel->next;
		}
	}
	close(file);
// BUILDING THE ASM FILE ***********************************************
	sprintf(temp,"%s.asm",name);
	file=open(temp,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return -1;
	for(i=0;i<numfiles;i++)
	{
		sprintf(temp,"\tdw\tPAL_%s",fixednames[i]);
		addline(file,temp);
	}
	addline(file,"\tdw\t0");
	addline(file,"");
	for(i=0;i<numframes-1;i++)
	{
		sprintf(temp,"\tdb\t254,%d,%d",frames[i].bgdx,frames[i].bgdy);
		addline(file,temp);
		acel=frames[i].cellist;
		while(acel)
		{
			sprintf(temp,"\tdb\tIDX_%s+%d,%d,%d,%d",
				fixednames[acel->filenumber],
				acel->spritenumber,
				acel->filenumber | ((acel->flags&CEL_FLIPX) ? 0x80 : 0),
				acel->deltax,acel->deltay);
			addline(file,temp);
			acel=acel->next;
		}
		addline(file,"\tdb\t255");
		addline(file,"");
	}
	addline(file,"\tdb\t249");
	close(file);
// BUILDING THE AS2 FILE ***********************************************
	sprintf(temp,"%s.as2",name);
	file=open(temp,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return -1;
	j=0;
	for(i=0;i<numframes-1;++i)
	{
		k=0;
		acel=frames[i].cellist;
		while(acel)
		{
			++k;
			acel=acel->next;
		}
		if(k>j) j=k;
	}

	sprintf(temp,"\tdb\t%d",j);
	addline(file,temp);
	for(i=0;i<numfiles;i++)
	{
		sprintf(temp,"\tdw\tPAL_%s",fixednames[i]);
		addline(file,temp);
		sprintf(temp,"\tdw\tIDX_%s",fixednames[i]);
		addline(file,temp);
	}
	for(i=0;i<numframes-1;i++)
	{
		acel=frames[i].cellist;
		k=0;
		while(acel)
		{
			sprintf(temp,"\tdb\t%d,%d,%d,%d",
				acel->spritenumber,
				acel->filenumber | ((acel->flags&CEL_FLIPX) ? 0x80 : 0),
				acel->deltax,acel->deltay);
			addline(file,temp);
			acel=acel->next;
			++k;
		}
		while(k++<j)
			addline(file,"\tdb\t-1,0,0,0");
	}
	close(file);

// BUILDING THE JOHN FILE ***********************************************

#ifdef DOJOHN
	sprintf(temp,"%s.jon",name);
	file=open(temp,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return -1;

	xo=yo=zo=0;
	for(i=0;i<numframes-1;i++)
	{
		acel=frames[i].cellist;
		x1=acel->deltax;	// ball position
		y1=acel->deltay;
		acel=acel->next;
		if(acel)
		{
			x2=acel->deltax; // shadow position
			y2=acel->deltay;
		}
		z=y2-y1; // shadowy - bally
		xd=x2-xo;
		yd=y2-yo;
		zd=z-zo;
		xo=x2;
		yo=y2;
		zo=z;


		x=xd-yd-yd;
		y=xd+yd+yd;

		v1=255&(x<<1);
		v2=255&(y<<1);
		v3=255&(zd<<3);
		sprintf(temp,"\tDB\t$%02X,$%02X,$%02X,$%02X,$%02X,$%02X",
			v1,v2,v3,v1,v2,v3);
		addline(file,temp);
	}
	close(file);
#endif

	return 0;
}

void anymove1(int f,int pick,int dx,int dy)
{
cel *acel;
int i;

	if(f==numframes-1) return;
	acel=frames[f].cellist;
	if((selected&1) || (!selected && !pick))
	{
		frames[f].bgdx+=dx;
		frames[f].bgdy+=dy;
	}
	i=1;
	while(acel)
	{
		if(((2<<acel->filenumber)&selected) || (!selected && i==pick))
		{
			acel->deltax+=dx;
			acel->deltay+=dy;
		}
		acel=acel->next;
		++i;
	}
}
void anymove(int f,int pick,int dx,int dy)
{
	if(f>=locklow && f<locklow+locklen)
	{
		f=locklow;
		while(f<locklow+locklen)
			anymove1(f++,pick,dx,dy);
	} else
		anymove1(f,pick,dx,dy);
}
void flipx(int f,int pick)
{
cel *acel;
int i;

	if(f==numframes-1) return;
	acel=frames[f].cellist;
	if((selected&1) || (!selected && !pick))
	{
		return;//can't flip background yet...
	}
	i=1;
	while(acel)
	{
		if(((2<<acel->filenumber)&selected) || (!selected && i==pick))
			acel->flags^=CEL_FLIPX;
		acel=acel->next;
		++i;
	}
}
/*
	if(f==numframes-1) return;
	acel=frames[f].cellist;
	if((selected&1) || (!selected && !pick))
	{
		frames[f].bgdx+=dx;
		frames[f].bgdy+=dy;
	}
	i=1;
	while(acel)
	{
		if(((2<<acel->filenumber)&selected) || (!selected && i==pick))
		{
			acel->deltax+=dx;
			acel->deltay+=dy;
		}
		acel=acel->next;
		++i;
	}

*/


void flipX1(int f)
{
cel *acel;
int i;

	if(f==numframes-1) return;
	acel=frames[f].cellist;
	i=1;
	while(acel)
	{
		if(((2<<acel->filenumber)&selected) || !selected)
		{
			acel->flags^=CEL_FLIPX;
			acel->deltax=-acel->deltax;
		}
		acel=acel->next;
		++i;
	}
}
void flipX(int f)
{
	if(f>=locklow && f<locklow+locklen)
	{
		f=locklow;
		while(f<locklow+locklen)
			flipX1(f++);
	} else
		flipX1(f);
}



void docopy(int f)
{
cel *acel,*pb;

	pb=paste;
	acel=frames[f].cellist;
	pasteselected=selected;
	pastebgdx=frames[f].bgdx;
	pastebgdy=frames[f].bgdy;
	while(acel)
	{
		if(selected & (2<<acel->filenumber))
		{
			*pb=*acel;
/*
			pb->filenumber=acel->filenumber;
			pb->deltax=acel->deltax;
			pb->deltay=acel->deltay;
			pb->spritenumber=acel->spritenumber;
			pb->flags=acel->flags;
*/
			++pb;
		}
		acel=acel->next;
	}
	inpaste=pb-paste;
}
cel *addcel(int f)
{
cel *acel,**celp;
	celp=&(frames[f].cellist);
	while(*celp) celp=&((*celp)->next);
	acel=newcel();
	*celp=acel;
	return acel;
}

void copyframe(int dest,int src)
{
	memcpy(frames+dest,frames+src,sizeof(struct frame));
}

int selectdowns[256]={0};

int handleinput(int frame)
{
int code;

	for(;;)
	{
		scaninput();
		code=processmouse(frame);
		if(code) return code;
		if(kr()) return wci();
		domouse(1);
		copyup();
		domouse(0);
	}
}
void drawbox(int x,int y,int sx,int sy,int c)
{
int i;
	for(i=0;i<sx;++i)
	{
		dot(x+i,y,c);
		dot(x+i,y+sy-1,c);
	}
	for(i=0;i<sy;++i)
	{
		dot(x,y+i,c);
		dot(x+sx-1,y+i,c);
	}
}

void changebgcolor()
{
	bgcolor=(bgcolor+1 & 3) | 252;
}

int picknewcel(int frame)
{
struct group *grp;
int down;
int numx,numy;
int start;
int tx,ty;
int cx,cy;
int visy;
int code;

	grp=groups+filewant;
	for(;;)
	{
		clear(bgcolor);
		numx=320/grp->sizex;
		visy=168/grp->sizey;
		numy=(grp->length+numx-1)/numx;
		start=selectdowns[filewant]*numx;
		ty=16;
		cy=0;
		while(cy<visy && cy<numy)
		{
			tx=0;
			cx=0;
			while(start<grp->length && cx<numx)
			{
				putsimplecel(start+grp->start,tx+grp->offsetx,ty+grp->offsety);
				drawbox(tx,ty,grp->sizex,grp->sizey,0);
				++cx;
				tx+=grp->sizex;
				++start;
			}
			ty+=grp->sizey;
			++cy;
		}
		code=handleinput(DISPLAY_CELS);
		if(code==0x1b) return -1;
		if(code=='c') changebgcolor();
		if(code==CODE_LEFTCLICK)
		{
			if(mousedowny<16) code=MYUP;
			else if(mousedowny>=16+visy*grp->sizey) code=MYDOWN;
			else
			{
				tx=mousedownx/grp->sizex;
				ty=mousedowny/grp->sizey;
				down=(ty+selectdowns[filewant])*numx+tx;
				if(down<grp->length) return down;
			}
		}
		if(code==MYUP && selectdowns[filewant]) --selectdowns[filewant];
		if(code==MYDOWN &&
			selectdowns[filewant]+visy<numy) ++selectdowns[filewant];
	}
}


char commandline[64];

int gatherline()
{
int count;
int ch;
char temp[64];

	count=0;
	*commandline=0;
	selectfont(1);
	for(;;)
	{
		sprintf(temp,"%s*",commandline);
		drawprintf(0,(IYSIZE>>1)-8,"%-40s",temp);
		copyup();
		ch=wci();
		if(ch==0x1b) return 0;
		if(ch=='\n' || ch=='\r') return 1;
		if(ch==8 && count)
		{
			commandline[--count]=0;
			continue;
		}
		if(ch>=' ' && ch<128 && count<39)
		{
			commandline[count++]=toupper(ch);
			commandline[count]=0;
		}
	}
}

void dogoto(char *p)
{
int val;
int n;

	n=sscanf(p,"%d",&val);
	if(n<1) return;
	if(val<1 || val>numframes) return;
	currentframe=val-1;
}
void unlock()
{
	locklow=locklen=0;
}
void deleteframe(int fr)
{
int i;
struct cel *acel,*acel2;

	unlock();
	if(fr==numframes-1) return; // don't delete last frame
	acel=frames[fr].cellist;
	for(i=fr;i<numframes;i++) copyframe(i,i+1); //frames[i]=frames[i+1];
	while(acel)
	{
		acel2=acel;
		acel=acel->next;
		freecel(acel2);
	}
	if(currentframe>fr) --currentframe;
	--numframes;
}
void dodel(char *p)
{
int val1,val2;
int n;
	n=sscanf(p,"%d-%d",&val1,&val2);
	if(n<1) return;
	if(n<2)
		val2=val1;
	if(val1<1 || val1>=numframes) return;
	if(val2<1 || val2>=numframes || val1>val2) return;
	val2-=val1;
	while(val2-->=0)
		deleteframe(val1-1);
}
void dolock(char *p)
{
int val1,val2;
int n;
	n=sscanf(p,"%d-%d",&val1,&val2);
	if(n<1) {unlock();return;}
	if(n<2)
		val2=val1;
	if(val1<1 || val1>=numframes) return;
	if(val2<1 || val2>=numframes || val1>val2) return;
	val2-=val1;
	locklow=val1-1;
	locklen=val2+1;
}
void dupframe(int dest,int src)
{
cel *acel,**celp;

	copyframe(dest,src);
	frames[dest].cellist=0;
	acel=frames[src].cellist;
	celp=&(frames[dest].cellist);
	while(acel)
	{
		*celp=newcel();
		(*celp)->next=0;
		(*celp)->deltax=acel->deltax;
		(*celp)->deltay=acel->deltay;
		(*celp)->filenumber=acel->filenumber;
		(*celp)->spritenumber=acel->spritenumber;
		(*celp)->flags=acel->flags;
		celp=&((*celp)->next);
		acel=acel->next;
	}
}

void revorder(int start,int num)
{
int end;
struct frame temp;
	end=start+num-1;
	while(end>start)
	{
		temp=frames[start];
		frames[start]=frames[end];
		frames[end]=temp;
		++start;
		--end;
	}
}



void domove(char *p)
{
int val1,val2,val3;
int n;
	n=sscanf(p,"%d-%d,%d",&val1,&val2,&val3);
	if(n<3) return;
	if(val1<1 || val1>=numframes) return;
	if(val2<1 || val2>=numframes) return;
	if(val3<1 || val3>=numframes) return;
	if(val2<val1) return;
	if(val3>=val1) return;
	--val1;
	--val2;
	--val3;
	currentframe=val3;
	revorder(val1,val2-val1+1);
	revorder(val3,val1-val3);
	revorder(val3,val2-val3+1);
}


void dodup(char *p)
{
int val1,val2,val3;
int n,n2;
char tempcom[256];

	n2=sscanf(p,"%d,%d",&val1,&val3);
	n=sscanf(p,"%d-%d,%d",&val1,&val2,&val3);
	if(n2>n && n2==2)
	{
		n=3;
		val2=val1;
	}
	if(n<1) return;
	if(n<2)
		val2=val1;
	if(val1<1 || val1>=numframes) return;
	if(val2<1 || val2>=numframes || val1>val2) return;
	if(n==3 && (val3<1 || val3>=numframes)) return;
	val2-=val1;
	if(numframes+val2>MAXFRAMES) return;
	currentframe=numframes-1;
	if(n==3)
		sprintf(tempcom,"%d-%d,%d",currentframe+1,currentframe+1+val2,val3);
	while(val2-->=0)
	{
		dupframe(numframes-1,val1-1);
		++numframes;
		++val1;
	}
	if(n==3) domove(tempcom);
}


struct commandentry
{
char *name;
void (*func)(char *);
};
struct commandentry comlist[]={
"GOTO",dogoto,
"RM",dodel,
"DUP",dodup,
"LOCK",dolock,
"MOVE",domove,
0
};

int matching(char *p1,char *p2)
{
int c;
char ch;

	c=0;
	while((ch=*p1++)==*p2++ && ch)
		++c;
	return c;
}


void executeline()
{
char name[64],*p,*p2,ch;
struct commandentry *ce,*bestmatch;
int bestval;
int bestdup;
int match;


	p=commandline;
	p2=name;
	while(ch=*p)
	{
		if(ch==' ' || ch>='1' && ch<='9') break;
		*p2++=ch;
		++p;
	}
	*p2++=0;
	while(*p==' ') ++p;
	ce=comlist;
	bestval=0;
	bestdup=0;
	while(ce->name)
	{
		match=matching(name,ce->name);
		if(match>bestval)
		{
			bestval=match;
			bestmatch=ce;
			bestdup=0;
		} else if(match==bestval)
			++bestdup;
		++ce;
	}
	if(bestval && !bestdup)
		bestmatch->func(p);

}



void updatemap()
{
	SDL_SetColors(thescreen, themap, 0, 256);
}

void closex()
{
	SDL_Quit();
}
void openx()
{
	unsigned int videoflags;
	int i;

	for(i=0;i<256;++i)
	{
		themap[i].r=i;
		themap[i].g=i;
		themap[i].b=i;

	}
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 )
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
	updatemap();
	SDL_ShowCursor(0);
}




/*
ddfetch(unsigned char *put,int line)
{
	memmove(put,mybm+line*currentbmxsize,currentbmxsize);
}
*/
void lfetch(unsigned char *buff,int line)
{
	memmove(buff,video+line*320,DX);
}
int writepcx(unsigned char *name, int width, int height, void (*fetch)(), unsigned char *colors)
{
	int file;
	unsigned char temp[2048],*p,temp2[2048],*p2;
	int i,j,k;
	int res;

	sprintf(temp,"%s.pcx",name);
	file=open(temp,O_BINARY|O_WRONLY|O_TRUNC|O_CREAT,0644);
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
	i=width+1 & 0xfffe;
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
		i=width+1 & 0xfffe;
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
}
void savepcx(int fr) {
	char temp[256];
	sprintf(temp,"%s%d",rootname,fr+1);
	strcpy(errormsg,temp);
	message=errormsg;
	writepcx(temp,DX,DY,lfetch,(unsigned char *)thecmap);
}

int main(int argc,char **argv) {
	int i,j,k;
	int t;
	char *p;
	int file;
	int err;
	int sel1,sel2,sel1want;
	UL * pul__Mem;
	UL   ul___Mem;
	cel *acel,*acel2;
	int code;
	cel **celp;
	int tryexit=0;
	int now;

	keyput=keytake=0;

	memset(spritepalettes,0,sizeof(spritepalettes));
	mask=0;
	for(i=0;i<64;++i) picks[i]=0xff;
	sel1want=0;
	inpaste=0;
	pasteselected=0;
	if(argc<2)
	{
		printf("ANIM %s %s\n",__DATE__,__TIME__);
		printf("Use: Anim <file.pos>\n");
		exit(1);
	}

	openx();

	freecolor=1;
	numgfx=0;
	pul__Mem = (UL *) malloc(ul___Mem = BLOCKSIZE);

	if (pul__Mem == NULL)
	{
		printf("No memory(2)\n");
		exit(20);
	}
	memset(pul__Mem,0,BLOCKSIZE);

	strcpy(rootname,argv[1]);
	p=rootname;
	while(*p && *p!='.') ++p;
	*p=0;
	message=0;
	tryexit=0;
	buffer1=malloc(BUFFERSIZE);
	buffer2=malloc(BUFFERSIZE);
	buffer2w=malloc(BUFFERSIZE);
	spritez=malloc(DX*DY);
	pixelid=malloc(IDY*IDX);
	video=malloc(videosize);
	backbuffer=malloc(videosize);
	if(!buffer1 || !buffer2 || !video || !pixelid ||
		 !spritez || !backbuffer)
	{
		printf("No memory\n");
		exit(2);
	}
	file=open(argv[1],O_RDONLY);
	if(file<0)
	{
		printf("Cannot open %s for input\n",argv[1]);
		exit(3);
	}
	i=read(file,buffer1,BUFFERSIZE-1);
	close(file);
	buffer1[i]=0;

	clear(bgcolor);
	err=parseinput(buffer1);
	if(err)
	{
		exit(4);
	}

	colors();
	clear(bgcolor);

	currentframe=0;
	sel1=sel2=0;
	paint(currentframe,sel1,sel2,1);
	copyup();
//	sleep(5);	closex();exit(0);

	for(;;)
	{
		SDL_Delay(1);
		scaninput();
		code=processmouse(currentframe);
		if(code) goto docode;
		if(!kr()) goto skip;
		code=wci();
		if(tryexit==1)
		{
			if(code=='y' || code=='Y') break;
			code=-1;
		}
		if(code==3 || code==('q'|MYALTED) || code=='Q')
		{
			if(tryexit) break;
			tryexit=1;
			message="ARE YOU SURE YOU WANT TO EXIT?";
		} else
			tryexit=0;

docode:
		switch(code)
		{
		case CODE_CHANGEFILE:
			i=mousedownpos&255;
			if(i>=numfiles) break;
			if(filewant==i)
			{
				if(currentframe==numframes-1) break;
				i=picknewcel(currentframe);
				if(i>=0)
				{
					acel=addcel(currentframe);
					acel->filenumber=filewant;
					acel->spritenumber=i;
					sel1=celmax(currentframe)-1;
				}
			}
			else
				filewant=i;
			break;
		case MYPAGEUP: // page up
			if(sel1) --sel1;
			else sel1=celmax(currentframe)-1;
			sel1want=sel1;
			break;
		case MYPAGEDOWN: // page down
			++sel1;
			if(sel1==celmax(currentframe)) sel1=0;
			sel1want=sel1;
			break;
		case 'x':
			flipx(currentframe,sel1);
			break;
		case 'X':
			flipX(currentframe);
			break;
		case MYLEFT: // left arrow
			anymove(currentframe,sel1,-1,0);
			break;
		case MYLEFT+MYSHIFTED: // shift left
			anymove(currentframe,sel1,-8,0);
			break;
		case MYRIGHT: // right arrow
			anymove(currentframe,sel1,1,0);
			break;
		case MYRIGHT+MYSHIFTED: // shift right
			anymove(currentframe,sel1,8,0);
			break;
		case MYUP: // up arrow
			anymove(currentframe,sel1,0,-1);
			break;
		case MYUP+MYSHIFTED: // shift up
			anymove(currentframe,sel1,0,-8);
			break;
		case MYDOWN: // down arrow
			anymove(currentframe,sel1,0,1);
			break;
		case MYDOWN+MYSHIFTED: // shift down
			anymove(currentframe,sel1,0,8);
			break;
		case CODE_CHANGECEL:
			if(!mousepixelid) break;
			if(currentframe==numframes-1) break;
			acel=frames[currentframe].cellist;
			j=1;
			while(acel)
			{
				if(mousepixelid==j)
					break;
				acel=acel->next;
				++j;
			}
			if(!acel) break; //shouldn't happen
			filewant=acel->filenumber;
			i=picknewcel(currentframe);
			if(i>=0)
				acel->spritenumber=i;
			break;
		case CODE_MOVECEL:
//			selected=0;
			sel1=mousepixelid;
anymove(currentframe,sel1,mousedx,mousedy);
break;
/*
			if((1<<sel1)&selected)
				anymove(currentframe,mousepixelid,mousedx,mousedy);
			else
			{
				i=selected;
				selected=0;
				anymove(currentframe,mousepixelid,mousedx,mousedy);
				selected=i;
			}
			break;
*/
		case CODE_PREV:
		case '1':
			if(currentframe)
			{
				sel1=sel1want;
				--currentframe;
				i=celmax(currentframe);
				if(sel1>=i) sel1=i-1;
			}
			break;
		case MYHOME:
			currentframe=0;
			break;
		case MYEND:
			currentframe=numframes-1;
			break;
		case CODE_NEXT:
		case '2':
			if(currentframe<numframes-1)
			{
				sel1=sel1want;
				++currentframe;
				i=celmax(currentframe);
				if(sel1>=i) sel1=i-1;
			}
			break;
		case MYF1+MYSHIFTED: // Shift F1, delete frame
			deleteframe(currentframe);
			break;
		case MYF1: // F1, insert frame
			if(numframes==MAXFRAMES) break;
			for(i=numframes;i>currentframe;--i)
				copyframe(i,i-1); //frames[i]=frames[i-1];
			frames[currentframe].cellist=0;
			unlock();
			++numframes;
			break;
		case CODE_DUPFRAME:
		case MYF3: // F3, dup frame
			if(numframes==MAXFRAMES || currentframe==numframes-1) break;
			for(i=numframes;i>currentframe+1;--i)
				copyframe(i,i-1); //frames[i]=frames[i-1];
			dupframe(currentframe+1,currentframe);

/*
			frames[currentframe].cellist=0;
			acel=frames[currentframe+1].cellist;
			celp=&(frames[currentframe].cellist);
			while(acel)
			{
				*celp=newcel();
				(*celp)->next=0;
				(*celp)->deltax=acel->deltax;
				(*celp)->deltay=acel->deltay;
				(*celp)->filenumber=acel->filenumber;
				(*celp)->spritenumber=acel->spritenumber;
				celp=&((*celp)->next);
				acel=acel->next;
			}
*/
			++currentframe;
			++numframes;
			unlock();
			break;
		case MYDELETE:
		case MYF2+MYSHIFTED: // Shift F2, delete cel
			celp=&(frames[currentframe].cellist);
			i=sel1-1;
			if(i<0) break;
			while(i && *celp)
			{
				celp=&((*celp)->next);
				--i;
			}
			if(*celp)
			{
				acel=*celp;
				*celp=acel->next;
				freecel(acel);
				if(sel1==celmax(currentframe)) --sel1;
			}
			break;
		case CODE_NEWCEL:
		case MYF2: // F2, new cel
			if(currentframe==numframes-1) break;
			acel=addcel(currentframe);
			acel->filenumber=filewant;
			sel1=celmax(currentframe)-1;
			break;
		case CODE_CELTOBOTTOM:
		case MYF4: // F4, cel to bottom
			i=sel1-1;
			if(i<0) break;
			celp=&(frames[currentframe].cellist);
			while(i-- && *celp) celp=&((*celp)->next);
			if(*celp)
			{
				acel=*celp;
				*celp=(*celp)->next;
				while(*celp) celp=&((*celp)->next);
				*celp=acel;
				acel->next=0;
			}
			break;
		case MYF5: // F5, obj -1
			acel=getcel(currentframe,sel1-1);
			if(acel)
			{
				if(acel->filenumber)
				{
					--acel->filenumber;
				}
			}
			break;
		case MYF6: // F6, obj +1
			acel=getcel(currentframe,sel1-1);
			if(acel)
			{
				if(acel->filenumber<numfiles-1)
				{
					++acel->filenumber;
				}
			}
			break;
		case MYF7: // F7, fig -1
			acel=getcel(currentframe,sel1-1);
			if(acel)
			{
				if(acel->spritenumber)
				{
					--acel->spritenumber;
				}
			}
			break;
		case MYF8: // F8, fig +1
			acel=getcel(currentframe,sel1-1);
			if(acel)
			{
				if(acel->spritenumber<groups[acel->filenumber].length-1)
				{
					++acel->spritenumber;
				}
			}
			break;
		case 's'|MYALTED: // alt-s, save
			i=save(rootname);
			if(i)
				sprintf(errormsg,"THERE WAS AN ERROR SAVING: %d",i);
			else
				sprintf(errormsg,"FILE SAVED OK");
			message=errormsg;
			break;
		case CODE_PLAY:
		case 13: // play
			j=0;
			i=0;
			now=SDL_GetTicks();
			while(!j)
			{
				scaninput();
				SDL_Delay(1);
				while(kr())
				{
					k=wci();
					if((k=='-' || k=='_') && playspeed>0) --playspeed;
					else if((k=='=' || k=='+') && playspeed<7) ++playspeed;
					else if(k==' ' || k==0x1b || k==13) j=1;
				}
				if(mouseup) j=1;
//				SDL_Delay(playspeed*SPEEDFACTOR);
				k=SDL_GetTicks();
				if(k>now)
				{
					clear(zerocolor);
					paint(i,sel1,sel2,0);
					copyup();
					++i;
					if(i>=numframes-1) i=0;
					now+=speeddelays[playspeed];
				}
			}
			break;
		case 'l': // lock/unlock
			selected=~selected;
			break;
		case 0x1b: // Escape
			if(gatherline())
				executeline(currentframe);
			break;
		case CODE_TOGGLE:
			i=mousedownpos&255;
			if(i==0  || i>celmax(currentframe))
				break;
			--i;
			if(sel1!=i) {sel1=i;break;}
			sel1=i;
// FALL THROUGH
		case ' ': // invert selection bit
			if(sel1)
			{
				acel=getcel(currentframe,sel1-1);
				if(acel)
					selected^=2<<acel->filenumber;
			} else
				selected^=1;
			break;
		case 'c'|MYALTED: // alt-c, copy
			docopy(currentframe);
			break;
		case 'v'|MYALTED: // alt-v, paste
			if(pasteselected&1)
			{
				frames[currentframe].bgdx=pastebgdx;
				frames[currentframe].bgdy=pastebgdy;
			}
			for(i=0;i<inpaste;i++)
			{
				acel=addcel(currentframe);
				paste[i].next=acel->next;
				*acel=paste[i];
/*
				acel->filenumber=paste[i].filenumber;
				acel->spritenumber=paste[i].spritenumber;
				acel->deltax=paste[i].deltax;
				acel->deltay=paste[i].deltay;
				acel->flags=paste[i].flags;
*/
			}
			break;
		case 'x'|MYALTED: // alt-x, cut, not implemented
			break;
		case	'w': // write out pcx file
			savepcx(currentframe);
			break;
		case CODE_HELP:
		case 'h': // help text
			drawhelp();
			copyup();
			wci();
			break;
		case 'c': // change background color
			changebgcolor();
			break;
		default:
			break;
		}
		clear(bgcolor);
		paint(currentframe,sel1,sel2,1);
		selectfont(1);
		if(locklen)
			drawprintf(320-12*8,200-16,"LOCK:%03d %03d",locklow+1,
				locklow+locklen);
		drawprintf((IXSIZE>>1)-24,(IYSIZE>>1)-8,"%3X",code);
skip:
		if(message) drawstring(0,(IYSIZE>>1)-8,message);
		message=0;
		domouse(1);
		copyup();
		domouse(0);
	}
done:
	closex();
	exit(0);
}
