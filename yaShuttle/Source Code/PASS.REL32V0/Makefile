# The author, Ron Burkey, declares that this file is in the Public Domain under
# U.S. law, and may be freely used, modified, or distributed for any purpose
# whatever.

# This Makefile is used to compile the individual passes of the HAL/S compiler,
# HAL/S-FC, or else to use HAL/S-FC to compile a program written in HAL/S.
# I expect that the Makefile will work out of the box on Linux or Mac OS, if 
# all of the command-line utilities used are installed, but needs a lot of setup 
# on Windows. (See https://www.ibiblio.org/apollo/XPL.html#Windows.)
#
# HAL/S-FC is compiled using XCOM-I to translate HAL/S-FC's XPL+BAL source code
# to C, and then the C code is compiled using gcc or clang.
#
# HAL/S source code is compiled primarily by the version of HAL/S-FC just 
# mentioned, running each of the 7 passes of HAL/S-FC (or at least, however many
# passes are currently functional) in succession.  Additionally, though, there
# is a Python3 port of HAL/S-FC's first pass, so it is also used to compile the
# HAL/S program, and the results of the two first passes are compared.  I.e.,
# the first compiler pass is always run twice on the same HAL/S-FC source-code
# file, using two different implementations of the first pass.
#
# The useful targets of the Makefile are:
#
#	PASS1	(these first 7 targets each compile a single pass of HAL/S-FC)
#	FLO
#	OPT
#	AUX
#	PASS2
#	PASS3
#	PASS4
#	all		(compiles all 7 passes of HAL/S-FC, both PASS and BFS)
#	compile		(uses HAL/S-FC to compile a HAL/S source-code file)
#
# Additional things specifiable on the `make` command line.
#
#	RTARGET=source.hal	By default, the HAL/S source-code file
#				compiled by the `compile` target is
#				HELLO.hal.  But it can be changed to
#				any single HAL/S file.  The extension ".hal"
#				is optional, and will be added or deleted 
#				transparently as needed, but the physical 
#				filename must have that extension regardless
#				of whether or not it's present in RTARGET.
#	BFS=yes			By default, the `compile` target usses the 
#				PASS version of the compiler to comile HAL/S
#				files.  If BFS=yes is present, it instead uses
#				the BFS version of the compiler.
#	PARM_STRING="..."	By default, the compiler options used
#				by HAL/S-FC are given by the variable
#				`PARM_STRING` hard-coded below.  But it
#				can be changed to something else.  See
#				the HAL/S-FC User's Manual, section 5.1.
#				(https://www.ibiblio.org/apollo/Shuttle/HAL_S-FC%20User's%20Manual%20Nov%202005.pdf)
#				Regardless, DEMO.hal uses (different)
#				hard-code parameters, which cannot be changed
#				from the command line.
#	XEXTRA="..."		Extra command-line options for XCOM-I.
#				You can see those options by running
#					XCOM-I.py --help
#	PEXTRA="..."            Extra command-line options for HAL_S_FC.py.
#	EXTRA="..."		Extra C-compiler command-line options.
#				Typical options would be -ggdb (for
#				embedding debugging info for gdb),
#				-w to disable all warning messages,
#				-O3 for optimization, and so on.  Check
#				gcc or clang documentation.
#	HEXTRA="..."		Extra options for HAL/S-FC passes.  
#				Not compiler options as defined by the
#				original documentation (which are in 
#				`PARM_STRING`), but rather the kinds of
#				options which XCOM-I endows uniformly
#				on each of programs it produces.  You
#				can see those options by running 
#					PASS1 --help

SHELL := /bin/bash # To use bash rather than sh.

TARGETS := PASS1 FLO OPT AUX PASS2 PASS3 PASS4
TARGETSB := PASS1B OPTB PASS2B PASS3B
XCOM_DIR := ../../../../XCOM-I
XCOMI := $(XCOM_DIR)/XCOM-I.py
XLIB := $(XCOM_DIR)/SPACELIB.xpl
PORTED := ../../ported
HAL_S_FC_DIR = $(PORTED)/PASS1.PROCS

