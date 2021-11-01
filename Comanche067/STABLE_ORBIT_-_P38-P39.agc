




### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    STABLE_ORBIT_-_P38-P39.agc
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

## Page 525
# STABLE ORBIT RENDEZVOUS PROGRAMS (P38 AND P78)
#
# MOD NO -1		LOG SECTION - STABLE ORBIT - P38-P39
# MOD BY RUDNICKI.S	DATE 25JAN68
#
# FUNCTIONAL DESCRIPTION
#
#	P38 AND P78 CALCULATE THE REQUIRED DELTA V AND OTHER INITIAL
#	CONDITIONS REQUIRED BY THE AGC TO (1) PUT THE ACTIVE VEHICLE
#	ON A TRANSFER TRAJECTORY THAT INTERCEPTS THE PASSIVE VEHICLE
#	ORBIT A GIVEN DISTANCE, DELTA R, EITHER AHEAD OF OR BEHIND THE
#	PASSIVE VEHICLE AND (2) ACTUALLY PLACE THE ACTIVE VEHICLE IN THE
#	PASSIVE VEHICLE ORBIT WITH A DELTA R SEPARATION BETWEEN THE TWO
#	VEHICLES
#
# CALLING SEQUENCE
#
#	ASTRONAUT REQUEST THRU DSKY
#
#	V37E38E		IF THIS VEHICLE IS ACTIVE VEHICLE
#	V37E78E		IF OTHER VEHICLE IS ACTIVE VEHICLE
#
# INPUT
#
#	(1)	SOI MANEUVER
#
#		(A)  TIG	TIME OF SOI MANEUVER
#		(B)  CENTANG	ORBITAL CENTRAL ANGLE OF THE PASSIVE VEHICLE
#				DURING TRANSFER FROM TIG TO TIME OF INTERCEPT
#		(C)  DELTAR	THE DESIRED SEPARATION OF THE TWO VEHICLES
#				SPECIFIED AS A DISTANCE ALONG THE PASSIVE VEHICLE
#				ORBIT
#		(D)  OPTION	EQUALS 1 FOR SOI
#
#	(2)	SOR MANEUVER
#
#		(A)  TIG	TIME OF SOR MANEUVER
#		(B)  CENTANG	AN OPTIONAL RESPECIFICATION OF 1 (B) ABOVE
#		(C)  OPTION	EQUALS 2 FOR SOR
#		(D)  DELTTIME	THE TIME REQUIRED TO TRAVERSE DELTA R WHEN
#				TRAVELING AT A VELOCITY EQUAL TO THE HORIZONTAL
#				VELOCITY OF THE PASSIVE VEHICLE - SAVED FROM
#				SOI PHASE
#		(E)  TINT	TIME OF INTERCEPT (SOI) - SAVED FROM SOI PHASE
#
# OUTPUT
#
#	(1)  TRKMKCNT	NUMBER OF MARKS
#	(2)  TTOGO	TIME TO GO
#	(3)  +MGA	MIDDLE GIMBAL ANGLE
## Page 526
#	(4)  DSPTEM1	TIME OF INTERCEPT OF PASSIVE VEHICLE ORBIT
#			(FOR SOI ONLY)
#	(5)  POSTTPI	PERIGEE ALTITUDE OF ACTIVE VEHICLE ORBIT AFTER
#			THE SOI (SOR) MANEUVER
#	(6)  DELVTPI	MAGNITUDE OF DELTA V AT SOI (SOR) TIME
#	(7)  DELVTPF	MAGNITUDE OF DELTA V AT INTERCEPT TIME
#	(8)  DELVLVC 	DELTA VELOCITY AT SOI (AND SOR) - LOCAL VERTICAL
#			COORDINATES
#
# SUBROUTINES USED
#
#	AVFLAGA
#	AVFLAGP
#	VNDSPLY
#	BANKCALL
#	GOFLASHR
#	GOTOPOOH
#	BLANKET
#	ENDOFJOB
#	PREC/TT
#	SELECTMU
#	INTRPVP
#	MAINRTNE

		BANK	04
		SETLOC	STBLEORB
		BANK
		
		EBANK=	SUBEXIT
		COUNT*	$$/P3879
		
P38		TC	AVFLAGA         # THIS VEHICLE ACTIVE
		TC      +2
P78		TC	AVFLAGP         # OTHER VEHICLE ACTIVE
		TC      P20FLGON        # SET UPDATFLG, TRACKFLG
		CAF	V06N33SR	# DISPLAY TIG
		TC	VNDSPLY
		CAF	V06N55SR	# DISPLAY CENTANG
		TCR	BANKCALL
		CADR	GOFLASHR
		TCF	GOTOPOOH	# TERMINATE
		TCF	+5		# PROCEED
		TCF	-5		# RECYCLE
		CAF	THREE		# IMMEDIATE RETURN - BLANK R1, R2
		TCR	BLANKET
		TCF	ENDOFJOB
		CAF	FIVE
		TS	OPTION1
		CAF	ONE
		TS	OPTION2		# OPTION CODE IS SET TO 1
