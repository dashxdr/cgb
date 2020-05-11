#include <stdio.h>
#include <fcntl.h>
#include "link.h"

int infile;
int halt=1;

long revlong(long val)
{
	return ((val&0xff)<<24) | ((val&0xff00)<<8)
	 | ((val&0xff0000L)>>8) | ((val&0xff000000)>>24);
}

cchit() {return 0;}

long readlong()
{
long along;

	halt=read(infile,&along,4);
	return revlong(along);
}
symbol(len)
long len;
{
char temp[80];
char *p1;

	read(infile,temp,(int)len<<2);
	len<<=2;
	p1=temp;
	while(len-- && *p1) putchar(*p1++);
}


dataout(len)
long len;
{
	int x=0;
	long v;

	len&=0xffffffL;
	while(len--)
	{
		if(cchit()) exit();
		v=readlong();
		printf(" %08lx",v);
		x++;
		if(x==8) {x=0;putchar('\n');}
	}
	if(x) putchar('\n');
}

main(argc,argv)
int argc;
char *argv[];
{
long	v1,v2,v3;
int t;

	if(argc<2) {printf("Use: od <objectfile>\n");return 0;}
	infile=open(argv[1],O_RDONLY);
	if(infile<0) {printf("Cannot open input file %s\n",argv[1]);return 1;}
	for(;;)
	{
		v1=readlong();
		if(!halt) return 0;
		if(cchit()) exit();
printf("[%08lx] ",v1);
		switch((int)v1)
		{
		case 0x3f3:
			printf("HUNK_HEADER\n ");
			while(v1=readlong())
			{
				putchar('"');
				symbol(v1);
				printf("\",");
			}
			v1=readlong();printf(" [%ld]",v1);
			v1=readlong();printf(" [%ld]",v1);
			v2=readlong();printf(" [%ld]",v1);
			putchar('\n');
			dataout(v2-v1+1);
			break;
		case	0x3eb:
			printf("HUNK_BSS [%08lx]\n",readlong());
			break;
		case 0x3f1:
			v1=readlong();
			printf("HUNK_DEBUG [%08lx]\n",v1);
			dataout(v1);
			break;
		case 0x3f2:
			printf("HUNK_END\n");
			break;
		case 0x3e8:
			printf("HUNK_NAME \"");
			symbol(readlong());
			printf("\"\n");
			break;
		case 0x3e9:
			v1=readlong();
			printf("HUNK_CODE [%08lx]\n",v1);
			dataout(v1);
			break;
		case 0x3ea:
			v1=readlong();
			printf("HUNK_DATA [%08lx]\n",v1);
			dataout(v1);
			break;
		case 0x3cd:
			relocout("16RELOC");
			break;
		case 0x3cc:
			relocout("32RELOC");
			break;
		case 0x3ed:
			relocout("RELOC16");
			break;
		case 0x3ec:
			relocout("RELOC32");
			break;
		case 0x3f0:
			printf("HUNK_SYMBOL\n");
			while(v1=readlong())
			{
				if(cchit()) exit();
				putchar(' ');
				symbol(v1);
				printf("=%lx\n",readlong());
			}
			break;
		case 0x3e7:
			printf("HUNK_UNIT \"");
			if(v1=readlong()) symbol(v1);
			printf("\"\n");
			break;
		case 0x3ef:
			printf("HUNK_EXT\n");
			while(v1=readlong())
			{
				if(cchit()) exit();
				t=(unsigned long)v1>>24L;
				v1&=0xffffffL;
				printf(" [EXT_");
				switch(t)
				{
				case 0x00: printf("SYMB] ");break;
				case 0x01: printf("DEF] ");break;
				case 0x02: printf("ABS] ");break;
				case 0x81: printf("REF32] ");break;
				case 0x82: printf("COMMON] ");break;
				case 0x83: printf("REF16] ");break;
				case 0x84: printf("REF8] ");break;
				case 0x86: printf("CODE86 ");break;
				case 0x8b: printf("REL16] ");break;
				case 0x91: printf("32REF] ");break;
				case 0x93: printf("16REF] ");break;
				case 0x99: printf("32REL] ");break;
				case 0x9b: printf("16REL] ");break;
				case LINKLOW8: printf("LOW8] ");break;
				case LINKHIGH8: printf("HIGH8] ");break;
				case LINKBANK8: printf("BANK8] ");break;
				case LINK16NREF: printf("16NREF] ");break;
				default: printf("%02x?] ",t);break;
				}
				symbol(v1);
				if(t==1 || t==2 || t==3)
					printf("=%08lx\n",readlong());
				else
				if(t&0x80)
					{putchar('\n');dataout(readlong());}
				else
					{v1=readlong();printf(" [%08lx]\n");
						dataout(readlong());}
			}
			break;
		default:
			printf("Unknown code %08lx\n",v1);
			return 1;
		}
	}
}
relocout(str)
char *str;
{
long v1,v2;
	printf("HUNK_%s\n",str);
	while(v1=readlong())
	{
		v2=readlong();
		printf("hunk=%ld\n",v2);
		dataout(v1);
	}
}
