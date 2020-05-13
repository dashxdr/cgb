#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>


#define FACTOR 8
#define FACTOR2 ((10000L<<FACTOR)>>10)
#define RATE 2
#define MAXV 48
#define MAXTRACKS 256
typedef unsigned char uchar;

unsigned char songdata[500000];
int numtracks;
int division;
long pertick;
long masterclock;
struct atrack
{
	uchar *pointer;
	uchar *start;
	uchar *put;
	int lasttime;
	int dump;
	long left;
	long time;
	int id;
	uchar flags;
	uchar laststatus;
	uchar programs[16];
}tracks[MAXTRACKS];
#define NEEDDELTA 1

int mididowncount;



void midiprintf(char *name,...)
{
//	vfprintf(stderr,name,&name+1);
}


midiup(int v1,int id)
{
}
mididown(int v2,int v1,int id,int program)
{
}



#define BUFFSIZE 2048


#define MTHD 0x4d546864L
#define MTRK 0x4d54726bL

unsigned char *inpoint;
int inleft;
char *errormsgs[]={
"All ok",
"File not in midi format",
"File ended abruptly",
};

unsigned char readbyte()
{
	if(inleft>0)
	{
		--inleft;
		return *inpoint++;
	}
	return 0;
}
readword()
{
int b1,b2;
	b1=readbyte();
	b2=readbyte();
	if(b2==-1) return -1;
	return (b1<<8)|b2;
}
long readlong()
{
long b1,b2,b3,b4;
	b1=readbyte();
	b2=readbyte();
	b3=readbyte();
	b4=readbyte();
	if(b4==-1) return -1;
	return (b1<<24)|(b2<<16)|(b3<<8)|b4;
}
int readlimit(struct atrack *track)
{
int i;
	if(!track->left) return -1;
	--track->left;
	i=*(track->pointer)++;
	*(track->put)++=i;
	++(track->dump);
	return i;
}
long readvariable(struct atrack *track)
{
long val=0;
int t;
	for(;;)
	{
		t=readlimit(track);
		if(t<0) return -1;
		val<<=7;
		val|=t&127;
		if(t<128) break;
	}
	return val;
}
void writevariable(struct atrack *track,int v)
{
int i,j,k;
	i=1;
	while(1<<i*7<=v) ++i;
	while(i--)
	{
		j=(!i ? 0 : 0x80) | ((v>>i*7)&127);
		*(track->put)++=j;
		++(track->dump);
	}
}
int need;
void keep(struct atrack *track)
{
	track->dump=0;
	track->lasttime=0;
	need=0;
}
void toss(struct atrack *track)
{
need=0;
	track->put-=track->dump;
	track->dump=0;
	need=0;
}
int fixtime(struct atrack *track)
{
int t;

//	track->dump=0;
	t=readvariable(track);
	if(t<0) return t;
	track->put-=track->dump;
	track->dump=0;
	track->lasttime+=t;
	writevariable(track,track->lasttime);
	return t;
}


dump(struct atrack *track,int len)
{
	while(len--) readlimit(track);
}
hex(struct atrack *track,int len)
{
	while(len--) midiprintf(" %x",readlimit(track));
	midiprintf("\n");
}
text(struct atrack *track,int len)
{
	midiprintf("%d:",len);
	while(len--) midiprintf("%c",readlimit(track));
	midiprintf("\n");
}
char *midinames[]={
"Note off   ",
"Note on    ",
"After touch",
"Ctrl change",
"",
"",
"Pitch wheel"
};

