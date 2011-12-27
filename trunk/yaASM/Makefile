# Copyright 2010 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the yaASM assembler.
# Mods:		2010-01-30 RSB	Adapted from yaLEMAP Makefile.
#
# The default is to build using the native gcc. To cross build from 
# Linux to get Win32 and Mac OS X executables as well (make all-archs), 
# you need to have IMCROSS (http://www/sandroid.org/imcross) installed.

ifndef PREFIX
ifdef MSYSTEM
PREFIX=/mingw
SUFFIX=.exe
endif
else	# MSYSTEM
PREFIX=/usr/local
endif	# MSYSTEM

ifeq "${USER}" "rburkey"
CFLAGS+=-Wall -Werror -O3
WEB=${HOME}/Projects/sandroid.org/public_html/apollo/Downloads
SAVE=cp yaASM yaASM.exe yaASM-macosx Test.obc ${WEB}
else
SAVE=echo "All done!"
endif

.PHONY:	default
#default: SampleCodeASM.lst
default: yaASM

.PHONY: all-archs
all-archs: yaASM yaASM.exe yaASM-macosx
	${SAVE}

SampleCodeASM.lst: yaASM SampleCodeASM.obc
	./yaASM SampleCodeASM.obc
	mv yaASM.bin SampleCodeASM.bin
	mv yaASM.lst SampleCodeASM.lst

yaASM: yaASM.c yaASM.h Makefile
	gcc ${CFLAGS} -m32 -o $@ $< -lm

yaASM.exe: yaASM.c yaASM.h Makefile
	i386-mingw32-gcc ${CFLAGS} -o $@ $< -lm

yaASM-macosx: yaASM.c yaASM.h Makefile
	powerpc-apple-darwin9-gcc -arch i386 -arch ppc ${CFLAGS} -o $@ $< -lm

.PHONY:	clean
clean:
	-rm binASM yaASM *.exe *-macosx \
		*.o *.bin *.lst *.io *~

%.o:	%.c ../yaYUL/yaYUL.h
	gcc ${CFLAGS} -DNVER=${NVER} -c -o $@ $<
	

