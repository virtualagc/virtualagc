# I, the author, Ron Burkey, declare this Makefile to be in the
# Public Domain under U.S. law.
#
# Filename:	Makefile
# Purpose:	Makefile for the yaLVDC emulator.
# Mods:		2011-12-23 RSB	Adapted from yaASM Makefile.
#		2020-04-30 RSB	Removed the compiler -m32 switch, which
#				doesn't work for my current gcc setup.
#				I don't even recall why it had been there.
#				Also made the Makefile public domain. 
#		2025-07-19 RSB	Added HAS_ERRNO_H
#
# The default is to build using the native gcc. To cross build from 
# Linux to get Win32 and Mac OS X executables as well (make all-archs), 
# you need to have IMCROSS (http://www/sandroid.org/imcross) installed.

TARGET=yaLVDC

ifndef cc
cc=gcc
endif

OURFLAGS=${CFLAGS}
ifdef WIN32
OURFLAGS+=-DHAVE_TIME_H
LIBS=-lwsock32 -lws2_32 -lwinmm
endif

ifeq "${USER}" "rburkey"
#OURFLAGS+=-Wall -Werror -O3
OURFLAGS+=-Wall -Werror -O0 -g
endif

ifdef HAS_ERRNO_H
OURFLAGS+=-DHAS_ERRNO_H
endif

SOURCE:=$(wildcard *.c)

.PHONY:	default
default: ${TARGET}

.PHONY: all-archs
all-archs: ${TARGET}

${TARGET}: ${SOURCE} yaLVDC.h Makefile
	${cc} ${OURFLAGS} -o $@ *.c -lm ${LIBS}

.PHONY:	clean
clean:
	-rm ${TARGET}


