#include <stdio.h>
int array[2000];
int count;
int max;

void insert(int at) {
	if(at<max)
	{
		insert(at+at+1);
		array[at]=count++;
		insert(at+at+2);
	}
}


int main(int argc, char **argv) {
	int i;

	max=12;
	count=1;

	insert(0);
	for(i=0;i<max;++i)
		printf(" %2d",array[i]);
	printf("\n");
	return 0;
}
