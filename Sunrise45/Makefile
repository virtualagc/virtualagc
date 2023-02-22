# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sunrise 45
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2022-10-29 RSB	So far we have no source code, so 
#				this is the octal dump of the physical
#				rope-memory modules right now.
# 		2023-02-21 MAS	Added building of reconstructed source.

BASENAME=Sunrise45
EXTRA_YAYUL_ARGS+=--block1 --no-checksums --parity --honeywell
NO_BINSOURCE=yes
EXTRA_TARGETS=diffSunrise45

include ../Makefile.inc

.PHONY: diffSunrise45
diffSunrise45:
	diff -s Sunrise45.bin Sunrise45-dump.bin
