# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 97.
#		The original release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 11. It has been
#		reconstructed from a listing of Luminary 099 (revision 1)
#		and Luminary memos 83 and 85.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-07-28 MAS	Created.

BASENAME=Luminary097

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLuminary097sums

include ../Makefile.inc

.PHONY: diffLuminary097sums
diffLuminary097sums:
	../Tools/check_buggers.py Luminary097.bin Luminary097.buggers
