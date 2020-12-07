# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 045.
#		The second release of the software for the Command Module's
#		(CM) Apollo Guidance Computer (AGC) for Apollo 10. It has been
#		reconstructed from a listing of Comanche 055 and NASA drawing
#		2021153D.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2020-12-03 MA6	Created.

BASENAME=Comanche045

NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche045sums

include ../Makefile.inc

.PHONY: diffComanche045sums
diffComanche045sums:
	../Tools/check_buggers.py Comanche045.bin Comanche045.buggers
