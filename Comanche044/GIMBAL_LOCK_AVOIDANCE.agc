### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GIMBAL_LOCK_AVOIDANCE.agc
## Purpose:     A section of Comanche revision 044.
##              It is part of the reconstructed source code for the
##              original release of the flight software for the Command
##              Module's (CM) Apollo Guidance Computer (AGC) for Apollo 10.
##              The code has been recreated from a copy of Comanche 055. It
##              has been adapted such that the resulting bugger words
##              exactly match those specified for Comanche 44 in NASA drawing
##              2021153D, which gives relatively high confidence that the
##              reconstruction is correct.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-12-03 MAS  Created from Comanche 51.
##              2020-12-04 MAS  Changed the last ARATE entry back to 4 deg/s.
##		2020-12-11 RSB	Added justifying annotations for Mike's 
##				reconstruction steps.

## Page 412
		BANK	15		
		SETLOC	KALCMON1
		BANK
		
		EBANK=	BCDU
		
# DETECTING GIMBAL LOCK
LOCSKIRT	EQUALS	WCALC
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
		SETGO			# STATE SWITCH CALCMAN2 (43D)
			CALCMAN2	# 0(OFF) = BYPASS STARTING PROCEDURE
			NEWANGL +1	# 1(ON) = START MANEUVER
			
			
ARATE		2DEC	.0022222222	# = .05 DEG/SEC

		2DEC	.0088888889	# = .2 DEG/SEC
		
		2DEC	.0222222222	# = .5 DEG/SEC
		
## <b>Reconstruction:</b> The following value has been changed from its
## Comanche 51 value (2 degrees per seconds) to its Colossus 249 (Apollo 9)
## value.  This is justified by 
## <a href="http://www.ibiblio.org/apollo/Documents/Programmed%20Guidance%20Equations%20for%20Colossus%202.pdf#page=14">
## <i>Programmed Guidance Equations for Colossus 2</i>, p. ATTM-14</a>
		2DEC	.1777777777	# = 4 DEG/SEC		$ 22.5 DEG/SEC
		
ANGLTIME	2DEC	.000190735	# = 100B - 19

					# MANEUVER ANGLE TO MANEUVER TIME
QUADROT		2DEC	.1		# ROTATION MATRIX FROM S/C AXES TO CONTROL

## Page 413
		2DEC	0		# AXES (X ROT = -7.25 DEG)
		
		2DEC	0
		
		2DEC	0
		
		2DEC	.099200		# =(.1)COS7.25
		
		2DEC	-.012620	# =-(.1)SIN7.25
		
		2DEC	0
		
		2DEC	.012620		# (.1)SIN7.25
		
		2DEC	.099200		# (.1)COS7.25
		
BIASCALE	2DEC	.0002543132	# = (450/180)(1/0.6)(1/16384)
