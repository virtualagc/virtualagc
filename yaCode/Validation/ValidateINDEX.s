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

# Filename:	ValidateINDEX.s
# Purpose:	This is the part of the Validation program that validates
#		just the INDEX instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# First do the "basic" (non-Extracode) INDEX instruction.
		# Just load values from the table and check them.
		TCF	AFTERTAB
		DEC	-5
		DEC	-9
TABLE		DEC	-10
		DEC	-1
		DEC	1
AFTERTAB
		CA	ONE
		AD	ONE
		COM
		TS	TEMPI		# TEMPI is -2.
		
		INCR	ERRSUB		# 1
		INDEX	TEMPI
		CA	TABLE
		AD	FIVE
		EXTEND
		BZF	INDEX1
		TCF	VNDERROR
INDEX1		
		INCR	ERRSUB		# 2
		INCR	TEMPI
		INDEX	TEMPI
		CA	TABLE
		AD	NINE
		EXTEND
		BZF	INDEX2
		TCF	VNDERROR
INDEX2
		INCR	ERRSUB		# 3
		INCR	TEMPI
		INDEX	TEMPI
		CA	TABLE
		AD	TEN
		EXTEND
		BZF	INDEX3
		TCF	VNDERROR
INDEX3
		INCR	ERRSUB		# 4
		INCR	TEMPI
		INDEX	TEMPI
		CA	TABLE
		AD	ONE
		EXTEND
		BZF	INDEX4
		TCF	VNDERROR
INDEX4
		INCR	ERRSUB		# 5
		INCR	TEMPI
		INDEX	TEMPI
		CA	TABLE
		AD	NEGONE
		EXTEND
		BZF	INDEX5
		TCF	VNDERROR
INDEX5

		# The test of the Extracode version is done the same way,
		# except that we use DCA rather than CA to load the values.
		# (We discard the extra word loaded into L without checking.
		CA	ONE
		AD	ONE
		COM
		TS	TEMPI		# TEMPI is -2.
		
		INCR	ERRSUB		# 6
		EXTEND
		INDEX	TEMPI
		DCA	TABLE
		AD	FIVE
		EXTEND
		BZF	INDEX6
		TCF	VNDERROR
INDEX6		
		INCR	ERRSUB		# 7
		INCR	TEMPI
		EXTEND
		INDEX	TEMPI
		DCA	TABLE
		AD	NINE
		EXTEND
		BZF	INDEX7
		TCF	VNDERROR
INDEX7
		INCR	ERRSUB		# 10 octal
		INCR	TEMPI
		EXTEND
		INDEX	TEMPI
		DCA	TABLE
		AD	TEN
		EXTEND
		BZF	INDEX8
		TCF	VNDERROR
INDEX8
		INCR	ERRSUB		# 11
		INCR	TEMPI
		EXTEND
		INDEX	TEMPI
		DCA	TABLE
		AD	ONE
		EXTEND
		BZF	INDEX9
		TCF	VNDERROR
INDEX9
		INCR	ERRSUB		# 12
		INCR	TEMPI
		EXTEND
		INDEX	TEMPI
		DCA	TABLE
		AD	NEGONE
		EXTEND
		BZF	INDEX10
		TCF	VNDERROR
INDEX10

		# We also need to check that if the following instructions
		# are created by indexing, that they are treated as real,
		# rather than as the special codes RELINT, INHINT, EXTEND, 
		# and RESUME:
		#	TC	3
		#	TC	4
		#	TC	6
		#	INDEX	17
		# However, we DON'T actually check that now, since that's
		# not the way yaAGC is implemented currently.
		
		TCF	+2
VNDERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
