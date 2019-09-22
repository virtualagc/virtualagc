# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 173.
#		The second (unflown) release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 14. It has been
#		reconstructed from a reconstructed copy of Luminary 178, as well
#		as well as Luminary memo 167 (revision 1) and NASA drawing 2021152N.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-09-18 MAS	Created.

BASENAME=Luminary173

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLuminary173sums

include ../Makefile.inc

.PHONY: diffLuminary173sums
diffLuminary173sums:
	../Tools/check_buggers.py Luminary173.bin Luminary173.buggers
