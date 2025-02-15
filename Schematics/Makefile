#!/usr/bin/make
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Filename: 	Schematics/Makefile
# Purpose:	Makefile for building a Verilog simulation of the AGC from
#		the KiCad schematics. It doesn't attempt to actually run
#		the simulated hardware, but simply builds it.
# Host system:	This expects expects to be running under 'bash' (or a very 
#		similar shell program), and expects
#		'touch', 'mv', 'rm', and 'cat' to be available.  So it works
#		in Linux systems and possibly Mac OS X, but not in Windows.
#		If you want to fix it up to work other than in Linux, look 
#		for 'if', 'touch', 'mv', 'rm', and 'cat' uses.
# Warning:	This Makefile requires GNU 'make' v4.x or higher.  It does 
#		not work with v3.x.
# Mod history:	2018-09-29 RSB	Wrote first version of this makefile, 
#				covering just testVerilog, 2005259A, 
#				and 2005260A targets.
#		2018-09-30 RSB	Just went ahead and added all of the rest
#				of the AGC modules for 2003200 as TARGETS.
#				The build will probably fail as soon as it
#				hits one of the targets I haven't debugged
#				yet, but so what?
#		2018-10-01 RSB	The main target has now become 2003200,
#				which is the AGC p/n 2003200 backplane 
#				(testbench) plus modules A1-A24. It still
#				translates and builds all of the individual
#				modules, of course, on an as-needed basis.
#		2018-10-02 RSB	Simplified the structure of the makefile
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
#		2018-10-08 RSB	Now account for separate "tb.v" files, so 
#				avoid hard-coding unnecessary stuff into 
#				the module_tb.v files or AGCNUMBER.v files.
#		2018-10-10 RSB	Changed the default Verilog construct used
#				for NOR gates from 'wand' to 'wire'.  I did
#				that because the 'wand' construct was making
#				a simulation that didn't work as well as the
#				'wire'.  However, I've since fixed that in
#				dumbVerilog.py, so I've added a 'test' target
#				here to verify that the two produce the same
#				simulation results.
#		2018-10-11 RSB	For the 2003200.init target (which creates 
#				the initialization conditions for the flip-flops)
#				I found that it was rebuilding 2003200.vvp
#				which wasn't wanted.
#		2018-10-12 RSB	Changed the default ROM from Aurora12 to 
#				Validation-hardware-simulation.
#		2018-10-13 RSB	Now pass various parameters to the testbench
#				so that they can change at build-time rather
#				than needing to be hardcoded into the testbench
#				Verilog:  simulation run-length, signals to 
#				be dumped, and so on.
#		2018-10-18 RSB	Added A52.
#		2018-10-27 RSB	Changed time units from 100ns/1ns to 1ns/1ps.
#				Also, I notice that 'clean' doesn't delete the
#				generated module_tb.v files, so that's been fixed.
#		2025-01-17 RSB	Updates for KiCad v6+.
#
# This 'make' needs to be performed from the Schematics/ directory.
# Icarus Verilog must be installed, and iverilog must be in the PATH.
# Python 3 is required.
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
# Note that in any given DRAWING directory, if module_tb.v isn't empty, 
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
# There are various environment variables that can be defined to alter
# the default setup: 
#
#	[VAR1=VAL1] [VAR2=VAL2] ... make ...
#
# These variables are:
#
#	KICAD_EXT=EXTENSION	Filename extension for KiCad schematics.  Default
#				is "kicad_sch" (KiCad v6+), but could be "sch" (KiCad v5-).
#	AGC_MODEL=N		Default 2003200.  Choices are 2003993 etc.
#	WIRETYPE=wand		The affect which Verilog constructs are used to accomplish
#	WIRETYPE=wire		wire-AND'ing of signals.  By default, "wire" is used, which
#				means that signals are defined to actively pull to ground
#				when 0, but are tri-stated when 1, and have a pullup.
#				The other choice, "wand", is a dedicated Verilog construct
#				that serves the same purpose.  The intention is that identical
#				simulation results will be achieved by the two.
#	GATE_DELAY=TIME		Overrides at Verilog-compile time the DEFAULT_GATE_DELAY
#				(see below) embedded in the Verilog files.
#	DEFAULT_GATE_DELAY=TIME	Affects how dumbVerilog.py assigns the default gate delay it
#				embeds when it generates Verilog from the KiCad netlists.  
#				The default is 20 (in units of ns), i.e. 20 ns.
#	ROM=PROGRAM		The name of the AGC software installed in the simulation.
#				Defaults to "Validation-hardware-simulation".
#	RUNLENGTH=TIME		Controls the length of the simulation.  The units are ns,
#				and the default for full-AGC targets (2003200, 2003100, etc.)
#				is 250000000 (250 ms).  The defaults for other testbench
#				targets (module A1, A2, etc.) may differ, but all will be
#				affected by this setting.
#	DUMP_ALL=1		These affect which set of signals is stored in the 
#	DUMP_BACKPLANE=1	file (.lxt2, .lxt, .vcd, .fst) dumped to the filesystem
#	DUMP_DECODER=1		during the simulation run.  Respectively, they mean
#	DUMP_HELPFUL=1		literally all the signals, just the signals appearing
#				on the backplane, just the signals needed by the 
#				gtkwave instruction decoder, or the signals for the 
#				instruction decoder plus a few other signals (A, L, Z, ...).
#				The default is DUMP_HELPFUL.  This is only guaranteed to
#				affect full-AGC targets; whether it affects other testbenches
#				depend on how those are defined internally.
#	DUMPFILE=FILENAME	Name of the dumpfile to create, defaulting to "agc.fst"
#				for full-AGC targets (2003200, 2003100, ...).  Other 
#				targets, like those for module A1, A2, and so on, may 
#				have different defaults, but all will be affected equally
#				by this setting.
#
# Note that WIRETYPE and DEFAULT_GATE_DELAY affect the generated Verilog for the circuit
# modules, and hence different values (at present) affect files that are stored in the 
# git repository.  The others affect only the Verilog compilation process, and therefore
# do not modify files saved in git.

