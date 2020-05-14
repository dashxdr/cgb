#include <stdio.h>

int list1[]={
14,3,2,
31,14,1,
31,25,2,
53,41,2,
77,58,2,
102,75,2,
124,92,2,
145,107,1,
146,117,2,
170,133,0
};

int list2[]={
161,5,2,
147,14,1,
146,24,2,
122,41,2,
98,57,2,
73,76,2,
50,92,2,
30,106,1,
30,117,2,
5,134,0
};

int count;

void step(int x1,int y1,int x2,int y2,int n) {
	int i;
	for(i=0;i<n;++i)
	{
		printf("\t\tdb\t%d,%d",x1+(x2-x1)*i/n,y1+(y2-y1)*i/n);
		if(!i)
			printf("\t;%d",count);
		printf("\n");
		++count;
	}
}

#define STEPS 8
void dump(int *p) {
	count=0;
	while(p[2])
	{
		step(p[0],p[1],p[3],p[4],p[2]*STEPS);
		p+=3;
	}
}



int main(int argc, char **argv) {
	printf("rapidlist1:\n");
	dump(list1);
	printf("rapidlist2:\n");
	dump(list2);
	return 0;
}
