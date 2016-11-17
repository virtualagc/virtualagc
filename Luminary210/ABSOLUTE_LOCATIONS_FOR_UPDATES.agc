### FILE="Main.annotation"
## Copyright:   Public domain.
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. XXX-XXX
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Artemis072 version.

## NOTE: Page numbers below have yet to be updated from Artemis072 to Luminary210!

## Page 36
# ABSOLUTE LOCATIONS FOR UPDATES

# ECADR			MNEMONIC
# -----			--------
		=ECADR	UPSVFLAG	# CSM/LM STATE VECTOR UPDATE
		
		=ECADR	XSMD		# DESIRED REFSMMAT UPDATE

		=ECADR	REFSMMAT	# REFSMMAT UPDATE
		
		=ECADR	DELVSLV		# EXTERNAL DELTA-V UPDATE
		
		=ECADR	LAT(SPL)	# RETROFIRE EXT DELTA-V OR ENTRY UPDATE
		
		=ECADR	TIG		# LAMBERT TARGET UPDATE
		
		=ECADR	RLS		# LANDING SITE VECTOR UPDATE
