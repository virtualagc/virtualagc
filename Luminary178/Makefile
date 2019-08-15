# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 178.
#		The final release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 14. It has been
#		reconstructed from listings of Zerlina 56, Luminary 210, and
#		Luminary 131, as well as many Luminary memos.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-08-14 MAS	Created.

BASENAME=Luminary178

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLuminary178sums

include ../Makefile.inc

.PHONY: diffLuminary178sums
diffLuminary178sums:
	../Tools/check_buggers.py Luminary178.bin Luminary178.buggers
