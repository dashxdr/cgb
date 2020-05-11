#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#include "font.h"
#include "gfx.h"
#include "math.h"

surface boardgfx;
surface collision;

struct ball {
int x,y;
int vx,vy;
};

#define EMPTY   0
#define POWER   1
#define FLIPPER 2
#define BUMPER  3

unsigned short basemap[64][24];
unsigned char *tiles=0;
int numtiles=0;

unsigned char *lastpic=0,*lastout=0;
int lastxsize,lastysize;


int simsin[64],simcos[64];

#define BASENAME "test"

#define FRAC 5

struct ball aball;

void nomem(int val)
{
	printf("No memory! %d\n",val);
	exit(val);
}

void striptail(char *s)
{
char *p;
	p=s+strlen(s);
	while(--p>s)
		if(*p=='.')
		{
			*p=0;
			break;
		}
}



void rainbow(int which,int num,int *r,int *g,int *b)
{
float v;
	v=(float)which/num;
	if(v<.16666666666)
	{
		v*=6;
		*r=255;
		*g=v*255;
		*b=0;
	} else if(v<.333333333)
	{
		v-=.16666666666;
		v*=6;
		*r=255-v*255;
		*g=255;
		*b=0;
	} else if(v<.5)
	{
		v-=.3333333333;
		v*=6;
		*r=0;
		*g=255;
		*b=v*255;
	} else if(v<.6666666666)
	{
		v-=.5;
		v*=6;
		*r=0;
		*g=255-v*255;
		*b=255;
	} else if(v<.83333333333)
	{
		v-=.66666666666;
		v*=6;
		*r=v*255;
		*g=0;
		*b=255;
	} else
	{
		v-=.8333333333;
		v*=6;
		*r=255;
		*g=0;
		*b=255-v*255;
	}

}

void initcolors()
{
int i;
int r,g,b;
	setcolor(&collision,0,0,0,0);
	setcolor(&collision,1,64,0,0);
	for(i=64;i<256;++i)
	{
		setcolor(&boardgfx,i,i<<5,i<<5,192);
		rainbow(i&7,8,&r,&g,&b);
		setcolor(&collision,i,r,g,b);
	}

//	collision.rgb[0]=maprgb(0,0,128);
//	collision.rgb[1]=maprgb(128,64,0);
	for(i=192;i<256;++i)
	{
		rainbow(i-192,64,&r,&g,&b);
		setcolor(&collision,i,r,g,b);
//		collision.rgb[i]=maprgb(r,g,b);
	}
}
void initrainbow(char *m)
{
int i,j,r,g,b;

	memset(m,0,64*3);
	j=3;
	m[j++]=255;m[j++]=0;m[j++]=0;
	m[j++]=0;m[j++]=0;m[j++]=255;
	m[j++]=64;m[j++]=0;m[j++]=0;


	j=64*3;
	for(i=0;i<192;++i)
	{
		rainbow(i&63,64,&r,&g,&b);
		m[j++]=r;
		m[j++]=g;
		m[j++]=b;
	}
}


void outtiles(char *basename) {
	int i,j,k,f,s;
	char name[128];
	int res;
	j=numtiles*64;
	i=0;
	k=0;
	while(i<j)
	{
		sprintf(name,"%s.pn%d",basename,k++);
		s=j-i;
		if(s>16384) s=16384;
		f=open(name,O_WRONLY|O_CREAT|O_TRUNC,0644);
		if(f>=0)
		{
			res=write(f,tiles+i,s);res=res;
			close(f);
		}
		i+=s;
	}
}


