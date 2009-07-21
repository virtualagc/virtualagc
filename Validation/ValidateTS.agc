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

# Filename:	ValidateTS.agc
# Purpose:	This is the part of the Validation program that validates
#		just the TS instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# I think that the "normal" uses of TS have been 
		# adequately check by the previous tests, since data has
		# been saved and compared for correctness.  In other words,
		# we know that it correctly saves data.  That leaves
		# only weird cases like overflow behavior and +-0 to check.
		
		# +0.
		INCR	ERRSUB		# 1
		CA	ZEROES
		TS	L
		CCS	L
		TCF	VTSERROR
		TCF	TS1
		NOOP
		TCF	VTSERROR
TS1

		# -0.
		INCR	ERRSUB		# 2
		CA	NEGZERO
		TS	L
		CCS	L
		NOOP
		NOOP
		TCF	VTSERROR

		# +Overflow
		INCR	ERRSUB		# 3
		CA	MAXP
		AD	TEN
		TS	L		# Should be 9.
		TCF	VTSERROR	# No overflow.
		INCR	ERRSUB		# 4
		AD	NEGONE		# A should have been +1.
		EXTEND
		BZF	TS2
		TCF	VTSERROR
TS2		INCR	ERRSUB		# 5
		CA	NINE
		EXTEND
		SU	L
		EXTEND
		BZF	VTSERROR	# L contains overflow.
		CA	L
		TS	TEMPI
		NOOP
		CA	NINE
		EXTEND
		SU	TEMPI		# ... but TEMPI does not.
		EXTEND
		BZF	+2
		TCF	VTSERROR
		
TS3

		# -Overflow
		INCR	ERRSUB		# 6
		CA	TEN
		TS	L
		CA	MAXN
		EXTEND
		SU	L
		TS	L		# Should be -9.
		TCF	VTSERROR	# No overflow.
		INCR	ERRSUB		# 7
		AD	ONE		# A should have been -1.
		EXTEND
		BZF	TS4A
		TCF	VTSERROR
TS4A		INCR	ERRSUB		# 10 octal
		CA	NINE
		AD	L
		EXTEND
		BZF	VTSERROR	# L contains overflow.
		CA	L
		TS	TEMPI
		NOOP
		CA	NINE
		AD	TEMPI
		EXTEND
		BZF	+2		# ... but TEMPI does not.
		TCF	VTSERROR
		
TS4

		# No overflow
		INCR	ERRSUB		# 11
		CA	FIVE
		COM
		TS	L		# -5
		TCF	TS5A		# No overflow.
		TCF	VTSERROR	# Overflow.
TS5A		INCR	ERRSUB		# 12
		AD	FIVE		# A should have been -5.
		EXTEND
		BZF	TS5
		TCF	VTSERROR
TS5		INCR	ERRSUB		# 13
		CA	FIVE
		AD	L
		EXTEND
		BZF	TS6
		TCF	VTSERROR
TS6

		TCF	+2
VTSERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
