# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Corona 261
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	2023-05-02 RSB	So far we have no source code, so 
#				this is the octal dump of the physical
#				rope-memory modules right now.
#		2023-05-27 MAS	Added source build.

BASENAME=Corona261
EXTRA_YAYUL_ARGS+=--block1 --honeywell --parity
NO_BINSOURCE=yes
EXTRA_TARGETS=diffCorona261

include ../Makefile.inc

.PHONY: diffCorona261
diffCorona261:
	diff -s Corona261.bin Corona261-dump.bin
