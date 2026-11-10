# ODYSSEY-AGC test ROM: PHASE-2K
# Benchmark target ~2 kHz AGC sample rate (set by the delay loop; the ACHIEVED rate
# is measured by the host from AGC cycle timestamps -- it is not guaranteed).
# See PHASE-CORE.agc.  License: GNU GPL v2 or later.

$PHASE-CORE.agc

STEPW		OCT	00100			# phase increment per sample (pitch)
DLYCNTW		DEC	9			# delay-loop count (sample rate)
