### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERPRETIVE_CONSTANTS.agc
## Purpose:     A section of Luminary revision 163.
##              It is part of the reconstructed source code for the first
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 173, as well as Luminary memos 157 amd 158.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 163 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1091-1092
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              LUMINARY 163.
## Mod history: 2019-08-21 MAS  Created from Luminary 173.

## Page 1091
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

## Page 1092
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

		OCT	77777		# -0,-6,-12 MUST REMAIN IN THIS ORDER
DFC-6		DEC	-6
DFC-12		DEC	-12
LODPMAX		2OCT	3777737777	# THESE TWO CONSTANTS MUST REMAIN

LODPMAX1	2OCT	3777737777	# ADJACENT AND THE SAME FOR INTEGRATION

ZERODP		=	ZEROVEC
HALFDP		=	XUNIT
