#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#include "mgb.h"
#include "debug.h"

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define HL ((regs[4]<<8)|regs[5])
#define DE ((regs[2]<<8)|regs[3])
#define BC ((regs[0]<<8)|regs[1])

#define FLAGC 0x10
#define FLAGH 0x20
#define FLAGN 0x40
#define FLAGZ 0x80
#define FLAGS regs[8]

extern int sound3counter;

unsigned char peek(unsigned int addr);

#define nexti() peek(regpc++)

unsigned char tima,tma,tac;
int timerdiv,timermax;

unsigned char *cgbrambank;
unsigned char mie,hie;
unsigned char lycmatch;

int cyclecount,cycledelta;

unsigned char hs1,hs2,doublespeed;
int lc=0;
int cyclechange=0;

unsigned short regpc,regsp;
unsigned short pcold;
unsigned char oldvalid;
unsigned char oldbank,currentbank;
unsigned char regs[9]; // bcdehlmaf

unsigned char *rombank;
unsigned char objpal[64],bgpal[64];

char trace=0;
char disabled;
char irq;

char cyclesused;
unsigned char inst;

unsigned char peekbank(unsigned char bank,unsigned int addr)
{
unsigned char *save,v;
	save=rombank;
	rombank=romblock+((bank&0xff)<<14);
	v=peek(addr);
	rombank=save;
	return v;
}


unsigned char peekff(unsigned char addr)
{
int i,j;
	switch(addr)
	{
	case 0x00: // rP1
		if(!(ramblock[0xff00]&0x20))
		{
			return (ramblock[0xff00]&0x30) | 
				(buttonstart ? 0 : 8) |
				(buttonselect ? 0 : 4) |
				(buttonb ? 0 : 2) |
				(buttona ? 0 : 1);
		}
		if(!(ramblock[0xff00]&0x10))
		{
			return (ramblock[0xff00]&0x30) |
				(buttond ? 0 : 8) |
				(buttonu ? 0 : 4) |
				(buttonl ? 0 : 2) |
				(buttonr ? 0 : 1);
		}
		return 0xff;
	case 0x05: // TIMA
		return tima;
	case 0x41: // STAT
		return lycmatch | (hstat[cyclecount]&3);
	case 0x44: // LY
		return vline[cyclecount];
	case 0x55: // DMA
		return (hstat[cyclecount]&3)==0 ? 0x80 : 0;
	case 0x69:
		if(hMachine!=CGB) return 0xff;
		i=ramblock[0xff68];
		j=bgpal[i&0x3f];
		if(i&0x80)
			ramblock[0xff68]=0x80+((i+1)&0x3f);
		return j;
	case 0x6b:
		if(hMachine!=CGB) return 0xff;
		i=ramblock[0xff6a];
		j=objpal[i&0x3f];
		if(i&0x80)
			ramblock[0xff68]=0x80+((i+1)&0x3f);
		return j;
	default:
		return ramblock[0xff00+addr];
	}
}
unsigned char peek(unsigned int addr)
{
	if(addr<0x4000)
		return romblock[addr];
	if(addr<0x8000)
		return rombank[addr-0x4000];
	if(addr>=0xff00)
		return peekff(addr);
	if(hMachine==CGB)
	{
		if(addr<0xa000)
		{
			if(ramblock[0xff4f]&1) addr+=0x8000;
		} else if(addr>=0xd000 && addr<0xe000)
			return cgbrambank[addr&0xfff];
	}
	return ramblock[addr];
}



void makestrip(int addr)
{
unsigned register char b1,b2,*p;

	addr&=~1;
	if(addr<0x10000)
		p=stripblock+((addr-0x8000)<<2);
	else
		p=stripblock+((addr-0xe800)<<2);
	b1=ramblock[addr];
	b2=ramblock[addr+1];
	*p=((b1&0x80) ? 1 : 0) | ((b2&0x80) ? 2 : 0);
	p[1]=((b1&0x40) ? 1 : 0) | ((b2&0x40) ? 2 : 0);
	p[2]=((b1&0x20) ? 1 : 0) | ((b2&0x20) ? 2 : 0);
	p[3]=((b1&0x10) ? 1 : 0) | ((b2&0x10) ? 2 : 0);
	p[4]=((b1&0x08) ? 1 : 0) | ((b2&0x08) ? 2 : 0);
	p[5]=((b1&0x04) ? 1 : 0) | ((b2&0x04) ? 2 : 0);
	p[6]=((b1&0x02) ? 1 : 0) | ((b2&0x02) ? 2 : 0);
	p[7]=((b1&0x01) ? 1 : 0) | ((b2&0x01) ? 2 : 0);
}

unsigned char duty125[8]={1,0,0,0,0,0,0,0};
unsigned char duty250[8]={1,1,0,0,0,0,0,0};
unsigned char duty500[8]={1,1,1,1,0,0,0,0};
unsigned char duty750[8]={1,1,1,1,1,1,0,0};
unsigned char *dutys[]={duty125,duty250,duty500,duty750};

