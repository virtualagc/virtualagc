### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc
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
## Mod history:	2024-02-19 MAS  Created from Luminary 131.
##		2024-03-04 MAS  Updated for Skylark 48.

# NAME - LSPOS - LOCATE SUN AND MOON			DATE - 25 OCT 67
# MOD NO.1
# MOD BY NEVILLE					ASSEMBLY SUNDANCE
#
# FUNCTIONAL DESCRIPTION
#
# COMPUTES UNIT POSITION VECTOR OF THE SUN AND MOON IN THE BASIC REFERENCE SYSTEM.  THE SUN VECTOR S IS
# LOCATED VIA TWO ANGLES.  THE FIRST ANGLE (OBLIQUITY) IS THE ANGLE BETWEEN THE EARTH EQUATOR AND THE ECLIPTIC. THE
# SECOND ANGLE IS THE LONGITUDE OF THE SUN MEASURED IN THE ECLIPTIC.
# THE POSITION VECTOR OF THE SUN IS
#	-
#	S = (COS(LOS), COS(OBL)*SIN(LOS), SIN(OBL)*SIN(LOS)), WHERE
#
#	LOS = LOS +LOS *T-(C *SIN(2PI*T)/365.24 +C *COS(2PI*T)/365.24)
#	         0    R     0                     1
#	LOS  (RAD) IS THE LONGITUDE OF THE SUN FOR MIDNIGHT JUNE 30TH OF THE PARTICULAR YEAR.
#          0
#	LOS  (RAD/DAY) IS THE MEAN RATE FOR THE PARTICULAR YEAR.
#    	   R
#
# LOS  AND LOS  ARE STORED AS LOSC AND LOSR IN RATESP.
#    0        R
# COS(OBL) AND SIN(OBL) ARE STORED IN THE MATRIX KONMAT.
#
# T, TIME MEASURED IN DAYS (24 HOURS), IS STORED IN TIMEP.
#
# C  AND C  ARE FUDGE FACTORS TO MINIMIZE THE DEVIATION.  THEY ARE STORED AS ONE CONSTANT (CMOD), SINCE
#  0      1                               2  2 1/2
# C *SIN(X)+C *COS(X) CAN BE WRITTEN AS (C +C )   *SIN(X+PHI), WHERE PHI=ARCTAN(C /C ).
#  0         1                            0  1                                   1  0
#
# THE MOON IS LOCATED VIA FOUR ANGLES. THE FIRST IS THE OBLIQUITY. THE SECOND IS THE MEAN LONGITUDE OF THE MOON,
# MEASURED IN THE ECLIPTIC FROM THE MEAN EQUINOX TO THE MEAN ASCENDING NODE OF THE LUNAR ORBIT, AND THEN ALONG THE
# ORBIT.  THE THIRD ANGLE IS THE ANGLE BETWEEN THE ECLIPTIC AND THE LUNAR ORBIT.  THE FOURTH ANGLE IS THE LONGITUDE
# OF THE NODE OF THE MOON, MEASURED IN THE LUNAR ORBIT.  LET THESE ANGLES BE OBL,LOM,IM, AND LON RESPECTIVELY.
#
# THE SIMPLIFIED POSITION VECTOR OF THE MOON IS
#	-
#	M=(COS(LOM), COS(OBL)*SIN(LOM)-SIN(OBL)*SIN(IM)*SIN(LOM-LON), SIN(OBL)*SIN(LOM)+COS(OBL)*SIN(IM)*SIN(LOM-LON))
#
# WHERE
#	LOM=LOM +LOM *T-(A *SIN 2PI*T/27.5545+A *COS(2PI*T/27.5545)+B *SIN 2PI*T/32+B *COS(2PI*T/32)), AND
#	       0    R     0                    1                     0               1
#	LON=LON +LON
#	       0    R
# A , A , B  AND B  ARE STORED AS AMOD AND BMOD (SEE DESCRIPTION OF CMOD, ABOVE).  COS(OBL), SIN(OBL)*SIN(IM),
#  0   1   0      1
# SIN(OBL), AND COS(OBL)*SIN(IM) ARE STORED IN KONMAT AS K1, K2, K3  AND K4, RESPECTIVELY.  LOM , LOM , LON , LON
# ARE STORED AS LOMO, LOMR, LONO, AND LONR IN RATESP.                                          0     R     0     R
#
# THE THREE PHIS ARE STORED AS AARG, BARG, AND CARG(SUN).  ALL CONSTANTS ARE UPDATED BY YEAR.
#
# CALLING SEQUENCE
#	CALL LSPOS.  RETURN IS VIA CPRET.
#
# ALARMS OR ABORTS
#	NONE
#
# ERASABLE INITIALIZATION REQUIRED
#	TEPHEM - TIME FROM MIDNIGHT 1 JULY PRECEDING THE LAUNCH TO THE TIME OF THE LAUNCH (WHEN THE AGC CLOCK WENT
#	TO ZERO).  TEPHEM IS TP WITH UNITS OF CENTI-SECONDS.
#
#	TIME2 AND TIME1 ARE IN MPAC AND MPAC +1 WHEN PROGRAM IS CALLED.
#
# OUTPUT
#	UNIT POSITIONAL VECTOR OF SUN IN VSUN.  (SCALED B-1)
#	UNIT POSITIONAL VECTOR OF MOON IN VMOON.  (SCALED B-1)
#
# SUBROUTINES USED
#	NONE
#
# DEBRIS
#	CURRENT CORE SET, WORK AREA AND FREEFLAG

		BANK	04
		SETLOC	EPHEM
		BANK

		EBANK=	VSUN
		COUNT*	$$/EPHEM

LSPOS		SETPD	SR
			0
			14D		# TP
		TAD	DDV
			TEPHEM		# TIME OF LAUNCH
			CSTODAY		# 24 HOURS-8640000 CENTI-SECS/DAY B-33
		PUSH	DMP		# T IN DAYS
			KOMEGAC
		SL	DAD
			9D
			CARG
		SIN	DMP
			CMOD
		PDDL
		DMP	SL
			LOSR
			6
		DAD	DSU
			LOSO
		PUSH	SIN
		PUSH	DMP
			KONMAT3
		SL1	PDDL
		DMP	SL1
			KONMAT1
		PDDL	COS
			0
		VDEF	UNIT
		PUSH	RVQ

LOSR		2DEC*	.00273780317 B+4*
KOMEGAC		2DEC*	.00273777859 B+1*
CSTODAY		2DEC	8640000 B-32
KONMAT1		2DEC*	.91745773 B-1*
KONMAT3		2DEC*	.397833274 B-1*
