### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P76.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.

## Page 511
# 1)	PROGRAM NAME - TARGET DELTA V PROGRAM (P76).
# 2)	FUNCTIONAL DESCRIPTION - UPON ENTRY BY ASTRONAUT ACTION, P76 FLASHES DSKY REQUESTS TO THE ASTRONAUT
#	TO PROVIDE VIA DSKY (1) THE DELTA V TO BE APPLIED TO THE OTHER VEHICLE STATE VECTOR AND (2) THE
#	TIME (TIG) AT WHICH THE OTHER VEHICLE VELOCITY WAS CHANGED BY EXECUTION OF A THRUSTING MANEUVER. THE
#	OTHER VEHICLE STATE VECTOR IS INTEGRATED TO TIG AND UPDATED BY THE ADDITION OF DELTA V (DELTA V HAVING
#	BEEN TRANSFORMED FROM LV TO REF COSYS).  USING INTEGRVS, THE PROGRAM THEN INTEGRATES THE OTHER
#	VEHICLE STATE VECTOR TO THE STATE VECTOR OF THIS VEHICLE, THUS INSURING THAT THE W-MATRIX AND BOTH VEHICLE
#	STATES CORRESPOND TO THE SAME TIME.
# 3)	ERASABLE INITIALIZATION REQUIRED - NONE.
# 4)	CALLING SEQUENCES AND EXIT MODES - CALLED BY ASTRONAUT REQUEST THRU DSKY V 37 E 76E.
#	EXITS BY TCF ENDOFJOB.
# 5)	OUTPUT - OTHER VEHICLE STATE VECTOR INTEGRATED TO TIG AND INCREMENTED BY DELTA V IN REF COSYS.
#	THE PUSHLIST CONTAINS THE MATRIX BY WHICH THE INPUT DELTA V MUST BE POST-MULTIPLIED TO CONVERT FROM LV
#	TO REF COSYS.
# 6)	DEBRIS - OTHER VEHICLE STATE VECTOR.
# 7)	SUBROUTINES CALLED - BANKCALL, GOXDSPF, CSMPREC (OR LEMPREC), ATOPCSM (OR ATOPLEM), INTSTALL, INTWAKE, PHASCHNG
#	INTPRET, INTEGRVS, AND MINIRECT.
# 8)	FLAG USE - MOONFLAG, CMOONFLAG, INTYPFLG, RASFLAG, AND MARKCTR.

		BANK	30
		SETLOC	P76LOC
		BANK

		COUNT*	$$/P76

		EBANK=	TIG

P76		TC	UPFLAG
		ADRES	TRACKFLG

## <b>Reconstruction:</b>  The instructions `CAF V06N84` and `CAF V06N84 +1` (see next 
## annotation as well) are swapped in Comanche 55 vs Comanche 67.  This is known from
## the mission checklists.  There is a similar swap in Luminary 99 vs Luminary 116, due
## to PCR 826.2, "REVERSE P76 DISPLAY" 
## <a href="https://www.ibiblio.org/apollo/Documents/LUM92_text.pdf">
## see LUMINARY Memo 92</a>  We do not have a record of the corresponding PCR for Comanche, 
## but it's possible that such a PCR would be numbered PCR 826.1.
                CAF     V06N84 +1       # FLASH VERB 06 NOUN 33, DISPLAY LAST TIG,
		TC      BANKCALL        # AND WAIT FOR KEYBOARD ACTION.
	        CADR    GOFLASH
		TCF     ENDP76	
		TC	+2		# PROCEED
		TC	-5		# STORE DATA AND REPEAT FLASHING
## <b>Reconstruction:</b>  See the annotation above.
                CAF     V06N84          # FLASH LAST DELTA V,
		TC	BANKCALL	# AND WAIT FOR KEYBOARD ACTION.
		CADR	GOFLASH
		TCF	ENDP76
		TC	+2
		TC	-5
		TC	INTPRET		# RETURN TO INTERPRETIVE CODE
		DLOAD	                # SET D(MPAC)=TIG IN CSEC B28
			TIG
		STCALL	TDEC1		# SET TDEC1=TIG FOR ORBITAL INTEGRATION
			OTHPREC
COMPMAT		VLOAD	UNIT
			RATT
## Page 512
		VCOMP			# U(-R)
		STORE	24D		# U(-R) TO 24D
		VXV	UNIT		# U(-R) X V = U(V X R)
			VATT
		STORE	18D
		VXV	UNIT		# U(V X R) X U(-R) = U((R X V) X R)
			24D
		STOVL	12D
			DELVOV
		VXM	VSL1		# V(MPAC)=DELTA V IN REFCOSYS
			12D
		VAD
			VATT
		STORE	6		# V(PD6)=VATT + DELTA V
		CALL			# PREVENT WOULD-BE USER OF ORBITAL
			INTSTALL	# INTEG FROM INTERFERING WITH UPDATING
		CALL
			P76SUB1
		VLOAD	VSR*
			6
			0,2
		STOVL	VCV
			RATT
		VSR*
			0,2
		STODL	RCV
			TIG
		STORE	TET
		CLEAR	DLOAD
			INTYPFLG
			TETTHIS
INTOTHIS	STCALL	TDEC1
			INTEGRVS
		CALL
			INTSTALL
		CALL
		        P76SUB1         # SET/CLEAR MOONFLAG
		VLOAD
			RATT1
		STORE	RRECT
		STODL	RCV
			TAT
		STOVL	TET
			VATT1
		CALL
			MINIRECT
		EXIT
		TC	PHASCHNG
		OCT	04024
## Page 513
		TC	UPFLAG
		ADRES	REINTFLG
			 
		TC	INTPRET
		CALL
			ATOPOTH
		SSP     EXIT
		        QPRET
		        OUT
		TC      BANKCALL        # PERMIT USE OF ORBITAL INTEGRATION
		CADR    INTWAKE1
OUT		EXIT
ENDP76		CAF	ZERO
		TS	MARKCTR		# CLEAR RR TRACKING MARK COUNTER
		TS      VHFCNT
		
		CAF     NEGONE
		TS      MRKBUF2         # INVALIDATE MARK BUFFER
		
		TCF	GOTOPOOH

V06N84		NV	0684
		NV	0633
P76SUB1		CLEAR   SLOAD
			MOONFLAG        
			X2
		BHIZ    SET             # X2=0...CLEAR MOONFLAG
			+2              #   =2.....SET MOONFLAG
			MOONFLAG
		RVQ 