char wavevol[4]={8,0,1,2};
int timermaxes[4]={256,4,16,64};
char noisefreqs[]={1,1,2,3,4,5,6,7};//{1,2,4,6,8,10,12,14};
void poke(unsigned int addr,unsigned char ch)
{
int i,j,k;
	addr&=0xffff;
	if(addr>=0xff00)
	{
		switch(addr&0xff)
		{
		case 0x05:
			tima=ch;
			break;
		case 0x06:
			tma=ch;
			break;
		case 0x07:
			tac=ch;
			timermax=timermaxes[ch&3];
			break;
		case 0x11:
			v1.duty=dutys[ch>>6];
			break;
		case 0x12:
			v1.volume=(ch&0xf0)>>4;
			v1.env=ch&15;
			v1.envclock=0;
			break;
		case 0x13:
		case 0x14:
			ramblock[addr]=ch;
#define FREQVAL (0x100000) /* $800000000/sampling rate */
			i=(ramblock[0xff14]<<8) | ramblock[0xff13];
			v1.freqval=FREQVAL/(2048-(i&0x7ff));
			if((addr&0xff)==0x14 && (ch&0x80))
			{
				v1.mode=ch;
				v1.timer=(0x40-(ramblock[0xff11]&0x3f));
			}
			break;
		case 0x16:
			v2.duty=dutys[ch>>6];
			break;
		case 0x17:
			v2.volume=(ch&0xf0)>>4;
			v2.env=ch&15;
			v2.envclock=0;
			break;
		case 0x18:
		case 0x19:
			ramblock[addr]=ch;
			i=((ramblock[0xff19]<<8) | ramblock[0xff18]);
			v2.freqval=FREQVAL/(2048-(i&0x7ff));
			if((addr&0xff)==0x19 && (ch&0x80))
			{
				v2.mode=ch;
				v2.timer=(0x40-(ramblock[0xff16]&0x3f));
			}
			break;
		case 0x1a:
			sound3counter=0;
			break;
		case 0x1c:
			v3.volume=wavevol[(ch&0x60)>>5];
			break;
		case 0x1d:
		case 0x1e:
			ramblock[addr]=ch;
			i=((ramblock[0xff1e]<<8) | ramblock[0xff1d]);
			v3.freqval=FREQVAL/(2048-(i&0x7ff));
			if((addr&0xff)==0x1e && (ch&0x80))
			{
				v3.mode=ch;
				v3.timer=(256-ramblock[0xff1b]);
			}
			break;
		case 0x21:
			v4.volume=(ch&0xf0)>>4;
			v4.env=ch&15;
			v4.envclock=0;
			break;
		case 0x22:
			v4.freqval=noisefreqs[ch&7];
			break;
		case 0x23:
			if(ch&0x80)
			{
				v4.mode=ch;
				v4.timer=(0x40-(ramblock[0xff20]&0x3f));
			}
			break;
		case 0x26:
			if(!(ch&0x80))
			{
				v1.mode&=0x7f;
				v2.mode&=0x7f;
				v3.mode&=0x7f;
				v4.mode&=0x7f;
			}
			break;
		case 0x30:
		case 0x31:
		case 0x32:
		case 0x33:
		case 0x34:
		case 0x35:
		case 0x36:
		case 0x37:
		case 0x38:
		case 0x39:
		case 0x3a:
		case 0x3b:
		case 0x3c:
		case 0x3d:
		case 0x3e:
		case 0x3f:
			i=(addr&15)<<1;
			v3tab[i]=((ch&0xf0)>>2)-32;
			v3tab[i+1]=((ch&0x0f)<<2)-32;
			break;
		case 0x40: // LCDC
			if(ch&16) striplookup=striplookupblock;
			else striplookup=striplookupblock+256;
			break;
		case 0x41: // stat
			hie=ch;
			lycmatch=(ch&0x78) | (lycmatch&~0x78);
			break;
		case 0x45: // LYC
			if(!((mie&2) && (hie&0x40))) break;
			i=vline[cyclecount];
			if(ramblock[0xff45]!=i && ch==i)
				irq|=2;
			if(ch==i)
				lycmatch|=4;
			else
				lycmatch&=~4;
			break;
		case 0x46: //OAM DMA
			j=ch<<8;
			i=0xfe00;
			while(i<0xfea0)
				poke(i++,peek(j++));
			break;
		case 0x47: // BGP
			bgmap[0]=252|(ch&3);
			bgmap[1]=252|((ch>>2)&3);
			bgmap[2]=252|((ch>>4)&3);
			bgmap[3]=252|((ch>>6)&3);
			break;
		case 0x48: // OBP0
			ob0map[0]=252|(ch&3);
			ob0map[1]=252|((ch>>2)&3);
			ob0map[2]=252|((ch>>4)&3);
			ob0map[3]=252|((ch>>6)&3);
			break;
		case 0x49: // OBP1
			ob1map[0]=252|(ch&3);
			ob1map[1]=252|((ch>>2)&3);
			ob1map[2]=252|((ch>>4)&3);
			ob1map[3]=252|((ch>>6)&3);
			break;
		case 0x4d: // rKey1
			if(hMachine==CGB)
				if(ch&1) {ch=(ramblock[0xff4d]) ^ 0x80;}
			break;
		case 0x55: // HDMA5
			k=((ch&0x7f)+1)<<4;
			i=(ramblock[0xff51]<<8) | (ramblock[0xff52] & 0xf0);
			ramblock[0xff52]=i+k;
			ramblock[0xff51]=(i+k)>>8;
			j=(ramblock[0xff53]<<8) | (ramblock[0xff54] & 0xf0);
			ramblock[0xff54]=j+k;
			ramblock[0xff53]=(j+k)>>8;
			while(k--) poke(0x8000 | (j++ & 0x1fff),peek(i++));
			break;
		case 0x69: // BCPD
			if(hMachine!=CGB) break;
			i=ramblock[0xff68];
			bgpal[i&0x3f]=ch;
			if(i&0x80)
				ramblock[0xff68]=0x80+((i+1)&0x3f);
			i&=0x3e;
			j=(bgpal[i+1]<<8) | bgpal[i];
			set_color(i>>1,(j&0x1f)<<3,(j&0x3e0)>>2,(j&0x7c00)>>7);
			break;
		case 0x6b: // OCPD
			if(hMachine!=CGB) break;
			i=ramblock[0xff6a];
			objpal[i&0x3f]=ch;
			if(i&0x80)
				ramblock[0xff6a]=0x80+((i+1)&0x3f);
			i&=0x3e;
			j=(objpal[i+1]<<8) | objpal[i];
			set_color(32+(i>>1),(j&0x1f)<<3,(j&0x3e0)>>2,(j&0x7c00)>>7);
			break;
		case 0x70: // SVBK
			ch&=7;
			if(ch<2) cgbrambank=ramblock+0x1000;
			else cgbrambank=ramblock+(ch<<12);			
			break;
		case 0xff: // MIE
			mie=ch;
			break;
		}
		ramblock[addr]=ch;
	} else if(addr>=0x8000)
	{
		switch(hMachine)
		{
		case GMB:
			ramblock[addr]=ch;
			if(addr<0x9800)
				makestrip(addr);
			break;
		case CGB:
			if(addr<0xa000)
			{
				if(ramblock[0xff4f]&1) addr+=0x8000;
				ramblock[addr]=ch;
				if((addr&0x7fff)<0x1800)
					makestrip(addr);
			} else if(addr>=0xd000 && addr<0xe000)
				cgbrambank[addr&0xfff]=ch;
			else
				ramblock[addr]=ch;
		}
	} else if(addr>=0x2000 && addr<0x3000)
	{
		currentbank=ch&0xff;
		rombank=romblock+(currentbank<<14);
	}
}