ifndef AGC_MODEL
	AGC_MODEL = 2003200
endif

ifndef DEFAULT_GATE_DELAY
	# In 1ns units.
	DEFAULT_GATE_DELAY = 20
endif

ifndef ROM
	ROM := Validation-hardware-simulation
endif

ifndef KICAD_EXT
	KICAD_EXT=kicad_sch
endif

ifndef GATE_DELAY
	GATE_DELAY = $(DEFAULT_GATE_DELAY)
endif

# Mods for the 2003200.v and similar compilation by iverilog.
EXTRA_IV_ARGS = -DSPOOF_SC
ifdef DUMPFILE
	EXTRA_IV_ARGS += -Pagc.DUMPFILE='"$(DUMPFILE)"'
endif
ifdef RUNLENGTH
	EXTRA_IV_ARGS += -Pagc.RUNLENGTH=$(RUNLENGTH)
endif
DUMPED =
ifdef DUMP_ALL
	EXTRA_IV_ARGS += -DDUMP_ALL
	DUMPED = 1
endif
ifdef DUMP_BACKPLANE
	EXTRA_IV_ARGS += -DDUMP_BACKPLANE
	DUMPED = 1
endif
ifdef DUMP_DECODER
	EXTRA_IV_ARGS += -DDUMP_DECODER
	DUMPED = 1
endif
ifdef DUMP_HELPFUL
	EXTRA_IV_ARGS += -DDUMP_HELPFUL
	DUMPED = 1
endif
ifndef DUMPED
	EXTRA_IV_ARGS += -DDUMP_HELPFUL
endif
ifneq ($(DEFAULT_GATE_DELAY),$(GATE_DELAY))
	EXTRA_IV_ARGS += -Pagc.GATE_DELAY=$(GATE_DELAY)
endif

