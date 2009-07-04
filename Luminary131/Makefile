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
#		03/06/09 RSB	Added 'all-archs' and associated stuff.
#		2009-07-04 RSB	Added --html switch.

ifndef PREFIX
PREFIX=/usr/local
endif
SOURCE:=$(wildcard *.s)
TARGETXEQ:=bdiffhead webb2burkey-rope Oct2Bin CheckDec
TARGETEXE:=$(patsubst %,%.exe,${TARGETXEQ})
TARGETMAC:=$(patsubst %,%-macosx,${TARGETXEQ})
TARGETS:=${TARGETXEQ} Luminary131.bin Luminary131.lst Luminary131.symtab

default:	$(TARGETS)

all-archs:	default ${TARGETEXE} ${TARGETMAC}

${TARGETXEQ} : % : %.c
	gcc ${CFLAGS} -DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin \
		-DMAIN_PROGRAM -o $@ $^ -lm

${TARGETEXE} : %.exe : %.c
	i386-mingw32-gcc ${CFLAGS} -DNVER=${NVER} \
		-DINSTALLDIR=${PREFIX}/bin -DMAIN_PROGRAM -o $@ $^ -lm

${TARGETMAC} : %-macosx : %.c
	powerpc-apple-darwin9-gcc -arch i386 -arch ppc ${CFLAGS} \
		-DNVER=${NVER} -DINSTALLDIR=${PREFIX}/bin \
		-DMAIN_PROGRAM -o $@ $^ -lm

Luminary131.bin: Oct2Bin Luminary131.binsource
	./Oct2Bin <Luminary131.binsource
	mv Oct2Bin.bin Luminary131.bin

Luminary131.lst Luminary131.symtab: ${SOURCE} Luminary131.bin
	../yaYUL/yaYUL --html MAIN.s >Luminary131.lst
	mv MAIN.s.symtab Luminary131.symtab
	diff -s MAIN.s.bin Luminary131.bin

.PHONY: JustAssemble
JustAssemble:
	../yaYUL/yaYUL --html MAIN.s >Luminary131.lst
	mv MAIN.s.symtab Luminary131.symtab

clean:
	-rm $(TARGETXEQ) *.exe *-macosx *.lst *~ MAIN.s.bin Luminary131.bin *.symtab *.html

install:	default
	cp ${TARGETS} Luminary131.symtab ${PREFIX}/bin
	chmod ugo+x ${PREFIX}/bin/webb2burkey-rope ${PREFIX}/bin/Oct2Bin \
		${PREFIX}/bin/CheckDec ${PREFIX}/bin/bdiffhead
	chmod ugo+r ${PREFIX}/bin/Luminary131.bin
	rm *.symtab *.lst



