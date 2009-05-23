# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus 2A (Comanche 055).
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), Apollo 11.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2009-05-20 RSB	Adapted from similar Colossus 249
#				Makefile.

BASENAME=Comanche055

SOURCE:=$(wildcard *.s)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default:	$(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	-../Luminary131/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL MAIN.s >${BASENAME}.lst
	#cp MAIN.s.bin Oct2Bin.bin
	#../Luminary131/Oct2Bin --invert --page=1598
	mv MAIN.s.symtab ${BASENAME}.symtab
	diff -s MAIN.s.bin ${BASENAME}.bin
		
clean:
	-rm -f *.lst *~ MAIN.s.bin ${BASENAME}.bin *.symtab

