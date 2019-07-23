# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sundial E.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2019-07-23 RSB	So far we have no source code, so 
#				this is just an empty shell right now.

BASENAME=SundialE

## Retread was built for the BLK2 target
EXTRA_YAYUL_ARGS+=--blk2 --early-sbank --no-checksums --parity

# Retread does not have checksums, so disable them.
OCT2BIN_ARGS+=--no-checksums

NO_BINSOURCE=yes
EXTRA_TARGETS=diffSundialE

#include ../Makefile.inc

# This isn't the real "default" target.  It's just here in case
# Makefile.inc is commented out above.
.PHONY: default
default:
	@echo Nothing to do yet.

.PHONY: diffSundialE
diffSundialE:
	diff -s SundialEvb.bin SundialE.bin
