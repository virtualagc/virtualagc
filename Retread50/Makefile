# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Retread 50.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2019-06-12 MAS  Created.
#		2019-06-17 RSB	Tweaked.

BASENAME=Retread50

## Retread was built for the BLK2 target
EXTRA_YAYUL_ARGS+=--blk2 --early-sbank --no-checksums --parity --honeywell

# Retread does not have checksums, so disable them.
OCT2BIN_ARGS+=--no-checksums

NO_BINSOURCE=yes
EXTRA_TARGETS=diffRetread50

include ../Makefile.inc

.PHONY: diffRetread50
diffRetread50:
	diff -s Retread50vb.bin Retread50.bin
