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

# Filename:	SmallyMPNMBRS.s
# Purpose:	This is code written from the flowchart on p. 58-61 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 58 of Smally.
		INCR	ERRSUB
		CA	MAXP		# 37777
MPLOOP1		TS	SKEEP2
		CA	MAXP		# 37777
		EXTEND
		MP	SKEEP2
		AD	L
		AD	MAXN		# 40000
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	SKEEP2
		AD	NEGONE
		EXTEND
		BZF	+2
		TC	MPLOOP1
		
		INCR	ERRSUB
		# P. 59 of Smally.
		CA	MAXP		# 37777
MPLOOP2		TS	SKEEP2
		CA	NEGONE		# 37777
		EXTEND
		MP	SKEEP2
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	L
		AD	SKEEP2
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	SKEEP2
		AD	NEGONE
		EXTEND
		BZF	+2
		TC	MPLOOP2
		
		INCR	ERRSUB
		# P. 60 of Smally
		CA	MAXP		# 37777
MPLOOP3		TS	SKEEP1
		CA	SKEEP1
		EXTEND
		MP	MAXP		# 37777
		AD	L
		AD	MAXN		# 40000
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	SKEEP1
		AD	NEGONE
		EXTEND
		BZF	+2
		TC	MPLOOP3
		
		INCR	ERRSUB
		# P. 61 of Smally
		CA	MAXP		# 37777
MPLOOP4		TS	SKEEP1
		CA	SKEEP1
		EXTEND
		MP	NEGONE
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	L
		AD	SKEEP1
		CCS	A
		NOOP
		NOOP
		TCF	MPERROR
		CA	SKEEP1
		AD	NEGONE
		EXTEND
		BZF	+2
		TC	MPLOOP4
		
		# All done.
		TCF	MPDONE
MPERROR		TC	ERRORDSP
MPDONE

