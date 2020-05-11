#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

#include "mgb.h"
#include "expr.h"
#include "debug.h"

#define HISTSIZE 512
#define LINESIZE 128

int *ihistory,ihistoryin;
int deltasave;

extern struct breakpoint {
	unsigned char flags;
	unsigned char bank;
	unsigned short addr;
	int count;
} breaks[];
extern unsigned char *breakhash;
extern int fheight; // font.c

unsigned char symbolsabsolute=0;

#define BREAK_USED 1
#define MAXBREAKS 16
#define BREAKHASHSIZE 4096
struct symbol *symbolblock,*freesymbols,**symbollist;
#define SYMBOLSPERBLOCK 512
#define SYMBOLTEXTSIZE 8192

int viewsize=16;
int viewwindow=0;

struct symbol *allocsymbol();
char *symboltext;
int symboltextleft;
void addsymbol(char *name,unsigned char bank,unsigned short addr);

int symbolsleft,numsymbols;
int symbollistsize;

struct breakpoint breaks[MAXBREAKS];
unsigned char *breakhash;

char debline[LINESIZE];
char *dp;
char *debhist=0;
int hcount=0;


#define CR 13

void cr(void)
{
	ddprintf("\n");
}

void addspecialsymbols(void)
{
	addsymbol("rP1",0,0xff00);
	addsymbol("rSB",0,0xff01);
	addsymbol("rSC",0,0xff02);
	addsymbol("rDIV",0,0xff04);
	addsymbol("rTIMA",0,0xff05);
	addsymbol("rTMA",0,0xff06);
	addsymbol("rP1",0,0xff00);
	addsymbol("rTAC",0,0xff07);
	addsymbol("rIF",0,0xff0f);
	addsymbol("rNR10",0,0xff10);
	addsymbol("rNR11",0,0xff11);
	addsymbol("rNR12",0,0xff12);
	addsymbol("rNR13",0,0xff13);
	addsymbol("rNR14",0,0xff14);
	addsymbol("rNR21",0,0xff16);
	addsymbol("rNR22",0,0xff17);
	addsymbol("rNR23",0,0xff18);
	addsymbol("rNR24",0,0xff19);
	addsymbol("rNR30",0,0xff1a);
	addsymbol("rNR31",0,0xff1b);
	addsymbol("rNR32",0,0xff1c);
	addsymbol("rNR33",0,0xff1d);
	addsymbol("rNR34",0,0xff1e);
	addsymbol("rNR41",0,0xff20);
	addsymbol("rNR42",0,0xff21);
	addsymbol("rNR43",0,0xff22);
	addsymbol("rNR44",0,0xff23);
	addsymbol("rNR50",0,0xff24);
	addsymbol("rNR51",0,0xff25);
	addsymbol("rNR52",0,0xff26);
	addsymbol("rWAVE",0,0xff30);
	addsymbol("rLCDC",0,0xff40);
	addsymbol("rSTAT",0,0xff41);
	addsymbol("rSCY",0,0xff42);
	addsymbol("rSCX",0,0xff43);
	addsymbol("rLY",0,0xff44);
	addsymbol("rLYC",0,0xff45);
	addsymbol("rDMA",0,0xff46);
	addsymbol("rBGP",0,0xff47);
	addsymbol("rOBP0",0,0xff48);
	addsymbol("rOBP1",0,0xff49);
	addsymbol("rWY",0,0xff4a);
	addsymbol("rWX",0,0xff4b);
	addsymbol("rKEY1",0,0xff4d);
	addsymbol("rVBK",0,0xff4f);
	addsymbol("rHDMA1",0,0xff51);
	addsymbol("rHDMA2",0,0xff52);
	addsymbol("rHDMA3",0,0xff53);
	addsymbol("rHDMA4",0,0xff54);
	addsymbol("rHDMA5",0,0xff55);
	addsymbol("rRP",0,0xff56);
	addsymbol("rBCPS",0,0xff68);
	addsymbol("rBCPD",0,0xff69);
	addsymbol("rOCPS",0,0xff6a);
	addsymbol("rOCPD",0,0xff6b);
	addsymbol("rSVBK",0,0xff70);
	addsymbol("rIE",0,0xffff);
}

int listcomp(const void *p1,const void *p2)
{
char *s1,*s2;

	s1=*(char **)p1;
	s2=*(char **)p2;
	while(tolower(*s1)==tolower(*s2)) ++s1,++s2;
	return tolower(*s1)-tolower(*s2);
}


