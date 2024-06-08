# Licensing:	Declared by the author (Ronald Burkey) to be Public Domain
#		in the U.S., and can be freely distributed or modified in 
#		any desired way whatsoever.
# Filename:	Makefile
# Purpose:	1. For building C-language source-code output from the XCOM-I.py
#		   XPL/I-to-C translator program.  
#		2. For running tests on the XCOM-I system.
#		3. This Makefile does *not* build XCOM-I itself, since XCOM-I
#		   is a Python script, which does not require any building.
# Reference:	https://www.ibiblio.org/apollo/Shuttle.html
# Contact:	info@sandroid.org
# Mod history:	2024-03-30 RSB	Wrote
#
# Compiling C-language Source-Code Files Created by XCOM-I
# --------------------------------------------------------
#
# If XCOM-I has translated an XPL or XPL/I program to C, it has moved all of
# the C source-code files (and this Makefile) into a separate project folder
# usually named after the original XPL source-code file it has translated.
# You can `cd` into that project folder and follow the instructions below to
# compile those C-language files into an executable.
#
# You can build the executable from the C source code simply with
#	make
# By default, the compiled program is given the same name as the folder that 
# holds the source code, which is determined by the XCOM-I command-line switch
# --output=FOLDER.  On Windows, you'd typically want the executable you produce
# to have the filename extension ".exe", but this Makefile makes no effort to
# automatically deal with detecting this condition.  
# 
# There are several alterations you can make by changing how `make` is invoked.
# Any of these alterations can be used by itself, or in combination with the 
# others:
#
#	To change the filename of the executable, without changing the 
#	folder name:
#		make TARGET=filename
#	where filename is the desired filename.  For example,
#		make TARGET=myfile.exe
#
#	The name of the C compiler is by default assumed to be given by
#	the setting of the environment variable CC, though if there is
#	no environment variable called CC, it falls back to `gcc` (the
#	GNU C compiler).  To change it to something else, you use
#		make CC=compilername
#	Examples: 
#		make CC=clang
#		make CC=i686-w64-mingw32-gcc

#	To include debugging info in the executable, so that it can be
#	debugged with `gdb` (or whatever), you can use this:
#		make EXTRA=-ggdb

