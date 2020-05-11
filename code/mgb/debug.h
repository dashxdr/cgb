struct symbol {
	struct symbol *next;
	char *name;
	unsigned char bank;
	unsigned short addr;
};

extern char *getname(unsigned char bank,unsigned short addr);
extern int setbreak(unsigned char bank,unsigned short addr,int count);
extern void clearbreak(unsigned char bank,unsigned short addr);
extern int clearbreakn(int);
extern struct symbol *findsym(char *name);
extern char *complete(char *basename);
extern int *ihistory,ihistoryin;
#define IHISTORYSIZE 65536
