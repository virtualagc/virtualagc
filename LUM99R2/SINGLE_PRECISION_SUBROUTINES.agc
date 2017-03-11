### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	SINGLE_PRECISION_SUBROUTINES.agc
## Purpose: 	Part of the source code for Luminary 1A build 099.
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC), for Apollo 11.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	1102
## Mod history:	2009-05-25 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2010-12-31 JL	Fixed page number comment.
##		2016-12-17 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-03 RSB	Snapshot of Luminary 99 Rev 1. 

## Page 1102
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
		

