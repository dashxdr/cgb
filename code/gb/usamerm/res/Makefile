SUBDIRS:=fire pin misc gmb printer jfont text

all: $(SUBDIRS)
	./resall
clean: $(SUBDIRS)
	rm -f filesys.asm filesys.b?? sprites.b?? sprites.equ sprites.asm sprites.pal

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
