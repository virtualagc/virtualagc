# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus Build 237.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2010-12-12 RSB	Adapted from the corresponding
#				Colossus 249 file.
#		2011-05-03 JL	Replaced with newer version from Artemis072.
#				Point to moved Oct2Bin.

BASENAME=Colossus237

.PHONY: ${BASENAME}.lst

SOURCE:=$(wildcard *.agc)
#TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab
TARGETS=${BASENAME}.lst ${BASENAME}.symtab

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

#${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} 
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >MAIN.agc.lst
	#diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab Oct2Bin.bin* *.html

