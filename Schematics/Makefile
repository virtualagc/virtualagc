#!/usr/bin/make
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Filename: 	Schematics/Makefile
# Purpose:	Makefile for building a Verilog simulation of the AGC from
#		the KiCad schematics. It doesn't attempt to actually run
#		the simulated hardware, but simply builds it.
# Mod history:	2018-07-29 RSB	Wrote first version of this makefile, 
#				covering just testVerilog, 2005259A, 
#				and 2005260A targets.
#		2018-07-30 RSB	Just went ahead and added all of the rest
#				of the AGC modules for 2003200 as TARGETS.
#				The build will probably fail as soon as it
#				hits one of the targets I haven't debugged
#				yet, but so what?
#		2018-08-01 RSB	The main target has now become 2003200,
#				which is the AGC p/n 2003200 backplane 
#				(testbench) plus modules A1-A24. It still
#				translates and builds all of the individual
#				modules, of course, on an as-needed basis.
#
# This 'make' needs to be performed from the Schematics/ directory.
# Icarus Verilog must be installed, and iverilog must be in the PATH.
# Python 2 is also required (rather than Python 3).
#
# Underneath the Schematics/ directory, Makefile expects the following 
# hierarchy and file-naming convention:
#
#	DRAWING/
#		DRAWING/module.net		Input to the build process
#		DRAWING/module.init		Input to the build process
#		DRAWING/module_tb.v		Input to the build process
#		DRAWING/module.v		Output from the build process
#		DRAWING/module.vvp		Output from the build process
#
# The build process basically does this for each individual DRAWING:
#
#	module.net + module.init   ->    module.v
#	module_tb.v + module.v     ->    module.vvp  
#
# If module.init and/or module_tb.v don't exist, an empty one will be created.
#
# Note that in any given DRAWING directory, of module_tb.v isn't empty, 
# the declarations of the Verilog module and its parameters must be consistent
# between module_tb.v (which is supplied as an input) and module.v (which is 
# an output of the build process), but makes no attempt to enforce 
# that.  (Though it's possible that iverilog may detect a mismatch and complain.)
# Instead, insuring consistency is the programmer's responsibility.  Since 
# dumbVerilog.py operates in a consistent and predictable way, it should 
# hopefully be effortless to maintain consistency once it's first established.
# However, some actions (like adding an extra input or output for debugging 
# purposes) will temporarily break consistency.
#
# Finally, in addition to translating and building Verilog for the individual
# DRAWING directories, it also creates and builds a test bench for an entire 
# AGC:
#
#	DRAWING1/module.v + ... + DRAWINGn/module.v   ->    AGC_PN.v
#	AGC_PN.v + DRAWING1/module.v + ... + DRAWINGn/module.v   ->    AGC_PN.vvp
#
# The testbench AGC_PN.v is really just intended to be a starting point, since while it 
# has regs, wires, and modules for all of the DRAWINGs used in it, those aren't
# necessarily correctly set up, nor do they necessarily behave correctly.  The 
# testbench is only create if it doesn't already exist.

##################################################################################
# Here's what goes into an AGC p/n 2003200.
DRAWINGS_2003200 = 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
DRAWINGS_2003200 += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
DRAWINGS_2003200 += 2005264A 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
DRAWINGS_2003200 += 2005250- 2005271- 2005272A 2005273A
TARGETS_VVP_2003200 := $(DRAWINGS_2003200:%=%/module.vvp)
TARGETS_V_2003200 := $(DRAWINGS_2003200:%=%/module.v)
# These are the AGC modules and the global gate delays associated with the various
# TARGETS.  Each of the TARGETS must have a module_TARGET variable assigned for
# it, which will be one of A1 through A24.  Similarly, a TARGET *could* have a
# delay_TARGET variable assigned for it.  I *hope* that for most modules, after 
# debugging, delay_TARGET won't be needed and can just be omitted.
module_testVerilog = A1
module_2005259A = A1
module_2005260A = A2
delay_2005260A = 0.01
module_2005251A = A3
module_2005262A = A4
module_2005261A = A5
module_2005263A = A6
module_2005252A = A7
module_2005255- = A8
module_2005256A = A9
module_2005257A = A10
module_2005258A = A11
module_2005253A = A12
module_2005269- = A13
module_2005264A = A14
module_2005265A = A15
module_2005266- = A16
module_2005267A = A17
module_2005268A = A18
module_2005270- = A19
module_2005254- = A20
module_2005250- = A21
module_2005271- = A22
module_2005272A = A23
module_2005273A = A24
##################################################################################

# Here's what we're actually trying to build. 
TARGETS = testVerilog/module.vvp 2003200.vvp

.PHONY: all
all: $(TARGETS)

2003200.vvp: 2003200.v $(TARGETS_V_2003200)
	iverilog -o $@ $^

# Note that we only create an AGC's testbench file (such as 2003200) if it doesn't
# already exist.  That's because the one we create from the Verilog of the 
# individual modules is almost certainly goofy, so the developer is likely to 
# have put some work into modifying it the one we create before it has become 
# usable.  But it's a significant amount of work to manually create the testbench
# initially, too, so we would still like to automate that work when we can.
ifeq ("$(wildcard 2003200.v)", "")
2003200.v: $(TARGETS_V_2003200)
	cat $^ | ../Scripts/dumbTestbench.py >$@
else
2003200.v:
	touch $@
endif


# Make some stubs for a couple of required files.  This helpful for a
# first compilation, but the files need to be filled and the 'make'
# redone if an actual, usable simulation is to be performed.
.SECONDARY: $(DRAWINGS_2003200:%=%/module.init)
%/module.init:
	touch $@

%/module_tb.v:
	touch $@

# Below are the rules which should work for every TARGET in $(TARGETS)
%/module.vvp: %/module_tb.v %/module.v
	iverilog -o $@ $^

# The purpose of the SECONDARY directive below is that when it's omitted,
# 'make' will believe that module.v is a so-called "intermediate file", and
# will delete it at the end of the build.  By specifying that module.v is
# SECONDARY instead, it will keep module.v and not delete it.
.SECONDARY: $(DRAWINGS_2003200:%=%/module.v)
%/module.v: %/module.net %/module.init ../Scripts/pins.txt
	../Scripts/dumbVerilog.py $(module_$*) $*/module.net ../Scripts/pins.txt "$(delay_$*)" $*/module.init >$*/temp.v
	mv $*/temp.v $@
