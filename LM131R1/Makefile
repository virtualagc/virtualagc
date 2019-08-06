# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for LM131 revision 1.
#		The final release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 13. It has been
#		reconstructed from a listing of Luminary 131 and NASA drawing
#		2021152L.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2018-09-05 MAS	Created.

BASENAME=LM131R1

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLM131R1sums

include ../Makefile.inc

.PHONY: diffLM131R1sums
diffLM131R1sums:
	../Tools/check_buggers.py LM131R1.bin LM131R1.buggers
