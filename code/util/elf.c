#include <elf.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

unsigned char *data;
int datalen;

#define MAXSIZE 0x800000

#define MAXPIECES 256
struct piece {
	int offset;
	int len;
	int put;
} pieces[MAXPIECES];

int romlen;
unsigned char *armrom=0;

dumpelf(unsigned char *data,int datalen)
{
int i,j;
unsigned char *p,*t;
Elf32_Ehdr *ehdr;
Elf32_Shdr *shdr;
char *strings,*name;
Elf32_Sym *symtab=0;
int symsize;
char *stringtab=0;
int stringsize;
Elf32_Phdr *phdr;
int numpieces;
unsigned int minpos,maxpos;

	ehdr=(Elf32_Ehdr *)data;
	printf("%8x e_type\n",ehdr->e_type);
	printf("%8x e_machine\n",ehdr->e_machine);
	printf("%8x e_version\n",ehdr->e_version);
	printf("%8x e_entry\n",ehdr->e_entry);
	printf("%8x e_phoff\n",ehdr->e_phoff);
	printf("%8x e_shoff\n",ehdr->e_shoff);
	printf("%8x e_flags\n",ehdr->e_flags);
	printf("%8x e_ehsize\n",ehdr->e_ehsize);
	printf("%8x e_phentsize\n",ehdr->e_phentsize);
	printf("%8x e_phnum\n",ehdr->e_phnum);
	printf("%8x e_shentsize\n",ehdr->e_shentsize);
	printf("%8x e_shnum\n",ehdr->e_shnum);
	printf("%8x e_shnum\n",ehdr->e_shnum);
	printf("%8x e_shstrndx\n",ehdr->e_shstrndx);

	strings=data+((Elf32_Shdr *)
			(data+ehdr->e_shoff+ehdr->e_shstrndx*ehdr->e_shentsize))->sh_offset;

	for(i=0;i<ehdr->e_shnum;++i)
	{
		shdr=(Elf32_Shdr *)(data+ehdr->e_shoff+i*ehdr->e_shentsize);
		printf("---- Section %3d ----\n",i);
		name=strings+shdr->sh_name;
		printf("%8x sh_name %s\n",shdr->sh_name,name);
		printf("%8x sh_type\n",shdr->sh_type);
		printf("%8x sh_flags\n",shdr->sh_flags);
		printf("%8x sh_addr\n",shdr->sh_addr);
		printf("%8x sh_offset\n",shdr->sh_offset);
		printf("%8x sh_size\n",shdr->sh_size);
		printf("%8x sh_link\n",shdr->sh_link);
		printf("%8x sh_info\n",shdr->sh_info);
		printf("%8x sh_addralign\n",shdr->sh_addralign);
		printf("%8x sh_entsize\n",shdr->sh_entsize);
		if(!strcmp(name,".symtab"))
		{
			symtab=(Elf32_Sym *)(data+shdr->sh_offset);
			symsize=shdr->sh_size;
		} else if(!strcmp(name,".strtab"))
		{
			stringtab=data+shdr->sh_offset;
			stringsize=shdr->sh_size;
		}
	}

	maxpos=0;
	minpos=~0;
	numpieces=0;
	for(i=0;i<ehdr->e_phnum;++i)
	{
		phdr=(Elf32_Phdr *)(data+ehdr->e_phoff+i*ehdr->e_phentsize);
		printf("---- Program Header %3d ----\n",i);
		printf(" %8x p_type\n",phdr->p_type);
		printf(" %8x p_offset\n",phdr->p_offset);
		printf(" %8x p_vaddr\n",phdr->p_vaddr);
		printf(" %8x p_paddr\n",phdr->p_paddr);
		printf(" %8x p_filesz\n",phdr->p_filesz);
		printf(" %8x p_memsz\n",phdr->p_memsz);
		printf(" %8x p_flags\n",phdr->p_flags);
		printf(" %8x p_align\n",phdr->p_align);
		if(phdr->p_type==PT_LOAD && phdr->p_offset && phdr->p_filesz)
		{
			pieces[numpieces].offset=phdr->p_offset;
			pieces[numpieces].len=phdr->p_filesz;
			pieces[numpieces].put=phdr->p_vaddr;
			++numpieces;
			if(phdr->p_vaddr<minpos) minpos=phdr->p_vaddr;
			if(phdr->p_vaddr+phdr->p_filesz>maxpos)
				maxpos=phdr->p_vaddr+phdr->p_filesz;
		}
	}
	if(numpieces)
	{
		if(armrom) {free(armrom);armrom=0;}
		romlen=maxpos-minpos;
		armrom=malloc(romlen);
		if(!armrom)
		{
			printf("No memory for rom image, %d bytes\n",romlen);
			exit(-1);
		}
		memset(armrom,0,romlen);
		for(i=0;i<numpieces;++i)
			memcpy(armrom+pieces[i].put-minpos,data+pieces[i].offset,
					pieces[i].len);
	}


	if(symtab && stringtab)
	{
		int bind,type;
		i=0;
		while(symsize>=sizeof(Elf32_Sym))
		{
			printf("---- Symbol %4d: %s\n",i++,stringtab+symtab->st_name);
			printf(" %08x st_value\n",symtab->st_value);
			printf(" %08x st_size\n",symtab->st_size);
			printf(" %08x st_info",symtab->st_info);
			bind=symtab->st_info>>4;
			type=symtab->st_info&15;
			switch(bind)
			{
			case 0: printf(" STB_LOCAL");break;
			case 1: printf(" STB_GLOBAL");break;
			case 2: printf(" STB_WEAK");break;
			case 13: printf(" STB_LOPROC");break;
			case 14: printf(" STB_MIDPROC");break;
			case 15: printf(" STB_HIPROC");break;
			}
			switch(type)
			{
			case 0: printf(" STT_NOTYPE");break;
			case 1: printf(" STT_OBJECT");break;
			case 2: printf(" STT_FUNC");break;
			case 3: printf(" STT_SECTION");break;
			case 4: printf(" STT_FILE");break;
			case 13: printf(" STT_LOPROC");break;
			case 14: printf(" STT_MIDPROC");break;
			case 15: printf(" STT_HIPROC");break;
			}
			printf("\n");
			printf(" %08x st_other\n",symtab->st_other);
			printf(" %08x st_shndx\n",symtab->st_shndx);
			++symtab;
			symsize-=sizeof(Elf32_Sym);
		}
	}

}

main(int argc,char **argv)
{
int f;
	if(argc<2) return;
	data=malloc(MAXSIZE);
	f=open(argv[1],O_RDONLY);
	if(f<0) return;
	datalen=read(f,data,MAXSIZE);
	close(f);
	dumpelf(data,datalen);
}
