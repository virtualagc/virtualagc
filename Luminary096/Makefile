# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 96.
#		The original release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 11. It has been
#		reconstructed from a listing of Luminary 099 (revision 1)
#		and Luminary memos 83 and 85.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2019-08-04 MAS	Created.

BASENAME=Luminary096

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLuminary096sums

include ../Makefile.inc

.PHONY: diffLuminary096sums
diffLuminary096sums:
	../Tools/check_buggers.py Luminary096.bin Luminary096.buggers
