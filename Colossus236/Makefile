# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus Build 236.
#		The second release (first to be manufactured) of
#		the software for the Command Module's (CM) Apollo
#		Guidance Computer (AGC) for Apollo 8. It has been
#		reconstructed from a listing of Colossus 237.
# Contact:	Ron Burkey <info@sandroid.org>.
# Warning:	THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
# 		AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
# 		COLOSSUS 236.
# Mod history:	2019-08-02 MAS	Created from Colossus 237.

BASENAME=Colossus236

NO_BINSOURCE=yes
EXTRA_TARGETS=diffColossus236sums

include ../Makefile.inc

.PHONY: diffColossus236sums
diffColossus236sums:
	../Tools/check_buggers.py Colossus236.bin Colossus236.buggers
