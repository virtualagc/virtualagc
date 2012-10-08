# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 1C, revision 131.
#		(The source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13 and Apollo 14.)
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	05/06/03 RSB.	Began.
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
#		2011-05-03 JL	Moved oct2bin, checkdec, bdiffhead, webb2burkey-rope to Tools directory. 
#				Changed to simpler Makefile based on Artemis072.
#		2012-09-16 JL	Updated to match tools dir changes.

BASENAME=Luminary131

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst 

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

MAIN.agc.bin MAIN.agc.lst: ${SOURCE}
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >MAIN.agc.lst

${BASENAME}.lst: MAIN.agc.bin ${BASENAME}.bin
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: ${BASENAME}.bin MAIN.agc.bin
	python ../Tools/ropediff.py -p -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html

