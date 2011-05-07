# Copyright:	Public domain.
# Filename:	ALARM_AND_ABORT.agc
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Reference:	Starts on p. 1483 of 1701.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Mod history:	08/30/04   RSB	Adapted from corresponding Luminary131 file.
#		2010-10-24 JL	Indentation fixes.
#               2011-05-07 JL   Removed workarounds.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  Notations on this
# document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
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
# Please report any errors (relative to 1701.pdf) to info@sandroid.org.
#
# In some cases, where the source code for Luminary 131 overlaps that of 
# Colossus 249, this code is instead copied from the corresponding Luminary 131
# source file, and then is proofed to incorporate any changes.

# Page 1483
# THE FOLLOWING SUBROUTINE MAY BE CALLED TO DISPLAY A NON-ABORTIVE ALARM CONDITION.  IT MAY BE CALLED
# EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL.
#
# THE CALLING SEQUENCE IS AS FOLLOWS:
#		TC	ALARM
#		OCT	AAANN		# ALARM NO. NN IN GENERAL AREA AAA.
#					# (RETURNS HERE)

		BLOCK	02
		SETLOC	FFTAG7
		BANK

		EBANK=	FAILREG

		COUNT	02/ALARM

# ALARM TURNS ON THE PROGRAM ALARM LIGHT, BUT DOES NOT DISPLAY.

ALARM		INHINT

		CA	Q
ALARM2		TS	ALMCADR
		INDEX	Q
		CA	0
BORTENT		TS	L

PRIOENT		CA	BBANK
 +1		EXTEND
		ROR	SUPERBNK	# ADD SUPER BITS.
		TS	ALMCADR +1

LARMENT		CA	Q		# STORE RETURN FOR ALARM
		TS	ITEMP1

CHKFAIL1	CCS	FAILREG		# IS ANYTHING IN FAILREG
		TCF	CHKFAIL2	# YES TRY NEXT REG
		LXCH	FAILREG
		TCF	PROGLARM	# TURN ALARM LIGHT ON FOR FIRST ALARM

CHKFAIL2	CCS	FAILREG +1
		TCF	FAIL3
		LXCH	FAILREG +1
		TCF	MULTEXIT
		
FAIL3		CA	FAILREG +2
		MASK	POSMAX
		CCS	A
		TCF	MULTFAIL
		LXCH	FAILREG +2
# Page 1484
		TCF	MULTEXIT
		
PROGLARM	CS	DSPTAB +11D	# TURN ON PROGRAM ALARM IF OFF
		MASK	OCT40400
		ADS	DSPTAB +11D

MULTEXIT	XCH	ITEMP1		# OBTAIN RETURN ADDRESS IN A
		RELINT
		INDEX	A
		TC	1

MULTFAIL	CA	L
		AD	BIT15
		TS	FAILREG +2
		
		TCF	MULTEXIT

# PRIOLARM DISPLAYS V05N09 VIA PRIODSPR WITH 3 RETURNS TO THE USER FROM THE ASTRONAUT AT CALL LOC +1,+2,+3 AND
# AN IMMEDIATE RETURN TO THE USER AT CALL LOC +4.  EXAMPLE FOLLOWS,
#		CAF	OCTXX		# ALARM CODE
#		TC	BANKCALL
#		CADR	PRIOLARM
#		...	...
#		...	...
#		...	...		# ASTRONAUT RETURN
#		TC	PHASCHNG	# IMMEDIATE RETURN TO USER.  RESTART
#		OCT	X.1		# PHASE CHANGE FOR PRIO DISPLAY

		BANK	10
		SETLOC	DISPLAYS
		BANK

		COUNT	10/DSPLA
PRIOLARM	INHINT			# * * * KEEP IN DISPLAY ROUTINE'S BANK
		TS	L		# SAVE ALARM CODE

		CA	BUF2		# 2 CADR OF PRIOLARM USER
		TS	ALMCADR
		CA	BUF2 +1
		TC	PRIOENT +1	# * LEAVE L ALONE
-2SEC		DEC	-200		# *** DON'T MOVE
		CAF	V05N09
		TCF	PRIODSPR

		BLOCK	02
		SETLOC	FFTAG7
		BANK

# Page 1485
		COUNT	02/ALARM
		
BAILOUT		INHINT
		CA	Q
		TS	ALMCADR

		INDEX	Q
		CAF	0
		TC	BORTENT
OCT40400	OCT	40400

		INHINT
WHIMPER		CA	TWO
		AD	Z
		TS	BRUPT
		RESUME
		TC	POSTJUMP	# RESUME SENDS CONTROL HERE
		CADR	ENEMA
P00DOO		INHINT
		CA	Q
ABORT2		TS	ALMCADR
		INDEX	Q
		CAF	0
		TC	BORTENT
OCT77770	OCT	77770		# DON'T MOVE
		CA	V37FLBIT	# IS AVERAGE G ON
		MASK	FLAGWRD7
		CCS	A
		TC	WHIMPER -1	# YES.  DON'T DO P00DOO.  DO BAILOUT.

		TC	BANKCALL
		CADR	MR.KLEAN
		TC	WHIMPER
		
CCSHOLE		INHINT
		CA	Q
		TC	ABORT2
OCT1103		OCT	1103
CURTAINS	INHINT
		CA	Q
		TC	ALARM2
OCT217		OCT	00217
		TC	ALMCADR		# RETURN TO USER

DOALARM		EQUALS	ENDOFJOB

# CALLING SEQUENCE FOR VARALARM
#		CAF	(ALARM)
#		TC	VARALARM
# Page 1486

# VARALARM TURNS ON PROGRAM ALARM LIGHT BUT DOES NOT DISPLAY

VARALARM	INHINT

		TS	L		# SAVE USER'S ALARM CODE

		CA	Q		# SAVE USER'S Q
		TS	ALMCADR

		TC	PRIOENT
OCT14		OCT	14		# DON'T MOVE

		TC	ALMCADR		# RETURN TO USER

ABORT		EQUALS	BAILOUT		# *** TEMPORARY UNTIL ABORT CALLS OUT
