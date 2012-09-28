# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 1A (build 099).
#		(The source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), Apollo 11.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2009-06-05 RSB	Adapted from similar Comanche 055
#				Makefile.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Fixed so that errors will cause rebuild next
#				time make is run. Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.

BASENAME=Luminary099

.PHONY: ${BASENAME}.lst

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default:	$(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

MAIN.agc.bin MAIN.agc.lst: ${SOURCE}
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >MAIN.agc.lst

${BASENAME}.lst ${BASENAME}.symtab: MAIN.agc.bin ${BASENAME}.bin
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: ${BASENAME}.bin MAIN.agc.bin
	python ../Tools/ropediff.py -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html

