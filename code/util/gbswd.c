#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

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
void bitsout(int numbits,int val)
{
int tap;

	tap=1<<numbits-1;
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

complook(char *at,int before,int after)
{
int i,j,k;
int bestcost,ratio,bestratio,cost;

	if(!before) return -1;
	if(!after) return -2;
	bestratio=bestoff=bestlen=0;
	i=1;
	if(before>maxdist) before=maxdist;
	if(after>maxsize) after=maxsize;
	while(i<=before)
	{
		j=0;k=0;
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
dumpliteral(unsigned char *from,int len)
{
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
dumpcopy()
{
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
		bitsout(9,0x80 | bestoff-0x21);
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
int docompress(char *from,int len)
{
int offset;
int i,j,k;
int literal;
int val;
int out;
	out=offset=literal=0;
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
	return 2+(totalcost+7>>3);
}
initswd()
{
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




main(int argc,char **argv)
{
int file;
char *inputdata,*p,ch;
int inputlen,outputlen;
char outname[128];
char makedirectory,outputheader;
struct stat statbuff;
int i,res;
char t4[4];

	initswd();
	if(argc<2)
	{
		printf("%s [options ...] <file to compress> ...\n",argv[0]);
		printf("   -d = put files in swd directory\n");
		printf("   -h = include header (long word of uncompressed length)\n");
		return 1;
	}
	makedirectory=outputheader=0;
	for(i=1;i<argc;++i)
	{
		if(*argv[i]=='-')
		{
			if(argv[i][1]=='d')
				makedirectory=1;
			else if(argv[i][1]=='h')
				outputheader=1;
			continue;
		}
		file=open(argv[i],O_RDONLY);
		if(file<0) {printf("couldn't open %s\n",argv[i]);return;}
		inputlen=lseek(file,0,2);
		lseek(file,0,0);
		inputdata=malloc(inputlen);
		obuff=malloc((inputlen*9>>3)+50);
		if(!inputdata || !obuff)
		{
			printf("Not enough memory\n");
			return 2;
		}
		read(file,inputdata,inputlen);
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
			write(ofile,t4,4);
		}
		write(ofile,obuff,ocount);
		close(ofile);
		free(inputdata);
		free(obuff);
		printf("%s:%d (%d%%)\n",outname,res,res*100/inputlen);
	}
}
