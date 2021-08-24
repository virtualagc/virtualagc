### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	SERVICE_ROUTINES.agc
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
## Pages:	1374-1380
## Mod history: 2009-05-10 SN   (Sergio Navarro).  Started adapting
##				from the Luminary131/ file of the same
##				name, using Luminary099 page images.
##		2016-12-18 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-16 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.
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

## Page 1374
		BANK	10
		SETLOC	DISPLAYS
		BANK
		COUNT*	$$/DSPLA

UPENT2		INHINT
		MASK	OCT77770
		TS	L
		CS	FLAGWRD4
		MASK	L
		ADS	FLAGWRD4
JOIN		RELINT
		TCF	Q+1

DOWNENT2	INHINT
		MASK	OCT77770
		COM
		MASK	FLAGWRD4
		TS	FLAGWRD4
		TCF	JOIN

OCT7		EQUALS	SEVEN

## Page 1375
# UPFLAG AND DOWNFLAG ARE ENTIRELY GENERAL FLAG SETTING AND CLEARING SUBROUTINES.  USING THEM, WHETHER OR
# NOT IN INTERRUPT, ONE MAY SET OR CLEAR ANY SINGLE, NAMED BIT IN ANY ERASABLE REGISTER, SUBJECT OF COURSE TO
# EBANK SETTING.  A "NAMED" BIT, AS THE WORD IS USED HERE, IS ANY BIT WITH A NAME FORMALLY ASSIGNED BY THE YUL
# ASSEMBLER.
#
# AT PRESENT THE ONLY NAMED BITS ARE THOSE IN THE FLAGWORDS.  ASSEMBLER CHANGES WILL MAKE IT POSSIBLE TO
# NAME ANY BIT IN ERASABLE MEMORY.
#
# CALLING SEQUENCES ARE AS FOLLOWS :-
#		TC	UPFLAG			TC	DOWNFLAG
#		ADRES	NAME OF FLAG		ADRES	NAME OF FLAG
#
# RETURN IS TO THE LOCATION FOLLOWING THE "ADRES" ABOUT .58 MS AFTER THE "TC".
# UPON RETURN A CONTAINS THE CURRENT FLAGWRD SETTING.

		BLOCK	02
		SETLOC	FFTAG1
		BANK
		COUNT*	$$/FLAG

UPFLAG		CA	Q
		TC	DEBIT
		COM			# +(15 - BIT)
		EXTEND
		ROR	LCHAN		# SET BIT
COMFLAG		INDEX	ITEMP1
		TS	FLAGWRD0
		LXCH	ITEMP3
		RELINT
		TC	L

DOWNFLAG	CA	Q
		TC	DEBIT
		MASK	L		# RESET BIT
		TCF	COMFLAG

DEBIT		AD	ONE		# GET DE BITS
		INHINT
		TS	ITEMP3
		CA	LOW4		# DEC15
		TS	ITEMP1
		INDEX	ITEMP3
		CA	0 -1		# ADRES
		TS	L
		CA	ZERO
## Page 1376
		EXTEND
		DV	ITEMP1		# A = FLAGWRD, L = (15 - BIT)
		DXCH	ITEMP1
		INDEX	ITEMP1
		CA	FLAGWRD0
		TS	L		# CURRENT STATE
		INDEX	ITEMP2
		CS	BIT15		# -(15 - BIT)
		TC	Q

## Page 1377
# DELAYJOB - A GENERAL ROUTINE TO DELAY A JOB A SPECIFIC AMOUNT OF TIME BEFORE PICKING UP AGAIN.
#
# ENTRANCE REQUIREMENTS ...
#		CAF	DT		DELAY JOB FOR DT CENTISECS
#		TC	BANKCALL
#		CADR	DELAYJOB

		BANK	06
		SETLOC	DLAYJOB
		BANK

# THIS MUST REMAIN IN BANK 0 *****************************************

		COUNT*	$$/DELAY
DELAYJOB	INHINT
		TS	Q		# STORE DELAY DT IN Q FOR DLY -1 IN
		CAF	DELAYNUM	# WAITLIST
