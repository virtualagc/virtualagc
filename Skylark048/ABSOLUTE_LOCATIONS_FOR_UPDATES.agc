### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	ABSOLUTE_LOCATIONS_FOR_UPDATES.agc
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
##		2024-02-27 MAS  Updated for Skylark 48.

# ECADR			MNEMONIC
# -----			--------
		=ECADR	UPSVFLAG	# CSM/LM STATE VECTOR UPDATE
		
		=ECADR	XSMD		# DESIRED REFSMMAT UPDATE

		=ECADR	REFSMMAT	# REFSMMAT UPDATE
		
		=ECADR	DELVSLV		# EXTERNAL DELTA-V UPDATE
		
		=ECADR	LAT(SPL)	# RETROFIRE EXT DELTA-V OR ENTRY UPDATE
