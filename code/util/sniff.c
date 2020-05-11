#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <net/if.h>
#include <sys/time.h>
#include <sys/wait.h>

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned long U32;

#define TIMESTEP 1000
#define TIMEHISTORY 60

int used[256][TIMEHISTORY];

struct use2 {
unsigned long amount;
int id;
} used2[256];


#define NOBEFORE 9
#define NOAFTER 18
#define TIMEFIX 3600000

unsigned long bytesperday=0,packetsperday=0;

struct iphdr
{
	U8	version;
	U8	tos;
	U16	total_length;
	U16	id;
	U16	fragment_offset;
	U8	ttl;
	U8	protocol;
	U16	check;
	U32	saddr;
	U32	daddr;
};

struct tcphdr
{
	U16	sport;
	U16	dport;
	U32	sequence;
	U32	ack;
	U8	data_offset;
	U8	flags;
	U8	window_size;
	U16	checksum;
	U16	urgent_ponter;
};




long gtime()
{
struct timeval tv;


	gettimeofday(&tv,0);
	return tv.tv_sec*1000+tv.tv_usec/1000;
}

verifytotals()
{
static int maxtime=0;
int nt;
time_t now;
struct tm brokentime;
FILE *statfile;

	time(&now);
	brokentime=*localtime(&now);
	nt=brokentime.tm_sec+60*(brokentime.tm_min+60*brokentime.tm_hour);
//	nt=nt % 10;

	if(maxtime>nt+100)
	{
		statfile=fopen("/tmp/Usage","a");
		if(statfile)
		{
			now-=5;
			fprintf(statfile,"%10d Bytes %10d Packets %s",
				bytesperday,packetsperday,ctime(&now));
			fclose(statfile);
		}
		bytesperday=packetsperday=0;
	}
	maxtime=nt;
}

int u2comp(const void *v1,const void *v2)
{
	return ((struct use2 *)v2)->amount-((struct use2 *)v1)->amount;
}

outputused2()
{
static int maxtime=0;
int nt;
time_t now;
struct tm brokentime;
FILE *statfile;
int i,j;
struct hostent *h;
unsigned char addr[4];
char name[256];

	addr[0]=192;
	addr[1]=168;
	addr[2]=0;

	time(&now);
	brokentime=*localtime(&now);
	nt=brokentime.tm_sec+60*(brokentime.tm_min+60*brokentime.tm_hour);
//	nt=nt % 10;

	if(maxtime>nt+100)
	{
		statfile=fopen("/tmp/People","a");
		if(statfile)
		{
			now-=5;
			fprintf(statfile,"-------- %s",ctime(&now));
			for(i=0;i<256;++i)
				used2[i].id=i;
			qsort(used2,256,sizeof(struct use2),u2comp);
			for(i=0;i<256;++i)
			{
				if(!used2[i].amount) continue;
				j=addr[3]=used2[i].id;
				h=gethostbyaddr(addr,sizeof(addr),AF_INET);
				if(h)
					sprintf(name,"%3d:%s",j&255,h->h_name);
				else
					sprintf(name,"%3d",j&255);
				fprintf(statfile,"%10d %s\n",used2[i].amount,name);
			}
			memset(used2,0,sizeof(used2));

			fclose(statfile);
		}
		bytesperday=packetsperday=0;
	}
	maxtime=nt;
}


int intcomp(const void *v1,const void *v2)
{
	return *(int *)v2-*(int *)v1;
}

char outputbuffer[16384];
int outputsize;

printout()
{
int usedcopy[256];
int i,j,k;
char *p;
int total;
char name[64];
char *w;
int *ip;
int t200;
struct hostent *h;
unsigned char addr[4];

	w=outputbuffer;
	addr[0]=192;
	addr[1]=168;
	addr[2]=0;

	total=0;
	for(i=0;i<256;++i)
	{
		k=0;
		ip=used[i];
		for(j=0;j<TIMEHISTORY;++j)
			k+=*ip++;
		usedcopy[i]=(k<<8) | i;
		total+=k;
	}
	qsort(usedcopy,256,sizeof(int),intcomp);
	t200=total/200;

	*w++=12;
	*w++=27;
	*w++='c';
	for(i=0;i<256;++i)
	{
		j=usedcopy[i];
		if(!(j>>8)) break;
		addr[3]=j;
		h=gethostbyaddr(addr,sizeof(addr),AF_INET);
		if(h)
			sprintf(name,"%3d:%s",j&255,h->h_name);
		else
			sprintf(name,"%3d",j&255);

/*
		p=idmap[j&255];
		if(p) strcpy(name,p);
		else sprintf(name,"%3d",j&255);
*/
		j>>=8;
		sprintf(w,"%3d%%  %7d   %s\r\n",(j*100+t200)/total,j>>1,name);
		w+=strlen(w);
	}
	outputsize=w-outputbuffer;
}




#define MASK 0xffff0000
#define VALUE 0xc0a80000

char message[]="You suck!\n";

