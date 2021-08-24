# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Artemis 071.
#		The first release of the software for the Command 
#		Module's (CM) Apollo Guidance Computer (AGC) for
#		Apollo 15 through 17. It has been reconstructed
#		from a listing of Artemis 071 and NASA drawing
#		2021154-.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2019-08-14 MAS	Created from Artemis 072.

BASENAME=Artemis071

NO_BINSOURCE=yes
EXTRA_TARGETS=diffArtemis071sums

include ../Makefile.inc

.PHONY: diffArtemis071sums
diffArtemis071sums:
	../Tools/check_buggers.py Artemis071.bin Artemis071.buggers
