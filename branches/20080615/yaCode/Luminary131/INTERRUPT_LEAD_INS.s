# Copyright:	Public domain.
# Filename:	INTERRUT_LEAD_INS.s
# Purpose:	This is the interrupt table for Luminary 1C, revision 131.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC) for Apollo 13 and Apollo 14.
#		This file is intended to be a faithful transcription, except
#		that the code format has been changed to conform to the
#		requirements of the yaYUL assembler rather than the 
#		original YUL assembler.
# Reference:	pp. 160-161 of 1729.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo/index.html
# Mod history:	04/11/03 RSB.	Began transcribing.
#		05/14/05 RSB	Corrected website reference above.

# Page 160
		SETLOC	4000 
		
		COUNT*	$$/RUPTS	# FIX-FIX LEAD INS
		INHINT			# GO
		CAF	GOBB
		XCH	BBANK
		TCF	GOPROG
		
		DXCH	ARUPT		# T6RUPT
		EXTEND
		DCA	T6ADR
		DTCB
		
		DXCH	ARUPT		# T5RUPT -- AUTOPILOT
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
# Page 161
		XCH	BBANK
		TCF	RADAREAD
		
		DXCH	ARUPT		# RUPT10 IS USED ONLY BY LANDING GUIDANCE
		CA	RUPT10BB
		XCH	BBANK
		TCF	PITFALL
		
		EBANK=	LST1		# RESTART USES E0,E3
GOBB		BBCON	GOPROG

		EBANK=	PERROR
T6ADR		2CADR	DOT6RUPT

		EBANK=	LST1
T3RPTBB		BBCON	T3RUPT

		EBANK=	KEYTEMP1
KEYRPTBB	BBCON	KEYRUPT1

		EBANK=	AOTAZ
MKRUPTBB	BBCON	MARKRUPT

UPRPTBB		=	KEYRPTBB

		EBANK=	DNTMBUFF
DWNRPTBB	BBCON	DODOWNTM

		EBANK=	TTOGO
RDRPTBB		BBCON	RADAREAD

		EBANK=	M11
T4RPTBB		BBCON	T4RUPT

		EBANK=	ELVIRA
RUPT10BB	BBCON	PITFALL
				
