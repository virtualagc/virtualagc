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
			

