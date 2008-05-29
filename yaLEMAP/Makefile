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
# Purpose:	Makefile for the yaLEMAP assembler and friends.
# Mods:		01/12/05 RSB.	Adapted from yaYUL's makefile.
#		01/18/05 RSB	Added FP8. 
#		01/23/05 RSB	Added FP6.
#		04/30/05 RSB	Added CFLAGS.  No longer is 'clean' 
#				for the default target.
#		06/02/05 RSB	FP6.bin and FP8.bin added to list of files
#				to install.
#		08/04/05 RSB	Took care of FP[6].symtab

ifndef PREFIX
ifdef MSYSTEM
PREFIX=/mingw
endif
else	# MSYSTEM
PREFIX=/usr/local
endif	# MSYSTEM

.PHONY:	default
default: binLEMAP${SUFFIX} SampleCodeAGS.lst \
	../FP8/FP8.lst ../FP8/FP8.bin ../FP8/FP8.symtab \
	../FP6/FP6.lst ../FP6/FP6.bin ../FP6/FP6.symtab

../FP8/FP8.lst ../FP8/FP8.bin ../FP8/FP8.symtab: yaLEMAP${SUFFIX} ../FP8/FP8.s
	./yaLEMAP ../FP8/FP8.s
	mv yaLEMAP.bin ../FP8/FP8.bin
	mv yaLEMAP.symtab ../FP8/FP8.symtab
	mv yaLEMAP.lst ../FP8/FP8.lst

../FP6/FP6.lst ../FP6/FP6.bin ../FP6/FP6.symtab: yaLEMAP${SUFFIX} ../FP6/FP6.s
	./yaLEMAP ../FP6/FP6.s
	mv yaLEMAP.bin ../FP6/FP6.bin
	mv yaLEMAP.symtab ../FP6/FP6.symtab
	mv yaLEMAP.lst ../FP6/FP6.lst

SampleCodeAGS.lst: yaLEMAP${SUFFIX} SampleCodeAGS.s
	@echo \*\*\* The following operation should result in 13 errors and 3 warnings. \*\*\*
	./yaLEMAP --compare=binLEMAP.bin SampleCodeAGS.s
	mv yaLEMAP.bin SampleCodeAGS.bin
	mv yaLEMAP.lst SampleCodeAGS.lst

binLEMAP${SUFFIX}: binLEMAP.c
	gcc ${CFLAGS} -o $@ $^
	./binLEMAP <SampleCodeAGS.binsource

yaLEMAP${SUFFIX}: yaLEMAP.c ../yaYUL/SymbolTable.o
	gcc ${CFLAGS} -g -o $@ $^ -lm

.PHONY:	clean
clean:
	-rm binLEMAP${SUFFIX} yaLEMAP${SUFFIX} *.o *~ yaLEMAP.binsource \
		binLEMAP.bin SampleCodeAGS.bin SampleCodeAGS.lst \
		../FP8/FP8.bin ../FP8/FP8.lst ../FP8/*.symtab \
		../FP6/FP6.bin ../FP6/FP6.lst ../FP6/*.symtab

.PHONY:	install
install: default
	cp  binLEMAP${SUFFIX} yaLEMAP${SUFFIX} ${PREFIX}/bin
	-chmod ugo+x ${PREFIX}/bin/binLEMAP${SUFFIX} ${PREFIX}/bin/yaLEMAP${SUFFIX}
	mv ../FP6/FP6.bin ../FP6/FP6.symtab ${PREFIX}/bin
	mv ../FP8/FP8.bin ../FP8/FP8.symtab ${PREFIX}/bin
	

%.o:	%.c ../yaYUL/yaYUL.h
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX} -Wall -c -o $@ $<
	

