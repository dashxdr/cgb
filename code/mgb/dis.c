#include "mgb.h"
#include "debug.h"

#define NEXTBYTE peekbank(dbank,distake++)


unsigned char dbank;
char disline[64];
unsigned char disop;
int distake;
char *disregs16[]={"bc","de","hl","sp"};
char *disregs16af[]={"bc","de","hl","af"};
char *disregs8[]={"b","c","d","e","h","l","[hl]","a"};

int distake16()
{
int i;
	i=NEXTBYTE;
	return i|NEXTBYTE<<8;
}
char *disaddr(int addr)
{
static char disaddrtxt[64];

	return getname(dbank,addr);
	sprintf(disaddrtxt,"$%04x",addr);
	return disaddrtxt;
}
char *disd8()
{
static char disd8txt[64];
	sprintf(disd8txt,"$%02x",NEXTBYTE);
	return disd8txt;
}
char *disr8()
{
char v;
	v=NEXTBYTE;
	return disaddr(distake+v);
}

void disnop(void)
{
	strcpy(disline,"nop");
}
void disldss16(void)
{
	sprintf(disline,"ld %s,%s",disregs16[(disop>>4)&3],disaddr(distake16()));
}
void disldbca(void)
{
	sprintf(disline,"ld [bc],a");
}
void dislddea(void)
{
	sprintf(disline,"ld [de],a");
}
void disldabc(void)
{
	strcpy(disline,"ld a,[bc]");
}
void disldade(void)
{
	strcpy(disline,"ld a,[de]");
}
void disincss(void)
{
	sprintf(disline,"inc %s",disregs16[(disop>>4)&3]);
}
void disdecss(void)
{
	sprintf(disline,"dec %s",disregs16[(disop>>4)&3]);
}
void disincs(void)
{
	sprintf(disline,"inc %s",disregs8[(disop>>3)&7]);
}
void disdecs(void)
{
	sprintf(disline,"dec %s",disregs8[(disop>>3)&7]);
}
void dislds8(void)
{
	sprintf(disline,"ld %s,%s",disregs8[(disop>>3)&7],disd8());
}
char *singlewordtab[]={"rlca","rrca","rla","rra","daa","cpl","scf","ccf"};
void dissinglewords(void)
{
	strcpy(disline,singlewordtab[(disop>>3)&7]);
}
void disldm16sp(void)
{
	sprintf(disline,"ld [%s],sp",disaddr(distake16()));
}
void disaddhlss(void)
{
	sprintf(disline,"add hl,%s",disregs16[(disop>>4)&3]);
}
void disstop(void)
{
	sprintf(disline,"stop %s",disd8());
}
char *discctab[]={"nz","z","nc","c"};
void disjr8(void)
{
	sprintf(disline,"jr %s",disr8());
}
void disjrcc8(void)
{
	sprintf(disline,"jr %s,%s",discctab[(disop>>3)&3],disr8());
}
void disldhlia(void)
{
	strcpy(disline,"ld [hli],a");
}
void disldahli(void)
{
	strcpy(disline,"ld a,[hli]");
}
void disldhlda(void)
{
	strcpy(disline,"ld [hld],a");
}
void disldahld(void)
{
	strcpy(disline,"ld a,[hld]");
}
void dishlt(void)
{
	strcpy(disline,"hlt");
}
void disldss(void)
{
	sprintf(disline,"ld %s,%s",disregs8[(disop>>3)&7],disregs8[disop&7]);
}
char *arrithtab[]={"add","adc","sub","sbc","and","xor","or","cp"};
void disarrithas(void)
{
	sprintf(disline,"%s %s",arrithtab[(disop>>3)&7],disregs8[disop&7]);
}
void disretcc(void)
{
	sprintf(disline,"ret %s",discctab[(disop>>3)&3]);
}
void dispopss(void)
{
	sprintf(disline,"pop %s",disregs16af[(disop>>4)&3]);
}
void dispushss(void)
{
	sprintf(disline,"push %s",disregs16af[(disop>>4)&3]);
}
void disjpcc16(void)
{
	sprintf(disline,"jp %s,%s",discctab[(disop>>3)&3],disaddr(distake16()));
}
void disjp16(void)
{
	sprintf(disline,"jp %s",disaddr(distake16()));
}
void discallcc16(void)
{
	sprintf(disline,"call %s,%s",discctab[(disop>>3)&3],disaddr(distake16()));
}
void discall16(void)
{
	sprintf(disline,"call %s",disaddr(distake16()));
}
void disarritha8(void)
{
	sprintf(disline,"%s %s",arrithtab[(disop>>3)&7],disd8());

}
void disrstn(void)
{
	sprintf(disline,"rst $%02x",disop&0x38);
}
void disret(void)
{
	strcpy(disline,"ret");
}
char *disrottab[]={"rlc","rrc","rl","rr","sla","sra","swap","srl"};
char *disbittab[]={"bit","res","set"};
void disbytecb(void)
{
unsigned char v;
	v=NEXTBYTE;
	if(!(v&0xc0))	// all rotates
	{
		sprintf(disline,"%s %s",disrottab[(v>>3)&7],disregs8[v&7]);
	} else
	{
		sprintf(disline,"%s %d,%s",disbittab[((v>>6)&3)-1],
			(v>>3)&7,disregs8[v&7]);
	}

}
void disbadop(void)
{
	sprintf(disline,"db $%02x",disop);
}
void disreti(void)
{
	strcpy(disline,"reti");
}
void disldh8a(void)
{
	sprintf(disline,"ldh [%s],a",disaddr(0xff00+NEXTBYTE));
}
void disldha8(void)
{
	sprintf(disline,"ldh a,[%s]",disaddr(0xff00+NEXTBYTE));
}
void disldhca(void)
{
	strcpy(disline,"ldh [c],a");
}
void disldhac(void)
{
	strcpy(disline,"ldh a,[c]");
}
void disaddsp8(void)
{
	sprintf(disline,"add sp,%s",disd8());
}
void disjphl(void)
{
	strcpy(disline,"jp [hl]");
}
void disld16a(void)
{
	sprintf(disline,"ld [%s],a",disaddr(distake16()));
}
void dislda16(void)
{
	sprintf(disline,"ld a,[%s]",disaddr(distake16()));
}
void disdi(void)
{
	strcpy(disline,"di");
}
void disei(void)
{
	strcpy(disline,"ei");
}
void disldhlsp8(void)
{
char num[8];
unsigned char v;
	v=NEXTBYTE;
	if(v<128)
		sprintf(num,"+$%02x",v);
	else
		sprintf(num,"-$%02x",256-v);
	sprintf(disline,"ld hl,sp%s",num);
}
void disldsphl(void)
{
	strcpy(disline,"ld sp,hl");
}

