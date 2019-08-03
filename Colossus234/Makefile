# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus Build 234.
#		The first (unmanufactured) of the software for the
#		Command Module's (CM) Apollo Guidance Computer (AGC)
#		for Apollo 8. It has been reconstructed from a
#		listing of Colossus 237.
# Contact:	Ron Burkey <info@sandroid.org>.
# Warning:	THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
# 		AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
# 		COLOSSUS 234.
# Mod history:	2019-08-02 MAS	Created from Colossus 237.

BASENAME=Colossus234

NO_BINSOURCE=yes
EXTRA_TARGETS=diffColossus234sums

include ../Makefile.inc

.PHONY: diffColossus234sums
diffColossus234sums:
	../Tools/check_buggers.py Colossus234.bin Colossus234.buggers
