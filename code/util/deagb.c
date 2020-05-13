#include <stdio.h>
#include <fcntl.h>

unsigned long input[20000];
unsigned char output[80000];

unsigned long *swdtake,swdword;
int swdbits;

unsigned long swdmasks[]={0x0000,
0x0001,0x0003,0x0007,0x000f,0x001f,0x003f,0x007f,0x00ff,
0x01ff,0x03ff,0x07ff};

unsigned long swdbit(int num)
{
unsigned long r;
int t1,t2,t3;
	if(num<=swdbits)
	{
		r=swdword&swdmasks[num];
		swdword>>=num;
		swdbits-=num;
	} else
	{
		t1=num-swdbits;
		r=swdword;
		swdword=*swdtake++;
		r|=(swdword&swdmasks[t1])<<swdbits;
		swdbits=32-t1;
		swdword>>=t1;
	}
	return r;
}

int SwdDecode(unsigned char *to,unsigned long *compressed)
{
int length;
int copylen;
int copyoffset;
int t;
unsigned char *put,*p;

	length=*compressed++; // first long is uncompressed length
	swdtake=compressed;
	put=to;
	swdbits=0;
	for(;;)
	{
		if(!swdbit(1))
		{
			*put++=swdbit(8);
			continue;
		}
		if(!swdbit(1))
			copylen=2;
		else if(t=swdbit(2))
			copylen=t+2;
		else if(t=swdbit(4))
			copylen=t+5;
		else if(t=swdbit(8))
			copylen=t+20;
		else break;
		switch(swdbit(2))
		{
		case 0: // 5 bit offset
			copyoffset=1+swdbit(5);
			break;
		case 1: // 7 bit offset
			copyoffset=0x21+swdbit(7);
			break;
		case 2: // 9 bit offset
			copyoffset=0xa1+swdbit(9);
			break;
		case 3: // 10 bit offset
			copyoffset=0x2a1+swdbit(10);
			break;
		}
		p=put-copyoffset;
		while(copylen--) *put++=*p++;
	}
	return put-to;
}

void main(int argc,char **argv)
{
int f;
long len;

	if(argc<2) return;
	f=open(argv[1],O_RDONLY);
	if(f<0) return;
	read(f,input,sizeof(input));
	close(f);
	len=SwdDecode(output,input);
	write(1,output,len);
}
