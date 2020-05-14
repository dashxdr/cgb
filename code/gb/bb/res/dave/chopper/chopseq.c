/*
This program generates the chopper ASM trigger file choptrig.asm.

3 stages per difficulty
5 difficulty levels
4 varieties of each
= 60 lists

Index=rand(4)*15+difficulty*3+stage

Each line of a list is
1 byte cycles to next entry (can be 0), 255=endmark
1 byte type 0-5 (LOW1234,MED24,MED1234,HIGH24,HI1234,VHIGH24)
1 byte rate 0-64 (64=fastest)

input parameters to set difficulty are:
# of logs in each stage
safe zone around each landing
time in seconds for each stage
min rate
max rate
allowed bounce sequences, string of digits 1-6


*/

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define OUTPUTNAME "choptrig.asm"
#define INPUTNAME  "choptrig.txt"

#define MAXTIME 2048
#define FRAMESPERSECOND 20

#ifndef O_BINARY
#define O_BINARY 0
#endif

unsigned char criticals[]=
{
9-1,17-1,25-1,33-1,
0,54-42,0,66-42,
89-73,105-73,121-73,137-73,
0,172-154,0,190-154,
220-200,240-200,260-200,280-200,
0,325-301,0,349-301,
};

unsigned char lens[]=
{
41-1,
72-42,
153-73,
199-154,
300-200,
361-301
};

FILE *ofile,*ifile;

unsigned char *timeline,*timeline2,*outblock,*outblockp;
unsigned char cycledata[1024];
struct event
{
	int start;
	int rate;
	int type;
} events[512];

void markhitany(int safe,int start,int type,int rate,unsigned char *time)
{
int i,j,k,index;

	type<<=2;
	for(i=0;i<4;++i)
	{
		k=criticals[type+i];
		if(!k) continue;
		index=start+(k<<6)/rate;
		time[index]=i+1;
/*
		for(j=-safe;j<=safe;++j)
			time[index+j]=i+1;
*/
	}
}
void markhit(int safe,int start,int type,int rate)
{
	markhitany(safe,start,type,rate,timeline);
}
void markhit2(int safe,int start,int type,int rate)
{
	markhitany(safe,start,type,rate,timeline2);
}

int checkhit(int safe,int start,int type,int rate)
{
int i,j,k,index;
int diff;
int bad;
	for(i=0;i<4;++i)
	{
		k=criticals[(type<<2)+i];
		if(!k) continue;
		index=start+(k<<6)/rate;
		if(timeline[index])
			return 1;
/*
		for(j=-safe;j<=safe;++j)
			if(timeline[index+j] && timeline[index+j]!=i+1)
				return 1;
*/
	}
	memcpy(timeline2,timeline,MAXTIME);
	markhit2(safe,start,type,rate);
	j=-1;
	bad=0;
	for(i=0;i<MAXTIME;++i)
	{
		if(!timeline2[i]) continue;
		k=j;
		j=i;
		if(k<0) continue;
		diff=timeline2[j]-timeline2[k];
//		if(!diff) continue;
		if(diff<0) diff=-diff;
if(!diff) diff=1;
		if(j-k<safe*diff) bad=1;
	}
	return bad;
}

int compev(const void *e1,const void *e2)
{
	return ((struct event *)e1)->start-((struct event *)e2)->start;
}


void makecycle(int safe,int numlogs,int stagetime,int minrate,int maxrate,int mask)
{
int i,j,k,start,rate,type;
unsigned char *put,*take;
struct event *ev;
int tries1,tries2;
int stagetimefix;
int counts[16];

	stagetimefix=stagetime*FRAMESPERSECOND;
	tries2=500;
top:
	memset(counts,0,sizeof(counts));
	j=0;
	k=mask;
	i=numlogs;
	while(i)
	{
		while(!(k&1))
		{
			k>>=1;
			++j;
			if(!k)
			{
				j=0;
				k=mask;
			}
		}
		++counts[j];
		--i;
		k>>=1;
		++j;
	}
	ev=events;
	memset(timeline,0,MAXTIME);
	for(i=0;i<numlogs;++i)
	{
		tries1=500;
		while(tries1)
		{
			--tries1;
			#ifdef _WIN32
			start=rand()%stagetimefix;
			#else
			start=random()%stagetimefix;
			#endif
			for(type=0;type<16;++type)
				if(counts[type]) break;
			if(type==16) {printf("Critical error\n");exit(1);}
/*			for(;;)
			{
				type=random()%6;
				if(mask & (1<<type)) break;
			}
*/
			if(maxrate-minrate)
				#ifdef _WIN32
				rate=rand()%(maxrate-minrate)+minrate;
				#else
				rate=random()%(maxrate-minrate)+minrate;
				#endif
			else
				rate=minrate;
			if(start+(lens[type]<<6)/rate>stagetimefix) continue;
//printf("valid=%d %d %d\n",start,type,rate);
			if(!checkhit(safe,start,type,rate))
			{
				--counts[type];
				break;
			}
		}
		if(!tries1)
		{
			--tries2;
			if(tries2) goto top;
			printf("Failed:numlogs=%d,stagetime=%d,safe=%d,minrate=%d,maxrate=%d\n",
				numlogs,stagetime,safe,minrate,maxrate);
			exit(2);
		}
		markhit(safe,start,type,rate);
		ev->type=type;
		ev->start=start;
		ev->rate=rate;
		++ev;
	}
/*
for(i=0;i<2048;++i)
{
	putchar(timeline[i]+'0');
	if(i%64==63) printf("\n");
}
printf("\n");
*/
	i=ev-events;
	qsort(events,i,sizeof(struct event),compev);
	put=cycledata;
	ev=events;
	j=0;
	while(i--)
	{
		start=ev->start;
		rate=ev->rate;
		type=ev->type;
		*put++=start-j;
		j=start;
		*put++=type;
		*put++=rate;
		++ev;
	}
	*cycledata=0;//so cycle begins instantly
	*put++=255;

}

