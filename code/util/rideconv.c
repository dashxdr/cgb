#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#define OUTPUTNAME "RIDETRIG.ASM"

char inbuff[65536];
char line1[65536];
char line2[65536];
FILE *ofile;



striptail(char *s)
{
char *p,ch,*p2;
	p=s+strlen(s);
	while(p>s)
	{
		ch=*--p;
		if(ch=='/' || ch==':' || ch=='\\') break;
		if(ch=='.')
		{
			*p=0;
			break;
		}
	}
	while(p>s)
	{
		if(ch=='/' || ch==':' || ch=='\\') break;
		--p;
	}
	p2=s;
	if(p>s)
		while(*s++=*p++);
	while(*p2) {*p2=tolower(*p2);++p2;}
}

append(char **in, char **out)
{
char ch;

	while(ch=**in)
	{
		++(*in);
		if(ch=='\n') break;
		*(*out)++=ch;
	}
	**out=0;
}

outspace(int num)
{
	fprintf(ofile,"\t\tDB\t%d\n",num);
}
outnamed(char *name)
{
	fprintf(ofile,"\t\tDB\t%s\n",name);
}


parseprint(char *name,char *suffix,char *source)
{
int i,j,k,left,space,lastchar;
char *p1,*p2,ch,*lastname;
char tempname[64];
int digit;

	fprintf(ofile,"%s%s:\n",name,suffix);
	left=0;
	space=0;
	while(ch=tolower(*source++))
	{
		if(left && ch!=lastchar)
		{
			printf("error in %s,character %c\n",name,lastchar);
			left=0;
		}
		if(ch==' ' || ch=='.')
		{
			++space;
			if(space==240)
			{
				outspace(space);
				space=0;
			}
			continue;
		}
		if(space)
		{
			outspace(space);
			space=0;
		}
		if(left && ch==lastchar)
		{
			--left;
			if(!left)
				outnamed(lastname);
			continue;
		}
		lastchar=ch;
		switch(ch)
		{
		case 'l':
			left=10-1;
			lastname="LOG";
			break;
		case 'r':
			left=7-1;
			lastname="ROCK";
			break;
		case 't':
			left=4-1;
			lastname="TRAP";
			break;
		case 's':
			outnamed("STAGE");
			break;
		case '*':
			outnamed("STAR");
			break;
		case 'b':
		case 'w':
			digit=1;
			*source;
			if(*source>='1' && *source<='3')
			{
				digit=*source++-'0';
				++space;
			}
			sprintf(tempname,"%s%d",ch=='b' ? "BAT" : "WOLF",digit);
			outnamed(tempname);
			break;
		}
	}

	outnamed("FINISH");
}


convertfile(char *name)
{
int file;
char fixedname[256];
char *p1,*p2,*in;
int i,j,k;

	file=open(name,O_RDONLY);
	if(file<0)
	{
		printf("Could not open input file %s\n",name);
		return -1;
	}
	memset(inbuff,0,sizeof(inbuff));
	read(file,inbuff,sizeof(inbuff)-1);
	close(file);
	in=inbuff;
	p1=line1;
	p2=line2;
	do
	{
		append(&in,&p1);
//		append(&in,&p2);
	} while(*in);

	strcpy(fixedname,name);
	striptail(fixedname);
	parseprint(fixedname,"hi",line1);
//	parseprint(fixedname,"lo",line2);

}

main(int argc,char **argv)
{
int i;

	if(argc<2)
	{
		printf("%s Version %s\n",argv[0],__DATE__);
		printf("USE:%s <filename>...\n",argv[0]);
		printf("Takes text file and generates %s source for B&B Belle's Wild Ride\n",
			OUTPUTNAME);
		return 1;
	}
	ofile=fopen(OUTPUTNAME,"a");
	if(!ofile)
	{
		printf("Couldn't open %s for output\n",OUTPUTNAME);
		return 2;
	}
	
	for(i=1;i<argc;++i)
		convertfile(argv[i]);
	fclose(ofile);
}
