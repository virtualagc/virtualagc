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

BASENAME=Luminary099

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default:	$(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	-../Luminary131/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL --html MAIN.agc >${BASENAME}.lst
	cp MAIN.agc.bin Oct2Bin.bin
	../Luminary131/Oct2Bin --invert --page=1590
	mv MAIN.agc.symtab ${BASENAME}.symtab
	diff -s MAIN.agc.bin ${BASENAME}.bin
		
clean:
	-rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab Oct2Bin.bin* *.html

