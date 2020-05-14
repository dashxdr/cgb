SUBDIRS:=dave john

all: $(SUBDIRS)
	./resusa   # ./resintl

clean: $(SUBDIRS)
	rm -f sprites.b?? filesys.b?? *.list *.asm *.equ filesys.lst

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
