




### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.

## Page 1037
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

		BANK	20
		SETLOC	DAPS8
		BANK
		
		COUNT*	$$/DAPEX
		EBANK=	KMPAC
AMBGUPDT	CA	FLAGWRD6	# CHECK FOR RCS AUTOPILOT
		EXTEND
		BZMF	ENDOFJOB	# BIT15 = 0, BIT14 = 1
		MASK	BIT14		# IF NOT RCS, EXIT
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
## Page 1038
		TS	AMGB7
		TCF	ENDOFJOB
QUADANGL	DEC	660		# = 7.25 DEGREES

