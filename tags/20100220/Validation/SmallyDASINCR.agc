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

# Filename:	SmallyDASINCR.agc
# Purpose:	This is code written from the flowchart on p. 41 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#		07/09/04 RSB.	Finished.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 41 of Smally
		
		CA	NEGONE
		TS	L
		CA	TWO
		
		INCR	ERRSUB		# 36
		DDOUBL
		AD	NEGFOUR
		EXTEND
		BZF	+2
		TCF	DIERROR
		CA	L
		AD	TWO
		EXTEND
		BZF	+2
		TCF	DIERROR
		
		CA	MAXP		# 37777.  Smally incorrectly says 3777.
		TS	SKEEP3
		CA	MAXN		# 40000
		TS	SKEEP4
		CA	NEGTWO
		TS	L
		CA	THREE
		
		INCR	ERRSUB		# 37
		# Smally incorrectly says here that c(A)==+0 and c(L)==+1.
		# This is actually reversed.
		DAS	SKEEP3
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		CCS	L
		TCF	DIERROR
		TCF	+3
		TCF	DIERROR
		TCF	DIERROR
		CA	SKEEP3
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		CA	SKEEP4
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		
		INCR	ERRSUB		# 40 octal
		INCR	SKEEP4
		CCS	SKEEP4
		TCF	DIERROR
		TCF	DIERROR
		TCF	DIERROR
		
		INCR	ERRSUB		# 41
		CA	ZEROES
		TS	L
		INCR	L
		INCR	A
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		CA	L
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		
		CA	MAXN		# 40000
		TS	SKEEP1
		CA	MAXP		# 37777
		TS	SKEEP2
		CA	THREE
		TS	L
		CA	NEGTHREE
		
		INCR	ERRSUB		# 42
		# Here Smally says that c(SKEEP1)==+1 and c(SKEEP2)==-2
		# after the addition.  I think both signs are the opposite of
		# what they should be.
		DAS	SKEEP1
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		CA	SKEEP1
		AD	ONE
		EXTEND
		BZF	+2
		TCF	DIERROR
		CA	SKEEP2
		AD	NEGTWO
		EXTEND
		BZF	+2
		TCF	DIERROR

		TCF	+2
DIERROR		TC	ERRORDSP

