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

# Filename:	ValidateLXCH.agc
# Purpose:	This is the part of the Validation suite used for checking
#		the LXCH instruction.
# Mod history:	07/04/04 RSB.	Began.

		INCR	ERRNUM
		
		# First we'll swap L and TEMPI
		INCR	ERRSUB		# 1
		CA	ONE
		TS	TEMPI
		CA	NEGONE
		TS	L
		LXCH	TEMPI
		CA	TEMPI
		AD	ONE
		EXTEND
		BZF	LXCHOK1
		TCF	VLXERROR
LXCHOK1		INCR	ERRSUB		# 2
		CA	L
		AD	NEGONE
		EXTEND
		BZF	LXCHOK2
		TCF	VLXERROR
LXCHOK2
		# Now we'll swap A and L (without overflow)
		INCR	ERRSUB		# 3
		CA	NEGONE
		TS	L
		CA	ONE
		LXCH	A
		AD	ONE
		EXTEND
		BZF	LXCHOK3
		TCF	VLXERROR
LXCHOK3		INCR	ERRSUB		# 4
		CA	L
		AD	NEGONE
		EXTEND
		BZF	LXCHOK4
		TCF	VLXERROR
LXCHOK4
		# Now we'll swap A and L with + overflow.
		INCR	ERRSUB		# 5
		CA	NEGONE
		TS	L
		CA	MAXP
		AD	ONE
		OVSK
		TCF	VLXERROR
		INCR	ERRSUB		# 6
		OVSK
		TCF	VLXERROR
		INCR	ERRSUB		# 7
		LXCH	A
		AD	ONE
		EXTEND
		BZF	LXCHOK5
		TCF	VLXERROR
LXCHOK5		INCR	ERRSUB		# 10 octal
		CA	L
		EXTEND
		BZF	VLXERROR
LXCHOK6
		# Now we'll swap A and L with - overflow.
		INCR	ERRSUB		# 11
		CA	NEGONE
		TS	L
		CA	MAXN
		AD	NEGONE
		OVSK
		TCF	VLXERROR
		INCR	ERRSUB		# 12
		OVSK
		TCF	VLXERROR
		INCR	ERRSUB		# 13
		LXCH	A
		AD	ONE
		EXTEND
		BZF	LXCHOK7
		TCF	VLXERROR
LXCHOK7		INCR	ERRSUB		# 14
		CA	L
		EXTEND
		BZF	VLXERROR
LXCHOK8
		
		TCF	+2
VLXERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
				
