### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERRUPT_TRANSFER_ROUTINES.agc
## Purpose:	A section of Corona revision 261.
##		It is part of the source code for the Apollo Guidance Computer
##		(AGC) for AS-202. No original listings of this software are
##		available; instead, this file was created via disassembly of
##		the core rope modules actually flown on the mission.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-05-27 MAS  Created from Solarium 55.

		SETLOC	2000

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	T3RUPT

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	ERRUPT

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	T4RUPT		# OUTPUT CONTROL.

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	KEYRUPT

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	UPRUPT

		TS	ARUPT
		XCH	Q
		XCH	QRUPT
		TC	DOWNRUPT	# DOWNLINK.

		INHINT			# GOJAM - PARITY ALARM, POWER FAIL, ETC.
		CAF	EXECBANK

		TS	BANKREG
		TC	GOPROG

ERRUPT		TC	ALARM		# ***NO ERRUPTS IN SYSTEM 5***
		OCT	01101
		TC	NBRESUME

UPRUPT		CAF	UPBANK		# CALL IN BANK WITH UPRUPT PROGRAM.
		XCH	BANKREG
		TC	UPRUPTB

KEYRUPT		CAF	MODEBANK
		XCH	BANKREG
		TC	KEYRUPTA

MODEBANK	CADR	KEYRUPTA
