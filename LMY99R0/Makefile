# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for LMY99 Rev 0 (Luminary Rev 99)
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2009-06-05 RSB	Adapted from similar Comanche 055
#				Makefile.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Fixed so that errors will cause rebuild next
#				time make is run. Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-10-04 JL	Change to use Makefile.inc.
#		2017-08-01 MAS	Updated for LMY99 Rev 0.
#		2019-07-27 MAS	Added check against bugger words from NASA
#				drawing 2021152D.

BASENAME=LMY99R0

EXTRA_TARGETS=diffLMY99R0sums

include ../Makefile.inc

.PHONY: diffLMY99R0sums
diffLMY99R0sums:
	../Tools/check_buggers.py LMY99R0.bin LMY99R0.buggers
