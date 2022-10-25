### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	GIMBAL_LOCK_AVOIDANCE.agc
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
## Pages:	364
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2010-12-31 JL	Fixed page number comment.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				but no errors found.
##		2017-08-01 MAS	Created from LMY99 Rev 1.
##		2017-08-22 RSB	Fixed comment-text typo identified in ZERLINA 56.

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
					

