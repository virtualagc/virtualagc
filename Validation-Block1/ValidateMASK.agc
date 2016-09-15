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

# Filename:	ValidateMASK.agc
# Purpose:	This is the part of the Validation program that validates
#		just the MASK instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# Just check a few values.
		INCR	ERRSUB		# 1
		CA	MASKL1
		MASK	MASKL2
		COM
		AD	ANDL1L2
		EXTEND
		BZF	MASK1
		TCF	VMSERROR
MASK1

		INCR	ERRSUB		# 2
		CA	MASKL1
		MASK	MASKR2
		COM
		AD	ANDL1R2
		EXTEND
		BZF	MASK2
		TCF	VMSERROR
MASK2

		INCR	ERRSUB		# 3
		CA	MASKR1
		MASK	MASKL2
		COM
		AD	ANDR1L2
		EXTEND
		BZF	MASK3
		TCF	VMSERROR
MASK3

		INCR	ERRSUB		# 4
		CA	MASKR1
		MASK	MASKR2
		COM
		AD	ANDR1R2
		EXTEND
		BZF	MASK4
		TCF	VMSERROR
MASK4

		TCF	+2
VMSERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
