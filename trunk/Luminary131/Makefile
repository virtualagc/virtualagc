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
#		2011-05-03 JL	Moved Oct2Bin, CheckDec, bdiffhead, webb2burkey-rope to Tools directory. 
#				Changed to simpler Makefile based on Artemis072.

BASENAME=Luminary131

.PHONY: ${BASENAME}.lst

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL --html MAIN.agc >MAIN.agc.lst
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab
		
clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab Oct2Bin.bin* *.html