void cpuhalt(void) // halt
{
	--regpc;
	cyclesused+=2;
}
void cpuldbc(void) {regs[0]=regs[1];++cyclesused;}
void cpuldbd(void) {regs[0]=regs[2];++cyclesused;}
void cpuldbe(void) {regs[0]=regs[3];++cyclesused;}
void cpuldbh(void) {regs[0]=regs[4];++cyclesused;}
void cpuldbl(void) {regs[0]=regs[5];++cyclesused;}
void cpuldbm(void) {regs[0]=peek(HL);cyclesused+=2;}
void cpuldba(void) {regs[0]=regs[7];++cyclesused;}
void cpuldcb(void) {regs[1]=regs[0];++cyclesused;}
void cpuldcd(void) {regs[1]=regs[2];++cyclesused;}
void cpuldce(void) {regs[1]=regs[3];++cyclesused;}
void cpuldch(void) {regs[1]=regs[4];++cyclesused;}
void cpuldcl(void) {regs[1]=regs[5];++cyclesused;}
void cpuldcm(void) {regs[1]=peek(HL);cyclesused+=2;}
void cpuldca(void) {regs[1]=regs[7];++cyclesused;}
void cpulddb(void) {regs[2]=regs[0];++cyclesused;}
void cpulddc(void) {regs[2]=regs[1];++cyclesused;}
void cpuldde(void) {regs[2]=regs[3];++cyclesused;}
void cpulddh(void) {regs[2]=regs[4];++cyclesused;}
void cpulddl(void) {regs[2]=regs[5];++cyclesused;}
void cpulddm(void) {regs[2]=peek(HL);cyclesused+=2;}
void cpuldda(void) {regs[2]=regs[7];++cyclesused;}
void cpuldeb(void) {regs[3]=regs[0];++cyclesused;}
void cpuldec(void) {regs[3]=regs[1];++cyclesused;}
void cpulded(void) {regs[3]=regs[2];++cyclesused;}
void cpuldeh(void) {regs[3]=regs[4];++cyclesused;}
void cpuldel(void) {regs[3]=regs[5];++cyclesused;}
void cpuldem(void) {regs[3]=peek(HL);cyclesused+=2;}
void cpuldea(void) {regs[3]=regs[7];++cyclesused;}
void cpuldhb(void) {regs[4]=regs[0];++cyclesused;}
void cpuldhc(void) {regs[4]=regs[1];++cyclesused;}
void cpuldhd(void) {regs[4]=regs[2];++cyclesused;}
void cpuldhe(void) {regs[4]=regs[3];++cyclesused;}
void cpuldhl(void) {regs[4]=regs[5];++cyclesused;}
void cpuldhm(void) {regs[4]=peek(HL);cyclesused+=2;}
void cpuldha(void) {regs[4]=regs[7];++cyclesused;}
void cpuldlb(void) {regs[5]=regs[0];++cyclesused;}
void cpuldlc(void) {regs[5]=regs[1];++cyclesused;}
void cpuldld(void) {regs[5]=regs[2];++cyclesused;}
void cpuldle(void) {regs[5]=regs[3];++cyclesused;}
void cpuldlh(void) {regs[5]=regs[4];++cyclesused;}
void cpuldlm(void) {regs[5]=peek(HL);cyclesused+=2;}
void cpuldla(void) {regs[5]=regs[7];++cyclesused;}
void cpuldmb(void) {poke(HL,regs[0]);cyclesused+=2;}
void cpuldmc(void) {poke(HL,regs[1]);cyclesused+=2;}
void cpuldmd(void) {poke(HL,regs[2]);cyclesused+=2;}
void cpuldme(void) {poke(HL,regs[3]);cyclesused+=2;}
void cpuldmh(void) {poke(HL,regs[4]);cyclesused+=2;}
void cpuldml(void) {poke(HL,regs[5]);cyclesused+=2;}
void cpuldma(void) {poke(HL,regs[7]);cyclesused+=2;}
void cpuldab(void) {regs[7]=regs[0];++cyclesused;}
void cpuldac(void) {regs[7]=regs[1];++cyclesused;}
void cpuldad(void) {regs[7]=regs[2];++cyclesused;}
void cpuldae(void) {regs[7]=regs[3];++cyclesused;}
void cpuldah(void) {regs[7]=regs[4];++cyclesused;}
void cpuldal(void) {regs[7]=regs[5];++cyclesused;}
void cpuldam(void) {regs[7]=peek(HL);cyclesused+=2;}