void dumpcycle(int num)
{
unsigned char *take,*p;
int out;
char name[64];
int i,j,k;

	p=outblock+num+num;
	i=outblockp-p-1;
	*p++=i;
	*p=i>>8;
	take=cycledata;
	while(*take!=255)
	{
		memcpy(outblockp,take,3);
		take+=3;
		outblockp+=3;
	}
	*outblockp++=*take;


/*
	sprintf(name,"CHOP%02d.bin",num);
	out=open(name,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,0644);
	if(out<0)
	{
		printf("Could not open %s file for output\n",name);
		return;
	}
	take=cycledata;
	while(*take!=255)
	{
		write(out,take,3);
		take+=3;
	}
	write(out,take,1);
	close(out);
*/
/*
	fprintf(ofile,"chopblock%d:\n",num);
	take=cycledata;
	while(*take!=255)
	{
		fprintf(ofile,"\t\tdb\t%d,%d,%d\n",*take,take[1],take[2]);
		take+=3;
	}
	fprintf(ofile,"\t\tdb\t255\n");
*/
}


//Rate minimums, value 1-64, 64 = fastest at 1 anim step per cycle
int mins[15];

//Rate maximums, value 1-64, 64 = fastest at 1 anim step per cycle
int maxs[15];

//Number of logs to place in each cycle
int nums[15];

//Number of safe steps around each log bounce (higher=easier)
int safes[15];

//Stage times in seconds
int times[15];

//Allowed bounce masks
int masks[15];


void _getline(char *line)
{
int ch;

	while((ch=fgetc(ifile))!=EOF)
	{
		if(ch=='\n') break;
		*line++=ch;
	}
	*line=0;
}


#define NUMDUPS 4

int main(int argc, char **argv)
{
int stage,difficulty,version;
int i,j,k,index,id,t1;
char aline[1024];
int linecount;

	timeline=malloc(MAXTIME);
	timeline2=malloc(MAXTIME);
	outblock=malloc(4096);
	if(!timeline || !timeline2 || !outblock)
	{
		printf("No memory!\n");
		exit(1);
	}
	memset(outblock,0,sizeof(outblock));
	outblockp=outblock+NUMDUPS*15*2;
/*
	ofile=fopen(OUTPUTNAME,"w");
	if(!ofile)
	{
		printf("Couldn't open %s for output\n",OUTPUTNAME);
		exit(3);
	}
*/
	ifile=fopen(INPUTNAME,"r");
	if(!ifile)
	{
		printf("Couldn't open %s for input\n",INPUTNAME);
		exit(4);
	}
	j=0;
	for(i=0;i<15;)
	{
		_getline(aline);
		++j;
		if(!aline[0]) break;
		if(aline[0]=='#') continue;
		k=sscanf(aline,"%d,%d,%d,%d,%d,%d",
			nums+i,times+i,safes+i,mins+i,maxs+i,&t1);
		if(k<6)
		{
			printf("Short line, not enough values, %d\n",j);
			continue;
		}
		masks[i]=0;
		while(t1)
		{
			masks[i]|=1<< t1%10-1;
			t1/=10;
		}
		++i;
	}
	if(i<15)
	{
		printf("Could only get %d valid lines from input file\n", i);
		exit(5);
	}

	for(version=0;version<NUMDUPS;++version)
	{
		for(difficulty=0;difficulty<5;++difficulty)
		{
			for(stage=0;stage<3;++stage)
			{
				index=difficulty*3+stage;
				id=version*15+index;
				makecycle(safes[index],nums[index],times[index],
						mins[index],maxs[index],masks[index]);
				dumpcycle(id);
			}
		}
	}
	i=open("chopdat.bin",O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(i<0)
	{
		printf("Could not open output file\n");
		exit(7);
	}
	int res=write(i,outblock,outblockp-outblock);res=res;
	close(i);
/*
	fprintf(ofile,"choptrig:\n");
	for(i=0;i<60;++i)
	{
		fprintf(ofile,"\t\tdw\tchopblock%d\n",i);
	}
	close(ofile);
*/
	return 0;
}
