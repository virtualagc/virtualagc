# The author, Ron Burkey, declares that this file is in the Public Domain under
# U.S. law, and may be freely used, modified, or distributed for any purpose
# whatever.

# Required:	Parent folder is PASS.REL32V0/ in Virtual AGC source tree.
#		BASH shell or similar ... i.e., probably for *NIX, not Windows.
#		Python 3
#		gcc

# This Makefile has several purposes related to the original source code for
# the HAL/S-FC compiler for the HAL/S language.  By default, it builds 
# HAL/S-FC itself, targeting the Primary Flight System's software.

SHELL := /bin/bash # To use bash rather than sh.

defaultTargets = PASS1 FLO OPT AUX PASS2 PASS3 PASS4
XCOM = ../../../../XCOM-I/XCOM-I.py

.PHONY: all
all:	$(defaultTargets)

$(defaultTargets):
	if [[ "$@" == "AUX" ]] ; \
	then \
		cd AUX_PROCS; \
	else \
		cd $@.PROCS; \
	fi && \
	$(XCOM)	--output=$@ \
		--lib-file=../HALINCL/SPACELIB.xpl \
		'##DRIVER.xpl' && \
	make -C $@ && \
	mv $@/$@ ..
