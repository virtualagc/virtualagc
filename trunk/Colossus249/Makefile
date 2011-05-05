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

BASENAME=Colossus249

.PHONY: ${BASENAME}.lst ${BASENAME}.symtab

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