# Uses commas (and no spaces) as delimiters between parameters in `PARM_STRING`.
PARM_STRING = SRN,LISTING2,X6,LIST,ADDRS,HALMAT,NOTABLES,DECK
PARM4_STRING := 

RTARGET := $(HAL_S_FC_DIR)/HELLO
RTARGET2 := $(subst .hal,,$(RTARGET))

# `sPARM_STRING` is `PARM_STRING` with commas replaced by spaces.
comma := ,
empty :=
space := $(empty) $(empty)
sPARM_STRING := $(subst $(comma),$(space),$(PARM_STRING))

ifdef BFS
HCSUFFIX := B
HCOPTION := --bfs
CARDS := --pdso=3,cards2,E
else
HCSUFFIX :=
HCOPTION := 
CARDS := --ddo=3,cards2.bin,E
endif

all:	$(TARGETS) $(TARGETSB)

.PHONY: $(TARGETS)
$(TARGETS):
	@echo Building HAL/S-FC $@ ...
	@if [[ "$@" == "AUX" ]] ; \
	then \
		cd AUX_PROCS; \
	else \
		cd $@.PROCS; \
	fi && \
	$(XCOMI) $(XEXTRA) --cond=P --cond=V --output=$@ \
		--lib-file=$(XLIB) \
		'##DRIVER.xpl' && \
	make -C $@ $@ && \
	mv $@/$@* ..

.PHONY: $(TARGETSB)
$(TARGETSB):
	@echo Building HAL/S-FC $@ ...
	@if [[ "$@" == "AUXB" ]] ; \
	then \
		cd AUX_PROCS; \
	else \
		cd $(subst B,,$@).PROCS; \
	fi && \
	$(XCOMI) $(XEXTRA) --cond=B --cond=V --output=$@ \
		--lib-file=$(XLIB) \
		'##DRIVER.xpl' && \
	make -C $@ $@ && \
	mv $@/$@* ..

# Note that `clean` doesn't clean everything that was built:  The executables
# from TARGETS remain in place in the current folder, and the build-folders
# for those (such as PASS1.PROCS/PASS1/) remain in place too.  What's cleaned is
# the huge batch of intermediate files created by the builds.  Whereas
# `cleanall` does clean everything.
.PHONY: clean
clean:
	-@rm COMMON* listing2* vmem* halmat* litfile* \
	    *.rpt optmat* auxmat* objcode* cards* \
	    extra* deck* monitor13 -rf 2>/dev/null

.PHONY: cleanall
cleanall: clean
	-@rm $(TARGETS) $(TARGETSB) \
	    PASS1.PROCS/PASS1 FLO.PROCS/FLO OPT.PROCS/OPT \
            AUX_PROCS/AUX PASS2.PROCS/PASS2 PASS3.PROCS/PASS3 \
            PASS4.PROCS/PASS4 \
	    PASS1.PROCS/PASS1B OPT.PROCS/OPTB \
            PASS2.PROCS/PASS2B PASS3.PROCS/PASS3B \
            -rf 2>/dev/null

