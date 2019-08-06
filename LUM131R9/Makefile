# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for LUM131 revision 9.
#		The third release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 13. It has been
#		reconstructed from a listing of Luminary 131 and NASA drawing
#		2021152L.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2018-09-04 MAS	Created.

BASENAME=LUM131R9

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLUM131R9sums

include ../Makefile.inc

.PHONY: diffLUM131R9sums
diffLUM131R9sums:
	../Tools/check_buggers.py LUM131R9.bin LUM131R9.buggers
