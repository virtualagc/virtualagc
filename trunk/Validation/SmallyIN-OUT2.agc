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

# Filename:	SmallyIN-OUT2.agc
# Purpose:	This is code written from the flowchart on p. 50 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 50 of Smally
		
		CA	NEGTHREE
		TS	L
		CA	MAXP-1
		
		INCR	ERRSUB		
		EXTEND
		ROR	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	IO2ERROR
		
		CA	MAXP-1
		
		INCR	ERRSUB
		EXTEND
		WOR	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	IO2ERROR
		CA	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	IO2ERROR
		
		TCF	+2
IO2ERROR	TC	ERRORDSP

