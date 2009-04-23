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

# Filename:	ValidateXCH.s
# Purpose:	This is the part of the Validation program that validates
#		just the XCH instruction.
# Mod history:	07/05/04 RSB.	Began.
#		07/13/04 RSB.	Added ERRSUB.
		
		INCR	ERRNUM
		
		# Swap some stuff.
		INCR	ERRSUB		# 1
		CA	TEN
		TS	TEMPI
		CA	FIVE
		XCH	TEMPI
		COM
		AD	TEN
		EXTEND
		BZF	XCH1
		TCF	VXCERROR
XCH1		INCR	ERRSUB		# 2
		CA	TEMPI
		COM
		AD	FIVE
		EXTEND
		BZF	XCH2
		TCF	VXCERROR
XCH2

		# Same, but with some overflow correction.
		INCR	ERRSUB		# 3
		CA	TEN
		TS	TEMPI
		CA	MAXP
		AD	FIVE
		XCH	TEMPI
		OVSK
		TCF	XCH3A
		TCF	VXCERROR
XCH3A		INCR	ERRSUB		# 4
		COM
		AD	TEN
		EXTEND
		BZF	XCH3
		TCF	VXCERROR
XCH3		INCR	ERRSUB		# 5
		CA	TEMPI
		INCR	A
		COM
		AD	FIVE
		EXTEND
		BZF	XCH4
		TCF	VXCERROR
XCH4

		# Check for "XCH A", as if it's of any interest.
		INCR	ERRSUB		# 6
		CA	MAXP
		AD	TEN
		XCH	A
		OVSK
		TCF	VXCERROR
XCH5		INCR	ERRSUB		# 7
		INCR	A
		TS	L
		NOOP
		CA	L
		COM
		AD	TEN
		EXTEND
		BZF	VXCERROR	# L contains overflow.
		CA	L
		TS	TEMPI
		NOOP
		CA	TEN
		COM
		AD	TEMPI
		EXTEND
		BZF	+2		# ... but TEMP doesn't.
		TCF	VXCERROR
		
		
XCH6

		TCF	+2
VXCERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
