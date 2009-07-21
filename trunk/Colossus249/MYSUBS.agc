# Copyright:	Public domain.
# Filename:	MYSUBS.agc
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Reference:	Begins on p. 974 of 1701.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Mod history:	08/25/04 RSB.	Began transcribing.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  Notations on this
# document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
#
#	This AGC program shall also be referred to as
#				Colossus 1A
#
#	Prepared by
#			Massachussets Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to 1701.pdf) to info@sandroid.org.
#
# In some cases, where the source code for Luminary 131 overlaps that of 
# Colossus 249, this code is instead copied from the corresponding Luminary 131
# source file, and then is proofed to incorporate any changes.

# Page 974
		BANK	20
		SETLOC	MYSUBS
		BANK
		
		EBANK=	MPAC
SPCOS1		EQUALS	SPCOS
SPSIN1		EQUALS	SPSIN
SPCOS2		EQUALS	SPCOS
SPSIN2		EQUALS	SPSIN
		COUNT	21/DAPMS
		
# ONE AND ONE HALF PRECISION MULTIPLICATION ROUTINE

SMALLMP		TS	KMPTEMP		# A(X+Y)
		EXTEND
		MP	KMPAC +1
		TS	KMPAC +1	# AY
		CAF	ZERO
		XCH	KMPAC
		EXTEND
		MP	KMPTEMP		# AX
		DAS	KMPAC		# AX+AY
		TC	Q
		
# SUBROUTINE FOR DOUBLE PRECISION ADDITIONS OF ANGLES
# A AND L CONTAIN A DP(1S) ANGLE SCALED BY 180 DEGS TO BE ADDED TO KMPAC.
# RESULT IS PLACED IN KMPAC.  TIMING = 6 MCT (22 MCT ON OVERFLOW)

DPADD		DAS	KMPAC
		EXTEND
		BZF	TSK +1		# NO OVERFLOW
		CCS	KMPAC
		TCF	DPADD+		# + OVERFLOW
		TCF	+2
		TCF	DPADD-		# - OVERFLOW
		CCS	KMPAC +1
		TCF	DPADD2+		# UPPER = 0, LOWER +
		TCF	+2
		COM			# UPPER = 0, LOWER -
		AD	POSMAX		# LOWER = 0, A = 0
		TS	KMPAC +1	# CAN NOT OVERFLOW
		CA	POSMAX		# UPPER WAS = 0
TSK		TS	KMPAC
		TC	Q
		
DPADD+		AD	NEGMAX		# KMPAC GREATER THAN 0
		TCF	TSK

# Page 975
DPADD-		COM
		AD	POSMAX		# KMPAC LESS THAN 0
		TCF	TSK
		
DPADD2+		AD	NEGMAX		# CAN NOT OVERFLOW
		TS	KMPAC +1
		CA	NEGMAX		# UPPER WAS = 0
		TCF	TSK

# Page 976
# This page is empty ... woo-hoo!! -- RSB 2004

