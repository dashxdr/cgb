//#define _XOPEN_SOURCE
#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <crypt.h>


char saltletters[]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789./";

char *randomsalt(void)
{
	static char salt[3];
	int i;
	i=rand()%strlen(saltletters);
	salt[0]=saltletters[i];
	i=rand()%strlen(saltletters);
	salt[1]=saltletters[i];
	salt[2]=0;
	return salt;
}

int main(int argc,char **argv)
{
	int i;
	struct timeval tv;

	if(argc<2)
	{
		printf("Use: %s <password> ...\n",argv[0]);
		exit(0);
	}
	gettimeofday(&tv,0);
	srand(tv.tv_sec+tv.tv_usec);
	for(i=1;i<argc;++i)
	{
		printf("%s:%s\n",argv[i],crypt(argv[i],randomsalt()));
	}
	return 0;
}
	