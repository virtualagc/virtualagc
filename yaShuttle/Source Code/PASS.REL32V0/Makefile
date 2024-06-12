# The author, Ron Burkey, declares that this file is in the Public Domain under
# U.S. law, and may be freely used, modified, or distributed for any purpose
# whatever.

# Required:	Parent folder is PASS.REL32V0/ in Virtual AGC source tree.
#		BASH shell or similar ... i.e., probably for *NIX, not Windows.
#		Python 3
#		gcc
#		make
#		Various *NIX utilities (diff, egrep)

# This Makefile is used to build the components of HAL/S-FC.  It can also be
# used to perform some regression tests, at least insofar as comparing
# HAL/S-FC PASS1 to HAL_S_FC.py.

SHELL := /bin/bash # To use bash rather than sh.

TARGETS := PASS1 FLO OPT AUX PASS2 PASS3 PASS4
XCOM_DIR := ../../../../XCOM-I
XCOMI := $(XCOM_DIR)/XCOM-I.py
XLIB := $(XCOM_DIR)/SPACELIB.xpl
PORTED := ../../ported
HAL_S_FC_DIR = $(PORTED)/PASS1.PROCS

# Uses commas (and no spaces) as delimiters between parameters in `PARM_STRING`.
PARM_STRING := SRN,LISTING2
RTARGET := HELLO

# `sPARM_STRING` is `PARM_STRING` with commas replaced by spaces.
comma := ,
empty :=
space := $(empty) $(empty)
sPARM_STRING := $(subst $(comma),$(space),$(PARM_STRING))


all:	$(TARGETS)

.PHONY: $(TARGETS)
$(TARGETS):
	@echo Building HAL/S-FC $@ ...
	@if [[ "$@" == "AUX" ]] ; \
	then \
		cd AUX_PROCS; \
	else \
		cd $@.PROCS; \
	fi && \
	$(XCOMI) $(XEXTRA) --cond=P --output=$@ \
		--lib-file=$(XLIB) \
		'##DRIVER.xpl' && \
	make -C $@ $@ && \
	cp $@/$@ ..

IGNORE_LINES = (HAL/S|FREE STRING AREA|NUMBER OF FILE 6|PROCESSING RATE|CPU TIME FOR|TODAY IS)
.PHONY: regression
regression: 
	@echo Processing $(RTARGET).xpl with HAL_S_FC.py ...
	$(HAL_S_FC_DIR)/HAL_S_FC.py $(sPARM_STRING) --hal=$(HAL_S_FC_DIR)/$(RTARGET) >py.rpt
	@echo Processing $(RTARGET).xpl with PASS1 ...
	-./PASS1 --pdsi=5,ERRORLIB --pdsi=6,ACCESS  \
		--commono=COMMON-PASS1.out \
		--ddi=0,$(HAL_S_FC_DIR)/$(RTARGET).hal --parm="$(PARM_STRING)" \
		--ddo=2,listing2.txt \
		--raf=B,3360,6,vmem.bin --raf=B,7200,1,halmat.bin \
		--raf=B,1560,2,litfile.bin >c.rpt
	@echo Comparing ...
	-@egrep --invert-match "$(IGNORE_LINES)" c.rpt >c2.rpt
	-@egrep --invert-match "$(IGNORE_LINES)" py.rpt >py2.rpt
	@diff -q -s c2.rpt py2.rpt
	@diff -s $(PORTED)/FILE1.bin halmat.bin
	@diff -q -s $(PORTED)/LISTING2.txt listing2.txt
	
	abort
	@echo Processing $(RTARGET).xpl with FLO ...
	cp vmem.bin vmemf.bin
	cp halmat.bin halmatf.bin
	cp litfile.bin litfilef.bin
	./FLO \
		--commoni=COMMON-PASS1.out --commono=COMMON-FLO.out \
		--raf=B,3360,6,vmemf.bin --raf=B,7200,1,halmatf.bin \
		--raf=B,1560,2,litfilef.bin >f.rpt