void cpuldmn(void) // ld [hl],#
{
	poke(HL,nexti());
	cyclesused+=3;
}
void cpuldrn(void) // ld r,#
{
	regs[(inst>>3)&7]=nexti();
	cyclesused+=2;
}
void cpuldabc(void) // ld a,[bc]
{
	regs[7]=peek(BC);
	cyclesused+=2;
}
void cpuldade(void) // ld a,[de]
{
	regs[7]=peek(DE);
	cyclesused+=2;
}
void cpuldhac(void) // ldh a,[c]
{
	regs[7]=peekff(regs[1]);
	cyclesused+=2;
}
void cpuldhca(void) // ldh [c],a
{
	poke(0xff00+regs[1],regs[7]);
	cyclesused+=2;
}
void cpuldham(void) // ldh a,[addr]
{
	regs[7]=peekff(nexti());
	cyclesused+=3;
}
void cpuldhma(void) // ldh [addr],a
{
	poke(0xff00+nexti(),regs[7]);
	cyclesused+=3;
}
void cpulda16(void) // ld a,[addr]
{
int addr;
	addr=nexti();
	regs[7]=peek(addr | (nexti()<<8));
	cyclesused+=4;
}
void cpuld16a(void) // ld [addr],a
{
int addr;
	addr=nexti();
	poke(addr | (nexti()<<8),regs[7]);
	cyclesused+=4;
}
void cpuldami(void) // ld a,[hli]
{
	regs[7]=peek(HL);
	if(!++regs[5]) ++regs[4];
	cyclesused+=2;
}
void cpuldamd(void) // ld a,[hld]
{
	regs[7]=peek(HL);
	if(!regs[5]--) --regs[4];
	cyclesused+=2;
}
void cpuldbca(void) // ld [bc],a
{
	poke(BC,regs[7]);
	cyclesused+=2;
}
void cpulddea(void) // ld [de],a
{
	poke(DE,regs[7]);
	cyclesused+=2;
}
void cpuldmia(void) // ld [hli],a
{
	poke(HL,regs[7]);
	if(!++regs[5]) ++regs[4];
	cyclesused+=2;
}
void cpuldmda(void) // ld [hld],a
{
	poke(HL,regs[7]);
	if(!regs[5]--) --regs[4];
	cyclesused+=2;
}
void cpuldddnn(void) // ld dd,nn
{
unsigned char low,high;
	low=nexti();
	high=nexti();
	switch((inst>>4) & 3)
	{
	case 0: // BC
		regs[1]=low;
		regs[0]=high;
		break;
	case 1: // DE
		regs[3]=low;
		regs[2]=high;
		break;
	case 2: // HL
		regs[5]=low;
		regs[4]=high;
		break;
	case 3: // SP
		regsp=(high<<8) | low;
		break;
	}
	cyclesused+=3;
}
void cpuldsphl(void) // ld sp,hl
{
	regsp=(regs[4]<<8) | regs[5];
	cyclesused+=2;
}
void cpupushdd(void) // push dd
{
int i;
	i=(inst>>3) & 6;
	if(i==6) ++i;
	poke(--regsp,regs[i]);
	poke(--regsp,regs[i+1]);
	cyclesused+=4;
}
void cpupopdd(void) // pop dd
{
int i;
	i=(inst>>3) & 6;
	if(i==6) ++i;
	regs[i+1]=peek(regsp++);
	regs[i]=peek(regsp++);
	cyclesused+=4;
}
void cpuldnnsp(void) // ld (nn),sp
{
int addr;
	addr=nexti();
	addr|=nexti()<<8;
	poke(addr,regsp);
	poke(addr+1,regsp>>8);
	cyclesused+=5;
}
void cpuldhlspe(void) // ldhl sp,e
{
int addr;
	addr=nexti();
	if(addr>127) addr-=256;
	addr+=regsp;
	regs[4]=addr>>8;
	regs[5]=addr;
	cyclesused+=3;
	FLAGS&=~(FLAGC|FLAGH);
	if((regsp^addr)&0x8000) FLAGS|=FLAGC;
}
unsigned char arrithpar(void)
{
	if((inst&7)==6)
	{
		cyclesused+=2;
		if(inst>=0xc0) return nexti();
		return peek(HL);
	} else
	{
		++cyclesused;
		return regs[inst&7];
	}
}
int flagsadd8(int a)
{
int b;
	b=regs[7];
	FLAGS&=~(FLAGC|FLAGH|FLAGZ|FLAGN);
	if(a+b>=0x100) FLAGS|=FLAGC;
	if((a&15)+(b&15)>=0x10) FLAGS|=FLAGH;
	if(!((a+b)&255)) FLAGS|=FLAGZ;
	return (a+b) & 255;
}
void cpuaddas(void) // add a,s
{
	regs[7]=flagsadd8(arrithpar());
}
void cpuadcas(void) // adc a,s
{
	regs[7]=flagsadd8(arrithpar() + ((FLAGS&FLAGC) ? 1 : 0));
}
int flagssub8(int a)
{
int b;
	b=regs[7];
	FLAGS&=~(FLAGC|FLAGH|FLAGZ|FLAGN);
	FLAGS|=FLAGN;
	if(b-a<0) FLAGS|=FLAGC;
	if((b&15)-(a&15)<0) FLAGS|=FLAGH;
	if(!((b-a)&255)) FLAGS|=FLAGZ;
	return (b-a) & 255;
}
void cpusubas(void) // sub a,s
{
	regs[7]=flagssub8(arrithpar());
}
void cpusbcas(void) // sbc a,s
{
	regs[7]=flagssub8(arrithpar() + ((FLAGS&FLAGC) ? 1 : 0));
}
void setzflag(int a)
{
	if(!(a&255)) FLAGS|=FLAGZ;
}
void cpuandas(void) // and a,s
{
	FLAGS&=~(FLAGC|FLAGH|FLAGZ|FLAGN);
	FLAGS|=FLAGH;
	setzflag(regs[7]&=arrithpar());
}
void cpuxoras(void) // xor a,s
{
	FLAGS&=~(FLAGC|FLAGH|FLAGZ|FLAGN);
	setzflag(regs[7]^=arrithpar());
}
void cpuoras(void) // or a,s
{
	FLAGS&=~(FLAGC|FLAGH|FLAGZ|FLAGN);
	setzflag(regs[7]|=arrithpar());
}
void cpucpas(void) // cp a,s
{
	flagssub8(arrithpar());
}
int cpuinc8(int v)
{
	FLAGS&=~(FLAGH|FLAGZ|FLAGN);
	if(v==255) FLAGS|=FLAGZ;
	if((v&15)==15) FLAGS|=FLAGH;
	return v+1;
}
void cpuincm(void) // inc [hl]
{
	poke(HL,cpuinc8(peek(HL)));
	cyclesused+=3;
}
void cpuincr(void) // inc r
{
int r;
	r=(inst>>3)&7;
	regs[r]=cpuinc8(regs[r]);
	++cyclesused;
}
int cpudec8(int v)
{
	FLAGS&=~(FLAGH|FLAGZ|FLAGN);
	if(v==1) FLAGS|=FLAGZ;
	if(!(v&15)) FLAGS|=FLAGH;
	return v-1;
}
void cpudecm(void) // dec [hl]
{
	poke(HL,cpudec8(peek(HL)));
	cyclesused+=3;
}
void cpudecr(void) // dec r
{
int r;
	r=(inst>>3)&7;
	regs[r]=cpudec8(regs[r]);
	++cyclesused;
}
void cpudecss(void) // dec dd
{
int r;
	r=(inst>>3)&6;
	if(r==6)
		--regsp;
	else
		if(!regs[r+1]--) --regs[r]; // warn if fe00-feff range
	cyclesused+=2;
}
void cpuincss(void) // inc dd
{
int r;
	r=(inst>>3)&6;
	if(r==6)
		++regsp;
	else
		if(!++regs[r+1]) ++regs[r]; // warn if fe00-feff range
	cyclesused+=2;
}
void cpuaddhlss(void) // add hl,dd
{
int r,a,b;
	r=(inst>>3)&6;
	if(r==6)
		a=regsp;
	else
		a=(regs[r]<<8) | regs[r+1];
	FLAGS&=~(FLAGN|FLAGC|FLAGH);
	b=HL+a;
	if(b>=0x10000) FLAGS|=FLAGC;
	if(regs[5]+(a&255)>=256) FLAGS|=FLAGH;
	regs[5]=b;
	regs[4]=b>>8;
	cyclesused+=2;
}
void cpuaddspe(void) // add sp,e
{
int a,b;
	FLAGS&=~(FLAGN|FLAGC|FLAGH|FLAGZ);
	b=nexti();
	if(b>127) b-=256;
	a=regsp;
	a+=b;
	if(a<0 || a>=0x10000) FLAGS|=FLAGC;
	regsp=a;
	cyclesused+=4;
}
void cpurots(void) // rot m
{
int reg,rot,val,carrybit=0,oldcarry;
	rot=(inst>>3)&7;
	reg=inst&7;
	oldcarry=FLAGS&FLAGC;
	FLAGS&=~(FLAGN|FLAGC|FLAGH|FLAGZ);
	if(reg==6) {cyclesused+=4;val=peek(HL);}
	else {cyclesused+=2;val=regs[reg];}
	switch(rot)
	{
	case 0: // rlc
		carrybit=val&0x80;
		val<<=1;
		if(carrybit) ++val;
		break;
	case 1: // rrc
		carrybit=val&0x01;
		val>>=1;
		if(carrybit) val+=128;
		break;
	case 2: // rl
		carrybit=val&0x80;
		val<<=1;
		if(oldcarry) ++val;
		break;
	case 3: // rr
		carrybit=val&0x01;
		val>>=1;
		if(oldcarry) val+=128;
		break;
	case 4: // sla
		carrybit=val&0x80;
		val<<=1;
		break;
	case 5: // sra
		carrybit=val&0x01;
		val=(val&0x80) | (val>>1);
		break;
	case 6: // swap
		val=((val&0x0f)<<4) | ((val&0xf0)>>4);
		carrybit=0;
		break;
	case 7: // srl
		carrybit=val&0x01;
		val>>=1;
		break;
	}
	if(carrybit) FLAGS|=FLAGC;
	if(!(val&=255)) FLAGS|=FLAGZ;
	if(reg==6) poke(HL,val);
	else regs[reg]=val;
}
void cpurotsa(void) // rlca/rrca/rla/rra
{
int rot,val,carrybit=0,oldcarry;
	rot=(inst>>3)&3;
	oldcarry=FLAGS&FLAGC;
	FLAGS&=~(FLAGN|FLAGC|FLAGH|FLAGZ);
	++cyclesused;
	val=regs[7];
	switch(rot)
	{
	case 0: // rlca
		carrybit=val&0x80;
		val<<=1;
		if(carrybit) ++val;
		break;
	case 1: // rrca
		carrybit=val&0x01;
		val>>=1;
		if(carrybit) val+=128;
		break;
	case 2: // rla
		carrybit=val&0x80;
		val<<=1;
		if(oldcarry) ++val;
		break;
	case 3: // rra
		carrybit=val&0x01;
		val>>=1;
		if(oldcarry) val+=128;
		break;
	}
	if(carrybit) FLAGS|=FLAGC;
	if(!(val&=255)) FLAGS|=FLAGZ;
	regs[7]=val;
}
void cpudi(void) // di
{
	disabled=1;
	++cyclesused;
}
void cpuei(void) // ei
{
	disabled=0;
	++cyclesused;
}
void cpuccf(void) // ccf
{
	FLAGS^=FLAGC;
	++cyclesused;
}
void cpuscf(void) // scf
{
	FLAGS|=FLAGC;
	++cyclesused;
}
void cpunop(void) // nop
{
	++cyclesused;
}
void cpucpl(void) // cpl
{
	FLAGS|=FLAGH|FLAGN;
	regs[7]^=255;
	++cyclesused;
}
void cpubits(void) // bit,set,res, rots
{
int type,reg,bit,val;

	type=nexti();
	if(!(type&0xc0))
	{
		inst=type;
		cpurots();
		return;
	}
	cyclesused+=2;
	bit=1 << ((type>>3)&7);
	reg=type&7;
	if(reg==6) {val=peek(HL);++cyclesused;}
	else val=regs[reg];
	type>>=6;
	switch(type)
	{
	case 1: // bit b,s
		FLAGS&=~(FLAGZ|FLAGN);
		FLAGS|=FLAGH;
		if(!(bit&val)) FLAGS|=FLAGZ;
		break;
	case 2: // res b,s
		val&=~bit;
		break;
	case 3: // set b,s
		val|=bit;
		break;
	}
	if(type!=1)
	{
		if(reg==6) {poke(HL,val);++cyclesused;}
		else regs[reg]=val;
	}
}
void cpujpnn(void) // jp nn
{
int addr;
	addr=nexti();
	addr |= nexti()<<8;
	regpc=addr;
	cyclesused+=4;
}
int condition(void)
{
	switch(inst&0x18)
	{
	default:
	case 0x00: // nz
		return !(FLAGS&FLAGZ);
	case 0x08: // z
		return FLAGS&FLAGZ;
	case 0x10: // nc
		return !(FLAGS&FLAGC);
	case 0x18: // c
		return FLAGS&FLAGC;
	}
}
void cpujpccnn(void) // jp cc,nn
{
int addr;
	addr=nexti();
	addr|=nexti()<<8;
	if(condition()) {++cyclesused;regpc=addr;}
	cyclesused+=3;
}
void cpujre(void) // jr e
{
int delta;
	delta=nexti();
	if(delta>127) delta-=256;
	regpc+=delta;
	cyclesused+=3;
}
void cpujrcce(void) // jr cc,e
{
int delta;
	delta=nexti();
	if(delta>127) delta-=256;
	if(condition()) {++cyclesused;regpc+=delta;}
	cyclesused+=2;
}
void cpujphl(void) // jp [hl]
{
	regpc=HL;
	++cyclesused;
}
void cpucallnn(void) // call nn
{
int addr;
	addr=nexti();
	addr|=nexti()<<8;
	poke(--regsp,regpc>>8);
	poke(--regsp,regpc);
	regpc=addr;
	cyclesused+=6;
}
void cpuirq(int addr) // interrupt to addr
{
	addr&=0xffff;
	if(peek(regpc)==0x76) ++regpc; // halt
	poke(--regsp,regpc>>8);
	poke(--regsp,regpc);
	regpc=addr;
	disabled=1;
	cyclesused+=3;
}

