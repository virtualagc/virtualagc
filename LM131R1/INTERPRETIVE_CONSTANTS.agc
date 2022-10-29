### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERPRETIVE_CONSTANTS.agc
## Purpose:     A section of LM131 revision 1.
##              It is part of the reconstructed source code for the final
##              release of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 13. The code has
##              been reconstructed from a listing of Luminary 131 and a dump
##              of a core rope memory module B5, part number 2010802-171,
##              which is the only module different between LM131 revision 1
##              and Luminary 131. The executable generated from this source
##              has been verified against the module dump, so while the names,
##              comments, and ordering may not be exactly correct, the
##              resulting binary is.
## Reference:   pp. 1094-1095
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2022-10-28 MAS  Created from Luminary 131.

## Page 1094
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

## Page 1095
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


