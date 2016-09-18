# This is a Block 1 AGC program which I'm using just to test
# some specific instructions I'm confused about in yaAGCb1
# vs yaAGC-Block1.

		SETLOC	2030

START

# Test positive vs negative overflow in TS.
TSTEST		CAF	C30000
		AD	C30000
		TS	RESULT
		NOOP
		CAF	C50000
		AD	C50000
		TS	RESULT
		NOOP
		
# Test DV.
DVTESTPP	CAF	C4321
		EXTEND
		DV	C12345
		NOOP
		
DVTESTMP	CAF	C4321
		COM
		EXTEND
		DV	C12345
		NOOP
		
DVTESTPM	CAF	C4321
		EXTEND
		DV	CM12345
		NOOP
		
DVTESTMM	CAF	C4321
		COM
		EXTEND
		DV	CM12345
		NOOP
		
# All done.
		TC	START
		
# Constants and variables used by the program		
		
C12345		OCT	12345
C4321		OCT	4321
CM12345		OCT	65432
C30000		OCT	30000
C50000		OCT	50000

		SETLOC	5777
		XCADR	0

		SETLOC	60
		
RESULT		ERASE
