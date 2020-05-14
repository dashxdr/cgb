#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
	int i,j;
	char ramp[256];

	memset(ramp,0,sizeof(ramp));

	for(i=0;i<256;++i)
	{
		if((i-15)%35==0)
			ramp[i]=3;
		else if((i-6)%12==0)
			ramp[i]=2;
		else if((i-3)%6==0)
			ramp[i]=1;
	}
	for(j=0;j<16;++j)
	{
		printf("\t\tdb\t");
		for(i=0;i<16;++i)
		{
			printf("%d,",ramp[(j<<4)+i]);	
		}
		printf("\n");
	}

}
