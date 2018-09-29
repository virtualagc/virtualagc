#!/usr/bin/make
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Filename: 	Schematics/Makefile
# Purpose:	Makefile for building Verilog simulation of AGC from
#		the KiCad schematics.
#
# Mod history:	2018-07-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
#
# We expect the following corresponding directory/file arrangement:
#
#	TARGET/
#		TARGET/module.net		Input to the build process
#		TARGET/module.init		Input to the build process
#		TARGET/module_tb.v		Input to the build process
#		TARGET/module.v			Output from the build process
#		TARGET/module.vvp		Output from the build process

TARGETS := testVerilog 2005259A 2005260A
# These are the AGC modules and the global gate delays associated with the various
# TARGETS.  Each of the TARGETS must have a module_TARGET variable assigned for
# it, which will be one of A1 through A24.  Similarly, a TARGET *could* have a
# delay_TARGET variable assigned for it.  I *hope* that for most modules, after 
# debugging, delay_TARGET won't be needed and can just be omitted.
module_testVerilog = A1
module_2005259A = A1
module_2005260A = A2
delay_2005260A = 0.01

.PHONY: all
all: $(TARGETS:%=%/module.vvp)

# Below are the rules which should work for all TARGET in $(TARGETS)
%/module.vvp: %/module_tb.v %/module.v
	iverilog -o $@ $^

# The purpose of the SECONDARY directive below is that when it's omitted,
# 'make' will believe that module.v is a so-called "intermediate file", and
# will delete it at the end of the build.  By specifying that module.v is
# SECONDARY instead, it will keep module.v and not delete it.
.SECONDARY: $(TARGETS:%=%/module.v)
%/module.v: %/module.net %/module.init ../Scripts/pins.txt
	dumbVerilog.py $(module_$*) $*/module.net ../Scripts/pins.txt "$(delay_$*)" $*/module.init >$@
