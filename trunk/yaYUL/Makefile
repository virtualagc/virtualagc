# Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the yaYUL assembler.
# Mods:		04/11/03 RSB.	Began. 
#		10/22/03 RSB.	Added the "install" target.
#		05/14/04 RSB.	Added PREFIX.
#		04/30/05 RSB	Added CFLAGS

ifndef PREFIX
PREFIX=/usr/local
endif

CFILES:=$(wildcard *.c)

yaYUL:	$(CFILES:%.c=%.o)
	gcc ${CFLAGS} -o $@ $^ -lm

clean:
	-rm yaYUL *.o *~

install: yaYUL
	cp  yaYUL ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/yaYUL

%.o:	%.c yaYUL.h
	gcc ${CFLAGS} -DORIGINAL_SBANK_SURMISE -DNVER=${NVER} -g -O0 -DINSTALLDIR=${PREFIX} -Wall -c -o $@ $<
	

