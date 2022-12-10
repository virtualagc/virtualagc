### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERRUPT_TRANSFER_ROUTINES.agc
## Purpose:	A section of Sunrise 45.
##		It is part of the reconstructed source code for the penultimate
##		release of the Block I Command Module system test software. No
##		original listings of this program are available; instead, this
##		file was created via disassembly of dumps of Sunrise core rope
##		memory modules and comparison with the later Block I program
##		Solarium 55.
## Assembler:	yaYUL --block1
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2022-12-09 MAS	Initial reconstructed source.

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
		CAF	PHASBANK
		TS	BANKREG
		TC	GOPROG

ERRUPT		TC	ALARM		# ***NO ERRUPTS IN SYSTEM 5***
		OCT	01101
		TC	NBRESUME
