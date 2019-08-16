### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ABSOLUTE_LOCATIONS_FOR_UPDATES.agc
## Purpose:     A section of Artemis revision 071.
##              It is part of the reconstructed source code for the first
##              release of the flight software for the Command Module's
##              (CM) Apollo Guidance Computer (AGC) for Apollo 15 through
##              17. The code has been recreated from a copy of Artemis 072.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Artemis 071 in NASA
##              drawing 2021154-, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   36
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Artemis 072.

## Page 36
# ECADR			MNEMONIC
# -----			--------
		=ECADR	UPSVFLAG	# CSM/LM STATE VECTOR UPDATE
		
		=ECADR	XSMD		# DESIRED REFSMMAT UPDATE

		=ECADR	REFSMMAT	# REFSMMAT UPDATE
		
		=ECADR	DELVSLV		# EXTERNAL DELTA-V UPDATE
		
		=ECADR	LAT(SPL)	# RETROFIRE EXT DELTA-V OR ENTRY UPDATE
		
		=ECADR	TIG		# LAMBERT TARGET UPDATE
		
		=ECADR	RLS		# LANDING SITE VECTOR UPDATE
