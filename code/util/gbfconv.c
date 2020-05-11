#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


/* Converts from .fnt file to a .asm file */

/* input file:
  16 byte header
     (6) = byte telling first ascii character
     (7) = byte telling # of character structures
  ---
     X copies of the following structure, X = byte 7
   8 byte structure defining letter
     2 bytes delta from here to font data,LH
     1 byte dummy
     1 byte DX (shift pen after drawing)
     1 byte X (delta off draw position)
     1 byte Y (delta off draw position)
     1 byte W
     1 byte H
   Kern table
   Character data stored as W*H bytes, 1 byte/pixel
   output file:
   128*
     1 byte char delta lo (data - (this address+1))
     1 byte char delta hi (data - this address)
   Each character has follwing structure:
     1 byte delta x
     1 byte delta y
     1 byte width in pixels
     1 byte # of rows (YSIZE)
     YSIZE *
       1 byte low bits
       1 byte hight bits

*/


#define MAXBUFFLEN 16384
#define MAXOUT 8192
#define LABEL "sf_"
unsigned char buffer[MAXBUFFLEN];
unsigned char output[MAXOUT];
char temp[1024];

int main(int argc, char **argv) {
	int file;
	int i,j,k;
	int height,width;
	unsigned char byte,bit;
	unsigned char *p,*p2,pixel;
	unsigned char *op;
	int res;

	if(argc<2)
	{
		printf("Use: fconv <filename>\n");
		printf("     Reads <filename>.fnt and writes <filename>.gbf");
		exit(0);
	}
	sprintf(temp,"%s.fnt",argv[1]);
	file=open(temp,O_RDONLY);
	if(file<0) {printf("Cannot open %s\n",temp);exit(1);}
	res=read(file,buffer,MAXBUFFLEN);res=res;
	close(file);
	sprintf(temp,"%s.gbf",argv[1]);
	file=open(temp,O_WRONLY|O_TRUNC|O_CREAT, 0644);
	if(!file) {printf("Cannot open %s for output\n",temp);exit(2);}

	op=output+128*2;

	*op++=0;
	*op++=0;
	*op++=4;
	*op++=1;
	*op++=0;
	*op++=0;

	for(i=0;i<128;i++)
	{
		if(i<buffer[6] || i>=buffer[6]+buffer[7])
		{
			k=256-(i+i+1);
			output[i+i]=k;
			output[i+i+1]=k>>8;
			continue;
		}
		k=(op-output)-(i+i+1);
		output[i+i]=k;
		output[i+i+1]=k>>8;
		p=buffer+16+((i-buffer[6])<<3);
		height=p[7];
		width=p[6];
		*op++=p[4];
		*op++=p[5];
		*op++=p[3]+buffer[8];
		*op++=height;
		p+=p[0] + (p[1]<<8);
		for(j=0;j<height;j++)
		{
			p2=p;
			byte=0;bit=128;
			for(k=0;k<width;k++)
			{
				pixel=*p++;
				if(k<8)
				{
					if(pixel & 1) byte|=bit;
					bit>>=1;
				}
			}
			*op++=byte;
			p=p2;
			byte=0;bit=128;
			for(k=0;k<width;k++)
			{
				pixel=*p++;
				if(k<8)
				{
					if(pixel & 2) byte|=bit;
					bit>>=1;
				}
					
			}
			*op++=byte;
		}
	}
	res=write(file,output,op-output);res=res;
	close(file);
	return 0;
}
