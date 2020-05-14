SUBDIRS:=dave john

all: $(SUBDIRS)
	./resusa   # ./resintl

clean: $(SUBDIRS)
	rm -f sprites.b?? filesys.b?? *.list *.asm *.equ sprites.lst filesys.lst sprites.pal

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
