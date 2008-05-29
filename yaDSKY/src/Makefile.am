## Process this file with automake to produce Makefile.in

INCLUDES = \
	-DNVER=${NVER} \
	-DINSTALLDIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@ -I../../yaAGC

bin_PROGRAMS = yadsky

yadsky_SOURCES = \
	main.c \
	support.c support.h \
	interface.c interface.h \
	callbacks.c callbacks.h \
	hCreateMainWindow.c

yadsky_LDADD = @PACKAGE_LIBS@ -L../../yaAGC -lyaAGC

