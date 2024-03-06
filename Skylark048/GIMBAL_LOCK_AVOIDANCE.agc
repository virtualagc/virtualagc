### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	GIMBAL_LOCK_AVOIDANCE.agc
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
## Mod history:	2023-09-04 MAS  Created from Artemis 072.
##		2024-03-04 MAS  Updated for Skylark 48.

		
		SETLOC	KALCMON1
		BANK
		
		COUNT*	$$/KALC
		EBANK=	BCDU
		
# DETECTING GIMBAL LOCK
LOCSKIRT	SLOAD	BHIZ
			WHICHDAP
			WCALC
		
		SLOAD	DMP
			DKRATE
			TUFITDK
		SR4	CALL		# COMPUTE THE INCREMENTAL ROTATION MATRIX
			DELCOMP		# DEL CORRESPONDING TO A 1 SEC ROTATION
					# ABOUT COF
		SLOAD	DMP
			DKRATE
			TUFITDK
		PUSH	VXSC
			COF
		MXV
			QUADROT
		STODL	BRATE
			AM
		DMP	DDV
			ANGLTIME
		SR
			5
		STODL	TM
			BRATE +4
		ABVAL	DMP
			BRATE +4
		PDDL	ABVAL
			BRATE +2
		DMP	PDDL
			BRATE +2
			BRATE
		ABVAL	DMP
			BRATE
		VDEF	VXSC
			1/2ALPHA
		STCALL	BIASTEMP
			WCALCOUT

WCALC		LXC,1	DLOAD*
			RATEINDX
			ARATE,1	
		SR4	CALL		# COMPUTE THE INCREMENTAL ROTATION MATRIX
			DELCOMP		# DEL CORRESPONDING TO A 1 SEC ROTATION
					# ABOUT COF
		DLOAD*	VXSC
			ARATE,1
			COF
		MXV
			QUADROT
		STODL	BRATE	
			AM
		DMP	DDV*
			ANGLTIME
			ARATE,1
		SR
			5
		STOVL	TM
			BRATE
		VXSC
			BIASCALE
		STORE	BIASTEMP	# ATTITUDE ERROR BIAS TO PREVENT OVERSHOOT
					# IN SYSTEM
## The following label name is a guess.
WCALCOUT	BON	SETGO		# STATE SWITCH CALCMAN2 (43D)
			CYC61FLG
			RCYCLR61
			CALCMAN2	# 0(OFF) = BYPASS STARTING PROCEDURE
			NEWANGL +1	# 1(ON) = START MANEUVER
			
			
ARATE		2DEC	.0022222222	# = .05 DEG/SEC
		2DEC	.0088888889	# = .2 DEG/SEC
		2DEC	.0222222222	# = .5 DEG/SEC
		2DEC	.0888888889	# = 2 DEG/SEC                $22.5 DEG/SEC
ANGLTIME	2DEC	.000190735	# = 100B - 19
					# MANEUVER ANGLE TO MANEUVER TIME
QUADROT		2DEC	.1		# ROTATION MATRIX FROM S/C AXES TO CONTROL
		2DEC	0		# AXES (X ROT = -7.25 DEG)
		2DEC	0
		2DEC	0
		2DEC	.099200		# =(.1)COS7.25
		2DEC	-.012620	# =-(.1)SIN7.25
		2DEC	0
		2DEC	.012620		# (.1)SIN7.25
		2DEC	.099200		# (.1)COS7.25
BIASCALE	2DEC	.0002543132	# = (450/180)(1/0.6)(1/16384)
TUFITDK		2DEC	0.3125
