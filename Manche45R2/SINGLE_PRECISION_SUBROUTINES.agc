### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
## Purpose:     A section of Manche45 revision 2.
##              It is part of the reconstructed source code for the
##              final, flown release of the flight software for the Command
##              Module's (CM) Apollo Guidance Computer (AGC) for Apollo 10.
##              The code has been recreated from a copy of Comanche 055. It
##              has been adapted such that the resulting bugger words
##              exactly match those specified for Manche 45/2 in NASA drawing
##              2021153D, which gives relatively high confidence that the
##              reconstruction is correct.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-12-24 MAS  Created from Comanche 45.

## Page 1207
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
		
# SPROOT WAS DELETED IN REV 51 OF MASTER. ASS. CONT. HAS CARDS.




