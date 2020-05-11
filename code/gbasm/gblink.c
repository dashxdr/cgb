#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>

#include "link.h"

typedef unsigned char uchar;

#define MAXBANKS 256
#define OBJEXTENSION ".obj"

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define DATABLOCKSIZE 0x200000L
#define IOBLOCKSIZE 30000
#define OUTBLOCKSIZE 0x200000L
#define MAXIN 256
#define MAXHUNKS 1024
#define CODE 0
#define BSS 1
#define UNDEF 255
#define MAXFILES 1024
#define MAXDIRS 64

struct define {
	struct define *defnext;
	uchar *deftext;
	uchar deftype;
	uchar defhunk;
	int32_t defoffset;
	struct use *defuse;
};
struct use {
	struct use *usenext;
	uchar usetype;
	uchar usehunk;
	int32_t useoffset;
};

struct sym {
	struct sym *symnext;
	uchar *symtext;
	int32_t symval;
	uchar symhunk;
	uchar sympad;
};
struct input
{
	uchar inputname[80];
	uchar *inputloc;
};
struct hunk
{
	int hunktype;
	int codelen;
	int bsslen;
	int codedelta;
	int bank;
};


uchar mainname[]="_main";
int unresolved=0;

int hunkcount,hunkmax;

char *inputnames[MAXFILES];
char *dirnames[MAXDIRS];
int inputnum;
int dirnum;

struct define *predef(uchar *,int32_t);
void fixcart(void);
void patch(int thishunk,int num);
void handlefile(uchar *str);
void dosymbols(void);
int fix(int which);
int scan(uchar *str);

int infile;
int outfile;
uchar *filepoint;
struct input *ins=0;
struct hunk *hunks=0;
uchar *datablock=0;
uchar *datapoint;
uchar *ioblock=0;
int incount;
uchar scr1[80];
struct define **headers=0;
uchar outputname[256];
int32_t *longp;
short *wordp;
uchar *bytep;
uchar multflag=1;

uchar *outbuff=0;

uchar *codeloc;

int maxcode[MAXBANKS]={0};
int dummy;
#define OPTH 1
#define OPTS 2
#define OPTU 4
#define OPTF 8
#define OPTM 16
struct sym *symhead;
uchar *inctext;
uchar options[256];
int maxbank;

void skip(int len) {
	filepoint+=len<<2;
}

struct define *newdef()
{
struct define *t;
	t=(void *)datapoint;
	datapoint+=sizeof(struct define);
	return t;
}
struct sym *newsym()
{
struct sym *t;
	t=(void *)datapoint;
	datapoint+=sizeof(struct sym);
	return t;
}
struct use *newuse()
{
struct use *t;
	t=(void *)datapoint;
	datapoint+=sizeof(struct use);
	return t;
}
uchar *addtext(str)
uchar *str;
{
uchar *t;
int len;
	t=datapoint;
	len=strlen(str)+1;
	len+=len&1;
	datapoint+=len;
	strcpy(t,str);
	return t;
}

void cliptail(char *s1,char *s2) {
	int l1,l2;
	l1=strlen(s1);
	l2=strlen(s2);
	if(l2>l1 || strcmp(s1+l1-l2,s2)) return;
	s1[l1-l2]=0;
}


int revword(unsigned int val) {
	return ((val&0xff00)>>8) | ((val&0x00ff)<<8);
}
uint32_t revlong(uint32_t val) {
	return ((val&0xff000000)>>24) | ((val&0xff0000)>>8) | ((val&0xff00)<<8) | ((val&0xff)<<24);
}

uint32_t readlong(void) {
	uint32_t val;

	val=(filepoint[0]<<24) | (filepoint[1]<<16) | (filepoint[2]<<8) | filepoint[3];
	filepoint+=4;
	return val;
}

void symbol(int v) {
	int t;

	t=v<<2;

	bcopy(filepoint,scr1,t);
	filepoint+=t;
	scr1[t]=0;
}


