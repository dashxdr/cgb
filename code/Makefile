SUBDIRS:=john util gbasm gb mgb

all: $(SUBDIRS)
clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)

play:
	mgb/mgb gb/usamerm/merm.gb
