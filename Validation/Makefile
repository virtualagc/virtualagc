# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for AGC instruction validation suite.
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	07/03/04 RSB.	Create.
#		07/16/04 RSB.	Added Validation.txt (the validation-suite
#				binary as formatted for Julian Webb's AGC sim).
#		08/30/04 RSB	Added '-' prefix and --force switch to the 
#				validation-suite build, to work around yaYUL
#				bugs on some platforms.
#		09/05/04 RSB	... and removed them again.  The should work
#				and so shouldn't need them.
#		08/06/05 RSB	In the Validation.bin target, the dependency on
#				../yaYUL/yaYUL was removed, since it's pointless
#				and since it messes up CygWin.
#		05/23/09 RSB	Changed the naming of the symtab file to conform
#				to the new build procedure for VirtualAGC.
#		2009-07-04 RSB	Added --html switch.
#		2016-10-04 JL	Changed to use Makefile.inc.
#		2018-10-12 RSB	Added the Validation-hardware-simulation target.

BASENAME=Validation
NO_BINSOURCE=yes
include ../Makefile.inc

# Assemble a verson for use in hardware simulator.  The --simulation switch in 
# yaYUL tells it how to deal with source lines containing the strings -SIMULATION
# or +SIMULATION in the program comments.
SIM_SOURCE := Validation-hardware-simulation.agc
$(SIM_SOURCE).bin: $(SOURCE)
	cp Validation.agc $(SIM_SOURCE)
	../yaYUL/yaYUL --simulation --hardware --html $(EXTRA_YAYUL_ARGS) $(SIM_SOURCE) >Validation-hardware-simulation.lst
	rm $(SIM_SOURCE)
