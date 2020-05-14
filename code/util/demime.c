#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <strings.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <regex.h>
#include <string.h>
#include <stdlib.h>

#define MAXLINE 1024
char line[MAXLINE];
char name[MAXLINE];
char temp[MAXLINE];

int begins(char *input,char *against)
{
int i,l1,l2;
	l1=strlen(input);
	l2=strlen(against);
	for(i=0;i<l1-l2;++i)
		if(!strncmp(input+i,against,l2)) return 0;
	return 1;
}
int pid;

int startapp(char *n)
{
	int inout[2];

	int res=pipe(inout);res=res;
	if((pid=fork()))
	{
		close(inout[0]);
		return inout[1];
	}
	close(0);
	close(1);
	close(inout[1]);
	res=dup(inout[0]);
	open(n,O_WRONLY|O_CREAT|O_TRUNC,0644);
	execlp("/usr/bin/mmencode","mmencode","-u", NULL);
	exit(0); //shouldn't get here
}
void stopapp(int f) {
	close(f);
	wait(0);
}


int main(int argc, char **argv) {
	int mode;
	char *s;
	char *p,*p2;
	int out=-1;
	regex_t precompiled[1024];
	int res;

	regcomp(precompiled,"filename=",0);
	mode=0;
	for(;;)
	{
		line[0]=0;
		s=fgets(line, sizeof(line), stdin);
		switch(mode)
		{
		case 0:
			if(!regexec(precompiled,line,0,0,0))
			{
				mode=1;
				p=line;
				while(*p && *p!='"') ++p;
				if(*p)
				{
					++p;
					p2=name;
					while(*p && *p!='"') *p2++=*p++;
					*p2=0;
					out=startapp(name);
				}
				printf("Found header for %s\n",name);
			}
			break;
		case 1:
			if(!line[0]) mode=2;
			break;
		case 2:
			sprintf(temp,"%s\n",line);
			res=write(out,temp,strlen(temp));res=res;
			if(!line[0])
			{
				stopapp(out);
				mode=0;
			}
			break;
		}
		if(!s) break;
	}
	return 0;
}
