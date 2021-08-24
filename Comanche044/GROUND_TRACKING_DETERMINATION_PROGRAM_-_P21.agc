### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc
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
##              2020-12-04 MAS  Removed the SL* 0,2 for P21VEL in P21VSAVE.
##		2020-12-11 RSB	Added justification annotations for Mike's
##				reconstruction steps.
##		2020-12-13 RSB	Added feedback about the annotations.

## Page 456
# GROUND TRACKING DETERMINATION PROGRAM P21
#
# PROGRAM DESCRIPTION
# MOD NO - 1
# MOD BY - N. M. NEVILLE
# FUNCTIONAL DECRIPTION-

# TO PROVIDE THE ASTRONAUT DETAILS OF THE LM OR CSM GROUND TRACK WITHOUT
# THE NEED FOR GROUND COMMUNICATION (REQUESTED BY DSKY).
# CALLING SEQUENCE-

# ASTRONAUT REQUEST THROUGH DSKY V37E21E
# SUBROUTINES CALLED-

# GOPERF4
# GOFLASH
# THISPREC
# OTHPREC
# LAT-LONG
# NORMAL EXIT MODES-

# ASTRONAUT REQUEST TROUGH DSKY TO TERMINATE PROGRAM V34E
# ALARM OR ABORT EXIT MODES-

# NONE
# OUTPUT-

# OCTAL DISPLAY OF OPTION CODE AND VEHICLE WHOSE GROUND TRACK IS TO BE
# COMPUTED
#	   OPTION CODE	00002
#	   THIS		00001
#	   OTHER		00002
# DECIMAL DISPLAY OF TIME TO BE INTEGRATED TO HOURS , MINUTES , SECONDS
# DECIMAL DISPLAY OF LAT,LONG,ALT
# ERASABLE INITIALIZATION REQUIRED

# AX0	 2DEC	4.652459653 E-5   RADIANS       %68-69 CONSTANTS"

# -AY0	 2DEC	2.147535898 E-5   RADIANS

# AZ0	 2DEC	.7753206164	  REVOLUTIONS
# FOR LUNAR ORBITS 504LM VECTOR IS NEEDED

# 504LM	 2DEC	-2.700340600 E-5  RADIANS

# 504LM _2 2DEC	-7.514128400 E-4  RADIANS

# 504LM _4 2DEC	_2.553198641 E-4  RADIANS
#
# NONE
# DEBRIS

## Page 457
# CENTRALS-A,Q,L
# OTHER-THOSE USED BY THE ABOVE LISTED SUBROUTINES
# SEE LEMPREC, LAT-LONG

		SBANK=	LOWSUPER	# FOR LOW 2CADR'S.

		BANK	33
		SETLOC	P20S
		BANK

		EBANK=	P21TIME
		COUNT	24/P21
		
PROG21		CAF	ONE
		TS	OPTION2		# ASSUMED VEHICLE IS LM, R2 = 00001
		CAF	BIT2		#  OPTION 2
		TC	BANKCALL
		CADR	GOPERF4
		TC	GOTOPOOH	# TERMINATE
		TC	+2		# PROCEED VALUE OF ASSUMED VEHICLE OK
		TC	-5		# R2 LOADED THROUGH DSKY
P21PROG1	CAF	V6N34		# LOAD DESIRED TIME OF LAT-LONG.
		TC	BANKCALL
		CADR	GOFLASH
		TC	GOTOPOOH	# TERM
		TC	+2		# PROCEED VALUES OK
		TC	-5		# TIME LOADED THROUGH DSKY
		TC	INTPRET
		DLOAD	
			DSPTEM1
		STCALL	TDEC1		# INTEG TO TIME SPECIFIED IN TDEC
			INTSTALL
		BON	SET
			P21FLAG
			P21CONT		# ON...RECYCLE USING BASE VECTOR
			VINTFLAG	# OFF..1ST PASS CALC BASE VECTOR
		SLOAD	SR1
			OPTION2
		BHIZ	CLEAR
			+2		# ZERO..THIS VEHICLE (CM)
			VINTFLAG	# ONE...OTHER VEHICLE(LM)
		CLEAR	CLEAR
			DIM0FLAG
			INTYPFLG	# PRECISION
		CALL
			INTEGRV		# CALCULATE
		GOTO			# .AND
			P21VSAVE	# ..SAVE BASE VECTOR
