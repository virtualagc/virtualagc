# This is just a little program for testing concepts in yaYUL.
# At the moment, the concept it's testing is the SECSIZ
# pseudo-op.

A		EQUALS	0

		BLOCK	2
		SECSIZ	25
FIRST		AD	A
		AD	A
		
		BLOCK	3
		SECSIZ	64
SECOND		XCH	A
		BANK
		SECSIZ	6
SECONDB		AD	A
		
		SETLOC	FIRST
		BANK
		SECSIZ	12
THIRD		AD	A

		BLOCK	3
		SECSIZ	14
FOURTH		AD	A

		BLOCK	3
		SECSIZ	31
FIFTH		AD	A

		BANK	2
		SECSIZ	17
SIXTH		AD	A
		BANK
		SECSIZ	18
SEVENTH		AD	A
			
# Test for issue #1072
A = 0
L = 1
Q = 2

	BLOCK 0
L1	ERASE 1

	BLOCK 2
C1	RETURN

	BLOCK 0
L2	ERASE

	BLOCK 2
C2	RESUME

	BLOCK 0
L3	ERASE 2

	BLOCK 0
L4	ERASE

