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
# used to perform some regression tests.

SHELL := /bin/bash # To use bash rather than sh.

COND := P	# P for PFS or B for BFS (or TBD?)

TARGETS := PASS1 FLO OPT AUX PASS2 PASS3 PASS4
XCOM_DIR := ../../../../XCOM-I
XCOMI := $(XCOM_DIR)/XCOM-I.py
XLIB := $(XCOM_DIR)/SPACELIB.xpl
PORTED := ../../ported
HAL_S_FC_DIR = $(PORTED)/PASS1.PROCS

# Uses commas (and no spaces) as delimiters between parameters in `PARM_STRING`.
PARM_STRING := SRN,LISTING2,X6,LIST
PARM4_STRING := 

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
	$(XCOMI) $(XEXTRA) --cond=$(COND) --cond=V --output=$@ \
		--lib-file=$(XLIB) \
		'##DRIVER.xpl' && \
	make EXTRA="-DIS_$@ $(EXTRA)" -C $@ $@ && \
	cp $@/$@ ..

# Note that `clean` doesn't clean everything that was built:  The executables
# from TARGETS remain in place in the current folder, and the build-folders
# for those (such as PASS1.PROCS/PASS1/) remain in place too.  What's cleaned is
# the huge batch of intermediate files created by the builds.  Whereas
# `cleanall` does clean everything.
.PHONY: clean
clean:
	-rm COMMON-*.out listing2*.txt vmem*.bin halmat*.bin litfile*.bin \
	    *.rpt optmat*.bin auxmat*.bin objcode*.obj cards*.txt \
	    extra*.txt deck*.txt monitor13.parms

.PHONY: cleanall
cleanall: clean
	-rm $(TARGETS) PASS1.PROCS/PASS1 FLO.PROCS/FLO OPT.PROCS/OPT \
            AUX_PROCS/AUX PASS2.PROCS/PASS2 PASS3.PROCS/PASS3 \
            PASS4.PROCS/PASS4 -rf

IGNORE_LINES = (HAL/S|FREE STRING AREA|NUMBER OF FILE 6|PROCESSING RATE|CPU TIME FOR|TODAY IS)
.PHONY: regression
regression: 
	@echo Processing $(RTARGET) with HAL_S_FC.py ...
	$(HAL_S_FC_DIR)/HAL_S_FC.py \
		$(sPARM_STRING) \
		--hal=$(HAL_S_FC_DIR)/$(RTARGET) \
		>py.rpt
	
	@echo Processing $(RTARGET) with PASS1 ...
	-./PASS1 $(REXTRA) \
		--parm="$(PARM_STRING)" \
		--ddi=0,$(HAL_S_FC_DIR)/$(RTARGET).hal \
		--ddo=2,listing2.txt \
		--pdsi=5,ERRORLIB \
		--pdsi=6,ACCESS  \
		--commono=COMMON-PASS1.out \
		--raf=B,7200,1,halmat.bin \
		--raf=B,1560,2,litfile.bin \
		--raf=B,3360,6,vmem.bin \
		>c.rpt
	@echo Comparing ...
	-@egrep --invert-match "$(IGNORE_LINES)" c.rpt >cA.rpt
	-@egrep --invert-match "$(IGNORE_LINES)" py.rpt >pyA.rpt
	@-diff -q -s cA.rpt pyA.rpt
	@diff -s $(PORTED)/FILE1.bin halmat.bin
	@diff -q -s $(PORTED)/LISTING2.txt listing2.txt
	
	@echo Processing $(RTARGET) with FLO ...
	cp vmem.bin vmemf.bin
	cp halmat.bin halmatf.bin
	cp litfile.bin litfilef.bin
	./FLO   \
		--ddo=2,listing2f.txt \
		--commoni=COMMON-PASS1.out \
		--commono=COMMON-FLO.out \
		--raf=B,7200,1,halmatf.bin \
		--raf=B,1560,2,litfilef.bin \
		--raf=B,3360,6,vmemf.bin \
		>f.rpt
	
	@echo Processing $(RTARGET) with OPT ...
	cp vmemf.bin vmemo.bin
	cp halmatf.bin halmato.bin
	cp litfilef.bin litfileo.bin
	./OPT   \
		--ddo=2,listing2o.txt \
		--commoni=COMMON-FLO.out \
		--commono=COMMON-OPT.out \
		--raf=B,7200,1,halmato.bin \
		--raf=B,1560,2,litfileo.bin \
		--raf=B,7200,4,optmato.bin \
		--raf=B,3360,6,vmemo.bin \
		>o.rpt
	
	@echo Processing $(RTARGET) with AUX ...
	cp vmemo.bin vmema.bin
	cp halmato.bin halmata.bin
	cp litfileo.bin litfilea.bin
	cp optmato.bin optmata.bin
	./AUX   \
		--ddo=2,listing2a.txt \
		--commoni=COMMON-OPT.out \
		--commono=COMMON-AUX.out \
		--raf=B,7200,1,auxmata.bin \
		--raf=B,1560,2,litfilea.bin \
		--raf=B,7200,4,optmata.bin \
		--raf=B,3360,6,vmema.bin \
		>a.rpt
	
	@echo Processing $(RTARGET) with PASS2 ...
	cp vmema.bin vmem2.bin
	cp halmata.bin halmat2.bin
	cp litfilea.bin litfile2.bin
	cp optmata.bin optmat2.bin
	cp auxmata.bin auxmat2.bin
	./PASS2 \
		--ddo=2,listing22.txt \
		--ddo=3,cards2.bin,U \
		--ddo=4,deck2.bin,U \
		--pdsi=5,ERRORLIB \
		--ddo=7,extra2.txt \
		--commoni=COMMON-AUX.out \
		--commono=COMMON-PASS2.out \
		--raf=B,7200,1,auxmat2.bin \
		--raf=B,1560,2,litfile2.bin \
		--raf=B,1600,3,objcode2.bin \
		--raf=B,7200,4,optmat2.bin \
		--raf=B,3360,6,vmem2.bin \
		>c2.rpt
	
	