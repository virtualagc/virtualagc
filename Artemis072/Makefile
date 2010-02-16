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

BASENAME=Artemis072

SOURCE:=$(wildcard *.agc)
TARGETS=${BASENAME}.bin ${BASENAME}.lst ${BASENAME}.symtab

default:	$(TARGETS)

${BASENAME}.bin: ${BASENAME}.binsource
	-../Luminary131/Oct2Bin <${BASENAME}.binsource
	mv Oct2Bin.bin $@

${BASENAME}.lst ${BASENAME}.symtab: ${SOURCE} ${BASENAME}.bin
	../yaYUL/yaYUL --html MAIN.agc >${BASENAME}.lst
	mv MAIN.agc.symtab ${BASENAME}.symtab
	diff -s MAIN.agc.bin ${BASENAME}.bin
		
clean:
	-rm -f *.lst *~ MAIN.agc.bin ${BASENAME}.bin *.symtab Oct2Bin.bin* *.html


#--------------------------------------------------------------------
ifdef OBSOLETE

PROJECT:=Artemis072

ifndef PREFIX
PREFIX=/usr/local
endif

SOURCE:=$(wildcard *.agc)
TARGETS=${PROJECT}.bin ${PROJECT}.lst

default: $(TARGETS)

clean:
	-rm -f *.lst *~ *.bin *.symtab *.html
	
install: default
	cp ${PROJECT}.bin ${PREFIX}/bin
	chmod ugo+r ${PREFIX}/bin/${PROJECT}.bin
	
# Implicit rules.

%.bin: %.binsource
	../Luminary131/Oct2Bin <$^
	mv Oct2Bin.bin $@

%.lst: %.bin ${SOURCE}
	@echo ====================================================
	../yaYUL/yaYUL --html MAIN.agc >$@
	diff -s MAIN.agc.bin $<
		
endif 

