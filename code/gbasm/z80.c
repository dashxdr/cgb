#include "asm.h"
#include <ctype.h>


void dorefs(int size) {
int i,j;
int t1,t2;
struct sym *s,*s1,*s2;

	if(!pass || !relsp) return;
	for(i=0;i<relsp-1;++i)
	{
		if(!(s1=rellist[i].sym) || !(s1->symflags&ADEF)) continue;
		t1=rellist[i].type;
		for(j=i+1;j<relsp;++j)
		{
			if(!(s2=rellist[j].sym) || !(s2->symflags&ADEF)) continue;
			t2=rellist[j].type;
			if(t1==REFNORMAL && t2==REFNEG || t2==REFNORMAL && t1==REFNEG)
			{
				rellist[i].sym=rellist[j].sym=0;
				break;
			}
		}
	}
	for(i=0;i<relsp;++i)
	{
		s=rellist[i].sym;
		if(!s) continue;
		switch(rellist[i].type)
		{
		case REFNORMAL:
			if(size==1)
			{
				addref(s,LINKLOW8);
				break;
			}
			if(s->symflags&ADEF)
				addreloc(2);
			else
				addref(s,LINK16REF);
			break;
		case REFLOW:
			if(size!=1) {outofrange();break;}
			addref(s,LINKLOW8);
			break;
		case REFHIGH:
			if(size!=1) {outofrange();break;}
			addref(s,LINKHIGH8);
			break;
		case REFBANK:
			if(size!=1) {outofrange();break;}
			addref(s,LINKBANK8);
			break;
		case REFNEG:
			if(size!=2) {outofrange();break;}
/*
			if(s->symflags&ADEF)
				error2("wtf!");
			else
*/
				addref(s,LINK16NREF);
			break;
		}
	}
}

void z808(void)
{
	expr();
	dorefs(1);
/*
	if(pass && exprtype==XREFTYPE)
		addref(lastxref,lastxreftype);
*/
	bout(exprval);
}

void z8016(void)
{
int flags;

//	lastnref=0;
	expr();
	dorefs(2);
/*
	if(pass && exprtype==RELTYPE)
	{
		flags=lastrel->symflags;
		if((flags&APUBLIC) && !(flags&ADEF))
			addref(lastrel,LINK16REF);
		if(flags&ADEF)
			addreloc(2);
		if(lastnref)
			addref(lastnref,LINK16NREF);
	}
*/
	if(pass && exprtype==XREFTYPE) badvalue();
	bout(exprval);
	bout(exprval>>8);
}
#define Z80INDC 0
#define Z80INDHLI 1
#define Z80INDHLD 2
#define Z80INDBC 3
#define Z80INDDE 4

int z80regind()
{
uchar ch;
	if(at()!='[') return -1;
	get();
	ch=lowercase[get()];
	switch(ch)
	{
	case 'c':
		if(at()==']') {get();return Z80INDC;}
		break;
	case 'h':
		if(lowercase[at()]=='l')
		{
			ch=lowercase[ahead(1)];
			if(ch=='i' && ahead(2)==']')
				{get();get();get();return Z80INDHLI;}
			if(ch=='d' && ahead(2)==']')
				{get();get();get();return Z80INDHLD;}
		}
		break;
	case 'b':
		if(lowercase[at()]=='c' && ahead(1)==']')
			{get();get();return Z80INDBC;}
		break;
	case 'd':
		if(lowercase[at()]=='e' && ahead(1)==']')
			{get();get();return Z80INDDE;}
		break;
	}
	back();
	back();
	return -1;
}
int z80r82()
{
	char ch;

	ch=get();
	if(isoksym(ch) && !isoksym(at()))
		switch(lowercase[ch])
		{
		case 'b': return 0;
		case 'c': return 1;
		case 'd': return 2;
		case 'e': return 3;
		case 'h': return 4;
		case 'l': return 5;
		case 'a': return 7;
		}
	else if(ch=='[')
	{
		if(lowercase[at()]=='h' && lowercase[ahead(1)]=='l' && ahead(2)==']')
		{
			get();
			get();
			get();
			return 6;
		}
	}
	back();
	return -1;
}
int z80r8(void)
{
int reg;
	reg=z80r82();
	if(reg>=0) return reg;
	badreg();
	return 0;
}



