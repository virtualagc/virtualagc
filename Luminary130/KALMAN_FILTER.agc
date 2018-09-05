### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	KALMAN_FILTER.agc
## Purpose:	A section of Luminary 1C, revision 131.
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC) for Apollo 13.
##		This file is intended to be a faithful transcription, except
##		that the code format has been changed to conform to the
##		requirements of the yaYUL assembler rather than the
##		original YUL assembler.
## Reference:	pp. 1462-1463
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	06/08/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website reference above
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original hardcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-02-28 RSB	Proofed comment text using octopus/ProoferComments.

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
		

