# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus 2A (Comanche 055).
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), Apollo 11.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2009-05-20 RSB	Adapted from similar Colossus 249
#				Makefile.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Replaced with newer version from Artemis072.
#				Point to moved Oct2Bin.

BASENAME=Comanche055

.PHONY: ${BASENAME}.lst ${BASENAME}.symtab

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default:	$(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL --html MAIN.agc >MAIN.agc.lst
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

clean:
	-rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab Oct2Bin.bin* *.html

