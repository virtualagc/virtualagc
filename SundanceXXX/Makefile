# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 69 revision 2.
#		The flown version of software for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 10. It has been
#		reconstructed from a listing of Luminary 069 (revision 0),
#		Luminary 099 (revision 1), and Luminary memos 75 and 78.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2019-07-27 	MAS	Created.

BASENAME=SundanceXXX

EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=SundanceDumps.bin diffSundanceXXX

include ../Makefile.inc

.PHONY: diffSundanceXXX
diffSundanceXXX: ../Tools/bdiffhead SundanceDumps.bin $(BASENAME).bin
	../Tools/bdiffhead SundanceDumps.bin $(BASENAME).bin | tail -n+2 | wc -l

SundanceDumps.bin:
	cat Sundance292-B1.bin Sundance302-B2.bin Sundance302-B3.bin \
	    Sundance302-B4.bin Sundance292-B5.bin Sundance306-B6.bin > $@