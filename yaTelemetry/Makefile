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
# Purpose:	Makefile for the yaTelemetry program.
# Mods:		2009-03-10 RSB	Created.
#		2009-03-11 RSB	Working, on Linux and Windows XP.  Don't
#				know yet about Mac OS X.

APP=yaTelemetry

# For cross-platform building --- i.e., for building Win32 and Mac OS X versions
# of VirtualAGC on a Linux platform --- it is assumed that the IMCROSS
# environment (www.sandroid.org/imcross) is installed.  It is further supposed
# that the IMCROSS installation directory is ~/IMCROSS and that ~/IMCROSS/bin 
# is in the PATH.  The following variables just reflect the default setup for
# IMCROSS.


# IMCROSS compilation is default but also allow native builds
# To build native on a platform set the NATIVE environment variable
# to either WIN32,MACOSX or LINUX

ifdef NATIVE

PREFIX_WIN=
BIN_WIN=

else

PREFIX_WIN=i386-mingw32-
PREFIX_MAC=powerpc-apple-darwin9-
BIN_WIN=${HOME}/IMCROSS/i386-mingw32/bin/
BIN_MAC=${HOME}/IMCROSS/mac/bin/
INC_MAC=${HOME}/IMCROSS/mac/include
SDK_MAC=${HOME}/IMCROSS/mac/SDKs/MacOSX10.4u.sdk

endif

.PHONY:	default
default: ${APP}

.PHONY: all-archs
all-archs: default ${APP}.exe ${APP}-macosx

.PHONY:	clean
clean:
	-rm -f ${APP} *.exe *-macosx* *.o *~ *.bak

SOURCES:=${APP}.cpp \
	../yaAGC/agc_utilities.c \
	../yaAGC/DecodeDigitalDownlink.c \
	../yaAGC/agc_engine.c \
	../yaAGC/Backtrace.c \
	../yaAGC/random.c \
	../yaAGC/SocketAPI.c

HEADERS:=${APP}.h

${APP}: ${SOURCES} ${HEADERS}
	g++ -DNVER=${NVER} -Wall \
		`wx-config --cxxflags` \
		-o $@ ${SOURCES} \
		`wx-config --libs`

${APP}.exe: ${SOURCES} ${HEADERS}
	${PREFIX_WIN}g++ \
		`${BIN_WIN}wx-config --static --cxxflags` \
		-o $@ ${SOURCES} \
		`${BIN_WIN}wx-config --static --libs`		
	${PREFIX_WIN}strip $@

# Normally, the compiler can create a universal binary without having to
# do separate compilations for the different architectures and combining
# them afterward, the way I do below, but for some reason there are 
# separate C++ header files associated with iostreams for each architecture,
# and the compiler can't find them unless I specify the architecture-dependent
# directories in which they're located.  I am completely confused by the 
# maneuvers I had to go through here, and I don't remember gaving these 
# problems before.
${APP}-macosx: ${SOURCES} ${HEADERS}
	powerpc-apple-darwin9-g++ \
		-arch ppc -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/powerpc-apple-darwin9 \
		`${BIN_MAC}wx-config --static --cxxflags` \
		-o $@-ppc ${SOURCES} \
		`${BIN_MAC}wx-config --static --libs`
	powerpc-apple-darwin9-lipo \
		$@-ppc \
		-remove i386 \
		-output $@-ppc-a		
	i686-apple-darwin9-g++ \
		-arch i386 -I${INC_MAC} -isysroot ${SDK_MAC} \
		-I${SDK_MAC}/usr/include/c++/4.0.0 \
		-I${SDK_MAC}/usr/include/c++/4.0.0/i686-apple-darwin9 \
		`${BIN_MAC}wx-config --static --cxxflags` \
		-o $@-i386 ${SOURCES} \
		`${BIN_MAC}wx-config --static --libs`
	i686-apple-darwin9-lipo \
		$@-i386 \
		-remove ppc \
		-output $@-i386-a		
	${PREFIX_MAC}lipo \
		$@-ppc-a \
		$@-i386-a \
		-create \
		-output $@		
	${PREFIX_MAC}strip $@


	

