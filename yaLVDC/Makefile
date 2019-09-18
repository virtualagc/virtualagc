# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the yaLVDC emulator.
# Mods:		2011-12-23 RSB	Adapted from yaASM Makefile.
#
# The default is to build using the native gcc. To cross build from 
# Linux to get Win32 and Mac OS X executables as well (make all-archs), 
# you need to have IMCROSS (http://www/sandroid.org/imcross) installed.

TARGET=yaLVDC

ifndef cc
cc=gcc
endif

ifeq "${USER}" "rburkey"
#CFLAGS+=-Wall -Werror -O3
CFLAGS+=-Wall -Werror -O0 -g
endif

SOURCE:=$(wildcard *.c)

.PHONY:	default
default: ${TARGET}

.PHONY: all-archs
all-archs: ${TARGET}

${TARGET}: ${SOURCE} yaLVDC.h Makefile
	${cc} ${CFLAGS} -m32 -o $@ *.c

.PHONY:	clean
clean:
	-rm ${TARGET}


