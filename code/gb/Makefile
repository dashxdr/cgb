SUBDIRS:=usamerm bb thrill

all: $(SUBDIRS)
clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
