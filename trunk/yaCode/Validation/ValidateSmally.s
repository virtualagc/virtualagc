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

# Filename:	ValidateSmally.s
# Purpose:	This is the part of the Validation program, written to 
#		correspond as best I can to the flowcharts in the Appendix
#		of E-2065, which is a document titled "Block II AGC
#		Self-Check and Show-Banksum", by Edwin D. Smally.
# Mod history:	07/07/04 RSB.	Began.
#
# Similar code was apparently originally in Luminary and/or Colossus,
# but much of it was removed over the course of time to make more room.  
# I don't know what the original code was like, but the flowcharts still
# exist, so I've rewritten the code from the flowcharts. 
		
		EXTEND
		DCA	ASMGEN
		DTCF
ASMGEN		2FCADR	SMGEN
ASMGEN2		2FCADR	SMGEN2
ASMGEN3		2FCADR	SMGEN3
ASMMP		2FCADR	SMMP
ASMDV		2FCADR	SMDV
SMNEXT
				
		BANK	4
SMGEN				
		INCR	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		# ERRNUM==61
$SmallyTCTCF.s		# ERRSUB==1
$SmallyCCSCHK.s		# 2-7
$SmallyBZMFCHK.s	# 10-14
$SmallyRESTORE1.s	# 15-16
$SmallyRESTORE2.s	# 17-20
$SmallyRESTORE3.s	# 21-22
$SmallyBZFCHK.s		# 23-30
$SmallyDXCHDIM.s	# 31-35
$SmallyDASINCR.s	# 36-42
$SmallyMPCHK.s		# 43-50
$SmallyDVCHK.s		# 51-57
$SmallyMSUCHK.s		# 60-62
$SmallyMASKCHK.s	# 63-66
$SmallyD--SC.s		# 67-71
$SmallyD--LCHK.s	# 72-76
$SmallyRUPTCHK.s	# 77
		EXTEND
		DCA	ASMGEN2
		DTCF

		BANK	5
SMGEN2
		INCR	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		# ERRNUM==62
$SmallyIN-OUT1.s	# ERRSUB==1-3
$SmallyIN-OUT2.s	# 4-5
$SmallyIN-OUT3.s	# 6-10
$SmallyCOUNTCHK.s	# 11
$SmallyO-UFLOW.s	# 12
		EXTEND
		DCA	ASMGEN3
		DTCF

		BANK	6
SMGEN3
		INCR	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		# ERRNUM==63
$SmallyCNTRCHK.s	# ERRSUB==1
$SmallyCYCLSHFT.s	# 2-3
		EXTEND
		DCA	ASMMP
		DTCF

		BANK	7
SMMP
		INCR	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		# ERRNUM==64
$SmallyMPNMBRS.s	# ERRSUB=1-4
		EXTEND
		DCA	ASMDV
		DTCF

		BANK	10
SMDV
		INCR	ERRNUM
		CA	ZEROES
		TS	ERRSUB
		# ERRNUM==65
$SmallyDVCHECK.s	# ERRSUB=1-11
		TCF	SMNEXT
		
		
		SETLOC	SMNEXT

