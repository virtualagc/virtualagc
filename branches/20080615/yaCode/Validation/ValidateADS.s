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

# Filename:	ValidateADS.s
# Purpose:	This is the part of the validation suite which tests the
#		ADS instruction.
# Mod history:	07/05/04 RSB.	Began.
#		07/08/04 RSB.	+ and - overflow now block BZF.

		INCR	ERRNUM		
		
		INCR	ERRSUB		# 1
		# First, start with -3*12345, and then add 12345 until
		# we reach 3*12345, and check.
		CA	SMALRNUM	# 3 * 12345 (octal)
		COM			# -3 * 12345.
		TS	TEMPJ		# TEMPJ is running sum.
		CA	FIVE
ADSLOOP1	TS	TEMPI		# TEMPI is loop counter.
		CA	SMALNUM
		ADS	TEMPJ
		OVSK			# Overflow?
		TCF	ADS1
		TCF	VDSERROR
ADS1		EXTEND			# A and TEMPJ match?
		SU	TEMPJ
		EXTEND
		BZF	ADS2
		TCF	VDSERROR
ADS2		CCS	TEMPI
		TCF	ADSLOOP1
		INCR	ERRSUB		# 2
		INCR	ERRSUB		# 3
		# Now compare.
		CA	SMALRNUM
		EXTEND
		SU	TEMPJ
		EXTEND
		BZF	ADS3
		TCF	VDSERROR
ADS3
		
		INCR	ERRSUB		# 4
		# Same, but in the opposite direction.
		CA	SMALRNUM	# 3 * 12345 (octal)
		TS	TEMPJ		# TEMPJ is running sum.
		CA	FIVE
ADSLOOP2	TS	TEMPI		# TEMPI is loop counter.
		CA	SMALNUM
		COM
		ADS	TEMPJ
		OVSK			# Overflow?
		TCF	ADS4
		TCF	VDSERROR
ADS4		EXTEND			# A and TEMPJ match?
		SU	TEMPJ
		EXTEND
		BZF	ADS5
		TCF	VDSERROR
ADS5		CCS	TEMPI
		TCF	ADSLOOP2
		INCR	ERRSUB		# 5
		INCR	ERRSUB		# 6
		# Now compare.
		CA	SMALRNUM
		COM
		EXTEND
		SU	TEMPJ
		EXTEND
		BZF	ADS6
		TCF	VDSERROR
ADS6
		
		INCR	ERRSUB		# 7
		# The steps above didn't generate overflow.  We want to 
		# check out overflow now.
		# + Overflow
		CA	ONE
		TS	L
		CA	MAXP-1
		AD	L
		OVSK
		TCF	ADS7
		TCF	VDSERROR
ADS7		INCR	ERRSUB		# 10 octal
		AD	L
		OVSK
		TCF	VDSERROR
		INCR	ERRSUB		# 11 OCTAL
		EXTEND
		BZF	VDSERROR
ADS8
		INCR	ERRSUB		# 12
		# - Overflow
		CA	NEGONE
		TS	L
		CA	MAXN-1
		AD	L
		OVSK
		TCF	ADS9
		TCF	VDSERROR
ADS9		INCR	ERRSUB		# 13
		AD	L
		OVSK
		TCF	VDSERROR
		INCR	ERRSUB		# 14
		EXTEND
		BZF	VDSERROR
ADS10

		INCR	ERRSUB		# 15
		# Check that X + -X = -0.  This isn't spec'd, but I've seen
		# a comment somewhere that it is true.
		CA	SMALNUM
		COM	
		TS	L
		CA	SMALNUM
		AD	L
		CCS	A
		TCF	VDSERROR
		TCF	VDSERROR
		TCF	VDSERROR

		TCF	+2
VDSERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
