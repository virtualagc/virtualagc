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
#
# This 'make' needs to be performed from the Schematics/ directory.
# Icarus Verilog must be installed, and iverilog must be in the PATH.
# Python 2 is also required (rather than Python 3).
#
# Underneath the Schematics/ directory, Makefile expects the following 
# hierarchy and file-naming convention:
#
#	TARGET/
#		TARGET/module.net		Input to the build process
#		TARGET/module.init		Input to the build process
#		TARGET/module_tb.v		Input to the build process
#		TARGET/module.v			Output from the build process
#		TARGET/module.vvp		Output from the build process
#
# The build process basically does this:
#
#	module.net + module.init   ->    module.v
#	module_tb.v + module.v     ->    module.vvp  
#
# Note that the declarations of the Verilog module and its parameters must be
# consistent between module_tb.v (which is supplied as an input) and module.v
# (which is an output of the build process), but makes no attempt to enforce 
# that.  (Though it's possible that iverilog may detect a mismatch and complain.)
# Instead, insuring consistency is the programmer's responsibility.  Since 
# dumbVerilog.py operates in a consistent and predictable way, it should 
# hopefully be effortless to maintain consistency once it's first established.
# However, some actions (like adding an extra input or output for debugging 
# purposes) will temporarily break consistency.

# Here are the targets and their config parameters for AGC 2003200.
TARGETS = testVerilog 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
TARGETS += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
TARGETS += 2005264A 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
TARGETS += 2005250- 2005271- 2005272A 2005273A
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

.PHONY: all
all: $(TARGETS:%=%/module.vvp)

# Make some stubs for a couple of required files.  This helpful for a
# first compilation, but the files need to be filled and the 'make'
# redone if an actual, usable simulation is to be performed.
.SECONDARY: $(TARGETS:%=%/module.init)
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
.SECONDARY: $(TARGETS:%=%/module.v)
%/module.v: %/module.net %/module.init ../Scripts/pins.txt
	../Scripts/dumbVerilog.py $(module_$*) $*/module.net ../Scripts/pins.txt "$(delay_$*)" $*/module.init >$*/temp.v
	mv $*/temp.v $@
