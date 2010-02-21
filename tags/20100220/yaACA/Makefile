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
# Purpose:	Makefile for yaACA 
# Mods:		2004-09-15 RSB.	Began. 
#		2004-09-16 RSB	Got it to compile in Win32 (had already
#				worked in Linux) with Paul Fjeld's help.
#		2005-04-30 RSB	Added CFLAGS
#		2009-03-06 RSB	Adapted for the 'all-archs' target.
#		2009-04-08 RSB	Added yaACA-cfg.exe.
#		2009-05-04 RSB	Made some SOLARIS-based fixes.

.PHONY: default
default: yaACA

.PHONY: all-archs
all-archs: default yaACA.exe yaACA-cfg.exe yaACA-macosx

ALLEGRO_EXTRA_LIBS=\
	-lkernel32 -luser32 -lgdi32 -lcomdlg32 -lole32 \
	-ldinput -lddraw -ldxguid -lwinmm -ldsound
ifdef MSYSTEM
EXENAME:=yaACA.exe
ifndef PREFIX
PREFIX=/mingw
endif
ALLEGRO:=-lalleg_s -lwsock32 ${ALLEGRO_EXTRA_LIBS}
else	# MSYSTEM
EXENAME:=yaACA
ifndef PREFIX
PREFIX=/usr/local
endif
ALLEGRO:=`allegro-config --libs`
endif	# MSYSTEM
ifdef SOLARIS
ALLEGRO:=`allegro-config --static --libs`
ALLEGRO+=-L/usr/local/lib
ALLEGRO+=-lsocket
ALLEGRO+=-lnsl
endif

CFILES:=$(wildcard *.c)

yaACA: $(CFILES:%.c=%.o)
	gcc ${CFLAGS} -o $@ $^ -L../yaAGC -lyaAGC ${ALLEGRO}

yaACA-nay.exe: ${CFILES} ../yaAGC/agc_utilities.c
	i386-mingw32-gcc -I../yaAGC \
		${CFLAGS} -DNVER=${NVER} \
		-DALLEGRO_STATICLINK \
		-Wl,--subsystem,windows \
		-Wall -o $@ $^ \
		-lalleg_s -lwsock32 ${ALLEGRO_EXTRA_LIBS}

yaACA-cfg.exe: ${CFILES} ../yaAGC/agc_utilities.c
	i386-mingw32-gcc -I../yaAGC \
		${CFLAGS} -DNVER=${NVER} \
		-DALLEGRO_STATICLINK \
		-Wall -o $@ $^ \
		-lalleg_s -lwsock32 ${ALLEGRO_EXTRA_LIBS}

# We actually compile 2 separate versions of yaACA for Windows.
# One (yaACA) is for use during the normal simulation, while
# the other (yaACA-cfg) is used only by jWiz.  The difference
# is that yaACA-cfg has console output, but for some reason
# cannot access the joystick whilst connected to yaAGC.
yaACA.exe: ${CFILES} ../yaAGC/agc_utilities.c
	i386-mingw32-gcc -I../yaAGC \
		${CFLAGS} -DNVER=${NVER} \
		-DALLEGRO_STATICLINK \
		-Wl,--subsystem,windows \
		-Wall -o $@ $^ \
		-lalleg_s -lwsock32 ${ALLEGRO_EXTRA_LIBS}

yaACA-macosx: ${CFILES} ../yaAGC/agc_utilities.c
	powerpc-apple-darwin9-gcc -arch ppc -arch i386 -I../yaAGC \
		`${HOME}/IMCROSS/mac/bin/allegro-config --cflags` \
		${CFLAGS} -DNVER=${NVER} \
		-Wall -o $@ $^ \
		`${HOME}/IMCROSS/mac/bin/allegro-config --libs`

clean:
	-rm -f yaACA *.o *~ *.exe *-macosx

install: yaACA
	cp yaACA ${PREFIX}/bin/${EXENAME}
	chmod ugo+x ${PREFIX}/bin/${EXENAME}

%.o:	%.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX} -Wall -c -I../yaAGC -o $@ $<
	

