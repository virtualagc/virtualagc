# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Aurora 88.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2022-11-17 RSB	Adapted from Retread50/Makefile
#				and Aurora12/Makefile.
# 		2023-07-12 MAS	Added source build.

BASENAME=Aurora88
EXTRA_YAYUL_ARGS+=--blk2 --early-sbank --parity --honeywell
NO_BINSOURCE=yes
EXTRA_TARGETS=diffAurora88

include ../Makefile.inc

.PHONY: diffAurora88
diffAurora88:
	diff -s Aurora88.bin Aurora88-dump.bin
