# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Manche72 revision 3.
#		(The source code for the final, flown release of the Command
#		Module's (CM) Apollo Guidance Computer (AGC), Apollo 13.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2024-05-19 MAS	Created from Comanche 072.

BASENAME=Manche72R3

EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffManche72R3sums

include ../Makefile.inc

.PHONY: diffManche72R3sums
diffManche72R3sums:
	../Tools/check_buggers.py Manche72R3.bin Manche72R3.buggers
