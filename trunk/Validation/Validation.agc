# Copyright 2004 Ronald S. Burkey <info@sandroid.org>
#  
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Filename:	Validation.agc
# Purpose:	This is a program which attempts to provide a validation
#		suite --- "suite" being, perhaps, too grandiose a term ---
#		for the instructions of the yaAGC CPU.  I've written this
#		directly from E-2052 (Savage & Drake).
# Mod history:	07/03/04 RSB.	Began.
#		07/07/04 RSB.	Added ValidateSmally.agc.
#		07/10/04 RSB.	Added ERRSUB.
#		07/23/04 RSB	Added a few seconds of delay at the start
#				of the program.
#		08/12/04 RSB	... and removed it again, since yaAGC has
#				been fixed not to need it.  The last time
#				I checked, Julian's sim would still need\
#				it, but that was a month or so ago.

# This program is probably not a bad introduction on how to write an AGC
# program that interacts with the DSKY, though it doesn't use any interrupts.  
# What it does is pretty simple:
#
#	1.  Clears the DSKY, and then writes 00 to MODE of the DSKY.
#	2.  Perform tests.  Upon finding an error:
#	    a)	Writes a non-zero error code to MODE of the DSKY.
#	    b)  Turns on the OPR ERR lamp.
#	    c)  Waits for the PRO key to be pressed.
#	    d)	Turns off the OPR ERR lamp.
#	    e)	Proceeds with further tests.
#	3.  When all done, writes 77 to MODE of the DSKY.
#
# To keep this file from becoming too big and ponderous, most of the 
# code is split out into include-files.

#-------------------------------------------------------------------------
		
		SETLOC	4000 
		
		# An interrupt-vector table will go here when (if) I become
		# interested in validating the interrupt behavior, but for
		# now I'm just interested in how the instructions perform,
		# so the program simply starts here.
		
		# We start by testing a few random items that pop into my
		# mind, and then proceed to test the instructions, to the
		# extent feasible.
		
		# Initialization.
		INHINT
		CA	ZEROES		# zero out A
		TS	ERRNUM		# and the error-code
		TS	ERRSUB
		
# The following has been removed because the problem in yaAGC that it worked
# around has been fixed.
#		# A few seconds delay.  Not needed by the test, but helpful
#		# (given the wimpy socket mechanism I used to connect the
#		# simulated DSKY and AGC) to allow time for the DSKY and
#		# AGC to connect.
#		CA	THREE
#INITLOOP	TS	TEMPI
#		CA	MAXP
#		CCS	A
#		TCF	-1
#		CA	TEMPI
#		CCS	A
#		TCF	INITLOOP
		
		TC	ERRORDSP	# display it on the DSKY.

# Just a little test of ERRORDSP ...		
#LOOP		INCR	ERRNUM
#		TC	ERRORDSP
#		TCF	LOOP

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 1:  what is in the Z register?  Should be the 
		# next address after the 'CA' instruction, which I've 
		# cunningly placed in the WHERE1 constant.
		INCR	ERRNUM
		CA	Z		# fetch Z.
DEST1		TS	L
		CA	WHERE1
		EXTEND
		SU	L
		EXTEND
		BZF	TEST1OK
		TC	ERRORDSP	# Error!	
TEST1OK

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 2:  check of the editing registers.
		# I've swiped this from the Luminary AGC self-check.
CYCLSHFT	INCR	ERRNUM
		CA	CONC+S1		# 25252
		TS	CYR		# C(CYR) = 12525
		TS	CYL		# C(CYL) = 52524
		TS	SR		# C(SR) = 12525
		TS	EDOP		# C(EDOP) = 00125
		AD	CYR		# 37777		C(CYR) = 45252
		AD	CYL		# 00-12524	C(CYL) = 25251
		AD	SR		# 00-25251	C(SR) = 05252
		AD	EDOP		# 00-25376	C(EDOP) = +0
		AD	CONC+S2		# C(CONC+S2) = 52400
		TC	-1CHK
		AD	CYR		# 45252
		AD	CYL		# 72523
		AD	SR		# 77775
		AD	EDOP		# 77775
		AD	S+1		# 77776
		TC	-1CHK

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 3:  check of TC.  
		INCR	ERRNUM
		# ... add the code for this later ...
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 4:  check of CCS.  
$ValidateCCS.agc		

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 5:  check of TCF.
		INCR	ERRNUM
		# ... add this later ...
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Tests 6-10 (octal):  check of DAS.  
$ValidateDAS.agc		
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 11:  check of LXCH.
$ValidateLXCH.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 12:  check of INCR. 
$ValidateINCR.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 13:  check of ADS.
$ValidateADS.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 14:  check of CA
$ValidateCA.agc
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 15:  check of CS
$ValidateCS.agc
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 16:  check of TS
$ValidateTS.agc
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 17:  check of INDEX
$ValidateINDEX.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 20:  check of RELINT
		INCR	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 21:  check of INHINT
		INCR	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 22:  check of EXTEND
		INCR	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 23:  check of RESUME
		INCR	ERRNUM
		# ... later ...

		TCF	BANK3
		SETLOC	6000
BANK3

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 24:  check of DXCH
$ValidateDXCH.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 25:  check of XCH
$ValidateXCH.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 26:  check of AD
$ValidateAD.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 27:  check of MASK
$ValidateMASK.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 30:  check of READ, WRITE, etc.
$ValidateIO.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 31:  check of DV
$ValidateDV.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 32:  check of BZF
$ValidateBZF.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 33:  check of MSU
$ValidateMSU.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 34:  check of QXCH
$ValidateQXCH.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 35:  check of AUG
$ValidateAUG.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 36:  check of DIM
$ValidateDIM.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 37:  check of DCA
$ValidateDCA.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 40:  check of DCS
$ValidateDCS.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 41:  check of SU
$ValidateSU.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 42:  check of BZMF
$ValidateBZMF.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 43:  check of MP
$ValidateMP.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 44:  check of XXALQ, XLQ
$ValidateX.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 45:  check of RETURN
		INCR	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 46:  check of NOOP
$ValidateNOOP.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 47:  check of DDOUBL
$ValidateDDOUBL.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 50:  check of ZL, ZQ
$ValidateZX.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 51:  check of COM
$ValidateCOM.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 52:  check of OVSK
$ValidateOVSK.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 53:  check of TCAA
$ValidateTCAA.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 54:  check of DOUBLE
$ValidateDOUBLE.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 55:  check of DCOM
$ValidateDCOM.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 56:  check of SQUARE
$ValidateSQUARE.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 57:  check of DTCB
$ValidateDTCB.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 60:  check of DTCF
$ValidateDTCF.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 61-65:  Test written from the flowcharts in the
		# Appendix of E-2065 (Smally's "Block II AGC Self-Check
		# and Show-Banksum).
$ValidateSmally.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Tests are all done.  We display 77 on the DSKY
		# to indicate this.
		CA	MAXERR
		TS	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		TC	ERRORDSP
DONE		TCF	DONE

#-------------------------------------------------------------------------
# Various useful things like utility functions and variable allocations.		

$Errordsp.agc
$Utilities.agc		
$VariablesAndConstants.agc



