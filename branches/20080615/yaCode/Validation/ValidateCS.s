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

# Filename:	ValidateCS.s
# Purpose:	This is the part of the Validation program that validates
#		just the CS instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# Now just load and check a few values.  
		
		INCR	ERRSUB		# 1
		# Start with MAXP.  Generate overflow too.
		CA	MAXP		# Generate overflow.
		INCR	A
		CS	MAXP		# Load and check overflow.
		OVSK
		TCF	CS1
		TCF	VCSERROR
CS1		INCR	ERRSUB		# 2
		TS	L		# Check that loaded value is right.
		CA	MAXN
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CS2
		TCF	VCSERROR
CS2

		INCR	ERRSUB		# 3
		# -MAXP.
		CS	MAXN
		TS	L		# Check that loaded value is right.
		CA	MAXP
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CS3
		TCF	VCSERROR
CS3

		INCR	ERRSUB		# 4
		# +1.
		CS	ONE
		TS	L		# Check that loaded value is right.
		CA	NEGONE
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CS4
		TCF	VCSERROR
CS4

		INCR	ERRSUB		# 5
		# -1.
		CS	NEGONE
		TS	L		# Check that loaded value is right.
		CA	ONE
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CS5
		TCF	VCSERROR
CS5
		
		INCR	ERRSUB		# 6
		# 0.
		CS	ZEROES
		CCS	A
		TCF	VCSERROR
		TCF	VCSERROR
		TCF	VCSERROR

		INCR	ERRSUB		# 7
		# -0.
		CS	NEGZERO
		CCS	A
		TCF	VCSERROR
		TCF	CS7
		TCF	VCSERROR
		TCF	VCSERROR
CS7

		TCF	+2
VCSERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		

