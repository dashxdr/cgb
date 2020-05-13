SUBDIRS:=fire pin misc gmb printer jfont text

all: $(SUBDIRS)
	./resall
clean: $(SUBDIRS)
	rm -f filesys.asm filesys.b?? sprites.b?? sprites.asm sprites.equ sprites.pal

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
