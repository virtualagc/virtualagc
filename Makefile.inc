# Copyright:	Public domain.
# Filename: 	Makefile.inc
# Purpose:  	Makefile include for all flights.
# Contact:  	Ron Burkey <info@sandroid.org>.
# Website:  	http://www.ibiblio.org/apollo
# Mod history:	2016-10-04 JL   Created.
#               2016-10-04 JL   Added format target.

# Note: $(BASENAME) must be set by calling Makefile to the flight name.

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst 

default: $(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	../Tools/oct2bin <${BASENAME}.binsource
	mv oct2bin.bin $@

MAIN.agc.bin MAIN.agc.lst: ${SOURCE}
	../yaYUL/yaYUL $(EXTRA_YUL_ARGS) --unpound-page --html MAIN.agc >MAIN.agc.lst

${BASENAME}.lst: MAIN.agc.bin ${BASENAME}.bin
	diff -s MAIN.agc.bin ${BASENAME}.bin
	mv MAIN.agc.lst ${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab

corediff.txt: ${BASENAME}.bin MAIN.agc.bin MAIN.agc.lst
	python ../Tools/ropediff.py -p -c -a -o $@ ${BASENAME}.bin MAIN.agc.bin

clean:
	rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab oct2bin.bin* *.html

%.agc.out: %.agc 
	../yaYUL/yaYUL --format $< >$@
ifeq "$(REFORMAT)" "yes"
	mv -f $@ $<
endif

format: $(SOURCE:.agc=.agc.out)

