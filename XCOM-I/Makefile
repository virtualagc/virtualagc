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
#	debugged with `gdb` (or whatever):
#		make EXTRA="options"
#	where the options are specific to the compiler.  The quotation
#	marks need to be present if there are any spaces in the options.
#	For `gcc` or its variants:
#		make EXTRA=-ggdb
#
#	EXTRA can also be used for any other compiler switches you like,
# 	such as switched to turn off compiler warnings:
#		make EXTRA="-ggdb -Wdangling-else"
#
#	Some targets (in particular, "make tests") also run XCOM-I, and
#	PEXTRA allows adding extra command-line switches for XCOM-I.
#	At the moment, this is only interesting for debugging XCOM-I
#	itself, for adding engineering switches like --packing.
#
# Running Tests on the XCOM-I System
# ----------------------------------
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
# Second, use the command `make tests`.  Note that the CC alternative described
# in the preceding section can be used to change the compiler name.
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

TARGET = $(notdir $(CURDIR))
ifeq ($(strip $(CC)),)
	CC = gcc
endif

SOURCES = $(wildcard *.c)
HEADERS = $(wildcard *.h)

#----------------------------------------------------------------------------
# For building C-language files.

.PHONY: all
all: $(TARGET)

$(TARGET): $(SOURCES) $(HEADERS)
	$(CC) $(EXTRA) -o $@ $(SOURCES)

.PHONY: clean
clean:
	-rm $(TARGET)	# For Linux or Mac
	-del $(TARGET)	# For Windows

#----------------------------------------------------------------------------
# For running test suite.

XPLI_APPS = bitsizeDemo bitsizeDemoCommon bitsizeDemoCommonIn
XPL_APPS = Example-6.18.3 Example-6.18.4 Example-6.18.5 Example-6.18.6
XPL_APPS += ANALYZER SKELETON

.PHONY: testclean
testclean:
	-rm $(XPL_APPS) $(XPLI_APPS) -rf

.PHONY: $(XPL_APPS)
$(XPL_APPS): 
	mkdir $@
	XCOM-I.py --xpl $(PEXTRA) Tests/$@.xpl
	$(CC) $(EXTRA) -o $@/$@ $@/*.c

.PHONY: $(XPLI_APPS)
$(XPLI_APPS): 
	mkdir $@
	XCOM-I.py $(PEXTRA) Tests/$@.xpl
	$(CC) $(EXTRA) -o $@/$@ $@/*.c

# Here are the principles behind the tests:
#   1.	Various test programs from the Tests/ folder are built.
#   2.  The test programs are run, and output data collected from them.
#   3.  The output data is either checked directly, or more-usually, compared
#	against other the collected data files or compared to previously-
#	determined-correct "regression" files.
#   4.  The only manual step is occasional determination that the "regression"
#	files are valid.
.PHONY: tests
tests: testclean $(XPL_APPS) $(XPLI_APPS)
	cd bitsizeDemo && \
	./bitsizeDemo >out.txt && \
	diff -s -q ../Tests/bitsizeDemo.regression out.txt
	
	cd bitsizeDemoCommon && \
	./bitsizeDemoCommon >out.txt && \
	csplit out.txt '%^Address Allocations .*%' \
		       '/^Initial Values .*/' \
		       '%^Assignments .*%' >/dev/null && \
	cat xx00 xx01 | \
	egrep --invert-match '(^Address Allocations |^Assignments |^.PAGE [0-9]|^$$)' > xxxx
	
	diff -s -q bitsizeDemo/out.txt bitsizeDemoCommon/out.txt
	
	cd bitsizeDemoCommonIn && \
	./bitsizeDemoCommonIn --commoni=../bitsizeDemoCommon/COMMON.out >out.txt && \
	csplit out.txt '%^Address Allocations .*%' >/dev/null && \
	cat xx00 | \
	egrep --invert-match '(^Address Allocations |^COMMON |^.PAGE [0-9]|^$$)' > xxxx
	
	diff -s -q bitsizeDemoCommon/xxxx bitsizeDemoCommonIn/xxxx
	
	e=Example-6.18.3 && \
	cd $$e && \
	./$$e <../Tests/testdata.txt >out.txt && \
	diff -s -q ../Tests/$$e.regression out.txt
	
	e=Example-6.18.4 && \
	cd $$e && \
	./$$e <../Tests/testdata.txt >out.txt && \
	diff -s -q ../Tests/$$e.regression out.txt
	
	Example-6.18.6/Example-6.18.6 | \
	egrep '^[0-9]+' | \
	Example-6.18.5/Example-6.18.5 >Example-6.18.5/out.txt && \
	diff -s -q Tests/Example-6.18.5-and-6.regression Example-6.18.5/out.txt
	
	ANALYZER/ANALYZER <Tests/SKELETON.bnf | \
	egrep --invert-match 'ANALYZER VERSION|^TODAY IS|^TIME USED|^TOTAL TIME' \
	>ANALYZER/out.txt && \
	egrep --invert-match 'ANALYZER VERSION|^TODAY IS|^TIME USED|^TOTAL TIME' \
	Tests/ANALYZER-SKELETON.regression >ANALYZER/out.regression && \
	diff -s -q ANALYZER/out.regression ANALYZER/out.txt
	
	@echo "*** Success! ***"
	