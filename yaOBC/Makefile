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
# Purpose:	Makefile for the yaOBC emulator.
# Mods:		2011-12-23 RSB	Adapted from yaASM Makefile.
#
# The default is to build using the native gcc. To cross build from 
# Linux to get Win32 and Mac OS X executables as well (make all-archs), 
# you need to have IMCROSS (http://www/sandroid.org/imcross) installed.

TARGET=yaOBC
TARGET2=enetHost

ifndef PREFIX
ifdef MSYSTEM
PREFIX=/mingw
SUFFIX=.exe
endif
else	# MSYSTEM
PREFIX=/usr/local
endif	# MSYSTEM

ifdef WIN32
WLIBS=-lwsock32 -lws2_32 -lwinmm
endif

ifeq "${USER}" "rburkey"
CFLAGS+=-Wall -Werror -O3
WEB=${HOME}/Projects/sandroid.org/public_html/apollo/Downloads
SAVE=cp ${TARGET} ${TARGET2} *.exe *-macosx ${WEB}
else
SAVE=echo "All done!"
endif

.PHONY:	default
default: ${TARGET} ${TARGET2}

.PHONY: all-archs
all-archs: \
	${TARGET} ${TARGET}.exe ${TARGET}-macosx \
	${TARGET2} ${TARGET2}.exe ${TARGET2}-macosx
	${SAVE}

${TARGET} ${TARGET2}: % : %.c ../yaASM/yaASM.h Makefile
	${cc} -pthread ${CFLAGS} -o $@ -I../enet/include \
		$< ../enet/*.c -lpthread -lm $(WLIBS)

${TARGET}.exe ${TARGET2}.exe: %.exe : %.c ../yaASM/yaASM.h Makefile
	i386-mingw32-${cc} -DPTW32_STATIC_LIB -O3 -o $@ \
		-I../enet/include $< ../enet/*.c \
		-lpthreadGC2-static -lm -lwsock32 -lws2_32 -lwinmm

${TARGET}-macosx ${TARGET2}-macosx: %-macosx : %.c ../yaASM/yaASM.h Makefile
	powerpc-apple-darwin9-${cc} -arch i386 -arch ppc -O3 \
		-o $@ -I../enet/include $< ../enet/*.c -lpthread -lm

.PHONY:	clean
clean:
	-rm ${TARGET} ${TARGET2} *.exe *-macosx \
		*.o *.bin *.lst *.io *~

%.o:	%.c ../yaYUL/yaYUL.h
	${cc} ${CFLAGS} -DNVER=${NVER} -c -o $@ $<
	

