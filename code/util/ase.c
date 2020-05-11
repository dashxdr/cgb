#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAXVERTEXES 1024
#define MAXFACES 1024

#define NORMAL 1024
#define SCALE 1024

int numvertexes;
struct vertex {
float x,y,z;
int nx,ny,nz;
} vertexes[MAXVERTEXES];

int numfaces;
struct face {
int a,b,c,m;
int nx,ny,nz;
} faces[MAXFACES];

char *inpoint;

int white(char c)
{
	return c==' ' || c=='\t' || c==':';
}

int match(char *s)
{
int l;
char c;
	l=strlen(s);
	if(strlen(inpoint)<l) return 0;
	if(strncmp(inpoint,s,l)) return 0;
	c=inpoint[l];
	if(!white(c)) return 0;
	inpoint+=l;
	return 1;
}

int moveto(char *s)
{
int l;
	l=strlen(s);
	while(*inpoint && strncmp(inpoint,s,l)) ++inpoint;
	if(*inpoint) {inpoint+=l;return 1;}
	return 0;
}


void skipwhite(void)
{
char c;
	while(c=*inpoint)
	{
		if(white(c)) ++inpoint;
		else break;
	}
}
void findwhite(void)
{
char c;
	while(c=*inpoint)
	{
		if(white(c)) break;
		else ++inpoint;
	}
}
void skip(void)
{
	skipwhite();
	findwhite();
}

float getfloat(void)
{
float k;
	skipwhite();
	sscanf(inpoint,"%f",&k);
	findwhite();
	return k;
}
int getint(void)
{
int k;
	skipwhite();
	sscanf(inpoint,"%d",&k);
	findwhite();
	return k;
}



main(int argc,char **argv)
{
FILE *f;
char line[1024];
float size2,dist2;
int i;
float scale;

float minx,maxx,miny,maxy,minz,maxz;
float cx,cy,cz;

	if(argc<2) return;
	f=fopen(argv[1],"rb");
	if(!f) return;
	numvertexes=0;

	size2=0.0;
	minx=miny=minz=1000000.0;
	maxx=maxy=maxz=-1000000.0;
	while(fgets(line,sizeof(line),f))
	{
		inpoint=line;
		while(*inpoint && *inpoint++!='*');
		if(!*inpoint) continue;
		if(match("MESH_VERTEX"))
		{
			int n;
			float x,y,z;
			n=getint();
			x=vertexes[numvertexes].x=getfloat();
			y=vertexes[numvertexes].y=getfloat();
			z=vertexes[numvertexes].z=getfloat();
			if(x<minx) minx=x;
			if(y<miny) miny=y;
			if(z<minz) minz=z;
			if(x>maxx) maxx=x;
			if(y>maxy) maxy=y;
			if(z>maxz) maxz=z;
			dist2=x*x+y*y+z*z;
			if(dist2>size2) size2=dist2;
			if(numvertexes<MAXVERTEXES)
				++numvertexes;
			else printf("Too many vertexes\n");
		} else if(match("MESH_FACE"))
		{
			int n,a,b,c,m;
			n=getint();
			skip();
			a=getint();
			skip();
			b=getint();
			skip();
			c=getint();
			if(moveto("MESH_MTLID"))
				m=getint();
			else m=0;
			faces[numfaces].a=a;
			faces[numfaces].b=b;
			faces[numfaces].c=c;
			faces[numfaces].m=m;
			if(numfaces<MAXFACES)
				++numfaces;
			else printf("Too many faces\n");
		} else if(match("MESH_VERTEXNORMAL"))
		{
			int n,nx,ny,nz;
			n=getint();
			nx=getfloat()*NORMAL;
			ny=getfloat()*NORMAL;
			nz=getfloat()*NORMAL;
			if(n<MAXVERTEXES)
			{
				vertexes[n].nx=nx;
				vertexes[n].ny=ny;
				vertexes[n].nz=nz;
			}
		} else if(match("MESH_FACENORMAL"))
		{
			int n,nx,ny,nz;
			n=getint();
			nx=getfloat()*NORMAL;
			ny=getfloat()*NORMAL;
			nz=getfloat()*NORMAL;
			if(n<MAXFACES)
			{
				faces[n].nx=nx;
				faces[n].ny=ny;
				faces[n].nz=nz;
			}
		}
	}

	cx=(maxx+minx)/2.0;
	cy=(maxy+miny)/2.0;
	cz=(maxz+minz)/2.0;

	maxx-=minx;
	maxy-=miny;
	maxz-=minz;
	scale=maxx;
	if(maxy>scale) scale=maxy;
	if(maxz>scale) scale=maxz;
	scale=2.0*SCALE/scale;

	printf("#define NUMVERTEXES %d\n",numvertexes);
	printf("#define NUMFACES %d\n",numfaces);

//	scale=SCALE/sqrt(size2);
	printf("short coords[NUMVERTEXES][3]={\n");
	for(i=0;i<numvertexes;++i)
	{
		printf("%d,%d,%d,\n",
			(int)((vertexes[i].x-cx)*scale),
			(int)((vertexes[i].y-cy)*scale),
			(int)((vertexes[i].z-cz)*scale));
	}
	printf("};\n");

	printf("short faces[NUMFACES][4]={\n");
	for(i=0;i<numfaces;++i)
	{
		printf("%d,%d,%d,%d,\n",faces[i].a,faces[i].b,faces[i].c,faces[i].m);
	}
	printf("};\n");
	printf("short vertexnormals[NUMVERTEXES][3]={\n");
	for(i=0;i<numvertexes;++i)
	{
		printf("%d,%d,%d,\n",vertexes[i].nx,vertexes[i].ny,vertexes[i].nz);
	}
	printf("};\n");

	printf("short facenormals[NUMFACES][3]={\n");
	for(i=0;i<numfaces;++i)
	{
		printf("%d,%d,%d,\n",faces[i].nx,faces[i].ny,faces[i].nz);
	}
	printf("};\n");


}
