SUBDIRS:=cellar chip chopper ride stove sultan target whack
all: $(SUBDIRS)
	./resall
clean: $(SUBDIRS)
	rm -f *.hi *.lo *.map *.chr *.pkg *.equ *.rgb
	rm -rf swd

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