void listall(char *base)
{
int i,j,k,len;
struct symbol *asym;
char outline[256];
int num;
int size;
int limit=80;
char **templist;
int numlines;
int perline;
int which;

	templist=malloc(numsymbols*sizeof(char *));
	if(!templist)
	{
		ddprintf("No memory for checking %d symbols!!\n",numsymbols);
		return;
	}

	len=strlen(base);
	j=0;
	num=0;
	for(i=0;i<numsymbols;++i)
	{
		asym=symbollist[i];
		if(strncmp(asym->name,base,len)) continue;
		templist[num++]=asym->name;
		k=strlen(asym->name);
		if(k>j) j=k;
	}
	qsort(templist,num,sizeof(char *),&listcomp);
	perline=limit/(j+2);
	if(!perline) perline=1;
	size=limit/perline;
	numlines=(num+perline-1)/perline;
	for(i=j=which=0;i<num;++i)
	{
		if(which<num)
		{
			strcpy(outline+j,templist[which]);
			k=strlen(templist[which]);
			j+=k;
			if(perline>1)
				while(k++<size)
					outline[j++]=' ';
			outline[j]=0;
			which+=numlines;
		}
		if(which>=num)
		{
			ddprintf("%s\n",outline);
			j=0;
			which%=numlines;
			++which;
		}
	}
	if(j) ddprintf("%s\n",outline);
	free(templist);
}


void typeline(char *prompt,int echocr)
{
int i=0,j;
int code;
int backcount=0;
char linesave[LINESIZE],ch;
int linesin;
char ref;
int xdelta;
int plen;
char *p1,*p2;
char token[128];
char *fake;
int scrollback;

	plen=strlen(prompt);
	xdelta=0;
	linesin=hcount>HISTSIZE ? HISTSIZE : hcount;
	*debline=0;
	ddprintf(prompt);
	ref=0;
	i=0;
	fake=0;
	scrollback=0;
	while(!exitflag)
	{
		if(!fake)
		{
			SDL_Delay(10);
			scaninput();
			code=takedown();
		} else
		{
			code=*fake++;
			if(!code) {fake=0;continue;}
		}
		if(code==-1) continue;
		if(code==MYPAGEUP || code==(MYPAGEUP|MYSHIFTED))
		{
			if(code==MYPAGEUP) ++scrollback;
			else scrollback+=fheight;
			scrollback=showhistory(scrollback);
			continue;
		} else if(code==MYPAGEDOWN || code==(MYPAGEDOWN|MYSHIFTED))
		{
			if(code==MYPAGEDOWN) --scrollback;
			else scrollback-=fheight;
			if(scrollback<0) scrollback=0;
			scrollback=showhistory(scrollback);
			continue;
		}
		if(code==9 || code==4)
		{
			j=0;
			while(i+xdelta-j>0)
			{
				ch=debline[i+xdelta-j-1];
				if(!isalpha(ch) && !isdigit(ch) && ch!='_' && ch!='.') break;
				++j;
			}
			p1=token;
			while(j)
				*p1++=debline[i+xdelta-j--];
			*p1=0;
			if(*token)
			{
				if(code==9)
					fake=complete(token);
				else
				{
					cr();
					listall(token);
					ref=1;
				}
			}
		} else if(code==0x7f)
		{
			if(!xdelta) continue;
			p1=debline+i+xdelta;
			p2=p1+1;
			while((*p1++=*p2++));
			--i;
			++xdelta;
			++ref;
		} else if(code==MYLEFT)
		{
			if(i+xdelta>0) {--xdelta;++ref;}
		} else if(code==MYRIGHT)
		{
			if(xdelta<0) {++xdelta;++ref;}
		} else if(code==MYUP)
		{
			if(backcount>=linesin) continue;
			if(!backcount)
				memcpy(linesave,debline,LINESIZE);
			++backcount;
			memcpy(debline,debhist+LINESIZE*((hcount-backcount)&(HISTSIZE-1)),LINESIZE);
			xdelta=0;
			++ref;
		} else if(code==MYDOWN)
		{
			if(!backcount) continue;
			--backcount;
			if(!backcount) memcpy(debline,linesave,LINESIZE);
			else
				memcpy(debline,
					debhist+LINESIZE*((hcount-backcount)&(HISTSIZE-1)),
					LINESIZE);
			xdelta=0;
			++ref;
		} else if(code>=0 && code<128)
		{
			if(code==8)
			{
				if(i+xdelta)
				{
					--i;
					p1=debline+i+xdelta;
					p2=p1+1;
					while((*p1++=*p2++));
					++ref;
				} else continue;
			} else if(code==CR)
			{
				if(echocr) cr();
				break;
			}
			else if(code>=0x20 && i<sizeof(debline)-1)
			{
				p2=debline+i;
				p1=p2+1;
				j=1-xdelta;
				while(j--) *p1--=*p2--;
				*p1=code;
				++ref;
			} else continue;
		}
		if(ref)
		{
			if(scrollback)
				scrollback=showhistory(0);
			i=strlen(debline);
			ddprintf("\r%s%s\033k\033%dx",prompt,debline,plen+i+xdelta);
			ref=0;
		}

	}
	if(i)
	{
		memcpy(debhist+LINESIZE*(hcount&(HISTSIZE-1)),debline,LINESIZE);
		++hcount;
	}
}
int exprprint(void)
{
char *err;
	err=expr(&dp);
	if(err) {ddprintf("%s\n",err);return 1;}
	return 0;
}