DELLOOP		TS	RUPTREG1
		INDEX	A
		CA	DELAYLOC	# IS THIS DELAYLOC AVAILABLE
		EXTEND
		BZF	OK2DELAY	# YES

		CCS	RUPTREG1	# NO, TRY NEXT DELAYLOC
		TCF	DELLOOP

		DXCH	BUF2
		TC	BAILOUT1	# NO AVAILABLE LOCS.
		OCT	1104

OK2DELAY	CA	TCSLEEP		# SET WAITLIST IMMEDIATE RETURN
		TS	WAITEXIT

		CA	FBANK
		AD	RUPTREG1	# STORE BBANK FOR TASK CALL
		TS	L

		CAF	WAKECAD		# STORE CADR FOR TASK CALL
		TCF	DLY2 -1		# DLY IS IN WAITLIST ROUTINE

TCGETCAD	TC	MAKECADR	# GET CALLERS FCADR

		INDEX	RUPTREG1
		TS	DELAYLOC	# SAVE DELAY CADRS

		TC	JOBSLEEP

WAKER		CAF	ZERO
		INDEX	BBANK
		XCH	DELAYLOC	# MAKE DELAYLOC AVAILABLE
## Page 1378
		TC	JOBWAKE

		TC	TASKOVER

TCSLEEP		GENADR	TCGETCAD -2
WAKECAD		GENADR	WAKER

## Page 1379
# GENTRAN, A BLOCK TRANSFER ROUTINE.
# WRITTEN BY D. EYLES
# MOD 1 BY KERNAN				UTILITYM REV 17 11/18/67
# MOD 2 BY SCHULENBERG (REMOVE RELINT) SKIPPER REV 4 2/28/68
#
# THIS ROUTINE IS USEFULL FOR TRANSFERING N CONSECUTIVE ERASABLE OR FIXED QUANTITIES TO SOME OTHER N
# CONSECUTIVE ERASABLE LOCATIONS.  IF BOTH BLOCKS OF DATA ARE IN SWITCHABLE EBANKS, THEY MUST BE IN THE SAME ONE.
#
# GENTRAN IS CALLABLE IN A JOB AS WELL AS A RUPT.  THE CALLING SEQUENCE IS:
#	I	CA	N-1		# OF QUANTITIES MINUS ONE.
#	I +1	TC	GENTRAN		IN FIXED-FIXED.
#	I +2	ADRES	L		STARTING ADRES OF DATA TO BE MOVED.
#	I +3	ADRES	M		STARTING ADRES OF DUPLICATION BLOCK.
#	I +4				RETURNS HERE.
#
# GENTRAN TAKES 25 MCT'S (300 MICROSECONDS) PER ITEM + 5 MCT'S (60 MICS) FOR ENTERING AND EXITING.
# A, L AND ITEMP1 ARE NOT PRESERVED.

		BLOCK	02
		SETLOC	FFTAG4
		BANK

		EBANK=	ITEMP1

		COUNT*	$$/TRAN

GENTRAN		INHINT
		TS	ITEMP1		# SAVE N-1.
		INDEX	Q		# C(Q) = ADRES L.
		AD	0		# ADRES (L + N - 1).
		INDEX	A
		CA	0		# C(ABOVE).
		TS	L		# SAVE DATA.
		CA	ITEMP1
		INDEX	Q
		AD	1		# ADRES (M + N - 1).
		INDEX	A
		LXCH	0		# STUFF IT.
		CCS	ITEMP1		# LOOP UNTIL N-1 = 0.
		TCF	GENTRAN +1
		TCF	Q+2		# RETURN TO CALLER.

## Page 1380
# B5OFF		ZERO BIT 5 OF EXTVBACT, WHICH IS SET BY TESTXACT.
# MAY BE USED AS NEEDED BY ANY EXTENDED VERB WHICH HAS DONE TESTXACT

		COUNT*	$$/EXTVB

B5OFF		CS	BIT5
		MASK	EXTVBACT
		TS	EXTVBACT
		TC	ENDOFJOB



