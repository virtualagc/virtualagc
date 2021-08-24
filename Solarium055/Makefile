# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Solarium build 055.
#		(The source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 6
# Contact:	Ron Burkey <info@sandroid.org>.
# Mod history:	
#		2009-07-25 RSB	Created, based on Artemis072 version.
#		2011-05-03 JL	Updated.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-08-24 RSB	Added --block1 switch to yaYUL command line.
#		2016-08-24 RSB	Added target for corediff.txt.
#		2016-08-24 RSB	... and other stuff related to that too.
#		2016-10-04 JL	Change to use Makefile.inc.
#		2016-10-21 RSB	Hadn't accounted for the need for a --block1
#				arg for oct2bin.
#		2017-01-30 MAS	Changed to += for extra args.

BASENAME=Solarium055
EXTRA_YAYUL_ARGS+=--block1 --honeywell
OCT2BIN_ARGS+="--block1"
include ../Makefile.inc
