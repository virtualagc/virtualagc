### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	GIMBAL_LOCK_AVOIDANCE.agc
## Purpose: 	Part of the source code for Luminary 1A build 099.
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC), for Apollo 11.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	364
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2010-12-31 JL	Fixed page number comment.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				but no errors found.
##		2017-03-03 RSB	Snapshot of Luminary 99 Rev 1. 
##		2017-03-15 RSB	Comment-text proofed using 5-way
##				side-by-side diff of Luminary 69/99/116/131/210,
##				but no errors (or any differences) found.
##		2017-08-22 RSB	Fixed comment-text typo identified in ZERLINA 56.

## Page 364
		BANK	15
		
		SETLOC	KALCMON1
		BANK
		
# DETECTING GIMBAL LOCK
LOCSKIRT	EQUALS	NOGIMLOC

NOGIMLOC	SET
			CALCMAN3
WCALC		LXC,1	DLOAD*
			RATEINDX	# CHOOSE THE DESIRED MANEUVER RATE
			ARATE,1		# FROM A LIST OF FOUR
		SR4	CALL		# COMPUTE THE INCREMENTAL ROTATION MATRIX
			DELCOMP		# DEL CORRESPONDING TO A 1 SEC ROTATION
					# ABOUT COF
		DLOAD*	VXSC
			ARATE,1
			COF
		STODL	BRATE		# COMPONENT MANEUVER RATES 45 DEG/SEC
			AM
		DMP	DDV*
			ANGLTIME
			ARATE,1
		SR
			5
		STORE	TM		# MANEUVER EXECUTION TIME SCALED AS T2
		SETGO	
			CALCMAN2	# 0(OFF) = CONTINUE MANEUVER
			NEWANGL +1	# 1(ON) = START MANEUVER
			
# THE FOUR SELECTABLE FREE FALL MANEUVER RATES SELECTED BY
# LOADING RATEINDX WITH 0, 2, 4, 6, RESPECTIVELY

ARATE		2DEC	.0088888888	# = 0.2 DEG/SEC		$ 22.5 DEG/SEC

		2DEC	.0222222222	# = 0.5 DEG/SEC		$ 22.5 DEG/SEC
		
		2DEC	.0888888888	# = 2.0 DEG/SEC		$ 22.5 DEG/SEC
		
		2DEC	.4444444444	# = 10.0 DEG/SEC	$ 22.5 DEG/SEC
		
ANGLTIME	2DEC	.0001907349	# = 100B-19 FUDGE FACTOR TO CONVERT
					# MANEUVER ANGLE TO MANEUVER TIME
					

