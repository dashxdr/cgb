extern int vxsize,vysize;

typedef struct surface
{
	unsigned char format;
	int rgb[256];
	unsigned char colormap[768];
	unsigned char *pic;
	int xsize;
	int ysize;
} surface;

#define FORMAT8 1
#define FORMAT16 2
#define FORMAT32 4

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

/* mouse events followed by int x,int y */
#define MYMOUSE 0x400
#define MYMOUSE1DOWN (MYMOUSE)
#define MYMOUSE2DOWN (MYMOUSE|1)
#define MYMOUSE3DOWN (MYMOUSE|2)
#define MYMOUSE1UP (MYMOUSE|3)
#define MYMOUSE2UP (MYMOUSE|4)
#define MYMOUSE3UP (MYMOUSE|5)
#define MYMOUSEMOVE (MYMOUSE|6)

#define ENDMARK 0xffffff

#define MYDELETE 0x7f
#define MYSHIFTED 0x40
#define MYALTED 0x200
#define MYMOUSE 0x400

extern unsigned char *videomem;
extern int stride;

void updatemap(void);
void mapkey(int code,int qual,int *mapped);
void markkey(int code,int mod,int status);
int ignorable(int code);
int nextcode(void);
int peekcode(void);
int checkdown(int code);
void scaninput(void);
void opendisplay(int sx,int sy);
void closedisplay(void);
void clear(void);
void copyup(void);
void scrunlock(void);
void scrlock(void);
void delay(int);
int gticks(void);
int readpcx(char *name,surface *gs);
void gstoback(int destx,int desty,surface *gs,int sourcex,int sourcey,int sizex,int sizey);
void rgbdot(unsigned int x,unsigned int y,unsigned char r,unsigned char g,unsigned char b);
void eraserect(int x,int y,int sizex,int sizey);
void solidrect(int x,int y,int sizex,int sizey,unsigned char r,unsigned char g,unsigned char b);
void copytoback(unsigned int n);
void copyfromback(unsigned int n);
void darkenrect(int x,int y,int sizex,int sizey);
void lightenrect(int x,int y,int sizex,int sizey);
void transformrect(int x,int y,int sizex,int sizey,unsigned short *trans);
void freegs(surface *gs);
int maprgb(int r,int g,int b);
int writeppm(char *name);
int allocgs(struct surface *gs,int width,int height,int depth);
void setcolor(struct surface *gs,int n,int r,int g,int b);
void copyupany(int mx,int my,int sx,int sy);
