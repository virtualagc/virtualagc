# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 1A (build 099).
#		(The source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), Apollo 11.)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2009-06-05 RSB	Adapted from similar Comanche 055
#				Makefile.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Fixed so that errors will cause rebuild next
#				time make is run. Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-10-04 JL	Change to use Makefile.inc.
#		2017-12-29 RSB	Temporarily (or otherwise), added the
#				--bailout=BAILOUT1 CLI switch for yaYUL.

BASENAME=Luminary099

# The following variable is used to cause yaYUL to place the address of the
# BAILOUT1 routine at address 07777, which was a feature the orginal rope did
# NOT have.  In fact, that address was unused fixed-memory in the original
# rope.  See the comments in the header of the file Luminary099.binsource
# for further explanation of why I've put it there.
EXTRA_YAYUL_ARGS=--bailout=BAILOUT1

include ../Makefile.inc

AP11ROPE.bin: Luminary099.bin AP11ROPE.binsource
	../Tools/oct2bin $(OCT2BIN_ARGS) <AP11ROPE.binsource
	mv oct2bin.bin $@
	# Uncomment and add to $(EXTRA_TARGETS) when this when AP11ROPE 
	# proofing is complete
	# diff -s $@ $<
