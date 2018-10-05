#!/usr/bin/make
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Filename: 	Schematics/Makefile
# Purpose:	Makefile for building a Verilog simulation of the AGC from
#		the KiCad schematics. It doesn't attempt to actually run
#		the simulated hardware, but simply builds it.
# Host system:	This expects expects to be running under 'bash', and expects
#		'touch', 'mv', 'rm', and 'cat' to be available.  So it works
#		in Linux systems and possibly Mac OS X, but not in Windows.
#		If you want to fix it up to work other than in Linux, look 
#		for 'if', 'touch', 'mv', 'rm', and 'cat' uses.
# Warning:	This Makefile requires GNU 'make' v4.x or higher.  It does 
#		not work with v3.x.
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
#		2018-08-02 RSB	Simplified the structure of the makefile
#				somewhat --- i.e., made it much harder to
#				maintain --- to make it cleaner to added
#				new AGC target p/n's.  I did in fact add
#				all of the machinery for AGC's 2003100 and
#				2003993 (to the extent that I know it), though
#				those targets aren't actually built yet since
#				I don't have CAD for all their files yet.
#				Part of the machinery for Block I (AGC
#				1003700) has also been added, but I haven't
#				worked out details such as gaps in the 
#				module numbering and the lack of a pinDB yet.
#				Also added a default but non-zero gate delay.
#				Added target for AGC.init.
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
# necessarily correctly set up, nor do they necessarily behave correctly.  
#
# Finally, by default, the Verilog "wand" construct is used for NOR-gates, to support
# wire-ANDing them.  The Verilog "pullup" construct is alternately available, and
# to use it instead, the make command would be changed to
#
#	PULLUP=pullup make ...

DEFAULT_GATE_DELAY = 0.2 # In 100ns units.

# An auxiliary function, which takes a drawing number for a given AGC p/n,
# and creates variables (module_DRAWING) that tells which AGC module the drawing
# corresponds to (A1 through A24).  You must the variable MODULES_PROCESSED=none 
# before using on the first module of a given AGC p/n.  Also creates a default
# delay_DRAWING variable, that can be overridden afterward if desired.
MODULES_PROCESSED = none
define moduleTemplate =
	MODULES_PROCESSED += $(1)
	module_$(1) := A$(words $(MODULES_PROCESSED))
	delay_$(1) = $(DEFAULT_GATE_DELAY)
endef

##################################################################################
# Definitions needed for the testVerilog target.
module_testVerilog = A1
delay_testVerilog = 0

##################################################################################
# Here's what goes into an AGC p/n 1003700.  They need to be the drawing numbers
# of modules A1 through A18 and A21 through A38, in exactly that order.
DRAWINGS_1003700 =  1006540A 1006540A 1006540A 1006540A 1006540A 1006540A 1006540A
DRAWINGS_1003700 += 1006540A 1006540A 1006540A 1006540A 1006540A 1006540A 1006540A
DRAWINGS_1003700 += 1006540A 1006540A 1006543D 1006542B 
DRAWINGS_1003700 += 1006556B 1006553F 1006545- 1006555B 1006554A 1006549B 1006544D
DRAWINGS_1003700 += 1006552B 1006559r 1006548B 1006548B 1006546A 1006547H 1006547H
DRAWINGS_1003700 += 1006541B 1006557E 1006550r 1006551B
TARGETS_VVP_1003700 := $(DRAWINGS_1003700:%=%/module.vvp)
TARGETS_V_1003700 := $(DRAWINGS_1003700:%=%/module.v)
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_1003700),$(eval $(call moduleTemplate,$(drawing))))
# Override default delay_DRAWING variables, if a specific drawing needs it. 

##################################################################################
# Here's what goes into an AGC p/n 2003100.  They need to be the drawing numbers
# of modules A1 through A24, in exactly that order.
DRAWINGS_2003100 = 2005059E 2005060D 2005051D 2005062C 2005061D 2005063F
DRAWINGS_2003100 += 2005052D 2005055D 2005056C 2005057E 2005058D 2005053F 2005069E
DRAWINGS_2003100 += 2005064F 2005065D 2005066D 2005067B 2005068C 2005070E 2005054C
DRAWINGS_2003100 += 2005050J 2005071B 2005072C 2005073A
TARGETS_VVP_2003100 := $(DRAWINGS_2003100:%=%/module.vvp)
TARGETS_V_2003100 := $(DRAWINGS_2003100:%=%/module.v)
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003100),$(eval $(call moduleTemplate,$(drawing))))

##################################################################################
# Here's what goes into an AGC p/n 2003200.  They need to be the drawing numbers
# of modules A1 through A24, in exactly that order.
DRAWINGS_2003200 = 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
DRAWINGS_2003200 += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
DRAWINGS_2003200 += 2005264A 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
DRAWINGS_2003200 += 2005250- 2005271- 2005272A 2005273A
TARGETS_VVP_2003200 := $(DRAWINGS_2003200:%=%/module.vvp)
TARGETS_V_2003200 := $(DRAWINGS_2003200:%=%/module.v)
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003200),$(eval $(call moduleTemplate,$(drawing))))

