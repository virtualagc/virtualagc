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

# Filename:	ValidateAD.agc
# Purpose:	This is the part of the Validation program that validates
#		just the AD instruction.
# Mod history:	07/05/04 RSB.	Began.
		
		INCR	ERRNUM
		
		# First, just add a bunch of stuff and compare.
		# We start with -3*12345 (octal) and add 12345
		# until we reach 3*12345.
		CA	SMALNUM
		TS	TEMPK		# TEMPK is the addend.
		CA	SMALRNUM
		COM
		TS	TEMPJ		# TEMPJ is the running sum.
		CA	FIVE
		INCR	ERRSUB
ADLOOP		TS	TEMPI		# TEMPI is loop counter.
		CA	TEMPJ
		AD	TEMPK
		OVSK			# Should be no overflow.
		TCF	AD1
		TCF	MADERROR	# ERRSUB==1
AD1		TS	TEMPJ
		CCS	TEMPI
		TCF	ADLOOP
		# Check if correct.
		INCR	ERRSUB
		CA	TEMPJ
		COM
		AD	SMALRNUM
		EXTEND
		BZF	AD2
		TCF	MADERROR	# ERRSUB==2
AD2

		# Now check +- overflow.
		INCR	ERRSUB
		CA	MAXP
		AD	ONE
		OVSK
		TCF	MADERROR	# ERRSUB==3
		INCR	ERRSUB
		TS	L
		NOOP
		CA	L
		TS	TEMPI
		NOOP
		CCS	L
		TCF	+4
		TCF	MADERROR	# ERRSUB==4
		TCF	MADERROR
		TCF	MADERROR
		INCR	ERRSUB
		CCS	TEMPI
		TCF	MADERROR	# ERRSUB==5
		TCF	+3
		TCF	MADERROR
		TCF	MADERROR
AD3		INCR	ERRSUB
		CA	MAXN
		AD	NEGONE
		OVSK
		TCF	MADERROR	# ERRSUB==6
		INCR	ERRSUB
		TS	L
		NOOP
		CA	L
		TS	TEMPI
		NOOP
		CCS	L
		NOOP
		TCF	MADERROR
		TCF	+2
		TCF	MADERROR	# ERRSUB==7
		CCS	TEMPI
		NOOP
		NOOP
		TCF	MADERROR	# ERRSUB==7
		
		# We don't need to check "AD A", as this is checked
		# for the DOUBLE instruction.
		
		TCF	+2
MADERROR	TC	ERRORDSP
		CA	ZEROES
		TS	ERRSUB
		
