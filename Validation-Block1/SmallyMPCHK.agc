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

# Filename:	SmallyMPCHK.agc
# Purpose:	This is code written from the flowchart on p. 42 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 42 of Smally
		
		INCR	ERRSUB			# 43
		CA	ONE
		EXTEND
		AUG	A			# A == +2
		AD	NEGTWO
		EXTEND
		BZF	+2
		TCF	MPCERROR
		
		CA	TWO
		EXTEND
		MP	MAXP
		
		INCR	ERRSUB			# 44
		AD	L			# A == 37777
		AD	MAXN			# -37777
		EXTEND
		BZF	+2
		TCF	MPCERROR
		CA	MAXP			# 37777
		EXTEND
		MP	NEGTWO
		
		INCR	ERRSUB			# 45
		ADS	L			# A == -37777
		AD	MAXP			# 37777
		EXTEND
		BZF	+2
		TCF	MPCERROR
		CA	MAXN			# -37777
		
		INCR	ERRSUB			# 46
		EXTEND
		MP	TWO
		TS	SKEEP6			# -1
		AD	ONE
		EXTEND
		BZF	+2
		TCF	MPCERROR
		EXTEND
		AUG	SKEEP6			# SKEEP6==-2
		
		INCR	ERRSUB			# 47
		CA	MAXN			# 40000
		EXTEND
		MP	SKEEP6
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	MPCERROR
		CA	L
		AD	MAXN-1			# -37776
		EXTEND
		BZF	+2
		TCF	MPCERROR
		
		INCR	ERRSUB			# 50 octal
		CA	ONE			# Smally says -1.
		ADS	SKEEP6
		AD	ONE
		EXTEND
		BZF	+2
		TCF	MPCERROR
		CA	SKEEP6
		AD	ONE
		EXTEND
		BZF	+2
		TCF	MPCERROR
		
		TCF +2
MPCERROR	TC	ERRORDSP

