#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
This program reads in an excel .csv file and outputs it in 'c' format.
The first 6 fields are coordinates to be divided by 8. The
next two fields are descriptions.
*/

void outstops(int *p,int n,int v,char (*name)[128])
{
int i;
	if(!n) return;
	printf("static int states%d[]={\n",v);
	for(i=0;i<n;++i)
	{
		printf("%3d, // %3d %s\n",p[i],i,name[i]);
	}
	printf("};\n");
}

int main(int argc, char **argv) {
	char line[1024],*p;
	int v1,v2,v3,v4,v5,v6,v7,v8;
	int n;
	int ic;
	int stops[1024],sc;
	int tc;
	char names[500][128];

	sc=tc=0;
	ic=1;
	for(;;)
	{
		p=fgets(line,sizeof(line),stdin);
		if(!p) break;
		if(strlen(p)>1 && p[strlen(p)-1]=='\n')
			p[strlen(p)-1]=0;
		n=sscanf(line,"%d,%d,%d,%d,%d,%d,%d,%d",
			&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8);
		if(n<8)
		{
			if(tc)
				printf("};\n");
			outstops(stops,sc,ic,names);
			++ic;
			sc=tc=0;
			continue;
		}
		p=line;
		while(*p && n)
			if(*p++==',') --n;
		if(!v8)
		{
			stops[sc]=tc;
			strcpy(names[sc],p);
			++sc;
		}
		v1>>=3;
		v2>>=3;
		v3>>=3;
		v4>>=3;
		v5>>=3;
		v6>>=3;
		if(!tc) printf("static struct light info%d[]={\n",ic);
		printf("%2d,%2d,%2d,%2d,%2d,%2d,%2d,\t// %3d:%s\n",v1,v2,v3,v4,v5,v6,v7,tc++,
			p);
	}
	if(tc)
		printf("};\n");
	outstops(stops,sc,ic,names);
	return 0;
}