int zzz=0;
dotrack(struct atrack *track)
{
long time;
int type;
int sysexlen;
int metalen;
int id;
int v1,v2,v3,v4;
int laststatus;
long val;

	need=0;
	for(;;)
	{
		if(need) fprintf(stderr,"didn't do keep or toss\n");
		need=1;
//track->dump=0;
		if(track->flags & NEEDDELTA)
		{
			track->time+=fixtime(track)<<FACTOR;
			track->flags ^= NEEDDELTA;
		}
		if(track->time > masterclock) break;
		track->flags |= NEEDDELTA;

		type=readlimit(track);
		if(type==-1) break;
		if(type==0xf7 || type==0xf0)
		{
			sysexlen=readlimit(track);
			if(sysexlen==-1) break;
			while(sysexlen--) readlimit(track);
toss(track);
			continue;
		}
		if(type==0xff)
		{
			type=readlimit(track);
			if(type==-1) break;
			metalen=readlimit(track);
			if(metalen==-1) break;
			switch(type)
			{
			case 0:
				midiprintf("Sequence number:");
				dump(track,metalen);
				break;
			case 1:
				midiprintf("Text event:");
				text(track,metalen);
				break;
			case 2:
				midiprintf("Copyright notice:");
				text(track,metalen);
				break;
			case 3:
				midiprintf("Sequence/track name:");
				text(track,metalen);
				break;
			case 4:
				midiprintf("Instrument name:");
				text(track,metalen);
				break;
			case 5:
				midiprintf("Lyric:");
				text(track,metalen);
				break;
			case 6:
				midiprintf("Marker:");
				text(track,metalen);
				break;
			case 7:
				midiprintf("Cue point:");
				text(track,metalen);
				break;
			case 0x20:
				midiprintf("Midi channel prefix:");
				dump(track,metalen);
				break;
			case 0x2f:
/*				midiprintf("End of track:");*/
				dump(track,metalen);
keep(track);
				break;
			case 0x51:
				midiprintf("Set tempo:");
				if(metalen<3)
					dump(track,metalen);
				else
				{
					long b1,b2,b3;
					b1=readlimit(track);b2=readlimit(track);b3=readlimit(track);
					while(metalen>3) readlimit(track);
					val=(b1<<16)|(b2<<8)|b3;
					midiprintf("%ld microseconds per MIDI quarter note\n",val);
					val>>=10;
					pertick=(FACTOR2*division)/val;
keep(track);
				}
				break;
			case 0x58:
				midiprintf("Time Signature:");
				hex(track,metalen);
toss(track); // **** problems
				break;
			case 0x21:
				dump(track,metalen);
				break;
			default:
				midiprintf("Meta code %x:",type);
				hex(track,metalen);
				break;
			}
if(need) toss(track);
			continue;
		}
		if(type<0x80)
		{
			v1=type;
			type=track->laststatus;
		}
		else
		{
			track->laststatus=type;
			v1=readlimit(track);
		}
		switch(type&0xf0)
		{

		case 0xe0:
		case 0xb0:
		case 0xa0:
		case 0x90:
		case 0x80:
			v2=readlimit(track);
			id=(type&15) | (track->id<<4);
			if((type>>4)==8 || (type>>4)==9 && !v2)
				midiup(v1,id);
			else if((type>>4)==9)
				mididown(v2,v1,id,track->programs[type&0x0f]);
keep(track);
			break;
		case 0xc0:
			midiprintf("Program change %d:%02x\n",type&15,v1);
			track->programs[type&0x0f]=v1;
keep(track);
			break;
		case 0xd0:
			midiprintf("Channel aftertouch %d:%x\n",type&15,v1);
//toss(track);
			break;
		}
if(need) toss(track);
	}
}

int domidi(unsigned char *midistream,int size)
{
int i,j,k;
int format,ntracks;
long type,length;
struct atrack *track;
uchar doneflag;

	mididowncount=0;
	inpoint=midistream;
	inleft=size;
	if(readlong()!=MTHD) return 1;
	i=readlong();
	if(i<6) return 2;
	format=readword();
	numtracks=readword();
	division=readword();
	if(division<0) return 2;
	while(i-->6) readbyte();
	midiprintf("Format %d, ntracks %d, ",format,numtracks);
	if(division&0x8000)
		midiprintf("SMPTE format %d, %d ticks per frame\n",(division>>8)-256,
			division&255);
	else
{
		midiprintf("%d ticks per quarter note\n",division);
		pertick=34L*division<<FACTOR;
}

	track=tracks;
	for(i=0;i<numtracks;i++)
	{
		type=readlong();
		length=readlong();
		if(type==-1 || length==-1) return 2;
		track->pointer=inpoint;
		track->start=inpoint;
		track->put=inpoint;
		track->dump=0;
		track->lasttime=0;
		inpoint+=length;
		inleft-=length;

		if(type!=MTRK)
		{
			midiprintf("Unknown hunk %lx, length %d bytes\n",type,length);
			while(length--) readbyte();
			continue;
		}
		track->left=length;
		track->id=i;
		track->time=0;
		track->flags=NEEDDELTA;
		track->laststatus=0x80;
		++track;
	}
	masterclock=0;

	return 0;
}
midiroutine()
{
struct atrack *track;
int i;
int doneflag;

	track=tracks;
	i=numtracks;
	doneflag=1;
	while(i--)
	{
		if(track->left>0)
		{
			doneflag=0;
			dotrack(track);
		}
		++track;
	}
	masterclock+=pertick;
	return doneflag;
}


int playsong(char *name)
{
int f;
int len;

	f=open(name,O_RDONLY);
	if(f<0) return 1;
	len=read(f,songdata,sizeof(songdata));
	close(f);
	return domidi(songdata,len);
}

main(int argc,char **argv)
{
int i,j;
	for(i=1;i<argc;++i)
	{
		playsong(argv[i]);
		while(!midiroutine());
		write(1,songdata,14);
		for(j=0;j<numtracks;++j)
		{
			struct atrack* t;
			int len;
			t=tracks+j;
			len=t->put-t->start;
			t->start[-1]=len;
			t->start[-2]=len>>8;
			t->start[-3]=len>>16;
			t->start[-4]=len>>24;
			write(1,t->start-8,len+8);
		}

	}
}