## Page 527
		CAF	V04N06SR	# DISPLAY OPTION CODE -1 = SOI, 2 = SOR
		TCR	BANKCALL
		CADR	GOFLASHR
		TCF	GOTOPOOH	# TERMINATE
		TCF	+5		# PROCEED
		TCF	-5		# RECYCLE
		CAF	BIT3		# IMMEDIATE RETURN - BLANK R3
		TCR	BLANKET
		TCF	ENDOFJOB
		TC	INTPRET
		SSP
		        NN
		        2
		SLOAD   SR1
			OPTION2
		BHIZ	DLOAD
			OPTN1
			TINT
		STORE	TINTSOI		# STORE FOR SOR PHASE
		CLRGO
			OPTNSW		# OPTNSW; ON = SOI, OFF = SOR
			JUNCTN1
OPTN1		SET	CLEAR		# SOI
			OPTNSW
			UPDATFLG
		CALL
			PREC/TT
		SET	DAD
			UPDATFLG
			TIG
		STORE	TINT		# TI = TIG + TF
		STORE	DSPTEM1		# FOR DISPLAY
		EXIT
		CAF	V06N57SR	# DISPLAY DELTA R
		TCR	BANKCALL
		CADR	GOFLASHR
		TCF	GOTOPOOH	# TERMINATE
		TCF	+5		# PROCEED
		TCF	-5		# RECYCLE
		CAF	SIX		# IMMEDIATE RETURN - BLANK R2, R3
		TCR	BLANKET
		TCF	ENDOFJOB
		CAF	V06N34SR	# DISPLAY TIME OF INTERCEPT
		TC	VNDSPLY
		TC	INTPRET
JUNCTN1		CLEAR	CALL
			P39/79SW
			SELECTMU	# SELECT MU, CLEAR FINALFLG, GO TO VN1645
RECYCLE		CALL
			PREC/TT
## Page 528
		BOFF	DLOAD
			OPTNSW
			OPTN2
			TINT
		STCALL	TDEC1		# PRECISION UPDATE PASSIVE VEHICLE TO
			INTRPVP		# INTERCEPT TIME
		VLOAD	UNIT
			RATT		# RP/(RP)
		PDVL	VXV
			VATT
		ABVAL	NORM		# (VP X RP/(RP))
			X1
		PDDL	DDV
			DELTAR
		SL*			# DELTA R / (VP X RP/RP)
			0 -7,1
		STCALL	DELTTIME	# DELTA T = (RP) DELTA R / (VP X RP)
			JUNCTN2
OPTN2		DLOAD	DAD
			TINTSOI
			T
		STORE	TINT		# TI = TI + TF
JUNCTN2		DLOAD	DSU
			TINT
			DELTTIME
		STORE	TARGTIME	# TT = TI - DELTA T
		
# .... MAINRTNE ....
#
# SUBROUTINES USED
#
#	S3435.25
#	PERIAPO1
#	SHIFTR1
#	VNDSPLY
#	BANKCALL
#	GOFLASH
#	GOTOPOOH
#	VN1645

MAINRTNE	STCALL	TDEC1		# PRECISION UPDATE PASSIVE VEHICLE TO
			INTRPVP		#	TARGET TIME
		DLOAD
			TIG
		STORE	INTIME
		SSP	VLOAD
			SUBEXIT
			TEST3979
			RATT
		CALL
			S3435.25
TEST3979	BOFF	BON
## Page 529
			P39/79SW
			MAINRTN1
			FINALFLG
			P39P79
		SET
			UPDATFLG
P39P79		EXIT
		TC	DSPLY81		# FOR P39 AND P79
MAINRTN1	VLOAD	ABVAL
			DELVEET3
		STOVL	DELVTPI		# DELTA V
			VPASS4
		VSU	ABVAL
			VTPRIME
		STOVL	DELVTPF		# DELTA V (FINAL) = V'T - VT
			RACT3
		PDVL	CALL
			VIPRIME
			PERIAPO1	# GET PERIGEE ALTITUDE
		CALL
			SHIFTR1
		STORE	POSTTPI
		BON	SET
			FINALFLG
			DSPLY58
			UPDATFLG
DSPLY58		EXIT
		CAF	V06N58SR	# DISPLAY HP, DELTA V, DELTA V (FINAL)
		TC	VNDSPLY
DSPLY81		CAF	V06N81SR	# DISPLAY DELTA V (LV)
		TC	VNDSPLY
		TC	INTPRET
		CLEAR	VLOAD
			XDELVFLG
			DELVEET3
		STCALL	DELVSIN
			VN1645		# DISPLAY TRKMKCNT, TTOGO, +MGA
		BON	GOTO
			P39/79SW
			P39/P79B
			RECYCLE
			
