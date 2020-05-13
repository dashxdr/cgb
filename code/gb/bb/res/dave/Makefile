SUBDIRS:=cellar chip chopper dance fire font kiss logo misc ride
SUBDIRS+=spit stove sultan whackoff sgb

all: $(SUBDIRS)
clean: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
