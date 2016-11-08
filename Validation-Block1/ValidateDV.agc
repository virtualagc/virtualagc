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

# Filename:	ValidateDV.agc
# Purpose:	This is the part of the Validation program that validates
#		just the DV instruction.
# Mod history:	07/05/04 RSB.	Began.
# 		09/11/16 MAS.	Added eight checks for 0 divided by a number
		
		INCR	ERRNUM
		
		# Check some corner corner cases discovered by NASSP

		INCR	ERRSUB		#1
		CA	TWO
		TS	TEMPI
		CA	ZEROES		# Check +0+0 / +2 = +0, +0
		TS	L
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is +0
		TCF	DVERR
		TCF	DV1LCHK
		TCF	DVERR
		TCF	DVERR
DV1LCHK		CCS	L 		# Check that L is +0
		TCF	DVERR
		TCF	DV2
		TCF	DVERR
		TCF	DVERR

DV2		INCR	ERRSUB		#2
		CA	NEGZERO		# Check that -0+0 / +2 = +0, +0
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is +0
		TCF	DVERR
		TCF	DV2LCHK
		TCF	DVERR
		TCF	DVERR
DV2LCHK		CCS	L 		# Check that L is +0
		TCF	DVERR
		TCF	DV3
		TCF	DVERR
		TCF	DVERR

DV3		INCR	ERRSUB		#3
		CA	NEGZERO		# Check that +0-0 / +2 = -0, -0
		TS	L
		CA	ZEROES
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR
DV3LCHK		CCS	L 		# Check that L is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR

DV4		INCR	ERRSUB		#4
		CA	NEGZERO		# Check that -0-0 / +2 = -0, -0
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR
DV4LCHK		CCS	L 		# Check that L is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR

DV5		CA	NEGTWO
		TS	TEMPI
		INCR	ERRSUB		#5
		CA	ZEROES		# Check that +0+0 / -2 = -0, +0
		TS	L
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR
DV5LCHK		CCS	L 		# Check that L is +0
		TCF	DVERR
		TCF	DV6
		TCF	DVERR
		TCF	DVERR

DV6		INCR	ERRSUB		#6
		CA	NEGZERO		# Check that -0+0 / -2 = -0, +0
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR
DV6LCHK		CCS	L 		# Check that L is +0
		TCF	DVERR
		TCF	DV7
		TCF	DVERR
		TCF	DVERR

DV7		INCR	ERRSUB		#7
		CA	NEGZERO		# Check that +0-0 / -2 = +0, -0
		TS	L
		CA	ZEROES
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is +0
		TCF	DVERR
		TCF	DV7LCHK
		TCF	DVERR
		TCF	DVERR
DV7LCHK		CCS	L 		# Check that L is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR

DV8		INCR	ERRSUB		#8
		CA	NEGZERO		# Check that -0-0 / -2 = +0, -0
		EXTEND
		DV	TEMPI
		CCS	A		# Check that A is +0
		TCF	DVERR
		TCF	DV8LCHK
		TCF	DVERR
		TCF	DVERR
DV8LCHK		CCS	L 		# Check that L is -0
		TCF	DVERR
		TCF	DVERR
		TCF	DVERR

		TCF	+2
DVERR		TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB

