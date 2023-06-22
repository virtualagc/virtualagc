# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sunrise 69
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2022-10-29 RSB	So far we have no source code, so 
#				this is the octal dump of the physical
#				rope-memory modules right now.
# 		2023-06-19 MAS	Added source build.

BASENAME=Sunrise69
EXTRA_YAYUL_ARGS+=--block1 --no-checksums --parity --honeywell
NO_BINSOURCE=yes
EXTRA_TARGETS=diffSunrise69

include ../Makefile.inc

.PHONY: diffSunrise69
diffSunrise69:
	diff -s Sunrise69.bin Sunrise69-dump.bin
