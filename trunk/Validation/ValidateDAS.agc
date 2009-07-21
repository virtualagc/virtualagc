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

# Filename:	ValidateDAS.agc
# Purpose:	This is the portion of the Validation program that attempts
#		to validate the DAS instruction
# Mod history:	07/04/04 RSB.	Began.

		# (Test 6.)  What we do here is just add 
		# various numbers and check the result, including some
		# boundary cases that generate +- overflow.
		INCR	ERRNUM
		
		EXTEND
		DCA	BIGRNUM		# Get 123454321 * 14 (octal).
		EXTEND
		DCOM			# 123454321 * -14.
		DXCH	TEMPJ		# Save at TEMPJ,TEMPK
		CA	TWNTHREE	# TEMPI is loop counter.
		
		# First check the normal case.
		# The idea here is that we start with -14*123454321, go to
		# -13*123454321, ..., -0, +1*123454321, ..., +14*123454321.
		# Then we compare the results.
		INCR	ERRSUB		# 1
DASLOOP		TS	TEMPI
		EXTEND			# Update the running sum.
		DCA	BIGNUM
		DAS	TEMPJ
		EXTEND			# Overflow?
		BZF	DASNOV1
		TCF	VDAERROR		
DASNOV1		CA	L		# L-reg 0?
		EXTEND
		BZF	DASNOV1A
		TCF	VDAERROR
DASNOV1A	CCS	TEMPI
		TCF	DASLOOP
		INCR	ERRSUB		# 2
		EXTEND			# Compare.
		DCA	BIGRNUM
		EXTEND
		SU	TEMPJ
		EXTEND
		BZF	DASOK1
		TCF	VDAERROR
DASOK1		INCR	ERRSUB		# 3
		CA	L
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK2
		TCF	VDAERROR
DASOK2
		CA	ZEROES
		TS	ERRSUB

		# (Test 7.) Now we check boundary cases where +- overflow are 
		# generated.  Also, we check that adding +-0 doesn't change
		# the result.
		INCR	ERRNUM
		INCR	ERRSUB		# 1
		# Add +-0 to next-to-highest DP integer.
		EXTEND
		DCA	DBMAXP-1	# Next-to-highest + DP.
		DXCH	TEMPJ		# Store in erasable.
		# ... first, +0.
		EXTEND			# Let's add +0 to it.
		DCA	DBZERO
		DAS	TEMPJ
		EXTEND			# Overflow?
		BZF	DASOK3
		TCF	VDAERROR
DASOK3		INCR	ERRSUB		# 2
		EXTEND
		DCA	DBMAXP-1	# Check if unchanged.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK4
		TCF	VDAERROR
DASOK4		INCR	ERRSUB		# 3
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK5
		TCF	VDAERROR
		# ... now, -0.
DASOK5		INCR	ERRSUB		# 4
		EXTEND			# Let's add -0 to it.
		DCA	DBMZERO
		DAS	TEMPJ
		EXTEND			# Overflow?
		BZF	DASOK6
		TCF	VDAERROR
DASOK6		INCR	ERRSUB		# 5
		EXTEND
		DCA	DBMAXP-1	# Check if unchanged.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK7
		TCF	VDAERROR
DASOK7		INCR	ERRSUB		# 6
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK8
		TCF	VDAERROR
DASOK8
		# Now add +1, and make sure no overflow.
		INCR	ERRSUB		# 7
		EXTEND			# Let's add +1 to it.
		DCA	DBONE
		DAS	TEMPJ
		EXTEND			# Overflow?
		BZF	DASOK9
		TCF	VDAERROR
DASOK9		INCR	ERRSUB		# 10 octal
		EXTEND
		DCA	DBMAXP		# Check result.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK10
		TCF	VDAERROR
DASOK10		INCR	ERRSUB		# 11 octal
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK11
		TCF	VDAERROR
DASOK11		
		# Now add +1 again, and make sure there is overflow and
		# there is wraparound to +0.
		INCR	ERRSUB		# 12
		EXTEND			# Let's add +1 to it.
		DCA	DBONE
		DAS	TEMPJ
		AD	NEGONE		# Positive overflow?
		EXTEND			# Overflow?
		BZF	DASOK12
		TCF	VDAERROR
DASOK12		INCR	ERRSUB		# 13
		EXTEND
		DCA	DBZERO		# Check result.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK13
		TCF	VDAERROR
DASOK13		INCR	ERRSUB		# 14
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK14
		TCF	VDAERROR
DASOK14
		# Same thing now, but with negative values.
		INCR	ERRSUB		# 15
		EXTEND
		DCA	DBMAXN-1
		DXCH	TEMPJ
		# Now add -1, and make sure no overflow.
		EXTEND			# Let's add -1 to it.
		DCA	DBMONE
		DAS	TEMPJ
		EXTEND			# Overflow?
		BZF	DASOK15
		TCF	VDAERROR
DASOK15		INCR	ERRSUB		# 16
		EXTEND
		DCA	DBMAXN		# Check result.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK16
		TCF	VDAERROR
DASOK16		INCR	ERRSUB		# 17
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK17
		TCF	VDAERROR
DASOK17		
		# Now add -1 again, and make sure there is pos. overflow and
		# there is wraparound to -0.
		INCR	ERRSUB		# 20 octal
		EXTEND			# Let's add -1 to it.
		DCA	DBMONE
		DAS	TEMPJ
		AD	ONE
		EXTEND			# Overflow?
		BZF	DASOK18
		TCF	VDAERROR
DASOK18		INCR	ERRSUB		# 21 octal
		EXTEND
		DCA	DBMZERO		# Check result.
		EXTEND			# MS word first.
		SU	TEMPJ
		EXTEND
		BZF	DASOK19
		TCF	VDAERROR
DASOK19		INCR	ERRSUB		# 22
		CA	L		# LS word.
		EXTEND
		SU	TEMPK
		EXTEND
		BZF	DASOK20
		TCF	VDAERROR
DASOK20

		CA	ZEROES
		TS	ERRSUB

		# (Test 8.) Now we check cases where the signs of the more-significant
		# and less-significant words disagree.
		INCR	ERRNUM
		
		# Check that X + -X = -0.  This isn't spec'd, but I've seen
		# a comment somewhere that it is true.
		INCR	ERRSUB		# 1
		EXTEND
		DCA	BIGNUM
		EXTEND
		DCOM
		DXCH	TEMPJ
		EXTEND
		DCA	BIGNUM
		DAS	TEMPJ
		CA	TEMPJ
		CCS	A
		TCF	VDAERROR
		TCF	VDAERROR
		TCF	VDAERROR
		INCR	ERRSUB		# 2
		CA	TEMPK
		CCS	A
		TCF	VDAERROR
		TCF	VDAERROR
		TCF	VDAERROR

		TCF	+3
TSTEIGHT	DEC	8		
VDAERROR	TC	ERRORDSP
		CA	TSTEIGHT
		TS	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		
