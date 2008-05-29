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

# Filename:	ValidateCA.s
# Purpose:	This is the part of the Validation program that validates
#		just the CA instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# Now just load and check a few values.  
		
		INCR	ERRSUB		# 1
		# Start with MAXP.  Generate overflow too.
		CA	MAXP		# Generate overflow.
		INCR	A
		CA	MAXP		# Load and check overflow.
		OVSK
		TCF	CA1
		TCF	VCAERROR
CA1		INCR	ERRSUB		# 2
		TS	L		# Check that loaded value is right.
		EXTEND			# Compute rather than load MAXP.
		SU	A
		AD	MAXP
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CA2
		TCF	VCAERROR
CA2

		INCR	ERRSUB		# 3
		# -MAXP.
		CA	MAXN
		TS	L		# Check that loaded value is right.
		EXTEND			# Compute rather than load MAXN.
		SU	A
		AD	MAXN
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CA3
		TCF	VCAERROR
CA3

		INCR	ERRSUB		# 4
		# +1.
		CA	ONE
		TS	L		# Check that loaded value is right.
		EXTEND			# Compute rather than load MAXN.
		SU	A
		AD	ONE
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CA4
		TCF	VCAERROR
CA4

		INCR	ERRSUB		# 5
		# -1.
		CA	NEGONE
		TS	L		# Check that loaded value is right.
		EXTEND			# Compute rather than load MAXN.
		SU	A
		AD	NEGONE
		EXTEND			# Compare.
		SU	L
		EXTEND
		BZF	CA5
		TCF	VCAERROR
CA5

		INCR	ERRSUB		# 6
		# 0.
		CA	ZEROES
		CCS	A
		TCF	VCAERROR
		TCF	CA6
		TCF	VCAERROR
		TCF	VCAERROR
CA6

		INCR	ERRSUB		# 7
		# -0.
		CA	NEGZERO
		CCS	A
		TCF	VCAERROR
		TCF	VCAERROR
		TCF	VCAERROR
		
		TCF	+2
VCAERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		

