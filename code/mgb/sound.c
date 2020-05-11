#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <SDL_audio.h>
#include <SDL_error.h>
#include "mgb.h"


#define SNDFRAGMENT 1024

int soundworking=0;
int fragment;
char quiet;

struct voice v1,v2,v3,v4;
char v3tab[32];

int sound3counter;

void fillaudio(void *udata,Uint8 *buffer,int len)
{
int i,k,filled;
int fa,fb,fc,fd;
unsigned char y1,y2,y3,y4,t1,t2,t3,t4;
char vol1,vol2,vol3,vol4;
static int sa=0,sb=0,sd=0;
static char randbyte=0;
unsigned char *duty1,*duty2;
char v;

#define CUTOFF 0x20000
#define SHIFT 15
	filled=0;
	while(filled<len)
	{
		fa=v1.freqval;
		fb=v2.freqval;
		fc=v3.freqval;
		fd=v4.freqval;
		i=ramblock[0xff26]&0x80;
//		j=ramblock[0xff26];
		k=ramblock[0xff25];
		y1=i && (v1.mode&0x80) && (k&0x11);
		y2=i && (v2.mode&0x80) && (k&0x22);
		y3=(ramblock[0xff1a]&0x80) && i && (v3.mode&0x80) && (k&0x44);
		y4=i && (v4.mode&0x80) && (k&0x88);
		t1=y1 && (v1.mode&0x40);
		t2=y2 && (v2.mode&0x40);
		t3=y3 && (v3.mode&0x40);
		t4=y4 && (v4.mode&0x40);

		if(t1)
		{
			v1.timer-=4;
			if(v1.timer<=0)
			{
				y1=0;
				v1.timer=0;
				v1.mode&=~0x80;
			}
		}
		if(t2)
		{
			v2.timer-=4;
			if(v2.timer<=0)
			{
				y2=0;
				v2.timer=0;
				v2.mode&=~0x80;
			}
		}
		if(t3)
		{
			v3.timer-=4;
			if(v3.timer<=0)
			{
				y3=0;
				v3.timer=0;
				v3.mode&=~0x80;
			}
		}
		if(t4)
		{
			v4.timer-=4;
			if(v4.timer<=0)
			{
				y4=0;
				v4.timer=0;
				v4.mode&=~0x80;
			}
		}
		if(y1 && (v1.env&7))
		{
			if(v1.envclock>=(v1.env&7))
			{
				v1.envclock=0;
				if(v1.env&8)
				{
					if(v1.volume<15) ++v1.volume;
				} else
				{
					if(v1.volume) --v1.volume;
				}
			} else
				++v1.envclock;
		}
		if(y2 && (v2.env&7))
		{
			if(v2.envclock>=(v2.env&7))
			{
				v2.envclock=0;
				if(v2.env&8)
				{
					if(v2.volume<15) ++v2.volume;
				} else
				{
					if(v2.volume) --v2.volume;
				}
			} else
				++v2.envclock;
		}
		if(y4 && (v4.env&7))
		{
			if(v4.envclock>=(v4.env&7))
			{
				v4.envclock=0;
				if(v4.env&8)
				{
					if(v4.volume<15) ++v4.volume;
				} else
				{
					if(v4.volume) --v4.volume;
				}
			} else
				++v4.envclock;
		}

		vol1=v1.volume<<1;
		vol2=v2.volume<<1;
		vol3=v3.volume;
		if(vol3>3) y3=0;
		vol4=v4.volume;
		duty1=v1.duty;
		duty2=v2.duty;

		if(quiet || interact || paused) y1=y2=y3=y4=0;
		i=len>>1;
		filled+=i;
		while(i--)
		{
			v=127;
			if(y1 && fa<CUTOFF)
			{
				v+= duty1[(sa>>15)&7] ? +vol1 : -vol1;
				sa+=fa;
			}
			if(y2 && fb<CUTOFF)
			{
				v+= duty2[(sb>>15)&7] ? +vol2 : -vol2;
				sb+=fb;
			}
			if(y3 && fc<CUTOFF)
			{
				v+=v3tab[(sound3counter>>14)&31]>>vol3;
				sound3counter+=fc;
			}
			if(y4)
			{
				++sd;
				if(sd>=fd)
				{
					randbyte=(rand()&0x3f)-32;
					sd=0;
				}
				v+=randbyte*vol4 >>4;
			}
			*buffer++=v;
		}
	}

}

int soundopen(void)
{
SDL_AudioSpec wanted;

	fragment=SNDFRAGMENT;

	memset(&wanted,0,sizeof(wanted));
	wanted.freq=32768;
	wanted.channels=1;
	wanted.format=AUDIO_U8;
	wanted.samples=fragment;
	wanted.callback=fillaudio;
	wanted.userdata=0;

	if(SDL_OpenAudio(&wanted,0)<0)
	{
		fprintf(stderr,"Couldn't open audio: %s\n",SDL_GetError());
		return -1;
	}
	soundworking=1;

	SDL_PauseAudio(0);
	return 0;
}
void soundclose(void)
{
	if(soundworking)
	{
		SDL_CloseAudio();
		soundworking=0;
	}
}

void invertaudio(void)
{
	quiet=!quiet;
	if(!quiet)
	{
		if ( SDL_Init(SDL_INIT_AUDIO) < 0 )
		{
			fprintf(stderr, "Couldn't initialize SDL: %s\n",SDL_GetError());
			exit(1);
		}
		soundopen();
	} else
		soundclose();
}
