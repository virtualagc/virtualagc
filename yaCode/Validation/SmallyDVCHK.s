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

# Filename:	SmallyDVCHK.s
# Purpose:	This is code written from the flowchart on p. 43 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 43 of Smally
		
		CA	MAXP
		INCR	A
		TS	L
		TCF	DVCERROR		
		
		INCR	ERRSUB		# 51
		CA	MAXN
		AD	NEGONE
		TS	SKEEP2
		TCF	DVCERROR
		
		INCR	ERRSUB		# 52
		CA	ONE
		TS	TEMPI
		CA	O20000
		TS	L
		CA	NEGZERO
		EXTEND
		DV	TEMPI
		CCS	L
		TCF	DVCERROR
		TCF	+3
		TCF	DVCERROR
		TCF	DVCERROR
		
		INCR	ERRSUB		# 53
		CA	NEGONE
		TS	TEMPI
		CA	O-20000
		TS	L
		CA	ZEROES
		EXTEND
		DV	TEMPI
		AD	O-20000
		EXTEND
		BZF	+2
		TCF	DVCERROR
		CCS	L
		TCF	DVCERROR
		TCF	DVCERROR
		TCF	DVCERROR
		
		# Smally says in the following to divide +17777+37777 by -20000.
		# This is inconsistent with the sign of the remainder he seems
		# to imply.  I assume he means -17777-37777 / +20000.
		CA	O-20000
		TS	TEMPI
		CA	O20000
		TS	TEMPJ
		CA	MAXN
		TS	L
		CA	O-17777
		EXTEND
		DV	TEMPJ
		
		INCR	ERRSUB		# 54
		XCH	L
		EXTEND
		DV	TEMPJ
		AD	MAXP
		EXTEND
		BZF	+2
		TCF	DVCERROR
		CA	L
		AD	O17777
		EXTEND
		BZF	+2
		TCF	DVCERROR
		
		INCR	ERRSUB		# 55
		CA	MAXP
		TS	L
		CA	O-17777
		EXTEND
		DV	TEMPJ
		AD	MAXP-3
		EXTEND
		BZF	+2
		TCF	DVCERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DVCERROR

		# Note that Q still contains +3 from prior tests, and that SKEEP1
		# should still contain -1 (Smally says +1).		
		CA	MAXN-1
		TS	TEMPK
		ZL
		CA	MAXP-1
		EXTEND
		DV	TEMPK
		#QXCH	L
		
		INCR	ERRSUB		# 56
		AD	MAXP
		EXTEND
		BZF	+2
		TCF	DVCERROR
		CA	L
		AD	MAXP-1
		EXTEND
		BZF	+2
		TCF	DVCERROR
		
		INCR	ERRSUB		# ERRSUB = 57
		EXTEND
		QXCH	SKEEP1
		CA	Q
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DVCERROR
		CA	SKEEP1
		AD	NEGTHREE
		EXTEND
		BZF	+2
		TCF	DVCERROR
		
		TCF	+2
DVCERROR	TC	ERRORDSP

