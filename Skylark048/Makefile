# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Skylark048.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), Skylab 2-4 and ASTP.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2024-01-26 RSB	Dummy version to just use the dump of
#				the core ropes, since source isn't 
#				available yet.
#		2024-03-05 MAS	Added building of reconstructed source.

BASENAME=Skylark048
EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffSkylark048

include ../Makefile.inc

.PHONY: diffSkylark048
diffSkylark048:
	diff -s Skylark048.bin Skylark048-dump.bin
