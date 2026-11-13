# ODYSSEY-AGC test ROM: PHASE-500
# Benchmark target ~500 Hz AGC sample rate (set by the delay loop; the ACHIEVED rate
# is measured by the host from AGC cycle timestamps -- it is not guaranteed).
# See PHASE-CORE.agc.  License: GNU GPL v2 or later.

$PHASE-CORE.agc

STEPW		OCT	00100			# phase increment per sample (pitch)
DLYCNTW		DEC	51			# delay-loop count (sample rate)
