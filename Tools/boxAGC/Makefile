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
	gcc -o $@ $^ -lm

clean:
	${cc} -f boxAGC *.o *.exe *-macosx 

