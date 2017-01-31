# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Retread 44 (revision 0).
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2016-12-13 MAS  Created from Aurora 12 Makefile.
# 		2017-01-30 MAS  Changed EXTRA_YAYUL_ARGS and OCT2BIN_ARGS
# 		to += so they can be appended to.

BASENAME=Retread44

## Retread was built for the BLK2 target
EXTRA_YAYUL_ARGS+=--blk2 --no-checksums

# Retread does not have checksums, so disable them.
OCT2BIN_ARGS+=--no-checksums

include ../Makefile.inc
