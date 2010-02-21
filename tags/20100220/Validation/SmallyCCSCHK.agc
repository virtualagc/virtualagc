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

# Filename:	SmallyCCSCHK.agc
# Purpose:	This is code written from the flowchart on p. 33 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 33 of Smally.

		INCR	ERRSUB		# 2
		CA	NEGTHREE
		CCS	A
		TCF	CCSERROR
		TCF	CCSERROR
		TCF	+2
		TCF	CCSERROR
		
		INCR	ERRSUB		# 3
		CCS	A
		TCF	+4
		TCF	CCSERROR
		TCF	CCSERROR
		TCF	CCSERROR
		
		INCR	ERRSUB		# 4
		TS	SKEEP1
		CCS	SKEEP1
		TCF	+4
		TCF	CCSERROR
		TCF	CCSERROR
		TCF	CCSERROR
		
		INCR	ERRSUB		# 5
		CCS	A
		TCF	CCSERROR
		TCF	+3
		TCF	CCSERROR
		TCF	CCSERROR
		
		INCR	ERRSUB		# 6
		CS	A
		CCS	A
		TCF	CCSERROR
		TCF	CCSERROR
		TCF	CCSERROR
		
		INCR	ERRSUB		# 7
		CCS	A
		TCF	CCSERROR
		TCF	+3
		TCF	CCSERROR
		TCF	CCSERROR
		
		# The flowchart says here to 
		# "check read back into erasable
		# memory feature of CS instruction,"
		# whatever that may mean!
		
		TCF	CCSDONE		
CCSERROR	TC	ERRORDSP
CCSDONE		

		

