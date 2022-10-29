# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sunrise 69
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2022-10-29 RSB	So far we have no source code, so 
#				this is the octal dump of the physical
#				rope-memory modules right now.

BASENAME=Sunrise69
EXTRA_YAYUL_ARGS+=--block1 --no-checksums --parity --honeywell
OCT2BIN_ARGS+=--block1 --no-checksums
NO_BINSOURCE=yes
#EXTRA_TARGETS=diffSunrise69

#include ../Makefile.inc

# This isn't the real "default" target.  It's just here in case
# Makefile.inc is commented out above.
.PHONY: default
default:
	@echo Nothing to do yet.

.PHONY: diffSunrise69
diffSunrise69:
	diff -s Sunrise69vb.bin Sunrise69.bin
