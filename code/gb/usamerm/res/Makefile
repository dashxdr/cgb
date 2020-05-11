SUBDIRS:=fire pin misc gmb printer jfont text

all: $(SUBDIRS)
	./resall
clean: $(SUBDIRS)
	rm -f filesys.asm filesys.b?? sprites.b??

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
