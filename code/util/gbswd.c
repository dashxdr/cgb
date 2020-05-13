#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>

#define MAXOVERALL 2048

#define co(x) obuff[ocount++]=x
#define DIRNAME "swd"
#define EXTNAME ".swd"

unsigned char costsize[MAXOVERALL];
unsigned char costdist[MAXOVERALL];

int maxdist,maxsize;
int bestoff,bestlen;
int totalcost;
unsigned char verbose=0;

int ocount;
int ofile;
unsigned char *obuff;

unsigned char bitsin;
unsigned char *lastbyte;
void bitsout(int numbits,int val) {
	int tap;

	tap=1<<(numbits-1);
	while(numbits--)
	{
		if(!(bitsin&7))
		{
			lastbyte=obuff+ocount;
			co(0);
		}
		if(val&tap)
			*lastbyte|=1<<(bitsin&7);
		++bitsin;
		tap>>=1;
	}
}

int complook(unsigned char *at,int before,int after) {
	int i,k;
	int ratio,bestratio,cost;

	if(!before) return -1;
	if(!after) return -2;
	bestratio=bestoff=bestlen=0;
	i=1;
	if(before>maxdist) before=maxdist;
	if(after>maxsize) after=maxsize;
	while(i<=before)
	{
		k=0;
		while(k<after)
			if(at[-i+k]!=at[k]) break;
			else k++;
		if(k>1)
		{
			cost=costdist[i-1]+costsize[k];
			if(cost<9*k && (ratio=(k<<16)/cost) > bestratio)
			{
				bestlen=k;
				bestoff=i;
				bestratio=ratio;
			}
		}
		i++;
	}
	if(bestlen>1) return 1;
	return 0;
}
void dumpliteral(unsigned char *from,int len) {
	if(!len) return;
	if(verbose) printf("%5d bits:literal %d:",len*9,len);
	while(len)
	{
	if(verbose) printf(" %02x",from[-len]);
		bitsout(1,0);
		co(from[-len]);
		len--;
	}
	if(verbose) printf("\n");
}
void dumpcopy(void) {
	int t;
	if(bestlen==2)
		bitsout(2,2);
	else if(bestlen>=3 && bestlen<=5)
		bitsout(4,bestlen+10);
	else if(bestlen>=6 && bestlen<=20)
		bitsout(8,bestlen+187);
	else
	{
		bitsout(8,192);
		co(bestlen-20);
	}
	if(bestoff<=0x20)
		bitsout(7,bestoff-1);
	else if(bestoff<=0xa0)
		bitsout(9,0x80 | (bestoff-0x21));
	else if(bestoff<=0x2a0)
	{
		t=bestoff-0xa1;
		bitsout(3,4 | (t>>8));
		co(t);
	}
	else
	{
		t=bestoff-0x2a1;
		bitsout(4,0x0c | (t>>8));
		co(t);
	}
}
int docompress(unsigned char *from,int len) {
	int offset;
	int i;
	int literal;
	int val;

	offset=literal=0;
	totalcost=0;
	bitsin=0;
	while(offset<len)
	{
		val=complook(from+offset,offset,len-offset);
		switch(val)
		{
		case 0: /* couldn't find anything */
		case -1: /* nothing before */
			++offset;
			++literal;
			totalcost+=9;
			break;
		case -2: /* nothing after */
			break;
		default:
			dumpliteral(from+offset,literal);
			literal=0;
			i=costdist[bestoff-1]+costsize[bestlen];
			totalcost+=i;
			if(verbose) printf("%5d bits:Copy:(%d) %d bytes\n",i,-bestoff,bestlen);
			offset+=bestlen;
			dumpcopy();
			break;
		}
	}
	dumpliteral(from+offset,literal);
	bitsout(8,192);
	co(0);
	return 2+((totalcost+7)>>3);
}
void initswd(void) {
	int i;
	for(i=0;i<MAXOVERALL;++i)
	{
		if(i==2) costsize[i]=2;
		else if(i>=3 && i<=5) costsize[i]=4;
		else	if(i>=6 && i<=20) costsize[i]=8;
		else costsize[i]=16;
		if(i<0x20) costdist[i]=7;
		else if(i<0xa0) costdist[i]=9;
		else if(i<0x2a0) costdist[i]=11;
		else costdist[i]=12;
	}
	maxdist=0x6a0;
	maxsize=256;
}


