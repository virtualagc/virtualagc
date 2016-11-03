# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Colossus Build 237.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	2010-12-12 RSB	Adapted from the corresponding
#				Colossus 249 file.
#		2011-05-03 JL	Replaced with newer version from Artemis072.
#				Point to moved Oct2Bin.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-07-17 RSB	I don't believe that Colossus237 is actually
#				correct yet, since I get diff errors when
#				building it, so the diff step errors are
#				ignored.
#		2016-08-14 RSB	All of the afore-mentioned diff errors were
#				SBANK discrepancies (i.e., a well-known 
#				problem in which yaYUL's assumptions about
#				superbank settings don't always agree 100%
#				with those of YUL or GAP, and thus have to
#				be fixed manually in the AGC source code).
#				They have now all been fixed in the source,
#				and therefore diff errors are no longer 
#				ignored.
# 		2016-10-04 JL	Change to use Makefile.inc.

BASENAME=Colossus237
EXTRA_YAYUL_ARGS=

${BASENAME}.binsource: ${BASENAME}.binsource2.txt
	../Tools/listing2binsource ${VERBOSE} $^ $@

include ../Makefile.inc
