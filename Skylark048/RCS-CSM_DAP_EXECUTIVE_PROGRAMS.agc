### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc
## Purpose:	A section of Skylark revision 048.
##		It is part of the source code for the Apollo Guidance Computer (AGC)
##		for Skylab-2, Skylab-3, Skylab-4, and ASTP. No original listings of
##		this software are available; instead, this file was created via
##		disassembly of dumps of the core rope modules actually flown on
##		Skylab-2. Access to these modules was provided by the New Mexico
##		Museum of Space History.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-09-04 MAS  Created from Artemis 072.

# CALCULATION OF  AMGB, AMBG     ONCE EVERY SECOND
#
#  AMGB =  1	SIN(PSI)		0
#	   0	COS(PSI)COS(PHI)	SIN(PHI)
#	   0	-COS(PSI)SIN(PHI)	COS(PHI)
#
#  AMBG =  1	-TAN(PSI)COS(PHI)	TAN(PSI)SIN(PHI)
#	   0	COS(PHI)/COS(PSI)	-SIN(PHI)/COS(PSI)
#	   0	SIN(PHI)		COS(PHI)
#
#  WHERE PHI AND PSI ARE CDU ANGLES

		SETLOC	DAPS8
		BANK
		
		COUNT*	$$/DAPEX
		EBANK=	KMPAC
AMBGUPDT	CA	FLAGWRD6	# CHECK FOR RCS AUTOPILOT
		MASK	DPCONFIG
		EXTEND
		BZMF	ENDOFJOB	# BIT15 = 0, BIT14 = 1
		MASK	DAP2BIT		# IF NOT RCS, EXIT
		EXTEND
		BZF	ENDOFJOB	# TO PROTECT TVC DAP ON SWITCHOVER
		
		CA	CDUZ	
		TC	SPSIN2
		TS	AMGB1		# CALCULATE AMGB
		CA	CDUZ
		TC	SPCOS2
		TS	CAPSI		# MUST CHECK FOR GIMBAL LOCK
		CAF	QUADANGL	# = 7.25  DEGREES JET QUAD ANGULAR OFFSET
		EXTEND
		MSU	CDUX
		COM			# CDUX - 7.25 DEG
		TC	SPCOS1
		TS	AMGB8
		EXTEND
		MP	CAPSI
		TS	AMGB4
		CAF	QUADANGL
		EXTEND
		MSU	CDUX
		COM			# CDUX - 7.25 DEG
		TC	SPSIN1
		TS	AMGB5
		EXTEND
		MP	CAPSI
		COM
		TS	AMGB7
		TCF	ENDOFJOB
		SETLOC	FFTAG12
		BANK

		COUNT*	$$/DAPEX
QUADANGL	DEC	660		# = 7.25 DEGREES
