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

# Filename:	SmallyRESTORE1.agc
# Purpose:	This is code written from the flowchart on p. 35 of
#		E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#		08/08/04 RSB.	Finished.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 

		# P. 35 of Smally
		
		# Realize that to put 177 into SR with TS, we must actually
		# use 377 since the value will be shifted.  (I'm unable to
		# find a way to insert a value into an editing register 
		# without performing editing.)
		CA	O377
		TS	SR
		
		INCR	ERRSUB		# 15
		# Smally's flowchart is a bit confusing about what happens
		# at this step.  But it looks as though we execute a 
		# bunch of instructions (like CCS) that re-edit the 
		# registers, without bothering to use the results, and 
		# finally fetch the value with MASK, which does not.
		CCS	SR
		NOOP
		NOOP
		NOOP
		NOOP
		CS	SR
		AD	SR
		EXTEND
		MSU	SR
		EXTEND
		SU	SR
		CA	SR
		MASK	SR
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	R1ERROR

		INCR	ERRSUB		# 16
		EXTEND
		MP	SR
		EXTEND
		DV	SR
		CA	SR
		AD	NEGONE
		EXTEND
		BZF	+2
		TCF	R1ERROR		
		
		TCF	+2
R1ERROR		TC	ERRORDSP

