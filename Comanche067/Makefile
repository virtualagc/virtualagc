# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 067.
#		The original release of the software for the Command Module's
#		(CM) Apollo Guidance Computer (AGC) for Apollo 12. I'm thinking
#		of trying to reconstruct it from a listing of Comanche 055 and 
#		NASA drawing 2021153D.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2020-12-25 RSB	Adapted from Mike's Comanche 044 Makefile.

BASENAME=Comanche067

NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche067sums

include ../Makefile.inc

.PHONY: diffComanche067sums
diffComanche067sums:
	../Tools/check_buggers.py Comanche067.bin Comanche067.buggers
