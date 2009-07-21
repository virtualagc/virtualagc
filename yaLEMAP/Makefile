# Copyright 2005,2009 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the yaLEMAP assembler and friends.
# Mods:		01/12/05 RSB.	Adapted from yaYUL's makefile.
#		01/18/05 RSB	Added FP8. 
#		01/23/05 RSB	Added FP6.
#		04/30/05 RSB	Added CFLAGS.  No longer is 'clean' 
#				for the default target.
#		06/02/05 RSB	FP6.bin and FP8.bin added to list of files
#				to install.
#		08/04/05 RSB	Took care of FP[6].symtab
#		03/06/09 RSB	Added the 'all-archs' target, and modified
#				'clean' to account for Win32 and Mac
#				versions of the program as built on Linux.  
#				The 'all-archs' target assumes that 
#				IMCROSS (www.sandroid.org/imcross) is 
#				installed.
#		2009-07-04 RSB	Added --html switch.

ifndef PREFIX
ifdef MSYSTEM
PREFIX=/mingw
SUFFIX=.exe
endif
else	# MSYSTEM
PREFIX=/usr/local
endif	# MSYSTEM

.PHONY:	default
default: binLEMAP SampleCodeAGS.lst \
	../FP8/FP8.lst ../FP8/FP8.bin ../FP8/FP8.symtab \
	../FP6/FP6.lst ../FP6/FP6.bin ../FP6/FP6.symtab

.PHONY: all-archs
all-archs: default binLEMAP.exe binLEMAP-macosx yaLEMAP.exe yaLEMAP-macosx

../FP8/FP8.lst ../FP8/FP8.bin ../FP8/FP8.symtab: yaLEMAP ../FP8/FP8.aea
	./yaLEMAP --html ../FP8/FP8.aea
	mv yaLEMAP.bin ../FP8/FP8.bin
	mv yaLEMAP.symtab ../FP8/FP8.symtab
	mv yaLEMAP.lst ../FP8/FP8.lst

../FP6/FP6.lst ../FP6/FP6.bin ../FP6/FP6.symtab: yaLEMAP ../FP6/FP6.aea
	./yaLEMAP --html ../FP6/FP6.aea
	mv yaLEMAP.bin ../FP6/FP6.bin
	mv yaLEMAP.symtab ../FP6/FP6.symtab
	mv yaLEMAP.lst ../FP6/FP6.lst

SampleCodeAGS.lst: yaLEMAP SampleCodeAGS.aea
	@echo \*\*\* The following operation should result in 13 errors and 3 warnings. \*\*\*
	./yaLEMAP --compare=binLEMAP.bin SampleCodeAGS.aea
	mv yaLEMAP.bin SampleCodeAGS.bin
	mv yaLEMAP.lst SampleCodeAGS.lst

binLEMAP: binLEMAP.c
	gcc ${CFLAGS} -o $@ $^
	./binLEMAP <SampleCodeAGS.binsource

binLEMAP.exe: binLEMAP.c
	i386-mingw32-gcc ${CFLAGS} -o $@ $^

binLEMAP-macosx: binLEMAP.c
	powerpc-apple-darwin9-gcc -arch i386 -arch ppc ${CFLAGS} -o $@ $^

yaLEMAP: yaLEMAP.c ../yaYUL/SymbolTable.c
	gcc ${CFLAGS} -o $@ $^ -lm

yaLEMAP.exe: yaLEMAP.c ../yaYUL/SymbolTable.c
	i386-mingw32-gcc ${CFLAGS} -o $@ $^ -lm

yaLEMAP-macosx: yaLEMAP.c ../yaYUL/SymbolTable.c
	powerpc-apple-darwin9-gcc -arch i386 -arch ppc ${CFLAGS} -o $@ $^ -lm

.PHONY:	clean
clean:
	-rm binLEMAP yaLEMAP *.exe *-macosx \
		*.o *~ yaLEMAP.binsource \
		binLEMAP.bin SampleCodeAGS.bin SampleCodeAGS.lst \
		../FP8/FP8.bin ../FP8/FP8.lst ../FP8/*.symtab \
		../FP6/FP6.bin ../FP6/FP6.lst ../FP6/*.symtab

.PHONY:	install
install: default
	cp binLEMAP ${PREFIX}/bin/binLEMAP${SUFFIX} 
	cp yaLEMAP ${PREFIX}/bin/yaLEMAP${SUFFIX}
	-chmod ugo+x ${PREFIX}/bin/binLEMAP${SUFFIX} ${PREFIX}/bin/yaLEMAP${SUFFIX}
	mv ../FP6/FP6.bin ../FP6/FP6.symtab ${PREFIX}/bin
	mv ../FP8/FP8.bin ../FP8/FP8.symtab ${PREFIX}/bin
	

%.o:	%.c ../yaYUL/yaYUL.h
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX} -Wall -c -o $@ $<
	