int z80r162(void)
{
	char ch;

	ch=get();

	switch(lowercase[ch])
	{
		case 'b':
			ch=lowercase[get()];
			if(ch!='c' || isoksym(at())) {back();break;}
			return 0x00;
		case 'd':
			ch=lowercase[get()];
			if(ch!='e' || isoksym(at())) {back();break;}
			return 0x10;
		case 'h':
			ch=lowercase[get()];
			if(ch!='l' || isoksym(at())) {back();break;}
			return 0x20;
		case 's':
			ch=lowercase[get()];
			if(ch!='p' || isoksym(at())) {back();break;}
			return 0x30;
		case 'a':
			ch=lowercase[get()];
			if(ch!='f' || isoksym(at())) {back();break;}
			return 0x30;
	}
	back();
	return -1;
}
int z80r16(void)
{
	int reg;
	reg=z80r162();
	if(reg>=0) return reg;
	badreg();
	return 0;
}

int z80cond(void)
{
	char ch,ch2;
	char cond;
	char n=1;

	ch=lowercase[get()];
	if(ch=='n')
	{
		n=0;
		ch=lowercase[get()];
	}
	if(ch=='z' || ch=='c')
	{
		ch2=at();
		if(!isalpha(lowercase[ch2]) && !isdigit(ch2) && ch2!='_' && ch2!='.')
			return n | ((ch=='z') ? 0 : 2);
	}
	back();
	if(!n) back();
	return -1;
}


void z80ld(void)
{
int reg1,reg2;
	reg1=z80r162();
	if(reg1>=0)
	{
		if(comma()) return;
		reg2=z80r162();
		if(reg1==0x30 && reg2==0x20)
		{
			bout(0xf9);
		} else if(reg2>=0)
			badreg();
		else
		{
			bout(reg1|1);
			z8016();
		}
		return;
	}
	reg1=z80r82();
	if(reg1>=0)
	{
		if(comma()) return;
		reg2=z80r82();
		if(reg2>=0)
		{
			bout(0x40 | (reg1<<3) | reg2);
			return;
		}
		if(reg1==7)
			switch(z80regind())
			{
			case Z80INDC: bout(0xf2);return;
			case Z80INDHLI: bout(0x2a);return;
			case Z80INDHLD: bout(0x3a);return;
			case Z80INDBC: bout(0x0a);return;
			case Z80INDDE: bout(0x1a);return;
			}
		if(at()=='[')
		{
			get();
			if(reg1!=7) {badmode();return;}
			bout(0xfa);
			z8016();
			if(at()!=']') syntaxerr();
			return;
		}
		bout((reg1<<3)|6);
		z808();
		return;
	}
	reg1=z80regind();
	if(reg1>=0)
	{
		if(comma()) return;
		reg2=z80r8();
		if(reg2!=7) {badmode();return;}
		switch(reg1)
		{
		case Z80INDC: bout(0xe2);return;
		case Z80INDHLI: bout(0x22);return;
		case Z80INDHLD: bout(0x32);return;
		case Z80INDBC: bout(0x02);return;
		case Z80INDDE: bout(0x12);return;
		}
	}
	if(at()!='[') {badmode();return;}
	get();
	bout(0xea);
	z8016();
	if(at()!=']') {syntaxerr();return;}
	get();
	if(comma()) return;
	reg2=z80r82();
	if(reg2==7) return;
	if(reg2>=0) {badreg();return;}
	reg2=z80r162();
	if(reg2!=0x30) {badreg();return;}
	boutdoctor(-3,0x08);
}
void z80ldh(void)
{
int reg1,reg2;
	reg1=z80r82();
	if(reg1>=0)
	{
		if(reg1!=7) {badreg();return;}
		if(comma()) return;
		if(at()!='[') {syntaxerr();return;}
		get();
		bout(0xf0);
		z808();
		if(exprval<0 || exprval>0xffff || exprval>=0x100 && exprval<0xff00)
			outofrange();
		if(at()!=']') syntaxerr();
		else get();
		return;
	}
	if(at()!='[') {syntaxerr();return;}
	get();
	bout(0xe0);
	z808();
	if(exprval<0 || exprval>0xffff || exprval>=0x100 && exprval<0xff00)
		outofrange();
	if(at()!=']') {syntaxerr();return;}
	get();
	if(comma()) return;
	reg2=z80r82();
	if(reg2!=7) {badreg();return;}
}