# An auxiliary function, which takes a drawing number for a given AGC p/n,
# and creates variables (module_DRAWING) that tells which AGC module the drawing
# corresponds to (A1 through A24).  You must the set MODULES_PROCESSED=none 
# before using on the first module of a given AGC p/n.  Also creates a default
# delay_DRAWING variable, that can be overridden afterward if desired.
MODULES_PROCESSED = none
define moduleTemplate =
	MODULES_PROCESSED += $(1)
	module_$(1) := A$(words $(MODULES_PROCESSED))
	delay_$(1) = $(DEFAULT_GATE_DELAY)
endef

##################################################################################
# Definitions needed for targets that don't fit into the neat pattern dealt
# with by moduleTemplate above.  That's basically everything not in the module
# range A1-A24.
module_testVerilog = A1
delay_testVerilog = 0
module_2003305B = A52
delay_2003305B = $(DEFAULT_GATE_DELAY)
module_fixed_erasable_memory = A99
delay_fixed_erasable_memory = $(DEFAULT_GATE_DELAY)

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
TARGETS_TB_V_1003700 := $(DRAWINGS_1003700:%=%/module_tb.v)
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
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003100),$(eval $(call moduleTemplate,$(drawing))))
# Add more drawings separately that don't fit into the nice module-number sequence used above.
DRAWINGS_2003100 += fixed_erasable_memory
TARGETS_VVP_2003100 := $(DRAWINGS_2003100:%=%/module.vvp)
TARGETS_V_2003100 := $(DRAWINGS_2003100:%=%/module.v)
TARGETS_TB_V_2003100 := $(DRAWINGS_2003100:%=%/module_tb.v)

##################################################################################
# Here's what goes into an AGC p/n 2003200.  They need to be the drawing numbers
# of modules A1 through A24, in exactly that order.
DRAWINGS_2003200 = 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
DRAWINGS_2003200 += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
DRAWINGS_2003200 += 2005264A 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
DRAWINGS_2003200 += 2005250- 2005271- 2005272A 2005273A
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003200),$(eval $(call moduleTemplate,$(drawing))))
# Add more drawings separately that don't fit into the nice module-number sequence used above.
DRAWINGS_2003200 += fixed_erasable_memory
DRAWINGS_2003200 += 2003305B
TARGETS_VVP_2003200 := $(DRAWINGS_2003200:%=%/module.vvp)
TARGETS_V_2003200 := $(DRAWINGS_2003200:%=%/module.v)
TARGETS_TB_V_2003200 := $(DRAWINGS_2003200:%=%/module_tb.v)

##################################################################################
# Here's what goes into an AGC p/n 2003993.  They need to be the drawing numbers
# of modules A1 through A24, in exactly that order.
DRAWINGS_2003993 = 2005259A 2005260A 2005251A 2005262A 2005261A 2005263A
DRAWINGS_2003993 += 2005252A 2005255- 2005256A 2005257A 2005258A 2005253A 2005269-
DRAWINGS_2003993 += 2005264B 2005265A 2005266- 2005267A 2005268A 2005270- 2005254-
DRAWINGS_2003993 += 2005250- 2005271- 2005272A 2005273A
# Create module_DRAWING and delay_DRAWING variables for each drawing.
MODULES_PROCESSED = none
$(foreach drawing,$(DRAWINGS_2003993),$(eval $(call moduleTemplate,$(drawing))))
# Add more drawings separately that don't fit into the nice module-number sequence used above.
DRAWINGS_2003993 += fixed_erasable_memory
TARGETS_VVP_2003993 := $(DRAWINGS_2003993:%=%/module.vvp)
TARGETS_V_2003993 := $(DRAWINGS_2003993:%=%/module.v)
TARGETS_TB_V_2003993 := $(DRAWINGS_2003993:%=%/module_tb.v)

##################################################################################

# Override default delay_DRAWING variables here, if a specific drawing needs it or can
# benefit from it. 

