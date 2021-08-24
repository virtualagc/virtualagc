### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc
## Purpose:     A section of Luminary revision 97.
##              It is part of the reconstructed source code for the
##              second release of the flight software for the Lunar 
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 11.
##              It was created to fix two incorrect ephemeris constants in
##              Luminary 96, as described by anomaly report LNY-59.
##              The code has been recreated from a copy of Luminary 99
##              revision 001, using asterisks indicating changed lines in
##              the listing and Luminary Memos #83 and #85, which list 
##              changes between Luminary 97 and 98, and 98 and 99. The
##              code has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 97 in NASA drawing
##              2021152D, which gives relatively high confidence that the
##              reconstruction is correct.
## Reference:   pp. 984-987
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-28 MAS  Created from Luminary 99.

## Page 984
# NAME - LSPOS - LOCATE SUN AND MOON			DATE - 25 OCT 67
# MOD NO. 1
# MOD BY NEVILLE					ASSEMBLY SUNDANCE
#
# FUNCTIONAL DESCRIPTION
#
#        COMPUTES UNIT POSITION VECTOR OF THE SUN AND MOON IN THE BASIC REFERENCE SYSTEM. THE SUN VECTOR S IS
# LOCATED VIA TWO ANGLES. THE FIRST ANGLE(OBLIQUITY) IS THE ANGLE BETWEEN THE EARTH EQUATOR AND THE ECLIPTIC. THE
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
# SIN(OBL), AND COS(OBL)*SIN(IM) ARE STORED IN KONMAT AS K1, K2, K3 AND K4, RESPECTIVELY.  LOM , LOM , LON , LON                                   
# ARE STORED AS LOMO, LOMR, LONO, AND LONR IN RATESP.                                         0     R     0     R
# THE THREE PHIS ARE STORED AS AARG, BARG, AND CARG(SUN).  ALL CONSTANTS ARE UPDATED BY YEAR.
#
# CALLING SEQUENCE
## Page 985
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
LUNPOS		EQUALS	LSPOS

LSPOS		SETPD	SR
			0
			14D		# TP
		TAD	DDV
## The hand-written notation "in centisec B 42" appears to the right.	
			TEPHEM		# TIME OF LAUNCH
			CSTODAY		# 24 HOURS-8640000 CENTI-SECS/DAY B-33
## The hand-written notation "@ B 9 = 512 days" appears to the right.
		STORE	TIMEP		# T IN DAYS
## The hand-written notation "&there4; granularity &asymp; 0.164 sec" appears to the right.
		AXT,1	AXT,2
			0
			0
		CLEAR
			FREEFLAG	# SWITCH BIT
POSITA		DLOAD
			KONMAT +2	# ZEROS
		STORE	GTMP
POSITB		DLOAD	DMP*
			TIMEP		# T
			VAL67 +4,1	# 1/27 OR 1/32 OR 1/365
## Page 986
		SL	DAD*
			8D
			VAL67 +2,1	# AARG
		SIN	DMP*		# SIN(T/27+PHI) OR T/32 OR T/365
			VAL67,1		# (A0**2+A1**2)**1/2 SIN(X+PHIA)
		DAD	INCR,1		# PLUS
			GTMP		# (B0**2+B1**2)**1/2 SIN(X+PHIB)
		DEC	-6
		STORE	GTMP		# OR (C0**2+C1**2)**1/2 SIN(X+PHIC)
		BOFSET
			FREEFLAG
			POSITB
POSITD		DLOAD	DMP*
			TIMEP		# T
			RATESP,2	# LOMR,LOSR,LONR
		SL	DAD*
			5D
			RATESP +6,2	# LOMO,LOSO,LONO
		DSU
			GTMP
		STORE	STMP,2		# LOM,LOS,LON
		SLOAD	INCR,2
			X2
		DEC	-2
		DAD	BZE
			RCB-13		# PLUS 2
			POSITE		# 2ND
		BPL
			POSITA		# 1ST
POSITF		DLOAD	DSU		# 3RD
			STMP		# LOM
			STMP +4		# LON
		SIN	PDDL		# SIN(LOM-LON)
			STMP
		SIN	PDDL		# SIN LOM
			STMP
		COS	VDEF		# COS LOM
		MXV	UNIT
			KONMAT		# K1,K2,K3,K4,
		STORE	VMOON
		DLOAD	PDDL
			KONMAT +2	# ZERO
			STMP +2
		SIN	PDDL		# SIN LOS
			STMP +2
		COS	VDEF		# COS LOS
		MXV	UNIT
			KONMAT
		STORE	VSUN
		RVQ
## Page 987
POSITE		DLOAD
			KONMAT +2	# ZEROS
		STORE	GTMP
		GOTO
			POSITD
LUNVEL		RVQ			#        TO FOOL INTEGRATION
		SETLOC	EPHEM1
		BANK

		COUNT*	$$/EPHEM
STMP		EQUALS	16D
GTMP		EQUALS	22D
TIMEP		EQUALS	24D

