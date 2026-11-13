# ODYSSEY-AGC test ROM: PHASE-1K
# Benchmark target ~1 kHz AGC sample rate (set by the delay loop; the ACHIEVED rate
# is measured by the host from AGC cycle timestamps -- it is not guaranteed).
# See PHASE-CORE.agc.  License: GNU GPL v2 or later.

$PHASE-CORE.agc

STEPW		OCT	00100			# phase increment per sample (pitch)
DLYCNTW		DEC	23			# delay-loop count (sample rate)
