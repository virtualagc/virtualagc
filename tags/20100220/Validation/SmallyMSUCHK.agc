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

# Filename:	SmallyMSUCHK.agc
# Purpose:	This is code written from the flowchart on p. 44 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/10/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 44 of Smally
		
		INCR	ERRSUB		# 60
		CA	NEGZERO
		TS	L
		EXTEND
		MSU	L
		CCS	A
		TCF	MSCERROR
		TCF	+3
		TCF	MSCERROR
		TCF	MSCERROR
		
		INCR	ERRSUB		# 61
		EXTEND
		MSU	L
		CCS	A
		TCF	MSCERROR
		TCF	+3
		TCF	MSCERROR
		TCF	MSCERROR		
		
		INCR	ERRSUB		# 62
		CA	MAXN
		TS	L
		CA	MAXP
		EXTEND
		MSU	L
		AD	ONE
		EXTEND
		BZF	+2
		TCF	MSCERROR
		
		TCF	+2
MSCERROR	TC	ERRORDSP

