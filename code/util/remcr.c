main()
{
int c;
	for(;;)
	{
		c=getchar();
		if(c<0) break;
		if(c==13) continue;
		putchar(c);
	}
}
