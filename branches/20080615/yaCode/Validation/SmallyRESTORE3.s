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

# Filename:	SmallyRESTORE3.s
# Purpose:	This is code written from the flowchart on p. 37 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 37 of Smally.  It APPEARS to me that various 
		# statements about the contents of A are wrong here,
		# probably because of the OCR'ing which has been done
		# on Smally's doc before posting to the internet.
		
		TCF	+3
4SKEEP1		CS	A
4SKEEP2		TC	Q
		CA	4SKEEP1
		TS	SKEEP1
		CA	4SKEEP2
		TS	SKEEP2
		
		CA	ONE
		TC	SKEEP1		# Should be -1 on return.
		
		INCR	ERRSUB		# 21
		AD	ONE
		EXTEND
		BZF	+2
		TCF	R3ERROR
		
		CA	ZEROES
		TC	SKEEP1		# Should be -0 on return.
		
		INCR	ERRSUB		# 22
		CCS	A
		TCF	R3ERROR
		TCF	R3ERROR
		TCF	R3ERROR
		
		TCF	+2
R3ERROR		TC	ERRORDSP

		