##################################################################################
# Here's what goes into an AGC p/n 2003993.  They need to be the drawing numbers
# of modules A1 through A24, in exactly that order.
DRAWINGS_2003993 = 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
DRAWINGS_2003993 += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
DRAWINGS_2003993 += 2005264B 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
DRAWINGS_2003993 += 2005250- 2005271- 2005272A 2005273A
TARGETS_VVP_2003993 := $(DRAWINGS_2003993:%=%/module.vvp)
TARGETS_V_2003993 := $(DRAWINGS_2003993:%=%/module.v)
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003993),$(eval $(call moduleTemplate,$(drawing))))

##################################################################################

# Override default delay_DRAWING variables here, if a specific drawing needs it or can
# benefit from it. 

# Some combined variables for the complete set of AGC targets.
DRAWINGS_AGC := $(DRAWINGS_2003200) $(DRAWINGS_2003100) $(DRAWINGS_2003993) $(DRAWINGS_1003700)
TARGETS_VVP_AGC := $(TARGETS_VVP_2003200) $(TARGETS_VVP_2003100) $(TARGETS_VVP_2003993) $(TARGETS_VVP_1003700)
TARGETS_V_AGC := $(TARGETS_V_2003200) $(TARGETS_V_2003100) $(TARGETS_V_2003993) $(TARGETS_V_1003700)

# Here are the specific example and AGC targets we're actually trying to build. 
TARGETS = testVerilog/module.vvp
TARGETS += 2003200.vvp $(TARGETS_VVP_2003200)
#TARGETS += 2003100.vvp $(TARGETS_VVP_2003100)
#TARGETS += 2003993.vvp $(TARGETS_VVP_2003993)
#TARGETS += 1003700.vvp $(TARGETS_VVP_1003700)

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-rm $(TARGETS) testVerilog/module.v $(TARGETS_V_AGC) 2>/dev/null

2003200.vvp: 2003200.v $(TARGETS_V_2003200)
	iverilog -o $@ $^

2003100.vvp: 2003100.v $(TARGETS_V_2003100)
	iverilog -o $@ $^

2003993.vvp: 2003993.v $(TARGETS_V_2003993)
	iverilog -o $@ $^

1003700.vvp: 1003700.v $(TARGETS_V_1003700)
	iverilog -o $@ $^

# Note that we only create an AGC's testbench file (such as 2003200) if it doesn't
# already exist.  That's because the one we create from the Verilog of the 
# individual modules is almost certainly goofy, so the developer is likely to 
# have put some work into modifying it the one we create before it has become 
# usable.  But it's a significant amount of work to manually create the testbench
# initially, too, so we would still like to automate that work when we can.

2003200.v: $(TARGETS_V_2003200)
	@if test ! -f $@ ; then cat $^ | ../Scripts/dumbTestbench.py >$@ ; fi

2003100.v: $(TARGETS_V_2003100)
	@if test ! -f $@ ; then cat $^ | ../Scripts/dumbTestbench.py >$@ ; fi

2003993.v: $(TARGETS_V_2003993)
	@if test ! -f $@ ; then cat $^ | ../Scripts/dumbTestbench.py >$@ ; fi

1003700.v: $(TARGETS_V_1003700)
	@if test ! -f $@ ; then cat $^ | ../Scripts/dumbTestbench.py >$@ ; fi

# Make some stubs for a couple of required files.  This helpful for a
# first compilation, but the files need to be filled and the 'make'
# redone if an actual, usable simulation is to be performed.
%/module.init:
	touch $@

.SECONDARY: testVerilog/module_tb.v $(DRAWINGS_AGC:%=%/module_tb.v)
%/module_tb.v: %/module.v
	@if test ! -f $@ ; then cat $^ | ../Scripts/dumbTestbench.py >$@ ; fi

# Below are the rules which should work for every TARGET in $(TARGETS)
%/module.vvp: %/module_tb.v %/module.v
	iverilog -o $@ $^

# The purpose of the SECONDARY directive below is that when it's omitted,
# 'make' will believe that module.v is a so-called "intermediate file", and
# will delete it at the end of the build.  By specifying that module.v is
# SECONDARY instead, it will keep module.v and not delete it.
.SECONDARY: testVerilog/module.v $(DRAWINGS_AGC:%=%/module.v)
%/module.v: %/module.net %/module.init ../Scripts/pins.txt
	../Scripts/dumbVerilog.py $(module_$*) $*/module.net ../Scripts/pins.txt "$(delay_$*)" $*/module.init $*/module.sch $(PULLUP) >$*/temp.v
	mv $*/temp.v $@

# The following target can be used as 2003200.init, 2003993.init, etc.
# It does not create any of those files.  Instead, it creates init files
# for all of 2003200's (or whatever's) modules.  However, it doesn't 
# overwrite any module.init files that already exist.  Moreover, if any
# module.init files are change in the process, you'll need to rebuild all
# of the Verilog afterward, and this target doesn't do that for you.
%.init: %.vvp
	cat $(TARGETS_V_$*) | ../Scripts/dumbInitialization.py
	@n=1; \
	for d in $(DRAWINGS_$*) ; \
	do \
		echo Moving A$$n.init to $$d/module.init ; \
		mv A$$n.init $$d/module.init ; \
		n=$$((n+1)) ; \
	done
