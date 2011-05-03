# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Artemis build 072.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 15-17
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	
#		2009-07-25 RSB	Created, based on Artemis072 version.
#		2011-05-03 JL	Updated.

BASENAME=Solarium055

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

