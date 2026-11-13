# ODYSSEY-AGC test ROM core: PHASE-CORE
#
# Purpose:  Milestone 3 "audio proof".  An integer PHASE ACCUMULATOR computed
#           ENTIRELY BY THE AGC: each sample the AGC adds STEP to a 15-bit
#           one's-complement phase word and writes the phase to the ODYSSEY
#           audio channel (octal 0300).  Interpreted as a signed one's
#           complement number the phase ramps up and wraps through zero, so the
#           output is a crude SAWTOOTH.  The host does not compute any of it.
#
#           Pitch is set by STEP; sample rate by the delay loop (DLYCNT).
#           This file is not assembled by itself: PHASE-500.agc, PHASE-1K.agc
#           and PHASE-2K.agc include it and supply DLYCNT and STEP.
#
# NOTE:     Channel 0300 is an ODYSSEY EXTENSION, not an Apollo channel.
#
# License:  GNU GPL v2 or later (same as VirtualAGC).

PHASE		EQUALS	0100			# erasable: running phase word

$KEEPALIVE.agc

MAIN		RELINT				# interrupts on: T3RUPT keeps the watchdogs fed
		CAF	ZEROW
		TS	PHASE			# phase starts at +0

LOOP		CA	PHASE
		AD	STEPW			# phase += STEP (one's complement)
		TS	PHASE			# on overflow: skip next, A = +-1
		TCF	+1			# no overflow: fall to the CA below
		CA	PHASE			# (overflow path lands here too)
		EXTEND
		WRITE	0300			# emit the AGC-computed sample

		CAF	DLYCNTW			# pacing delay: ~3 cycles per pass
DELAY		CCS	A
		TCF	DELAY			# A > 0: A was decremented, loop
		TCF	LOOP			# A = +0: delay finished

ZEROW		OCT	00000
