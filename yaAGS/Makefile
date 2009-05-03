# Copyright 2005 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:	Makefile
# Purpose:	Makefile for the AGS (AEA) simulation,
# Contact:	Ron Burkey <info@sandroid.org>
# Reference:	http://www.ibiblio.org/apollo/yaAGS.html
# Mods:		2005-02-13 RSB	Adapted from yaAGC Makefile
#		2005-06-02 RSB	... continued.
#		2005-08-04 RSB	Added the CURSES variable.
#		2005-08-06 RSB	... removed it again, and added a path
#				where libcurses.a can be found on some systems.
#				(Sometimes it is in /usr/lib, sometimes in
#				/usr/lib/curses, maybe other places as well.
#		2009-03-06 RSB	Added the 'all-archs' target and adjusted
#				'clean' appropriately.
#		.......... OH	... something ...
#		2009-04-25 RSB	Fixed up the all-archs target.  Fixed up the
#				native-Mac build.
#		2009-05-03 RSB	Adjusted for SOLARIS.

LIBS=${LIBS2}

ifndef PREFIX
PREFIX=/usr/local
endif

.PHONY: default
default: yaAGS

#---------------------------------------------------------------------------
# The use of libreadline adds a command-history to yaAGC, but may have some
# other side effects.  It it turns out to be a problem, do this:
#	export NOREADLINE=yes
#	make
# instead of just 'make'.  However, I don't really recommend it, and don't
# guarantee that it works any longer.
LIBS0:=${LIBS}
ifndef NOREADLINE
CFLAGS2 = -DUSE_READLINE
ifdef MACOSX
CFLAGS2 += -I/usr/local/include
LIBS += /usr/local/lib/libreadline.a
else #MACOSX
#ifdef SOLARIS
#LIBS += /usr/local/lib/libreadline.a
#else # SOLARIS
#LIBS += -lreadline
#endif # SOLARIS
LIBS += -lreadline
endif # MACOSX
endif	# NOREADLINE

ifeq "${USER}" "rburkey"
STATIC=-static
endif

yaAGS:	mainAGS.o libyaAGS.a symbol_table.o nbfgets.o Backtrace.o
	gcc ${CFLAGS} ${CFLAGS2} -o yaAGS $^ ${STATIC} -L. -L../yaAGC -lpthread -lyaAGS -lyaAGC -lm ${LIBS} ${CURSES}

libyaAGS.a: aea_engine_init.o aea_engine.o DebuggerHookAGS.o SocketAPI_AGS.o
	ar -rc $@ $^
	ranlib $@
	touch ../yaDEDA/src/main.c

clean:
	-rm -f yaAGS libyaAGS.a *.o *~ *.bak *.elf *.o68 *.o8 *.rel *.exe *-macosx

install:	yaAGS
	cp yaAGS ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/yaAGS

%.o:	%.c aea_engine.h
	gcc -g ${CFLAGS} ${CFLAGS2} -DNVER=${NVER} -I../yaAGC -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<

#----------------------------------------------------------------------------------
# Building for multiple architectures, using IMCROSS.  Since IMCROSS presently
# does not support readline, I eliminate readline-support from the cross-builds.
# It would be added back by adding ${CFLAGS2} and changing ${LIBS0} to ${LIBS}.

.PHONY: all-archs
all-archs: default yaAGS.exe yaAGS-macosx

CSOURCE:=mainAGS.c aea_engine_init.c aea_engine.c DebuggerHookAGS.c SocketAPI_AGS.c \
	 ../yaAGC/nbfgets.c symbol_table.c \
	 ../yaAGC/rfopen.c ../yaAGC/SocketAPI.c ../yaAGC/agc_utilities.c \
	 ../yaAGC/agc_engine.c ../yaAGC/Backtrace.c

yaAGS.exe: ${CSOURCE} ../yaAGC/regex.c ../yaAGC/random.c
	i386-mingw32-gcc -DSTDC_HEADERS  -DPTW32_STATIC_LIB \
		${CFLAGS} ${CFLAGS2} -DNVER=${NVER} -I../yaAGC \
		-o $@ $^ -L. ${LIBS0} -lreadline -lpthreadGC2-static -lkernel32 -lwsock32

MACDIR:=${HOME}/IMCROSS/mac
yaAGS-macosx: ${CSOURCE}
	powerpc-apple-darwin9-gcc -arch ppc -arch i386 -DSTDC_HEADERS \
		-I${MACDIR}/include -L${MACDIR}/lib \
		${CFLAGS} ${CFLAGS2} -DNVER=${NVER} -I ../yaAGC \
		-o $@ $^ ${MACDIR}/lib/libreadline.a -L. ${LIBS0} -lpthread -lm -lcurses


