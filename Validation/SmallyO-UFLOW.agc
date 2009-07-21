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

# Filename:	SmallyO-UFLOW.agc
# Purpose:	This is code written from the flowchart on p. 53 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 53 of Smally
		
		INCR	ERRSUB

		CA	MAXN
		TS	SKEEP5
		CA	MAXP
		
OUFLOOP1	INHINT

		AD	MAXP
		AD	ONE
		TS	Q
		NOOP
		
OUFLOOP2	CCS	Q
		TCF	+4
		TCF	OUFERROR
		TCF	OUFNZERO
		TCF	OUFERROR
		
		TS	SKEEP4
		TCF	OUFDONE
		
		CA	SKEEP4
		AD	SKEEP5
		AD	ONE
		EXTEND
		BZF	+2
		TCF	OUFERROR
		
		CA	SKEEP5
		AD	MAXN
		AD	NEGONE
		TS	Q
		NOOP
		TCF	OUFLOOP2
		
OUFNZERO	TS	SKEEP3
		TCF	OUFERROR
		
		CA	SKEEP3
		AD	SKEEP5
		AD	ONE
		EXTEND
		BZF	+2
		TCF	OUFERROR
		
		RELINT
		
		CA	SKEEP4
		EXTEND
		DIM	SKEEP5
		TCF	OUFLOOP1
		
OUFDONE		CCS	SKEEP5			# Smally says that SKEEP5 is +1
		TCF	OUFERROR		# here, but that has to be wrong
		TCF	OUFERROR		# since SKEEP5 is always negative.
		TCF	OUFERROR		# Must be -1.
		
		CA	SKEEP4
		AD	MAXN
		EXTEND
		BZF	+2
		TCF	OUFERROR
		
		RELINT

		TCF	+2
OUFERROR	TC	ERRORDSP

