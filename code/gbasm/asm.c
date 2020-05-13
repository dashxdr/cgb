#include "asm.h"
#include <sys/timeb.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#define BLOCKSIZE 0x40000
#define IOBLOCKSIZE 30000
#define MACROMAX 16384
#define MAXSYMS 16384
#define LISTBOTH 0
#define FORCEOBJ 1

#define ASMEXTENSION ".asm"
#define OBJEXTENSION ".obj"
#define QUOTECHAR '"'
#define QUOTECHAR2 '\''

void outw(short),wout(short),outl(int32_t),lout(int32_t);

void addpublic(struct sym *);

struct relentry rellist[50];
int relsp;

uchar *equspntr,*equsbase;
int someequs,equssize;
uchar *outblock=0;
uchar *outoff;
uchar *textblock=0;
uchar *listbuff=0;
uchar *textpoint;
uchar *macroblock=0;
uchar **filelist=0;
uchar *publichead;
uchar anumsign;
//struct sym *lastrel;
//struct sym *lastxref;
//struct sym *lastnref;
//uchar lastxreftype;
uchar somebss;


uchar lowercase[256];

int currentsection;

struct reference *reloc16head=0,*reloc32head=0;
int reloc32num=0,reloc16num=0;


uchar *listpoint,*listend;

struct sym *heresym;

#define MAXREPTS 10
struct rept
{
	char *loc;
	int count;
	int cline;
} repts[MAXREPTS];
int reptsp;


struct oplist z80list,scanlist,directlist,*currentlist;

void domacro(void);
void doendm(void);
void doinclude(void);
void setyes(void);
void setno(void);
void doeset();
void doequ(void);
void doequs(void);
void dorb(void),dorw(void);

void fixlocal(struct sym *asym);
void clearmem(void *where,int len);
void outrelocs(void);
void outpublics(void);
void symout(uchar *s, int d);
void symsout(int mask);
void tailout(void);
void headout(void);
void varsize(int size);
void zeros(int32_t size);
void addtext(uchar *str);
void endstore(void);
void listline(uchar *toff1, uchar *ooff1,int pcsave);
void flushlist(void);
void handlelabel(handler *func);
int gather(void);
int token(struct sym *asym);
void aline(void);
void assemble(uchar *str);
void dofile(void);
int dopass(void);
void flush(void);
void closeall(void);
int isConditional(handler *f);

struct sym **headers=0;
int32_t exprval;

uchar *inpoint;

uchar exprstack[EXPRMAX];
uchar *exprsp;
void failerr(void);


struct sym *lastref;
int64_t operval;
struct relentry *operrel;
int32_t soffset;
struct sym *nextsym;
unsigned maxlines;
int numopen;
uchar options[256];
int outfile=-1;
FILE *listfile=0;
int32_t pcount,pcmax;
unsigned char bsshunk;
int pass,passlist;
int cline;
uchar *macstack;
uchar *macpars[10];
int maclens[10];
uchar attr[128];
int symcount;
FILE *errorfile=0;
int errorcount,warncount;
uchar **blockhead;
int32_t blockcount;
struct sym *symbols;

/*-----------------All uchars follow------*/
uchar alabel; /* flag, 1 if this line had a label */
struct sym linelabel,symbol,symbol2,opsym;
uchar ltext[SYMMAX+2];
uchar stext[SYMMAX+2];
uchar stext2[SYMMAX+2];
uchar lastreal[SYMMAX+2];
uchar opcode[80];
uchar opcodeorig[80];
uchar variant;
uchar exprtype;
uchar exprflag;
uchar opertype;
uchar phase;
uchar storing;
uchar oppri;
uchar opop;
uchar depth,ydepth;
uchar expanding;
uchar inmac;
uchar filename[256];
uchar inputname[256];
uchar outputname[256];
uchar umac[3];
uchar *TREAD="r";
uchar *TWRITE="w";