#	Or more generally, EXTRA can be used for any other compiler switches 
#	you like:
#		make EXTRA='options'
#	where the options are specific to the compiler.  The quotation
#	marks need to be present if there are any spaces in the options.  In
#	Linux at least, you can use either single-quotes (') or double-quotes("),
#	with the distinction that environment variables (like, say, $n) will be
#	expanded within double-quotes but not within single quotes; but that's
#	a feature of the command shell, and not something done by us.  
#	When compiling C code emitted by XCOM-I, clang produces large numbers
#	of warnings that most likely are of no interest to you, so you might
#	feel the need to disable those messages when using CC=clang:
#	   EXTRA='-Wno-dangling-else -Wno-constant-conversion -Wno-pointer-sign'
#	Or, if you trust XCOM-I to generate reasonable C source
#	code, you can use EXTRA='-w' to just disable all warning messages.
#	Conversely, if you're trying to figure out something XCOM-I and I 
#	screwed up, you could use EXTRA='-Wall' to enable all warning messages.
#
#	Some invocations of `make` (see below) run XCOM-I rather than merely
#	compiling previously-generated C code.  You can add extra command-line
#	switches for XCOM-I by using the XEXTRA variable.  For example,
#		XEXTRA=--pp
#	turns on "pretty printing" for the generated C code (assuming that the 
#	program clang-format is installed and accessible).
#
# Bootstrapping
# -------------
#
# The "bootstrapping" targets,
#	bootstrap3
#	bootstrap45
# are a little different, in that they perform an entire series of builds of
# an XPL compiler, all the way down to native IBM 360 versions, and try to 
# validate the entire chain of builds by verifying that the final version of 
# the compiler works correctly.  A successful bootstrap is a test of both
# XCOM-I and of sim360.
#
# The options TARGET, CC, EXTRA, and XEXTRA described above can be used as 
# usual with the bootstrapping targets.
#
# Warning:  Building these targets requires programs and BASH (or a similar
# command shell) not normally available on Windows, and maybe not in full on
# stock Mac or Linux without additional setup.  I'm sure Windows *could* be
# made to work, but I'm just not going to research it myself.
#
# For example, 
#	make bootstrap45
# would generate a lot of stuff if it works correctly:
#	XCOM45-native/		Folder of C files, plus XCOM45-native, which is
#				an XCOM 4.5 XPL compiler running natively.
#	XCOM45-360.obj		An IBM 360 version (a "load file") of XCOM 4.5,
#				as compiled by XCOM45-native.
#	XCOM45-360.hex		A human-readable hexadecimal dump of the same.
#	XCOM45-360.rpt		The compiler report.
#	XCOM45-360.*		... and others ...
#	XCOM45-360A.*		Same, but as compiled by XCOM45-360.obj, running
#				in an IBM 360 simulator.
#	XCOM45-360C.*		Same, but as compiled by the legacy XCOM45
#				executable, downloaded along with XCOM45 source.
# A "bootstrap" of XCOM 4.5 is successful if XCOM45-360.obj and XCOM45-360A.obj
# and XCOM45-360C.obj are identical (other than an embedded datestamp/timestamp
# of the compilation time).  This is tested via automated comparison.
#
# Regression Tests
# ----------------
#
# Warning: The same warning about Windows vs Mac vs Linux apply as in the
# preceding section.
#
# Included with the source code for the XCOM-I program itself is a folder
# (Tests/) which contains various XPL and XPL/I sample programs.  A number of
# those sample programs are intended to be tests of XCOM-I itself.  The 
# instructions below explain how to run those tests.
#
#	NOTE: These tests have been tailored for my own system,
#	which runs Linux.  I'm sure they would require adaptation
#	on Windows or Mac OS, because the extra utility programs
#	needed to complete some of the tests are either different
#	or else have somewhat different syntax on those other
#	platforms.
#
# First, `cd` into the folder containing the XCOM-I.py source code.  A copy
# of this Makefile will also be in that folder.  (But this Makefile may be in
# other folders as well, so don't let that confuse you.)
#
# Second, use the command `make REGRESSION=yes`.  Note that the CC, EXTRA, and
# XEXTRA variables can optionally be used as described above.
#
# This process should now have created various additional folders, with names
# like bitsizeDemo/, bitsizeDemoCommon/, and so forth, which contain the 
# executables for the XPL test programs it has built, and possibly test
# results for them.  (If folders by that name previously existed, they have 
# been removed.)
#
# Some tests may be automated, while others may require manual inspection of
# output files saved by the tests.  The manual inspections needed are TBD.
#
# Note on converting ANALYZER report output (say, out.txt) to PDF:  I used
#	enscript -B -f Courier9 -o out.ps out.txt
#	ps2pdf out.ps out.pdf

SHELL = /bin/bash

TARGET = $(notdir $(CURDIR))
ifeq ($(strip $(CC)),)
	CC = gcc
endif

SOURCES = $(wildcard *.c)
HEADERS = $(wildcard *.h)
DIR_SIM360 = sim360-source/simulate

ifndef REGRESSION

#----------------------------------------------------------------------------
# For normal use building C-language files from standard XPL source code.

