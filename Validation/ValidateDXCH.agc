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

# Filename:	ValidateDXCH.agc
# Purpose:	This is the part of the Validation program that validates
#		just the DXCH instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# Well, exchange something.
		CA	ONE
		TS	TEMPJ
		CA	NEGONE
		TS	TEMPK
		CA	FIVE
		TS	L
		CA	TEN
		DXCH	TEMPJ
		# Compare to see if right.
		AD	NEGONE
		EXTEND
		BZF	DXCH1
		TC	ERRORDSP
DXCH1		CA	L
		AD	ONE
		EXTEND
		BZF	DXCH2
		TC	ERRORDSP
DXCH2		CA	FIVE
		COM
		AD	TEMPK
		EXTEND
		BZF	DXCH3
		TC	ERRORDSP
DXCH3		CA	TEN
		COM
		AD	TEMPJ
		EXTEND
		BZF	DXCH4
		TC	ERRORDSP
DXCH4
		
		# Now do something similar, but with initial overflow.
		CA	ONE
		TS	TEMPJ
		CA	NEGONE
		TS	TEMPK
		CA	FIVE
		TS	L
		CA	MAXP
		AD	TEN			# Causes overflow.
		DXCH	TEMPJ
		OVSK
		TCF	DXCH5
		TC	ERRORDSP
DXCH5
		# Compare to see if right.
		AD	NEGONE
		EXTEND
		BZF	DXCH6
		TC	ERRORDSP
DXCH6		CA	L
		AD	ONE
		EXTEND
		BZF	DXCH7
		TC	ERRORDSP
DXCH7		CA	FIVE
		COM
		AD	TEMPK
		EXTEND
		BZF	DXCH8
		TC	ERRORDSP
DXCH8		CA	TEN
		COM
		INCR	A
		AD	TEMPJ
		EXTEND
		BZF	DXCH9
		TC	ERRORDSP
DXCH9

		# There shouldn't be any sensible reason for "DXCH A",
		# but let's check it anyhow.
		CA	TEN
		TS	L
		CA	FIVE
		DXCH	A
		COM
		AD	FIVE
		EXTEND
		BZF	DXCH10
		TC	ERRORDSP
DXCH10		CA	L
		COM
		AD	TEN
		EXTEND
		BZF	DXCH11
		TC	ERRORDSP
DXCH11
		
		# Finally, check "DXCH L".  (This wacky, undocumented
		# case sends A to L, L to Q, and Q to A.  Before you 
		# say "of course!" note that the opposite direction
		# is equally sensible.)
		CA	TEN
		TS	Q
		CA	FIVE
		TS	L
		CA	ONE
		DXCH	L
		COM
		AD	TEN
		EXTEND
		BZF	DXCH12
		TC	ERRORDSP
DXCH12		CA	Q
		COM
		AD	FIVE
		EXTEND
		BZF	DXCH13
		TC	ERRORDSP
DXCH13		CA	L
		AD	NEGONE
		EXTEND
		BZF	DXCH14
		TC	ERRORDSP
DXCH14
		
