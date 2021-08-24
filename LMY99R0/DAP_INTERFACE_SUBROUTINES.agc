### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DAP_INTERFACE_SUBROUTINES.agc
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
## Pages:	1406-1409
## Mod history: 2009-05-10 SN   (Sergio Navarro).  Started adapting
##				from the Luminary131/ file of the same
##				name, using Luminary099 page images.
##		2011-01-06 JL	Fixed pseudo-label indentation.
##		2016-12-18 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-10 RSB	Comment-text fixes noted in proofing Luminary 116.
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

## Page 1406
		BANK	20
		SETLOC	DAPS3
		BANK

		EBANK=	CDUXD
		COUNT*	$$/DAPIF

# MOD 0		DATE	11/15/66	BY GEORGE W. CHERRY
# MOD 1			 1/23/67	MODIFICATION BY PETER ADLER
#
# FUNCTIONAL DESCRIPTION
#	HEREIN ARE A COLLECTION OF SUBROUTINES WHICH ALLOW MISSION CONTROL PROGRAMS TO CONTROL THE MODE
#	AND INTERFACE WITH THE DAP.
#
# CALLING SEQUENCES
#	IN INTERRUPT OR WITH INTERRUPT INHIBITED
#		TC	IBNKCALL
#		FCADR	ROUTINE
#	IN A JOB WITHOUT INTERRUPT INHIBITED
#		INHINT
#		TC	IBNKCALL
#		FCADR	ROUTINE
#		RELINT
#
# OUTPUT
#	SEE INDIVIDUAL ROUTINES BELOW
#
# DEBRIS
#	A, L, AND SOMETIMES MDUETEMP			ODE	NOT IN PULSES MODE

## Page 1407
# SUBROUTINE NAMES:
#	SETMAXDB, SETMINDB, RESTORDB, PFLITEDB
# MODIFIED:	30 JANUARY 1968 BY P S WEISSMAN TO CREATE RESTORDB.
# MODIFIED:	1 MARCH 1968 BY P S WEISSMAN TO SAVE EBANK AND CREATE PFLITEDB
#
# FUNCTIONAL DESCRIPTION:
#	SETMAXDB - SET DEADBAND TO 5.0 DEGREES
#	SETMINDB - SET DEADBAND TO 0.3 DEGREE
#	RESTORDB - SET DEADBAND TO MAX OR MIN ACCORDING TO SETTING OF DBSELECT BIT OF DAPBOOLS
#	PFLITEDB - SET DEADBAND TO 1.0 DEGREE AND ZERO THE COMMANDED ATTITUDE CHANGE AND COMMANDED RATE
#
#	ALL ENTRIES SET UP A NOVAC JOB TO DO 1/ACCS SO THAT THE TJETLAW SWITCH CURVES ARE POSITIONED TO
#	REFLECT THE NEW DEADBAND.  IT SHOULD BE NOTED THAT THE DEADBAND REFERS TO THE ATTITUDE IN THE P-, U-, AND V-AXES.
#
# SUBROUTINE CALLED:	NOVAC
#
# CALLING SEQUENCE:	SAME AS ABOVE
#			OR	TC RESTORDB +1    FROM ALLCOAST
#
# DEBRIS:		A, L, Q, RUPTREG1, (ITEMPS IN NOVAC)

RESTORDB	CAE	DAPBOOLS	# DETERMINE CREW-SELECTED DEADBAND.
		MASK	DBSELECT
		EXTEND
		BZF	SETMINDB

SETMAXDB	CAF	WIDEDB		# SET 5 DEGREE DEADBAND.
 +1		TS	DB

		EXTEND			# SET UP JOB TO RE-POSITION SWITCH CURVES.
		QXCH	RUPTREG1
CALLACCS	CAF	PRIO27
		TC	NOVAC
		EBANK=	AOSQ
		2CADR	1/ACCJOB

		TC	RUPTREG1	# RETURN TO CALLER.

SETMINDB	CAF	NARROWDB	# SET 0.3 DEGREE DEADBAND.
		TCF	SETMAXDB +1

PFLITEDB	EXTEND			# THE RETURN FROM CALLACCS IS TO RUPTREG1.
		QXCH	RUPTREG1
		TC	ZATTEROR	# ZERO THE ERRORS AND COMMANDED RATES.
		CAF	POWERDB		# SET DB TO 1.0 DEG.
		TS	DB
		TCF	CALLACCS	# SET UP 1/ACCS AND RETURN TO CALLER.
NARROWDB	OCTAL	00155		# 0.3 DEGREE SCALED AT 45.
## Page 1408
WIDEDB		OCTAL	03434		# 5.0 DEGREES SCALED AT 45.
POWERDB		DEC	.02222		# 1.0 DEGREE SCALED AT 45.

ZATTEROR	CAF	EBANK6
		XCH	EBANK
		TS	L		# SAVE CALLERS EBANK IN L.
		CAE	CDUX
		TS	CDUXD
		CAE	CDUY
		TS	CDUYD
		CAE	CDUZ
		TS	CDUZD
		TCF	STOPRATE +3

STOPRATE	CAF	EBANK6
		XCH	EBANK
		TS	L		# SAVE CALLERS EBANK IN L.
 +3		CAF	ZERO
		TS	OMEGAPD
		TS	OMEGAQD
		TS	OMEGARD
		TS	DELCDUX
		TS	DELCDUY
		TS	DELCDUZ
		TS	DELPEROR
		TS	DELQEROR
		TS	DELREROR
		LXCH	EBANK		# RESTORE CALLERS EBANK.
		TC	Q

# SUBROUTINE NAME:	ALLCOAST
# WILL BE CALLED BY FRESH STARTS AND ENGINE OFF ROUTINES.		.
#
# CALLING SEQUENCE:	(SAME AS ABOVE)
#
# EXIT:			RETURN TO Q.
#
# SUBROUTINES CALLED:	STOPRATE, RESTORDB, NOVAC
#
# ZERO:			(FOR ALL AXES) AOS, ALPHA, AOSTERM, OMEGAD, DELCDU, DELEROR
#
# OUTPUT:		DRIFTBIT/DAPBOOLS, DB, JOB TO DO 1/ACCS
#
# DEBRIS:		A, L, Q, RUPTREG1, RUPTREG2, (ITEMPS IN NOVAC)

ALLCOAST	EXTEND			# SAVE Q FOR RETURN
		QXCH	RUPTREG2
## Page 1409
		TC	STOPRATE	# CLEAR RATE INTERFACE.  RETURN WITH A=0
		LXCH	EBANK		# AND L=EBANK6.  SAVE CALLERS EBANK.
		TS	AOSQ
		TS	AOSQ +1
		TS	AOSR
		TS	AOSR +1
		TS	ALPHAQ		# FOR DOWNLIST.
		TS	ALPHAR
		TS	AOSQTERM
		TS	AOSRTERM
		LXCH	EBANK		# RESTORE EBANK (EBANK6 NO LONGER NEEDED)

		CS	DAPBOOLS	# SET UP DRIFTBIT
		MASK	DRIFTBIT
		ADS	DAPBOOLS
		TC	RESTORDB +1	# RESTORE DEADBANK TO CREW-SELECTED VALUE.

		TC	RUPTREG2	# RETURN.

