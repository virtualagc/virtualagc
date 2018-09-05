### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	SINGLE_PRECISION_SUBROUTINES.agc
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
## Reference:	p. 1096
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	05/31/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website references above.
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original harcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-02-27 RSB	Proofed comment text using octopus/ProoferComments.
##		2018-09-04 MAS	Copied from Luminary 131 for Luminary 130.

## Page 1096
		BLOCK	02

# SINGLE PRECISION SINE AND COSINE

		COUNT*	$$/INTER
SPCOS		AD	HALF		# ARGUMENTS SCALED AT PI
SPSIN		TS	TEMK
		TCF	SPT
		CS	TEMK
SPT		DOUBLE
		TS	TEMK
		TCF	POLLEY
		XCH	TEMK
		INDEX	TEMK
		AD 	LIMITS
		COM
		AD	TEMK
		TS	TEMK
		TCF	POLLEY
		TCF	ARG90
POLLEY		EXTEND
		MP	TEMK
		TS	SQ
		EXTEND
		MP	C5/2
		AD	C3/2
		EXTEND
		MP	SQ
		AD	C1/2
		EXTEND
		MP	TEMK
		DDOUBL
		TS	TEMK
		TC	Q
ARG90		INDEX	A
		CS	LIMITS
		TC	Q		# RESULT SCALED AT 1
		

