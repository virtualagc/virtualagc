# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for boxAGC.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2016-12-12 RSB	Created.

ifndef cc
cc=gcc
endif

default: boxAGC

boxAGC: boxAGC.c imageUtilities.c imageUtilities.h
	${cc} -o $@ $^ -lm

clean:
	-rm boxAGC *.o *.exe *-macosx 