void doview(unsigned char bank,unsigned short addr,int size)
{
char line[128],*p,c;
int i;

	if(size<1) return;
	if(size>16) size=16;
	sprintf(line,"%-23s",getname(bank,addr));
	p=line+23;
	for(i=0;i<size;++i)
	{
		if(!(i&1)) *p++=' ';
		sprintf(p,"%02x",peekbank(bank,addr+i));
		p+=strlen(p);
	}
	while(i<16)
	{
		if(!(i&1)) *p++=' ';
		++i;
		strcpy(p,"   ");
		p+=strlen(p);
	}
	*p++=' ';
	for(i=0;i<size;++i)
	{
		c=peekbank(bank,addr+i);
		*p++= ((c&0x7f)<0x20) ? '.' : c;
	}
	*p++='\n';
	*p=0;
	ddprints(line);
}

void freesymbol(struct symbol *sym)
{
	sym->next=freesymbols;
	freesymbols=sym;
}

void deletesym(char *name)
{
struct symbol *asym=0;
int i;
	for(i=0;i<numsymbols;++i)
	{
		asym=symbollist[i];
		if(!strcmp(asym->name,name)) break;
	}
	if(!asym) return;
	freesymbol(asym);
	--numsymbols;
	while(i<numsymbols)
	{
		symbollist[i]=symbollist[i+1];
		++i;
	}
}

int symcomp(const void *p1,const void *p2)
{
int diff;
struct symbol *s1,*s2;
int v1,v2;

	s1=*(struct symbol **)p1;
	s2=*(struct symbol **)p2;
	v1=s1->bank;
	v2=s2->bank;
	diff=v1-v2;
	if(diff) return diff;
	v1=s1->addr;
	v2=s2->addr;
	return v1-v2;
}

void sortsymbols(void)
{
	if(numsymbols<2) return;
	qsort(symbollist,numsymbols,sizeof(struct symbol *),&symcomp);
/*
	{
		int i;
		struct symbol *asym;
		for(i=0;i<numsymbols;++i)
		{
			asym=symbollist[i];
			printf("%02x:%04x %s\n",asym->bank,asym->addr,asym->name);
		}			
	}
*/
}

void listbreaks(void)
{
int i,j;
	for(i=0,j=0;i<MAXBREAKS;++i)
	{
		if(breaks[i].flags & BREAK_USED)
		{
			++j;
			ddprintf("<%d>%02x:%s\n",breaks[i].count,
				breaks[i].bank,getname(breaks[i].bank,breaks[i].addr));
		}
	}
	if(!j)
		ddprintf("All breakpoints cleared\n");
}

int setbreak(unsigned char bank,unsigned short addr,int count)
{
int i;
	for(i=0;i<MAXBREAKS;++i)
	{
		if(breaks[i].flags & BREAK_USED) continue;
		else break;
	}
	if(i==MAXBREAKS) return -1;
	breaks[i].flags|=BREAK_USED;
	breaks[i].addr=addr;
	breaks[i].bank=bank;
	breaks[i].count=count;
	++breakhash[addr&(BREAKHASHSIZE-1)];
	return i;
}

