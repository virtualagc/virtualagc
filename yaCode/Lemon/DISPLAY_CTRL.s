# Copyright:	Public domain.
# Filename:	DISPLAY_CTRL.s
# Purpose:	Provide the basic Display functionality
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:
# Mod history:	08/06/07 OH.	Initial Version
#

DISPCTL	CAE		SECS		# Strobe the Comp Activity
		MASK 		MSKBIT1
		XCH		CYL		# Cycle bit Left
		CAE		CYL
		EXTEND
		WRITE		DSALMOUT	# Write to DSKY
EXTDSPC	RETURN

MSKBIT1		OCT		1
