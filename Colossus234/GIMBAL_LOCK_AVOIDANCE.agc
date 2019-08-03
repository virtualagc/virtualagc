### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GIMBAL_LOCK_AVOIDANCE.agc
## Purpose:     A section of Colossus revision 234.
##              It is part of the reconstructed source code for the first
##              (unmanufactured) release of the flighta software for the
##              Command Module's (CM) Apollo Guidance Computer (AGC) for
##              Apollo 8. The code has been recreated from a copy of
##              Colossus 237. It has been adapted such that the resulting
##              bugger words exactly match those specified for Colossus 234
##              in NASA drawing 2021151B, which gives relatively high
##              confidence that the reconstruction is correct.
## Reference:   403
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              COLOSSUS 234.
## Mod history: 2019-08-02 MAS  Created from Colossus 237.

## Page 403
		BANK	15
		SETLOC	KALCMON1
		BANK

		EBANK=	BCDU

# DETECTING GIMBAL LOCK
LOCSKIRT	EQUALS	NOGIMLOC

NOGIMLOC	SET
			CALCMAN3
WCALC		LXC,1	DLOAD*
			RATEINDX
			ARATE,1	
		SR4	CALL		# COMPUTE THE INCREMENTAL ROTATION MATRIX
			DELCOMP		# DEL CORRESPONDING TO A 1 SEC ROTATION
#					  ABOUT COF
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
#					  IN SYSTEM
		SETGO			# STATE SWITCH CALCMAN2 (43D)
			CALCMAN2	# 0(OFF) = BYPASS STARTING PROCEDURE
			NEWANGL +1	# 1(ON) = START MANEUVER


ARATE		2DEC	.0022222222	# = .05 DEG/SEC
		2DEC	.0088888889	# = .2 DEG/SEC
		2DEC	.0222222222	# = .5 DEG/SEC
		2DEC	.1777777777	# = 4 DEG/SEC		    $ 22.5 DEG/SEC
ANGLTIME	2DEC	.000190735	# = 100B - 19 
#					  MANEUVER ANGLE TO MANEUVER TIME
## Page 404
QUADROT		2DEC	.1		# ROTATION MATRIX FROM S/C AXES TO CONTROL
		2DEC	0		# AXES  (X ROT = -7.25 DEG)
		2DEC	0
		2DEC	0
		2DEC	.099200		# =(.1)COS7.25
		2DEC	-.012620	# =-(.1)SIN7.25
		2DEC	0
		2DEC	.012620		# (.1)SIN7.25
		2DEC	.099200		# (.1)COS7.25
BIASCALE	2DEC	.0002543132	# = (450/180)(1/0.6)(1/16384)
