# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 044.
#		The original release of the software for the Command Module's
#		(CM) Apollo Guidance Computer (AGC) for Apollo 10. It has been
#		reconstructed from a listing of Comanche 055 and NASA drawing
#		2021153D.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2020-12-03 MAS	Created.

BASENAME=Comanche044

NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche044sums

include ../Makefile.inc

.PHONY: diffComanche044sums
diffComanche044sums:
	../Tools/check_buggers.py Comanche044.bin Comanche044.buggers
