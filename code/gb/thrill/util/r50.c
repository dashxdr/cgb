#include <stdio.h>
#include <stdlib.h>

#define MAX 50
int main(int argc, char **argv)
{
int n[MAX],i,j;

	for(i=0;i<MAX;++i) n[i]=-1;
	for(i=0;i<MAX;++i)
	{
		for(;;)
		{
			j=rand()%MAX;
			if(n[j]<0) break;
		}
		n[j]=i;
	}
	for(i=0;i<MAX;++i)
	{
		if(i%10==0) printf("\t\tdb\t");
		printf("%d",n[i]);
		if(i%10==9) printf("\n");
		else printf(",");
	}
	printf("\n");
	return  0;
}
