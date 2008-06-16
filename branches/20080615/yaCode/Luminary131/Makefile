# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 1C, revision 131.
#		(The source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13 and Apollo 14.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	05/06/03 RSB.	Began.
#		11/02/03 RSB.	Added the "install" and "Luminary131.bin" targets.
#		05/06/04 RSB	Installs Luminary131.bin.
#		05/09/04 RSB	Added the MAIN_PROGRAM #define to CheckDec.
#		05/14/04 RSB	Added PREFIX.
#		07/16/04 RSB	Added webb2burkey-rope
#		08/14/04 RSB	Put the yaYUL/Luminary131 regression test back in.
#		09/05/04 RSB	yaYUL no longer needs --force.
#		04/30/05 RSB	Added CFLAGS.
#		07/28/05 RSB	Added symtab.

ifndef PREFIX
PREFIX=/usr/local
endif
SOURCE:=$(wildcard *.s)
TARGETXEQ=bdiffhead webb2burkey-rope Oct2Bin CheckDec
TARGETS:=${TARGETXEQ} Luminary131.bin Luminary131.lst Luminary131.symtab

default:	$(TARGETS)

webb2burkey-rope: webb2burkey-rope.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -o webb2burkey-rope webb2burkey-rope.c
	
bdiffhead:	bdiffhead.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -o $@ $^
	
Oct2Bin:	Oct2Bin.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -o Oct2Bin Oct2Bin.c
	
CheckDec:	CheckDec.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o CheckDec CheckDec.c -lm
	
Luminary131.bin: Oct2Bin Luminary131.binsource
	./Oct2Bin <Luminary131.binsource
	mv Oct2Bin.bin Luminary131.bin

Luminary131.lst Luminary131.symtab: ${SOURCE} Luminary131.bin
	../../yaYUL/yaYUL MAIN.s >Luminary131.lst
	mv MAIN.s.symtab Luminary131.symtab
	diff -s MAIN.s.bin Luminary131.bin
	
clean:
	-rm -f $(TARGETXEQ) *.lst *~ MAIN.s.bin Luminary131.bin *.symtab
	
install:	default
	cp ${TARGETS} Luminary131.symtab ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/webb2burkey-rope ${PREFIX}/bin/Oct2Bin \
		${PREFIX}/bin/CheckDec ${PREFIX}/bin/bdiffhead
	chmod ugo+r ${PREFIX}/bin/Luminary131.bin
	rm -f *.symtab *.lst
	
	
	
