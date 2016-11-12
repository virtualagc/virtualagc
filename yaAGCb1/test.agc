# This is a Block 1 AGC program which I'm using just to test
# some specific instructions I'm confused about in yaAGCb1
# vs yaAGC-Block1.

		SETLOC	2030

START

# Test CCS CYR
		CAF	C12345
		TS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		CCS	CYR
		NOOP
		NOOP
		NOOP
		NOOP

# Test positive vs negative overflow in TS.
TSTEST		CAF	C30000
		AD	C30000
		TS	RESULT
		NOOP
		CAF	C50000
		AD	C50000
		TS	RESULT
		NOOP
		
# Test DV under various conditions.
# Positive dividend and divisor.
DVTESTPP	CAF	C4321
		EXTEND
		DV	C12345
		NOOP
		
# Negative dividend and positive divisor.
DVTESTMP	CAF	C4321
		COM
		EXTEND
		DV	C12345
		NOOP
		
# Positive dividend and negative divisor.
DVTESTPM	CAF	C4321
		EXTEND
		DV	CM12345
		NOOP
		
# Negative dividend and divisor.
DVTESTMM	CAF	C4321
		COM
		EXTEND
		DV	CM12345
		NOOP

# Positive-overflow dividend and positive divisor.
DVTSTOPP	CAF	C4321
		AD	POSMAX
		EXTEND
		DV	C12345
		NOOP
		
# Negative-overflow dividend and positive divisor.
DVTSTOMP	CAF	C4321
		COM
		AD	POSMAX
		EXTEND
		DV	C12345
		NOOP
		
# Positive-overflow dividend and negative divisor.
DVTSTOPM	CAF	C4321
		AD	POSMAX
		EXTEND
		DV	CM12345
		NOOP
		
# Negative-overflow dividend and negative divisor.
DVTSTOMM	CAF	C4321
		COM
		AD	POSMAX
		EXTEND
		DV	CM12345
		NOOP

# Behavior of COM on overflow.
COMTEST		CAF	C4321
		COM
		NOOP
		CAF	CM12345
		COM
		NOOP
		CAF	C4321
		AD	POSMAX
		COM
		NOOP
		CAF	CM12345
		COM
		NOOP

# All done.
		TC	START
		
# Constants and variables used by the program		

CYR		=	20
POSMAX		OCT	37777
C12345		OCT	12345
C4321		OCT	4321
CM12345		OCT	65432
C30000		OCT	30000
C50000		OCT	50000

		SETLOC	5777
		XCADR	0

		SETLOC	60
		
RESULT		ERASE
