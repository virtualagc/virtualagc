### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	S-BAND_ANTENNA_FOR_LM.agc
## Purpose:	Part of the reconstructed source code for LMY99 Rev 0,
##		otherwise known as Luminary Rev 99, the third release
##		of the Apollo Guidance Computer (AGC) software for Apollo 11.
##		It differs from LMY99 Rev 1 (the flown version) only in the
##		placement of a single label. The corrections shown here have
##		been verified to have the same bank checksums as AGC developer
##		Allan Klumpp's copy of Luminary Rev 99, and so are believed
##		to be accurate. This file is intended to be a faithful 
##		recreation, except that the code format has been changed to 
##		conform to the requirements of the yaYUL assembler rather than 
##		the original YUL assembler.
##
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	486-489
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2009-06-07 RSB	Corrected a misprint.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-08-01 MAS	Created from LMY99 Rev 1.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the MIT Museum.  The digitization
## was performed by Paul Fjeld, and arranged for by Deborah Douglas of
## the Museum.  Many thanks to both.  The images (with suitable reduction
## in storage size and consequent reduction in image quality as well) are
## available online at www.ibiblio.org/apollo.  If for some reason you
## find that the images are illegible, contact me at info@sandroid.org
## about getting access to the (much) higher-quality images which Paul
## actually created.
##
## The code has been modified to match LMY99 Revision 0, otherwise
## known as Luminary Revision 99, the Apollo 11 software release preceeding
## the listing from which it was transcribed. It has been verified to
## contain the same bank checksums as AGC developer Allan Klumpp's listing
## of Luminary Revision 99 (for which we do not have scans).
##
## Notations on Allan Klumpp's listing read, in part:
##
##	ASSEMBLE REVISION 099 OF AGC PROGRAM LUMINARY BY NASA 2021112-51

## Page 486
# SUBROUTINE NAME: R05 - S-BAND ANTENNA FOR LM
#
# MOD0 BY T. JAMES
# MOD1 BY P. SHAKIR
#
# FUNCTIONAL DESCRIPTION
#
# THE S-BAND ANTENNA ROUTINE, R05, COMPUTES AND DISPLAYS THE PITCH AND
# YAW ANTENNA GIMBAL ANGLES REQUIRED TO POINT THE LM STEERABLE ANTENNA
# TOWARD THE CENTER OF THE EARTH.  THIS ROUTINE IS SELECTED BY THE ASTRO-
# NAUT VIA DSKY ENTRY DURING COASTING FLIGHT OR WHEN THE LM IS ON THE MOON
# SURFACE.  THE EARTH OR MOON REFERENCE COORDINATE SYSTEM IS USED DEPENDING
# ON WHETHER THE LM IS ABOUT TO ENTER OR HAS ALREADY ENTERED THE MOON
# SPHERE OF INFLUENCE, RESPECTIVELY
#
# TO CALL SUBROUTINE, ASTRONAUT KEYS IN V 64 E
#
# SUBROUTINES CALLED -
#	R02BOTH
#	INTPRET
#	LOADTIME
#	LEMCONIC
#	LUNPOS
#	CDUTRIG
#	*SMNB*
#	BANKCALL
#	B5OFF
#	ENDOFJOB
#	BLANKET
#
# RETURNS WITH
#	PITCH ANGLE IN PITCHANG 	REV. B0
#	YAW ANGLE IN YAWANG		REV. B0
#
# ERASABLES USED
#	PITCHANG
#	YAWANG
#	RLM
#	VAC AREA

		BANK	41
		SETLOC	SBAND
		BANK
		
		EBANK=	WHOCARES
		COUNT*	$$/R05
SBANDANT	TC	BANKCALL
## Page 487
		CADR	R02BOTH		# CHECK IF IMU IS ON AND ALIGNED
		TC	INTPRET
		SETPD	RTB
			0D
			LOADTIME	# PICK UP CURRENT TIME
		STCALL	TDEC1		# ADVANCE INTEGRATION TO TIME IN TDEC1
			LEMCONIC	# USING CONIC INTEGRATION
		SLOAD	BHIZ
			X2		# X2 =0 EARTH SPHERE, X2 =2 MOON SPHERE
			CONV4
		VLOAD
			RATT
		STODL	RLM
			TAT
