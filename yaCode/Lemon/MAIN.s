# Copyright:	Public domain.
# Filename:	MAIN.s
# Purpose:	Provide the basic Main programming Entry
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:
# Mod history:	08/06/07 OH	Initial Version
#

		SETLOC	4100

MAIN	CA	ZERO		# Load 0 value in A register
		XCH	SECS		# Set Clock to 0.
		CA	ONESEC		# Load Ticks for 1 second interrupts
		XCH	TIME4		# Now first set the Timer 4 register
		RELINT			# Allow for Interrupts to occur

BEGIN	TCR	CLKCTL		# Call the Clock Control Subroutine
		TCR	DISPCTL		# Call the Display COntrol Subroutine
		TCF	BEGIN		# Restart Clock examination
