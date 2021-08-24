### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	KALCMANU_STEERING.agc
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
## Pages:	365-369
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2011-01-06 JL	Added missing comment characters.
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-07 RSB	Removed yaYUL workaround that no longer 
##				seems to be needed.
##		2017-03-17 RSB	Comment-text fixes identified in diff'ing
##				Luminary 99 vs Comanche 55.
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

## Page 365
# GENERATION OF STEERING COMMANDS FOR DIGITAL AUTOPILOT FREE FALL MANEUVERS
#
# NEW COMMANDS WILL BE GENERATED EVERY ONE SECOND DURING THE MANEUVER

		EBANK=	TTEMP
		
NEWDELHI	TC	BANKCALL	# CHECK FOR AUTO STABILIZATION
		CADR	ISITAUTO	# ONLY
		CCS	A
		TCF	NOGO 	-2
NEWANGL		TC	INTPRET
		AXC,1	AXC,2
			MIS		# COMPUTE THE NEW MATRIX FROM S/C TO
			KEL		# STABLE MEMBER AXES
		CALL
			MXM3
		VLOAD	STADR
		STOVL	MIS 	+12D	# CALCULATE NEW DESIRED CDU ANGLES
		STADR
		STOVL	MIS 	+6D
		STADR
		STORE	MIS
		AXC,1	CALL
			MIS
			DCMTOCDU	# PICK UP THE NEW CDU ANGLES FROM MATRIX
		RTB	
			V1STO2S
		STORE	NCDU		# NEW CDU ANGLES
		BONCLR	EXIT
			CALCMAN2
			MANUSTAT	# TO START MANEUVER
		CAF	TWO		#	+0 OTHERWISE
INCRDCDU	TS	SPNDX
		INDEX	SPNDX
		CA	BCDU		# INITIAL CDU ANGLES
		EXTEND			# OR PREVIOUS DESIRED CDU ANGLES
		INDEX	SPNDX
		MSU	NCDU
		EXTEND
		SETLOC	KALCMON1
		BANK
		
		MP	DT/TAU
		CCS	A		# CONVERT TO 2S COMPLEMENT
		AD	ONE
		TCF	+2
		COM
		INDEX	SPNDX
		TS	DELDCDU		# ANGLE INCREMENTS TO BE ADDED TO
		INDEX	SPNDX		# CDUXD, CDUYD, CDUZD EVERY TENTH SECOND
## Page 366
		CA	NCDU		# BY LEM DAP
		INDEX	SPNDX
		XCH	BCDU
		INDEX	SPNDX
		TS	CDUXD
		CCS	SPNDX
		TCF	INCRDCDU	# LOOP FOR THREE AXES
		
		RELINT
		
# COMPARE PRESENT TIME WITH TIME TO TERMINATE MANEUVER

TMANUCHK	TC	TIMECHK
		TCF	CONTMANU
		CAF	ONE
MANUSTAL	INHINT			# END MAJOR PART OF MANEUVER WITHIN 1 SEC
		TC	WAITLIST	# UNDER WAITLIST CALL TO MANUSTOP
		EBANK=	TTEMP
		2CADR	MANUSTOP
		
		RELINT
		TCF	ENDOFJOB
		
TIMECHK		EXTEND
		DCS	TIME2
		DXCH	TTEMP
		EXTEND
		DCA	TM
		DAS	TTEMP
		CCS	TTEMP
		TC	Q
		TCF	+2
		TCF	2NDRETRN
		CCS	TTEMP 	+1
		TC	Q
		TCF	MANUOFF
		COM
MANUOFF		AD	ONESEK 	+1
		EXTEND
		BZMF	2NDRETRN
		INCR	Q
2NDRETRN	INCR	Q
		TC	Q
		
DT/TAU		DEC	.1

MANUSTAT	EXIT			# INITIALIZATION ROUTINE
		EXTEND			# FOR AUTOMATIC MANEUVERS
		DCA	TIME2
## Page 367
		DAS	TM		# TM+T0		MANEUVER COMPLETION TIME
		EXTEND
		DCS	ONESEK
		DAS	TM		# (TM+T0)-1
		INHINT
		CAF	TWO
RATEBIAS	TS	KSPNDX
		DOUBLE
		TS	KDPNDX
		INDEX	A
		CA	BRATE
		INDEX	KSPNDX		# STORE MANEUVER RATE IN
		TS	OMEGAPD		# OMEGAPD, OMEGAQD, OMEGARD
		EXTEND
		BZMF	+2		# COMPUTE ATTITUDE ERROR
		COM			# OFFSET = (WX)ABS(WX)/2AJX
		EXTEND			# WHERE AJX= 2-JET ACCELERATION
		MP	BIASCALE	# = -1/16
		EXTEND
		INDEX	KDPNDX
		MP	BRATE
		EXTEND
		INDEX	KSPNDX
		DV	1JACC		# = AJX		$ 90 DEG/SEC-SEC
		INDEX	KSPNDX
		TS	DELPEROR	#		$ 180 DEG
		CCS	KSPNDX
		TCF	RATEBIAS
		
		CA	TIME1
		AD	ONESEK 	+1
		XCH	NEXTIME
		TCF	INCRDCDU -1
		
ONESEK		DEC	0
		DEC	100
		
BIASCALE	OCT	75777		# = -1/16

CONTMANU	CS	TIME1		# RESET FOR NEXT DCDU UPDATE
		AD	NEXTIME
		CCS	A
		AD	ONE
		TCF	MANUCALL
		AD	NEGMAX
		COM
MANUCALL	INHINT			# CALL FOR NEXT UPDATE VIA WAITLIST
		TC	WAITLIST
		EBANK=	TTEMP
		2CADR	UPDTCALL
## Page 368
		CAF	ONESEK 	+1	# INCREMENT TIME FOR NEXT UPDATE
		ADS	NEXTIME
		TCF	ENDOFJOB
		
UPDTCALL	CAF	PRIO26		# SATELLITE PROGRAM TO CALL FOR UPDATE
		TC	FINDVAC		# OF STEERING COMMANDS
		EBANK=	TTEMP
		2CADR	NEWDELHI

		TC	TASKOVER
		
## Page 369
# ROUTINE FOR TERMINATING AUTOMATIC MANEUVERS

MANUSTOP	CAF	ZERO		# ZERO MANEUVER RATES
		TS	DELDCDU2
		TS	OMEGARD
		TS	DELREROR
		TS	DELDCDU1
		TS	OMEGAQD
		TS	DELQEROR
		CA	CPSI		# SET DESIRED GIMBAL ANGLES TO
		TS	CDUZD		# DESIRED FINAL GIMBAL ANGLES
		CA	CTHETA
		TS	CDUYD
ENDROLL		CA	CPHI		# NO FINAL YAW
		TS	CDUXD
		CAF	ZERO
		TS	OMEGAPD		# I.E. MANEUVER DID NOT GO THRU
		TS	DELDCDU		# GIMBAL LOCK ORIGINALLY
		TS	DELPEROR
GOODMANU	CA	ATTPRIO		# RESTORE USERS PRIO
		TS	NEWPRIO
		
		CA	ZERO		# ZERO ATTCADR
		DXCH	ATTCADR
		
		TC	SPVAC		# RETURN TO USER
		
		TC	TASKOVER
		