CONV3		CALL
			LUNPOS		# UNIT POSITION VECTOR FROM EARTH TO MOON
		VLOAD	VXSC
			VMOON
			REMDIST		# MEAN DISTANCE FROM EARTH TO MOON
		VSL1	VAD
			RLM
		GOTO
			CONV5
CONV4		VLOAD
			RATT		# UE = -UNIT(RATT)		EARTH SPHERE
CONV5		SETPD	UNIT		# UE = -UNIT((REM)(UEM) + RL)	MOON SPHERE
			0D		# SET PL POINTER TO 0
		VCOMP	CALL
			CDUTRIG		# COMPUTE SINES AND COSINES OF CDU ANGLES
		MXV	VSL1		# TRANSFORM REF. COORDINATE SYSTEM TO
			REFSMMAT	# STABLE MEMBER B-1 X B-1 X B+1 = B-1
		PUSH	DLOAD		# 8D
			HI6ZEROS
		STORE	PITCHANG
		STOVL	YAWANG		# ZERO OUT ANGLES
		CALL
			*SMNB*
		STODL	RLM		# PRE-MULTIPLY RLM BY (NBSA) MATRIX(B0)
			RLM 	+2
		PUSH	DSU
			RLM
		DMP
			1OVSQRT2
		STODL	RLM 	+2
		DAD	DMP
			RLM
			1OVSQRT2
		STOVL	RLM		# R B-1
			RLM
		UNIT	PDVL
## Page 488		
			RLM
		VPROJ	VSL2		# PROJECTION OF R ONTO LM XZ PLANE
			HIUNITY
		BVSU	BOV		# CLEAR OVERFLOW INDICATOR IF ON
			RLM
			COVCNV
COVCNV		UNIT	BOV		# EXIT ON OVERFLOW
			SBANDEX
		PUSH	VXV		# URP VECTOR B-1
			HIUNITZ
		VSL1	VCOMP		# UZ X URP = -(URP X UZ)
		STORE	RLM		# X VEC B-1
		DOT	PDVL		# SGN(X.UY) UNSCALED
			HIUNITY
			RLM
		ABVAL	SIGN
		ASIN			# ASIN((SGN(X.UY))ABV(X))	REV B0
		STOVL	PITCHANG
			URP
		DOT	BPL
			HIUNITZ
			NOADJUST	# YES, -90 TO +90
		DLOAD	DSU
			HIDPHALF
			PITCHANG
		STORE	PITCHANG
NOADJUST	VLOAD	VXV
			UR		# Z = (UR X URP)
			URP
		VSL1
		STODL	RLM		# Z VEC B-1
			PITCHANG
		SIN	VXSC
			HIUNITZ
		PDDL	COS
			PITCHANG
		VXSC	VSU
			HIUNITX		# (UX COS ALPHA) - (UZ SIN ALPHA)
		DOT	PDVL		# YAW.Z
			RLM
			RLM
		ABVAL	SIGN
		ASIN
		STORE	YAWANG
SBANDEX		EXIT
		CA	EXTVBACT
		MASK	BIT5		# IS BIT5 STILL ON
		EXTEND
		BZF	ENDEXT		# NO
		CAF	PRIO5
## Page 489		
		TC	PRIOCHNG
		CAF	V06N51		# DISPLAY ANGLES
		TC	BANKCALL
		CADR	GOMARKFR
		TC	B5OFF		# TERMINATE
		TC	B5OFF		# PROCEED
		TC	ENDOFJOB	# RECYCLE
		CAF	BIT3		# IMMEDIATE RETURN
		TC	BLANKET		# BLANK R3
		CAF	PRIO4
		TC	PRIOCHNG
		TC	SBANDANT +2	# YES, CONTINUE DISPLAYING ANGLES
V06N51		VN	0651
1OVSQRT2	2DEC	.7071067815	# 1/SQRT(2)

UR		EQUALS	0D
URP		EQUALS	6D
		SBANK=	LOWSUPER
		
