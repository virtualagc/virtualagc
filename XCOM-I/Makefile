# Licensing:	Declared by the author (Ronald Burkey) to be Public Domain
#		in the U.S., and can be freely distributed or modified in 
#		any desired way whatsoever.
# Filename:	Makefile
# Purpose:	Builds sim360, XCOM3, and XCOM4, and tests the latter (XCOMx)
#		for self-building property.  This Makefile does *not* build 
#		XCOM-I itself, since XCOM-I is a Python script that does not 
#		require any building.
# Reference:	https://www.ibiblio.org/apollo/Shuttle.html
# Contact:	info@sandroid.org
# Mod history:	2024-03-30 RSB	Wrote
#		2024-06-09 RSB	Split off Makefile.template and 
#				Makefile-regression.
#
# Bootstrapping
# -------------
#
# The "bootstrapping" targets,
#	bootstrap3
#	bootstrap45
# perform an entire series of builds of XPL compilers, all the way down to 
# native IBM 360 versions, and try to validate the entire chain of builds by 
# verifying that the final version of the compiler accurately rebuilds itself.  
# A successful bootstrap is a test of both XCOM-I and of sim360.
#
# The options CC, EXTRA, and XEXTRA described in Makefile.template can be used 
# as usual with the bootstrapping targets.  There's also an extra options
# REXTRA, which can be used to pass extra command-line parameters to the 
# XCOMn-native program.
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

SHELL = /bin/bash
# Just in case of working with .exe files in WINE.  Set EXER=wine on the 
# command line.
export WINEDEBUG=-all
EXER=

ifeq ($(strip $(CC)),)
	CC = gcc
endif
ifeq ($(CC), cl)
        CL = 1
        OUT = /Fe:
        CMP = fc /B
        EXT = .exe
        LIBS = 
        export PYTHONUTF8 := 1
else
	CL =
        OUT = -o
        CMP = cmp -l
        EXT =
        LIBS = -lm
endif

DIR_SIM360 = sim360-source/simulate

.PHONY: all
all: bootstrap3 bootstrap45

.PHONY: clean
clean:
	-rm -rf sim360 sim360.exe XCOM3* XCOM45* *.obj *.str *.dat *.rpt

#----------------------------------------------------------------------------
# For building sim360

sim360$(EXT): $(wildcard $(DIR_SIM360)/*.c) $(wildcard $(DIR_SIM360)/*.h)
	$(CC) $(EXTRA) $(OUT) sim360$(EXT) \
		$(DIR_SIM360)/system.c \
		$(DIR_SIM360)/ibm360.c \
		$(DIR_SIM360)/smop.c \
		$(DIR_SIM360)/debug.c \
		$(LIBS)

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
	@"$(MAKE)" -s \
		BASE=XCOM3 \
		XPLFILE=Tests/XCOM.xpl \
		LIBFILE=XPL.LIBRARY.xpl \
		RECSIZE=3600 \
		LEGACY=Tests/XCOM3-20010502.obj \
		bootstrap

# Should SUCCEED.
.PHONY: bootstrap45
bootstrap45:
	@"$(MAKE)" -s \
		BASE=XCOM45 \
		XPLFILE=sim360-source/port/XCOM4.5.xpl \
		LIBFILE=sim360-source/port/XPLIB4.5.xpl \
		RECSIZE=7200 \
		LEGACY=sim360-source/XCOM45-19760719.obj \
		bootstrap

# `bootstrap45w3` is expected to FAIL.  Or more-accurately, XCOM45w3 is not 
# legacy software, and has "modern" mods (vs XCOM45) related to EBCDIC vs ASCII
# that I don't understand but which likely wouldn't appear legacy software, so 
# its failure is likely not indicative of any problem with XCOM-I.  At least, 
#that's my rationale.
.PHONY: bootstrap45w3
bootstrap45w3:
	@"$(MAKE)" -s \
		BASE=XCOM45w3 \
		XPLFILE=sim360-source/port/xcom4.xpl \
		LIBFILE=sim360-source/port/xplib.xpl \
		RECSIZE=7200 \
		bootstrap

# Note that the condition for a successful bootstrap is that the XXX-360.obj
# and XXX-360A.obj files differ by precisely 3 bytes.  That's because the 
# embedded compile-time timestamp occupies 3 bytes.
.PHONY: bootstrap
bootstrap: sim360$(EXT)
	echo Bootstrapping $(BASE) -----------------------------------------
	-@rm $(BASE)-360*.*
	@python3 XCOM-I.py $(XEXTRA) --xpl \
		--lib-file=$(LIBFILE) \
		--output=$(BASE)-native \
		$(XPLFILE)
	@make -s -C $(BASE)-native.build
	@$(EXER) $(BASE)-native$(EXT) --extra=2,"/* $Y */" $(REXTRA) \
		--ddi=0,$(XPLFILE) \
		--ddi=2,$(LIBFILE) \
		--raf=B,$(RECSIZE),1,$(BASE)-360.obj \
		--raf=B,$(RECSIZE),2,$(BASE)-360.dat \
		--raf=B,$(RECSIZE),3,$(BASE)-360.str \
		>$(BASE)-360.rpt
	@$(EXER) sim360$(EXT) --size=$(RECSIZE) \
		-o0ET $(BASE)-360A.rpt \
		-i0AT $(XPLFILE) \
		-i2AT $(LIBFILE) \
		-f1wb+ $(BASE)-360A.obj \
		-f2wb+ $(BASE)-360A.dat \
		-f3wb+ $(BASE)-360A.str \
		$(BASE)-360.obj
ifdef LEGACY
	@$(EXER) sim360$(EXT) --size=$(RECSIZE) \
		-o0ET $(BASE)-360C.rpt \
		-i0AT $(XPLFILE) \
		-i2AT $(LIBFILE) \
		-f1wb+ $(BASE)-360C.obj \
		-f2wb+ $(BASE)-360C.dat \
		-f3wb+ $(BASE)-360C.str \
		$(LEGACY)
ifdef SELF
	@python3 cmp.py 6 $(BASE)-360.obj $(LEGACY) && \
		( echo Comparison to legacy load file successful ) || \
		( echo Comparison to legacy load file fails )
endif # SELF
	@python3 cmp.py 4 $(BASE)-360.obj $(BASE)-360C.obj && \
		( echo Cross-comparison to output of legacy compiler successful ) || \
		( echo Cross-comparison to output of legacy compiler fails )
endif # LEGACY
	@python3 cmp.py 4 $(BASE)-360.obj $(BASE)-360A.obj && \
		( echo Bootstrap of $(BASE) successful ) || \
		( echo Bootstrap of $(BASE) failed )
