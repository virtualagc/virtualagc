### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERPRETIVE_CONSTANTS.agc
## Purpose:	A section of Comanche revision 072.
##		It is part of the reconstructed source code for the first
##		release of the software for the Command Module's (CM) Apollo
##		Guidance Computer (AGC) for Apollo 13. No original listings
##		of this program are available; instead, this file was recreated
##		from a printout of Comanche 055, binary dumps of a set of
##		Comanche 067 rope modules, and changelogs between Comanche 067
##		and 072. It has been adapted such that the resulting bugger words
##		exactly match those specified for Comanche 072 in NASA drawing
##		2021153G, which gives relatively high confidence that the
##		reconstruction is correct.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2024-05-13 MAS	Created from Comanche 067.

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

		OCT	77777		# -0, -6, -12 MUST REMAIN IN THIS ORDER
DEC-6		DEC	-6
DEC-12		DEC	-12
LODPMAX		2OCT	3777737777	# THESE TWO CONSTANTS MUST REMAIN

LODPMAX1	2OCT	3777737777	# ADJACENT AND THE SAME FOR INTEGRATION

ZERODP		=	ZEROVEC
HALFDP		=	XUNIT




