### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERRUPT_LEAD_INS.agc
## Purpose:	A section of Skylark revision 048.
##		It is part of the source code for the Apollo Guidance Computer (AGC)
##		for Skylab-2, Skylab-3, Skylab-4, and ASTP. No original listings of
##		this software are available; instead, this file was created via
##		disassembly of dumps of the core rope modules actually flown on
##		Skylab-2. Access to these modules was provided by the New Mexico
##		Museum of Space History.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-09-04 MAS  Created from Artemis 072.

		SETLOC	4000

		COUNT*	$$/RUPTS

		INHINT			# GO
		CAF	GOBB
		XCH	BBANK
		TCF	GOPROG

		DXCH	ARUPT		# T6RUPT
		EXTEND
		DCA	T6LOC
		DTCB

		DXCH	ARUPT		# T5RUPT
		CS	TIME5
		AD	.5SEC
		TCF	T5RUPT

		DXCH	ARUPT		# T3RUPT
		CAF	T3RPTBB
		XCH	BBANK
		TCF	T3RUPT

		DXCH	ARUPT		# T4RUPT
		CAF	T4RPTBB
		XCH	BBANK
		TCF	T4RUPT

		DXCH	ARUPT		# KEYRUPT1
		CAF	KEYRPTBB
		XCH	BBANK
		TCF	KEYRUPT1

		DXCH	ARUPT		# KEYRUPT2
		CAF	MKRUPTBB
		XCH	BBANK
		TCF	MARKRUPT

		DXCH	ARUPT		# UPRUPT
		CAF	UPRPTBB
		XCH	BBANK
		TCF	UPRUPT

		DXCH	ARUPT		# DOWNRUPT
		CAF	DWNRPTBB
		XCH	BBANK
		TCF	DODOWNTM

		DXCH	ARUPT		# RADAR RUPT
		CAF	RDRPTBB
		XCH	BBANK
		TCF	VHFREAD

		RESUME

		EBANK=	LST1		# RESTART USES E0,E3
GOBB		BBCON	GOPROG

		EBANK=	LST1
T3RPTBB		EQUALS	WAITBB
KEYRPTBB	=	MKRUPTBB

		EBANK=	MRKBUF1
MKRUPTBB	BBCON	MARKRUPT
UPRPTBB		=	KEYRPTBB
DWNRPTBB	=	GOBB

		EBANK=	RM
RDRPTBB		BBCON	VHFREAD
		EBANK=	DSRUPTSW
T4RPTBB		BBCON	T4RUPT
		EBANK=	TIME1
T5RPTBB		BBCON	T5RUPT

T5RUPT		EXTEND
		BZMF	NOQBRSM
		EXTEND
		DCA	T5LOC
		DTCB
