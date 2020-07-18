### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 292

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
		

