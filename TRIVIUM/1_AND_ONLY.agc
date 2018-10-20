### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    1_AND_ONLY.agc
## Purpose:     Source code for TRIVIUM, a demonstration
##	       	Block I AGC program for the YUL assembler.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     https://www.ibiblio.org/apollo/index.html
## Page Scans:  http://www.ibiblio.org/apollo/ScansForConversion/TRIVIUM/
## Pages:	1
## Mod history: 2018-10-20 RSB  Created.

## Page 1

#          CANONICAL PROBLEM FOR AGC4: TO PLACE IN REGISTER HOUSTON THE NUMBER OF ONES IN REGISTER HUNTSVIL, USING
# THE LEAST NUMBER OF LOCATIONS AND ASSUMING THAT NO REGISTERS NEED BE SAVED.  THIS SOLUTION, REQUIRING 10 IN-
# STRUCTIONS AND TWO CONSTANTS, IS THE BEST KNOWN TO DATE.


# MISCELLANEOUS DEFINITIONS AND CONSTANTS HERE.  ENTER ROUTINE AT WERNER.

LP		=	3
HOUSTON		EQUALS	14

		SETLOC	5776
		
ONE		OCT	1
		4	7777
		
		
		SETLOC	2888D
		
WERNER		CAF	ONE
		EXTEND			# NOTICE THAT THIS IS INDEX 5777.
## In the original program, the variable HUNTSVIL is not defined, thus generating an error at 
## assembly-time and demonstrating YUL's error handling. Various oddities in columnar 
## alignment (pointed out where they appear below) are not treated as errors, and are presumably
## present to demonstrate that fact.
		MP	HUNTSVIL	# ZERO TO A, C(HUNTSVIL) TO LP.
		
## In the following line, note the peculiar alignment of the label VON.  This was not an
## error for the original assembler, YUL, but is an error for the modern assembler, yaYUL.
  VON		TS	HOUSTON		# ZERO COUNT (INITIALLLY), ACCUMULATE COUNT
					#  (SUBSEQUENTLY).
		CCS	LP		# EXAMINE AND CLEAR BIT 15 (FIRST TIME).
					# SUBSEQUENTLY, DO BITS 1-14 IN ORDER.
## In the following line, notice the unusual alignment of the TC opcode. This was not 
## an error for the original assembler, YUL, but is an error for the modern assembler,
## yaYUL.
		   TC	-1		# IF BIT=0 BUT C(LP) NON-ZERO, LOOK AGAIN.
		TC	BRAUN +1	# EXIT WHEN C(LP) EXHAUSTED.
		XCH	HOUSTON		# SET UP INCREMENT IF BIT=1.
## In the following line, notice the misalignment of the constant ONE.  This was not an error
## for the original assembler, YUL, nor for the modern assembler, yaYUL.
		AD	 ONE		# C(LP) CAN BE -0 FIRST TIME ONLY.
BRAUN		TC	VON
