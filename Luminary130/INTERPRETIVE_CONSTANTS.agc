### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERPRETIVE_CONSTANTS.agc
## Purpose:	A section of the reconstructed source code for Luminary 130.
##		This was the original program released for the Apollo 13 LM,
##		although several more revisions would follow. It has been
##		reconstructed from a listing of Luminary 131, from which it
##		differs on only two lines in P70-P71. The difference is
##		described in detail in Luminary memo #129, which was used
##		to perform the reconstruction. This file is intended to be a
##		faithful reconstruction, except that the code format has been
##		changed to conform to the requirements of the yaYUL assembler
##		rather than the original YUL assembler.
## Reference:	pp. 1094-1095
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	05/31/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website reference above
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original harcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-02-27 RSB	Proofed comment text using octopus/ProoferComments.
##		2018-09-04 MAS	Copied from Luminary 131 for Luminary 130.
##		2021-05-30 ABS	DFC-6 -> DEC-6, DFC-12 -> DEC-12

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


