# Copyright 2016 Ronald S. Burkey <info@sandroid.org>
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
#		for the instructions of the yaAGC CPU.  I've written it
#		somewhat from E-2052 (Savage & Drake), but since it relates
#		to Block 1 rather than Block 2, the correspondence may not
#		be tremendously close.
# Mod history:	2016-09-15 RSB	Began adapting from the Block 2 validation
#				file of the same name.

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
		
		SETLOC	2030 
		
		# We start by testing a few random items that pop into my
		# mind, and then proceed to test the instructions, to the
		# extent feasible.
		
		# Initialization.
		INHINT
		CAF	ZERO		# zero out A
		TS	ERRNUM		# and the error-code
		TS	ERRSUB
		CAF	WHERE2
		TS	BANK
		TC	ERRORDSP	# display it on the DSKY.

# Just a little test of ERRORDSP ... don't normally do it, except when
# debugging ERRORDSP itself.
		TC	BYPASSLP	
LOOP		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		TC	ERRORDSP
		TC	LOOP
BYPASSLP

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 1:  what is in the Z register?  Should be the 
		# next address after the 'CA' instruction, which I've 
		# cunningly placed in the WHERE1 constant.
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		CAF	ZERO		# fetch Z.
		AD	Z
DEST1		EXTEND
		SU	WHERE1
		CCS	A
		TC	ERRORDSP	# Error!
		TC	TEST1OK
		TC	ERRORDSP
TEST1OK

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 2:  check of the editing registers.
		# I've swiped this from the Luminary AGC self-check, and 
		# modified it to account for LP and SL in place of EDOP.
CYCLSHFT	XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		XCH	CONC+S1		# 25252
		TS	CYR		# C(CYR) = 12525
		TS	CYL		# C(CYL) = 52524
		TS	SR		# C(SR) = 12525
		TS	SL		# C(SL) = 52524
		AD	ONE
		TS	LP		# C(LP) = 72525
		AD	CYR		# 40000
		AD	CYL		# 152524
		AD	SR		# 00-25251
		AD	SL
		AD	LP		
		AD	CONC+S2		# C(CONC+S2) = 52400
		TC	-1CHK
		AD	CYR		# 45252
		AD	CYL		# 72523
		AD	SR		# 77775
		AD	SL		# 77775
		AD	S+1		# 77776
		TC	-1CHK

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 3:  check of TC.  
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... add the code for this later ...
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 4:  check of CCS.  
#$ValidateCCS.agc		

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 15:  check of CS
#$ValidateCS.agc
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 16:  check of TS
#$ValidateTS.agc
		
		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 17:  check of INDEX
#$ValidateINDEX.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 20:  check of RELINT
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 21:  check of INHINT
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 22:  check of EXTEND
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 23:  check of RESUME
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... later ...
		
		TC	BANK3

# Some constants that need to be stored in fixed-fixed.
WHERE2		CADR	ERRORDSP
		
		SETLOC	6000
BANK3

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 25:  check of XCH
#$ValidateXCH.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 26:  check of AD
#$ValidateAD.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 27:  check of MASK
#$ValidateMASK.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 31:  check of DV
#$ValidateDV.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 41:  check of SU
#$ValidateSU.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 43:  check of MP
#$ValidateMP.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 45:  check of RETURN
		XCH	ERRNUM
		AD	ONE
		XCH	ERRNUM
		# ... later ...

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 46:  check of NOOP
#$ValidateNOOP.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 51:  check of COM
#$ValidateCOM.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Test 54:  check of DOUBLE
#$ValidateDOUBLE.agc

		# Test 61-65:  Test written from the flowcharts in the
		# Appendix of E-2065 (Smally's "Block II AGC Self-Check
		# and Show-Banksum).
#$ValidateSmally.agc

		#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		# Tests are all done.  We display 77 on the DSKY
		# to indicate this.
		XCH	MAXERR
		TS	ERRNUM
		CAF	ZERO
		TS	ERRSUB
		TC	ERRORDSP
DONE		TC	DONE


#-------------------------------------------------------------------------
# Various useful things like utility functions and variable allocations.		

$Errordsp.agc
$Utilities.agc		
$VariablesAndConstants.agc

		SETLOC	5777
OPOVF		XCADR	0


