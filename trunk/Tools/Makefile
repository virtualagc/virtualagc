# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Oct2Bin.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2011-05-03 JL	Created.

ifndef PREFIX
PREFIX=/usr/local
endif

TARGETS=Oct2Bin bdiffhead CheckDec webb2burkey-rope

default: ${TARGETS}

Oct2Bin: Oct2Bin.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

CheckDec: CheckDec.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

bdiffhead: bdiffhead.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

webb2burkey-rope: webb2burkey-rope.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

clean:
	-rm -f ${TARGETS} *.o *.exe *-macosx 

