# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Luminary 130, the initial program released
#		for the Apollo 13 Lunar Module.
# Contact:	Ron Burkey <info@sandroid.org>.
# History:	05/06/03 RSB.	Began.
#		11/02/03 RSB.	Added the "install" and "Luminary131.bin" targets.
#		05/06/04 RSB	Installs Luminary131.bin.
#		05/09/04 RSB	Added the MAIN_PROGRAM #define to CheckDec.
#		05/14/04 RSB	Added PREFIX.
#		07/16/04 RSB	Added webb2burkey-rope
#		08/14/04 RSB	Put the yaYUL/Luminary131 regression test back in.
#		09/05/04 RSB	yaYUL no longer needs --force.
#		04/30/05 RSB	Added CFLAGS.
#		07/28/05 RSB	Added symtab.
#		03/06/09 RSB	Added 'all-archs' and associated stuff.
#		2009-07-04 RSB	Added --html switch.
#		2011-05-03 JL	Moved oct2bin, checkdec, bdiffhead, webb2burkey-rope to Tools directory. 
#				Changed to simpler Makefile based on Artemis072.
#		2012-09-16 JL	Updated to match tools dir changes.
#		2016-10-04 JL	Change to use Makefile.inc.
#		2018-09-04 MAS	Created for Luminary 130.

BASENAME=Luminary130

EXTRA_TARGETS=diffLuminary130sums

include ../Makefile.inc

.PHONY: diffLuminary130sums
diffLuminary130sums:
	../Tools/check_buggers.py Luminary130.bin Luminary130.buggers
