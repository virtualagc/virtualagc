# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sundial E.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2019-07-23 RSB	So far we have no source code, so 
#				this is just an empty shell right now.
# 		2023-06-30 MAS	Added source build.

BASENAME=SundialE
EXTRA_YAYUL_ARGS+=--blk2 --early-sbank --honeywell --parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffSundialE

include ../Makefile.inc

.PHONY: diffSundialE
diffSundialE:
	diff -s SundialE.bin SundialE-dump.bin
