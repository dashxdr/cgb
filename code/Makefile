SUBDIRS:=john util gbasm gb mgb

all: $(SUBDIRS)
clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)

play:
	mgb/mgb gb/usamerm/merm.gb

fixpcx:
	mkdir -p /tmp/x
	for zzz in `find -name *.pcx | sed -e 's/^..//'` ; do convert $$zzz /tmp/x/`echo $$zzz | tr / -`.png ; done
