# Copyright:	Public domain.
# Filename:	GIMBAL_LOCK_AVOIDANCE.agc
# Purpose:	Part of the source code for Colossus build 237.  
#		This is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), we believe for Apollo 8.
# Assembler:	yaYUL
# Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Colossus237/
# Mod history:	2010-06-01 OH	Adapted from corresponding Colossus 249 file.
#
# The contents of the "Colossus237" files, in general, are transcribed 
# from a scanned document obtained from Fred Martin.  Notations on this
# document read, in part:
#
#	Assemble revision 237 of AGC program Colossus by NASA
#	2021111-031.  August 24, 1968.  
#
#	This AGC program shall also be referred to as
#				Colossus 1A
#
#	Prepared by
#			Massachusetts Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors to info@sandroid.org.
#

# Page 403
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
		2DEC	.1777777777	# = 4 DEG/SEC
		
ANGLTIME	2DEC	.000190735	# = 100B-19 
					# MANEUVER ANGLE TO MANEUVER TIME
# Page 404
QUADROT		2DEC	.1		# ROTATION MATRIX FROM S/C AXES TO CONTROL
		2DEC	0		# AXES (X ROT = -7.25 DEG)
		2DEC	0
		2DEC	0
		2DEC	.099200		# = (.1)COS7.25
		2DEC	-.012620	# =-(.1)SIN7.25
		2DEC	0
		2DEC	.012620		# (.1)SIN7.25
		2DEC	.099200		# (.1)COS7.25
BIASCALE	2DEC	.0002543132	# (450/180)(1/0.6)(1/16384)
	