void clearbreak(unsigned char bank,unsigned short addr)
{
int i;

	for(i=0;i<MAXBREAKS;++i)
	{
		if(!(breaks[i].flags & BREAK_USED)) continue;
		if(breaks[i].addr==addr && breaks[i].bank==bank)
		{
			--breakhash[addr&(BREAKHASHSIZE-1)];
			breaks[i].flags &= ~BREAK_USED;
		}
	}
}

void clearbreaks(void)
{
	memset(breaks,0,MAXBREAKS*sizeof(struct breakpoint));
	memset(breakhash,0,BREAKHASHSIZE);
}

int clearbreakn(int n)
{
	if(breaks[n].flags & BREAK_USED)
	{
		if(!--breaks[n].count)
		{
			breaks[n].flags &= ~BREAK_USED;
			--breakhash[breaks[n].addr & (BREAKHASHSIZE-1)];
			return 1;
		}
	}
	return 0;
}

void handleview(void)
{
int i,j;
	i=0;
	while(i<viewsize)
	{
		j=viewsize-i;
		if(j>16) j=16;
		doview(viewwindow>>16,(viewwindow&0xffff)+i,j);
		i+=j;
	}
}



void skipwhite(void)
{
	while(*dp==' ') ++dp;
}
void gettoken(char *put)
{
char ch;

	while((ch=*dp))
	{
		if(isalpha(ch) || isdigit(ch) || ch=='_' || ch=='.')
			{*put++=ch;++dp;}
		else break;
	}
	*put=0;
}
void handledirectives(char ch)
{
	switch(ch)
	{
	case 'g':
		grab();
		break;
	case 's':
		quiet=!quiet;
		ddprintf("Sound is %s.\n",quiet ? "off" : "on");
		break;
	case 'm':
		hMachine=(hMachine==GMB) ? CGB : GMB;
		writebbram();
		initcpu();
		ddprintf("Machine is %s.\n",(hMachine==GMB) ? "GMB" : "CGB");
		break;
	default:
		ddprintf("Unknown directive, look at the help text\n");
		break;
	}
}


