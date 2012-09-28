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

#VERBOSE=-v

.PHONY: ${BASENAME}.lst corediff.txt

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default: $(TARGETS)

${BASENAME}.binsource: ${BASENAME}.binsource2.txt
	../Tools/listing2binsource ${VERBOSE} $^ $@

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin ${VERBOSE} <${BASENAME}.binsource
	mv oct2bin.bin $@

MAIN.agc.bin MAIN.agc.lst: ${SOURCE}
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >MAIN.agc.lst

${BASENAME}.lst ${BASENAME}.symtab: MAIN.agc.bin ${BASENAME}.bin
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: ${BASENAME}.bin MAIN.agc.bin MAIN.agc.lst
	python ../Tools/ropediff.py -p -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html ${BASENAME}.binsource

