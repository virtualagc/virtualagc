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

# Filename:	SmallyMASKCHK.s
# Purpose:	This is code written from the flowchart on p. 45 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/10/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 45 of Smally
		
		INCR	ERRSUB		# 63
		CA	O77770
		MASK	SEVEN
		EXTEND
		BZF	+2
		TCF	MSKERROR
		
		INCR	ERRSUB		# 64
		CA	SEVEN
		MASK	ONE
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	MSKERROR
				
		CA	ONE
		TS	L
		TS	SKEEP1
		
		INDEX	A
		AD	SZERO
		
		INCR	ERRSUB		# 65
		EXTEND
		SU	L
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	MSKERROR
		
		EXTEND
		INDEX	L
		SU	SZERO
		
		INCR	ERRSUB		# 66
		AD	ONE
		EXTEND
		BZF	+2
		TCF	MSKERROR
		
		TCF	+2
MSKERROR	TC	ERRORDSP

