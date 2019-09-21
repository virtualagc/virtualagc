# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 163.
#		The first (unflown) release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 14. It has been
#		reconstructed from a reconstructed copy of Luminary 173, as well
#		as well as Luminary memos 157 and 158, and NASA drawing 2021152N.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-09-21 MAS	Created.

BASENAME=Luminary163

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLuminary163sums

include ../Makefile.inc

.PHONY: diffLuminary163sums
diffLuminary163sums:
	../Tools/check_buggers.py Luminary163.bin Luminary163.buggers
