# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Sunburst 120.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2016-09-29 RSB	created.
# 		2016-10-04 JL	Change to use Makefile.inc.
# 		2016-10-05 JL	Set yaYUL args back to default.
#		2016-11-11 RSB	Added MAIN-test.agc for testing .yul.

BASENAME=Sunburst120
EXTRA_TARGETS=MAIN-test.agc.bin MAIN-test.agc.lst
EXTRA_YAYUL_ARGS=--honeywell

include ../Makefile.inc

$(EXTRA_TARGETS):
	../yaYUL/yaYUL --unpound-page ${EXTRA_YAYUL_ARGS} MAIN-test.agc >MAIN-test.agc.lst
	diff MAIN-test.agc.bin Sunburst120.bin
	@echo Build of MAIN-test.agc matches buildof MAIN.agc.