# STABLE ORBIT MIDCOURSE PROGRAM (P39 AND P79)
#
# MOD NO -1		LOG SECTION - STABLE ORBIT - P38-P39
# MOD BY RUDNICKI.S	DATE 25JAN68
#
# FUNCTIONAL DESCRIPTION
#
#	P39 AND P79 CALCULATE THE REQUIRED DELTA V AND OTHER INITIAL
#	CONDITIONS REQUIRED BY THE AGC TO MAKE A MIDCOURSE CORRECTION
## Page 530
#	MANEUVER AFTER COMPLETING THE SOI MANEUVER BUT BEFORE MAKING
#	THE SOR MANEUVER
#
# CALLING SEQUENCE
#
#	ASTRONAUT REQUEST THRU DSKY
#
#	V37E39E		IF THIS VEHICLE IS ACTIVE VEHICLE
#	V37E79E		IF OTHER VEHICLE IS ACTIVE VEHICLE
#
# INPUT
#
#	(1)  TPASS4	TIME OF INTERCEPT - SAVED FROM P38/P78
#	(2)  TARGTIME	TIME THAT PASSIVE VEHICLE IS AT INTERCEPT POINT -
#			SAVED FROM P38/P78
#
# OUTPUT
#
#	(1)  TRKMKCNT	NUMBER OF MARKS
#	(2)  TTOGO	TIME TO GO
#	(3)  +MGA	MIDDLE GIMBAL ANGLE
#	(4)  DELVLVC	DELTA VELOCITY AT MID - LOCAL VERTICAL COORDINATES
#
# SUBROUTINES USED
#
#	AVFLAGA
#	AVFLAGP
#	LOADTIME
#	SELECTMU
#	PRECSET
#	S34/35.1
#	MAINRTNE

P39		TC	AVFLAGA		# THIS VEHICLE ACTIVE
		EXTEND
		DCA	ATIGINC
		TC	P39/P79A
P79		TC	AVFLAGP		# OTHER VEHICLE ACTIVE
		EXTEND
		DCA	PTIGINC
P39/P79A	DXCH	KT		# TIME TO PREPARE FOR BURN
		TC	P20FLGON	# SET UPDATFLG, TRACKFLG
		TC	INTPRET
		SET	CALL
			P39/79SW
			SELECTMU	# SELECT MU, CLEAR FINALFLG, GO TO VN1645
P39/P79B	RTB	DAD
			LOADTIME
			KT
		STORE	TIG		# TIG = T (PRESENT) + PREPARATION TIME
## Page 531
		STCALL	TDEC1		# PRECISION UPDATE ACTIVE AND PASSIVE
			PRECSET		# 	VEHICLES TO TIG
		CALL
			S34/35.1	# GET UNIT NORMAL
		DLOAD	GOTO
			TARGTIME
			MAINRTNE	# CALCULATE DELTA V AND DELTA V (LV)
			
# .... PREC/TT ....
#
# SUBROUTINES USED
#
#	PRECSET
#	TIMETHET
#	S34/35.1

PREC/TT		STQ	DLOAD
			RTRN
			TIG
		STCALL	TDEC1		# PRECISION UPDATE ACTIVE AND PASSIVE
			PRECSET		#	VEHICLES TO TIG
		VLOAD	VSR*
			RPASS3
			0,2
		STODL	RVEC
			CENTANG
		PUSH	COS
		STODL	CSTH
		SIN	SET
			RVSW
		STOVL	SNTH
			VPASS3
		VSR*
			0,2
		STCALL	VVEC		# GET TRANSFER TIME BASED ON CENTANG OF
			TIMETHET	#	PASSIVE VEHICLE
		CALL
			S34/35.1	# GET UNIT NORMAL
		DLOAD	GOTO
			T
			RTRN
			
# .... INTRPVP ....
#
# SUBROUTINES USED
#
#	CSMPREC
#	LEMPREC

INTRPVP		STQ	BOFF		# PRECISION UPDATE PASSIVE VEHICLE TO
			RTRN		#	TDEC1
			AVFLAG
			OTHERV
		CALL
## Page 532
			CSMPREC
		GOTO
			RTRN
OTHERV		CALL
			LEMPREC
		GOTO
			RTRN
			
# .... VNDSPLY ....
#
# SUBROUTINES USED
#
#	BANKCALL
#	GOFLASH
#	GOTOPOOH

VNDSPLY		EXTEND			# FLASH DISPLAY
		QXCH	RTRN
		TS	VERBNOUN
		CA	VERBNOUN
		TCR	BANKCALL
		CADR	GOFLASH
		TCF	GOTOPOOH	# TERMINATE
		TC	RTRN		# PROCEED
		TCF	-5		# RECYCLE
V06N33SR	VN	0633
V06N55SR	VN	0655
V04N06SR	VN	0406
V06N57SR	VN	0657
V06N34SR	VN	0634
V06N58SR	VN	0658
V06N81SR	VN	0681

