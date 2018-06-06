ACLOCAL_AMFLAGS = -I m4

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/datastructures.so

lib_LTLIBRARIES = datastructures.la

datastructures_la_SOURCES = \
    src/binaryheap.c \
    src/binaryheap.h \
    src/hashmap.c \
    src/hashmap.h \
    src/hashfunctions.c \
    src/hashfunctions.h \
    src/pairingheap.c \
    src/pairingheap.h \
    src/datastructures.c \
    src/datastructures.h \
    src/skiplist.c \
    src/avl.c \
    src/uf.c \
    src/uf.h

datastructures_la_CPPFLAGS = $(GAP_CPPFLAGS)
datastructures_la_CFLAGS = $(GAP_CFLAGS)
datastructures_la_LDFLAGS = $(GAP_LDFLAGS) -module -avoid-version -Bsymbolic
if SYS_IS_CYGWIN
datastructures_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: datastructures.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
if SYS_IS_CYGWIN
	cp .libs/datastructures.dll $(GAPINSTALLLIB)
else
	cp .libs/datastructures.so $(GAPINSTALLLIB)
endif
	@echo "SUCCESS!"

distclean-local:
	rm -rf bin/*
	(cd doc ; ./clean)

doc:	doc/manual.six

doc/manual.six: doc/*.xml gap/*.g* src/*.* PackageInfo.g
	($(GAPROOT)/bin/gap.sh -A --quitonbreak < makedoc.g)

.PHONY: doc
