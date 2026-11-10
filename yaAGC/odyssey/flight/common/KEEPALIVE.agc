# ODYSSEY-AGC common include: KEEPALIVE
#
# Purpose:  Every ODYSSEY AGC program must keep the emulated AGC's hardware
#           watchdogs satisfied, or the engine performs a GOJAM restart (and the
#           host counts it in alarm_restarts).  This file provides, once, for
#           all programs:
#
#             * the standard interrupt vector table starting at 04000,
#             * a periodic T3RUPT (TIME3 overflow, every ~40 ms) that
#               - gives the Rupt Lock / NoRupt watchdog its interrupt, and
#               - touches NEWJOB (address 067) for the Night Watchman,
#             * the register symbols the handler needs.
#
#           The TC Trap watchdog cannot be handled here: the PROGRAM's main code
#           must, within every 5 ms (~430 machine cycles), execute at least one
#           TC/TCF AND at least one non-TC instruction.  A loop made only of
#           TCF, or of no TC/TCF at all, trips it.  See
#           docs/AGC-PROGRAMMING-RULES.md.
#
# Usage:    Put   $KEEPALIVE.agc   at the very top of a program, and define a
#           label MAIN for the program's entry point.  Do not use SETLOC 4000
#           again.  Entry begins with interrupts inhibited; MAIN should RELINT.
#
# Modelled on the periodic-TIME3 pattern in Validation/Validation.agc and
# Validation/Interrupts.agc (VirtualAGC).
#
# License:  GNU GPL v2 or later (same as VirtualAGC).

A		EQUALS	0			# accumulator, needed by CCS A
ARUPT		EQUALS	10			# A/L saved on interrupt entry
QRUPT		EQUALS	12			# Q saved on interrupt entry
TIME3		EQUALS	26			# T3RUPT timer (overflow -> T3RUPT)
NEWJOB		EQUALS	67			# any access resets the Night Watchman

		SETLOC	4000
		INHINT				# GOJAM entry: no interrupts yet
		CAF	KA37774			# first T3RUPT after 4 x 10 ms
		TS	TIME3
		TCF	MAIN			# program entry (RELINT there)

		RESUME				# T6RUPT   (04004)
		NOOP
		NOOP
		NOOP

		RESUME				# T5RUPT   (04010)
		NOOP
		NOOP
		NOOP

		DXCH	ARUPT			# T3RUPT   (04014): save A, L, Q
		EXTEND
		QXCH	QRUPT
		TCF	T3HAND

		RESUME				# T4RUPT   (04020)
		NOOP
		NOOP
		NOOP

		RESUME				# KEYRUPT1 (04024)
		NOOP
		NOOP
		NOOP

		RESUME				# KEYRUPT2 (04030)
		NOOP
		NOOP
		NOOP

		RESUME				# UPRUPT   (04034)
		NOOP
		NOOP
		NOOP

		RESUME				# DOWNRUPT (04040)
		NOOP
		NOOP
		NOOP

		RESUME				# RADARUPT (04044)
		NOOP
		NOOP
		NOOP

		RESUME				# RUPT10   (04050)
		NOOP
		NOOP
		NOOP

T3HAND		CAF	KA37774			# schedule the next T3RUPT
		TS	TIME3
		CS	NEWJOB			# touch NEWJOB: appease Night Watchman
		DXCH	ARUPT			# restore A, L, Q
		EXTEND
		QXCH	QRUPT
		RESUME

KA37774		OCT	37774
