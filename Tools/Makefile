# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for tools.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2011-05-03 JL	Created.
#               2012-09-16 JL   Added binsource2bin.
#               2012-09-17 JL   Renamed binsource2bin to listing2binsource.
#		2016-12-12 RSB	Added boxAGC
#		2017-08-22 RSB	Commented out boxAGC, since it's just
#				something I was experimenting with anyway,
#				isn't needed, and apparently caused problems
#				on some platforms.

ifndef PREFIX
PREFIX=/usr/local
endif

TARGETS=listing2binsource oct2bin bdiffhead checkdec webb2burkey-rope split-interp

default: ${TARGETS}
	# $(MAKE) -C boxAGC

listing2binsource: listing2binsource.c utils.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

oct2bin: oct2bin.c utils.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

checkdec: checkdec.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

bdiffhead: bdiffhead.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

webb2burkey-rope: webb2burkey-rope.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

split-interp: split-interp.c
	${cc} ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

clean:
	-rm -f ${TARGETS} *.o *.exe *-macosx 
	$(MAKE) -C boxAGC clean

