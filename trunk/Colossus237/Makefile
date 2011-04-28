# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus Build 237.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2010-12-12 RSB	Adapted from the corresponding
#				Colossus 249 file.

ifndef PREFIX
PREFIX=/usr/local
endif
SOURCE:=$(wildcard *.agc)
#TARGETS=Binsource2Bin Colossus237.bin Colossus237.lst Colossus237.symtab
TARGETS=Binsource2Bin Colossus237.lst Colossus237.symtab

default: $(TARGETS)

Colossus237.bin: Colossus237.binsource
	../Luminary131/Oct2Bin <Colossus237.binsource
	mv Oct2Bin.bin Colossus237.bin

#Colossus237.lst Colossus237.symtab: ${SOURCE} Colossus237.bin
Colossus237.lst Colossus237.symtab: ${SOURCE} 
	../yaYUL/yaYUL --unpound-page --html MAIN.agc >Colossus237.lst
	mv MAIN.agc.symtab Colossus237.symtab
	#diff -s MAIN.agc.bin Colossus237.bin
		
clean:
	-rm -f *.lst *~ MAIN.agc.bin Colossus237.bin *.symtab *.html
	
install:	default
	cp Colossus237.bin ${PREFIX}/bin
	chmod ugo+r ${PREFIX}/bin/Colossus237.bin
	cp *.symtab ${PREFIX}/bin
	rm -f *.symtab *.lst
	

