/* makebg
   takes one argument, assumed to be filename.map, reads filename.chr also
   and creates filename.bg, which contains both files together:
   1 byte x size of map
   1 byte y size of map
   1 byte of # of chars
   13 bytes padding
   16 bytes per char
for color background:
[
   x*y bytes of color attributes
   64 bytes color maps (file.rgb)
]
   x*y bytes of map
*/

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define BUFFERSIZE 65536
char *buffer1,*buffer2,*buffer3;
int len1,len2,len3;

void splitwrite(int file,int xsize,int ysize,char *p) {
	int i;
	char *p2;
	int res;
	i=xsize*ysize;
	p2=buffer2;
	while(i--) {*p2++=*p++;++p;}
	res=write(file,buffer2,p2-buffer2);res=res;
}


int main(int argc,char **argv) {
	int file,ofile;
	char temp1[256];
	char temp2[256];
	char temp3[256];
	char *p;
	int xsize,ysize,i;
	int res;

	if(argc<2)
	{
		printf("Use: makebg file.map\n");
		printf("   Reads file.map and file.chr to produce file.bg\n");
		exit(1);
	}
	buffer1=malloc(BUFFERSIZE);
	buffer2=malloc(BUFFERSIZE);
	buffer3=malloc(BUFFERSIZE);
	if(!buffer1 || !buffer2 || !buffer3)
	{
		printf("no memory\n");
		exit(2);
	}
	strcpy(temp1,argv[1]);
	p=temp1;
	while(*p && *p!='.') p++;
	*p=0;

	file=open(argv[1],O_RDONLY|O_BINARY);
	if(file<0)
	{
		printf("Cannot open %s for read\n",argv[1]);
		exit(3);
	}
	len1=read(file,buffer1,BUFFERSIZE);
	close(file);
	sprintf(temp2,"%s.chr",temp1);
	file=open(temp2,O_RDONLY|O_BINARY);
	if(file<0)
	{
		printf("Cannot open %s for read\n",temp2);
		exit(4);
	}
	len2=read(file,buffer2,BUFFERSIZE);
	close(file);
	sprintf(temp2,"%s.bg",temp1);
	ofile=open(temp2,O_WRONLY|O_CREAT|O_TRUNC|O_BINARY,0644);
	if(ofile<0)
	{
		printf("Cannot open %s for write\n",temp2);
		exit(5);
	}
	for(i=0;i<16;i++) temp3[i]=0;
	xsize=buffer1[6]+1;
	ysize=buffer1[7]+1;
	temp3[0]=xsize;
	temp3[1]=ysize;
	temp3[2]=len2>>4;
	temp3[3]=len2>>12;
	res=write(ofile,temp3,16);res=res;
	res=write(ofile,buffer2,len2);res=res;
	if(xsize*ysize+8<len1) // processing a color background
	{
		splitwrite(ofile,xsize,ysize,buffer1+9);
		sprintf(temp3,"%s.rgb",temp1);
		file=open(temp3,O_RDONLY|O_BINARY);
		if(file<0)
		{
			printf("Cannot open %s rgb file for read\n",temp3);
		} else
		{
			i=read(file,buffer2,64);
			close(file);
			res=write(ofile,buffer2,i);res=res;
		}
		splitwrite(ofile,xsize,ysize,buffer1+8);
	} else {
		res=write(ofile,buffer1+8,xsize*ysize);res=res;
	}
	close(ofile);
	printf("All done,wrote %s, %d x %d, %d characters\n",temp2,xsize,ysize,len2>>4);
	return 0;
}
