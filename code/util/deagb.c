#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <inttypes.h>

typedef int32_t LONG;
typedef uint32_t ULONG;

ULONG input[20000];
unsigned char output[80000];

ULONG *swdtake,swdword;
int swdbits;

ULONG swdmasks[]={0x0000,
0x0001,0x0003,0x0007,0x000f,0x001f,0x003f,0x007f,0x00ff,
0x01ff,0x03ff,0x07ff};

ULONG swdbit(int num) {
	ULONG r;
	int t1;
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

int SwdDecode(unsigned char *to, ULONG *compressed) {
	int copylen;
	int copyoffset=0;
	int t;
	unsigned char *put,*p;

	compressed++; // first LONG is uncompressed length, skip
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
		else if((t=swdbit(2)))
			copylen=t+2;
		else if((t=swdbit(4)))
			copylen=t+5;
		else if((t=swdbit(8)))
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

int main(int argc,char **argv) {
	int f;
	int len;
	int res;

	if(argc<2) return -1;
	f=open(argv[1],O_RDONLY);
	if(f<0) return -2;
	res=read(f,input,sizeof(input));res=res;
	close(f);
	len=SwdDecode(output,input);
	res=write(1,output,len);res=res;
	return 0;}

