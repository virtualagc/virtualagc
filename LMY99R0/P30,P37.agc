### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	P30,P37.agc
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
## Pages:	614-617
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2009-06-05 RSB	Removed 4 lines of code that shouldn't
##				have survived from Luminary 131.
##		2016-12-13 RSB	GOTOP00H -> GOTOPOOH
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

## Page 614
# PROGRAM DESCRIPTION P30	DATE 3-6-67
#
# MOD.1 BY RAMA AIYAWAR
#
# FUNCTIONAL DESCRIPTION
#	ACCEPT ASTRONAUT INPUTS OF TIG,DELV(LV)
#	CALL IMU STATUS CHECK ROUTINE (R02)
#	DISPLAY TIME TO GO, APOGEE, PERIGEE, DELV(MAG), MGA AT IGN
#	REQUEST BURN PROGRAM
#
# CALLING SEQUENCE VIA JOB FROM V37
#
# EXIT VIA V37 CALL OR TO GOTOPOOH (V34E)
#
# SUBROUTINE CALLS -	FLAGUP, PHASCHNG, BANKCALL, ENDOFJOB, GOFLASH, GOFLASHR
#			GOPERF3R, INTPRET, BLANKET, GOTOPOOH, R02BOTH, S30.1,
#			TTG/N35, MIDGIM, DISPMGA
#
# ERASABLE INITIALIZATION - STATE VECTOR
#
# OUTPUT - 	RINIT, VINIT, +MGA, VTIG, RTIG, DELVSIN, DELVSAB, DELVSLV, HAPO,
#	    	HPER, TTOGO
#
# DEBRIS - A, L, MPAC, PUSHLIST

		BANK	32
		SETLOC	P30S
		BANK
		EBANK=	+MGA
		COUNT*	$$/P30
P30		TC	UPFLAG		# SET UPDATE FLAG
		ADRES	UPDATFLG
		TC	UPFLAG		# SET TRACK FLAG
		ADRES	TRACKFLG
		
P30N33		CAF	V06N33		# T OF IGN
		TC	VNPOOH		# RETURNS ON PROCEED, POOH ON TERMINATE
		
		CAF	V06N81		# DISPLAY DELTA V (LV)
		TC	VNPOOH		#	REDISPLAY ON RECYCLE
					
		TC	DOWNFLAG	# RESET UPDATE FLAG
		ADRES	UPDATFLG
		TC	INTPRET
		CALL
			S30.1
		SET	EXIT
			UPDATFLG
PARAM30		CAF	V06N42		# DISPLAY APOGEE,PERIGEE,DELTA V
		TC	VNPOOH
## Page 615		
		
		TC	INTPRET
		SETGO
			XDELVFLG	# FOR P40'S: EXTERNAL DELTA-V GUIDANCE.
			REVN1645	# TRKMKCNT, TGO, +MGA  DISPLAY
			
V06N33		VN	0633
V06N42		VN	0642

## Page 616
# PROGRAM DESCRIPTION S30.1	DATE 9NOV66
# MOD NO 1			LOG SECTION P30,P37
# MOD BY RAMA AIYAWAR **
#
# FUNCTIONAL DESCRIPTION
#	BASED ON STORED TARGET PARAMETERS (R OF IGNITION (RTIG), V OF
#	IGNITION (VTIG), TIME OF IGNITION (TIG)), COMPUTE PERIGEE ALTITUDE
#	APOGEE ALTITUDE AND DELTAV REQUIRED (DELVSIN).
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		S30.1
#
# NORMAL EXIT MODE
#	AT L+2 OR CALLING SEQUENCE (GOTO L+2)
#
# SUBROUTINES CALLED
#	LEMPREC
#	PERIAPO
#
# ALARM OR ABORT EXIT MODES
#	NONE
#
# ERASABLE INITIALIZATION REQUIRED
#	TIG		TIME OF IGNITION	DP B28CS
#	DELVSLV		SPECIFIED DELTA-V IN LOCAL VERT.
#			COORDS. OF ACTIVE VEHICLE AT
#			TIME OF IGNITION	VECTOR B+7 METERS/CS
#
# OUTPUT
#	RTIG		POSITION AT TIG		VECTOR B+29 METERS
#	VTIG		VELOCITY AT TIG		VECTOR B+29 METERS/CS
#	PDL 4D		APOGEE ALTITUDE		DP B+29 M, B+27 METERS.
#	HAPO		APOGEE ALTITUDE		DP B+29 METERS
#	PDL 8D		PERIGEE ALTITUDE	DP B+29 M, B+27 METERS.
#	HPER		PERIGEE ALTITUDE	DP B+29 METERS
#	DELVSIN		SPECIFIED DELTA-V IN INERTIAL
#			COORD. OF ACTIVE VEHICLE AT
#			TIME OF IGNITION	VECTOR B+7 METERS/CS
#	DELVSAB		MAG. OF DELVSIN		VECTOR B+7 METERS/CS
#
# DEBRIS	QTEMP	TEMP.ERASABLE
#		QPRET, MPAC
#		PUSHLIST

		SETLOC	P30S1
		BANK
		
		COUNT*	$$/S30S
		
S30.1		STQ	DLOAD
			QTEMP
			TIG		# TIME IGNITION SCALED AT 2(+28)CS
		STCALL	TDEC1
			LEMPREC		# ENCKE ROUTINE FOR LEM
			
		VLOAD	SXA,2
## Page 617
			RATT
			RTX2
		STORE	RTIG		# RADIUS VECTOR AT IGNITION TIME
		UNIT	VCOMP
		STOVL	DELVSIN		# ZRF/LV IN DELVSIN SCALED AT 2
			VATT		# VELOCITY VECTOR AT TIG, SCALED 2(7) M/CS
		STORE	VTIG
		VXV	UNIT
			RTIG
		SETPD	SXA,1
			0
			RTX1
		PUSH	VXV		# YRF/LV PDL 0 SCALED AT 2
			DELVSIN
		VSL1	PDVL
		PDVL	PDVL		# YRF/LV PDL 6 SCALED AT 2
			DELVSIN		# ZRF/LV PDL 12D SCALED AT 2
			DELVSLV
		VXM	VSL1
			0
		STORE	DELVSIN		# DELTAV IN INERT. COOR. SCALED TO B+7M/CS
		ABVAL
		STOVL	DELVSAB		# DELTA V MAG.
			RTIG		# (FOR PERIAPO)
		PDVL	VAD		# VREQUIRED = VTIG + DELVSIN (FOR PERIAPO)
			VTIG
			DELVSIN
		CALL
			PERIAPO1
		CALL
			SHIFTR1		# RESCALE IF NEEDED
		CALL			# LIMIT DISPLAY TO 9999.9 N. MI.
			MAXCHK
		STODL	HPER		# PERIGEE ALT 2(29) METERS, FOR DISPLAY
			4D
		CALL
			SHIFTR1		# RESCALE IF NEEDED
		CALL			# LIMIT DISPLAY TO 9999.9 N. MI.
			MAXCHK
		STCALL	HAPO		# APOGEE ALT 2(29) METERS, FOR DISPLAY
			QTEMP
			

