### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM) 
#		Apollo Guidance Computer (AGC), we believe for 
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Sergio Navarro <sergionavarrog@gmail.com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-27 SN	Adapted from corresponding Comanche 055 file.

## Page 1036
# CALCULATION OF  AMGB, AMBG  ONCE EVERY SECOND
#
#	AMGB =	1	SIN(PSI)		0
#		0	COS(PSI)COS(PHI)	SIN(PHI)
#		0	-COS(PSI)SIN(PHI)	COS(PHI)
#
#	AMBG =	1	-TAN(PSI)COS(PHI)	TAN(PSI)SIN(PHI)
#		0	COS(PHI)/COS(PSI)	-SIN(PHI)/COS(PSI)
#		0	SIN(PHI)		COS(PHI)
#
# WHERE PHI AND PSI ARE CDU ANGLES

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
## Page 1037
		TS	AMGB7
		TCF	ENDOFJOB
		SETLOC	FFTAG12
		BANK

		COUNT*	$$/DAPEX
QUADANGL	DEC	660		# = 7.25 DEGREES

