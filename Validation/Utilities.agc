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

# Filename:	Utilities.agc
# Purpose:	Useful functions for the validation suite.
# Mod history:	07/04/04 RSB.	Began.
	
#-------------------------------------------------------------------------
# A utility to check if the accumulator contains -1.  Swiped from
# Luminary AGC self-check.		
				
-1CHK		CCS	A
		TCF	ERRORDSP
		TCF	ERRORDSP
		CCS	A
		TCF	ERRORDSP
		TC	Q