#define RADIUS 8
#define FLUFF (RADIUS+1)
void fixboard(char *basename,int n)
{
int xsize,ysize;
int i,j,k,u,v,v2;
int iu,jv;
unsigned char *in,*out,*ip,*op,*p1,*p2;
int xtotal,ytotal;
int closenum;
int angle;
float a;
unsigned short map[64][24];
char name[64];
int f,s,t,d;
int tx,ty;
int type[4];
unsigned short changes[8192];
int xmin,xmax,ymin,ymax;
int res;


	printf("Processing file name %s\n",basename);
	if(!tiles)
	{
		tiles=malloc(1000000);
		if(!tiles) nomem(2);
		memset(tiles,0,64);
		numtiles=1;
	}
	in=boardgfx.pic;
	memset(&collision,0,sizeof(collision));
	xsize=boardgfx.xsize;
	ysize=boardgfx.ysize;
	collision.xsize=xsize>>1;
	collision.ysize=ysize>>1;
	out=collision.pic=malloc(xsize*ysize>>2);
	if(!collision.pic) nomem(1);
	if(n)
	{
		if(xsize!=lastxsize || ysize!=lastysize)
		{
			printf("Sizes don't match!\n");
			exit(27);
		}
		memcpy(out,lastout,xsize*ysize>>2);
		xmin=ymin=1000000;
		xmax=ymax=-1000000;
		p1=lastpic;
		p2=boardgfx.pic;
		for(j=0;j<ysize;++j)
		{
			for(i=0;i<xsize;++i)
			{
				if(*p1++==*p2++) continue;
				if(i<xmin) xmin=i;
				if(i>xmax) xmax=i;
				if(j<ymin) ymin=j;
				if(j>ymax) ymax=j;
			}
		}
		xmin=xmin-FLUFF;
		if(xmin<0) xmin=0;
		xmin&=~1;
		xmax=xmax+FLUFF+1 & ~1;
		if(xmax>xsize) xmax=xsize;
		ymin=ymin-FLUFF;
		if(ymin<0) ymin=0;
		ymin&=~1;
		ymax=ymax+FLUFF+1 & ~1;
		if(ymax>ysize) ymax=ysize;
	} else
	{
		xmin=0;
		ymin=0;
		xmax=xsize;
		ymax=ysize;
		memset(out,0,xsize*ysize>>2);
	}
printf("(%d,%d) to (%d,%d)\n",xmin,ymin,xmax,ymax);
	for(j=ymin;j<ymax;j+=2)
	{
		op=out+(j>>1)*(xsize>>1);
		for(i=xmin;i<xmax;i+=2)
		{
			xtotal=ytotal=closenum=0;
			type[0]=type[1]=type[2]=type[3]=5000;
			for(ty=0;ty<2;++ty)
			{
				for(tx=0;tx<2;++tx)
				{
					t=in[i+tx+(j+ty)*xsize];
					if(t!=EMPTY)
					{
						op[i>>1]=t;
						goto gotit;
					}
					for(v=-RADIUS;v<=RADIUS;++v)
					{
						jv=j+ty+v;
						ip=in+jv*xsize;
						v2=v*v;
						for(u=-RADIUS;u<=RADIUS;++u)
						{
							d=v2+u*u;
							if(d>RADIUS*RADIUS) continue;
							iu=i+tx+u;
							if(iu<0 || iu>=xsize || jv<0 || jv>=ysize) continue;
							t=ip[iu]&3;
							if(t==EMPTY) continue;
							xtotal+=u;
							ytotal+=v;
							if(type[t]>d) type[t]=d;
							++closenum;
						}
					}
				}
			}
#define PI 3.1415926
			if(!closenum || xtotal==0 && ytotal==0)
			{
				op[i>>1]=0;
				continue;
			}
			a=atan2(-ytotal,-xtotal);
if(a>=0)
	angle=0.5+a*32.0/PI;
else
	angle=-0.5+a*32.0/PI;


//			if(angle<0) angle+=64;
			angle&=0x3f;
			t=3;
			if(type[2]<type[t]) t=2;
			if(type[1]<type[t]) t=1;
			op[i>>1]=angle+(t<<6);
gotit:;
		}
	}
	xsize>>=1;
	ysize>>=1;
	memset(map,0,sizeof(map));
printf("xsize=%d,ysize=%d\n",xsize,ysize);
	for(j=0;j<ysize>>3;++j)
		for(i=0;i<xsize>>3;++i)
		{
			ip=out+((xsize*j+i)<<3);
			op=tiles+(numtiles<<6);
			for(k=0;k<8;++k)
			{
				memcpy(op,ip,8);
				op+=8;
				ip+=xsize;
			}
			ip=tiles+(numtiles<<6);
			op=tiles;
			for(k=0;k<numtiles;++k)
			{
				if(!memcmp(ip,op,64)) break;
				op+=64;
			}
			if(k==numtiles) ++numtiles;
			map[j][i]=k;
		}

	if(!n)
	{
		memcpy(basemap,map,sizeof(basemap));
		sprintf(name,"%s.pmp",basename);
		f=open(name,O_WRONLY|O_CREAT|O_TRUNC,0644);
		if(f<0)
			{printf("could not open file %s for write\n",name);exit(10);}
		res=write(f,map,sizeof(map));res=res;
		close(f);
	} else
	{
		t=0;
		for(j=0;j<64;++j)
			for(i=0;i<24;++i)
				if(basemap[j][i]!=map[j][i])
				{
					printf("Difference %d,%d = %d (%d)\n",i,j,
						map[j][i],basemap[j][i]);
					changes[t++]=(&basemap[j][i]-&basemap[0][0])<<1;
					changes[t++]=map[j][i];
					changes[t++]=basemap[j][i];
				}
		changes[t++]=0xffff;
		sprintf(name,"%s.chg",basename);
		f=open(name,O_WRONLY|O_CREAT|O_TRUNC,0644);
		if(f<0)
			{printf("could not open file %s for write\n",name);exit(10);}
		res=write(f,changes,t<<1);res=res;
		close(f);
	}


	printf("numtiles= %d, memory requirement= %d bytes\n",
		numtiles,numtiles*64);

/*
	xsize=boardgfx.xsize;
	ysize=boardgfx.ysize;
	ip=collision.pic;
	op=boardgfx.pic;
	for(j=0;j<ysize>>1;++j)
		for(i=0;i<xsize>>1;++i)
		{
			op[i+j*xsize]=ip[i+j*(xsize>>1)];
		}
*/
}

