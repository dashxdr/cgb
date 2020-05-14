#include <stdio.h>

int main(int argc, char **argv) {
	int c;
	for(;;)
	{
		c=getchar();
		if(c<0) break;
		if(c==13) continue;
		putchar(c);
	}
	return 0;
}
