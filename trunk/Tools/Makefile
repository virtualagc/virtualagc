# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for tools.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2011-05-03 JL	Created.
#               2012-09-16 JL   Added binsource2bin.
#               2012-09-17 JL   Renamed binsource2bin to listing2binsource.

ifndef PREFIX
PREFIX=/usr/local
endif

TARGETS=listing2binsource oct2bin bdiffhead checkdec webb2burkey-rope split-interp

default: ${TARGETS}

listing2binsource: listing2binsource.c utils.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

oct2bin: oct2bin.c utils.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

checkdec: checkdec.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

bdiffhead: bdiffhead.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

webb2burkey-rope: webb2burkey-rope.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

split-interp: split-interp.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

clean:
	-rm -f ${TARGETS} *.o *.exe *-macosx 

