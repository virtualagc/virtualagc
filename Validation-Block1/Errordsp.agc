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

# Filename:	Errordsp.agc
# Purpose:	This is an error-display function for the Block 1 validation
#		suite.
# Mod history:	2016-09-15 RSB	Adapted from the Block 2 validation file of
#				the same name.
		
#-------------------------------------------------------------------------
# Display the error code.  What this does is to clear the entire display,
# except for MODE (which contains the error code), and then lights the 
# OPR ERR lamp and waits for the ENTR key to be hit.  Then it unlights
# OPR ERR and continues.

ERRORDSP	XCH	Q	# Save return address in TEMPK
		XCH	ERRORDSQ
		
		# Blank out all DSKY fields except MODE.  This means
		# writing out 50000, 44000, ..., 04000.
		CAF	O50000	
		TS	ERRORDSV	# ERRORDSV is the value we want to write to output.
		CAF	TEN		# A is the loop counter.
ERRORLOO	TC	IODELAY		# Delay, preserving A.
		XCH	ERRORDSV
		TS	OUT1
		AD	O-4000
		XCH	ERRORDSV
		CCS	A
		TC	ERRORLOO
		
		# Output ERRNUM in MODE. 
		CAF	O54000
		TS	TEMPI
		CAF	ZERO
		AD	ERRNUM
		TS	TEMPJ
		TC	IODELAY
		TC	DIGPAIR
		
		# Output ERRSUB in NOUN.
		CAF	O44000
		TS	TEMPI
		CAF	ZERO
		AD	ERRSUB
		TS	TEMPJ
		TC	IODELAY
		TC	DIGPAIR
		
		# Turn on the OPR ERR lamp.
		TC	IODELAY
		CAF	BIT5
		TS	OUT1
		
		# Wait for ENTER key to be pressed.
PRONWAIT	CAF	ZERO
		AD	IN0
		MASK	LOW6
		EXTEND
		SU	ENTERKEY
		CCS	A
		TC	PRONWAIT
		TC	PROPRESS
		TC	PRONWAIT
PROPRESS		
		
		# Turn off the OPR ERR lamp.
		TC	IODELAY
		CAF	ZERO
		TS	OUT1
		
		# Wait for ENTER key to be released.
PROFWAIT	CAF	ZERO
		AD	IN0
		MASK	LOW6
		CCS	A
		TC	PROFWAIT
		TC	ERRORDSQ	# RETURN
		TC	PROFWAIT
		TC	ERRORDSQ	# RETURN

#-------------------------------------------------------------------------
# Delay a little while.  No registers
# are affected, except that any overflow in the accumulator will be lost.

IODELAYT	DEC	500

IODELAY		XCH	IODELAYA	# Save accumulator.
		XCH	Q		# Save the return address.
		XCH	IODELAYQ
		NOOP
		CAF	IODELAYT
		CCS	A
		TC	-1
		XCH	IODELAYA	# Restore accumulator.
		TC	IODELAYQ	# return.
			
#-------------------------------------------------------------------------
# Display a two-digit octal code.  On entry, TEMPI should contain a 
# code corresponding to the digit pair, as follows:
#	54000	MODE
#	50000	VERB
#	44000	NOUN
#	40000	Not used/1st digit of R1
#	34000	2nd/3rd digit of R1
#	30000	4th/5th digit of R1
#	24000	1st/2nd digit of R2
#	20000	3rd/4th digit of R2
#	14000	5th digit of R2/1st digit of R3
#	10000	2nd/3rd digit of R3
#	04000	4th/5th digit of R3
# On entry also, TEMPJ contains the number we want displayed.

DIGPAIR		# Shift the error code down by 3 places, so as to get 
		# the first octal digit.
		XCH	Q	# Save the return address.
		XCH	TEMPK
		CAF	ZERO
		AD	TEMPJ
		TS	CYR
		CS	CYR
		CS	CYR
		CAF	ZERO
		AD	CYR
		MASK	SEVEN
		# Convert to a pattern for output.
		INDEX	A
		CAF	DSP0
		TS	CYL
		CS	CYL
		CS	CYL
		CS	CYL
		CS	CYL
		CAF	ZERO
		AD	CYL
		AD	TEMPI
		TS	TEMPI
		# Now do the same for the second octal digit, except that
		# all the shifting isn't needed.
		XCH	TEMPJ
		MASK	SEVEN
		INDEX	A
		CAF	DSP0
		AD	TEMPI
		TS	TEMPI
		# Output it!
		TS	OUT0
		
		TC	TEMPK
		
