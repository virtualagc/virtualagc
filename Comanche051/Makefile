# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 051.
#		The original release of the software for the Command Module's
#		(CM) Apollo Guidance Computer (AGC) for Apollo 11. It has been
#		reconstructed from a listing of Comanche 055 and NASA drawing
#		2021153D.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-07-30 MAS	Created.

BASENAME=Comanche051

NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche051sums

include ../Makefile.inc

.PHONY: diffComanche051sums
diffComanche051sums:
	../Tools/check_buggers.py Comanche051.bin Comanche051.buggers
