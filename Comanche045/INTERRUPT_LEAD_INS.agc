### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     A section of Comanche revision 045.
##              It is part of the reconstructed source code for the
##              second release of the flight software for the Command
##              Module's (CM) Apollo Guidance Computer (AGC) for Apollo 10.
##              The code has been recreated from a copy of Comanche 055. It
##              has been adapted such that the resulting bugger words
##              exactly match those specified for Comanche 45 in NASA drawing
##              2021153D, which gives relatively high confidence that the
##              reconstruction is correct.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-12-06 MAS  Created from Comanche 44.

## Page 131
		SETLOC	4000 
		
		COUNT	02/RUPTS
		
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
## Page 132
		CAF	RDRPTBB
		XCH	BBANK
		TCF	VHFREAD
		
		DXCH	ARUPT		# HAND CONTROL RUPT
		CAF	HCRUPTBB
		XCH	BBANK
		TCF	RESUME +3	# NOT USED
		
		EBANK=	LST1		# RESTART USES E0,E3
GOBB		BBCON	GOPROG

		EBANK=	LST1
T3RPTBB		BBCON	T3RUPT

		EBANK=	KEYTEMP1
KEYRPTBB	BBCON	KEYRUPT1

		EBANK=	MRKBUF1
MKRUPTBB	BBCON	MARKRUPT

UPRPTBB		=	KEYRPTBB

		EBANK=	DNTMBUFF
DWNRPTBB	BBCON	DODOWNTM

		EBANK=	DATATEST
RDRPTBB		BBCON	VHFREAD

		EBANK=	TIME1
HCRUPTBB	BBCON	RESUME		# NOT USED

		EBANK=	DSRUPTSW
T4RPTBB		BBCON	T4RUPT

		EBANK=	TIME1
T5RPTBB		BBCON	T5RUPT

T5RUPT		EXTEND
		BZMF	NOQBRSM
		EXTEND
		DCA	T5LOC
		DTCB
		
		