senddata(int out,int in)
{
int r;
char buffer[256];
int s;
	while(1)
	{
		r=read(in,buffer,sizeof(buffer));
		if(r>0)
			r=write(out,buffer,r);
	}
	exit(0);
}

#define MAXCONNECTED 20
struct sender
{
	int pid;
	int outfd;

};
struct sender sendlist[MAXCONNECTED];

unsigned char pbuffer[65536];

main()
{
int sock;
struct sockaddr_in myaddr,otheraddr;
int otherlen;
int out;
int r;
char buffer[50];
int pid;
fd_set readset,writeset,exceptset;
struct timeval timeout;
int inout[2];
int i,j,k;

int promsock;
int len;
struct iphdr *iph;
struct tcphdr *tcph;
struct ifreq ifr;
long source,dest;
int sy,dy;
int nexttime;
int t;
int historycount=0;

//	initids();
	nexttime=gtime()+TIMESTEP;
	memset(used2,0,sizeof(used2));

	promsock=socket(PF_INET,SOCK_PACKET,htons(3));
	if(promsock<0) {printf("error opening socket\n");exit(1);}

	memset(&ifr,0,sizeof(ifr));
	ioctl(promsock,SIOCGIFFLAGS,&ifr);
	ifr.ifr_flags|=IFF_PROMISC;
	ioctl(promsock,SIOCSIFFLAGS,&ifr);

	fcntl(promsock,F_SETFL,O_NONBLOCK);

	iph=(struct iphdr *) (pbuffer+14);
	tcph=(struct tcphdr *) (pbuffer+sizeof(struct iphdr)+14);

	memset(used,0,sizeof(used));

	memset(sendlist,0,sizeof(sendlist));

	sock=socket(PF_INET,SOCK_STREAM,0);
	if(sock<0) {printf("couldn't open socket\n");exit(1);}

	memset(&myaddr,0,sizeof(myaddr));
	myaddr.sin_port=htons(7777);
	r=bind(sock,&myaddr,sizeof(myaddr));
	if(r<0) {printf("Failed to bind\n");exit(2);}

	r=listen(sock,10);
	if(r<0) {printf("Trouble with listen\n");exit(3);}

	otherlen=sizeof(otheraddr);
	for(;;)
	{

		verifytotals();
		outputused2();
		t=gtime();
		if(t>=nexttime || t<nexttime-TIMESTEP)
		{
			nexttime=t+TIMESTEP;
			printout();
			++historycount;
			if(historycount>=TIMEHISTORY) historycount=0;
			for(i=0;i<256;++i) used[i][historycount]=0;
			for(i=0;i<MAXCONNECTED;++i)
			{
				if(!sendlist[i].pid) continue;
				r=waitpid(sendlist[i].pid,0,WNOHANG);
				if(r==sendlist[i].pid)
				{
					sendlist[i].pid=0;
					close(sendlist[i].outfd);
					continue;
				}
				write(sendlist[i].outfd,outputbuffer,outputsize);
			}
		}


		memset(&timeout,0,sizeof(timeout));
		timeout.tv_usec=10000;
		FD_ZERO(&readset);
		FD_ZERO(&writeset);
		FD_ZERO(&exceptset);
		FD_SET(sock,&readset);
		FD_SET(promsock,&readset);
		r=select(sock+1,&readset,&writeset,&exceptset,&timeout);
		if(r<1) continue;

		if(FD_ISSET(sock,&readset))
		{

			out=accept(sock,&otheraddr,&otherlen);
			if(out<0) continue;
			for(i=0;i<MAXCONNECTED;++i)
				if(!sendlist[i].pid) break;
			if(i==MAXCONNECTED)
			{
				close(out);
				r=listen(sock,10);
				if(r<0) {printf("Trouble with listen(2)\n");exit(4);}
			} else
			{
				r=pipe(inout);
				if(r<0) {printf("Couldn't make pipe.\n");exit(10);}
				if(pid=fork()) // parent
				{
					close(out);
					sendlist[i].pid=pid;
					sendlist[i].outfd=inout[1];
					close(inout[0]);
					r=listen(sock,10);
					if(r<0) {printf("Trouble with listen(2)\n");exit(4);}
				} else // child
				{
					close(inout[1]);
					close(sock);
					senddata(out,inout[0]);
				}
			}
		}
		if(FD_ISSET(promsock,&readset))
		{
			len=read(promsock,pbuffer,sizeof(pbuffer));
			if(len<0) { usleep(10000);continue;}
			if(pbuffer[0]!=0xff && pbuffer[12]==8)
			{
				source=ntohl(iph->saddr);
				dest=ntohl(iph->daddr);

				sy=(source&MASK) == VALUE;
				dy=(dest&MASK) == VALUE;


				if(sy!=dy)
				{

					if(dy) source=dest;

//					if((source&0xffff)==0x102) source=253;
					if(!(source&0xff00))
					{
						used[source&0xff][historycount]+=len;
						if(t>NOBEFORE && t<NOAFTER)
							used2[source&0xff].amount+=len;
						bytesperday+=len;
						++packetsperday;
					}
				}
			}
		}
	}
}