void cpucallccnn(void) // call cc,nn
{
int addr;
	addr=nexti();
	addr|=nexti()<<8;
	if(condition())
	{
		poke(--regsp,regpc>>8);
		poke(--regsp,regpc);
		regpc=addr;
		cyclesused+=6;
	} else
		cyclesused+=3;
}
void cpuret(void) // ret
{
int addr;
	addr=peek(regsp++);
	addr|=peek(regsp++)<<8;
	regpc=addr;
	cyclesused+=4;
}
void cpureti(void) // reti
{
	disabled=0;
	cpuret();
}
void cpuretcc(void) // ret cc
{
	if(condition()) {cpuret();++cyclesused;}
	else cyclesused+=2;
}
void cpurstt(void) // rst t
{
	poke(--regsp,regpc>>8);
	poke(--regsp,regpc);
	regpc=inst&0x38;
	cyclesused+=4;
}

void cpudaa(void) // daa
{
int i;
	i=regs[7];
	if(FLAGS&FLAGC) i|=256;
	if(FLAGS&FLAGH) i|=512;
	if(FLAGS&FLAGN) i|=1024;
	i=daat[i];
	regs[7]=i>>8;
	FLAGS&=~(FLAGH|FLAGC|FLAGZ);
	if(i&0x40) FLAGS|=FLAGZ;
	if(i&1) FLAGS|=FLAGC;
	++cyclesused;
}

