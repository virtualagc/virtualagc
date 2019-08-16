### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc
## Purpose:     A section of Artemis revision 071.
##              It is part of the reconstructed source code for the first
##              release of the flight software for the Command Module's
##              (CM) Apollo Guidance Computer (AGC) for Apollo 15 through
##              17. The code has been recreated from a copy of Artemis 072.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Artemis 071 in NASA
##              drawing 2021154-, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   1036
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Artemis 072.

## Page 1036
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
## Page 1037
		TS	AMGB7
		TCF	ENDOFJOB
		SETLOC	FFTAG12
		BANK

		COUNT*	$$/DAPEX
QUADANGL	DEC	660		# = 7.25 DEGREES
