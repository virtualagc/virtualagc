# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Solarium build 055.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 6
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	
#		2009-07-25 RSB	Created, based on Artemis072 version.
#		2011-05-03 JL	Updated.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-08-24 RSB	Added --block1 switch to yaYUL command line.
#		2016-08-24 RSB	Added target for corediff.txt.
#		2016-08-24 RSB	... and other stuff related to that too.

BASENAME=Solarium055

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst 

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

MAIN.agc.bin MAIN.agc.lst: ${SOURCE}
	../yaYUL/yaYUL --block1 --unpound-page --html MAIN.agc >MAIN.agc.lst

${BASENAME}.lst: MAIN.agc.bin ${BASENAME}.bin
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: ${BASENAME}.bin MAIN.agc.bin MAIN.agc.lst
	python ../Tools/ropediff.py -p -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html
