SUBDIRS:=small intro match story multiend board shell target trivia
SUBDIRS+=mirror gaston lucky knight font marker maps strings

all: $(SUBDIRS)
clean: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(SUBDIRS)