.PHONY: all
all: $(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(EXTRA) -o $@ $(SOURCES) -lm -rdynamic

# The `clean` target is very iffy.  It must be used only in the XCOM-I folder
# itself, or in folders created by XCOM-I.
.PHONY: clean
clean:
ifeq ($(TARGET),XCOM-I)
	-rm sim360
	-make -C $(DIR_SIM360) clean
else
	-rm $(TARGET)  # For Linux or Mac
	-del $(TARGET) # For Windows
endif

#----------------------------------------------------------------------------
# For building sim360

sim360: $(wildcard $(DIR_SIM360)/*.c) $(wildcard $(DIR_SIM360)/*.h)
	make -C $(DIR_SIM360)
	cp $(DIR_SIM360)/sim360 .

#----------------------------------------------------------------------------
# For building HAL/S-FC source code and running HAL/S-FC.



#----------------------------------------------------------------------------
# Bootstrap tests for legacy source code of standard-XPL compilers.  To
# bootstrap any particular version of XCOM, several variables are set and
# then the `bootstrap` target is built.  The variables are:
#	BASE		The base name upon which all files are built. 
#			Conventionally, XCOM+version.  The C files are stored
#			in BASE/, the executables built are BASE-native, 
#			BASE-360.obj, BASE-360A.obj, and so on.
#	XPLFILE		Path to the XCOM source-code file to build.
#	LIBFILE		Path to the library file containing COMPACTIFY source.
#	RECSIZE		3600 or 7200.  Must match the hardcoded value of
#			`DISKBYTES` in the XPLFILE.
#	LEGACY		Path to the legacy IBM 360 load file for this version
#			of XCOM from the Good Old Days.  Omit this variable
#			entirely if there's no legacy load file available.
#	SELF		(For LEGACY.)  If the legacy load file had been
#			used to build itself, assign SELF any value (such as
#			YES).  If the legacy load file cannot build itself
#			faithfully -- i.e., cannot be used to build the source
#			code and create a load file that *matches* the legacy
#			load file -- then omit this variable entirely.


# Should SUCCEED.  XCOM3 is the 
.PHONY: bootstrap3
bootstrap3:
	@$(MAKE) -s \
		BASE=XCOM3 \
		XPLFILE=Tests/XCOM.xpl \
		LIBFILE=XPL.LIBRARY.xpl \
		RECSIZE=3600 \
		LEGACY=Tests/XCOM3-20010502.obj \
		bootstrap

# Should SUCCEED.
.PHONY: bootstrap45
bootstrap45:
	@$(MAKE) -s \
		BASE=XCOM45 \
		XPLFILE=sim360-source/port/XCOM4.5.xpl \
		LIBFILE=sim360-source/port/XPLIB4.5.xpl \
		RECSIZE=7200 \
		LEGACY=sim360-source/XCOM45-19760719.obj \
		bootstrap

# Expected to FAIL.  However, XCOM45w3 is not legacy software, and has "modern"
# mods (vs XCOM45) related to EBCDIC vs ASCII that I don't understand but which 
# likely wouldn't be rational for legacy software, so its failure is likely not
# indicative of any problem with XCOM-I.  At least, that's my rationale.
.PHONY: bootstrap45w3
bootstrap45w3:
	@$(MAKE) -s \
		BASE=XCOM45w3 \
		XPLFILE=sim360-source/port/xcom4.xpl \
		LIBFILE=sim360-source/port/xplib.xpl \
		RECSIZE=7200 \
		bootstrap

# Note that the condition for a successful bootstrap is that the XXX-360.obj
# and XXX-360A.obj files differ by precisely 3 bytes.  That's because the 
# embedded compile-time timestamp occupies 3 bytes.
ELSE = else
.PHONY: bootstrap
bootstrap: sim360
	@echo "Bootstrapping $(BASE) -----------------------------------------"
	-rm $(BASE)-360*.*
	XCOM-I.py $(XEXTRA) --xpl \
		--lib-file=$(LIBFILE) \
		--output=$(BASE)-native \
		$(XPLFILE)
	make -s -C $(BASE)-native
	$(BASE)-native/$(BASE)-native --extra=2,'/* $Y */' \
		--ddi=0,$(XPLFILE) \
		--ddi=2,$(LIBFILE) \
		--raf=B,$(RECSIZE),1,$(BASE)-360.obj \
		--raf=B,$(RECSIZE),2,$(BASE)-360.dat \
		--raf=B,$(RECSIZE),3,$(BASE)-360.str \
		&>$(BASE)-360.rpt
	sim360 --size=$(RECSIZE) \
		-o0ET $(BASE)-360A.rpt \
		-i0AT $(XPLFILE) \
		-i2AT $(LIBFILE) \
		-f1wb+ $(BASE)-360A.obj \
		-f2wb+ $(BASE)-360A.dat \
		-f3wb+ $(BASE)-360A.str \
		$(BASE)-360.obj
ifdef LEGACY
	sim360 --size=$(RECSIZE) \
		-o0ET $(BASE)-360C.rpt \
		-i0AT $(XPLFILE) \
		-i2AT $(LIBFILE) \
		-f1wb+ $(BASE)-360C.obj \
		-f2wb+ $(BASE)-360C.dat \
		-f3wb+ $(BASE)-360C.str \
		$(LEGACY)
ifdef SELF
	@if [ `cmp -l $(BASE)-360.obj $(LEGACY) | wc -l` -le 6 ] ; \
	then \
		echo "Comparison to legacy load file successful!" ; \
	else \
		echo "Comparison to legacy load file fails!" ; \
	fi
endif # SELF
	@if [ `cmp -l $(BASE)-360.obj $(BASE)-360C.obj | wc -l` -le 4 ] ; \
	then \
		echo "Cross-comparison to legacy compiler's output successful!" ; \
	else \
		hexdump -C $(BASE)-360.obj >$(BASE)-360.hex ; \
		hexdump -C $(BASE)-360C.obj >$(BASE)-360C.hex ; \
		echo "Cross-comparison to legacy compilers's output fails!" ; \
		echo "For more info, try:" ; \
		echo "	meld $(BASE)-360.hex $(BASE)-360C.hex" ; \
	fi
endif # LEGACY
	@if [ `cmp -l $(BASE)-360.obj $(BASE)-360A.obj | wc -l` -le 4 ] ; \
	then \
		echo "Bootstrap of $(BASE) successful!" ; \
	else \
		hexdump -C $(BASE)-360.obj >$(BASE)-360.hex ; \
		hexdump -C $(BASE)-360A.obj >$(BASE)-360A.hex ; \
		echo "Bootstrap of $(BASE) failed!  For more info, try:" ; \
		echo "	meld $(BASE)-360.hex $(BASE)-360A.hex" ; \
	fi

else # REGRESSION

#----------------------------------------------------------------------------
# For running test suite.

XPLI_APPS = bitsizeDemo bitsizeDemoCommon bitsizeDemoCommonIn
XPL_APPS = Example-6.18.3 Example-6.18.4 Example-6.18.5 Example-6.18.6
XPL_APPS += breakCharactersDemo
XPL_APPS += ANALYZER SKELETON

# Here are the principles behind the tests:
#   1.	Various test programs from the Tests/ folder are built.
#   2.  The test programs are run, and output data collected from them.
#   3.  The output data is either checked directly, or more-usually, compared
#	against other the collected data files or compared to previously-
#	determined-correct "regression" files.
#   4.  The only manual step is occasional determination that the "regression"
#	files are valid.
.PHONY: tests
all: testclean $(XPL_APPS) $(XPLI_APPS)
	@cd bitsizeDemo && \
	./bitsizeDemo >out.txt
	@diff -s -q bitsizeDemo/out.txt Tests/bitsizeDemo.regression
	
	@cd bitsizeDemoCommon && \
	./bitsizeDemoCommon >out.txt && \
	csplit out.txt '%^Address Allocations .*%' \
		       '/^Initial Values .*/' \
		       '%^Assignments .*%' >/dev/null && \
	cat xx00 xx01 | \
	egrep --invert-match '(^Address Allocations |^Assignments |^.PAGE [0-9]|^$$)' > xxxx
	
	@e=Example-6.18.3 && \
	cd $$e && \
	./$$e <../Tests/testdata.txt >out.txt && \
	diff -s -q out.txt ../Tests/$$e.regression
	
	@e=Example-6.18.4 && \
	cd $$e && \
	./$$e <../Tests/testdata.txt >out.txt && \
	diff -s -q out.txt ../Tests/$$e.regression
	
	@Example-6.18.6/Example-6.18.6 | \
	egrep '^[0-9]+' | \
	Example-6.18.5/Example-6.18.5 >Example-6.18.5/out.txt && \
	diff -s -q Example-6.18.5/out.txt Tests/Example-6.18.5-and-6.regression
	
	@e=breakCharactersDemo && \
	cd $$e && \
	./$$e >out.txt && \
	diff -s -q out.txt ../Tests/$$e.regression
	
	@ANALYZER/ANALYZER <Tests/SKELETON.bnf | \
	egrep --invert-match 'ANALYZER VERSION|^TODAY IS|^TIME USED|^TOTAL TIME' \
	>ANALYZER/out.txt && \
	egrep --invert-match 'ANALYZER VERSION|^TODAY IS|^TIME USED|^TOTAL TIME' \
	Tests/ANALYZER-SKELETON.regression >ANALYZER/out.regression && \
	diff -s -q ANALYZER/out.txt ANALYZER/out.regression
	
	@echo ""
	@echo "*********** All regression tests passed! ***********"
	@echo ""

.PHONY: testclean
testclean:
	-@rm -rf $(XPL_APPS) $(XPLI_APPS)

.PHONY: $(XPL_APPS)
$(XPL_APPS): 
	@mkdir $@
	@XCOM-I.py $(XEXTRA) --xpl --keep-unused $(PEXTRA) Tests/$@.xpl
	@$(CC) $(EXTRA) -o $@/$@ $@/*.c -lm

.PHONY: $(XPLI_APPS)
$(XPLI_APPS): 
	@mkdir $@
	@XCOM-I.py $(XEXTRA) --keep-unused $(PEXTRA) Tests/$@.xpl
	@$(CC) $(EXTRA) -o $@/$@ $@/*.c -lm

endif # REGRESSION