void cpuerror(void) // illegal op code
{
	printf("%02x:%04x Illegal op code %02x\n",oldbank,pcold,inst);
}
void cpustop(void)
{
	nexti();
}
void cpudebug(void)
{
char temp[16];
static int lastcycledelta=0,maxcycledelta=0;
	switch(nexti())
	{
	case 0:	// print ACC
		dco(regs[7]);
		break;
	case 1:	// print ACC as hex
		sprintf(temp,"%02x",regs[7]);
		dco(*temp);
		dco(temp[1]);
		break;
	case 2:	// print cycle count since last
		ddprintf("%d\n",cycledelta-lastcycledelta);
	case 3:	// reset cycle count
		lastcycledelta=cycledelta;
		break;
	case 4:	// print cycle count since last if bigger
		if(cycledelta-lastcycledelta>maxcycledelta)
		{
			maxcycledelta=cycledelta-lastcycledelta;
			ddprintf("%d\n",maxcycledelta);
		}
		lastcycledelta=cycledelta;
		break;
	case 5:	// clear out max value of cycle count
		maxcycledelta=0;
		lastcycledelta=cycledelta;
		break;
	}
}

void (*handlers[])()=
{
cpunop, // 00
cpuldddnn, // 01
cpuldbca, // 02
cpuincss, // 03
cpuincr, // 04
cpudecr, // 05
cpuldrn, // 06
cpurotsa, // 07
cpuldnnsp, // 08
cpuaddhlss, // 09
cpuldabc, // 0a
cpudecss, // 0b
cpuincr, // 0c
cpudecr, // 0d
cpuldrn, // 0e
cpurotsa, // 0f
cpustop, // 10
cpuldddnn, // 11
cpulddea, // 12
cpuincss, // 13
cpuincr, // 14
cpudecr, // 15
cpuldrn, // 16
cpurotsa, // 17
cpujre, // 18
cpuaddhlss, // 19
cpuldade, // 1a
cpudecss, // 1b
cpuincr, // 1c
cpudecr, // 1d
cpuldrn, // 1e
cpurotsa, // 1f
cpujrcce, // 20
cpuldddnn, // 21
cpuldmia, // 22
cpuincss, // 23
cpuincr, // 24
cpudecr, // 25
cpuldrn, // 26
cpudaa, // 27
cpujrcce, // 28
cpuaddhlss, // 29
cpuldami, // 2a
cpudecss, // 2b
cpuincr, // 2c
cpudecr, // 2d
cpuldrn, // 2e
cpucpl, // 2f
cpujrcce, // 30
cpuldddnn, // 31
cpuldmda, // 32
cpuincss, // 33
cpuincm, // 34
cpudecm, // 35
cpuldmn, // 36
cpuscf, // 37
cpujrcce, // 38
cpuaddhlss, // 39
cpuldamd, // 3a
cpudecss, // 3b
cpuincr, // 3c
cpudecr, // 3d
cpuldrn, // 3e
cpuccf, // 3f
cpunop, // 40
cpuldbc, // 41
cpuldbd, // 42
cpuldbe, // 43
cpuldbh, // 44
cpuldbl, // 45
cpuldbm, // 46
cpuldba, // 47
cpuldcb, // 48
cpunop, // 49
cpuldcd, // 4a
cpuldce, // 4b
cpuldch, // 4c
cpuldcl, // 4d
cpuldcm, // 4e
cpuldca, // 4f
cpulddb, // 50
cpulddc, // 51
cpunop, // 52
cpuldde, // 53
cpulddh, // 54
cpulddl, // 55
cpulddm, // 56
cpuldda, // 57
cpuldeb, // 58
cpuldec, // 59
cpulded, // 5a
cpunop, // 5b
cpuldeh, // 5c
cpuldel, // 5d
cpuldem, // 5e
cpuldea, // 5f
cpuldhb, // 60
cpuldhc, // 61
cpuldhd, // 62
cpuldhe, // 63
cpunop, // 64
cpuldhl, // 65
cpuldhm, // 66
cpuldha, // 67
cpuldlb, // 68
cpuldlc, // 69
cpuldld, // 6a
cpuldle, // 6b
cpuldlh, // 6c
cpunop, // 6d
cpuldlm, // 6e
cpuldla, // 6f
cpuldmb, // 70
cpuldmc, // 71
cpuldmd, // 72
cpuldme, // 73
cpuldmh, // 74
cpuldml, // 75
cpuhalt, // 76
cpuldma, // 77
cpuldab, // 78
cpuldac, // 79
cpuldad, // 7a
cpuldae, // 7b
cpuldah, // 7c
cpuldal, // 7d
cpuldam, // 7e
cpunop, // 7f
cpuaddas, // 80
cpuaddas, // 81
cpuaddas, // 82
cpuaddas, // 83
cpuaddas, // 84
cpuaddas, // 85
cpuaddas, // 86
cpuaddas, // 87
cpuadcas, // 88
cpuadcas, // 89
cpuadcas, // 8a
cpuadcas, // 8b
cpuadcas, // 8c
cpuadcas, // 8d
cpuadcas, // 8e
cpuadcas, // 8f
cpusubas, // 90
cpusubas, // 91
cpusubas, // 92
cpusubas, // 93
cpusubas, // 94
cpusubas, // 95
cpusubas, // 96
cpusubas, // 97
cpusbcas, // 98
cpusbcas, // 99
cpusbcas, // 9a
cpusbcas, // 9b
cpusbcas, // 9c
cpusbcas, // 9d
cpusbcas, // 9e
cpusbcas, // 9f
cpuandas, // a0
cpuandas, // a1
cpuandas, // a2
cpuandas, // a3
cpuandas, // a4
cpuandas, // a5
cpuandas, // a6
cpuandas, // a7
cpuxoras, // a8
cpuxoras, // a9
cpuxoras, // aa
cpuxoras, // ab
cpuxoras, // ac
cpuxoras, // ad
cpuxoras, // ae
cpuxoras, // af
cpuoras, // b0
cpuoras, // b1
cpuoras, // b2
cpuoras, // b3
cpuoras, // b4
cpuoras, // b5
cpuoras, // b6
cpuoras, // b7
cpucpas, // b8
cpucpas, // b9
cpucpas, // ba
cpucpas, // bb
cpucpas, // bc
cpucpas, // bd
cpucpas, // be
cpucpas, // bf
cpuretcc, // c0
cpupopdd, // c1
cpujpccnn, // c2
cpujpnn, // c3
cpucallccnn, // c4
cpupushdd, // c5
cpuaddas, // c6
cpurstt, // c7
cpuretcc, // c8
cpuret, // c9
cpujpccnn, // ca
cpubits, // cb
cpucallccnn, // cc
cpucallnn, // cd
cpuadcas, // ce
cpurstt, // cf
cpuretcc, // d0
cpupopdd, // d1
cpujpccnn, // d2
cpuerror, // d3
cpucallccnn, // d4
cpupushdd, // d5
cpusubas, // d6
cpurstt, // d7
cpuretcc, // d8
cpureti, // d9
cpujpccnn, // da
cpudebug, // db
cpucallccnn, // dc
cpuerror, // dd
cpusbcas, // de
cpurstt, // df
cpuldhma, // e0
cpupopdd, // e1
cpuldhca, // e2
cpuerror, // e3
cpuerror, // e4
cpupushdd, // e5
cpuandas, // e6
cpurstt, // e7
cpuaddspe, // e8
cpujphl, // e9
cpuld16a, // ea
cpuerror, // eb
cpuerror, // ec
cpuerror, // ed
cpuxoras, // ee
cpurstt, // ef
cpuldham, // f0
cpupopdd, // f1
cpuldhac, // f2
cpudi, // f3
cpuerror, // f4
cpupushdd, // f5
cpuoras, // f6
cpurstt, // f7
cpuldhlspe, // f8
cpuldsphl, // f9
cpulda16, // fa
cpuei, // fb
cpuerror, // fc
cpuerror, // fd
cpucpas, // fe
cpurstt, // ff

};

