# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for AGC instruction validation suite.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	07/03/04 RSB.	Create.
#		07/16/04 RSB.	Added Validation.txt (the validation-suite
#				binary as formatted for Julian Webb's AGC sim).
#		08/30/04 RSB	Added '-' prefix and --force switch to the 
#				validation-suite build, to work around yaYUL
#				bugs on some platforms.
#		09/05/04 RSB	... and removed them again.  The should work
#				and so shouldn't need them.
#		08/06/05 RSB	In the Validation.bin target, the dependency on
#				../yaYUL/yaYUL was removed, since it's pointless
#				and since it messes up CygWin.

ifndef PREFIX
PREFIX=/usr/local
endif
SSOURCE:=$(wildcard *.s)

default:	Validation.bin Validation.txt

Validation.txt: Validation.bin
	../Luminary131/webb2burkey-rope Validation.bin Validation.txt

Validation.bin:	${SSOURCE}
	../yaYUL/yaYUL Validation.s >Validation.lst
	mv Validation.s.bin Validation.bin

clean:
	-rm -f Validation.bin Validation.lst Validation.s.bin Validation.txt *~ *.symtab
	
install:	default
	cp Validation.bin ${PREFIX}/bin
	chmod ugo+r ${PREFIX}/bin/Validation.bin
	
