SUBDIRS:=fire gmb jfont misc pin text

all: $(SUBDIRS)
	./resall

clean: $(SUBDIRS)
	rm -f sprites.b?? filesys.b?? *.asm *.equ sprites.lst filesys.lst

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
