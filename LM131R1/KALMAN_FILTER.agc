### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALMAN_FILTER.agc
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
## Reference:   pp. 1462-1463
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2022-10-28 MAS  Created from Luminary 131.

## Page 1462
		EBANK=	NO.UJETS
		BANK	16
		SETLOC	DAPS1
		BANK

		COUNT*	$$/DAP

RATELOOP	CA	TWO
		TS	DAPTEMP6
		DOUBLE
		TS	Q
		INDEX	DAPTEMP6
		CCS	TJP
		TCF	+2
		TCF	LOOPRATE
		AD	-100MST6
		EXTEND
		BZMF	SMALLTJU
		INDEX	DAPTEMP6
		CCS	TJP
		CA	-100MST6
		TCF	+2
		CS	-100MST6
		INDEX	DAPTEMP6
		ADS	TJP
		INDEX	DAPTEMP6
		CCS	TJP
		CS	-100MS		# 0.1 AT 1
		TCF	+2
		CA	-100MS
LOOPRATE	EXTEND
		INDEX	DAPTEMP6
		MP	NO.PJETS
		CA	L
		INDEX	DAPTEMP6
		TS	DAPTEMP1	# SIGNED TORQUE AT 1 JET-SEC FOR FILTER
		EXTEND
		MP	BIT10		# RESCALE TO 32; ONE BIT ABOUT 2 JET-MSEC
		EXTEND
		BZMF	NEGTORK
STORTORK	INDEX	Q		# INCREMENT DOWNLIST REGISTER.
		ADS	DOWNTORK	#	NOTE:  NOT INITIALIZED; OVERFLOWS.

		CCS	DAPTEMP6
		TCF	RATELOOP +1
		TCF	ROTORQUE
SMALLTJU	CA	ZERO
		INDEX	DAPTEMP6
		XCH	TJP
		EXTEND
## Page 1463
		MP	ELEVEN		# 10.24 PLUS
		CA	L
		TCF	LOOPRATE
ROTORQUE	CA	DAPTEMP2
		AD	DAPTEMP3
		EXTEND
		MP	1JACCR
		TS	JETRATER
		CS	DAPTEMP3
		AD	DAPTEMP2
		EXTEND
		MP	1JACCQ
		TS	JETRATEQ
		TCF	BACKP
-100MST6	DEC	-160

NEGTORK		COM
		INCR	Q
		TCF	STORTORK
		

