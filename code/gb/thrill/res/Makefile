SUBDIRS:=fire gmb jfont misc pin text

all: $(SUBDIRS)
	./resall

clean: $(SUBDIRS)
	rm -f sprites.b?? sprites.pal filesys.b?? *.asm *.equ

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
