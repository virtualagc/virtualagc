#!/usr/bin/make
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Filename: 	Schematics/Makefile
# Purpose:	Makefile for building a Verilog simulation of the AGC from
#		the KiCad schematics. It doesn't attempt to actually run
#		the simulated hardware, but simply builds it.
# Mod history:	2018-07-29 RSB	Wrote first version of this makefile, 
#				covering just testVerilog, 2005259A, 
#				and 2005260A targets.
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

TARGETS := testVerilog 2005259A 2005260A 2005250-
# These are the AGC modules and the global gate delays associated with the various
# TARGETS.  Each of the TARGETS must have a module_TARGET variable assigned for
# it, which will be one of A1 through A24.  Similarly, a TARGET *could* have a
# delay_TARGET variable assigned for it.  I *hope* that for most modules, after 
# debugging, delay_TARGET won't be needed and can just be omitted.
module_testVerilog = A1
module_2005259A = A1
module_2005260A = A2
delay_2005260A = 0.01
module_2005250- = A21

.PHONY: all
all: $(TARGETS:%=%/module.vvp)

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