void z80bitops(uchar op)
{
int reg;

	bout(0xcb);
	expr();
	if(exprval!=(exprval&7)) badvalue();
	if(!comma())
		reg=z80r8();
	else
		reg=0;
	bout(op | (exprval<<3) | reg);
}

void z80bit(void){z80bitops(0x40);}
void z80set(void){z80bitops(0xc0);}
void z80res(void){z80bitops(0x80);}

void z80ldhl(void)
{
	if(z80r16()!=0x30) {badreg();return;}
	if(comma()) return;
	expr();
	if(exprval<-0x80 || exprval>0x7f) outofrange();
	bout(0xf8);
	bout(exprval);
}


void z80rots(uchar op)
{
uchar reg;

	bout(0xcb);
	reg=z80r8();
	bout(op | reg);
}
void z80rlca(void){bout(0x07);}
void z80rrca(void){bout(0x0f);}
void z80rla(void){bout(0x17);}
void z80rra(void){bout(0x1f);}
void z80rlc(void){z80rots(0x00);}
void z80rrc(void){z80rots(0x08);}
void z80rl(void){z80rots(0x10);}
void z80rr(void){z80rots(0x18);}
void z80sla(void){z80rots(0x20);}
void z80sra(void){z80rots(0x28);}
void z80swap(void){z80rots(0x30);}
void z80srl(void){z80rots(0x38);}

void z80arrith(op)
char op;
{
int reg;
	reg=z80r82();
	if(reg==7 && at()==',')
	{
		get();
		reg=z80r82();
	}
	if(reg<0)
	{
		bout(op|0x46);
		z808();
	} else
		bout(op|reg);
}
void z80xor(void){z80arrith(0xa8);}
void z80sub(void){z80arrith(0x90);}
void z80sbc(void){z80arrith(0x98);}
void z80or(void){z80arrith(0xb0);}
void z80adc(void){z80arrith(0x88);}
void z80add(void)
{
int reg;
	reg=z80r162();
	if(reg<0)
		z80arrith(0x80);
	else if(reg==0x20) // hl
	{
		if(comma()) return;
		reg=z80r16();
		bout(reg|9);
	} else if(reg==0x30) // sp
	{
		if(comma()) return;
		bout(0xe8);
		expr();
		bout(exprval);
		if(exprval<-0x80 || exprval>0x7f) outofrange();
	}
}
void z80and(void){z80arrith(0xa0);}
void z80cp(void){z80arrith(0xb8);}
void z80abs(op)
char op;
{
	int	res;
	bout(op);
	z8016();
}
void z80call(void)
{
int cond;
	cond=z80cond();
	if(cond<0)
		z80abs(0xcd);
	else
	{
		if(comma()) return;
		z80abs(0xc4 | (cond<<3));
	}
}
void z80cm(void){z80abs(0xfc);}
void z80cpl(void){bout(0x2f);}
void z80ccf(void){bout(0x3f);}
void z80scf(void){bout(0x37);}

