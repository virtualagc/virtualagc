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

# Filename:	SmallyCOUNTCHK.agc
# Purpose:	This is code written from the flowchart on p. 52 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		INCR	ERRSUB
		
		# P. 52 of Smally
		
		CA	MAXP
		TS	SKEEP6
		CA	MAXN
		TS	SKEEP7
		
CCKLOOP1	CA	SKEEP6
		TS	Q
		
CCKLOOP2	CA	Q
		TS	L
		
		CCS	A
		TCF	+4
		TCF	CCK+0
		TCF	CCKNEG
		TCF	CCKERROR	# Don't know where this is supposed to go
		
		EXTEND			# Smally says AD L, but that makes no sense.
		SU	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	CCKERROR
		
		CA	SKEEP6
		COM
		TS	Q
		TCF	CCKLOOP2
		
CCKNEG		TS	SKEEP6

		AD	SKEEP7
		AD	ONE
		EXTEND
		BZF	+2
		TCF	CCKERROR
		
		INCR	SKEEP7
		TCF	CCKLOOP1
		
CCK+0		CA	SKEEP6
		AD	SKEEP7
		CCS	A
		TCF	CCKERROR
		TCF	CCKERROR
		TCF	CCKERROR
	
		TCF	+2
CCKERROR	TC	ERRORDSP

	
