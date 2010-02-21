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

# Filename:	SmallyD--SC.agc
# Purpose:	This is code written from the flowchart on p. 46 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 46 of Smally.
		
		CA	NEGONE		# Smally says +2, but I think this is right.
		TS	L
		CA	ONE
		
		INCR	ERRSUB		# 67
		EXTEND
		DCS	A
		AD	ONE
		EXTEND
		BZF	+2
		TC	DSCERROR
		CA	ZEROES
		
		# The following assumes that c(Q)==3 from previous RETURNs.  In 
		# fact, it contains -1 from previous tests, as there have been 
		# no intervening returns.  So we'll fix that:
		TCF	+2
		RETURN
		TC	-1
		INCR	ERRSUB		# 70 octal
		DXCH	L
		AD	NEGTHREE
		EXTEND
		BZF	+2
		TCF	DSCERROR
		CCS	L
		TCF	DSCERROR
		TCF	+3
		TCF	DSCERROR
		TCF	DSCERROR
		CA	Q
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DSCERROR
		
		CA	NEGONE
		TS	Q
		CA	ONE
		
		INCR	ERRSUB		# 71
		EXTEND
		DCA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DSCERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DSCERROR
		CA	Q
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DSCERROR
		
		TCF	+2
DSCERROR	TC	ERRORDSP