int hash8(uchar *str) {
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

struct define *finddef(str)
uchar *str;
{
struct define *h;

	h=headers[hash8(str)];
	while(h)
	{
		if(!strcmp(str,h->deftext)) break;
		h=h->defnext;
	}
	return h;
}


void freeind(void **addr) {
	if(*addr)
	{
		free(*addr);
		*addr=0;
	}
}

void freestuff(void)
{
	int i;
	if(ins)
	{
		for(i=0;i<incount;i++)
			freeind((void **)&ins[i].inputloc);
	}
	for(i=0;i<inputnum;i++)
		freeind((void **)inputnames+i);
	for(i=0;i<dirnum;i++)
		freeind((void **)dirnames+i);

	freeind((void **)&ins);
	freeind((void **)&ioblock);
	freeind((void **)&datablock);
	freeind((void **)&outbuff);
	freeind((void **)&headers);
	freeind((void **)&hunks);
}

void nomem(void) {
	freestuff();
	printf("Out of memory\n");
	exit(1);
}

void missing(uchar *str) {
	if(!unresolved)
		printf("Unresolved references:\n");
	printf("%s\n",str);
	unresolved++;
}

void addname(char *name) {
	uchar *p;
	if(inputnum<MAXFILES && (p=malloc(strlen(name)+1)))
	{
		inputnames[inputnum++]=p;
		strcpy(p,name);
	}
}
void adddirname(char *name) {
	uchar *p;
	int i;
	if(dirnum<MAXFILES && (p=malloc(strlen(name)+1)))
	{
		dirnames[dirnum++]=p;
		strcpy(p,name);
		while((i=strlen(p)) && p[i-1]=='/') p[i-1]=0;
	}
}

int setup(int argc,char **argv)
{
	int i,j,k,mode,sfile;
	uchar ch;

	inputnum=0;
	dirnum=0;
	strcpy(outputname,"test.gb");
	for(i=0;i<256;i++) options[i]=0;
	options['s']=1;
	for(i=1,mode=0;i<argc;i++)
	{
reswitch:
		switch(mode)
		{
		case 0:
			if(argv[i][0]!='-')
			{
				addname(argv[i]);
				break;
			}
			mode=argv[i][1];
			if(argv[i][2]) {j=2;goto reswitch;}
			else {j=0;continue;}
		case 'o':
			strcpy(outputname,argv[i]+j);
			break;
		case '-':
			while(ch=argv[i][j++]) options[ch]^=1;
			break;
		case 'f':
			handlefile(argv[i]+j);
			break;
		case 'L':
			adddirname(argv[i]+j);
			break;
		default:
			mode=0;
			break;
		}
		mode=0;
	}

	return 0;
}
void clearmem(void *where,int len) {
	memset(where, 0, len);
}


int main(int argc, char **argv) {
	int i,j;
	int exelen;
	struct define *d;
	struct use *t1;
	uchar ch,*p1;
	int left;
	struct use *ause;
	int err;
	int res;

/*
for(i=0;i<argc;i++) printf("%s ",argv[i]);
printf("\n");
*/

	if(argc<2)
	{
		printf("%s 1999 by David Ashley\n",*argv);
		printf("Use: link [--OPTIONS] [-f <filelist>] [-o output] inputfile...\n");
		printf("m   Warn of multiple definitions\n");
		printf("u   Display usage information\n");
		return 0;
	}

	incount=0;
	inputnum=0;
	dirnum=0;
	ins=malloc(MAXIN*sizeof(struct input));
	if(!ins) nomem();
	hunks=malloc(MAXHUNKS*sizeof(struct hunk));
	if(!hunks) nomem();
	clearmem(ins,MAXIN*sizeof(struct input));
	datablock=malloc(DATABLOCKSIZE);
	if(!datablock) nomem();
	datapoint=datablock;
	outbuff=malloc(OUTBLOCKSIZE);
	if(!outbuff) nomem();
	memset(outbuff,0xff,OUTBLOCKSIZE);
	ioblock=malloc(IOBLOCKSIZE);
	if(!ioblock) nomem();
	headers=malloc(256*sizeof(struct define *));
	if(!headers) nomem();

	symhead=0;
	for(i=0;i<256;i++) headers[i]=0;

	hunkcount=0;
	maxbank=0;

	setup(argc,argv);

/*
	if(~options['h'])
		scan("_start");
*/

	multflag=1;
	for(i=0;i<inputnum;i++)
		scan(inputnames[i]);
/*
	for(i=1;i<argc;i++)
	{
		if(argv[i][0]!='-')
			scan(argv[i]);
		else if(argv[i][1]=='f')
			handlefile(argv[i]+2);
	}
*/
	multflag=0;
/*	if(~options['h'])
		scan("_lib");*/
#ifdef DEBUG
	for(i=0;i<incount;i++)
	{
		printf("file:%s\n",ins[i].inputname);
		printf(" CODE=%08lx,BSS=%08lx\n",ins[i].codelen,ins[i].bsslen);
	}
#endif
	unresolved=0;
	for(i=0;i<256;i++)
	{
		if(d=headers[i])
			while(d)
			{
				if(d->deftype==UNDEF)
					missing(d->deftext);
				d=d->defnext;
			}
	}
	if(unresolved) goto abort;
	if(!incount || !hunkcount) {printf("Nothing to do\n");goto abort;}

	for(i=0;i<MAXBANKS;++i)
		maxcode[i]=0;
	hunkmax=hunkcount;

	err=0;
	for(i=0;i<hunkmax;i++)
	{
		j=hunks[i].bank&MAXBANKS-1;
		hunks[i].codedelta=maxcode[j] | (j ? 0x4000 : 0);
		maxcode[j]+=hunks[i].codelen;
		if(maxcode[j]>0x4000)
		{
			printf("Overflowed bank $%02x\n",j);
			err=1;
		}
	}
	if(err) goto abort;

	outfile=open(outputname,O_WRONLY|O_BINARY|O_TRUNC|O_CREAT,0644);
	if(outfile<0) {printf("Cannot open output file %s\n",outputname);goto abort;}

	hunkcount=0;
	for(i=0;i<incount;i++) fix(i);
	i=(maxbank+1)*0x4000;
	j=0x8000;
	while(j<i) j<<=1;
	j=j/0x4000;
	while(maxbank+1<j)
	{
		++maxbank;
		memset(outbuff+maxbank*0x4000,0xff,0x4000);
	}
	fixcart();
	res=write(outfile,outbuff,(maxbank+1)*0x4000);res=res;
	close(outfile);
	dosymbols();

#ifdef DEBUG
	for(i=0;i<256;i++)
		if(d=headers[i])
			while(d)
			{
				printf("%08lx ",ins[d->defhunk].codedelta+d->defoffset);
				printf(d->deftext);
				putchar('\n');
/*				t1=d->defuse;
				while(t1)
				{
					printf(" %d:%08lx",t1->usehunk,t1->useoffset);
					t1=t1->usenext;
				}
				putchar('\n');*/
				d=d->defnext;
			}
#endif

abort:
	if(options['u'])
	{
		printf("%08lx Memory used for data\n",datapoint-datablock);
	}
	freestuff();
	exit(0);
}

struct symboldump
{
	int32_t val;
	char *name;
};
#define MAXSYMBOLDUMP 65536

int symboldumpcomp(const void *s1,const void *s2)
{
	return ((struct symboldump *)s1)->val - ((struct symboldump *)s2)->val;
}
void dosymbols(void)
{
	int i;
	int base;
	uchar type,num;
	int count;
	struct define *d,*od;
	int bank;
	struct symboldump *sd;
	char mapname[128];
	FILE *f;
	int lastbank;

	strcpy(mapname,outputname);
	cliptail(mapname,".gb");
	strcat(mapname,".map");
	f=fopen(mapname,"w");
	if(!f) {printf("Could not open %s map file\n",mapname);return;}

	sd=malloc(MAXSYMBOLDUMP*sizeof(struct symboldump));
	if(!sd) {fclose(f);printf("No memory for symbol dump\n");return;}
	count=0;


	for(i=0;i<256;i++)
	{
		d=headers[i];
		while(d)
		{
			od=d;
			d=d->defnext;
			type=od->deftype;
			num=od->defhunk;
			if(type==CODE)
			{
				base=hunks[num].codedelta;
				bank=hunks[num].bank;
			} else if(type==BSS) bank=base=0;
			else continue;
			base+=od->defoffset;
			if(count<MAXSYMBOLDUMP)
			{
				sd[count].val=(bank<<16)|(base&0xffff);
				sd[count].name=od->deftext;
				++count;
			}
//printf("%02x:%04x %s\n",bank,base,od->deftext);
		}
	}
	while(symhead)
	{
		if(!finddef(symhead->symtext))
		{
			bank=hunks[symhead->symhunk].bank;
			base=symhead->symval+hunks[symhead->symhunk].codedelta;
			if(count<MAXSYMBOLDUMP)
			{
				sd[count].val=(bank<<16)|(base&0xffff);
				sd[count].name=symhead->symtext;
				++count;
			}
		}
		symhead=symhead->symnext;
	}
	qsort(sd,count,sizeof(struct symboldump),symboldumpcomp);
	lastbank=-1;
	for(i=0;i<count;++i)
	{
		base=sd[i].val;
		bank=base>>16;
		base&=0xffff;
		if(bank!=lastbank)
		{
			lastbank=bank;
			fprintf(f,"Bank #%d:\n",bank);
		}
		fprintf(f," $%04x = %s\n",base,sd[i].name);
	}
	free(sd);
	fclose(f);
}

#define FILEMAX 4096
void handlefile(uchar *str) {
int file;
uchar filearea[FILEMAX+1];
int len;
uchar name[256],ch,*p,*p2;

	file=open(str,O_RDONLY);
	if(file<0)
	{
		printf("Cannot open parameter file %s\n",str);
		return;
	}
	len=read(file,filearea,FILEMAX);
	close(file);
	filearea[len]=0;
	if(len==FILEMAX)
		printf("Parameter file %s truncated to %d bytes\n",str,FILEMAX);
	p=filearea;
	for(;;)
	{
		while((ch=*p) && (ch==' ' || ch==13 || ch==10 || ch==9)) p++;
		if(!*p) break;
		p2=name;
		while((ch=*p) && ch!=' ' && ch!=13 && ch!=10 && ch!=9) *p2++=*p++;
		*p2=0;
		addname(name);
	}
}


int scan(uchar *str) {
	uint32_t v1,v2,v3;
	int t,type;
	struct use *t2;
	int htype;
	int hashval;
	struct define *def1;
	uchar iname[256];
	uchar *pntr,*p2;
	uchar namecopy[64];
	int filelen;
	struct define *adef;
	struct sym *asym;
	struct use *ause;
	int thishunk;
	int thisfile;
	int i,j;
	int currentbank;
	int res;

	i=strlen(str);
	if(i>strlen(OBJEXTENSION) && !strcmp(str+i-strlen(OBJEXTENSION),OBJEXTENSION))
		strcpy(namecopy,str);
	else
		sprintf(namecopy,"%s%s",str,OBJEXTENSION);
	strcpy(ins[incount].inputname,namecopy);
	thisfile=incount;

	infile=open(namecopy,O_RDONLY|O_BINARY);
	if(infile<0)
	{
		for(i=0;i<dirnum;i++)
		{
			sprintf(iname,"%s/%s",dirnames[i],namecopy);
			infile=open(iname,O_RDONLY|O_BINARY);
			if(infile>=0)
				break;
		}
		if(infile<0)
		{
			printf("Unable to open file %s\n",namecopy);
			return 1;
		}
		strcpy(ins[incount].inputname,iname);
	}

	filelen=lseek(infile,0L,2);
	lseek(infile,0L,0);
	filepoint=malloc(filelen+4);
	if(!filepoint) nomem();
	ins[incount].inputloc=filepoint;
	pntr=filepoint;
	res=read(infile,pntr,filelen);res=res;
	*(int32_t *)(pntr+filelen)=0xffffffffL;
	close(infile);
	incount++;

	currentbank=0;
	for(;;)
	{
		v1=readlong();
		switch((int)v1)
		{
		case 0x3f3:
			printf("Cannot link executable %s\n",str);
			return 2;
		case	HUNK_BSS: /* hunk_bss */
			thishunk=hunkcount++;
			htype=BSS;
			hunks[thishunk].codelen=0;
			hunks[thishunk].bsslen=readlong()*4L;
			break;
		case HUNK_END: /* hunk_end */
			break;
		case HUNK_NAME: /* hunk_name */
			symbol(readlong());
			sscanf(scr1,"%x",&currentbank);
			currentbank&=MAXBANKS-1;
			if(currentbank>maxbank) maxbank=currentbank;
			break;
		case 0x3ea: /* hunk_data */
		case HUNK_CODE: /* hunk_code */
			thishunk=hunkcount++;
			htype=CODE;
			v1=readlong();
			hunks[thishunk].codelen=v1<<2;
			hunks[thishunk].bsslen=0;
			hunks[thishunk].bank=currentbank;
			skip(v1);
			break;
		case 0x3cd: /* hunk_16reloc */
		case 0x3cc: /* hunk_32reloc */
		case 0x3ed: /* hunk_reloc16 */
		case 0x3ec: /* hunk_reloc32 */
			while(v1=readlong()) skip(v1+1);
			break;
		case 0x3f0: /* hunk_symbol */
			while(v1=readlong())
			{
				symbol((int)v1);
				asym=newsym();
				asym->symnext=symhead;
				asym->symtext=addtext(scr1);
				asym->symval=readlong();
				asym->symhunk=thishunk;
				symhead=asym;
			}
			break;
		case	0x3f1: /* hunk_debug */
			v1=readlong(); skip(v1);
			break;
		case 0x3e7: /* hunk_unit */
			if(v1=readlong()) skip(v1);
			break;
		case 0x3ef: /* hunk_ext */
			while(v1=readlong())
			{
				type=(uint32_t)v1>>24L;
				v1&=0xffffffL;
				symbol((int)v1);
				switch(type)
				{
				case 1: /* def */
					v1=readlong();
					def1=finddef(scr1);
					if(def1)
					{
						if(def1->deftype==UNDEF)
						{
							def1->defoffset=v1;
							def1->defhunk=thishunk;
							def1->deftype=htype;
						}
						else
							if(options['m'] || multflag) printf("Multiply defined symbol %s\n",scr1);
					}
					else
					{
						hashval=hash8(scr1);
						adef=newdef();
						adef->defnext=headers[hashval];
						headers[hashval]=adef;
						adef->deftext=addtext(scr1);
						adef->deftype=htype;
						adef->defhunk=thishunk;
						adef->defoffset=v1;
						adef->defuse=0;
					}
					break;
				case 0x91: /* 32ref */
				case 0x93: /* 16ref */
				case 0x99: /* 32rel */
				case 0x9b: /* 16rel */
				case 0x81: /* ref32 129 */
				case 0x83: /* ref16 131 */
				case 0x8b: /* rel16 139 was 140?? */
				case LINKLOW8:
				case LINKHIGH8:
				case LINKBANK8:
				case LINK16NREF:
					def1=finddef(scr1);
					if(!def1)
					{
						def1=newdef();
						hashval=hash8(scr1);
						def1->defnext=headers[hashval];
						headers[hashval]=def1;
						def1->deftext=addtext(scr1);
						def1->deftype=UNDEF;
						def1->defuse=0;
					}
					t=readlong();
					t2=def1->defuse;
					while(t--)
					{
						ause=newuse();
						ause->usenext=t2;
						t2=ause;
						ause->usetype=type;
						ause->usehunk=thishunk;
						ause->useoffset=readlong();
					}
					def1->defuse=t2;
					break;
				}
			}
			break;
		default:
			if(v1==0xffffffffL) return 0;
			printf("Unknown code %08x in file %s\n",
				v1,ins[thisfile].inputname);
			return 1;
		}
	}
}
struct define *predef(uchar *name,int32_t value)
{
int hashval;
struct define *adef;

	hashval=hash8(name);
	adef=newdef();
	adef->defnext=headers[hashval];
	headers[hashval]=adef;
	adef->deftext=addtext(name);
	adef->deftype=1;
	adef->defhunk=0;
	adef->defoffset=value;
	adef->defuse=0;
	return adef;
}


int fix(int which) {
	int v1,v2,v3;
	int htype,t;
	uchar *p;
	int thishunk;
	int starthunk;

	starthunk=hunkcount;
	filepoint=ins[which].inputloc;
	for(;;)
	{
		v1=readlong();
		switch((int)v1)
		{
		case	HUNK_BSS: /* hunk_bss */
			thishunk=hunkcount++;
			htype=BSS;
			readlong();
			break;
		case HUNK_END: /* hunk_end */
			if(htype==CODE)
			{
				v1=hunks[thishunk].codelen;
				memcpy(outbuff+hunks[thishunk].bank*0x4000+
					(hunks[thishunk].codedelta&0x3fff),codeloc,v1);
			}
			break;
		case HUNK_NAME: /* hunk_name */
			skip(readlong());
			break;
		case 0x3ea: /* hunk_data */
		case HUNK_CODE: /* hunk_code */
			thishunk=hunkcount++;
			htype=CODE;
			v1=readlong();
			codeloc=filepoint;
			filepoint+=v1<<2;
			patch(thishunk,which);
			break;
		case 0x3cd: /* hunk_16reloc */
			while(v1=readlong())
			{
				v2=readlong();
				v2=hunks[starthunk+v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					wordp=(void *)(codeloc+v3);
					*wordp+=v2;
				}
			}
			break;
		case 0x3ed: /* hunk_reloc16 */
			while(v1=readlong())
			{
				v2=readlong();
				v2=hunks[starthunk+v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					wordp=(void *)(codeloc+v3);
					*wordp=revword(revword(*wordp)+v2);
				}
			}
			break;
		case 0x3cc: /* hunk_32reloc */
			while(v1=readlong())
			{
				v2=readlong();
				v2=hunks[starthunk+v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					longp=(void *)(codeloc+v3);
					*longp+=v2;
				}
			}
			break;
		case 0x3ec: /* hunk_reloc32 */
			while(v1=readlong())
			{
				v2=readlong();
				v2=hunks[starthunk+v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					longp=(void *)(codeloc+v3);
					*longp=revlong(revlong(*longp)+v2);
				}
			}
			break;
		case 0x3f0: /* hunk_symbol */
			while(v1=readlong()) skip(v1+1);
			break;
		case	0x3f1: /* hunk_debug */
			v1=readlong(); skip(v1);
			break;
		case 0x3e7: /* hunk_unit */
			if(v1=readlong()) skip(v1);
			break;
		case 0x3ef: /* hunk_ext */
			while(v1=readlong())
			{
				t=(uint32_t)v1>>24;
				v1&=0xffffff;
				skip(v1);
				switch(t)
				{
				case 1: /* def */
				case 2:
				case 3:
					readlong();
					break;
				case 0x81: /* ref32 129 */
				case 0x83: /* ref16 131 */
				case 0x84: /* ref8 132 */
				case 0x8b: /* rel16 140 */
				case 0x91: /* 32ref */
				case 0x93: /* 16ref */
				case 0x99: /* 32rel */
				case 0x9b: /* 16rel */
				default:
					v1=readlong();
					skip(v1);
					break;
				}
			}
			break;
		default:
			if(v1==0xffffffffL) return 0;
			return 1;
		}
	}
}

void rangeerr(int num, int loc, struct define *def) {
	printf("Range error in %s,offset %x, symbol=%s\n",
		ins[num].inputname,loc,def->deftext);
}

void patch(int thishunk,int num)
{
	int i,t,n;
	struct define *d;
	int loc;
	int dest,t2;
	struct use *t1;
	int thishunkbase;
	int bank;

	for(i=0;i<256;i++)
		if(d=headers[i])
			while(d)
			{
				n=d->defhunk;
				t=d->deftype;
				if(t==CODE) dest=hunks[n].codedelta;
				else if(t==BSS) dest=0;
				else continue;
				thishunkbase=hunks[thishunk].codedelta;
				dest+=d->defoffset;
				bank=hunks[n].bank;

				t1=d->defuse;
				while(t1)
				{
					if(t1->usehunk==thishunk)
					{
						loc=t1->useoffset;
						t=t1->usetype;
						switch(t)
						{
						case 0x91: /* 32ref */
							longp=(void *)(codeloc+loc);
							*longp+=dest;
							break;
						case 0x93: /* 16ref */
							wordp=(void *)(codeloc+loc);
							t2=(unsigned)*wordp+dest;
							if(t2<0 || t2>0xffffL)
								rangeerr(num,loc,d);
							*wordp=t2;
							break;
						case 0x99: /* 32rel */
							longp=(void *)(codeloc+loc);
							*longp+=dest-thishunkbase;
							break;
						case 0x9b: /* 16rel */
							wordp=(void *)(codeloc+loc);
							t2=*wordp+dest-thishunkbase;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=t2;
							break;
						case 0x81: /* ref32 */
							longp=(void *)(codeloc+loc);
							*longp=revlong(revlong(*longp)+dest);
							break;
						case 0x83: /* ref16 */
							wordp=(void *)(codeloc+loc);
							t2=revword(*wordp)+dest;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=revword((short)t2);
							break;
						case 0x8b: /* rel16 was 8c??? */
							wordp=(void *)(codeloc+loc);
							t2=revword(*wordp)+dest-loc-thishunkbase;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=revword((short)t2);
							break;
						case LINKLOW8:
							bytep=(void *)(codeloc+loc);
							*bytep+=dest&255;
							break;
						case LINKHIGH8:
							bytep=(void *)(codeloc+loc);
							*bytep+=(dest>>8)&255;
							break;
						case LINKBANK8:
							bytep=(void *)(codeloc+loc);
							*bytep+=bank&255;
							break;
						case LINK16NREF:
							wordp=(void *)(codeloc+loc);
							t2=(unsigned)*wordp-dest;
/*
							if(t2<0 || t2>0xffffL)
								rangeerr(num,loc,d);
*/
							*wordp=t2;
							break;
						}
					}
					t1=t1->usenext;
				}
				d=d->defnext;
			}
}

unsigned char NintendoChar[48]=
{
	0xCE,0xED,0x66,0x66,0xCC,0x0D,0x00,0x0B,0x03,0x73,0x00,0x83,0x00,0x0C,0x00,0x0D,
	0x00,0x08,0x11,0x1F,0x88,0x89,0x00,0x0E,0xDC,0xCC,0x6E,0xE6,0xDD,0xDD,0xD9,0x99,
	0xBB,0xBB,0x67,0x63,0x6E,0x0E,0xEC,0xCC,0xDD,0xDC,0x99,0x9F,0xBB,0xB9,0x33,0x3E
};

void fixcart(void)
{
	int i, byteschanged=0;
	int cartromsize, calcromsize=0, filesize;
	int carttype;
	unsigned short cartchecksum=0, calcchecksum=0;
	unsigned char cartcompchecksum=0, calccompchecksum=0;
	int ch;
	unsigned char *take;

	/* Nintendo Character Area */

	filesize=(maxbank+1)*0x4000;

	take=outbuff+0x104;

	memcpy(take,NintendoChar,48);


	/* ROM size */

	take=outbuff+0x148;

	while( filesize>(0x8000L<<calcromsize) )
		calcromsize+=1;

	*take++=calcromsize;

	/* Cartridge type */

	take=outbuff+0x147;

/*(DA)???	if( filesize>0x8000L )
		*take=1;
*/
	take=outbuff;

	for( i=0; i<filesize; ++i )
	{
		ch=*take++;
		if( i<0x0134L )
			calcchecksum+=ch;
		else if( i<0x014DL )
		{
			calccompchecksum+=ch;
			calcchecksum+=ch;
		}
		else if( i==0x014DL )
			cartcompchecksum=ch;
		else if( i==0x014EL )
			cartchecksum=ch<<8;
		else if( i==0x014FL )
			cartchecksum|=ch;
		else
			calcchecksum+=ch;
	}

	calccompchecksum=0xE7-calccompchecksum;
	calcchecksum+=calccompchecksum;

	outbuff[0x14e]=calcchecksum>>8;
	outbuff[0x14f]=calcchecksum;
	outbuff[0x14d]=calccompchecksum;

}
