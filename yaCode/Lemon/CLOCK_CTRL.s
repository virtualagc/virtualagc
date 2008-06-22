# Copyright:	Public domain.
# Filename:	CLOCK_CTRL.s
# Purpose:	Provide the basic Main programming Entry
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:
# Mod history:	08/06/07 OH.	Initial Version
#

CLKCTL	CAF	ROLLSEC		# Check for Seconds roll over
		LXCH	A
		CAE	SECS
		EXTEND
		SU	L
		EXTEND
		BZMF	EXTCLK
		INHINT			# Watch out for shared memory
		CAE	ZERO
		XCH	SECS		# Roll over Seconds
		RELINT
CHECK	INCR	MINS		# Increment Minutes
		CAF	ROLLMIN
		LXCH	A
		CAE	MINS
		EXTEND
		SU	L
		EXTEND
		BZMF	EXTCLK		# Check for Minute roll over
		CAE	ZERO
		XCH	MINS		# Clear Minutes
		INCR	HRS		# Increment HOurs
		CAF	ROLLHRS
		LXCH	A
		EXTEND
		SU	L		# Check for Hour Roll over
		EXTEND
		BZMF	EXTCLK
		CAE	ZERO
		XCH	HRS		# Clear Hours
EXTCLK	RETURN

ROLLSEC		OCT	74
ROLLMIN		OCT	74
ROLLHRS		OCT	30
