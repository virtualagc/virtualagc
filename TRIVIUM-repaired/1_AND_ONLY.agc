### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    1_AND_ONLY.agc
## Purpose:     Source code for TRIVIUM, a demonstration
##	       	Block I AGC program for the YUL assembler,
##		with the intentional and unintended coding
##		errors repaired.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     https://www.ibiblio.org/apollo/index.html
## Page Scans:  http://www.ibiblio.org/apollo/ScansForConversion/TRIVIUM/
## Pages:	1-1
## Mod history: 2018-10-20 RSB  Created.

## Page 1

#          CANONICAL PROBLEM FOR AGC4: TO PLACE IN REGISTER HOUSTON THE NUMBER OF ONES IN REGISTER HUNTSVIL, USING
# THE LEAST NUMBER OF LOCATIONS AND ASSUMING THAT NO REGISTERS NEED BE SAVED.  THIS SOLUTION, REQUIRING 10 IN-
# STRUCTIONS AND TWO CONSTANTS, IS THE BEST KNOWN TO DATE.


# MISCELLANEOUS DEFINITIONS AND CONSTANTS HERE.  ENTER ROUTINE AT WERNER.

LP		=	3
HOUSTON		EQUALS	14
## The following line was not present in the original program.
HUNTSVIL	EQUALS	15

		SETLOC	5776
		
ONE		OCT	1
		4	7777
		
		
		SETLOC	2888D
		
WERNER		CAF	ONE
		EXTEND			# NOTICE THAT THIS IS INDEX 5777.
		MP	HUNTSVIL	# ZERO TO A, C(HUNTSVIL) TO LP.
		
## The label VON was misaligned in the original program.
VON		TS	HOUSTON		# ZERO COUNT (INITIALLLY), ACCUMULATE COUNT
					#  (SUBSEQUENTLY).
		CCS	LP		# EXAMINE AND CLEAR BIT 15 (FIRST TIME).
					# SUBSEQUENTLY, DO BITS 1-14 IN ORDER.
## The opcode TC was misaligned in the original program.
		TC	-1		# IF BIT=0 BUT C(LP) NON-ZERO, LOOK AGAIN.
		TC	BRAUN +1	# EXIT WHEN C(LP) EXHAUSTED.
		XCH	HOUSTON		# SET UP INCREMENT IF BIT=1.
## The operand ONE was misaligned in the original program.
		AD	ONE		# C(LP) CAN BE -0 FIRST TIME ONLY.
BRAUN		TC	VON
