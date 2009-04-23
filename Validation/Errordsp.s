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

# Filename:	Errordsp.s
# Purpose:	This is an error-display function for the validation
#		suite.
# Mod history:	07/04/04 RSB.	Began.
#		07/10/04 RSB.	Added display of the error sub-code.
#		07/17/04 RSB.	PRO key signal level inverted.
		
#-------------------------------------------------------------------------
# Display the error code.  What this does is to clear the entire display,
# except for MODE (which contains the error code), and then lights the 
# OPR ERR lamp and waits for the ENTR key to be hit.  Then it unlights
# OPR ERR and continues.

ERRORDSP	
		# Save return address in TEMPK
		EXTEND
		QXCH	TEMPK
		
		# Blank out all DSKY fields except MODE.  This means
		# writing out 50000, 44000, ..., 04000.
		CA	O50000	
		TS	L	# L is the value we want to write to ch 10.
		CA	TEN	# A is the loop counter.
ERRORLOO	XCH	L
		TC	IODELAY
		EXTEND
		WRITE	CH10
		AD	O-4000
		XCH	L
		CCS	A
		TCF	ERRORLOO
		
		# Output ERRNUM in MODE. 
		CA	O54000
		TS	TEMPI
		CA	ERRNUM
		TS	TEMPJ
		TC	IODELAY
		TC	DIGPAIR
		
		# Output ERRSUB in NOUN.
		CA	O44000
		TS	TEMPI
		CA	ERRSUB
		TS	TEMPJ
		TC	IODELAY
		TC	DIGPAIR
		
		# Turn on the OPR ERR lamp.
		CA	BIT7
		TC	IODELAY
		EXTEND
		WRITE	CH11
		
		# Wait for PRO key to be pressed.  Please recall that
		# the PRO key is a low-polarity signal:  0 when pressed,
		# 1 when released.
PRONWAIT	EXTEND
		READ	CH32
		MASK	BIT14
		CCS	A
		TCF	PRONWAIT
PROPRESS		
		
		# Turn off the OPR ERR lamp.
		CA	ZEROES
		TC	IODELAY
		EXTEND
		WRITE	CH11		
		
		# Wait for PRO key to be released.
PROFWAIT	EXTEND
		READ	CH32
		MASK	BIT14
		CCS	A
		TCF	+2
		TCF	PROFWAIT

		# Restore the return address.  (Could actually just
		# "TC TEMPK" here.)
		EXTEND
		QXCH	TEMPK
		RETURN

#-------------------------------------------------------------------------
# Delay a little while.  This is a workaround for some characteristics
# (as of 07/17/04, anyhow) of Webb's AGC-DSKY interaction.  No registers
# are affected, except that any overflow in the accumulator will be lost.

IODELAYT	DEC	500

IODELAY		TS	TEMPJ		# Save accumulator.
		NOOP
		CA	IODELAYT
		CCS	A
		TCF	-1
		CA	TEMPJ		# Restore accumulator.
		RETURN
			
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
		CA	TEMPJ
		TS	CYR
		CA	CYR
		CA	CYR
		CA	CYR
		MASK	SEVEN
		# Convert to a pattern for output.
		INDEX	A
		CA	DSP0
		TS	CYL
		CA	CYL
		CA	CYL
		CA	CYL
		CA	CYL
		CA	CYL
		AD	TEMPI
		TS	TEMPI
		# Now do the same for the second octal digit, except that
		# all the shifting isn't neeeded.
		CA	TEMPJ
		MASK	SEVEN
		INDEX	A
		CA	DSP0
		AD	TEMPI
		TS	TEMPI
		# Output it!
		EXTEND
		WRITE	CH10
		
		RETURN
		
