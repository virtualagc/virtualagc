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

# Filename:	ValidateINCR.s
# Purpose:	This is the part of the validation suite which tests the
#		INCR instruction.
# Mod history:	07/05/04 RSB.	Began.
#		07/08/04 RSB.	Overflow now inhibits BZF rather than being
#				ignored by it.


		INCR	ERRNUM
		
		# Accumulator
		INCR	ERRSUB		# 1
		CA	NEGONE
		INCR	A
		EXTEND
		BZF	INCROK1
		TCF	VINERROR
INCROK1		INCR	ERRSUB		# 2
		OVSK
		TCF	INCROK2
		TCF	VINERROR
INCROK2		INCR	ERRSUB		# 3
		INCR	A
		OVSK
		TCF	INCROK3
		TCF	VINERROR
INCROK3		INCR	ERRSUB		# 4
		TS	L
		CA	ONE
		EXTEND
		SU	L
		EXTEND
		BZF	INCROK4
		TCF	VINERROR
INCROK4		INCR	ERRSUB		# 5
		CA	MAXP-1
		INCR	A
		OVSK
		TCF	INCROK5
		TCF	VINERROR
INCROK5		INCR	ERRSUB		# 6
		INCR	A
		EXTEND
		BZF	VINERROR
		INCR	ERRSUB		# 7
		OVSK			# We expect there to BE overflow.
		TCF	VINERROR
		
		# TEMPI
		INCR	ERRSUB		# 10 octal
		CA	NEGONE
		TS	TEMPI
		INCR	TEMPI
		CA	TEMPI
		EXTEND
		BZF	INCROK7
		TCF	VINERROR
INCROK7		INCR	ERRSUB		# 11
		INCR	TEMPI
		CA	ONE
		EXTEND
		SU	L
		EXTEND
		BZF	INCROK8
		TCF	VINERROR
INCROK8		INCR	ERRSUB		# 12
		CA	MAXP-1
		TS	TEMPI
		INCR	TEMPI
		INCR	TEMPI
		CA	TEMPI
		EXTEND
		BZF	INCROK9
		TCF	VINERROR
INCROK9		

		TCF	+2
VINERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
