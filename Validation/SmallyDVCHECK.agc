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

# Filename:	SmallyDVCHECK.agc
# Purpose:	This is code written from the flowchart on p. 62-64 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 62 of Smally.
		CA	O-3777
		TS	SKEEP4
		INCR	SKEEP4
		CA	O20000
		TS	SKEEP1
		CA	O-20000
		TS	SKEEP2
		CA	MAXN			# -37777
		TS	L
		CA	O17777
		
		INCR	ERRSUB
		CA	O20000
		TS	TEMPI
		CA	MAXN			# -37777
		TS	L
		CA	O17777
		EXTEND
		DV	TEMPI
		TS	SKEEP7
		CA	L
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	O-20000
		TS	TEMPI
		CA	MAXN
		TS	L
		CA	O17777
		EXTEND
		DV	TEMPI
		AD	SKEEP7
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CA	L
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	O20000
		TS	TEMPI
		CA	MAXP
		TS	L
		CA	O-17777
		EXTEND
		DV	TEMPI
		TS	SKEEP6
		AD	SKEEP7
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	O-20000
		TS	TEMPI
		CA	MAXP
		TS	L
		CA	O-17777
		EXTEND
		DV	TEMPI
		AD	SKEEP6
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DVERROR
		CA	O37774
		AD	SKEEP6
		EXTEND
		BZF	+2
		TCF	DVERROR
		
		INCR	ERRSUB
		# P. 63 of Smally.
		CA	O20000
		TS	TEMPI
		CA	MAXP			# 37777
		TS	L
		CA	O17777
		EXTEND
		DV	TEMPI
		AD	MAXN			# -37777
		EXTEND
		BZF	+2
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	O37776
		TS	TEMPI
		ZL
		CA	O37776
		EXTEND
		DV	TEMPI
		AD	MAXN			# -37777
		EXTEND
		BZF	+2
		TCF	DVERROR
		CA	L
		AD	O-37776
		EXTEND
		BZF	+2
		TCF	DVERROR

		# P. 64 of Smally
		CA	ZEROES
		TS	SKEEP1
		CA	NEGZERO
		TS	SKEEP2
		
		INCR	ERRSUB
		CA	ZEROES
		TS	TEMPI
		TS	L
		EXTEND
		DV	TEMPI
		TS	SKEEP7
		CCS	L
		TCF	DVERROR
		TCF	+3
		NOOP
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	NEGZERO
		TS	TEMPI
		ZL
		EXTEND
		DV	TEMPI
		TS	SKEEP6
		AD	SKEEP7
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CA	L
		
		INCR	ERRSUB
		CA	ZEROES
		TS	TEMPI
		CA	NEGZERO
		TS	L
		CA	ZEROES
		EXTEND
		DV	TEMPI
		AD	SKEEP7
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CCS	L			# Smally says -0, but I think +0.
		TCF	DVERROR
		TCF	+3
		TCF	DVERROR
		TCF	DVERROR
		
		INCR	ERRSUB
		CA	NEGZERO
		TS	TEMPI
		TS	L
		CA	ZEROES
		EXTEND
		DV	TEMPI
		AD	SKEEP6
		CCS	A
		NOOP
		NOOP
		TCF	DVERROR
		CCS	L
		NOOP
		NOOP
		TCF	DVERROR
		CA	MAXP			# 37777
		AD	SKEEP6
		EXTEND
		BZF	+2
		TCF	DVERROR

		# All done.
		TCF	DVDONE
DVERROR		TC	ERRORDSP
DVDONE

