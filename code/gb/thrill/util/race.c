#define X1A 3
#define X1B 156
#define YA 88
#define Y1B 3
#define Y2B 19
#define X2A 19
#define X2B 140

#define SPREAD 7
#define BOOST -12

track(int xa,int xb,int ya,int yb)
{
int lena,lenb,lenc;
int i,j;
int x,y,f;

	lena=ya-yb;
	lenb=lena+xb-xa;
	lenc=lenb+ya-yb;
	for(i=0;i<lenc;++i)
	{
		if(i<lena)
		{
			x=xa;
			y=ya-i;
		} else if(i<lenb)
		{
			x=xa+i-lena;
			y=yb;
		} else
		{
			x=xb;
			y=yb+i-lenb;
		}
		j=i+BOOST;
		if(j<lena-3*SPREAD) f=0;
		else if(j<lena) f=(j-(lena-3*SPREAD))/SPREAD+1;
		else if(j<lenb-3*SPREAD) f=4;
		else if(j<lenb) f=(j-(lenb-3*SPREAD))/SPREAD+5;
		else f=8;
		printf("\t\tdb\t%d,%d,%d\n",x,y,f);
	}

}




main()
{
int i,j,k;
	printf("racetrack1:\n");
	track(X1A,X1B,YA,Y1B);
	printf("racetrack2:\n");
	track(X2A,X2B,YA,Y2B);

}
