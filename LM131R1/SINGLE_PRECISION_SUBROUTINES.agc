### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
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
## Reference:   p.  1096
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2022-10-28 MAS  Created from Luminary 131.

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
		