# Most lines ignored via `IGNORE_LINES` in comparisons are due to obvious 
# reasons, such as having timestamps or other uncontrollable values in them.
# COMPOOL.*VERSION is present because I haven't been able to figure out no way to
# reconcile HAL/S-FC PASS1's habit of using single-byte EBCDIC codes as version
# codes in "D VERSION c" compiler directives with HAL_S_FC's implementation
# of strings as ASCII and it's use of JSON for storing PDS.  So I just ignore
# those version codes as printed out in symbol tables.
# 
# Regarding the differences between the PASS and BFS versions of the compiler:
#    1. Passes FLO, AUX, and PASS4 are identical executables.
#    2. For passes PASS1, OPT, PASS2, and PASS2, the BFS version has 'B'
#	suffixed to the executable's name.
#    3. HAL_S_FC.py differs only in that the switch --bfs is used.
#    4. Different template libraries are used:  TEMPLIB[.json] vs TEMPLIBB[.json].
#    5. The ERRORLIB[.json]'s are identical.
#
# Regarding comparisons between PASS1 and HAL_S_FC.py, note that the literal
# files (litfile.bin or ported/FILE2.bin, respectively) are incomparable.  That's
# because HAL_S_FC.py does not mimic the AP-101S memory model.  Consequently,
# string addresses in litfile.bin are correctly the absolute addresses of
# locations within the LIT_NDX array, but string addresses in FILE2.bin are 
# relative to the beginning of LIT_NDX. If all string addresses within FILE2.bin
# were offset by the absolute starting address of LIT_NDX, the files would
# then be comparable.  The starting address of LIT_NDX does appear in the
# COMMON-memory file output by PASS1, so in principle we could pick this address
# from there, adjust FILE2.bin, and perform the comparison  However, I don't
# do that because it doesn't seem to be worth the effort.
IGNORE_LINES = (HAL/S|FREE STRING AREA|NUMBER OF FILE 6|PROCESSING RATE|CPU TIME FOR|TODAY IS|COMPOOL.*VERSION)
.PHONY: compile
compile: clean
	@echo Processing $(RTARGET2) ==========================================
	
	-$(HAL_S_FC_DIR)/HAL_S_FC.py $(HCOPTION) \
		$(sPARM_STRING) $(PEXTRA) \
		--hal='$(RTARGET2)' \
		>py.rpt
	-./PASS1$(HCSUFFIX) $(HEXTRA) \
		--parm="$(PARM_STRING)" \
		--ddi=0,'$(RTARGET2).hal' \
		--ddo=2,listing2.txt \
		--pdsi=4,TEMPLIB$(HCSUFFIX),E \
		--pdsi=5,ERRORLIB \
		--pdsi=6,ACCESS  \
		--pdso=6,TEMPLIB$(HCSUFFIX),E \
		--commono=COMMON-PASS1.out \
		--raf=B,7200,1,halmat.bin \
		--raf=B,1560,2,litfile.bin \
		--raf=B,3360,6,vmem.bin \
		>c.rpt
	@echo Comparing ...
	-@egrep --invert-match "$(IGNORE_LINES)" c.rpt >cA.rpt
	-@egrep --invert-match "$(IGNORE_LINES)" py.rpt >pyA.rpt
	@diff $(DEXTRA) -q -s cA.rpt pyA.rpt
	@diff $(DEXTRA) -s $(PORTED)/FILE1.bin halmat.bin
	@diff $(DEXTRA) -q -s $(PORTED)/LISTING2.txt listing2.txt
	
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
	
	cp vmemf.bin vmemo.bin
	cp halmatf.bin halmato.bin
	cp litfilef.bin litfileo.bin
	./OPT$(HCSUFFIX)   \
		--ddo=2,listing2o.txt \
		--commoni=COMMON-FLO.out \
		--commono=COMMON-OPT.out \
		--raf=B,7200,1,halmato.bin \
		--raf=B,1560,2,litfileo.bin \
		--raf=B,7200,4,optmato.bin \
		--raf=B,3360,6,vmemo.bin \
		>o.rpt
	
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
	
	cp vmema.bin vmem2.bin
	cp halmata.bin halmat2.bin
	cp litfilea.bin litfile2.bin
	cp optmata.bin optmat2.bin
	cp auxmata.bin auxmat2.bin
	./PASS2$(HCSUFFIX) \
		--ddo=2,listing22.txt \
		$(CARDS) \
		--ddo=4,deck2.bin,E \
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

# Stuff not yet ready enough to be moved up in the `compile` target.	
ignore:
	cp vmem2.bin vmem3.bin
	cp litfile2.bin litfile3.bin
	./PASS3$(HCSUFFIX) \
		--ddo=2,listing23.txt \
		--raf=B,1680,5,sdf3.bin \
		--commoni=COMMON-PASS2.out \
		--commono=COMMON-PASS3.out \
		--raf=B,1560,2,litfile3.bin \
		--raf=B,3360,6,vmem3.bin \
		>c3.rpt
	
	# Fill in PASS4 here ...
	