# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Super Job by Super Team.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2017-01-27 MAS  Created from Aurora 12 Makefile.

BASENAME=SuperJob
EXTRA_YAYUL_ARGS=--raytheon --no-checksums
OCT2BIN_ARGS=--no-checksums

include ../Makefile.inc

${BASENAME}.binsource: ${BASENAME}.binsource2.txt
	../Tools/listing2binsource ${VERBOSE} $^ $@
