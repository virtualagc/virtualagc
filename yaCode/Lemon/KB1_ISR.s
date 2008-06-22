# Copyright:	Public domain.
# Filename:	KB1_ISR.s
# Purpose:	Provide the Keyboard interrupt handler
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:	
# Mod history:	08/06/07 OH.	Initial Version
#

KB1ISR		XCH	ARUPT		# Backup A register
		EXTEND
		READ	MNKEYIN		# Read the Main Keyboard Channel
		XCH	LASTKEY		# Store the Pressed Key
		CAF	KRSET		# Check if Reset Key is Pressed
		EXTEND
		SU	LASTKEY
		EXTEND
		BZF	RSTCLK
		TCF	KB1EXIT		# Other Key Pressed
RSTCLK		CAE	ZERO		# Clear Clock values	
		TS	SECS
		TS	MINS
		TS	HRS
KB1EXIT		XCH	ARUPT		# Restore Registers
		RELINT
		RESUME			# Return from ISR

KRSET		OCT	22		# 100ms ticks remain till overflow
