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
#               2012-09-16 JL   Updated to match tools dir changes.

BASENAME=Comanche055

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

corediff.txt: ${BASENAME}.bin MAIN.agc.bin ${BASENAME}.lst
	python ../Tools/ropediff.py -p -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html
