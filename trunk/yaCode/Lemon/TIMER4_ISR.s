# Copyright:	Public domain.
# Filename:	TIMER4ISR.s
# Purpose:	Provide the basic Timer 4 Handler
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:	
# Mod history:	08/06/07 OH	Initial Version
#

T4ISR		XCH	ARUPT		# Backup A register
		CA	ONESEC		# Load A with 100ms ticks for 1 sec. interrupt
		XCH	TIME4		# Store A in Timer 4 register (Reset Timer4)
		INCR	SECS		# Increment Second Clock by 1
T4EXIT		XCH	ARUPT		# Restore A register
		RELINT			# Allow Interrupts
		RESUME			# Return from Interrupt Handler

ONESEC		DEC	16284		# 100ms ticks remain till overflow
