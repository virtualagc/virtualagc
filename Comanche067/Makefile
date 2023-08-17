# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Comanche 67.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), Apollo 12.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2024-05-13 RSB	Added
# 		2024-05-13 MAS	Added source build.

BASENAME=Comanche067

EXTRA_YAYUL_ARGS+=--parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffComanche067

include ../Makefile.inc

.PHONY: diffComanche067
diffComanche067:
	diff -s Comanche067.bin Comanche067-dump.bin