#define RAMNAME ".ram"

void readbbram(void)
{
char t[256];
int f;
	int res;
	sprintf(t,"%s%s",basefname,RAMNAME);
	f=open(t,O_RDONLY|O_BINARY);
	if(f<0) return;
	res=read(f,ramblock+0xa000,0x2000);
	close(f);
}

void writebbram(void)
{
char t[256];
int f;
	int res;
	sprintf(t,"%s%s",basefname,RAMNAME);
	f=open(t,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,0644);
	if(f<0) return;
	res=write(f,ramblock+0xa000,0x2000);
	close(f);
}

void initcpu(void)
{
	timerdiv=tma=tima=tac=0;
	timermax=256;
	cyclecount=0;
	lc=0;
	oldvalid=0;
	memset(&objpal,0,sizeof(objpal));
	memset(&bgpal,0,sizeof(bgpal));
	colors();
	cyclechange=0;
	hs2=0xff;
	mie=0;
	hie=0;
	ihistoryin=0;
	lycmatch=0;
	memset(ramblock,0,RAMSIZE);
	readbbram();
	memset(stripblock,0,STRIPSIZE);
	currentbank=1;
	rombank=romblock+(currentbank<<14);
	cgbrambank=ramblock+0x1000;
	regpc=0x100;
	regsp=0xfffe;
	cyclesused=0;
	striplookup=striplookupblock+256;
	memset(regs,0,sizeof(regs));
	regs[7]=(hMachine==GMB) ? 1 : 0x11;
	disabled=1;
	irq=0;
	memset(&v1,0,sizeof(v1));
	v1.duty=duty125;
	memset(&v2,0,sizeof(v2));
	v2.duty=duty250;
	memset(&v3,0,sizeof(v3));
	memset(&v4,0,sizeof(v4));

}