void z80daa(void){bout(0x27);}
void z80incdec(char op)
{
int reg;
	reg=z80r162();
	if(reg>=0)
		bout((op<<3) | 3 | reg);
	else
	{
		reg=z80r8();
		bout(op | 4 | (reg<<3));
	}
}
void z80inc(void){z80incdec(0);}
void z80dec(void){z80incdec(1);}
void z80di(void){bout(0xf3);}
void z80ds(void){dodsb();}
void z80db(void)
{
	uchar ch;
	if(bsshunk)
	{
		bout(0);
		return;
	}
	for(;;)
	{
		ch=at();
		if(ch==LF) break;
		if(ch==',') {syntaxerr();return;}
		if(ch==QUOTECHAR)
		{
			get();
			while((ch=get())!=LF)
			{
				if(ch==QUOTECHAR)
				{
					if((ch=get())!=QUOTECHAR) break;
					bout(ch);continue;
				}
				bout(ch);
			}
			back();
		} else
		{
			z808();
		}
		ch=skipwhite();
		if(ch!=',') break;
		get();
		skipwhite();
	}
}

void z80dw(void)
{
	if(bsshunk)
	{
		bout(0);
		bout(0);
		return;
	}
	for(;;)
	{
		z8016();
		if(get()!=',') break;
	}
	back();
}
void z80ei(void){bout(0xfb);}
void z80halt(void){bout(0x76);}
void z80stop(void){bout(0x10);bout(0);}
void z80jp(void)
{
int cond;

	if(at()=='[')
	{
		get();
		if(lowercase[get()]=='h' && lowercase[get()]=='l' && get()==']')
		{
			bout(0xe9);
			return;
		}
		back();
		syntaxerr();
		return;
	}
	cond=z80cond();
	if(cond<0)
		z80abs(0xc3);
	else
	{
		if(comma()) return;
		z80abs(0xc2 | (cond<<3));
	}
}
void z80rels(op)
char op;
{
	long off;

	bout(op);
	expr();
	off=exprval-pcount-1;
	bout((int)off);
	if(off<-0x80 || off>0x7f) outofrange();
}
void z80jr(void)
{
int cond;
	cond=z80cond();
	if(cond<0)
		z80rels(0x18);
	else
	{
		if(comma()) return;
		z80rels(0x20 | (cond<<3));
	}
}
void z80nop(void){bout(0x00);}
void z80ops16(unsigned char op)
{
	int reg;
	reg=z80r16();
	bout(op | reg);
}
void z80pop(void){z80ops16(0xc1);}
void z80push(void){z80ops16(0xc5);}
void z80ret(void)
{
int cond;
	cond=z80cond();
	if(cond<0)
		bout(0xc9);
	else
		bout(0xc0 | (cond<<3));
}
void z80reti(void){bout(0xd9);}
void z80rst(void)
{
	char ch;

	expr();
	ch=exprval;
	ch&=7;
	bout(0xc7 | (ch<<3));
}
void z80stc(void){bout(0x37);}


void z80ax(op)
char op;
{
	char r1;
	r1=z80r16();
	if(r1>=0x20) badreg();
	else bout(op | r1);
}



struct anopcode z80codes[]={
{"adc",z80adc},
{"add",z80add},
{"and",z80and},
{"bit",z80bit},
{"call",z80call},
{"ccf",z80ccf},
{"cp",z80cp},
{"cpl",z80cpl},
{"daa",z80daa},
{"db",z80db},
{"dec",z80dec},
{"di",z80di},
{"ds",z80ds},
{"dw",z80dw},
{"ei",z80ei},
{"halt",z80halt},
{"inc",z80inc},
{"jp",z80jp},
{"jr",z80jr},
{"ld",z80ld},
{"ldh",z80ldh},
{"ldhl",z80ldhl},
{"ldio",z80ldh},
{"nop",z80nop},
{"or",z80or},
{"pop",z80pop},
{"push",z80push},
{"res",z80res},
{"ret",z80ret},
{"reti",z80reti},
{"rl",z80rl},
{"rla",z80rla},
{"rlc",z80rlc},
{"rlca",z80rlca},
{"rr",z80rr},
{"rra",z80rra},
{"rrc",z80rrc},
{"rrca",z80rrca},
{"rst",z80rst},
{"sbc",z80sbc},
{"scf",z80scf},
{"set",z80set},
{"sla",z80sla},
{"sra",z80sra},
{"srl",z80srl},
{"stc",z80stc},
{"stop",z80stop},
{"sub",z80sub},
{"swap",z80swap},
{"xor",z80xor},
{0}};
