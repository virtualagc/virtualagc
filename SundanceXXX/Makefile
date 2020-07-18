# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for a reconstructed, mixed version of Sundance,
#		the software for the Lunar Module's (LM) Apollo Guidance
#		Computer (AGC) for Apollo 9. It has been reconstructed
#		from binary dumps of original core rope program modules.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	2019-07-27 	MAS	Created.

BASENAME=SundanceXXX

EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=SundanceDumps.bin diffSundanceXXX.txt checkSundanceXXX

include ../Makefile.inc

diffSundanceXXX.txt: ../Tools/bdiffhead SundanceDumps.bin $(BASENAME).bin
	../Tools/bdiffhead SundanceDumps.bin $(BASENAME).bin | tail -n+3 > $@

.PHONY: checkSundanceXXX
checkSundanceXXX: diffSundanceXXX.txt
	cat $< SundanceXXXDifferences.txt | sed 's/;.*//' | sort | uniq -u | wc -l

SundanceDumps.bin:
	cat Sundance292-B1.bin Sundance302-B2.bin Sundance302-B3.bin \
	    Sundance302-B4.bin Sundance292-B5.bin Sundance306-B6.bin > $@
