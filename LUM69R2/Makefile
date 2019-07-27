# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 69 revision 2.
#		The flown version of software for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 10. It has been
#		reconstructed from a listing of Luminary 069 (revision 0),
#		Luminary 099 (revision 1), and Luminary memos 75 and 78.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2019-07-27 	MAS	Created.

BASENAME=LUM69R2

NO_BINSOURCE=yes
EXTRA_TARGETS=diffLUM69R2sums

include ../Makefile.inc

.PHONY: diffLUM69R2sums
diffLUM69R2sums:
	../Tools/check_buggers.py LUM69R2.bin LUM69R2.buggers