void helptext(char *name) {
	printf("%s [options ...] <file to compress> ...\n",name);
	printf("   -d  = put files in swd directory\n");
	printf("   -h  = include header (long word of uncompressed length)\n");
	printf("   -ba = For 2k chunked compress .chr data we put 8 byte header:\n");
	printf("         73 57 64 d0 43 48 52 00\n");
	printf("         then 4 byte big endian total length of uncompressed data,\n");
	printf("         Then N+1 32-bit words which are offset << 4 bits and if the LSB\n");
	printf("         is 1 that means there is compressed data at that offset,\n");
	printf("         otherwise the offset is to the end of compressed data\n");
	printf("         Each chunk of compressed data is at most 2K bytes\n");
	exit(-1);
}


int main(int argc,char **argv) {
	int file;
	unsigned char *inputdata, *inputBuffer;
	char *p,ch;
	int inputlen;
	char outname[128];
	char makedirectory,outputheader, chunk2k=0;
	struct stat statbuff;
	int i,res;
	char tb[512];
	int dummy;
	int any = 0;

	initswd();
	if(argc<2) helptext(argv[0]);

	makedirectory=outputheader=0;
	for(i=1;i<argc;++i)
	{
		char *arg = argv[i];
		if(*arg=='-')
		{
			char *p=argv[i]+1;
			if(!strcmp(p, "d"))
				makedirectory=1;
			else if(!strcmp(p, "h"))
				outputheader=1;
			else if(!strcmp(p, "ba")) chunk2k=1;
			else if(!strcmp(p, "n")); // ignore -n
			else if(!strcmp(p, "g")); // ignore -g
			else {
				printf("Unknown option %s\n", arg);
				helptext(argv[0]);
			}
			continue;
		}
		++any;
		file=open(arg,O_RDONLY);
		if(file<0) {printf("couldn't open %s\n",arg);return -1;}
		inputlen=lseek(file,0,2);
		lseek(file,0,0);
		inputBuffer=malloc(inputlen);
		obuff=malloc((inputlen*9>>3)+50);
		if(!inputBuffer || !obuff)
		{
			printf("Not enough memory\n");
			return 2;
		}
		inputdata = inputBuffer;
		dummy=read(file,inputdata,inputlen);dummy=dummy;
		close(file);
		if(!makedirectory)
		{
			strcpy(outname,arg);
			p=outname+strlen(outname);
			while(p>outname)
			{
				ch=*--p;
				if(ch=='.') {*p=0;break;}
				if(ch=='/' || ch==':') break;
			}
			strcat(outname,EXTNAME);
		}
		else
		{
			if(stat(DIRNAME,&statbuff))
			{
				if(mkdir(DIRNAME,00755))
				{
					printf("Could not make directory %s\n",DIRNAME);
					return 3;
				}
			} else
				if(!S_ISDIR(statbuff.st_mode))
				{
					printf("%s is not a directory\n",DIRNAME);
					return 4;
				}
			sprintf(outname,"%s/%s",DIRNAME,arg);
		}
		ofile=creat(outname,0644);
		if(ofile<0)
		{
			printf("Couldn't create %s\n",outname);
			return 3;
		}
		void be32(char *p, int v) {p[3] = v;p[2] = v>>8;p[1] = v>>16;p[0] = v>>24;}
		void le32(char *p, int v) {p[0] = v;p[1] = v>>8;p[2] = v>>16;p[3] = v>>24;}
		ocount=0;
		if(!chunk2k) {
			res=docompress(inputdata,inputlen);
			if(outputheader)
			{
				le32(tb, inputlen);
				dummy=write(ofile,tb,4);dummy=dummy;
			}
		} else {
			int chunksize = 2048;
			int offsets[50];
			int n = 0;
			unsigned char *end = inputdata + inputlen;
			for(;;) {
				offsets[n++] = ocount;
				if(inputdata>=end) break;
				int chunk = end-inputdata;
				if(chunk>chunksize) chunk=chunksize;
				res = docompress(inputdata, chunk);
				inputdata += chunk;
			}
			char *t = tb;
			*t++ = 0x73; // s
			*t++ = 0x57; // W
			*t++ = 0x64; // d
			*t++ = 0xd0;
			*t++ = 0x43; // C
			*t++ = 0x48; // H
			*t++ = 0x52; // R
			*t++ = 0;
			be32(t, inputlen);
			t+=4;
			int headersize = t-tb + n*4;
			int j;
			for(j=0;j<n;++j) {
				int v = (headersize+offsets[j])<<4;
				if(j<n-1) v|=1;
				be32(t+j*4, v);
			}
			dummy=write(ofile, tb, headersize);dummy=dummy;
		}
		dummy=write(ofile,obuff,ocount);dummy=dummy;
		close(ofile);
		free(inputBuffer);
		free(obuff);
		printf("%s:%d (%d%%)\n",outname,res,res*100/inputlen);
	}
	if(!any) helptext(argv[0]);
	return 0;
}

