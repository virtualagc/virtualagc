# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Artemis build 072.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 6
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	
#		2009-07-25 RSB	Created, based on Artemis072 version.
#		2011-05-03 JL	Updated.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-08-24 RSB	Added --block1 switch to yaYUL command line.

BASENAME=Solarium055

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL --block1 --unpound-page --html MAIN.agc >MAIN.agc.lst
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab
		
clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html

