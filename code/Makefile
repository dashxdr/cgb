SUBDIRS:=john util gbasm gb mgb anim

all: $(SUBDIRS)
clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)

play:
	mgb/mgb gb/usamerm/merm.gb
play2:
	mgb/mgb gb/bb/bb.gb
play3:
	mgb/mgb gb/thrill/thrill.gb

fixpcx:
	mkdir -p /tmp/x
	for zzz in `find -name *.pcx | sed -e 's/^..//'` ; do convert $$zzz /tmp/x/`echo $$zzz | tr / -`.png ; done