/* abs=0, rel=1, reg=2, xref=3, mac=4 */
uchar cnone[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
uchar cplus[5][5]={
	ABSTYPE,RELTYPE,ERR,XREFTYPE,ERR,
	RELTYPE,RELTYPE,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	XREFTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
uchar cminus[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	RELTYPE,ABSTYPE,ERR,ERR,ERR,
	ERR,ERR,REGTYPE,ERR,ERR,
	XREFTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
uchar cdivide[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,REGTYPE,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};


int gtime(void) {
	struct timeb tb;

	ftime(&tb);
	return tb.time*1000 + tb.millitm;
}


void makename(char *to, char *from, char *ch) {
	strcpy(to,from);
	strcat(to,ch);
}

int hash8(uchar *str)
{
int hash=0;
uchar ch;

	while(ch=*str++)
	{
		hash+=hash;
		if(hash&256) hash-=255;
		hash^=ch;
	}
	return hash;
}


struct sym *addsym(asym)
struct sym *asym;
{
	struct sym *pntr;
	int h;

	h=hash8(asym->symtext);
	nextsym->symnext=headers[h];
	headers[h]=nextsym;
	nextsym->symvalue=asym->symvalue;
	nextsym->symtype=asym->symtype;
	nextsym->symflags=asym->symflags;
	nextsym->symref=0;
	nextsym->symtext=textpoint;
	nextsym++; /* bounds check */
	addtext(asym->symtext);
	return nextsym-1;
}



void fixattr(int orval, uchar *str) {
	uchar ch;

	while(ch=*str++)
		attr[ch]|=orval;
}
void error(emsg)
uchar *emsg;
{
	if(errorfile) fprintf(errorfile,"%d:%s\n",cline,emsg);
	else printf("%s(%d) %s\n",filename,cline,emsg);
}
void error2(emsg)
uchar *emsg;
{
	if(pass) {errorcount++;error(emsg);}
}
void error1(emsg)
uchar *emsg;
{
	if(!pass) {errorcount++;error(emsg);}
}
void warn2(emsg)
uchar *emsg;
{
	if(pass) {warncount++;error(emsg);}
}
void phaserr(void) {error2("Phase error");}
void failerr(void) {error2("FAIL directive");}
void unbalancedq(void) {error2("Unbalanced '");}
void unbalanced(void) {error2("Unbalanced ()");}
void cantopen(void) {error2("Can't open file");}
void badreg(void) {error2("Illegal register");}
void baduchar(void) {error2("Illegal ucharacter");}
void illegalop(void) {error2("Illegal op code");}
void reptdepth(void) {error2("REPT overflow");}
void syntaxerr(void) {error2("Syntax error");}
void absreq(void) {error2("Absolute data required");}
void badvalue(void) {error2("Illegal value");}
void badmode(void) {error2("Illegal effective address");}
void outofrange(void) {error2("Operand out of range");}
void div0(void) {error2("Divide by zero");}
void unknownerr(str)
uchar *str;
{
uchar temp[80];
	strcpy(temp,"Undefined symbol ");
	strcat(temp,str);
	error2(temp);
}
void duplicate(void) {error1("Duplicate label");}
void badoperation(void) {error2("Illegal operation");}
void badsize(void) {error2("Illegal opcode size");}

void nomem(int num) {
	printf("Not enough memory %d\n",num);
	closeall();
	exit(num);
}
void freeind(void **addr) {
	if(*addr)
	{
		tfree(*addr);
		*addr=0;
	}
}
void ccexit(void) {
	closeall();
	printf("*** Break\n");
	exit(1);
}
void freestuff(void) {
	uchar **p;

	freeind((void**)&headers);
	freeind((void**)&listbuff);
	freeind((void**)&outblock);
	freeind((void**)&textblock);
	freeind((void**)&macroblock);
	freeind((void**)&symbols);

	while(filelist)
	{
		p=filelist;
		filelist=(void *)*filelist;
		tfree(p);
	}
}
void *tmalloc(int len)
{
void *p;
	p=malloc(len);
	return p;
}
void tfree(void *pntr)
{
	free(pntr);
}



void countops(struct oplist *list, struct anopcode *tab) {
	int i,j;
	i=0;
	list->listopcodes=tab;
	while((tab++) ->opcodename) i++;
	j=1;
	while(j<=i) j+=j;
	j>>=1;
	list->numops=i;
	list->powerops=j;
}
void setz80(void) {
	currentlist=&z80list;
}

uchar *nametail(uchar *str)
{
uchar *p;

        p=str+strlen(str);
        while(p>str && p[-1]!='/' && p[-1]!=':') p--;
        return p;
}

void setup(int argc,uchar **argv) {
	int i,j,k,mode,sfile;
	uchar ch;

	outputname[0]=0;
	filename[0]=0;
	inputname[0]=0;
	for(i=0;i<256;i++) options[i]=0;
	for(i=1,mode=0;i<argc;i++)
	{
reswitch:
		switch(mode)
		{
		case 0:
			if(argv[i][0]!='-')
			{
				strcpy(inputname,argv[i]);
				break;
			}
			mode=argv[i][1];
			if(argv[i][2]) {j=2;goto reswitch;}
			else {j=0;continue;}
		case 'o':
			strcpy(outputname,argv[i]+j);
			mode=0;
			break;
		case '-':
			while(ch=argv[i][j++]) options[ch]=1;
			break;
		default:
			mode=0;
			break;
		}
		mode=0;
	}
}
void makefilename(void) {
	int i;
	i=strlen(inputname);
	if(i>strlen(ASMEXTENSION) && 
			(!strcmp(inputname+i-strlen(ASMEXTENSION),ASMEXTENSION)))
		strcpy(filename,inputname);
	else sprintf(filename,"%s%s",inputname,ASMEXTENSION);
}


int main(int argc,char **argv) {
	uchar temp[80];
	uchar *pntr,ch,*outoffsave;
	int i,j;
	int time1,time2,lpm;
	int pcmaxt;
	struct sym *asym;
	int sfile;

	time1=gtime();
	for(i=0;i<256;++i)
		lowercase[i]=tolower(i);
	errorcount=0;warncount=0;
	errorfile=0;
	listfile=0;
	blockhead=0;
	blockcount=0;
	outfile=-1;
	publichead=0;
	filelist=0;

	if(argc<2)
	{
		printf("%s 1999 by David Ashley\n",nametail(*argv));
		printf("%s <inputfile> [-o <outputfile>] [-- <options>]\n",nametail(*argv));
		printf("Options:\n");
		printf("b    Produce binary file\n");
		printf("e    Send errors to <inputfile>.err\n");
		printf("l    Produce listing file <inputfile>.list\n");
		printf("o    Inhibit creation of object file\n");
		printf("s    Include symbol table information in output\n");
		printf("u    Display statistics on usage and speed\n");
		return 1;
	}

	headers=tmalloc(256*sizeof(struct sym *));
	if(!headers) nomem(11);
	clearmem(headers,256*sizeof(struct sym *));
	outblock=tmalloc(BLOCKSIZE);
	if(!outblock) nomem(1);
	textblock=tmalloc(BLOCKSIZE);
	if(!textblock) nomem(2);
	textpoint=textblock;
	listbuff=tmalloc(IOBLOCKSIZE);
	if(!listbuff) nomem(10);
	listpoint=listbuff;
	listend=listbuff+IOBLOCKSIZE-512;
	macroblock=tmalloc(MACROMAX);
	if(!macroblock) nomem(4);
	macstack=macroblock;
	symbols=tmalloc(sizeof(struct sym) * MAXSYMS);
	if(!symbols) nomem(6);
	nextsym=symbols;
	heresym=nextsym++;
	clearmem(heresym,sizeof(struct sym));
	heresym->symtype=RELTYPE;

	countops(&z80list,z80codes);
	countops(&directlist,directs);

	somebss=0;
	for(i=0;i<128;i++)
		attr[i]=0;
	fixattr(ATTRWHITE,"\t \015");
	fixattr(ATTRSYM+ATTRFSYM+ATTROP,
		"abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ");
	fixattr(ATTRFSYM+ATTROP+ATTRSYM,".");
//	fixattr(ATTRFSYM,"@");
	fixattr(ATTRSYM+ATTRNUM+ATTRHEX+ATTROP,"0123456789");
	fixattr(ATTRHEX,"abcdefABCDEF");
	linelabel.symtext=ltext;
	symbol.symtext=stext;
	symbol2.symtext=stext2;
	opsym.symtext=opcodeorig;

	setup(argc,argv);
	makefilename();
	sfile=open(filename,O_RDONLY);
	if(sfile<0) {printf("Cannot open %s\n",filename);return 1;}
	close(sfile);

	if(options['e'])
	{
		makename(temp,inputname,".err");
		errorfile=fopen(temp,"w");
	}
	if(options['l'])
	{
		makename(temp,inputname,".list");
		listfile=fopen(temp,"w");
		if(!listfile)
		{
			printf("Cannot open listing file %s\n",temp);
			closeall();
			return 1;
		}
	}

	addspecial("LOW",REFLOW);
	addspecial("HIGH",REFHIGH);
	addspecial("BANK",REFBANK);
	currentsection=0;
	bsshunk=0;
	outoff=outblock;
	phase=0;
	pass=0;
	passlist=LISTBOTH;
	if(dopass()) goto skip2;
	outoff=outblock;
	pass=1;
	passlist=1;

	makefilename();

	if(!options['o'])
	{
		if(!outputname[0])
		{
			strcpy(outputname,filename);
			outputname[strlen(outputname)-strlen(ASMEXTENSION)]=0;
			strcat(outputname,OBJEXTENSION);
		}
		outfile=open(outputname,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
		if(outfile<0)
		{
			printf("Cannot open output file %s\n",outputname);
			closeall();
			return 1;
		}
	}

	if(!options['b']) headout();
	outoffsave=outoff;
	dopass();
	if(bsshunk) outoff=outoffsave;
	pcmaxt=pcmax;
	symsout(ADEF);
	outrelocs();
	outpublics();
	if(!options['b']) tailout();
//	if(somebss)
//		outbss();
	flush();
	if(listfile && 0)
	{
		for(i=0;i<256;i++)
		{
			asym=headers[i];
			while(asym)
			{
				putc(asym->symtype+'0',listfile);
				putc(':',listfile);
				pntr=asym->symtext;
				while(ch=*pntr++) putc(ch,listfile);
				fprintf(listfile,"=%x\n",(int32_t)asym->symvalue);
				asym=asym->symnext;
			}
		}
	}
	time2=gtime();
	time2-=time1;if(time2==0) time2++;

	lpm=(maxlines*6000L)/time2;

	if(options['u'])
	{
		printf("%06lx/%06x Macro/symbol text/xdef/xref used\n",textpoint-textblock,BLOCKSIZE);
		printf("%04x/%04x     Symbols\n",(int)(nextsym-symbols),MAXSYMS);
		printf("%06x        Object code bytes\n",pcmaxt);
		printf("%-11d   Lines\n",maxlines);
		printf("%-11d   Lines/minute\n",lpm);
	}

skip2:
	closeall();
	if(errorcount)
	{
		printf("%d error%s\n",errorcount,errorcount==1 ? "" : "s");
		unlink(outputname);
	}
	if(warncount) printf("%d warning%s\n",warncount,
		warncount==1 ? "" : "s");
	exit(errorcount!=0);
}

void closeall(void) {
	if(listfile) {flushlist();fclose(listfile);}
	if(outfile>=0) {close(outfile);outfile=-1;}
	if(errorfile) fclose(errorfile);
	freestuff();
}


void flush(void) {
	uchar *p;
	int32_t left;
	int res;

	if(outfile) {
		res=write(outfile,outblock,outoff-outblock);res=res;
	}
	outoff=outblock;
}



int dopass(void) {

	reptsp=-1;
	strcpy(lastreal,"wtf");
	umac[0]='a'-1;umac[1]=umac[2]='a';
	symcount=1;
	storing=0;
	pcmax=0;
	depth=0;ydepth=0;
	pcount=0;
	setz80();
	maxlines=0;
	expanding=0;inmac=0;
	numopen=0;
	dofile();
	while(pcmax & 3)
		bout(0xff);
	return 0;
}
int32_t filelen(file)
int file;
{
int32_t len,loc;
	loc=lseek(file,0L,1);
	len=lseek(file,0L,2);
	lseek(file,loc,0);
	return len;
}
void dofile(void) {
	int file,piece;
	int32_t len;
	uchar *addr,*p,*p2,ch;
	uchar **fl;
	int i;

	cline=0;
	if(!pass)
	{
		file=open(filename,O_RDONLY);
		if(file<0)
		{
			printf("Cannot open input file %s\n",filename);
			return;
		}
		len=filelen(file);
		addr=tmalloc(len+65);
		if(!addr) nomem(5);
		fl=filelist;
		filelist=(void *)addr;
		*filelist=(void *)fl;
		strcpy((void *)(filelist+1),filename);

		addr+=64;
		len=read(file,addr,len);
		addr[len]=0;
		removecr(addr);

		close(file);
	} else
	{
		fl=filelist;
		while(fl)
		{
			if(!strcmp((void *)(fl+1),filename))
			{
				addr=(void *)fl;
				addr+=64;
				break;
			}
			fl=(void *)*fl;
		}
		if(!fl)
		{
			printf("Pass 2: File %s not seen in pass 1\n",filename);
			return;
		}
	}
	numopen++;
	assemble(addr);
	maxlines+=cline;
	numopen--;
}



int expect(uchar ch) {
	if(get()==ch) return 0;
	syntaxerr();back();return 1;
}
int expects(uchar *str) {
	while(*str)
		if(get()!=*str++)
			{syntaxerr();back();return 1;}
	return 0;
}

void assemble(uchar *str) {
	uchar c;
	inpoint=str;

	while(at())
	{
		++cline;
		aline();
		while((c=get()) && c!=LF);
		if(!c) break;
	}
}

void aline(void) {
	handler *func;
	uchar *toff1,*toff2;
	uchar *ooff1;
	uchar ch,eo,lflag;
	int pcsave;
	uchar *save;
	int xpos,cnt,i,j;
	struct sym *pntr;
	uchar *mactop,*cursave;
	uchar *p,*p2;

	heresym->symvalue=pcount;
	toff1=inpoint;
	ooff1=outoff;
	pcsave=pcount;

	equssize=someequs=0;
	equsbase=0;
	alabel=0;
	ch=at();
	if(!storing && !iswhite(ch))
	{
		if(ch==';') goto printline;

		if(isokfirst(ch))
		{
			i=ch;
			ch=token(&linelabel);
			if(i!=LOCAL)
			{
				++symcount;
				strcpy(lastreal,linelabel.symtext);
			} else
				fixlocal(&linelabel);
			alabel=1;
			linelabel.symflags=0;
			if(ch==':')
			{
				get();
				if(at()==':')
				{
					get();
					linelabel.symflags|=APUBLIC;
				}
			}

			linelabel.symtype=RELTYPE;
			linelabel.symvalue=pcount;
		}
	}
	if(storing && !iswhite(at())) {if(!pass) inpoint=storeline(toff1);goto printline;}
	ch=skipwhite();
	if(isokfirst(ch))
	{
		gather();
		variant=0;
		skipwhite();

		anumsign=(at()=='#');

		func=scan(opcode,currentlist);

		if(!func) func=scan(opcode,&directlist);

		if(storing)
		{
			if(func==doendm) {storing=0;if(!pass) endstore();}
			else if(!pass) inpoint=storeline(toff1);
			goto printline;
		}
		if(func)
		{
			if(func==doinclude && depth==ydepth)
			{
				if(listfile && passlist)
					listline(toff1,ooff1,pcsave); /*{save=inpoint;listline(toff1,ooff1,pcsave);inpoint=save;}*/
				doinclude();
				return;
			}
			if(depth==ydepth)
			{
				if(alabel) handlelabel(func);
				func();
			}
			else if(isConditional(func)) func();
		} else
		{
			if(pntr=findsym(&opsym))
			{
				if(pntr->symtype==MACTYPE);
				{
					umac[0]++;
					if(umac[0]=='z'+1)
					{
						umac[0]='a';
						umac[1]++;
						if(umac[1]=='z'+1)
						{
							umac[1]='a';
							umac[2]++;
						}
					}
					mactop=macstack;
					maclens[0]=0;
					for(i=1;i<10;i++)
					{
						macpars[i]=inpoint;
						maclens[i]=0;
						for(;;)
						{
							ch=at();
							if(ch==LF) break;
							if(iswhite(ch)) break;
							get();
							if(ch==',') break;
							maclens[i]++;
						}
					}
					if(listfile && passlist && expanding)
						listline(toff1,ooff1,pcsave);
					if(inmac==MACDEPTH)
						{error("Macro overflow");return;}
					inmac++;
					p=(uchar *)pntr->symvalue;
					while(ch=*p++)
					{
						if(ch=='\\')
						{
							if(isoknum(ch=*p))
							{
								p++;
								ch-='0';
								j=maclens[ch];
								p2=macpars[ch];
								while(j--) *macstack++=*p2++;
							} else if(ch=='@')
							{
								p++;
								*macstack++=umac[2];
								*macstack++=umac[1];
								*macstack++=umac[0];
							}
						} else *macstack++=ch;
					}
					*macstack++=0;

					cursave=inpoint;
					inpoint=mactop;
					while(at())
					{
						aline();
						while(get()!=LF);
					}
					inpoint=cursave;
					macstack=mactop;inmac--;
					if(expanding) return;
				}
			} else
				illegalop();
		}
	} else if(alabel && depth==ydepth) handlelabel(0);

printline:
	if(listfile && passlist)
		listline(toff1,ooff1,pcsave);
//	while(ch=*toff1++) {putchar(ch);if(ch=='\n') break;}
}

void handlelabel(handler *func) {
	struct sym *pntr,*asym;

	if(!pass)
	{
		if(pntr=findsym(&linelabel))
		{
			if(func!=doeset)
			{
				if(pntr->symflags&ADEF)
					duplicate();
				else
				{
					if(linelabel.symflags&APUBLIC && ~pntr->symflags&APUBLIC)
						addpublic(pntr);
					pntr->symvalue=linelabel.symvalue;
					pntr->symtype=linelabel.symtype;
					pntr->symflags|=ADEF|linelabel.symflags;
				}
			}
		} else
		{
			linelabel.symflags|=ADEF;
			asym=addsym(&linelabel);
			if(asym->symflags&APUBLIC)
			{
				addpublic(asym);
			}
		}
	} else
	{
		pntr=findsym(&linelabel);
		if(pntr->symvalue!=linelabel.symvalue)
		{
			if(func!=doeset && func!=doequ && func!=domacro && !phase &&
				func!=dorb && func!=dorw && func!=doequs)
			{
				phase=1;
				phaserr();
			}
		}
	}
}

void flushlist(void) {
	fwrite(listbuff,1,listpoint-listbuff,listfile);
	listpoint=listbuff;
}
void listadvance(void) {while(*listpoint) ++listpoint;}

void listline(uchar *toff1, uchar *ooff1,int pcsave) {
	uchar *ooff2;
	uchar eo,ch,lflag;
	int xpos,cnt;
	uchar *toff2;
	uchar *save;
	uchar buff[128];

	if(!expanding && inmac) return;

	if(listpoint>listend)
		flushlist();

	save=inpoint;
	ooff2=outoff;
	outoff=ooff1;
	lflag=0;
	for(;;)
	{
		sprintf(listpoint,"%04x",pcsave);
		listadvance();
		xpos=5;
		eo=0;
		cnt=0;
		*listpoint++=inmac ? '+' : ' ';
		while(outoff<ooff2)
		{
			sprintf(listpoint,"%02x",*outoff++);
			listadvance();
			pcsave++;
			xpos+=2;
			cnt++;
			if(cnt==8) break;
		}
		if(!lflag)
		{
			lflag++;
			while(xpos<24) {xpos++; *listpoint++=' ';}
			toff2=inpoint;
			inpoint=toff1;
			while((ch=get())!=LF) *listpoint++=ch;
			back();
		}
		*listpoint++='\n';
		if(outoff==ooff2) break;
		if(listpoint>listend) flushlist();
	}
	inpoint=save;
}




void pushll(int64_t val) {
	*(int64_t *)exprsp=val;
	exprsp+=8;
}
void pushl(int32_t val) {
	*(int32_t *)exprsp=val;
	exprsp+=4;
}
void pushb(uchar val) {
	*exprsp++=val;
}
int64_t popll(void) {
	exprsp-=8;
	return *(int64_t *)exprsp;
}
int32_t popl(void) {
	exprsp-=4;
	return *(int32_t *)exprsp;
}
int popb(void) {
	return *--exprsp;
}

void operand(void), operator(void);
int trytop(void);
void expr2(void);

void rexpr(void) {
	uchar flags;
	exprsp=exprstack;
	exprflag=0;
	lastref=0;
	expr2();
	if(exprflag & 1) unbalanced();
	if(exprflag & 2) badoperation();
}
void expr(void) {
	relsp=0;
	rexpr();
}
/*uchar opuchars[]={'+','-','/','*','|','&','<<','>>','!'};*/
void expr2(void) {
	pushb(0);
	for(;;)
	{
		operand();
		operator();
		if(trytop()) break;
		pushll(operval);
		pushll((int64_t)operrel);
		pushb(opertype);
		pushb(opop);
		pushb(oppri);
	}
	exprval=operval;
	exprtype=opertype;
	popb();
}
int trytop(void) {
	uchar toppri,topop,toptype;
	int32_t topval;
	struct relentry *toprel;
	struct sym *sym1,*sym2;

	for(;;)
	{
		toppri=popb();
		if(oppri>toppri) {pushb(toppri);return oppri==8;}
		topop=popb();
		toptype=popb();
		toprel=(void *)popll();
		topval=popll();
		switch(topop)
		{
		case 0: /* + */
			operval+=topval;
			opertype=cplus[toptype][opertype];
			break;
		case 1: /* - */
			operval=topval-operval;
			if(toptype==RELTYPE && opertype==RELTYPE && toprel && operrel &&
				(toprel->sym->symflags&ADEF) && (operrel->sym->symflags&ADEF))
			{
				toprel->sym=0;
				operrel->sym=0;
				opertype=ABSTYPE;
				operrel=0;
				break;
			}
			if(opertype==RELTYPE && operrel)
				operrel->type=REFNEG;
			opertype=cminus[toptype][opertype];
			break;
		case 2: /* / */
			opertype=cdivide[toptype][opertype];
			if(!operval) {div0();operval=1;}
			operval=topval/operval;
			break;
		case 3: /* * */
			operval*=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 4: /* | */
			operval|=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 9: /* ^ */
			operval^=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 5: /* & */
			operval&=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 6: /* << */
			operval=topval<<operval;
			opertype=cnone[toptype][opertype];
			break;
		case 7: /* >> */
			operval=topval>>operval;
			opertype=cnone[toptype][opertype];
			break;
		case 8: return 1;
		}
		if(opertype==ERR) {opertype=ABSTYPE;exprflag|=2;}
	}
}

void operator(void) {
	uchar ch;

	ch=get();
	switch(ch)
	{
		case '^': oppri=32;opop=9;break;
		case '+': oppri=16;opop=0;break;
		case '-': oppri=16;opop=1;break;
		case '/': oppri=24;opop=2;break;
		case '*': oppri=24;opop=3;break;
		case '|': oppri=32;opop=4;break;
		case '&': oppri=40;opop=5;break;
		case '<':
			if(get()!='<') back();
			oppri=48;opop=6;break;
		case '>':
			if(get()!='>') back();
			oppri=32;opop=7;break;
		default:
			back();oppri=8;opop=8;
	}
}

/*
+ 010
- 110
/ 218,20f
* 318
| 420
& 528
<< 630
>> 730
. , ( ) white ; 008
*/



/* fills in operval and opertype, leaves pointer on ucharacter stopped on */
void operand(void) {
	uchar ch;
	struct sym *pntr;
	uchar *p;

top:
	operrel=0;
	ch=at();
	if(ch=='(')
	{
		get();
		expr2();
		if(get()!=')') {exprflag|=1;back();}
		operval=exprval;
		opertype=exprtype;
	} else if(ch=='-')
	{
		get();
		operand();
		if(opertype==ABSTYPE) operval=-operval;
		else error2("Illegal use of unary -");
		return;
	} else if(ch=='!')
	{
		get();
		operand();
		if(opertype==ABSTYPE) operval=!operval;
		else error2("Illegal use of unary !");
		return;
	} else if(ch=='~')
	{
		get();
		operand();
		if(opertype==ABSTYPE) operval=~operval;
		else error2("Illegal use of unary ~");
		return;
	} else if(isokfirst(ch))
	{
		token(&symbol);
		if(*symbol.symtext==LOCAL)
			fixlocal(&symbol);
		p=stext;
		ch=*p++;
		if(pntr=findsym(&symbol))
		{
			if(pntr->symflags&ASPECIAL)
			{
				if(pntr->symflags&ANEQUS)
				{
					equspntr=(uchar *)(pntr->symvalue);
					equssize=someequs=strlen(equspntr);
					equsbase=currentpos();
					goto top;
				}
				operval=pntr->symvalue;
				opertype=ABSTYPE;
				if(at()!='(') {syntaxerr();return;}
				get();
				token(&symbol);
				if(at()!=')') {syntaxerr();return;}
				get();
				pntr=findsym(&symbol);
				if(!pntr)
				{
					symbol.symvalue=0;
					symbol.symtype=RELTYPE;
					symbol.symflags=0;
					pntr=addsym(&symbol);
				} else
				{
					if(pntr->symflags&ANEQUS) error2("OP(EQUS variable)");
				}
				if(pntr->symtype==RELTYPE) {
					rellist[relsp].sym=pntr;
					rellist[relsp++].type=operval;
					if(!(pntr->symflags&APUBLIC))
					{
						addpublic(pntr);
						pntr->symflags|=APUBLIC;
					}
					opertype=XREFTYPE;
					operval=0;
				} else {// must be ABSTYPE
					opertype=ABSTYPE;
					switch(operval) {
					case REFLOW: operval=pntr->symvalue&0xff;break;
					case REFHIGH: operval=(pntr->symvalue>>8)&0xff;break;
					case REFBANK: operval=0;error2("BANK(<constant>) meaningless");break;
					}
				}
			} else
			{
				opertype=pntr->symtype;
				if(opertype==RELTYPE)
				{
					operrel=rellist+relsp++;
					operrel->sym=pntr;
					operrel->type=REFNORMAL;
					operval=pntr->symvalue;
				} else
					operval=pntr->symvalue;
				if(pass && !(pntr->symflags&(APUBLIC|ADEF))) unknownerr(pntr->symtext);
			}
		} else
		{
			operval=0;
			symbol.symvalue=0;
			symbol.symtype=opertype=ABSTYPE; //RELTYPE;
			symbol.symflags=0;
			operval=(int64_t)(pntr=addsym(&symbol));
			if(pass)
				unknownerr(symbol.symtext);
		}
	} else if(isoknum(ch))
	{
		operval=0;
		while(isoknum(ch=get())) {operval*=10;operval+=ch-'0';}
		opertype=ABSTYPE;
		back();
		ch=tolower(ch);
		if(ch=='h' || ch>='a' && ch<='f') error2("Old fashioned 'h' stuff");
	} else if(ch=='$')
	{
		get();
		operval=0;
		while(ishex(ch=get())) {operval<<=4;operval+=tohex(ch);}
		opertype=ABSTYPE;
		back();
	} else if(ch==QUOTECHAR)
	{
		get();
		opertype=ABSTYPE;
		operval=0;
		while(ch=get())
		{
			if(ch==LF) {back();unbalancedq();break;}
			if(ch==QUOTECHAR)
				if(get()!=QUOTECHAR) {back();break;}
			operval<<=8;operval+=ch;
		}
	} else if(ch==QUOTECHAR2)
	{
		get();
		opertype=ABSTYPE;
		operval=0;
		while(ch=get())
		{
			if(ch==LF) {back();unbalancedq();break;}
			if(ch==QUOTECHAR2)
				if(get()!=QUOTECHAR2) {back();break;}
			operval<<=8;operval+=ch;
		}
	} else if(ch=='@')
	{
		get();
		opertype=RELTYPE;
		operval=heresym->symvalue;
	} else if(ch=='%')
	{
		get();
		operval=0;
		while((ch=get()) && ch=='0' || ch=='1')
			{operval<<=1;operval|=ch-'0';}
		opertype=ABSTYPE;
		back();
	} else
	{
		operval=0;
		opertype=NOTHING;
	}
}


uchar *storeline(str)
uchar *str;
{
	uchar ch;
	do
	{
		ch=*str++;
		*textpoint++=ch;
	} while(ch!=10);
	return str-1;
}
void endstore(void) {
	*textpoint++=0;
	if((int64_t)textpoint&1) textpoint++;
}
void addword(val)
short val;
{
	*(short *)textpoint=val;
	textpoint += 2;
}
void addpntr(void *val) {
	*(void **)textpoint=val;
	textpoint+=sizeof(void *);
}
void addlong(int32_t val) {
	*(int32_t *)textpoint=val;
	textpoint+=4;
}
void addtext(uchar *str) {
	int len;
	len=(strlen(str)+2)&0xfffe;
	bcopy(str,textpoint,len);
	textpoint+=len;
}

void predef(name,value)
uchar *name;
int32_t value;
{
	strcpy(symbol2.symtext,name);
	symbol2.symtype=ABSTYPE;
	symbol2.symvalue=value;
	symbol2.symflags=ADEF;
	if(!findsym(&symbol2)) addsym(&symbol2);
}



int comma(void) {if(get()==',') return 0; else back();syntaxerr();return 1;}
int numsign(void) {if(get()=='#') return 0; else back();syntaxerr();return 1;}
int squote(void) {if(get()=='\'') return 0; else back(); return 1;}

void dofiledirective(void) {}

void dosection(void)
{
	expr();
	currentsection=exprval;
}

void dodcb(void)
{
int size,val;
	expr();
	size=exprval;
	expr();
	val=exprval;
	while(size-->0)
		bout(val);
}

void dorept(void)
{
	expr();
	if(reptsp<MAXREPTS-1)
	{
		++reptsp;
		repts[reptsp].loc=currentpos();
		repts[reptsp].count=exprval;
		repts[reptsp].cline=cline;
	} else
		reptdepth();
}
void doendr(void)
{
	if(reptsp<0)
		reptdepth();
	else
	{
		if(--repts[reptsp].count>0)
		{
			moveto(repts[reptsp].loc);
			cline=repts[reptsp].cline;
		}
		else
			--reptsp;
	}
}


void dodsb(void)
{
	expr();
	zeros(exprval);
}
void dodsw(void)
{
	expr();
	zeros(exprval<<1);
}
void dodsl(void)
{
	expr();
	zeros(exprval<<2);
}
void zeros(int32_t size) {
	if(size>MAXDB || size<0) outofrange();
	else while(size--) bout(0);
}

void doalign(void)
{
int32_t v1,v2;
	expr();
	v1=exprval;
	v2=pcount%v1;
	if(v2) zeros(v1-v2);
}

int dnd(void) {
	struct sym *dndsym;
	token(&symbol2);
	dndsym=findsym(&symbol2);
	if(!dndsym) return 0;

	if(!pass) return 1;

	return 1;
}
int fetchstr(uchar *str) {
	uchar ch;
	if(squote()) return 1;
	for(;;)
	{
		ch=get();
		if(ch==LF || ch==0) {back();return 1;}
		*str++=ch;
		if(ch!='\'') continue;
		*--str=0;break;
	}
	return 0;
}
int cnc(void) {
	uchar ch;
	uchar str1[80],str2[80];

	if(fetchstr(str1)) {syntaxerr();return 0;}
	if(comma()) return 0;
	if(fetchstr(str2)) {syntaxerr();return 0;}
	return strcmp(str1,str2);
}

int checkdepth(void){if(depth==ydepth) return 0;++depth;return 1;}
void setyes(void){if(depth==ydepth) ++ydepth;++depth;}
void doifeq(void){if(checkdepth()) return;expr();if(!exprval) setyes(); else setno();}
void doifne(void){if(checkdepth()) return;expr();if(exprval) setyes(); else setno();}
void doifge(void){if(checkdepth()) return;expr();if(exprval>=0) setyes(); else setno();}
void doifgt(void){if(checkdepth()) return;expr();if(exprval>0) setyes(); else setno();}
void doifle(void){if(checkdepth()) return;expr();if(exprval<=0) setyes(); else setno();}
void doiflt(void){if(checkdepth()) return;expr();if(exprval<0) setyes(); else setno();}
void doifc(void){if(!cnc()) setyes(); else setno();}
void doifnc(void){if(cnc()) setyes(); else setno();}
void doifd(void){if(dnd()) setyes(); else setno();}
void doifnd(void){if(!dnd()) setyes(); else setno();}
void doelse(void)
{
	if(!depth) illegalop();
	else
	{
		if(depth==ydepth) --ydepth;
		else
		if(depth==ydepth+1) ++ydepth;
	}
}
void doendc(void){if(!depth) illegalop();else {if(depth==ydepth) --ydepth;--depth;}}
int isConditional(handler *f) {
	return f==doelse || f==doendc || f==doifeq || f==doifne ||
		f==doifge || f==doifgt || f==doifle || f==doiflt ||
		f==doifc || f==doifnc || f==doifd || f==doifnd;
}
void setno(void){++depth;}
void doorg(void){expr();pcount=exprval;}

/*
dobss()
{
	struct sym *s;
	uchar *t;

	if(pass) return;
	token(&symbol2);
	s=findsym(&symbol2);
	if(comma()) return;
	expr();
	if(s)
	{
		if(s->symflags&(ADEF|ABSS))
		{
			duplicate();
			return;
		}
		s->symvalue=blockcount;
		s->symtype=RELTYPE;
		s->symflags|=ABSS|APUBLIC;
		t=(void *)blockhead;
		blockhead=(void *)textpoint;
		addpntr(t);
		addpntr(s);
		addpublic(s);
	} else
	{
		symbol2.symvalue=blockcount;
		symbol2.symtype=RELTYPE;
		symbol2.symflags=ABSS|APUBLIC;
		s=addsym(&symbol2);
		t=(void *)blockhead;
		blockhead=(void *)textpoint;
		addpntr(t);
		addpntr(s);
		addpublic(s);
	}
	somebss=1;
	if(exprval>1 && (blockcount&1)) blockcount++;
	blockcount+=exprval;
}
*/

void dobss(void)
{
	bsshunk=1;
	expr();
	pcount=exprval;
}

void dopublic(void)
{
struct sym *s;
	if(pass) return;
	for(;;)
	{
		skipwhite();
		token(&symbol2);
		s=findsym(&symbol2);
		if(s)
		{
			if(~s->symflags & APUBLIC)
			{
				s->symflags|=APUBLIC;
				addpublic(s);
			}
		} else
		{
			symbol2.symvalue=0;
			symbol2.symtype=RELTYPE;
			symbol2.symflags=APUBLIC;
			s=addsym(&symbol2);
			addpublic(s);
		}
/*
		if(skipwhite()==':')
		{
			get();
			skipwhite();
			while(isoksym(at())) get();
		}
*/
		if(skipwhite()!=',') break;
		get();
	}
}

void doendm(void){;}
void domacro(void)
{
	struct sym *pntr;

	storing++;
	if(pass) return;
	pntr=findsym(&linelabel);
	pntr->symtype=MACTYPE;
	pntr->symvalue=(int64_t)textpoint;
}
void doexpon(void){expanding=1;}
void doexpoff(void){expanding=0;}
void doinclude(void)
{
uchar	iname[80];
uchar	namesave[80];
int linesave;
uchar *macsave;
uchar *pntr,ch,*p2;
int	sfile;
uchar *save;
uchar *env;

	if(numopen==MAXIN) {error("Too many nested includes");return;}

	ch=at();
	if(ch!='\'' && ch!='"') {syntaxerr();return;}
	get();
	pntr=iname;
	for(;;)
	{
		ch=get();if(ch==LF) {back();break;}
		if(ch=='\'' || ch=='"' || iswhite(ch)) break;
		*pntr++=ch;
	}
	*pntr=0;
	sfile=open(iname,O_RDONLY);
	if(sfile<0)
	{
/*
		if(env=getenv(INCNAME))
		{
			strcpy(namesave,iname);
			pntr=env;
			while(*pntr)
			{
				p2=iname;
				while(*pntr && *pntr!=';') *p2++=*pntr++;
				if(*pntr) pntr++;
				*p2=0;
				strcat(iname,namesave);
				if((sfile=open(iname,O_RDONLY))>=0) break;
			}
		}
*/
		if(!sfile)
			{error("Cannot open file");return;}
	}
	close(sfile);
	strcpy(namesave,filename);
	strcpy(filename,iname);
	linesave=cline;

	save=inpoint;
	macsave=macstack;
	dofile();
	macstack=macsave;
	inpoint=save;
	strcpy(filename,namesave);
	cline=linesave;
}

void donds(void)
{
	token(&symbol2);
	if(comma()) return;
	expr();
	soffset-=exprval;
	symbol2.symvalue=soffset;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=ADEF;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}
void domds(void)
{
	token(&symbol2);
	if(comma()) return;
	expr();
	symbol2.symvalue=soffset;
	soffset+=exprval;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=ADEF;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}

void dostructure(void)
{
	token(&symbol2);
	if(comma()) return;
	expr();
	soffset=exprval;
}


void doinit(void)
{
	expr();
	soffset=exprval;
}
void dolabel(void) {varsize(0);}
void dobyte(void) {varsize(1);}
void doword(void) {varsize(2);}
void dolong(void) {varsize(4);}

void varsize(int size) {
	token(&symbol2);
	symbol2.symvalue=soffset;
	soffset+=size;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=ADEF;
	symbol2.symref=0;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}

void doeset(void)
{
	struct sym *pntr;

	expr();
	pntr=findsym(&linelabel);
	pntr->symtype=exprtype;
	pntr->symvalue=exprval;
}

void dorsset(void)
{
	expr();
	soffset=exprval;
}
void dorsreset(void)
{
	soffset=0;
}
void dorany(int size) {
	struct sym *pntr;

	expr();
	exprval*=size;
	pntr=findsym(&linelabel);
	pntr->symtype=ABSTYPE;
	if(pass && pntr->symvalue!=soffset) phaserr();
	pntr->symvalue=soffset;
	soffset+=exprval;
}
void dorb(void)
{
	dorany(1);
}
void dorw(void)
{
	dorany(2);
}
int fetchquoted(char *put,int size) {
	char ch;
	if(at()!=QUOTECHAR) {syntaxerr();return -1;}
	get();
	while(ch=at())
	{
		if(ch=='\n' || ch==QUOTECHAR) break;
		get();
		if(size>1) --size,*put++=ch;
	}
	*put=0;
	if(at()==QUOTECHAR)
	{
		get();
		return 0;
	}
	syntaxerr();
	return -1;
}
void doincbin(void)
{
	int file,in;
	char block[256],*p;

	if(fetchquoted(block,sizeof(block))) return;
	file=open(block,O_RDONLY);
	if(file<0) {cantopen();return;}
	while(in=read(file,block,sizeof(block)))
	{
		p=block;
		while(in--)
			bout(*p++);
	}
	close(file);
}

void doequs(void)
{
	struct sym *pntr;
	char text[256];

	if(fetchquoted(text,sizeof(text))) return;

	pntr=findsym(&linelabel);
	pntr->symtype=ABSTYPE;
	pntr->symflags=ANEQUS|ASPECIAL;
	pntr->symvalue=(int64_t)textpoint;
	addtext(text);
}
void doequ(void)
{
	struct sym *pntr;

	expr();
	pntr=findsym(&linelabel);
	pntr->symtype=exprtype;
	if(pass && pntr->symvalue!=exprval) phaserr();
	pntr->symvalue=exprval;
}

void doeven(void) {if(pcount&1) bout(0);}
void dosteven(void) {if(soffset&1) soffset++;}

void headout(void) {
	int32_t temp;
	uchar *p1,*p2,ch,txt[80];
	int t;

	temp=pcmax;
	lout(HUNK_NAME);
	lout(1L);
	sprintf(txt,"%02X",currentsection&255);
	bout(*txt);
	bout(txt[1]);
	wout(0);

	if(!bsshunk)
	{
		lout(HUNK_CODE);
		lout(temp>>2);
	}
	else
	{
		lout(HUNK_BSS);
		lout(0);
	}
}
void tailout(void){lout(HUNK_END);}
void symsout(int mask) {
	int i,j;
	uchar ch;
	struct sym *pntr;
	int p2;

	lout(0x3f0L);
	for(i=0;i<256;i++)
	{
		pntr=headers[i];
		while(pntr)
		{
			if(pntr->symtype==RELTYPE && (pntr->symflags & mask) &&
				*pntr->symtext!=LOCAL && !(pntr->symflags& APUBLIC))
			{
				symout(pntr->symtext,0);
				lout(pntr->symvalue);
			}
			pntr=pntr->symnext;
		}
	}
	lout(0L);
}

void symout(uchar *s, int d) {
	int j;
	uchar text[80],*p,ch;

	p=text;
	while(ch=*s++) *p++=ch;
	while((p-text)&3) *p++=0;
	j=p-text;
	p=text;
	bout(d);
	wout(0);
	bout(j>>2);
	while(j--) bout(*p++);
}

void addref(struct sym *asym, int type) {
	uchar *t;
	t=textpoint;
	addpntr(asym->symref);
	asym->symref=(void *)t;
	addlong(pcount);
	addword(type);
}
void addreloc(int size) {
	uchar *t;
	t=textpoint;
	if(size==2)
	{
		addpntr(reloc16head);
		addlong(pcount);
		addword(2);
		reloc16head=(void *)t;
		++reloc16num;
	} else
	{
		addpntr(reloc32head);
		addlong(pcount);
		addword(4);
		reloc32head=(void *)t;
		++reloc32num;
	}
}
void outreloclist(hunktype,head,num)
struct reference *head;
int num,hunktype;
{
	if(!num) return;
	lout((int32_t)hunktype);
	lout((int32_t)num);
	lout(0L);
	while(head)
	{
		lout(head->refoff);
		head=head->refnext;
	}
	lout(0L);
}
void outrelocs(void)
{
	outreloclist(0x3cd,reloc16head,reloc16num);
	outreloclist(0x3cc,reloc32head,reloc32num);
}

/*
outbss()
{
struct sym *asym;

	lout(0x3eb);
	lout(blockcount+3>>2);
	if(options['s'])
		symsout(ABSS);
	lout(0x3efL); // hunk_ext
	asym=publichead;
	while(asym)
	{
		if(asym->symflags & ABSS)
		{
			symout(asym->symtext,1);
			lout(asym->symvalue);
		}
		asym=asym->sympublic;
	}
	lout(0);
	lout(0x3f2);
}
*/


void outpublics(void) {
	struct sym *asym;
	struct reference *aref,*ref2,*t;
	int count,type;
	unsigned char *p;

	if(!publichead) return;
	lout(0x3efL); /* hunk_ext */
	p=publichead;
	while(p)
	{
		asym=((struct sym **)p)[1];
		if(asym->symflags & ADEF)
		{
			symout(asym->symtext,1);
			lout(asym->symvalue);
		}
		p=*(char **)p;
	}
	p=publichead;
	while(p)
	{
		asym=((struct sym **)p)[1];
//		if(~asym->symflags & ADEF)
		{
			while(aref=asym->symref)
			{
				type=aref->reftype;
				count=0;
				while(aref)
				{
					if(aref->reftype==type) count++;
					aref=aref->refnext;
				}

				symout(asym->symtext,type);
				lout((int32_t)count);
				ref2=0;
				aref=asym->symref;
				while(aref)
				{
					t=aref;
					aref=aref->refnext;
					if(t->reftype==type) lout(t->refoff);
					else
					{
						t->refnext=ref2;
						ref2=t;
					}
				}
				asym->symref=ref2;
			}
		}
		p=*(char **)p;
	}
	lout(0L);
}
void docnop(void)
{
int firstval,secondval;

	expr();
	firstval=exprval;
	if(comma()) return;
	expr();
	secondval=exprval;
	if(firstval>=secondval || secondval==0)
	{
		outofrange();
		return;
	}
	while(pcount%secondval!=firstval)
		bout(0);
}



void donothing(void) {}

struct anopcode directs[]={
{"align",doalign},
{"bss",dobss},
{"cnop",docnop},
{"dcb",dodcb},
{"ds",dodsb},
{"else",doelse},
{"end",donothing},
{"endc",doendc},
{"endm",doendm},
{"endr",doendr},
{"equ",doequ},
{"equs",doequs},
{"eset",doeset},
{"even",doeven},
{"expoff",doexpoff},
{"expon",doexpon},
{"fail",failerr},
{"file",dofiledirective},
{"global",dopublic},
{"if",doifne},
{"ifc",doifc},
{"ifd",doifd},
{"ifeq",doifeq},
{"ifge",doifge},
{"ifgt",doifgt},
{"ifle",doifle},
{"iflt",doiflt},
{"ifnc",doifnc},
{"ifnd",doifnd},
{"ifne",doifne},
{"incbin",doincbin},
{"include",doinclude},
{"label",dolabel},
{"macro",domacro},
{"public",dopublic},
{"rb",dorb},
{"rept",dorept},
{"rsreset",dorsreset},
{"rsset",dorsset},
{"rw",dorw},
{"section",dosection},
{"steven",dosteven},
{0}};


handler *scan(uchar *code, struct oplist *list) {
	struct anopcode *op;
	struct anopcode *table;
	int num,power;
	int way,n;

	table=list->listopcodes;
	num=list->numops;
	power=list->powerops;
	n=power-1;
	op=table+n;
	for(;;)
	{
		power>>=1;
		if(n>=num) way=-1;
		else
			if(!(way=strcmp(code,op->opcodename))) return op->opcodehandler;
		if(!power) return 0;
		if(way<0) {op-=power;n-=power;}
		else {op+=power;n+=power;}
	}
}
void outl(int32_t val)
{
	outw((short)val);
	outw((short)(val>>16));
}
void lout(int32_t val)
{
	wout((short)(val>>16));
	wout((short)val);
}
void outw(short val)
{
	bout(val);
	bout(val>>8);
}
void wout(short val)
{
	bout(val>>8);
	bout(val);
}
void bout(uchar val)
{
	*outoff++=val;
	pcount++;
	pcmax++;
}
void boutdoctor(int offset,uchar val)
{
	outoff[offset]=val;
}

void clearmem(void *where,int len) {
	memset(where,0,len);
}

struct sym *addspecial(char *name,int val)
{
struct sym ss;
	memset(&ss,0,sizeof(struct sym));
	ss.symflags=ASPECIAL|ADEF;
	ss.symtext=name;
	ss.symvalue=val;
	ss.symtype=ABSTYPE;
	return addsym(&ss);
}

struct sym *findsym(struct sym *asym)
{
	struct sym *pntr;
	uchar *p;

	p=asym->symtext;
	pntr=headers[hash8(p)];
	while(pntr && strcmp(pntr->symtext,p))
		pntr=pntr->symnext;
	return pntr;
}
void fixlocal(struct sym *asym) {
	int i,j;
	char *p;
	p=asym->symtext;
	i=strlen(lastreal);
	j=strlen(p);
	memmove(p+i,p,j);
	memcpy(p,lastreal,i);
	p[i+j]=0;
}
int token(struct sym *asym) {
	uchar *pntr,endch;
	int count=0;

	pntr=asym->symtext;
	while(endch=get())
	{
		if(count && isoksym(endch) || !count && isokfirst(endch))
		{
			*pntr++=endch;
			++count;
		} else break;
	}
	*pntr=0;
	return back();
}
int gather(void) {
	uchar *p1,*p2,ch;
	p1=opcode;
	p2=opcodeorig;

	while(isokop(ch=get())) *p1++=lowercase[*p2++=ch];
	*p1=*p2=0;
	return back();
}
int skipwhite(void) {
	while(iswhite(get()));
	return back();
}
void removecr(uchar *where) {
	uchar *p,ch;
	p=where;
	while(*p++=ch=*where++)
		if(ch==13) p--;
}
void addpublic(struct sym *s) {
	uchar *t;
	t=textpoint;
	addpntr(publichead);
	addpntr(s);
	publichead=t;
}
