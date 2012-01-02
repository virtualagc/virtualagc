# Copyright 2011,2012 Ronald S. Burkey <info@sandroid.org>
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
# Purpose:	Makefile for the yaPanel emulation of Gemini peripherals
#		MDR, MDK, IVI, PCDP, TRS.
# Mods:		2011-12-30 RSB	Began.
#		2012-01-02 RSB	Prepared for first save to svn.
#
# The default is to build using the native gcc. To cross build from 
# Linux to get Win32 and Mac OS X executables as well (make all-archs), 
# you need to have IMCROSS (http://www/sandroid.org/imcross) installed.

ifeq "${USER}" "rburkey"
TARGET=yaPanel
CFLAGS=-Wall -Werror
WEB=${HOME}/Projects/sandroid.org/public_html/apollo/Downloads
else
endif

.PHONY:	default
default: ${TARGET}

${TARGET}: ${TARGET}.cpp Makefile
	g++ ${CFLAGS} `wx-config --cxxflags` -o $@ $< `wx-config --libs`

.PHONY: clean
clean:
	-rm ${TARGET} ${TARGET}.exe ${TARGET}-macosx