int dirtyxmin=5000,dirtyxmax=-5000;
int dirtyymin=5000,dirtyymax=-5000;

void repair()
{
	if(dirtyxmin<dirtyxmax)
	{
		gstoback(dirtyxmin,dirtyymin,&boardgfx,dirtyxmin,dirtyymin,
			dirtyxmax-dirtyxmin,dirtyymax-dirtyymin);
	}
}

void update()
{
	if(dirtyxmin<dirtyxmax)
	{
		copyupany(dirtyxmin,dirtyymin,dirtyxmax-dirtyxmin,dirtyymax-dirtyymin);
		dirtyxmin=5000;
		dirtyxmax=-5000;
		dirtyymin=5000;
		dirtyymax=-5000;
	}
}

#define DRAWRADIUS 7

void markball(int x,int y)
{
int i,j;

	i=x-DRAWRADIUS-1;
	if(i<0) i=0;
	if(i<dirtyxmin) dirtyxmin=i;
	i=x+DRAWRADIUS+2;
	if(i>collision.xsize) i=collision.xsize;
	if(i>dirtyxmax) dirtyxmax=i;

	j=y-DRAWRADIUS-1;
	if(j<0) j=0;
	if(j<dirtyymin) dirtyymin=j;
	j=y+DRAWRADIUS+2;
	if(j>collision.ysize) j=collision.ysize;
	if(j>dirtyymax) dirtyymax=j;

//dirtyxmin=0;dirtyymin=0;dirtyxmax=xsize;dirtyymax=ysize;

}

