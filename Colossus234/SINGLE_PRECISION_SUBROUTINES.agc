### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
## Purpose:     A section of Colossus revision 234.
##              It is part of the reconstructed source code for the first
##              (unmanufactured) release of the flighta software for the
##              Command Module's (CM) Apollo Guidance Computer (AGC) for
##              Apollo 8. The code has been recreated from a copy of
##              Colossus 237. It has been adapted such that the resulting
##              bugger words exactly match those specified for Colossus 234
##              in NASA drawing 2021151B, which gives relatively high
##              confidence that the reconstruction is correct.
## Reference:   1174
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              COLOSSUS 234.
## Mod history: 2019-08-02 MAS  Created from Colossus 237.

## Page 1174
		BLOCK	02

# SINGLE PRECISION SINE AND COSINE

		COUNT	02/INTER
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
# 	   SPROOT WAS DELETED IN REV 51 OF MASTER. ASS. CONT. HAS CARDS.
