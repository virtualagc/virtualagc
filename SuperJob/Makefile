# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Retread 44 (revision 0).
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2016-12-13 MAS  Created from Aurora 12 Makefile.

BASENAME=SuperJob
EXTRA_YAYUL_ARGS=--no-checksums

NO_BINSOURCE=YES
include ../Makefile.inc

${BASENAME}.binsource: ${BASENAME}.binsource2.txt
	../Tools/listing2binsource ${VERBOSE} $^ $@

