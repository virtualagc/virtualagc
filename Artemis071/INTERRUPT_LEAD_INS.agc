### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     A section of Artemis revision 071.
##              It is part of the reconstructed source code for the first
##              release of the flight software for the Command Module's
##              (CM) Apollo Guidance Computer (AGC) for Apollo 15 through
##              17. The code has been recreated from a copy of Artemis 072.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Artemis 071 in NASA
##              drawing 2021154-, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   139
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Artemis 072.

## Page 139
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
## Page 140
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