void (*distab[])()={
disnop, // 00
disldss16,
disldbca,
disincss,
disincs,
disdecs,
dislds8,
dissinglewords,
disldm16sp, // 08
disaddhlss,
disldabc,
disdecss,
disincs,
disdecs,
dislds8,
dissinglewords,
disstop, // 10
disldss16,
dislddea,
disincss,
disincs,
disdecs,
dislds8,
dissinglewords,
disjr8, // 18
disaddhlss,
disldade,
disdecss,
disincs,
disdecs,
dislds8,
dissinglewords,
disjrcc8, // 20
disldss16,
disldhlia,
disincss,
disincs,
disdecs,
dislds8,
dissinglewords,
disjrcc8, // 28
disaddhlss,
disldahli,
disdecss,
disincs,
disdecs,
dislds8,
dissinglewords,
disjrcc8, // 30
disldss16,
disldhlda,
disincss,
disincs,
disdecs,
dislds8,
dissinglewords,
disjrcc8, // 38
disaddhlss,
disldahld,
disdecss,
disincs,
disdecs,
dislds8,
dissinglewords,
disldss, // 40
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 48
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 50
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 58
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 60
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 68
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss, // 70
disldss,
disldss,
disldss,
disldss,
disldss,
dishlt,
disldss,
disldss, // 78
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disldss,
disarrithas, // 80
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // 88
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // 90
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // 98
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // a0
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // a8
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // b0
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas, // b8
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disarrithas,
disretcc, // c0
dispopss,
disjpcc16,
disjp16,
discallcc16,
dispushss,
disarritha8,
disrstn,
disretcc, // c8
disret,
disjpcc16,
disbytecb,
discallcc16,
discall16,
disarritha8,
disrstn,
disretcc, // d0
dispopss,
disjpcc16,
disbadop,
discallcc16,
dispushss,
disarritha8,
disrstn,
disretcc, // d8
disreti,
disjpcc16,
disbadop,
discallcc16,
disbadop,
disarritha8,
disrstn,
disldh8a, // e0
dispopss,
disldhca,
disbadop,
disbadop,
dispushss,
disarritha8,
disrstn,
disaddsp8, // e8
disjphl,
disld16a,
disbadop,
disbadop,
disbadop,
disarritha8,
disrstn,
disldha8, // f0
dispopss,
disldhac,
disdi,
disbadop,
dispushss,
disarritha8,
disrstn,
disldhlsp8, // f8
disldsphl,
dislda16,
disei,
disbadop,
disbadop,
disarritha8,
disrstn
};


int disz80(unsigned char bank,int from,char *put)
{
void (*func)();
char *p,ch;
int to,i;

	dbank=bank;
	distake=from;
	disop=NEXTBYTE;
	func=distab[disop];
	func();
	if(0)
	{
		i=0;
		to=distake;
		distake=from;
		while(distake<to)
		{
			sprintf(put,"%02x",NEXTBYTE);
			put+=2;
			++i;
		}
		while(i<3)
		{
			strcpy(put,"  ");
			put+=2;
			++i;
		}
		*put++=' ';
	}
	p=disline;
	i=0;
	while((ch=*p++))
	{
		if(ch==' ')
			do {*put++=' ';++i;} while(i&7);
		else {*put++=ch;++i;}
	}
	*put=0;
	return distake-from;
}
