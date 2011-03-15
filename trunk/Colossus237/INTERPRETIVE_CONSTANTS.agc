### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:	INTERPRETIVE_CONSTANTS.agc
# Purpose:      Part of the source code for Colossus build 237.
#               This is for the Command Module's (CM) Apollo Guidance
#               Computer (AGC), we believe for Apollo 8.
# Assembler:    yaYUL
# Contact:      Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:      www.ibiblio.org/apollo/index.html
# Page scans:   www.ibiblio.org/apollo/ScansForConversion/Colossus237/
# Mod history:  2011-03-12 JL	Adapted from corresponding Colossus 249 file.

## Page 1187
		SETLOC	INTPRET1
		BANK

		COUNT	23/ICONS

DP1/4TH		2DEC	.25
UNITZ		2DEC	0
UNITY		2DEC	0
UNITX		2DEC	.5
ZEROVECS	2DEC	0
		2DEC	0
		2DEC	0

DPHALF		=	UNITX
DPPOSMAX	OCT	37777
		OCT	37777

## Page 1188
# INTERPRETIVE CONSTANTS IN THE OTHER HALF-MEMORY

		SETLOC	INTPRET2
		BANK

		COUNT	14/ICONS

ZUNIT		2DEC	0
YUNIT		2DEC	0
XUNIT		2DEC	.5
ZEROVEC		2DEC	0
		2DEC	0
		2DEC	0

		OCT	77777		# -0,-6,-12 MUST REMAIN IN THIS ORDER
DEC-6		DEC	-6
DEC-12		DEC	-12
LODPMAX		2OCT	3777737777	# THESE TWO CONSTANTS MUST REMAIN
LODPMAX1	2OCT	3777737777	# ADJACENT AND THE SAME FOR INTEGRATION
ZERODP		=	ZEROVEC
HALFDP		=	XUNIT
