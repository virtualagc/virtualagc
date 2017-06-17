### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INTERRUPT_LEAD_INS.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst).
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##				I've also corrected this against the Sunburst120
##				scans, so modulo any errors of mine, should be
##				ready to go.
##		2016-11-03 RSB	Some SBANK= workarounds.
##		2016-12-03 RSB	Fixed 5 comment typos (out of 2 total pages)
##				using octopus/ProoferComments.
##		2017-06-17 MAS	Globally removed all SBANK= workarounds.

## Page 60
		SETLOC	4000 
		
		INHINT			# GO
		CAF	GOBB
		XCH	BBANK
		TCF	GOPROG
		
		DXCH	ARUPT		# T6RUPT
		EXTEND
		DCA	T6ADR
		DTCB
		
		DXCH	ARUPT		# T5RUPT
		EXTEND
		DCA	T5ADR
		DTCB
		
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
## Page 61
		TCF	NOQRSM 	+1	# WAS TCF RADAREAD (NO RADAR IN 206).
		
# TRAPS 31B AND 32 SHOULD NEVER BE SET.  THEREFORE-
# RUPT 10 WILL ALWAYS REFER TO THE HAND CONTROLLER LPD OR MINIMUM IMPULSE
# USE.  SEE GEORGE CHERRY FOR RATIONALE REGARDING THE AFORESAID.
		
		DXCH	ARUPT		# RUPT10 USED FOR RHC MINIMP MODE ONLY.
		CAF	TWO
		TS	DELAYCTR
		TCF	NOQBRSM

		EBANK=	LST1		# RESTART USES E0, E3
GOBB		BBCON	GOPROG

		EBANK=	TIME1
T6RPTBB		BBCON	RESUME		# ***FIX LATER***

		EBANK=	LST1		
T3RPTBB		BBCON	T3RUPT

		EBANK=	KEYTEMP1
KEYRPTBB	BBCON	KEYRUPT1

		EBANK=	AOTAZ
MKRUPTBB	BBCON	MARKRUPT

UPRPTBB		=	KEYRPTBB

		EBANK=	DNTMBUFF
DWNRPTBB	BBCON	DODOWNTM

		EBANK=	RADMODES
RDRPTBB		BBCON	RADAREAD

		EBANK=	M11
T4RPTBB		BBCON	T4RUPTA

				
