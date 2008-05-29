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

# Filename:	SmallyDXCHDIM.s
# Purpose:	This is code written from the flowchart on p. 39 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 39 of Smally
		
		CA	MAXP		# 37777
		AD	TWO
		
		INCR	ERRSUB		# ERRSUB = 31
		TS	SKEEP1		# Smally says SKEEP2, but must be SKEEP1.
		TCF	DDERROR
		
		CA	NEGONE
		TS	SKEEP2
		CA	MAXN		# 40000
		TS	L
		CA	MAXP		# 37777
		
		INCR	ERRSUB		# ERRSUB = 32
		DXCH	SKEEP1
		AD	NEGONE
		EXTEND
		BZF 	+2
		TCF	DDERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DDERROR
		
		EXTEND
		DIM	SKEEP1
		EXTEND
		DIM	SKEEP2
		
		INCR	ERRSUB		# ERRSUB = 33
		CA	MAXP-1		# 37776
		COM
		AD	SKEEP1
		EXTEND
		BZF	+2
		TCF	DDERROR
		CA	MAXN-1		# 40001
		COM
		AD	SKEEP2
		EXTEND
		BZF	+2
		TCF	DDERROR
		
		INCR	ERRSUB		# ERRSUB = 34
		CA	ONE
		EXTEND
		DIM	A
		EXTEND
		DIM	A
		# Note:  The reason we're looking for -0 here instead of +0 is
		# that 1 - 1 = -0.
		CCS	A
		TCF	DDERROR
		TCF	DDERROR
		TCF	DDERROR
		
		INCR	ERRSUB		# ERRSUB = 35
		CA	ZEROES
		EXTEND
		DIM	A
		CCS	A
		TCF	DDERROR
		TCF	+3
		TCF	DDERROR
		TCF	DDERROR
		ZL
		EXTEND
		DIM	L
		CCS	L
		TCF	DDERROR
		TCF	+3
		TCF	DDERROR
		TCF	DDERROR
		EXTEND
		ZQ
		EXTEND
		DIM	Q
		CCS	Q
		TCF	DDERROR
		TCF	+3
		TCF	DDERROR
		TCF	DDERROR
		
		TCF	+2
DDERROR		TC	ERRORDSP
		CA	THREE		# Some downstream tests will expect Q==3.
		TS	Q
		
