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
#		2012-09-16 JL	Updated to match tools dir changes.

BASENAME=Colossus237

.PHONY: ${BASENAME}.lst

SOURCE:=$(wildcard *.agc)
#TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab
TARGETS=${BASENAME}.lst ${BASENAME}.symtab

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

#${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} 
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >MAIN.agc.lst
	#diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: 
#corediff.txt: ${BASENAME}.bin MAIN.agc.bin
#	python ../Tools/ropediff.py -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html

