# Copyright 2004,2005,2009 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for yaUniverse 
# Mods:		08/25/04 RSB.	Began. 
#		2004-09-02 RSB	Changed to yaUniverse (from yaIMU).
#		2004-09-15 RSB	Added Win32.
#		2005-04-30 RSB	Added CFLAGS.
#		2009-03-06 RSB	Adjusted for the 'all-archs' target,
#				and relevant changes.

ifdef MSYSTEM
EXENAME:=yaUniverse.exe
ifndef PREFIX
PREFIX=/mingw
endif
else 	# MSYSTEM
EXENAME:=yaUniverse
ifndef PREFIX
PREFIX=/usr/local
endif
endif 	# MSYSTEM

ifdef NATIVE
PREFIX_WIN=
BIN_WIN=
else
PREFIX_WIN=i386-mingw32-
PREFIX_MAC=powerpc-apple-darwin9-
BIN_WIN=${HOME}/IMCROSS/i386-mingw32/bin/
BIN_MAC=${HOME}/IMCROSS/mac/bin/
INC_MAC=${HOME}/IMCROSS/mac/include
SDK_MAC=${HOME}/IMCROSS/mac/SDKs/MacOSX10.4u.sdk
endif


.PHONY: default
default: $(EXENAME)

.PHONY: all-archs
all-archs: default yaUniverse.exe yaUniverse-macosx

CFILES:=$(wildcard *.c)

yaUniverse: $(CFILES:%.c=%.o)
	gcc ${CFLAGS} -o $@ $^ -L../yaAGC -lyaAGC -lm

yaUniverse.exe: ${CFILES} ../yaAGC/rfopen.c
	$(PREFIX_WIN)gcc ${CFLAGS} -DNVER=${NVER} -Wall -o $@ $^ -lm

yaUniverse-macosx: ${CFILES} ../yaAGC/rfopen.c
	$(PREFIX_MAC)gcc -arch ppc -arch i386 ${CFLAGS} -DNVER=${NVER} \
		-Wall -o $@ $^ -lm

clean:
	-rm -f yaUniverse *.o *~ *.exe *-macosx

install: yaUniverse
	cp yaUniverse ${PREFIX}/bin/${EXENAME}
	chmod ugo+x ${PREFIX}/bin/${EXENAME}
	-cp Ephemeris*.txt ${PREFIX}/bin

%.o:	%.c yaUniverse.h
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX} -Wall -c -o $@ $<
	

