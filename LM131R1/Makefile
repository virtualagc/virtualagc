# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for LM131 revision 1.
#		The final release of the software for the Lunar Module's
#		(LM) Apollo Guidance Computer (AGC) for Apollo 13. It has been
#		reconstructed from a listing of Luminary 131 and dump of
#		rope memory module B5, part number 2010802-171.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2022-10-28 MAS	Created.

BASENAME=LM131R1

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLM131R1
EXTRA_YAYUL_ARGS=--parity

include ../Makefile.inc

.PHONY: diffLM131R1
diffLM131R1:
	../Tools/check_buggers.py LM131R1.bin LM131R1.buggers
	diff -q LM131R1.bin Luminary131PlusLM131R1ModuleDump.bin