void drawball(int x,int y)
{
int xsize,ysize;
int i,j;

	xsize=collision.xsize;
	ysize=collision.ysize;

	for(i=-DRAWRADIUS;i<=DRAWRADIUS;++i)
		for(j=-DRAWRADIUS;j<=DRAWRADIUS;++j)
		{
			if(i*i+j*j>DRAWRADIUS*DRAWRADIUS) continue;
			rgbdot(x+i,y+j,0,0,255);
		}
	markball(x,y);
}


#define ABS(x) (((x)<0) ? -(x) : (x))

void showball()
{
int ox,oy;

	ox=aball.x>>FRAC;
	oy=aball.y>>FRAC;
	drawball(ox,oy);
	update();
	markball(ox,oy);
	repair();
}


#define ELAST 90
void moveball()
{
int x,y;
int dx,dy;
int t;
int v,s,c;

//	aball.vy+=1;
if((aball.y>>FRAC)>318) aball.vy=-8<<FRAC-1;

	aball.x+=aball.vx;
	aball.y+=aball.vy;
	x=aball.x>>FRAC;
	y=aball.y>>FRAC;
	if((t=collision.pic[x+y*collision.xsize]))
	{
		t&=0x3f;
		s=simsin[t];
		c=simcos[t];
//printf("t=%d  %d,%d\n",t,c,s);
		v=aball.vx*c+aball.vy*s>>FRAC;
		if(v<0)
		{
			dx=c*v;
			dy=s*v;
			if(dx<0) dx=-((-dx)*ELAST>>FRAC+6);
			else dx=dx*ELAST>>FRAC+6;
			if(dy<0) dy=-((-dy)*ELAST>>FRAC+6);
			else dy=dy*ELAST>>FRAC+6;
			aball.vx-=dx;
			aball.vy-=dy;
//dx=aball.vx;
//dy=aball.vy;
//if(dx*dx+dy*dy<5) aball.vx=aball.vy=0;
		}
		dx=0;
		for(;;)
		{
			if(c<0) c=-((-c)>>2);
			else c>>=2;
			if(s<0) s=-((-s)>>2);
			else s>>=2;

			aball.x+=c;
			aball.y+=s;
			x=aball.x>>FRAC;
			y=aball.y>>FRAC;
			t=collision.pic[x+y*collision.xsize];
			if(!t) break;
			t&=0x3f;
			s=simsin[t];
			c=simcos[t];
			++dx;
		}
	}
}

int writepcx(unsigned char *name, int width, int height, void (*fetch)(), unsigned char *colors)
{
	int file;
	unsigned char temp[2048],*p,temp2[2048],*p2;
	int i,j,k;
	int res;


	file=open(name,O_WRONLY|O_TRUNC|O_CREAT,0644);
	if(file<0) return 1;
	p=temp;
	*p++=10;
	*p++=5;
	*p++=1;
	*p++=8;
	*p++=0;
	*p++=0;
	*p++=0;
	*p++=0;
	i=width-1;
	*p++=i;
	*p++=i>>8;
	i=height-1;
	*p++=i;
	*p++=i>>8;
	*p++=width;
	*p++=width>>8;
	*p++=height;
	*p++=height>>8;
	for(i=0;i<49;++i) *p++=0;
	*p++=1; //NPlanes
	i=width+1 & 0xfffe;
	*p++=width;	//bytes per line
	*p++=width>>8;
	*p++=1;		//palette info
	*p++=0;
	for(i=0;i<58;++i) *p++=0;
	res=write(file,temp,p-temp);res=res;
	for(j=0;j<height;++j)
	{
		fetch(temp,j);
		p=temp;
		p2=temp2;
		i=width+1 & 0xfffe;
		temp[width]=0;
		k=0;
		while(i)
		{
			while(k<i && k<63 && p[++k]==*p);
			if(k>1)
			{
				*p2++=k | 0xc0;
				*p2++=*p;
				p+=k;
			} else
			{
				if(*p>=0xc0)
					*p2++=0xc1;
				*p2++=*p++;
			}
			i-=k;
			k=0;
		}
		res=write(file,temp2,p2-temp2);res=res;
	}
	res=write(file,"\014",1);res=res;
	res=write(file,colors,0x300);res=res;
	close(file);
}
surface *pcxs;

