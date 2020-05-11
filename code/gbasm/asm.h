#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <inttypes.h>
#include "link.h"

#ifndef O_BINARY
#define O_BINARY 0
#endif

typedef unsigned char uchar;

#define QUOTECHAR '"'
#define USEHIGH    ; whether to use low level ASM code
#define M68000 0
#define Z80 1
#define X86 2
#define MAXIN 5
#define EXPRMAX 256
#define MACDEPTH 10
#define LF 10
#define ATTRWHITE 1
#define ATTRSYM 2
#define ATTRFSYM 4
#define ATTROP 8
#define ATTRNUM 16
#define ATTRHEX 32
#define CHUNK 0xffff
#define LOCAL '.'
/* leave 1.5K for macro expansion */
#define MACSIZE 0x600
#define MAXDB 65536L
#define SYMMAX 64

#define iswhite(ch) (attr[ch] & ATTRWHITE)
#define isokfirst(ch) (attr[ch] & ATTRFSYM)
#define isoksym(ch) (attr[ch] & ATTRSYM)
#define isokop(ch) (attr[ch] & ATTROP)
#define isoknum(ch) (attr[ch] & ATTRNUM)
#define ishex(ch) (attr[ch] & ATTRHEX)
#define tohex(ch) (ch<'A' ? ch-'0' : (ch&15)+9)

#define ERR 99
#define ABSTYPE 0
#define RELTYPE 1
#define REGTYPE 2
#define XREFTYPE 3
#define MACTYPE 4
#define NOTHING 98

typedef void (handler)(void);
struct anopcode
{
	uchar *opcodename;
	handler *opcodehandler; //void (*opcodehandler)(void);
};

struct reference
{
	struct reference *refnext;
	int32_t refoff;
	short reftype;
};

struct sym
{
	uchar *symtext;
	struct sym *symnext;
	int64_t symvalue;
	uchar symtype;
	uchar symflags;
	struct reference *symref;
};
/* sym flags */
#define APUBLIC 1
#define ADEF 2
#define ABSS 4
#define ASPECIAL 8
#define ANEQUS 16

struct oplist
{
	struct anopcode *listopcodes;
	int numops,powerops;
};

extern struct oplist z80list,scanlist,directlist,x86list,*currentlist;
handler *scan();
extern struct anopcode scantab[];
extern struct anopcode z80codes[];
extern struct anopcode directs[];
extern struct anopcode x86codes[];

extern int32_t exprval; /* expr fills in */

extern uchar exprstack[EXPRMAX];
extern uchar *exprsp;

extern int eaword1; /* effectaddr fills in */
extern int eaword2;
extern int ealen;
extern int eabits;
extern int eaop;
extern int earel;

extern int64_t operval;
extern int32_t soffset;
extern struct sym *nextsym;
extern unsigned nexttext;
extern unsigned maxlines;
extern int numopen;
extern uchar options[];
extern int outfile;
extern FILE *listfile;
extern int32_t pcount,pcmax,z80zero;
extern int32_t pline;
extern int pass;
extern int cline;
extern uchar *macstack;
extern uchar *macpars[10];
extern int maclens[10];
extern uchar attr[128];
extern int symcount;
extern FILE *errorfile;
extern int errorcount;
extern uchar **xdefhead;
extern uchar **xrefhead;
extern uchar **blockhead;
extern int32_t blockcount;
extern struct sym *lastxref;

/*-----------------All chars follow------*/
extern uchar alabel; /* flag, 1 if this line had a label */
extern struct sym linelabel,symbol,symbol2,opsym;
extern uchar ltext[SYMMAX+2];
extern uchar stext[SYMMAX+2];
extern uchar stext2[SYMMAX+2];
extern uchar opcode[80];
extern uchar variant;
extern uchar optl,opto;
extern uchar exprtype;
extern uchar exprflag;
extern uchar opertype;
extern uchar phase;
extern uchar storing;
extern uchar oppri;
extern uchar opop;
extern uchar depth,ydepth;
extern uchar expanding;
extern uchar inmac;
extern uchar cpu;
extern uchar xrdflag;
extern uchar inputname[];
extern uchar origname[];
extern uchar outputname[];
extern uchar umac[3];
extern uchar *TREAD;
extern uchar *TWRITE;
extern struct sym *symbols;

extern struct sym *findsym(),*addspecial(char *name,int value);
extern struct sym *addsym();
extern uchar *inpoint;
extern int equssize,someequs;
extern uchar *equspntr,*equsbase;
#define at() (someequs ? *equspntr : *inpoint)
#define ahead(x) inpoint[x]
#define get() (someequs ? --someequs,*equspntr++ : *inpoint++)
#define back() ((equssize && inpoint==equsbase && someequs<equssize) ? ++someequs,*--equspntr : *--inpoint)
#define moveto(x) inpoint=(x)
#define currentpos() inpoint

uchar *storeline();
extern uchar *textpoint;
void removecr();
extern uchar *findenv();
extern void *tmalloc(int);
extern void tfree(void *);
extern uchar anumsign;
extern struct sym *lastrel,*lastxref,*lastnref;
extern uchar lastxreftype;
extern uchar lowercase[];
extern struct relentry
{
	struct sym *sym;
	uchar type;
} rellist[];
extern int relsp;
extern uchar bsshunk;
extern int skipwhite(void);
extern void dodsb(void);
extern void boutdoctor(int offset,uchar val);
extern void syntaxerr(void);
extern void badmode(void);
extern void badreg(void);
extern void badvalue(void);
extern void outofrange(void);
extern int comma(void);
extern void bout(uchar);
extern void expr(void);
extern void addreloc(int size);
extern void addref(struct sym *asym, int type);
