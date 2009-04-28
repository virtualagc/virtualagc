# Copyright 2009 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	This makefile is used to build the yaACA3 program.
# Mods:		2009-03-28 RSB	Adapted yaACA2.
#		.......... OH	... something ...
#		2009-04-25 RSB	Undid some stylistic changes that broke the 
#				all-archs target.  Fixed NVER.  Undid the
#				conditional stuff associated with the
#				NATIVE flag, since it shouldn't be needed.
#				Changed back some stuff for the .exe 
#				sub-target of all-archs.

APPNAME=yaACA3

# For cross-platform building --- i.e., for building Win32 and Mac OS X versions
# of ${APPNAME} on a Linux platform --- it is assumed that the IMCROSS
# environment (www.sandroid.org/imcross) is installed.  It is further supposed
# that the IMCROSS installation directory is ~/IMCROSS and that ~/IMCROSS/bin 
# is in the PATH.  The following variables just reflect the default setup for
# IMCROSS.
PREFIX_WIN=i386-mingw32
PREFIX_MAC=powerpc-apple-darwin9
BIN_WIN=${HOME}/IMCROSS/i386-mingw32/bin
BIN_MAC=${HOME}/IMCROSS/mac/bin
INC_MAC=${HOME}/IMCROSS/mac/include
SDK_MAC=${HOME}/IMCROSS/mac/SDKs/MacOSX10.4u.sdk

# This is just so that when I build it, it will be statically linked.  For
# anybody else, it will just accept whatever your wxWidgets default library is.
ifeq "${USER}" "rburkey"
WXSTATIC=--static
SDLIBS=--static-libs
else
SDLIBS=--libs
endif

NATIVE_SDL_CFLAGS:=$(shell sdl-config --cflags)
NATIVE_SDL_LIBS:= $(shell sdl-config ${SDLIBS})

ifeq "${EXT}" ".exe"
WINFLAGS=-DNO_STDIO_REDIRECT
WINFLAGS+=SDL_win32_main.c
endif
#WIN_SDL_CFLAGS:=$(shell ${BIN_WIN}/sdl-config --cflags)
WIN_SDL_CFLAGS:=$(shell ${BIN_WIN}/sdl-config --cflags) -DNO_STDIO_REDIRECT SDL_win32_main.c
#WIN_SDL_LIBS:=$(shell ${BIN_WIN}/sdl-config --static-libs)
WIN_SDL_LIBS:=\
	-L${HOME}/IMCROSS/i386-mingw32/lib -lmingw32 -lSDL \
	-lkernel32 -luser32 -lgdi32 -lcomdlg32 \
	-lole32 -ldinput -lddraw -ldxguid -lwinmm -ldsound
#WIN_SDL_LIBS:=-L${HOME}/IMCROSS/i386-mingw32/lib -lmingw32 -lSDL
MAC_SDL_CFLAGS:=$(shell ${BIN_MAC}/sdl-config --cflags)
MAC_SDL_LIBS:=$(shell ${BIN_MAC}/sdl-config --static-libs)


.PHONY: default
default: Linux

.PHONY: all-archs
all-archs: Linux Win32 MacOsX

.PHONY: Linux
Linux: ${APPNAME}

.PHONY: Win32
Win32: ${APPNAME}.exe

.PHONY: MacOsX
MacOsX: ${APPNAME}-macosx

.PHONY: clean
clean:
	-rm -rf temp
	-rm -f *~ *.bak ${APPNAME} *.exe *-macosx* *.cfg

SOURCES:=${APPNAME}.c \
	../yaAGC/agc_utilities.c \
	../yaAGC/SocketAPI.c \
	../yaAGC/agc_engine.c \
	../yaAGC/Backtrace.c


//HEADERS:=${APPNAME}.h

${APPNAME}: ${SOURCES} ${HEADERS}
	gcc \
		${NATIVE_SDL_CFLAGS} \
		-DNVER=${NVER} \
		-o $@ ${SOURCES} ${WINFLAGS} \
		${NATIVE_SDL_LIBS} \
		${CURSES} ${LIBS2}
	strip $@${EXT}

${APPNAME}.exe: ${SOURCES} ../yaAGC/random.c ${HEADERS}
	${PREFIX_WIN}-gcc \
		${WIN_SDL_CFLAGS} \
		-DNVER=${NVER} \
		-o $@ ${SOURCES} ../yaAGC/random.c -lwsock32 \
		${WIN_SDL_LIBS}
	${PREFIX_WIN}-strip $@

${APPNAME}-macosx: ${SOURCES} ${HEADERS}
	powerpc-apple-darwin9-gcc \
		-arch i386 -arch ppc -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/powerpc-apple-darwin9 \
		${MAC_SDL_CFLAGS} \
		-DNVER=${NVER} \
		-o $@ ${SOURCES} \
		${MAC_SDL_LIBS}
	${PREFIX_MAC}-strip $@

temp:
	powerpc-apple-darwin9-lipo \
		$@-ppc \
		-remove i386 \
		-output $@-ppc-a		
	i686-apple-darwin9-gcc \
		-arch i386 -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/i686-apple-darwin9 \
		${MAC_SDL_CFLAGS} \
		-o $@-i386 ${SOURCES} \
		${MAC_SDL_LIBS}
	i686-apple-darwin9-lipo \
		$@-i386 \
		-remove ppc \
		-output $@-i386-a		
	${PREFIX_MAC}-lipo \
		$@-ppc-a \
		$@-i386-a \
		-create \
		-output $@		