# Some combined variables for the complete set of AGC targets.
DRAWINGS_AGC := $(DRAWINGS_2003200) $(DRAWINGS_2003100) $(DRAWINGS_2003993) $(DRAWINGS_1003700)
TARGETS_VVP_AGC := $(TARGETS_VVP_2003200) $(TARGETS_VVP_2003100) $(TARGETS_VVP_2003993) $(TARGETS_VVP_1003700)
TARGETS_V_AGC := $(TARGETS_V_2003200) $(TARGETS_V_2003100) $(TARGETS_V_2003993) $(TARGETS_V_1003700)
TARGETS_TB_V_AGC := $(TARGETS_TB_V_2003200) $(TARGETS_TB_V_2003100) $(TARGETS_V_TB_2003993) $(TARGETS_TB_V_1003700)

# Do not combined these Verilog files with any of the TARGETS_V_etc, because they
# are not auto-generated and definitely should never be erased.
EXTRA_V := fixed_erasable_memory/BUFFER.v fixed_erasable_memory/RAM.v fixed_erasable_memory/ROM.v 

# Here are the specific example and AGC targets we're actually trying to build. 
TARGETS = testVerilog/module.vvp
TARGETS += $(AGC_MODEL).vvp $(TARGETS_VVP_$(AGC_MODEL))

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-rm $(TARGETS) roms/rom.v 2003200.v 2003100.v 2003993.v 1003700.v \
		testVerilog/module.v testVerilog/module_tb.v \
		$(TARGETS_V_AGC) $(TARGETS_TB_V_AGC) 2>/dev/null

2003200.vvp: 2003200.v $(TARGETS_V_2003200) tb-2003200.v $(EXTRA_V) roms/rom.v
	iverilog $(EXTRA_IV_ARGS) -o $@ 2003200.v $(TARGETS_V_2003200) $(EXTRA_V)

2003100.vvp: 2003100.v $(TARGETS_V_2003100) tb-2003100.v $(EXTRA_V) roms/rom.v
	iverilog $(EXTRA_IV_ARGS) -o $@ 2003100.v $(TARGETS_V_2003100) $(EXTRA_V)

2003993.vvp: 2003993.v $(TARGETS_V_2003993) tb-2003993.v $(EXTRA_V) roms/rom.v
	iverilog $(EXTRA_IV_ARGS) -o $@ 2003993.v $(TARGETS_V_2003993) $(EXTRA_V)

1003700.vvp: 1003700.v $(TARGETS_V_1003700) tb-1003700.v roms/rom.v
	iverilog $(EXTRA_IV_ARGS) -o $@ 1003700.v $(TARGETS_V_1003700)

# Note that we only create an AGC's testbench file (such as 2003200) if it doesn't
# already exist.  That's because the one we create from the Verilog of the 
# individual modules is almost certainly goofy, so the developer is likely to 
# have put some work into modifying it the one we create before it has become 
# usable.  But it's a significant amount of work to manually create the testbench
# initially, too, so we would still like to automate that work when we can.

2003200.v: $(TARGETS_V_2003200) tb-2003200.v
	@if test ! -f $@ ; then cat $(TARGETS_V_2003200) | dumbTestbench.py tb-2003200.v $(DEFAULT_GATE_DELAY) >$@ ; fi

2003100.v: $(TARGETS_V_2003100) tb-2003100.v
	@if test ! -f $@ ; then cat $(TARGETS_V_2003100) | dumbTestbench.py tb-2003100.v $(DEFAULT_GATE_DELAY) >$@ ; fi

2003993.v: $(TARGETS_V_2003993) tb-2003993.v
	@if test ! -f $@ ; then cat $(TARGETS_V_2003993) | dumbTestbench.py tb-2003993.v $(DEFAULT_GATE_DELAY) >$@ ; fi

1003700.v: $(TARGETS_V_1003700) tb-1003700.v
	@if test ! -f $@ ; then cat $(TARGETS_V_1003700) | dumbTestbench.py tb-1003700.v $(DEFAULT_GATE_DELAY) >$@ ; fi

# Make some stubs for a couple of required files.  This helpful for a
# first compilation, but the files need to be filled and the 'make'
# redone if an actual, usable simulation is to be performed.
%/module.init:
	touch $@

