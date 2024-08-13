# The author, Ron Burkey, declares that this file is in the Public Domain under
# U.S. law, and may be freely used, modified, or distributed for any purpose
# whatever.

# This Makefile is used to compile the HAL/S compiler, HAL/S-FC.  This is the
# default when either no target is specified, or with the target 'all'.  It is
# also possible to individually build some subset of the 11 individual programs
# comprising the compiler, by instead mixing-and-matching the targets
# PASS1, PASS1B, FLO, OPT, OPTB, AUXP, PASS2, PASS2B, PASS3, PASS3B, and PASS4.
# However, this is normally needed only when there are changes in the XPL/I
# compiler (XCOM-I) or in the BAL-to-C "patch files", and that is typically
# performed in the XPL/I source-code directory rather than here.
#
# Additional options are specifiable on the `make` command line, including:
#
#	-s		"Silent".  Useful if you don't want a lot of confusing
#			clutter on your screen during the build.
#
#	EXTRA="..."	Extra C-compiler command-line options separated by spaces. 
#			The Makefiles in the subdirectories describe various useful
#			options.  See PASS1/Makefile.  Other typical options 
#			would be -ggdb (useful for executing the compiler under
#			a debugger such as gdb), -w to disable all warning messages
#			useful if your C compiler produces huge numbers of warning
#			messages), -O3 (useful for for optimizing the compiler), 
#			and so on.  Check gcc documentation.

TARGETS = PASS1 FLO OPT AUXP PASS2 PASS3 PASS4
TARGETSB = PASS1B OPTB PASS2B PASS3B

all:	$(TARGETS) $(TARGETSB)

.PHONY: $(TARGETS) $(TARGETSB)
$(TARGETS) $(TARGETSB):
	@echo Building HAL/S-FC $@ ...
	make -C $@ $@
	-mv $@/$@ HALSFC-$@ &>/dev/null
	-mv $@/$@.exe HALSFC-$@.exe &>/dev/null

.PHONY: clean
clean:
	make -C PASS1 clean
	make -C FLO clean
	make -C OPT clean
	make -C AUXP clean
	make -C PASS2 clean
	make -C PASS3 clean
	make -C PASS4 clean
	make -C PASS1B clean
	make -C OPTB clean
	make -C PASS2B clean
	make -C PASS3B clean

.PHONY: distclean
distclean: clean
	-rm HALSFC-PASS1 HALSFC-FLO HALSFC-OPT HALSFC-AUXP HALSFC-PASS2 \
		HALSFC-PASS3 HALSFC-PASS4 HALSFC-PASS1B HALSFC-OPTB HALSFC-PASS2B \
		HALSFC-PASS3B HALSFC-*.exe &>NUL
	-del HALSFC-PASS1 HALSFC-FLO HALSFC-OPT HALSFC-AUXP HALSFC-PASS2 \
		 HALSFC-PASS3 HALSFC-PASS4 HALSFC-PASS1B HALSFC-OPTB HALSFC-PASS2B \
		 HALSFC-PASS3B HALSFC-*.exe &>NUL
		