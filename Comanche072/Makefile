# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 72.
#		(The source code for the first release of the Command
#		Module's (CM) Apollo Guidance Computer (AGC), Apollo 13.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2024-05-13 MAS	Created from Comanche 067.

BASENAME=Comanche072

EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche072sums

include ../Makefile.inc

.PHONY: diffComanche072sums
diffComanche072sums:
	../Tools/check_buggers.py Comanche072.bin Comanche072.buggers
