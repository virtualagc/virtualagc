# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus 1A, Build 249.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), maybe for Apollo 8 and/or 9.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	11/13/03 RSB.	Adapted from Luminary131 makefile.
#		11/25/03 RSB.	Removed the '-' prefices in the
#				Colossus249.bin target.
#		01/01/04 RSB	Fixed the path for Oct2Bin
#		05/06/04 RSB	Installs Colossus249.bin.
#		05/14/04 RSB	Added PREFIX
#		09/05/04 RSB	Now runs yaYUL by default.
#		07/28/05 RSB	Now account for symtabs.

ifndef PREFIX
PREFIX=/usr/local
endif
SOURCE:=$(wildcard *.s)
TARGETS=Colossus249.bin Colossus249.lst Colossus249.symtab

default:	$(TARGETS)

Colossus249.bin: Colossus249.binsource
	../Luminary131/Oct2Bin <Colossus249.binsource
	mv Oct2Bin.bin Colossus249.bin

Colossus249.lst Colossus249.symtab: ${SOURCE} Colossus249.bin
	../../yaYUL/yaYUL MAIN.s >Colossus249.lst
	mv MAIN.s.symtab Colossus249.symtab
	diff -s MAIN.s.bin Colossus249.bin
		
clean:
	-rm *.lst *~ MAIN.s.bin Colossus249.bin *.symtab
	
install:	default
	cp Colossus249.bin ${PREFIX}/bin
	chmod ugo+r ${PREFIX}/bin/Colossus249.bin
	cp *.symtab ${PREFIX}/bin
	rm *.symtab *.lst
	

