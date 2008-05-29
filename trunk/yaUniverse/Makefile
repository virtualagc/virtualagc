# Copyright 2004,2005 Ronald S. Burkey <info@sandroid.org>
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

CFILES:=$(wildcard *.c)

${EXENAME}: $(CFILES:%.c=%.o)
	gcc ${CFLAGS} -o $@ $^ -L../yaAGC -lyaAGC -lm

clean:
	-rm ${EXENAME} *.o *~

install: ${EXENAME}
	cp ${EXENAME} ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/${EXENAME}
	-cp Ephemeris*.txt ${PREFIX}/bin

%.o:	%.c yaUniverse.h
	gcc ${CFLAGS} -DNVER=${NVER} -g -O0 -DINSTALLDIR=${PREFIX} -Wall -c -o $@ $<
	

