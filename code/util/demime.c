#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <strings.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <regex.h>


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

	pipe(inout);
	if(pid=fork())
	{
		close(inout[0]);
		return inout[1];
	}
	close(0);
	close(1);
	close(inout[1]);
	dup(inout[0]);
	open(n,O_WRONLY|O_CREAT|O_TRUNC,0644);
	execlp("/usr/bin/mmencode","mmencode","-u",0);
	exit(0); //shouldn't get here
}
stopapp(int f)
{
	close(f);
	wait(0);
}


main()
{
int mode;
char *s;
char *p,*p2;
int out;
regex_t precompiled[1024];

	regcomp(precompiled,"filename=",0);
	mode=0;
	for(;;)
	{
		line[0]=0;
		s=gets(line);
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
			write(out,temp,strlen(temp));
			if(!line[0])
			{
				stopapp(out);
				mode=0;
			}
			break;
		}
		if(!s) break;
	}



}