int processline()
{
unsigned char bank,ch;
unsigned short at;
int i,j;
char atoken[128];
struct symbol *asym;

	dp=debline;
	ch=*dp++;
	if(ch)
		while(*dp && (*dp==' ' || *dp=='\t')) ++dp;
	else --dp;

	switch(ch)
	{
	case '@':
		handledirectives(*dp);
		break;
	case 0:
		shregs();
		break;
	case 'g':
		if(!*dp) return 1;
		if(exprprint()) break;
		regpc=exprval&0xffff;
		return 1;
	case 'd':
		bank=oldbank;
		if(*dp)
		{
			if(!exprprint())
			{
				if(exprval&0xff0000) bank=(exprval&0xff0000)>>16;
				else if(exprval>=0x4000 && exprval<0x8000) bank=currentbank;
				at=exprval&0xffff;
			}
			else break;
		} else
			at=regpc;
		while(!exitflag)
		{
			at+=disprint(bank,at);
			typeline("",0);
			if(*debline) cr();
			if(!strcmp(debline,"q")) break;
			dp=debline;
			if(*dp)
			{
				if(!exprprint())
				{
					if(exprval&0xff0000) bank=(exprval&0xff0000)>>16;
					else if(exprval>=0x4000 && exprval<0x8000)
						bank=currentbank;
					at=exprval&0xffff;
				}
				else break;
			}
		}
		break;
	case '=':
		if(!exprprint())
			ddprintf("$%x   %d\n",exprval,exprval);
		break;
	case '?':
		ddprintf("@g                grab screenshot\n");
		ddprintf("@s                toggle sound on/off\n");
		ddprintf("@m                toggle machine type\n");
		ddprintf("!                 reset\n");
		ddprintf("?                 help\n");
		ddprintf("= <expr>          evaluate expression\n");
		ddprintf("[                 move memory window back\n");
		ddprintf("]                 move memory window ahead\n");
		ddprintf("{space}           single step\n");
		ddprintf("d [<addr>]        disassemble\n");
		ddprintf("f                 flip symbols/absolute\n");
		ddprintf("g [<addr>]        go\n");
		ddprintf("h [<expr>]        instruction history\n");
		ddprintf("i [<addr>]        Clear all or individual breakpoints\n");
		ddprintf("k [<expr>]        break hear after # times\n");
		ddprintf("n <addr> <symbol> define symbol\n");
		ddprintf("p [<addr>] ...    set/view breakpoints\n");
		ddprintf("r                 break at addr on TOS\n");
		ddprintf("s                 break at next instruction\n");
		ddprintf("u <symbol>        Undefine symbol\n");
		ddprintf("v [<addr>]        View memory\n");
		break;
	case ' ':
		if(!*dp)
			i=1;
		else
		{
			if(exprprint()) break;
			i=exprval;
		}
		deltasave=cycledelta;
		while(i--)
			stepone();
		shregs();
		break;
	case 'i':
		if(!*dp)
			clearbreaks();
		else
		{
			if(exprprint()) break;
			clearbreak(exprval>>16,exprval&0xffff);
		}
		listbreaks();
		break;
	case 'p':
		if(*dp)
		{
			if(exprprint()) break;
			setbreak(exprval>>16,exprval&0xffff,1);
		}   
		listbreaks();
		break;
	case 'r':
		setbreak(currentbank,cputos(),1);
		return 1;
	case 's':
		at=pcold;
		ddprintf("Putting breakpoint after\n");
		at+=disprint(oldbank,at);
		setbreak(oldbank,at,1);
		return 1;
	case 'k':
		if(!oldvalid) stepone();
		if(!*dp)
		{
			setbreak(oldbank,pcold,1);
			return 1;
		}
		if(exprprint()) break;
		setbreak(oldbank,pcold,exprval);
		return 1;
	case ']':
		viewwindow=(viewwindow&0xff0000) | ((viewwindow+viewsize)&0xffff);
		handleview();
		break;
	case '[':
		viewwindow=(viewwindow&0xff0000) | ((viewwindow-viewsize)&0xffff);
		handleview();
		break;
	case 'v':
		if(*dp)
		{
			if(exprprint()) break;
			if(exprval>=0x4000 && exprval<0x8000)
				exprval|=currentbank<<14;
			viewwindow=exprval;
			if(*dp==',')
			{
				++dp;
				if(exprprint()) break;
				viewsize=exprval;
			}
		}
		handleview();
		break;
	case 'f':
		symbolsabsolute=!symbolsabsolute;
		break;
	case '!':
		writebbram();
		initcpu();
		shregs();
		break;
	case 'n':
		if(exprprint()) break;
		skipwhite();
		gettoken(atoken);
		asym=findsym(atoken);
		if(asym)
		{
			asym->bank=exprval>>16;
			asym->addr=exprval&0xffff;
		} else
		{
			addsymbol(atoken,exprval>>16,exprval&0xffff);
			sortsymbols();
		}
		break;
	case 'u':
		gettoken(atoken);
		asym=findsym(atoken);
		if(!asym) ddprintf("Unknown symbol %s\n",atoken);
		else deletesym(atoken);
		break;
	case 'h':
		i=20;
		if(*dp)
		{
			if(exprprint()) break;
			else i=exprval;
		}
		if(i<0) break;
		if(i>ihistoryin) i=ihistoryin;
		if(i>IHISTORYSIZE) i=IHISTORYSIZE;
		i=ihistoryin-i;
		while(i<ihistoryin)
		{
			ddprintf("%10d ",i);
			j=ihistory[i++ & (IHISTORYSIZE-1)];
			disprint(j>>16,j&0xffff);
		}
		break;
	}
	return 0;
}

void interaction(void)
{
	shregs();
	do
	{
		typeline(":",1);
	} while(!exitflag && !processline());
	deltasave=cycledelta;
}

void loadsymbols(char *name)
{
char *p,*p2;
char mapname[256];
char mapline[256];
FILE *infile;
int bank=-1;
int value;
char symbol[256];

	addspecialsymbols();
	sortsymbols();
	strcpy(mapname,name);
	p=mapname+strlen(mapname);
	while(p>mapname && *--p!='.');
	if(*p=='.') *p=0;
	strcat(mapname,".map");
	infile=fopen(mapname,"r");
	if(!infile) return;
	for(;;)
	{
		p=fgets(mapline,sizeof(mapline),infile);
		if(!p) break;
		if(!strncmp(mapline,"Bank #",6))
		{
			bank=atoi(mapline+6);
			continue;
		}
		if(!strncmp(mapline,"BSS:",4))
		{
			bank=0;
			continue;
		}
		if(bank==-1) continue;
		while(*p==' ') ++p;
		if(*p!='$') continue;
		++p;
		if(sscanf(p,"%x",&value)!=1) continue;
		while(*p && *p!='=') ++p;
		if(*p!='=') continue;
		++p;
		if(*p!=' ') continue;
		++p;
		p2=symbol;
		while(*p && *p!='\n' && *p!='\r') *p2++=*p++;
		*p2=0;
		addsymbol(symbol,bank,value);
	}
	fclose(infile);
	sortsymbols();
}

