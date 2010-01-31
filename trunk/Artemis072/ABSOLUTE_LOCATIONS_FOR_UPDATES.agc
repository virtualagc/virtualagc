### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	ABSOLUTE_LOCATIONS_FOR_UPDATES.agc
## Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
##		build 072.  This is for the Command Module's (CM) 
##		Apollo Guidance Computer (AGC), we believe for 
##		Apollo 15-17.
## Assembler:	yaYUL
## Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
## Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
## Mod history:	2009-07-29 OH	New file created.
##		2009-09-01 JL	Commented out =ECADR directives, see note below.
##		2009-09-03 JL	Uncommented =ECADR directives, after modifying yaYUL to skip them.

## Page 36
# ABSOLUTE LOCATIONS FOR UPDATES

## (JL 2009-09-01: The =ECADR directive doesn't seem to produce any binary, define any symbols, 
## or allocate any memory. It appears to be there to create a convenient reference table of 
## certain addresses.)

# ECADR			MNEMONIC
# -----			--------
		=ECADR	UPSVFLAG	# CSM/LM STATE VECTOR UPDATE
		
		=ECADR	XSMD		# DESIRED REFSMMAT UPDATE

		=ECADR	REFSMMAT	# REFSMMAT UPDATE
		
		=ECADR	DELVSLV		# EXTERNAL DELTA-V UPDATE
		
		=ECADR	LAT(SPL)	# RETROFIRE EXT DELTA-V OR ENTRY UPDATE
		
		=ECADR	TIG		# LAMBERT TARGET UPDATE
		
		=ECADR	RLS		# LANDING SITE VECTOR UPDATE