P21CONT		VLOAD			# RECYCLE..INTEG FROM BASE VECTOR			
			P21BASER
## Page 458		
		STOVL	RCV		# ..POS
			P21BASEV
		STODL	VCV		# ..VEL
			P21TIME
		STORE	TET		# ..TIME
		CLEAR	CLEAR
			DIM0FLAG
			MOONFLAG
		SLOAD	BZE
			P21ORIG
			+3		# ZERO = EARTH
		SET			# ...2 = MOON
			MOONFLAG
		CALL
			INTEGRVS
P21VSAVE	DLOAD			# SAVE CURRENT BASE VECTOR
			TAT
		STOVL	P21TIME		# ..TIME
			RATT1
		STOVL	P21BASER	# ..POS B-29 OR B-27
			VATT1
		STORE	P21BASEV	# ..VEL B-7  OR B-5
## <b>Reconstruction:</b> This change, from<br>
## <pre>
##    ABVAL   SL*
##            0,2
## </pre>
## to simply ABVAL, is justified by 
## <a href="http://www.ibiblio.org/apollo/Documents/Programmed%20Guidance%20Equations%20for%20Colossus%202.pdf#page=83">
## <i>Programmed Guidance Equations for Colossus 2</i>, p. ORVN-3</a>.  (The indicated change,
## from Comanche 45/2 to Comanche 55, is that an absolute value is taken, shifted right by
## two bits, and then stored, so the only actual change in the code is the shift, with the
## the absolute value and storage remain unchanged.  The change bars refer to changes in the
## <i>document</i> rather than changes in the code.)		
		ABVAL
		STOVL	P21VEL		# /VEL/ FOR N73 DSP
			RATT
		UNIT	DOT
			VATT		# U(R).(V)
		DDV	ASIN		# U(R).U(V)
			P21VEL
		STORE	P21GAM		# SIN-1 U(R).U(V), -90 TO +90
		SXA,2	SET
			P21ORIG		# 0 = EARTH  2 = MOON
			P21FLAG
P21DSP		CLEAR	SLOAD		# GENERATE DISPLAY DATA
			LUNAFLAG
			X2
		BZE	SET
			+2		# 0 = EARTH
			LUNAFLAG
		VLOAD
			RATT
		STODL	ALPHAV
			TAT
		CLEAR	CALL
			ERADFLAG
			LAT-LONG
		DMP			# MPAC = ALT, METERS B-29
			K.01
		STORE	P21ALT		# ALT/100 FOR N73 DSP
## Page 459		
		EXIT
		CAF	V06N43		# DISPLAY LAT,LONG,ALT
		TC	BANKCALL	# LAT,LONG = REVS B0 BOTH EARTH/MOON
		CADR	GOFLASH		# ALT = METERS B-29  BOTH EARTH/MOON
		TC	GOTOPOOH	# TERM
		TC	GOTOPOOH
		TC	INTPRET		# V32E RECYCLE
		DLOAD	DAD
			P21TIME
			600SEC		# 600 SECONDS OR 10 MIN
		STORE	DSPTEM1
		RTB	
			P21PROG1
	
600SEC		2DEC	60000		# 10 MIN

P21ONENN	OCT	00001		# NEEDED TO DETERMINE VEHICLE
		OCT	00000		# TO BE INTEGRATED
V06N43		VN	00643
V6N34		VN	00634
K.01		2DEC	.01

