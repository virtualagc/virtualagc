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

ifndef PREFIX
PREFIX=/usr/local
endif

#---------------------------------------------------------------------------
# The use of libreadline adds a command-history to yaAGC, but may have some
# other side effects.  It it turns out to be a problem, do this:
#	export NOREADLINE=yes
#	make
# instead of just 'make'.
ifndef NOREADLINE
CFLAGS2 = -DUSE_READLINE
LIBS += -L/sw/lib -lreadline
LIBS += -L/usr/lib/curses -lcurses
endif	# NOREADLINE

yaAGS:	mainAGS.o libyaAGS.a ../yaAGC/nbfgets.o ../yaAGC/symbol_table.o 
	gcc -o yaAGS $^ -L. -L../yaAGC -lpthread -lyaAGS -lyaAGC -lm ${LIBS}

libyaAGS.a: aea_engine_init.o aea_engine.o DebuggerHookAGS.o SocketAPI_AGS.o
	ar -rc $@ $^
	ranlib $@
	touch ../yaDEDA/src/main.c

clean:
	-rm yaAGS libyaAGS.a *.o *~ *.bak *.elf *.o68 *.o8 *.rel

install:	yaAGS
	cp yaAGS ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/yaAGS

%.o:	%.c aea_engine.h
	gcc -I/sw/include -g ${CFLAGS} ${CFLAGS2} -DNVER=${NVER} -I../yaAGC -DINSTALLDIR="\"${PREFIX}/bin\"" -c -o $@ $<
	
