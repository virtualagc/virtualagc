### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    ABSOLUTE_ADDRESSES_FOR_UPDATE_PROGRAM.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   p. 1
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Artemis072 version.
##		2016-11-18 RSB	Transcribed
##		2016-12-15 RSB	Proofed comment text with octopus/ProoferComments,
##				and corrected the errors found.

## Page 1
# ECADR			MNEMONIC
# -----			--------
		=ECADR	UPSVFLAG
		
		=ECADR	XSMD

		=ECADR	REFSMMAT
		
		=ECADR	DELVSLV	
	
		=ECADR	RLS
