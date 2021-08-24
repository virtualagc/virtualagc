### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LEM_GEOMETRY.agc
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
## Pages:	320-325
## Mod history:	2009-05-16 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2016-12-13 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-07 RSB	Fixed comment-text error noticed while proofing
##				Luminary 116.
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

## Page 320
		BANK	23
		SETLOC	LEMGEOM
		BANK
		
		SBANK=	LOWSUPER
		EBANK=	XSM
		
# THESE TWO ROUTINES COMPUTE THE ACTUAL STATE VECTOR FOR LM,CSM BY ADDING
# THE CONIC R,V AND THE DEVIATIONS R,V.  THE STATE VECTORS ARE CONVERTED TO
# METERS B-29 AND METERS/CSEC B-7 AND STORED APPROPRIATELY IN RN,VN OR
# R-OTHER,V-OTHER FOR DOWNLINK.  THE ROUTINES NAMES ARE SWITCHED IN THE
# OTHER VEHICLES COMPUTER.
#
# INPUT
#	STATE VECTOR IN TEMPORARY STORAGE AREA
#	IF STATE VECTOR IS SCALED POS B27 AND VEL B5
#		SET X2 TO +2
#	IF STATE VECTOR IS SCALED POS B29 AND VEL B7
#		SET X2 TO 0
#
# OUTPUT
#	R(T) IN RN, V(T) IN VN, T IN PIPTIME
# OR
#	R(T) IN R-OTHER, V(T) IN V-OTHER	(T IS DEFINED BY T-OTHER)

		COUNT*	$$/GEOM
SVDWN2		BOF	RVQ		# SW=1=AVETOMID DOING W-MATRIX INTEG.
			AVEMIDSW
			+1
		VLOAD	VSL*
			TDELTAV
			0 	-7,2
		VAD	VSL*
			RCV
			0,2
		STOVL	RN
			TNUV
		VSL*	VAD
			0 	-4,2
			VCV
		VSL*
			0,2
		STODL	VN
			TET
		STORE	PIPTIME
		RVQ
## Page 321
SVDWN1		VLOAD	VSL*
			TDELTAV
			0 	-7,2
		VAD	VSL*
			RCV
			0,2
		STOVL	R-OTHER
			TNUV
		VSL*	VAD
			0 	-4,2
			VCV
		VSL*	
			0,2
		STORE	V-OTHER
		RVQ
		
## Page 322
# THE FOLLOWING ROUTINE TAKES A HALF UNIT TARGET VECTOR REFERRED TO NAV BASE COORDINATES AND FINDS BOTH
# GIMBAL ORIENTATIONS AT WHICH THE RR MIGHT SIGHT THE TARGET.  THE GIMBAL ANGLES CORRESPONDING TO THE PRESENT MODE
# ARE LEFT IN MODEA AND THOSE WHICH WOULD BE USED AFTER A REMODE IN MODEB.  THIS ROUTINE ASSUMES MODE 1 IS TRUNNION
# ANGLE LESS THAN 90 DEGS IN ABS VALUE WITH ARBITRARY SHAFT, WITH A CORRESPONDING DEFINITION FOR MODE 2.  MODE
# SELECTION AND LIMIT CHECKING ARE DONE ELSEWHERE.
#
# THE MODE 1 CONFIGURATION IS CALCULATED FROM THE VECTOR AND THEN MODE 2 IS FOUND USING THE RELATIONS
#
#	S(2) = 180 + S(1)
#	T(2) = 180 - T(1)
#
# THE VECTOR ARRIVES IN MPAC WHERE TRG*SMNG OR *SMNB* WILL HAVE LEFT IT.

RRANGLES	STORE	32D
		DLOAD	DCOMP		# SINCE WE WILL FIND THE MODE 1 SHAFT
			34D		# ANGLE LATER, WE CAN FIND THE MODE 1
		SETPD	ASIN		# TRUNNION BY SIMPLY TAKING THE ARCSIN OF
			0		# THE Y COMPONENT, THE ASIN GIVING AN
		PUSH	BDSU		# ANSWER WHOSE ABS VAL IS LESS THAN 90 DEG
			LODPHALF
		STODL	4		# MODE 2 TRUNNION TO 4.
		
			LO6ZEROS
		STOVL	34D		# UNIT THE PROJECTION OF THE VECTOR
			32D		#	IN THE X-Z PLANE
		UNIT	BOVB		# IF OVERFLOW, TARGET VECTOR IS ALONG Y
			LUNDESCH	# CALL FOR MANEUVER UNLESS ON LUNAR SURF
		STODL	32D		# PROJECTION VECTOR.
			32D
		SR1	STQ
			S2
		STODL	SINTH		# USE ARCTRIG SINCE SHAFT COULD BE ARB.
			36D
		SR1
		STCALL	COSTH
			ARCTRIG
## Page 323
		PUSH	DAD		# MODE 1 SHAFT TO 2.
			LODPHALF
		STOVL	6
			4
		RTB			# FIND MODE 2 CDU ANGLES.
			2V1STO2S
		STOVL	MODEB
			0
		RTB			# MODE 1 ANGLES TO MODE A.
			2V1STO2S
		STORE	MODEA
		EXIT
		
		CS	RADMODES	# SWAP MODEA AND MODEB IF RR IN MODE 2.
		MASK	ANTENBIT
		CCS	A
		TCF	+4
		
		DXCH	MODEA
		DXCH	MODEB
		DXCH	MODEA
		
		TC	INTPRET
		GOTO
			S2
## Page 324
# GIVEN RR TRUNNION AND SHAFT (T,S) IN TANGNB,+1, FIND THE ASSOCIATED
# LINE OF SIGHT IN NAV BASE AXES.  THE HALF UNIT VECTOR, .5(SIN(S)COS(T),
# -SIN(T),COS(S)COS(T)) IS LEFT IN MPAC AND 32D.

		SETLOC	INFLIGHT
		BANK
		
		COUNT*	$$/GEOM

RRNB		SLOAD	RTB
			TANGNB
			CDULOGIC
		SETPD	PUSH		# TRUNNION ANGLE TO 0
			0
		SIN	DCOMP
		STODL	34D		# Y COMPONENT
		
		COS	PUSH		# .5 COS(T) TO 0
		SLOAD	RTB
			TANGNB +1
			CDULOGIC
RRNB1		PUSH	COS		# SHAFT ANGLE TO 2
		DMP	SL1
			0
		STODL	36D		# Z COMPONENT
		
		SIN	DMP
		SL1
		STOVL	32D
			32D
		RVQ
		
# THIS ENTRY TO RRNB REQUIRES THE TRUNNION AND SHAFT ANGLES IN MPAC AND MPAC +1 RESPECTIVELY

RRNBMPAC	STODL	20D		# SAVE SHAFT CDU IN 21.
			MPAC		# SET MODE TO DP.  (THE PRECEEDING STORE
					# MAY BE DP, TP OR VECTOR.)
		RTB	SETPD
			CDULOGIC
			0
		PUSH	SIN		# TRUNNION ANGLE TO 0
		DCOMP
		STODL	34D		# Y COMPONENT
		COS	PUSH		# .5COS(T) TO 0
		SLOAD	RTB		# PICK UP CDU'S.
			21D
			CDULOGIC
		GOTO
			RRNB1
## Page 325
## <br>This page has nothing on it.

			
