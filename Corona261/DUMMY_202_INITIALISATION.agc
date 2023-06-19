### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DUMMY_202_INITIALIZATION.agc
## Purpose:	A section of Corona revision 261.
##		It is part of the source code for the Apollo Guidance Computer
##		(AGC) for AS-202. No original listings of this software are
##		available; instead, this file was created via disassembly of
##		the core rope modules actually flown on the mission.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-05-27 MAS  Created from Solarium 55.
## 		2023-06-17 MAS  Updated for Corona.

		BANK	33
BEGINNER	TC	BANKCALL	# CHANGE IMUMODE AS REQUIRED.
CADRMODE	CADR	IMUREENT

BEGIN202	TC	INTPRET
		VMOVE	1
		ITC
			RN
			CALCGRAV

		EXIT	0
		TC	PHASCHNG	# SETUP SOME PHASE INFO.
EXITLOC2	OCT	00105		# 5.1 MODE GOES WITH READACCS.

		INHINT
		CS	TIME1
		AD	STARTDT1
		TC	WAITLIST
		CADR	READACCS

		CS	TIME1		# SPARE START ROUTINE
		AD	STARTDT2
		TC	WAITLIST
		CADR	START2

		TC	ENDOFJOB

## (JL) seems to be an arg missing. Is YUL assuming 0? Generates 07435.
BEGINSW		TC	BANKCALL	# WAIT FOR MODE SWITCH IF NECESSARY.
		CADR	IMUSTALL
		TC

		TC	ENDOFJOB

		DEC	0		# HOLE FOR 2DEC PATCHING STARTDT1 -1
STARTDT1	DEC	200
STARTDT2	DEC	830

START2		CAF	PRIO27
		TC	FINDVAC
		CADR	S4BSMSEP

		TC	TASKOVER
