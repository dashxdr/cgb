#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define MAXFILE 65536


char *fileblock;
char *take,*ltake;

_getline(char *put)
{
char *p;
	p=put;
	while(*take && *take!='\n')
		*p++=*take++;
	if(*take) ++take;
	*p=0;
	return *put || *take;
}

char atoken[64];

token()
{
char *p,ch;
	p=atoken;
	while(ch=tolower(*ltake))
	{
		++ltake;
		if(ch==' ' || ch=='\t') break;
		*p++=ch;
	}
	*p=0;
	while(*ltake && (*ltake==' ' || *ltake=='\t')) ++ltake;
	return *atoken;
}


char *list2[]=
{
"up",
"down",
"left",
"right",
0
};

int dx[]={0,0,-6,6};
int dy[]={-6,6,0,0};

#define END 16

char *list1[]=
{
"chip",
"beast",
"belle",
"enchantress",
"target",
"cellar",
"stove",
"gaston",
"lucky",
"magic",
"chop",
"match",
"trivia",
"sultan",
"star",
"start",
"end",
0
};

char *jlist[]=
{
"SQR_CHIP",
"SQR_BEAST",
"SQR_BELLE",
"SQR_LUCKY",
"SQR_LEFOU",
"SQR_LUMIR",
"SQR_POTTS",
"SQR_GASTN",
"SQR_LUCKY",
"SQR_MIRRO",
"SQR_POPPA",
"SQR_DOORS",
"SQR_COGGS",
"SQR_SULTN",
"SQR_STAR",
"SQR_START",
"SQR_END"
};

int look(char **list)
{
int num;
int match;
int matchrate;
int i;

	token();
	match=-1;
	matchrate=0;
	num=0;
	while(list[num])
	{
		i=0;
		while(list[num][i]==tolower(atoken[i]))
		{
			if(!atoken[i]) break;
			++i;
		}
		if(i>matchrate && !atoken[i])
		{
			match=num;
			matchrate=i;
		}
		++num;
	}
	return match;
}
struct entry
{
	int id;
	int x;
	int y;
	int type;
	int dest1;
	int dest2;
} entries[1024];

int maxid=0;
outline(int id,int x,int y,int type,int dest1,int dest2)
{
	if(id>maxid) maxid=id;
	entries[id].x=x;
	entries[id].y=y;
	entries[id].type=type;
	entries[id].dest1=dest1;
	entries[id].dest2=dest2;
}

flush()
{
int i,j;
struct entry *e;
int came;
char line[128],*p;

	for(i=1;i<=maxid;++i)
	{
		p=line;
		for(j=1;j<i;++j)
			if(entries[j].dest1==i || entries[j].dest2==i) break;
		if(j==i) j=i;
		e=entries+i;
		sprintf(p,"%d,%d,%d,%d,",e->x,e->y,e->dest1,e->dest2);
		p+=strlen(p);
		sprintf(p,"%s,%d,%d,",jlist[e->type],j,0);
		p+=strlen(p);
		sprintf(p,"%d,%d",e->x*8/3,e->y*8/6);
		p+=strlen(p);
		if(p-line<=31)
		{
			*p++='\t';
			*p=0;
		}
		printf("\t\tDB\t%s\t;%d\n",line,i);
	}
}

main(int argc, char *argv[])
{
int i,j,k;
int infile;
char line[256];

int xpos,ypos;
int xpos2,ypos2;
int t1,t2,t1x,t2x;
int lc;
int online;
int sp2;
int stack2x[20];
int stack2y[20];
int stack2type[20];
int sp;
int stackx[20];
int stacky[20];
int stacktype[20];
int posnum;

	if(argc<2)
	{
		printf("specify file\n");
		exit(1);
	}
	infile=open(argv[1],O_RDONLY);
	if(infile<0)
	{
		printf("Can't open %s\n",argv[1]);
		exit(2);
	}
	fileblock=malloc(MAXFILE);
	if(!fileblock)
	{
		printf("No memory\n");
		exit(3);
	}
	i=read(infile,fileblock,MAXFILE-1);
	fileblock[i]=0;
	close(infile);
	take=fileblock;
	lc=0;
	_getline(line);
	++lc;
	if(sscanf(line,"%d,%d",&xpos,&ypos)!=2)
	{
		printf("Syntax error first line, should have X,Y coord\n");
		exit(3);
	}
	sp=sp2=0;
	posnum=1;
	while(_getline(line))
	{
		++lc;
		ltake=line;
		if((t1x=look(list1))>=0)
		{
			t2x=look(list2);
			if(t2x<0)
			{
				printf("Parse error line %d\n",lc);
				break;
			}
			xpos2=xpos;
			ypos2=ypos;
			if(sp2>0 && xpos==stack2x[sp2-1] && ypos==stack2y[sp2-1])
			{
				outline(posnum,stackx[0],stacky[0],stacktype[0],posnum+1,posnum+sp-sp2+1);
				++posnum;
				for(i=1;i<sp-sp2;++i)
				{
					outline(posnum,stackx[i],stacky[i],stacktype[i],
						posnum+1,0);
					++posnum;
				}
				for(i=0;i<sp2;++i)
				{
					j=i+sp-sp2;
					outline(posnum,stackx[j],stacky[j],stacktype[j],
						i==sp2-1 ? posnum+1 : posnum+2,0);
					++posnum;
					if(i==sp2-1) continue;
					outline(posnum,stack2x[i],stack2y[i],stack2type[i],
						posnum+2,0);
					++posnum;
				}
				sp=sp2=0;
			}
			while((t2=look(list2))>=0)
			{
				xpos2+=dx[t2];
				ypos2+=dy[t2];
				stack2x[sp2]=xpos2;
				stack2y[sp2]=ypos2;
				stack2type[sp2]=t1=look(list1);
				++sp2;
				if(t1<0) break;
			}
			if(!sp2)
			{
				outline(posnum,xpos,ypos,t1x,
					t1x!=END ? posnum+1 :posnum,0);
				++posnum;
			} else
			{
				stackx[sp]=xpos;
				stacky[sp]=ypos;
				stacktype[sp]=t1x;
				++sp;
			}
			xpos+=dx[t2x];
			ypos+=dy[t2x];
		} else
			printf("Unrecognized keyword line %d\n",lc);
	}
	flush();
}
