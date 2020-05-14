#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

#define MAXFILE 65536

#define DEB 0


char *fileblock;
char *take,*ltake;

int primary[1024],alternate[1024];
int order[1024];

int _getline(char *put) {
	char *p;
	p=put;
	while(*take && *take!='\n')
		*p++=*take++;
	if(*take) ++take;
	*p=0;
	return *put || *take;
}

char atoken[64];

int token(void) {
	char *p,ch;
	p=atoken;
	while((ch=tolower(*ltake)))
	{
		++ltake;
		if(ch==' ' || ch=='\t') break;
		*p++=ch;
	}
	*p=0;
	while(*ltake && (*ltake==' ' || *ltake=='\t')) ++ltake;
	return *atoken;
}

void massiveerror(void)
{
	printf("Serious error, probably your input file is screwed up, James.\n");
	exit(5);
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
"SQR_END" // 16
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
struct item
{
	int sqr;
	char type;// 1=normal path, <0=shortcut
	int x,y;
	int nextx,nexty;
	int altx,alty;
} items[1024];
int itemcount;


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
void outline(int id,int x,int y,int type,int dest1,int dest2) {
	if(id>maxid) maxid=id;
	entries[id].x=x;
	entries[id].y=y;
	entries[id].type=type;
	entries[id].dest1=dest1;
	entries[id].dest2=dest2;
}

void flush2(void) {
	int i,j;
	struct entry *e;
	char line[128],*p;
	int dest1,dest2;
	int found;

	for(i=1;i<=maxid;++i)
	{
		p=line;
		found=-1;
		for(j=1;j<i;++j)
			if(entries[j].dest1==i || entries[j].dest2==i)
				found=j;
		if(found<0) found=1; // start < start
		e=entries+i;
		dest1=e->dest1;
		dest2=e->dest2;
		if(e->type==16) dest1=i; // end -> end
		sprintf(p,"%d,%d,%d,%d,",e->x,e->y,dest1,dest2);
		p+=strlen(p);
		sprintf(p,"%s,%d,",jlist[e->type],found);
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
int search(int it,int *cnt,int type)
{
int x,y;
int i,j;

	if(it==0) return -1;
	x=items[it].x;
	y=items[it].y;
	while(*cnt<itemcount)
	{
		i=(*cnt)++;
		j=items[i].type;
		if(items[i].altx==x && items[i].alty==y && type<0)
			return i;
		if(items[i].nextx!=x || items[i].nexty!=y) continue;
		if((j<0 && type>0) || (j>0 && type<0)) continue;
		return i;
	}
	return -1;
}

int unmap(int want,int num) {
	int i;
	if(!want) return 0;
	for(i=0;i<num;++i)
		if(order[i]==want) return num-i;
	return 0;
}

void flush(void) {
	int i,j,k;
	int active1[50],active2[50],ac1,ac2;
	struct item *it;
	int cnt;
	int num;

	memset(primary,0,sizeof(primary));
	memset(alternate,0,sizeof(alternate));
	ac1=1;
	active1[0]=itemcount-1;
	k=0;
	while(ac1)
	{

		if(ac1>20) massiveerror();
#if DEB
		for(i=0;i<ac1;++i)
			printf(" %3d",active1[i]);
		printf("\n");
getchar();
#endif
		memcpy(active2,active1,ac1*sizeof(int));
		ac2=ac1;
		ac1=0;
		for(i=0;i<ac2;++i)
		{
			num=active2[i];
			it=items+num;
//			if(it->type==-1) continue;
			if(it->sqr>=0)
			{
				order[k++]=num;
			}
			cnt=0;
			while((j=search(num,&cnt,1))>=0)
			{
//printf("pri:%3d->%3d\n",j,num);
				primary[j]=num;
				if(it->type!=-1)
					active1[ac1++]=j;
			}
			cnt=0;
			while((j=search(num,&cnt,-1))>=0)
			{
//printf("alt:%3d->%3d\n",j,num);
				alternate[j]=num;
				if(it->type!=-1)
					active1[ac1++]=j;
			}
		}
	}
	i=k;
	while(i-->0)
	{
		int alt,pri;
		num=order[i];
		it=items+num;
		alt=unmap(alternate[num],k);
		pri=unmap(primary[num],k);
		if(alt && !pri)
		{
			pri=alt;
			alt=0;
		}
/*
		printf("%3d:(%3d,%3d) pri:%3d alt:%3d %s\n",k-i,
			it->x,it->y,pri,alt,jlist[it->sqr]);
*/
//outline(int id,int x,int y,int type,int dest1,int dest2)
		outline(k-i,it->x,it->y,it->sqr,pri,alt);
	}
	flush2();
}


void additem(int x,int y,int sqr,int dir,int type,int alt) {
	int altx,alty;

	if(itemcount==500)
		massiveerror();
	items[itemcount].sqr=sqr;
	items[itemcount].x=x;
	items[itemcount].y=y;
	altx=x;
	alty=y;
	x+=dx[dir];
	y+=dy[dir];
	items[itemcount].nextx=x;
	items[itemcount].nexty=y;
	if(alt>=0)
	{
		altx+=dx[alt];
		alty+=dy[alt];
	} else
		altx=alty=-1;
	items[itemcount].altx=altx;
	items[itemcount].alty=alty;
	items[itemcount].type=type;

#if DEB

printf("%3d:%10s (%3d,%3d) type %3d   (%3d,%3d)  (%3d,%3d)\n",itemcount,
		sqr>=0 ? list1[sqr] : "---",tx,ty,type,x,y,altx,alty);
#endif

	++itemcount;
}

int main(int argc, char *argv[]) {
	int i;
	int infile;
	char line[256];

	int xpos,ypos;
	int xpos2,ypos2;
	int t1,t2,t1x,t2x;
	int lc;
	int sp2;

	itemcount=0;
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
	sp2=0;
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
			sp2=0;
			t2=look(list2);
			additem(xpos,ypos,t1x,t2x,1,t2);
			while(t2>=0)
			{
				xpos2+=dx[t2];
				ypos2+=dy[t2];
				t1=look(list1);
				if(t1<0) break;
				additem(xpos2,ypos2,t1,t2,--sp2,-1);
				t2=look(list2);
			}
			xpos+=dx[t2x];
			ypos+=dy[t2x];
		} else
			printf("Unrecognized keyword line %d\n",lc);
	}
	flush();
}
