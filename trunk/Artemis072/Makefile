# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Artemis build 072.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 15-17
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2005-07-06 RSB 	Began.
#		2006-01-09 RSB  Removed the comment to ignore 
#				errors.  (Artemis072.binsource is 
#				now complete and proofed, so the
#				warning isn't needed.)
#		2009-07-04 RSB	Added --html switch.
#		2010-01-16 RSB	Replaced body of this file by a
#				slight variation of the Makefile
#				for Comanche 055.  The original
#				file was apparently created before
#				the much-better Comanche 055 file
#				was available.
#		2010-01-20 RSB	Removed the '-' in front of various
#				commands.
#		2011-05-03 JL	Fixed so an error will always cause 
#				a rebuild the next time make is run.
#				Remove obsolete stuff. Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.

BASENAME=Artemis072

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
