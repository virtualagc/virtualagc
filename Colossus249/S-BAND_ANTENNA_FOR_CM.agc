### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	S-BAND_ANTENNA_FOR_CM.agc
## Purpose:	Part of the source code for Colossus, build 249.
##		It is part of the source code for the Command Module's (CM)
##		Apollo Guidance Computer (AGC), for Apollo 9.
## Assembler:	yaYUL
## Reference:	pp. 887-888.
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history:	08/22/04 RSB.	Began transcribing.
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original harcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-01-18 RSB	Cross-diff'd comment text (not whitespace)
##				vs the already-proofed corresponding Colossus
##				237 and Comanche 55 source-code files
##				and corrected errors found.
##
## The contents of the "Colossus249" files, in general, are transcribed 
## from a scanned copy of the program listing.  Notations on this
## document read, in part:
##
##	Assemble revision 249 of AGC program Colossus by NASA
##	2021111-041.  October 28, 1968.  
##
##	This AGC program shall also be referred to as
##				Colossus 1A
##
##	Prepared by
##			Massachusetts Institute of Technology
##			75 Cambridge Parkway
##			Cambridge, Massachusetts
##	under NASA contract NAS 9-4065.
##
## Refer directly to the online document mentioned above for further information.
## Please report any errors (relative to the scanned pages) to info@sandroid.org.
##
## In some cases, where the source code for Luminary 131 overlaps that of 
## Colossus 249, this code is instead copied from the corresponding Luminary 131
## source file, and then is proofed to incorporate any changes.

## Page 887
		BANK	23
		SETLOC	SBAND
		BANK
		
		COUNT*	$$/R05
		EBANK=	EMSALT
		
SBANDANT	TC	BANKCALL	# V 64 E GETS US HERE
		CADR	R02BOTH		# CHECK IF IMU IS ON AND ALIGNED
		TC	INTPRET
		RTB	CALL
			LOADTIME	# PICKUP CURRENT TIME SCALED B-28
			CDUTRIG		# COMPUTE SINES AND COSINES OF CDU ANGLES
		STCALL	TDEC1		# ADVANCE INTEGRATION TO TIME IN TDEC1
			CSMCONIC	# USING CONIC INTEGRATION
		SLOAD	BHIZ		# ORIGIN OF REFERENCE INERTIAL SYSTEM IS
			X2		# EARTH = 0, MOON = 2
			EISOI
		VLOAD
			RATT
		STORE	RCM		# MOVE RATT TO PREVENT WIPEOUT
		DLOAD	CALL		# MOON, PUSH ON
			TAT		# GET ORIGINAL TIME
			LUNPOS		# COMPUTE POSITION VECTOR OF MOON
		VAD	VCOMP		# R= -(REM+RCM) = NEG. OF S/C POS. VEC
			RCM
		GOTO
			EISOI +2
EISOI		VLOAD	VCOMP		# EARTH, R= -RCM
			RATT
		SETPD	MXV		# RCS TO STABLE MEMBER- B-1X B-29X B+1
			2D		# 2D
			REFSMMAT	# STABLE MEMBER.  B-1X B-29X B+1= B-29
		VSL1	PDDL		# 8D
			HI6ZEROS
		STOVL	YAWANG		# ZERO OUT YAWANG, SET UP FOR SMNB
			RCM		# TRANSFORMATION.  SM COORD.  SCALED B-29
		CALL
			*SMNB*
		STORE	R		# SAVE NAV. BASE COORDINATES
		UNIT	PDVL		# 14D
			R
		VPROJ	VSL2		# COMPUTE PROJECTION OF VECTOR INTO CM
			HIUNITZ		# XY-PLANE, R-(R.UZ)UZ
		BVSU	BOV		# CLEAR OVERFLOW INDICATOR IF SET
			R
			COVCNV
COVCNV		UNIT	BOV		# TEST OVERFLOW FOR INDICATION OF NULL
			NOADJUST	# VECTOR
		PUSH	DOT		# 20D
## Page 888
			HIUNITX		# COMPUTE YAW ANGLE = ACOS (URP.UX)
		SL1	ACOS		# REVOLUTIONS SCALED B0
		PDVL	DOT		# 22D YAWANG
			URP
			HIUNITY		# COMPUTE FOLLOWING- URP.UY
		SL1	BPL		# POSITIVE
			NOADJUST	# YES, 0-180 DEGREES
		DLOAD	DSU		# NO, 181-360 DEGREES 20D
			DPPOSMAX	# COMPUTE 2 PI MINUS YAW ANGLE
		PUSH			# 22D YAWANG
NOADJUST	VLOAD	DOT		# COMPUTE PITCH ANGLE
			UR		# ACOS (UR.UZ) - PI/2
			HIUNITZ
		SL1	ACOS		# REVOLUTIONS B0
		DSU
			HIDP1/4
		STODL	RHOSB
			YAWANG
		STORE	GAMMASB		# PATCH FOR CHECKOUT
		EXIT
		CA	EXTVBACT	# IS BIT 5 STILL ON
		MASK	BIT5
		EXTEND
		BZF	ENDEXT		# NO, WE HAVE BEEN ANSWERED
		CAF	V06N51		# DISPLAY ANGLES
		TC	BANKCALL
		CADR	GOMARKFR
		TC	B5OFF		# TERMINATE
		TC	B5OFF
		TC	ENDOFJOB	# RECYCLE
		CAF	BIT3		# IMMEDIATE RETURN
		TC	BLANKET		# BLANK R3
		CAF	BIT1		# DELAY MINIMUM TIME TO ALLOW DISPLAY IN
		TC	BANKCALL
		CADR	DELAYJOB
		TCF	SBANDANT +2
V06N51		VN	0651
RCM		EQUALS	2D
UR		EQUALS	8D
URP		EQUALS	14D
YAWANG		EQUALS	20D
PITCHANG	EQUALS	22D
R		EQUALS	RCM

