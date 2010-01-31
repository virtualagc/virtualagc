### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	MYSUBS.agc
## Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
##		build 072.  This is for the Command Module's (CM) 
##		Apollo Guidance Computer (AGC), we believe for 
##		Apollo 15-17.
## Assembler:	yaYUL
## Contact:	Sergio Navarro <sergionavarrog@gmail.com>
## Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
## Mod history:	2009-08-27 SN	Adapted from corresponding Comanche 055 file.
## 		2009-09-04 JL	Fix typos.

## Page 997

		SETLOC	MYSUBS
		BANK
		
		EBANK=	KMPAC
SPCOS1		EQUALS	SPCOS
SPSIN1		EQUALS	SPSIN
SPCOS2		EQUALS	SPCOS
SPSIN2		EQUALS	SPSIN

		COUNT*	$$/DAPMS

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
 +1		TC	Q
DPADD+		AD	NEGMAX		# KMPAC GREATER THAN 0
		TCF	TSK

DPADD-		COM
		AD	POSMAX		# KMPAC LESS THAN 0
## Page 998
		TCF	TSK
		
DPADD2+		AD	NEGMAX		# CAN NOT OVERFLOW
		TS	KMPAC +1
		CA	NEGMAX		# UPPER WAS = 0
		TCF	TSK

## Page 999 (empty page)
