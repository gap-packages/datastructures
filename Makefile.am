ACLOCAL_AMFLAGS = -I m4

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/gapdata.so

lib_LTLIBRARIES = gapdata.la

gapdata_la_SOURCES = src/avltree.c src/avltree.h src/gapdata.c src/hashtable.c src/misc.c src/hashtable.h src.misc.h
gapdata_la_CPPFLAGS = $(GAP_CPPFLAGS) -DCONFIG_H
# Note that the latter is only for GAP 4.4.12
gapdata_la_LDFLAGS = -module -avoid-version -Bsymbolic 
if SYS_IS_CYGWIN
gapdata_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: gapdata.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
if SYS_IS_CYGWIN
	cp .libs/gapdata.dll $(GAPINSTALLLIB)
else
	cp .libs/gapdata.so $(GAPINSTALLLIB)
endif
	@echo "SUCCESS!"

distclean-local:
	rm -rf bin/*
	(cd doc ; ./clean)

doc:	doc/manual.six

doc/manual.six: doc/*.xml PackageInfo.g
	($(GAPROOT)/bin/gap.sh -A makedoc.g)
