# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus 1A, Build 249.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), maybe for Apollo 8 and/or 9.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	11/13/03 RSB.	Adapted from Luminary131 makefile.
#		11/25/03 RSB.	Removed the '-' prefices in the
#				Colossus249.bin target.
#		01/01/04 RSB	Fixed the path for Oct2Bin
#		05/06/04 RSB	Installs Colossus249.bin.
#		05/14/04 RSB	Added PREFIX
#		09/05/04 RSB	Now runs yaYUL by default.
#		07/28/05 RSB	Now account for symtabs.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Replaced with newer version from Artemis072.
#				Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.

BASENAME=Colossus249

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
