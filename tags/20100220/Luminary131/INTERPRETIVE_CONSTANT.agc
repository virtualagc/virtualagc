# Copyright:	Public domain.
# Filename:	INTERPRETIVE_CONSTANT.agc
# Purpose:	A section of Luminary 1C, revision 131.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13 and Apollo 14.
#		This file is intended to be a faithful transcription, except
#		that the code format has been changed to conform to the
#		requirements of the yaYUL assembler rather than the
#		original YUL assembler.
# Reference:	pp. 1099-1100 of 1729.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	05/31/03 RSB.	Began transcribing.
#		05/14/05 RSB	Corrected website reference above

# Page 1099
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

# Page 1100
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
DFC-6		DEC	-6
DFC-12		DEC	-12
LODPMAX		2OCT	3777737777	# THESE TWO CONSTANTS MUS REMAIN
LODPMAX1	2OCT	3777737777	# ADJACENT AND THE SAME FOR INTEGRATION

ZERODP		=	ZEROVEC
HALFDP		=	XUNIT


