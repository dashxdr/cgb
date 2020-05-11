#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <ctype.h>
#include "expr.h"
#include "debug.h"

typedef unsigned char uchar;
#define EXPRMAX 32
uchar exprstack[EXPRMAX];
uchar *exprsp;
short oppri;
short opop;
int operval;
uchar exprflag;
int expr2();
char *exprpnt;
int exprval;
char *exprerr;
char *unbalancedmsg="Unbalanced parenthesis";
char *unbalancedqmsg="Unbalanced single quote expression";
char *badopmsg="Illegal operation";
char *syntaxerrmsg="Syntax error";
char *unknownerr="Unknown symbol";

int at(void)
{
	return *exprpnt;
}

int get(void)
{
	return *exprpnt++;
}
int back(void)
{
	return *--exprpnt;
}

int isoknum(uchar ach)
{
	return ach>='0' && ach<='9';
}
int ishex(uchar ach)
{
	return isoknum(ach) || (ach>='a' && ach<='f');
}
int tohex(uchar ach)
{
	return ach<'a' ? ach-'0' : ach-'a'+10;
}


void pushl(int val)
{
	*(int *)exprsp=val;
	exprsp+=4;
}
void pushb(uchar val)
{
	*exprsp++=val;
}
int popl()
{
	exprsp-=4;
	return *(int *)exprsp;
}
int popb()
{
	return *--exprsp;
}

int trytop(void)
{
	uchar toppri,topop;
	int topval;

	for(;;)
	{
		toppri=popb();
		if(oppri>toppri) {pushb(toppri);return oppri==8;}
		topop=popb();
		topval=popl();

		switch(topop)
		{
			case 0: /* + */
				operval+=topval;
				break;
			case 1: /* - */
				operval=topval-operval;
				break;
			case 2: /* / */
				operval=topval/operval;
				break;
			case 3: /* * */
				operval*=topval;
				break;
			case 4: /* | */
				operval|=topval;
				break;
			case 5: /* & */
				operval&=topval;
				break;
			case 6: /* << */
				operval=topval<<operval;
				break;
			case 7: /* >> */
				operval=topval>>operval;
				break;
			case 8: /* : */
				operval=((topval&255)<<16) | (operval&0xffff);
				break;
			case 16: return 1;
		}
	}
	return 0;
}

void operator(void)
{
uchar ch;

	ch=get();
	switch(ch)
	{
		case '+': oppri=16;opop=0;break;
		case '-': oppri=16;opop=1;break;
		case '/': oppri=24;opop=2;break;
		case '*': oppri=24;opop=3;break;
		case '|': oppri=32;opop=4;break;
		case '&': oppri=40;opop=5;break;
		case '<':
			if(get()!='<') back();
			oppri=48;opop=6;break;
		case '>':
			if(get()!='>') back();
			oppri=32;opop=7;break;
		case ':': oppri=15;opop=8;break;
		default:
			back();oppri=8;opop=16;
	}
}

/*
+ 010
- 110
/ 218,20f
* 318
| 420
& 528
<< 630
>> 730
. , ( ) white ; 008
*/


/* fills in operval and opertype, leaves pointer on character stopped on */
void operand(void)
{
	uchar ch;
	char *p;
	struct symbol *asym;
	char token[128];

	ch=at();
	if(ch=='#')
	{
		get();
		operval=0;
		while(isoknum(ch=get())) {operval*=10L;operval+=ch-'0';}
		back();
	} else if(ch=='@')
	{
		get();
		ch=get();
		if(ch=='b' || ch=='w' || ch=='l')
		{
;
		} else {back();exprerr=syntaxerrmsg;}
	} else if(ch=='\'')
	{
		get();
		operval=0;
		while((ch=get()))
		{
			if(ch=='\n' || !ch) {back();exprerr=unbalancedqmsg;break;}
			if(ch=='\'')
				if(get()!='\'') {back();break;}
			operval<<=8;operval+=ch;
		}
	} else if(ch=='(')
	{
		get();
		operval=expr2();
		if(get()!=')') {exprflag|=1;back();}
	}  else
	{
		p=token;
		for(;;)
		{
			ch=get();
			if(!isalpha(ch) && !isdigit(ch) && ch!='.' && ch!='_') break;
			*p++=ch;
		}
		back();
		*p=0;
		if((asym=findsym(token)))
			operval=(asym->bank<<16) | asym->addr;
		else
		{
			p=token;
			operval=0;
			while(ishex(ch=*p++)) {operval<<=4;operval+=tohex(ch);}
			if(ch) exprerr=unknownerr;
		}
	}
}

/*uchar opchars[]={'+','-','/','*','|','&','<<','>>','!'};*/
int expr2(void)
{
	pushb(0);
	if(at()=='-')
	{
		get();
		pushl(0L);
		pushb(1);
		pushb(0x10);
	}
	for(;;)
	{
		operand();
		operator();
		if(trytop()) break;

		pushl(operval);
		pushb(opop);
		pushb(oppri);
	}
	popb();
	return operval;
}

char *expr(char **from)
{
int eval;

	exprpnt=*from;
	exprerr=0;
	exprsp=exprstack;
	exprflag=0;
	eval=expr2();
	if(exprflag & 1) exprerr=unbalancedmsg;
	if(exprflag & 2) exprerr=badopmsg;
	exprval=eval;
	*from=exprpnt;
	return exprerr;
}
