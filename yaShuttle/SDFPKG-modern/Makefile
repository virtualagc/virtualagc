# License:	This file is declared to be in the Public Domain in the U.S., 
#		and may be freely used, modified, or distributed in any manner 
#		whatsoever.
# Filename:	Makefile
# Purpose:	Makefile for the "modern" port to C of the SDFPKG.ASM (IBM BAL)
#		suite of source-code files.
# History:	2026-06-24 RSB	Began.
#
# This Makefile is initially designed for GNU make, gcc, and Linux, but will 
# probably work on Mac OS and/or with clang.  Changes will probably be needed 
# eventually to support Windows.

ifndef CC
CC = gcc
endif

SOURCES=LOCATE.c NDX2PTR.c PAGMOD.c SDFCHECK.c SDFPKG.c SELECT.c
OBJECTS=$(subst .c,.o,$(SOURCES))

TEST1: $(OBJECTS)
	${CC} ${CFLAGS} -o $@ TEST1.c $(OBJECTS)

.PHONY:	clean
clean:
	-rm *.o TEST1

%.o: %.c SDFPKG.h Makefile
	${CC} ${CFLAGS} -c -o $@ $<


