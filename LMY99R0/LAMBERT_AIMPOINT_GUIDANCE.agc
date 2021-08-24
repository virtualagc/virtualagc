### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LAMBERT_AIMPOINT_GUIDANCE.agc
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
## Pages:	651-653
## Mod history:	2009-05-18 RSB	Transcribed from Luminary 099
##				page images.
##		2009-06-05 RSB	Corrected 4 typos.
##		2009-06-07 RSB	Fixed a typo.
##		2016-12-14 RSB	VNP00H -> VNPOOH.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
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

## Page 651

# GENERAL LAMBERT AIMPOINT GUIDANCE **
# WRITTEN BY RAMA M AIYAWAR

# PROGRAM P-31 DESCRIPTION **
#
# 1.	TO ACCEPT TARGETING PARAMETERS OBTAINED FROM A SOURCE EXTERNAL
#	TO THE LEM AND COMPUTE THERE FROM THE REQUIRED-VELOCITY AND
#	OTHER INITIAL CONDITIONS REQUIRED BY LM FOR DESIRED MANEUVER.
#	THE TARGETING PARAMETERS ARE TIG (TIME OF IGNITION), TARGET 
#	VECTOR (RTARG), AND THE TIME FROM TIG UNTIL THE TARGET IS
#	REACHED (DELLT4), DESIRED TIME OF FLIGHT FROM RINIT TO RTARG..

# ASSUMPTIONS **
#
# 1.	THE TARGET PARAMETERS MAY HAVE BEEN LOADED PRIOR TO THE
#	EXECUTION OF THIS PROGRAM.
# 2.	THIS PROGRAM IS APPLICABLE IN EITHER EARTH OR LUNAR ORBIT.
# 3.	THIS PROGRAM IS DESIGNED FOR ONE-MAN OPERATION, AND SHOULD
#	BE SELECTED BY THE ASTRONAUT BY DSKY ENTRY V37 E31.

# SUBROUTINES USED **
# 
# MANUPARM, TTG/N35, R02BOTH, MIDGIM, DISPMGA, FLAGDOWN, BANKCALL,
# GOTOPOOH, ENDOFJOB, PHASCHNG, GOFLASHR, GOFLASH.
#
# MANUPARM	CALCULATES APOGEE, PERIGEE ALTITUDES AND DELTAV DESIRED
#		FOR THE MANEUVER.
#
# TTG/N35	CLOCKTASK - UPDATES CLOCK.
#
# MIDGIM	CALCULATES MIDDLE GIMBAL ANGLE FOR DISPLAY.
#
# R02BOTH	IMU - STATUS CHECK ROUTINE.

# DISPLAYS USED IN P-31LM **
#
# V06N33	DISPLAY SOTRED TIG (IN HRS. MINS. SECS)
# V06N42	DISPLAY APOGEE, PERIGEE, DELTAV.
# V16N35	DISPLAY TIME FROM TIG.
# V06N45	TIME FROM IGNITION AND MIDDLE GIMBAL ANGLE.

# ERASABLE INITIALIZATION REQUIRED **
#
# TIG		TIME OF IGNITION		DP	(B+28) CS.
#
# DELLT4	DESIRED TIME OF FLIGHT		DP	(B+28) CS
#		FROM RINIT TO RTARG.
#
# RTARG		RADIUS VECTOR OF TARGET POSITION VECTOR
#		RADIUS VECTOR SCALED TO (B+29)METERS IF EARTH ORBIT
## Page 652
#		RADIUS VECTOR SCALED TO (B+27)METERS IF MOON ORBIT

# OUTPUT **
#
# HAPO		APOGEE ALTITUDE
# HPER		PERIGEE ALTITUDE
# VGDISP	MAG. OF DELTAV FOR DISPLAY, SCALING	B+7 M/CS EARTH
# 		MAG. OF DELTAV FOR DISPLAY, SCALING	B+5 M/CS MOON
# MIDGIM	MIDDLE GIMBAL ANGLE
# XDELVFLG	RESETS XDELVFLG FOR LAMBERT VG COMPUTATIONS

# ALARMS OR ABORTS	NONE **

# RESTARTS ARE VIA GROUP 4 **

		SETLOC	GLM
		BANK
		
		EBANK=	SUBEXIT
		
		COUNT*	$$/P31
P31		TC	P20FLGON
		CAF	V06N33		# TIG
		TC	VNPOOH
		TC	INTPRET
		CLEAR	DLOAD
			UPDATFLG
			TIG
		STCALL	TDEC1		# INTEGRATE STATE VECTORS TO TIG
			LEMPREC
		VLOAD	SETPD
			RATT
			0D
		STORE	RTIG
		STOVL	RINIT
			VATT
		STORE	VTIG
		STODL	VINIT
			P30ZERO
		PUSH	PDDL		# E4 AND NUMIT = 0
			DELLT4
		DAD	SXA,1
			TIG
			RTX1
		STORE	TPASS4
		SXA,2	CALL
			RTX2
			INITVEL
		VLOAD	PUSH
## Page 653
			DELVEET3
		STORE	DELVSIN
		ABVAL	CLEAR
			XDELVFLG
		STCALL	VGDISP
			GET.LVC
		VLOAD	PDVL
			RTIG
			VIPRIME
		CALL
			PERIAPO1
		CALL
			SHIFTR1
		CALL			# LIMIT DISPLAY TO 9999.9 N. MI.
			MAXCHK
		STODL	HPER
			4D
		CALL
			SHIFTR1
		CALL			# LIMIT DISPLAY TO 9999.9 N. MI.
			MAXCHK
		STORE	HAPO
		EXIT
		CAF	V06N81		# DELVLVC
		TC	VNPOOH
		CAF	V06N42		# HAPO, HPER, VGDISP
		TC	VNPOOH
		TC	INTPRET
REVN1645	SET	CALL		# TRKMKCNT, TTOGO, +MGA
			FINALFLG
			VN1645
		GOTO
			REVN1645

