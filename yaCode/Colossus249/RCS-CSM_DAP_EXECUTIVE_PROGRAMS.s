# Copyright:	Public domain.
# Filename:	RCS-CSM_DAP_EXECUTIVE_PROGRAMS.s
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Reference:	Starts on p. 1012 of 1701.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.sandroid.org/Apollo.
# Mod history:	08/26/04 RSB.	Began transcribing.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  Notations on this
# document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
#
#	This AGC program shall also be referred to as
#				Colossus 1A
#
#	Prepared by
#			Massachussets Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to 1701.pdf) to info@sandroid.org.
#
# In some cases, where the source code for Luminary 131 overlaps that of 
# Colossus 249, this code is instead copied from the corresponding Luminary 131
# source file, and then is proofed to incorporate any changes.

# Page 1012
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
# Page 1013
		TS	AMGB7
		TCF	ENDOFJOB
QUADANGL	DEC	660		# = 7.25 DEGREES

