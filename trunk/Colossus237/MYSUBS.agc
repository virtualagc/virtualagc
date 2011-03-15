### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:	MYSUBS.agc
# Purpose:      Part of the source code for Colossus build 237.
#               This is for the Command Module's (CM) Apollo Guidance
#               Computer (AGC), we believe for Apollo 8.
# Assembler:    yaYUL
# Contact:      Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:      www.ibiblio.org/apollo/index.html
# Page scans:   www.ibiblio.org/apollo/ScansForConversion/Colossus237/
# Mod history:  2011-03-15 JL	Adapted from corresponding Colossus 249 file.

## Page 967
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
		AD	POSMAX		# LOWER = 0, A=0
		TS	KMPAC +1	# CAN NOT OVERFLOW
		CA	POSMAX		# UPPER WAS = 0
TSK		TS	KMPAC
		TC	Q

DPADD+		AD	NEGMAX		# KMPAC GREATER THAN 0
		TCF	TSK

## Page 968
DPADD-		COM
		AD	POSMAX		# KMPAC LESS THAN 0
		TCF	TSK

DPADD2+		AD	NEGMAX		# CAN NOT OVERFLOW
		TS	KMPAC +1
		CA	NEGMAX		# UPPER WAS = 0
		TCF	TSK

## Page 969
