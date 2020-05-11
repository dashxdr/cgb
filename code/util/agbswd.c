#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <inttypes.h>
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
uint32_t *obuff;

int bitsin;
uint32_t workinglong;
void bitsout(int numbits,int val)
{
//printf("Writing %d bits:%x\n",numbits,val);
	if(bitsin+numbits<=32)
	{
		workinglong|=val<<bitsin;
		bitsin+=numbits;
	} else
	{
	int t1,t2,t3;
		t1=32-bitsin;
		t3=numbits-t1;
		if(t1)
		{
			t2=val&((1<<t1)-1);
			val>>=t1;
			workinglong|=t2<<bitsin;
		}
		co(workinglong);
		workinglong=val;
		bitsin=t3;
	}
}

int complook(char *at,int before,int after) {
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
void dumpliteral(char *from,int len) {
	if(!len) return;
	if(verbose) printf("%5d bits:literal %d:",len*9,len);
	while(len)
	{
	if(verbose) printf(" %02x",from[-len]);
		bitsout(1,0);
		bitsout(8,from[-len]);
		len--;
	}
	if(verbose) printf("\n");
}
void dumpcopy(void) {
//printf("bestlen=%d\n",bestlen);
	if(bestlen==2)
		bitsout(2,1);
	else if(bestlen>=3 && bestlen<=5)
		{bitsout(2,3);bitsout(2,bestlen-2);}
	else if(bestlen>=6 && bestlen<=20)
		{bitsout(4,3);bitsout(4,bestlen-5);}
	else
		{bitsout(8,3);bitsout(8,bestlen-20);}

	if(bestoff<=0x20)
		{bitsout(2,0);bitsout(5,bestoff-1);}
	else if(bestoff<=0xa0)
		{bitsout(2,1);bitsout(7,bestoff-0x21);}
	else if(bestoff<=0x2a0)
		{bitsout(2,2);bitsout(9,bestoff-0xa1);}
	else
		{bitsout(2,3);bitsout(10,bestoff-0x2a1);}
}
int docompress(char *from,int len)
{
	int offset;
	int i;
	int literal;
	int val;

	offset=literal=0;
	totalcost=0;
	bitsin=0;
	workinglong=0;
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
	bitsout(16,3);
	bitsout(32,0);
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




int main(int argc,char **argv) {
	int file;
	char *inputdata,*p,ch;
	int inputlen;
	char outname[128];
	char makedirectory,outputheader;
	struct stat statbuff;
	int i,res;
	char t4[4];
	int dummy;

	initswd();
	if(argc<2)
	{
		printf("%s [options ...] <file to compress> ...\n",argv[0]);
		printf("   -d = put files in swd directory\n");
		printf("   -h = Don't include header (32 bit word of uncompressed length)\n");
		return 1;
	}
	makedirectory=0;
	outputheader=1;
	for(i=1;i<argc;++i)
	{
		if(*argv[i]=='-')
		{
			if(argv[i][1]=='d')
				makedirectory=1;
			else if(argv[i][1]=='h')
				outputheader=0;
			continue;
		}
		file=open(argv[i],O_RDONLY);
		if(file<0) {printf("couldn't open %s\n",argv[i]);return -1;}
		inputlen=lseek(file,0,2);
		lseek(file,0,0);
		inputdata=malloc(inputlen);
		obuff=malloc((inputlen*9>>3)+50);
		if(!inputdata || !obuff)
		{
			printf("Not enough memory\n");
			return 2;
		}
		dummy=read(file,inputdata,inputlen);dummy=dummy;
		close(file);
		if(!makedirectory)
		{
			strcpy(outname,argv[i]);
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
				if(mkdir(DIRNAME,0700))
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
			sprintf(outname,"%s/%s",DIRNAME,argv[i]);
		}
		ofile=creat(outname,0644);
		if(ofile<0)
		{
			printf("Couldn't create %s\n",outname);
			return 3;
		}
		ocount=0;
		res=docompress(inputdata,inputlen);
		if(outputheader)
		{
			t4[0]=inputlen;
			t4[1]=inputlen>>8;
			t4[2]=inputlen>>16;
			t4[3]=inputlen>>24;
			dummy=write(ofile,t4,4);dummy=dummy;
		}
		dummy=write(ofile,obuff,ocount<<2);dummy=dummy;
		close(ofile);
		free(inputdata);
		free(obuff);
		printf("%s:%d (%d%%)\n",outname,res,res*100/inputlen);
	}
	return 0;
}
