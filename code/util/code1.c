#include <stdio.h>
#include <stdarg.h>

/* This program generates the CalcPlyrDirn function(s) */

char *names1[]={
"wPlayer0",
"wPlayer1",
"wPlayer2",
"wPlayer3",
"wPlayer4",
"wPlayer5",
};
char *names2[]={
"P0","P1","P2","P3","P4","P5","HP"
};
char *xnames[]={
"wPlayer0+SPR_CRT_X",
"wPlayer1+SPR_CRT_X",
"wPlayer2+SPR_CRT_X",
"wPlayer3+SPR_CRT_X",
"wPlayer4+SPR_CRT_X",
"wPlayer5+SPR_CRT_X",
"wHoopCrtX",
};
char *ynames[]={
"wPlayer0+SPR_CRT_Y",
"wPlayer1+SPR_CRT_Y",
"wPlayer2+SPR_CRT_Y",
"wPlayer3+SPR_CRT_Y",
"wPlayer4+SPR_CRT_Y",
"wPlayer5+SPR_CRT_Y",
"wHoopCrtY",

};

void tprintf(char *format, ...)
{
char buff[128],*p;
	va_list ap;
	va_start(ap, format);
	vsprintf(buff,format, ap);
	va_end(ap);
	p=buff;
	while(*p)
	{
		if(*p==' ') *p='\t';
		++p;
	}
	printf("%s", buff);
}



void calc(int p1,int p2) {
	tprintf("  LD HL,%s\n",xnames[p1]);
	tprintf("  LD A,[HLI]\n");
	tprintf("  LD C,A\n");
	tprintf("  LD A,[HLI]\n");
	tprintf("  LD B,A\n");
	tprintf("  INC L\n");
	tprintf("  LD A,[HLI]\n");
	tprintf("  LD E,A\n");
	tprintf("  LD D,[HL]\n");

	tprintf("  LD HL,%s\n",xnames[p2]);
	tprintf("  LD A,[HLI]\n");
	tprintf("  SUB C\n");
	tprintf("  LD C,A\n");
	tprintf("  LD A,[HLI]\n");
	tprintf("  SBC B\n");
	tprintf("  LD B,A\n");
	if(p2<6)
		tprintf("  INC L\n");
	tprintf("  LD A,[HLI]\n");
	tprintf("  SUB E\n");
	tprintf("  LD E,A\n");
	tprintf("  LD A,[HL]\n");
	tprintf("  SBC D\n");
	tprintf("  LD D,A\n");

	tprintf("  CALL CalcDistance\n");
	tprintf("  LD [%s+SPR_DIR_%s],A\n",names1[p1],names2[p2]);
	if(p2<6)
	{
		tprintf("  XOR $80\n");
		tprintf("  LD [%s+SPR_DIR_%s],A\n",names1[p2],names2[p1]);
	}
	tprintf("  LD A,C\n");
	tprintf("  LD [%s+SPR_DST_%s],A\n",names1[p1],names2[p2]);
	if(p2<6)
	{
		tprintf("  LD [%s+SPR_DST_%s],A\n",names1[p2],names2[p1]);
	}
}


void head(int n) {
	tprintf("CalcPlyrDirn%d_B::\n",n);
}
void tail() {
	tprintf("  RET\n");
}



int main(int argc, char **argv) {
	int i,j,k;

	k=0;
	for(i=0;i<6;++i)
		for(j=i+1;j<7;++j)
		{
			if(!k || k==11)
				head(k/11);
			calc(i,j);
			if(k==10 || k==20)
				tail();
			++k;
		}
}
