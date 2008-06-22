# Copyright:	Public domain.
# Filename:	VECTOR_TABLE.s
# Purpose:	Provide the basic interrup vectoring
# Assembler:	yaYUL
# Reference:	None
# Contact:	Onno Hommes
# Website:
# Mod history:	08/06/07 OH	Initial Version
#

		SETLOC	4000

RESET	INHINT			# 4000
		NOOP
		NOOP
		TCF	MAIN

T6INT	NOOP			# 4004
		NOOP
		NOOP
		RESUME

T5INT	NOOP			# 4010
		NOOP
		NOOP
		RESUME

T3INT	NOOP			# 4014
		NOOP
		NOOP
		RESUME

T4INT	INHINT			# 4020
		NOOP
		NOOP
		TCF	T4ISR

KB1INT	NOOP			# 4024
		NOOP
		NOOP
		TCF	KB1ISR

KB2INT	NOOP			# 4030
		NOOP
		NOOP
		RESUME

UPINT	NOOP			# 4034
		NOOP
		NOOP
		RESUME

DNINT	NOOP			# 4040
		NOOP
		NOOP
		RESUME

RDRINT	NOOP			# 4044
		NOOP
		NOOP
		RESUME

JOYINT	NOOP			# 4050
		NOOP
		NOOP
		RESUME
