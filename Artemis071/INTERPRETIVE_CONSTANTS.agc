### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERPRETIVE_CONSTANTS.agc
## Purpose:     A section of Artemis revision 071.
##              It is part of the reconstructed source code for the first
##              release of the flight software for the Command Module's
##              (CM) Apollo Guidance Computer (AGC) for Apollo 15 through
##              17. The code has been recreated from a copy of Artemis 072.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Artemis 071 in NASA
##              drawing 2021154-, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   1205
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Artemis 072.

## Page 1205
		SETLOC	INTPRET1
		BANK

		COUNT*	$$/ICONS
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

## Page 1206

# INTERPRETIVE CONSTANTS IN THE OTHER HALF-MEMORY

		SETLOC	INTPRET2
		BANK

		COUNT*	$$/ICONS
ZUNIT		2DEC	0
YUNIT		2DEC	0
XUNIT		2DEC	.5
ZEROVEC		2DEC	0
		2DEC	0
		2DEC	0

		OCT	77777		# -0, -6, -12 MUST REMAIN IN THIS ORDER
DEC-6		DEC	-6
DEC-12		DEC	-12
LODPMAX		2OCT	3777737777	# THESE TWO CONSTANTS MUST REMAIN
LODPMAX1	2OCT	3777737777	# ADJACENT AND THE SAME FOR INTEGRATION

ZERODP		=	ZEROVEC
HALFDP		=	XUNIT