.SECONDARY: testVerilog/module_tb.v $(DRAWINGS_AGC:%=%/module_tb.v)
%/module_tb.v: %/module.v %/tb.v
	@if test ! -f $@ ; then cat $^ | dumbTestbench.py $*/tb.v $(DEFAULT_GATE_DELAY) >$@ ; fi

# Below are the rules which should work for every TARGET in $(TARGETS)

roms/rom.v: roms/$(ROM).v
	cp $< $@

FIXED_ERASABLE_V := fixed_erasable_memory/module_tb.v fixed_erasable_memory/module.v fixed_erasable_memory/tb.v $(EXTRA_V)
fixed_erasable_memory/module.vvp: $(FIXED_ERASABLE_V) roms/rom.v
	iverilog -o $@ $(FIXED_ERASABLE_V)

%/module.vvp: %/module_tb.v %/module.v %/tb.v
	iverilog -o $@ $*/module_tb.v $*/module.v

# The purpose of the SECONDARY directive below is that when it's omitted,
# 'make' will believe that module.v is a so-called "intermediate file", and
# will delete it at the end of the build.  By specifying that module.v is
# SECONDARY instead, it will keep module.v and not delete it.  The gate
# delay is fixed.  That's because if we want the gate delay changed, we'll
# do it at Verilog-compile time, rather than changing the Verilog source
# files.  However, the value 0.2 seems to work well.
.SECONDARY: testVerilog/module.v $(DRAWINGS_AGC:%=%/module.v)
%/module.v: %/module.net %/module.init pins.txt
	dumbVerilog.py $(module_$*) $*/module.net pins.txt "$(delay_$*)" $*/module.init $*/module.$(KICAD_EXT) $(WIRETYPE) >$*/temp.v
	mv $*/temp.v $@

# The following target can be used as 2003200.init, 2003993.init, etc.
# It does not create any of those files.  Instead, it creates init files
# for all of 2003200's (or whatever's) modules.  However, it doesn't 
# overwrite any module.init files that already exist.  Moreover, if any
# module.init files are change in the process, you'll need to rebuild all
# of the Verilog afterward, and this target doesn't do that for you.
%.init:
	cat $*.v tb-$*.v $(TARGETS_V_$*) | dumbInitialization.py
	@n=1; \
	for d in $(DRAWINGS_$*) ; \
	do \
		m=A$$n ; \
		if test "$$d" = "fixed_erasable_memory" ; then m=A99 ; fi ; \
		if test "$$d" = "2003305B" ; then m=A52 ; fi ; \
		echo Moving $$m.init to $$d/module.init ; \
		mv $$m.init $$d/module.init ; \
		n=$$((n+1)) ; \
	done

# Performs a test of building with the "wand" construct vs the "wire" construct.
# Unfortunately, the .lxt files produced by this (test-wire.lxt and test-wand.lxt)
# will differ, so you can't automatically compare them.  You have several choices,
# I guess.  If you install Impulse in Eclipse, it can compare two .lxt files; but
# you need to get a (free) license and in my experience, the comparison feature is
# rather useless for this purpose.  You code just visually compare the waveforms by
# running two instances of gtkwave side by side (which this target does for you).
# Or ... and this is my recommendation ... you can export the data from gtkwave as
# a TIM file.  If I knew how to automate that, I would.  The two TIM files will be
# identical and can be diff'd. A nice side effect is that the TIM files contain a
# friendly list of the instructions and involuntary instructions executed.
.PHONY: test
test: 
	-rm test-wand.lxt test-wire.lxt test-wand.tim test-wire.tim
	make test-wand.lxt
	make test-wire.lxt
	gtkwave test-wand.lxt agc-decoder.gtkw & \
	gtkwave test-wire.lxt agc-decoder.gtkw &

test-%.lxt: 
	WIRETYPE=$* make clean all
	cp fixed_erasable_memory/module.v test-$*.v
	vvp $(AGC_MODEL).vvp -lxt
	mv agc.lxt $@

	