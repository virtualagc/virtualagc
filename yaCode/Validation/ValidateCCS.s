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

# Filename:	ValidateCCS.s
# Purpose:	This is the part of the Validation program that validates
#		just the CCS instruction.
# Mod history:	07/04/04 RSB.	Began.
		
		# We check using values that are
		# +-37777, +-1, and +-0, from both the accumulator and the
		# L register.
		INCR	ERRNUM
		
		# First, 37777 from accumulator.
		INCR	ERRSUB			# 1
		CA	MAXP
		CCS	A
		TCF	CCSCHK1
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
CCSCHK1		INCR	ERRSUB			# 2
		TS	L
		CA	MAXP-1
		EXTEND
		SU	L
		EXTEND
		BZF	CCSOK1
		TCF	ERROR4
CCSOK1
		# Next, 0 and 1 from accumulator.
		INCR	ERRSUB			# 3
		CA	ZEROES
		INCR	A
		CCS	A
		TCF	CCSCHK2
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
CCSCHK2		INCR	ERRSUB			# 4
		EXTEND
		BZF	CCSOK2
		TCF	ERROR4
CCSOK2
		# Next, -37777 from accumulator.
		INCR	ERRSUB			# 5
		CA	MAXP
		COM
		CCS	A
		TCF	ERROR4
		TCF	ERROR4
		TCF	CCSCHK3
		TCF	ERROR4
CCSCHK3		INCR	ERRSUB			# 6
		TS	L
		CA	MAXP-1
		EXTEND
		SU	L
		EXTEND
		BZF	CCSOK3
		TCF	ERROR4
CCSOK3
		# Next, -0 and -1 from accumulator.
		INCR	ERRSUB			# 7
		CA	ZEROES
		INCR	A
		COM
		TS	L
		CCS	L
		TCF	ERROR4
		TCF	ERROR4
		TCF	CCSCHK4
		TCF	ERROR4
CCSCHK4		INCR	ERRSUB			# 10
		COM
		CCS	A
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
		EXTEND
		BZF	CCSOK4
CCSOK4
		# Next, 37777 from L.
		INCR	ERRSUB			# 11
		CA	MAXP
		TS	L
		CCS	L
		TCF	CCSCHK5
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
CCSCHK5		INCR	ERRSUB			# 12
		TS	TEMPI
		CA	MAXP-1
		EXTEND
		SU	TEMPI
		EXTEND
		BZF	CCSOK5
		TCF	ERROR4
CCSOK5		INCR	ERRSUB			# 13
		CA	MAXP
		EXTEND
		SU	L
		EXTEND
		BZF	CCSOK5A
		TCF	ERROR4
CCSOK5A
		# Next, 0 and 1 from L.
		INCR	ERRSUB			# 14
		CA	ZEROES
		INCR	A
		TS	L
		CCS	L
		TCF	CCSCHK6
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
CCSCHK6		INCR	ERRSUB			# 15
		TS	L
		CCS	L
		TCF	ERROR4
		TCF	CCSOK6
		TCF	ERROR4
		TCF	ERROR4
CCSOK6
		# Next, -37777 from L.
		INCR	ERRSUB			# 16
		CA	MAXP
		COM
		TS	L
		CCS	L
		TCF	ERROR4
		TCF	ERROR4
		TCF	CCSCHK7
		TCF	ERROR4
CCSCHK7		INCR	ERRSUB			# 17
		TS	TEMPI
		CA	MAXP-1
		EXTEND
		SU	TEMPI
		EXTEND
		BZF	CCSOK7A
		TCF	ERROR4
CCSOK7A
		# Next, -0 and -1 from L.
		INCR	ERRSUB			# 20
		CA	ZEROES
		INCR	A
		COM
		TS	L
		CCS	L
		TCF	ERROR4
		TCF	ERROR4
		TCF	CCSCHK8
		TCF	ERROR4
CCSCHK8		INCR	ERRSUB			# 21
		COM
		TS	L
		CCS	L
		TCF	ERROR4
		TCF	ERROR4
		TCF	ERROR4
		TCF	CCSOK8A
CCSOK8A
		# All done.		
		TCF	DONE4
ERROR4		TC	ERRORDSP
DONE4		CA	ZEROES
		TS	ERRSUB
		