int stepone(void)
{
unsigned char flags;
static char framecount2;
static unsigned char fdelay=0;

	cyclesused=0;
	if(irq && !disabled)
	{
		if(irq&1) {irq&=~1;cpuirq(0x40);}
		else if(irq&2) {irq&=~2;cpuirq(0x48);}
		else if(irq&4) {irq&=~4;cpuirq(0x50);}
	}
	if(checkbreak()) {oldvalid=0;return 1;}
	oldvalid=1;

	pcold=regpc;
	oldbank=currentbank;
	ihistory[ihistoryin++&(IHISTORYSIZE-1)]=(currentbank<<16) | regpc;
	inst=nexti();
	handlers[inst]();
	hs1=hs2;

	cycledelta+=cyclesused;
	if(!doublespeed)
		cyclecount+=cyclesused;
	else
	{
		cyclechange+=cyclesused;
		cyclecount+=cyclechange>>1;
		cyclechange&=1;
	}
	hs2=hstat[cyclecount];
	if(tac&4)
	{
		timerdiv+=cyclesused;
		if(timerdiv>=timermax)
		{
			timerdiv&=timermax-1;
			++tima;
			if(!tima)
			{
				tima=tma;
				if(mie&4)
					irq|=4;
			}
		}
	}

	flags=fdelay;
	fdelay=~hs1 & hs2 & 0xf8;
	if(flags)
	{
		if((flags&0x10) && (mie&1))
			irq|=1;
		if((flags&0x38&hie) && (mie&2))
			irq|=2;
		if(flags&0x20)
		{
			if(ramblock[0xff45]==vline[cyclecount])
			{
				if((mie&2) && (hie&0x40))
					irq|=2;
				lycmatch|=4;
			} else
				lycmatch&=~4;
		}
		if(flags&0x80)
		{
			if(!fast || !(framecount2&7))
				buildline(lc);
			++lc;
		}
	}
	if(cyclecount>=154*114)
	{
		cyclecount-=154*114;
		lc=0;
		if(!fast || !(framecount2&7))
			updategb();
		++framecount;
		++framecount2;
	}
//	return checkbreak();
	return 0;
}
int cpu(int numcycles)
{
int res;
static int cyclesleft=0;

	doublespeed=(hMachine==CGB && (ramblock[0xff4d]&0x80));
	cyclesleft+=doublespeed ? (numcycles<<1) : numcycles;

	res=0;
	while(!res && cyclesleft>0)
	{
		res=stepone();
		cyclesleft-=cyclesused;
	}
	return res;
}
int disprint(unsigned char bank,unsigned short addr)
{
char disline[80];
int size;
	size=disz80(bank,addr,disline);
	ddprintf("%02x:%-30s %-30s\n",bank,getname(bank,addr),disline);
	return size;
}
void shregs(void)
{
char flagstr[8],*p;

	p=flagstr;
	*p++=(FLAGS&FLAGZ) ? 'Z' : ' ';
	*p++=(FLAGS&FLAGN) ? 'N' : ' ';
	*p++=(FLAGS&FLAGH) ? 'H' : ' ';
	*p++=(FLAGS&FLAGC) ? 'C' : ' ';
	*p++=disabled ? 'D' : 'E';
	*p=0;
	ddprintf("AF:%02x%02x BC:%02x%02x DE:%02x%02x HL:%02x%02x SP:%04x [%s] %05d Y%03d D%08d\n",
		regs[7],FLAGS,regs[0],regs[1],regs[2],regs[3],regs[4],regs[5],regsp,
		flagstr,cyclecount,vline[cyclecount],cycledelta-deltasave);
	handleview();
	if(oldvalid)
		disprint(oldbank,pcold);
	else
		ddprintf("--:----\n");
	disprint(currentbank,regpc);
}

int cputos(void)
{
	return peek(regsp) | (peek(regsp+1)<<8);
}
