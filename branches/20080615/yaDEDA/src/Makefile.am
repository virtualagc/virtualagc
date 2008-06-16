## Process this file with automake to produce Makefile.in

INCLUDES = \
	-DNVER=${NVER} \
	-DINSTALLDIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@ -I../../yaAGC

bin_PROGRAMS = yaDEDA

yaDEDA_SOURCES = \
	main.c \
	support.c support.h \
	interface.c interface.h \
	callbacks.c callbacks.h \
	hCreateMainWindow.c \
	../../yaAGS/Backtrace.c

yaDEDA_LDADD = @PACKAGE_LIBS@ $(INTLLIBS) -L../../yaAGC -lyaAGC