void lfetch(unsigned char *buff,int line)
{
	memmove(buff,pcxs->pic+line*pcxs->xsize,pcxs->xsize);
}

void surfacetopcx(char *out,surface *s)
{
unsigned char tmap[768];
	initrainbow(tmap);
	pcxs=s;
	writepcx(out,s->xsize,s->ysize,lfetch,tmap);
}

int main(int argc,char **argv) {
	int i,j,code,exitflag;
	int x=0,y=0;
	int time,newtime;
	char name[64];
	int count;
	char *first;

	initcolors();
//goto skip;
	first=0;
	count=0;
	for(i=1;i<argc;++i)
	{
		if(argv[i][0]=='-')
		{
			j=argv[i][1];
			if(j=='n') count=0;
			continue;
		}
		if(!first) first=argv[i];
		strcpy(name,argv[i]);
		j=readpcx(name,&boardgfx);
		if(j) {printf("error in file %s\n",name);exit(2);}
		striptail(name);
		fixboard(name,count);
surfacetopcx("/tmp/out.pcx",&collision);
		if(!count)
		{
			lastxsize=boardgfx.xsize;
			lastysize=boardgfx.ysize;
			if(lastpic)
				free(lastpic);
			lastpic=boardgfx.pic;
			if(lastout)
				free(lastout);
			lastout=collision.pic;
		} else
		{
			free(collision.pic);
			free(boardgfx.pic);
		}
		++count;
	}
	strcpy(name,first);
	striptail(name);
	outtiles(name);

return 0;
skip:

	for(i=0;i<64;++i)
	{
		float a;
		a=i*3.1415926/32.0;
		simcos[i]=(1<<FRAC)*cos(a);
		simsin[i]=(1<<FRAC)*sin(a);
	}

/*
printf("TblSin::\n");
for(i=0;i<64;++i)
	printf("\t\tdb\t%d\n",simsin[i]);
printf("TblCos::\n");
for(i=0;i<64;++i)
	printf("\t\tdb\t%d\n",simcos[i] );
*/


	opendisplay(640,800);
	atexit(closedisplay);
//	sprintf(name,"%s.pcx",BASENAME);
	snprintf(name, sizeof(name), "%s", argv[1]);
	i=readpcx(name,&boardgfx);
	if(i) exit(2);
	initfont();

	fixboard(BASENAME,0);
	initcolors();

surfacetopcx("/tmp/out.pcx",&collision);



	gstoback(0,0,&boardgfx,0,0,boardgfx.xsize,boardgfx.ysize);
//	gstoback(0,0,&collision,0,0,collision.xsize,collision.ysize);

	copyup();

	aball.x=167<<FRAC;
	aball.y=260<<FRAC;
	aball.vx=0;
	aball.vy=0;
aball.x=50<<FRAC;aball.y=240<<FRAC;
aball.x=96<<FRAC;
	exitflag=0;
	time=gticks();
	while(!exitflag)
	{
		while((i=gticks())<time)
			delay(1);

		time=i+20;
aball.vy++;
		moveball();
		moveball();
		moveball();
		showball();
		scaninput();
		for(;;)
		{
//			scaninput();
			code=nextcode();
			if(code<0) break;
			switch(code)
			{
			case 0x1b:
				exitflag=1;
				break;
			default:
				if(code&MYMOUSE)
				{
					x=nextcode();
					y=nextcode();
					if(code==MYMOUSEMOVE)
					{
						while(peekcode()==MYMOUSEMOVE)
						{
							code=nextcode();
							x=nextcode();
							y=nextcode();
						}
					}
				}
				break;
			}
		}
	}
}
