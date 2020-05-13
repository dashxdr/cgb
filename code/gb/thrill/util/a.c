#include <stdio.h>
#include <math.h>
#define FRAC 5
int main(int argc, char **argv)
{
int i,j;
int simcos[128],simsin[128];
int x,y;

	for(i=0;i<16;++i)
	{
		float a;
		a=i*3.1415926/32.0;
		x=(1<<FRAC)*cos(a);
		y=(1<<FRAC)*sin(a);
		simcos[i]=x;
		simsin[i]=y;
		j=i+16;
		simcos[j]=-y;
		simsin[j]=x;
		j=i+32;
		simcos[j]=-x;
		simsin[j]=-y;
		j=i+48;
		simcos[j]=y;
		simsin[j]=-x;
	}
/*
for(i=0;i<64;++i)
	printf("%3d  (%5d,%5d)\n",i,simcos[i],simsin[i]);
*/

printf("TblSin::\n");
for(i=0;i<64;++i)
	printf("\t\tdb\t%d\n",simsin[i]);
printf("TblCos::\n");
for(i=0;i<64;++i)
	printf("\t\tdb\t%d\n",simcos[i] );

}