void initdebug(void)
{
	ihistoryin=0;
	ihistory=malloc(IHISTORYSIZE*sizeof(int));
	if(!ihistory) nomem(28);
	breakhash=malloc(BREAKHASHSIZE);
	if(!breakhash) nomem(22);
	clearbreaks();
	debhist=malloc(LINESIZE*HISTSIZE);
	if(!debhist) nomem(20);
	symbolsleft=0;
	freesymbols=0;
	numsymbols=0;
	symboltextleft=0;
	symbollistsize=0;
	symbollist=0;
}
int checkbreak(void)
{
int i;

	if(breakhash[regpc & (BREAKHASHSIZE-1)])
	{
		for(i=0;i<MAXBREAKS;++i)
		{
			if(!(breaks[i].flags&BREAK_USED)) continue;
			if(regpc!=breaks[i].addr) continue;
			if(regpc>=0x4000 && regpc<0x8000 && breaks[i].bank!=currentbank)
				continue;
			return clearbreakn(i);
		}
	}
	return 0;
}
struct symbol *allocsymbol()
{
struct symbol *t;

	if(freesymbols)
	{
		t=freesymbols;
		freesymbols=freesymbols->next;
	} else
	{
		if(!symbolsleft)
		{
			symbolblock=malloc(SYMBOLSPERBLOCK*sizeof(struct symbol));
			if(!symbolblock) nomem(24);
			symbolsleft=SYMBOLSPERBLOCK;
		}
		t=symbolblock+ --symbolsleft;
	}
	memset(t,0,sizeof(struct symbol));
	return t;
}
void addsymbol(char *name,unsigned char bank,unsigned short addr)
{
struct symbol *sym;
	sym=allocsymbol();
	if(strlen(name)+1>symboltextleft)
	{
		symboltext=malloc(SYMBOLTEXTSIZE);
		if(!symboltext) nomem(25);
		symboltextleft=SYMBOLTEXTSIZE;
	}
	symboltextleft-=strlen(name)+1;
	strcpy(symboltext+symboltextleft,name);
	sym->name=symboltext+symboltextleft;
	sym->bank=bank;
	sym->addr=addr;
	if(numsymbols+1>symbollistsize)
	{
		symbollistsize+=500;
		symbollist=realloc(symbollist,symbollistsize*sizeof(struct symbol *));
		if(!symbollist) nomem(26);
	}
	symbollist[numsymbols++]=sym;
}
char *getname(unsigned char bank,unsigned short addr)
{
static char name[128];
int i;
struct symbol *asym,*lastgood;

	if(addr<0x4000 || addr>=0x8000) bank=0;
	lastgood=0;
	for(i=0;i<numsymbols;++i)
	{
		asym=symbollist[i];
		if(asym->bank==bank && asym->addr<=addr) lastgood=asym;
	}
	if(lastgood && !symbolsabsolute)
	{
		i=addr-lastgood->addr;
		if(!i)
			sprintf(name,"%s=%04x",lastgood->name,addr);
		else
			sprintf(name,"%s+$%x=%04x",lastgood->name,i,addr);
	} else
		sprintf(name,"%04x",addr);
	return name;
}
struct symbol *findsym(char *name)
{
struct symbol *asym;
int i;
	for(i=0;i<numsymbols;++i)
	{
		asym=symbollist[i];
		if(!strcmp(asym->name,name)) return asym;
	}
	return 0;
}

char *complete(char *base)
{
int i,j,k;
struct symbol *asym;
static char longest[128];

	j=strlen(base);
	k=-1;
	longest[0]=0;
	for(i=0;i<numsymbols && k;++i)
	{
		asym=symbollist[i];
		if(strncmp(asym->name,base,j)) continue;
		if(k<0)
		{
			strcpy(longest,asym->name+j);
			k=strlen(longest);
			continue;
		}
		while(k && strncmp(longest,asym->name+j,k)) --k;
		longest[k]=0;
	}
	return longest;
}
