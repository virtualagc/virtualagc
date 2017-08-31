# Copyright 2009,2016,2017 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the jWiz program.
# Mods:		2009-04-08 RSB	Adapted from yaTelemetry makefile.
#		2009-04-14 RSB	Added some stuff for building in Mac OS X.
#		.......... OH	... something ...
#		2009-04-25 RSB	Undid some stylistic cleanups that broke the 
#				all-archs target.
#		2009-05-02 RSB	Added DEV_STATIC.
#		2016-07-17 RSB	Added -lX11 to the jWiz target.
#		2016-08-06 RSB  This had been set to build jWiz statically-linked
#				for USERNAME=rburkey (me!) and dynamically-linked
#				for everyone else.  That's because I would often
#				build it for the purpose of making an installer,
#				and it was easier if the executables were statically
#				linked to the extent possible.  But it turns out 
#				that the standard library function gethostbyname()
#				used by agc_utilities.c no longer works (at least on
#		                some Linux distributions) if statically 
#		                linked.  Therefore, I need to make this change
#				to fix the symptoms I was seeing (namely, that 
#				yaAGC no longer listened on the specified port
#				on 64-bit Linux Mint and Ubuntu).  Neither the
#				problem nor the fix presumably affects anybody 
#				else's builds. 
#				Also:  Eliminated some compiler warnings solely
#				related internally to wxWidgets 2.8.12.
#		2017-08-24 RSB	Added wxFLAGS.

APP=jWiz

# For cross-platform building --- i.e., for building Win32 and Mac OS X versions
# of VirtualAGC on a Linux platform --- it is assumed that the IMCROSS
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

ifdef MACOSX
# For native building in Mac OS X.
MACFLAG=-DISMACOSX
endif

# This is just so that when I build it, I can insure that it will be statically or
# dynamically linked in the binary installers, according to my current whims.
# For anybody else, it will just accept whatever your wxWidgets default library is.
ifeq "${USER}" "rburkey"
ifdef DEV_STATIC
WXSTATIC=--static
else
EXTRA_WIN_LIBS=-lwsock32
endif
endif

ifndef WIN32
LIBS2+=-lX11
endif

.PHONY:	default
default: ${APP}

.PHONY: all-archs
all-archs: default ${APP}.exe ${APP}-macosx

.PHONY:	clean
clean:
	-rm -f ${APP} *.exe *-macosx* *.o *~ *.bak

SOURCES:=${APP}.cpp
SOURCESc:=\
	../yaAGC/agc_utilities.c \
	../yaAGC/DecodeDigitalDownlink.c \
	../yaAGC/agc_engine.c \
	../yaAGC/Backtrace.c \
	../yaAGC/random.c \
	../yaAGC/SocketAPI.c

HEADERS:=${APP}.h

${APP}: ${SOURCES} ${SOURCESc} ${HEADERS}
	${CC} -DNVER=${NVER} ${MACFLAG} \
		`wx-config --cxxflags` ${wxFLAGS} \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`wx-config --libs` \
		${LIBS2}
	strip $@${EXT}

${APP}.exe: ${SOURCES} ${SOURCESc} ${HEADERS}
	${PREFIX_WIN}-${CC} \
		`${BIN_WIN}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_WIN}/wx-config ${WXSTATIC} --libs` \
		${EXTRA_WIN_LIBS}		
	${PREFIX_WIN}-strip $@

${APP}-macosx: ${SOURCES} ${SOURCESc} ${HEADERS}
	powerpc-apple-darwin9-${CC} \
		-arch ppc -arch i386 -I${INC_MAC} -isysroot ${SDK_MAC} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@ ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --libs`
	${PREFIX_MAC}-strip $@

# Normally, the compiler can create a universal binary without having to
# do separate compilations for the different architectures and combining
# them afterward, the way I do below, but for some reason there are 
# separate C++ header files associated with iostreams for each architecture,
# and the compiler can't find them unless I specify the architecture-dependent
# directories in which they're located.  I am completely confused by the 
# maneuvers I had to go through here, and I don't remember gaving these 
# problems before.
ignore-${APP}-macosx: ${SOURCES} ${SOURCESc} ${HEADERS}
	powerpc-apple-darwin9-${CC} \
		-arch ppc -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/powerpc-apple-darwin9 \
		`${BIN_MAC}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@-ppc ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --libs`
	powerpc-apple-darwin9-lipo \
		$@-ppc \
		-remove i386 \
		-output $@-ppc-a		
	i686-apple-darwin9-${CC} \
		-arch i386 -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/i686-apple-darwin9 \
		`${BIN_MAC}/wx-config ${WXSTATIC} --cxxflags` \
		-o $@-i386 ${SOURCES} ${DASHX} ${SOURCESc} \
		`${BIN_MAC}/wx-config ${WXSTATIC} --libs`
	i686-apple-darwin9-lipo \
		$@-i386 \
		-remove ppc \
		-output $@-i386-a		
	${PREFIX_MAC}-lipo \
		$@-ppc-a \
		$@-i386-a \
		-create \
		-output $@		
	${PREFIX_MAC}-strip $@


	

