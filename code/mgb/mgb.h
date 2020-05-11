#include <SDL.h>

extern unsigned char *ramblock,*romblock;
#define RAMSIZE 0x012000L
#define ROMSIZE 0x400000L
#define STRIPSIZE (0x1800*16)

#define IXSIZE 480
#define IYSIZE 640

extern char basefname[];
int cpu(int numcycles);
unsigned char peek(unsigned int);
void cpuinit(void);
void poke(unsigned int,unsigned char);
unsigned char nexti(void);
extern short daat[];
extern unsigned char *vline,*hstat,hmode;
extern int cyclecount,cycledelta,deltasave;
extern char trace,quiet,paused;
extern char displaying;
extern unsigned char ob0map[4],ob1map[4],bgmap[4];
extern unsigned char *stripblock;
extern unsigned char **striplookupblock,**striplookup;
extern char irq;
extern unsigned char *videomem;
extern int stride;

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
#define MYALTL 0x198
#define MYALTR 0x199
#define MYCTRLL 0x19a
#define MYCTRLR 0x19b
#define MYSHIFTL 0x19c
#define MYSHIFTR 0x19d

#define MYDELETE 0x7f
#define MYSHIFTED 0x40
#define MYALTED 0x200

extern char buttond,buttonl,buttonr,buttonu;
extern char buttona,buttonb,buttonselect,buttonstart;
extern char hMachine;

#define CGB 1
#define GMB 0
extern unsigned char *cgbrambank;
int maprgb(int,int,int);
extern unsigned short rgbmap[256],myrgbmap[256];
extern int framecount;
extern unsigned char soundbuff[];
extern int soundput,soundtake;

extern int f1,f2,f3;

extern struct voice
{
	unsigned char mode;
	int freqval;
	unsigned char timer;
	char volume;
	unsigned char *duty;
	unsigned char env,envclock;
} v1,v2,v3,v4;
extern char v3tab[32];
int disz80(unsigned char bank,int addr,char *put);
int maprgb(int r,int g,int b);
void ddprintfxy(unsigned int x,unsigned int y,char *str,...);
extern unsigned char currentbank,oldbank;
extern unsigned short pcold,regpc;
extern unsigned char fast;
extern unsigned char oldvalid;
extern unsigned char interact;
extern unsigned char mapsave[];
void ddprintf(char *s, ...);


/* mgb.c */
extern int exitflag;
void nomem(int code);
void grab(void);
void buildline(int line);
void colors(void);

/* gfx.c */
void scaninput(void);
int takedown(void);
void updatef(void);
void set_color(int color, int red, int green, int blue);
void updategb(void);
void opengfx(void);
void closegfx();
int gticks(void);
int checkpressed(int code);
void wait1(void);
void clear(void);

/* font.c */
int showhistory(int back);
void ddprints(char *s);
void dco(char c);
void drawcharxy(unsigned int x,unsigned int y,unsigned char c);
void initfont(void);

/* cpu.c */
unsigned char peekbank(unsigned char bank,unsigned int addr);
void writebbram(void);
void initcpu(void);
void shregs(void);
int disprint(unsigned char bank,unsigned short addr);
int stepone(void);
int cputos(void);

/* debug.c */
int checkbreak(void);
void handleview(void);
void initdebug(void);
void loadsymbols(char *name);
void interaction(void);

/* sound.c */
int soundopen(void);
void invertaudio(void);
