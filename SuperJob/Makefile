# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Super Job by Super Team.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2017-01-27 MAS  Created from Aurora 12 Makefile.
# 		2017-01-30 MAS  Changed to += for extra arguments, and
# 		                added a rule to clean the binsource.

BASENAME=SuperJob
EXTRA_YAYUL_ARGS+=--raytheon --no-checksums --parity
OCT2BIN_ARGS+=--no-checksums --parity

include ../Makefile.inc

${BASENAME}.binsource: ${BASENAME}.binsource2.txt
	../Tools/listing2binsource ${VERBOSE} $^ $@

clean: clean-binsource

clean-binsource:
	rm -f $(BASENAME).binsource
